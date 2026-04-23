// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { NECallEndReason, NECallEngine, NECallEngineDelegate, NEErrorCode, NEGroupCall } from '@yunxin/callkit';
import {
  NECallType,
  NECallEndInfo,
  NEInviteInfo,
  NECallInfo,
  NECallTypeChangeInfo,
  NERecordConfig,
  NECallParticipant,
  NEInviteStatus,
  NEUserLeftReason,
  NECallScene as NECallSceneEngine
} from '@yunxin/callkit';
import {
  NEGroupCallInfo,
  NEGroupCallDelegate,
  GroupCallMember,
  GroupCallHangupEvent,
  GroupCallEndEvent,
  NEGroupHangupReason
} from '@yunxin/callkit/src/main/ets/api/NEGroupCallInfo';
import { NEEventNotify } from '../event/EventNotify';
import {
  setStateEvent,
  setStateEventOnCallReceived,
  setStateEventOnCallEnd,
  setStateEventRefreshTiming,
  setStateEventOnCallBegin,
  speakingStateChangedEvent
} from '../data/Constants';
import {
  NECallRole,
  NECallStatus,
  NECallScene,
  NECamera,
  NENetworkQuality,
} from '../CallDefine';
import { User } from '../data/User';
import { CallingBellFeature } from './CallingBellFeature';
import { CallManager } from './CallManager';
import { NimUtils } from '../utils/NimUtils';
import { CallUILog } from '../utils/CallUILog';
import { ToastUtils } from '../utils/ToastUtils';

/**
 * 通话状态管理类
 * 单例模式，负责管理通话相关的状态
 */
export class CallState {
  private static readonly _tag = 'CallState';
  private static readonly SPEAKER_ROUTE_RETRY_DELAY_MS = 150;
  private static _instance: CallState = new CallState();
  private _incomingTaskToken: number = 0;

  /**
   * 工厂方法，返回单例实例
   */
  static get instance(): CallState {
    return CallState._instance;
  }

  // 用户信息
  selfUser: User = new User();
  /** 上一次通话的角色（cleanState 前保存，用于 onCallEnd 判断 toast 显示） */
  _lastCallRole: NECallRole = NECallRole.NONE;
  caller: User = new User();
  calleeList: Array<User> = [];
  calleeIdList: Array<string> = [];
  remoteUserList: Array<User> = [];
  // 通话信息
  scene: NECallScene = NECallScene.SINGLE_CALL;
  callType: NECallType = NECallType.AUDIO;
  timeCount: number = 0;
  startTime: number = 0;
  groupId: string = '';
  /** 当前通话ID */
  callId: string = '';

  // ========== 群呼相关字段 (2.0.0+) ==========
  /**
   * 群呼会话信息 (仅群呼模式有效)
   * @since 2.0.0
   */
  groupCallInfo?: NEGroupCallInfo;

  /**
   * 参与者列表 (群呼模式使用，包含所有人含自己)
   * @since 2.0.0
   */
  participantList: Array<NECallParticipant> = [];

  /**
   * 群呼参与者数量（用于 UI 显示）
   * @since 2.0.0
   */
  groupCallParticipantCount: number = 0;

  // 媒体控制状态
  isCameraOpen: boolean = true;
  camera: NECamera = NECamera.FRONT;
  isMicrophoneMute: boolean = false;
  isEnableSpeaker: boolean = false;
  enableBlurBackground: boolean = false;
  /** 主动挂断标志，防止引擎回调重复关闭页面 */
  isActiveHangup: boolean = false;
  /** 群呼邀请待接听标志，用于 UI 判断是否显示来电页 */
  isGroupCallInvited: boolean = false;
  networkQualityReminder: number = 0; // NetworkQualityHint
  isLocalViewBig: boolean = true;
  enableIncomingBanner: boolean = false;
  isInNativeIncomingBanner: boolean = false;
  isStartForegroundService: boolean = false;

  // ========== 说话状态检测 (2.0.0+) ==========
  /**
   * 说话状态防抖时间 (毫秒)
   * @since 2.0.0
   */
  private static readonly SPEAKING_DEBOUNCE_MS = 300;

  /**
   * 本地用户是否正在说话
   * @since 2.0.0
   */
  localIsSpeaking: boolean = false;

  /**
   * 远端用户说话状态映射表 (rtcUid -> isSpeaking)
   * @since 2.0.0
   */
  remoteSpeakingMap: Map<number, boolean> = new Map();

  /**
   * 说话状态防抖定时器映射表 (key -> timerId)
   * key 格式: "local" 或 "remote_{rtcUid}"
   * @since 2.0.0
   */
  private speakingDebounceTimers: Map<string, number> = new Map();

  // 定时器
  private _timer: number | null = null;
  /**
   * 引擎观察者
   */
  readonly observer: NECallEngineDelegate = new NECallEngineDelegate({
    onReceiveInvited: async (info: NEInviteInfo) => {
      CallUILog.info(CallState._tag, `onReceiveInvited(callerAccId:${info.inviter}, callType:${info.callType},callScene:${info.callScene}, participantCount:${info.participantCount}, extrainfo:${info.extraInfo}, globalInfo:${info.globalExtra})`);
      const incomingTaskToken = CallState.instance.beginIncomingTask();

      // 处理来电逻辑（先设置角色），传递群呼相关参数
      const handled = await CallState.instance.handleCallReceivedData(
        info.inviter,
        info.inviteList,
        info.groupId ?? '',
        info.callType,
        info.callScene,
        info.participantCount,
        incomingTaskToken
      );
      if (!handled || !CallState.instance.isIncomingTaskValid(incomingTaskToken)) {
        CallUILog.info(CallState._tag, `onReceiveInvited: incoming task invalidated, skip launch. token=${incomingTaskToken}`);
        return;
      }

      // 启动铃声（角色已设置）
      CallingBellFeature.instance.startRing();

      // 通知 CallManager 来电到达，由 CallManager 统一决策：横幅模式或直接跳转通话页
      NEEventNotify.getInstance().notify(setStateEventOnCallReceived, {});
    },
    onCallEnd: async (info: NECallEndInfo) => {
      CallUILog.info(CallState._tag, `onCallEnd(reasonCode:${info.reason}, message:${info.callId}, isActiveHangup=${CallState.instance.isActiveHangup})`);

      // 主动挂断由 CallManager.hangup() 统一处理，此处跳过避免重复清理
      if (CallState.instance.isActiveHangup) {
        CallUILog.info(CallState._tag, `onCallEnd: 主动挂断，跳过回调处理`);
        return;
      }

      // 停止铃声
      CallingBellFeature.instance.stopRing();

      // 如果是视频通话且摄像头已打开，关闭摄像头
      if (
        CallState.instance.callType === NECallType.VIDEO &&
        CallState.instance.isCameraOpen
      ) {
        await CallManager.instance.closeCamera();
      }
      let showToast = true;
      if (info.reason === NECallEndReason.TERMINAL_CODE_TIME_OUT && CallState.instance.selfUser.callRole === NECallRole.CALLED) {
        // 被叫方超时不显示 toast
        showToast = false;
      } else if (info.reason === NECallEndReason.TERMINAL_CALLER_CANCEL
        && (CallState.instance.selfUser.callRole === NECallRole.CALLER
          || CallState.instance._lastCallRole === NECallRole.CALLER)) {
        // 主叫方自己取消不显示 toast（"对方取消" 只应给被叫看）
        // 检查 callRole 和 _lastCallRole 以覆盖 cleanState() 前后两种时序
        showToast = false;
      } else if (info.reason === NECallEndReason.TERMINAL_HANG_UP) {
        // 主动挂断不显示 toast
        showToast = false;
      }
      const eventData: Record<string, Object> = { 'info': info, 'showToast': showToast};
      NEEventNotify.getInstance().notify(setStateEventOnCallEnd, eventData);
      CallState.instance.cleanState();
      CallState.instance.stopTimer();
    },
    onCallConnected: async (info: NECallInfo) => {
      CallUILog.info(CallState._tag, `onCallConnected(callId:${info.callId}, callType:${info.callType})`);

      // 保存 callId（用于邀请新成员等操作）
      CallState.instance.callId = info.callId;

      // 同步群呼信息（接听后 API 返回的 members 会更新 memberList，包含 rtcUid）
      CallState.instance.syncGroupCallInfo();

      CallState.instance.callType = info.callType;
      // 记录开始时间（秒级时间戳）
      CallState.instance.startTime = Math.floor(Date.now() / 1000);
      CallState.instance.selfUser.callStatus = NECallStatus.ACCEPT;

      // 根据静音状态设置麦克风
      if (CallState.instance.isMicrophoneMute) {
        await CallManager.instance.closeMicrophone();
      } else {
        await CallManager.instance.openMicrophone();
      }

      await CallingBellFeature.instance.stopRing();

      if (info.callType === NECallType.VIDEO) {
        CallState.instance.isEnableSpeaker = true;
      }

      if (CallState.instance.isEnableSpeaker) {
        CallUILog.info(CallState._tag, 'onCallConnected: retry speaker route for single call');
        const targetSpeakerEnabled = CallState.instance.isEnableSpeaker;
        await CallManager.instance.setSpeakerphoneOn(false, false, false);
        await new Promise<void>((resolve) => {
          setTimeout(() => resolve(), CallState.SPEAKER_ROUTE_RETRY_DELAY_MS);
        });
        await CallManager.instance.setSpeakerphoneOn(targetSpeakerEnabled);
      } else {
        await CallManager.instance.setSpeakerphoneOn(CallState.instance.isEnableSpeaker);
      }

      CallState.instance.startTimer();
      CallState.instance.isLocalViewBig = false;
      CallState.instance.isInNativeIncomingBanner = false;

      NEEventNotify.getInstance().notify(setStateEvent, {});
      NEEventNotify.getInstance().notify(setStateEventOnCallBegin, {});
      // TODO: 更新原生状态
      // NECallKitPlatform.instance.updateCallStateToNative();
    },
    onCallTypeChange: (info: NECallTypeChangeInfo) => {
      CallUILog.info(CallState._tag,
        `[${CallState._tag}] onCallTypeChange(callType:${info.callType}, state:${info.state})`
      );
      CallState.instance.callType = info.callType;
      NEEventNotify.getInstance().notify(setStateEvent, {});
      // TODO: 更新原生状态
      // NECallKitPlatform.instance.updateCallStateToNative();
    },
    onVideoAvailable: (available: boolean, userID: string) => {
      CallUILog.info(CallState._tag, `onVideoAvailable(userId:${userID}, isVideoAvailable:${available})`);
      for (let remoteUser of CallState.instance.remoteUserList) {
        if (remoteUser.id === userID) {
          remoteUser.videoAvailable = available;
          NEEventNotify.getInstance().notify(setStateEvent, {});
          // TODO: 更新原生状态
          // NECallKitPlatform.instance.updateCallStateToNative();
          return;
        }
      }
    },
    onVideoMuted: (muted: boolean, userID: string) => {
      CallUILog.info(CallState._tag, `onVideoMuted(userId:${userID}, muted:${muted})`);
      // 处理视频静音逻辑
      for (let remoteUser of CallState.instance.remoteUserList) {
        if (remoteUser.id === userID) {
          remoteUser.videoAvailable = !muted;
          NEEventNotify.getInstance().notify(setStateEvent, {});
          return;
        }
      }
    },
    onAudioMuted: (muted: boolean, userID: string) => {
      CallUILog.info(CallState._tag, `onAudioMuted(userId:${userID}, muted:${muted})`);
      for (let remoteUser of CallState.instance.remoteUserList) {
        if (remoteUser.id === userID) {
          remoteUser.audioAvailable = !muted;
          NEEventNotify.getInstance().notify(setStateEvent, {});
          return;
        }
      }
      // TODO: 更新原生状态
      // NECallKitPlatform.instance.updateCallStateToNative();
    },
    onLocalAudioMuted: (muted: boolean) => {
      CallUILog.info(CallState._tag, `onLocalAudioMuted(muted:${muted})`);
      CallState.instance.isMicrophoneMute = muted;
      // TODO: 更新原生状态
      // NECallKitPlatform.instance.updateCallStateToNative();
    },
    onRtcInitEnd: () => {
      CallUILog.info(CallState._tag, `onRtcInitEnd()`);
      // TODO: 更新原生状态
      // NECallKitPlatform.instance.updateCallStateToNative();
      // RTC 初始化完成
    },
    // onRecordSend: (config: NERecordConfig) => {
    //   CallUILog.info(CallState._tag, `onRecordSend(accId:${config.accId ?? 'unknown'})`);
    //   // TODO: 更新原生状态
    //   // NECallKitPlatform.instance.updateCallStateToNative();
    //   // 处理话单发送
    // },
    onNERtcEngineVirtualBackgroundSourceEnabled: (
      enabled: boolean,
      reason: number
    ) => {
      CallUILog.info(CallState._tag,
        `onNERtcEngineVirtualBackgroundSourceEnabled(enabled:${enabled}, reason:${reason})`);
      // 处理虚拟背景
      // TODO: 更新原生状态
      // NECallKitPlatform.instance.updateCallStateToNative();
    },
    // 群呼模式：用户加入回调
    onUserJoined: (participant: NECallParticipant) => {
      CallUILog.info(CallState._tag, `onUserJoined(accId:${participant.accId})`);
      // 更新远端用户的 callStatus 为 ACCEPT，以便 UI 隐藏等待指示器
      for (let remoteUser of CallState.instance.remoteUserList) {
        if (remoteUser.id === participant.accId) {
          remoteUser.callStatus = NECallStatus.ACCEPT;
          CallUILog.info(CallState._tag, `onUserJoined: 更新用户 ${participant.accId} 状态为 ACCEPT`);
          break;
        }
      }
      NEEventNotify.getInstance().notify(setStateEvent, {});
    },
    // 群呼模式：用户离开回调
    onUserLeft: (participant: NECallParticipant, reason: NEUserLeftReason) => {
      CallUILog.info(CallState._tag, `onUserLeft(accId:${participant.accId}, reason:${reason})`);
      // 从远端用户列表中移除
      const index = CallState.instance.remoteUserList.findIndex(u => u.id === participant.accId);
      if (index >= 0) {
        CallState.instance.remoteUserList.splice(index, 1);
        CallUILog.info(CallState._tag, `onUserLeft: 移除用户 ${participant.accId}`);
      }
      NEEventNotify.getInstance().notify(setStateEvent, {});
    },
    // 说话状态回调
    onLocalSpeakingStateChanged: (isSpeaking: boolean) => {
      CallState.instance.updateLocalSpeakingState(isSpeaking);
    },
    onRemoteSpeakingStateChanged: (rtcUid: number, isSpeaking: boolean) => {
      CallState.instance.updateRemoteSpeakingState(rtcUid, isSpeaking);
    }
  });

  /**
   * 群呼观察者（NEGroupCallDelegate 实现）
   * 群呼场景由 NEGroupCallImpl 独立处理，UI 层监听 NEGroupCallDelegate
   */
  readonly groupCallObserver: NEGroupCallDelegate = new NEGroupCallDelegate({
    onReceiveGroupInvitation: async (info: NEGroupCallInfo) => {
      CallUILog.info(CallState._tag, `[群呼] onReceiveGroupInvitation: callId=${info.callId}, caller=${info.callerAccId}, memberCount=${info.memberList.length}`);
      const incomingTaskToken = CallState.instance.beginIncomingTask();

      // 处理来电逻辑（先设置角色）
      const handled = await CallState.instance.handleCallReceivedData(
        info.callerAccId,
        info.calleeAccIds,
        '', // groupId
        info.callType,
        NECallSceneEngine.GROUP_CALL,
        info.memberList.length + 1, // 成员数 + 主叫
        incomingTaskToken
      );
      if (!handled || !CallState.instance.isIncomingTaskValid(incomingTaskToken)) {
        CallUILog.info(CallState._tag, `[群呼] onReceiveGroupInvitation: incoming task invalidated, skip launch. token=${incomingTaskToken}`);
        return;
      }

      // 保存群呼信息
      CallState.instance.groupCallInfo = info;
      CallState.instance.callId = info.callId;
      CallState.instance.isGroupCallInvited = true;

      // 启动铃声（角色已设置）
      CallingBellFeature.instance.startRing();

      // 通知 CallManager 来电到达，由 CallManager 统一决策：横幅模式或直接跳转通话页
      NEEventNotify.getInstance().notify(setStateEventOnCallReceived, {});
    },

    onGroupMemberListChanged: (callId: string, userList: GroupCallMember[]) => {
      CallUILog.info(CallState._tag, `[群呼] onGroupMemberListChanged: callId=${callId}, count=${userList.length}`);

      // 检查自己的状态是否变为 JOINED (state=2)
      for (const member of userList) {
        if (member.accId === CallState.instance.selfUser.id && member.state === 2) {
          // 群呼主叫方：自己加入 RTC 不代表通话接通，跳过 handleGroupCallConnected
          // 计时器在首个被叫接听时由 onGroupMemberListChanged 远端成员处理逻辑启动
          const isGroupCaller = CallState.instance.isGroupCall() &&
            CallState.instance.selfUser.callRole === NECallRole.CALLER;
          if (!isGroupCaller && CallState.instance.selfUser.callStatus !== NECallStatus.ACCEPT) {
            CallUILog.info(CallState._tag, `[群呼] onGroupMemberListChanged: 自己已加入通话，触发 handleGroupCallConnected`);
            CallState.instance.handleGroupCallConnected(callId);
          }
        }
      }

      // 更新远端用户状态
      for (const member of userList) {
        // 跳过自己
        if (member.accId === CallState.instance.selfUser.id) {
          continue;
        }
        let remoteUser = CallState.instance.remoteUserList.find(u => u.id === member.accId);

        // 新成员（不在已有列表中）：创建并添加到远端用户列表
        if (!remoteUser && member.state !== 3) { // LEAVING 状态的未知成员无需添加
          CallUILog.info(CallState._tag, `[群呼] onGroupMemberListChanged: 新成员加入 ${member.accId}, state=${member.state}`);
          remoteUser = new User();
          remoteUser.id = member.accId;
          remoteUser.callStatus = member.state === 2 ? NECallStatus.ACCEPT : NECallStatus.WAITING;
          CallState.instance.remoteUserList.push(remoteUser);
          // 异步获取新成员的昵称和头像
          NimUtils.getUserInfo(member.accId).then((userInfo: User) => {
            const target = CallState.instance.remoteUserList.find(u => u.id === member.accId);
            if (target) {
              target.nickname = userInfo.nickname;
              target.avatar = userInfo.avatar;
              NEEventNotify.getInstance().notify(setStateEvent, {});
            }
          });
        }

        if (remoteUser) {
          // 根据 state 同步 callStatus（显式处理所有状态，避免漏同步）
          if (member.state === 2) { // JOINED
            remoteUser.callStatus = NECallStatus.ACCEPT;
            // 仅主叫方：有人接听了，停止呼叫提示音
            // 被叫方不应因远端已加入而停止来电铃声（铃声由被叫自己接听/拒绝时停止）
            if (CallState.instance.selfUser.callRole === NECallRole.CALLER) {
              CallingBellFeature.instance.stopRing();
              // 首个被叫接听时启动计时器（主叫方 callStatus 尚未变为 ACCEPT 说明是第一个接听）
              if (CallState.instance.selfUser.callStatus !== NECallStatus.ACCEPT) {
                CallState.instance.startTime = Math.floor(Date.now() / 1000);
                CallState.instance.selfUser.callStatus = NECallStatus.ACCEPT;
                CallState.instance.startTimer();
                NEEventNotify.getInstance().notify(setStateEventOnCallBegin, {});
              }
            }
          } else if (member.state === 3) { // LEAVING
            // 从列表中移除
            const index = CallState.instance.remoteUserList.findIndex(u => u.id === member.accId);
            if (index >= 0) {
              CallState.instance.remoteUserList.splice(index, 1);
            }
          } else if (member.state === 1 || member.state === 4) { // WAITING / JOIN_WAIT_RTC
            // 确保待接听/等待加入 RTC 的成员保持 WAITING 状态
            // 防止其他回调（如 RTC onUserJoined）误更新后无法纠正
            remoteUser.callStatus = NECallStatus.WAITING;
          }
        }
      }
      NEEventNotify.getInstance().notify(setStateEvent, {});
    },

    onGroupCallHangup: (hangupEvent: GroupCallHangupEvent) => {
      CallUILog.info(CallState._tag, `[群呼] onGroupCallHangup: callId=${hangupEvent.callId}, accId=${hangupEvent.accId}, reason=${hangupEvent.reason}`);

      // 多端登录场景：hangup 的是本端自己，说明另一台设备已处理了邀请
      if (hangupEvent.accId === CallState.instance.selfUser.id) {
        const isOtherAccepted = hangupEvent.reason === NEGroupHangupReason.PEER_ACCEPT;
        const isOtherRejected = hangupEvent.reason === NEGroupHangupReason.PEER_REJECT;
        if (isOtherAccepted || isOtherRejected) {
          CallUILog.info(CallState._tag, `[群呼] onGroupCallHangup: 多端登录，其他端${isOtherAccepted ? '接听' : '拒绝'}，关闭本端 UI`);
          CallingBellFeature.instance.stopRing();
          const endReason = isOtherAccepted ? NECallEndReason.TERMINAL_OTHER_ACCEPTED : NECallEndReason.TERMINAL_OTHER_REJECTED;
          const info: NECallEndInfo = { callId: hangupEvent.callId, reason: endReason, duration: 0 };
          const eventData: Record<string, Object> = { 'info': info, 'showToast': false };
          NEEventNotify.getInstance().notify(setStateEventOnCallEnd, eventData);
          CallState.instance.cleanState();
          CallState.instance.stopTimer();
          return;
        }
      }

      // 处理单个用户挂断
      const index = CallState.instance.remoteUserList.findIndex(u => u.id === hangupEvent.accId);
      if (index >= 0) {
        CallState.instance.remoteUserList.splice(index, 1);
      }
      NEEventNotify.getInstance().notify(setStateEvent, {});
    },

    onGroupCallEnd: (endEvent: GroupCallEndEvent) => {
      CallUILog.info(CallState._tag, `[群呼] onGroupCallEnd: callId=${endEvent.callId}, reason=${endEvent.reasonCode}, isActiveHangup=${CallState.instance.isActiveHangup}`);

      // 主动挂断由 CallManager.hangup() 统一处理，此处跳过避免重复清理
      if (CallState.instance.isActiveHangup) {
        CallUILog.info(CallState._tag, `[群呼] onGroupCallEnd: 主动挂断，跳过回调处理`);
        return;
      }

      // 停止铃声
      CallingBellFeature.instance.stopRing();

      // 构造 NECallEndInfo 以复用现有逻辑
      const info: NECallEndInfo = {
        callId: endEvent.callId,
        reason: endEvent.reasonCode === 2 ? NECallEndReason.TERMINAL_CODE_TIME_OUT : NECallEndReason.TERMINAL_BE_HANG_UP,
        duration: 0
      };

      let showToast = endEvent.reasonCode !== 2 || CallState.instance.selfUser.callRole !== NECallRole.CALLED;
      const eventData: Record<string, Object> = { 'info': info, 'showToast': showToast };
      NEEventNotify.getInstance().notify(setStateEventOnCallEnd, eventData);
      CallState.instance.cleanState();
      CallState.instance.stopTimer();
    }
  });

  /**
   * 私有构造函数，单例模式
   */
  private constructor() {
    this.init();
  }

  /**
   * 初始化
   */
  init(): void {
    // 初始化逻辑
  }

  /**
   * 注册引擎观察者
   */
  async registerEngineObserver(): Promise<void> {
    CallUILog.info(CallState._tag, `registerEngineObserver`);
    // 注册 1v1 呼叫回调
    NECallEngine.getInstance().addCallDelegate(this.observer);
    // 注册群呼回调（群呼由 NEGroupCallImpl 独立处理）
    NEGroupCall.getInstance().addGroupCallDelegate(this.groupCallObserver);
  }

  /**
   * 取消注册引擎观察者
   */
  unRegisterEngineObserver(): void {
    CallUILog.info(CallState._tag, `unRegisterEngineObserver`);
    NECallEngine.getInstance().removeCallDelegate(this.observer);
    NEGroupCall.getInstance().removeGroupCallDelegate(this.groupCallObserver);
  }

  /**
   * 处理呼叫接收数据
   * @param callerId 主叫ID
   * @param calleeIdList 被叫ID列表
   * @param groupId 群组ID
   * @param callMediaType 通话类型
   * @param callScene 通话场景 (可选，2.0.0+)
   * @param participantCount 参与者数量 (可选，2.0.0+)
   */
  async handleCallReceivedData(
    callerId: string,
    calleeIdList: Array<string>,
    groupId: string,
    callMediaType: NECallType,
    callScene?: NECallSceneEngine,
    participantCount?: number,
    incomingTaskToken?: number
  ): Promise<boolean> {
    CallUILog.info(CallState._tag, `handleCallReceivedData callerId = ${callerId} callMediaType = ${callMediaType} callScene = ${callScene} participantCount = ${participantCount}`);
    if (!CallState.instance.isIncomingTaskValid(incomingTaskToken)) {
      CallUILog.info(CallState._tag, `handleCallReceivedData: task already invalid before setup. token=${incomingTaskToken}`);
      return false;
    }

    CallState.instance.caller.id = callerId;
    CallState.instance.calleeIdList = [];
    CallState.instance.calleeIdList.push(...calleeIdList);
    CallState.instance.callType = callMediaType;
    CallState.instance.selfUser.callStatus = NECallStatus.WAITING;

    // 根据 callScene 设置通话场景
    if (callScene === NECallSceneEngine.GROUP_CALL) {
      CallState.instance.scene = NECallScene.GROUP_CALL;
      // 存储参与者数量用于 UI 显示
      CallState.instance.groupCallParticipantCount = participantCount ?? (calleeIdList.length + 1);
      CallUILog.info(CallState._tag, `群呼模式: participantCount = ${CallState.instance.groupCallParticipantCount}`);
      // 同步群呼信息到 UI 层
      CallState.instance.syncGroupCallInfo();
    } else {
      CallState.instance.scene = NECallScene.SINGLE_CALL;
      CallState.instance.groupCallParticipantCount = 0;
    }

    CallState.instance.callType = callMediaType;
    CallState.instance.selfUser.callRole = NECallRole.CALLED;

    const allUserId = [callerId, ...calleeIdList];

    for (let userId of allUserId) {
      if (CallState.instance.selfUser.id === userId) {
        if (userId === callerId) {
          CallState.instance.caller = CallState.instance.selfUser;
        } else {
          CallState.instance.calleeList.push(CallState.instance.selfUser);
        }
        continue;
      }

      const user = new User();
      user.id = userId;

      if (userId === callerId) {
        CallState.instance.caller = user;
      } else {
        // 其他被叫方设置为待接听状态
        user.callRole = NECallRole.CALLED;
        user.callStatus = NECallStatus.WAITING;
        CallState.instance.calleeList.push(user);
      }
    }

    const callerInfo = await NimUtils.getUserInfo(callerId);
    if (!CallState.instance.isIncomingTaskValid(incomingTaskToken)) {
      CallUILog.info(CallState._tag, `handleCallReceivedData: caller info expired. token=${incomingTaskToken}`);
      return false;
    }
    CallState.instance.caller.id = callerInfo.id;
    CallState.instance.caller.nickname = callerInfo.nickname;
    CallState.instance.caller.avatar = callerInfo.avatar;
    CallState.instance.caller.callRole = NECallRole.CALLER;

    CallState.instance.remoteUserList = [];
    if (
      CallState.instance.caller.id.length > 0 &&
        CallState.instance.selfUser.id !== CallState.instance.caller.id
    ) {
      CallState.instance.remoteUserList.push(CallState.instance.caller);
    }
    for (let callee of CallState.instance.calleeList) {
      if (CallState.instance.selfUser.id === callee.id) {
        continue;
      }
      CallState.instance.remoteUserList.push(callee);
    }

    // 群呼模式：批量获取所有被叫方的用户信息（头像、昵称）
    if (callScene === NECallSceneEngine.GROUP_CALL && CallState.instance.calleeList.length > 0) {
      CallUILog.info(CallState._tag, `群呼模式: 开始获取 ${CallState.instance.calleeList.length} 个被叫方的用户信息`);
      const calleeIds = CallState.instance.calleeList
        .filter(u => u.id !== CallState.instance.selfUser.id)
        .map(u => u.id);

      if (calleeIds.length > 0) {
        try {
          const userInfoList = await NimUtils.getUserInfos(calleeIds);
          if (!CallState.instance.isIncomingTaskValid(incomingTaskToken)) {
            CallUILog.info(CallState._tag, `handleCallReceivedData: callee info expired. token=${incomingTaskToken}`);
            return false;
          }
          // 更新 calleeList 和 remoteUserList 中的用户信息
          for (const userInfo of userInfoList) {
            // 更新 calleeList
            const callee = CallState.instance.calleeList.find(u => u.id === userInfo.id);
            if (callee) {
              callee.nickname = userInfo.nickname;
              callee.avatar = userInfo.avatar;
            }
            // 更新 remoteUserList
            const remoteUser = CallState.instance.remoteUserList.find(u => u.id === userInfo.id);
            if (remoteUser) {
              remoteUser.nickname = userInfo.nickname;
              remoteUser.avatar = userInfo.avatar;
            }
          }
          CallUILog.info(CallState._tag, `群呼模式: 成功获取 ${userInfoList.length} 个用户信息`);
        } catch (error) {
          CallUILog.warn(CallState._tag, `群呼模式: 获取被叫方用户信息失败: ${String(error)}`);
        }
      }
    }

    return CallState.instance.isIncomingTaskValid(incomingTaskToken);
  }

  /**
   * 启动定时器
   */
  startTimer(): void {
    CallState.instance.timeCount = 0;
    // 使用 setInterval 实现定时器
    CallState.instance._timer = setInterval(() => {
      if (NECallStatus.ACCEPT !== CallState.instance.selfUser.callStatus) {
        CallState.instance.stopTimer();
        return;
      }
      CallState.instance.timeCount++;
      NEEventNotify.getInstance().notify(setStateEventRefreshTiming, {});
    }, 1000) as number; // 将 setInterval 返回的 timer ID 转换为 number
  }

  /**
   * 停止定时器
   */
  stopTimer(): void {
    if (CallState.instance._timer != null) {
      clearInterval(CallState.instance._timer);
      CallState.instance._timer = null;
    }
  }

  /**
   * 清理状态
   */
  cleanState(): void {
    CallUILog.info(CallState._tag, `cleanState`);
    this.invalidateIncomingTask();
    this.stopTimer();
    // 保存角色信息，供 onCallEnd 判断 toast 显示（callRole 即将被重置）
    CallState.instance._lastCallRole = CallState.instance.selfUser.callRole;
    CallState.instance.selfUser.callRole = NECallRole.NONE;
    CallState.instance.selfUser.callStatus = NECallStatus.NONE;

    CallState.instance.remoteUserList = [];
    CallState.instance.caller = new User();
    CallState.instance.calleeList = [];
    CallState.instance.calleeIdList = [];

    CallState.instance.callType = NECallType.AUDIO;
    CallState.instance.timeCount = 0;
    CallState.instance.groupId = '';
    CallState.instance.callId = '';

    CallState.instance.isMicrophoneMute = false;
    CallState.instance.camera = NECamera.FRONT;
    CallState.instance.isCameraOpen = true;
    CallState.instance.isEnableSpeaker = false;

    CallState.instance.isLocalViewBig = true;
    CallState.instance.enableBlurBackground = false;
    CallState.instance.isActiveHangup = false;
    CallState.instance.isGroupCallInvited = false;

    // 清理群呼相关状态
    CallState.instance.scene = NECallScene.SINGLE_CALL;
    CallState.instance.groupCallInfo = undefined;
    CallState.instance.participantList = [];
    CallState.instance.groupCallParticipantCount = 0;

    // 清理说话状态
    CallState.instance.cleanSpeakingState();
  }

  private beginIncomingTask(): number {
    this._incomingTaskToken++;
    return this._incomingTaskToken;
  }

  private invalidateIncomingTask(): void {
    this._incomingTaskToken++;
  }

  private isIncomingTaskValid(token?: number): boolean {
    return token === undefined || token === this._incomingTaskToken;
  }

  /**
   * 判断是否为群呼模式
   * @returns 是否为群呼
   * @since 2.0.0
   */
  isGroupCall(): boolean {
    return this.scene === NECallScene.GROUP_CALL;
  }

  /**
   * 处理群呼通话接通
   * 当自己状态变为 JOINED 时调用，类似 1v1 的 onCallConnected
   * @param callId 通话 ID
   * @since 2.0.0
   */
  async handleGroupCallConnected(callId: string): Promise<void> {
    CallUILog.info(CallState._tag, `handleGroupCallConnected: callId=${callId}`);

    // 保存 callId
    this.callId = callId;

    // 同步群呼信息
    this.syncGroupCallInfo();

    // 记录开始时间（秒级时间戳）
    this.startTime = Math.floor(Date.now() / 1000);

    // 更新状态
    this.selfUser.callStatus = NECallStatus.ACCEPT;

    // 根据静音状态设置麦克风
    if (this.isMicrophoneMute) {
      await CallManager.instance.closeMicrophone();
    } else {
      await CallManager.instance.openMicrophone();
    }

    // 等待铃声完全停止后再恢复通话音频路由，避免被叫接听时 UI 与实际输出设备不一致
    await CallingBellFeature.instance.stopRing();

    // 群呼被叫接听后，部分设备首次设置扬声器会被系统路由覆盖。
    // 这里对“目标为扬声器开启”的场景做一次静默的听筒->扬声器重置，
    // 等价于用户手动先关再开，但不让 UI 中间态闪动。
    if (this.isGroupCall()
      && this.selfUser.callRole === NECallRole.CALLED
      && this.isEnableSpeaker) {
      CallUILog.info(CallState._tag, 'handleGroupCallConnected: retry speaker route for group callee');
      const targetSpeakerEnabled = this.isEnableSpeaker;
      await CallManager.instance.setSpeakerphoneOn(false, false, false);
      await new Promise<void>((resolve) => {
        setTimeout(() => resolve(), CallState.SPEAKER_ROUTE_RETRY_DELAY_MS);
      });
      await CallManager.instance.setSpeakerphoneOn(targetSpeakerEnabled);
    } else {
      // 设置扬声器
      await CallManager.instance.setSpeakerphoneOn(this.isEnableSpeaker);
    }

    // 启动计时器
    this.startTimer();
    this.isLocalViewBig = false;
    this.isInNativeIncomingBanner = false;

    CallUILog.info(CallState._tag, `handleGroupCallConnected: 通话已接通，发送事件通知`);
    NEEventNotify.getInstance().notify(setStateEvent, {});
    NEEventNotify.getInstance().notify(setStateEventOnCallBegin, {});
  }

  /**
   * 从引擎层同步群呼信息到 UI 层
   * 在群呼发起成功、收到群呼邀请、通话接通后调用
   * @since 2.0.0
   */
  syncGroupCallInfo(): void {
    if (!this.isGroupCall()) {
      return;
    }
    // 群呼信息由 NEGroupCallImpl 独立管理，从 NEGroupCall 获取
    const info = NEGroupCall.getInstance().currentGroupCallInfo();
    if (info) {
      this.groupCallInfo = info;
      // 同步 callId 用于邀请新成员等操作
      if (info.callId) {
        this.callId = info.callId;
      }
      CallUILog.info(CallState._tag, `syncGroupCallInfo: callId=${info.callId}, memberCount=${info.memberList?.length ?? 0}`);
    } else {
      CallUILog.warn(CallState._tag, `syncGroupCallInfo: groupCallInfo is null from NEGroupCall`);
    }
  }

  /**
   * 获取参与者数量
   * @returns 参与者数量
   * @since 2.0.0
   */
  getParticipantCount(): number {
    if (this.isGroupCall()) {
      return this.participantList.length;
    }
    // 单人模式：自己 + 远端用户
    return 1 + this.remoteUserList.length;
  }

  /**
   * 判断网络质量是否差
   * @param quality 网络质量
   * @returns 是否差
   */
  isBadNetwork(quality: NENetworkQuality): boolean {
    return (
      quality === NENetworkQuality.BAD ||
        quality === NENetworkQuality.VERY_BAD ||
        quality === NENetworkQuality.DOWN
    );
  }

  /**
   * 判断是否有任何远端用户已接听
   * 用于控制摄像头按钮的可用状态（对外呼叫过程中，只有有人接听后才能开启摄像头）
   * @returns 是否有人已接听
   * @since 2.0.0
   */
  hasAnyoneAnswered(): boolean {
    // 如果自己是被叫方且已接听，则可以开启摄像头
    if (this.selfUser.callRole === NECallRole.CALLED && this.selfUser.callStatus === NECallStatus.ACCEPT) {
      return true;
    }
    // 检查是否有任何远端用户已接听
    for (const remoteUser of this.remoteUserList) {
      if (remoteUser.callStatus === NECallStatus.ACCEPT) {
        return true;
      }
    }
    return false;
  }

  // ========== 说话状态检测方法 (2.0.0+) ==========

  /**
   * 更新本地用户说话状态
   * 使用防抖逻辑避免频繁闪烁
   * @param isSpeaking 是否正在说话
   * @since 2.0.0
   */
  updateLocalSpeakingState(isSpeaking: boolean): void {
    const key = 'local';
    this.updateSpeakingStateWithDebounce(key, isSpeaking, () => {
      if (this.localIsSpeaking !== isSpeaking) {
        this.localIsSpeaking = isSpeaking;
        CallUILog.info(CallState._tag, `updateLocalSpeakingState: ${isSpeaking}`);
        this.notifySpeakingStateChanged();
      }
    });
  }

  /**
   * 更新远端用户说话状态
   * 使用防抖逻辑避免频繁闪烁
   * @param rtcUid 远端用户的 RTC UID
   * @param isSpeaking 是否正在说话
   * @since 2.0.0
   */
  updateRemoteSpeakingState(rtcUid: number, isSpeaking: boolean): void {
    const key = `remote_${rtcUid}`;
    this.updateSpeakingStateWithDebounce(key, isSpeaking, () => {
      const current = this.remoteSpeakingMap.get(rtcUid) ?? false;
      if (current !== isSpeaking) {
        this.remoteSpeakingMap.set(rtcUid, isSpeaking);
        CallUILog.info(CallState._tag, `updateRemoteSpeakingState: rtcUid=${rtcUid}, isSpeaking=${isSpeaking}`);
        this.notifySpeakingStateChanged();
      }
    });
  }

  /**
   * 带防抖的说话状态更新
   * @param key 状态键
   * @param isSpeaking 是否正在说话
   * @param updateFn 实际更新函数
   * @since 2.0.0
   */
  private updateSpeakingStateWithDebounce(key: string, isSpeaking: boolean, updateFn: () => void): void {
    // 如果变为说话状态，立即更新；如果变为不说话，延迟更新（防抖）
    if (isSpeaking) {
      // 清除之前的防抖定时器
      const existingTimer = this.speakingDebounceTimers.get(key);
      if (existingTimer) {
        clearTimeout(existingTimer);
        this.speakingDebounceTimers.delete(key);
      }
      updateFn();
    } else {
      // 如果没有正在等待的定时器，设置防抖定时器
      if (!this.speakingDebounceTimers.has(key)) {
        const timerId = setTimeout(() => {
          this.speakingDebounceTimers.delete(key);
          updateFn();
        }, CallState.SPEAKING_DEBOUNCE_MS) as number;
        this.speakingDebounceTimers.set(key, timerId);
      }
    }
  }

  /**
   * 查询用户是否正在说话
   * @param accId 用户账号 ID
   * @returns 是否正在说话
   * @since 2.0.0
   */
  isSpeaking(accId: string): boolean {
    // 本地用户
    if (accId === this.selfUser.id) {
      // 诊断日志：仅在说话时打印，避免刷屏
      if (this.localIsSpeaking) {
        CallUILog.info(CallState._tag, `isSpeaking: local user ${accId} is speaking`);
      }
      return this.localIsSpeaking;
    }

    // 远端用户：通过 accId 查找对应的 rtcUid
    const rtcUid = this.getUidByAccId(accId);
    if (rtcUid > 0) {
      const speaking = this.remoteSpeakingMap.get(rtcUid) ?? false;
      // 诊断日志：仅在说话时打印，避免刷屏
      if (speaking) {
        const mapKeys = Array.from(this.remoteSpeakingMap.keys()).join(',');
        CallUILog.info(CallState._tag, `isSpeaking: accId=${accId}, rtcUid=${rtcUid}, speaking=${speaking}, mapKeys=[${mapKeys}]`);
      }
      return speaking;
    }

    // 诊断：首次查询时打印一次警告（rtcUid 未找到）
    CallUILog.info(CallState._tag, `isSpeaking: accId=${accId}, rtcUid not found (mapping issue)`);
    return false;
  }

  /**
   * 通过 accId 获取 rtcUid
   * @param accId 用户账号 ID
   * @returns RTC UID，如果未找到返回 0
   * @since 2.0.0
   */
  private getUidByAccId(accId: string): number {
    // 群呼模式：从 NEGroupCall 获取最新的 groupCallInfo（群呼由 NEGroupCallImpl 独立管理）
    const groupCallInfo = NEGroupCall.getInstance().currentGroupCallInfo();
    if (groupCallInfo?.memberList) {
      for (const member of groupCallInfo.memberList) {
        if (member.accId === accId) {
          // 诊断：找到成员但 rtcUid 为 0 说明映射尚未建立
          if (member.rtcUid === 0) {
            CallUILog.info(CallState._tag, `getUidByAccId: accId=${accId} found but rtcUid=0 (not yet joined RTC)`);
          }
          return member.rtcUid;
        }
      }
      // 诊断：打印所有成员的 accId 和 rtcUid
      const memberInfo = groupCallInfo.memberList.map(m => `${m.accId}:${m.rtcUid}`).join(', ');
      CallUILog.info(CallState._tag, `getUidByAccId: accId=${accId} not in memberList [${memberInfo}]`);
    } else {
      CallUILog.info(CallState._tag, `getUidByAccId: accId=${accId}, groupCallInfo is null or memberList is empty`);
    }

    // TODO: 1v1 模式的 rtcUid 查找逻辑
    return 0;
  }

  /**
   * 通知说话状态变化
   * @since 2.0.0
   */
  private notifySpeakingStateChanged(): void {
    NEEventNotify.getInstance().notify(speakingStateChangedEvent, {});
  }

  /**
   * 清理说话状态
   * @since 2.0.0
   */
  private cleanSpeakingState(): void {
    this.localIsSpeaking = false;
    this.remoteSpeakingMap.clear();
    // 清除所有防抖定时器
    for (const timerId of this.speakingDebounceTimers.values()) {
      clearTimeout(timerId);
    }
    this.speakingDebounceTimers.clear();
  }
}
