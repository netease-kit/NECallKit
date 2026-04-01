// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// 来电 UI 配置
class NECallUIConfig {
  /// 是否开启来电横幅模式。默认 false。
  /// Android 端驱动已有原生实现（IncomingFloatView.java）；
  /// iOS 端触发新建的原生横幅视图。
  bool enableIncomingBanner;

  NECallUIConfig({
    this.enableIncomingBanner = false,
  });
}
