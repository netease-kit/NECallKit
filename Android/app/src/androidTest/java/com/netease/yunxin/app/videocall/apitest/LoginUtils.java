// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.apitest;

import android.os.Handler;
import android.os.Looper;
import com.netease.nimlib.sdk.auth.LoginInfo;
import com.netease.yunxin.app.videocall.login.LoginManager;
import com.netease.yunxin.nertc.ui.callback.NECallback;

public final class LoginUtils {
  private static final Handler mainHandler = new Handler(Looper.getMainLooper());

  public static void login(String accountId, String token, ResultNotify notify) {
    mainHandler.post(() -> loginWithAccountToken(accountId, token, notify));
  }

  private static void loginWithAccountToken(String accountId, String token, ResultNotify notify) {

    LoginManager.getInstance()
        .login(
            new LoginInfo(accountId, token),
            new NECallback<Void>() {

              @Override
              public void onSuccess(Void result) {
                notify.notifyResult(200);
              }

              @Override
              public void onError(int code, String errorMsg) {
                notify.notifyResult(code);
              }
            });
  }

  public static void logout(ResultNotify notify) {
    mainHandler.post(() -> logoutAndIM(notify));
  }

  private static void logoutAndIM(ResultNotify notify) {
    LoginManager.getInstance().logout();
    notify.notifyResult(200);
  }
}
