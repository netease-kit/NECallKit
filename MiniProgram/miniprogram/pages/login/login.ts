// pages/login/login.ts
Page({
  data: {
    accountId: '',
    token: '',
    loading: false,
  },

  onLoad() {
    const app = getApp<IAppOption>()
    if (app.globalData.accountId) {
      wx.redirectTo({ url: '/pages/index/index' })
    }
  },

  onAccountIdInput(e: any) {
    this.setData({ accountId: e.detail.value })
  },

  onTokenInput(e: any) {
    this.setData({ token: e.detail.value })
  },

  async login() {
    const { accountId, token } = this.data
    if (!accountId) {
      wx.showToast({ title: '账号ID不能为空', icon: 'none' })
      return
    }
    if (!token) {
      wx.showToast({ title: 'Token不能为空', icon: 'none' })
      return
    }

    this.setData({ loading: true })
    wx.showLoading({ title: '登录中...' })

    try {
      const app = getApp<IAppOption>()
      await app.initNIM(accountId, token)

      wx.setStorageSync('userConfig', { accountId, token })
      wx.hideLoading()
      wx.showToast({ title: '登录成功', icon: 'success' })
      wx.redirectTo({ url: '/pages/index/index' })
    } catch (err: any) {
      wx.hideLoading()
      console.error('登录失败:', err)
      wx.showToast({ title: err.message || '登录失败', icon: 'none' })
    } finally {
      this.setData({ loading: false })
    }
  },

  openGuide() {
    wx.showModal({
      title: '如何获取账号与Token',
      content: '请访问云信官网 https://doc.yunxin.163.com 获取云信账号与Token',
      showCancel: false,
    })
  },
})
