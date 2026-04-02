// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/**
 * 来电 UI 配置接口
 */
export interface NECallUIConfig {
  /**
   * 是否开启来电横幅模式。默认 false。
   * 使用 SubWindow 覆盖层实现横幅展示。
   */
  enableIncomingBanner?: boolean;
}
