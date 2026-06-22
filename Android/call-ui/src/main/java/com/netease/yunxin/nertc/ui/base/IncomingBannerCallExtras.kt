/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.base

internal const val KEY_AUTO_ACCEPT_FROM_INCOMING_BANNER = "callkit_auto_accept_from_incoming_banner"

internal fun CallParam.markAutoAcceptFromIncomingBanner() {
    if (extras == null) {
        extras = mutableMapOf()
    }
    extras?.set(KEY_AUTO_ACCEPT_FROM_INCOMING_BANNER, true)
}

internal fun CallParam.consumeAutoAcceptFromIncomingBanner(): Boolean {
    val shouldAutoAccept = extras?.get(KEY_AUTO_ACCEPT_FROM_INCOMING_BANNER) == true
    if (shouldAutoAccept) {
        extras?.remove(KEY_AUTO_ACCEPT_FROM_INCOMING_BANNER)
    }
    return shouldAutoAccept
}
