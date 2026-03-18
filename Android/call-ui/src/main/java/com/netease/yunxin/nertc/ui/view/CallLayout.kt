/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.view

import android.content.Context
import androidx.constraintlayout.widget.ConstraintLayout
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.nertc.ui.p2p.CallUIOperationsMgr

open class CallLayout(context: Context) : ConstraintLayout(context) {

    init {
        initView()
    }

    private fun initView() {
        this.layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
        if (CallUIOperationsMgr.callType == NECallType.AUDIO) {
            addView(P2PAudioCallLayout(context), layoutParams)
        } else {
            addView(P2PVideoCallLayout(context), layoutParams)
        }
    }
}
