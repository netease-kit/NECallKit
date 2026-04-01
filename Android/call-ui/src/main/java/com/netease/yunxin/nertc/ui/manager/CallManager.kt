/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.manager

import android.content.Context
import com.netease.lava.api.IVideoRender
import com.netease.lava.nertc.sdk.NERtcEx
import com.netease.lava.nertc.sdk.audio.NERtcAudioAINSMode
import com.netease.yunxin.kit.call.p2p.NECallEngine
import com.netease.yunxin.kit.call.p2p.model.NECallConfig
import com.netease.yunxin.kit.call.p2p.model.NECallInfo
import com.netease.yunxin.kit.call.p2p.param.NECallParam
import com.netease.yunxin.kit.call.p2p.param.NEHangupParam
import com.netease.yunxin.kit.call.p2p.param.NESwitchParam
import com.netease.yunxin.nertc.nertcvideocall.model.CallErrorCode
import com.netease.yunxin.nertc.ui.callback.NECallback
import com.netease.yunxin.nertc.ui.floating.FloatingWindowObserver
import com.netease.yunxin.nertc.ui.hybird.FloatingWindowManager
import com.netease.yunxin.nertc.ui.permission.PermissionCallback
import com.netease.yunxin.nertc.ui.permission.PermissionRequest
import com.netease.yunxin.nertc.ui.permission.PermissionRequester
import com.netease.yunxin.nertc.ui.utils.CallUILog

class CallManager {
    var callParams: NECallParam? = null
    var isLocalMuteAudio = false
    var isLocalMuteVideo = false

    fun setupLocalView(videoRender: IVideoRender) {
        CallUILog.i(TAG, "setupLocalView videoRender = $videoRender")
        videoRender.setScalingType(IVideoRender.ScalingType.SCALE_ASPECT_BALANCED)
        NECallEngine.sharedInstance().setupLocalView(videoRender)
    }

    fun setupRemoteView(videoRender: IVideoRender) {
        CallUILog.i(TAG, "setupRemoteView videoRender = $videoRender")
        videoRender.setScalingType(IVideoRender.ScalingType.SCALE_ASPECT_BALANCED)
        NECallEngine.sharedInstance().setupRemoteView(videoRender)
    }

    fun call(params: NECallParam, callback: NECallback<NECallInfo>?) {
        CallUILog.i(TAG, "call")
        this.callParams = params
        NECallEngine.sharedInstance().call(params) { result ->
            if (result?.code == 0) {
                callback?.onSuccess(result.data)
            } else {
                callback?.onError(result?.code ?: -1, result?.msg)
            }
        }
    }

    fun accept(callback: NECallback<NECallInfo>?) {
        CallUILog.i(TAG, "accept")
        NECallEngine.sharedInstance().accept { result ->
            if (result?.code == 0) {
                callback?.onSuccess(result.data)
            } else {
                callback?.onError(result?.code ?: -1, result?.msg)
            }
        }
    }

    fun hangup(param: NEHangupParam, callback: NECallback<Void>?) {
        CallUILog.i(TAG, "hangup param = $param")
        NECallEngine.sharedInstance().hangup(param) { result ->
            if (result?.code == 0) {
                callback?.onSuccess(result.data)
            } else {
                callback?.onError(result?.code ?: -1, result?.msg)
            }
        }
    }

    fun muteLocalAudio(mute: Boolean): Int {
        CallUILog.i(TAG, "muteLocalAudio mute = $mute")
        val result = NECallEngine.sharedInstance().muteLocalAudio(mute)
        if (result == 0) {
            isLocalMuteAudio = mute
        }
        CallUILog.i(TAG, "muteLocalAudio mute = $mute result = $result")
        return result
    }

    fun muteLocalVideo(mute: Boolean): Int {
        CallUILog.i(TAG, "muteLocalVideo mute = $mute")
        val result = NECallEngine.sharedInstance().muteLocalVideo(mute)
        if (result == 0) {
            isLocalMuteVideo = mute
        }
        CallUILog.i(TAG, "muteLocalVideo mute = $mute result = $result")
        return result
    }

    fun enableLocalVideo(enable: Boolean): Int {
        CallUILog.i(TAG, "enableLocalVideo enable = $enable")
        val result = NECallEngine.sharedInstance().enableLocalVideo(enable)
        CallUILog.i(TAG, "enableLocalVideo enable = $enable result = $result")
        return result
    }

    fun setTimeout(millisecond: Long) {
        CallUILog.i(TAG, "setTimeout millisecond = $millisecond")
        NECallEngine.sharedInstance().setTimeout(millisecond)
    }

    fun switchCallType(param: NESwitchParam, callback: NECallback<Void>?) {
        CallUILog.i(TAG, "switchCallType param = $param")
        NECallEngine.sharedInstance().switchCallType(
            param
        ) { result ->
            if (result?.code == 0) {
                callback?.onSuccess(result.data)
            } else {
                callback?.onError(result?.code ?: -1, result?.msg)
            }
        }
    }

    fun switchCamera(position: Int) {
        CallUILog.i(TAG, "switchCamera position = $position")
        NERtcEx.getInstance().switchCameraWithPosition(position)
    }

    fun setSpeakerphoneOn(enable: Boolean): Int {
        CallUILog.i(TAG, "setSpeakerphoneOn enable = $enable")
        return NECallEngine.sharedInstance().setSpeakerphoneOn(enable)
    }

    fun isSpeakerphoneOn(): Boolean {
        CallUILog.i(TAG, "isSpeakerphoneOn")
        return NECallEngine.sharedInstance().isSpeakerphoneOn()
    }

    fun setCallConfig(config: NECallConfig) {
        CallUILog.i(TAG, "setCallConfig config = $config")
        NECallEngine.sharedInstance().callConfig = config
    }

    fun getCallConfig(): NECallConfig? {
        CallUILog.i(TAG, "getCallConfig")
        return NECallEngine.sharedInstance().callConfig
    }

    fun getCallInfo(): NECallInfo? {
        CallUILog.i(TAG, "getCallInfo")
        return NECallEngine.sharedInstance().callInfo
    }

    fun setAINSMode(mode: NERtcAudioAINSMode): Int {
        CallUILog.i(TAG, "setAINSMode mode = $mode")
        return NECallEngine.sharedInstance().setAINSMode(mode)
    }

    fun destroy() {
        CallUILog.i(TAG, "destroy")
        NECallEngine.sharedInstance().destroy()
    }

    fun addFloatWindowObserver(observer: FloatingWindowObserver) {
        CallUILog.i(TAG, "addFloatWindowObserver, observer: $observer")
        FloatingWindowManager.addFloatWindowObserver(observer)
    }

    fun removeFloatWindowObserver(observer: FloatingWindowObserver) {
        CallUILog.i(TAG, "removeFloatWindowObserver, observer: $observer")
        FloatingWindowManager.removeFloatWindowObserver(observer)
    }

    fun startFloatWindow(context: Context) {
        CallUILog.i(TAG, "startFloatWindow")
        if (FloatingWindowManager.isFloating()) {
            CallUILog.i(TAG, "There is already a floatWindow on display, do not open it again.")
            return
        }

        if (PermissionRequester.newInstance(PermissionRequester.FLOAT_PERMISSION).has()) {
            FloatingWindowManager.showFloat(context)
        } else {
            PermissionRequester.newInstance(PermissionRequester.FLOAT_PERMISSION).request()
        }
    }

    fun stopFloatWindow() {
        CallUILog.i(TAG, "stopFloatWindow")
        if (FloatingWindowManager.isFloating()) {
            FloatingWindowManager.releaseFloat()
        }
    }

    fun hasPermission(context: Context, callType: Int?, callback: NECallback<Void>?) {
        CallUILog.i(TAG, "hasPermission")
        if (callType == null) {
            callback?.onError(CallErrorCode.COMMON_ERROR, "callType is null")
            return
        }

        PermissionRequest.requestPermissions(
            context,
            callType,
            object : PermissionCallback() {
                override fun onGranted() {
                    callback?.onSuccess(null)
                }

                override fun onDenied() {
                    callback?.onError(-1, "Permission denied")
                }
            }
        )
    }

    companion object {
        private const val TAG = "CallManager"
        val instance: CallManager = CallManager()
    }
}
