// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import com.netease.yunxin.app.videocall.login.LoginManager;
import com.netease.yunxin.app.videocall.login.ui.LoginActivity;
import com.netease.yunxin.app.videocall.user.UserModel;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.nertc.ui.callback.NECallback;

public class SplashActivity extends AppCompatActivity {

  private static final String TAG = "SplashActivity";

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    if (!isTaskRoot()) {
      finish();
      return;
    }
    checkAutoLogin();
  }

  @Override
  protected void onNewIntent(Intent intent) {
    super.onNewIntent(intent);
    ALog.d(TAG, "onNewIntent: intent -> " + intent.getData());
    setIntent(intent);
    navigationMain();
  }

  private void checkAutoLogin() {
    UserModel savedUserModel = LoginManager.getInstance().getUserModel();

    // 检查是否有保存的登录信息
    if (savedUserModel != null
        && !TextUtils.isEmpty(savedUserModel.getAccount())
        && !TextUtils.isEmpty(savedUserModel.getToken())) {
      ALog.i(TAG, "Found saved credentials, attempting auto login");

      // 执行自动登录
      LoginManager.getInstance()
          .autoLogin(
              new NECallback<Void>() {
                @Override
                public void onSuccess(Void unused) {
                  ALog.i(TAG, "Auto login successful, navigating to MainActivity");
                  navigationMain();
                }

                @Override
                public void onError(int code, String errorMsg) {
                  ALog.e(TAG, "Auto login failed: code=" + code + ", msg=" + errorMsg);
                  // 自动登录失败，跳转到登录页
                  navigationMain();
                }
              });
    } else {
      ALog.i(TAG, "No saved credentials found, navigating to LoginActivity");
      // 没有保存的登录信息，直接跳转
      navigationMain();
    }
  }

  private void navigationMain() {
    if (LoginManager.getInstance().isLogin()) {
      Intent intent = new Intent(this, MainActivity.class);
      startActivity(intent);
    } else {
      Intent intent = new Intent(this, LoginActivity.class);
      startActivity(intent);
    }
    finish();
  }
}
