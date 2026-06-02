/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.banner

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.call.p2p.NECallEngine
import com.netease.yunxin.kit.call.p2p.model.NECallEndInfo
import com.netease.yunxin.kit.call.p2p.model.NECallEngineDelegateAbs
import com.netease.yunxin.kit.call.p2p.model.NEHangupReasonCode
import com.netease.yunxin.kit.call.p2p.param.NEHangupParam
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.permission.CallMediaPermissionPolicy
import com.netease.yunxin.nertc.ui.utils.isGranted
import com.netease.yunxin.nertc.ui.utils.toastShort

/**
 * 来电方信息数据类
 *
 * @param accId       来电方账号 ID
 * @param displayName 来电方显示名称（昵称）
 * @param avatarUrl   来电方头像 URL，可为 null
 * @param callType    通话类型，参考 [com.netease.yunxin.kit.call.p2p.model.NECallType]
 */
data class CallerInfo(
    val accId: String,
    val displayName: String,
    val avatarUrl: String?,
    val callType: Int,
    val isMultiCallInvite: Boolean = false
)

/**
 * 来电横幅管理器（单例）。
 *
 * 横幅通过 WindowManager TYPE_APPLICATION_OVERLAY 挂载，
 * 悬浮在所有界面之上（含应用外），Activity 切换时无闪烁，对齐 iOS UIWindow 方案。
 * 需要 SYSTEM_ALERT_WINDOW 权限。
 */
object IncomingCallBannerManager {

    private const val TAG = "IncomingCallBannerManager"

    private var bannerView: IncomingCallBannerView? = null
    private var bannerContext: Context? = null

    /**
     * 标记用户已主动导航到通话页面（点击横幅主体或接听），
     * 用于防止 tryResumeInvitedUI 在 app 进前台时重复展示横幅。
     */
    @Volatile
    var navigatedToCallPage = false
        private set

    private val callEngineDelegate = object : NECallEngineDelegateAbs() {
        override fun onCallEnd(info: NECallEndInfo?) {
            val toastResId = info?.reasonCode?.let(::incomingBannerCallEndToastResId)
            val toastContext = bannerContext
            ALog.i(TAG, "dismissIncomingBanner reason=callEnded reasonCode=${info?.reasonCode}")
            Handler(Looper.getMainLooper()).post {
                dismiss()
                if (toastResId != null && toastContext != null) {
                    toastContext.getString(toastResId).toastShort(toastContext)
                }
                NECallEngine.sharedInstance().removeCallDelegate(this)
            }
        }
    }

    /**
     * 检查是否有悬浮窗权限。
     */
    fun hasOverlayPermission(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(context)
        } else {
            true
        }
    }

    /**
     * 跳转系统设置页申请悬浮窗权限。
     */
    fun requestOverlayPermission(activity: Activity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:${activity.packageName}")
            )
            activity.startActivity(intent)
        }
    }

    /**
     * 标记已导航到通话页面，阻止 tryResumeInvitedUI 重复展示横幅。
     */
    fun setNavigatedToCallPage() {
        navigatedToCallPage = true
    }

    /**
     * 异步更新横幅中展示的昵称。
     */
    fun updateCallerName(name: String) {
        bannerView?.updateCallerName(name)
    }

    /**
     * 异步更新横幅中展示的头像。
     */
    fun updateAvatarUrl(url: String?) {
        bannerView?.updateAvatarUrl(url)
    }

    /**
     * 展示来电横幅。
     *
     * @param context    Context（取 applicationContext 使用）
     * @param callerInfo 来电方信息
     * @param onBodyTap  点击横幅主体的回调（由调用方负责跳转全屏页，铃声不中断）
     * @return true 表示成功展示，false 表示无悬浮窗权限（调用方可降级为通知）
     */
    fun show(context: Context, callerInfo: CallerInfo, onBodyTap: (() -> Unit)? = null): Boolean {
        return show(context, callerInfo, onBodyTap, onBodyTap)
    }

    /**
     * 展示来电横幅。
     *
     * @param context    Context（取 applicationContext 使用）
     * @param callerInfo 来电方信息
     * @param onBodyTap  点击横幅主体的回调（由调用方负责跳转全屏页，铃声不中断）
     * @param onAcceptNavigate 点击接听后的回调（由调用方负责跳转全屏页并在权限通过后接听）
     * @return true 表示成功展示，false 表示无悬浮窗权限（调用方可降级为通知）
     */
    fun show(
        context: Context,
        callerInfo: CallerInfo,
        onBodyTap: (() -> Unit)?,
        onAcceptNavigate: (() -> Unit)?
    ): Boolean {
        ALog.i(TAG, "showIncomingBanner callerAccId=${callerInfo.accId} callType=${callerInfo.callType}")

        if (!hasOverlayPermission(context)) {
            ALog.w(TAG, "No overlay permission, cannot show banner.")
            return false
        }

        if (bannerView != null) dismiss()

        // 新来电时重置导航标志
        navigatedToCallPage = false
        bannerContext = context.applicationContext

        val view = IncomingCallBannerView(
            context = context.applicationContext,
            callerInfo = callerInfo,
            onDismissCallback = { bannerView = null },
            onBodyTapCallback = onBodyTap,
            onRejectCallback = {
                ALog.i(TAG, "rejectCall")
                NECallEngine.sharedInstance().hangup(NEHangupParam(), null)
            },
            onAcceptCallback = {
                val hasMediaPermission =
                    context.applicationContext.hasIncomingBannerMediaPermission(callerInfo)
                val acceptAction = resolveIncomingBannerAcceptAction(hasMediaPermission)
                ALog.i(
                    TAG,
                    "bannerAcceptTapped: hasMediaPermission=$hasMediaPermission, " +
                        "acceptInBanner=${acceptAction.acceptInBanner}, " +
                        "autoAcceptInCallPage=${acceptAction.autoAcceptInCallPage}"
                )
                runIncomingBannerAcceptFlow(
                    hasMediaPermission = hasMediaPermission,
                    navigateToCallPage = {
                        setNavigatedToCallPage()
                        onAcceptNavigate?.invoke()
                    },
                    acceptCall = { onFinished ->
                        NECallEngine.sharedInstance().accept { result ->
                            ALog.d(TAG, "accept result=$result")
                            Handler(Looper.getMainLooper()).post {
                                onFinished()
                            }
                        }
                    },
                    dismissBanner = {
                        dismiss()
                    }
                )
            }
        )
        bannerView = view
        NECallEngine.sharedInstance().addCallDelegate(callEngineDelegate)
        view.show()
        return true
    }

    fun dismiss() {
        ALog.i(TAG, "dismissIncomingBanner reason=userAction")
        NECallEngine.sharedInstance().removeCallDelegate(callEngineDelegate)
        bannerView?.dismiss()
        bannerView = null
        bannerContext = null
    }

    fun isShowing(): Boolean = bannerView?.isShowing() == true
}

internal fun incomingBannerCallEndToastResId(reasonCode: Int): Int? {
    return when (reasonCode) {
        NEHangupReasonCode.CALLEE_CANCELED -> R.string.tip_cancel_by_other
        NEHangupReasonCode.OTHER_REJECTED -> R.string.tip_other_client_other_reject
        NEHangupReasonCode.OTHER_ACCEPTED -> R.string.tip_other_client_other_accept
        else -> null
    }
}

internal data class IncomingBannerAcceptAction(
    val acceptInBanner: Boolean,
    val autoAcceptInCallPage: Boolean
)

internal fun resolveIncomingBannerAcceptAction(hasMediaPermission: Boolean): IncomingBannerAcceptAction {
    return IncomingBannerAcceptAction(
        acceptInBanner = hasMediaPermission,
        autoAcceptInCallPage = !hasMediaPermission
    )
}

internal fun runIncomingBannerAcceptFlow(
    hasMediaPermission: Boolean,
    navigateToCallPage: () -> Unit,
    acceptCall: (onFinished: () -> Unit) -> Unit,
    dismissBanner: () -> Unit
) {
    val acceptAction = resolveIncomingBannerAcceptAction(hasMediaPermission)
    navigateToCallPage()
    if (acceptAction.acceptInBanner) {
        acceptCall {
            dismissBanner()
        }
    } else {
        dismissBanner()
    }
}

internal fun Context.hasIncomingBannerMediaPermission(callerInfo: CallerInfo): Boolean {
    return hasIncomingBannerMediaPermission(callerInfo.callType, callerInfo.isMultiCallInvite)
}

internal fun Context.hasIncomingBannerMediaPermission(
    callType: Int,
    isMultiCallInvite: Boolean
): Boolean {
    return if (
        CallMediaPermissionPolicy.requiresCameraPermission(
                callType,
                isMultiCallInvite
            )
    ) {
        isGranted(Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO)
    } else {
        isGranted(Manifest.permission.RECORD_AUDIO)
    }
}
