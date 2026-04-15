/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.flutter.plugins.callkit.videorenderer

import com.netease.lava.nertc.sdk.NERtcEx
import com.netease.lava.webrtc.EglBase
import com.netease.yunxin.flutter.plugins.callkit.pigeon.Pigeon
import com.netease.yunxin.kit.alog.ALog
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.view.TextureRegistry

/**
 * 视频渲染器 API 实现
 *
 * 管理 Flutter Texture 的创建、绑定和销毁
 */
class VideoRendererApiImpl(
    private val textureRegistry: TextureRegistry,
    private val messenger: BinaryMessenger
) : Pigeon.CallkitVideoRendererApi {

    companion object {
        private const val TAG = "VideoRendererApi"

        /** 单例：共享的 EGL 上下文包装器 */
        private var eglBase: EglBase? = null

        /** 获取或创建共享的 EGL 上下文包装器（供 NERtc SDK 配置使用） */
        fun getSharedEglContextWrapper(): EglBase {
            if (eglBase == null) {
                eglBase = EglBase.create()
                ALog.i(TAG, "getSharedEglContextWrapper: created eglBase=${eglBase.hashCode()}")
            } else {
                ALog.i(TAG, "getSharedEglContextWrapper: reused eglBase=${eglBase.hashCode()}")
            }
            return eglBase!!
        }

        fun getEglBaseContext(): EglBase.Context? {
            val context = getSharedEglContextWrapper().eglBaseContext
            ALog.i(TAG, "getEglBaseContext: context=${context?.hashCode()}")
            return context
        }

        /** 释放共享的 EGL 上下文（在 release 时调用） */
        fun releaseSharedEglContext() {
            if (eglBase != null) {
                ALog.i(TAG, "releaseSharedEglContext: releasing eglBase=${eglBase?.hashCode()}")
            } else {
                ALog.i(TAG, "releaseSharedEglContext: skip, eglBase already null")
            }
            eglBase?.release()
            eglBase = null
            ALog.i(TAG, "releaseSharedEglContext: done")
        }
    }

    private val renderers = mutableMapOf<Long, CallkitFlutterVideoRenderer>()

    /**
     * 创建视频渲染器，返回 textureId
     */
    override fun createVideoRenderer(): Long {
        ALog.i(TAG, "createVideoRenderer")
        return try {
            val entry = textureRegistry.createSurfaceTexture()
            val eglContext = getEglBaseContext()
            val renderer = CallkitFlutterVideoRenderer(messenger, entry, eglContext)
            renderers[entry.id()] = renderer
            ALog.i(TAG, "createVideoRenderer success: textureId=${entry.id()}, renderer=${renderer.hashCode()}, renderersSize=${renderers.size}, eglContext=${eglContext?.hashCode()}")
            entry.id()
        } catch (e: Exception) {
            ALog.e(TAG, "createVideoRenderer error: ${e.message}")
            -1L
        }
    }

    /**
     * 设置镜像
     */
    override fun setMirror(textureId: Long, mirror: Boolean): Long {
        ALog.i(TAG, "setMirror: textureId=$textureId, mirror=$mirror")
        return try {
            val renderer = renderers[textureId]
            if (renderer != null) {
                renderer.setMirror(mirror)
                0L
            } else {
                ALog.e(TAG, "setMirror: renderer not found for textureId=$textureId")
                -1L
            }
        } catch (e: Exception) {
            ALog.e(TAG, "setMirror error: ${e.message}")
            -1L
        }
    }

    /**
     * 绑定为本地视频画布
     */
    override fun setupLocalVideoRenderer(textureId: Long): Long {
        ALog.i(TAG, "setupLocalVideoRenderer: textureId=$textureId, hasRenderer=${renderers.containsKey(textureId)}, renderersSize=${renderers.size}")
        return try {
            val renderer = renderers[textureId]
            if (renderer != null) {
                val ret = NERtcEx.getInstance().setupLocalVideoCanvas(renderer)
                ALog.i(TAG, "setupLocalVideoRenderer result: $ret, renderer=${renderer.hashCode()}")
                ret.toLong()
            } else {
                ALog.e(TAG, "setupLocalVideoRenderer: renderer not found for textureId=$textureId")
                -1L
            }
        } catch (e: Exception) {
            ALog.e(TAG, "setupLocalVideoRenderer error: ${e.message}")
            -1L
        }
    }

    /**
     * 绑定为远端视频画布
     */
    override fun setupRemoteVideoRenderer(uid: Long, textureId: Long): Long {
        ALog.i(TAG, "setupRemoteVideoRenderer: uid=$uid, textureId=$textureId, hasRenderer=${renderers.containsKey(textureId)}, renderersSize=${renderers.size}")
        return try {
            val renderer = renderers[textureId]
            if (renderer != null) {
                val ret = NERtcEx.getInstance().setupRemoteVideoCanvas(renderer, uid)
                ALog.i(TAG, "setupRemoteVideoRenderer result: $ret, renderer=${renderer.hashCode()}")
                ret.toLong()
            } else {
                ALog.e(TAG, "setupRemoteVideoRenderer: renderer not found for textureId=$textureId")
                -1L
            }
        } catch (e: Exception) {
            ALog.e(TAG, "setupRemoteVideoRenderer error: ${e.message}")
            -1L
        }
    }

    /**
     * 释放视频渲染器
     */
    override fun disposeVideoRenderer(textureId: Long) {
        ALog.i(TAG, "disposeVideoRenderer: textureId=$textureId, renderersSizeBefore=${renderers.size}")
        try {
            val renderer = renderers.remove(textureId)
            renderer?.dispose()
            ALog.i(TAG, "disposeVideoRenderer success: renderer=${renderer?.hashCode()}, renderersSizeAfter=${renderers.size}")
        } catch (e: Exception) {
            ALog.e(TAG, "disposeVideoRenderer error: ${e.message}")
        }
    }

    /**
     * 清理所有渲染器
     */
    fun release() {
        ALog.i(TAG, "release: disposing ${renderers.size} renderers, keys=${renderers.keys}")
        renderers.values.forEach { it.dispose() }
        renderers.clear()
    }
}
