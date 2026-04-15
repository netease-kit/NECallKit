// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Flutter
import UIKit

/// CallKit PlatformView 工厂
class FLTCallKitPlatformViewFactory: NSObject, FlutterPlatformViewFactory {
  private var messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
    let view = FLTCallKitPlatformView(
      frame: frame,
      viewIdentifier: viewId,
      arguments: args,
      binaryMessenger: messenger
    )
    return view
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
}

/// CallKit PlatformView
class FLTCallKitPlatformView: NSObject, FlutterPlatformView {
  private var _view: UIView
  private var _viewId: Int64
  private var _methodChannel: FlutterMethodChannel?

  init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger messenger: FlutterBinaryMessenger) {
    _view = UIView(frame: frame)
    _viewId = viewId

    super.init()

    // 注册到视图管理器
    FLTCallKitViewManager.shared.registerView(_view, withId: Int(viewId))

    // 设置方法通道
    _methodChannel = FlutterMethodChannel(name: "ne_call_kit/video_view_\(viewId)", binaryMessenger: messenger)
    _methodChannel?.setMethodCallHandler { [weak self] call, result in
      self?.handleMethodCall(call, result: result)
    }

    print("FLTCallKitPlatformView created: viewId=\(viewId)")
  }

  func view() -> UIView {
    _view
  }

  /// 获取视图 ID
  var viewId: Int64 {
    _viewId
  }

  /// 处理方法调用
  private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    print("FLTCallKitPlatformView: Method call - \(call.method)")
    switch call.method {
    case "destroyVideoView":
      handleDestroyVideoView(result: result)
    default:
      print("FLTCallKitPlatformView: Method not implemented - \(call.method)")
      result(FlutterMethodNotImplemented)
    }
  }

  /// 处理销毁视频视图
  private func handleDestroyVideoView(result: @escaping FlutterResult) {
    print("FLTCallKitPlatformView: Destroying video view with ID: \(_viewId)")

    // 清理方法通道
    _methodChannel?.setMethodCallHandler(nil)
    _methodChannel = nil

    // 从视图管理器中注销
    FLTCallKitViewManager.shared.unregisterView(withId: Int(_viewId))

    // 移除视图
    _view.removeFromSuperview()

    print("FLTCallKitPlatformView: Video view destroyed successfully")
    result(true)
  }

  deinit {
    // 注销视图
    FLTCallKitViewManager.shared.unregisterView(withId: Int(_viewId))
    print("FLTCallKitPlatformView deallocated: viewId=\(_viewId)")
  }
}
