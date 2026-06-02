/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.banner

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import com.bumptech.glide.Glide
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.utils.dip2Px

/**
 * 来电横幅视图，通过 WindowManager TYPE_APPLICATION_OVERLAY 挂载，
 * 悬浮在所有界面之上，Activity 切换时无闪烁，对齐 iOS UIWindow 方案。
 */
@SuppressLint("ViewConstructor")
class IncomingCallBannerView(
    private val context: Context,
    private val callerInfo: CallerInfo,
    private val onDismissCallback: (() -> Unit)? = null,
    private val onBodyTapCallback: (() -> Unit)? = null,
    private val onRejectCallback: (() -> Unit)? = null,
    private val onAcceptCallback: (() -> Unit)? = null
) {

    companion object {
        private const val TAG = "IncomingCallBannerView"

        private const val BG_COLOR = 0xFF22262E.toInt()
        private const val BG_RADIUS_DP = 10
        private const val AVATAR_SIZE_DP = 60
        private const val AVATAR_RADIUS_DP = 7
        private const val AVATAR_MARGIN_LEFT_DP = 16
        private const val TEXT_MARGIN_LEFT_DP = 12
        private const val NAME_TEXT_SIZE_SP = 18f
        private const val DESC_TEXT_SIZE_SP = 12f
        private const val DESC_TEXT_COLOR = 0xFFC5CCDB.toInt()
        private const val BTN_SIZE_DP = 52
        private const val ACCEPT_MARGIN_RIGHT_DP = 16
        private const val REJECT_MARGIN_RIGHT_DP = 12
        private const val BANNER_MARGIN_DP = 12
        private const val BANNER_PADDING_VERTICAL_DP = 16
    }

    private var rootView: View? = null
    private val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager

    // 保留对名称和头像视图的引用，以便异步更新
    private var nameView: TextView? = null
    private var avatarImageView: ImageView? = null

    fun show() {
        if (rootView != null) {
            ALog.w(TAG, "Banner is already showing.")
            return
        }
        val view = buildView(context)
        rootView = view

        val margin = BANNER_MARGIN_DP.dip2Px(context)
        val screenWidth = context.resources.displayMetrics.widthPixels

        @Suppress("DEPRECATION")
        val windowType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val params = WindowManager.LayoutParams(
            screenWidth - 2 * margin,
            WindowManager.LayoutParams.WRAP_CONTENT,
            windowType,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = margin
            y = getStatusBarHeight() + margin
        }

        try {
            windowManager.addView(view, params)
            ALog.i(TAG, "Banner shown for caller: ${callerInfo.accId}")
        } catch (e: Exception) {
            ALog.e(TAG, "Failed to add banner view to WindowManager", e)
            rootView = null
        }
    }

    fun dismiss() {
        val view = rootView ?: return
        rootView = null
        nameView = null
        avatarImageView = null
        try {
            windowManager.removeView(view)
        } catch (e: Exception) {
            ALog.e(TAG, "Failed to remove banner view", e)
        }
        onDismissCallback?.invoke()
        ALog.i(TAG, "Banner dismissed for caller: ${callerInfo.accId}")
    }

    fun isShowing(): Boolean = rootView != null

    // 异步更新昵称
    fun updateCallerName(name: String) {
        nameView?.post {
            nameView?.text = name.ifBlank { callerInfo.accId }
        }
    }

    // 异步更新头像
    fun updateAvatarUrl(url: String?) {
        val iv = avatarImageView ?: return
        if (url.isNullOrBlank()) return
        iv.post {
            try {
                Glide.with(context.applicationContext)
                    .load(url)
                    .diskCacheStrategy(DiskCacheStrategy.ALL)
                    .placeholder(R.drawable.t_avchat_avatar_default)
                    .error(R.drawable.t_avchat_avatar_default)
                    .into(iv)
            } catch (e: Exception) {
                ALog.e(TAG, "Glide update avatar failed", e)
            }
        }
    }

    // ----------------------------- 内部构建 -----------------------------

    @SuppressLint("ClickableViewAccessibility")
    private fun buildView(context: Context): View {
        val root = FrameLayout(context).apply {
            background = GradientDrawable().apply {
                setColor(BG_COLOR)
                cornerRadius = BG_RADIUS_DP.dip2Px(context).toFloat()
            }
            val vPad = BANNER_PADDING_VERTICAL_DP.dip2Px(context)
            setPadding(0, vPad, 0, vPad)
        }

        val inner = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
        }

        val avatarSize = AVATAR_SIZE_DP.dip2Px(context)
        val avatarView = ImageView(context).apply {
            scaleType = ImageView.ScaleType.CENTER_CROP
            background = GradientDrawable().apply {
                cornerRadius = AVATAR_RADIUS_DP.dip2Px(context).toFloat()
            }
            clipToOutline = true
        }
        avatarImageView = avatarView  // 保存引用
        inner.addView(avatarView, LinearLayout.LayoutParams(avatarSize, avatarSize).apply {
            marginStart = AVATAR_MARGIN_LEFT_DP.dip2Px(context)
        })
        loadAvatar(context, avatarView)

        val textGroup = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_VERTICAL
        }
        val textParams = LinearLayout.LayoutParams(
            0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f
        ).apply {
            marginStart = TEXT_MARGIN_LEFT_DP.dip2Px(context)
            marginEnd = TEXT_MARGIN_LEFT_DP.dip2Px(context)  // 12dp gap before reject btn, aligns with iOS
        }

        val tv = TextView(context).apply {
            textSize = NAME_TEXT_SIZE_SP
            setTextColor(Color.WHITE)
            typeface = android.graphics.Typeface.DEFAULT_BOLD
            maxLines = 1
            ellipsize = android.text.TextUtils.TruncateAt.END
            text = callerInfo.displayName.ifBlank { callerInfo.accId }
        }
        nameView = tv  // 保存引用
        textGroup.addView(tv, LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT
        ))

        val descView = TextView(context).apply {
            textSize = DESC_TEXT_SIZE_SP
            setTextColor(DESC_TEXT_COLOR)
            maxLines = 1
            text = buildDescText(context, callerInfo.callType)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT
            ).also { it.topMargin = 4.dip2Px(context) }
        }
        textGroup.addView(descView)
        inner.addView(textGroup, textParams)

        val btnSize = BTN_SIZE_DP.dip2Px(context)

        val rejectBtn = ImageButton(context).apply {
            setBackgroundColor(Color.TRANSPARENT)
            setImageResource(R.drawable.call_reject)
            scaleType = ImageView.ScaleType.FIT_CENTER
            contentDescription = "拒绝"
        }
        inner.addView(rejectBtn, LinearLayout.LayoutParams(btnSize, btnSize).apply {
            marginEnd = REJECT_MARGIN_RIGHT_DP.dip2Px(context)
        })

        val acceptBtn = ImageButton(context).apply {
            setBackgroundColor(Color.TRANSPARENT)
            val acceptIcon = if (callerInfo.callType == NECallType.VIDEO)
                R.drawable.call_accept_video else R.drawable.call_accept
            setImageResource(acceptIcon)
            scaleType = ImageView.ScaleType.FIT_CENTER
            contentDescription = if (callerInfo.callType == NECallType.VIDEO) "接听视频通话" else "接听"
        }
        inner.addView(acceptBtn, LinearLayout.LayoutParams(btnSize, btnSize).apply {
            marginEnd = ACCEPT_MARGIN_RIGHT_DP.dip2Px(context)
        })

        root.addView(inner, FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.WRAP_CONTENT
        ))

        root.setOnClickListener {
            ALog.i(TAG, "bannerBodyTapped")
            try {
                onBodyTapCallback?.invoke()
            } finally {
                dismiss()
            }
        }

        rejectBtn.setOnClickListener {
            ALog.i(TAG, "bannerRejectTapped")
            dismiss()
            onRejectCallback?.invoke()
        }

        // 不提前 dismiss，保留 overlay 窗口直到 accept 完成后再关闭，
        // 以便在后台时仍可通过 overlay 窗口权限启动 Activity。
        acceptBtn.setOnClickListener {
            ALog.i(TAG, "bannerAcceptTapped")
            onAcceptCallback?.invoke()
        }

        return root
    }

    private fun loadAvatar(context: Context, imageView: ImageView) {
        val url = callerInfo.avatarUrl
        if (url.isNullOrBlank()) {
            imageView.setImageResource(R.drawable.t_avchat_avatar_default)
        } else {
            try {
                Glide.with(context.applicationContext)
                    .load(url)
                    .diskCacheStrategy(DiskCacheStrategy.ALL)
                    .placeholder(R.drawable.t_avchat_avatar_default)
                    .error(R.drawable.t_avchat_avatar_default)
                    .into(imageView)
            } catch (e: Exception) {
                ALog.e(TAG, "Glide load avatar failed", e)
                imageView.setImageResource(R.drawable.t_avchat_avatar_default)
            }
        }
    }

    private fun buildDescText(context: Context, callType: Int): String {
        if (callerInfo.isMultiCallInvite) {
            return context.getString(R.string.tip_incoming_banner_single_to_group_call)
        }
        return when (callType) {
            NECallType.VIDEO -> context.getString(R.string.tip_incoming_banner_video_call)
            else -> context.getString(R.string.tip_incoming_banner_audio_call)
        }
    }

    private fun getStatusBarHeight(): Int {
        val resourceId = context.resources.getIdentifier("status_bar_height", "dimen", "android")
        return if (resourceId > 0) context.resources.getDimensionPixelSize(resourceId) else 0
    }
}
