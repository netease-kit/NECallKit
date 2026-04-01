// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit

/// Flutter iOS 层来电横幅处理器
///
/// 负责：
/// 1. 存储 Dart 层通过方法通道传入的 enable flag
/// 2. 在 flag 为 true 时，当收到来电时展示横幅视图
///
/// 展示逻辑由 NEWindowManager 中的 showIncomingBanner() 驱动；
/// 若 iOS 平台横幅视图（NEIncomingCallBannerWindow）已实现，
/// 可在此处调用其展示方法。
@objc public class NEFlutterIncomingBannerHandler: NSObject {
  private static var isEnabled: Bool = false

  /// 通知名：Flutter 层请求取消来电横幅
  @objc public static let cancelIncomingBannerNotification = Notification.Name("NEFlutterCancelIncomingBanner")

  @objc public static func setEnabled(_ enable: Bool) {
    isEnabled = enable
    NEFLTCallUIKitLog.infoLog("NEFlutterIncomingBannerHandler", desc: "setEnabled: \(enable)")
  }

  @objc public static func getEnabled() -> Bool {
    return isEnabled
  }

  /// 展示来电横幅（在 isEnabled 为 true 时调用）
  ///
  /// - Parameters:
  ///   - callerId: 来电方账号 ID
  ///   - displayName: 来电方昵称
  ///   - avatarUrl: 来电方头像 URL
  ///   - callType: 通话类型（音频/视频）
  @objc public static func showIncomingBanner(callerId: String, displayName: String, avatarUrl: String?, callType: Int) {
    guard isEnabled else {
      NEFLTCallUIKitLog.infoLog("NEFlutterIncomingBannerHandler", desc: "showIncomingBanner skipped, banner not enabled")
      return
    }
    NEFLTCallUIKitLog.infoLog("NEFlutterIncomingBannerHandler", desc: "showIncomingBanner callerId=\(callerId), callType=\(callType)")
    // 若 NEIncomingCallBannerWindow（T015）已实现，在此调用展示逻辑：
    // NEIncomingCallBannerWindow.shared.show(callerId: callerId, displayName: displayName, avatarUrl: avatarUrl, callType: callType)
    //
    // 当前阶段：enable flag 已存储，等待 T015 完成后接入具体展示实现。
  }

  /// 隐藏来电横幅
  ///
  /// 发出 NEFlutterCancelIncomingBanner 通知，由宿主 App 中的
  /// NERtcCallUIKit 层监听并调用 NEIncomingCallBannerWindow.sharedInstance dismiss。
  /// 注意：iOS 原生层已通过 NECallEngineDelegate.onCallEnd: 自动关闭横幅（T030），
  /// 此处为 Flutter 侧的双保险调用。
  @objc public static func dismissIncomingBanner() {
    NEFLTCallUIKitLog.infoLog("NEFlutterIncomingBannerHandler", desc: "dismissIncomingBanner")
    NotificationCenter.default.post(name: cancelIncomingBannerNotification, object: nil)
  }
}
