// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

/// 接口链接器
class FLTLinker {
  private var interfaceItems: [FLTAssociativeWrapper] = [
    FLTCallkit(),
    FLTGroupCallkit(),
    FLTVideoRendererApi(),
  ]

  func onAttachedToEngine(_ registrar: FlutterPluginRegistrar) {
    interfaceItems.forEach { $0.onAttachedToEngine(registrar) }
  }

  func onDetachedToEngine(_ registrar: FlutterPluginRegistrar) {
    interfaceItems.forEach { $0.onDetachedFromEngine(registrar) }
  }
}
