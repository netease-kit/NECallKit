/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.p2p

import com.netease.yunxin.nertc.nertcvideocall.model.impl.state.CallState.STATE_DIALOG

internal object P2PCallFragmentInviteEntryPolicy {
    fun shouldRefreshOnFragmentReady(callState: Int): Boolean = callState == STATE_DIALOG
}
