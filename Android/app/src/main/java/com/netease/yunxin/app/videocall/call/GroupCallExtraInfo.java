// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.call;

final class GroupCallExtraInfo {

  static final String AUTO_JSON =
      "{\"source\":\"callkit-demo\",\"scene\":\"group-call\",\"key\":\"extraInfo-test\",\"value\":\"testValue\"}";

  private GroupCallExtraInfo() {}

  static String valueAfterAutoFillChanged(boolean enabled, String current) {
    if (enabled) {
      return AUTO_JSON;
    }
    return AUTO_JSON.equals(current) ? "" : current;
  }

  static boolean isEditable(boolean autoFillEnabled) {
    return !autoFillEnabled;
  }

  static boolean isVisibleForCallMode(int callModeType) {
    return callModeType == CallModeType.RTC_GROUP_CALL;
  }

  static String optional(String value) {
    return value == null || value.isEmpty() ? null : value;
  }
}
