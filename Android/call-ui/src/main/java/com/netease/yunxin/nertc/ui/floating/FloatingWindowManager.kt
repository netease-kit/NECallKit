/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.floating

import android.app.Activity
import android.content.Context
import android.view.View
import com.netease.yunxin.nertc.ui.p2p.CallUIFloatingWindowMgr
import com.netease.yunxin.nertc.ui.utils.CallUILog
import com.netease.yunxin.nertc.ui.view.OverLayPermissionDialog

class FloatingWindowManager {
    private var overLayPermissionDialog: OverLayPermissionDialog? = null

    companion object {
        private const val TAG = "FloatingWindowManager"
        val instance: FloatingWindowManager = FloatingWindowManager()
    }

    fun startFloatWindow(context: Context) {
        if (!FloatingPermission.isFloatPermissionValid(context)) {
            if (overLayPermissionDialog?.isShowing != true) {
                showOverlayPermissionDialog(context) {
                    FloatingPermission.requireFloatPermission(context)
                }
            }
            return
        }

        if (!FloatingPermission.isBackgroundStartAllowed(context)) {
            if (overLayPermissionDialog?.isShowing != true) {
                showOverlayPermissionDialog(context) {
                    FloatingPermission.startToPermissionSetting(context)
                }
            }
            return
        }

        if (!CallUIFloatingWindowMgr.isFloating()) {
            CallUIFloatingWindowMgr.showFloat(context)
        }
    }

    fun stopFloatWindow() {
        if (CallUIFloatingWindowMgr.isFloating()) {
            CallUIFloatingWindowMgr.releaseFloat()
        }
    }

    fun showOverlayPermissionDialog(context: Context, clickListener: View.OnClickListener): OverLayPermissionDialog {
        CallUILog.i(TAG, "show")
        return OverLayPermissionDialog(context as Activity, clickListener).apply {
            overLayPermissionDialog = this
            show()
        }
    }
}
