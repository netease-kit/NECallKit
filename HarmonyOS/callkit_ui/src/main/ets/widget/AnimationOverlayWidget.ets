// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { Constants } from '../data/Constants';
import { CallUILog } from '../utils/CallUILog';

/**
 * 动画项状态数据
 * 用于多 item 同步动画时追踪每个参与者的动画状态
 * @since 2.1.0
 */
@Observed
export class AnimationItem {
  /** 参与者账号 ID */
  accId: string = '';
  /** 头像 URL */
  avatar: string = '';
  /** 是否为本地用户 */
  isLocal: boolean = false;

  // ========== 初始状态（动画起点）==========

  /** 起始 X 坐标 */
  startX: number = 0;
  /** 起始 Y 坐标 */
  startY: number = 0;
  /** 起始宽度 */
  startWidth: number = 0;
  /** 起始高度 */
  startHeight: number = 0;

  // ========== 目标状态（动画终点）==========

  /** 目标 X 坐标 */
  endX: number = 0;
  /** 目标 Y 坐标 */
  endY: number = 0;
  /** 目标宽度 */
  endWidth: number = 0;
  /** 目标高度 */
  endHeight: number = 0;

  // ========== 当前动画状态（@State 驱动）==========

  /** 当前 X 轴缩放比例 */
  currentScaleX: number = 1;
  /** 当前 Y 轴缩放比例 */
  currentScaleY: number = 1;
  /** 当前 X 轴位移 */
  currentTranslateX: number = 0;
  /** 当前 Y 轴位移 */
  currentTranslateY: number = 0;

  constructor(
    accId: string,
    avatar: string,
    isLocal: boolean,
    startX: number,
    startY: number,
    startWidth: number,
    startHeight: number,
    endX: number,
    endY: number,
    endWidth: number,
    endHeight: number
  ) {
    this.accId = accId;
    this.avatar = avatar;
    this.isLocal = isLocal;
    this.startX = startX;
    this.startY = startY;
    this.startWidth = startWidth;
    this.startHeight = startHeight;
    this.endX = endX;
    this.endY = endY;
    this.endWidth = endWidth;
    this.endHeight = endHeight;

    // 初始化为起始状态
    this.currentScaleX = 1;
    this.currentScaleY = 1;
    this.currentTranslateX = 0;
    this.currentTranslateY = 0;
  }

  /** 计算起始中心点 X 坐标 */
  get startCenterX(): number {
    return this.startX + this.startWidth / 2;
  }

  /** 计算起始中心点 Y 坐标 */
  get startCenterY(): number {
    return this.startY + this.startHeight / 2;
  }

  /** 计算目标中心点 X 坐标 */
  get endCenterX(): number {
    return this.endX + this.endWidth / 2;
  }

  /** 计算目标中心点 Y 坐标 */
  get endCenterY(): number {
    return this.endY + this.endHeight / 2;
  }

  /** 计算目标缩放比例 X */
  get targetScaleX(): number {
    return this.endWidth / this.startWidth;
  }

  /** 计算目标缩放比例 Y */
  get targetScaleY(): number {
    return this.endHeight / this.startHeight;
  }

  /** 计算目标位移 X（基于中心点） */
  get targetTranslateX(): number {
    return this.endCenterX - this.startCenterX;
  }

  /** 计算目标位移 Y（基于中心点） */
  get targetTranslateY(): number {
    return this.endCenterY - this.startCenterY;
  }

  /**
   * 设置到起始状态
   */
  setToStartState(): void {
    this.currentScaleX = 1;
    this.currentScaleY = 1;
    this.currentTranslateX = 0;
    this.currentTranslateY = 0;
  }

  /**
   * 设置到目标状态
   */
  setToEndState(): void {
    this.currentScaleX = this.targetScaleX;
    this.currentScaleY = this.targetScaleY;
    this.currentTranslateX = this.targetTranslateX;
    this.currentTranslateY = this.targetTranslateY;
  }
}

/**
 * 动画层组件
 * 用于多 item 同步动画，在模式切换时覆盖原布局
 *
 * 架构说明（参考 research.md Section 6）：
 * - Layer 1: 原布局 (Grid/Focus) → 动画开始时隐藏
 * - Layer 2: 动画层 (此组件) → 动画期间显示
 * - Layer 3: 目标布局 → 动画完成时显示
 *
 * @since 2.1.0
 */
@Component
export struct AnimationOverlayWidget {
  private static readonly TAG = 'AnimationOverlayWidget';

  /** 参与动画的 item 列表 */
  @Link animationItems: AnimationItem[];
  /** 是否可见 */
  @Link isVisible: boolean;

  build() {
    if (this.isVisible && this.animationItems.length > 0) {
      // 使用 Stack 作为根容器，所有动画 item 使用绝对定位
      // 必须设置 TopStart 对齐，否则 position 相对定位会出错
      Stack({ alignContent: Alignment.TopStart }) {
        ForEach(this.animationItems, (item: AnimationItem) => {
          // 每个动画 item
          this.AnimationItemView(item)
        }, (item: AnimationItem) => `${item.accId}_${item.currentScaleX}_${item.currentTranslateX}`)
      }
      .width('100%')
      .height('100%')
      .hitTestBehavior(HitTestMode.Transparent) // 允许点击穿透
    }
  }

  /**
   * 单个动画 item 视图
   * 使用绝对定位 + scale/translate 实现动画
   */
  @Builder
  AnimationItemView(item: AnimationItem) {
    // 使用头像作为动画内容（避免视频流迁移的复杂性）
    Image(item.avatar || Constants.defaultAvatar)
      .width(item.startWidth)
      .height(item.startHeight)
      .objectFit(ImageFit.Cover)
      .borderRadius(4)
      // 绝对定位到起始位置
      .position({ x: item.startX, y: item.startY })
      // 应用动画变换
      .scale({
        x: item.currentScaleX,
        y: item.currentScaleY,
        centerX: '50%',
        centerY: '50%'
      })
      .translate({
        x: item.currentTranslateX,
        y: item.currentTranslateY
      })
  }
}
