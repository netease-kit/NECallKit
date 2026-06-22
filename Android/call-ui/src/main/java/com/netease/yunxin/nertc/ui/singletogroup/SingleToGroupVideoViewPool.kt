/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.singletogroup

import android.content.Context
import android.view.ViewGroup
import android.widget.LinearLayout
import com.netease.lava.api.IVideoRender
import com.netease.lava.nertc.sdk.NERtcEx
import com.netease.lava.nertc.sdk.video.NERtcTextureView
import java.util.LinkedList

class SingleToGroupVideoViewPool {
    companion object {
        const val TAG = "SingleToGroupVideoViewPool"
    }

    private val maxSize = 8
    private val rtcVideoMap = mutableMapOf<Long, NERtcTextureView?>()
    private val queue = LinkedList<NERtcTextureView>()
    private var context: Context? = null

    fun init(context: Context) {
        this.context = context
    }

    fun recycleRtcVideo(rtcUid: Long, forceRecycler: Boolean = false) {
        if (!forceRecycler && maxSize <= rtcVideoMap.size) {
            return
        }
        val videoView = rtcVideoMap[rtcUid]
        removeSelf(videoView)
        rtcVideoMap[rtcUid] = null
    }

    fun obtainRtcVideo(rtcUid: Long, isSelf: Boolean): NERtcTextureView {
        var videoView = rtcVideoMap[rtcUid]
        videoView = pickVideoView(videoView)
        rtcVideoMap[rtcUid] = videoView
        if (isSelf) {
            NERtcEx.getInstance().setupLocalVideoCanvas(videoView)
        } else {
            NERtcEx.getInstance().setupRemoteVideoCanvas(videoView, rtcUid)
        }
        return videoView
    }

    fun release() {
        queue.clear()
        rtcVideoMap.clear()
        context = null
    }

    private fun removeSelf(videoView: NERtcTextureView?) {
        if (videoView != null) {
            if (videoView.parent != null) {
                (videoView.parent as ViewGroup).removeView(videoView)
            }
            queue.add(videoView)
        }
    }

    private fun pickVideoView(videoView: NERtcTextureView?): NERtcTextureView {
        var result = videoView
        if (result == null) {
            result = queue.poll()
        }
        if (result == null) {
            result = NERtcTextureView(context!!).apply {
                layoutParams = ViewGroup.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                setScalingType(IVideoRender.ScalingType.SCALE_ASPECT_FILL)
            }
        }
        if (result.parent != null) {
            (result.parent as ViewGroup).removeView(result)
        }
        return result
    }
}
