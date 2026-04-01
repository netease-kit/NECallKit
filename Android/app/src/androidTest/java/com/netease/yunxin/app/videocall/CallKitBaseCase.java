// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall;

import android.text.TextUtils;
import android.util.Log;
import com.netease.yunxin.app.videocall.base.TestHelper;
import com.netease.yunxin.kit.integrationtest.base.AbsHandleIntegratedEvent;
import com.netease.yunxin.kit.integrationtest.model.TestItem;

public class CallKitBaseCase extends AbsHandleIntegratedEvent<TestItem> {
  @Override
  public boolean handle(TestItem testItem) throws Exception {
    super.handle(testItem);
    if (TextUtils.isEmpty(methodName)) {
      return false;
    }
    Log.e("!!!!!!!", methodName);
    return TestHelper.handleMethod(this, testItem);
  }
}
