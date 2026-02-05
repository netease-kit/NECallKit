import { secondToDate } from './utils/index'
const app = getApp()

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
    },
    player: {
      mode: 'RTC',
      autoplay: true,
      enableCamera: true,
      enableMic: true,
      objectFit: 'fillCrop',
      videoMute: false,
      pictureInPictureMode: ['push', 'pop'],
    },
  },
  lifetimes: {
    async attached() {
      const neCall = app.globalData.neCall
      const nim = app.globalData.nim
      if (!neCall || !nim) {
        throw new Error(
          '需要在全局实例化 neCall 和 nim，绑定到 app.globalData 上'
        )
      }
      const callStatus = neCall.signalController.callStatus
      let userAccId =
        callStatus === 1
          ? neCall.signalController._channelInfo.calleeId
          : neCall.signalController._channelInfo.callerId
          
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
                ...user
              }
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
      let durationTimer
      let duration = 0
      neCall.on('onCallConnected', () => {
        this.setData({
          callStatus: 3,
        })
        durationTimer = setInterval(() => {
          duration += 1
          this.setData({
            durationText: secondToDate(duration),
          })
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
      neCall.on('onCallEnd', () => {
        duration = 0
        if (durationTimer) clearInterval(durationTimer)
      
        // 1. 尝试调用 API 退出
        if (wx.exitPictureInPicture) {
          wx.exitPictureInPicture().catch(() => {})
        }
      
        // 2. 清空配置并切断显示状态
        this.setData({
          callStatus: 0, // 销毁 live-pusher/player 组件
          'player.pictureInPictureMode': [],
          'pusher.pictureInPictureMode': []
        }, () => {
          // 3. 稍微延迟返回，防止微信内部引擎没反应过来
          setTimeout(() => {
            wx.navigateBack({
              delta: 1
            })
          }, 200)
        })
      })
    },
    detached() {
      const neCall = app.globalData.neCall
      neCall.off('onCallConnected')
      neCall.off('onStreamPublish')
      neCall.off('onStreamSubscribed')
      neCall.off('onCallEnd')
    },
  },
  methods: {
    onHangup() {
      const neCall = app.globalData.neCall
      neCall.hangup()
    },
    onAccept() {
      const neCall = app.globalData.neCall
      neCall.accept()
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
  },
})
