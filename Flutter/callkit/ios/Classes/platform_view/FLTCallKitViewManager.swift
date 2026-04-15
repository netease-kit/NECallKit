// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit

/// CallKit 视图管理器
class FLTCallKitViewManager {
  static let shared = FLTCallKitViewManager()

  private var _views: [Int: UIView] = [:]
  private let _lock = NSLock()

  private init() {}

  /// 注册视图
  func registerView(_ view: UIView, withId viewId: Int) {
    _lock.lock()
    defer { _lock.unlock() }

    _views[viewId] = view
    print("FLTCallKitViewManager: registered view with id \(viewId)")
  }

  /// 注销视图
  func unregisterView(withId viewId: Int) {
    _lock.lock()
    defer { _lock.unlock() }

    _views.removeValue(forKey: viewId)
    print("FLTCallKitViewManager: unregistered view with id \(viewId)")
  }

  /// 根据 ID 查找视图
  func findView(withId viewId: Int) -> UIView? {
    _lock.lock()
    defer { _lock.unlock() }

    let view = _views[viewId]
    print("FLTCallKitViewManager: found view with id \(viewId): \(view != nil)")
    return view
  }

  /// 获取所有注册的视图
  func getAllViews() -> [Int: UIView] {
    _lock.lock()
    defer { _lock.unlock() }

    return _views
  }

  /// 清空所有视图
  func clearAllViews() {
    _lock.lock()
    defer { _lock.unlock() }

    _views.removeAll()
    print("FLTCallKitViewManager: cleared all views")
  }
}
