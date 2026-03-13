<script lang="ts">
import V2NIM from 'nim-web-sdk-ng/dist/v2/NIM_MINIAPP_SDK'
import { NECall } from '@xkit-yx/call-kit/miniprogram_dist/index'

export default {
  globalData: {
    appkey: "", // 请填写应用对应的AppKey，可在云信控制台的"AppKey管理"页面获取
    nim: null as any,
    neCall: null as any,
    accountId: '',
    isLoggedIn: false,
  },
  onLaunch: async function() {
    console.log('App Launch')
    const userConfig = uni.getStorageSync('userConfig')
    if (userConfig && userConfig.accountId && userConfig.token) {
      // 有缓存登录信息，自动重新初始化（修复杀进程后重进无账号信息问题）
      try {
        await (this as any).initNIM(userConfig.accountId, userConfig.token)
        setTimeout(() => {
          uni.redirectTo({ url: '/pages/index/index' })
        }, 100)
      } catch (err) {
        console.error('Auto re-login failed:', err)
        uni.removeStorageSync('userConfig')
        setTimeout(() => {
          uni.redirectTo({ url: '/pages/login/login' })
        }, 100)
      }
    } else {
      setTimeout(() => {
        uni.redirectTo({ url: '/pages/login/login' })
      }, 100)
    }
  },
  onShow: function() {
    console.log('App Show')
    // 修复锁屏/切后台被呼后返回无法弹出被呼页面的问题
    const neCall = (this as any).globalData.neCall
    if (neCall && neCall.signalController?.callStatus === 2) {
      const pages = getCurrentPages()
      const isOnCallPage = pages.some((p: any) => p.route === 'pages/call/call')
      if (!isOnCallPage) {
        uni.navigateTo({ url: '/pages/call/call' })
      }
    }
  },
  onHide: function() {
    console.log('App Hide')
  },
  methods: {
    async initNIM(accountId: string, token: string) {
      const appkey = (this as any).globalData.appkey

      const nim = V2NIM.getInstance({
        appkey,
        apiVersion: 'v2',
        debugLevel: 'debug',
      })
      await nim.V2NIMLoginService.login(accountId, token)

      const neCall = NECall.getInstance()
      neCall.setup({
        nim,
        appkey,
        account: accountId,
        debug: true,
      })

      // 统一注册 onReceiveInvited 事件，防止重复注册
      neCall.off('onReceiveInvited')
      neCall.on('onReceiveInvited', () => {
        const pages = getCurrentPages()
        const isOnCallPage = pages.some((p: any) => p.route === 'pages/call/call')
        if (!isOnCallPage) {
          uni.navigateTo({ url: '/pages/call/call' })
        }
      })

      ;(this as any).globalData.nim = nim
      ;(this as any).globalData.neCall = neCall
      ;(this as any).globalData.accountId = accountId
      ;(this as any).globalData.isLoggedIn = true
    }
  }
}
</script>

<style>
  /*每个页面公共css */
</style>
