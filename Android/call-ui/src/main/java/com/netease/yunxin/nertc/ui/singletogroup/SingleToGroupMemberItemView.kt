/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.singletogroup

import android.content.Context
import android.text.TextUtils
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import com.bumptech.glide.Glide
import com.netease.nimlib.sdk.NIMClient
import com.netease.yunxin.kit.call.p2p.model.NECallMemberState
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.utils.dip2Px
import com.netease.yunxin.nertc.ui.utils.image.RoundedCornersCenterCrop

class SingleToGroupMemberItemView(context: Context) : FrameLayout(context) {
    companion object {
        const val TAG = "SingleToGroupMemberItemView"
    }

    private lateinit var ivUserAvatar: ImageView
    private lateinit var userVideoViewGroup: ViewGroup
    private lateinit var tvUserName: TextView
    private lateinit var tipToAccept: TextView
    private lateinit var focusFlag: View
    private var isLayoutAnimating = false
    private var boundAccId: String? = null
    private var boundUid: Long = 0
    private var boundIsSelf = false
    private var boundEnableVideo = false
    private var boundState: Int? = null
    private var refreshVersion = 0

    init {
        initUI()
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val size = minOf(
            MeasureSpec.getSize(widthMeasureSpec),
            MeasureSpec.getSize(heightMeasureSpec)
        )
        val squareMeasureSpec = MeasureSpec.makeMeasureSpec(size, MeasureSpec.EXACTLY)
        for (i in 0 until childCount) {
            val child = getChildAt(i)
            child.measure(squareMeasureSpec, squareMeasureSpec)
        }
        setMeasuredDimension(size, size)
    }

    override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
        val size = minOf(right - left, bottom - top)
        for (i in 0 until childCount) {
            val child = getChildAt(i)
            child.layout(0, 0, size, size)
        }
        updateAvatarSize(size)
    }

    private fun updateAvatarSize(containerSize: Int) {
        val avatarSize = containerSize / 2
        val layoutParams = ivUserAvatar.layoutParams as androidx.constraintlayout.widget.ConstraintLayout.LayoutParams
        layoutParams.width = avatarSize
        layoutParams.height = avatarSize
        ivUserAvatar.layoutParams = layoutParams
    }

    private fun initUI() {
        LayoutInflater.from(context)
            .inflate(R.layout.view_single_to_group_member_item, this, false)
            .run {
                addView(this, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
            }
        ivUserAvatar = findViewById(R.id.ivUserAvatar)
        userVideoViewGroup = findViewById(R.id.userVideoView)
        tvUserName = findViewById(R.id.tvUserName)
        tipToAccept = findViewById(R.id.tvTipToAccept)
        focusFlag = findViewById(R.id.focusFlag)
    }

    fun refreshData(data: SingleToGroupMemberInfo, videoViewPool: SingleToGroupVideoViewPool) {
        val currentRefreshVersion = ++refreshVersion
        if (data.state == NECallMemberState.LEAVING) {
            visibility = View.GONE
            return
        }
        visibility = View.VISIBLE
        Glide.with(context)
            .asBitmap()
            .load(data.avatarUrl)
            .error(R.drawable.t_avchat_avatar_default)
            .transform(RoundedCornersCenterCrop(4.dip2Px(context)))
            .into(ivUserAvatar)
        tvUserName.text = if (TextUtils.isEmpty(data.name)) data.accId else data.name
        tipToAccept.visibility =
            if (data.state == NECallMemberState.WAITING) View.VISIBLE else View.GONE
        focusFlag.visibility = if (data.focus) View.VISIBLE else View.GONE
        if (isLayoutAnimating) {
            postDelayed({
                if (currentRefreshVersion == refreshVersion) {
                    updateVideoView(data, videoViewPool)
                }
            }, 600)
        } else {
            updateVideoView(data, videoViewPool)
        }
    }

    fun setLayoutAnimating(animating: Boolean) {
        isLayoutAnimating = animating
    }

    fun release(videoViewPool: SingleToGroupVideoViewPool) {
        refreshVersion++
        if (boundUid > 0) {
            videoViewPool.recycleRtcVideo(boundUid)
        }
        userVideoViewGroup.removeAllViews()
        clearVideoBinding()
    }

    private fun updateVideoView(
        data: SingleToGroupMemberInfo,
        videoViewPool: SingleToGroupVideoViewPool
    ) {
        val currentAccount = NIMClient.getCurrentAccount()
        val isSelf = data.accId == currentAccount
        if (isSameVideoBinding(data, isSelf)) {
            return
        }
        if (data.state == NECallMemberState.WAITING) {
            recycleBoundVideoIfNeeded(data.uid, videoViewPool)
            userVideoViewGroup.visibility = View.GONE
            userVideoViewGroup.removeAllViews()
            ivUserAvatar.visibility = View.VISIBLE
            updateVideoBinding(data, isSelf)
            requestLayout()
            return
        }
        if (data.enableVideo && data.uid > 0) {
            recycleOldVideoIfUidChanged(data.uid, videoViewPool)
            userVideoViewGroup.removeAllViews()
            userVideoViewGroup.visibility = View.VISIBLE
            videoViewPool.obtainRtcVideo(data.uid, isSelf).run {
                layoutParams = ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT
                )
                userVideoViewGroup.addView(this)
            }
            ivUserAvatar.visibility = View.GONE
            updateVideoBinding(data, isSelf)
        } else {
            recycleBoundVideoIfNeeded(data.uid, videoViewPool)
            userVideoViewGroup.visibility = View.GONE
            userVideoViewGroup.removeAllViews()
            ivUserAvatar.visibility = View.VISIBLE
            updateVideoBinding(data, isSelf)
        }
        requestLayout()
    }

    private fun isSameVideoBinding(data: SingleToGroupMemberInfo, isSelf: Boolean): Boolean {
        return boundAccId == data.accId &&
            boundUid == data.uid &&
            boundIsSelf == isSelf &&
            boundEnableVideo == data.enableVideo &&
            boundState == data.state
    }

    private fun updateVideoBinding(data: SingleToGroupMemberInfo, isSelf: Boolean) {
        boundAccId = data.accId
        boundUid = data.uid
        boundIsSelf = isSelf
        boundEnableVideo = data.enableVideo
        boundState = data.state
    }

    private fun clearVideoBinding() {
        boundAccId = null
        boundUid = 0
        boundIsSelf = false
        boundEnableVideo = false
        boundState = null
    }

    private fun recycleOldVideoIfUidChanged(
        newUid: Long,
        videoViewPool: SingleToGroupVideoViewPool
    ) {
        if (boundUid > 0 && boundUid != newUid) {
            videoViewPool.recycleRtcVideo(boundUid)
        }
    }

    private fun recycleBoundVideoIfNeeded(
        uid: Long,
        videoViewPool: SingleToGroupVideoViewPool
    ) {
        if (boundEnableVideo && boundUid > 0) {
            videoViewPool.recycleRtcVideo(boundUid)
        } else if (uid > 0) {
            videoViewPool.recycleRtcVideo(uid)
        }
    }
}
