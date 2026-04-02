// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { CallState } from '../impl/CallState';
import { CallManager } from '../impl/CallManager';
import { NECallType, NECallStatus, NECallRole, NECamera, NECallScene } from '../CallDefine';
import { Constants, setStateEvent, setStateEventRefreshTiming } from '../data/Constants';
import { NEEventNotify } from '../event/EventNotify';
import { CallsP2PUserWidget } from './CallP2PUserWidget';
import { CallFunctionWidget } from './CallFunctionWidget';
import { CallGridWidget } from './CallGridWidget';
import { GroupCallIncomingWidget } from './GroupCallIncomingWidget';
import { NetworkStatusWidget, NetworkStatus } from './NetworkStatusWidget';
import { CallUILog } from '../utils/CallUILog';
import router from '@ohos.router';

/**
 * 通话组件
 *
 * 支持两种模式：
 * 1. 单人通话 (P2P) - 使用 CallsP2PUserWidget
 * 2. 多人通话 (Group) - 使用 CallGridWidget（支持宫格和放大模式动画）
 *
 * @since 2.0.0 支持群呼多人通话模式
 * @since 2.1.0 放大模式动画整合到 CallGridWidget 中（参考 Android GroupCallGridLayout）
 */
@Component
export struct CallMainWidget {
  private static readonly TAG = 'CallMainWidget';

  close: () => void = () => {};

  @State isMultiPerson: boolean = false;

  /** 网络状态 */
  @State networkStatus: NetworkStatus = NetworkStatus.NORMAL;
  /** 麦克风静音状态 */
  @State isMicrophoneMute: boolean = false;
  /** 扬声器开启状态 */
  @State isEnableSpeaker: boolean = false;
  /** 摄像头开启状态 */
  @State isCameraOpen: boolean = true;
  /** 当前重连尝试次数 */
  @State reconnectAttempt: number = 0;
  /** 最大重连次数 */
  @State maxReconnectAttempts: number = 3;

  /** 模糊背景头像 URL */
  @State blurBackgroundAvatar: string = '';

  /** 通话状态文字 */
  @State callStatusText: string = '等待接听';
  /** 是否已接通 */
  @State isConnected: boolean = false;
  /** 是否是被叫来电状态 */
  @State isCalleeIncoming: boolean = false;
  /** 是否是主叫方 */
  @State isCaller: boolean = false;
  /** 摄像头按钮是否可用（群呼主叫需要有人接听后才能开启摄像头） */
  @State isCameraButtonEnabled: boolean = true;
  private setStateCallBack = () => {
    this.updateMultiPersonState();
    this.updateCallStatus();
    this.updateControlButtonStates();
    this.updateBlurBackgroundAvatar();
  }

  private refreshTimingCallback = () => {
    this.updateCallStatus();
  }

  aboutToAppear(): void {
    NEEventNotify.getInstance().register(setStateEvent, this.setStateCallBack);
    NEEventNotify.getInstance().register(setStateEventRefreshTiming, this.refreshTimingCallback);
    this.updateMultiPersonState();
    this.updateCallStatus();
    this.updateControlButtonStates();
    this.updateBlurBackgroundAvatar();
  }

  aboutToDisappear(): void {
    NEEventNotify.getInstance().unregister(setStateEvent, this.setStateCallBack);
    NEEventNotify.getInstance().unregister(setStateEventRefreshTiming, this.refreshTimingCallback);
  }

  private updateMultiPersonState(): void {
    const state = CallState.instance;
    this.isMultiPerson = (state.scene === NECallScene.GROUP_CALL || state.remoteUserList.length >= 2);
    this.isCaller = state.selfUser.callRole === NECallRole.CALLER;

    const isGroupCall = state.scene === NECallScene.GROUP_CALL;
    this.isCalleeIncoming = isGroupCall && state.isGroupCallInvited;

    CallUILog.info(CallMainWidget.TAG,
      `updateMultiPersonState: isMultiPerson=${this.isMultiPerson}, isCaller=${this.isCaller}, isCalleeIncoming=${this.isCalleeIncoming}`);
  }

  private updateControlButtonStates(): void {
    const state = CallState.instance;
    this.isMicrophoneMute = state.isMicrophoneMute;
    this.isEnableSpeaker = state.isEnableSpeaker;
    this.isCameraOpen = state.isCameraOpen;

    // 群呼主叫方：只有有人接听后才能开启摄像头
    if (state.isGroupCall() && state.selfUser.callRole === NECallRole.CALLER) {
      this.isCameraButtonEnabled = state.hasAnyoneAnswered();
    } else {
      this.isCameraButtonEnabled = true;
    }
  }

  private updateCallStatus(): void {
    const state = CallState.instance;
    const selfStatus = state.selfUser.callStatus;

    if (selfStatus === NECallStatus.ACCEPT) {
      this.isConnected = true;
      this.callStatusText = this.formatDuration(state.timeCount);
    } else {
      this.isConnected = false;
      this.callStatusText = '等待接听';
    }
  }

  private formatDuration(seconds: number): string {
    const h = Math.floor(seconds / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    const s = seconds % 60;
    if (h > 0) {
      return `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
    }
    return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
  }

  /**
   * 更新模糊背景头像
   */
  private updateBlurBackgroundAvatar(): void {
    const state = CallState.instance;
    // 群呼场景使用本地用户头像作为模糊背景
    if (state.scene === NECallScene.GROUP_CALL) {
      this.blurBackgroundAvatar = state.selfUser.avatar || Constants.defaultAvatar;
    }
  }

  setNetworkReconnecting(attempt: number, maxAttempts: number): void {
    this.networkStatus = NetworkStatus.RECONNECTING;
    this.reconnectAttempt = attempt;
    this.maxReconnectAttempts = maxAttempts;
  }

  setNetworkReconnected(): void {
    this.networkStatus = NetworkStatus.NORMAL;
    this.reconnectAttempt = 0;
  }

  setNetworkReconnectFailed(): void {
    this.networkStatus = NetworkStatus.DISCONNECTED;
  }

  setNetworkWeak(): void {
    this.networkStatus = NetworkStatus.WEAK;
  }

  build() {
    if (this.isMultiPerson) {
      if (this.isCalleeIncoming) {
        this.GroupCallIncomingLayout()
      } else {
        this.GroupCallLayout()
      }
    } else {
      this.P2PCallLayout()
    }
  }

  @Builder
  P2PCallLayout() {
    Stack({ alignContent: Alignment.Bottom }) {
      CallsP2PUserWidget({ close: this.close })
        .width('100%')
        .height('100%')

      CallFunctionWidget({ close: this.close })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }

  @Builder
  GroupCallIncomingLayout() {
    GroupCallIncomingWidget({
      onAccept: () => this.handleAcceptGroupCall(),
      onReject: () => this.handleRejectGroupCall(),
      onIgnore: () => this.handleIgnoreGroupCall()
    })
    .width('100%')
    .height('100%')
  }

  private handleAcceptGroupCall(): void {
    CallUILog.info(CallMainWidget.TAG, 'handleAcceptGroupCall');
    CallManager.instance.accept();
  }

  private handleRejectGroupCall(): void {
    CallUILog.info(CallMainWidget.TAG, 'handleRejectGroupCall');
    CallManager.instance.hangup();
  }

  /**
   * 处理忽略群呼（仅关闭 UI，不发送服务端通知）
   */
  private handleIgnoreGroupCall(): void {
    CallUILog.info(CallMainWidget.TAG, 'handleIgnoreGroupCall: 忽略群呼邀请，仅关闭本地 UI');
    CallManager.instance.ignore();
  }

  @Builder
  BlurBackground() {
    Column()
      .width('100%')
      .height('100%')
      .backgroundColor('#000000')

    Image(this.blurBackgroundAvatar || Constants.defaultAvatar)
      .width('200%')
      .height('200%')
      .objectFit(ImageFit.Cover)
      .blur(40)
      .position({ x: '-50%', y: '-50%' })

    Column()
      .width('100%')
      .height('100%')
      .backgroundColor('rgba(0, 0, 0, 0.5)')
  }

  /**
   * 多人通话布局
   *
   * CallGridWidget 自身处理宫格模式和放大模式的动画切换
   * 参考 Android GroupCallGridLayout.kt 实现
   */
  @Builder
  GroupCallLayout() {
    Stack() {
      this.BlurBackground()

      Column() {
        // 状态栏安全区域
        Column()
          .width('100%')
          .height(44)

        // 导航栏
        this.NavigationBar()

        // 主内容区域
        Column() {
          // 宫格/放大模式区域（动画由 CallGridWidget 内部处理）
          CallGridWidget({
            onCellClick: (accId: string, cellIndex: number) => {
              CallUILog.info(CallMainWidget.TAG, `onCellClick: accId=${accId}, cellIndex=${cellIndex}`);
            },
            onExitFocusMode: () => {
              CallUILog.info(CallMainWidget.TAG, 'onExitFocusMode');
            },
            onThumbnailClick: (accId: string) => {
              CallUILog.info(CallMainWidget.TAG, `onThumbnailClick: accId=${accId}`);
            }
          })
            .width('100%')
            .layoutWeight(1)

          // 网络状态提示
          if (this.networkStatus !== NetworkStatus.NORMAL) {
            NetworkStatusWidget({
              status: this.networkStatus,
              reconnectAttempt: this.reconnectAttempt,
              maxAttempts: this.maxReconnectAttempts
            })
              .margin({ bottom: 8 })
          }

          // 控制按钮区域
          this.ControlButtons()
        }
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  NavigationBar() {
    Row() {
      // 最小化按钮暂时隐藏，功能待实现
      Column()
        .width(24)
        .height(24)
        .margin({ left: 20 })

      Column() {
        Text(this.callStatusText)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)

      Image($r('app.media.ic_add_member'))
        .width(24)
        .height(24)
        .fillColor('#FFFFFF')
        .margin({ right: 20 })
        .onClick(() => {
          const callId = CallState.instance.callId;
          CallUILog.info(CallMainWidget.TAG, `点击邀请成员按钮, callId=${callId}`);
          router.pushNamedRoute({
            name: 'groupCallLaunchPage',
            params: {
              isInviteMode: true,
              callId: callId
            }
          });
        })
    }
    .width('100%')
    .height(56)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  ControlButtons() {
    Column() {
      Row() {
        // 麦克风按钮
        Column() {
          Image(this.isMicrophoneMute ? $r('app.media.ic_mic_off') : $r('app.media.ic_mic_on'))
            .width(64)
            .height(64)
            .onClick(() => {
              if (this.isMicrophoneMute) {
                CallManager.instance.openMicrophone();
              } else {
                CallManager.instance.closeMicrophone();
              }
            })

          Text(this.isMicrophoneMute ? '麦克风已关' : '麦克风已开')
            .fontSize(12)
            .fontColor('#FFFFFF')
            .margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.Center)

        // 扬声器按钮
        Column() {
          Image(this.isEnableSpeaker ? $r('app.media.ic_speaker_on') : $r('app.media.ic_speaker_off'))
            .width(64)
            .height(64)
            .onClick(() => {
              CallManager.instance.setSpeakerphoneOn(!this.isEnableSpeaker);
            })

          Text(this.isEnableSpeaker ? '扬声器已开' : '扬声器已关')
            .fontSize(12)
            .fontColor('#FFFFFF')
            .margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.Center)

        // 摄像头按钮
        Column() {
          Image(this.isCameraOpen ? $r('app.media.ic_camera_on') : $r('app.media.ic_camera_off'))
            .width(64)
            .height(64)
            .opacity(this.isCameraButtonEnabled ? 1.0 : 0.4)
            .onClick(() => {
              if (!this.isCameraButtonEnabled) {
                return;
              }
              if (this.isCameraOpen) {
                CallManager.instance.closeCamera();
              } else {
                CallManager.instance.openCamera();
              }
            })

          Text(this.isCameraOpen ? '摄像头已开' : '摄像头已关')
            .fontSize(12)
            .fontColor('#FFFFFF')
            .opacity(this.isCameraButtonEnabled ? 1.0 : 0.4)
            .margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.Center)

        // 挂断按钮
        Column() {
          Image($r('app.media.ic_hangup'))
            .width(64)
            .height(64)
            .onClick(() => {
              CallManager.instance.hangup();
            })

          Text('挂断')
            .fontSize(12)
            .fontColor('#FFFFFF')
            .margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .padding({ left: 8, right: 8 })
    }
    .width('100%')
    .padding({ top: 16, bottom: 40 })
  }
}
