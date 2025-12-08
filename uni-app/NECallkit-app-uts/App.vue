<script>
import {
  CallRole,
  CallStatus,
  NAME,
  StoreName,
} from "@/uni_modules/Netease-Call/callkit/callServices/const/index";

export default {
  onLaunch: function () {
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
    app.globalData = {
      timeout: 30,
      channelName: '',
      rtcUid: 0
    };
  },
  onShow: function () {
    console.log("App Show");
    uni?.$UIKitNIM?.V2NIMSettingService?.setAppBackground(false);
    
    uni?.$NIMPushPlugin?.addOpenNotificationListener((result) => {
      if (typeof result === 'object') {
        console.log('=====addOpenNotificationListener success:', JSON.stringify(result))
        
        const callInfo = JSON.parse(result.nertcCallkit);
        let updateStoreParams = {
          [NAME.CALL_ROLE]: CallRole.CALLEE,
          [NAME.CALL_STATUS]: CallStatus.CALLING,
          [NAME.MEDIA_TYPE]: callInfo.callType,
          [NAME.CALLER_USER_INFO]: callInfo.accId,
        };
        uni.$NEStore.updateStore(updateStoreParams, StoreName.CALL);
        
        uni.$NECallKit._navigateToCallPage();
      } else {
        console.log('=====addOpenNotificationListener unexpected:', result)
      }
    });
  },
  onHide: function () {
    console.log("App Hide");
    uni?.$UIKitNIM?.V2NIMSettingService?.setAppBackground(true);
  },
};
</script>

<style>
</style>
