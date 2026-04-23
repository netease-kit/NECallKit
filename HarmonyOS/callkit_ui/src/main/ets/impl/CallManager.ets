// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import {
  NECallEngine,
  NECallEngineDelegate,
  NECallParam,
  NECallPushConfig,
  NECallSwitchState,
  NECallType,
  NECertificateConfig,
  NEExtraConfig,
  NERtcConstants,
  NESetupConfig,
  NEErrorCode,
  NEGroupCall,
  GroupJoinParam,
  GroupCallMember
} from '@yunxin/callkit';

import { media } from '@kit.MediaKit';
import { NEEventNotify } from '../event/EventNotify';
import { Constants, setStateEvent, setStateEventOnCallReceived, setStateEventOnCallEnd } from '../data/Constants';
import { NECallRole, NECallScene, NECallStatus, NECamera } from '../CallDefine';
import { CallState } from './CallState';
import { CallingBellFeature } from './CallingBellFeature';
import router from '@ohos.router';
import audio from '@ohos.multimedia.audio'
import { User } from '../data/User';
import { NimUtils } from '../utils/NimUtils';
import common from '@ohos.app.ability.common';
import { PermissionUtils } from '../utils/PermissionUtils';
import { CallUILog } from '../utils/CallUILog';
import { ToastUtils } from '../utils/ToastUtils';
import { NECallUIConfig } from './NECallUIConfig';
import { IncomingCallBannerWidget, CallerInfo } from '../widget/IncomingCallBannerWidget';

/**
 * 通用结果类型
 */
export class NEResult {
  code: number = 0;
  message: string = '';

  constructor(code: number = 0, message: string = '') {
    this.code = code;
    this.message = message;
  }
}

/**
 * 呼叫管理器
 * 单例模式，负责管理通话相关的操作
 */
interface CallParams {
  pushConfig?: NECallPushConfig;
}

/**
 * 路由信息接口
 */
interface PreviousRouteInfo {
  name: string | null;
  url: string | null;
}

export class CallManager {
  private static readonly _tag = 'CallManager';
  private static _instance: CallManager = new CallManager();

  // 保存 appKey
  private _appKey: string | null = null;

  // 保存额外配置
  private _extraConfig: NEExtraConfig | null = null;

  // 当前账号ID
  private _accountId: string | null = null;

  // Ability Context，用于权限请求等（通过 setupEngine 传入）
  private _context: common.Context | null = null;

  // UI 配置（来电横幅等）
  private _uiConfig: NECallUIConfig | null = null;

  // 来电横幅 SubWindow 管理实例
  private _bannerWidget: IncomingCallBannerWidget | null = null;

  // 引擎代理（用于接收回调）
  private _engineDelegate: NECallEngineDelegate | null = null;

  // 保存跳转前的路由信息，用于通话结束后返回
  private _previousRouteName: string | null = null;
  private _previousRouteUrl: string | null = null;

  /**
   * 私有构造函数，单例模式
   */
  private constructor() {
    // 注册呼叫接收事件
    NEEventNotify.getInstance().register(setStateEventOnCallReceived, (arg) => {
      CallUILog.info(CallManager._tag, `onCallReceived event`);
      // 来电横幅仅支持 1v1 通话，群呼直接跳转通话页面
      if (this._uiConfig?.enableIncomingBanner === true && !CallState.instance.isGroupCall()) {
        // 并发来电检查：若横幅已显示，说明已有一路来电，新来电回复忙线并丢弃
        if (this._bannerWidget?.isShowing()) {
          CallUILog.info(CallManager._tag, `secondCallIgnored replyBusy`);
          NECallEngine.getInstance().hangup('').then(() => {});
          return;
        }
        CallUILog.info(CallManager._tag, `showIncomingBanner enableIncomingBanner=true`);
        // 构建来电方信息（从 CallState 获取已解析的主叫信息）
        const callerUser = CallState.instance.caller;
        const callTypeValue = CallState.instance.callType;
        // NECallType: AUDIO=1, VIDEO=2；横幅 callType 约定 0=audio, 1=video, 2=group
        let bannerCallType = 0;
        if (callTypeValue === NECallType.VIDEO) {
          bannerCallType = 1;
        }
        const callerInfo: CallerInfo = {
          accountId: callerUser.id ?? '',
          displayName: callerUser.nickname && callerUser.nickname.length > 0
            ? callerUser.nickname
            : (callerUser.id ?? ''),
          avatarUrl: callerUser.avatar && callerUser.avatar.length > 0
            ? callerUser.avatar
            : undefined,
          callType: bannerCallType
        };

        // 懒初始化横幅组件
        if (!this._bannerWidget) {
          this._bannerWidget = new IncomingCallBannerWidget(this._context!);
        }

        this._bannerWidget.show(
          callerInfo,
          // 接听回调
          () => {
            CallUILog.info(CallManager._tag, 'bannerAcceptTapped');
            NECallEngine.getInstance().accept().then(async (result) => {
              if (result.code === 0) {
                // 先销毁 SubWindow（让主窗口恢复控制权），再执行路由跳转
                await this._bannerWidget?.dismiss();
                this._bannerWidget = null;
                router.pushNamedRoute({ name: 'callMainPage' }).catch((err: Error) => {
                  CallUILog.error(CallManager._tag, `bannerAccept: 跳转通话页面失败:: ${String(err)}`);
                });
              } else {
                CallUILog.error(CallManager._tag, `bannerAccept: accept failed code=${result.code}`);
                await this._bannerWidget?.dismiss();
                this._bannerWidget = null;
              }
            });
          },
          // 拒绝回调
          () => {
            CallUILog.info(CallManager._tag, 'bannerRejectTapped');
            NECallEngine.getInstance().hangup('').then(() => {
              this._bannerWidget?.dismiss();
            });
          },
          // 点击主体回调（跳全屏来电页）
          () => {
            CallUILog.info(CallManager._tag, 'bannerBodyTapped');
            (async () => {
              // 先销毁 SubWindow，再跳转，避免 SubWindow 遮挡路由
              await this._bannerWidget?.dismiss();
              this._bannerWidget = null;
              this.launchCallingPage();
            })();
          }
        );
        return;
      }
      // 跳转到通话页面
      this.launchCallingPage();
    });

    // 订阅通话结束事件，横幅显示期间来电取消/超时时自动关闭
    NEEventNotify.getInstance().register(setStateEventOnCallEnd, () => {
      if (this._bannerWidget?.isShowing()) {
        CallUILog.info(CallManager._tag, 'dismissIncomingBanner reason=callEnded');
        this._bannerWidget.dismiss();
        this._bannerWidget = null;
      }
    });
  }

  /**
   * 启动通话页面
   */
  launchCallingPage(): void {
    CallUILog.info(CallManager._tag, `launchCallingPage`);
    this.initAudioPlayDeviceAndCamera();
    try {
      // 保存当前路由信息，用于通话结束后返回
      this._saveCurrentRoute();
      
      router.pushNamedRoute({
        name: 'callMainPage'
      }).catch((err: Error) => {
        CallUILog.error(CallManager._tag, `跳转通话页面失败:: ${String(err)}`);
      });
    } catch (error) {
      CallUILog.error(CallManager._tag, `跳转通话页面异常:: ${String(error)}`);
    }
  }

  /**
   * 保存当前路由信息
   * 注意：由于 HarmonyOS RouterState API 限制，这里简化处理
   * 实际返回时通过检查路由栈来决定返回方式
   */
  private _saveCurrentRoute(): void {
    try {
      const state: router.RouterState | undefined = router.getState();
      if (state !== undefined) {
        CallUILog.info(CallManager._tag, `当前路由索引: ${state.index}`);
        // 由于 RouterState 可能不提供直接访问路由名称/URL 的方式
        // 这里只记录索引，实际返回时通过 router.back() 或检查路由栈来处理
      }
    } catch (error) {
      CallUILog.error(CallManager._tag, `保存当前路由信息失败:: ${String(error)}`);
    }
  }

  /**
   * 获取跳转前的路由信息
   */
  getPreviousRoute(): PreviousRouteInfo {
    return {
      name: this._previousRouteName,
      url: this._previousRouteUrl
    };
  }

  /**
   * 清除保存的路由信息
   */
  clearPreviousRoute(): void {
    this._previousRouteName = null;
    this._previousRouteUrl = null;
  }

  /**
   * 获取单例实例
   * @returns CallManager 实例
   */
  static get instance(): CallManager {
    return CallManager._instance;
  }

  /**
   * 获取 appKey
   */
  get appKey(): string | null {
    return this._appKey;
  }

  /**
   * 获取额外配置
   */
  get extraConfig(): NEExtraConfig | null {
    return this._extraConfig;
  }

  /**
   * 设置 UI 配置
   * @param uiConfig UI 配置（可选）
   */
  setUIConfig(uiConfig: NECallUIConfig): void {
    const enableCallToast = uiConfig.enableCallToast ?? ToastUtils.isToastEnabled();
    this._uiConfig = {
      enableIncomingBanner: uiConfig.enableIncomingBanner,
      enableCallToast: enableCallToast
    };
    ToastUtils.setToastEnabled(enableCallToast);
    CallUILog.info(CallManager._tag,
      `setUIConfig(enableIncomingBanner:${uiConfig.enableIncomingBanner}, enableCallToast:${enableCallToast})`);
  }

  /**
   * 获取 UI 配置
   */
  get uiConfig(): NECallUIConfig | null {
    return this._uiConfig;
  }

  /**
   * 设置引擎
   * @param appKey 应用 Key
   * @param accountId 账号ID
   * @param extraConfig 额外配置（可选）
   */
  async setupEngine(
    config: NESetupConfig
  ): Promise<void> {
    CallUILog.info(CallManager._tag, `setupEngine(appKey:${config.appKey}, accountId: ${config.accountId}, extraConfig: ${config.extraConfig})`);

    this._appKey =  config.appKey;
    this._accountId =  config.accountId;

    // 保存 Ability Context，供权限请求等场景使用
    this._context = config.context as common.Context;

    // 设置 CallingBellFeature 的 context
    CallingBellFeature.instance.setContext(config.context);

    // 注册引擎观察者
    CallState.instance.registerEngineObserver();
    CallState.instance.selfUser.id = config.accountId;

    const result = await NECallEngine.getInstance().setup(config);

    if (result.code == 0) {
      CallUILog.info(CallManager._tag, `setupEngine success`);
      // 设置 NIM 实例到 NimUtils，用于获取用户信息
      NimUtils.setNimInstance(config.nim);

      // 异步获取本地用户的头像和昵称信息
      this._fetchSelfUserInfo(config.accountId);
    } else {
      CallUILog.error(CallManager._tag, `setupEngine failed: code=${result.code}, message=${result.message}`);
      // TODO: 显示错误提示
    }
  }

  /**
   * 获取本地用户的头像和昵称信息
   * @param accountId 用户账号ID
   */
  private async _fetchSelfUserInfo(accountId: string): Promise<void> {
    try {
      const userInfo = await NimUtils.getUserInfo(accountId);
      if (userInfo) {
        CallState.instance.selfUser.nickname = userInfo.nickname || accountId;
        CallState.instance.selfUser.avatar = userInfo.avatar || '';
        CallUILog.info(CallManager._tag,
          `fetchSelfUserInfo success: nickname=${CallState.instance.selfUser.nickname}, avatar=${CallState.instance.selfUser.avatar ? '有' : '无'}`);
      }
    } catch (error) {
      CallUILog.warn(CallManager._tag,
        `fetchSelfUserInfo failed: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  /**
   * 释放引擎
   */
  releaseEngine(): void {
    CallUILog.info(CallManager._tag, `releaseEngine`);
    CallState.instance.unRegisterEngineObserver();
  }

  /**
   * 发起呼叫
   * @param params 呼叫参数
   * @returns 结果
   */
  async call(
    params: NECallParam
  ): Promise<NEResult> {
    CallUILog.info(CallManager._tag, `call(params:${params}), type: ${params.callType}, version:${Constants.pluginVersion}`);

    if (params.accountId.length === 0) {
      CallUILog.error(CallManager._tag, `Call failed, userId is empty`);
      return new NEResult(-1, 'Call failed, userId is empty');
    }

    // 请求媒体权限（麦克风 + 摄像头）
    // 注意：底层 NECallEngine 在加入 RTC 前也会再次校验权限，这里是 UI 层的前置校验，便于及早给出提示
    try {
      const code = await PermissionUtils.requestMediaPermissions(this._context!, params.callType);
      if (code != NEErrorCode.SUCCESS) {
        CallUILog.error(CallManager._tag, 'call: media permission denied');
        // 显示权限拒绝引导提示
        this._handlePermissionDenied(code);
        return new NEResult(code, PermissionUtils.getPermissionDeniedMessage(code));
      }
    } catch (error) {
      CallUILog.error(CallManager._tag, `call: requestMediaPermissions exception: ${String(error)}`);
      return new NEResult(NEErrorCode.COMMON_ERROR, 'Media permission request failed');
    }

    const callResult = await NECallEngine.getInstance().call(params);

    if (callResult.code == 0) {
      let user: User = new User();
      user.id = params.accountId;
      user.callRole = NECallRole.CALLER;
      user.callStatus = NECallStatus.WAITING;
      CallState.instance.remoteUserList.push(user);
      this._updateUserInfo();

      CallState.instance.callType = params.callType;
      CallState.instance.scene = NECallScene.SINGLE_CALL;
      CallState.instance.selfUser.callRole = NECallRole.CALLER;
      CallState.instance.selfUser.callStatus = NECallStatus.WAITING;
      CallingBellFeature.instance.startRing();
      this.launchCallingPage();
    } else if (
      callResult.code == -2 // ERROR_CURRENT_WRONG_STATE
    ) {
      // TODO: 显示用户正在通话中的提示
      CallUILog.info(CallManager._tag, `User is in call`);
    } else {
      CallUILog.info(CallManager._tag, `callResult.code: ${callResult.code}, callResult.message: ${callResult.message}`);
    }

    return new NEResult(callResult.code, callResult.message ?? '');
  }

  /**
   * 发起群呼
   * @param params 群呼参数（包含 calledAccIds）
   * @returns 结果
   * @since 2.0.0
   */
  async startGroupCall(params: NECallParam): Promise<NEResult> {
    CallUILog.info(CallManager._tag, `startGroupCall: calleeCount=${params.calledAccIds?.length ?? 0}, type=${params.callType}`);

    // 验证群呼参数
    if (!params.calledAccIds || params.calledAccIds.length === 0) {
      CallUILog.error(CallManager._tag, 'startGroupCall failed: calledAccIds is empty');
      return new NEResult(-1, 'Group call requires calledAccIds');
    }

    // 请求媒体权限
    try {
      const code = await PermissionUtils.requestMediaPermissions(this._context!, params.callType);
      if (code != NEErrorCode.SUCCESS) {
        CallUILog.error(CallManager._tag, 'startGroupCall: media permission denied');
        // 显示权限拒绝引导提示
        this._handlePermissionDenied(code);
        return new NEResult(code, PermissionUtils.getPermissionDeniedMessage(code));
      }
    } catch (error) {
      CallUILog.error(CallManager._tag, `startGroupCall: requestMediaPermissions exception: ${String(error)}`);
      return new NEResult(NEErrorCode.COMMON_ERROR, 'Media permission request failed');
    }

    // 调用引擎发起群呼
    CallUILog.info(CallManager._tag, `[群呼调试] 开始调用 NECallEngine.call(), params=${JSON.stringify({
      callType: params.callType,
      calledAccIds: params.calledAccIds,
      rtcChannelName: params.rtcChannelName,
      isGroupCall: params.isGroupCall()
    })}`);
    const callResult = await NECallEngine.getInstance().call(params);
    CallUILog.info(CallManager._tag, `[群呼调试] NECallEngine.call() 返回: code=${callResult.code}, message=${callResult.message}`);

    if (callResult.code === 0) {
      // 检查群呼是否已提前结束（例如所有被叫均因占线自动拒绝）
      // await call() 期间 IM 通知可能已处理并触发 onGroupCallEnd/reset，此时不应再打开通话页
      const groupCallInfo = NEGroupCall.getInstance().currentGroupCallInfo();
      if (!groupCallInfo) {
        CallUILog.warn(CallManager._tag, 'startGroupCall: group call already ended before page launch, skip opening calling page');
        return new NEResult(-1, 'Group call ended immediately');
      }

      // 设置群呼状态
      CallState.instance.callType = params.callType;
      CallState.instance.scene = NECallScene.GROUP_CALL;
      CallState.instance.selfUser.callRole = NECallRole.CALLER;

      // 主叫保持等待状态，计时器在首个被叫接听后启动
      CallState.instance.selfUser.callStatus = NECallStatus.WAITING;

      // 同步群呼信息到 UI 层（包含 callId）
      CallState.instance.syncGroupCallInfo();

      // 主叫方已加入 RTC，配置音视频设备（不启动计时器，等待首个被叫接听）
      if (CallState.instance.isMicrophoneMute) {
        await this.closeMicrophone();
      } else {
        await this.openMicrophone();
      }
      await this.setSpeakerphoneOn(CallState.instance.isEnableSpeaker);
      CallState.instance.isLocalViewBig = false;
      CallState.instance.isInNativeIncomingBanner = false;

      // 初始化远端用户列表
      CallState.instance.remoteUserList = [];
      for (const accId of params.calledAccIds) {
        const user = new User();
        user.id = accId;
        user.callRole = NECallRole.CALLED;
        user.callStatus = NECallStatus.WAITING;
        CallState.instance.remoteUserList.push(user);
      }

      // 更新用户信息（获取昵称、头像等）
      this._updateUserInfo();

      // 二次检查：设备配置的 await 期间群呼也可能已结束
      if (!NEGroupCall.getInstance().currentGroupCallInfo()) {
        CallUILog.warn(CallManager._tag, 'startGroupCall: group call ended during device setup, skip opening calling page');
        return new NEResult(-1, 'Group call ended during device setup');
      }

      // 开始响铃
      CallingBellFeature.instance.startRing();

      // 启动通话页面
      this.launchCallingPage();

      CallUILog.info(CallManager._tag, 'startGroupCall success');
    } else if (callResult.code === -2) {
      CallUILog.info(CallManager._tag, 'User is in call');
    } else {
      CallUILog.error(CallManager._tag, `startGroupCall failed: code=${callResult.code}, message=${callResult.message}`);
    }

    return new NEResult(callResult.code, callResult.message ?? '');
  }

  /**
   * 加入群呼（通过 callId）
   * @param callId 群呼 ID
   * @returns 结果
   * @since 4.4.0
   */
  async joinGroupCall(callId: string): Promise<NEResult> {
    CallUILog.info(CallManager._tag, `joinGroupCall: callId=${callId}`);

    if (!callId || callId.length === 0) {
      return new NEResult(-1, 'callId is empty');
    }

    // 请求媒体权限（群呼默认音频）
    try {
      const code = await PermissionUtils.requestMediaPermissions(this._context!, NECallType.AUDIO);
      if (code != NEErrorCode.SUCCESS) {
        CallUILog.error(CallManager._tag, 'joinGroupCall: media permission denied');
        this._handlePermissionDenied(code);
        return new NEResult(code, PermissionUtils.getPermissionDeniedMessage(code));
      }
    } catch (error) {
      CallUILog.error(CallManager._tag, `joinGroupCall: requestMediaPermissions exception: ${String(error)}`);
      return new NEResult(NEErrorCode.COMMON_ERROR, 'Media permission request failed');
    }

    const param: GroupJoinParam = { callId };
    const result = await NEGroupCall.getInstance().groupJoin(param);
    CallUILog.info(CallManager._tag, `joinGroupCall result: code=${result.code}`);

    if (result.code === 0) {
      // 设置通话状态
      CallState.instance.scene = NECallScene.GROUP_CALL;
      CallState.instance.callType = NECallType.AUDIO;
      CallState.instance.selfUser.callRole = NECallRole.CALLED;
      CallState.instance.isLocalViewBig = false;
      CallState.instance.isInNativeIncomingBanner = false;

      // 从 groupCallInfo 同步远端成员列表
      CallState.instance.remoteUserList = [];
      const members: GroupCallMember[] = result.members ?? [];
      for (const member of members) {
        if (member.accId && member.accId !== CallState.instance.selfUser.id) {
          const user = new User();
          user.id = member.accId;
          user.callRole = NECallRole.CALLED;
          user.callStatus = NECallStatus.ACCEPT;
          CallState.instance.remoteUserList.push(user);
        }
      }

      // 处理通话接通（同步群呼信息、启动计时器、发送事件）
      await CallState.instance.handleGroupCallConnected(callId);

      // 更新用户信息（昵称、头像）
      this._updateUserInfo();

      // 启动通话页面
      this.launchCallingPage();
    }

    return new NEResult(result.code, result.message ?? '');
  }

  /**
   * 启动群呼发起页面
   * @since 2.0.0
   */
  launchGroupCallPage(): void {
    CallUILog.info(CallManager._tag, 'launchGroupCallPage');
    try {
      router.pushNamedRoute({
        name: 'groupCallLaunchPage'
      }).catch((err: Error) => {
        CallUILog.error(CallManager._tag, `跳转群呼发起页面失败: ${String(err)}`);
      });
    } catch (error) {
      CallUILog.error(CallManager._tag, `跳转群呼发起页面异常: ${String(error)}`);
    }
  }

  /**
   * 接受呼叫
   * @returns 结果
   */
  async accept(): Promise<NEResult> {
    CallUILog.info(CallManager._tag, `accept: isGroupCall=${CallState.instance.isGroupCall()}`);

    // 权限在进入通话页面时已请求（与 Android 对齐），接听时不再检查

    let resultCode: number = 0;
    let resultMessage: string = '';

    if (CallState.instance.isGroupCall()) {
      // 群呼场景：接听后立即切换 UI 为通话页
      CallState.instance.isGroupCallInvited = false;
      const callId = CallState.instance.callId;
      CallUILog.info(CallManager._tag, `accept: calling groupAccept, callId=${callId}`);
      const groupResult = await NEGroupCall.getInstance().groupAccept({ callId: callId });
      resultCode = groupResult.code;
      resultMessage = groupResult.message ?? '';
      CallUILog.info(CallManager._tag, `accept groupResult: code=${resultCode}, message=${resultMessage}`);
    } else {
      // 1v1 场景：调用 NECallEngine.accept()
      const engineResult = await NECallEngine.getInstance().accept();
      resultCode = engineResult.code;
      resultMessage = engineResult.message ?? '';
      CallUILog.info(CallManager._tag, `accept engineResult: code=${resultCode}, message=${resultMessage}`);
    }

    if (resultCode == 0) {
      if (CallState.instance.isGroupCall()) {
        // 群呼场景：groupAccept() 后服务端会推送自己的 state=2，
        // 但 onGroupMemberListChanged 中有 callStatus !== ACCEPT 的防重入检查。
        // 为避免该检查误拦截，直接在此处调用 handleGroupCallConnected，
        // 而不依赖 IM 通知回调，确保麦克风开启、计时器启动、UI 事件正常触发。
        // 铃声停止和扬声器恢复统一在 handleGroupCallConnected 中收敛，避免时序竞争。
        await CallState.instance.handleGroupCallConnected(CallState.instance.callId);
      } else {
        // 1v1 保持原有时序：接听成功后立即停止铃声
        CallingBellFeature.instance.stopRing();
        CallUILog.info(CallManager._tag, 'accept: success, stopped ring');
        CallState.instance.selfUser.callStatus = NECallStatus.ACCEPT;
      }
    } else {
      CallState.instance.selfUser.callStatus = NECallStatus.NONE;
      if (resultMessage.length > 0) {
        ToastUtils.showToastWithString(this._context! as common.UIAbilityContext, resultMessage);
      } else {
        ToastUtils.showToast(this._context! as common.UIAbilityContext, $r('app.string.call_accept_failed'));
      }

      CallingBellFeature.instance.stopRing();
      // 清除保存的路由信息
      this.clearPreviousRoute();
      router.back();
    }

    return new NEResult(resultCode, resultMessage);
  }

  /**
   * 拒绝呼叫
   * @returns 结果
   */
  async reject(): Promise<NEResult> {
    CallUILog.info(CallManager._tag, `reject`);
    const result = await NECallEngine.getInstance().hangup('');
    CallUILog.info(CallManager._tag, `reject result = ${result}`);

    CallState.instance.selfUser.callStatus = NECallStatus.NONE;
    return new NEResult(result.code, result.message ?? '');
  }

  /**
   * 切换通话类型
   * @param mediaType 通话类型
   * @param state 切换状态
   */
  async switchCallMediaType(
    mediaType: NECallType,
    state: NECallSwitchState
  ): Promise<void> {
    CallUILog.info(CallManager._tag, `switchCallMediaType mediaType = ${mediaType}`);
    await NECallEngine.getInstance().switchCallType(mediaType, state);
  }

  /**
   * 挂断通话
   * @returns 结果
   */
  async hangup(): Promise<NEResult> {
    CallUILog.info(CallManager._tag, `hangup: isGroupCall=${CallState.instance.isGroupCall()}`);

    let resultCode: number = 0;
    let resultMessage: string = '';

    // 设置主动挂断标志，防止引擎回调（onCallEnd/onGroupCallEnd）重复关闭页面
    CallState.instance.isActiveHangup = true;

    if (CallState.instance.isGroupCall()) {
      // 群呼场景：使用 NEGroupCall.groupHangup()
      // 群呼被叫通过 NEGroupCallImpl 独立管理，引擎层 context 未设置 callScene=GROUP_CALL，
      // 若使用 NECallEngine.hangup() 会因 IDLE 状态直接返回，reject 请求不会发到服务端
      const callId = CallState.instance.callId;
      CallUILog.info(CallManager._tag, `hangup: 群呼模式，callId=${callId}`);
      const groupResult = await NEGroupCall.getInstance().groupHangup({ callId: callId, reason: 'hangup' });
      resultCode = groupResult.code;
      resultMessage = groupResult.message ?? '';
    } else {
      // 1v1 场景：使用 NECallEngine.hangup()
      const engineResult = await NECallEngine.getInstance().hangup('');
      resultCode = engineResult.code;
      resultMessage = engineResult.message ?? '';
    }
    CallUILog.info(CallManager._tag, `hangup result: code=${resultCode}, message=${resultMessage}`);

    // 停止铃声
    CallingBellFeature.instance.stopRing();
    CallUILog.info(CallManager._tag, `hangup: stopped ring`);

    CallState.instance.selfUser.callStatus = NECallStatus.NONE;
    CallState.instance.cleanState();

    // 清除保存的路由信息并关闭页面
    this.clearPreviousRoute();
    try {
      router.back();
      CallUILog.info(CallManager._tag, `hangup: router.back() called`);
    } catch (e) {
      CallUILog.error(CallManager._tag, `hangup: router.back() failed: ${e}`);
    }

    return new NEResult(resultCode, resultMessage);
  }

  /**
   * 忽略来电（仅关闭本地 UI，不发送服务端通知）
   * 与 reject/hangup 不同，ignore 不会通知服务端
   * @since 2.1.0
   */
  ignore(): void {
    CallUILog.info(CallManager._tag, `ignore: 忽略来电，仅重置本地状态`);

    // 停止铃声
    CallingBellFeature.instance.stopRing();

    // 重置本地状态，不调用任何服务端 API
    CallState.instance.selfUser.callStatus = NECallStatus.NONE;
    CallState.instance.cleanState();

    // 关闭通话页面
    try {
      router.back();
    } catch (e) {
      CallUILog.error(CallManager._tag, `ignore: router.back failed: ${e}`);
    }
  }

  /**
   * 打开摄像头
   * @param camera 摄像头类型
   * @param viewId 视图ID
   * @returns 结果
   */
  async openCamera(notify: boolean = true): Promise<NEResult> {
    CallUILog.info(CallManager._tag, `openCamera`);

    // TODO: 请求摄像头权限
    // PermissionResult permissionResult = PermissionResult.granted;
    // if (await Permission.has(permissions: [PermissionType.camera])) {
    //   permissionResult = await Permission.request(NECallType.VIDEO);
    // }
    // if (PermissionResult.granted != permissionResult) {
    //   return new NEResult(-1, 'Camera permission denied');
    // }

    // 先确保本地视频采集已启用（NERtc 要求在 muteLocalVideo 前先 enableLocalVideo）
    const enableRet = NECallEngine.getInstance().enableLocalVideo(true);
    CallUILog.info(CallManager._tag, `openCamera: enableLocalVideo(true) ret=${enableRet}`);

    // 再取消静音（开始发送视频流）
    const ret = NECallEngine.getInstance().muteLocalVideo(false);
    CallUILog.info(CallManager._tag, `openCamera: muteLocalVideo(false) ret=${ret}`);
    const result = new NEResult(ret, '');

    if (result.code == 0) {
      CallState.instance.isCameraOpen = true;
      // CallState.instance.camera = camera;
      CallState.instance.selfUser.videoAvailable = true;
    }
    if (notify) {
      NEEventNotify.getInstance().notify(setStateEvent, {});
    }
    return result;
  }

  /**
   * 关闭摄像头
   */
  async closeCamera(notify: boolean = true): Promise<void> {
    CallUILog.info(CallManager._tag, `closeCamera`);
    NECallEngine.getInstance().muteLocalVideo(true);
    CallState.instance.isCameraOpen = false;
    CallState.instance.selfUser.videoAvailable = false;
    if (notify) {
      NEEventNotify.getInstance().notify(setStateEvent, {});
    }
  }

  /**
   * 切换摄像头
   * @param camera 摄像头类型
   */
  async switchCamera(camera: NECamera): Promise<void> {
    CallUILog.info(CallManager._tag, `switchCamera camera = ${camera}`);
    NECallEngine.getInstance().switchCamera();
  }

  /**
   * 打开麦克风
   * @param notify 是否通知（可选，默认 true）
   * @returns 结果
   */
  async openMicrophone(notify: boolean = true): Promise<NEResult> {
    CallUILog.info(CallManager._tag, `openMicrophone notify = ${notify}`);
    const result = NECallEngine.getInstance().muteLocalAudio(false);
    // 更新状态
    CallState.instance.isMicrophoneMute = false;
    if (notify) {
      NEEventNotify.getInstance().notify(setStateEvent, {});
    }
    return new NEResult(result, '');
  }

  /**
   * 关闭麦克风
   * @param notify 是否通知（可选，默认 true）
   */
  async closeMicrophone(notify: boolean = true): Promise<void> {
    CallUILog.info(CallManager._tag, `closeMicrophone notify = ${notify}`);
    NECallEngine.getInstance().muteLocalAudio(true);
    // 更新状态
    CallState.instance.isMicrophoneMute = true;
    if (notify) {
      NEEventNotify.getInstance().notify(setStateEvent, {});
    }
  }

  /**
   * 设置扬声器开关
   * @param enable 是否开启
   */
  async setSpeakerphoneOn(enable: boolean, notify: boolean = true, updateState: boolean = true): Promise<void> {
    CallUILog.info(CallManager._tag, `setSpeakerphoneOn enable = ${enable}`);
    const result = NECallEngine.getInstance().setSpeakerphoneOn(enable);
    try {
      await audio.getAudioManager().getRoutingManager()
        .setCommunicationDevice(audio.CommunicationDeviceType.SPEAKER, enable);
      CallUILog.info(CallManager._tag, `setCommunicationDevice success, enable = ${enable}`);
    } catch (e) {
      CallUILog.warn(CallManager._tag, `setCommunicationDevice failed, enable = ${enable}, error = ${String(e)}`);
    }
    CallUILog.info(CallManager._tag, `setSpeakerphoneOn result = ${result}, enable = ${enable}, notify = ${notify}, updateState = ${updateState}`);
    // 静默路由重置时只切系统/RTC 路由，不覆盖 UI 目标状态
    if (updateState) {
      CallState.instance.isEnableSpeaker = enable;
    }
    if (notify) {
      NEEventNotify.getInstance().notify(setStateEvent, {});
    }
  }

  /**
   * 设置本地视图
   * @param viewId 视图ID
   */
  async setupLocalView(viewId: string): Promise<void> {
    CallUILog.info(CallManager._tag, `setupLocalView(viewId:${viewId})`);

    let canvas: NERtcConstants.NERtcVideoCanvas = { canvasId: viewId }
    canvas.scalingMode = NERtcConstants.NERtcVideoScalingMode.kNERtcVideoScaleCropFill

    if (viewId.length > 0) {
      //尝试请求权限，否则预览的时候会黑
      const code = await PermissionUtils.requestMediaPermissions(this._context!, NECallType.VIDEO);
      if (code != NEErrorCode.SUCCESS) {
        CallUILog.error(CallManager._tag, 'call: video permission denied');
      }
    }
    NECallEngine.getInstance().setupLocalView(canvas);
  }

  /**
   * 设置远程视图
   * @param userId 用户ID (群呼模式需要传入 accId)
   * @param viewId 视图ID
   */
  async setupRemoteView(userId: string, viewId: string): Promise<void> {
    CallUILog.info(CallManager._tag, `setupRemoteView(userId:${userId}, viewId:${viewId})`);
    let canvas: NERtcConstants.NERtcVideoCanvas = { canvasId: viewId }
    canvas.scalingMode = NERtcConstants.NERtcVideoScalingMode.kNERtcVideoScaleCropFill

    // 群呼模式使用 setupRemoteViewByUserId，1v1 模式使用 setupRemoteView
    if (CallState.instance.isGroupCall() && userId) {
      CallUILog.info(CallManager._tag, `setupRemoteView: 群呼模式，使用 setupRemoteViewByUserId`);
      NECallEngine.getInstance().setupRemoteViewByUserId(canvas, userId);
    } else {
      NECallEngine.getInstance().setupRemoteView(canvas);
    }
  }

  /**
   * 停止远程视图
   * @param userId 用户ID
   */
  async stopRemoteView(userId: string): Promise<void> {
    // TODO: 实现停止远程视图
  }

  /**
   * 设置自己的信息
   * @param nickname 昵称
   * @param avatar 头像
   * @returns 结果
   */
  async setSelfInfo(nickname: string, avatar: string): Promise<NEResult> {
    const accountId = CallState.instance.selfUser.id || this._accountId || '';
    if (accountId.length === 0) {
      CallUILog.error(CallManager._tag, `setSelfInfo failed: accountId is empty`);
      return new NEResult(-1, 'setSelfInfo failed: accountId is empty');
    }

    const normalizedNickname = nickname.trim();
    const normalizedAvatar = avatar.trim();

    // 1) 立即更新本地通话状态，保障 UI 立刻生效
    CallState.instance.selfUser.nickname = normalizedNickname.length > 0 ? normalizedNickname : accountId;
    CallState.instance.selfUser.avatar = normalizedAvatar;

    // 如果自己在 caller/calleeList 中，也同步一份，避免通话过程中的角色视图不一致
    if (CallState.instance.caller.id === accountId) {
      CallState.instance.caller.nickname = CallState.instance.selfUser.nickname;
      CallState.instance.caller.avatar = normalizedAvatar;
    }
    const selfInCallee = CallState.instance.calleeList.find((user) => user.id === accountId);
    if (selfInCallee) {
      selfInCallee.nickname = CallState.instance.selfUser.nickname;
      selfInCallee.avatar = normalizedAvatar;
    }

    NEEventNotify.getInstance().notify(setStateEvent, {});

    // 2) 尝试同步到 NIM 资料，保证对端后续拉取到一致的昵称/头像
    const updateResult = await NimUtils.updateSelfUserProfile(
      CallState.instance.selfUser.nickname,
      normalizedAvatar
    );
    if (!updateResult.success) {
      CallUILog.warn(
        CallManager._tag,
        `setSelfInfo local updated, but sync to NIM failed: ${updateResult.message}`
      );
      return new NEResult(0, `local updated, nim sync failed: ${updateResult.message}`);
    }

    CallUILog.info(
      CallManager._tag,
      `setSelfInfo success: accountId=${accountId}, nickname=${CallState.instance.selfUser.nickname}, avatar=${normalizedAvatar.length > 0 ? '有' : '无'}`
    );
    return new NEResult(0, 'success');
  }

  /**
   * 登录
   * @param appKey 应用 Key
   * @param accountId 账号ID
   * @param token 令牌
   * @param certificateConfig 证书配置（可选）
   * @param extraConfig 额外配置（可选）
   * @returns 结果
   */
  async login(
    appKey: string,
    accountId: string,
    token: string,
    certificateConfig?: NECertificateConfig,
    extraConfig?: NEExtraConfig
  ): Promise<NEResult> {
    CallUILog.info(CallManager._tag, `login(appKey:${appKey}, accountId:${accountId}, certificateConfig:${certificateConfig}, extraConfig:${extraConfig}) version:${Constants.pluginVersion}`);

    // 保存 appKey 和 extraConfig
    this._appKey = appKey;
    this._extraConfig = extraConfig ?? new NEExtraConfig();
    CallUILog.info(CallManager._tag, `login: appKey saved = ${this._appKey}, extraConfig = ${this._extraConfig}`);

    // TODO: 初始化 NIM SDK
    // const options = new NIMSDKOptions();
    // options.appKey = appKey;
    // var initRet = await NimCore.instance.initialize(options);
    // if (initRet.code == 0) {
    //   NEEventNotify.getInstance().notify(imSDKInitSuccessEvent, {});
    // }

    // TODO: 登录 IM
    // var imRet = await NimCore.instance.loginService.login(accountId, token, NIMLoginOption());
    // if (imRet.code == 0) {
    //   NEEventNotify.getInstance().notify(loginSuccessEvent, { 'accountId': accountId, 'token': token });
    // }

    // 登录成功后设置引擎
    // this.handleLoginSuccess(accountId, token);

    return new NEResult(0, 'success');
  }

  /**
   * 登出
   */
  async logout(): Promise<void> {
    CallUILog.info(CallManager._tag, `logout()`);
    NEEventNotify.getInstance().notify('LOGOUT_SUCCESS_EVENT', {});
    // TODO: 登出 IM
    // await _im.loginService.logout();
    this.handleLogoutSuccess();
  }

  /**
   * 设置呼叫铃声
   * @param source 铃声源（AVFileDescriptor 或 string 路径），仅用于被叫时播放
   */
  async setCallingBell(source: media.AVFileDescriptor | string): Promise<void> {
    CallUILog.info(CallManager._tag, `setCallingBell`);
    CallingBellFeature.instance.setCustomIncomingRingtone(source);
  }

  /**
   * 启用/禁用虚拟背景
   * @param enable 是否启用
   */
  enableVirtualBackground(enable: boolean): void {
    CallUILog.info(CallManager._tag, `enableVirtualBackground enable = ${enable}`);
    CallState.instance.enableBlurBackground = enable;
  }

  /**
   * 设置模糊背景
   * @param enable 是否启用
   */
  setBlurBackground(enable: boolean): void {
    // TODO: 实现模糊背景功能
    CallUILog.info(CallManager._tag, `setBlurBackground enable = ${enable}`);
    NECallEngine.getInstance().enableVirtualBackground(enable);
  }

  /**
   * 初始化音频播放设备和摄像头
   * 群呼默认只开音频，不开视频（用户可手动开启摄像头）
   */
  initAudioPlayDeviceAndCamera(): void {
    const isGroupCall = CallState.instance.isGroupCall();
    const callType = CallState.instance.callType;

    // 群呼默认只开音频，摄像头关闭
    if (isGroupCall) {
      CallState.instance.isEnableSpeaker = true;
      CallState.instance.isCameraOpen = false;  // 默认不开视频
    } else if (NECallType.AUDIO == callType) {
      CallState.instance.isEnableSpeaker = false;
      CallState.instance.isCameraOpen = false;
    } else {
      CallState.instance.isEnableSpeaker = true;
      CallState.instance.isCameraOpen = true;
    }

    // 同步 RTC 层的视频状态（重要：避免 UI 状态与 RTC 状态不一致）
    if (!CallState.instance.isCameraOpen) {
      // 禁用本地视频采集（节省资源，不启动摄像头）
      NECallEngine.getInstance().enableLocalVideo(false);
      // 静音本地视频（不发送视频流）
      NECallEngine.getInstance().muteLocalVideo(true);
      CallState.instance.selfUser.videoAvailable = false;
    }

    CallUILog.info(CallManager._tag, `initAudioPlayDeviceAndCamera: isGroupCall=${isGroupCall}, callType=${callType}, isCameraOpen=${CallState.instance.isCameraOpen}, isEnableSpeaker=${CallState.instance.isEnableSpeaker}`);
    CallManager.instance.setSpeakerphoneOn(CallState.instance.isEnableSpeaker);
  }

  /**
   * 处理登录成功
   * @param accountId 账号ID
   * @param token 令牌
   */
  handleLoginSuccess(accountId: string, token: string): void {
    CallUILog.info(CallManager._tag, `handleLoginSuccess: appKey = ${this._appKey}, accountId = ${accountId}`);
    if (this._appKey) {
      // this.setupEngine(new NESetupConfig(null, this._appKey, accountId, this._extraConfig ?? undefined));
    }
  }

  /**
   * 处理登出成功
   */
  handleLogoutSuccess(): void {
    CallUILog.info(CallManager._tag, `handleLogoutSuccess()`);
    NECallEngine.getInstance().destroy();
    // 停止铃声
    CallingBellFeature.instance.stopRing();
    CallState.instance.cleanState();
    CallState.instance.unRegisterEngineObserver();
  }

  /**
   * 启用/禁用来电横幅
   * @param enable 是否启用
   */
  enableIncomingBanner(enable: boolean): void {
    if (!this._uiConfig) {
      this._uiConfig = {
        enableCallToast: ToastUtils.isToastEnabled()
      };
    }
    this._uiConfig.enableIncomingBanner = enable;
    CallUILog.info(CallManager._tag, `enableIncomingBanner enable = ${enable}`);
  }

  /**
   * 启用/禁用通话流程 toast 提示
   * @param enable 是否启用
   */
  enableCallToast(enable: boolean): void {
    if (!this._uiConfig) {
      this._uiConfig = {};
    }
    this._uiConfig.enableCallToast = enable;
    ToastUtils.setToastEnabled(enable);
    CallUILog.info(CallManager._tag, `enableCallToast enable = ${enable}`);
  }

  /**
   * 启用/禁用唤醒锁
   * @param enable 是否启用
   */
  async enableWakeLock(enable: boolean): Promise<void> {
    CallUILog.info(CallManager._tag, `enableWakeLock(${enable})`);
    // TODO: 实现唤醒锁功能
  }

  /**
   * 显示来电横幅
   */
  showIncomingBanner(): void {
    CallUILog.info(CallManager._tag, `showIncomingBanner`);
    // TODO: 实现显示来电横幅
  }

  /**
   * T042：前台重显——应用回到前台时调用，检查来电状态并重新展示横幅
   * 集成方在 UIAbility.onForeground() 中调用此方法
   */
  handleAppEnterForeground(): void {
    CallUILog.info(CallManager._tag,
      `handleAppEnterForeground callStatus=${CallState.instance.selfUser.callStatus}`);

    // 若横幅模式未开启，跳过横幅重显逻辑
    if (this._uiConfig?.enableIncomingBanner !== true) {
      return;
    }

    // 若来电仍在进行且横幅未显示，则重新展示横幅
    if (CallState.instance.selfUser.callStatus === NECallStatus.WAITING &&
        CallState.instance.selfUser.callRole !== undefined) {
      if (!this._bannerWidget?.isShowing()) {
        CallUILog.info(CallManager._tag, `appResumed checkBannerState reShowBanner`);
        // 重新触发来电横幅展示：通过事件系统驱动，复用已有的展示逻辑
        NEEventNotify.getInstance().notify(setStateEventOnCallReceived, {});
      }
    }
  }

  /**
   * 拉取后台应用
   */
  pullBackgroundApp(): void {
    CallUILog.info(CallManager._tag, `pullBackgroundApp`);
    // TODO: 实现拉取后台应用
  }

  /**
   * 打开锁屏应用
   */
  openLockScreenApp(): void {
    CallUILog.info(CallManager._tag, `openLockScreenApp`);
    // TODO: 实现打开锁屏应用
  }

  /**
   * 启动前台服务
   */
  startForegroundService(): void {
    CallUILog.info(CallManager._tag, `startForegroundService`);
    // TODO: 实现启动前台服务
  }

  /**
   * 停止前台服务
   */
  stopForegroundService(): void {
    CallUILog.info(CallManager._tag, `stopForegroundService`);
    // TODO: 实现停止前台服务
  }

  /**
   * 检查屏幕是否锁定
   * @returns 是否锁定
   */
  async isScreenLocked(): Promise<boolean> {
    // TODO: 实现检查屏幕锁定
    return false;
  }

  /**
   * 检查是否为三星设备
   * @returns 是否为三星设备
   */
  async isSamsungDevice(): Promise<boolean> {
    // TODO: 实现检查三星设备
    return false;
  }

  /**
   * 获取远程用户信息并更新
   */
  async _updateUserInfo(): Promise<void> {
    CallUILog.info(CallManager._tag, `_getUserInfo`);
    
    const remoteUserList = CallState.instance.remoteUserList;
    if (remoteUserList.length === 0) {
      CallUILog.info(CallManager._tag, `_getUserInfo: remoteUserList is empty`);
      return;
    }

    try {
      // 收集所有需要获取的用户ID
      const accountIdList: string[] = [];
      for (const user of remoteUserList) {
        if (user.id && user.id.length > 0) {
          accountIdList.push(user.id);
        }
      }

      if (accountIdList.length === 0) {
        CallUILog.info(CallManager._tag, `_getUserInfo: no valid accountId found`);
        return;
      }

      // 批量获取用户信息
      const userInfoList = await NimUtils.getUserInfos(accountIdList);

      // 创建用户信息映射，方便查找
      const userInfoMap = new Map<string, User>();
      for (const userInfo of userInfoList) {
        userInfoMap.set(userInfo.id, userInfo);
      }

      // 更新 remoteUserList 中的用户信息
      for (const user of remoteUserList) {
        const userInfo = userInfoMap.get(user.id);
        if (userInfo) {
          user.nickname = userInfo.nickname || user.id;
          user.avatar = userInfo.avatar || Constants.defaultAvatar;
        } else {
          // 如果获取不到用户信息，使用默认值
          if (!user.nickname || user.nickname.length === 0) {
            user.nickname = user.id;
          }
          if (!user.avatar || user.avatar.length === 0) {
            user.avatar = Constants.defaultAvatar;
          }
        }
      }

      // 通知状态更新
      NEEventNotify.getInstance().notify(setStateEvent, {});
      CallUILog.info(CallManager._tag, `_getUserInfo: success, updated ${remoteUserList.length} users`);
    } catch (error) {
      CallUILog.error(CallManager._tag, `_getUserInfo error:: ${String(error)}`);
    }
  }

  /**
   * 处理权限被拒绝的情况
   * @param errorCode 权限错误码
   * @since 2.0.0
   */
  private _handlePermissionDenied(errorCode: number): void {
    CallUILog.info(CallManager._tag, `_handlePermissionDenied: errorCode=${errorCode}`);
    if (this._context) {
      // 显示权限拒绝引导对话框
      PermissionUtils.showPermissionDeniedGuidance(this._context as common.UIAbilityContext, errorCode);
    } else {
      CallUILog.warn(CallManager._tag, '_handlePermissionDenied: context is null, cannot show guidance');
    }
  }

}
