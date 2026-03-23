import type {
  NECall,
  NECallInfo,
  NECallParam,
  NEGroupCall,
  NEGroupCallCallFnParams,
  NEGroupCallCallRes,
  NEGroupCallConfig,
  NESetupConfig,
  SignalControllerCallType,
} from '@xkit-yx/call-kit'

export interface CommonError extends Error {
  code: number | string
  message: string
}

export type CallType = SignalControllerCallType
export type CallViewStatus = 0 | 1 | 2 | 3
export type GroupCallViewStatus = 0 | 1 | 2

export interface Position {
  x: number
  y: number
}

export interface UserInfo {
  account: string
  avatar: string
  nick: string
  tel: string
  state?: number
  videoEnable?: boolean
}

export interface SwitchCallTypeBtn {
  switchToVideo?: boolean
  switchToAudio?: boolean
}

export interface CallViewProviderProps {
  neCallConfig: NESetupConfig
  position?: Position
  uiConfig?: {
    switchCallTypeBtn?: SwitchCallTypeBtn
  }
}

export interface GroupCallViewProviderProps {
  neGroupCallConfig: NEGroupCallConfig
  position?: Position
  onInviteClick?: (event: MouseEvent) => void
}

export interface CallViewProviderRef {
  call: (opt: NECallParam) => Promise<NECallInfo | undefined>
  neCall?: NECall
}

export interface GroupCallViewProviderRef {
  groupCall: (
    opt: NEGroupCallCallFnParams
  ) => Promise<NEGroupCallCallRes | undefined>
  groupJoin: (opt: {
    callId: string
    rtcUid?: number
  }) => Promise<NEGroupCallCallRes | undefined>
  neGroupCall?: NEGroupCall
}

export type GlobalCallErrorCode =
  | 'CALL_PROVIDER_NOT_READY'
  | 'GROUP_PROVIDER_NOT_READY'
  | 'GROUP_JOIN_NOT_READY'

export interface GlobalCallError extends Error {
  code: GlobalCallErrorCode
}

export interface UseCallResult extends CallViewProviderRef {}

export interface UseGroupCallResult extends GroupCallViewProviderRef {}

export type NIMMsgScene = 'p2p' | 'team' | 'superTeam'
export type NIMMsgType =
  | 'video'
  | 'audio'
  | 'image'
  | 'text'
  | 'geo'
  | 'notification'
  | 'file'
  | 'tip'
  | 'robot'
  | 'g2'
  | 'custom'

export interface NIMMessage {
  scene?: NIMMsgScene
  from?: string
  to?: string
  time?: number
  type?: NIMMsgType
  content?: string
  account?: string
  [key: string]: unknown
}

export interface NIMUserProfile {
  accountId: string
  avatar?: string
  name?: string
  mobile?: string
}

export interface NIMLike {
  account?: string
  on: (event: string, handler: (payload: any) => void) => void
  off: (event: string, handler: (payload: any) => void) => void
  V2NIMNotificationService?: {
    on: (event: string, handler: (payload: any) => void) => void
    off: (event: string, handler: (payload: any) => void) => void
  }
  V2NIMUserService: {
    getUserList: (accounts: string[]) => Promise<NIMUserProfile[]>
  }
}

export interface TrackInitOptions {
  appKey: string
  version: string
  component: string
}

export interface GlobalCallRegistry {
  callMounted: boolean
  callReady: boolean
  groupMounted: boolean
  groupReady: boolean
  call?: (opt: NECallParam) => Promise<NECallInfo | undefined>
  groupCall?: (
    opt: NEGroupCallCallFnParams
  ) => Promise<NEGroupCallCallRes | undefined>
  groupJoin?: (opt: {
    callId: string
    rtcUid?: number
  }) => Promise<NEGroupCallCallRes | undefined>
  neCall?: NECall
  neGroupCall?: NEGroupCall
}
