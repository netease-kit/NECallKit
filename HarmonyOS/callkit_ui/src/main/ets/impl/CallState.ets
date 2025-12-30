// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { NECallEndReason, NECallEngine, NECallEngineDelegate, NEErrorCode } from '@yunxin/callkit';
import {
  NECallType,
  NECallEndInfo,
  NEInviteInfo,
  NECallInfo,
  NECallTypeChangeInfo,
  NERecordConfig
} from '@yunxin/callkit';
import { NEEventNotify } from '../event/EventNotify';
import {
  setStateEvent,
  setStateEventOnCallReceived,
  setStateEventOnCallEnd,
  setStateEventRefreshTiming,
  setStateEventOnCallBegin
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
  private static _instance: CallState = new CallState();

  /**
   * 工厂方法，返回单例实例
   */
  static get instance(): CallState {
    return CallState._instance;
  }

  // 用户信息
  selfUser: User = new User();
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
  // 媒体控制状态
  isCameraOpen: boolean = true;
  camera: NECamera = NECamera.FRONT;
  isMicrophoneMute: boolean = false;
  isEnableSpeaker: boolean = false;
  enableBlurBackground: boolean = false;
  networkQualityReminder: number = 0; // NetworkQualityHint
  isLocalViewBig: boolean = true;
  enableIncomingBanner: boolean = false;
  isInNativeIncomingBanner: boolean = false;
  isStartForegroundService: boolean = false;
  // 定时器
  private _timer: number | null = null;
  /**
   * 引擎观察者
   */
  readonly observer: NECallEngineDelegate = new NECallEngineDelegate({
    onReceiveInvited: async (info: NEInviteInfo) => {
      CallUILog.info(CallState._tag, `onReceiveInvited(callerAccId:${info.inviter}, callType:${info.callType})`);

      // 处理来电逻辑（先设置角色）
      await CallState.instance.handleCallReceivedData(
        info.inviter,
        info.inviteList,
        info.groupId ?? '',
        info.callType
      );

      // 启动铃声（角色已设置）
      CallingBellFeature.instance.startRing();

      CallManager.instance.launchCallingPage();
    },
    onCallEnd: async (info: NECallEndInfo) => {
      CallUILog.info(CallState._tag, `onCallEnd(reasonCode:${info.reason}, message:${info.callId})`);
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
      if (info.reason === NECallEndReason.TERMINAL_CODE_TIME_OUT && CallState.instance.selfUser.callRole === NECallRole.CALLED ) {
        showToast = false;
      } else {
        showToast = true;
      }
      const eventData: Record<string, Object> = { 'info': info, 'showToast': showToast};
      NEEventNotify.getInstance().notify(setStateEventOnCallEnd, eventData);
      CallState.instance.cleanState();
      CallState.instance.stopTimer();
    },
    onCallConnected: async (info: NECallInfo) => {
      CallUILog.info(CallState._tag, `onCallConnected(callId:${info.callId}, callType:${info.callType})`);

      // 记录开始时间（秒级时间戳）
      CallState.instance.startTime = Math.floor(Date.now() / 1000);
      // 停止铃声
      CallingBellFeature.instance.stopRing();

      CallState.instance.callType = info.callType;
      CallState.instance.selfUser.callStatus = NECallStatus.ACCEPT;

      // 根据静音状态设置麦克风
      if (CallState.instance.isMicrophoneMute) {
        await CallManager.instance.closeMicrophone();
      } else {
        await CallManager.instance.openMicrophone();
      }

      // 设置扬声器
      await CallManager.instance.setSpeakerphoneOn(
        CallState.instance.isEnableSpeaker
      );

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
    NECallEngine.getInstance().addCallDelegate(this.observer);
  }

  /**
   * 取消注册引擎观察者
   */
  unRegisterEngineObserver(): void {
    CallUILog.info(CallState._tag, `unRegisterEngineObserver`);
    NECallEngine.getInstance().removeCallDelegate(this.observer);
  }

  /**
   * 处理呼叫接收数据
   * @param callerId 主叫ID
   * @param calleeIdList 被叫ID列表
   * @param groupId 群组ID
   * @param callMediaType 通话类型
   */
  async handleCallReceivedData(
    callerId: string,
    calleeIdList: Array<string>,
    groupId: string,
    callMediaType: NECallType
  ): Promise<void> {
    CallUILog.info(CallState._tag, `handleCallReceivedData callerId = ${callerId} callMediaType = ${callMediaType}`);

    CallState.instance.caller.id = callerId;
    CallState.instance.calleeIdList = [];
    CallState.instance.calleeIdList.push(...calleeIdList);
    // CallState.instance.groupId = groupId;
    CallState.instance.callType = callMediaType;
    CallState.instance.selfUser.callStatus = NECallStatus.WAITING;

    // TODO: 检查被叫列表是否为空
    // if (calleeIdList.length === 0) {
    //   return;
    // }

    // TODO: 检查是否超过最大用户数
    // if (calleeIdList.length >= Constants.groupCallMaxUserCount) {
    //   CallManager.instance.showToast('Exceeded maximum number');
    //   return;
    // }

    // CallState.instance.groupId = groupId;
    // if (CallState.instance.groupId.length > 0 || calleeIdList.length > 1) {
    //   CallState.instance.scene = NECallScene.GROUP_CALL;
    // } else {
    //   CallState.instance.scene = NECallScene.SINGLE_CALL;
    // }
    CallState.instance.scene = NECallScene.SINGLE_CALL;

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
        CallState.instance.calleeList.push(user);
      }
    }

    const callerInfo = await NimUtils.getUserInfo(callerId);
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
    this.stopTimer();
    CallState.instance.selfUser.callRole = NECallRole.NONE;
    CallState.instance.selfUser.callStatus = NECallStatus.NONE;

    CallState.instance.remoteUserList = [];
    CallState.instance.caller = new User();
    CallState.instance.calleeList = [];
    CallState.instance.calleeIdList = [];

    CallState.instance.callType = NECallType.AUDIO;
    CallState.instance.timeCount = 0;
    CallState.instance.groupId = '';

    CallState.instance.isMicrophoneMute = false;
    CallState.instance.camera = NECamera.FRONT;
    CallState.instance.isCameraOpen = true;
    CallState.instance.isEnableSpeaker = false;

    CallState.instance.isLocalViewBig = true;
    CallState.instance.enableBlurBackground = false;
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
}



