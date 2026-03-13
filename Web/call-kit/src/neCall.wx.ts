import SignalController from './signalController'
import {
  SignalControllerMember,
  SignalControllerChannelInfo,
  SignalControllerCallType,
} from './signalController/types'
import {
  UserInfo,
  NECallConfig,
  NECallParam,
  NEHangupParam,
  NESetupConfig,
  NECallEndInfo,
  NECallEvents,
  NECallInfo,
} from './neCallTypes'
import RTCController, { RTCConfig as WxRTCConfig } from './rtcController/wx'
import EventEmitter from 'eventemitter3'
import { logger, createLoggerDecorator } from './logger'
import { EventTracking } from '@xkit-yx/utils/dist/wx'
import pkg from '../package.json'

const loggerDecorator = createLoggerDecorator('MiniAppNECallEngine', logger)

export interface MiniAppNECallEvents extends NECallEvents {
  // rtc 事件
  onVideoMuteOrUnmute: [mute: boolean]
  onStreamSubscribed: [url: string]
  onStreamPublish: [url: string]
}

class MiniAppNECallEngine extends EventEmitter<MiniAppNECallEvents> {
  static instance?: MiniAppNECallEngine

  public signalController!: SignalController
  public rtcController!: RTCController
  public enableJoinRtcWhenCall = false
  public enableSwitchVideoConfirm = false
  public enableSwitchAudioConfirm = false

  private _unusualTimeout = 15000
  private _unusualTimer?: NodeJS.Timeout
  private _callType!: SignalControllerCallType
  private _currentUserInfo!: UserInfo
  private _remoteUserInfo!: UserInfo
  private _callConnectedTime?: number

  constructor() {
    super()
  }
  /**
   * 设置呼叫组件
   * @param params 初始化参数
   */
  public setup(params: NESetupConfig): void {
    const {
      nim,
      appkey,
      enableRecord = true,
      enableAutoJoinSignalChannel = false,
      enableJoinRtcWhenCall = false,
      rtcContext,
      debug = false,
    } = params

    if (this.signalController) {
      this.signalController.destroy()
    }

    this.signalController = new SignalController({ nim })
    this.signalController.enableRecord = enableRecord
    this.signalController.enableAutoJoinSignalChannel =
      enableAutoJoinSignalChannel
    this.rtcController = new RTCController({
      appkey,
      rtcConfig: rtcContext as unknown as WxRTCConfig,
      debug,
    })

    this._currentUserInfo = { accId: nim.V2NIMLoginService.getLoginUser() }
    this.enableJoinRtcWhenCall = enableJoinRtcWhenCall

    this._bindSignalControllerHooks()
    this._handleRtcEvents()
    this._handleWxEvents()

    logger.setLevel(debug ? 'debug' : 'warn')
    // 接入统计
    const eventTracking = new EventTracking({
      appKey: appkey,
      version: pkg.version,
      nertcVersion: '4.6.10',
      component: 'CallKit',
      platform: 'MiniApp',
    })

    eventTracking.track('init', '')
  }
  /**
   * 发起呼叫
   * @param params 呼叫参数
   */
  @loggerDecorator
  public async call(params: NECallParam): Promise<NECallInfo | undefined> {
    // 兼容 callType 为 number 的情况
    if (typeof params.callType === 'number') {
      params.callType = String(params.callType) as SignalControllerCallType
    }

    this._callType = params.callType
    this._remoteUserInfo = {
      accId: params.accId,
    }
    await this.signalController.call({
      ...params,
      nertcChannelName: params.rtcChannelName,
    })
    return this.getCallInfo()
  }
  /**
   * 接收呼叫
   */
  @loggerDecorator
  public async accept(): Promise<NECallInfo | undefined> {
    await this.signalController.accept()
    return this.getCallInfo()
  }
  /**
   * 拒绝呼叫，包含主叫取消，被叫拒绝（reason: 3，主叫接受到繁忙），通话中挂断。
   * @param params 挂断参数
   */
  @loggerDecorator
  public async hangup(params?: NEHangupParam): Promise<void> {
    if (this.signalController.callStatus === 1) {
      await this.signalController.cancel(params)
    }

    if (this.signalController.callStatus === 2) {
      await this.signalController.reject(params)
    }

    if (this.signalController.callStatus === 3) {
      // 计算通话时长并传入，用于生成话单
      const duration = this._callConnectedTime
        ? Math.floor((Date.now() - this._callConnectedTime) / 1000)
        : undefined
      this._callConnectedTime = undefined
      await this.signalController.hangup({ ...params, duration })
    }
  }
  /**
   * 切换呼叫类型
   * @param params.callType 呼叫类型
   * @param params.state  1: 邀请； 2：同意； 3：拒绝
   */
  @loggerDecorator
  public async switchCallType(params: {
    callType: SignalControllerCallType
    state: number // 1: 邀请； 2：同意； 3：拒绝
  }): Promise<void> {
    const state = params.state
    const callType = params.callType

    // 当 state = 1 时候， 跟 callType 判断是否需要确认
    if (state === 1) {
      const needConfirm =
        (callType === '1' && this.enableSwitchAudioConfirm) ||
        (callType === '2' && this.enableSwitchVideoConfirm)

      if (!needConfirm) {
        this.emit('onCallTypeChange', { callType, state: 2 })
        // 兼容老逻辑
        await this.signalController.control({
          ext: { cid: 2, type: Number(callType) },
        })
        this._switchRTCCallType(params.callType)
      }
    }

    if (params.state === 2) {
      this.emit('onCallTypeChange', { callType, state: 2 })
      this._switchRTCCallType(params.callType)
    }

    await this.signalController.control({
      ext: { cid: 3, type: Number(callType), state },
    })
  }
  /**
   * 开关本地视频
   * @param enabled true: 开启； false: 关闭
   */
  public async enableLocalVideo(enabled: boolean): Promise<void> {
    await this.rtcController.muteLocalVideo(!enabled)
  }
  /**
   * 开关本地音频
   * @param enabled true: 开启； false: 关闭
   */
  public async enableLocalAudio(enabled: boolean): Promise<void> {
    await this.rtcController.muteLocalAudio(!enabled)
  }
  /**
   * 设置超时时间
   * @param time 超时取消，单位：秒
   */
  public setTimeout(time: number): void {
    this.signalController.callTimeout = time * 1000
  }
  /**
   * 根据accId获取rtc uid
   * @param accId 用户 im 的 accId
   */
  public setCallConfig(params: NECallConfig): void {
    if (params.enableOffline !== undefined) {
      this.signalController.offlineEnabled = params.enableOffline
    }

    if (params.enableSwitchVideoConfirm !== undefined) {
      this.enableSwitchVideoConfirm = params.enableSwitchVideoConfirm
    }

    if (params.enableSwitchAudioConfirm !== undefined) {
      this.enableSwitchAudioConfirm = params.enableSwitchAudioConfirm
    }

    if (params.enableJoinRtcWhenCall !== undefined) {
      this.enableJoinRtcWhenCall = params.enableJoinRtcWhenCall
    }
  }
  /**
   * 根据accId获取rtc uid
   * @param accId 用户 im 的 accId
   */
  public getUidByAccId(accId: string): string | undefined {
    // 日志
    if (this._remoteUserInfo.accId === accId) {
      return this._remoteUserInfo.uid
    }

    if (this._currentUserInfo.accId === accId) {
      return this._currentUserInfo.uid
    }
  }
  /**
   * 通话中获取通话信息
   */
  public getCallInfo(): NECallInfo | undefined {
    if (this.signalController.callStatus === 0) return

    let callerInfo = this._currentUserInfo
    let calleeInfo = this._remoteUserInfo

    if (this._remoteUserInfo.role === 'caller') {
      callerInfo = this._remoteUserInfo
      calleeInfo = this._currentUserInfo
    }

    delete callerInfo.role
    delete calleeInfo.role
    const rtcChannelInfo = this.rtcController.getChannelInfo()

    return {
      callId: this.signalController.channelInfo?.attachExt.callId,
      callStatus: this.signalController.callStatus,
      callType: Number(this._callType),
      currentAccId: this._currentUserInfo.accId,
      rtcInfo: {
        channelId: rtcChannelInfo.cid,
        channelName: rtcChannelInfo.channelName,
        token: rtcChannelInfo.token,
      },
      signalInfo: {
        channelId: this.signalController.channelInfo?.channelId,
        requestId: this.signalController.channelInfo?.requestId,
        channelName: this.signalController.channelInfo?.channelName,
        extraInfo: this.signalController.channelInfo?.attachExt.extraInfo,
        globalExtraCopy:
          this.signalController.channelInfo?.attachExt.global_extra,
      },
      callerInfo,
      calleeInfo,
    }
  }
  /**
   * 获取呼叫时的配置参数
   */
  public getCallConfig(): NECallConfig {
    return {
      enableOffline: this.signalController.offlineEnabled,
      enableSwitchVideoConfirm: this.enableSwitchVideoConfirm,
      enableSwitchAudioConfirm: this.enableSwitchAudioConfirm,
    }
  }
  /**
   * 重连，im 重连成功后调用
   */
  public reconnect(): void {
    // 获取离线消息
    this.signalController.reconnect()
  }
  /**
   * 销毁
   */
  public destroy(): void {
    this.rtcController.destroy()
    this.signalController.destroy()
  }

  private _switchRTCCallType(callType: SignalControllerCallType) {
    this._callType = callType
    this.enableLocalVideo(callType === '2')
    this.enableLocalAudio(true)
  }

  private _handleCallEnd(callEndInfo: NECallEndInfo): void {
    this._unusualTimer && clearTimeout(this._unusualTimer)
    this._unusualTimer = undefined

    // Calculate call duration if the call was connected
    const callConnectedTime = this._callConnectedTime
    this._callConnectedTime = undefined
    const duration = callConnectedTime
      ? Math.floor((Date.now() - callConnectedTime) / 1000)
      : undefined

    if (this.signalController.callStatus === 3) {
      this.signalController.hangup({ duration })
    }
    this.rtcController.leaveRTCChannel()
    this.emit('onCallEnd', callEndInfo)
  }

  private async _rtcJoin(channelInfo: SignalControllerChannelInfo) {
    // 这里处理异常
    this._unusualTimer = setTimeout(() => {
      this._handleCallEnd({ reasonCode: 5 })
    }, this._unusualTimeout)
    this._remoteUserInfo.uid = channelInfo.members.find((item) => {
      return item.accid === this._remoteUserInfo.accId
    })?.uid
    await this.rtcController.joinRTCChannel({
      channelName: channelInfo.attachExt.channelName,
      uid: this._currentUserInfo.uid,
      token: channelInfo.nertcToken,
      // @ts-ignore
      getChanneInfoResponse: channelInfo.nertcJoinRoomResponse,
    })
    const res = await this.rtcController.publishLocalStream()

    res && this.emit('onStreamPublish', res)
  }

  private _syncCurrentUserInfoBySignalControllerMembers(
    members: SignalControllerMember[]
  ) {
    const member = members.find(
      (member) => member.accid === this._currentUserInfo.accId
    )

    if (member) {
      this._currentUserInfo.uid = member.uid
    }
  }

  private _bindSignalControllerHooks() {
    this.signalController.on('afterSignalCallEx', async (value) => {
      this._syncCurrentUserInfoBySignalControllerMembers(value.members)
      if (this.enableJoinRtcWhenCall) {
        // 提早加入 rtc channel
        await this.rtcController.joinRTCChannel({
          channelName: value.attachExt.channelName,
          uid: this._currentUserInfo.uid,
          token: value.nertcToken,
          // @ts-ignore
          getChanneInfoResponse: value.nertcJoinRoomResponse,
        })
      }
    })

    this.signalController.on('afterSignalAccept', async (value) => {
      this._syncCurrentUserInfoBySignalControllerMembers(value.members)
      await this._rtcJoin(value)
    })

    this.signalController.on('afterSignalCancel', (value) => {
      this._handleCallEnd({
        extraString: value._attachment,
        reasonCode: value.reason === 2 ? 2 : 11,
      })
    })

    this.signalController.on('afterSignalReject', (value) => {
      this._handleCallEnd({
        extraString: value._attachment,
        reasonCode: value.reason === 2 ? 2 : 13,
      })
    })

    this.signalController.on('afterSignalHangup', (value) => {
      this._handleCallEnd({ extraString: value._attachment, reasonCode: 15 })
    })

    this.signalController.on('whenSignalCancel', async (value) => {
      this._handleCallEnd({
        extraString: value._attachment,
        reasonCode: value.reason === 2 ? 2 : 12,
      })
    })

    this.signalController.on('whenSignalReject', async (value) => {
      this._handleCallEnd({
        extraString: value._attachment,
        reasonCode: value.reason === 2 ? 2 : value.reason === 3 ? 3 : 14,
      })
    })

    this.signalController.on('whenSignalAccept', async (value) => {
      await this._rtcJoin(value)
    })

    this.signalController.on('whenSignalInvite', async (value) => {
      this._callType = value.type
      this._syncCurrentUserInfoBySignalControllerMembers(value.members)
      this._remoteUserInfo = {
        accId: value.callerId,
        uid: value.members.find((item) => item.accid === value.callerId)?.uid,
      }
      const inviterInfo = {
        callerAccId: this._remoteUserInfo.accId,
        callType: value.type,
        extraInfo: value.attachExt.extraInfo || value.attachExt?._attachment,
        channelId: value.channelId,
      }

      this.emit('onReceiveInvited', inviterInfo)
    })

    this.signalController.on('whenSignalControl', async (value) => {
      if ((value.cid === 3 || value.cid === 2) && value.type) {
        const state = value.state ?? 1
        const callType = String(value.type) as SignalControllerCallType

        if (callType === this._callType) {
          return
        }

        if (state === 1) {
          const needConfirm =
            (callType === '1' && this.enableSwitchAudioConfirm) ||
            (callType === '2' && this.enableSwitchVideoConfirm)

          if (needConfirm) {
            this.emit('onCallTypeChange', { callType, state: 1 })
          } else {
            this.emit('onCallTypeChange', { callType, state: 2 })
            this._switchRTCCallType(callType)
            await this.signalController.control({
              ext: { cid: 3, type: Number(callType), state: 2 },
            })
          }
        }

        if (state === 2) {
          this.emit('onCallTypeChange', { callType, state: 2 })
          this._switchRTCCallType(callType)
        }

        if (state === 3) {
          this.emit('onCallTypeChange', { callType, state: 3 })
        }
      }
    })

    this.signalController.on('whenSignalRoomClose', async (value) => {
      this._handleCallEnd({ extraString: value._attachment, reasonCode: 16 })
    })

    this.signalController.on('whenSignalAcceptOtherClient', async () => {
      this._handleCallEnd({ reasonCode: 18 })
    })

    this.signalController.on('whenSignalRejectOtherClient', async () => {
      this._handleCallEnd({ reasonCode: 17 })
    })

    this.signalController.on('afterCallRecordSend', async (value) => {
      this.emit('onRecordSend', value)
    })
  }

  private _handleRtcEvents() {
    this.rtcController.on('streamSubscribed', (stream) => {
      this.emit('onStreamSubscribed', stream.url)
    })
    this.rtcController.on('clientJoin', () => {
      this._unusualTimer && clearTimeout(this._unusualTimer)
      this._unusualTimer = undefined
      this._callConnectedTime = Date.now()
      this.emit('onCallConnected', this.getCallInfo())
    })
    this.rtcController.on('clientLeave', () => {
      if (this._unusualTimer) return
      this._unusualTimer = setTimeout(() => {
        this._handleCallEnd({ reasonCode: 20 })
      }, this._unusualTimeout)
    })
    this.rtcController.on('videoMuteOrUnmute', ({ mute }) => {
      this.emit('onVideoMuteOrUnmute', mute)
    })
    this.rtcController.on('error', () => {
      if (this._unusualTimer) return
      this._unusualTimer = setTimeout(() => {
        this._handleCallEnd({ reasonCode: 14 })
      }, this._unusualTimeout)
    })
  }

  // 处理微信断网事件及前后台切换
  private _handleWxEvents() {
    let offlineTimer: NodeJS.Timeout | undefined
    const offlineTimeout = 30000

    wx.onNetworkStatusChange((res) => {
      if (!res.isConnected) {
        offlineTimer = setTimeout(() => {
          if (this.signalController.callStatus === 3) {
            this._handleCallEnd({ reasonCode: 2 })
          }
        }, offlineTimeout)
      } else {
        offlineTimer && clearTimeout(offlineTimer)
        offlineTimer = undefined
      }
    })

    // 从后台切回前台时，若在通话中则重新推流，解决切后台听不到声音的问题
    wx.onAppShow(() => {
      if (this.signalController.callStatus === 3) {
        this.rtcController.publishLocalStream().then((url) => {
          if (url) this.emit('onStreamPublish', url)
        }).catch(() => {})
      }
    })
  }

  //静态方法
  static getInstance(): MiniAppNECallEngine {
    if (!this.instance) {
      this.instance = new MiniAppNECallEngine()
    }

    return this.instance
  }
}

export default MiniAppNECallEngine
