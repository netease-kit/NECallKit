// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall;

import com.netease.yunxin.kit.integrationtest.base.AbsHandleIntegratedEvent;
import com.netease.yunxin.kit.integrationtest.model.TestItem;
import com.netease.yunxin.kit.integrationtest.register.ManualParser;
import java.util.ArrayList;
import java.util.List;

public class CallKitTestParser implements ManualParser {
  @Override
  public List<AbsHandleIntegratedEvent<TestItem>> getHandleIntegratedEventList() {
    // 点对点呼叫 触发登录
    // 执行登录
    //-------
    // 点击 点对点呼叫 触发登录——2
    // 执行登录 ——2
    //-------
    // 搜索
    // 呼叫目标
    //---------
    // 等待 5s——2
    // 接听——2
    //----------
    // 等待 15s
    // 挂断
    // 退出当前页面
    // 登出
    // 等待 15s——2
    // 退出当前页面——2
    // 登出——2
    return handleCase(1);
  }

  private List<AbsHandleIntegratedEvent<TestItem>> handleCase(int caseCount) {
    List<AbsHandleIntegratedEvent<TestItem>> list = new ArrayList<>(caseCount);
    for (int i = 0; i < caseCount; i++) {
      list.add(new CallKitBaseCase());
    }
    return list;
  }
}
