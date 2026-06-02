/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.singletogroup

internal object SingleToGroupMediaPolicy {
    fun shouldShowVideoControls(): Boolean = true

    fun shouldShowVirtualBlurControl(enableVirtualBlur: Boolean): Boolean = enableVirtualBlur

    fun shouldMuteLocalVideoOnEnterMode(
        originalOneToOneVideoCall: Boolean,
        localVideoMuted: Boolean
    ): Boolean = !originalOneToOneVideoCall || localVideoMuted

    fun isMemberVideoOpen(
        joined: Boolean,
        videoAvailable: Boolean,
        hasCachedVideoMuted: Boolean,
        muted: Boolean
    ): Boolean = joined && (videoAvailable || hasCachedVideoMuted) && !muted
}
