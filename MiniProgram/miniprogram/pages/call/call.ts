// pages/call/call.ts
Page({
  onUnload() {
    // 这里用户自行业务判断，是否需要挂断通话
    const app = getApp<IAppOption>()
    const neCall = app.globalData.neCall
    if (neCall) {
      neCall.hangup()
    }
  },
})
