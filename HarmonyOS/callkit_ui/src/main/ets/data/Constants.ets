// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/**
 * Constants class containing static constants
 */
export class Constants {
  /**
   * Plugin version
   */
  static readonly pluginVersion: string = '3.0.0';

  /**
   * Default avatar URL
   */
  static readonly defaultAvatar: string =
    "https://yx-web-nosdn.netease.im/common/8aaaf3fb0524d941d603f32c877d897d/default-avatar.png";

  /**
   * High blur level
   */
  static readonly blurLevelHigh: number = 3;

  /**
   * Close blur level
   */
  static readonly blurLevelClose: number = 0;
}

/**
 * Network quality hint enumeration
 */
export enum NetworkQualityHint {
  NONE = 0,
  LOCAL = 1,
  REMOTE = 2
}

/**
 * Set state event name
 */
export const setStateEvent: string = 'SET_STATE_EVENT';

/**
 * Set state event name for call received
 */
export const setStateEventOnCallReceived: string = 'SET_STATE_EVENT_ONCALLRECEIVED';

/**
 * Set state event name for call end
 */
export const setStateEventOnCallEnd: string = 'SET_STATE_EVENT_ONCALLEND';

/**
 * Set state event name for refresh timing
 */
export const setStateEventRefreshTiming: string = 'SET_STATE_EVENT_REFRESH_TIMING';

/**
 * Set state event name for call begin
 */
export const setStateEventOnCallBegin: string = 'SET_STATE_EVENT_CALLBEGIN';

/**
 * Set state event name for group call user widget refresh
 */
export const setStateEventGroupCallUserWidgetRefresh: string =
  'SET_STATE_EVENT_GROUP_CALL_USER_WIDGET_REFRESH';

/**
 * Speaking state changed event name
 * @since 2.0.0
 */
export const speakingStateChangedEvent: string = 'SPEAKING_STATE_CHANGED_EVENT';

/**
 * 动画配置常量
 * 用于宫格小画面放大过渡动画
 * @since 2.1.0
 */
export class AnimationConfig {
  /** 动画时长（毫秒）*/
  static readonly DURATION: number = 300;

  /** 动画曲线 - 使用 FastOutSlowIn 提供自然流畅的过渡效果 */
  static readonly CURVE: Curve = Curve.FastOutSlowIn;

  /** 动画期间的遮罩透明度 */
  static readonly OVERLAY_OPACITY: number = 0.3;
}

/**
 * 组件位置信息
 * 用于动画起点/终点计算
 * @since 2.1.0
 */
export class RectInfo {
  left: number = 0;
  top: number = 0;
  width: number = 0;
  height: number = 0;

  constructor(left: number = 0, top: number = 0, width: number = 0, height: number = 0) {
    this.left = left;
    this.top = top;
    this.width = width;
    this.height = height;
  }

  /** 计算中心点 X 坐标 */
  get centerX(): number {
    return this.left + this.width / 2;
  }

  /** 计算中心点 Y 坐标 */
  get centerY(): number {
    return this.top + this.height / 2;
  }
}
