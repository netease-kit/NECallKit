/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.singletogroup

import android.content.Context
import android.view.ViewGroup
import com.netease.yunxin.nertc.ui.utils.CallUILog
import com.netease.yunxin.nertc.ui.view.GroupCallGridLayout

class SingleToGroupMemberGridAdapter(private val context: Context) {
    companion object {
        const val TAG = "SingleToGroupMemberGridAdapter"
    }

    private val userList = mutableListOf<SingleToGroupMemberInfo>()
    private val videoViewPool = SingleToGroupVideoViewPool()
    private val itemViews = mutableListOf<SingleToGroupMemberItemView>()
    private var gridLayout: GroupCallGridLayout? = null
    private var isLayoutAnimating = false

    init {
        videoViewPool.init(context)
    }

    fun setGridLayout(gridLayout: GroupCallGridLayout) {
        this.gridLayout = gridLayout
    }

    fun setLayoutAnimating(animating: Boolean) {
        isLayoutAnimating = animating
        itemViews.forEach { itemView ->
            itemView.setLayoutAnimating(animating)
        }
    }

    fun setData(itemList: List<SingleToGroupMemberInfo>) {
        CallUILog.i(TAG, "setData newData is $itemList")
        if (itemViews.size != userList.size) {
            clearViews()
            userList.clear()
        }

        val newItems = itemList.distinctBy { it.accId }
        if (newItems.isEmpty()) {
            clearViews()
            userList.clear()
            gridLayout?.requestLayout()
            return
        }

        val newItemMap = newItems.associateBy { it.accId }
        for (index in userList.indices.reversed()) {
            if (!newItemMap.containsKey(userList[index].accId)) {
                removeItemView(index)
            }
        }

        for (index in userList.indices) {
            val newItem = newItemMap[userList[index].accId] ?: continue
            userList[index] = newItem
            itemViews[index].refreshData(newItem, videoViewPool)
        }

        newItems.forEach { data ->
            if (findPosition(data.accId) < 0) {
                userList.add(data)
                addItemView(data)
            }
        }

        gridLayout?.run {
            if (getLargeViewIndex() >= childCount) {
                resetLargeView(false)
            } else {
                requestLayout()
            }
        }
    }

    fun updateState(accId: String?, enableVideo: Boolean? = null, enableAudio: Boolean? = null) {
        if (accId == null) {
            return
        }
        val index = findPosition(accId)
        if (index < 0) {
            return
        }
        val item = userList[index]
        enableVideo?.let { item.enableVideo = it }
        enableAudio?.let { item.enableAudio = it }
        if (index < itemViews.size) {
            itemViews[index].refreshData(item, videoViewPool)
        }
    }

    fun release() {
        clearViews()
        videoViewPool.release()
    }

    private fun clearViews() {
        itemViews.forEach { view ->
            view.release(videoViewPool)
            gridLayout?.removeView(view)
        }
        itemViews.clear()
    }

    private fun addItemView(data: SingleToGroupMemberInfo) {
        val itemView = SingleToGroupMemberItemView(context)
        itemView.layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        itemView.setLayoutAnimating(isLayoutAnimating)
        itemView.refreshData(data, videoViewPool)
        itemViews.add(itemView)
        gridLayout?.addView(itemView)
    }

    private fun removeItemView(index: Int) {
        val itemView = itemViews.removeAt(index)
        itemView.release(videoViewPool)
        gridLayout?.removeView(itemView)
        userList.removeAt(index)
    }

    private fun findPosition(accId: String): Int {
        for (index in userList.indices) {
            if (userList[index].accId == accId) {
                return index
            }
        }
        return -1
    }
}
