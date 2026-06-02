/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.singletogroup

internal object SingleToGroupCountdownPolicy {

    fun shouldStartLocalTimer(sharedTimerReady: Boolean): Boolean = !sharedTimerReady

    fun initialSeconds(sharedTimerSeconds: Long?): Long = sharedTimerSeconds ?: 0L
}
