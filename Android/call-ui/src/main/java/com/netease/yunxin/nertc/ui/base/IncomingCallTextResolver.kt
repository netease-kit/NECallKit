/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.base

import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.nertc.ui.R

object IncomingCallTextResolver {
    fun incomingTipRes(callType: Int, multiCallInvite: Boolean): Int {
        if (multiCallInvite) {
            return R.string.tip_invite_to_single_to_group_call
        }
        return if (callType == NECallType.VIDEO) {
            R.string.tip_invite_to_video_call
        } else {
            R.string.tip_invite_to_audio_call
        }
    }
}
