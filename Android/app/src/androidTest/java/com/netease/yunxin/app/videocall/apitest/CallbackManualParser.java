// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.apitest;

import com.netease.yunxin.app.videocall.apitest.handlecase.HandleCallbackCase;
import com.netease.yunxin.app.videocall.apitest.handlecase.LoginCase;
import com.netease.yunxin.app.videocall.apitest.handlecase.NewInterfaceV2Case;
import com.netease.yunxin.app.videocall.apitest.handlecase.RtcHelperCase;
import com.netease.yunxin.kit.integrationtest.base.AbsHandleIntegratedEvent;
import com.netease.yunxin.kit.integrationtest.model.TestItem;
import com.netease.yunxin.kit.integrationtest.register.ManualParser;
import java.util.ArrayList;
import java.util.List;

public class CallbackManualParser implements ManualParser {
  @Override
  public List<AbsHandleIntegratedEvent<TestItem>> getHandleIntegratedEventList() {
    List<AbsHandleIntegratedEvent<TestItem>> list = new ArrayList<>();
    list.add(new HandleCallbackCase());
    list.add(new LoginCase());
    list.add(new NewInterfaceV2Case());
    list.add(new RtcHelperCase());
    return list;
  }
}
