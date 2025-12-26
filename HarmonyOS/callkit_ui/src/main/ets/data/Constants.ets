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




