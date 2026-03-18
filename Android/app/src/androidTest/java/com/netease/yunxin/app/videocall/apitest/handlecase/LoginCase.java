// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.apitest.handlecase;

import android.text.TextUtils;
import android.util.Log;
import com.netease.yunxin.app.videocall.apitest.LoginUtils;
import com.netease.yunxin.app.videocall.login.LoginManager;
import com.netease.yunxin.kit.integrationtest.Hawk;
import com.netease.yunxin.kit.integrationtest.base.AbsHandleIntegratedEvent;
import com.netease.yunxin.kit.integrationtest.model.TestItem;

public class LoginCase extends AbsHandleIntegratedEvent<TestItem> {
  @Override
  public boolean handle(TestItem testItem) throws Exception {
    super.handle(testItem);
    Log.d("LoginCase =======>", "start：" + methodName);
    boolean res = false;
    if (TextUtils.equals(methodName, "login")) {
      String accountId =
          testItem.getParams().get(0).get("info").getAsJsonObject().get("accountId").getAsString();
      String token =
          testItem.getParams().get(0).get("info").getAsJsonObject().get("token").getAsString();
      LoginUtils.login(
          accountId,
          token,
          code ->
              Hawk.getInstance()
                  .reportWithCurrentCaseId(
                      code, "loginResult", LoginManager.getInstance().getUserModel()));
      res = true;
    } else if (TextUtils.equals(methodName, "logout")) {
      res = true;
      LoginUtils.logout(
          code -> Hawk.getInstance().reportWithCurrentCaseId(code, "logoutResult", code));
    }
    return res;
  }
}
