import RTCController from './rtcController'
import { RTCConfig } from './rtcController/types'
import EventEmitter from 'eventemitter3'
import { logger, createLoggerDecorator } from './logger'

enum HttpRequestProxy {
  GET = '1',
  POST = '2',
  PUT = '3',
  DELETE = '4',
}

type UserInfo = {
  accId: string
  uid?: number
}

export type NEGroupCallConfig = {
  nim: any
  appkey: string
  rtcConfig?: RTCConfig
  debug?: boolean
}

export type NEGroupCallCallFnParams = {
  /** 呼叫id */
  callId?: string
  /** 呼叫人列表 */
  calleeList: string[]
  /** 话单发送的群组 */
  groupId?: string
  /** 1: 讨论组 2: 高级群 3: 聊天室 */
  groupType?: number
  /** 邀请模式 */
  inviteMode?: number
  /** 加入模式 0 任何人都可以加入群聊通话，1 只能被邀请 */
  joinMode?: number
  /** 附加信息 */
  extraInfo?: string
  /** 超时时间 */
  timeout?: number
  /** 自定义推送参数 */
  pushParam?: {
    /** 推送模式，0.关闭，1.开启，2.强制开启 */
    pushMode?: number
    /** 推送文案，最长 500 个字符 */
    pushContent?: string
    /** 推送对应的 payload，必须是 JSON 格式且不能超过 2000 字符 */
    payload?: string
    /** 客户端本地的声音文件名，长度不要超过 30 个字符 */
    sound?: string
  }
}

export type NEGroupCallInviteFnParams = {
  /** 呼叫id列表 */
  calleeList: string[]
}

export type NEGroupCallReceiveInfo = {
  isFromCallKitServer: true // 为避免和用户自定义消息使用冲突添加本字段。解析不到此字段时则忽略。
  callId: string
  type: 0
  callerAccid: string // 发起者accId
  calleeList: string[] // 被叫方accId列表
  members: NEGroupCallMember[]
  inviteMode: number // 邀请模式，0 通话中任何人均可邀请，1 通话中只有发起者才能邀请他人
  joinMode: number // 加入模式，0 任何人都可以加入群聊通话，1 只能被邀请
  startTimestamp: number // 开始时间戳
  timeout: number // 呼叫超时时间
  rtcChannelName: string // 本次通话应加入的音视频房间名称
  extraInfo: string // 扩展信息到被叫
}

export type NEGroupCallMember = {
  imAccid: string
  rtcUid: number
  rtcToken: string
  state: number // 1 pending 2 accepted 3 rejected
  reason: string
}

export type NEGroupCallCallRes = {
  callId: string
  callerUid: number
  rtcChannelName: string
  startTimestamp: number
  members: NEGroupCallMember[]
  timeout: number
  rtcToken: string
}

type NEGroupCallQueryInfo = {
  callId: string
  callerAccid: string
  callerUid: number
  channelName: string
  extraInfo: string
  inviteMode: number
  joinMode: number
  safeMode: number
  startTimestamp: number
  timeout: number
}

type NEGroupCallAcceptRes = {
  callId: string
  callerAccid: string
  callerUid: number
  inviteMode: number
  joinMode: number
  members: NEGroupCallMember[]
  rtcChannelName: string
  safeMode: number
  startTimestamp: number
  rtcToken: string
}

type NEGroupCallEndInfo = {
  reason: string //
}

interface NEGroupCallEvents {
  onReceiveInvited: [NEGroupCallReceiveInfo]
  onMembersChange: [NEGroupCallMember[]]
  onCallEnd: [NEGroupCallEndInfo?]
}

const loggerDecorator = createLoggerDecorator('NEGroupCallEngine', logger)

class NEGroupCallEngine extends EventEmitter<NEGroupCallEvents> {
  static instance?: NEGroupCallEngine

  public rtcController!: RTCController
  public callStatus = 0 // 0: 未呼叫 1: 被呼叫 2: 已接听

  private _nim: any
  private _baseUrl!: string
  private _currentUserInfo!: UserInfo
  private _callId?: string
  private _rtcViews: { [key: string]: HTMLElement } = {} // a
  private _members: NEGroupCallMember[] = []
  private _rtcChannelName?: string
  private _rtcToken?: string
  private _rejectTimer?: NodeJS.Timeout

  constructor() {
    super()
  }

  setup(params: NEGroupCallConfig): void {
    const { nim, appkey, rtcConfig, debug } = params

    this.rtcController = new RTCController({ appkey, rtcConfig, debug })

    this._currentUserInfo = { accId: nim.account }

    this._baseUrl = `/scene/groupCall/${appkey}/call/`

    this._nim = nim

    this._handleRtcEvents()

    logger.setLevel(debug ? 'debug' : 'warn')
  }
  /**
   * 用于接收im自定义消息
   * @param msg im onmsg 事件参数
   */
  public receiveNimMsg(msg: string): boolean {
    const data = JSON.parse(msg)

    if (data.isFromCallKitServer) {
      // 当前不在闲置，且不是当前通话的消息，直接拒绝，显示占用
      if (this.callStatus !== 0 && data.callId !== this._callId) {
        if (data.type === 1) {
          this._busyReject({ callId: data.callId })
        }
      } else {
        // type: 1 邀请
        if (data.type === 1) {
          this._rejectTimer = setTimeout(() => {
            this._resetState()
            this.emit('onCallEnd')
          }, 1000 * data.timeout)
          this.callStatus = 1
          this._callId = data.callId
          this._queryMembers().then((members) => {
            data.members = members
            this._members = data.members
            this.emit('onReceiveInvited', data)
          })
          // type: 2 成员变更
        } else if (data.type === 2) {
          const member = data.members.find(
            (member) => member.imAccid === this._currentUserInfo.accId
          )
          const isEnd = member && this.callStatus === 2 && member.state === 3
          const isHandleByOtherClient =
            member &&
            this.callStatus === 1 &&
            (member.state === 3 || member.state === 2)

          if (isHandleByOtherClient || isEnd) {
            this.rtcController.leaveRTCChannel()
            this._resetState()
            this.emit('onCallEnd')
          } else {
            this._updateMembers(data.members)
            this.emit('onMembersChange', this._members)
          }
          // type: 3 结束
        } else if (data.type === 3) {
          this.rtcController.leaveRTCChannel()
          this._resetState()
          this.emit('onCallEnd')
        }
      }

      return true
    } else {
      return false
    }
  }
  /**
   * 发起群组呼叫
   * @param opt
   * @returns
   */
  @loggerDecorator
  public async groupCall(
    opt: NEGroupCallCallFnParams
  ): Promise<NEGroupCallCallRes> {
    let url = this._baseUrl

    if (opt.callId) {
      url += opt.callId
    }

    const res = await this._nimHttpRequestProxy<NEGroupCallCallRes>(
      url,
      HttpRequestProxy.PUT,
      {
        ...opt,
        safeMode: 1,
      }
    )

    this.callStatus = 2
    this._rtcToken = res.rtcToken
    this._currentUserInfo.uid = res.callerUid
    this._rtcChannelName = res.rtcChannelName
    this._callId = res.callId
    res.members = await this._queryMembers()
    this._members = res.members
    this.emit('onMembersChange', this._members)
    return res
  }
  /**
   * 接收群组呼叫
   */
  @loggerDecorator
  public async groupAccept(): Promise<NEGroupCallAcceptRes> {
    const url =
      this._baseUrl +
      this._callId +
      '/member/' +
      this._currentUserInfo.accId +
      '/state/' +
      'accept'
    const res = await this._nimHttpRequestProxy<NEGroupCallAcceptRes>(
      url,
      HttpRequestProxy.POST,
      {
        safeMode: 1,
      }
    )

    this.callStatus = 2
    res.members = this._sortMembers(res.members)
    this._members = res.members
    this._rtcChannelName = res.rtcChannelName
    this._rtcToken = res.rtcToken
    this._callId = res.callId
    const member = res.members.find(
      (item) => item.imAccid === this._currentUserInfo.accId
    )

    if (member) {
      this._currentUserInfo.uid = member.rtcUid
    }

    this._rejectTimer && clearTimeout(this._rejectTimer)
    return res
  }
  /**
   * 挂断群组通话
   */
  @loggerDecorator
  public async groupHangup(): Promise<void> {
    let url =
      this._baseUrl +
      this._callId +
      '/member/' +
      this._currentUserInfo.accId +
      '/state/'

    switch (this.callStatus) {
      case 1:
        url += 'reject'
        break
      case 2:
        url += 'leave'
        break
    }

    if (this.callStatus === 2) {
      this.rtcController.leaveRTCChannel()
    }

    this._resetState()
    await this._nimHttpRequestProxy<NEGroupCallAcceptRes>(
      url,
      HttpRequestProxy.POST,
      {}
    )
  }
  /**
   * 邀请参加群组呼叫
   */
  @loggerDecorator
  public async groupInvite(opt: NEGroupCallInviteFnParams): Promise<void> {
    const url = this._baseUrl + this._callId + '/member/invite'

    await this._nimHttpRequestProxy(url, HttpRequestProxy.POST, opt)
    this._members = await this._queryMembers()
    this.emit('onMembersChange', this._members)
  }
  /**
   * 加入群组通话
   * @param params.callId 群组呼叫id
   * @param params.rtcUid 加入群组通话的用户uid
   */
  @loggerDecorator
  public async groupJoin(params: {
    callId: string
    rtcUid?: number
  }): Promise<NEGroupCallCallRes> {
    const url = this._baseUrl + params.callId + '/member/join'
    const res = await this._nimHttpRequestProxy<NEGroupCallCallRes>(
      url,
      HttpRequestProxy.POST,
      params
    )

    this._currentUserInfo.uid = res.members.find(
      (item) => item.imAccid === this._currentUserInfo.accId
    )?.rtcUid
    this._callId = params.callId
    this.callStatus = 2
    this._rtcChannelName = res.rtcChannelName
    this._members = await this._queryMembers()
    this.emit('onMembersChange', this._members)
    return res
  }
  /**
   * 查询通话信息
   * @param params.callId 通话id
   */
  @loggerDecorator
  public async groupQueryCallInfo(params?: {
    callId: string
  }): Promise<NEGroupCallQueryInfo> {
    const url = this._baseUrl + (params?.callId ?? this._callId)
    const res = await this._nimHttpRequestProxy<NEGroupCallQueryInfo>(
      url,
      HttpRequestProxy.GET
    )

    return res
  }
  /**
   * 开关本地视频
   * @param enabled true开启，false关闭
   */
  public async enableLocalVideo(enabled: boolean): Promise<void> {
    if (enabled) {
      await this.rtcController.enableLocalVideo(enabled)
    } else {
      // iOS 异常，先不 mute
      // await this.rtcController.muteLocalVideo(!enabled)
      await this.rtcController.enableLocalVideo(enabled)
    }
  }
  /**
   * 开关本地音频
   * @param enabled true开启，false关闭
   */
  public async enableLocalAudio(enabled: boolean): Promise<void> {
    await this.rtcController.muteLocalAudio(!enabled)
  }
  /**
   * 设置用户视图
   * @param view 视频渲染容器
   * @param accId im id
   */
  public setRtcView(view: HTMLElement, accId: string): void {
    // 更新用户视图
    if (this._rtcViews[accId] && view !== this._rtcViews[accId]) {
      const uid = this._members.find((item) => item.imAccid === accId)?.rtcUid
      const stream = this.rtcController.remoteStreams.find(
        (stream) => stream.getId() === uid
      )

      if (uid && stream) {
        this.rtcController.setRemoteView(view, uid)
        this.rtcController.playRemoteStream(stream)
      }
    }

    this._rtcViews[accId] = view
  }
  /**
   * 本端加入rtc房间，需要
   * @param opt video: 加入时是否开启视频
   */
  public async joinRtc(opt?: { video?: boolean }): Promise<void> {
    if (!this._rtcChannelName) {
      throw new Error('rtcChannelName is empty')
    }

    if (!this._currentUserInfo.uid) {
      throw new Error('current uid is empty')
    }

    await this.rtcController.joinRTCChannel({
      channelName: this._rtcChannelName,
      token: this._rtcToken,
      uid: this._currentUserInfo.uid,
    })
    const localView = this._rtcViews[this._currentUserInfo.accId]

    this.rtcController.setLocalView(localView)
    await this.rtcController.initLocalStream({
      uid: this._currentUserInfo.uid,
      audio: true,
      video: opt?.video ?? false,
      screen: false,
    })
    await this.rtcController.playLocalStream()
    await this.rtcController.publishLocalStream()
  }
  /**
   * 销毁实例
   */
  public destroy(): void {
    this.rtcController.destroy()
    this._resetState()
  }

  private _resetState(): void {
    this.callStatus = 0
    this._callId = undefined
    this._rtcChannelName = undefined
    this._rtcViews = {}
    this._members = []
    this._rejectTimer && clearTimeout(this._rejectTimer)
  }

  private async _busyReject(opt: { callId: string }): Promise<void> {
    const url =
      this._baseUrl +
      opt.callId +
      '/member/' +
      this._currentUserInfo.accId +
      '/state/reject'

    await this._nimHttpRequestProxy<NEGroupCallAcceptRes>(
      url,
      HttpRequestProxy.POST,
      { reason: 'busy' }
    )
  }

  private async _queryMembers(): Promise<NEGroupCallMember[]> {
    const url = this._baseUrl + this._callId + '/members'
    const res = await this._nimHttpRequestProxy<NEGroupCallAcceptRes>(
      url,
      HttpRequestProxy.GET
    )

    res.members = this._sortMembers(res.members)
    return res.members
  }

  private _updateMembers(members: NEGroupCallMember[]): void {
    members.forEach((member) => {
      const index = this._members.findIndex(
        (item) => item.imAccid === member.imAccid
      )

      if (index !== -1) {
        this._members[index] = member
      } else {
        this._members.push(member)
      }
    })
  }

  // 把自己放到第一位
  private _sortMembers(members: NEGroupCallMember[]): NEGroupCallMember[] {
    const index = members.findIndex(
      (item) => item.imAccid === this._currentUserInfo.accId
    )

    if (index !== -1) {
      return members.splice(index, 1).concat(members)
    }

    return members
  }

  private _handleRtcEvents() {
    this.rtcController.on('streamSubscribed', (stream) => {
      const uid = stream.getId()

      if (uid) {
        const accId = this._members.find((item) => item.rtcUid === uid)?.imAccid

        if (accId) {
          const view = this._rtcViews[accId]

          this.rtcController.setRemoteView(view, uid)
          this.rtcController.playRemoteStream(stream)
        } else {
          // 这里可能存在rtc通知到了，成员变更没到的情况，所以需要查询一下
          this._queryMembers().then((res) => {
            this._members = res
            const accId = this._members.find(
              (item) => item.rtcUid === uid
            )?.imAccid

            if (accId) {
              const view = this._rtcViews[accId]

              this.rtcController.setRemoteView(view, uid)
              this.rtcController.playRemoteStream(stream)
            }
          })
        }
      }
    })
    this.rtcController.on('error', () => {
      this.rtcController.leaveRTCChannel()
      this._resetState()
      this.emit('onCallEnd')
    })
  }

  private _nimHttpRequestProxy<T>(
    url: string,
    method: HttpRequestProxy,
    data?: any
  ): Promise<T> {
    return this._nim.passThrough
      .request({
        header: JSON.stringify({
          groupCallVer: '1.6.0',
          user: this._currentUserInfo.accId,
        }),
        method,
        path: url,
        body: data && JSON.stringify(data),
      })
      .then((data) => {
        const res = JSON.parse(data.body)

        if (res.code === 0) {
          return res.data
        } else {
          throw res
        }
      })
  }
  //静态方法
  static getInstance(): NEGroupCallEngine {
    if (!this.instance) {
      this.instance = new NEGroupCallEngine()
    }

    return this.instance
  }
}

export default NEGroupCallEngine
