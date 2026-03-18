/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.utils

import android.content.Context
import android.text.TextUtils
import android.widget.ImageView
import com.bumptech.glide.Glide
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.RequestCallbackWrapper
import com.netease.nimlib.sdk.nos.NosService
import com.netease.nimlib.sdk.uinfo.UserService
import com.netease.nimlib.sdk.uinfo.model.NimUserInfo
import com.netease.nimlib.sdk.uinfo.model.UserInfo
import com.netease.yunxin.kit.call.p2p.NECallEngine
import com.netease.yunxin.kit.call.p2p.model.NEHangupReasonCode
import com.netease.yunxin.nertc.ui.R
import java.util.Collections

object CallUIUtils {
    private const val TAG = "CallUIUtils"
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

    fun loadImgByAccId(context: Context, accId: String, imageView: ImageView) {
        val applicationContext = context.applicationContext
        val defaultResId = R.drawable.t_avchat_avatar_default

        val loadAction: (String?) -> Unit = { url ->
            Glide.with(applicationContext)
                .load(url)
                .placeholder(defaultResId)
                .error(defaultResId)
                .into(imageView)
        }

        val getLongUrlAndLoad: (String?) -> Unit = { url ->
            if (url == null) {
                loadAction(null)
            } else {
                NIMClient.getService(NosService::class.java).getOriginUrlFromShortUrl(url)
                    .setCallback(object : RequestCallbackWrapper<String>() {
                        override fun onResult(code: Int, result: String?, exception: Throwable?) {
                            loadAction(result)
                        }
                    })
            }
        }

        val userInfo: UserInfo? = NIMClient.getService(UserService::class.java).getUserInfo(accId)
        if (userInfo?.avatar != null) {
            getLongUrlAndLoad(userInfo.avatar)
            return
        }

        NIMClient.getService(UserService::class.java).fetchUserInfo(
            Collections.singletonList(accId)
        )
            .setCallback(object : RequestCallbackWrapper<List<NimUserInfo?>>() {
                override fun onResult(
                    code: Int,
                    result: List<NimUserInfo?>?,
                    exception: Throwable?
                ) {
                    if (result.isNullOrEmpty()) {
                        loadAction(null)
                        return
                    }
                    getLongUrlAndLoad(result[0]?.avatar)
                }
            })
    }

    /**
     * 加载图片
     */
    fun loadImg(context: Context, url: String?, imageView: ImageView?) {
        imageView ?: run {
            CallUILog.e(this.TAG, "loadImg imageView is null.")
            return
        }
        val currentContext = context.applicationContext ?: run {
            CallUILog.e(this.TAG, "loadImg context is null.")
            return
        }
        Glide.with(currentContext).load(url)
            .error(R.color.black)
            .placeholder(R.color.black)
            .centerCrop()
            .into(imageView)
    }
}
