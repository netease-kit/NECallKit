// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { NERtcVideoView } from '@nertc/nertc_sdk';
import { NECallEngine } from '@yunxin/callkit';
import { CallManager } from '../impl/CallManager';
import { CallState } from '../impl/CallState';
import { CallUILog } from '../utils/CallUILog';
import { Constants } from '../data/Constants';
import { NECamera } from '../CallDefine';
import { WaitingIndicator } from './WaitingIndicator';
import { SpeakingIndicator } from './SpeakingIndicator';

/**
 * 参与者单元格组件
 * 用于群呼多宫格布局中显示单个参与者的视频画面或头像
 * @since 2.0.0
 */
@Component
export struct CallParticipantCell {
  private static readonly TAG = 'CallParticipantCell';

  /** 参与者账号ID */
  @Prop accId: string = '';
  /** 参与者昵称 */
  @Prop nickname: string = '';
  /** 参与者头像URL */
  @Prop avatar: string = '';
  /** 是否为本地用户 */
  @Prop isLocal: boolean = false;
  /** 摄像头是否关闭 */
  @Prop isCameraOff: boolean = false;
  /** 麦克风是否静音 */
  @Prop isMuted: boolean = false;
  /** 是否为音频通话 */
  @Prop isAudioCall: boolean = false;
  /** 单元格索引（用于生成唯一canvasId） */
  @Prop cellIndex: number = 0;
  /** 是否为待接听状态（显示等待指示器）
   * @since 2.0.0
   */
  @Prop isPending: boolean = false;
  // 注意: isSpeaking 不再通过 @Prop 传递，SpeakingIndicator 内部订阅事件实现局部更新
  /** 是否为放大模式下的焦点画面（显示昵称、说话指示器、摄像头反转按钮）
   * @since 2.1.0
   */
  @Prop isFocused: boolean = false;
  /** 是否为缩略图（放大模式下的小图，不显示说话指示器）
   * @since 2.1.0
   */
  @Prop isThumbnail: boolean = false;
  /** 单元格点击回调（用于放大模式）
   * @param accId 被点击成员的账号ID
   * @param cellIndex 单元格索引（用于动画位置计算）
   * @since 2.0.0
   * @since 2.1.0 新增 cellIndex 参数
   */
  onCellClick?: (accId: string, cellIndex: number) => void;

  private get canvasId(): string {
    return `grid_cell_${this.cellIndex}_${this.accId}`;
  }

  /**
   * 切换前后摄像头
   */
  private switchCamera(): void {
    const state = CallState.instance;
    const newCamera = state.camera === NECamera.FRONT ? NECamera.BACK : NECamera.FRONT;
    CallUILog.info(CallParticipantCell.TAG, `switchCamera: ${state.camera} -> ${newCamera}`);
    CallManager.instance.switchCamera(newCamera);
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 视频画面或头像占位
      if (this.isPending || this.isAudioCall || this.isCameraOff) {
        // 待接听、音频通话或摄像头关闭时显示头像
        // 注意：不使用 @Builder，直接内联以响应 @Prop avatar 变化
        Image(this.avatar || Constants.defaultAvatar)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
      } else {
        // 视频通话且摄像头开启时显示视频流
        this.VideoContent()
      }

      // 等待指示器（仅在待接听状态显示）
      if (this.isPending) {
        Column() {
          WaitingIndicator()
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .position({ x: 0, y: 0 })
      }

      // 底部信息栏
      // - 宫格模式（非放大、非缩略图）：已接通用户显示说话指示器
      // - 放大模式大画面：昵称 + 说话指示器（已接通）+ 摄像头反转按钮（本地用户）
      // - 缩略图（放大模式下的小图）：不显示说话指示器（FR-034a）
      // 注意：放大模式下即使用户未接通（isPending=true）也要显示昵称
      if (this.isFocused || !this.isPending) {
        Row() {
          // 左侧：说话指示器（宫格模式）或 昵称 + 说话指示器（放大模式）
          if (this.isFocused) {
            // 放大模式大画面：显示昵称和说话指示器
            Text(this.nickname || '未知用户')
              .fontSize(12)
              .fontColor(Color.White)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .textShadow({ radius: 4, color: '#80000000', offsetX: 0, offsetY: 1 })

            // 说话指示器：仅在远端用户已接通时显示（本地用户不显示、待接听用户不会有说话状态）
            if (!this.isPending && !this.isLocal) {
              SpeakingIndicator({ accId: this.accId })
                .margin({ left: 8 })
            }
          } else if (!this.isThumbnail && !this.isLocal) {
            // FR-034: 宫格模式下显示说话指示器（已接通的远端用户）
            // FR-034a: 缩略图不显示说话指示器
            // 本地用户不显示说话指示器
            SpeakingIndicator({ accId: this.accId })
          }

          // 右侧：摄像头反转按钮（仅放大模式 + 本地用户）
          if (this.isFocused && this.isLocal) {
            Blank()
            Image($r('app.media.ic_switch_camera'))
              .width(28)
              .height(28)
              .onClick(() => {
                this.switchCamera();
              })
          }
        }
        .width('100%')
        .padding({ left: 8, right: 8, bottom: 8 })
        .justifyContent(FlexAlign.Start)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#292933')
    .borderRadius(0)  // Figma 规格：单元格无圆角，紧密贴合
    .clip(true)
    .onClick(() => {
      if (this.onCellClick) {
        this.onCellClick(this.accId, this.cellIndex);
      }
    })
  }

  /**
   * 头像占位显示
   * 按视觉稿：头像铺满整个单元格视图
   */
  @Builder
  AvatarPlaceholder() {
    Image(this.avatar || Constants.defaultAvatar)
      .width('100%')
      .height('100%')
      .objectFit(ImageFit.Cover)  // 铺满并裁剪
  }

  /**
   * 视频内容显示
   */
  @Builder
  VideoContent() {
    Column() {
      // 直接计算 canvasId，不使用 getter（ArkTS @Builder 中 private getter 可能不工作）
      VideoContentInner({
        canvasId: `grid_cell_${this.cellIndex}_${this.accId}`,
        accId: this.accId,
        isLocal: this.isLocal
      })
    }
    .width('100%')
    .height('100%')
  }

}

/**
 * 视频内容内部组件
 * 用于正确捕获 canvasId 到 @Prop，避免闭包中 this.canvasId 为 undefined
 */
@Component
struct VideoContentInner {
  private static readonly TAG = 'VideoContentInner';

  @Prop canvasId: string = '';
  @Prop accId: string = '';
  @Prop isLocal: boolean = false;

  build() {
    NERtcVideoView({
      canvasId: this.canvasId,
      onLoad: async () => {
        CallUILog.info(VideoContentInner.TAG, `video canvas onLoad: ${this.canvasId}, isLocal=${this.isLocal}, accId=${this.accId}`);
        if (this.isLocal) {
          // 设置本地视频画布（内部会调用 enableLocalVideo 和 startVideoPreview）
          await CallManager.instance.setupLocalView(this.canvasId);
          CallUILog.info(VideoContentInner.TAG, `setupLocalView completed`);

          // 取消视频静音，开始发送视频流
          await CallManager.instance.openCamera();
          CallUILog.info(VideoContentInner.TAG, `openCamera completed`);
        } else {
          await CallManager.instance.setupRemoteView(this.accId, this.canvasId);
        }
      },
      onDestroy: () => {
        CallUILog.info(VideoContentInner.TAG, `video canvas onDestroy: ${this.canvasId}, isLocal=${this.isLocal}`);
        if (this.isLocal) {
          CallManager.instance.setupLocalView('');
        } else {
          CallManager.instance.setupRemoteView(this.accId, '');
        }
      }
    })
  }
}
