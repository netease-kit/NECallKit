/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.p2p

internal object FloatingWindowVideoPolicy {
    fun shouldHandleRemoteVideoState(boundRemoteUserId: String?, eventUserId: String?): Boolean {
        if (boundRemoteUserId.isNullOrEmpty()) {
            return true
        }
        return boundRemoteUserId == eventUserId
    }
}
