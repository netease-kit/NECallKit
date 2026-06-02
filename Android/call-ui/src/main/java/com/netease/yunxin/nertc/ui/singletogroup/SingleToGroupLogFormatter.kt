/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.singletogroup

import com.netease.yunxin.kit.call.p2p.model.NECallMemberChangeInfo
import com.netease.yunxin.kit.call.p2p.model.NECallMemberChangeType
import com.netease.yunxin.kit.call.p2p.model.NECallMemberInfo
import com.netease.yunxin.kit.call.p2p.model.NECallMemberState

internal object SingleToGroupLogFormatter {

    fun memberChangeSummary(
        info: NECallMemberChangeInfo,
        members: List<NECallMemberInfo> = info.members.orEmpty()
    ): String {
        val joined = members.count { it.state == NECallMemberState.JOINED }
        val waiting = members.count { it.state == NECallMemberState.WAITING }
        val leaving = members.count { it.state == NECallMemberState.LEAVING }
        val changed = info.changedMember?.let { memberCompact(it) } ?: "none"
        val invalid = invalidMembers(members)
        val invalidPart = if (invalid.isEmpty()) "" else " invalid=$invalid"
        return "callId:${info.callId} channelId:${info.channelId} " +
            "changeType:${changeTypeName(info.changeType)} " +
            "changed:$changed count=${members.size} joined=$joined waiting=$waiting leaving=$leaving" +
            invalidPart
    }

    fun memberSnapshotSummary(members: List<NECallMemberInfo>): String {
        val joined = members.count { it.state == NECallMemberState.JOINED }
        val waiting = members.count { it.state == NECallMemberState.WAITING }
        val leaving = members.count { it.state == NECallMemberState.LEAVING }
        val compactMembers = members.joinToString(prefix = "[", postfix = "]") { memberCompact(it) }
        val invalid = invalidMembers(members)
        val invalidPart = if (invalid.isEmpty()) "" else " invalid=$invalid"
        return "count=${members.size} joined=$joined waiting=$waiting leaving=$leaving " +
            "members=$compactMembers$invalidPart"
    }

    fun memberDiff(
        oldMembers: List<NECallMemberInfo>,
        newMembers: List<NECallMemberInfo>
    ): String {
        val oldMap = oldMembers.associateBy { it.userID }
        val newMap = newMembers.associateBy { it.userID }
        val userIds = linkedSetOf<String>().apply {
            addAll(oldMap.keys)
            addAll(newMap.keys)
        }
        return userIds.mapNotNull { userId ->
            val oldMember = oldMap[userId]
            val newMember = newMap[userId]
            when {
                oldMember == null && newMember != null -> "$userId{added:${memberCompact(newMember)}}"
                oldMember != null && newMember == null -> "$userId{removed:${memberCompact(oldMember)}}"
                oldMember != null && newMember != null -> changedFields(oldMember, newMember)
                    .takeIf { it.isNotEmpty() }
                    ?.let { "$userId{${it.joinToString(",")}}" }
                else -> null
            }
        }.joinToString(";")
    }

    private fun changedFields(oldMember: NECallMemberInfo, newMember: NECallMemberInfo): List<String> {
        val changes = mutableListOf<String>()
        appendChange(changes, "uid", oldMember.uid, newMember.uid)
        appendChange(changes, "state", oldMember.state, newMember.state)
        appendChange(changes, "joinedAt", oldMember.joinedAt, newMember.joinedAt)
        appendChange(changes, "leftAt", oldMember.leftAt, newMember.leftAt)
        appendChange(changes, "audioMuted", oldMember.audioMuted, newMember.audioMuted)
        appendChange(changes, "videoMuted", oldMember.videoMuted, newMember.videoMuted)
        appendChange(changes, "videoAvailable", oldMember.videoAvailable, newMember.videoAvailable)
        return changes
    }

    private fun appendChange(changes: MutableList<String>, name: String, oldValue: Any, newValue: Any) {
        if (oldValue != newValue) {
            changes.add("$name:$oldValue->$newValue")
        }
    }

    private fun memberCompact(member: NECallMemberInfo): String {
        return "${member.userID}:state=${member.state}:uid=${member.uid}"
    }

    private fun changeTypeName(changeType: Int): String {
        return when (changeType) {
            NECallMemberChangeType.JOIN -> "JOIN"
            NECallMemberChangeType.LEAVE -> "LEAVE"
            NECallMemberChangeType.STATE_CHANGE -> "STATE_CHANGE"
            NECallMemberChangeType.MEDIA_CHANGE -> "MEDIA_CHANGE"
            else -> changeType.toString()
        }
    }

    private fun invalidMembers(members: List<NECallMemberInfo>): List<String> {
        return members.mapNotNull { member ->
            when {
                member.userID.isBlank() -> "empty_user"
                member.state == NECallMemberState.JOINED && member.uid == 0L ->
                    "${member.userID}:joined_zero_uid"
                member.state == NECallMemberState.JOINED && member.joinedAt == 0L ->
                    "${member.userID}:joined_zero_joinedAt"
                else -> null
            }
        }
    }
}
