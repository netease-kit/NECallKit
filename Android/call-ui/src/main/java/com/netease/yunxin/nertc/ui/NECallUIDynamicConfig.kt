/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui

import androidx.annotation.DrawableRes

class NECallUIIncomingBackgroundSource private constructor(
    val type: Type,
    @DrawableRes val resId: Int?,
    val url: String?
) {
    enum class Type {
        RESOURCE,
        URL
    }

    class Builder {
        private var type: Type? = null
        private var resId: Int? = null
        private var url: String? = null

        fun resource(@DrawableRes resId: Int) = apply {
            this.type = Type.RESOURCE
            this.resId = resId
            this.url = null
        }

        fun url(url: String) = apply {
            this.type = Type.URL
            this.url = url
            this.resId = null
        }

        fun build(): NECallUIIncomingBackgroundSource {
            val sourceType = type ?: throw IllegalArgumentException("Incoming background source type is required.")
            return NECallUIIncomingBackgroundSource(sourceType, resId, url)
        }
    }
}

class NECallUIDynamicConfig private constructor(
    val incomingCallBackground: NECallUIIncomingBackgroundSource?
) {
    class Builder {
        private var incomingCallBackground: NECallUIIncomingBackgroundSource? = null

        fun incomingCallBackground(source: NECallUIIncomingBackgroundSource?) = apply {
            this.incomingCallBackground = source
        }

        fun build(): NECallUIDynamicConfig {
            return NECallUIDynamicConfig(incomingCallBackground)
        }
    }
}
