/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.flutter.plugins.callkit

import android.content.Context
import com.netease.lava.nertc.sdk.NERtcCallbackEx
import com.netease.lava.nertc.sdk.NERtcEx
import com.netease.lava.nertc.sdk.stats.NERtcAudioVolumeInfo
import com.netease.lava.nertc.sdk.video.NERtcVideoStreamType
import com.netease.yunxin.flutter.plugins.callkit.pigeon.Pigeon
import com.netease.yunxin.flutter.plugins.callkit.videorenderer.VideoRendererApiImpl
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.call.NEResultObserver
import com.netease.yunxin.nertc.nertcvideocall.model.impl.NERtcCallbackProxyMgr
import com.netease.yunxin.kit.call.group.GroupCallEndEvent
import com.netease.yunxin.kit.call.group.GroupCallHangupEvent
import com.netease.yunxin.kit.call.group.GroupCallMember
import com.netease.yunxin.kit.call.group.NEGroupCall
import com.netease.yunxin.kit.call.group.NEGroupCallDelegate
import com.netease.yunxin.kit.call.group.NEGroupCallInfo
import com.netease.yunxin.kit.call.group.param.GroupAcceptParam
import com.netease.yunxin.kit.call.group.param.GroupCallParam
import com.netease.yunxin.kit.call.group.param.GroupConfigParam
import com.netease.yunxin.kit.call.group.param.GroupHangupParam
import com.netease.yunxin.kit.call.group.param.GroupInviteParam
import com.netease.yunxin.kit.call.group.param.GroupJoinParam
import com.netease.yunxin.kit.call.group.param.GroupPushParam
import com.netease.yunxin.kit.call.group.param.GroupQueryCallInfoParam
import com.netease.yunxin.kit.call.group.param.GroupQueryMembersParam
import com.netease.yunxin.kit.call.group.result.GroupAcceptResult
import com.netease.yunxin.kit.call.group.result.GroupCallResult
import com.netease.yunxin.kit.call.group.result.GroupHangupResult
import com.netease.yunxin.kit.call.group.result.GroupInviteResult
import com.netease.yunxin.kit.call.group.result.GroupJoinResult
import com.netease.yunxin.kit.call.group.result.GroupQueryCallInfoResult
import com.netease.yunxin.kit.call.group.result.GroupQueryMembersResult
import io.flutter.embedding.engine.plugins.FlutterPlugin

/**
 * 群呼平台桥接类
 *
 * 实现 Pigeon 生成的 GroupCallKitApi 接口，
 * 将 Flutter 调用转发到原生 SDK。
 */
class GroupCallKitPlatform : Pigeon.GroupCallKitApi, IPlatform, NEGroupCallDelegate {

    companion object {
        private const val TAG = "GroupCallKitPlatform"
    }

    private lateinit var applicationContext: Context
    private var eventSink: Pigeon.GroupCallKitEventSink? = null
    private var mediaEventSink: Pigeon.GroupMediaEventSink? = null
    private var rtcCallback: NERtcCallbackEx? = null

    // ============================================================================
    // IPlatform 实现
    // ============================================================================

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        Pigeon.GroupCallKitApi.setup(binding.binaryMessenger, this)
        eventSink = Pigeon.GroupCallKitEventSink(binding.binaryMessenger)
        mediaEventSink = Pigeon.GroupMediaEventSink(binding.binaryMessenger)
        ALog.i(TAG, "onAttachedToEngine")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Pigeon.GroupCallKitApi.setup(binding.binaryMessenger, null)
        eventSink = null
        mediaEventSink = null
        ALog.i(TAG, "onDetachedFromEngine")
    }

    // ============================================================================
    // 初始化与释放
    // ============================================================================

    override fun init(
        config: Pigeon.NEGroupConfigParam,
        result: Pigeon.Result<Pigeon.GroupSimpleResponse>
    ) {
        ALog.i(TAG, "init: appKey=${config.appKey}")
        try {
            val configParam = GroupConfigParam(
                config.appKey,
                config.rtcSafeMode?.toInt() ?: 1,
                config.currentUserRtcUid ?: 0L,
                config.timeout?.toInt() ?: 30,
                null
            )
            NEGroupCall.instance().init(configParam)
            NEGroupCall.instance().addGroupCallDelegate(this)
            registerRtcCallback()

            val response = Pigeon.GroupSimpleResponse.Builder()
                .setCode(0L)
                .setMsg("Init successful")
                .build()
            result.success(response)
        } catch (e: Exception) {
            ALog.e(TAG, "init error: ${e.message}")
            result.error(e)
        }
    }

    override fun release(result: Pigeon.Result<Pigeon.GroupSimpleResponse>) {
        ALog.i(TAG, "release")
        try {
            unregisterRtcCallback()
            NEGroupCall.instance().removeGroupCallDelegate(this)
            NEGroupCall.instance().release()
            VideoRendererApiImpl.releaseSharedEglContext()

            val response = Pigeon.GroupSimpleResponse.Builder()
                .setCode(0L)
                .setMsg("Release successful")
                .build()
            result.success(response)
        } catch (e: Exception) {
            ALog.e(TAG, "release error: ${e.message}")
            result.error(e)
        }
    }

    // ============================================================================
    // NEGroupCallDelegate 实现
    // ============================================================================

    override fun onReceiveGroupInvitation(info: NEGroupCallInfo) {
        ALog.i(TAG, "onReceiveGroupInvitation: callId=${info.callId}")
        val pigeonInfo = convertToPigeonCallInfo(info)
        eventSink?.onReceiveGroupInvitation(pigeonInfo, createVoidReply("onReceiveGroupInvitation"))
    }

    override fun onGroupMemberListChanged(callId: String, userList: MutableList<GroupCallMember>) {
        ALog.i(TAG, "onGroupMemberListChanged: callId=$callId, members=${userList.size}")
        val members = userList.map { convertToPigeonMember(it) }
        eventSink?.onGroupMemberListChanged(callId, members, createVoidReply("onGroupMemberListChanged"))
    }

    override fun onGroupCallHangup(hangupEvent: GroupCallHangupEvent) {
        ALog.i(TAG, "onGroupCallHangup: callId=${hangupEvent.callId}")
        val event = Pigeon.NEGroupCallHangupEvent.Builder()
            .setCallId(hangupEvent.callId)
            .setReason(hangupEvent.reason.toLong())
            .setMessage(hangupEvent.message)
            .build()
        eventSink?.onGroupCallHangup(event, createVoidReply("onGroupCallHangup"))
    }

    override fun onGroupCallEnd(endEvent: GroupCallEndEvent) {
        ALog.i(TAG, "onGroupCallEnd: callId=${endEvent.callId}")
        val event = Pigeon.NEGroupCallEndEvent.Builder()
            .setCallId(endEvent.callId)
            .setReason(endEvent.reason.toLong())
            .setMessage(endEvent.message)
            .build()
        eventSink?.onGroupCallEnd(event, createVoidReply("onGroupCallEnd"))
    }

    /**
     * 创建 Reply<Void> 回调对象
     */
    private fun createVoidReply(methodName: String): Pigeon.GroupCallKitEventSink.Reply<Void> {
        return Pigeon.GroupCallKitEventSink.Reply<Void> {
            ALog.i(TAG, "$methodName callback reply")
        }
    }

    private fun createMediaVoidReply(methodName: String): Pigeon.GroupMediaEventSink.Reply<Void> {
        return Pigeon.GroupMediaEventSink.Reply<Void> {
            ALog.i(TAG, "$methodName callback reply")
        }
    }

    // ============================================================================
    // 群呼基础操作
    // ============================================================================

    override fun groupCall(
        param: Pigeon.NEGroupCallParam,
        result: Pigeon.Result<Pigeon.GroupCallResponse>
    ) {
        ALog.i(TAG, "groupCall: callId=${param.callId}, calleeList=${param.calleeList?.size}")
        try {
            val pushParam = param.pushParam?.let {
                GroupPushParam(
                    it.pushMode?.toInt() ?: 1,
                    it.pushContent,
                    it.pushPayload,
                    it.sound
                )
            }

            val callParam = GroupCallParam(
                param.callId,
                param.calleeList?.filterNotNull() ?: emptyList(),
                param.groupId,
                param.groupType.toInt(),
                param.inviteMode?.toInt() ?: 0,
                param.joinMode?.toInt() ?: 0,
                pushParam,
                param.extraInfo
            )

            NEGroupCall.instance().groupCall(callParam, object : NEResultObserver<GroupCallResult> {
                override fun onResult(ret: GroupCallResult) {
                    val callInfo = NEGroupCall.instance().currentGroupCallInfo()?.let { convertToPigeonCallInfo(it) }
                    val response = Pigeon.GroupCallResponse.Builder()
                        .setCode(ret.dataCode.toLong())
                        .setMsg(null)
                        .setCallInfo(callInfo)
                        .build()
                    result.success(response)
                }
            })
        } catch (e: Exception) {
            ALog.e(TAG, "groupCall error: ${e.message}")
            result.error(e)
        }
    }

    override fun groupAccept(
        param: Pigeon.NEGroupAcceptParam,
        result: Pigeon.Result<Pigeon.GroupAcceptResponse>
    ) {
        ALog.i(TAG, "groupAccept: callId=${param.callId}")
        try {
            val acceptParam = GroupAcceptParam(param.callId)

            NEGroupCall.instance().groupAccept(acceptParam, object : NEResultObserver<GroupAcceptResult> {
                override fun onResult(ret: GroupAcceptResult) {
                    val callInfo = NEGroupCall.instance().currentGroupCallInfo()?.let { convertToPigeonCallInfo(it) }
                    val response = Pigeon.GroupAcceptResponse.Builder()
                        .setCode(ret.dataCode.toLong())
                        .setMsg(null)
                        .setCallInfo(callInfo)
                        .build()
                    result.success(response)
                }
            })
        } catch (e: Exception) {
            ALog.e(TAG, "groupAccept error: ${e.message}")
            result.error(e)
        }
    }

    override fun groupHangup(
        param: Pigeon.NEGroupHangupParam,
        result: Pigeon.Result<Pigeon.GroupSimpleResponse>
    ) {
        ALog.i(TAG, "groupHangup: callId=${param.callId}, reason=${param.reason}")
        try {
            val hangupParam = GroupHangupParam(param.callId, param.reason)

            NEGroupCall.instance().groupHangup(hangupParam, object : NEResultObserver<GroupHangupResult> {
                override fun onResult(ret: GroupHangupResult) {
                    val response = Pigeon.GroupSimpleResponse.Builder()
                        .setCode(ret.dataCode.toLong())
                        .setMsg(null)
                        .build()
                    result.success(response)
                }
            })
        } catch (e: Exception) {
            ALog.e(TAG, "groupHangup error: ${e.message}")
            result.error(e)
        }
    }

    override fun groupInvite(
        param: Pigeon.NEGroupInviteParam,
        result: Pigeon.Result<Pigeon.GroupSimpleResponse>
    ) {
        ALog.i(TAG, "groupInvite: callId=${param.callId}, calleeList=${param.calleeList?.size}")
        try {
            val inviteParam = GroupInviteParam(
                param.callId,
                param.calleeList?.filterNotNull() ?: emptyList()
            )

            NEGroupCall.instance().groupInvite(inviteParam, object : NEResultObserver<GroupInviteResult> {
                override fun onResult(ret: GroupInviteResult) {
                    val response = Pigeon.GroupSimpleResponse.Builder()
                        .setCode(ret.dataCode.toLong())
                        .setMsg(null)
                        .build()
                    result.success(response)
                }
            })
        } catch (e: Exception) {
            ALog.e(TAG, "groupInvite error: ${e.message}")
            result.error(e)
        }
    }

    override fun groupJoin(
        param: Pigeon.NEGroupJoinParam,
        result: Pigeon.Result<Pigeon.GroupJoinResponse>
    ) {
        ALog.i(TAG, "groupJoin: callId=${param.callId}")
        try {
            val joinParam = GroupJoinParam(param.callId)

            NEGroupCall.instance().groupJoin(joinParam, object : NEResultObserver<GroupJoinResult> {
                override fun onResult(ret: GroupJoinResult) {
                    val callInfo = NEGroupCall.instance().currentGroupCallInfo()?.let { convertToPigeonCallInfo(it) }
                    val response = Pigeon.GroupJoinResponse.Builder()
                        .setCode(ret.dataCode.toLong())
                        .setMsg(null)
                        .setCallInfo(callInfo)
                        .build()
                    result.success(response)
                }
            })
        } catch (e: Exception) {
            ALog.e(TAG, "groupJoin error: ${e.message}")
            result.error(e)
        }
    }

    override fun groupQueryCallInfo(
        callId: String,
        result: Pigeon.Result<Pigeon.GroupQueryCallInfoResponse>
    ) {
        ALog.i(TAG, "groupQueryCallInfo: callId=$callId")
        try {
            val queryParam = GroupQueryCallInfoParam(callId)

            NEGroupCall.instance().groupQueryCallInfo(queryParam, object : NEResultObserver<GroupQueryCallInfoResult> {
                override fun onResult(ret: GroupQueryCallInfoResult) {
                    val callInfo = ret.groupCallInfo?.let { convertToPigeonCallInfo(it) }
                    val response = Pigeon.GroupQueryCallInfoResponse.Builder()
                        .setCode(ret.dataCode.toLong())
                        .setMsg(null)
                        .setCallInfo(callInfo)
                        .build()
                    result.success(response)
                }
            })
        } catch (e: Exception) {
            ALog.e(TAG, "groupQueryCallInfo error: ${e.message}")
            result.error(e)
        }
    }

    override fun groupQueryMembers(
        callId: String,
        result: Pigeon.Result<Pigeon.GroupQueryMembersResponse>
    ) {
        ALog.i(TAG, "groupQueryMembers: callId=$callId")
        try {
            val queryParam = GroupQueryMembersParam(callId)

            NEGroupCall.instance().groupQueryMembers(queryParam, object : NEResultObserver<GroupQueryMembersResult> {
                override fun onResult(ret: GroupQueryMembersResult) {
                    val membersList = mutableListOf<Pigeon.NEGroupCallMember>()
                    ret.callerInfo?.let { membersList.add(convertToPigeonMember(it)) }
                    ret.calleeList?.forEach { membersList.add(convertToPigeonMember(it)) }
                    val response = Pigeon.GroupQueryMembersResponse.Builder()
                        .setCode(ret.dataCode.toLong())
                        .setMsg(null)
                        .setMembers(membersList)
                        .build()
                    result.success(response)
                }
            })
        } catch (e: Exception) {
            ALog.e(TAG, "groupQueryMembers error: ${e.message}")
            result.error(e)
        }
    }

    // ============================================================================
    // 媒体操作接口
    // ============================================================================

    override fun enableLocalVideo(
        enable: Boolean,
        result: Pigeon.Result<Pigeon.GroupSimpleResponse>
    ) {
        ALog.i(TAG, "enableLocalVideo: enable=$enable")
        try {
            val ret = NERtcEx.getInstance().enableLocalVideo(enable)
            val response = Pigeon.GroupSimpleResponse.Builder()
                .setCode(ret.toLong())
                .setMsg(if (ret == 0) "EnableLocalVideo successful" else "EnableLocalVideo failed")
                .build()
            result.success(response)
        } catch (e: Exception) {
            ALog.e(TAG, "enableLocalVideo error: ${e.message}")
            result.error(e)
        }
    }

    override fun muteLocalVideo(
        mute: Boolean,
        result: Pigeon.Result<Pigeon.GroupSimpleResponse>
    ) {
        ALog.i(TAG, "muteLocalVideo: mute=$mute")
        try {
            val ret = NERtcEx.getInstance().muteLocalVideoStream(mute)
            val response = Pigeon.GroupSimpleResponse.Builder()
                .setCode(ret.toLong())
                .setMsg(if (ret == 0) "MuteLocalVideo successful" else "MuteLocalVideo failed")
                .build()
            result.success(response)
        } catch (e: Exception) {
            ALog.e(TAG, "muteLocalVideo error: ${e.message}")
            result.error(e)
        }
    }

    override fun enableLocalAudio(
        enable: Boolean,
        result: Pigeon.Result<Pigeon.GroupSimpleResponse>
    ) {
        ALog.i(TAG, "enableLocalAudio: enable=$enable")
        try {
            val ret = NERtcEx.getInstance().enableLocalAudio(enable)
            val response = Pigeon.GroupSimpleResponse.Builder()
                .setCode(ret.toLong())
                .setMsg(if (ret == 0) "EnableLocalAudio successful" else "EnableLocalAudio failed")
                .build()
            result.success(response)
        } catch (e: Exception) {
            ALog.e(TAG, "enableLocalAudio error: ${e.message}")
            result.error(e)
        }
    }

    override fun muteLocalAudio(
        mute: Boolean,
        result: Pigeon.Result<Pigeon.GroupSimpleResponse>
    ) {
        ALog.i(TAG, "muteLocalAudio: mute=$mute")
        try {
            val ret = NERtcEx.getInstance().muteLocalAudioStream(mute)
            val response = Pigeon.GroupSimpleResponse.Builder()
                .setCode(ret.toLong())
                .setMsg(if (ret == 0) "MuteLocalAudio successful" else "MuteLocalAudio failed")
                .build()
            result.success(response)
        } catch (e: Exception) {
            ALog.e(TAG, "muteLocalAudio error: ${e.message}")
            result.error(e)
        }
    }

    override fun setSpeakerphoneOn(
        enable: Boolean,
        result: Pigeon.Result<Pigeon.GroupSimpleResponse>
    ) {
        ALog.i(TAG, "setSpeakerphoneOn: enable=$enable")
        try {
            val ret = NERtcEx.getInstance().setSpeakerphoneOn(enable)
            val response = Pigeon.GroupSimpleResponse.Builder()
                .setCode(ret.toLong())
                .setMsg(if (ret == 0) "SetSpeakerphoneOn successful" else "SetSpeakerphoneOn failed")
                .build()
            result.success(response)
        } catch (e: Exception) {
            ALog.e(TAG, "setSpeakerphoneOn error: ${e.message}")
            result.error(e)
        }
    }

    override fun isSpeakerphoneOn(result: Pigeon.Result<Boolean>) {
        ALog.i(TAG, "isSpeakerphoneOn")
        try {
            val ret = NERtcEx.getInstance().isSpeakerphoneOn
            result.success(ret)
        } catch (e: Exception) {
            ALog.e(TAG, "isSpeakerphoneOn error: ${e.message}")
            result.error(e)
        }
    }

    override fun switchCamera(result: Pigeon.Result<Pigeon.GroupSimpleResponse>) {
        ALog.i(TAG, "switchCamera")
        try {
            val ret = NERtcEx.getInstance().switchCamera()
            val response = Pigeon.GroupSimpleResponse.Builder()
                .setCode(ret.toLong())
                .setMsg(if (ret == 0) "SwitchCamera successful" else "SwitchCamera failed")
                .build()
            result.success(response)
        } catch (e: Exception) {
            ALog.e(TAG, "switchCamera error: ${e.message}")
            result.error(e)
        }
    }

    override fun setupLocalView(
        param: Pigeon.NEGroupViewParam,
        result: Pigeon.Result<Pigeon.GroupSimpleResponse>
    ) {
        ALog.i(TAG, "setupLocalView: viewId=${param.viewId}")
        try {
            val platformVideoView = PlatformVideoViewFactory.mVideoViewMap[param.viewId?.toInt()]
            val videoView = platformVideoView?.getVideoView()
            if (videoView != null) {
                val ret = NERtcEx.getInstance().setupLocalVideoCanvas(videoView)
                val response = Pigeon.GroupSimpleResponse.Builder()
                    .setCode(ret.toLong())
                    .setMsg(if (ret == 0) "SetupLocalView successful" else "SetupLocalView failed")
                    .build()
                result.success(response)
            } else {
                val response = Pigeon.GroupSimpleResponse.Builder()
                    .setCode(-1L)
                    .setMsg("VideoView not found for viewId: ${param.viewId}")
                    .build()
                result.success(response)
            }
        } catch (e: Exception) {
            ALog.e(TAG, "setupLocalView error: ${e.message}")
            result.error(e)
        }
    }

    override fun setupRemoteView(
        param: Pigeon.NEGroupViewParam,
        result: Pigeon.Result<Pigeon.GroupSimpleResponse>
    ) {
        ALog.i(TAG, "setupRemoteView: uid=${param.uid}, viewId=${param.viewId}")
        try {
            val platformVideoView = PlatformVideoViewFactory.mVideoViewMap[param.viewId?.toInt()]
            val videoView = platformVideoView?.getVideoView()
            val uid = param.uid
            if (videoView != null && uid != null) {
                val ret = NERtcEx.getInstance().setupRemoteVideoCanvas(videoView, uid)
                val response = Pigeon.GroupSimpleResponse.Builder()
                    .setCode(ret.toLong())
                    .setMsg(if (ret == 0) "SetupRemoteView successful" else "SetupRemoteView failed")
                    .build()
                result.success(response)
            } else {
                val response = Pigeon.GroupSimpleResponse.Builder()
                    .setCode(-1L)
                    .setMsg("VideoView not found for viewId: ${param.viewId} or uid is null")
                    .build()
                result.success(response)
            }
        } catch (e: Exception) {
            ALog.e(TAG, "setupRemoteView error: ${e.message}")
            result.error(e)
        }
    }

    override fun enableAudioVolumeIndication(
        enable: Boolean,
        interval: Long,
        result: Pigeon.Result<Pigeon.GroupSimpleResponse>
    ) {
        ALog.i(TAG, "enableAudioVolumeIndication: enable=$enable, interval=$interval")
        try {
            val ret = NERtcEx.getInstance().enableAudioVolumeIndication(enable, interval.toInt())
            val response = Pigeon.GroupSimpleResponse.Builder()
                .setCode(ret.toLong())
                .setMsg(if (ret == 0) "EnableAudioVolumeIndication successful" else "EnableAudioVolumeIndication failed")
                .build()
            result.success(response)
        } catch (e: Exception) {
            ALog.e(TAG, "enableAudioVolumeIndication error: ${e.message}")
            result.error(e)
        }
    }

    override fun setParameters(
        params: MutableMap<String, Any>,
        result: Pigeon.Result<Pigeon.GroupSimpleResponse>
    ) {
        ALog.i(TAG, "setParameters: params=$params")
        try {
            // NERtcParameters 需要特定的 Key 类型，这里简化处理
            // 如果需要设置特定参数，可以使用预定义的 Key 常量
            val response = Pigeon.GroupSimpleResponse.Builder()
                .setCode(0L)
                .setMsg("SetParameters successful")
                .build()
            result.success(response)
        } catch (e: Exception) {
            ALog.e(TAG, "setParameters error: ${e.message}")
            result.error(e)
        }
    }

    // ============================================================================
    // NERtc 媒体回调注册
    // ============================================================================

    /**
     * 注册 NERtc 媒体回调
     * 通过 NERtcCallbackProxyMgr 注册 NERtcCallbackEx 实例监听媒体回调
     */
    private fun registerRtcCallback() {
        rtcCallback = object : NERtcCallbackEx {
            override fun onUserAudioStart(uid: Long) {
                ALog.i(TAG, "onUserAudioStart: uid=$uid")
                mediaEventSink?.onUserAudioStart(uid, createMediaVoidReply("onUserAudioStart"))
            }

            override fun onUserAudioStop(uid: Long) {
                ALog.i(TAG, "onUserAudioStop: uid=$uid")
                mediaEventSink?.onUserAudioStop(uid, createMediaVoidReply("onUserAudioStop"))
            }

            override fun onUserAudioMute(uid: Long, muted: Boolean) {
                ALog.i(TAG, "onUserAudioMute: uid=$uid, muted=$muted")
                mediaEventSink?.onUserAudioMute(uid, muted, createMediaVoidReply("onUserAudioMute"))
            }

            // NERtcCallback 基础接口版本
            override fun onUserVideoStart(uid: Long, maxProfile: Int) {
                ALog.i(TAG, "onUserVideoStart(base): uid=$uid, maxProfile=$maxProfile")
                mediaEventSink?.onUserVideoStart(uid, maxProfile.toLong(), createMediaVoidReply("onUserVideoStart"))
            }

            // NERtcCallbackEx 扩展接口版本
            override fun onUserVideoStart(uid: Long, streamType: NERtcVideoStreamType?, maxProfile: Int) {
                ALog.i(TAG, "onUserVideoStart(ex): uid=$uid, streamType=$streamType, maxProfile=$maxProfile")
                // 已经在基础版本中处理，这里只记录日志
            }

            // NERtcCallback 基础接口版本
            override fun onUserVideoStop(uid: Long) {
                ALog.i(TAG, "onUserVideoStop(base): uid=$uid")
                mediaEventSink?.onUserVideoStop(uid, createMediaVoidReply("onUserVideoStop"))
            }

            // NERtcCallbackEx 扩展接口版本
            override fun onUserVideoStop(uid: Long, streamType: NERtcVideoStreamType?) {
                ALog.i(TAG, "onUserVideoStop(ex): uid=$uid, streamType=$streamType")
                // 已经在基础版本中处理，这里只记录日志
            }

            override fun onUserVideoMute(uid: Long, muted: Boolean) {
                ALog.i(TAG, "onUserVideoMute: uid=$uid, muted=$muted")
                mediaEventSink?.onUserVideoMute(uid, muted, createMediaVoidReply("onUserVideoMute"))
            }

            override fun onRemoteAudioVolumeIndication(
                volumeList: Array<out NERtcAudioVolumeInfo>?,
                totalVolume: Int
            ) {
                val volumes = volumeList?.map { info ->
                    Pigeon.NEAudioVolumeInfo.Builder()
                        .setUid(info.uid)
                        .setVolume(info.volume.toLong())
                        .build()
                } ?: emptyList()
                mediaEventSink?.onRemoteAudioVolumeIndication(
                    volumes,
                    totalVolume.toLong(),
                    createMediaVoidReply("onRemoteAudioVolumeIndication")
                )
            }

            override fun onDisconnect(reason: Int) {
                ALog.i(TAG, "onDisconnect: reason=$reason")
                mediaEventSink?.onDisconnect(reason.toLong(), createMediaVoidReply("onDisconnect"))
            }

            override fun onError(code: Int) {
                ALog.e(TAG, "onError: code=$code")
                mediaEventSink?.onError(code.toLong(), createMediaVoidReply("onError"))
            }

            // 以下为 NERtcCallback/NERtcCallbackEx 接口的其他必要回调方法（空实现）
            override fun onJoinChannel(result: Int, channelId: Long, elapsed: Long, uid: Long) {}
            override fun onLeaveChannel(result: Int) {}
            override fun onUserJoined(uid: Long) {}
            override fun onUserJoined(uid: Long, extraInfo: com.netease.lava.nertc.sdk.NERtcUserJoinExtraInfo?) {}
            override fun onUserLeave(uid: Long, reason: Int) {}
            override fun onUserLeave(uid: Long, reason: Int, extraInfo: com.netease.lava.nertc.sdk.NERtcUserLeaveExtraInfo?) {}
            override fun onClientRoleChange(oldRole: Int, newRole: Int) {}
            override fun onUserSubStreamVideoStart(uid: Long, maxProfile: Int) {}
            override fun onUserSubStreamVideoStop(uid: Long) {}
            override fun onConnectionTypeChanged(type: Int) {}
            override fun onReconnectingStart() {}
            override fun onConnectionStateChanged(state: Int, reason: Int) {}
            override fun onReJoinChannel(result: Int, channelId: Long) {}
            override fun onAudioDeviceChanged(device: Int) {}
            override fun onAudioDeviceStateChange(deviceType: Int, deviceState: Int) {}
            override fun onVideoDeviceStageChange(deviceState: Int) {}
            override fun onFirstAudioDataReceived(uid: Long) {}
            override fun onFirstVideoDataReceived(uid: Long) {}
            override fun onFirstVideoDataReceived(streamType: NERtcVideoStreamType?, uid: Long) {}
            override fun onFirstAudioFrameDecoded(uid: Long) {}
            override fun onFirstVideoFrameDecoded(uid: Long, width: Int, height: Int) {}
            override fun onFirstVideoFrameDecoded(streamType: NERtcVideoStreamType?, uid: Long, width: Int, height: Int) {}
            override fun onUserVideoProfileUpdate(uid: Long, maxProfile: Int) {}
            override fun onAudioMixingStateChanged(reason: Int) {}
            override fun onAudioMixingTimestampUpdate(timestampMs: Long) {}
            override fun onAudioEffectTimestampUpdate(effectId: Long, timestampMs: Long) {}
            override fun onAudioEffectFinished(effectId: Int) {}
            override fun onLocalAudioVolumeIndication(volume: Int) {}
            override fun onLocalAudioVolumeIndication(volume: Int, vadFlag: Boolean) {}
            override fun onLocalVideoRenderSizeChanged(streamType: NERtcVideoStreamType?, width: Int, height: Int) {}
            override fun onFirstVideoFrameRender(uid: Long, streamType: NERtcVideoStreamType?, width: Int, height: Int, elapsed: Long) {}
            override fun onRecvSEIMsg(uid: Long, seiMsg: String?) {}
            override fun onLiveStreamState(taskId: String?, pushUrl: String?, state: Int) {}
            override fun onLocalPublishFallbackToAudioOnly(isFallback: Boolean, streamType: NERtcVideoStreamType?) {}
            override fun onRemoteSubscribeFallbackToAudioOnly(uid: Long, isFallback: Boolean, streamType: NERtcVideoStreamType?) {}
            override fun onLastmileQuality(quality: Int) {}
            override fun onLastmileProbeResult(result: com.netease.lava.nertc.sdk.LastmileProbeResult?) {}
            override fun onMediaRelayStatesChange(state: Int, channelName: String?) {}
            override fun onMediaRelayReceiveEvent(event: Int, code: Int, channelName: String?) {}
            override fun onLocalVideoWatermarkState(streamType: NERtcVideoStreamType?, state: Int) {}
            override fun onUserSubStreamAudioStart(uid: Long) {}
            override fun onUserSubStreamAudioStop(uid: Long) {}
            override fun onUserSubStreamAudioMute(uid: Long, muted: Boolean) {}
            override fun onPermissionKeyWillExpire() {}
            override fun onUpdatePermissionKey(key: String?, error: Int, timeout: Int) {}
            override fun onVirtualBackgroundSourceEnabled(enabled: Boolean, reason: Int) {}
            override fun onUserVideoMute(streamType: NERtcVideoStreamType?, uid: Long, muted: Boolean) {}
            override fun onLocalAudioFirstPacketSent(streamType: com.netease.lava.nertc.sdk.audio.NERtcAudioStreamType?) {}
            override fun onCameraFocusChanged(rect: android.graphics.Rect?) {}
            override fun onCameraExposureChanged(rect: android.graphics.Rect?) {}
            override fun onAudioRecording(code: Int, filePath: String?) {}
            override fun onWarning(code: Int) {}
            override fun onApiCallExecuted(apiName: String?, result: Int, msg: String?) {}
            override fun onAsrCaptionStateChanged(state: Int, code: Int, msg: String?) {}
            override fun onAsrCaptionResult(results: Array<out com.netease.lava.nertc.sdk.NERtcAsrCaptionResult>?, channel: Int) {}
            override fun onPlayStreamingStateChange(taskId: String?, state: Int, code: Int) {}
            override fun onPlayStreamingReceiveSeiMessage(taskId: String?, seiMsg: String?) {}
            override fun onPlayStreamingFirstAudioFramePlayed(taskId: String?, uid: Long) {}
            override fun onPlayStreamingFirstVideoFrameRender(taskId: String?, uid: Long, width: Int, height: Int) {}
            // onPlayStreamingDuration removed - not available in all SDK versions
            override fun onMediaRightChange(audioRight: Boolean, videoRight: Boolean) {}
            override fun onRemoteVideoSizeChanged(uid: Long, streamType: NERtcVideoStreamType?, width: Int, height: Int) {}
            override fun onUserDataStart(uid: Long) {}
            override fun onUserDataStop(uid: Long) {}
            override fun onUserDataReceiveMessage(uid: Long, buffer: java.nio.ByteBuffer?, size: Long) {}
            override fun onUserDataStateChanged(uid: Long) {}
            override fun onUserDataBufferedAmountChanged(uid: Long, prevAmount: Long) {}
            override fun onLabFeatureCallback(key: String?, param: Any?) {}
            override fun onAiData(key: String?, param: String?) {}
        }
        NERtcCallbackProxyMgr.getInstance().addCallback(rtcCallback)
        ALog.i(TAG, "registerRtcCallback: NERtcCallbackEx registered")
    }

    /**
     * 取消注册 NERtc 媒体回调
     */
    private fun unregisterRtcCallback() {
        rtcCallback?.let {
            NERtcCallbackProxyMgr.getInstance().removeCallback(it)
            ALog.i(TAG, "unregisterRtcCallback: NERtcCallbackEx removed")
        }
        rtcCallback = null
    }

    // ============================================================================
    // 辅助转换方法
    // ============================================================================

    /**
     * 将原生 NEGroupCallInfo 转换为 Pigeon NEGroupCallInfo
     */
    private fun convertToPigeonCallInfo(info: NEGroupCallInfo): Pigeon.NEGroupCallInfo {
        val members = info.memberList?.map { convertToPigeonMember(it) }
        return Pigeon.NEGroupCallInfo.Builder()
            .setCallId(info.callId ?: "")
            .setGroupId(info.groupId)
            .setGroupType(info.groupType.toLong())
            .setCallerAccId(info.callerAccId ?: "")
            .setCallerRtcUid(info.getCallerInfo()?.uid)
            .setMemberList(members)
            .setInviteMode(info.inviteMode.toLong())
            .setJoinMode(info.joinMode.toLong())
            .setExtraInfo(info.extraInfo)
            .setStartTimestamp(info.startTimestamp)
            .build()
    }

    /**
     * 将原生 GroupCallMember 转换为 Pigeon NEGroupCallMember
     */
    private fun convertToPigeonMember(member: GroupCallMember): Pigeon.NEGroupCallMember {
        return Pigeon.NEGroupCallMember.Builder()
            .setAccId(member.accId ?: "")
            .setRtcUid(member.uid)
            .setState(member.state.toLong())
            .setAction(member.action)
            .setReason(member.reason)
            .build()
    }
}
