const { secondToDate } = require('../utils/index')
const app = getApp()

// 铃声地址（主叫等待音 / 被叫来电音）
const RING_URL = '/static/ring.mp3'

// 鸿蒙系统 live-player 需使用 'live' 模式，其他平台使用 'RTC'
function getPlayerMode() {
  try {
    const info = wx.getDeviceInfo ? wx.getDeviceInfo() : wx.getSystemInfoSync()
    const platform = (info.platform || '').toLowerCase()
    console.log('设备信息platform: ', platform)
    const system = (info.system || '').toLowerCase()
    console.log('设备信息system: ', system)
    if (platform.includes('ohos') || system.includes('harmonyos')) {
      return 'live'
    }
  } catch (e) {}
  return 'RTC'
}

Component({
  properties: {
    userAccId: String,
  },
  data: {
    callStatus: 0, // 状态 0：闲置 1：正在呼叫 2：正在被呼叫 3：通话中
    callType: '2', // 通话类型 1：语音通话 2：视频通话
    durationText: '00:00', // 通话时长
    userInfo: {},
    microphoneImg: {
      open: './assets/microphone-open.png',
      close: './assets/microphone-close.png',
    },
    videoImg: {
      open: './assets/video-open.png',
      close: './assets/video-close.png',
    },
    acceptImg: {
      audio: './assets/audio-accept.png',
      video: './assets/video-accept.png',
    },
    hangupImg: './assets/hangup.png',
    cameraRevertImg: './assets/camera-revert.png',
    pusher: {
      mode: 'RTC',
      autopush: true,
      enableCamera: true,
      enableMic: true,
      pictureInPictureMode: ['push', 'pop'],
      waitingImage:
        'https://yx-web-nosdn.netease.im/quickhtml%2Fassets%2Fyunxin%2Fdefault%2Fgroupcall%2FLark20210401-161321.jpeg',
      videoWidth: 360,
      videoHeight: 640,
      videoBitrate: 600,
      videoFPS: 15,
      enableAudioQuality: 'high',
      enableVideoHardwareEncode: true,
      enableAudioHardwareEncode: true,
      minBitrate: 400,
      maxBitrate: 800,
      adaptiveBitrate: true,
    },
    player: {
      mode: 'RTC',
      autoplay: true,
      enableCamera: true,
      enableMic: true,
      objectFit: 'fillCrop',
      videoMute: false,
      pictureInPictureMode: ['push', 'pop'],
      soundMode: 'speaker',
    },
    // movable-view 本地视频位置
    localViewX: 0,
    localViewY: 0,
  },

  // 使用实例属性存储定时器，避免内存泄漏
  _durationTimer: null,
  _duration: 0,
  _ringContext: null,
  _appShowHandler: null,

  lifetimes: {
    async attached() {
      const neCall = app.globalData.neCall
      const nim = app.globalData.nim
      if (!neCall || !nim) {
        throw new Error(
          '需要在全局实例化 neCall 和 nim，绑定到 app.globalData 上'
        )
      }

      // 本地小窗初始位置：右上角，right=20px，top 留出状态栏高度后再加间距
      try {
        const { windowWidth, statusBarHeight = 0 } = wx.getSystemInfoSync()
        const LOCAL_VIEW_W = 125
        const RIGHT_MARGIN = 20
        const TOP_MARGIN = (statusBarHeight || 0) + 60
        this.setData({
          localViewX: windowWidth - LOCAL_VIEW_W - RIGHT_MARGIN,
          localViewY: TOP_MARGIN,
        })
      } catch (e) {}

      // 鸿蒙系统 live-player mode 需为 'live'
      const playerMode = getPlayerMode()
      console.log('设置 player mode: ', playerMode)
      if (playerMode !== this.data.player.mode) {
        this.setData({ 'player.mode': playerMode })
      }

      const callStatus = neCall.signalController.callStatus
      const channelInfo = neCall.signalController._channelInfo
      let userAccId =
        callStatus === 1
          ? (channelInfo && channelInfo.calleeId)
          : (channelInfo && channelInfo.callerId)

      try {
        if (userAccId) {
          const userProfiles = await nim.V2NIMUserService.getUserList([userAccId])
          if (userProfiles && userProfiles.length > 0) {
            const user = userProfiles[0]
            this.setData({
              userInfo: {
                nick: user.name,
                avatar: user.avatar,
                tel: user.mobile,
                ...user,
              },
            })
          }
        }
      } catch (error) {
        console.error('获取用户信息失败:', error)
      }

      this.setData({
        callStatus: neCall.signalController.callStatus,
        callType: neCall._callType,
      })

      // 初始铃声：呼叫中(1)或被呼叫(2)时播放
      if (callStatus === 1 || callStatus === 2) {
        this._startRing()
      }

      neCall.on('onCallConnected', () => {
        this._stopRing()
        this.setData({ callStatus: 3 })
        this._duration = 0
        this._durationTimer = setInterval(() => {
          this._duration += 1
          this.setData({ durationText: secondToDate(this._duration) })
        }, 1000)
      })

      neCall.on('onVideoMuteOrUnmute', (mute) => {
        this.setData({
          player: { ...this.data.player, videoMute: mute },
        })
      })

      neCall.on('onStreamPublish', (url) => {
        this.setData({
          pusher: { ...this.data.pusher, url },
        })
      })

      neCall.on('onStreamSubscribed', (url) => {
        this.setData({
          player: { ...this.data.player, url },
        })
      })

      const handleCallEnd = (callEndInfo) => {
        this._stopRing()
        this._duration = 0
        if (this._durationTimer) {
          clearInterval(this._durationTimer)
          this._durationTimer = null
        }

        // 根据结束原因显示提示（修复多端接听无提示问题）
        const reasonCode = callEndInfo && callEndInfo.reasonCode
        const reasonMsgMap = {
          2: '通话超时，已自动挂断',
          3: '对方正在通话中',
          12: '对方已取消呼叫',
          13: '已拒绝通话',
          14: '对方已拒绝',
          17: '其他端已拒绝',
          18: '其他端已接听',
          20: '对方网络异常，通话已断开',
        }
        const msg = reasonMsgMap[reasonCode]
        if (msg) {
          wx.showToast({ title: msg, icon: 'none', duration: 2000 })
        }

        // 退出画中画并返回上一页
        if (wx.exitPictureInPicture) {
          wx.exitPictureInPicture().catch(() => {})
        }

        this.setData(
          {
            callStatus: 0,
            'player.pictureInPictureMode': [],
            'pusher.pictureInPictureMode': [],
          },
          () => {
            setTimeout(() => {
              wx.navigateBack({ delta: 1 })
            }, msg ? 2100 : 200)
          }
        )
      }

      // 移除 index 页注册的早期监听（如果有），避免重复处理
      if (app.globalData._earlyCallEndHandler) {
        neCall.off('onCallEnd', app.globalData._earlyCallEndHandler)
        app.globalData._earlyCallEndHandler = null
      }

      neCall.on('onCallEnd', handleCallEnd)

      // 修复竞态条件：对方占线时会立即拒绝，onCallEnd 可能在本组件 attached 之前已触发。
      // index 页注册的早期监听会将结束信息暂存到 app.globalData._earlyCallEndInfo，
      // 在此处检查并补充触发。
      if (app.globalData._earlyCallEndInfo) {
        const pendingEndInfo = app.globalData._earlyCallEndInfo
        app.globalData._earlyCallEndInfo = null
        handleCallEnd(pendingEndInfo)
      }

      // 从后台切回前台时，重新订阅远端流（修复切后台后听不到声音）
      this._appShowHandler = () => {
        if (this.data.callStatus === 3 && this.data.player.url) {
          this.setData({
            player: { ...this.data.player, url: this.data.player.url },
          })
        }
      }
      wx.onAppShow(this._appShowHandler)
    },

    detached() {
      const neCall = app.globalData.neCall
      if (neCall) {
        neCall.off('onCallConnected')
        neCall.off('onStreamPublish')
        neCall.off('onStreamSubscribed')
        neCall.off('onCallEnd')
        neCall.off('onVideoMuteOrUnmute')
      }
      // 清理早期监听引用
      app.globalData._earlyCallEndHandler = null
      app.globalData._earlyCallEndInfo = null

      // 清理定时器
      if (this._durationTimer) {
        clearInterval(this._durationTimer)
        this._durationTimer = null
      }

      // 停止铃声
      this._stopRing()

      // 移除 onAppShow 监听
      if (this._appShowHandler) {
        wx.offAppShow(this._appShowHandler)
        this._appShowHandler = null
      }
    },
  },

  methods: {
    onHangup() {
      const neCall = app.globalData.neCall
      neCall.hangup()
    },

    async onAccept() {
      const neCall = app.globalData.neCall
      try {
        await neCall.accept()
      } catch (err) {
        console.error('接听失败:', err)
        wx.showToast({ title: '接听失败，请重试', icon: 'none' })
      }
    },

    handleEnableLocalAudio() {
      const neCall = app.globalData.neCall
      const enable = this.data.pusher.enableMic
      neCall.enableLocalAudio(!enable)
      this.setData({
        pusher: { ...this.data.pusher, enableMic: !enable },
      })
    },

    handleEnableLocalVideo() {
      const neCall = app.globalData.neCall
      const enable = this.data.pusher.enableCamera
      neCall.enableLocalVideo(!enable)
      this.setData({
        pusher: { ...this.data.pusher, enableCamera: !enable },
      })
    },

    handleCameraRevert() {
      const livePusherContext = wx.createLivePusherContext()
      livePusherContext.switchCamera()
    },

    // 铃声控制
    _startRing() {
      if (this._ringContext) return
      try {
        const ctx = wx.createInnerAudioContext()
        ctx.src = RING_URL
        ctx.loop = true
        ctx.volume = 1
        ctx.play()
        this._ringContext = ctx
      } catch (e) {
        console.warn('铃声播放失败:', e)
      }
    },

    _stopRing() {
      if (this._ringContext) {
        try {
          this._ringContext.stop()
          this._ringContext.destroy()
        } catch (e) {}
        this._ringContext = null
      }
    },
  },
})
