<template>
  <view class="container">
    <view class="counter-warp">
      <view class="header-content">
        <text class="header-title">网易云信</text>
      </view>
      <view class="box">
        <view class="list-item">
          <label class="list-item-label">账号ID</label>
          <input 
            class="input-box" 
            type="text" 
            v-model="accountId" 
            maxlength="50" 
            placeholder="请输入账号ID"
            placeholder-style="color:#BBBBBB;" 
          />
        </view>
        <view class="list-item" style="margin-top: 15px;">
          <label class="list-item-label">Token</label>
          <input 
            class="input-box" 
            type="text" 
            v-model="token" 
            maxlength="50" 
            placeholder="请输入Token"
            placeholder-style="color:#BBBBBB;" 
          />
        </view>
        <view class="login">
          <button class="loginBtn" @tap="login" :loading="loading">
            登录
          </button>
        </view>
        <view style="margin-top: 30px; text-align: center;">
          <text class="link-text" @tap="openGuide">如何获取云信账号与Token</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
import V2NIM from 'nim-web-sdk-ng/dist/v2/NIM_MINIAPP_SDK'
import { NECall } from '@xkit-yx/call-kit/miniprogram_dist/index'

export default {
  data() {
    return {
      accountId: '',
      token: '',
      loading: false,
    }
  },
  onLoad() {
    const app = getApp()
    if (app.globalData && app.globalData.isLoggedIn) {
      uni.redirectTo({ url: '/pages/index/index' })
    }
  },
  methods: {
    async login() {
      if (!this.accountId) {
        uni.showToast({
          title: '账号ID不能为空',
          icon: 'none',
        })
        return
      }
      if (!this.token) {
        uni.showToast({
          title: 'Token不能为空',
          icon: 'none',
        })
        return
      }

      this.loading = true
      uni.showLoading({ title: '登录中...' })

      try {
        const app = getApp()
        const appkey = app.globalData.appkey
        console.log('app.globalData:', app.globalData)
        console.log('appkey:', appkey)

        const nim = V2NIM.getInstance({
          appkey,
          account: this.accountId,
          token: this.token,
          apiVersion: 'v2',
          debugLevel: 'debug',
        })

        await nim.V2NIMLoginService.login(this.accountId, this.token)

        const neCall = NECall.getInstance()
        neCall.setup({
          nim,
          appkey,
        })

        neCall?.on('onReceiveInvited', () => {
          uni.navigateTo({
            url: '/pages/call/call',
          })
        })

        app.globalData.nim = nim
        app.globalData.neCall = neCall
        app.globalData.accountId = this.accountId
        app.globalData.isLoggedIn = true

        uni.setStorageSync('userConfig', {
          accountId: this.accountId,
          token: this.token,
        })

        uni.hideLoading()
        uni.showToast({
          title: '登录成功',
          icon: 'success',
        })

        setTimeout(() => {
          uni.redirectTo({ url: '/pages/index/index' })
        }, 500)
      } catch (err) {
        uni.hideLoading()
        console.error('登录失败:', err)
        uni.showToast({
          title: err.message || '登录失败',
          icon: 'none',
        })
      } finally {
        this.loading = false
      }
    },
    openGuide() {
      uni.showModal({
        title: '如何获取账号与Token',
        content: '请访问云信官网 https://doc.yunxin.163.com 获取云信账号与Token',
        showCancel: false,
      })
    },
  },
}
</script>

<style scoped>
.container {
  width: 100vw;
  height: 100vh;
  background-color: #1a1a23;
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

.header-content {
  display: flex;
  width: 100vw;
  padding: 50px 10px 30px 10px;
  box-sizing: border-box;
  align-items: center;
  justify-content: center;
}

.header-title {
  font-size: 32rpx;
  color: #ffffff;
  font-weight: bold;
}

.box {
  width: 80%;
  position: relative;
  background: #292935;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  justify-content: left;
  padding: 30px 20px;
}

.input-box {
  flex: 1;
  display: flex;
  font-size: 14px;
  color: #ffffff;
  letter-spacing: 0;
  background-color: #3a3a4a;
  border-radius: 4px;
  padding: 10px;
}

.login {
  display: flex;
  box-sizing: border-box;
  margin-top: 30px;
  width: 100%;
}

.loginBtn {
  width: 100%;
  line-height: 44px;
  background-color: #467ff6;
  border-radius: 50px;
  font-size: 16px;
  color: #ffffff;
  margin: 0;
  border: none;
}

.list-item {
  display: flex;
  flex-direction: column;
  font-size: 14px;
  color: #ffffff;
}

.list-item .list-item-label {
  font-weight: 500;
  padding: 10px 0;
  color: #ffffff;
}

.link-text {
  color: #467ff6;
  font-size: 14px;
}
</style>
