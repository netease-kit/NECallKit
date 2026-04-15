/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.flutter.plugins.callkit

import android.content.Intent
import com.netease.yunxin.flutter.plugins.callkit.videorenderer.VideoRendererPlatform
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry

/** CallkitPlugin */
class CallkitPlugin : FlutterPlugin, ActivityAware {
    companion object {
        const val TAG = "CallkitPlugin"
    }

    private val activityResultLauncher = ActivityResultLauncher()

    private val platforms = listOf(
        CallKitPlatform(),
        GroupCallKitPlatform()
    )

    private val videoRendererPlatform = VideoRendererPlatform()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        platforms.forEach { it.onAttachedToEngine(flutterPluginBinding) }
        videoRendererPlatform.onAttachedToEngine(flutterPluginBinding)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        platforms.forEach { it.onDetachedFromEngine(binding) }
        videoRendererPlatform.onDetachedFromEngine(binding)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityResultLauncher.onAttachedToActivity(binding)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityResultLauncher.onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityResultLauncher.onDetachedFromActivity()
    }

    override fun onDetachedFromActivity() {
        activityResultLauncher.onDetachedFromActivity()
    }
}

class ActivityResultLauncher : PluginRegistry.ActivityResultListener {

    private var activityBinding: ActivityPluginBinding? = null
    private val resultCallbacks = hashSetOf<PluginRegistry.ActivityResultListener>()

    internal fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        binding.addActivityResultListener(this)
    }

    internal fun onDetachedFromActivity() {
        activityBinding!!.removeActivityResultListener(this)
        activityBinding = null
    }

    fun launch(intent: Intent, requestCode: Int): Boolean {
        val act = activityBinding?.activity
        if (act != null) {
            act.startActivityForResult(intent, requestCode)
            return true
        }
        return false
    }

    fun addActivityResultListener(listener: PluginRegistry.ActivityResultListener) {
        resultCallbacks.add(listener)
    }

    fun removeActivityResultListener(listener: PluginRegistry.ActivityResultListener) {
        resultCallbacks.remove(listener)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        return resultCallbacks.any { listener ->
            listener.onActivityResult(requestCode, resultCode, data)
        }
    }
}
