/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.flutter.plugins.callkit

import android.content.Context
import com.netease.lava.nertc.sdk.NERtcASRCaptionConfig
import com.netease.lava.nertc.sdk.NERtcConstants
import com.netease.lava.nertc.sdk.NERtcOption
import com.netease.lava.nertc.sdk.video.NERtcTextureView
import com.netease.yunxin.flutter.plugins.callkit.pigeon.Pigeon
import com.netease.yunxin.flutter.plugins.callkit.videorenderer.VideoRendererApiImpl
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.call.p2p.NECallEngine
import com.netease.yunxin.kit.call.p2p.extra.DefaultNERecordProvider
import com.netease.yunxin.kit.call.p2p.model.NECallConfig
import com.netease.yunxin.kit.call.p2p.model.NECallEndInfo
import com.netease.yunxin.kit.call.p2p.model.NECallEngineDelegate
import com.netease.yunxin.kit.call.p2p.model.NECallInfo
import com.netease.yunxin.kit.call.p2p.model.NECallInitRtcMode
import com.netease.yunxin.kit.call.p2p.model.NECallPushConfig
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.kit.call.p2p.model.NECallTypeChangeInfo
import com.netease.yunxin.kit.call.p2p.model.NEInviteInfo
import com.netease.yunxin.kit.call.p2p.model.NERecord
import com.netease.yunxin.kit.call.p2p.model.NERecordCallStatus
import com.netease.yunxin.kit.call.p2p.model.NERecordProvider
import com.netease.yunxin.kit.call.p2p.model.NESetupConfig
import com.netease.yunxin.kit.call.p2p.param.NECallParam
import com.netease.yunxin.kit.call.p2p.param.NEHangupParam
import com.netease.yunxin.kit.call.p2p.param.NESwitchParam
import io.flutter.embedding.engine.plugins.FlutterPlugin

interface IPlatform {

    fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding)

    fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding)
}

class CallKitPlatform : Pigeon.CallKitApi, IPlatform, NECallEngineDelegate, NERecordProvider {

    companion object {
        private const val TAG = "CallKitPlatform"

        internal fun resolveRemoteViewId(viewId: Long?): Int? {
            if (viewId == null || viewId < 0) {
                return null
            }
            return viewId.toInt()
        }
    }

    private lateinit var applicationContext: Context
    private var mVideoViewFactory: PlatformVideoViewFactory? = null
    private var mEventSink: Pigeon.CallKitEventSink? = null
    private var callExtension: NECallExtension? = null

    private fun createVoidReply(methodName: String): Pigeon.CallKitEventSink.Reply<Void> {
        return Pigeon.CallKitEventSink.Reply<Void> {
            ALog.d(TAG, "$methodName callback reply")
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        Pigeon.CallKitApi.setup(binding.binaryMessenger, this)
        mVideoViewFactory = PlatformVideoViewFactory(binding.binaryMessenger)
        binding.platformViewRegistry.registerViewFactory(PlatformVideoViewFactory.SIGN, mVideoViewFactory!!)
        mEventSink = Pigeon.CallKitEventSink(binding.binaryMessenger)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Pigeon.CallKitApi.setup(binding.binaryMessenger, null)
    }

    override fun setup(config: Pigeon.SetupConfig, result: Pigeon.Result<Pigeon.SimpleResponse>) {
        try {
            // 注意：lckConfig 参数在 Android 端被忽略，因为 Live Communication Kit 仅支持 iOS
            // config.lckConfig 包含 enableLiveCommunicationKit 和 ringtoneName 参数
            // 这些参数在 Android 端不需要处理

            val initRtcMode = if (config.initRtcMode == Pigeon.CallInitRtcMode.IN_NEED_DELAY_TO_ACCEPT) {
                NECallInitRtcMode.IN_NEED_DELAY_TO_ACCEPT
            } else if (config.initRtcMode == Pigeon.CallInitRtcMode.IN_NEED) {
                NECallInitRtcMode.IN_NEED
            } else {
                NECallInitRtcMode.GLOBAL
            }
            callExtension = NECallExtension(object : NECallExtension.CallKitPlatformCallback {
                override fun onAsrCaptionResult(result: Array<com.netease.lava.nertc.sdk.NERtcAsrCaptionResult>?, resultCount: Int) {
                    this@CallKitPlatform.onAsrCaptionResult(result, resultCount)
                }

                override fun onAsrCaptionStateChanged(asrState: Int, code: Int, message: String) {
                    this@CallKitPlatform.onAsrCaptionStateChanged(asrState, code, message)
                }
            })
            NECallEngine.sharedInstance().setup(
                applicationContext,
                NESetupConfig.Builder(config.appKey)
                    .initRtcMode(initRtcMode)
                    .currentUserRtcUid(config.currentUserRtcUid ?: 0)
                    .rtcOption(NERtcOption().apply {
                        logLevel = NERtcConstants.LogLevel.INFO
                        // 注入共享的 EGL 上下文，确保渲染器和 SDK 使用同一上下文
                        eglContext = VideoRendererApiImpl.getSharedEglContextWrapper()
                    })
                    .enableJoinRtcWhenCall(config.enableJoinRtcWhenCall ?: false)
                    .rtcCallExtension(callExtension)
                    .framework("Flutter")
                    .build()
            )
            NECallEngine.sharedInstance().removeCallDelegate(this)
            NECallEngine.sharedInstance().addCallDelegate(this)
            val response = Pigeon.SimpleResponse.Builder()
                .setCode(0L)
                .setMsg("Setup successful")
                .build()
            result.success(response)
        } catch (e: Exception) {
            result.error(e)
        }
    }

    override fun getVersion(): String {
        return NECallEngine.getVersion()
    }

    override fun call(param: Pigeon.CallParam, result: Pigeon.Result<Pigeon.CallResponse>) {
        try {
            val pushConfig = param.pushConfig?.let {
                NECallPushConfig(it.needPush, it.pushTitle, it.pushContent, it.pushPayload, it.needBadge)
            }
            val callParam = NECallParam.Builder(param.accId)
                .callType(
                    if (param.callType == com.netease.yunxin.flutter.plugins.callkit.pigeon.Pigeon.CallType.VIDEO) {
                        NECallType.VIDEO
                    } else {
                        NECallType.AUDIO
                    }
                )
                .rtcChannelName(param.rtcChannelName)
                .extraInfo(param.extraInfo)
                .pushConfig(pushConfig)
                .globalExtraCopy(param.globalExtraCopy)
                .build()

            NECallEngine.sharedInstance().call(callParam) { ret ->
                // ret 是 CommonResult<NECallInfo>，这里同时返回 code/msg 以及 callInfo 给 Flutter
                val neCallInfo = ret?.data
                val pigeonCallInfo = neCallInfo?.let { neCallInfo2CallInfo(it) }

                val response = Pigeon.CallResponse.Builder()
                    .setCode(ret?.code?.toLong() ?: -1L)
                    .setMsg(ret?.msg)
                    .setCallInfo(pigeonCallInfo)
                    .build()

                result.success(response)
            }
        } catch (e: Exception) {
            result.error(e)
        }
    }

    override fun accept(result: Pigeon.Result<Pigeon.CallResponse>) {
        try {
            NECallEngine.sharedInstance().accept() { ret ->
                // ret 是 CommonResult<NECallInfo>，这里同时返回 code/msg 以及 callInfo 给 Flutter
                val neCallInfo = ret?.data
                val pigeonCallInfo = neCallInfo?.let { neCallInfo2CallInfo(it) }

                val response = Pigeon.CallResponse.Builder()
                    .setCode(ret?.code?.toLong() ?: -1L)
                    .setMsg(ret?.msg)
                    .setCallInfo(pigeonCallInfo)
                    .build()

                result.success(response)
            }
        } catch (e: Exception) {
            result.error(e)
        }
    }

    override fun hangup(param: Pigeon.HangupParam, result: Pigeon.Result<Pigeon.SimpleResponse>) {
        try {
            val callParam = NEHangupParam(param.channelId, param.extraString)
            NECallEngine.sharedInstance().hangup(callParam) { ret ->
                val response = Pigeon.SimpleResponse.Builder()
                    .setCode(ret?.code?.toLong() ?: -1L)
                    .setMsg(ret?.msg)
                    .build()
                result.success(response)
            }
        } catch (e: Exception) {
            result.error(e)
        }
    }

    override fun switchCallType(param: Pigeon.SwitchParam, result: Pigeon.Result<Pigeon.SimpleResponse>) {
        try {
            NECallEngine.sharedInstance().switchCallType(NESwitchParam(param.callType.ordinal, param.state.ordinal)) { p0 ->
                val response = Pigeon.SimpleResponse.Builder()
                    .setCode(p0?.code?.toLong() ?: -1L)
                    .setMsg(p0?.msg)
                    .build()
                result.success(response)
            }
        } catch (e: Exception) {
            result.error(e)
        }
    }

    override fun setupLocalView(param: Pigeon.ViewParam, result: Pigeon.Result<Pigeon.SimpleResponse>) {
        try {
            val platformVideoView = PlatformVideoViewFactory.mVideoViewMap[param.viewId!!.toInt()]
            val videoView: NERtcTextureView? = platformVideoView?.getVideoView()
            if (videoView != null) {
                val ret = NECallEngine.sharedInstance().setupLocalView(videoView)
                val response = Pigeon.SimpleResponse.Builder()
                    .setCode(ret.toLong())
                    .setMsg("")
                    .build()
                result.success(response)
            } else {
                val ret = NECallEngine.sharedInstance().setupLocalView(null)
                val response = Pigeon.SimpleResponse.Builder()
                    .setCode(ret.toLong())
                    .setMsg("VideoView not found for viewId: ${param.viewId}")
                    .build()
                result.success(response)
            }
        } catch (e: Exception) {
            result.error(e)
        }
    }

    override fun setupRemoteView(param: Pigeon.ViewParam, result: Pigeon.Result<Pigeon.SimpleResponse>) {
        try {
            val rawViewId = param.viewId
            val viewId = resolveRemoteViewId(rawViewId)
            val platformVideoView = viewId?.let { PlatformVideoViewFactory.mVideoViewMap[it] }
            val videoView: NERtcTextureView? = platformVideoView?.getVideoView()
            if (videoView != null) {
                val ret = NECallEngine.sharedInstance().setupRemoteView(videoView)
                val response = Pigeon.SimpleResponse.Builder()
                    .setCode(ret.toLong())
                    .setMsg("")
                    .build()
                result.success(response)
            } else {
                val response = Pigeon.SimpleResponse.Builder()
                    .setCode(-1)
                    .setMsg("VideoView not found for viewId: $rawViewId")
                    .build()
                result.success(response)
            }
        } catch (e: Exception) {
            result.error(e)
        }
    }

    override fun switchCamera(result: Pigeon.Result<Pigeon.SimpleResponse>) {
        try {
            NECallEngine.sharedInstance().switchCamera()
            val response = Pigeon.SimpleResponse.Builder()
                .setCode(0)
                .setMsg("")
                .build()
            result.success(response)
        } catch (e: Exception) {
            result.error(e)
        }
    }

    override fun isSpeakerphoneOn(result: Pigeon.Result<Boolean>) {
        try {
            val ret = NECallEngine.sharedInstance().isSpeakerphoneOn
            result.success(ret)
        } catch (e: Exception) {
            result.error(e)
        }
    }

    override fun setSpeakerphoneOn(enable: Boolean, result: Pigeon.Result<Pigeon.SimpleResponse>) {
        try {
            val ret = NECallEngine.sharedInstance().setSpeakerphoneOn(enable)
            val response = Pigeon.SimpleResponse.Builder()
                .setCode(ret.toLong())
                .setMsg("")
                .build()
            result.success(response)
        } catch (e: Exception) {
            result.error(e)
        }
    }

    override fun setCallConfig(config: Pigeon.CallConfig, result: Pigeon.Result<Pigeon.SimpleResponse>) {
        try {
            NECallEngine.sharedInstance().callConfig = NECallConfig.Builder()
                .enableSignalOffline(config.enableOffline)
                .enableSwitchAudioConfirm(config.enableSwitchAudioConfirm)
                .enableSwitchVideoConfirm(config.enableSwitchVideoConfirm)
                .build()
            val response = Pigeon.SimpleResponse.Builder()
                .setCode(0)
                .setMsg("")
                .build()
            result.success(response)
        } catch (e: Exception) {
            result.error(e)
        }
    }

    override fun getCallInfo(result: Pigeon.Result<Pigeon.CallInfo>) {
        try {
            NECallEngine.sharedInstance().callInfo?.let { callInfo ->
                val response = neCallInfo2CallInfo(callInfo)
                result.success(response)
            } ?: run {
                result.success(null)
            }
        } catch (e: Exception) {
            result.error(e)
        }
    }

    override fun getCallConfig(result: Pigeon.Result<Pigeon.CallConfig>) {
        try {
            NECallEngine.sharedInstance().callConfig?.let { callConfig ->
                val response = Pigeon.CallConfig.Builder()
                    .setEnableOffline(callConfig.enableOffline)
                    .setEnableSwitchVideoConfirm(callConfig.enableSwitchVideoConfirm)
                    .setEnableSwitchAudioConfirm(callConfig.enableSwitchAudioConfirm)
                    .build()
                result.success(response)
            } ?: run {
                result.success(null)
            }
        } catch (e: Exception) {
            result.error(e)
        }
    }

    override fun destroy(result: Pigeon.Result<Pigeon.SimpleResponse>) {
        try {
            NECallEngine.sharedInstance().destroy()
            VideoRendererApiImpl.releaseSharedEglContext()
            val response = Pigeon.SimpleResponse.Builder()
                .setCode(0L)
                .setMsg("Destroy successful")
                .build()
            result.success(response)
        } catch (e: Exception) {
            result.error(e)
        }
    }

    override fun muteLocalAudio(muted: Boolean, result: Pigeon.Result<Pigeon.SimpleResponse>) {
        try {
            val ret = NECallEngine.sharedInstance().muteLocalAudio(muted)
            val response = Pigeon.SimpleResponse.Builder()
                .setCode(ret.toLong())
                .setMsg("")
                .build()
            result.success(response)
        } catch (e: Exception) {
            result.error(e)
        }
    }

    override fun muteLocalVideo(muted: Boolean, result: Pigeon.Result<Pigeon.SimpleResponse>) {
        try {
            val ret = NECallEngine.sharedInstance().muteLocalVideo(muted)
            val response = Pigeon.SimpleResponse.Builder()
                .setCode(ret.toLong())
                .setMsg("")
                .build()
            result.success(response)
        } catch (e: Exception) {
            result.error(e)
        }
    }

    override fun enableLocalVideo(enable: Boolean, result: Pigeon.Result<Pigeon.SimpleResponse>) {
        try {
            val ret = NECallEngine.sharedInstance().enableLocalVideo(enable)

            val response = Pigeon.SimpleResponse.Builder()
                .setCode(ret.toLong())
                .setMsg("")
                .build()
            result.success(response)
        } catch (e: Exception) {
            result.error(e)
        }
    }

    override fun setTimeout(time: Long, result: Pigeon.Result<Pigeon.SimpleResponse>) {
        try {
            NECallEngine.sharedInstance().setTimeout(time * 1000)
            val response = Pigeon.SimpleResponse.Builder()
                .setCode(0L)
                .setMsg("")
                .build()
            result.success(response)
        } catch (e: Exception) {
            result.error(e)
        }
    }

    override fun onReceiveInvited(info: NEInviteInfo?) {
        info?.let { inviteInfo ->
            try {
                val pigeonInfo = Pigeon.InviteInfo.Builder()
                    .setCallerAccId(inviteInfo.callerAccId)
                    .setCallType(if (inviteInfo.callType == com.netease.yunxin.kit.call.p2p.model.NECallType.VIDEO) Pigeon.CallType.VIDEO else Pigeon.CallType.AUDIO)
                    .setExtraInfo(inviteInfo.extraInfo)
                    .setChannelId(inviteInfo.channelId)
                    .build()

                mEventSink?.onReceiveInvited(pigeonInfo, createVoidReply("onReceiveInvited"))
            } catch (e: Exception) {
                ALog.e(CallkitPlugin.TAG, "onReceiveInvited error: ${e.message}")
            }
        }
    }

    override fun onCallConnected(info: NECallInfo?) {
        info?.let {
            try {
                val pigeonInfo = neCallInfo2CallInfo(info)
                mEventSink?.onCallConnected(pigeonInfo) {
                    // 回调完成
                }
            } catch (e: Exception) {
                ALog.e(CallkitPlugin.TAG, "onCallConnected error: ${e.message}")
            }
        } ?: run {
            ALog.e(CallkitPlugin.TAG, "onCallConnected info is null")
        }
    }

    private fun neCallInfo2CallInfo(callInfo: NECallInfo): Pigeon.CallInfo {
        // 转换主叫方信息
        val callerInfo = callInfo.callerInfo?.let { userInfo ->
            Pigeon.UserInfo.Builder()
                .setAccId(userInfo.accId ?: "")
                .setUid(userInfo.uid)
                .build()
        }

        // 转换被叫方信息
        val calleeInfo = callInfo.calleeInfo?.let { userInfo ->
            Pigeon.UserInfo.Builder()
                .setAccId(userInfo.accId ?: "")
                .setUid(userInfo.uid)
                .build()
        }

        // 转换信令信息
        val signalInfo = callInfo.signalInfo?.let { signal ->
            Pigeon.SignalInfo.Builder()
                .setChannelId(signal.channelId ?: "")
                .setRequestId(signal.requestId ?: "")
                .setChannelName(signal.channelName ?: "")
                .setExtraInfo(signal.extraInfo ?: "")
                .setGlobalExtraCopy(signal.globalExtraCopy ?: "")
                .build()
        }

        // 转换RTC信息
        val rtcInfo = callInfo.rtcInfo?.let { rtc ->
            Pigeon.RtcInfo.Builder()
                .setChannelName(rtc.channelName)
                .setToken(rtc.token)
                .setCid(rtc.channelId)
                .setUid(0)
                .build()
        }
        return Pigeon.CallInfo.Builder()
            .setCallId(callInfo.callId ?: "")
            .setCurrentAccId(callInfo.currentAccId ?: "")
            .setCallerInfo(callerInfo)
            .setCalleeInfo(calleeInfo)
            .setCallType(if (callInfo.callType == com.netease.yunxin.kit.call.p2p.model.NECallType.VIDEO) Pigeon.CallType.VIDEO else Pigeon.CallType.AUDIO)
            .setSignalInfo(signalInfo)
            .setRtcInfo(rtcInfo)
            .setCallStatus(Pigeon.CallEngineStatus.entries[callInfo.callStatus])
            .build()
    }

    override fun onCallTypeChange(info: NECallTypeChangeInfo?) {
        info?.let { typeChangeInfo ->
            try {
                val pigeonInfo = Pigeon.CallTypeChangeInfo.Builder()
                    .setCallType(if (typeChangeInfo.callType == com.netease.yunxin.kit.call.p2p.model.NECallType.VIDEO) Pigeon.CallType.VIDEO else Pigeon.CallType.AUDIO)
                    .setState(Pigeon.CallSwitchState.values()[typeChangeInfo.state])
                    .build()

                mEventSink?.onCallTypeChange(pigeonInfo, createVoidReply("onCallTypeChange"))
            } catch (e: Exception) {
                ALog.e(CallkitPlugin.TAG, "onCallTypeChange error: ${e.message}")
            }
        }
    }

    override fun onCallEnd(info: NECallEndInfo?) {
        info?.let { endInfo ->
            try {
                val pigeonInfo = Pigeon.CallEndInfo.Builder()
                    .setReasonCode(Pigeon.CallTerminalCode.values()[endInfo.reasonCode])
                    .setExtraString(endInfo.extraString)
                    .setMessage(endInfo.message)
                    .build()

                mEventSink?.onCallEnd(pigeonInfo, createVoidReply("onCallEnd"))
            } catch (e: Exception) {
                ALog.e(CallkitPlugin.TAG, "onCallEnd error: ${e.message}")
            }
        }
    }

    override fun onVideoAvailable(userID: String?, available: Boolean) {
        userID?.let { userId ->
            try {
                mEventSink?.onVideoAvailable(available, userId, createVoidReply("onVideoAvailable"))
            } catch (e: Exception) {
                ALog.e(CallkitPlugin.TAG, "onVideoAvailable error: ${e.message}")
            }
        }
    }

    override fun onVideoMuted(userID: String?, muted: Boolean) {
        userID?.let { userId ->
            try {
                mEventSink?.onVideoMuted(muted, userId, createVoidReply("onVideoMuted"))
            } catch (e: Exception) {
                ALog.e(CallkitPlugin.TAG, "onVideoMuted error: ${e.message}")
            }
        }
    }

    override fun onAudioMuted(userID: String?, muted: Boolean) {
        userID?.let { userId ->
            try {
                mEventSink?.onAudioMuted(muted, userId, createVoidReply("onAudioMuted"))
            } catch (e: Exception) {
                ALog.e(CallkitPlugin.TAG, "onAudioMuted error: ${e.message}")
            }
        }
    }

    override fun startASRCaption(config: Pigeon.NERtcASRCaptionConfig, result: Pigeon.Result<Pigeon.SimpleResponse>) {
        try {
            if (callExtension == null) {
                val response = Pigeon.SimpleResponse.Builder()
                    .setCode(-1L)
                    .setMsg("CallExtension not initialized")
                    .build()
                result.success(response)
                return
            }

            val nertcConfig = NERtcASRCaptionConfig()
            // 根据 Pigeon 配置设置 NERtcASRCaptionConfig
            // 设置源语言
            config.srcLanguage?.let {
                nertcConfig.srcLanguage = it
            }
            // 设置多个源语言
            config.srcLanguages?.let {
                nertcConfig.srcLanguageArr = it.toTypedArray()
            }
            // 设置目标语言（已废弃，但保留兼容性）
            config.dstLanguage?.let {
                nertcConfig.dstLanguage = it
            }
            // 设置多个目标语言
            config.dstLanguages?.let {
                nertcConfig.dstLanguageArr = it.toTypedArray()
            }
            // 设置是否需要翻译相同语言
            config.needTranslateSameLanguage?.let {
                nertcConfig.needTranslateSameLanguage = it
            }

            val ret = callExtension!!.startASRCaption(nertcConfig)
            val response = Pigeon.SimpleResponse.Builder()
                .setCode(ret.toLong())
                .setMsg(if (ret == 0) "Success" else "Failed")
                .build()
            result.success(response)
        } catch (e: Exception) {
            ALog.e(CallkitPlugin.TAG, "startASRCaption error: ${e.message}")
            result.error(e)
        }
    }

    override fun stopASRCaption(result: Pigeon.Result<Pigeon.SimpleResponse>) {
        try {
            if (callExtension == null) {
                val response = Pigeon.SimpleResponse.Builder()
                    .setCode(-1L)
                    .setMsg("CallExtension not initialized")
                    .build()
                result.success(response)
                return
            }

            val ret = callExtension!!.stopASRCaption()
            val response = Pigeon.SimpleResponse.Builder()
                .setCode(ret.toLong())
                .setMsg(if (ret == 0) "Success" else "Failed")
                .build()
            result.success(response)
        } catch (e: Exception) {
            ALog.e(CallkitPlugin.TAG, "stopASRCaption error: ${e.message}")
            result.error(e)
        }
    }

    override fun setCallRecordProvider(
        enable: Boolean,
        result: Pigeon.Result<Pigeon.SimpleResponse>
    ) {
        try {
            if (enable) {
                // 使用 Flutter 插件自身作为 NERecordProvider，将话单事件转发给 Flutter
                NECallEngine.sharedInstance().setCallRecordProvider(this)
                ALog.i(CallkitPlugin.TAG, "setCallRecordProvider: enable Flutter record provider")
            } else {
                // 恢复默认话单处理逻辑
                NECallEngine.sharedInstance()
                    .setCallRecordProvider(DefaultNERecordProvider())
                ALog.i(CallkitPlugin.TAG, "setCallRecordProvider: use default record provider")
            }

            val response = Pigeon.SimpleResponse.Builder()
                .setCode(0L)
                .setMsg("Set call record provider successful")
                .build()
            result.success(response)
        } catch (e: Exception) {
            ALog.e(CallkitPlugin.TAG, "setCallRecordProvider error: ${e.message}")
            result.error(e)
        }
    }

    override fun getUserWithRtcUid(uid: Long, result: Pigeon.Result<Pigeon.UserInfo>) {
        try {
            val userInfo = NECallEngine.sharedInstance().getUserWithRtcUid(uid)
            if (userInfo != null) {
                val pigeonUser = Pigeon.UserInfo.Builder()
                    .setAccId(userInfo.accId ?: "")
                    .setUid(userInfo.uid)
                    .build()
                result.success(pigeonUser)
            } else {
                // 当前没有查到对应用户，按空结果返回给 Flutter
                result.success(null)
            }
        } catch (e: Exception) {
            ALog.e(CallkitPlugin.TAG, "getUserWithRtcUid error: ${e.message}")
            result.error(e)
        }
    }

    // NERecordProvider 实现：将原生话单回调转发到 Flutter
    override fun onRecordSend(record: NERecord) {
        try {
            // 映射通话类型
            val callType = if (record.callType == NECallType.VIDEO) {
                Pigeon.CallType.VIDEO
            } else {
                Pigeon.CallType.AUDIO
            }

            // 映射话单状态到 Pigeon.NIMRtcCallStatus
            val callState = when (record.callState) {
                NERecordCallStatus.CANCELED -> Pigeon.NIMRtcCallStatus.CANCELLED
                NERecordCallStatus.REJECTED -> Pigeon.NIMRtcCallStatus.REJECTED
                NERecordCallStatus.TIMEOUT -> Pigeon.NIMRtcCallStatus.TIMEOUT
                NERecordCallStatus.BUSY -> Pigeon.NIMRtcCallStatus.BUSY
                NERecordCallStatus.COMPLETE -> Pigeon.NIMRtcCallStatus.COMPLETED
                else -> Pigeon.NIMRtcCallStatus.COMPLETED
            }

            val recordConfig = Pigeon.RecordConfig.Builder()
                .setAccId(record.accId)
                .setCallType(callType)
                .setCallState(callState)
                .build()

            mEventSink?.onRecordSend(recordConfig) {
                // 回调完成，无需处理
            }
        } catch (e: Exception) {
            ALog.e(CallkitPlugin.TAG, "onRecordSend error: ${e.message}")
        }
    }

    // ASR 字幕状态变化回调
    // 这个方法从 CallExtension 的回调中调用
    fun onAsrCaptionStateChanged(asrState: Int, code: Int, message: String) {
        try {
            mEventSink?.onAsrCaptionStateChanged(asrState.toLong(), code.toLong(), message) {
                // 回调完成
            }
        } catch (e: Exception) {
            ALog.e(CallkitPlugin.TAG, "onAsrCaptionStateChanged error: ${e.message}")
        }
    }

    // ASR 字幕结果回调
    // 这个方法从 CallExtension 的回调中调用
    fun onAsrCaptionResult(results: Array<com.netease.lava.nertc.sdk.NERtcAsrCaptionResult>?, resultCount: Int) {
        try {
            val resultList = mutableListOf<Pigeon.NERtcAsrCaptionResult>()

            // 转换 native 结果到 Pigeon 结果
            if (results != null && resultCount > 0) {
                for (i in 0 until resultCount) {
                    val nativeResult = results[i]
                    nativeResult.let {
                        val builder = Pigeon.NERtcAsrCaptionResult.Builder()

                        // 注意：以下字段名需要根据实际的 NERtcAsrCaptionResult SDK 字段进行调整
                        // 如果编译错误，请根据实际的 SDK 字段名修改

                        // 设置必需字段
                        // uid: 用户ID（根据实际 SDK 字段调整，可能是 uid 或 userId）
                        builder.setUid(it.uid.toLong())

                        // isLocalUser: 是否为本地用户（根据实际 SDK 字段调整，可能是 isLocal 或 isLocalUser）
                        builder.setIsLocalUser(it.isLocalUser)

                        // timestamp: 时间戳
                        builder.setTimestamp(it.timestamp)

                        // content: 字幕内容
                        it.content?.let { content ->
                            builder.setContent(content)
                        }

                        // language: 语言
                        it.language?.let { language ->
                            builder.setLanguage(language)
                        }

                        // haveTranslation: 是否有翻译（根据实际 SDK 字段调整，可能是 haveTranslation 或 hasTranslation）
                        builder.setHaveTranslation(it.haveTranslation ?: false)

                        // translatedText: 翻译文本
                        it.translatedText?.let { translatedText ->
                            builder.setTranslatedText(translatedText)
                        }

                        // translationLanguage: 翻译语言
                        it.translationLanguage?.let { translationLanguage ->
                            builder.setTranslationLanguage(translationLanguage)
                        }

                        // isFinal: 是否为最终结果
                        builder.setIsFinal(it.isFinal ?: false)

                        resultList.add(builder.build())
                    }
                }
            }

            mEventSink?.onAsrCaptionResult(resultList) {
                // 回调完成
            }
        } catch (e: Exception) {
            ALog.e(CallkitPlugin.TAG, "onAsrCaptionResult error: ${e.message}", e)
        }
    }
}
