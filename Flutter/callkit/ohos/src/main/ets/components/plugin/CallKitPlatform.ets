import { BinaryMessenger } from '@ohos/flutter_ohos';
import { common } from '@kit.AbilityKit';
import {
  NECallEngine,
  NECallEngineDelegate
} from '@yunxin/callkit';
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager';
import wantAgent, { WantAgent } from '@ohos.app.ability.wantAgent';
import { BusinessError } from '@ohos.base';
import {
  NECallEndInfo,
  NECallInfo,
  NECallType,
  NECallSwitchState,
  NEInviteInfo,
  NECallTypeChangeInfo,
  NESetupConfig,
  NECallParam,
  NECallConfig
} from '@yunxin/callkit';
import { NIMInterface } from '@nimsdk/base';
import { NIMSdk } from '@nimsdk/nim';
import {
  CallKitApi,
  CallKitEventSink,
  CallConfig,
  CallEndInfo,
  CallInfo,
  CallParam,
  CallResponse,
  CallTerminalCode,
  CallType,
  CallTypeChangeInfo,
  CallSwitchState,
  HangupParam,
  InviteInfo,
  NERtcASRCaptionConfig,
  SetupConfig,
  SimpleResponse,
  SwitchParam,
  UserInfo,
  ViewParam,
  SignalInfo,
  RtcInfo,
  CallEngineStatus
} from './Pigeon';
import { VideoViewFactory } from './VideoViewFactory';
import { Reply } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BasicMessageChannel';

const TAG = "CallKitPlatform";

// Result 接口定义
interface Result<T> {
  success(value: T): void;
  error(error: Error): void;
}

// 辅助：构建成功的 SimpleResponse
function okSimple(): SimpleResponse {
  return new SimpleResponse(0, "Success", 0, 0, "");
}

// 辅助：构建失败的 SimpleResponse
function errSimple(code: number, msg: string): SimpleResponse {
  return new SimpleResponse(code, msg, 0, 0, "");
}

// 辅助：将 NECallEngine 回调的通话类型映射到 Pigeon CallType
function toCallType(type: NECallType): CallType {
  if (type === NECallType.VIDEO) {
    return CallType.VIDEO;
  }
  return CallType.AUDIO;
}

// 辅助：将 NECallType 转换为 NECallSwitchState
function toNECallSwitchState(state: CallSwitchState): NECallSwitchState {
  if (state === CallSwitchState.AGREE) {
    return NECallSwitchState.SWITCHED;
  }
  return NECallSwitchState.SWITCHING;
}

// 辅助：将 NECallInfo 映射为 Pigeon CallInfo
function toCallInfo(info: NECallInfo): CallInfo {
  const callerInfo = new UserInfo(
    info.callerInfo?.userId ?? "",
    Number(info.callerInfo?.uid ?? BigInt(0))
  );
  const calleeInfo = new UserInfo(
    info.calleeInfo?.userId ?? "",
    Number(info.calleeInfo?.uid ?? BigInt(0))
  );
  const signalInfo = new SignalInfo(
    info.signalInfo?.channelName ?? "",
    "",
    info.signalInfo?.channelName ?? "",
    "",
    ""
  );
  const rtcInfo = new RtcInfo(
    info.rtcInfo?.channelId ?? "",
    info.rtcInfo?.token ?? "",
    Number(info.rtcInfo?.uid ?? BigInt(0)),
    Number(info.rtcInfo?.cid ?? BigInt(0))
  );
  // 将 NECallEngineStatus 映射为 CallEngineStatus
  let callStatus: CallEngineStatus;
  switch (info.callStatus) {
    case 1:
      callStatus = CallEngineStatus.CALLING;
      break;
    case 2:
      callStatus = CallEngineStatus.CALLED;
      break;
    case 3:
      callStatus = CallEngineStatus.IN_CALL;
      break;
    default:
      callStatus = CallEngineStatus.IDLE;
  }
  return new CallInfo(
    info.callId ?? "",
    info.currentAccId ?? "",
    callerInfo,
    calleeInfo,
    toCallType(info.callType),
    signalInfo,
    rtcInfo,
    callStatus
  );
}

// 创建空的 CallInfo
function emptyCallInfo(): CallInfo {
  const emptyUserInfo = new UserInfo("", 0);
  const emptySignalInfo = new SignalInfo("", "", "", "", "");
  const emptyRtcInfo = new RtcInfo("", "", 0, 0);
  return new CallInfo(
    "",
    "",
    emptyUserInfo,
    emptyUserInfo,
    CallType.NONE,
    emptySignalInfo,
    emptyRtcInfo,
    CallEngineStatus.IDLE
  );
}

// 4.1: CallKitPlatform 实现 CallKitApi 抽象类
export class CallKitPlatform extends CallKitApi {
  // 4.2: 持有 eventSink
  private eventSink: CallKitEventSink;
  private context: common.Context;
  // 用于在 destroy 时注销回调
  private delegate: NECallEngineDelegate | null = null;
  // 后台运行状态标识
  private isBackgroundRunning: boolean = false;
  // 多端拒绝保护：记录最后一次通话结束的时间戳（用于防止连续来电响铃）
  private lastCallEndTime: number = 0;
  private static readonly CALL_END_COOLDOWN_MS: number = 3000; // 通话结束后的冷却时间（毫秒）

  constructor(messenger: BinaryMessenger, context: common.Context) {
    super();
    this.context = context;
    this.eventSink = new CallKitEventSink(messenger);
  }

  // 4.3: setup —— 初始化 NECallEngine
  setup(config: SetupConfig, result: Result<SimpleResponse>): void {
    try {
      const engine = NECallEngine.getInstance();
      
      // 从 NIMSdk 获取 NIM 实例（Flutter nim_core_v2 初始化后会创建实例，默认 id 为 0）
      const nim = NIMSdk.getInstance(0);
      
      if (!nim) {
        console.error(`[${TAG}] setup failed: NIM instance not available. Please ensure NimCore.instance.initialize() is called in Flutter before setup.`);
        result.success(errSimple(-1, "NIM instance not available. Please ensure NimCore is initialized before calling setup."));
        return;
      }
      
      console.info(`[${TAG}] setup: NIM instance obtained successfully`);
      
      const setupConfig: NESetupConfig = new NESetupConfig(
        this.context,
        nim,
        config.getAppKey(),
        "" // accountId
      );
      engine.setup(setupConfig).then((res) => {
        if (res.code === 0) {
          // 5.1: 注册事件监听
          this.registerDelegate();
          result.success(okSimple());
        } else {
          result.success(errSimple(res.code, res.message ?? "setup failed"));
        }
      }).catch((e: Error) => {
        result.success(errSimple(-1, String(e)));
      });
    } catch (e) {
      result.success(errSimple(-1, String(e)));
    }
  }

  // 4.4: getVersion
  getVersion(): string {
    try {
      return NECallEngine.getInstance().getVersion() ?? "unknown";
    } catch (e) {
      return "unknown";
    }
  }

  // 4.5: call —— 发起通话
  call(param: CallParam, result: Result<CallResponse>): void {
    try {
      const callType = param.getCallType() === CallType.VIDEO ? NECallType.VIDEO : NECallType.AUDIO;
      const callParam = new NECallParam(param.getAccId(), callType);
      callParam.extraInfo = param.getExtraInfo();
      callParam.rtcChannelName = param.getRtcChannelName();

      NECallEngine.getInstance().call(callParam).then((res) => {
        if (res.code === 0) {
          // 主叫方发起呼叫成功后启动后台任务，保证退后台时铃声持续播放
          this.enableBackgroundRunning(true);
          // 获取通话信息
          NECallEngine.getInstance().getCallInfo().then((info) => {
            if (info) {
              result.success(new CallResponse(0, "Success", toCallInfo(info)));
            } else {
              result.success(new CallResponse(0, "Success", emptyCallInfo()));
            }
          }).catch(() => {
            result.success(new CallResponse(0, "Success", emptyCallInfo()));
          });
        } else {
          result.success(new CallResponse(res.code, res.message ?? "call failed", emptyCallInfo()));
        }
      }).catch((e: Error) => {
        result.success(new CallResponse(-1, String(e), emptyCallInfo()));
      });
    } catch (e) {
      result.success(new CallResponse(-1, String(e), emptyCallInfo()));
    }
  }

  // 4.6: accept —— 接听通话
  accept(result: Result<CallResponse>): void {
    try {
      NECallEngine.getInstance().accept().then((res) => {
        if (res.code === 0) {
          NECallEngine.getInstance().getCallInfo().then((info) => {
            if (info) {
              result.success(new CallResponse(0, "Success", toCallInfo(info)));
            } else {
              result.success(new CallResponse(0, "Success", emptyCallInfo()));
            }
          }).catch(() => {
            result.success(new CallResponse(0, "Success", emptyCallInfo()));
          });
        } else {
          result.success(new CallResponse(res.code, res.message ?? "accept failed", emptyCallInfo()));
        }
      }).catch((e: Error) => {
        result.success(new CallResponse(-1, String(e), emptyCallInfo()));
      });
    } catch (e) {
      result.success(new CallResponse(-1, String(e), emptyCallInfo()));
    }
  }

  // 4.7: hangup —— 挂断通话
  hangup(param: HangupParam, result: Result<SimpleResponse>): void {
    try {
      NECallEngine.getInstance().hangup(param.getChannelId(), param.getExtraString()).then((res) => {
        result.success(res.code === 0 ? okSimple() : errSimple(res.code, res.message ?? "hangup failed"));
      }).catch((e: Error) => {
        result.success(errSimple(-1, String(e)));
      });
    } catch (e) {
      result.success(errSimple(-1, String(e)));
    }
  }

  // 4.8: switchCallType —— 切换音视频
  switchCallType(param: SwitchParam, result: Result<SimpleResponse>): void {
    try {
      const callType = param.getCallType() === CallType.VIDEO ? NECallType.VIDEO : NECallType.AUDIO;
      const switchState = toNECallSwitchState(param.getState());
      NECallEngine.getInstance().switchCallType(callType, switchState).then((res) => {
        result.success(res.code === 0 ? okSimple() : errSimple(res.code, res.message ?? "switchCallType failed"));
      }).catch((e: Error) => {
        result.success(errSimple(-1, String(e)));
      });
    } catch (e) {
      result.success(errSimple(-1, String(e)));
    }
  }

  // 4.9: setTimeout —— 设置超时
  setTimeout(time: number, result: Result<SimpleResponse>): void {
    try {
      NECallEngine.getInstance().setTimeout(time);
      result.success(okSimple());
    } catch (e) {
      result.success(errSimple(-1, String(e)));
    }
  }

  // 4.10: setupLocalView —— 绑定本地视频
  setupLocalView(param: ViewParam, result: Result<SimpleResponse>): void {
    try {
      const viewId = param.getViewId();
      console.info(`[${TAG}] setupLocalView: viewId=${viewId}, mapSize=${VideoViewFactory.videoViewMap.size}`);
      
      // 如果 viewId 为 -1，表示解绑本地视频
      if (viewId === -1) {
        console.info(`[${TAG}] setupLocalView: unbind local view`);
        const code = NECallEngine.getInstance().setupLocalView(null);
        result.success(code === 0 ? okSimple() : errSimple(code, "setupLocalView(null) failed"));
        return;
      }
      
      const videoView = VideoViewFactory.videoViewMap.get(viewId);
      if (!videoView) {
        console.error(`[${TAG}] setupLocalView: VideoView not found for viewId=${viewId}`);
        result.success(errSimple(-1, "VideoView not found"));
        return;
      }
      
      const canvas = videoView.getCanvas();
      console.info(`[${TAG}] setupLocalView: bindinging to canvasId=${canvas.canvasId}`);
      const code = NECallEngine.getInstance().setupLocalView(canvas);
      console.info(`[${TAG}] setupLocalView: result code=${code}`);
      result.success(code === 0 ? okSimple() : errSimple(code, "setupLocalView failed"));
    } catch (e) {
      console.error(`[${TAG}] setupLocalView error: ${String(e)}`);
      result.success(errSimple(-1, String(e)));
    }
  }

  // 4.11: setupRemoteView —— 绑定远端视频
  setupRemoteView(param: ViewParam, result: Result<SimpleResponse>): void {
    try {
      const videoView = VideoViewFactory.videoViewMap.get(param.getViewId());
      if (!videoView) {
        result.success(errSimple(-1, "VideoView not found"));
        return;
      }
      const code = NECallEngine.getInstance().setupRemoteView(videoView.getCanvas());
      result.success(code === 0 ? okSimple() : errSimple(code, "setupRemoteView failed"));
    } catch (e) {
      result.success(errSimple(-1, String(e)));
    }
  }

  // 4.12: enableLocalVideo
  enableLocalVideo(enable: boolean, result: Result<SimpleResponse>): void {
    try {
      const code = NECallEngine.getInstance().enableLocalVideo(enable);
      result.success(code === 0 ? okSimple() : errSimple(code, "enableLocalVideo failed"));
    } catch (e) {
      result.success(errSimple(-1, String(e)));
    }
  }

  // 4.13: muteLocalVideo
  muteLocalVideo(muted: boolean, result: Result<SimpleResponse>): void {
    try {
      const code = NECallEngine.getInstance().muteLocalVideo(muted);
      result.success(code === 0 ? okSimple() : errSimple(code, "muteLocalVideo failed"));
    } catch (e) {
      result.success(errSimple(-1, String(e)));
    }
  }

  // 4.14: muteLocalAudio
  muteLocalAudio(muted: boolean, result: Result<SimpleResponse>): void {
    try {
      const code = NECallEngine.getInstance().muteLocalAudio(muted);
      result.success(code === 0 ? okSimple() : errSimple(code, "muteLocalAudio failed"));
    } catch (e) {
      result.success(errSimple(-1, String(e)));
    }
  }

  // 4.15: switchCamera
  switchCamera(result: Result<SimpleResponse>): void {
    try {
      const code = NECallEngine.getInstance().switchCamera();
      result.success(code === 0 ? okSimple() : errSimple(code, "switchCamera failed"));
    } catch (e) {
      result.success(errSimple(-1, String(e)));
    }
  }

  // 4.16: isSpeakerphoneOn
  isSpeakerphoneOn(result: Result<boolean>): void {
    try {
      NECallEngine.getInstance().isSpeakerphoneOn().then((on) => {
        result.success(on);
      }).catch(() => {
        result.success(false);
      });
    } catch (e) {
      result.success(false);
    }
  }

  // 4.17: setSpeakerphoneOn
  setSpeakerphoneOn(enable: boolean, result: Result<SimpleResponse>): void {
    try {
      const code = NECallEngine.getInstance().setSpeakerphoneOn(enable);
      result.success(code === 0 ? okSimple() : errSimple(code, "setSpeakerphoneOn failed"));
    } catch (e) {
      result.success(errSimple(-1, String(e)));
    }
  }

  // 4.18: setCallConfig
  setCallConfig(config: CallConfig, result: Result<SimpleResponse>): void {
    try {
      NECallEngine.getInstance().setCallConfig(
        config.getEnableOffline(),
        config.getEnableSwitchVideoConfirm(),
        config.getEnableSwitchAudioConfirm()
      ).then((res) => {
        result.success(res.code === 0 ? okSimple() : errSimple(res.code, res.message ?? "setCallConfig failed"));
      }).catch((e: Error) => {
        result.success(errSimple(-1, String(e)));
      });
    } catch (e) {
      result.success(errSimple(-1, String(e)));
    }
  }

  // 4.19: getCallInfo
  getCallInfo(result: Result<CallInfo>): void {
    try {
      NECallEngine.getInstance().getCallInfo().then((info) => {
        if (info) {
          result.success(toCallInfo(info));
        } else {
          result.success(emptyCallInfo());
        }
      }).catch(() => {
        result.success(emptyCallInfo());
      });
    } catch (e) {
      result.success(emptyCallInfo());
    }
  }

  // 4.20: getCallConfig
  getCallConfig(result: Result<CallConfig>): void {
    try {
      NECallEngine.getInstance().getCallConfig().then((cfg: NECallConfig | null) => {
        result.success(new CallConfig(
          cfg?.enableOffline ?? false,
          cfg?.enableSwitchVideoConfirm ?? false,
          cfg?.enableSwitchAudioConfirm ?? false
        ));
      }).catch(() => {
        result.success(new CallConfig(false, false, false));
      });
    } catch (e) {
      result.success(new CallConfig(false, false, false));
    }
  }

  // 4.21: destroy —— 销毁引擎，注销回调
  // 仿照 Android 的方式，在销毁引擎之前先调用 hangup 停止正在进行的通话
  destroy(result: Result<SimpleResponse>): void {
    try {
      this.unregisterDelegate();
      // 确保停止后台任务
      this.enableBackgroundRunning(false);
      // 先尝试挂断当前通话（如果有），再销毁引擎
      NECallEngine.getInstance().hangup("", "").then(() => {
        // hangup 完成后销毁引擎
        NECallEngine.getInstance().destroy().then((res) => {
          result.success(res.code === 0 ? okSimple() : errSimple(res.code, res.message ?? "destroy failed"));
        }).catch((e: Error) => {
          result.success(errSimple(-1, String(e)));
        });
      }).catch(() => {
        // hangup 失败也继续销毁引擎（可能本来就没有通话）
        NECallEngine.getInstance().destroy().then((res) => {
          result.success(res.code === 0 ? okSimple() : errSimple(res.code, res.message ?? "destroy failed"));
        }).catch((e: Error) => {
          result.success(errSimple(-1, String(e)));
        });
      });
    } catch (e) {
      result.success(errSimple(-1, String(e)));
    }
  }

  // 4.22: 不支持的接口 —— 统一返回 not supported
  startASRCaption(config: NERtcASRCaptionConfig, result: Result<SimpleResponse>): void {
    result.success(errSimple(-1, "not supported on ohos"));
  }

  stopASRCaption(result: Result<SimpleResponse>): void {
    result.success(errSimple(-1, "not supported on ohos"));
  }

  getUserWithRtcUid(uid: number, result: Result<UserInfo>): void {
    result.success(new UserInfo("", uid));
  }

  setCallRecordProvider(enable: boolean, result: Result<SimpleResponse>): void {
    result.success(errSimple(-1, "not supported on ohos"));
  }

  // ──────────────────────────────────────────────
  // 5.1–5.9: NECallEngine 事件回调注册与转发
  // ──────────────────────────────────────────────

  private registerDelegate(): void {
    const sink = this.eventSink;
    const self = this; // 保存 this 引用用于在回调中访问
    // 5.1: 构造 delegate 实现
    this.delegate = new NECallEngineDelegate({
      // 5.2: 收到来电邀请
      onReceiveInvited: async (info: NEInviteInfo) => {
        console.info(`[${TAG}] onReceiveInvited: inviter=${info.inviter}, callId=${info.callId}`);
        
        // 【多端拒绝保护】检查是否在冷却期内：防止多端拒绝后立即收到的连续来电被误判
        const now = Date.now();
        const timeSinceLastCallEnd = now - self.lastCallEndTime;
        if (self.lastCallEndTime > 0 && timeSinceLastCallEnd < CallKitPlatform.CALL_END_COOLDOWN_MS) {
          console.warn(`[${TAG}] onReceiveInvited: in call end cooldown period, timeSinceLastCallEnd=${timeSinceLastCallEnd}ms, rejecting incoming call`);
          // 自动拒绝来电（冷却期内）
          try {
            await NECallEngine.getInstance().hangup(info.callId ?? "", "");
          } catch (e) {
            console.error(`[${TAG}] onReceiveInvited: failed to reject call in cooldown: ${String(e)}`);
          }
          return; // 不转发到 Flutter 层，避免响铃和显示UI
        }
        
        // 【多端登录占线检测】检查当前通话状态
        try {
          const currentCallInfo = await NECallEngine.getInstance().getCallInfo();
          if (currentCallInfo && currentCallInfo.callStatus !== 0) { // 0=IDLE
            console.warn(`[${TAG}] onReceiveInvited: user is busy, current callStatus=${currentCallInfo.callStatus}, rejecting incoming call`);
            // 自动拒绝来电（占线）
            await NECallEngine.getInstance().hangup(info.callId ?? "", "");
            return; // 不转发到 Flutter 层，避免响铃和显示UI
          }
        } catch (e) {
          console.error(`[${TAG}] onReceiveInvited: failed to check call status: ${String(e)}`);
          // 如果检查失败，仍然转发邀请（保守策略）
        }
        
        // 收到来电时启动后台任务，保证退后台时铃声持续播放
        self.enableBackgroundRunning(true);
        const inviteInfo = new InviteInfo(
          info.inviter ?? "",
          toCallType(info.callType),
          "", // extraInfo 在新版 SDK 中不在 NEInviteInfo 中
          info.callId ?? ""
        );
        sink.onReceiveInvited(inviteInfo, { reply: () => {} });
      },

      // 5.3: 通话接通
      onCallConnected: (info: NECallInfo) => {
        // 确保后台任务已启动（如果是主叫方，在 call 成功时已启动）
        self.enableBackgroundRunning(true);
        sink.onCallConnected(toCallInfo(info), { reply: () => {} });
      },

      // 5.4: 通话结束
      onCallEnd: (info: NECallEndInfo) => {
        // 只有在多端拒绝/接听时才记录时间戳，启动冷却期保护
        const reason = info.reason as CallTerminalCode;
        if (reason === CallTerminalCode.OTHER_REJECTED || reason === CallTerminalCode.OTHER_ACCEPTED) {
          self.lastCallEndTime = Date.now();
          console.info(`[${TAG}] onCallEnd: multi-client operation detected (reason=${reason}), set lastCallEndTime=${self.lastCallEndTime}`);
        }
        // 停止后台任务
        self.enableBackgroundRunning(false);
        const endInfo = new CallEndInfo(
          info.reason as CallTerminalCode ?? CallTerminalCode.NORMAL,
          "", // extraInfo
          "" // message
        );
        sink.onCallEnd(endInfo, { reply: () => {} });
      },

      // 5.5: 通话类型切换
      onCallTypeChange: (info: NECallTypeChangeInfo) => {
        const changeInfo = new CallTypeChangeInfo(
          toCallType(info.callType),
          info.state as CallSwitchState ?? CallSwitchState.INVITE
        );
        sink.onCallTypeChange(changeInfo, { reply: () => {} });
      },

      // 5.6: 远端用户视频可用
      // SDK 回调的 available 可能是 number (0/1) 或 boolean，需要统一转换
      onVideoAvailable: (available: boolean | number, userId: string) => {
        const availableBool = typeof available === 'number' ? available !== 0 : available;
        console.info(`[${TAG}] onVideoAvailable: available=${available}(raw) -> ${availableBool}(bool), userId=${userId}`);
        sink.onVideoAvailable(availableBool, userId, { reply: () => {} });
      },

      // 5.7: 远端用户视频静音
      // SDK 回调的 muted 可能是 number (0/1) 或 boolean，需要统一转换
      onVideoMuted: (muted: boolean | number, userId: string) => {
        const mutedBool = typeof muted === 'number' ? muted !== 0 : muted;
        console.info(`[${TAG}] onVideoMuted: muted=${muted}(raw) -> ${mutedBool}(bool), userId=${userId}`);
        sink.onVideoMuted(mutedBool, userId, { reply: () => {} });
      },

      // 5.8: 远端用户音频静音
      // SDK 回调的 muted 可能是 number (0/1) 或 boolean，需要统一转换
      onAudioMuted: (muted: boolean | number, userId: string) => {
        const mutedBool = typeof muted === 'number' ? muted !== 0 : muted;
        console.info(`[${TAG}] onAudioMuted: muted=${muted}(raw) -> ${mutedBool}(bool), userId=${userId}`);
        sink.onAudioMuted(mutedBool, userId, { reply: () => {} });
      },
    });

    NECallEngine.getInstance().addCallDelegate(this.delegate);
  }

  private unregisterDelegate(): void {
    if (this.delegate) {
      NECallEngine.getInstance().removeCallDelegate(this.delegate);
      this.delegate = null;
    }
  }

  // ──────────────────────────────────────────────
  // 后台任务管理 - 保证 App 退后台时麦克风持续采集
  // ──────────────────────────────────────────────

  /**
   * 启用/禁用后台运行
   * @param enable 是否启用后台运行
   */
  private enableBackgroundRunning(enable: boolean): void {
    if (enable) {
      this.startBackgroundRunning();
    } else {
      this.stopBackgroundRunning();
    }
  }

  /**
   * 启动后台任务，保证麦克风持续采集
   */
  private startBackgroundRunning(): void {
    if (this.isBackgroundRunning) {
      console.info(`[${TAG}] Background task already running`);
      return;
    }
    
    // 获取 bundleName 和 abilityName
    const bundleName = this.context.applicationInfo?.name ?? "";
    const abilityName = "EntryAbility";
    
    const wantAgentInfo: wantAgent.WantAgentInfo = {
      // 点击通知后，将要执行的动作列表
      wants: [
        {
          bundleName: bundleName,
          abilityName: abilityName
        }
      ],
      // 指定点击通知栏消息后的动作是拉起 ability
      actionType: wantAgent.OperationType.START_ABILITY,
      // 使用者自定义的一个私有值
      requestCode: 0,
      // 点击通知后，动作执行属性
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };
    
    // 通过 wantAgent 模块获取 WantAgent 对象
    wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: WantAgent) => {
      // 后台模式：音频录制和音频播放
      const backgroundModes: string[] = ["audioRecording", "audioPlayback"];
      backgroundTaskManager.startBackgroundRunning(this.context, backgroundModes, wantAgentObj)
        .then((taskNotification: backgroundTaskManager.ContinuousTaskNotification) => {
          console.info(`[${TAG}] startBackgroundRunning succeed`);
          this.isBackgroundRunning = true;
        })
        .catch((err: BusinessError) => {
          console.error(`[${TAG}] startBackgroundRunning failed, code:${err.code}, message:${err.message}`);
        });
    }).catch((err: BusinessError) => {
      console.error(`[${TAG}] getWantAgent failed, code:${err.code}, message:${err.message}`);
    });
  }

  /**
   * 停止后台任务
   */
  private stopBackgroundRunning(): void {
    if (!this.isBackgroundRunning) {
      console.info(`[${TAG}] Background task not running`);
      return;
    }
    
    backgroundTaskManager.stopBackgroundRunning(this.context)
      .then(() => {
        console.info(`[${TAG}] stopBackgroundRunning succeed`);
        this.isBackgroundRunning = false;
      })
      .catch((err: BusinessError) => {
        console.error(`[${TAG}] stopBackgroundRunning failed, code:${err.code}, message:${err.message}`);
      });
  }
}
