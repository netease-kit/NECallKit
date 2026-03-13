// @ts-nocheck
import {
  CALL_BUSY,
  CHANNEL_INFO_NULL,
  NOT_BE_CALL,
  NOT_CALLING,
  NOT_IN_CALL,
  CHANNEL_NOT_MATCH,
} from './error'
import {
  SignalControllerAttachExt,
  SignalControllerChannelInfo,
  SignalControllerCallingStatus,
  SignalControllerCallParams,
  SignalControllerEvents,
  SignalControllerCallType,
} from './types'
import { logger, createLoggerDecorator } from '../logger'
import EventEmitter from 'eventemitter3'
import pkg from '../../package.json'
import V2NIM from 'nim-web-sdk-ng'

function uuidv4() {
  if (
    typeof crypto !== 'undefined' &&
    typeof crypto.randomUUID === 'function'
  ) {
    return crypto.randomUUID()
  }

  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
    const r = (Math.random() * 16) | 0,
      v = c == 'x' ? r : (r & 0x3) | 0x8

    return v.toString(16)
  })
}

const TAG_NAME = 'SignalController'

const loggerDecorator = createLoggerDecorator(TAG_NAME, logger)

// V10 signalling event type constants (from V2NIMConst)
const V10_EVENT_TYPE = {
  CLOSE: 1,
  JOIN: 2,
  INVITE: 3,
  CANCEL_INVITE: 4,
  REJECT: 5,
  ACCEPT: 6,
  LEAVE: 7,
  CONTROL: 8,
  KICK: 9,
}

class SignalController extends EventEmitter<SignalControllerEvents> {
  public callStatus = SignalControllerCallingStatus.idle // 通话状态
  public callTimeout = 30 * 1000 // 通话超时时间
  public offlineEnabled = true
  public enableAutoJoinSignalChannel = false
  public enableRecord = true

  private _nim: V2NIM
  private _signal: any // V2NIMSignallingService (V10 new API)

  private _callTimer?: NodeJS.Timeout
  private _rejectTimer?: NodeJS.Timeout

  private _channelInfo?: SignalControllerChannelInfo
  private _offlineInviteEvents: any[] = []
  private _offlineCancelInviteEvents: any[] = []

  get channelInfo(): SignalControllerChannelInfo | undefined {
    return this._channelInfo
  }

  get nimInstance(): V2NIM {
    return this._nim
  }
  /**
   *
   * @param im im实例对象
   * @param kitName 上层kit名称
   * @param version 上层kit版本
   * @param debug 是否开启debug，输出日志
   */
  constructor({ nim }: { nim: V2NIM }) {
    super()
    this._nim = nim
    // V10: use V2NIMSignallingService instead of nim.signaling
    this._signal = nim.V2NIMSignallingService

    this._onOnlineEvent = this._onOnlineEvent.bind(this)
    this._onOfflineEvent = this._onOfflineEvent.bind(this)
    this._onMultiClientEvent = this._onMultiClientEvent.bind(this)
    this._onSyncRoomInfoList = this._onSyncRoomInfoList.bind(this)

    this._signal.on('onOnlineEvent', this._onOnlineEvent)
    this._signal.on('onOfflineEvent', this._onOfflineEvent)
    this._signal.on('onMultiClientEvent', this._onMultiClientEvent)
    this._signal.on('onSyncRoomInfoList', this._onSyncRoomInfoList)
  }

  @loggerDecorator
  public async call(
    opt: SignalControllerCallParams
  ): Promise<SignalControllerChannelInfo> {
    if (this.callStatus !== SignalControllerCallingStatus.idle) {
      throw CALL_BUSY
    }

    this.callStatus = SignalControllerCallingStatus.calling
    return await this._signalCallEx(opt)
  }

  @loggerDecorator
  public async accept(opt?: {
    nertcJoinRoomQueryParamMap?: string
  }): Promise<SignalControllerChannelInfo> {
    if (
      this.callStatus !== SignalControllerCallingStatus.called ||
      !this._channelInfo
    ) {
      throw NOT_BE_CALL
    }

    this.callStatus = SignalControllerCallingStatus.inCall
    await this._signalAccept({
      ...this._channelInfo,
      account: this._channelInfo.callerId,
      nertcJoinRoomQueryParamMap: opt?.nertcJoinRoomQueryParamMap,
    })
    return this._channelInfo
  }

  @loggerDecorator
  public async cancel(opt?: {
    channelId?: string
    extraString?: string
  }): Promise<void> {
    if (
      this.callStatus !== SignalControllerCallingStatus.calling ||
      !this._channelInfo
    ) {
      throw NOT_CALLING
    }

    if (opt?.channelId && this._channelInfo?.channelId !== opt.channelId) {
      throw CHANNEL_NOT_MATCH
    }

    const { attachExt } = this._channelInfo

    if (opt?.extraString) {
      attachExt._attachment = opt.extraString
    }

    await this._signalCancel({
      ...this._channelInfo,
      attachExt,
      account: this._channelInfo.calleeId,
    })
  }

  @loggerDecorator
  public async reject(opt?: {
    channelId?: string
    reason?: number
    extraString?: string
  }): Promise<void> {
    if (this.callStatus !== SignalControllerCallingStatus.called) {
      throw NOT_BE_CALL
    }

    if (opt?.channelId && this._channelInfo?.channelId !== opt.channelId) {
      throw CHANNEL_NOT_MATCH
    }

    if (!this._channelInfo) {
      throw CHANNEL_INFO_NULL
    }

    const { attachExt } = this._channelInfo

    attachExt.reason = opt?.reason ?? 0
    if (opt?.extraString) {
      attachExt._attachment = opt.extraString
    }

    await this._signalReject({
      ...this._channelInfo,
      account: this._channelInfo.callerId,
      attachExt,
    })
  }

  @loggerDecorator
  public async hangup(opt?: {
    channelId?: string
    extraString?: string
    duration?: number
  }): Promise<void> {
    if (
      this.callStatus !== SignalControllerCallingStatus.inCall ||
      !this._channelInfo
    ) {
      throw NOT_IN_CALL
    }

    if (opt?.channelId && this._channelInfo?.channelId !== opt.channelId) {
      throw CHANNEL_NOT_MATCH
    }

    const { attachExt } = this._channelInfo

    if (opt?.extraString) {
      attachExt._attachment = opt.extraString
    }

    await this._signalHangup({
      ...this._channelInfo,
      duration: opt?.duration,
    })
  }

  @loggerDecorator
  public async control(opt?: {
    ext?: any // 自定义扩展信息 为了兼容老功能
  }): Promise<void> {
    try {
      if (!this._channelInfo) {
        throw CHANNEL_INFO_NULL
      }

      // V10: sendControl(channelId, receiverAccountId, serverExtension)
      // empty receiverAccountId means send to all users in the room
      await this._signal.sendControl(
        this._channelInfo.channelId,
        '',
        JSON.stringify({
          ...this._channelInfo.attachExt,
          ...opt?.ext,
        })
      )
    } catch (error) {
      // 日志
      logger.error(TAG_NAME, 'control fail', error)
      throw error
    }
  }

  public reconnect(): void {
    // 获取离线消息
    // this._signal.signalingSync()
  }

  public resetState(): void {
    this._channelInfo = undefined
    this.callStatus = SignalControllerCallingStatus.idle
    this._callTimer && clearTimeout(this._callTimer)
    this._rejectTimer && clearTimeout(this._rejectTimer)
  }

  public destroy(): void {
    this.resetState()
    // V10: unregister 4 new events
    this._signal.off('onOnlineEvent', this._onOnlineEvent)
    this._signal.off('onOfflineEvent', this._onOfflineEvent)
    this._signal.off('onMultiClientEvent', this._onMultiClientEvent)
    this._signal.off('onSyncRoomInfoList', this._onSyncRoomInfoList)
  }

  private async _signalCallEx(
    params: SignalControllerCallParams
  ): Promise<SignalControllerChannelInfo> {
    try {
      const attachExt: SignalControllerAttachExt = {
        callId: uuidv4(),
        channelName: params.nertcChannelName || uuidv4(),
        rtcTokenTtl: params.nertcTokenTtl || 500,
        version: pkg.version,
        callType: 0,
        global_extra: params.globalExtraCopy,
        extraInfo: params.extraInfo,
        _attachment: params.extraInfo,
        reason: 0,
      }

      const requestId = uuidv4()
      // V10: call() replaces callEx()
      const result = await this._signal.call({
        calleeAccountId: params.accId,
        channelType: Number(params.callType),
        requestId,
        serverExtension: JSON.stringify(attachExt),
        signallingConfig: {
          offlineEnabled: this.offlineEnabled,
        },
        rtcConfig: {
          rtcChannelName: attachExt.channelName,
          rtcTokenTtl: params.nertcTokenTtl,
        },
        pushConfig: {
          pushEnabled: params.pushConfig?.needPush ?? true,
          pushTitle: params.pushConfig?.pushTitle ?? '邀请通知',
          pushContent: params.pushConfig?.pushContent ?? '你收到了通话邀请',
          pushPayload:
            typeof params.pushConfig?.pushPayload === 'undefined'
              ? '{}'
              : JSON.stringify(params.pushConfig?.pushPayload),
        },
      })

      this._channelInfo = this._formatSDKChannelInfo(
        result.roomInfo,
        result.rtcInfo
      )
      // 补充channelInfo信息
      this._channelInfo.calleeId = params.accId
      this._channelInfo.requestId = requestId
      this._channelInfo.attachExt = attachExt
      // 日志
      logger.log(TAG_NAME, 'signalingCallEx success', this._channelInfo)

      this.emit('afterSignalCallEx', this._channelInfo)
      // 超时取消
      if (this.callTimeout) {
        this._callTimer = setTimeout(async () => {
          if (
            this.callStatus === SignalControllerCallingStatus.calling &&
            this._channelInfo
          ) {
            this._channelInfo.attachExt.reason = 2
            await this._signalCancel({
              ...this._channelInfo,
              account: this._channelInfo.calleeId,
            })
          }
        }, this.callTimeout)
      }

      return this._channelInfo
    } catch (error) {
      // 日志
      logger.error(TAG_NAME, 'signalingCallEx fail', error)
      // 重置状态
      this.resetState()
      throw error
    }
  }

  /**
   * V10: Dispatcher for online events (replaces 6 separate old event handlers)
   */
  private _onOnlineEvent(event: any): void {
    logger.log(TAG_NAME, '_onOnlineEvent', event)
    switch (event.eventType) {
      case V10_EVENT_TYPE.INVITE:
        return this._handleOnlineInvite(event)
      case V10_EVENT_TYPE.CANCEL_INVITE:
        return this._handleOnlineCancelInvite(event)
      case V10_EVENT_TYPE.ACCEPT:
        return this._handleOnlineAccept(event)
      case V10_EVENT_TYPE.REJECT:
        return this._handleOnlineReject(event)
      case V10_EVENT_TYPE.CLOSE:
        return this._handleOnlineClose(event)
      case V10_EVENT_TYPE.CONTROL:
        return this._handleOnlineControl(event)
      default:
        break
    }
  }

  /**
   * V10: Multi-client event (replaces feature=3 branches of _signalingAccept/_signalingReject)
   */
  private _onMultiClientEvent(event: any): void {
    logger.log(TAG_NAME, '_onMultiClientEvent', event)
    if (this._channelInfo?.channelId === event.channelInfo?.channelId) {
      switch (event.eventType) {
        case V10_EVENT_TYPE.ACCEPT:
          this.resetState()
          this.emit('whenSignalAcceptOtherClient')
          break
        case V10_EVENT_TYPE.REJECT:
          // TODO 考虑下这里是否需要定时器延时处理，之前有这个逻辑
          this.resetState()
          this.emit('whenSignalRejectOtherClient')
          break
        default:
          break
      }
    }
  }

  /**
   * V10: Offline event handler (replaces feature=1 branches of _signalingInvite/_signalingCancelInvite)
   */
  private _onOfflineEvent(events: any[]): void {
    logger.log(TAG_NAME, '_onOfflineEvent', events)
    events.forEach((event) => {
      switch (event.eventType) {
        case V10_EVENT_TYPE.INVITE:
          if (event.channelInfo?.channelValid) {
            this._offlineInviteEvents.push(event)
          }
          break
        case V10_EVENT_TYPE.CANCEL_INVITE:
          if (event.channelInfo?.channelValid) {
            this._offlineCancelInviteEvents.push(event)
          }
          break
        default:
          break
      }
    })
  }

  /**
   * V10: Sync room info list (replaces _singalingSyncChannels + _onDataSync)
   */
  private _onSyncRoomInfoList(data: any): void {
    logger.log(TAG_NAME, '_onSyncRoomInfoList', data)

    // 找出没有被取消的离线邀请，继续当做在线处理
    const offlineCancelEventsChannelIds = this._offlineCancelInviteEvents.map(
      (item) => item.channelInfo?.channelId
    )
    const inviteEvents = this._offlineInviteEvents.filter(
      (item) =>
        // 这里因为每次呼叫都是新的 channel，因此可以根据 channelId 来作为唯一 key，严谨些应该换成 requestId
        !offlineCancelEventsChannelIds.includes(item.channelInfo?.channelId)
    )

    inviteEvents.forEach(async (item) => {
      await this._handleOnlineInvite(item)
    })
  }

  /**
   * V10: Handle online invite event (replaces _signalingInvite case 0)
   */
  private async _handleOnlineInvite(event: any) {
    logger.log(TAG_NAME, '_handleOnlineInvite', event)
    if (!event.channelInfo?.channelValid) {
      return
    }

    const channelId = event.channelInfo.channelId
    const requestId = event.requestId
    // V10 INVITE: inviterAccountId = caller, inviteeAccountId = callee
    const account = event.inviterAccountId || event.operatorAccountId
    let attachExt: SignalControllerAttachExt

    try {
      attachExt = JSON.parse(event.serverExtension || '{}')
    } catch (error) {
      // 日志
      logger.error(TAG_NAME, 'inviteHandler parse attachExt fail', error)

      throw error
    }

    // 这里处理占线的情况
    if (this.callStatus !== SignalControllerCallingStatus.idle) {
      if (channelId !== this._channelInfo?.channelId) {
        attachExt.reason = 3
        await this._signalReject({
          channelId,
          requestId,
          account,
          attachExt,
        })
      }

      return
    }

    this.callStatus = SignalControllerCallingStatus.called
    // 这里提早加入房间用来通信与生成uid
    if (this.enableAutoJoinSignalChannel) {
      const result = await this._signal.joinRoom({
        channelId: event.channelInfo.channelId,
        signallingConfig: {
          offlineEnabled: this.offlineEnabled,
        },
        serverExtension: event.serverExtension,
        rtcConfig: {
          rtcChannelName: attachExt.channelName,
          rtcTokenTtl: attachExt.rtcTokenTtl,
        },
      })
      this._channelInfo = this._formatSDKChannelInfo(
        result.roomInfo,
        result.rtcInfo
      )
    } else {
      // V10: getRoomInfoByChannelName(channelName) replaces queryInfo({ name })
      const result = await this._signal.getRoomInfoByChannelName(
        event.channelInfo.channelName
      )
      this._channelInfo = this._formatSDKChannelInfo(result, null)
    }

    this._channelInfo.callerId = account
    this._channelInfo.requestId = requestId
    this._channelInfo.attachExt = attachExt

    this.emit('whenSignalInvite', this._channelInfo)
    if (this.callTimeout) {
      this._rejectTimer = setTimeout(async () => {
        if (this._channelInfo) {
          this._channelInfo.attachExt.reason = 2
          try {
            await this._signalReject({
              ...this._channelInfo,
              account: this._channelInfo.callerId,
            })
          } catch (error) {
            // 忽略
          }
        }
      }, this.callTimeout)
    }
  }

  /**
   * V10: Handle online accept event (replaces _signalingAccept case 0/1)
   */
  private async _handleOnlineAccept(event: any) {
    logger.log(TAG_NAME, '_handleOnlineAccept', event)
    this.callStatus = SignalControllerCallingStatus.inCall
    this._callTimer && clearTimeout(this._callTimer)
    try {
      // V10: getRoomInfoByChannelName replaces queryInfo({ name })
      const result = await this._signal.getRoomInfoByChannelName(
        this._channelInfo?.channelName || ''
      )

      logger.log(
        TAG_NAME,
        'acceptHandler from signal success:',
        result,
        this._channelInfo
      )
      const channelInfo = this._formatSDKChannelInfo(result, null)
      this._channelInfo = { ...this._channelInfo, ...channelInfo }
      this.emit('whenSignalAccept', this._channelInfo)
    } catch (error) {
      logger.error(TAG_NAME, 'acceptHandler error:', error)
      throw error
    }
  }

  /**
   * V10: Handle online reject event (replaces _signalingReject case 0)
   */
  private _handleOnlineReject(event: any): void {
    logger.log(TAG_NAME, '_handleOnlineReject', event)
    // V10 REJECT: inviteeAccountId = callee (who rejected), inviterAccountId = caller
    const fromAccountId = event.inviteeAccountId || event.operatorAccountId
    const calleeId = this._channelInfo?.calleeId

    if (calleeId === fromAccountId) {
      let attachExt: SignalControllerAttachExt

      try {
        attachExt = JSON.parse(event.serverExtension || '{}')
      } catch (error) {
        logger.error(
          TAG_NAME,
          'rejectHandler:',
          'parse attachExt error:',
          error
        )
        throw error
      }

      switch (attachExt.reason) {
        case 3:
          this._sendMessage(calleeId, 'busy')
          break
        case 2:
          this._sendMessage(calleeId, 'timeout')
          break
        default:
          this._sendMessage(calleeId, 'rejected')
      }

      this.resetState()
      this.emit('whenSignalReject', attachExt)
    }
  }

  /**
   * V10: Handle online cancel invite event (replaces _signalingCancelInvite case 0)
   */
  private _handleOnlineCancelInvite(event: any): void {
    logger.log(TAG_NAME, '_handleOnlineCancelInvite', event)
    let attachExt: SignalControllerAttachExt

    try {
      attachExt = JSON.parse(event.serverExtension || '{}')
    } catch (error) {
      logger.error(
        TAG_NAME,
        'cancelInviteHandler:',
        'parse attachExt error:',
        error
      )
      throw error
    }

    this.resetState()
    this.emit('whenSignalCancel', attachExt)
  }

  /**
   * V10: Handle online close event (replaces _signalingClose)
   */
  private _handleOnlineClose(event: any): void {
    logger.log(TAG_NAME, '_handleOnlineClose', event)
    let attachExt: SignalControllerAttachExt

    try {
      attachExt = JSON.parse(event.serverExtension || '{}')
    } catch (error) {
      logger.error(
        TAG_NAME,
        'roomCloseHandler:',
        'parse attachExt error:',
        error
      )
      throw error
    }

    // Save info for call record before resetState clears channelInfo
    const savedCallerId = this._channelInfo?.callerId
    const savedCalleeId = this._channelInfo?.calleeId

    this.resetState()
    this.emit('whenSignalRoomClose', attachExt)

    // Send completed call record: remote side closed the room, notify them
    const remoteUserId = savedCallerId || savedCalleeId
    if (remoteUserId) {
      this._sendMessage(remoteUserId, 'completed')
    }
  }

  /**
   * V10: Handle online control event (replaces _signalingCustomCommand)
   */
  private _handleOnlineControl(event: any): void {
    logger.log(TAG_NAME, '_handleOnlineControl', event)
    try {
      let attachExt: SignalControllerAttachExt

      try {
        attachExt = JSON.parse(event.serverExtension || '{}')
      } catch (error) {
        logger.error(
          TAG_NAME,
          'controlHandler:',
          'parse attachExt error:',
          error
        )
        throw error
      }

      logger.log(TAG_NAME, 'controlHandler from signal success:', event)
      this.emit('whenSignalControl', attachExt)
    } catch (error) {
      logger.error(TAG_NAME, 'controlHandler error:', error)
      throw error
    }
  }

  /**
   * 接收呼叫
   * V10: joinRoom() + acceptInvite() replaces joinAndAccept()
   */
  private async _signalAccept(opt: {
    channelId: string
    requestId: string
    account: string
    attachExt: SignalControllerAttachExt
    nertcJoinRoomQueryParamMap?: string
  }): Promise<void> {
    const { attachExt } = opt

    try {
      if (!this.enableAutoJoinSignalChannel) {
        // V10: joinRoom() then acceptInvite()
        const result = await this._signal.joinRoom({
          channelId: opt.channelId,
          signallingConfig: {
            offlineEnabled: this.offlineEnabled,
          },
          serverExtension: JSON.stringify(attachExt),
          rtcConfig: {
            rtcChannelName: attachExt.channelName,
            rtcTokenTtl: attachExt.rtcTokenTtl,
          },
        })

        const channelInfo = this._formatSDKChannelInfo(
          result.roomInfo,
          result.rtcInfo
        )
        this._channelInfo = { ...this._channelInfo, ...channelInfo }
      }

      // V10: acceptInvite() replaces accept()
      // account = callerId = the one who invited (inviterAccountId)
      await this._signal.acceptInvite({
        inviterAccountId: opt.account,
        channelId: opt.channelId,
        requestId: opt.requestId,
        serverExtension: JSON.stringify(attachExt),
      })

      if (this._channelInfo) {
        this._channelInfo.attachExt = attachExt
        this.emit('afterSignalAccept', this._channelInfo)
      }

      this._rejectTimer && clearTimeout(this._rejectTimer)
    } catch (error) {
      // 这里不做重置状态处理，由 rejectTimer 事件处理，因为这里可能是断网状态
      logger.error(TAG_NAME, 'acceptSignal fail:', error, this._channelInfo)
      throw error
    }
  }

  /**
   * 取消呼叫中的信令
   * V10: cancelInvite() with inviteeAccountId
   */
  private async _signalCancel(opt: {
    channelId: string
    requestId: string
    account: string
    attachExt: SignalControllerAttachExt
  }): Promise<void> {
    const { account, attachExt } = opt
    const reason = attachExt.reason

    try {
      // V10: cancelInvite({ inviteeAccountId, channelId, requestId, serverExtension, signallingConfig })
      await this._signal.cancelInvite({
        inviteeAccountId: account,
        channelId: opt.channelId,
        requestId: opt.requestId,
        serverExtension: JSON.stringify(attachExt),
        signallingConfig: {
          offlineEnabled: this.offlineEnabled,
        },
      })
      if (reason === 2) {
        this._sendMessage(account, 'timeout')
      } else {
        this._sendMessage(account, 'canceled')
      }

      this.resetState()
      this.emit('afterSignalCancel', attachExt)
      logger.log(TAG_NAME, 'signalCancel success')
    } catch (error: any) {
      if (
        error &&
        (error.message === 'INVITE_HAS_ACCEPT' ||
          error.code === 10410 ||
          error.message === 'INVITE_HAS_REJECT' ||
          error.code === 10409)
      ) {
        // 忽略邀请已经被接受的错误
      } else {
        this.resetState()
        this.emit('afterSignalCancel', attachExt)
      }

      logger.error(TAG_NAME, 'signalCancel failed:', error, this._channelInfo)
      throw error
    }
  }

  /**
   * 拒绝通话，可能通过占线、超时、主动等方式触发
   * V10: rejectInvite() with inviterAccountId
   */
  private async _signalReject(opt: {
    channelId: string
    requestId: string
    account: string
    attachExt: SignalControllerAttachExt
  }): Promise<void> {
    const reason = opt.attachExt.reason

    try {
      // reason 为 3 时，表示正在通话中，占线拒绝通知，不需要重置状态
      if (reason !== 3) {
        this.resetState()
        this.emit('afterSignalReject', opt.attachExt)
      }

      // V10: rejectInvite({ inviterAccountId, channelId, requestId, serverExtension })
      // account = callerId = the one who invited (inviterAccountId)
      await this._signal.rejectInvite({
        inviterAccountId: opt.account,
        channelId: opt.channelId,
        requestId: opt.requestId,
        serverExtension: JSON.stringify(opt.attachExt),
      })
      logger.log(TAG_NAME, 'rejectReject success')
    } catch (error) {
      logger.error(TAG_NAME, 'rejectReject failed:', error, this._channelInfo)
      throw error
    }
  }

  /**
   * 关闭信令房间
   * V10: closeRoom(channelId, offlineEnabled, serverExtension)
   */
  private async _signalHangup(opt: {
    channelId: string
    attachExt: SignalControllerAttachExt
    duration?: number
  }): Promise<void> {
    // Save info needed for call record before resetState clears channelInfo
    const savedCalleeId = this._channelInfo?.calleeId
    const savedCallerId = this._channelInfo?.callerId
    const duration = opt.duration

    try {
      this.resetState()
      this.emit('afterSignalHangup', opt.attachExt)
      // V10: closeRoom(channelId, offlineEnabled, serverExtension)
      await this._signal.closeRoom(
        opt.channelId,
        this.offlineEnabled,
        JSON.stringify(opt.attachExt)
      )
      logger.log('signalClose success')

      // Send call record: the local user hung up, so notify the remote user
      const remoteUserId = savedCalleeId || savedCallerId
      if (remoteUserId) {
        this._sendMessage(remoteUserId, 'completed', duration)
      }
    } catch (error) {
      // 这里忽略关闭房间的错误
      logger.warn(
        TAG_NAME,
        'signalClose fail but resolve:',
        error,
        this._channelInfo
      )
      // throw error
    }
  }

  /**
   * 单人通话下，需要通知服务端退出的情况
   * @param userId IM的account账号
   * @param status
   */
  private async _sendMessage(
    userId: string,
    status: 'completed' | 'canceled' | 'rejected' | 'timeout' | 'busy',
    duration?: number
  ): Promise<void> {
    if (!this.enableRecord) {
      logger.log(TAG_NAME, 'sendMessage skip')
      return
    }

    const statusMap = {
      completed: 1,
      canceled: 2,
      rejected: 3,
      timeout: 4,
      busy: 5,
    }
    const attach = {
      type: this._channelInfo?.type,
      channelId: this._channelInfo?.channelId,
      status: statusMap[status],
      durations: duration !== undefined ? [{ duration }] : [],
    }

    try {
      // @ts-expect-error
      const callMsg = this._nim.V2NIMMessageCreator.createCallMessage(
        Number(attach.type),
        attach.channelId,
        attach.status,
        attach.durations
      )
      const { message } = await this._nim.V2NIMMessageService.sendMessage(
        callMsg,
        this._nim.V2NIMConversationIdUtil.p2pConversationId(userId),
        {}
      )

      logger.log(TAG_NAME, 'sendMessage success', attach, userId, message)
      this.emit('afterCallRecordSend', {
        ...message,
        accId: userId,
        callType: attach.type || '',
        callStatus: attach.status,
      })
    } catch (error: any) {
      logger.error(TAG_NAME, 'sendMessage fail:', attach, error.toString())
      // throw error
    }
  }

  /**
   * V10: Format SDK channel info using new field names
   * @param data - {channelInfo, members} from getRoomInfoByChannelName or roomInfo from call/joinRoom
   * @param rtcInfo - rtcInfo from call/joinRoom result (nullable)
   */
  private _formatSDKChannelInfo(
    data: { channelInfo: any; members?: any[] },
    rtcInfo?: any
  ): SignalControllerChannelInfo {
    const { channelInfo, members = [] } = data
    const res: SignalControllerChannelInfo = {
      // V10: channelValid (true=valid), so invalid = !channelValid
      invalid: !channelInfo.channelValid,
      channelId: channelInfo.channelId,
      // V10: channelName (not name)
      channelName: channelInfo.channelName,
      // V10: channelType (not type)
      type: (channelInfo.channelType + '') as SignalControllerCallType,
      createTimestamp: channelInfo.createTime,
      expireTimestamp: channelInfo.expireTime,
      // V10: creatorAccountId (not creatorAccid)
      creatorId: channelInfo.creatorAccountId,
      members: members.map((item) => ({
        uid: item.uid + '',
        // V10: accountId (not accid)
        account: item.accountId,
        accid: item.accountId,
        accountId: item.accountId,
        createTimestamp: item.joinTime,
        expireTimestamp: item.expireTime,
      })),
      callerId: '',
      calleeId: '',
      requestId: '',
      // V10: channelExtension (not ext)
      ext: channelInfo.channelExtension,
      // V10: rtcInfo replaces pluginSetting.nertcInfo
      nertcChannelName: rtcInfo?.rtcChannelName,
      nertcToken: rtcInfo?.rtcToken,
      nertcTokenTtl:
        rtcInfo?.rtcTokenTtl === void 0
          ? void 0
          : rtcInfo.rtcTokenTtl + '',
      nertcJoinRoomResponse: undefined,
    }

    Object.keys(res).forEach((key) => {
      if (res[key] === void 0) {
        delete res[key]
      }
    })

    logger.log(TAG_NAME, '_formatSDKChannelInfo', data, res)
    return res
  }
}

export default SignalController
