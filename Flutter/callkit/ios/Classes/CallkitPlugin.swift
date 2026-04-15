// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Flutter
import UIKit

public class SwiftCallkitPlugin: NSObject, FlutterPlugin {
  private var linker: FLTLinker?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SwiftCallkitPlugin()
    instance.linker = FLTLinker()
    instance.linker?.onAttachedToEngine(registrar)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    linker?.onDetachedToEngine(registrar)
    linker = nil
  }
}
