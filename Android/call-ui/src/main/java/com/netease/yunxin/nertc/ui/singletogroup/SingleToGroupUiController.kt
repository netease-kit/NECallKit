/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.singletogroup

import android.Manifest
import android.app.Activity
import android.view.View
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import com.netease.lava.nertc.sdk.NERtcConstants
import com.netease.yunxin.kit.call.NEResultObserver
import com.netease.yunxin.kit.call.p2p.NECallEngine
import com.netease.yunxin.kit.call.p2p.model.NECallInviteResult
import com.netease.yunxin.kit.call.p2p.model.NECallInviteState
import com.netease.yunxin.kit.call.p2p.model.NECallInviteStateInfo
import com.netease.yunxin.kit.call.p2p.model.NECallMemberChangeInfo
import com.netease.yunxin.kit.call.p2p.model.NECallMemberChangeType
import com.netease.yunxin.kit.call.p2p.model.NECallMemberInfo
import com.netease.yunxin.kit.call.p2p.model.NECallMemberState
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.kit.call.p2p.param.NECallInviteParam
import com.netease.yunxin.nertc.nertcvideocall.bean.CommonResult
import com.netease.yunxin.nertc.nertcvideocall.model.impl.NERtcCallbackExTemp
import com.netease.yunxin.nertc.nertcvideocall.model.impl.NERtcCallbackProxyMgr
import com.netease.yunxin.nertc.nertcvideocall.model.impl.state.CallState.STATE_DIALOG
import com.netease.yunxin.nertc.nertcvideocall.utils.NetworkUtils
import com.netease.yunxin.nertc.ui.CallKitUI
import com.netease.yunxin.nertc.ui.NECallInviteUIContext
import com.netease.yunxin.nertc.ui.NECallSingleToGroupInviteMode
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.base.CallParam
import com.netease.yunxin.nertc.ui.base.CommonCallActivity
import com.netease.yunxin.nertc.ui.base.Constants
import com.netease.yunxin.nertc.ui.p2p.CallUIFloatingWindowMgr
import com.netease.yunxin.nertc.ui.p2p.CallUIOperationsMgr
import com.netease.yunxin.nertc.ui.permission.PermissionCallback
import com.netease.yunxin.nertc.ui.permission.PermissionRequest
import com.netease.yunxin.nertc.ui.utils.CallUILog
import com.netease.yunxin.nertc.ui.utils.SecondsTimer
import com.netease.yunxin.nertc.ui.utils.formatSecondTime
import com.netease.yunxin.nertc.ui.utils.isGranted
import com.netease.yunxin.nertc.ui.utils.toastShort
import com.netease.yunxin.nertc.ui.view.GroupCallGridLayout

internal class SingleToGroupUiController(
    private val activity: Activity,
    private val callEngine: NECallEngine,
    private val callParam: CallParam,
    private val enableVirtualBlur: Boolean,
    private val currentCallState: () -> Int,
    private val onEnterSingleToGroupMode: () -> Unit,
    private val onMuteVideo: () -> Unit,
    private val onHangup: () -> Unit
) {
    companion object {
        private const val TAG = "SingleToGroupUiController"
    }

    private var inviteUsersButton: ImageView? = null
    private var switchCameraButton: ImageView? = null
    private var countdownTextView: TextView? = null
    private var operationBar: LinearLayout? = null
    private var muteAudioButton: ImageView? = null
    private var muteVideoButton: ImageView? = null
    private var speakerButton: ImageView? = null
    private var switchTypeButton: ImageView? = null
    private var virtualBlurButton: ImageView? = null
    private var hangupButton: ImageView? = null
    private var localVideoEnabled = false
    private var countdownBound = false
    private var localCountdownTimer: SecondsTimer? = null
    private var released = false
    private var didSyncSpeakerOnEnterMode = false
    private val videoMutedStates = mutableMapOf<String, Boolean>()
    private val userInfoFetcher = SingleToGroupUserInfoFetcher()
    private var gridAdapter: SingleToGroupMemberGridAdapter? = null
    private var lastOperationLogState: OperationLogState? = null
    private var lastMemberSnapshot: List<NECallMemberInfo> = emptyList()

    private val rtcCallback = object : NERtcCallbackExTemp() {
        override fun onVirtualBackgroundSourceEnabled(enabled: Boolean, reason: Int) {
            if (reason == NERtcConstants.NERtcVirtualBackgroundSourceStateReason.VBS_STATE_REASON_DEVICE_NOT_SUPPORTED) {
                CallUIOperationsMgr.updateUIState(isVirtualBlur = false)
                refreshOperationState()
            }
        }
    }

    var hasEnteredSingleToGroup = false
        private set

    fun init() {
        initGrid()
        initInviteEntry()
        initOperations()
    }

    fun hideInviteEntry() {
        inviteUsersButton?.visibility = View.GONE
    }

    fun release() {
        if (released) {
            return
        }
        released = true
        gridAdapter?.release()
        activity.findViewById<GroupCallGridLayout>(R.id.singleToGroupGridLayout)?.removeAllViews()
        hideCountdown()
        hideOperations()
        NERtcCallbackProxyMgr.getInstance().removeCallback(rtcCallback)
    }

    fun updateInviteEntry() {
        val connected = currentCallState() == STATE_DIALOG
        val remainingCount = remainingInviteCount()
        val canInvite = CallKitUI.options?.singleToGroupInviteMode ==
            NECallSingleToGroupInviteMode.AFTER_1V1_CONNECTED &&
            CallKitUI.options?.uiHelper?.inviteContactSelector != null &&
            callEngine.canInviteMembers()
        inviteUsersButton?.run {
            visibility = if (connected && canInvite && remainingCount > 0) View.VISIBLE else View.GONE
            isEnabled = connected && canInvite && remainingCount > 0
        }
    }

    fun enterMode(reason: String, members: List<NECallMemberInfo>? = callEngine.currentMembers()) {
        val callState = currentCallState()
        if (callState != STATE_DIALOG) {
            CallUILog.i(
                TAG,
                "skip enterSingleToGroupMode reason:$reason callState:$callState " +
                    "members:${SingleToGroupLogFormatter.memberSnapshotSummary(members.orEmpty())}"
            )
            return
        }
        if (!hasEnteredSingleToGroup) {
            expireSwitchCallTypeInvite("enterMode:$reason")
            hasEnteredSingleToGroup = true
            syncLocalVideoStateOnEnterMode()
            syncSpeakerStateOnEnterMode()
            if (enableVirtualBlur) {
                NERtcCallbackProxyMgr.getInstance().addCallback(rtcCallback)
            }
            CallUILog.i(TAG, "enterSingleToGroupMode reason: $reason")
            onEnterSingleToGroupMode()
            activity.findViewById<View>(R.id.p2pFragmentContainer)?.visibility = View.GONE
            activity.findViewById<View>(R.id.singleToGroupGridLayout)?.visibility = View.VISIBLE
            showCountdown()
            showOperations()
        }
        refreshMembers(members)
        refreshOperationState()
        updateInviteEntry()
    }

    fun handleMembersChanged(info: NECallMemberChangeInfo) {
        val members = info.members ?: callEngine.currentMembers()
        CallUILog.i(TAG, "onCallMembersChanged ${SingleToGroupLogFormatter.memberChangeSummary(info, members)}")
        val memberDiff = SingleToGroupLogFormatter.memberDiff(lastMemberSnapshot, members)
        if (memberDiff.isNotEmpty()) {
            CallUILog.i(TAG, "onCallMembersChanged diff:$memberDiff")
        }
        lastMemberSnapshot = members
        val shouldEnterAfterSingleToGroupChanged = callEngine.isInMultiCall() &&
            (info.changeType == NECallMemberChangeType.JOIN ||
                info.changeType == NECallMemberChangeType.LEAVE) &&
            (info.changedMember?.state == NECallMemberState.JOINED ||
                info.changedMember?.state == NECallMemberState.LEAVING)
        if (hasEnteredSingleToGroup || members.size >= 3 || shouldEnterAfterSingleToGroupChanged) {
            enterMode("onCallMembersChanged", members)
        }
        updateInviteEntry()
    }

    fun handleInviteStateChanged(infos: MutableList<NECallInviteStateInfo>?) {
        if (infos.isNullOrEmpty()) {
            return
        }
        val currentAccId = callEngine.callInfo.currentAccId
        val currentInviteInfos = infos.filter { it.inviterUserID == currentAccId }
        if (currentInviteInfos.isEmpty()) {
            return
        }
        CallUILog.i(
            TAG,
            "onCallInviteStateChanged count:${currentInviteInfos.size} " +
                currentInviteInfos.joinToString(prefix = "[", postfix = "]") {
                    "${it.inviteeUserID}:state=${it.state}:reason=${it.reasonCode}"
                }
        )
        activity.runOnUiThread {
            val message = inviteStateToastMessage(currentInviteInfos)
            if (!message.isNullOrEmpty()) {
                message.toastShort(activity)
            }
            if (hasEnteredSingleToGroup) {
                refreshMembers(callEngine.currentMembers())
            }
            updateInviteEntry()
        }
    }

    fun onVideoAvailable(userId: String?, available: Boolean): Boolean {
        if (!hasEnteredSingleToGroup) {
            return false
        }
        if (userId != currentUserId()) {
            return true
        }
        userId?.let { videoMutedStates[it] = !available }
        gridAdapter?.updateState(userId, enableVideo = available)
        refreshOperationState()
        return true
    }

    fun onVideoMuted(userId: String?, mute: Boolean): Boolean {
        if (!hasEnteredSingleToGroup) {
            return false
        }
        if (userId != currentUserId()) {
            return true
        }
        userId?.let { videoMutedStates[it] = mute }
        gridAdapter?.updateState(userId, enableVideo = !mute)
        refreshOperationState()
        return true
    }

    fun onAudioMuted(userId: String?, mute: Boolean): Boolean {
        if (!hasEnteredSingleToGroup) {
            return false
        }
        gridAdapter?.updateState(userId, enableAudio = !mute)
        refreshOperationState()
        return true
    }

    private fun initInviteEntry() {
        inviteUsersButton = activity.findViewById<ImageView>(R.id.ivInviteUsers)?.apply {
            visibility = View.GONE
            setOnClickListener {
                showInviteDialog()
            }
        }
    }

    private fun initGrid() {
        gridAdapter = SingleToGroupMemberGridAdapter(activity).apply {
            setGridLayout(activity.findViewById(R.id.singleToGroupGridLayout))
        }
        activity.findViewById<GroupCallGridLayout>(R.id.singleToGroupGridLayout)?.run {
            setSingleChildFullWidthSquareEnabled(true)
            setExpandedDefaultGridHeightEnabled(true)
            setOnAnimationStateChangeListener { isAnimating ->
                gridAdapter?.setLayoutAnimating(isAnimating)
            }
            setOnItemClickListener { index ->
                if (getLargeViewIndex() == index) {
                    resetLargeView(true)
                } else {
                    setLargeViewIndex(index, true)
                }
            }
        }
    }

    private fun initOperations() {
        switchCameraButton = activity.findViewById<ImageView>(R.id.ivSingleToGroupSwitchCamera)
        countdownTextView = activity.findViewById(R.id.tvSingleToGroupCountdown)
        operationBar = activity.findViewById<LinearLayout>(R.id.llSingleToGroupOperation)
        muteAudioButton = activity.findViewById<ImageView>(R.id.ivSingleToGroupMuteAudio)?.apply {
            setOnClickListener {
                CallUIOperationsMgr.doMuteAudio()
                refreshOperationState()
            }
        }
        muteVideoButton = activity.findViewById<ImageView>(R.id.ivSingleToGroupMuteVideo)?.apply {
            setOnClickListener {
                toggleLocalVideo()
            }
        }
        speakerButton = activity.findViewById<ImageView>(R.id.ivSingleToGroupSpeaker)?.apply {
            setOnClickListener {
                CallUIOperationsMgr.doConfigSpeaker(!CallUIOperationsMgr.isSpeakerOn())
                refreshOperationState()
            }
        }
        switchTypeButton = activity.findViewById<ImageView>(R.id.ivSingleToGroupSwitchType)?.apply {
            alpha = 0.35f
            setOnClickListener {
                CallUILog.i(TAG, "switch call type ignored in multi call.")
                activity.getString(R.string.single_to_group_switch_call_type_unsupported)
                    .toastShort(activity)
            }
        }
        virtualBlurButton = activity.findViewById<ImageView>(R.id.ivSingleToGroupVirtualBlur)?.apply {
            setOnClickListener {
                CallUIOperationsMgr.doVirtualBlur()
                refreshOperationState()
            }
        }
        hangupButton = activity.findViewById<ImageView>(R.id.ivSingleToGroupHangup)?.apply {
            setOnClickListener {
                onHangup()
            }
        }
        switchCameraButton?.setOnClickListener {
            CallUIOperationsMgr.doSwitchCamera()
        }
        hideOperations()
    }

    private fun showCountdown() {
        countdownTextView?.run {
            visibility = View.VISIBLE
            val sharedSeconds = CallUIOperationsMgr.timer?.currentSeconds
            text = SingleToGroupCountdownPolicy.initialSeconds(sharedSeconds).formatSecondTime()
            if (SingleToGroupCountdownPolicy.shouldStartLocalTimer(CallUIOperationsMgr.timer != null)) {
                startLocalCountdown()
                return@run
            }
            CallUIOperationsMgr.configTimeTick(
                CallUIOperationsMgr.TimeTickConfig(onTimeTick = { seconds ->
                    updateCountdown(seconds)
                })
            )
            countdownBound = true
        }
    }

    private fun hideCountdown() {
        countdownTextView?.visibility = View.GONE
        localCountdownTimer?.cancel()
        localCountdownTimer = null
        if (countdownBound) {
            CallUIOperationsMgr.configTimeTick(null)
            countdownBound = false
        }
    }

    private fun startLocalCountdown() {
        if (localCountdownTimer != null) {
            return
        }
        localCountdownTimer = SecondsTimer().apply {
            start { seconds ->
                updateCountdown(seconds)
            }
        }
    }

    private fun updateCountdown(seconds: Long) {
        activity.runOnUiThread {
            countdownTextView?.text = seconds.formatSecondTime()
        }
    }

    private fun syncLocalVideoStateOnEnterMode() {
        val state = CallUIOperationsMgr.callInfoWithUIState
        val shouldMuteLocalVideo = SingleToGroupMediaPolicy.shouldMuteLocalVideoOnEnterMode(
            originalOneToOneVideoCall = callParam.callType == NECallType.VIDEO,
            localVideoMuted = state.isLocalMuteVideo
        )
        localVideoEnabled = !shouldMuteLocalVideo
        currentUserId()?.let { videoMutedStates[it] = shouldMuteLocalVideo }
        if (shouldMuteLocalVideo) {
            CallUIOperationsMgr.updateUIState(isLocalMuteVideo = true)
        }
    }

    private fun syncSpeakerStateOnEnterMode() {
        if (didSyncSpeakerOnEnterMode || !callParam.multiCallInvite) {
            return
        }
        didSyncSpeakerOnEnterMode = true
        CallUILog.i(TAG, "sync speaker on enter single-to-group mode for invitee.")
        CallUIOperationsMgr.doConfigSpeaker(true)
    }

    private fun showOperations() {
        operationBar?.visibility = View.VISIBLE
        switchCameraButton?.visibility =
            if (SingleToGroupMediaPolicy.shouldShowVideoControls()) View.VISIBLE else View.GONE
        muteVideoButton?.visibility =
            if (SingleToGroupMediaPolicy.shouldShowVideoControls()) View.VISIBLE else View.GONE
        switchTypeButton?.setImageResource(
            if (callParam.callType == NECallType.VIDEO) R.drawable.video_to_audio else R.drawable.audio_to_video
        )
        virtualBlurButton?.visibility = if (
            SingleToGroupMediaPolicy.shouldShowVirtualBlurControl(enableVirtualBlur)
        ) {
            View.VISIBLE
        } else {
            View.GONE
        }
        refreshOperationState()
    }

    private fun hideOperations() {
        operationBar?.visibility = View.GONE
        switchCameraButton?.visibility = View.GONE
        virtualBlurButton?.visibility = View.GONE
    }

    private fun refreshOperationState() {
        if (!hasEnteredSingleToGroup) {
            return
        }
        val state = CallUIOperationsMgr.callInfoWithUIState
        muteAudioButton?.setImageResource(
            if (state.isLocalMuteAudio) R.drawable.voice_off else R.drawable.voice_on
        )
        muteVideoButton?.setImageResource(
            if (state.isLocalMuteVideo) R.drawable.cam_off else R.drawable.cam_on
        )
        speakerButton?.setImageResource(
            if (CallUIOperationsMgr.isSpeakerOn()) R.drawable.speaker_on else R.drawable.speaker_off
        )
        virtualBlurButton?.setImageResource(
            if (state.isVirtualBlur) R.drawable.icon_call_virtual_blur_on else R.drawable.icon_call_virtual_blur_off
        )
        switchTypeButton?.alpha = 0.35f
        val operationLogState = OperationLogState(
            audioMuted = state.isLocalMuteAudio,
            videoMuted = state.isLocalMuteVideo,
            speakerOn = CallUIOperationsMgr.isSpeakerOn(),
            virtualBlur = state.isVirtualBlur
        )
        if (lastOperationLogState != operationLogState) {
            CallUILog.i(TAG, "operationState $operationLogState")
            lastOperationLogState = operationLogState
        }
    }

    private fun toggleLocalVideo() {
        val targetMute = !CallUIOperationsMgr.callInfoWithUIState.isLocalMuteVideo
        if (!targetMute && !activity.isGranted(Manifest.permission.CAMERA)) {
            requestCameraPermissionThenOpenVideo()
            return
        }
        if (!targetMute && !localVideoEnabled) {
            val enableResult = callEngine.enableLocalVideo(true)
            localVideoEnabled = true
            CallUILog.i(TAG, "toggleLocalVideo restore local video capture result:$enableResult")
        }
        onMuteVideo()
        val localMuted = CallUIOperationsMgr.callInfoWithUIState.isLocalMuteVideo
        CallUILog.i(TAG, "toggleLocalVideo targetMute:$targetMute localMuted:$localMuted")
        val currentUserId = currentUserId()
        currentUserId?.let { videoMutedStates[it] = localMuted }
        gridAdapter?.updateState(currentUserId, enableVideo = !localMuted)
        refreshOperationState()
    }

    private fun requestCameraPermissionThenOpenVideo() {
        CallUILog.i(TAG, "toggleLocalVideo request camera permission before unmute")
        PermissionRequest.requestCameraPermission(
            activity,
            object : PermissionCallback() {
                override fun onGranted() {
                    if (activity.isFinishing || activity.isDestroyed) {
                        return
                    }
                    CallUILog.i(TAG, "toggleLocalVideo camera permission granted")
                    toggleLocalVideo()
                }

                override fun onRequesting() {
                    onDenied()
                }

                override fun onDenied() {
                    if (activity.isFinishing || activity.isDestroyed) {
                        return
                    }
                    CallUILog.i(TAG, "toggleLocalVideo camera permission denied")
                    activity.getString(R.string.tip_camera_permission_request_failed)
                        .toastShort(activity)
                    refreshOperationState()
                }
            }
        )
    }

    private fun refreshMembers(members: List<NECallMemberInfo>?) {
        val visibleMembers = members
            ?.filter { it.state != NECallMemberState.LEAVING }
            ?.distinctBy { it.userID }
            ?: emptyList()
        if (visibleMembers.isEmpty()) {
            gridAdapter?.setData(emptyList())
            return
        }
        val accIdList = visibleMembers.map { it.userID }
        userInfoFetcher.getUserInfoList(
            accIdList,
            NEResultObserver getUserInfoList@{ result: List<SingleToGroupMemberInfo>? ->
                val userInfoMap = result?.associateBy { it.accId } ?: emptyMap()
                val displayList = visibleMembers.map { member ->
                    val userInfo = userInfoMap[member.userID]
                    val cachedVideoMuted = videoMutedStates[member.userID]
                    val videoMuted = cachedVideoMuted ?: member.videoMuted
                    SingleToGroupMemberInfo(
                        accId = member.userID,
                        name = userInfo?.name ?: member.userID,
                        avatarUrl = userInfo?.avatarUrl,
                        enableVideo = SingleToGroupMediaPolicy.isMemberVideoOpen(
                            joined = member.state == NECallMemberState.JOINED,
                            videoAvailable = member.videoAvailable,
                            hasCachedVideoMuted = cachedVideoMuted != null,
                            muted = videoMuted
                        ),
                        enableAudio = !member.audioMuted,
                        state = member.state,
                        uid = member.uid
                    )
                }
                activity.runOnUiThread {
                    gridAdapter?.setData(displayList)
                }
            }
        )
    }

    private fun currentUserId(): String? = callParam.currentAccId ?: callEngine.callInfo.currentAccId

    private fun showInviteDialog() {
        if (!NetworkUtils.isConnected()) {
            activity.getString(R.string.tip_network_error).toastShort(activity)
            return
        }
        val remainingCount = remainingInviteCount()
        if (remainingCount <= 0) {
            activity.getString(R.string.ui_member_exceed_limit).toastShort(activity)
            return
        }
        if (!callEngine.canInviteMembers()) {
            activity.getString(R.string.single_to_group_invite_unsupported).toastShort(activity)
            updateInviteEntry()
            return
        }
        expireSwitchCallTypeInvite("showInviteDialog")
        showContactSelector(remainingCount)
    }

    private fun showContactSelector(remainingCount: Int) {
        val selector = CallKitUI.options?.uiHelper?.inviteContactSelector
        if (selector == null) {
            CallUILog.i(TAG, "single-to-group invite selector is not configured.")
            return
        }
        val callInfo = callEngine.callInfo
        selector.onSelectInviteMembers(
            activity,
            NECallInviteUIContext(
                callId = callInfo.callId,
                channelId = callInfo.signalInfo?.channelId,
                currentUserAccId = callInfo.currentAccId,
                inCallUserAccIds = currentExcludedInviteUserIds(),
                remainingCount = remainingCount,
                maxMembers = Constants.MAX_MEMBER_COUNT
            ),
            NEResultObserver contactSelector@{ selected: List<String>? ->
                val filterResult = filterInviteUserIds(selected)
                val invitees = filterResult.invitees
                CallUILog.i(
                    TAG,
                    "invite selector result selectedCount:${selected.orEmpty().size} " +
                        "invitees:$invitees filteredAdded:${filterResult.hasAdded} " +
                        "filteredInCall:${filterResult.hasInCall}"
                )
                showInviteFilterToast(filterResult)
                when {
                    invitees.isEmpty() -> return@contactSelector
                    invitees.size > remainingCount -> {
                        activity.getString(R.string.ui_member_exceed_limit).toastShort(activity)
                    }
                    else -> inviteMembers(invitees)
                }
            }
        )
    }

    private fun filterInviteUserIds(userIds: List<String>?): InviteFilterResult {
        if (userIds.isNullOrEmpty()) {
            return InviteFilterResult(emptyList())
        }
        val filterUsers = currentInviteFilterUsers()
        val result = linkedSetOf<String>()
        var hasAdded = false
        var hasInCall = false
        userIds.forEach { item ->
            val accId = item.trim()
            when {
                accId.isEmpty() -> Unit
                filterUsers.added.contains(accId) -> hasAdded = true
                filterUsers.inCall.contains(accId) -> hasInCall = true
                !result.add(accId) -> hasAdded = true
            }
        }
        return InviteFilterResult(result.toList(), hasAdded, hasInCall)
    }

    private fun showInviteFilterToast(result: InviteFilterResult) {
        when {
            result.hasInCall -> {
                activity.getString(R.string.single_to_group_invite_already_in_call)
                    .toastShort(activity)
            }
            result.hasAdded -> {
                activity.getString(R.string.single_to_group_invite_already_added)
                    .toastShort(activity)
            }
        }
    }

    private fun currentExcludedInviteUserIds(): List<String> {
        val excluded = linkedSetOf<String>()
        val callInfo = callEngine.callInfo
        excluded.add(callInfo.currentAccId)
        callEngine.currentMembers().forEach { member ->
            if (member.state != NECallMemberState.LEAVING) {
                excluded.add(member.userID)
            }
        }
        return excluded.toList()
    }

    private fun currentInviteFilterUsers(): InviteFilterUsers {
        val added = linkedSetOf<String>()
        val inCall = linkedSetOf<String>()
        val callInfo = callEngine.callInfo
        inCall.add(callInfo.currentAccId)
        callEngine.currentMembers().forEach { member ->
            when (member.state) {
                NECallMemberState.WAITING -> added.add(member.userID)
                NECallMemberState.JOINED -> inCall.add(member.userID)
            }
        }
        return InviteFilterUsers(added, inCall)
    }

    private data class InviteFilterResult(
        val invitees: List<String>,
        val hasAdded: Boolean = false,
        val hasInCall: Boolean = false
    )

    private data class InviteFilterUsers(
        val added: Set<String>,
        val inCall: Set<String>
    )

    private data class OperationLogState(
        val audioMuted: Boolean,
        val videoMuted: Boolean,
        val speakerOn: Boolean,
        val virtualBlur: Boolean
    )

    private fun inviteMembers(invitees: List<String>) {
        CallUILog.i(TAG, "inviteSingleToGroupMembers invitees: $invitees")
        expireSwitchCallTypeInvite("inviteMembers")
        val inviteParamBuilder = NECallInviteParam.Builder(invitees)
            .maxMembers(Constants.MAX_MEMBER_COUNT)
        callParam.pushConfig?.let { inviteParamBuilder.pushConfig(it) }
        callEngine.inviteMembers(
            inviteParamBuilder.build(),
            object : NEResultObserver<CommonResult<NECallInviteResult>> {
                override fun onResult(result: CommonResult<NECallInviteResult>?) {
                    activity.runOnUiThread {
                        val inviteResult = result?.data
                        val itemResults = inviteResult?.results.orEmpty()
                        val successCount = itemResults.count { it.success }
                        val failedCount = itemResults.size - successCount
                        val message = when {
                            result?.isSuccessful() == true && successCount > 0 && failedCount > 0 ->
                                activity.getString(R.string.single_to_group_invite_partial)
                            result?.isSuccessful() == true ->
                                activity.getString(R.string.single_to_group_invite_success)
                            !result?.msg.isNullOrEmpty() ->
                                result?.msg ?: activity.getString(R.string.single_to_group_invite_failed)
                            else -> activity.getString(R.string.single_to_group_invite_failed)
                        }
                        message.toastShort(activity)
                        CallUILog.i(
                            TAG,
                            "inviteSingleToGroupMembers result success:${result?.isSuccessful()} " +
                                "successCount:$successCount failedCount:$failedCount msg:${result?.msg}"
                        )
                        updateInviteEntry()
                    }
                }
            }
        )
    }

    private fun remainingInviteCount(): Int {
        val visibleMemberCount = callEngine.currentMembers()
            .filter { it.state != NECallMemberState.LEAVING }
            .map { it.userID }
            .toSet()
            .size
        val currentMemberCount = maxOf(visibleMemberCount, 2)
        return Constants.MAX_MEMBER_COUNT - currentMemberCount
    }

    private fun inviteStateToastMessage(infos: List<NECallInviteStateInfo>): String? {
        infos.firstOrNull { it.state == NECallInviteState.UNSUPPORTED }?.let {
            val invitee = it.inviteeUserID?.takeIf { userId -> userId.isNotBlank() }
            return if (invitee.isNullOrEmpty()) {
                activity.getString(R.string.single_to_group_invite_unsupported)
            } else {
                activity.getString(R.string.single_to_group_invite_peer_unsupported, invitee)
            }
        }
        infos.firstOrNull {
            it.state == NECallInviteState.REJECTED ||
                it.state == NECallInviteState.TIMEOUT ||
                it.state == NECallInviteState.BUSY ||
                it.state == NECallInviteState.FAILED ||
                it.state == NECallInviteState.CANCELED
        }?.let {
            return when (it.state) {
                NECallInviteState.BUSY -> activity.getString(R.string.tip_busy_by_other)
                NECallInviteState.REJECTED -> activity.getString(R.string.tip_reject_by_other)
                NECallInviteState.TIMEOUT -> activity.getString(R.string.tip_timeout_by_other)
                NECallInviteState.CANCELED -> activity.getString(R.string.tip_cancel_by_other)
                else -> it.message ?: activity.getString(R.string.single_to_group_invite_failed)
            }
        }
        return null
    }

    private fun expireSwitchCallTypeInvite(reason: String) {
        CallUIOperationsMgr.expireSwitchCallTypeInvite(reason)
        (activity as? CommonCallActivity)?.dismissSwitchCallTypeConfirmDialog()
        CallUIFloatingWindowMgr.dismissSwitchCallTypeConfirmDialog()
        com.netease.yunxin.nertc.ui.hybird.FloatingWindowManager
            .dismissSwitchCallTypeConfirmDialog()
    }
}
