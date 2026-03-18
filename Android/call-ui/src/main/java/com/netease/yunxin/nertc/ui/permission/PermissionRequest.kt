/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.permission

import android.Manifest
import android.content.Context
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.nertc.ui.R

object PermissionRequest {
    fun requestPermissions(context: Context, type: Int, callback: PermissionCallback?) {
        val title = StringBuilder().append(context.getString(R.string.ui_permission_microphone))
        val reason = StringBuilder()
        reason.append(getMicrophonePermissionHint(context))

        val permissionList: MutableList<String> = ArrayList()
        permissionList.add(Manifest.permission.RECORD_AUDIO)
        if (NECallType.VIDEO == type) {
            title.append(context.getString(R.string.ui_permission_separator))
            title.append(context.getString(R.string.ui_permission_camera))
            reason.append(getCameraPermissionHint(context))
            permissionList.add(Manifest.permission.CAMERA)
        }

        if (PermissionRequester.newInstance(*permissionList.toTypedArray()).has()) {
            callback?.onGranted()
            return
        }

        val permissionCallback: PermissionCallback = object : PermissionCallback() {
            override fun onGranted() {
                callback?.onGranted()
            }

            override fun onDenied() {
                super.onDenied()
                callback?.onDenied()
            }
        }
        val applicationInfo = context.applicationInfo
        val appName = context.packageManager.getApplicationLabel(applicationInfo).toString()
        PermissionRequester.newInstance(*permissionList.toTypedArray())
            .title(context.getString(R.string.ui_permission_title, appName, title))
            .description(reason.toString())
            .settingsTip(
                "${context.getString(R.string.ui_permission_tips, title)} $reason".trimIndent()
            )
            .callback(permissionCallback)
            .request()
    }

    fun requestCameraPermission(context: Context, callback: PermissionCallback?) {
        if (PermissionRequester.newInstance(Manifest.permission.CAMERA).has()) {
            callback?.onGranted()
            return
        }

        val permissionCallback: PermissionCallback = object : PermissionCallback() {
            override fun onGranted() {
                callback?.onGranted()
            }

            override fun onDenied() {
                super.onDenied()
                callback?.onDenied()
            }
        }

        val title = context.getString(R.string.ui_permission_camera)
        val reason = getCameraPermissionHint(context)
        val appName = context.packageManager.getApplicationLabel(context.applicationInfo).toString()

        PermissionRequester.newInstance(Manifest.permission.CAMERA)
            .title(context.getString(R.string.ui_permission_title, appName, title))
            .description(reason)
            .settingsTip(
                "${context.getString(R.string.ui_permission_tips, title)} $reason".trimIndent()
            )
            .callback(permissionCallback)
            .request()
    }

    private fun getMicrophonePermissionHint(context: Context): String {
        return context.getString(R.string.ui_permission_mic_reason)
    }

    private fun getCameraPermissionHint(context: Context): String {
        return context.getString(R.string.ui_permission_camera_reason)
    }
}
