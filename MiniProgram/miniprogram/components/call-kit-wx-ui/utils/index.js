function secondToDate(result) {
  let h = Math.floor(result / 3600)
  let m = Math.floor((result / 60) % 60)
  let s = Math.floor(result % 60)
  if (s < 10) {
    s = '0' + s
  }
  if (m < 10) {
    m = '0' + m
  }
  if (h === 0) {
    return m + ':' + s
  }
  if (h < 10) {
    h = '0' + h
  }
  return h + ':' + m + ':' + s
}

/**
 * 检查并请求通话所需权限（麦克风 / 摄像头）
 * @param {string} callType - '1' 语音通话，'2' 视频通话
 * @returns {Promise<boolean>} true 表示权限已就绪，false 表示被拒绝
 */
async function checkAndRequestPermissions(callType) {
  const scopes =
    callType === '2' ? ['scope.record', 'scope.camera'] : ['scope.record']
  const scopeNames = { 'scope.record': '麦克风', 'scope.camera': '摄像头' }

  let authSetting = {}
  try {
    const result = await new Promise((resolve, reject) =>
      wx.getSetting({ success: resolve, fail: reject })
    )
    authSetting = result.authSetting || {}
  } catch (e) {
    console.warn('获取权限设置失败:', e)
    return true // 检查失败时不阻断通话，由底层处理
  }

  for (const scope of scopes) {
    if (authSetting[scope] === false) {
      // 已明确拒绝，引导用户前往设置页开启
      const name = scopeNames[scope]
      const confirmed = await new Promise((resolve) =>
        wx.showModal({
          title: '需要授权',
          content: `请在设置中开启${name}权限，否则无法正常通话`,
          confirmText: '去设置',
          cancelText: '取消',
          success: (res) => resolve(res.confirm),
        })
      )
      if (confirmed) wx.openSetting()
      return false
    }

    if (authSetting[scope] !== true) {
      // 未授权，主动申请（仅在用户手势事件中调用才有效）
      try {
        await new Promise((resolve, reject) =>
          wx.authorize({ scope, success: resolve, fail: reject })
        )
      } catch (e) {
        wx.showToast({
          title: `需要${scopeNames[scope]}权限才能通话`,
          icon: 'none',
        })
        return false
      }
    }
  }

  return true
}

module.exports = { secondToDate, checkAndRequestPermissions }
