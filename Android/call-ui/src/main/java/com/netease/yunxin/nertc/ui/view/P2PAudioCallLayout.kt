/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.view

import android.content.Context
import android.view.LayoutInflater
import android.widget.ImageView
import androidx.constraintlayout.widget.ConstraintLayout
import com.bumptech.glide.Glide
import com.netease.yunxin.kit.call.p2p.model.NECallEndInfo
import com.netease.yunxin.kit.call.p2p.model.NECallEngineDelegate
import com.netease.yunxin.kit.call.p2p.model.NECallInfo
import com.netease.yunxin.kit.call.p2p.model.NECallTypeChangeInfo
import com.netease.yunxin.kit.call.p2p.model.NEInviteInfo
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.databinding.ViewP2pAudioOnTheCallBinding
import com.netease.yunxin.nertc.ui.p2p.CallUIOperationsMgr
import com.netease.yunxin.nertc.ui.utils.CallUILog

open class P2PAudioCallLayout(context: Context) : ConstraintLayout(context) {

    private val logTag = "SingleAudioCallLayout"
    protected lateinit var binding: ViewP2pAudioOnTheCallBinding

    init {
        initView()
    }

    private var callDelegate = object : NECallEngineDelegate {
        override fun onReceiveInvited(info: NEInviteInfo?) {
            CallUILog.i(logTag, "onReceiveInvited")
        }

        override fun onCallConnected(info: NECallInfo?) {
            CallUILog.i(logTag, "onCallConnected info: $info")
            refreshBigVideoView()
            refreshSmallVideoView()
        }

        override fun onCallTypeChange(info: NECallTypeChangeInfo?) {
            CallUILog.i(logTag, "onCallTypeChange")
        }

        override fun onCallEnd(info: NECallEndInfo?) {
            CallUILog.i(logTag, "onCallEnd")
        }

        override fun onVideoAvailable(userId: String?, available: Boolean) {
            CallUILog.i(logTag, "onVideoAvailable")
        }

        override fun onVideoMuted(userId: String?, mute: Boolean) {
            CallUILog.i(logTag, "onVideoMuted")
        }

        override fun onAudioMuted(userId: String?, mute: Boolean) {
            CallUILog.i(logTag, "onAudioMuted")
        }
    }

    private fun initBigVideoView() {
    }

    private fun refreshBigVideoView() {
        if (CallUIOperationsMgr.callInfoWithUIState.isLocalSmallVideo) {
        } else {
        }
    }

    private fun refreshSmallVideoView() {
        if (CallUIOperationsMgr.callInfoWithUIState.isLocalSmallVideo) {
        } else {
        }
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        registerObserver()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        unregisterObserver()
    }

    private fun initView() {
        binding = ViewP2pAudioOnTheCallBinding.inflate(LayoutInflater.from(context), this, true)
        initBigVideoView()
    }

    private fun registerObserver() {
        CallUIOperationsMgr.callEngine.addCallDelegate(callDelegate)
    }

    private fun unregisterObserver() {
        CallUIOperationsMgr.callEngine.removeCallDelegate(callDelegate)
    }

    protected open fun loadImg(url: String?, imageView: ImageView?) {
        imageView ?: run {
            CallUILog.e(logTag, "loadImg imageView is null.")
            return
        }
        val currentContext = context.applicationContext ?: run {
            CallUILog.e(logTag, "loadImg context is null.")
            return
        }
        Glide.with(currentContext).load(url)
            .error(R.color.black)
            .placeholder(R.color.black)
            .centerCrop()
            .into(imageView)
    }

    protected fun getString(resId: Int): String {
        return context.getString(resId)
    }
}
