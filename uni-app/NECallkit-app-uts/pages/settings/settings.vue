<template>
  <view class="container">
    <view
      style="flex:auto;display: flex;flex-direction: column;padding: 0 10px;background-color: #1f1f26;color: white;">
      <view
        style="display: flex;flex-direction: row;padding: 10px 0px;align-items: center;justify-content: space-between;">
        <view style="flex:none;" @click="handleCancle">
          取消
        </view>
        <view style="flex:auto;text-align: center;">
          设置
        </view>
        <view style="flex:none;" @click="handleSetting">
          完成
        </view>
      </view>

      <view style="display: flex;align-items: center;padding: 20px 0;margin-top: 20px;">
        <label>设置呼叫超时时间（秒）：</label>
        <view class="input-box" style="margin-left: 15px;">
          <input class="input-timeout" v-model="timeout" maxlength="10" type="number" />
        </view>
      </view>
      
      <view style="display: flex;align-items: center;padding: 20px 0;">
        <label>自定义channelName：</label>
        <view style="margin-left: 15px;width: 70px;height: 40px;display: flex;align-items: center;border-bottom: 1px solid white;">
          <input v-model="channelName" maxlength="50" type="text"/>
        </view>
      </view>
      
      <view style="display: flex;align-items: center;padding: 20px 0;">
        <label>自定义RtcUid（重新登录生效）：</label>
        <view style="margin-left: 15px;width: 70px;height: 40px;display: flex;align-items: center;border-bottom: 1px solid white;">
          <input v-model="rtcUid" maxlength="20" type="number"/>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
  export default {
    data() {
      return {
        timeout: getApp().globalData.timeout,
        channelName: getApp().globalData.channelName,
        rtcUid: getApp().globalData.rtcUid
      };
    },
    computed: {
      isValidTimeout() {
        const num = Number(this.timeout);
        return !isNaN(num) && num > 0;
      }
    },
    methods: {
      handleCancle() {
        uni.navigateBack();
      },
      handleSetting() {
        if (this.timeout != getApp().globalData.timeout) {
          if (this.isValidTimeout) {
            uni.$NECallKit.setTimeout(Number(this.timeout) * 1000);
            getApp().globalData.timeout = Number(this.timeout);
          } else {
            uni.showToast({
              title: "设置失败，超时时间必须大于0！",
              position: "bottom",
            });
            return;
          }
        }
        
        if (this.channelName !=  getApp().globalData.channelName) {
          getApp().globalData.channelName = this.channelName;
        }
        
        if (this.rtcUid != getApp().globalData.rtcUid) {
          getApp().globalData.rtcUid = Number(this.rtcUid);
          uni.navigateBack();
          uni.showToast({
            title: "设置成功，RtcUid需重新登录生效",
            position: "bottom",
          });
        } else {
          uni.navigateBack();
          uni.showToast({
            title: "设置成功",
            position: "bottom",
          });
        }
      },
    },
  };
</script>

<style scoped>
  .container {
    width: 100vw;
    height: 100vh;
    overflow: hidden;
    margin: 0;
    padding-top: 40px;
    background-color: black;
    box-sizing: border-box;
    display: flex;
    flex-direction: column;
  }

  .input-box {
    box-sizing: border-box;
    width: 100px;
    height: 40px;
    background: #393945;
    border-radius: 10px;
    padding: 10px 15px;
    display: flex;
    align-items: center;
  }

  .input-timeout {
    flex: 1;
    box-sizing: border-box;
  }

  .input-timeout[placeholder] {
    font-family: PingFangSC-Regular;
    font-size: 16px;
    color: #8a898e;
    letter-spacing: 0;
    font-weight: 400;
  }
</style>