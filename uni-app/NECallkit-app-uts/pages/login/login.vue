<template>
  <view class="container">
    <image class="background-image" src="../../static/background.svg"></image>
    <view class="counter-warp">
      <view class="header-content">
        <image style="width: 212px;height: 27px;" src="../../static/yunxin_logo.png"></image>
      </view>
      <view class="box">
        <view class="list-item">
          <label class="list-item-label">{{ "账号ID" }}</label>
          <input class="input-box" type="text" v-model="userID" maxlength="50" placeholder="请输入账号ID"
            placeholder-style="color:#BBBBBB;" />
        </view>
        <view class="list-item" style="margin-top: 15px;">
          <label class="list-item-label">{{ "Token" }}</label>
          <input class="input-box" type="text" v-model="token" maxlength="50" placeholder="请输入Token"
            placeholder-style="color:#BBBBBB;" />
        </view>
        <view class="login">
          <button class="loginBtn" @click="login" :loading="user.loading">
            {{ "登录" }}
          </button>
        </view>
        <view style="margin-top: 30px; text-align: center;">
          <uni-link
            href="https://doc.yunxin.163.com/messaging2/guide/jU0Mzg0MTU?platform=client#%E7%AC%AC%E4%BA%8C%E6%AD%A5%E6%B3%A8%E5%86%8C-im-%E8%B4%A6%E5%8F%B7"
            text="如何获取云信账号与Token" color="#007BFF"></uni-link>
        </view>
      </view>
    </view>
  </view>
</template>
<script setup>
import { ref } from "vue";
import { useUserStore } from "@/stores/user";

const user = useUserStore();

const userID = ref("");
const token = ref("");

const login = () => {
  if (!userID.value) {
    uni.showToast({
      title: "账号ID不能为空",
      position: "bottom",
    });
    return;
  }
  if (!token.value) {
    uni.showToast({
      title: "Token不能为空",
      position: "bottom",
    });
    return;
  }
  user.login(userID.value, token.value);
};
</script>

<style scoped>
  .container {
    width: 100vw;
    height: 100vh;
    background-color: #f4f5f9;
    position: fixed;
    top: 0;
    right: 0;
    left: 0;
    bottom: 0;
  }

  .counter-warp {
    position: absolute;
    top: 40px;
    right: 0;
    left: 0;
    width: 100%;
    height: 100%;
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .background-image {
    width: 100%;
  }

  .header-content {
    display: flex;
    width: 100vw;
    padding: 50px 10px 30px 10px;
    box-sizing: border-box;
    align-items: center;
    justify-content: center;
  }

  .icon-box {
    width: 56px;
    height: 56px;
    flex: none;
    border-radius: 4px;
  }

  .text-header {
    height: 72rpx;
    font-size: 48rpx;
    line-height: 72rpx;
    color: #ffffff;
    margin-left: 20px;
  }

  .text-content {
    height: 36rpx;
    font-size: 24rpx;
    line-height: 36rpx;
    color: #ffffff;
  }

  .box {
    width: 80%;
    height: 50vh;
    position: relative;
    background: #ffffff;
    border-radius: 4px;
    display: flex;
    flex-direction: column;
    justify-content: left;
    padding: 30px 20px;
  }

  .input-box {
    flex: 1;
    display: flex;
    font-family: PingFangSC-Regular;
    font-size: 14px;
    color: rgba(0, 0, 0, 0.8);
    letter-spacing: 0;
  }

  .login {
    display: flex;
    box-sizing: border-box;
    margin-top: 15px;
    width: 100%;
  }

  .login button {
    background: rgba(0, 110, 255, 1);
    border-radius: 30px;
    font-size: 16px;
    color: #ffffff;
    letter-spacing: 0;
    font-weight: 500;
  }

  .loginBtn {
    margin-top: 64px;
    background-color: white;
    border-radius: 24px;
    border-radius: 24px;
    width: 100% !important;
    font-family: PingFangSC-Regular;
    font-size: 16px;
    color: #ffffff;
    letter-spacing: 0;
  }

  .list-item {
    display: flex;
    flex-direction: column;
    font-family: PingFangSC-Medium;
    font-size: 14px;
    color: #333333;
    border-bottom: 1px solid #eef0f3;
  }

  .input-container {
    width: 90%;
    margin: 50px auto 0;
    display: flex;
    flex-direction: column;
    font-family: PingFangSC-Medium;
    font-size: 14px;
    color: #333333;
    border-bottom: 1px solid #eef0f3;
  }

  .list-item .list-item-label {
    font-weight: 500;
    padding: 10px 0;
  }

  .guide-box {
    width: 100vw;
    box-sizing: border-box;
    padding: 16px;
    display: flex;
    flex-direction: column;
  }

  .single-box {
    flex: 1;
    border-radius: 10px;
    background-color: #ffffff;
    margin-bottom: 16px;
    display: flex;
    align-items: center;
  }

  .icon {
    display: block;
    width: 180px;
    height: 144px;
  }

  .single-content {
    padding: 36px 30px 36px 20px;
    color: #333333;
  }

  .label {
    display: block;
    font-size: 18px;
    color: #333333;
    letter-spacing: 0;
    font-weight: 500;
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
</style>