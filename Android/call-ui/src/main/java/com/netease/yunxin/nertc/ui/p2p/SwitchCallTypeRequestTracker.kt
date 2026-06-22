/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.p2p

import com.netease.yunxin.kit.call.p2p.model.NECallTypeChangeInfo
import com.netease.yunxin.nertc.nertcvideocall.model.SwitchCallState

internal class SwitchCallTypeRequestTracker {
    private var currentInfo: NECallTypeChangeInfo? = null
    private var inviteRevision = 0

    fun reset() {
        currentInfo = null
        inviteRevision = 0
    }

    fun record(info: NECallTypeChangeInfo) {
        val previous = currentInfo
        if (info.state == SwitchCallState.INVITE &&
            (previous?.state != SwitchCallState.INVITE || previous.callType != info.callType)
        ) {
            inviteRevision++
        }
        currentInfo = info
    }

    fun expireInvite(reason: String, logger: (String) -> Unit = {}) {
        val info = currentInfo
        if (info?.state != SwitchCallState.INVITE) {
            return
        }
        inviteRevision++
        currentInfo = null
        logger("expireSwitchCallTypeInvite reason:$reason revision:$inviteRevision info:$info")
    }

    fun currentInfo(): NECallTypeChangeInfo? = currentInfo

    fun currentInviteRevision(): Int = inviteRevision

    fun hasCurrentInvite(callType: Int): Boolean {
        val info = currentInfo ?: return false
        return info.state == SwitchCallState.INVITE && info.callType == callType
    }

    fun isCurrentInvite(callType: Int, revision: Int): Boolean {
        return revision == inviteRevision && hasCurrentInvite(callType)
    }
}
