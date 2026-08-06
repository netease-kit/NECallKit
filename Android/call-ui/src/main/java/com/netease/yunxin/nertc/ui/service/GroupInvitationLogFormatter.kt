package com.netease.yunxin.nertc.ui.service

import com.netease.yunxin.kit.call.group.NEGroupCallInfo

internal object GroupInvitationLogFormatter {

    fun format(info: NEGroupCallInfo): String =
        "CallKitUI onReceiveGroupInvitation callId=${info.callId}, " +
            "groupId=${info.groupId}, extraInfo=${info.extraInfo}"
}
