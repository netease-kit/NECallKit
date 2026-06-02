/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.singletogroup

import android.text.TextUtils
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.RequestCallbackWrapper
import com.netease.nimlib.sdk.uinfo.UserService
import com.netease.nimlib.sdk.uinfo.model.NimUserInfo
import com.netease.yunxin.kit.call.NEResultObserver

internal class SingleToGroupUserInfoFetcher {
    private val userService = NIMClient.getService(UserService::class.java)
    private val localCache: MutableMap<String, SingleToGroupMemberInfo> = HashMap()

    fun getUserInfoList(
        accIdList: List<String>?,
        observer: NEResultObserver<List<SingleToGroupMemberInfo>>?
    ) {
        if (observer == null) {
            return
        }
        if (accIdList == null || accIdList.isEmpty()) {
            observer.onResult(emptyList())
            return
        }
        val resultList: MutableList<SingleToGroupMemberInfo> = ArrayList()
        val tempAccIdList: MutableList<String> = ArrayList(accIdList)
        val iterator = tempAccIdList.iterator()
        while (iterator.hasNext()) {
            val accId = iterator.next()
            var userInfo = localCache[accId]
            if (userInfo != null) {
                resultList.add(userInfo)
                iterator.remove()
                continue
            }
            userInfo = userService.getUserInfo(accId)?.toSingleToGroupMemberInfo()
            if (userInfo != null) {
                localCache[accId] = userInfo
                resultList.add(userInfo)
                iterator.remove()
            }
        }
        if (tempAccIdList.isEmpty()) {
            observer.onResult(resultList)
            return
        }
        userService.fetchUserInfo(tempAccIdList)
            .setCallback(object : RequestCallbackWrapper<List<NimUserInfo?>?>() {
                override fun onResult(
                    code: Int,
                    result: List<NimUserInfo?>?,
                    exception: Throwable?
                ) {
                    if (result != null && result.isNotEmpty()) {
                        val resultFromServer = mutableListOf<SingleToGroupMemberInfo>()
                        for (item in result) {
                            if (item == null) {
                                continue
                            }
                            item.toSingleToGroupMemberInfo().run {
                                localCache[item.account] = this
                                resultFromServer.add(this)
                            }
                        }
                        resultList.addAll(resultFromServer)
                    }

                    val missingAccIds = tempAccIdList.filter { accId ->
                        result?.find { it?.account == accId } == null
                    }
                    for (accId in missingAccIds) {
                        val defaultInfo = SingleToGroupMemberInfo(accId, accId, null)
                        localCache[accId] = defaultInfo
                        resultList.add(defaultInfo)
                    }

                    observer.onResult(resultList)
                }
            })
    }

    private fun NimUserInfo.toSingleToGroupMemberInfo(): SingleToGroupMemberInfo {
        val displayName = if (TextUtils.isEmpty(name)) account else name
        return SingleToGroupMemberInfo(account, displayName, avatar)
    }
}
