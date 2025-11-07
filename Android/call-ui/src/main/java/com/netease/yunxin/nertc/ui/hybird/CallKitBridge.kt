/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.hybird

import android.content.Context
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.SDKOptions
import com.netease.nimlib.sdk.v2.auth.V2NIMLoginService
import com.netease.yunxin.kit.call.p2p.NECallEngine
import com.netease.yunxin.kit.call.p2p.model.NECallInfo
import com.netease.yunxin.kit.call.p2p.model.NESetupConfig
import com.netease.yunxin.kit.call.p2p.param.NECallParam
import com.netease.yunxin.kit.call.p2p.param.NEHangupParam
import com.netease.yunxin.kit.common.utils.ThreadUtils.runOnUiThread
import com.netease.yunxin.nertc.ui.callback.NECallback
import com.netease.yunxin.nertc.ui.utils.CallUILog

class CallKitBridge {

    companion object {
        private const val TAG = "CallBridge"
        val instance: CallKitBridge = CallKitBridge()
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
            NECallEngine.sharedInstance().call(params) { result ->
                if (result?.code == 0) {
                    callback?.onSuccess(result.data)
                } else {
                    callback?.onError(result?.code ?: -1, result?.msg)
                }
            }
        }
    }

    fun accept(callback: NECallback<NECallInfo>?) {
        CallUILog.i(TAG, "accept")
        runOnUiThread {
            NECallEngine.sharedInstance().accept { result ->
                if (result?.code == 0) {
                    callback?.onSuccess(result.data)
                } else {
                    callback?.onError(result?.code ?: -1, result?.msg)
                }
            }
        }
    }

    fun hangup(param: NEHangupParam, callback: NECallback<Void>?) {
        CallUILog.i(TAG, "hangup param = $param")
        runOnUiThread {
            NECallEngine.sharedInstance().hangup(param) { result ->
                if (result?.code == 0) {
                    callback?.onSuccess(result.data)
                } else {
                    callback?.onError(result?.code ?: -1, result?.msg)
                }
            }
        }
    }
}
