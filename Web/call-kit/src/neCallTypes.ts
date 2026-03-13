import {
  SignalControllerCallRecord,
  SignalControllerCallType,
  SignalControllerPushInfo,
  SignalControllerCallingStatus,
} from './signalController/types'

import { RTCConfig } from './rtcController/types'
import V2NIM from 'nim-web-sdk-ng'

export type { SignalControllerCallType, SignalControllerCallRecord, RTCConfig }

export type UserInfo = {
  /** im id */
  accId: string
  /** im rtc id */
  uid?: string
  /** 角色 */
  role?: 'caller' | 'callee'
}

export type NECallConfig = {
  /** 支持离线，默认支持离线 */
  enableOffline?: boolean
  /** 开启切换视频通话确认，默认不开启 */
  enableSwitchVideoConfirm?: boolean
  /** 开启切换音频通话确认，默认不开启 */
  enableSwitchAudioConfirm?: boolean
  /** 主叫是否在呼叫时加入RTC，默认不提前加入 */
  enableJoinRtcWhenCall?: boolean
}

export type NECallInfo = {
  /** 当前用户的im id */
  currentAccId: string
  /** 当前通话状态 */
  callStatus: SignalControllerCallingStatus
  /** 通话id */
  callId?: string
  /** 主叫信息 */
  callerInfo?: UserInfo
  /** 被叫信息 */
  calleeInfo?: UserInfo
  /** 通话类型 */
  callType?: number | SignalControllerCallType
  /** 信令通道id */
  channelId?: string
  /** 信令信息 */
  signalInfo?: any
  /** rtc信息 */
  rtcInfo?: any
}

export type NECallParam = {
  /** 被叫accId */
  accId: string
  /** 呼叫类型 */
  callType: SignalControllerCallType
  /** 扩展信息，透传到到被叫onInvited */
  extraInfo?: string
  /** 自定义channelName，不传会默认生成 */
  rtcChannelName?: string
  /** 自定义的呼叫全局抄送信息，用户服务端接收抄送时设置自己的业务标识 */
  globalExtraCopy?: string
  /** 用户推送自定义内容，为空时使用内部默认推送配置 */
  pushConfig?: SignalControllerPushInfo
}

export type NEHangupParam = {
  /** 只有拒绝接听的时候会使用 0 正常流程,1 token 请求失败, 2 超时, 3 用户占线, 4 rtc 初始化失败, 5 加入rtc失败, 6 cancel 取消参数错误, 7 发起呼叫失败 */
  reason?: number
  /** 附加信息 */
  extraString?: string
  /** 信令通道id，可选 */
  channelId?: string
  /** 通话时长（秒），用于话单生成 */
  duration?: number
}

export type NESetupConfig = {
  /** 云信im实例 */
  nim: V2NIM
  /** 云信appKey */
  appkey: string
  /** RTC私有化配置 */
  rtcContext?: RTCConfig
  /** 被叫是否自动加入channel，默认不加入 */
  enableAutoJoinSignalChannel?: boolean
  /** 是否关闭话单，默认不关闭 */
  enableRecord?: boolean
  /** 主叫是否在呼叫时加入RTC，默认不提前加入 */
  enableJoinRtcWhenCall?: boolean
  /** 是否开启邀请消息延迟标记已读，默认关闭 */
  enableMarkInviteEventDelay?: boolean
  /** 是否打印日志 */
  debug?: boolean
}

export type NECallEndInfo = {
  /** 结束原因: 0 正常（兼容老版本） 1 token 错误 2 超时响应  3 呼叫占线  4 rtc 初始化失败  5 加入 rtc 失败  6 取消参数错误  7 呼叫失败   8 用户被踢出  9 rtcUid 错误为空  10 本地 rtc 房间断开  11 本地主动取消呼叫   12 另一段收到取消呼叫通知  13  本地主动拒绝呼叫  14 另一端收到被叫拒绝通知   15 本地主动挂断      16 另一段收到挂断通知   17 多端登录下其他端已经拒绝  18 多端登录下其他端已经接听  19 另一端用户非正常断开rtc房间  20 另一段用户正常离开rtc房间  21 接听失败 */
  reasonCode: number
  /** 附加信息 */
  extraString?: string
  /** 结束消息 */
  message?: string
}

export type NECallTypeChangeInfo = {
  /** 切换类型 1：语音，2：视频 */
  callType: SignalControllerCallType
  /** 切换状态 1：邀请，2：同意，3：拒绝 */
  state: number
}

export type NEInviteInfo = {
  /** 呼叫id */
  callerAccId: string
  /** 呼叫类型 1 音频 2 视频 */
  callType: SignalControllerCallType
  /** 附加信息 */
  extraInfo?: string
  /** 用于挂断 */
  channelId: string
}

export interface NECallEvents {
  /** 通话邀请 */
  onReceiveInvited: [NEInviteInfo]
  /** 通话方式切换 */
  onCallTypeChange: [NECallTypeChangeInfo]
  /** rtc建立 */
  onCallConnected: [NECallInfo | undefined]
  /** 通话结束 */
  onCallEnd: [NECallEndInfo]
  /** 话单回调 */
  onRecordSend: [SignalControllerCallRecord]
}
