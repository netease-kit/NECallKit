// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.call;

import com.netease.yunxin.kit.call.group.NEGroupConstants;
import com.netease.yunxin.kit.call.group.param.GroupCallParam;

final class GroupCallParamFactory {

  private GroupCallParamFactory() {}

  static GroupCallParam create(
      String[] callees, String callId, String groupId, String extraInfo) {
    GroupCallParam.Builder builder =
        new GroupCallParam.Builder().callees(callees).extraInfo(GroupCallExtraInfo.optional(extraInfo));
    if (!isEmpty(callId)) {
      builder.callId(callId);
    }
    if (!isEmpty(groupId)) {
      builder.groupInfo(groupId, NEGroupConstants.GroupType.NORMAL_TEAM);
    }
    return builder.build();
  }

  private static boolean isEmpty(String value) {
    return value == null || value.isEmpty();
  }
}
