/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.hybird

import android.content.Context
import com.netease.lava.nertc.sdk.NERtcConstants
import com.netease.lava.nertc.sdk.audio.NERtcAudioAINSMode
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.SDKOptions
import com.netease.nimlib.sdk.v2.auth.V2NIMLoginService
import com.netease.yunxin.kit.call.p2p.NECallEngine
import com.netease.yunxin.kit.call.p2p.model.NECallConfig
import com.netease.yunxin.kit.call.p2p.model.NECallInfo
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.kit.call.p2p.model.NESetupConfig
import com.netease.yunxin.kit.call.p2p.param.NECallParam
import com.netease.yunxin.kit.call.p2p.param.NEHangupParam
import com.netease.yunxin.kit.call.p2p.param.NESwitchParam
import com.netease.yunxin.kit.common.utils.ThreadUtils.runOnUiThread
import com.netease.yunxin.nertc.nertcvideocall.model.CallErrorCode
import com.netease.yunxin.nertc.ui.callback.NECallback
import com.netease.yunxin.nertc.ui.floating.FloatingWindowObserver
import com.netease.yunxin.nertc.ui.manager.CallManager
import com.netease.yunxin.nertc.ui.p2p.CallUIOperationsMgr
import com.netease.yunxin.nertc.ui.service.foregroundservice.AudioForegroundService
import com.netease.yunxin.nertc.ui.service.foregroundservice.VideoForegroundService
import com.netease.yunxin.nertc.ui.utils.CallUILog
import java.util.concurrent.CountDownLatch

class CallKitBridge {
    companion object {
        private const val TAG = "CallBridge"
        val instance: CallKitBridge = CallKitBridge()
        fun getVersion(): String {
            CallUILog.i(TAG, "getVersion")
            var result = ""
            val latch = CountDownLatch(1)
            runOnUiThread {
                result = NECallEngine.getVersion()
                latch.countDown()
            }
            latch.await()
            return result
        }
    }

    fun init(context: Context, appKey: String, frameWork: String, channel: String, currentUserRtcUid: Long) {
        CallUILog.i(
            TAG,
            "init appKey = $appKey, frameWork = $frameWork, channel = $channel, currentUserRtcUid"
        )
        runOnUiThread {
            val options = SDKOptions()
            options.appKey = appKey
            NIMClient.initV2(context, options)
            val config = NESetupConfig.Builder(appKey)
                .channel(channel)
                .framework(frameWork)
                .currentUserRtcUid(currentUserRtcUid)
                .build()
            NECallEngine.sharedInstance().setup(context, config)
            CallUIOperationsMgr.load(context)
        }
    }

    fun login(
        accountId: String, token: String, callback: NECallback<Void>?
    ) {
        CallUILog.i(TAG, "login accountId = $accountId")
        runOnUiThread {
            NIMClient.getService(V2NIMLoginService::class.java)
                .login(
                    accountId,
                    token,
                    null,
                    {
                        CallUILog.i(TAG, "login im success")
                        callback?.onSuccess(null)
                    },
                    { error ->
                        CallUILog.e(
                            TAG,
                            "login im failed code = " + error.code + ", msg = " + error.desc
                        )
                        callback?.onError(error.code, error.desc)
                    }
                )
        }
    }

    fun logout(callback: NECallback<Void>?) {
        CallUILog.i(TAG, "logout")
        runOnUiThread {
            NIMClient.getService(V2NIMLoginService::class.java)
                .logout({
                    CallUILog.i(TAG, "logout im success")
                    callback?.onSuccess(null)
                }, { error ->
                    CallUILog.e(
                        TAG,
                        "logout im failed code = " + error.code + ", msg = " + error.desc
                    )
                    callback?.onError(error.code, error.desc)
                })
        }
    }

    fun call(
        params: NECallParam, callback: NECallback<NECallInfo>?
    ) {
        CallUILog.i(TAG, "call")
        runOnUiThread {
            CallManager.instance.call(params, callback)
        }
    }

    fun accept(callback: NECallback<NECallInfo>?) {
        CallUILog.i(TAG, "accept")
        runOnUiThread {
            CallManager.instance.accept(callback)
        }
    }

    fun hangup(param: NEHangupParam, callback: NECallback<Void>?) {
        CallUILog.i(TAG, "hangup param = $param")
        runOnUiThread {
            CallManager.instance.hangup(param, callback)
        }
    }

    fun muteLocalAudio(mute: Boolean): Int {
        CallUILog.i(TAG, "muteLocalAudio mute = $mute")
        var result: Int = CallErrorCode.COMMON_ERROR
        val latch = CountDownLatch(1)
        runOnUiThread {
            result = CallManager.instance.muteLocalAudio(mute)
            latch.countDown()
        }
        latch.await()
        return result
    }

    fun muteLocalVideo(mute: Boolean): Int {
        CallUILog.i(TAG, "muteLocalVideo mute = $mute")
        var result: Int = CallErrorCode.COMMON_ERROR
        val latch = CountDownLatch(1)
        runOnUiThread {
            result = CallManager.instance.muteLocalVideo(mute)
            latch.countDown()
        }
        latch.await()
        return result
    }

    fun enableLocalVideo(enable: Boolean): Int {
        CallUILog.i(TAG, "enableLocalVideo enable = $enable")
        var result: Int = CallErrorCode.COMMON_ERROR
        val latch = CountDownLatch(1)
        runOnUiThread {
            result = CallManager.instance.enableLocalVideo(enable)
            latch.countDown()
        }
        latch.await()
        return result
    }

    fun setTimeout(millisecond: Long) {
        CallUILog.i(TAG, "setTimeout millisecond = $millisecond")
        runOnUiThread {
            CallManager.instance.setTimeout(millisecond)
        }
    }

    fun switchCallType(param: NESwitchParam, callback: NECallback<Void>?) {
        CallUILog.i(TAG, "switchCallType param = $param")
        runOnUiThread {
            CallManager.instance.switchCallType(param, callback)
        }
    }

    fun switchCamera(position: Int? = 0) {
        CallUILog.i(TAG, "switchCamera position = $position")
        runOnUiThread {
            val finalPosition: Int = if (position == 0) {
                NERtcConstants.CameraPosition.CAMERA_POSITION_FRONT
            } else {
                NERtcConstants.CameraPosition.CAMERA_POSITION_BACK
            }
            CallManager.instance.switchCamera(finalPosition)
        }
    }

    fun setSpeakerphoneOn(enable: Boolean): Int {
        CallUILog.i(TAG, "setSpeakerphoneOn enable = $enable")
        var result = CallErrorCode.COMMON_ERROR
        val latch = CountDownLatch(1)
        runOnUiThread {
            result = CallManager.instance.setSpeakerphoneOn(enable)
            latch.countDown()
        }
        latch.await()
        return result
    }

    fun isSpeakerphoneOn(): Boolean {
        CallUILog.i(TAG, "isSpeakerphoneOn")
        var result = false
        val latch = CountDownLatch(1)
        runOnUiThread {
            result = CallManager.instance.isSpeakerphoneOn()
            latch.countDown()
        }
        latch.await()
        return result
    }

    fun setCallConfig(config: NECallConfig) {
        CallUILog.i(TAG, "setCallConfig config = $config")
        runOnUiThread {
            CallManager.instance.setCallConfig(config)
        }
    }

    fun getCallConfig(): NECallConfig? {
        CallUILog.i(TAG, "getCallConfig")
        var result: NECallConfig? = null
        val latch = CountDownLatch(1)
        runOnUiThread {
            result = CallManager.instance.getCallConfig()
            latch.countDown()
        }
        latch.await()
        return result
    }

    fun getCallInfo(): NECallInfo? {
        CallUILog.i(TAG, "getCallInfo")
        var result: NECallInfo? = null
        val latch = CountDownLatch(1)
        runOnUiThread {
            result = CallManager.instance.getCallInfo()
            latch.countDown()
        }
        latch.await()
        return result
    }

    fun setAINSMode(mode: NERtcAudioAINSMode): Int {
        CallUILog.i(TAG, "setAINSMode mode = $mode")
        var result: Int = CallErrorCode.COMMON_ERROR
        val latch = CountDownLatch(1)
        runOnUiThread {
            result = CallManager.instance.setAINSMode(mode)
            latch.countDown()
        }
        latch.await()
        return result
    }

    fun destroy() {
        CallUILog.i(TAG, "destroy")
        runOnUiThread {
            CallManager.instance.destroy()
        }
    }

    fun addFloatWindowObserver(observer: FloatingWindowObserver) {
        CallUILog.i(TAG, "addFloatWindowObserver, observer: $observer")
        runOnUiThread {
            CallManager.instance.addFloatWindowObserver(observer)
        }
    }

    fun removeFloatWindowObserver(observer: FloatingWindowObserver) {
        CallUILog.i(TAG, "removeFloatWindowObserver, observer: $observer")
        runOnUiThread {
            CallManager.instance.removeFloatWindowObserver(observer)
        }
    }

    fun startFloatWindow(context: Context) {
        CallUILog.i(TAG, "startFloatWindow")
        runOnUiThread {
            CallManager.instance.startFloatWindow(context)
        }
    }

    fun stopFloatWindow() {
        CallUILog.i(TAG, "stopFloatWindow")
        runOnUiThread {
            CallManager.instance.stopFloatWindow()
        }
    }

    fun hasPermission(context: Context, callType: Int, callback: NECallback<Void>?) {
        CallUILog.i(TAG, "hasPermission")
        runOnUiThread {
            CallManager.instance.hasPermission(context, callType, callback)
        }
    }

    fun startForegroundService(context: Context, callType: Int, title: String, description: String) {
        if (callType == NECallType.VIDEO) {
            VideoForegroundService.start(context, title, description, 0)
        } else if (callType == NECallType.AUDIO) {
            AudioForegroundService.start(context, title, description, 0)
        }
    }

    fun stopForegroundService(context: Context) {
        VideoForegroundService.stop(context)
        AudioForegroundService.stop(context)
    }
}
