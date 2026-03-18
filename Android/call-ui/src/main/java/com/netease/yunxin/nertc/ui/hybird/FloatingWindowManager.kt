/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.hybird

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.view.View
import android.view.WindowManager
import com.netease.yunxin.kit.alog.ParameterMap
import com.netease.yunxin.kit.call.p2p.NECallEngine
import com.netease.yunxin.kit.call.p2p.model.NECallEndInfo
import com.netease.yunxin.kit.call.p2p.model.NECallEngineDelegateAbs
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.kit.call.p2p.model.NECallTypeChangeInfo
import com.netease.yunxin.kit.call.p2p.model.NEHangupReasonCode
import com.netease.yunxin.nertc.nertcvideocall.model.SwitchCallState
import com.netease.yunxin.nertc.ui.base.CallParam
import com.netease.yunxin.nertc.ui.base.Constants
import com.netease.yunxin.nertc.ui.base.launchTask
import com.netease.yunxin.nertc.ui.floating.FloatingTouchEventStrategy
import com.netease.yunxin.nertc.ui.floating.FloatingWindowObserver
import com.netease.yunxin.nertc.ui.floating.FloatingWindowWrapper
import com.netease.yunxin.nertc.ui.p2p.CallUIOperationsMgr
import com.netease.yunxin.nertc.ui.p2p.FloatingView
import com.netease.yunxin.nertc.ui.p2p.IFloatingView
import com.netease.yunxin.nertc.ui.p2p.P2PUIConfig
import com.netease.yunxin.nertc.ui.utils.CallUILog
import com.netease.yunxin.nertc.ui.utils.CallUIUtils
import com.netease.yunxin.nertc.ui.utils.SwitchCallTypeConfirmDialog

object FloatingWindowManager {

    private const val TAG = "FloatingWindowManager"
    private const val REQUEST_CODE_FLOAT = 21301

    private var floatContentView: IFloatingView? = null
    private var floatingWindowWrapper: FloatingWindowWrapper? = null
    private var dialog: SwitchCallTypeConfirmDialog? = null
    private var dialogFlag: Any? = null

    /**
     * 用于用户展示自己的切换弹窗样式
     */
    private var switchCallTypeConfirmDialogProvider: ((Activity) -> SwitchCallTypeConfirmDialog?)? = null

    /**
     * 浮窗观察者列表
     */
    private val observers = mutableListOf<FloatingWindowObserver>()

    /**
     * 配置通话结束及通话类型变化监听
     */
    private val delegate = object : NECallEngineDelegateAbs() {
        override fun onCallTypeChange(info: NECallTypeChangeInfo?) {
            super.onCallTypeChange(info)
            info ?: return

            if (info.state == SwitchCallState.INVITE && dialog?.isShowing != true) {
                showSwitchCallTypeConfirmDialog(info)
                return
            }

            if (info.state != SwitchCallState.ACCEPT) {
                return
            }
            if (info.callType == NECallType.VIDEO) {
                // 视频
                CallUIOperationsMgr.doMuteVideo(false)
                // 扬声器
                CallUIOperationsMgr.doConfigSpeaker(true)
                // 音频
                CallUIOperationsMgr.doMuteAudio(false)
                // 背景虚化
                CallUIOperationsMgr.doVirtualBlur(false)
            } else {
                // 视频
                CallUIOperationsMgr.doMuteVideo(true)
                // 扬声器
                CallUIOperationsMgr.doConfigSpeaker(false)
                // 音频
                CallUIOperationsMgr.doMuteAudio(false)
                // 背景虚化
                CallUIOperationsMgr.doVirtualBlur(false)
            }
            // 初始化状态，不同通话类型
            if (info.callType == NECallType.AUDIO) {
                floatContentView?.transToAudioUI()
            } else if (info.callType == NECallType.VIDEO) {
                floatContentView?.transToVideoUI()
            }
            // 用于浮窗在左侧时变化ui时浮窗没有吸附
            floatingWindowWrapper?.toUpdateViewContent()
        }

        override fun onCallEnd(info: NECallEndInfo?) {
            super.onCallEnd(info)
            floatingWindowWrapper?.let {
                CallUIUtils.showToastWithCallEndReason(
                    it.context,
                    info?.reasonCode ?: NEHangupReasonCode.NORMAL
                )
            }

            innerRelease(true)
        }
    }

// -----------------------------------------------------

    /**
     * 展示悬浮窗
     *
     * @param context 上下文
     */
    @JvmOverloads
    fun showFloat(
        context: Context,
        uiConfig: P2PUIConfig? = null,
        floatingView: IFloatingView? = null,
        windowLayoutParams: WindowManager.LayoutParams? = null,
        touchEventStrategy: FloatingTouchEventStrategy? = null

    ) {
        CallUILog.dApi(
            TAG,
            ParameterMap("showFloat").append("context", context).append("uiConfig", uiConfig)
        )
        NECallEngine.sharedInstance().addCallDelegate(delegate)
        if (floatingView != null && floatingView !is View) {
            throw IllegalArgumentException("floatingView$floatingView must be a view instance.")
        }
        floatContentView = floatingView ?: FloatingView(context)
        if (floatContentView is View) {
            registerFullScreenActionForView(context, floatContentView as View)
        }

        val builder = FloatingWindowWrapper.Builder()
            .windowYPos(400)
        windowLayoutParams?.run {
            builder.windowLayoutParams(this)
        }
        touchEventStrategy?.run {
            builder.touchEventStrategy(this)
        }
        floatingWindowWrapper = builder.build(context)
            .apply {
                showView(floatContentView as View)
            }
        floatContentView?.run {
            toInit()
            when (NECallEngine.sharedInstance().callInfo.callType) {
                NECallType.AUDIO -> {
                    transToAudioUI()
                }

                NECallType.VIDEO -> {
                    transToVideoUI()
                }

                else -> {
                    CallUILog.e(TAG, "unknown call type")
                }
            }
        }
        // 避免在全屏/小窗切换时丢失音视频切换弹窗
        val info = CallUIOperationsMgr.currentSwitchTypeCallInfo() ?: return
        if (dialog?.isShowing == true || info.state != SwitchCallState.INVITE) {
            return
        }
        showSwitchCallTypeConfirmDialog(info)
    }

    fun registerFullScreenActionForView(context: Context, view: View) {
        view.setOnClickListener {
            notifyObservers()
        }
    }

    /**
     * 配置音视频通话切换确认弹窗
     */
    fun configSwitchCallTypeConfirmDialogProvider(provider: (Activity) -> SwitchCallTypeConfirmDialog?) {
        this.switchCallTypeConfirmDialogProvider = provider
    }

    /**
     * 注册浮窗观察者
     *
     * @param observer 观察者
     */
    fun addFloatWindowObserver(observer: FloatingWindowObserver) {
        if (!observers.contains(observer)) {
            observers.add(observer)
            CallUILog.d(TAG, "registerObserver: ${observer.javaClass.simpleName}")
        }
    }

    /**
     * 取消注册浮窗观察者
     *
     * @param observer 观察者
     */
    fun removeFloatWindowObserver(observer: FloatingWindowObserver) {
        if (observers.remove(observer)) {
            CallUILog.d(TAG, "unregisterObserver: ${observer.javaClass.simpleName}")
        }
    }

    /**
     * 通知所有观察者浮窗被点击
     */
    private fun notifyObservers() {
        observers.forEach { observer ->
            try {
                observer.onFloatWindowClick()
            } catch (e: Exception) {
                CallUILog.e(TAG, "notifyObserver error: ${observer.javaClass.simpleName}", e)
            }
        }
    }

    /**
     * 销毁悬浮窗
     */
    fun releaseFloat(isFinished: Boolean = true) {
        CallUILog.dApi(TAG, ParameterMap("releaseFloat"))
        innerRelease(isFinished)
    }

    /**
     * 是否正在展示浮窗
     */
    fun isFloating(): Boolean {
        return floatingWindowWrapper != null
    }

    /**
     * 展示音视频切换确认弹窗
     */
    private fun showSwitchCallTypeConfirmDialog(info: NECallTypeChangeInfo) {
        if (dialogFlag != null) {
            return
        }
        dialogFlag = Any()
        floatingWindowWrapper?.context?.run {
            launchTask(this, REQUEST_CODE_FLOAT, { activity, _ ->
                CallUILog.d(TAG, "showSwitchCallTypeConfirmDialog")
                dialog =
                    switchCallTypeConfirmDialogProvider?.invoke(activity) ?: SwitchCallTypeConfirmDialog(
                        activity,
                        {
                            CallUIOperationsMgr.doSwitchCallType(
                                info.callType,
                                SwitchCallState.ACCEPT,
                                null
                            )
                        },
                        {
                            CallUIOperationsMgr.doSwitchCallType(
                                info.callType,
                                SwitchCallState.REJECT,
                                null
                            )
                        }
                    ).apply {
                        setOnDismissListener {
                            activity.finish()
                        }
                        show(info.callType)
                        val latestInfo = CallUIOperationsMgr.currentSwitchTypeCallInfo()
                        if (latestInfo?.state != SwitchCallState.INVITE) {
                            dismiss()
                        }
                    }
                dialogFlag = null
            }, {})
        }
    }

    private fun innerRelease(isFinished: Boolean) {
        CallUILog.d(TAG, ParameterMap("innerRelease").toValue())
        NECallEngine.sharedInstance().removeCallDelegate(delegate)
        CallUIOperationsMgr.configTimeTick(null)
        floatContentView?.toDestroy(isFinished)
        floatingWindowWrapper?.dismissView()
        floatingWindowWrapper = null
        dialog?.dismiss()
        dialog = null
        dialogFlag = null
        observers.clear()
    }

    /**
     * 启动对应页面
     */
    private fun launch(
        context: Context,
        clazz: Class<out Activity>,
        callParam: CallParam
    ) {
        CallUILog.dApi(
            TAG,
            ParameterMap("launch")
                .append("context", context)
                .append("callParam", callParam)
        )
        val intent = Intent(context, clazz).apply {
            putExtra(Constants.PARAM_KEY_CALL, callParam)
            if (context !is Activity) {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            putExtra(Constants.PARAM_KEY_FLAG_IS_FROM_FLOATING_WINDOW, true)
        }
        context.startActivity(intent)
    }
}
