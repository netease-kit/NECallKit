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
  NEErrorCode
} from '@yunxin/callkit';

import { media } from '@kit.MediaKit';
import { NEEventNotify } from '../event/EventNotify';
import { Constants, setStateEvent, setStateEventOnCallReceived } from '../data/Constants';
import { NECallRole, NECallScene, NECallStatus, NECamera } from '../CallDefine';
import { CallState } from './CallState';
import { CallingBellFeature } from './CallingBellFeature';
import router from '@ohos.router';
import { User } from '../data/User';
import { NimUtils } from '../utils/NimUtils';
import common from '@ohos.app.ability.common';
import { PermissionUtils } from '../utils/PermissionUtils';
import { CallUILog } from '../utils/CallUILog';
import { ToastUtils } from '../utils/ToastUtils';

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
      // 跳转到通话页面
      this.launchCallingPage();
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
    } else {
      CallUILog.error(CallManager._tag, `setupEngine failed: code=${result.code}, message=${result.message}`);
      // TODO: 显示错误提示
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
        return new NEResult(code, 'Media permission denied');
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
   * 接受呼叫
   * @returns 结果
   */
  async accept(): Promise<NEResult> {
    CallUILog.info(CallManager._tag, `accept`);
    const result = await NECallEngine.getInstance().accept();
    CallUILog.info(CallManager._tag, `accept result = ${result}`);

    if (result.code == 0) {
      CallState.instance.selfUser.callStatus = NECallStatus.ACCEPT;
    } else {
      CallState.instance.selfUser.callStatus = NECallStatus.NONE;
      if (result.message && result.message.length > 0) {
        ToastUtils.showToastWithString(this._context! as common.UIAbilityContext, result.message);
      } else {
        ToastUtils.showToast(this._context! as common.UIAbilityContext, $r('app.string.call_accept_failed'));
      }

      CallingBellFeature.instance.stopRing();
      // 清除保存的路由信息
      this.clearPreviousRoute();
      router.back();
    }

    return new NEResult(result.code, result.message ?? '');
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
    CallUILog.info(CallManager._tag, `hangup`);
    const result = await NECallEngine.getInstance().hangup('');
    CallUILog.info(CallManager._tag, `hangup result = ${result}`);

    CallState.instance.selfUser.callStatus = NECallStatus.NONE;
    CallState.instance.cleanState();

    return new NEResult(result.code, result.message ?? '');
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

    const ret = NECallEngine.getInstance().muteLocalVideo(false);
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
  async setSpeakerphoneOn(enable: boolean): Promise<void> {
    CallUILog.info(CallManager._tag, `setSpeakerphoneOn enable = ${enable}`);
    NECallEngine.getInstance().setSpeakerphoneOn(enable);
    // 更新状态
    CallState.instance.isEnableSpeaker = enable;
    NEEventNotify.getInstance().notify(setStateEvent, {});
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
   * @param userId 用户ID
   * @param viewId 视图ID
   */
  async setupRemoteView(userId: string, viewId: string): Promise<void> {
    CallUILog.info(CallManager._tag, `setupRemoteView(userId:${userId}, viewId:${viewId})`);
    let canvas: NERtcConstants.NERtcVideoCanvas = { canvasId: viewId }
    canvas.scalingMode = NERtcConstants.NERtcVideoScalingMode.kNERtcVideoScaleCropFill
    NECallEngine.getInstance().setupRemoteView(canvas);
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
    // TODO: 实现设置自己信息
    return new NEResult(0, '');
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
   */
  initAudioPlayDeviceAndCamera(): void {
    if (NECallType.AUDIO == CallState.instance.callType) {
      CallState.instance.isEnableSpeaker = false;
      CallState.instance.isCameraOpen = false;
    } else {
      CallState.instance.isEnableSpeaker = true;
      CallState.instance.isCameraOpen = true;
    }
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
    // TODO: 实现来电横幅功能
    CallUILog.info(CallManager._tag, `enableIncomingBanner enable = ${enable}`);
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

}

