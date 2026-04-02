// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be

import { CallState } from '../impl/CallState';
import { speakingStateChangedEvent } from '../data/Constants';
import { NEEventNotify } from '../event/EventNotify';

/**
 * 说话指示器组件
 * 用于在宫格模式和放大模式中显示用户是否正在说话
 * 视觉规格来自 Figma (node-id=19276-2661)
 *
 * **视觉规格**:
 * - 整体尺寸: 24x24 px
 * - 绿色圆形背景: 24x24 px, 颜色 #17C77C
 * - 声波图标: 18x18 px, 白色, 居中 (offset 3px)
 *
 * **实现说明**:
 * 组件内部订阅说话状态事件，实现局部更新，避免整个 item 重新渲染
 *
 * @since 2.0.0
 * @since 2.1.0 改为内部订阅事件，支持局部更新
 *
 * @example
 * ```typescript
 * SpeakingIndicator({ accId: participant.accId })
 *   .margin({ left: 8 })
 * ```
 */
@Component
export struct SpeakingIndicator {
  /**
   * 用户账号 ID，用于查询说话状态
   * @since 2.1.0
   */
  @Prop accId: string = '';

  /**
   * 是否正在说话（内部状态，通过事件更新）
   * @since 2.1.0
   */
  @State private isSpeaking: boolean = false;

  private speakingCallback = () => {
    this.updateSpeakingState();
  }

  aboutToAppear(): void {
    // 初始化状态
    this.updateSpeakingState();
    // 订阅说话状态变化事件
    NEEventNotify.getInstance().register(speakingStateChangedEvent, this.speakingCallback);
  }

  aboutToDisappear(): void {
    NEEventNotify.getInstance().unregister(speakingStateChangedEvent, this.speakingCallback);
  }

  private updateSpeakingState(): void {
    if (this.accId) {
      this.isSpeaking = CallState.instance.isSpeaking(this.accId);
    }
  }

  build() {
    if (this.isSpeaking) {
      Stack({ alignContent: Alignment.Center }) {
        // 24x24px 绿色圆形背景 (Figma Ellipse33)
        Circle()
          .width(24)
          .height(24)
          .fill('#17C77C')

        // 18x18px 声波图标 (Figma Intersect)
        // 注意: SVG 已包含白色填充，不要使用 fillColor 覆盖
        Image($r('app.media.ic_speaking'))
          .width(18)
          .height(18)
      }
      .width(24)
      .height(24)
    }
  }
}
