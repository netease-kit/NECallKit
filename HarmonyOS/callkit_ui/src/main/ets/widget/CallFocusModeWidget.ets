// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { NERtcVideoView } from '@nertc/nertc_sdk';
import { NECallEngine } from '@yunxin/callkit';
import { CallManager } from '../impl/CallManager';
import { CallState } from '../impl/CallState';
import { CallUILog } from '../utils/CallUILog';
import { Constants } from '../data/Constants';
import { NECallType, NECamera, NECallStatus } from '../CallDefine';
import { setStateEvent } from '../data/Constants';
import { NEEventNotify } from '../event/EventNotify';
import { WaitingIndicator } from './WaitingIndicator';
import { SpeakingIndicator } from './SpeakingIndicator';

/**
 * 参与者信息（用于Focus模式渲染）
 */
class FocusParticipantInfo {
  accId: string = '';
  nickname: string = '';
  avatar: string = '';
  isLocal: boolean = false;
  isCameraOff: boolean = false;
  isMuted: boolean = false;
  isPending: boolean = false;  // 是否待接听状态

  constructor(accId: string, nickname: string, avatar: string, isLocal: boolean, isCameraOff: boolean, isMuted: boolean, isPending: boolean = false) {
    this.accId = accId;
    this.nickname = nickname;
    this.avatar = avatar;
    this.isLocal = isLocal;
    this.isCameraOff = isCameraOff;
    this.isMuted = isMuted;
    this.isPending = isPending;
  }
}

/**
 * 点击放大模式组件
 * 用于群呼场景中将某个成员的视频放大为主视图，其他成员以缩略图形式展示
 * @since 2.0.0
 *
 * @example
 * ```typescript
 * CallFocusModeWidget({
 *   focusedAccId: 'user123',
 *   onExitFocusMode: () => { this.viewMode = 'grid'; },
 *   onThumbnailClick: (accId) => { this.focusedAccId = accId; }
 * })
 * ```
 */
@Component
export struct CallFocusModeWidget {
  private static readonly TAG = 'CallFocusModeWidget';

  /** 当前被放大的成员账号ID */
  @Prop focusedAccId: string = '';
  /** 退出放大模式回调 */
  onExitFocusMode?: () => void;
  /** 缩略图点击回调（切换主视图） */
  onThumbnailClick?: (accId: string) => void;

  @State focusedParticipant: FocusParticipantInfo | null = null;
  @State thumbnailParticipants: FocusParticipantInfo[] = [];
  @State isAudioCall: boolean = false;
  // 注意: focusedIsSpeaking 已移除，SpeakingIndicator 内部订阅事件实现局部更新
  @State focusedIsPending: boolean = false;  // 单独追踪被放大用户的待接听状态

  private stateEventCallback = () => {
    this.updateParticipants();
  }

  // 注意: speakingStateCallback 已移除，SpeakingIndicator 内部订阅事件实现局部更新

  aboutToAppear(): void {
    CallUILog.info(CallFocusModeWidget.TAG, `aboutToAppear: focusedAccId=${this.focusedAccId}`);
    this.updateParticipants();
    NEEventNotify.getInstance().register(setStateEvent, this.stateEventCallback);
    // 注意: speakingStateChangedEvent 不再订阅，SpeakingIndicator 内部处理
  }

  aboutToDisappear(): void {
    NEEventNotify.getInstance().unregister(setStateEvent, this.stateEventCallback);
  }

  /**
   * 切换前后摄像头
   */
  private switchCamera(): void {
    const state = CallState.instance;
    const newCamera = state.camera === NECamera.FRONT ? NECamera.BACK : NECamera.FRONT;
    CallUILog.info(CallFocusModeWidget.TAG, `switchCamera: ${state.camera} -> ${newCamera}`);
    CallManager.instance.switchCamera(newCamera);
  }

  // 注意: updateFocusedSpeakingState 已移除，SpeakingIndicator 内部订阅事件实现局部更新

  /**
   * 更新参与者列表
   */
  private updateParticipants(): void {
    const state = CallState.instance;
    // 群呼模式下始终支持音视频，不区分 callType
    // 用户可以在通话中随时开关摄像头
    this.isAudioCall = state.isGroupCall() ? false : (state.callType === NECallType.AUDIO);

    const allParticipants: FocusParticipantInfo[] = [];

    // 添加本地用户
    allParticipants.push(new FocusParticipantInfo(
      state.selfUser.id,
      state.selfUser.nickname || '我',
      state.selfUser.avatar || Constants.defaultAvatar,
      true,
      !state.isCameraOpen,
      state.isMicrophoneMute
    ));

    // 添加远程用户
    for (const remoteUser of state.remoteUserList) {
      const isPending = remoteUser.callStatus === NECallStatus.WAITING;
      allParticipants.push(new FocusParticipantInfo(
        remoteUser.id,
        remoteUser.nickname || remoteUser.id,
        remoteUser.avatar || Constants.defaultAvatar,
        false,
        !remoteUser.videoAvailable,
        !remoteUser.audioAvailable,
        isPending
      ));
    }

    // 找到被放大的参与者
    let focusedOne = allParticipants.find(p => p.accId === this.focusedAccId);

    // 如果被放大的成员已离开，自动切换到第一个成员或退出放大模式
    if (!focusedOne) {
      if (allParticipants.length > 0) {
        focusedOne = allParticipants[0];
        CallUILog.info(CallFocusModeWidget.TAG, `Focused member left, switching to: ${focusedOne.accId}`);
      } else {
        // 没有参与者，退出放大模式
        if (this.onExitFocusMode) {
          this.onExitFocusMode();
        }
        return;
      }
    }

    this.focusedParticipant = focusedOne;
    this.focusedIsPending = focusedOne.isPending;  // 单独更新待接听状态
    // 注意: focusedIsSpeaking 已移除，SpeakingIndicator 内部订阅事件实现局部更新
    this.thumbnailParticipants = allParticipants.filter(p => p.accId !== focusedOne!.accId);

    CallUILog.info(CallFocusModeWidget.TAG,
      `updateParticipants: focused=${this.focusedParticipant?.accId}, focusedIsPending=${this.focusedIsPending}, thumbnails=${this.thumbnailParticipants.length}`);
  }

  private get mainCanvasId(): string {
    return `focus_main_${this.focusedParticipant?.accId || ''}`;
  }

  build() {
    // 5 人放大模式使用特殊布局
    if (this.thumbnailParticipants.length === 4) {
      this.FivePersonLayout()
    } else {
      Column() {
        // 主视图区域
        this.MainView()

        // 缩略图列表
        if (this.thumbnailParticipants.length > 0) {
          this.ThumbnailStrip()
        }
      }
      .width('100%')
      .height('100%')
      // 不设置背景色，让父容器的模糊背景透出
    }
  }

  /**
   * 5 人放大模式布局
   * 按 Figma 规格 (node-id=19276:2483)：
   * - 左侧大图占 2/3 宽度（正方形）
   * - 右上 2 个小图垂直排列，各占 1/3 宽度
   * - 底部 2 个小图水平排列，各占 1/3 宽度，右侧 1/3 留空
   */
  @Builder
  FivePersonLayout() {
    Column() {
      // 上半部分：左侧大图 + 右侧 2 个小图
      Row() {
        // 左侧大图（占 2/3 宽度）
        Stack({ alignContent: Alignment.BottomStart }) {
          if (this.focusedParticipant) {
            if (this.focusedIsPending || this.isAudioCall || this.focusedParticipant.isCameraOff) {
              Image(this.focusedParticipant.avatar || Constants.defaultAvatar)
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
            } else {
              FocusMainVideoView({
                canvasId: `focus_main_${this.focusedParticipant.accId}`,
                accId: this.focusedParticipant.accId,
                isLocal: this.focusedParticipant.isLocal
              })
                .width('100%')
                .height('100%')
            }
          }

          // 等待指示器
          if (this.focusedIsPending) {
            Column() {
              WaitingIndicator()
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .position({ x: 0, y: 0 })
          }

          // 昵称
          Text(this.focusedParticipant?.nickname || '未知用户')
            .fontSize(12)
            .fontColor(Color.White)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ left: 8, bottom: 8 })
        }
        .width('66.67%')
        .aspectRatio(1)
        .clip(true)
        .id('focus_main_view')
        .onClick(() => {
          if (this.onExitFocusMode) {
            this.onExitFocusMode();
          }
        })

        // 右侧 2 个小图垂直排列（占 1/3 宽度）
        Column({ space: 0 }) {
          if (this.thumbnailParticipants.length > 0) {
            this.ThumbnailItemForFivePersonSmall(this.thumbnailParticipants[0], 0)
          }
          if (this.thumbnailParticipants.length > 1) {
            this.ThumbnailItemForFivePersonSmall(this.thumbnailParticipants[1], 1)
          }
        }
        .width('33.33%')
      }
      .width('100%')

      // 下半部分：底部 2 个小图（各占 1/3 宽度）
      Row({ space: 0 }) {
        if (this.thumbnailParticipants.length > 2) {
          this.ThumbnailItemForFivePersonSmall(this.thumbnailParticipants[2], 2)
        }
        if (this.thumbnailParticipants.length > 3) {
          this.ThumbnailItemForFivePersonSmall(this.thumbnailParticipants[3], 3)
        }
      }
      .width('66.67%')  // 只占左边 2/3 宽度
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 5 人模式小缩略图
   * 宽度 1/3 屏幕，高度等于宽度（正方形）
   */
  @Builder
  ThumbnailItemForFivePersonSmall(participant: FocusParticipantInfo, index: number) {
    Stack({ alignContent: Alignment.Center }) {
      if (participant.isPending || this.isAudioCall || participant.isCameraOff) {
        Image(participant.avatar || Constants.defaultAvatar)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
      } else {
        FocusThumbnailVideoView({
          canvasId: `focus_thumb_${index}_${participant.accId}`,
          accId: participant.accId,
          isLocal: participant.isLocal
        })
          .width('100%')
          .height('100%')
      }

      // 等待指示器
      if (participant.isPending) {
        WaitingIndicator()
      }
    }
    .width('100%')
    .aspectRatio(1)
    .clip(true)
    .backgroundColor('#292933')
    .id(`thumbnail_${participant.accId}`)
    .onClick(() => {
      if (this.onThumbnailClick) {
        this.onThumbnailClick(participant.accId);
      }
    })
  }

  /**
   * 主视图（放大的视频）
   * 按 Figma 规格 (node-id=19276:2875)：
   * - 昵称在大画面左下角 (x=8px, 距底部 8px)
   * - 翻转/退出按钮在右下角 (距右边 12px, 距底部 8px)
   * - 无整行背景条
   */
  @Builder
  MainView() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 视频内容或头像
      if (this.focusedParticipant) {
        if (this.focusedIsPending || this.isAudioCall || this.focusedParticipant.isCameraOff) {
          // 待接听、音频通话或摄像头关闭时显示头像
          this.MainViewAvatar()
        } else {
          // 视频画面
          this.MainViewVideo()
        }
      }

      // 等待指示器（待接听状态）- 使用单独的 @State 变量确保响应式更新
      if (this.focusedIsPending) {
        Column() {
          WaitingIndicator()
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .position({ x: 0, y: 0 })
      }

      // 底部覆盖层：昵称在左，按钮在右（无背景条）
      Row() {
        // 左下角：昵称 + 说话指示器
        Row() {
          Text(this.focusedParticipant?.nickname || '未知用户')
            .fontSize(12)
            .fontColor(Color.White)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          // 说话指示器 (Figma node-id=19294:4845)
          // 本地用户不显示说话指示器
          if (!this.focusedParticipant?.isLocal) {
            SpeakingIndicator({ accId: this.focusedParticipant?.accId || '' })
              .margin({ left: 8 })
          }
        }

        Blank()

        // 右下角按钮：仅本地用户显示翻转摄像头
        if (this.focusedParticipant?.isLocal) {
          Image($r('app.media.ic_switch_camera'))
            .width(28)
            .height(28)
            .onClick(() => {
              this.switchCamera();
            })
        }
      }
      .width('100%')
      .padding({ left: 8, right: 12, bottom: 8 })
    }
    .width('100%')
    .aspectRatio(1)  // 保持正方形 1:1 比例
    .clip(true)
    // T006: 为主视图添加 ID，用于交换动画位置计算
    .id('focus_main_view')
    .onClick(() => {
      // 点击主视图退出放大模式
      if (this.onExitFocusMode) {
        this.onExitFocusMode();
      }
    })
  }

  /**
   * 主视图头像显示
   * 按视觉稿：头像铺满整个视图
   */
  @Builder
  MainViewAvatar() {
    Image(this.focusedParticipant?.avatar || Constants.defaultAvatar)
      .width('100%')
      .height('100%')
      .objectFit(ImageFit.Cover)  // 铺满并裁剪
  }

  /**
   * 主视图视频显示
   */
  @Builder
  MainViewVideo() {
    Column() {
      // 直接计算 canvasId，不使用 getter（ArkTS @Builder 中 private getter 可能不工作）
      FocusMainVideoView({
        canvasId: `focus_main_${this.focusedParticipant?.accId || ''}`,
        accId: this.focusedParticipant?.accId || '',
        isLocal: this.focusedParticipant?.isLocal || false
      })
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 缩略图列表
   * 按 Figma 规格 (node-id=19276:2715)：
   * - 双人放大模式：小画面 125x125px，左对齐 (left: 0)
   * - 多人放大模式：小画面可横向滚动
   */
  @Builder
  ThumbnailStrip() {
    Scroll() {
      Row({ space: 0 }) {  // 左对齐，无间距
        ForEach(this.thumbnailParticipants, (participant: FocusParticipantInfo, index: number) => {
          this.ThumbnailItem(participant, index)
        }, (participant: FocusParticipantInfo) => participant.accId)
      }
      .alignItems(VerticalAlign.Top)
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .align(Alignment.TopStart)  // 左对齐
    .width('100%')
    .height(125)  // Figma 规格：125px
    // 不设置背景色，让父容器的模糊背景透出
  }

  /**
   * 单个缩略图
   * 按 Figma 规格：
   * - 尺寸 125x125px
   * - 不显示昵称和状态图标
   */
  @Builder
  ThumbnailItem(participant: FocusParticipantInfo, index: number) {
    Stack({ alignContent: Alignment.TopStart }) {
      // 缩略图内容
      if (participant.isPending || this.isAudioCall || participant.isCameraOff) {
        // 待接听、音频通话或摄像头关闭时显示头像（铺满视图）
        Image(participant.avatar || Constants.defaultAvatar)
          .width(125)
          .height(125)
          .objectFit(ImageFit.Cover)  // 铺满并裁剪
      } else {
        // 视频缩略图 - 使用独立组件捕获参数
        FocusThumbnailVideoView({
          canvasId: `focus_thumb_${index}_${participant.accId}`,
          accId: participant.accId,
          isLocal: participant.isLocal
        })
          .width(125)
          .height(125)
      }

      // 等待指示器（待接听状态）
      if (participant.isPending) {
        Column() {
          WaitingIndicator()
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .position({ x: 0, y: 0 })
      }
    }
    .width(125)
    .height(125)
    .clip(true)
    .backgroundColor('#292933')
    // T006: 为每个缩略图组件添加唯一 ID，用于动画位置计算
    .id(`thumbnail_${participant.accId}`)
    .onClick(() => {
      // 点击缩略图切换主视图
      if (this.onThumbnailClick) {
        this.onThumbnailClick(participant.accId);
      }
    })
  }
}

/**
 * 放大模式主视图视频组件
 * 用于正确捕获 canvasId 到 @Prop，避免闭包中 this.canvasId 为 undefined
 */
@Component
struct FocusMainVideoView {
  private static readonly TAG = 'FocusMainVideoView';

  @Prop canvasId: string = '';
  @Prop accId: string = '';
  @Prop isLocal: boolean = false;

  build() {
    NERtcVideoView({
      canvasId: this.canvasId,
      onLoad: async () => {
        CallUILog.info(FocusMainVideoView.TAG, `main video onLoad: ${this.canvasId}, isLocal=${this.isLocal}`);
        if (this.isLocal) {
          // 设置本地视频画布（内部会调用 enableLocalVideo 和 startVideoPreview）
          await CallManager.instance.setupLocalView(this.canvasId);
          // 取消视频静音，开始发送视频流
          await CallManager.instance.openCamera();
        } else if (this.accId) {
          await CallManager.instance.setupRemoteView(this.accId, this.canvasId);
        }
      },
      onDestroy: () => {
        CallUILog.info(FocusMainVideoView.TAG, `main video onDestroy: ${this.canvasId}`);
        if (this.isLocal) {
          CallManager.instance.setupLocalView('');
        } else if (this.accId) {
          CallManager.instance.setupRemoteView(this.accId, '');
        }
      }
    })
  }
}

/**
 * 放大模式缩略图视频组件
 * 用于正确捕获 canvasId 到 @Prop，避免闭包中参数为 undefined
 */
@Component
struct FocusThumbnailVideoView {
  private static readonly TAG = 'FocusThumbnailVideoView';

  @Prop canvasId: string = '';
  @Prop accId: string = '';
  @Prop isLocal: boolean = false;

  build() {
    NERtcVideoView({
      canvasId: this.canvasId,
      onLoad: async () => {
        CallUILog.info(FocusThumbnailVideoView.TAG, `thumbnail video onLoad: ${this.canvasId}, isLocal=${this.isLocal}`);
        if (this.isLocal) {
          // 设置本地视频画布（内部会调用 enableLocalVideo 和 startVideoPreview）
          await CallManager.instance.setupLocalView(this.canvasId);
          // 取消视频静音
          await CallManager.instance.openCamera();
        } else {
          await CallManager.instance.setupRemoteView(this.accId, this.canvasId);
        }
      },
      onDestroy: () => {
        CallUILog.info(FocusThumbnailVideoView.TAG, `thumbnail video onDestroy: ${this.canvasId}`);
        if (this.isLocal) {
          CallManager.instance.setupLocalView('');
        } else {
          CallManager.instance.setupRemoteView(this.accId, '');
        }
      }
    })
  }
}
