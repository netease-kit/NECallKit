/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.permission

import android.Manifest
import com.netease.yunxin.kit.call.p2p.model.NECallType

internal object CallMediaPermissionPolicy {

    fun requiresCameraPermission(callType: Int, multiCallInvite: Boolean): Boolean {
        return callType == NECallType.VIDEO || multiCallInvite
    }

    fun permissionRequestCallType(callType: Int, multiCallInvite: Boolean): Int {
        return if (requiresCameraPermission(callType, multiCallInvite)) {
            NECallType.VIDEO
        } else {
            NECallType.AUDIO
        }
    }

    fun requiredPermissions(callType: Int, multiCallInvite: Boolean): List<String> {
        return if (requiresCameraPermission(callType, multiCallInvite)) {
            listOf(Manifest.permission.RECORD_AUDIO, Manifest.permission.CAMERA)
        } else {
            listOf(Manifest.permission.RECORD_AUDIO)
        }
    }
}
