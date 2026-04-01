/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.utils

import android.Manifest
import android.content.Context
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.kit.common.ui.utils.Permission

object CallPermissionUtils {

    fun requirePermissions(context: Context, callType: Int, callback: Permission.PermissionCallback) {
        val permissions: Array<String>
        if (callType == NECallType.AUDIO) {
            permissions = arrayOf(Manifest.permission.RECORD_AUDIO)
        } else {
            permissions = arrayOf(Manifest.permission.RECORD_AUDIO, Manifest.permission.CAMERA)
        }

        Permission.requirePermissions(context, *permissions)
            .request(callback)
    }
}
