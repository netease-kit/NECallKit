// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit

// MARK: - Layout constants

private let kBannerWindowHeight: CGFloat = 92.0
private let kBannerWindowTopOffset: CGFloat = 54.0
private let kBannerWindowHorizontalMargin: CGFloat = 12.0
private let kBannerAnimationDuration: TimeInterval = 0.3

// MARK: - NEIncomingCallBannerWindow

/// Flutter iOS 层来电横幅 UIWindow 管理器（单例）
///
/// 负责：
/// 1. 创建专用 UIWindow 展示来电横幅
/// 2. 滑入/滑出动画
/// 3. 监听 NEFlutterCancelIncomingBanner 通知自动关闭横幅
class NEIncomingCallBannerWindow: NSObject {

  // MARK: - Singleton

  @objc static let shared = NEIncomingCallBannerWindow()

  // MARK: - Private properties

  private var bannerWindow: UIWindow?
  private var bannerVC: NEIncomingCallBannerViewController?
  private var cancelObserver: NSObjectProtocol?

  private override init() {
    super.init()
    observeCancelNotification()
  }

  deinit {
    if let obs = cancelObserver {
      NotificationCenter.default.removeObserver(obs)
    }
  }

  // MARK: - Public API

  /// 展示来电横幅
  @objc func show(callerId: String,
                  displayName: String,
                  avatarUrl: String?,
                  callType: Int,
                  onAccept: @escaping () -> Void,
                  onReject: @escaping () -> Void,
                  onBodyTap: @escaping () -> Void) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }

      // 若已在展示，先移除旧窗口
      if self.bannerWindow != nil {
        self._dismissWindowOnly(animated: false)
      }

      NEFLTCallUIKitLog.infoLog("NEIncomingCallBannerWindow",
                                desc: "show callerId=\(callerId) callType=\(callType)")

      // 创建 ViewController
      let vc = NEIncomingCallBannerViewController(
        callerId: callerId,
        displayName: displayName,
        avatarUrl: avatarUrl,
        callType: callType
      )
      self.bannerVC = vc

      // 绑定按钮回调（dismiss 后再执行外部回调）
      vc.onAccept = { [weak self] in
        self?._dismissWindowOnly(animated: true)
        onAccept()
      }
      vc.onReject = { [weak self] in
        self?._dismissWindowOnly(animated: true)
        onReject()
      }
      vc.onBodyTap = { [weak self] in
        self?._dismissWindowOnly(animated: true)
        onBodyTap()
      }

      // 创建专用 UIWindow
      let window = self.createBannerWindow()
      window.rootViewController = vc
      self.bannerWindow = window

      // 初始位置（屏幕上方）→ 滑入动画
      let screenWidth = UIScreen.main.bounds.width
      let bannerWidth = screenWidth - kBannerWindowHorizontalMargin * 2
      let finalFrame = CGRect(x: kBannerWindowHorizontalMargin,
                              y: kBannerWindowTopOffset,
                              width: bannerWidth,
                              height: kBannerWindowHeight)
      let initialFrame = CGRect(x: finalFrame.origin.x,
                                y: -kBannerWindowHeight,
                                width: finalFrame.width,
                                height: finalFrame.height)
      window.frame = initialFrame
      window.isHidden = false

      UIView.animate(withDuration: kBannerAnimationDuration,
                     delay: 0,
                     usingSpringWithDamping: 0.8,
                     initialSpringVelocity: 0.5,
                     options: .curveEaseOut) {
        window.frame = finalFrame
      }
    }
  }

  /// 关闭来电横幅
  @objc func dismiss() {
    DispatchQueue.main.async { [weak self] in
      guard let self = self, self.bannerWindow != nil else { return }
      NEFLTCallUIKitLog.infoLog("NEIncomingCallBannerWindow", desc: "dismiss")
      self._dismissWindowOnly(animated: true)
    }
  }

  @objc var isShowing: Bool {
    guard let w = bannerWindow else { return false }
    return !w.isHidden
  }

  // MARK: - Private

  private func _dismissWindowOnly(animated: Bool) {
    guard let window = bannerWindow else { return }
    bannerWindow = nil
    bannerVC = nil

    if animated {
      let dismissFrame = CGRect(x: window.frame.origin.x,
                                y: -kBannerWindowHeight,
                                width: window.frame.width,
                                height: window.frame.height)
      UIView.animate(withDuration: kBannerAnimationDuration,
                     animations: { window.frame = dismissFrame },
                     completion: { _ in window.isHidden = true })
    } else {
      window.isHidden = true
    }
  }

  private func createBannerWindow() -> UIWindow {
    var window: UIWindow?

    if #available(iOS 13.0, *) {
      for scene in UIApplication.shared.connectedScenes {
        if let windowScene = scene as? UIWindowScene,
           (windowScene.activationState == .foregroundActive ||
            windowScene.activationState == .foregroundInactive) {
          window = UIWindow(windowScene: windowScene)
          break
        }
      }
    }

    if window == nil {
      window = UIWindow()
    }

    window!.windowLevel = UIWindow.Level.statusBar
    window!.backgroundColor = .clear
    window!.clipsToBounds = true
    window!.layer.cornerRadius = 10.0
    return window!
  }

  private func observeCancelNotification() {
    cancelObserver = NotificationCenter.default.addObserver(
      forName: NEFlutterIncomingBannerHandler.cancelIncomingBannerNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      NEFLTCallUIKitLog.infoLog("NEIncomingCallBannerWindow", desc: "dismiss via cancelNotification")
      self?._dismissWindowOnly(animated: true)
    }
  }
}
