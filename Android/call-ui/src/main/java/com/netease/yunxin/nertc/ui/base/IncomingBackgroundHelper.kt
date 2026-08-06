/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.base

import android.widget.ImageView
import com.bumptech.glide.Glide
import com.bumptech.glide.load.DataSource
import com.bumptech.glide.load.engine.GlideException
import com.bumptech.glide.request.RequestListener
import com.bumptech.glide.request.target.Target
import com.netease.yunxin.nertc.ui.NECallUIIncomingBackgroundSource
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.utils.CallUILog

private const val TAG = "IncomingBackgroundHelper"

fun ImageView.applyIncomingBackground(
    source: NECallUIIncomingBackgroundSource?
) {
    when (source?.type) {
        NECallUIIncomingBackgroundSource.Type.RESOURCE -> {
            val resId = source.resId?.takeIf { it != 0 } ?: return
            runCatching {
                setTag(R.id.tag_incoming_dynamic_background, true)
                scaleType = ImageView.ScaleType.CENTER_CROP
                setImageResource(resId)
            }.onFailure {
                CallUILog.e(TAG, "Apply incoming background resource failed.", it)
            }
        }
        NECallUIIncomingBackgroundSource.Type.URL -> {
            val url = source.url?.takeIf { it.startsWith("http://") || it.startsWith("https://") }
                ?: return
            val placeholder = drawable
            setTag(R.id.tag_incoming_dynamic_background, true)
            scaleType = ImageView.ScaleType.CENTER_CROP
            Glide.with(this)
                .load(url)
                .placeholder(placeholder)
                .error(placeholder)
                .listener(object : RequestListener<android.graphics.drawable.Drawable> {
                    override fun onLoadFailed(
                        e: GlideException?,
                        model: Any?,
                        target: Target<android.graphics.drawable.Drawable>?,
                        isFirstResource: Boolean
                    ): Boolean {
                        CallUILog.e(TAG, "Load incoming background url failed.", e)
                        return false
                    }

                    override fun onResourceReady(
                        resource: android.graphics.drawable.Drawable?,
                        model: Any?,
                        target: Target<android.graphics.drawable.Drawable>?,
                        dataSource: DataSource?,
                        isFirstResource: Boolean
                    ): Boolean = false
                })
                .into(this)
        }
        null -> {
            setTag(R.id.tag_incoming_dynamic_background, false)
        }
    }
}

fun ImageView.hasIncomingDynamicBackground(): Boolean {
    return getTag(R.id.tag_incoming_dynamic_background) == true
}
