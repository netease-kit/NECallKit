/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.utils

import android.content.Context
import android.text.TextUtils
import com.netease.nimlib.sdk.NIMClient
import com.netease.yunxin.kit.call.p2p.NECallEngine
import com.netease.yunxin.kit.call.p2p.model.NEHangupReasonCode
import com.netease.yunxin.nertc.ui.R

object CallUIUtils {

    fun showToastWithCallEndReason(context: Context, reasonCode: Int) {
        when (reasonCode) {
            NEHangupReasonCode.CALLER_REJECTED -> if (!isCalled()) {
                context.getString(R.string.tip_reject_by_other).toastShort(context)
            }

            NEHangupReasonCode.BUSY -> if (!isCalled()) {
                context.getString(R.string.tip_busy_by_other).toastShort(context)
            }

            NEHangupReasonCode.CALLEE_CANCELED -> if (isCalled()) {
                context.getString(R.string.tip_cancel_by_other).toastShort(context)
            }

            NEHangupReasonCode.TIME_OUT ->
                if (!isCalled()) {
                    context.getString(R.string.tip_timeout_by_other).toastShort(context)
                }

            NEHangupReasonCode.OTHER_REJECTED -> context.getString(
                R.string.tip_other_client_other_reject
            ).toastShort(
                context
            )

            NEHangupReasonCode.OTHER_ACCEPTED -> context.getString(
                R.string.tip_other_client_other_accept
            ).toastShort(
                context
            )
        }
    }

    fun isCalled(): Boolean {
        val callInfo = NECallEngine.sharedInstance().callInfo ?: return false
        val calleeInfo = callInfo.calleeInfo ?: return false
        val currentAccount = NIMClient.getCurrentAccount() ?: return false
        return TextUtils.equals(calleeInfo.accId, currentAccount)
    }
}
