/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.view

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.ValueAnimator
import android.annotation.SuppressLint
import android.content.Context
import android.content.res.Configuration
import android.graphics.Color
import android.graphics.Outline
import android.text.TextUtils
import android.util.AttributeSet
import android.view.GestureDetector
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewOutlineProvider
import android.view.animation.AccelerateDecelerateInterpolator
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.constraintlayout.widget.ConstraintSet
import androidx.core.content.ContextCompat
import com.netease.lava.nertc.sdk.NERtcEx
import com.netease.yunxin.kit.call.p2p.NECallEngine
import com.netease.yunxin.kit.call.p2p.extra.NECallLocalActionMgr
import com.netease.yunxin.kit.call.p2p.extra.NECallLocalActionObserver
import com.netease.yunxin.kit.call.p2p.model.NECallEndInfo
import com.netease.yunxin.kit.call.p2p.model.NECallEngineDelegate
import com.netease.yunxin.kit.call.p2p.model.NECallInfo
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.kit.call.p2p.model.NECallTypeChangeInfo
import com.netease.yunxin.kit.call.p2p.model.NEInviteInfo
import com.netease.yunxin.nertc.nertcvideocall.model.CallLocalAction
import com.netease.yunxin.nertc.nertcvideocall.model.SwitchCallState
import com.netease.yunxin.nertc.nertcvideocall.model.impl.state.CallState
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.base.fetchNickname
import com.netease.yunxin.nertc.ui.base.loadAvatarByAccId
import com.netease.yunxin.nertc.ui.databinding.ViewP2pVideoCallBinding
import com.netease.yunxin.nertc.ui.manager.CallManager
import com.netease.yunxin.nertc.ui.utils.CallUILog
import com.netease.yunxin.nertc.ui.utils.CallUIUtils
import com.netease.yunxin.nertc.ui.utils.dip2Px

open class P2PVideoCallLayout @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : ConstraintLayout(context, attrs, defStyleAttr) {

    private val logTag = "SingleVideoCallLayout"
    lateinit var binding: ViewP2pVideoCallBinding
    private var localIsSmallVideo = true

    // 贴边动画相关
    private var positionAnimator: ValueAnimator? = null
    private var isDragging = false
    private var dragStartX: Float = 0f
    private var dragStartY: Float = 0f
    private var totalDragDistanceX: Float = 0f
    private var totalDragDistanceY: Float = 0f

    init {
        initView()
    }

    private var callDelegate = object : NECallEngineDelegate {
        override fun onReceiveInvited(info: NEInviteInfo?) {
            CallUILog.i(logTag, "onReceiveInvited info: $info")
        }

        override fun onCallConnected(info: NECallInfo?) {
            CallUILog.i(logTag, "onCallConnected info: $info")
            info?.otherUserInfo()?.accId.let {
                renderForOnTheCall(info?.callType, it)
            }
        }

        override fun onCallTypeChange(info: NECallTypeChangeInfo) {
            CallUILog.i(logTag, "onCallTypeChange info: $info")
            val callInfo = NECallEngine.sharedInstance().callInfo
            when (info.state) {
                SwitchCallState.ACCEPT -> {
                    if (NECallEngine.sharedInstance().callInfo.callStatus != CallState.STATE_DIALOG) {
                        if (callInfo.isCaller) {
                            renderForCaller(info.callType, callInfo.calleeInfo.accId)
                        } else {
                            renderForCalled(info.callType, callInfo.callerInfo.accId)
                        }
                    } else {
                        renderForOnTheCall(info.callType, callInfo.otherUserInfo().accId)
                    }
                }
            }
        }

        override fun onCallEnd(info: NECallEndInfo?) {
            CallUILog.i(logTag, "onCallEnd info: $info")
        }

        override fun onVideoAvailable(userId: String, available: Boolean) {
            CallUILog.i(logTag, "onVideoAvailable userId: $userId available: $available")
            updateOnTheCallState(UserState(userId, muteVideo = !available))
        }

        override fun onVideoMuted(userId: String, mute: Boolean) {
            CallUILog.i(logTag, "onVideoMuted userId: $userId mute: $mute")
            updateOnTheCallState(UserState(userId, muteVideo = mute))
        }

        override fun onAudioMuted(userId: String?, mute: Boolean) {
            CallUILog.i(logTag, "onAudioMuted userId: $userId mute: $mute")
        }
    }

    private val localActionObserver = NECallLocalActionObserver { actionId, resultCode, _ ->
        CallUILog.d(logTag, "onLocalAction actionId: $actionId resultCode: $resultCode")
        val callInfo = NECallEngine.sharedInstance().callInfo
        if (actionId == CallLocalAction.ACTION_MUTE_VIDEO) {
            updateOnTheCallState(
                UserState(
                    callInfo.currentAccId,
                    muteVideo = true
                )
            )
        } else if (actionId == CallLocalAction.ACTION_UNMUTE_VIDEO) {
            updateOnTheCallState(
                UserState(
                    callInfo.currentAccId,
                    muteVideo = false
                )
            )
        } else if (actionId == CallLocalAction.ACTION_CALL) {
            if (callInfo.isCaller) {
                renderForCaller(callInfo.callType, callInfo.calleeInfo.accId)
            } else {
                renderForCalled(callInfo.callType, callInfo.callerInfo.accId)
            }
        }
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        registerObserver()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        // 取消正在进行的动画
        positionAnimator?.cancel()
        positionAnimator = null
        unregisterObserver()
        NERtcEx.getInstance().setupLocalVideoCanvas(null)
        NERtcEx.getInstance().stopVideoPreview()
    }

    private fun initView() {
        CallUILog.i(logTag, "initView")
        binding = ViewP2pVideoCallBinding.inflate(LayoutInflater.from(context), this, true)
        binding.flSmallContainer.setOnClickListener {
            val callInfo = NECallEngine.sharedInstance().callInfo
            if (callInfo.callType == NECallType.VIDEO) {
                doSwitchCanvas()
            }
        }

        binding.flSmallContainer.outlineProvider = object : ViewOutlineProvider() {
            override fun getOutline(view: View, outline: Outline) {
                outline.setRoundRect(0, 0, view.width, view.height, 8F)
                outline.alpha = 1.0f
            }
        }
        binding.flSmallContainer.setClipToOutline(true)

        val callInfo = NECallEngine.sharedInstance().callInfo
        CallUILog.i(logTag, "initView callStatus: ${callInfo.callStatus}")
        if (callInfo.callStatus == CallState.STATE_CALL_OUT || callInfo.callStatus == CallState.STATE_INVITED) {
            if (callInfo.isCaller) {
                renderForCaller(callInfo.callType, callInfo.calleeInfo.accId)
            } else {
                renderForCalled(callInfo.callType, callInfo.callerInfo.accId)
            }
        } else if (callInfo.callStatus == CallState.STATE_DIALOG) {
            renderForOnTheCall(
                callInfo.callType,
                callInfo.otherUserInfo().accId
            )
            updateCurrentState()
        }
    }

    /**
     * 渲染主叫状态
     */
    fun renderForCaller(callType: Int, calledAccId: String) {
        forUserInfoUI(callType, calledAccId, forVideoCaller = true)
        if (callType == NECallType.VIDEO) {
            binding.videoViewBig.visibility = View.GONE
            binding.videoViewPreview.visibility = View.VISIBLE
            binding.videoViewSmall.visibility = View.GONE
            binding.ivBg.visibility = View.GONE
            CallManager.instance.setupLocalView(binding.videoViewPreview)
        } else {
            binding.ivBg.visibility = View.VISIBLE
            binding.videoViewBig.visibility = View.GONE
            binding.videoViewPreview.visibility = View.GONE
            binding.videoViewSmall.visibility = View.GONE
        }
    }

    /**
     * 渲染被叫状态
     */
    fun renderForCalled(callType: Int, callerAccId: String) {
        forUserInfoUI(callType, callerAccId)
        if (callType == NECallType.VIDEO) {
            binding.videoViewPreview.visibility = View.VISIBLE
            binding.videoViewBig.visibility = View.GONE
            binding.videoViewSmall.visibility = View.GONE
            binding.ivBg.visibility = View.GONE
            binding.tvOtherCallTip.setText(R.string.tip_invite_to_video_call)
            CallManager.instance.setupLocalView(binding.videoViewPreview)
        } else {
            binding.videoViewPreview.visibility = View.GONE
            binding.videoViewBig.visibility = View.GONE
            binding.videoViewSmall.visibility = View.GONE
            binding.ivBg.visibility = View.VISIBLE
            binding.tvOtherCallTip.setText(R.string.tip_invite_to_audio_call)
        }
    }

    /**
     * 渲染通话中状态
     */
    fun renderForOnTheCall(callType: Int? = NECallType.VIDEO, userAccId: String? = null) {
        val callInfo = NECallEngine.sharedInstance().callInfo
        if (callType == NECallType.VIDEO) {
            forUserInfoUI(callType, visible = false)

            binding.videoViewPreview.visibility = View.GONE
            binding.videoViewSmall.visibility = View.VISIBLE
            binding.videoViewBig.visibility = View.VISIBLE
            binding.ivSmallVideoShade.visibility = View.GONE
            binding.ivBg.visibility = View.GONE

            if (callInfo.isCaller) {
                NERtcEx.getInstance().setupLocalVideoCanvas(null)
                NERtcEx.getInstance().stopVideoPreview()
            }

            // 初始化手势监听器，支持拖动和点击切换
            initGestureListener(binding.flSmallContainer)

            CallManager.instance.setupRemoteView(binding.videoViewBig)
            binding.videoViewPreview.release()
            CallManager.instance.setupLocalView(binding.videoViewSmall)
        } else {
            forUserInfoUI(NECallType.AUDIO, userAccId)

            binding.tvOtherCallTip.setText(R.string.tip_on_the_call)
            binding.videoViewPreview.visibility = View.GONE
            binding.videoViewSmall.visibility = View.GONE
            binding.videoViewBig.visibility = View.GONE
            binding.ivSmallVideoShade.visibility = View.GONE
            binding.tvBigVideoCloseTip.visibility = View.GONE
            binding.ivBg.visibility = View.VISIBLE
        }
    }

    private fun registerObserver() {
        NECallEngine.sharedInstance().addCallDelegate(callDelegate)
        NECallLocalActionMgr.getInstance().addCallback(localActionObserver)
    }

    private fun unregisterObserver() {
        NECallEngine.sharedInstance().removeCallDelegate(callDelegate)
        NECallLocalActionMgr.getInstance().removeCallback(localActionObserver)
    }

    /**
     * 切换画布
     */
    open fun doSwitchCanvas() {
        CallUILog.i(logTag, "doSwitchCanvas")
        val callInfo = NECallEngine.sharedInstance().callInfo
        val otherRtcUid = callInfo.otherUserInfo().uid
        if (otherRtcUid == 0L) {
            CallUILog.e(
                logTag,
                "doSwitchCanvas otherRtcUid is 0L with accId ${callInfo.otherUserInfo().accId}."
            )
            return
        }
        if (CallManager.instance.isLocalMuteVideo) {
            binding.videoViewBig.clearImage()
            binding.videoViewSmall.clearImage()
        }

        if (localIsSmallVideo) {
            NERtcEx.getInstance().setupRemoteVideoCanvas(binding.videoViewSmall, otherRtcUid)
            NERtcEx.getInstance().setupLocalVideoCanvas(binding.videoViewBig)
        } else {
            NERtcEx.getInstance().setupRemoteVideoCanvas(binding.videoViewBig, otherRtcUid)
            NERtcEx.getInstance().setupLocalVideoCanvas(binding.videoViewSmall)
        }
        localIsSmallVideo = !localIsSmallVideo
        updateCurrentState()
    }

    fun updateCurrentState() {
        CallUILog.i(logTag, "updateCurrentState")
        val callInfo = NECallEngine.sharedInstance().callInfo

        updateOnTheCallState(
            UserState(
                callInfo.currentUserInfo().accId,
                muteVideo = callInfo.currentUserInfo().isMuteVideo
            )
        )

        val otherRtcUid = callInfo.otherUserInfo().uid
        if (otherRtcUid == 0L) {
            CallUILog.e(
                logTag,
                "updateCurrentState otherRtcUid is 0L with accId ${callInfo.otherUserInfo().accId}."
            )
            return
        }

        updateOnTheCallState(
            UserState(
                callInfo.otherUserInfo().accId,
                muteVideo = callInfo.otherUserInfo().isMuteVideo
            )
        )
    }

    /**
     * 更新通话中状态
     */
    open fun updateOnTheCallState(state: UserState) {
        val callInfo = NECallEngine.sharedInstance().callInfo

        if (callInfo.callType == NECallType.AUDIO) {
            CallUILog.i(logTag, "updateOnTheCallState callType is AUDIO.")
            return
        }

        CallUILog.i(
            logTag,
            "updateOnTheCallState state: $state localIsSmallVideo: $localIsSmallVideo"
        )
        if (localIsSmallVideo) {
            if (TextUtils.equals(state.userAccId, callInfo.currentAccId)) {
                state.muteVideo?.run {
                    CallUIUtils.loadImg(context, "", binding.ivSmallVideoShade)
                    binding.ivSmallVideoShade.visibility = if (this) View.VISIBLE else View.GONE
                    binding.tvSmallVideoCloseTip.visibility = if (this) View.VISIBLE else View.GONE
                    binding.tvSmallVideoCloseTip.text = context.getString(
                        R.string.ui_tip_close_camera_by_self
                    )
                }
            } else {
                state.muteVideo?.run {
                    CallUIUtils.loadImg(context, "", binding.ivBigVideoShade)
                    binding.ivBigVideoShade.visibility = if (this) View.VISIBLE else View.GONE
                    binding.tvBigVideoCloseTip.text = context.getString(
                        R.string.ui_tip_close_camera_by_other
                    )
                    binding.tvBigVideoCloseTip.visibility = if (this) View.VISIBLE else View.GONE
                }
            }
        } else {
            if (TextUtils.equals(state.userAccId, callInfo.currentAccId)) {
                state.muteVideo?.run {
                    CallUIUtils.loadImg(context, "", binding.ivBigVideoShade)
                    binding.ivBigVideoShade.visibility = if (this) View.VISIBLE else View.GONE
                    binding.tvBigVideoCloseTip.text = context.getString(
                        R.string.ui_tip_close_camera_by_self
                    )
                    binding.tvBigVideoCloseTip.visibility = if (this) View.VISIBLE else View.GONE
                }
            } else {
                state.muteVideo?.run {
                    CallUIUtils.loadImg(context, "", binding.ivSmallVideoShade)
                    binding.ivSmallVideoShade.visibility = if (this) View.VISIBLE else View.GONE
                    binding.tvSmallVideoCloseTip.visibility = if (this) View.VISIBLE else View.GONE
                    binding.tvSmallVideoCloseTip.text = context.getString(
                        R.string.ui_tip_close_camera_by_other
                    )
                }
            }
        }
    }

    /**
     * 渲染用户信息UI
     */
    open fun forUserInfoUI(
        type: Int,
        accId: String? = null,
        visible: Boolean = true,
        forVideoCaller: Boolean = false
    ) {
        if (!visible) {
            binding.userInfoGroup.visibility = View.GONE
            return
        }
        binding.userInfoGroup.visibility = View.VISIBLE

        accId?.run {
            fetchNickname {
                binding.tvUserName.text = it
            }
            loadAvatarByAccId(
                context,
                binding.ivUserInnerAvatar,
                binding.ivBg,
                binding.tvUserInnerAvatar,
                true
            )
        }
        val centerSize = 97.dip2Px(context)
        val topSize = 60.dip2Px(context)

        val constraintSet = ConstraintSet()
        constraintSet.clone(binding.clRoot)
        constraintSet.clear(R.id.flUserAvatar)
        constraintSet.clear(R.id.tvOtherCallTip)
        constraintSet.clear(R.id.tvUserName)
        constraintSet.constrainHeight(R.id.tvOtherCallTip, ConstraintSet.WRAP_CONTENT)
        constraintSet.constrainWidth(R.id.tvOtherCallTip, ConstraintSet.WRAP_CONTENT)
        constraintSet.constrainWidth(R.id.tvUserName, ConstraintSet.WRAP_CONTENT)

        if (type == NECallType.VIDEO && forVideoCaller) {
            val marginSize16 = 16.dip2Px(context)
            val marginTop = 50.dip2Px(context)
            binding.flUserAvatar.run {
                constraintSet.constrainWidth(id, topSize)
                constraintSet.constrainHeight(id, topSize)
                constraintSet.connect(
                    id,
                    ConstraintSet.END,
                    ConstraintSet.PARENT_ID,
                    ConstraintSet.END,
                    marginSize16
                )
                constraintSet.connect(
                    id,
                    ConstraintSet.TOP,
                    ConstraintSet.PARENT_ID,
                    ConstraintSet.TOP,
                    marginTop
                )
            }
            val marginSize10 = 10.dip2Px(context)
            val marginSize5 = 5.dip2Px(context)
            binding.tvUserName.run {
                textSize = 18f
                constraintSet.connect(
                    id,
                    ConstraintSet.END,
                    binding.flUserAvatar.id,
                    ConstraintSet.START,
                    marginSize10
                )
                constraintSet.connect(
                    id,
                    ConstraintSet.TOP,
                    binding.flUserAvatar.id,
                    ConstraintSet.TOP,
                    marginSize5
                )
            }
            binding.tvOtherCallTip.run {
                setTextColor(ContextCompat.getColor(context, R.color.white))
                constraintSet.connect(
                    id,
                    ConstraintSet.TOP,
                    binding.tvUserName.id,
                    ConstraintSet.BOTTOM,
                    marginSize5
                )
                constraintSet.connect(
                    id,
                    ConstraintSet.END,
                    binding.flUserAvatar.id,
                    ConstraintSet.START,
                    marginSize10
                )
            }
        } else {
            binding.flUserAvatar.run {
                constraintSet.constrainWidth(id, centerSize)
                constraintSet.constrainHeight(id, centerSize)
                constraintSet.connect(
                    id,
                    ConstraintSet.TOP,
                    ConstraintSet.PARENT_ID,
                    ConstraintSet.TOP,
                    160.dip2Px(context)
                )
                constraintSet.centerHorizontally(id, ConstraintSet.PARENT_ID)
            }
            binding.tvUserName.run {
                textSize = 20f
                constraintSet.centerHorizontally(id, ConstraintSet.PARENT_ID)
                constraintSet.connect(
                    id,
                    ConstraintSet.TOP,
                    binding.flUserAvatar.id,
                    ConstraintSet.BOTTOM,
                    15.dip2Px(context)
                )
            }
            binding.tvOtherCallTip.run {
                setTextColor(ContextCompat.getColor(context, R.color.color_cccccc))
                constraintSet.connect(
                    id,
                    ConstraintSet.TOP,
                    binding.tvUserName.id,
                    ConstraintSet.BOTTOM,
                    8.dip2Px(context)
                )
                constraintSet.centerHorizontally(id, ConstraintSet.PARENT_ID)
            }
        }
        constraintSet.applyTo(binding.clRoot)
    }

    /**
     * 重置切换状态
     */
    open fun resetSwitchState(callType: Int) {
        if (callType == NECallType.VIDEO) {
            localIsSmallVideo = true
            binding.tvBigVideoCloseTip.visibility = View.GONE
            binding.videoViewSmall.setBackgroundColor(Color.TRANSPARENT)
        }
    }

    /**
     * 初始化手势监听器，支持拖动和点击切换
     * @param view 需要添加手势的视图
     */
    @SuppressLint("ClickableViewAccessibility")
    private fun initGestureListener(view: View) {
        val detector = GestureDetector(
            context,
            object : GestureDetector.SimpleOnGestureListener() {
                override fun onSingleTapUp(e: MotionEvent): Boolean {
                    // 单击事件：切换画布（只有在非拖动状态下才响应）
                    if (!isDragging) {
                        view.performClick()
                    }
                    return true
                }

                override fun onDown(e: MotionEvent): Boolean {
                    // 取消正在进行的贴边动画
                    positionAnimator?.cancel()
                    isDragging = false
                    // 记录拖动起始位置
                    dragStartX = e.x
                    dragStartY = e.y
                    totalDragDistanceX = 0f
                    totalDragDistanceY = 0f
                    return true
                }

                override fun onScroll(
                    e1: MotionEvent?,
                    e2: MotionEvent,
                    distanceX: Float,
                    distanceY: Float
                ): Boolean {
                    // 标记为拖动状态
                    isDragging = true

                    // 累计拖动距离（用于判断拖动方向）
                    totalDragDistanceX += Math.abs(distanceX)
                    totalDragDistanceY += Math.abs(distanceY)

                    // 拖动事件：移动小窗口位置
                    val layoutParams = view.layoutParams as ConstraintLayout.LayoutParams
                    val offsetX = if (isRTL) {
                        // RTL 布局：从右到左，需要反转 X 方向
                        e2.x - (e1?.x ?: 0f)
                    } else {
                        // LTR 布局：从左到右
                        (e1?.x ?: 0f) - e2.x
                    }

                    val newX = (layoutParams.marginEnd + offsetX).toInt()
                    val newY = (layoutParams.topMargin + (e2.y - (e1?.y ?: 0f))).toInt()

                    // 边界检查，确保小窗口不会移出屏幕
                    val maxX = width - view.width
                    val maxY = height - view.height

                    if (newX >= 0 && newX <= maxX && newY >= 0 && newY <= maxY) {
                        layoutParams.marginEnd = newX
                        layoutParams.topMargin = newY
                        view.layoutParams = layoutParams
                        CallUILog.d(logTag, "onScroll: newX=$newX, newY=$newY")
                    }
                    return true
                }
            }
        )

        view.setOnTouchListener { v, event ->
            val result = detector.onTouchEvent(event)

            // 处理 ACTION_UP 事件，实现贴边效果
            if (event.action == MotionEvent.ACTION_UP || event.action == MotionEvent.ACTION_CANCEL) {
                if (isDragging) {
                    // 拖动结束后，自动贴边
                    snapToEdge(view)
                    isDragging = false
                }
            }

            result
        }
    }

    /**
     * 将小窗口吸附到最近的边缘
     * @param view 需要贴边的小窗口视图
     */
    private fun snapToEdge(view: View) {
        val layoutParams = view.layoutParams as ConstraintLayout.LayoutParams
        val currentX = layoutParams.marginEnd
        val currentY = layoutParams.topMargin

        val viewWidth = view.width
        val viewHeight = view.height
        val parentWidth = width
        val parentHeight = height

        // 判断是否为纯垂直拖动（垂直拖动距离明显大于水平拖动距离）
        val isPureVerticalDrag = totalDragDistanceY > totalDragDistanceX * 2.0f

        // 计算小窗口左边缘的 X 坐标（用于判断贴哪一边）
        // 注意：marginEnd 是右边距，需要转换为左边缘位置
        val leftEdgeX = parentWidth - currentX - viewWidth
        val centerY = currentY + viewHeight / 2

        // X 轴贴边逻辑：
        // 小窗口始终贴到最近的边（左边或右边），除非是纯垂直拖动
        val targetX = if (isPureVerticalDrag) {
            // 纯垂直拖动：X 坐标保持不变
            currentX
        } else {
            // 判断贴左边还是右边（基于左边缘位置）
            if (leftEdgeX < parentWidth / 2) {
                // 贴左边：marginEnd = parentWidth - viewWidth
                parentWidth - viewWidth
            } else {
                // 贴右边：marginEnd = 0
                0
            }
        }

        // Y 轴贴边逻辑：Y 坐标保持不变（确保在边界内）
        val targetY = currentY.coerceIn(0, parentHeight - viewHeight)

        CallUILog.d(
            logTag,
            "snapToEdge: isPureVerticalDrag=$isPureVerticalDrag, leftEdgeX=$leftEdgeX, currentX=$currentX, currentY=$currentY, targetX=$targetX, targetY=$targetY"
        )

        // 如果位置没有变化，不需要动画
        if (currentX == targetX && currentY == targetY) {
            return
        }

        // 使用动画平滑移动到目标位置
        animateToPosition(view, currentX, currentY, targetX, targetY)
    }

    /**
     * 使用动画将视图移动到目标位置
     */
    private fun animateToPosition(
        view: View,
        startX: Int,
        startY: Int,
        endX: Int,
        endY: Int
    ) {
        // 取消之前的动画
        positionAnimator?.cancel()

        val layoutParams = view.layoutParams as ConstraintLayout.LayoutParams

        // 创建 X 和 Y 的动画
        val animatorX = ValueAnimator.ofInt(startX, endX)
        val animatorY = ValueAnimator.ofInt(startY, endY)

        animatorX.duration = 200
        animatorX.interpolator = AccelerateDecelerateInterpolator()
        animatorX.addUpdateListener { animation ->
            val x = animation.animatedValue as Int
            layoutParams.marginEnd = x
            view.layoutParams = layoutParams
        }

        animatorY.duration = 200
        animatorY.interpolator = AccelerateDecelerateInterpolator()
        animatorY.addUpdateListener { animation ->
            val y = animation.animatedValue as Int
            layoutParams.topMargin = y
            view.layoutParams = layoutParams
        }

        // 同时启动 X 和 Y 的动画
        positionAnimator = animatorX
        animatorX.start()
        animatorY.start()

        // 动画结束后清理
        animatorX.addListener(object : AnimatorListenerAdapter() {
            override fun onAnimationEnd(animation: Animator) {
                positionAnimator = null
                CallUILog.d(
                    logTag,
                    "snapToEdge animation end: finalX=${layoutParams.marginEnd}, finalY=${layoutParams.topMargin}"
                )
            }
        })
    }

    /**
     * 判断是否为 RTL（从右到左）布局
     */
    private val isRTL: Boolean
        get() = context.resources.configuration.layoutDirection == View.LAYOUT_DIRECTION_RTL

    override fun onConfigurationChanged(newConfig: Configuration?) {
        super.onConfigurationChanged(newConfig)
        // 配置变化时，可能需要重新调整小窗口位置
        binding.videoViewSmall.requestLayout()
    }

    /**
     * 用户状态
     */
    data class UserState(
        val userAccId: String,
        val muteVideo: Boolean? = null
    )
}
