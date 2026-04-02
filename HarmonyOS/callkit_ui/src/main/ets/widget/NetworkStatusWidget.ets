// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { CallUILog } from '../utils/CallUILog';

/**
 * 网络状态类型
 * @since 2.0.0
 */
export enum NetworkStatus {
  /** 网络正常 */
  NORMAL = 'normal',
  /** 网络较差 */
  WEAK = 'weak',
  /** 正在重连 */
  RECONNECTING = 'reconnecting',
  /** 重连失败 */
  DISCONNECTED = 'disconnected'
}

/**
 * 网络状态 UI 组件
 * 用于在通话界面显示网络状态提示
 * @since 2.0.0
 *
 * @example
 * ```typescript
 * // 正常使用
 * NetworkStatusWidget({ status: NetworkStatus.WEAK })
 *
 * // 显示重连状态
 * NetworkStatusWidget({ status: NetworkStatus.RECONNECTING, reconnectAttempt: 1, maxAttempts: 3 })
 * ```
 */
@Component
export struct NetworkStatusWidget {
  private static readonly TAG = 'NetworkStatusWidget';

  /** 网络状态 */
  @Prop status: NetworkStatus = NetworkStatus.NORMAL;

  /** 当前重连尝试次数（仅在 RECONNECTING 状态有效） */
  @Prop reconnectAttempt: number = 0;

  /** 最大重连次数 */
  @Prop maxAttempts: number = 3;

  /** 是否显示（由外部控制，默认当状态不是 NORMAL 时显示） */
  @Prop isVisible: boolean = true;

  /** 动画相关状态 */
  @State dotOpacities: number[] = [0.3, 0.3, 0.3];
  private animationIndex: number = 0;
  private timerId: number = -1;

  aboutToAppear(): void {
    CallUILog.info(NetworkStatusWidget.TAG, `aboutToAppear: status=${this.status}`);
    if (this.status === NetworkStatus.RECONNECTING) {
      this.startAnimation();
    }
  }

  aboutToDisappear(): void {
    this.stopAnimation();
  }

  /**
   * 开始重连动画
   */
  private startAnimation(): void {
    if (this.timerId !== -1) {
      return;
    }
    this.timerId = setInterval(() => {
      this.dotOpacities = [0.3, 0.3, 0.3];
      animateTo({ duration: 400 }, () => {
        const newOpacities = [...this.dotOpacities];
        newOpacities[this.animationIndex] = 1.0;
        this.dotOpacities = newOpacities;
      });
      this.animationIndex = (this.animationIndex + 1) % 3;
    }, 400);
  }

  /**
   * 停止动画
   */
  private stopAnimation(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  /**
   * 获取状态对应的图标资源
   */
  private getIconResource(): Resource | null {
    switch (this.status) {
      case NetworkStatus.WEAK:
        return $r('app.media.ic_network_weak');
      case NetworkStatus.RECONNECTING:
        return $r('app.media.ic_network_reconnecting');
      case NetworkStatus.DISCONNECTED:
        return $r('app.media.ic_network_error');
      default:
        return null;
    }
  }

  /**
   * 获取状态对应的提示文案
   */
  private getStatusText(): string {
    switch (this.status) {
      case NetworkStatus.WEAK:
        return '网络较差';
      case NetworkStatus.RECONNECTING:
        return `正在重连 (${this.reconnectAttempt}/${this.maxAttempts})`;
      case NetworkStatus.DISCONNECTED:
        return '网络断开';
      default:
        return '';
    }
  }

  /**
   * 获取状态对应的背景颜色
   */
  private getBackgroundColor(): ResourceColor {
    switch (this.status) {
      case NetworkStatus.WEAK:
        return 'rgba(255, 165, 0, 0.8)'; // 橙色
      case NetworkStatus.RECONNECTING:
        return 'rgba(255, 193, 7, 0.8)'; // 黄色
      case NetworkStatus.DISCONNECTED:
        return 'rgba(244, 67, 54, 0.8)'; // 红色
      default:
        return 'transparent';
    }
  }

  build() {
    if (this.status !== NetworkStatus.NORMAL && this.isVisible) {
      Column() {
        Row() {
          // 图标
          if (this.status === NetworkStatus.RECONNECTING) {
            // 重连状态显示动画点
            Row({ space: 4 }) {
              ForEach([0, 1, 2], (index: number) => {
                Circle()
                  .width(6)
                  .height(6)
                  .fill(Color.White)
                  .opacity(this.dotOpacities[index])
              })
            }
            .margin({ right: 8 })
          } else {
            // 其他状态显示图标
            Image(this.getIconResource())
              .width(16)
              .height(16)
              .fillColor(Color.White)
              .margin({ right: 8 })
          }

          // 提示文案
          Text(this.getStatusText())
            .fontSize(12)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor(this.getBackgroundColor())
        .borderRadius(16)
      }
      .width('100%')
      .padding({ top: 8 })
      .alignItems(HorizontalAlign.Center)
    }
  }
}
