<script>
import {
  CallRole,
  CallStatus,
  NAME,
  StoreName,
} from "@/uni_modules/Netease-Call/callkit/callServices/const/index";

let openNotificationListenerRegistered = false;
const LIVE_COMMUNICATION_KIT_CONFIG_KEY = "NECallKit_UTS_LiveCommunicationKit_Config";
const DEFAULT_VOIP_CER_NAME = "party_release_inhouse";
const DEFAULT_LIVE_COMMUNICATION_KIT_RINGTONE_NAME = "lck_incoming_ring.mp3";

export default {
  onLaunch: function () {
    // #ifdef APP-ANDROID
    // 获取当前主 Activity
    let main = plus.android.runtimeMainActivity();

    // 重写 quit 方法，使其不退出应用而是移入后台
    plus.runtime.quit = function() {
      // moveTaskToBack(false) 表示将任务移到后台，不显示最近任务列表中的动画
      main.moveTaskToBack(false);
    };

    // 可选：拦截“再按一次退出”，其他 toast 仍交给原生实现，避免 uni.showToast 递归触发 native toast。
    const nativeToast = plus.nativeUI.toast;
    plus.nativeUI.toast = function(str) {
      if (str == '再按一次退出应用') {
        main.moveTaskToBack(false);
        return false;
      }
      return nativeToast.call(plus.nativeUI, str);
    };
    // #endif
    console.log("App Launch");
    // 关闭启动画面，锁定竖屏 */
    plus.navigator.closeSplashscreen();
    plus.screen.lockOrientation("portrait-primary");
    
    let isActive = true;
    uni.onAppShow(() => {
      isActive = true;
    });
    uni.onAppHide(() => {
      isActive = false;
    });

    uni.$appIsActive = () => isActive;
    
    const app = getApp();
    let liveCommunicationKitConfig = {};
    try {
      liveCommunicationKitConfig =
        uni.getStorageSync(LIVE_COMMUNICATION_KIT_CONFIG_KEY) || {};
    } catch (error) {
      console.error("读取LiveCommunicationKit配置失败", error);
    }
    app.globalData = {
      timeout: 30,
      channelName: '',
      rtcUid: 0,
      supportAudioToVideo: true,
      supportVideoToAudio: true,
      audioToVideoConfirm: false,
      videoToAudioConfirm: false,
      enableFloatingWindow: true,
      enableAutoFloatingWindowWhenHome: false,
      enableIncomingBanner: false,
      liveCommunicationKitEnabled: liveCommunicationKitConfig.enabled === true,
      voipCerName: liveCommunicationKitConfig.voipCerName || DEFAULT_VOIP_CER_NAME,
      liveCommunicationKitRingtoneName:
        liveCommunicationKitConfig.ringtoneName || DEFAULT_LIVE_COMMUNICATION_KIT_RINGTONE_NAME,
      pushEnabled: true,
      pushTitle: '',
      pushContent: '',
      pushPayload: '',
      needBadge: true
    };
    this.registerOpenNotificationListener();
  },
  onShow: function () {
    console.log("App Show");
    uni?.$UIKitNIM?.V2NIMSettingService?.setAppBackground(false);
  },
  onHide: function () {
    console.log("App Hide");
    uni?.$UIKitNIM?.V2NIMSettingService?.setAppBackground(true);
  },
  methods: {
    registerOpenNotificationListener() {
      if (openNotificationListenerRegistered) {
        return;
      }
      openNotificationListenerRegistered = true;
      uni?.$NIMPushPlugin?.addOpenNotificationListener((result) => {
        if (typeof result === 'object') {
          console.log('=====addOpenNotificationListener success:', JSON.stringify(result))

          const callInfo = JSON.parse(result.nertcCallkit);
          const isIOS = uni.getSystemInfoSync().platform === "ios";
          let nativeCallInfo = null;
          if (isIOS) {
            if (uni.$NECallKit?.recoverConnectedCallPageFromNative?.("notification")) {
              return;
            }
            nativeCallInfo = uni.$NECallKit?.getCallInfo?.();
            const nativeCallStatus = Number(nativeCallInfo?.callStatus ?? 0);
            if (nativeCallStatus !== 2 && nativeCallStatus !== 3) {
              console.log(
                '=====addOpenNotificationListener ignore stale call push, nativeCallStatus:',
                nativeCallStatus
              );
              return;
            }
          }
          let updateStoreParams = {
            [NAME.CALL_ROLE]: CallRole.CALLEE,
            [NAME.CALL_STATUS]: CallStatus.CALLING,
            [NAME.MEDIA_TYPE]: nativeCallInfo?.callType ?? callInfo.callType,
            [NAME.CALLER_USER_INFO]: nativeCallInfo?.callerInfo?.accId ?? callInfo.accId,
          };
          uni.$NEStore.updateStore(updateStoreParams, StoreName.CALL);

          if (getApp().globalData?.enableFloatingWindow === false) {
            uni.$NECallKit._navigateToCallPage();
          }
        } else {
          console.log('=====addOpenNotificationListener unexpected:', result)
        }
      });
    },
  },
};
</script>

<style>
</style>
