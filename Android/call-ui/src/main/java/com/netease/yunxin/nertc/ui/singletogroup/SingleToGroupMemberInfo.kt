/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.singletogroup

import com.netease.yunxin.kit.call.p2p.model.NECallMemberState

class SingleToGroupMemberInfo @JvmOverloads constructor(
    val accId: String,
    val name: String = "",
    val avatarUrl: String? = null,
    var enableVideo: Boolean = false,
    var enableAudio: Boolean = true,
    var focus: Boolean = false,
    var state: Int = NECallMemberState.JOINED,
    var uid: Long = 0
) {

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as SingleToGroupMemberInfo

        return accId == other.accId
    }

    override fun hashCode(): Int = accId.hashCode()

    override fun toString(): String {
        return "SingleToGroupMemberInfo(accId='$accId', name='$name', avatarUrl=$avatarUrl, " +
            "enableVideo=$enableVideo, enableAudio=$enableAudio, focus=$focus, state=$state, uid=$uid)"
    }
}
