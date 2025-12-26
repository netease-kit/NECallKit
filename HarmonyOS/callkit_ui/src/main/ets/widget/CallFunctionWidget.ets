// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { CallState } from '../impl/CallState';
import { CallManager } from '../impl/CallManager';
import { NECallType, NECallStatus, NECallRole, NECamera } from '../CallDefine';
import { setStateEvent } from '../data/Constants';
import { NEEventNotify } from '../event/EventNotify';
import common from '@ohos.app.ability.common';

/**
 * Resource 对象接口，用于访问资源ID
 */
interface ResourceWithId {
  id?: number;
}

/**
 * 功能按钮组件
 * 对应 Flutter 版本的 CallsFunctionWidget
 * 负责根据通话状态显示不同的功能按钮
 * 
 * 场景分类：
 * 1. 被叫等待中 - 显示功能按钮 + 拒绝/接听按钮
 * 2. 主叫等待中 - 显示功能按钮 + 挂断按钮
 * 3. 通话中 - 显示功能按钮 + 挂断按钮
 */
@Component
export struct CallFunctionWidget {
  close: () => void = () => {};
  
  @State isMuted: boolean = false;
  @State isSpeakerOn: boolean = false;
  @State isVideoCall: boolean = false;
  @State isCameraOpen: boolean = true;
  @State isBlurBackground: boolean = false;
  @State camera: NECamera = NECamera.FRONT;
  @State isCaller: boolean = false;
  @State callStatusEnum: NECallStatus = NECallStatus.WAITING;
  @State enableBlurBackground: boolean = false;

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
      console.error(`[CallFunctionWidget] getString error:`, error);
    }
    return '';
  }

  private stateEventCallback = () => {
    this.updateState();
  }

  aboutToAppear(): void {
    this.updateState();
    NEEventNotify.getInstance().register(setStateEvent, this.stateEventCallback);
  }

  aboutToDisappear(): void {
    NEEventNotify.getInstance().unregister(setStateEvent, this.stateEventCallback);
  }

  updateState(): void {
    const state = CallState.instance;
    this.isCaller = state.selfUser.callRole === NECallRole.CALLER;
    this.isVideoCall = state.callType === NECallType.VIDEO;
    this.isCameraOpen = state.isCameraOpen;
    this.camera = state.camera;
    this.isMuted = state.isMicrophoneMute;
    this.isSpeakerOn = state.isEnableSpeaker;
    this.callStatusEnum = state.selfUser.callStatus;
    this.enableBlurBackground = state.enableBlurBackground;
  }

  // ==================== 通用按钮组件 ====================

  /**
   * 麦克风按钮
   * @param showLabel 是否显示文字标签（默认 true）
   * @param size 按钮大小（默认根据通话类型：视频64，音频72）
   */
  @Builder
  MicrophoneButton(showLabel: boolean = true, size?: number) {
    Column() {
      Image(this.isMuted ? $r('app.media.ic_mic_off') : $r('app.media.ic_mic_on'))
        .width(size ?? (this.isVideoCall ? 64 : 72))
        .height(size ?? (this.isVideoCall ? 64 : 72))
        .onClick(() => {
          if (this.isMuted) {
            CallManager.instance.openMicrophone();
          } else {
            CallManager.instance.closeMicrophone();
          }
        })
      if (showLabel) {
        Text(this.isMuted ? this.getString($r('app.string.button_mic_off')) : this.getString($r('app.string.button_mic_on')))
          .fontSize(12)
          .fontColor(Color.White)
          .margin({ top: 8 })
      }
    }
    .width(80)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 扬声器按钮（音频通话专用）
   * @param showLabel 是否显示文字标签（默认 true）
   * @param size 按钮大小（默认根据通话类型：视频64，音频72）
   */
  @Builder
  SpeakerButton(showLabel: boolean = true, size?: number) {
    Column() {
      Image(this.isSpeakerOn ? $r('app.media.ic_speaker_on') : $r('app.media.ic_speaker_off'))
        .width(size ?? (this.isVideoCall ? 64 : 72))
        .height(size ?? (this.isVideoCall ? 64 : 72))
        .onClick(() => {
          CallManager.instance.setSpeakerphoneOn(!this.isSpeakerOn);
        })
      if (showLabel) {
        Text(this.isSpeakerOn ? this.getString($r('app.string.button_speaker')) : this.getString($r('app.string.button_earpiece')))
          .fontSize(12)
          .fontColor(Color.White)
          .margin({ top: 8 })
      }
    }
    .width(80)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 摄像头按钮（视频通话专用）
   * @param showLabel 是否显示文字标签（默认 false）
   * @param size 按钮大小（默认 64）
   */
  @Builder
  CameraButton(showLabel: boolean = false, size: number = 64) {
    Column() {
      Image(this.isCameraOpen ? $r('app.media.ic_camera_on') : $r('app.media.ic_camera_off'))
        .width(size)
        .height(size)
        .onClick(() => {
          if (this.isCameraOpen) {
            CallManager.instance.closeCamera();
          } else {
            CallManager.instance.openCamera();
          }
        })
      if (showLabel) {
        Text(this.isCameraOpen ? this.getString($r('app.string.button_camera_on')) : this.getString($r('app.string.button_camera_off')))
          .fontSize(12)
          .fontColor(Color.White)
          .margin({ top: 8 })
      }
    }
    .width(80)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 翻转摄像头按钮（视频通话专用）
   * @param showLabel 是否显示文字标签（默认 false）
   * @param size 按钮大小（默认 64）
   */
  @Builder
  SwitchCameraButton(showLabel: boolean = false, size: number = 64) {
    Column() {
      Image($r('app.media.ic_switch_camera'))
        .width(size)
        .height(size)
        .onClick(() => {
          const newCamera = this.camera === NECamera.FRONT ? NECamera.BACK : NECamera.FRONT;
          CallManager.instance.switchCamera(newCamera);
        })
      if (showLabel) {
        Text(this.getString($r('app.string.button_switch_camera')))
          .fontSize(12)
          .fontColor(Color.White)
          .margin({ top: 8 })
      }
    }
    .width(80)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 模糊背景按钮（视频通话专用）
   * @param showLabel 是否显示文字标签（默认 false）
   * @param size 按钮大小（默认 64）
   */
  @Builder
  BlurBackgroundButton(showLabel: boolean = false, size: number = 64) {
    Column() {
      Image(this.isBlurBackground ? $r('app.media.ic_blur_bg_on') : $r('app.media.ic_blur_bg_off'))
        .width(size)
        .height(size)
        .onClick(() => {
          this.isBlurBackground = !this.isBlurBackground;
          CallManager.instance.setBlurBackground(this.isBlurBackground);
        })
      if (showLabel) {
        Text(this.getString($r('app.string.button_blur_background')))
          .fontSize(12)
          .fontColor(Color.White)
          .margin({ top: 8 })
      }
    }
    .width(80)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 挂断按钮
   * @param showLabel 是否显示文字标签（默认 false，音频通话中为 true）
   * @param size 按钮大小（默认根据通话类型：视频64，音频72）
   */
  @Builder
  HangupButton(showLabel: boolean = false, size?: number) {
    Column() {
      Image($r('app.media.ic_hangup'))
        .width(size ?? (this.isVideoCall ? 64 : 72))
        .height(size ?? (this.isVideoCall ? 64 : 72))
        .onClick(() => {
          CallManager.instance.hangup();
        })
      if (showLabel) {
        Text(this.getString($r('app.string.button_hangup')))
          .fontSize(12)
          .fontColor(Color.White)
          .margin({ top: 8 })
      }
    }
    .width(80)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 拒绝按钮
   * @param size 按钮大小（默认根据通话类型：视频64，音频72）
   */
  @Builder
  RejectButton(size?: number) {
    Image($r('app.media.ic_hangup'))
      .width(size ?? (this.isVideoCall ? 64 : 72))
      .height(size ?? (this.isVideoCall ? 64 : 72))
      .onClick(() => {
        CallManager.instance.reject();
      })
  }

  /**
   * 接听按钮
   * @param size 按钮大小（默认根据通话类型：视频64，音频72）
   */
  @Builder
  AcceptButton(size?: number) {
    Image($r('app.media.ic_accept'))
      .width(size ?? (this.isVideoCall ? 64 : 72))
      .height(size ?? (this.isVideoCall ? 64 : 72))
      .onClick(() => {
        CallManager.instance.accept();
      })
  }

  // ==================== 场景布局 ====================

  /**
   * 被叫等待中 - 音频通话功能按钮
   */
  @Builder
  CalleeWaitingAudioButtons() {
    Row() {
      this.MicrophoneButton()
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
    .padding({ left: 26, right: 26 })
    .margin({ bottom: 40 })
  }

  /**
   * 被叫等待中 - 视频通话功能按钮
   */
  @Builder
  CalleeWaitingVideoButtons() {
    Row() {
      this.MicrophoneButton()
      this.CameraButton()
      if (this.enableBlurBackground) {
        this.BlurBackgroundButton(true)
      } else {
        // 占位符，保持布局位置不变
        Column()
          .width(80)
          .height(80)
      }
      this.SwitchCameraButton()
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
    .padding({ left: 26, right: 26 })
    .margin({ bottom: 40 })
  }

  /**
   * 被叫等待中 - 接听/拒绝按钮
   */
  @Builder
  CalleeWaitingActionButtons() {
    Row() {
      this.RejectButton()
      this.AcceptButton()
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 48, right: 48 })
    .margin({ bottom: 40 })
  }

  /**
   * 主叫等待中/通话中 - 音频通话功能按钮（麦克风、挂断、扬声器横向均匀分布）
   */
  @Builder
  CallerOrConnectedAudioButtons() {
    Row() {
      // 麦克风按钮（左侧）
      this.MicrophoneButton(true)
      Blank().layoutWeight(1)
      // 挂断按钮（中间，显示文字标签）
      this.HangupButton(true)
      Blank().layoutWeight(1)
      // 扬声器按钮（右侧）
      this.SpeakerButton(true)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 26, right: 26 })
    .margin({ bottom: 40 })
  }

  /**
   * 视频通话中 - 功能按钮（麦克风、扬声器、摄像头）
   */
  @Builder
  VideoConnectedFunctionButtons() {
    Row() {
      this.MicrophoneButton(true)
      this.SpeakerButton(true)
      this.CameraButton(true)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
    .padding({ left: 26, right: 26 })
    .margin({ bottom: 40 })
  }

  /**
   * 视频通话中 - 背景虚化、挂断、摄像头翻转三个按钮均分（不显示文字）
   */
  @Builder
  VideoConnectedActionButtons() {
    Row() {
      // 背景虚化按钮（左侧）- 根据设置决定是否显示
      if (this.enableBlurBackground) {
        this.BlurBackgroundButton(false)
      } else {
        // 占位符，保持布局位置不变
        Column()
          .width(80)
          .height(64)
      }
      // 挂断按钮（中间）
      this.HangupButton(false)
      // 翻转摄像头按钮（右侧）
      this.SwitchCameraButton(false)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
    .padding({ left: 26, right: 26 })
    .margin({ bottom: 40 })
  }

  /**
   * 主叫等待中/通话中 - 挂断按钮（居中）
   * @param showLabel 是否显示文字标签（默认根据通话类型：音频true，视频false）
   */
  @Builder
  CenterHangupButton(showLabel?: boolean) {
    Row() {
      Blank().layoutWeight(1)
      // 如果未指定 showLabel，则根据通话类型决定：音频显示，视频不显示
      this.HangupButton(showLabel ?? !this.isVideoCall)
      Blank().layoutWeight(1)
    }
    .width('100%')
    .margin({ bottom: 40 })
  }

  // ==================== 主构建函数 ====================

  build() {
    Column() {
      // 根据角色和状态显示不同的按钮布局
      if (this.isCalleeWaiting()) {
        // 被叫等待中
        this.buildCalleeWaitingUI()
      } else if (this.isCallerWaiting()) {
        // 主叫等待中
        this.buildCallerWaitingUI()
      } else if (this.isConnected()) {
        // 通话中
        this.buildConnectedUI()
      }
    }
    .width('100%')
    .padding({ bottom: 40 })
  }

  /**
   * 判断是否为被叫等待中
   */
  private isCalleeWaiting(): boolean {
    return !this.isCaller && this.callStatusEnum === NECallStatus.WAITING;
  }

  /**
   * 判断是否为主叫等待中
   */
  private isCallerWaiting(): boolean {
    return this.isCaller && this.callStatusEnum === NECallStatus.WAITING;
  }

  /**
   * 判断是否为通话中
   */
  private isConnected(): boolean {
    return this.callStatusEnum === NECallStatus.ACCEPT;
  }

  /**
   * 构建被叫等待中的 UI
   */
  @Builder
  buildCalleeWaitingUI() {
    if (this.isVideoCall) {
      // 视频通话（被叫中）：只显示挂断按钮、接听按钮
      this.CalleeWaitingActionButtons()
    } else {
      // 音频通话（被叫中）：只显示挂断按钮、接听按钮
      this.CalleeWaitingActionButtons()
    }
  }

  /**
   * 构建主叫等待中的 UI
   */
  @Builder
  buildCallerWaitingUI() {
    if (this.isVideoCall) {
      // 视频通话（主叫中）：只显示挂断按钮，居中显示
      this.CenterHangupButton()
    } else {
      // 音频通话（呼叫中）：只显示取消按钮（挂断按钮）
      this.CenterHangupButton()
    }
  }

  /**
   * 构建通话中的 UI
   */
  @Builder
  buildConnectedUI() {
    if (this.isVideoCall) {
      // 视频通话中：显示麦克风、扬声器、摄像头按钮，下面显示挂断按钮（居中），翻转按钮在挂断按钮右边
      this.VideoConnectedFunctionButtons()
      this.VideoConnectedActionButtons()
    } else {
      // 音频通话时，挂断按钮已包含在 CallerOrConnectedAudioButtons 中
      this.CallerOrConnectedAudioButtons()
    }
  }
}
