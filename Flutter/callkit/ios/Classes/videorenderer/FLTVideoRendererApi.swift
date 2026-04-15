// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Flutter
import Foundation
import NERtcSDK

/// 视频渲染器 API 实现
///
/// 实现 Pigeon 生成的 FLTCallkitVideoRendererApi 协议，
/// 管理 FLTCallkitVideoRenderer 实例的创建、绑定和销毁。
class FLTVideoRendererApi: NSObject, FLTCallkitVideoRendererApi {

    /// 渲染器缓存 [textureId: renderer]
    private var renderers: [Int64: FLTCallkitVideoRenderer] = [:]

    /// Flutter 纹理注册器
    private weak var textureRegistry: FlutterTextureRegistry?

    /// Flutter 消息通道
    private var messenger: FlutterBinaryMessenger?

    // MARK: - FLTCallkitVideoRendererApi

    /// 创建视频渲染器
    func createVideoRendererWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> NSNumber? {
        guard let registry = textureRegistry, let messenger = messenger else {
            error.pointee = FlutterError(code: "NOT_INITIALIZED",
                                         message: "Texture registry or messenger not initialized",
                                         details: nil)
            return nil
        }

        let renderer = FLTCallkitVideoRenderer(textureRegistry: registry, messenger: messenger)
        let textureId = renderer.textureId
        renderers[textureId] = renderer

        print("FLTVideoRendererApi: createVideoRenderer - textureId=\(textureId)")
        return NSNumber(value: textureId)
    }

    /// 设置镜像
    func setMirrorTextureId(_ textureId: NSNumber, mirror: NSNumber, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> NSNumber? {
        guard let renderer = renderers[textureId.int64Value] else {
            error.pointee = FlutterError(code: "RENDERER_NOT_FOUND",
                                         message: "Renderer with textureId \(textureId) not found",
                                         details: nil)
            return NSNumber(value: -1)
        }

        renderer.setMirror(mirror.boolValue)
        print("FLTVideoRendererApi: setMirror - textureId=\(textureId), mirror=\(mirror)")
        return NSNumber(value: 0)
    }

    /// 绑定为本地视频画布
    func setupLocalVideoRendererTextureId(_ textureId: NSNumber, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> NSNumber? {
        guard let renderer = renderers[textureId.int64Value] else {
            error.pointee = FlutterError(code: "RENDERER_NOT_FOUND",
                                         message: "Renderer with textureId \(textureId) not found",
                                         details: nil)
            return NSNumber(value: -1)
        }

        // 创建视频画布配置，使用外部渲染
        let canvas = NERtcVideoCanvas()
        canvas.useExternalRender = true
        canvas.externalVideoRender = renderer

        // 使用 NERtcEngine 设置本地视频画布
        let result = NERtcEngine.shared().setupLocalVideoCanvas(canvas)

        print("FLTVideoRendererApi: setupLocalVideoRenderer - textureId=\(textureId), result=\(result)")
        return NSNumber(value: result)
    }

    /// 绑定为远端视频画布
    func setupRemoteVideoRendererUid(_ uid: NSNumber, textureId: NSNumber, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> NSNumber? {
        guard let renderer = renderers[textureId.int64Value] else {
            error.pointee = FlutterError(code: "RENDERER_NOT_FOUND",
                                         message: "Renderer with textureId \(textureId) not found",
                                         details: nil)
            return NSNumber(value: -1)
        }

        // 创建视频画布配置，使用外部渲染
        let canvas = NERtcVideoCanvas()
        canvas.useExternalRender = true
        canvas.externalVideoRender = renderer

        // 使用 NERtcEngine 设置远端视频画布
        let result = NERtcEngine.shared().setupRemoteVideoCanvas(canvas, forUserID: uid.uint64Value)

        print("FLTVideoRendererApi: setupRemoteVideoRenderer - uid=\(uid), textureId=\(textureId), result=\(result)")
        return NSNumber(value: result)
    }

    /// 释放视频渲染器
    func disposeVideoRendererTextureId(_ textureId: NSNumber, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        guard let renderer = renderers.removeValue(forKey: textureId.int64Value) else {
            error.pointee = FlutterError(code: "RENDERER_NOT_FOUND",
                                         message: "Renderer with textureId \(textureId) not found",
                                         details: nil)
            return
        }

        renderer.dispose()
        print("FLTVideoRendererApi: disposeVideoRenderer - textureId=\(textureId)")
    }
}

// MARK: - FLTAssociativeWrapper 实现

extension FLTVideoRendererApi: FLTAssociativeWrapper {
    func onAttachedToEngine(_ registrar: FlutterPluginRegistrar) {
        textureRegistry = registrar.textures()
        messenger = registrar.messenger()
        FLTCallkitVideoRendererApiSetup(registrar.messenger(), self)
        print("FLTVideoRendererApi: onAttachedToEngine")
    }

    func onDetachedFromEngine(_ registrar: FlutterPluginRegistrar) {
        // 释放所有渲染器
        for (_, renderer) in renderers {
            renderer.dispose()
        }
        renderers.removeAll()

        textureRegistry = nil
        messenger = nil
        print("FLTVideoRendererApi: onDetachedFromEngine")
    }
}
