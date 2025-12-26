// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { CallState } from '../impl/CallState';
import { NECallType, NECallStatus, NECallRole } from '../CallDefine';
import { Constants, setStateEvent, setStateEventRefreshTiming } from '../data/Constants';
import { NERtcVideoView } from '@nertc/nertc_sdk';
import { CallManager } from '../impl/CallManager';
import common from '@ohos.app.ability.common';
import { NEEventNotify } from '../event/EventNotify';
import { CallUILog } from '../utils/CallUILog';
import { NimUtils } from '../utils/NimUtils';

/**
 * Resource 对象接口，用于访问资源ID
 */
interface ResourceWithId {
  id?: number;
}

/**
 * P2P 用户通话界面组件
 * 对应 Flutter 版本的 CallsIndividualUserWidget
 * 负责显示视频/音频界面、用户信息等
 *
 * 场景分类：
 * 1. 主叫等待中 - 音频/视频
 * 2. 被叫等待中 - 音频/视频
 * 3. 通话中 - 音频/视频
 */
@Component
export struct CallsP2PUserWidget {
  private static readonly TAG = 'CallsP2PUserWidget';
  close: () => void = () => {
  };
  @State remoteUserName: string = '';
  @State remoteUserID: string = '';
  @State remoteUserAvatar: string = Constants.defaultAvatar;
  @State remoteUserVideoAvailable: boolean = true;
  @State remoteUserAudioAvailable: boolean = true;
  @State localUserAvatar: string = Constants.defaultAvatar;
  @State callDuration: string = '00:00';
  @State callStatusText: string = '等待接听...';
  @State callStatusEnum: NECallStatus = NECallStatus.WAITING;
  @State isVideoCall: boolean = false;
  @State isCaller: boolean = false;
  @State isCameraOpen: boolean = false;
  @State isLocalViewBig: boolean = false;
  @State dotAnimationIndex: number = 0; // 用于三个点闪动动画
  // 保存大画面和小画面的viewId
  _bigViewId: string = "bigView";
  _smallViewId: string = "smallView";
  private refreshTimingCallback = () => {
    this.updateCallDuration();
  }
  private stateEventCallback = () => {
    this.updateUI();
  }
  private dotAnimationTimer: number | null = null; // 动画定时器（setInterval 返回的 timer ID）

  aboutToAppear(): void {
    this.updateUI();
    NEEventNotify.getInstance().register(setStateEvent, this.stateEventCallback);
    NEEventNotify.getInstance().register(setStateEventRefreshTiming, this.refreshTimingCallback);
    this.startDotAnimation();
  }

  aboutToDisappear(): void {
    NEEventNotify.getInstance().unregister(setStateEvent, this.stateEventCallback);
    NEEventNotify.getInstance().unregister(setStateEventRefreshTiming, this.refreshTimingCallback);
    this.stopDotAnimation();
  }

  // ==================== 状态更新 ====================

  updateUI(): void {
    const state = CallState.instance;

    // 更新远程用户信息（同步更新基本信息，异步获取头像）
    this.updateRemoteUserInfoSync(state);

    // 更新本地用户头像（同步更新基本信息，异步获取头像）
    this.updateLocalUserAvatarSync(state);

    // 更新通话状态
    this.isVideoCall = state.callType === NECallType.VIDEO;
    this.isCaller = state.selfUser.callRole === NECallRole.CALLER;
    this.callStatusEnum = state.selfUser.callStatus;
    this.isCameraOpen = state.isCameraOpen;
    this.isLocalViewBig = state.isLocalViewBig;

    // 更新状态文字
    this.updateCallStatusText(state);

    // 更新通话时长
    this.updateCallDuration();

    CallUILog.info(CallsP2PUserWidget.TAG,
      `updateUI: isCaller=${this.isCaller}, callStatus=${this.callStatusEnum}, remoteUser=${this.remoteUserName}, isVideoCall=${this.isVideoCall}, isCameraOpen=${this.isCameraOpen}, isLocalViewBig=${this.isLocalViewBig}, localAvatar=${this.localUserAvatar}, remoteAvatar=${this.remoteUserAvatar}`);

    // 异步获取用户头像信息
    this.updateUserAvatarsAsync(state);

    // 更新动画状态（如果是视频呼叫且是等待状态，启动动画）
    if (this.isVideoCall && this.callStatusEnum === NECallStatus.WAITING) {
      this.startDotAnimation();
    } else {
      this.stopDotAnimation();
    }
  }

  /**
   * 同步更新远程用户基本信息（不包含头像，头像通过异步获取）
   */
  private updateRemoteUserInfoSync(state: CallState): void {
    if (state.remoteUserList.length > 0) {
      const remoteUser = state.remoteUserList[0];
      this.remoteUserName = remoteUser.nickname || remoteUser.id || '未知用户';
      this.remoteUserAvatar = remoteUser.avatar || Constants.defaultAvatar;
      this.remoteUserID = remoteUser.id;
      this.remoteUserVideoAvailable = remoteUser.videoAvailable;
      this.remoteUserAudioAvailable = remoteUser.audioAvailable;
    } else if (state.caller.id.length > 0) {
      this.remoteUserName = state.caller.nickname || state.caller.id || '未知用户';
      this.remoteUserAvatar = state.caller.avatar || Constants.defaultAvatar;
      this.remoteUserID = state.caller.id;
      this.remoteUserVideoAvailable = state.caller.videoAvailable;
      this.remoteUserAudioAvailable = state.caller.audioAvailable;
    }
  }

  /**
   * 同步更新本地用户头像基本信息（不包含头像，头像通过异步获取）
   * 仅设置默认值，实际头像从 NimUtils.getUserInfo 异步获取
   */
  private updateLocalUserAvatarSync(state: CallState): void {
    this.localUserAvatar = state.selfUser.avatar || Constants.defaultAvatar;
  }

  /**
   * 异步获取用户头像信息
   * 本地和远程头像都从 NimUtils.getUserInfo 获取
   */
  private async updateUserAvatarsAsync(state: CallState): Promise<void> {
    // 获取远程用户头像
    if (this.remoteUserID && this.remoteUserID.length > 0) {
      try {
        const remoteUserInfo = await NimUtils.getUserInfo(this.remoteUserID);
        if (remoteUserInfo && remoteUserInfo.avatar && remoteUserInfo.avatar.length > 0) {
          this.remoteUserAvatar = remoteUserInfo.avatar;
          CallUILog.info(CallsP2PUserWidget.TAG, `Updated remote user avatar from NimUtils: ${this.remoteUserAvatar}`);
        } else {
          this.remoteUserAvatar = Constants.defaultAvatar;
          CallUILog.info(CallsP2PUserWidget.TAG, `Remote user avatar not found, using default`);
        }
      } catch (error) {
        CallUILog.error(CallsP2PUserWidget.TAG,
          `Failed to get remote user info: ${error instanceof Error ? error.message : String(error)}`);
        this.remoteUserAvatar = Constants.defaultAvatar;
      }
    }

    // 获取本地用户头像（从 NimUtils.getUserInfo 获取，与远程头像获取方式一致）
    if (state.selfUser.id && state.selfUser.id.length > 0) {
      try {
        const localUserInfo = await NimUtils.getUserInfo(state.selfUser.id);
        if (localUserInfo && localUserInfo.avatar && localUserInfo.avatar.length > 0) {
          this.localUserAvatar = localUserInfo.avatar;
          CallUILog.info(CallsP2PUserWidget.TAG, `Updated local user avatar from NimUtils: userId=${state.selfUser.id}, avatar=${this.localUserAvatar}`);
        } else {
          this.localUserAvatar = Constants.defaultAvatar;
          CallUILog.info(CallsP2PUserWidget.TAG, `Local user avatar not found, using default, userId=${state.selfUser.id}`);
        }
      } catch (error) {
        CallUILog.error(CallsP2PUserWidget.TAG,
          `Failed to get local user info: userId=${state.selfUser.id}, error=${error instanceof Error ? error.message : String(error)}`);
        this.localUserAvatar = Constants.defaultAvatar;
      }
    } else {
      CallUILog.warn(CallsP2PUserWidget.TAG, `Local user ID is empty, cannot fetch avatar from NimUtils`);
      this.localUserAvatar = Constants.defaultAvatar;
    }
  }

  /**
   * 获取国际化字符串
   * @param resId 资源对象
   * @returns 国际化字符串
   */
  private getString(resId: Resource): string {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      if (context && context.resourceManager) {
        // Resource 对象有 id 属性，使用类型断言访问
        const resourceObj = resId as ResourceWithId;
        if (resourceObj.id !== undefined) {
          return context.resourceManager.getStringSync(resourceObj.id);
        }
      }
    } catch (error) {
      console.error(`[${CallsP2PUserWidget.TAG}] getString error:`, error);
    }
    return '';
  }

  private updateCallStatusText(state: CallState): void {
    if (state.selfUser.callStatus === NECallStatus.WAITING) {
      this.callStatusText = this.isCaller
        ? this.getString($r('app.string.call_status_waiting_caller'))
        : this.getString($r('app.string.call_status_waiting_callee'));
    } else if (state.selfUser.callStatus === NECallStatus.ACCEPT) {
      this.callStatusText = this.getString($r('app.string.call_status_connected'));
    } else {
      this.callStatusText = '';
    }
  }

  updateCallDuration(): void {
    const state = CallState.instance;
    if (state.selfUser.callStatus === NECallStatus.ACCEPT && state.timeCount > 0) {
      const minutes = Math.floor(state.timeCount / 60);
      const seconds = state.timeCount % 60;
      this.callDuration = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    } else {
      this.callDuration = '00:00';
    }
  }

  // ==================== 状态判断 ====================

  private isCallerWaiting(): boolean {
    return this.isCaller && this.callStatusEnum === NECallStatus.WAITING;
  }

  private isCalleeWaiting(): boolean {
    return !this.isCaller && this.callStatusEnum === NECallStatus.WAITING;
  }

  private isConnected(): boolean {
    return this.callStatusEnum === NECallStatus.ACCEPT;
  }

  private isWaiting(): boolean {
    return this.callStatusEnum === NECallStatus.WAITING;
  }

  /**
   * 检查远程用户摄像头是否可用
   * 使用 @State 变量以确保状态变化时能触发 UI 更新
   * @returns true 表示远程摄像头打开，false 表示远程摄像头关闭
   */
  private isRemoteVideoAvailable(): boolean {
    // 使用 @State 变量而不是直接从 CallState.instance 读取，以确保状态变化时能触发 UI 更新
    console.log(`[${CallsP2PUserWidget.TAG}] isRemoteVideoAvailable: ${this.remoteUserVideoAvailable}, remoteUser=${this.remoteUserID}`);
    return this.remoteUserVideoAvailable;
  }

  // ==================== 通用组件 ====================

  /**
   * 背景遮罩层
   */
  @Builder
  BackgroundOverlay() {
    Column()
      .width('100%')
      .height('100%')
      .backgroundColor('rgba(0, 0, 0, 0.3)')
  }

  /**
   * 用户头像
   * @param size 头像大小
   * @param radius 圆角大小
   */
  @Builder
  UserAvatar(size: number, radius: number) {
    Image(this.remoteUserAvatar)
      .width(size)
      .height(size)
      .borderRadius(radius)
  }

  /**
   * 用户名文字
   */
  @Builder
  UserNameText() {
    Text(this.remoteUserName)
      .fontSize(20)
      .fontColor(Color.White)
      .fontWeight(FontWeight.Medium)
      .margin({ bottom: 8 })
  }

  /**
   * 通话状态文字（等待中显示）
   */
  @Builder
  CallStatusText() {
    if (this.callStatusText.length > 0 && !this.isConnected()) {
      Text(this.callStatusText)
        .fontSize(16)
        .fontColor('#CCCCCC')
        .margin({ top: 100, bottom: 4 })
    }
  }

  /**
   * 启动三个点闪动动画
   */
  private startDotAnimation(): void {
    this.stopDotAnimation(); // 先停止之前的动画
    // 在视频呼叫且是等待状态时启动动画（主叫或被叫都显示）
    if (this.isVideoCall && this.callStatusEnum === NECallStatus.WAITING) {
      this.dotAnimationTimer = setInterval(() => {
        this.dotAnimationIndex = (this.dotAnimationIndex + 1) % 3;
      }, 300) as number; // 每 300ms 更新一次，将 timer ID 转换为 number
    }
  }

  /**
   * 停止三个点闪动动画
   */
  private stopDotAnimation(): void {
    if (this.dotAnimationTimer !== null) {
      clearInterval(this.dotAnimationTimer);
      this.dotAnimationTimer = null;
    }
  }

  /**
   * 获取点的颜色（用于创建白色到灰色的闪动效果）
   */
  private getDotColor(index: number): string {
    // 根据当前动画索引和点的索引计算颜色
    // 创建波浪式的闪动效果：白色 -> 灰色
    const offset = (index - this.dotAnimationIndex + 3) % 3;
    if (offset === 0) {
      return '#FFFFFF'; // 当前点最亮（白色）
    } else if (offset === 1) {
      return '#999999'; // 下一个点中等亮度（中灰色）
    } else {
      return '#666666'; // 其他点较暗（深灰色）
    }
  }

  /**
   * 三个点闪动动画（用于视频呼叫等待对方接听）
   * 动画效果：白色到灰色的颜色变化
   */
  @Builder
  WaitingDotsAnimation() {
    Row() {
      ForEach([0, 1, 2], (index: number) => {
        Column()
          .width(6)
          .height(6)
          .borderRadius(3)
          .backgroundColor(this.getDotColor(index))
          .margin({ left: index === 0 ? 0 : 4 })
          .animation({
            duration: 300,
            curve: Curve.EaseInOut
          })
      })
    }
    .height(20)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: 4 })
  }

  /**
   * 通话时长文字（通话中显示）
   */
  @Builder
  CallDurationText() {
    if (this.isConnected()) {
      Text(this.callDuration)
        .fontSize(20)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
    }
  }

  // ==================== 音频通话布局 ====================

  /**
   * 音频通话背景 - 使用头像作为模糊背景
   */
  @Builder
  AudioCallBackground() {
    Stack() {
      // 头像作为背景
      Image(this.remoteUserAvatar)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
      // 半透明遮罩
      this.BackgroundOverlay()
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 音频通话用户信息区域
   */
  @Builder
  AudioCallUserInfo() {
    Column() {
      // 头像
      this.UserAvatar(72, 8)
      Blank().height(20)
      // 用户名
      this.UserNameText()
      // 通话时长不再显示在这里，改为在顶部显示（与视频通话一致）
      Blank().height(20)
      this.CallStatusText()

    }
    .width('100%')
    .height('100%')
    .padding({ top: 200 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 音频通话 - 通话中的用户信息区域（顶部简洁显示通话时长）
   */
  @Builder
  AudioCallConnectedUserInfo() {
    Column() {
      // 通话时长（顶部居中显示，与视频通话一致）
      Row() {
        Text(this.callDuration)
          .fontSize(16)
          .fontColor(Color.White)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .position({ top: 40 })
  }

  // ==================== 视频通话布局 ====================

  /**
   * 视频通话背景 - 远程用户视频或头像
   *
   * 逻辑说明：
   * - 通话中状态：
   *   * 如果本地是大画面 (isLocalViewBig = true)：
   *     - 本地摄像头打开 → 显示本地视频流
   *     - 本地摄像头关闭 → 显示本地头像
   *   * 如果远程是大画面 (isLocalViewBig = false)：
   *     - 远程摄像头打开 → 显示远程视频流
   *     - 远程摄像头关闭 → 显示远程头像
   * - 等待中状态（呼叫中/被呼叫中）：
   *   * 本地摄像头打开 → 显示本地预览视频流
   *   * 本地摄像头关闭 → 显示头像背景
   */
  @Builder
  VideoCallBackground() {
    Stack() {
      if (this.isConnected()) {
        // 通话中状态：根据 isLocalViewBig 决定显示本地还是远程
        if (this.isLocalViewBig) {
          // 本地是大画面
          if (this.isCameraOpen) {
            // 本地摄像头打开 → 显示本地视频流
            Column() {
              NERtcVideoView({
                canvasId: this._bigViewId,
                onLoad: (() => {
                  CallUILog.info(CallsP2PUserWidget.TAG, `video canvas on load (local big): ${this._bigViewId}`)
                  CallManager.instance.setupLocalView(this._bigViewId)
                }),
                onDestroy: (() => {
                  CallUILog.info(CallsP2PUserWidget.TAG, `video canvas on destroy (local big): ${this._bigViewId}`)
                  CallManager.instance.setupLocalView("")
                })
              })
            }
            .width('100%')
            .height('100%')
            .backgroundColor('#000000')
            .justifyContent(FlexAlign.Center)
          } else {
            // 本地摄像头关闭 → 显示本地头像（背景大图模糊 + 中间小图 + 昵称）
            Stack() {
              // 背景大图（模糊效果）
              Image(this.localUserAvatar)
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
                .blur(20)
              this.BackgroundOverlay()
              // 中间小头像和昵称
              Column() {
                // 小头像（72*72）
                Image(this.localUserAvatar)
                  .width(72)
                  .height(72)
                  .borderRadius(8)
                  .objectFit(ImageFit.Cover)
                // 昵称
                Text(CallState.instance.selfUser.nickname || CallState.instance.selfUser.id || '未知用户')
                  .fontSize(16)
                  .fontColor(Color.White)
                  .fontWeight(FontWeight.Medium)
                  .margin({ top: 12 })
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .alignItems(HorizontalAlign.Center)
            }
            .width('100%')
            .height('100%')
            .align(Alignment.Center)
          }
        } else {
          // 远程是大画面
          if (this.isRemoteVideoAvailable()) {
            // 远程摄像头打开 → 显示远程视频流
            Column() {
              NERtcVideoView({
                canvasId: this._bigViewId,
                onLoad: (() => {
                  CallUILog.info(CallsP2PUserWidget.TAG, `video canvas on load (remote big): ${this.remoteUserID}`)
                  CallManager.instance.setupRemoteView(this.remoteUserID, this._bigViewId)
                }),
                onDestroy: (() => {
                  CallUILog.info(CallsP2PUserWidget.TAG, `video canvas on destroy (remote big): ${this.remoteUserID}`)
                  CallManager.instance.setupRemoteView(this.remoteUserID, "")
                })
              })
            }
            .width('100%')
            .height('100%')
            .backgroundColor('#000000')
            .justifyContent(FlexAlign.Center)
          } else {
            // 远程摄像头关闭 → 显示远程头像（背景大图模糊 + 中间小图 + 昵称）
            Stack() {
              // 背景大图（模糊效果）
              Image(this.remoteUserAvatar)
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
                .blur(20)
              this.BackgroundOverlay()
              // 中间小头像和昵称
              Column() {
                // 小头像（72*72）
                Image(this.remoteUserAvatar)
                  .width(72)
                  .height(72)
                  .borderRadius(8)
                  .objectFit(ImageFit.Cover)
                // 昵称
                Text(this.remoteUserName)
                  .fontSize(16)
                  .fontColor(Color.White)
                  .fontWeight(FontWeight.Medium)
                  .margin({ top: 12 })
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .alignItems(HorizontalAlign.Center)
            }
            .width('100%')
            .height('100%')
            .align(Alignment.Center)
          }
        }
      } else {
        // 等待中状态（呼叫中/被呼叫中）
        if (this.isCameraOpen) {
          // 摄像头打开时显示本地预览视频流
          Column() {
            NERtcVideoView({
              canvasId: this._bigViewId,
              onLoad: (() => {
                console.info(`[${CallsP2PUserWidget.TAG}] video canvas on load :${this._bigViewId}`)
                CallManager.instance.setupLocalView(this._bigViewId)
                if (CallState.instance.isCameraOpen) {
                  CallManager.instance.openCamera();
                }
              }),
              onDestroy: (() => {
                console.info(`[${CallsP2PUserWidget.TAG}] video canvas on destroy :${this._bigViewId}`)
                CallManager.instance.setupLocalView("")
              })
            })
          }
          .width('100%')
          .height('100%')
          .backgroundColor($r('sys.color.black'))
          .justifyContent(FlexAlign.Center)
        } else {
          // 摄像头关闭时显示头像背景（背景大图模糊 + 中间小图 + 昵称）
          Stack() {
            // 背景大图（模糊效果）
            Image(this.remoteUserAvatar)
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)
              .blur(20)
            this.BackgroundOverlay()
            // 中间小头像和昵称
            Column() {
              // 小头像（72*72）
              Image(this.remoteUserAvatar)
                .width(72)
                .height(72)
                .borderRadius(8)
                .objectFit(ImageFit.Cover)
              // 昵称
              Text(this.remoteUserName)
                .fontSize(16)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Medium)
                .margin({ top: 12 })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .height('100%')
          .align(Alignment.Center)
        }
      }
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 视频通话 - 等待中的用户信息区域
   */
  @Builder
  VideoCallWaitingUserInfo() {
    Column() {
      // 头像
      this.UserAvatar(72, 8)
      Blank().height(20)
      // 用户名
      this.UserNameText()
      // 状态文字或动画
      // 如果是视频呼叫且是等待状态（主叫或被叫），显示三个点闪动动画
      if (this.isVideoCall && this.callStatusEnum === NECallStatus.WAITING) {
        this.WaitingDotsAnimation()
      } else {
        // 其他情况显示文字
        this.CallStatusText()
      }
    }
    .width('100%')
    .height('100%')
    .padding({ top: 200 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 视频通话 - 通话中的用户信息区域（顶部简洁显示）
   */
  @Builder
  VideoCallConnectedUserInfo() {
    Column() {
      // 用户名和通话时长（顶部居中显示，参考语音通话的时间展示）
      Row() {
        Text(this.callDuration)
          .fontSize(16)
          .fontColor(Color.White)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .position({ top: 40 })
  }

  /**
   * 视频通话 - 小窗口视频（右上角）
   * 只在通话中显示，根据 isLocalViewBig 决定显示本地还是远程
   * - 如果本地是大画面，小窗口显示远程视频或远程头像
   * - 如果远程是大画面，小窗口显示本地视频或本地头像
   */
  @Builder
  VideoCallSmallWindow() {
    if (this.isVideoCall && this.isConnected()) {
      Stack() {
        if (this.isLocalViewBig) {
          // 本地是大画面，小窗口显示远程
          if (this.isRemoteVideoAvailable()) {
            // 远程摄像头打开 → 显示远程视频流
            NERtcVideoView({
              canvasId: this._smallViewId,
              onLoad: () => {
                CallUILog.info(CallsP2PUserWidget.TAG, `video canvas on load (remote small): ${this.remoteUserID}`)
                CallManager.instance.setupRemoteView(this.remoteUserID, this._smallViewId)
              },
              onDestroy: () => {
                CallUILog.info(CallsP2PUserWidget.TAG, `video canvas on destroy (remote small): ${this.remoteUserID}`)
                CallManager.instance.setupRemoteView(this.remoteUserID, "")
              }
            })
          } else {
            // 远程摄像头关闭 → 显示远程头像（背景大图模糊 + 中间小图）
            Stack() {
              // 背景大图（模糊效果）
              Image(this.remoteUserAvatar)
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
                .blur(20)
              // 中间小头像（48*48）
              Image(this.remoteUserAvatar)
                .width(48)
                .height(48)
                .borderRadius(8)
                .objectFit(ImageFit.Cover)
            }
            .width('100%')
            .height('100%')
            .align(Alignment.Center)
          }
        } else {
          // 远程是大画面，小窗口显示本地
          if (this.isCameraOpen) {
            // 本地摄像头打开 → 显示本地视频流
            NERtcVideoView({
              canvasId: this._smallViewId,
              onLoad: () => {
                CallUILog.info(CallsP2PUserWidget.TAG, `video canvas on load (local small): ${this._smallViewId}`)
                CallManager.instance.setupLocalView(this._smallViewId)
              },
              onDestroy: () => {
                CallUILog.info(CallsP2PUserWidget.TAG, `video canvas on destroy (local small): ${this._smallViewId}`)
                CallManager.instance.setupLocalView("")
              }
            })
          } else {
            // 本地摄像头关闭 → 显示本地头像（背景大图模糊 + 中间小图）
            Stack() {
              // 背景大图（模糊效果）
              Image(this.localUserAvatar)
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
                .blur(20)
              // 中间小头像（48*48）
              Image(this.localUserAvatar)
                .width(48)
                .height(48)
                .borderRadius(8)
                .objectFit(ImageFit.Cover)
            }
            .width('100%')
            .height('100%')
            .align(Alignment.Center)
          }
        }
      }
      .onClick(() => {
        this._refreshVideoViews();
      })
      .width(98)
      .height(211)
      .borderRadius(8)
      .backgroundColor($r('sys.color.black'))
      .clip(true)
      .position({
        right: 15,
        top: 60
      })
    }
  }

  /**
   * 小窗口内的用户信息
   */
  @Builder
  SmallWindowUserInfo() {
    Column() {
      Text(this.remoteUserName)
        .fontSize(12)
        .fontColor(Color.White)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      // 状态指示点
      Row() {
        ForEach([1, 2, 3], () => {
          Column()
            .width(3)
            .height(3)
            .borderRadius(1.5)
            .backgroundColor(Color.White)
            .margin({ right: 2 })
        })
      }
      .margin({ top: 4 })
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
    .justifyContent(FlexAlign.End)
    .backgroundColor('rgba(0, 0, 0, 0.5)')
  }

  // ==================== 场景构建器 ====================

  /**
   * 构建音频通话界面
   */
  @Builder
  buildAudioCallUI() {
    Stack() {
      // 背景
      this.AudioCallBackground()
      // 用户信息
      this.AudioCallUserInfo()
      // 通话中时，在顶部显示通话时长（与视频通话一致）
      if (this.isConnected()) {
        this.AudioCallConnectedUserInfo()
      }
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 构建视频通话 - 主叫等待中界面
   */
  @Builder
  buildVideoCallerWaitingUI() {
    Stack() {
      // 背景（头像 + 遮罩）
      this.VideoCallBackground()
      // 用户信息
      this.VideoCallWaitingUserInfo()
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 构建视频通话 - 被叫等待中界面
   */
  @Builder
  buildVideoCalleeWaitingUI() {
    Stack() {
      // 背景（显示来电者头像）
      this.VideoCallBackground()
      // 用户信息
      this.VideoCallWaitingUserInfo()
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 构建视频通话 - 通话中界面
   */
  @Builder
  buildVideoConnectedUI() {
    Stack() {
      // 远程视频背景
      this.VideoCallBackground()
      // 顶部用户信息
      this.VideoCallConnectedUserInfo()
      // 本地视频小窗口
      this.VideoCallSmallWindow()
    }
    .width('100%')
    .height('100%')
  }

  // ==================== 主构建函数 ====================

  build() {
    Stack() {
      if (this.isVideoCall) {
        // 视频通话
        if (this.isCallerWaiting()) {
          this.buildVideoCallerWaitingUI()
        } else if (this.isCalleeWaiting()) {
          this.buildVideoCalleeWaitingUI()
        } else if (this.isConnected()) {
          this.buildVideoConnectedUI()
        }
      } else {
        // 音频通话（主叫/被叫/通话中统一布局）
        this.buildAudioCallUI()
      }
    }
    .width('100%')
    .height('100%')
  }

  _refreshVideoViews() {
    CallUILog.info(CallsP2PUserWidget.TAG,
      `Refreshing video views: current isLocalViewBig=${CallState.instance.isLocalViewBig}, isCameraOpen=${this.isCameraOpen}, remoteVideoAvailable=${this.remoteUserVideoAvailable}`);
    let isLocalViewBig = CallState.instance.isLocalViewBig;

    // 先清理旧的 view 设置
    if (isLocalViewBig) {
      // 当前本地是大画面，需要先清理
      CallManager.instance.setupLocalView("");
      CallManager.instance.setupRemoteView(this.remoteUserID, "");
    } else {
      // 当前远程是大画面，需要先清理
      CallManager.instance.setupLocalView("");
      CallManager.instance.setupRemoteView(this.remoteUserID, "");
    }

    // 切换状态
    if (isLocalViewBig) {
      // 切换：本地从大画面变为小画面，远程从小画面变为大画面
      CallState.instance.isLocalViewBig = false;
      // 设置新的 view
      CallManager.instance.setupLocalView(this._smallViewId);
      CallManager.instance.setupRemoteView(this.remoteUserID, this._bigViewId);
    } else {
      // 切换：远程从大画面变为小画面，本地从小画面变为大画面
      CallState.instance.isLocalViewBig = true;
      // 设置新的 view
      CallManager.instance.setupLocalView(this._bigViewId);
      CallManager.instance.setupRemoteView(this.remoteUserID, this._smallViewId);
    }

    // 触发 UI 更新，确保显示正确的占位图（根据视频关闭状态）
    this.updateUI();
    // 通知其他组件状态已更新
    NEEventNotify.getInstance().notify(setStateEvent, {});

    CallUILog.info(CallsP2PUserWidget.TAG,
      `Refreshing video views completed: new isLocalViewBig=${CallState.instance.isLocalViewBig}`);
  }
}
