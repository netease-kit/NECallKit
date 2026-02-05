<template>
  <view class="container">
    <view class="content-wrapper">
      <view class="header">
        <view class="header-center">
          <text class="header-title">一对一音视频通话</text>
        </view>
        <view class="header-right" @tap="logout">
          <text class="logout-text">退出登录</text>
        </view>
      </view>

      <view class="user-id-row">
        <text class="user-id-label">您的ID</text>
        <text class="user-id-value">{{ accountId }}</text>
      </view>

      <view class="search-row">
        <view class="input-box">
          <input 
            class="input-search" 
            v-model="imAccid" 
            maxlength="50" 
            type="text" 
            placeholder="请输入账号ID" 
          />
        </view>
        <view class="btn-call" @tap="startCall">
          <text class="btn-call-text">呼叫</text>
        </view>
      </view>

      <view class="call-type-row">
        <text class="call-type-label">呼叫类型</text>
        <radio-group class="call-type-group" @change="changeCallType">
          <label class="call-type-item">
            <radio :value="'2'" :checked="callType === '2'" />
            <text class="call-type-text">视频呼叫</text>
          </label>
          <label class="call-type-item">
            <radio :value="'1'" :checked="callType === '1'" />
            <text class="call-type-text">音频呼叫</text>
          </label>
        </radio-group>
      </view>
    </view>
  </view>
</template>

<script lang="ts">
import V2NIM from 'nim-web-sdk-ng/dist/v2/NIM_MINIAPP_SDK'
import { NECall } from '@xkit-yx/call-kit/miniprogram_dist/index'

type SignalControllerCallType = "1" | "2";

export default {
  data() {
    return {
      callType: "2" as SignalControllerCallType,
      imAccid: "",
      accountId: "",
    };
  },
  
  async onLoad() {
    await this.checkLogin();
  },
  
  methods: {
    async checkLogin() {
      const app = getApp();
      
      if (app.globalData && app.globalData.isLoggedIn) {
        this.accountId = app.globalData.accountId;
        return;
      }

      const userConfig = uni.getStorageSync('userConfig');
      if (userConfig && userConfig.accountId && userConfig.token) {
        try {
          const appkey = app.globalData.appkey;
          
          const nim = V2NIM.getInstance({
            appkey,
            account: userConfig.accountId,
            token: userConfig.token,
            apiVersion: 'v2',
            debugLevel: 'debug',
          });

          await nim.V2NIMLoginService.login(userConfig.accountId, userConfig.token);

          const neCall = NECall.getInstance();
          neCall.setup({
            nim,
            appkey,
          });

          neCall?.on('onReceiveInvited', () => {
            uni.navigateTo({
              url: '/pages/call/call',
            });
          });

          app.globalData.nim = nim;
          app.globalData.neCall = neCall;
          app.globalData.accountId = userConfig.accountId;
          app.globalData.isLoggedIn = true;
          
          this.accountId = userConfig.accountId;
        } catch (err) {
          console.error('自动登录失败:', err);
          uni.removeStorageSync('userConfig');
          uni.redirectTo({ url: '/pages/login/login' });
        }
      } else {
        uni.redirectTo({ url: '/pages/login/login' });
      }
    },
    
    changeCallType(e: any) {
      this.callType = e.detail.value as SignalControllerCallType;
    },
    
    async startCall() {
      if (!this.imAccid.trim()) {
        uni.showToast({
          title: '请输入账号ID',
          icon: 'none'
        });
        return;
      }

      if (this.accountId === this.imAccid.trim()) {
        uni.showToast({
          title: '不能呼叫自己',
          icon: 'none'
        });
        return;
      }
      
      try {
        const app = getApp<{ globalData: { neCall?: any } }>();
        
        if (app.globalData.neCall) {
          await app.globalData.neCall.call({
            callType: this.callType,
            accId: this.imAccid,
          });
          
          uni.navigateTo({
            url: '/pages/call/call'
          });
        } else {
          uni.showToast({
            title: '呼叫功能未初始化',
            icon: 'none'
          });
        }
      } catch (err: any) {
        console.error('呼叫失败:', err);
        uni.showToast({
          title: err.message || '呼叫失败',
          icon: 'none'
        });
      }
    },
    
    logout() {
      uni.showModal({
        title: '退出账号',
        content: '是否退出当前账号？',
        success: (res) => {
          if (res.confirm) {
            const app = getApp();
            
            if (app.globalData.neCall) {
              app.globalData.neCall.destroy();
            }
            
            if (app.globalData.nim) {
              app.globalData.nim.V2NIMLoginService.logout();
            }
            
            app.globalData.nim = null;
            app.globalData.neCall = null;
            app.globalData.accountId = '';
            app.globalData.isLoggedIn = false;
            
            uni.removeStorageSync('userConfig');
            
            uni.redirectTo({ url: '/pages/login/login' });
          }
        },
      });
    },
  }
};
</script>

<style scoped>
.container {
  width: 100vw;
  height: 100vh;
  overflow: hidden;
  margin: 0;
  padding-top: 80px;
  background-color: #1f1f26;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
}

.content-wrapper {
  flex: auto;
  display: flex;
  flex-direction: column;
  padding: 0 10px;
  background-color: #1f1f26;
}

.header {
  display: flex;
  flex-direction: row;
  padding: 10px 0;
  align-items: center;
  justify-content: space-between;
  color: white;
}

.header-left {
  flex: none;
  padding: 10rpx 20rpx;
}

.header-text {
  font-size: 28rpx;
  color: white;
}

.header-center {
  flex: auto;
  text-align: center;
}

.header-title {
  font-size: 32rpx;
  color: white;
  font-weight: 500;
}

.header-right {
  flex: none;
  padding: 10rpx;
}

.logout-text {
  font-size: 28rpx;
  color: #ff4757;
}

.user-id-row {
  display: flex;
  align-items: center;
  padding: 10px 0;
  color: rgba(255, 255, 255, 0.5);
}

.user-id-label {
  font-size: 28rpx;
}

.user-id-value {
  margin-left: 10px;
  font-size: 28rpx;
  color: rgba(255, 255, 255, 0.7);
}

.search-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-sizing: border-box;
  padding: 20px 0;
}

.input-box {
  flex: 1;
  box-sizing: border-box;
  margin-right: 20px;
  height: 80rpx;
  background: #f4f5f9;
  border-radius: 10px;
  padding: 18rpx 32rpx;
  display: flex;
  align-items: center;
}

.input-search {
  flex: 1;
  box-sizing: border-box;
  font-size: 32rpx;
  color: #333;
}

.btn-call {
  text-align: center;
  width: 120rpx;
  height: 80rpx;
  line-height: 80rpx;
  background: #337eff;
  border-radius: 10px;
}

.btn-call-text {
  color: white;
  font-size: 28rpx;
}

.call-type-row {
  display: flex;
  flex-direction: row;
  align-items: center;
  color: white;
  padding: 10px 0;
}

.call-type-label {
  font-size: 28rpx;
  color: white;
}

.call-type-group {
  margin-left: 30rpx;
  display: flex;
  flex-direction: row;
  align-items: center;
}

.call-type-item {
  display: flex;
  flex-direction: row;
  align-items: center;
  margin-right: 30rpx;
}

.call-type-text {
  font-size: 28rpx;
  color: white;
  margin-left: 10rpx;
}
</style>
