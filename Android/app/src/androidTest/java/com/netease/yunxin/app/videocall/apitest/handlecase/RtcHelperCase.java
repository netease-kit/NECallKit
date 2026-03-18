// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.apitest.handlecase;

import android.text.TextUtils;
import com.netease.yunxin.app.videocall.apitest.DataFactory;
import com.netease.yunxin.kit.integrationtest.Hawk;
import com.netease.yunxin.kit.integrationtest.base.AbsHandleIntegratedEvent;
import com.netease.yunxin.kit.integrationtest.model.TestItem;
import com.netease.yunxin.nertc.nertcvideocall.model.impl.NERtcCallbackProxyMgr;

public class RtcHelperCase extends AbsHandleIntegratedEvent<TestItem> {
  @Override
  public boolean handle(TestItem testItem) throws Exception {
    super.handle(testItem);
    boolean res = false;
    if (!TextUtils.equals(testItem.getClassName(), "RTC")) {
      return res;
    }
    if (TextUtils.equals(methodName, "onRtcJoinChannel")) {
      DataFactory.getInstance().callbackMap.put("onRtcJoinChannel", testItem.getCaseId());
      res = true;
    } else if (TextUtils.equals(methodName, "add")) {
      NERtcCallbackProxyMgr.getInstance().addCallback(DataFactory.getInstance().callbackExTemp);
      Hawk.getInstance().reportWithCurrentCaseId(0, "success", "");
      res = true;
    } else if (TextUtils.equals(methodName, "remove")) {
      NERtcCallbackProxyMgr.getInstance().removeCallback(DataFactory.getInstance().callbackExTemp);
      Hawk.getInstance().reportWithCurrentCaseId(0, "success", "");
      res = true;
    }
    return res;
  }
}
