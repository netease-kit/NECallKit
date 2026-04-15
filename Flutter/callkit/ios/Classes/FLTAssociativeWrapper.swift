// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Flutter
import Foundation

@objc
public protocol FLTAssociativeWrapper: AnyObject {
  @objc func onAttachedToEngine(_ registrar: FlutterPluginRegistrar)
  @objc func onDetachedFromEngine(_ registrar: FlutterPluginRegistrar)
}
