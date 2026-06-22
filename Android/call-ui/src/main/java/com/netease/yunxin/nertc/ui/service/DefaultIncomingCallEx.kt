/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.core.app.NotificationCompat
import com.netease.yunxin.kit.call.group.NEGroupCallInfo
import com.netease.yunxin.kit.call.p2p.NECallEngine
import com.netease.yunxin.kit.call.p2p.model.NEInviteInfo
import com.netease.yunxin.kit.call.p2p.param.NEHangupParam
import com.netease.yunxin.nertc.ui.CallKitNotificationConfig
import com.netease.yunxin.nertc.ui.CallKitUI
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.banner.CallerInfo
import com.netease.yunxin.nertc.ui.banner.IncomingCallBannerManager
import com.netease.yunxin.nertc.ui.banner.hasIncomingBannerMediaPermission
import com.netease.yunxin.nertc.ui.banner.resolveIncomingBannerAcceptAction
import com.netease.yunxin.nertc.ui.base.UserInfoExtensionHelper
import com.netease.yunxin.nertc.ui.base.toCallIntent
import com.netease.yunxin.nertc.ui.floating.FloatingPermission
import com.netease.yunxin.nertc.ui.utils.CallUILog

open class DefaultIncomingCallEx : IncomingCallEx() {

    protected val notificationManager: NotificationManager by lazy {
        context!!.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    }

    override fun onIncomingCall(invitedInfo: NEGroupCallInfo): Boolean {
        CallUILog.d(TAG, "onIncomingCall for group, invitedInfo is $invitedInfo.")
        // 直接呼起
        context!!.startActivity(invitedInfo.toCallIntent())
        // 生成通知并提醒
        generateNotificationAndNotifyForGroup(invitedInfo)
        return false
    }

    override fun onIncomingCall(invitedInfo: NEInviteInfo): Boolean {
        CallUILog.d(TAG, "onIncomingCall, invitedInfo is $invitedInfo.")
        // 横幅模式分支：enableIncomingBanner == true 时走横幅逻辑，跳过来电 Activity 启动
        if (CallKitUI.options?.enableIncomingBanner == true) {
            // T036：并发来电检查——若横幅已显示，向第二路来电回复忙线
            if (IncomingCallBannerManager.isShowing()) {
                CallUILog.i(TAG, "secondCallIgnored replyBusy callerAccId=${invitedInfo.callerAccId}")
                NECallEngine.sharedInstance().hangup(NEHangupParam(), null)
                return false
            }
            val callerAccId = invitedInfo.callerAccId ?: ""
            CallUILog.i(TAG, "showIncomingBanner callerAccId=$callerAccId callType=${invitedInfo.callType}")
            val shown = IncomingCallBannerManager.show(
                context = context!!,
                callerInfo = CallerInfo(
                    accId = callerAccId,
                    displayName = callerAccId,  // 先用 accId 兜底，昵称异步更新
                    avatarUrl = null,
                    callType = invitedInfo.callType,
                    isMultiCallInvite = invitedInfo.multiCallInvite
                ),
                onBodyTap = {
                    navigateToIncomingCallActivity(invitedInfo, "bannerBodyTapped")
                },
                onAcceptNavigate = {
                    navigateToIncomingCallActivity(invitedInfo, "bannerAcceptTapped")
                }
            )
            if (shown) {
                // 异步获取昵称和头像并更新横幅
                fetchAndUpdateBannerUserInfo(callerAccId)
                return false
            }
            // 无悬浮窗权限，降级为普通来电通知
            CallUILog.i(TAG, "bannerFallback → notification (no overlay permission)")
        }
        // 直接呼起
        context!!.startActivity(invitedInfo.toCallIntent())
        // 生成通知并提醒
        generateNotificationAndNotify(invitedInfo)
        return false
    }

    override fun onIncomingCallInvalid(invitedInfo: NEGroupCallInfo?) {
        cancelNotification()
    }

    override fun onIncomingCallInvalid(invitedInfo: NEInviteInfo?) {
        cancelNotification()
    }

    /**
     * 异步获取来电方昵称和头像，并更新横幅展示。
     */
    private fun fetchAndUpdateBannerUserInfo(callerAccId: String) {
        val helper = UserInfoExtensionHelper.userInfoHelper ?: return
        helper.fetchNickname(callerAccId) { name ->
            CallUILog.d(TAG, "fetchNickname callerAccId=$callerAccId name=$name")
            IncomingCallBannerManager.updateCallerName(name)
        }
        context?.let { ctx ->
            helper.fetchAvatar(ctx, callerAccId) { url, _ ->
                CallUILog.d(TAG, "fetchAvatar callerAccId=$callerAccId url=$url")
                IncomingCallBannerManager.updateAvatarUrl(url)
            }
        }
    }

    protected open fun generateNotificationAndNotifyForGroup(invitedInfo: NEGroupCallInfo) {
        generateNotificationAndNotify(
            invitedInfo.toCallIntent(),
            invitedInfo.callerAccId,
            uiService!!.getNotificationConfig(invitedInfo),
            isMultiCallInvite = false
        )
    }

    protected open fun generateNotificationAndNotify(invitedInfo: NEInviteInfo) {
        generateNotificationAndNotify(
            invitedInfo.toCallIntent(),
            invitedInfo.callerAccId,
            uiService!!.getNotificationConfig(invitedInfo),
            invitedInfo.multiCallInvite
        )
    }

    private fun generateNotificationAndNotify(
        intent: Intent,
        invitor: String,
        config: CallKitNotificationConfig?,
        isMultiCallInvite: Boolean = false,
        fullScreen: Boolean = false
    ) {
        val pendingIntent = PendingIntent.getActivity(
            context,
            INCOMING_CALL_NOTIFY_ID,
            intent,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
        )

        val channelId = config?.channelId ?: INCOMING_CALL_CHANNEL
        val iconId = config?.notificationIconRes ?: R.drawable.nim_actionbar_dark_logo_icon
        val title =
            config?.title ?: context?.getString(R.string.tip_new_incoming_call) ?: "您有新的来电"
        val content = config?.content ?: if (isMultiCallInvite) {
            "$invitor:【多人通话邀请】"
        } else {
            "$invitor:【网络通话】"
        }

        val builder = NotificationCompat.Builder(context!!, channelId)
            .setContentTitle(title)
            .setContentText(content)
            .setOngoing(true)
            .setContentIntent(pendingIntent)
            .setSmallIcon(iconId)
            .setTimeoutAfter(CallKitUI.options?.timeOutMillisecond ?: 0)
            .setPriority(if (fullScreen) NotificationCompat.PRIORITY_MAX else NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setAutoCancel(false)
            .setDefaults(Notification.DEFAULT_LIGHTS)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)

        if (fullScreen) {
            builder.setFullScreenIntent(pendingIntent, true)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // 用户可见的通道名称
            val notificationChannel =
                NotificationChannel(
                    channelId,
                    context?.getString(R.string.tip_notification_channel_name)
                        ?: "音视频通话邀请通知",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = context?.getString(R.string.tip_notification_channel_description)
                        ?: "用于接收音视频通话邀请时提示。"
                    enableLights(true)
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                    setBypassDnd(true)
                    enableVibration(true)
                }
            notificationManager.createNotificationChannel(notificationChannel)
        }
        notificationManager.notify(INCOMING_CALL_NOTIFY_ID, builder.build())
    }

    /**
     * 跳转到接通页面的intent
     *
     * @return
     */
    protected open fun NEInviteInfo.toCallIntent(): Intent {
        return this.toCallIntent(context!!)
    }

    protected open fun NEGroupCallInfo.toCallIntent(): Intent {
        return this.toCallIntent(context!!)
    }

    private fun navigateToIncomingCallActivity(invitedInfo: NEInviteInfo, source: String) {
        IncomingCallBannerManager.setNavigatedToCallPage()
        val ctx = context ?: run {
            CallUILog.w(TAG, "$source → launchIncomingCallActivity skip: context is null")
            return
        }
        val autoAcceptFromIncomingBanner = if (source.startsWith("bannerAcceptTapped")) {
            val hasMediaPermission = ctx.applicationContext.hasIncomingBannerMediaPermission(
                invitedInfo.callType,
                invitedInfo.multiCallInvite
            )
            val acceptAction = resolveIncomingBannerAcceptAction(hasMediaPermission)
            CallUILog.i(
                TAG,
                "$source → resolveAcceptAction hasMediaPermission=$hasMediaPermission " +
                    "acceptInBanner=${acceptAction.acceptInBanner} " +
                    "autoAcceptInCallPage=${acceptAction.autoAcceptInCallPage}"
            )
            acceptAction.autoAcceptInCallPage
        } else {
            false
        }
        val action = action@{
            try {
                val intent = invitedInfo.toCallIntent(ctx, autoAcceptFromIncomingBanner)
                if (shouldLaunchIncomingCallWithNotification(
                        FloatingPermission.isBackgroundStartAllowed(ctx)
                    )) {
                    CallUILog.i(TAG, "$source → launchIncomingCallActivity useFullScreenNotification")
                    generateNotificationAndNotify(
                        intent,
                        invitedInfo.callerAccId ?: "",
                        uiService!!.getNotificationConfig(invitedInfo),
                        invitedInfo.multiCallInvite,
                        fullScreen = true
                    )
                    sendIncomingCallPendingIntent(ctx, intent, source)
                    return@action
                }
                CallUILog.i(TAG, "$source → launchIncomingCallActivity keepRing")
                ctx.startActivity(intent)
            } catch (throwable: Throwable) {
                CallUILog.e(TAG, "$source → launchIncomingCallActivity failed", throwable)
            }
        }
        if (Looper.myLooper() == Looper.getMainLooper()) {
            action()
        } else {
            Handler(Looper.getMainLooper()).post(action)
        }
    }

    private fun sendIncomingCallPendingIntent(ctx: Context, intent: Intent, source: String) {
        try {
            val pendingIntent = PendingIntent.getActivity(
                ctx,
                INCOMING_CALL_NOTIFY_ID,
                intent,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                } else {
                    PendingIntent.FLAG_UPDATE_CURRENT
                }
            )
            pendingIntent.send()
            CallUILog.i(TAG, "$source → launchIncomingCallActivity pendingIntentSent")
        } catch (throwable: Throwable) {
            CallUILog.e(TAG, "$source → launchIncomingCallActivity pendingIntentFailed", throwable)
        }
    }

    protected open fun cancelNotification() {
        try {
            notificationManager.cancel(INCOMING_CALL_NOTIFY_ID)
        } catch (ignored: Exception) {
            CallUILog.e(TAG, "cancelNotification", ignored)
        }
    }

    override fun tryResumeInvitedUI(invitedInfo: NEInviteInfo): Boolean {
        // T041：前台重显——横幅模式开启时的恢复逻辑
        if (CallKitUI.options?.enableIncomingBanner == true) {
            // 若用户已通过横幅点击/接听主动导航到通话页面，不重复展示横幅
            if (IncomingCallBannerManager.navigatedToCallPage) {
                CallUILog.i(TAG, "tryResumeInvitedUI skip reShowBanner: already navigated to call page")
                return true
            }
            if (!IncomingCallBannerManager.isShowing()) {
                val callerAccId = invitedInfo.callerAccId ?: ""
                CallUILog.i(TAG, "tryResumeInvitedUI reShowBanner callerAccId=$callerAccId")
                val ctx = context ?: return false
                val shown = IncomingCallBannerManager.show(
                    context = ctx,
                    callerInfo = CallerInfo(
                        accId = callerAccId,
                        displayName = callerAccId,
                        avatarUrl = null,
                        callType = invitedInfo.callType,
                        isMultiCallInvite = invitedInfo.multiCallInvite
                    ),
                    onBodyTap = {
                        navigateToIncomingCallActivity(invitedInfo, "bannerBodyTapped(resume)")
                    },
                    onAcceptNavigate = {
                        navigateToIncomingCallActivity(invitedInfo, "bannerAcceptTapped(resume)")
                    }
                )
                if (shown) {
                    fetchAndUpdateBannerUserInfo(callerAccId)
                }
            }
            return true
        }
        val intent = invitedInfo.toCallIntent()
        // 直接呼起
        context?.startActivity(intent) ?: run {
            CallUILog.d("NERTCVideoCallImpl", "start new call In!")
            return false
        }
        CallUILog.d("NERTCVideoCallImpl", "start new call In!")
        return true
    }

    override fun tryResumeInvitedUI(invitedInfo: NEGroupCallInfo): Boolean {
        val intent = invitedInfo.toCallIntent()
        // 直接呼起
        context?.startActivity(intent) ?: run {
            CallUILog.d("NERTCVideoCallImpl", "start new group call In!")
            return false
        }
        CallUILog.d("NERTCVideoCallImpl", "start new group call In!")
        return true
    }

    companion object {
        const val TAG = "DefaultIncomingCallEx"

        const val INCOMING_CALL_CHANNEL = "incoming_call_notification_channel_id_133"

        const val INCOMING_CALL_NOTIFY_ID = 1025
    }
}

internal fun shouldLaunchIncomingCallWithNotification(
    backgroundStartAllowed: Boolean
): Boolean {
    return !backgroundStartAllowed
}
