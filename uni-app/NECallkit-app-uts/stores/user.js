import { defineStore } from "pinia";
import { useMessageStore } from "./message";
import { APP_CONFIG } from "@/config";
import {
  CallStatus,
  NAME,
  StoreName,
} from "@/uni_modules/Netease-Call/callkit/callServices/const/index";

const LOGIN_CACHE_KEY = "NECallKit_UTS_Login_Cache";
const ENABLE_WEB_NIM_LOGIN_AFTER_NATIVE = true;

const isCallPageActive = () => {
  const pages = getCurrentPages?.() || [];
  const currentPage = pages[pages.length - 1]?.route || "";
  return currentPage.indexOf("callkit/callPage") !== -1;
}

const isInCallFlow = () => {
  const callStatus = uni.$NEStore?.getData?.(StoreName.CALL, NAME.CALL_STATUS);
  return callStatus != null && callStatus !== CallStatus.IDLE;
}

const onReceiveMessages = (msgs) => {
  const filterMsgs = msgs.filter((msg) => msg.messageType == 12);
  const messageStore = useMessageStore();
  messageStore.addMessages(filterMsgs);
}

export const getLoginCache = () => {
  try {
    return uni.getStorageSync(LOGIN_CACHE_KEY) || null;
  } catch (error) {
    console.error("读取登录缓存失败", error);
    return null;
  }
}

const setLoginCache = (userID, token) => {
  try {
    uni.setStorageSync(LOGIN_CACHE_KEY, { userID, token });
  } catch (error) {
    console.error("保存登录缓存失败", error);
  }
}

const clearLoginCache = () => {
  try {
    uni.removeStorageSync(LOGIN_CACHE_KEY);
  } catch (error) {
    console.error("清理登录缓存失败", error);
  }
}

const resetLoginState = (store) => {
  try {
    uni.$UIKitNIM?.V2NIMMessageService?.off?.('onReceiveMessages', onReceiveMessages);
  } catch (error) {
    console.error("移除消息监听失败", error);
  }
  const messageStore = useMessageStore();
  messageStore.clearMessages();
  store.userID = "";
  clearLoginCache();
  uni.redirectTo({
    url: "/pages/login/login",
  });
}

export const useUserStore = defineStore("user", {
  state: () => ({ userID: "", loading: false, }),
  actions: {
    async login(userID, token) {
      this.loading = true;
      try {
        const globalData = getApp().globalData;
        uni.$NECallKit.init({
          appKey: APP_CONFIG.appKey,
          params: {
            currentUserRtcUid: globalData.rtcUid,
            voipCerName: globalData.voipCerName,
          },
          enableIncomingBanner: globalData.enableIncomingBanner,
          enableAutoFloatingWindowWhenHome: globalData.enableAutoFloatingWindowWhenHome,
          liveCommunicationKitConfig: {
            enabled: globalData.liveCommunicationKitEnabled === true,
            ringtoneName: globalData.liveCommunicationKitRingtoneName,
          },
        });
    
        uni.$NECallKit.login({
          accountId: userID,
          token,
          success: async () => {
            console.log("native login success");
            this.userID = userID;
            setLoginCache(userID, token);

            if (!isInCallFlow() && !isCallPageActive()) {
              uni.redirectTo({ url: "/pages/index/index" });
            }
            this.loading = false;

            if (ENABLE_WEB_NIM_LOGIN_AFTER_NATIVE) {
              try {
                console.log("[NECallKit Demo] web NIM login after native start");
                await uni.$UIKitNIM.V2NIMLoginService.login(userID, token);
                console.log("[NECallKit Demo] web NIM login after native success");
                uni.$UIKitNIM.V2NIMMessageService.on("onReceiveMessages", onReceiveMessages);
              } catch (err) {
                console.error(
                  `[NECallKit Demo] web NIM login after native failed, errCode=${err.code}, errMsg=${err.message}`
                );
                uni.showToast({ title: err.message, position: "bottom" });
              }
            }
          },
          fail: (errCode, errMsg) => {
            this.loading = false;
            uni.showToast({ title: errMsg, position: "bottom" });
            console.log(`NECallKit登录失败, errCode=${errCode}, errMsg=${errMsg}`);
          },
        });
      } catch (err) {
        this.loading = false;
        uni.showToast({ title: err.message, position: "bottom" });
        console.error(`登录失败, errCode=${err.code}, errMsg=${err.message}`);
      }
    },
    logout() {
      try {
        uni.$NECallKit.logout({
          success: () => {
            console.log("NECallKit退出成功");
            
            if (!ENABLE_WEB_NIM_LOGIN_AFTER_NATIVE) {
              resetLoginState(this);
              return;
            }

            // 退出IM
            uni.$UIKitNIM.V2NIMLoginService.logout().then(() => {
              console.log("IM退出成功");
              resetLoginState(this);
            })
            .catch((err) => {
              console.log(
                `NIM退出失败, errCode = ${err.code}, errMsg = ${err.message}`
              );
              uni.showToast({
                title: 'NIM退出失败',
                position: "bottom",
              });
              resetLoginState(this);
            });
          },
          fail: (errCode, errMsg) => {
            console.log(
              `NECallKit退出失败, errCode = ${errCode}, errMsg = ${errMsg}`
            );
            uni.showToast({
              title: 'NECallKit退出失败',
              position: "bottom",
            });
          },
        });
      } catch (error) {
        console.error("退出失败", error);
      }
    },
  },
});
