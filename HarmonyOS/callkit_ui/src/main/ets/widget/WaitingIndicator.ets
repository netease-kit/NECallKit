// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/**
 * 等待指示器组件
 * 用于群呼场景中显示待接听成员的等待状态动画（三个点依次闪烁）
 * @since 2.0.0
 *
 * @example
 * ```typescript
 * WaitingIndicator()
 * ```
 */
@Component
export struct WaitingIndicator {
  /** 动画周期时间（毫秒） */
  private static readonly ANIMATION_CYCLE_MS: number = 1200;
  /** 单个点的动画时间 */
  private static readonly DOT_ANIMATION_MS: number = 400;
  /** 默认透明度 */
  private static readonly DEFAULT_OPACITY: number = 0.3;
  /** 高亮透明度 */
  private static readonly HIGHLIGHT_OPACITY: number = 1.0;

  /** 三个点的透明度状态 */
  @State dotOpacities: number[] = [0.3, 0.3, 0.3];

  /** 当前动画索引 */
  private animationIndex: number = 0;
  /** 定时器ID */
  private timerId: number = -1;

  aboutToAppear(): void {
    this.startAnimation();
  }

  aboutToDisappear(): void {
    this.stopAnimation();
  }

  /**
   * 开始等待动画
   * 三个点依次从左到右变亮再变暗，形成"等待中"的视觉效果
   */
  private startAnimation(): void {
    this.timerId = setInterval(() => {
      // 重置所有点为默认透明度
      this.dotOpacities = [
        WaitingIndicator.DEFAULT_OPACITY,
        WaitingIndicator.DEFAULT_OPACITY,
        WaitingIndicator.DEFAULT_OPACITY
      ];

      // 高亮当前索引的点
      animateTo({ duration: WaitingIndicator.DOT_ANIMATION_MS }, () => {
        const newOpacities = [...this.dotOpacities];
        newOpacities[this.animationIndex] = WaitingIndicator.HIGHLIGHT_OPACITY;
        this.dotOpacities = newOpacities;
      });

      // 移动到下一个点
      this.animationIndex = (this.animationIndex + 1) % 3;
    }, WaitingIndicator.DOT_ANIMATION_MS);
  }

  /**
   * 停止等待动画
   */
  private stopAnimation(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  build() {
    Row({ space: 8 }) {
      ForEach([0, 1, 2], (index: number) => {
        Circle()
          .width(8)
          .height(8)
          .fill(Color.White)
          .opacity(this.dotOpacities[index])
      })
    }
    .justifyContent(FlexAlign.Center)
  }
}
