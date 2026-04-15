// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { window } from '@kit.ArkUI';
import { FloatWindowManager, FLOAT_WIN_NAME, FloatWindowUtils, FloatWindowPosition, FloatWindowConstants } from 'netease_callkit_ui';

// 媒体类型常量（与 MediaType 枚举对应）
const MEDIA_TYPE_AUDIO = 1;
const MEDIA_TYPE_VIDEO = 2;

@Entry
@Component
struct FloatWindowPage {
  @StorageLink('float_media_type') mediaType: number = MEDIA_TYPE_AUDIO;
  @StorageLink('float_remote_accid') remoteAccId: string = '';
  @StorageLink('float_remote_name') remoteName: string = '';
  @StorageLink('float_start_time') startTime: number = 0;
  @StorageProp('float_top_safe_area') topSafeArea: number = 0;
  @StorageProp('float_bottom_safe_area') bottomSafeArea: number = 0;

  // 通话计时器相关
  @State callDuration: string = '00:00';
  private timerInterval: number = -1;

  // 拖拽相关
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.All });
  private floatWin: window.Window | null = null;
  private windowPosition: FloatWindowPosition = { x: 0, y: 0 };
  private isDragging: boolean = false;

  aboutToAppear(): void {
    // 获取悬浮窗引用
    try {
      this.floatWin = window.findWindow(FLOAT_WIN_NAME);
    } catch (e) {
      // 窗口可能还未创建完成
    }
    
    // 获取初始位置
    const manager = FloatWindowManager.getInstance();
    const pos = manager.getWindowPosition();
    this.windowPosition = { x: pos.x, y: pos.y };
    
    // 启动通话计时器
    this.startTimer();
  }

  aboutToDisappear(): void {
    // 停止通话计时器
    this.stopTimer();
  }

  private startTimer(): void {
    this.updateDuration();
    this.timerInterval = setInterval(() => {
      this.updateDuration();
    }, 1000);
  }

  private stopTimer(): void {
    if (this.timerInterval !== -1) {
      clearInterval(this.timerInterval);
      this.timerInterval = -1;
    }
  }

  private updateDuration(): void {
    if (this.startTime > 0) {
      // startTime 是秒级时间戳（Flutter 端使用 millisecondsSinceEpoch ~/ 1000）
      const nowSeconds = Math.floor(Date.now() / 1000);
      const elapsed = nowSeconds - this.startTime;
      if (elapsed >= 0) {
        const minutes = Math.floor(elapsed / 60);
        const seconds = elapsed % 60;
        this.callDuration = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
      } else {
        this.callDuration = '00:00';
      }
    } else {
      this.callDuration = '通话中';
    }
  }

  build() {
    // 音频通话悬浮窗 - 必须使用容器组件作为根节点
    Stack() {
      this.AudioFloatWindow()
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 音频通话悬浮窗
   * 参考 Android FloatingView 实现：
   * - 尺寸: 72x72 vp
   * - 白色背景，圆角
   * - 电话图标（绿色）
   * - 通话时长文字（绿色）
   * - 支持拖拽移动和贴边吸附
   */
  @Builder
  AudioFloatWindow() {
    Column() {
      // 电话图标
      Image($r('app.media.ic_float_audio'))
        .width(35)
        .height(35)
        .margin({ top: 12 })

      // 通话时长
      Text(this.callDuration)
        .fontSize(12)
        .fontColor('#29CC85')
        .fontWeight(FontWeight.Medium)
        .margin({ top: 6 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .borderRadius(FloatWindowConstants.FLOAT_WIN_BORDER_RADIUS)
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .shadow({
      radius: 12,
      color: 'rgba(0, 0, 0, 0.15)',
      offsetX: 0,
      offsetY: 4
    })
    .gesture(
      // 拖拽手势
      PanGesture(this.panOption)
        .onActionStart(() => {
          this.isDragging = true;
          // 获取最新的窗口引用
          if (!this.floatWin) {
            try {
              this.floatWin = window.findWindow(FLOAT_WIN_NAME);
            } catch (e) {
              // ignore
            }
          }
        })
        .onActionUpdate((event: GestureEvent) => {
          if (this.floatWin) {
            FloatWindowUtils.dragToMove(
              event,
              this.floatWin,
              this.windowPosition,
              this.topSafeArea,
              this.bottomSafeArea
            );
            // 同步位置到 Manager
            FloatWindowManager.getInstance().updateWindowPosition(
              this.windowPosition.x,
              this.windowPosition.y
            );
          }
        })
        .onActionEnd(() => {
          this.isDragging = false;
          // 执行贴边吸附
          FloatWindowManager.getInstance().performEdgeSnap();
          // 更新本地位置
          const pos = FloatWindowManager.getInstance().getWindowPosition();
          this.windowPosition = { x: pos.x, y: pos.y };
        })
    )
    .onClick(() => {
      // 只有非拖拽状态才响应点击
      if (!this.isDragging) {
        FloatWindowManager.getInstance().onFloatWindowTapped();
      }
    })
  }
}
