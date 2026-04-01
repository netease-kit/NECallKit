// app.ts
// eslint-disable-next-line @typescript-eslint/no-var-requires
const V2NIM = require('./sdk/NIM_MINIAPP_SDK').default
// eslint-disable-next-line @typescript-eslint/no-var-requires
const { NECall } = require('@xkit-yx/call-kit')

App<IAppOption>({
  globalData: {
    appkey: '', // 请填写应用对应的AppKey，可在云信控制台的"AppKey管理"页面获取
    nim: null as any,
    neCall: null as any,
    accountId: '',
    isLoggedIn: false,
  },

  onLaunch: async function () {
    console.log('App Launch')
    const userConfig = wx.getStorageSync('userConfig')
    if (userConfig && userConfig.accountId && userConfig.token) {
      // 有缓存登录信息，自动重新初始化（修复杀进程后重进无账号信息问题）
      try {
        await (this as any).initNIM(userConfig.accountId, userConfig.token)
        setTimeout(() => {
          wx.redirectTo({ url: '/pages/index/index' })
        }, 100)
      } catch (err) {
        console.error('Auto re-login failed:', err)
        wx.removeStorageSync('userConfig')
        setTimeout(() => {
          wx.redirectTo({ url: '/pages/login/login' })
        }, 100)
      }
    } else {
      setTimeout(() => {
        wx.redirectTo({ url: '/pages/login/login' })
      }, 100)
    }
  },

  onShow: function () {
    console.log('App Show')
    // 修复锁屏/切后台被呼后返回无法弹出被呼页面的问题
    const neCall = (this as any).globalData.neCall
    if (neCall && neCall.signalController && neCall.signalController.callStatus === 2) {
      const pages = getCurrentPages()
      const isOnCallPage = pages.some((p: any) => p.route === 'pages/call/call')
      if (!isOnCallPage) {
        wx.navigateTo({ url: '/pages/call/call' })
      }
    }
  },

  onHide: function () {
    console.log('App Hide')
  },

  async initNIM(accountId: string, token: string) {
    const appkey = (this as any).globalData.appkey

    const nim = V2NIM.getInstance({
      appkey,
      apiVersion: 'v2',
      debugLevel: 'debug',
    })

    // setup() 必须在 login() 之前调用：NIM V10 在 login() 内部完成信令数据同步，
    // onOfflineEvent / onSyncRoomInfoList 在 login() resolve 前触发。
    // 提前调用 setup() 使 SignalController 注册好监听，确保登录时的离线来电不丢失。
    // account 参数保证 login() 前 _currentUserInfo.accId 已正确设置。
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
        wx.navigateTo({ url: '/pages/call/call' })
      }
    })

    await nim.V2NIMLoginService.login(accountId, token)

    ;(this as any).globalData.nim = nim
    ;(this as any).globalData.neCall = neCall
    ;(this as any).globalData.accountId = accountId
    ;(this as any).globalData.isLoggedIn = true
  },
})
