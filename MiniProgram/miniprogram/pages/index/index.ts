// pages/index/index.ts
Page({
  data: {
    callType: '2',
    imAccid: '',
    accountId: '',
  },

  onShow() {
    // 确保账号ID始终是最新的（防止杀进程后重进时globalData已恢复但data未更新）
    const app = getApp<IAppOption>()
    this.setData({ accountId: app.globalData.accountId })
  },

  onImAccidInput(e: any) {
    this.setData({ imAccid: e.detail.value })
  },

  changeCallType(e: any) {
    this.setData({ callType: e.detail.value })
  },

  async startCall() {
    const { imAccid, callType, accountId } = this.data
    if (!imAccid.trim()) {
      wx.showToast({ title: '请输入账号ID', icon: 'none' })
      return
    }
    if (accountId === imAccid.trim()) {
      wx.showToast({ title: '不能呼叫自己', icon: 'none' })
      return
    }

    try {
      const app = getApp<IAppOption>()
      if (app.globalData.neCall) {
        // 注册早期 onCallEnd 监听，捕获对方占线立即拒绝导致的竞态：
        // call() 返回后到 call-view attached() 完成之间，onCallEnd 可能已触发，
        // 将结束信息暂存到 globalData，由 call-view 在 attached 时检查并处理。
        ;(app.globalData as any)._earlyCallEndInfo = null
        const earlyCallEndHandler = (callEndInfo: any) => {
          ;(app.globalData as any)._earlyCallEndInfo = callEndInfo
        }
        ;(app.globalData as any)._earlyCallEndHandler = earlyCallEndHandler
        app.globalData.neCall.on('onCallEnd', earlyCallEndHandler)

        try {
          await app.globalData.neCall.call({ callType, accId: imAccid })
          wx.navigateTo({ url: '/pages/call/call' })
        } catch (err: any) {
          // 呼叫失败，移除早期监听
          app.globalData.neCall.off('onCallEnd', earlyCallEndHandler)
          ;(app.globalData as any)._earlyCallEndHandler = null
          throw err
        }
      } else {
        wx.showToast({ title: '呼叫功能未初始化', icon: 'none' })
      }
    } catch (err: any) {
      console.error('呼叫失败:', err)
      wx.showToast({ title: err.message || '呼叫失败', icon: 'none' })
    }
  },

  logout() {
    wx.showModal({
      title: '退出账号',
      content: '是否退出当前账号？',
      success: async (res) => {
        if (res.confirm) {
          const app = getApp<IAppOption>()

          if (app.globalData.neCall) {
            app.globalData.neCall.destroy()
          }

          if (app.globalData.nim) {
            try {
              await app.globalData.nim.V2NIMLoginService.logout()
              await app.globalData.nim.destroy()
              console.log('logout success!')
            } catch (err) {
              console.log(err)
            }
          }

          app.globalData.nim = null
          app.globalData.neCall = null
          app.globalData.accountId = ''
          app.globalData.isLoggedIn = false

          wx.removeStorageSync('userConfig')
          wx.redirectTo({ url: '/pages/login/login' })
        }
      },
    })
  },
})
