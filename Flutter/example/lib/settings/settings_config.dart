// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class SettingsConfig {
  static const defaultAvatar =
      "https://yx-web-nosdn.netease.im/common/8aaaf3fb0524d941d603f32c877d897d/default-avatar.png";
  static const version = '1.0.0';

  static String userId = '';
  static String avatar = '';
  static String nickname = '';

  static bool muteMode = false;
  static bool enableFloatWindow = true;
  static bool enableFloatWindowOutOfApp = false; // 应用外悬浮窗（画中画）- iOS 15+
  static bool showBlurBackground = false;
  static bool showIncomingBanner = false;

  static int intRoomId = 0;
  static String strRoomId = "";
  static int timeout = 30;
  static String extendInfo = "";
}
