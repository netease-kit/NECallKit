import { defineStore } from "pinia";
import { useMessageStore } from "./message";
import { APP_CONFIG } from "@/config";

const onReceiveMessages = (msgs) => {
  const filterMsgs = msgs.filter((msg) => msg.messageType == 12);
  const messageStore = useMessageStore();
  messageStore.addMessages(filterMsgs);
}

export const useUserStore = defineStore("user", {
  state: () => ({ userID: "", loading: false, }),
  actions: {
    async login(userID, token) {
      this.loading = true;
      try {
        await uni.$UIKitNIM.V2NIMLoginService.login(userID, token);
    
        uni.$NECallKit.init({
          appKey: APP_CONFIG.appKey,
          params: { currentUserRtcUid: getApp().globalData.rtcUid },
        });
    
        uni.$NECallKit.login({
          accountId: userID,
          token,
          success: () => {
            console.log("login success");
            this.userID = userID;
    
            uni.$UIKitNIM.V2NIMMessageService.on("onReceiveMessages", onReceiveMessages);
    
            uni.redirectTo({ url: "/pages/index/index" });
            this.loading = false;
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
        console.error(`NIM登录失败, errCode=${err.code}, errMsg=${err.message}`);
      }
    },
    logout() {
      try {
        uni.$NECallKit.logout({
          success: () => {
            console.log("NECallKit退出成功");
            
            // 退出IM
            uni.$UIKitNIM.V2NIMLoginService.logout().then(() => {
              console.log("IM退出成功");
              
              uni.$UIKitNIM.V2NIMMessageService.off('onReceiveMessages', onReceiveMessages);
              
              const messageStore = useMessageStore();
              messageStore.clearMessages();
              uni.redirectTo({
                url: "/pages/login/login",
              });
            })
            .catch((err) => {
              console.log(
                `NIM退出失败, errCode = ${err.code}, errMsg = ${err.message}`
              );
              uni.showToast({
                title: 'NIM退出失败',
                position: "bottom",
              });
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
