/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.flutter.plugins.callkit.videorenderer

import com.netease.yunxin.flutter.plugins.callkit.pigeon.Pigeon
import com.netease.yunxin.kit.alog.ALog
import io.flutter.embedding.engine.plugins.FlutterPlugin

/**
 * 视频渲染器平台
 *
 * 管理视频渲染器 API 的生命周期
 */
class VideoRendererPlatform {

    companion object {
        private const val TAG = "VideoRendererPlatform"
    }

    private var videoRendererApi: VideoRendererApiImpl? = null

    fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        ALog.i(TAG, "onAttachedToEngine")
        videoRendererApi = VideoRendererApiImpl(
            flutterPluginBinding.textureRegistry,
            flutterPluginBinding.binaryMessenger
        )
        Pigeon.CallkitVideoRendererApi.setup(
            flutterPluginBinding.binaryMessenger,
            videoRendererApi
        )
    }

    fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        ALog.i(TAG, "onDetachedFromEngine")
        Pigeon.CallkitVideoRendererApi.setup(binding.binaryMessenger, null)
        videoRendererApi?.release()
        videoRendererApi = null
    }
}
