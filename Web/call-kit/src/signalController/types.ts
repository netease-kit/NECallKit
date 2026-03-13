import { V2NIMMessage } from 'nim-web-sdk-ng/dist/v2/NIM_BROWSER_SDK/V2NIMMessageService'

export type SignalControllerCallType = '1' | '2' | '3' // 1:音频;2:视频;3:其他
// export type SignalControllerR

export enum SignalControllerCallingStatus {
  idle = 0, // 闲置
  calling = 1, // 正在呼叫
  called = 2, // 正在被呼叫
  inCall = 3, // 通话中
}

export type SignalControllerCallParams = {
  /** 被叫im id */
  accId: string
  /** 呼叫类型 */
  callType: SignalControllerCallType
  /** 信令房间名称，可选 */
  signalChannelName?: string
  /** 额外信息，被邀请端可以获取，可选 */
  extraInfo?: string
  /** 全局抄送，可选 */
  globalExtraCopy?: string
  /** rtc 房间名称，可选 */
  nertcChannelName?: string
  /** rtc token 超时时间，可选 */
  nertcTokenTtl?: number
  /** rtc 快呼叫参数，内部实现，用户可以忽略 */
  nertcJoinRoomQueryParamMap?: string
  /** 用户推送自定义内容，为空时使用内部默认推送配置 */
  pushConfig?: SignalControllerPushInfo
}

export type SignalControllerAttachExt = {
  callId: string
  channelName: string
  version: string
  callType: number // 0 | 1   单聊：0 群组：1
  reason: number // 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7
  rtcTokenTtl?: number
  cid?: number // 额外操作通知
  type?: number // 1:音频;2:视频;
  state?: number // 1: 邀请 2: 同意 3: 拒绝
  global_extra?: string
  extraInfo?: string
  // 扩展信息
  _attachment?: string
}

export type SignalControllerChannelInfo = {
  // 接口返回信息
  ext?: string
  channelId: string
  channelName: string
  type: SignalControllerCallType
  createTimestamp: number // 频道创建时间点
  expireTimestamp: number // 频道失效时间点
  creatorId: string // 频道创建者id
  invalid: boolean // 频道是否有效
  members: SignalControllerMember[]
  nertcChannelName?: string
  nertcToken?: string
  nertcTokenTtl?: string
  nertcJoinRoomResponse?: string
  // 扩展信息
  callerId: string
  calleeId: string
  requestId: string
  attachExt: SignalControllerAttachExt
}

export type SignalControllerPushInfo = {
  pushTitle?: string
  pushContent?: string
  pushPayload?: string
  needPush?: boolean
  needBadge?: boolean
}

export type SignalControllerMember = {
  uid: string // 该成员在频道中对应的uid
  account: string // 成员account账号
  accid: string // 成员account账号，sdk问题，字段没统一
  accountId: string // V10 新字段，与 accid 保持一致
  createTimestamp?: number
  expireTimestamp?: number
}

export type SignalControllerChannelEvent = {
  eventType: string // 这里应该是string，文档有误
  channelName: string
  channelId: string
  channelCreateTime: string
  channelExpireTime: string
  creator: string
  from: string
  attach: string
  attachExt: string
  time: number
  members: SignalControllerMember[]
  pushInfo: SignalControllerPushInfo
  requestId: string
  to: string
  channelInValid: boolean
  type: SignalControllerCallType
  msgid: number
}

export interface SignalControllerCallRecord extends V2NIMMessage {
  accId: string
  callType: string
  callStatus: number
}

export interface SignalControllerEvents {
  afterSignalCallEx: [SignalControllerChannelInfo]
  afterSignalAccept: [SignalControllerChannelInfo]
  afterSignalReject: [SignalControllerAttachExt]
  afterSignalCancel: [SignalControllerAttachExt]
  afterSignalHangup: [SignalControllerAttachExt]
  afterCallRecordSend: [SignalControllerCallRecord]
  whenSignalCancel: [SignalControllerAttachExt]
  whenSignalReject: [SignalControllerAttachExt]
  whenSignalAccept: [SignalControllerChannelInfo]
  whenSignalInvite: [SignalControllerChannelInfo]
  whenSignalControl: [SignalControllerAttachExt]
  whenSignalRoomClose: [SignalControllerAttachExt]
  whenSignalRejectOtherClient: void
  whenSignalAcceptOtherClient: void
}
