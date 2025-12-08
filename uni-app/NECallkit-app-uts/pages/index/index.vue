<template>
  <view class="container">
    <view class="guide-box">
      <view class="top">
        <view class="top-bar">
          <image class="top-bar-left" mode="aspectFit" src="../../static/yunxin_logo.png" role="img"></image>
          <image class="top-bar-right" @click="logout" mode="aspectFit" src="../../static/account_circle.png"
            role="img"></image>
        </view>
        <view class="single-box" v-for="(item, index) in entryInfos" :key="index" :id="index" @click="handleEntry">
          <view class="left">
            <image class="icon" mode="aspectFit" :src="item.icon" role="img"></image>
            <view class="label">{{ item.title }}</view>
          </view>
          <image class="icon-right" mode="aspectFit" src="../../static/light_right_arrow.png" role="img"></image>
        </view>
      </view>
      <view class="bottom">
        <view>NIM sdk version:{{ nimVersion }}</view>
        <view>CallKit version:{{ uni.$NECallKit.getVersion() }}</view>
        <view>本APP仅用于展示网易云信实时音视频各类功能</view>
      </view>
    </view>
  </view>
</template>

<script setup>
import NIM from "nim-web-sdk-ng/dist/v2/NIM_UNIAPP_SDK";
import { useUserStore } from "@/stores/user";

const user = useUserStore();

const entryInfos = [
  {
    icon: "../../static/video_call_icon.png",
    title: "一对一音视频通话",
    desc: "",
    navigateTo: "../call/call",
  },
];
const nimVersion = NIM.sdkVersionFormat;

const logout = () => {
  uni.showModal({
    title: "退出账号：" + user.userID,
    content: "是否退出当前账号？",
    success: (res) => {
      if (res.confirm) {
        user.logout();
      }
    },
  });
};

const handleEntry = (e) => {
  const url = entryInfos[e.currentTarget.id].navigateTo;
  uni.navigateTo({ url });
};
</script>

<style scoped>
  .container {
    background-image: url(../../static/main_bg.png);
    background-repeat: no-repeat;
    background-size: cover;
    width: 100vw;
    height: 100vh;
    display: flex;
    flex-direction: column;
    align-items: center;
    box-sizing: border-box;
    padding-top: 40px;
  }

  .container .title {
    position: relative;
    width: 100vw;
    font-size: 18px;
    color: #000000;
    letter-spacing: 0;
    text-align: center;
    line-height: 28px;
    font-weight: 600;
    background: #ffffff;
    margin-top: 3.8vh;
    padding: 1.2vh 0;
  }

  .tips {
    color: #ffffff;
    font-size: 12px;
    text-align: center;
  }

  .guide-box {
    width: 100vw;
    box-sizing: border-box;
    padding: 16px;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    flex: auto;
  }

  .top {
    flex: auto;
    display: flex;
    flex-direction: column;
  }

  .top-bar {
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 24px;
  }

  .top-bar-left {
    width: 212px;
    height: 27px;
    flex: none;
  }

  .top-bar-right {
    height: 22px;
    width: 22px;
    flex: none;
  }

  .bottom {
    flex: none;
    display: flex;
    flex-direction: column;
    align-items: center;
    color: #fff;
    padding-bottom: 35px;
  }

  .single-box {
    border-radius: 16px;
    background-color: rgba(39, 43, 70, 0.8);
    margin-bottom: 16px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 20px;
  }

  .left {
    display: flex;
    align-items: center;
    flex: auto;
  }

  .icon {
    width: 48px;
    height: 48px;
    flex: none;
    margin-right: 14px;
  }

  .icon-right {
    width: 16px;
    height: 16px;
    flex: none;
    margin-left: 14px;
  }

  .single-content {
    padding: 36px 30px 36px 20px;
    color: #333333;
  }

  .label {
    flex: auto;
    font-size: 18px;
    font-weight: 500;
    color: #fff;
    letter-spacing: 0;
  }

  .desc {
    display: block;
    font-size: 14px;
    color: #333333;
    letter-spacing: 0;
    font-weight: 500;
  }

  .logo-box {
    position: absolute;
    width: 100vw;
    bottom: 36rpx;
    text-align: center;
  }

  .logo {
    width: 160rpx;
    height: 44rpx;
  }
</style>