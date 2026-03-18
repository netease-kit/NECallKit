/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.p2p

import android.Manifest
import android.content.DialogInterface
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import androidx.appcompat.app.AlertDialog
import androidx.constraintlayout.widget.ConstraintLayout
import com.bumptech.glide.Glide
import com.netease.lava.nertc.sdk.NERtcConstants
import com.netease.lava.nertc.sdk.NERtcConstants.ErrorCode.ENGINE_ERROR_DEVICE_PREVIEW_ALREADY_STARTED
import com.netease.lava.nertc.sdk.NERtcEx
import com.netease.nimlib.sdk.ResponseCode
import com.netease.yunxin.kit.call.NEResultObserver
import com.netease.yunxin.kit.call.p2p.model.NECallEndInfo
import com.netease.yunxin.kit.call.p2p.model.NECallInfo
import com.netease.yunxin.kit.call.p2p.model.NECallInitRtcMode
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.kit.call.p2p.model.NECallTypeChangeInfo
import com.netease.yunxin.nertc.nertcvideocall.bean.CommonResult
import com.netease.yunxin.nertc.nertcvideocall.model.SwitchCallState
import com.netease.yunxin.nertc.nertcvideocall.model.impl.state.CallState
import com.netease.yunxin.nertc.nertcvideocall.utils.NetworkUtils
import com.netease.yunxin.nertc.ui.CallKitUI
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.base.CommonCallActivity
import com.netease.yunxin.nertc.ui.databinding.ActivityP2PcallBinding
import com.netease.yunxin.nertc.ui.utils.CallUILog
import com.netease.yunxin.nertc.ui.utils.CallUIUtils
import com.netease.yunxin.nertc.ui.utils.PermissionTipDialog
import com.netease.yunxin.nertc.ui.utils.formatSecondTime
import com.netease.yunxin.nertc.ui.utils.isGranted
import com.netease.yunxin.nertc.ui.utils.requestPermission
import com.netease.yunxin.nertc.ui.utils.toastShort
import com.netease.yunxin.nertc.ui.view.P2PVideoCallLayout

open class P2PCallActivity : CommonCallActivity() {
    private val tag = "P2PCallActivity"

    private var startPreviewCode = -1

    private var callFinished = true

    private var localIsSmallVideo = true

    private lateinit var binding: ActivityP2PcallBinding
    private lateinit var p2PVideoCallLayout: P2PVideoCallLayout

    override fun onCreate(savedInstanceState: Bundle?) {
        binding = ActivityP2PcallBinding.inflate(layoutInflater)
        super.onCreate(savedInstanceState)
    }

    private val onClickListener = View.OnClickListener { v ->
        when (v) {
            binding.ivAccept -> {
                v.isEnabled = false
                binding.ivSwitchType.isEnabled = false
                binding.ivCallSwitchType.isEnabled = false
                doAccept()
            }

            binding.ivReject -> {
                binding.ivAccept.isEnabled = false
                v.isEnabled = false
                doHangup()
            }

            binding.ivCancel -> {
                if (!callFinished) {
                    getString(R.string.tip_invite_was_sending).toastShort(this)
                    return@OnClickListener
                }
                v.isEnabled = false
                doHangup()
            }

            binding.ivHangUp -> {
                v.isEnabled = false
                doHangup()
            }

            binding.ivCallMuteAudio,
            binding.ivMuteAudio -> doMuteAudioSwitch(v as ImageView)

            binding.ivMuteVideo -> doMuteVideo(binding.ivMuteVideo)
            binding.ivSwitchCamera -> doSwitchCamera()
            binding.ivCallSwitchType,
            binding.ivSwitchType,
            binding.ivCallChannelTypeChange -> doSwitchCallType()

            binding.ivCallSpeaker,
            binding.ivMuteSpeaker -> doConfigSpeakerSwitch(v as ImageView)

            else -> {
                CallUILog.d(tag, "can't response this clicked Event for $v")
            }
        }
    }

    private val uiRender: UIRender
        get() = if (callParam.callType == NECallType.AUDIO) {
            AudioRender()
        } else {
            VideoRender()
        }

    override fun onCallConnected(info: NECallInfo) {
        if (isFinishing) {
            return
        }
        info.otherUserInfo()?.accId.run {
            initForOnTheCall(this)
        }

        configTimeTick(
            CallUIOperationsMgr.TimeTickConfig({
                runOnUiThread {
                    if (callParam.callType == NECallType.VIDEO) {
                        binding.tvCountdown.text = it.formatSecondTime()
                    }
                }
            })
        )
    }

    override fun onCallTypeChange(info: NECallTypeChangeInfo) {
        if (isFinishing) {
            return
        }
        when (info.state) {
            SwitchCallState.ACCEPT -> {
                binding.switchTypeTipGroup.visibility = View.GONE
                if (callEngine.callInfo.callStatus != CallState.STATE_DIALOG) {
                    if (callParam.isCalled) {
                        uiRender.renderForCalled()
                    } else {
                        uiRender.renderForCaller()
                    }
                    return
                }
                initForOnTheCall(callParam.otherAccId)
            }

            SwitchCallState.INVITE -> {
                showSwitchCallTypeConfirmDialog(info.callType)
            }

            SwitchCallState.REJECT -> {
                binding.switchTypeTipGroup.visibility = View.GONE
                getString(R.string.ui_switch_call_type_reject_tip).toastShort(
                    this@P2PCallActivity
                )
            }
        }
    }

    override fun onCallEnd(info: NECallEndInfo) {
        super.onCallEnd(info)
        configTimeTick(null)
        if (!isFinishing) {
            CallUIUtils.showToastWithCallEndReason(this@P2PCallActivity, info.reasonCode)
        }
        releaseAndFinish(false)
    }

    override fun onVideoAvailable(userId: String?, available: Boolean) {
        if (isFinishing) {
            return
        }
    }

    override fun onVideoMuted(userId: String?, mute: Boolean) {
        if (isFinishing) {
            return
        }
    }

    override fun doOnCreate(savedInstanceState: Bundle?) {
        super.doOnCreate(savedInstanceState)
        p2PVideoCallLayout = binding.singleVideoCallLayout
        CallUILog.d(tag, callParam.toString())
        initForLaunchUI()
        val dialog: PermissionTipDialog?
        if (!isGranted(
                Manifest.permission.CAMERA,
                Manifest.permission.RECORD_AUDIO
            )
        ) {
            dialog = showPermissionDialog {
                getString(R.string.tip_permission_request_failed).toastShort(this)
                releaseAndFinish(true)
            }
        } else {
            if (callParam.isCalled && callEngine.callInfo.callStatus == CallState.STATE_IDLE) {
                releaseAndFinish(false)
                return
            }
            initForLaunchAction()
            return
        }
        requestPermission({ granted ->
            if (isFinishing || isDestroyed) {
                return@requestPermission
            }
            granted.forEach {
                CallUILog.i(tag, "granted:$it")
            }
            if (granted.containsAll(
                    listOf(
                        Manifest.permission.CAMERA,
                        Manifest.permission.RECORD_AUDIO
                    )
                )
            ) {
                dialog.dismiss()
                if (callParam.isCalled && callEngine.callInfo.callStatus == CallState.STATE_IDLE) {
                    releaseAndFinish(false)
                    return@requestPermission
                }
                initForLaunchAction()
            }
            CallUILog.i(tag, "extra info is ${callParam.callExtraInfo}")
        }, { deniedForever, denied ->
            denied.forEach {
                CallUILog.i(tag, "denied:$it")
            }
            deniedForever.forEach {
                CallUILog.i(tag, "deniedForever:$it")
            }
            if (deniedForever.isNotEmpty() || denied.isNotEmpty()) {
                getString(R.string.tip_permission_request_failed).toastShort(this@P2PCallActivity)
                dialog.dismiss()
                releaseAndFinish(true)
            }
        }, Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO)
    }

    override fun provideLayoutView(): View? {
        return binding.root
    }

    override fun releaseAndFinish(finishCall: Boolean) {
        super.releaseAndFinish(false)

        if (startPreviewCode == 0 || startPreviewCode == ENGINE_ERROR_DEVICE_PREVIEW_ALREADY_STARTED) {
            NERtcEx.getInstance().setupLocalVideoCanvas(null)
            NERtcEx.getInstance().stopVideoPreview()
        }

        if (finishCall) {
            doHangup(null)
        }
    }

    override fun onBackPressed() {
        showExitDialog()
    }

    override fun onPause() {
        super.onPause()
        if (isFinishing) {
            releaseAndFinish(true)
        }
    }

    private fun showExitDialog() {
        val confirmDialog = AlertDialog.Builder(this)
        confirmDialog.setTitle(R.string.tip_dialog_finish_call_title)
        confirmDialog.setMessage(R.string.tip_dialog_finish_call_content)
        confirmDialog.setPositiveButton(
            R.string.tip_dialog_finish_call_positive
        ) { _: DialogInterface?, _: Int ->
            if (!callFinished) {
                getString(R.string.tip_invite_was_sending).toastShort(this)
                return@setPositiveButton
            }
            finish()
        }
        confirmDialog.setNegativeButton(
            R.string.tip_dialog_finish_call_negative
        ) { _: DialogInterface?, _: Int -> }
        confirmDialog.show()
    }

    private fun initForLaunchUI() {
        if (callParam.isCalled) {
            // 主叫页面初始化
            uiRender.renderForCalled()
        } else {
            // 被叫页面初始化
            uiRender.renderForCaller()
        }
    }

    private fun initForLaunchAction() {
        if (callParam.isCalled) {
            return
        }
        doCall()
        if (callParam.callType == NECallType.VIDEO) {
            if (CallKitUI.options?.initRtcMode != NECallInitRtcMode.GLOBAL) {
                CallUIOperationsMgr.setupLocalView(p2PVideoCallLayout.binding.videoViewPreview)
            }
            if (CallKitUI.options?.joinRtcWhenCall == false &&
                startPreviewCode != NERtcConstants.ErrorCode.OK
            ) {
                startPreviewCode = NERtcEx.getInstance().startVideoPreview().apply {
                    CallUILog.d(tag, "initForLaunchAction startPreviewCode is $this.")
                }
            }
        }
    }

    /**
     * 通话中页面初始化
     */
    private fun initForOnTheCall(userAccId: String? = null) {
        uiRender.renderForOnTheCall(userAccId)
    }

    private fun doCall() {
        callFinished = false

        doCall { result ->
            callFinished = true
            if (result?.isSuccessful != true && result.code != ResponseCode.RES_PEER_NIM_OFFLINE.toInt() && result.code != ResponseCode.RES_PEER_PUSH_OFFLINE.toInt()) {
                getString(R.string.tip_start_call_failed).toastShort(this@P2PCallActivity)
            }
        }
    }

    private fun doAccept() {
        if (binding.tvConnectingTip.tag != true) {
            binding.tvConnectingTip.tag = true
            binding.tvConnectingTip.visibility = View.VISIBLE
        }
        doAccept { result ->
            if (result?.isSuccessful != true) {
                getString(R.string.tip_accept_failed).toastShort(this@P2PCallActivity)
                finish()
            }
        }
    }

    private fun doHangup() {
        releaseAndFinish(true)
    }

    private fun doMuteVideo(view: ImageView) {
        doMuteVideo()
        view.setImageResource(if (isLocalMuteVideo) R.drawable.cam_off else R.drawable.cam_on)
    }

    private fun doConfigSpeakerSwitch(
        view: ImageView? = null,
        speakerEnable: Boolean = !isSpeakerOn()
    ) {
        doConfigSpeaker(speakerEnable)
        binding.ivMuteSpeaker.setImageResource(
            if (speakerEnable) R.drawable.speaker_on else R.drawable.speaker_off
        )
        binding.ivCallSpeaker.setImageResource(
            if (speakerEnable) R.drawable.icon_call_audio_speaker_on else R.drawable.icon_call_audio_speaker_off
        )
    }

    private fun doMuteAudioSwitch(view: ImageView? = null) {
        super.doMuteAudio(!isLocalMuteAudio)
        binding.ivMuteAudio.setImageResource(
            if (isLocalMuteAudio) R.drawable.voice_off else R.drawable.voice_on
        )
        binding.ivCallMuteAudio.setImageResource(
            if (isLocalMuteAudio) R.drawable.icon_call_audio_off else R.drawable.icon_call_audio_on
        )
    }

    private fun doSwitchCallType(switchCallState: Int = SwitchCallState.INVITE) {
        if (!NetworkUtils.isConnected()) {
            getString(R.string.tip_network_error).toastShort(this)
            return
        }
        val toCallType = if (callParam.callType == NECallType.VIDEO) {
            NECallType.AUDIO
        } else {
            NECallType.VIDEO
        }

        doSwitchCallType(
            toCallType,
            switchCallState,
            object : NEResultObserver<CommonResult<Void>> {
                override fun onResult(result: CommonResult<Void>?) {
                    if (result?.isSuccessful != true) {
                        getString(R.string.tip_switch_call_type_failed).toastShort(
                            this@P2PCallActivity
                        )
                        CallUILog.e(
                            tag,
                            "doSwitchCallType to $toCallType error, result is $result."
                        )
                        return
                    }
                    if (switchCallState == SwitchCallState.INVITE) {
                        binding.switchTypeTipGroup.visibility = View.VISIBLE
                    }
                }
            }
        )
    }

    private open inner class UIRender {
        open fun renderForCaller() {
            binding.tvSwitchTipClose.setOnClickListener {
                binding.switchTypeTipGroup.visibility = View.GONE
            }
            binding.calledSwitchGroup.visibility = View.GONE
            binding.callerSwitchGroup.visibility = View.GONE
        }

        open fun renderForCalled() {
            binding.tvSwitchTipClose.setOnClickListener {
                binding.switchTypeTipGroup.visibility = View.GONE
            }
            binding.callerSwitchGroup.visibility = View.GONE
            binding.calledSwitchGroup.visibility = View.GONE
        }

        open fun renderForOnTheCall(userAccId: String? = null) {
            binding.tvSwitchTipClose.setOnClickListener {
                binding.switchTypeTipGroup.visibility = View.GONE
            }
            binding.callerSwitchGroup.visibility = View.GONE
            binding.calledSwitchGroup.visibility = View.GONE
            binding.tvConnectingTip.visibility = View.GONE
            binding.tvCountdown.visibility = View.VISIBLE
            if (this is AudioRender) {
                binding.ivCallChannelTypeChange.visibility =
                    if (uiConfig?.showAudio2VideoSwitchOnTheCall == true) View.VISIBLE else View.GONE
            }
            if (this is VideoRender) {
                binding.ivCallChannelTypeChange.visibility =
                    if (uiConfig?.showVideo2AudioSwitchOnTheCall == true) View.VISIBLE else View.GONE
            }
            uiConfig?.overlayViewOnTheCall?.run {
                if (parent is ViewGroup) {
                    (parent as ViewGroup).removeView(this)
                }
                binding.clRoot.addView(
                    this,
                    ConstraintLayout.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.MATCH_PARENT
                    )
                )
            }
        }
    }

    private inner class AudioRender : UIRender() {
        override fun renderForCaller() {
            super.renderForCaller()
            doConfigSpeakerSwitch(speakerEnable = false)

            if (isLocalMuteAudio) {
                doMuteAudioSwitch()
            }

            binding.tvCallSwitchTypeDesc.setText(R.string.tip_switch_to_video)

            binding.llOnTheCallOperation.visibility = View.GONE
            binding.calledOperationGroup.visibility = View.GONE
            binding.callerOperationGroup.visibility = View.VISIBLE
            binding.callerAudioOperationGroup.visibility = View.VISIBLE

            binding.ivCancel.setOnClickListener(onClickListener)
            binding.ivCallSwitchType.setOnClickListener(onClickListener)
            binding.ivCallSwitchType.setImageResource(R.drawable.icon_call_tip_audio_to_video)
            binding.ivCallChannelTypeChange.setOnClickListener(onClickListener)

            binding.ivCallMuteAudio.setOnClickListener(onClickListener)
            binding.ivCallSpeaker.setOnClickListener(onClickListener)
            if (startPreviewCode == 0 || startPreviewCode == ENGINE_ERROR_DEVICE_PREVIEW_ALREADY_STARTED) {
                NERtcEx.getInstance().setupLocalVideoCanvas(null)
                startPreviewCode = if (NERtcEx.getInstance().stopVideoPreview() == 0) -1 else 0
            }
        }

        override fun renderForCalled() {
            super.renderForCalled()
            binding.ivAccept.setImageResource(R.drawable.icon_call_audio_accept)
            binding.ivSwitchType.setImageResource(R.drawable.icon_call_tip_audio_to_video)
            binding.tvSwitchTypeDesc.setText(R.string.tip_switch_to_video)

            binding.llOnTheCallOperation.visibility = View.GONE
            binding.calledOperationGroup.visibility = View.VISIBLE
            binding.callerOperationGroup.visibility = View.GONE
            binding.callerAudioOperationGroup.visibility = View.GONE

            binding.ivAccept.setOnClickListener(onClickListener)
            binding.ivReject.setOnClickListener(onClickListener)
            binding.ivSwitchType.setOnClickListener(onClickListener)
        }

        override fun renderForOnTheCall(userAccId: String?) {
            super.renderForOnTheCall(userAccId)

            binding.calledOperationGroup.visibility = View.GONE
            binding.callerOperationGroup.visibility = View.GONE
            binding.callerAudioOperationGroup.visibility = View.GONE
            binding.llOnTheCallOperation.visibility = View.VISIBLE

            binding.ivCallChannelTypeChange.setImageResource(R.drawable.audio_to_video)
            binding.ivCallChannelTypeChange.setOnClickListener(onClickListener)
            binding.ivMuteAudio.setOnClickListener(onClickListener)
            binding.ivMuteVideo.visibility = View.GONE
            binding.ivHangUp.setOnClickListener(onClickListener)
            binding.ivMuteSpeaker.setOnClickListener(onClickListener)

            binding.ivSwitchCamera.visibility = View.GONE

            if (!firstLaunch || callParam.isCalled) {
                resetSwitchState(NECallType.AUDIO)
            } else {
                firstLaunch = false
            }
            // sdk 版本变更后在加入通话前设置扬声器不生效，在对方接听后，自己加入rtc 后进行扬声器设置补充；
            if (!callParam.isCalled) {
                doConfigSpeakerSwitch(speakerEnable = isSpeakerOn())
            }
        }
    }

    private var firstLaunch = true

    private inner class VideoRender : UIRender() {
        override fun renderForCaller() {
            super.renderForCaller()
            doConfigSpeakerSwitch(speakerEnable = true)

            binding.llOnTheCallOperation.visibility = View.GONE
            binding.calledOperationGroup.visibility = View.GONE
            binding.callerOperationGroup.visibility = View.VISIBLE
            binding.callerAudioOperationGroup.visibility = View.GONE
            binding.ivCancel.setOnClickListener(onClickListener)
            binding.ivCallSwitchType.setOnClickListener(onClickListener)
            binding.ivCallSwitchType.setImageResource(R.drawable.icon_call_tip_video_to_audio)
            binding.tvCallSwitchTypeDesc.setText(R.string.tip_switch_to_audio)

            if (startPreviewCode != NERtcConstants.ErrorCode.OK &&
                startPreviewCode != ENGINE_ERROR_DEVICE_PREVIEW_ALREADY_STARTED
            ) {
                startPreviewCode = NERtcEx.getInstance().startVideoPreview().apply {
                    CallUILog.d(tag, "renderForCaller startPreviewCode is $this.")
                }
            }
        }

        override fun renderForCalled() {
            super.renderForCalled()
            binding.llOnTheCallOperation.visibility = View.GONE
            binding.calledOperationGroup.visibility = View.VISIBLE
            binding.callerOperationGroup.visibility = View.GONE
            binding.callerAudioOperationGroup.visibility = View.GONE
            binding.tvSwitchTypeDesc.setText(R.string.tip_switch_to_audio)

            binding.ivAccept.setImageResource(R.drawable.call_accept)
            binding.ivSwitchType.setImageResource(R.drawable.icon_call_tip_video_to_audio)

            binding.ivAccept.setOnClickListener(onClickListener)
            binding.ivReject.setOnClickListener(onClickListener)
            binding.ivSwitchType.setOnClickListener(onClickListener)
        }

        override fun renderForOnTheCall(userAccId: String?) {
            super.renderForOnTheCall(userAccId)
            binding.calledOperationGroup.visibility = View.GONE
            binding.callerOperationGroup.visibility = View.GONE
            binding.callerAudioOperationGroup.visibility = View.GONE
            binding.llOnTheCallOperation.visibility = View.VISIBLE

            binding.ivCallChannelTypeChange.setOnClickListener(onClickListener)
            binding.ivCallChannelTypeChange.setImageResource(R.drawable.video_to_audio)
            binding.ivMuteAudio.setOnClickListener(onClickListener)
            binding.ivMuteVideo.visibility = View.VISIBLE
            binding.ivMuteVideo.setOnClickListener(onClickListener)
            binding.ivHangUp.setOnClickListener(onClickListener)
            binding.ivMuteSpeaker.setOnClickListener(onClickListener)
            resetSwitchState(NECallType.VIDEO)

            firstLaunch = false
            binding.ivSwitchCamera.run {
                visibility = View.VISIBLE
                setOnClickListener(onClickListener)
            }
        }
    }

    private fun resetSwitchState(callType: Int) {
        if (callType == NECallType.VIDEO) {
            doConfigSpeaker(true)
            binding.ivMuteSpeaker.setImageResource(R.drawable.speaker_on)
            // 使用 SingleVideoCallLayout 重置切换状态
            p2PVideoCallLayout.resetSwitchState(callType)
        } else {
            doConfigSpeaker(false)
            binding.ivMuteSpeaker.setImageResource(R.drawable.speaker_off)
        }
        // 视频
        localIsSmallVideo = true

        doMuteAudio(false)
        if (callType == NECallType.VIDEO) {
            binding.ivMuteVideo.setImageResource(R.drawable.cam_on)
        }
        // 音频
        if (isLocalMuteAudio) {
            doMuteAudioSwitch(binding.ivMuteAudio)
        }
    }

    private fun loadImg(url: String?, imageView: ImageView) {
        Glide.with(applicationContext).load(url)
            .error(R.color.black)
            .placeholder(R.color.black)
            .centerCrop()
            .into(imageView)
    }
}
