<template>
  <view class="container-box">
    <call-view  />
  </view>
</template>

<script>
export default {
  onUnload() {
    // 这里用户自行业务判断，是否需要挂断通话
    const app = getApp();
    const neCall = app.globalData.neCall;
    neCall.hangup();
  },
}
</script>

<style>
.container-box {
  background-image: url(https://yx-web-nosdn.netease.im/quickhtml%2Fassets%2Fyunxin%2Fdefault%2Fgroupcall%2Fbg.png);
  background-color: #333;
  background-repeat:no-repeat;
  background-size: cover;
  background-color: #1a1a23;
  height: 100vh;
  padding: 0 40rpx;
  box-sizing: border-box;
  color: #fff;
}
</style>
