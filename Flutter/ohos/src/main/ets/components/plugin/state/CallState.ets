/** 通话媒体类型 */
export enum MediaType {
  AUDIO = 1,
  VIDEO = 2,
}

/** 通话用户信息 */
export interface CallUser {
  accId: string;
  callStatus: number; // 对应 Flutter 侧 CallStatus enum 的整数值
  avatar?: string;
  name?: string;
  videoAvailable?: boolean; // 对端视频是否可用
}

/** CallState 状态变更监听器 */
export type CallStateListener = () => void;

/** 通话状态单例 */
export class CallState {
  private static instance: CallState | null = null;

  selfUser: CallUser = { accId: '', callStatus: 0 };
  remoteUserList: CallUser[] = [];
  mediaType: number = MediaType.AUDIO;
  startTime: number = 0;
  resourceMap: Map<string, string> = new Map();
  incomingBannerEnabled: boolean = true;

  private listeners: Set<CallStateListener> = new Set();

  private constructor() {}

  static getInstance(): CallState {
    if (!CallState.instance) {
      CallState.instance = new CallState();
    }
    return CallState.instance;
  }

  /** 注册状态变更监听器 */
  addListener(listener: CallStateListener): void {
    this.listeners.add(listener);
  }

  /** 移除状态变更监听器 */
  removeListener(listener: CallStateListener): void {
    this.listeners.delete(listener);
  }

  /** 通知所有监听器状态已变更 */
  notifyListeners(): void {
    this.listeners.forEach(listener => {
      try {
        listener();
      } catch (e) {
        // 静默忽略监听器异常
      }
    });
  }

  /** 重置状态（通话结束时调用） */
  reset(): void {
    this.selfUser = { accId: '', callStatus: 0 };
    this.remoteUserList = [];
    this.mediaType = MediaType.AUDIO;
    this.startTime = 0;
    this.notifyListeners();
  }
}
