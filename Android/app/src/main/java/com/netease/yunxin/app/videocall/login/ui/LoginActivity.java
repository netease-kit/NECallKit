// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.login.ui;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import com.netease.nimlib.sdk.auth.LoginInfo;
import com.netease.yunxin.app.videocall.MainActivity;
import com.netease.yunxin.app.videocall.R;
import com.netease.yunxin.app.videocall.login.LoginManager;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.nertc.nertcvideocall.utils.NetworkUtils;
import com.netease.yunxin.nertc.ui.callback.NECallback;

public class LoginActivity extends AppCompatActivity {
  private EditText mEdtAccountId;
  private EditText mEdtToken;
  private Button mBtnLogin;
  private TextView mTvHelpLink;

  public static void startLogin(Context context) {
    Intent intent = new Intent();
    intent.setClass(context, LoginActivity.class);
    context.startActivity(intent);
  }

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.login_activity);
    initView();
  }

  private void initView() {
    mEdtAccountId = findViewById(R.id.edt_account_id);
    mEdtToken = findViewById(R.id.edt_token);
    mBtnLogin = findViewById(R.id.btn_login);
    mTvHelpLink = findViewById(R.id.tv_help_link);

    mBtnLogin.setOnClickListener(v -> login());
    mTvHelpLink.setOnClickListener(v -> openHelpLink());
  }

  private void openHelpLink() {
    String url =
        "https://doc.yunxin.163.com/messaging2/guide/jU0Mzg0MTU?platform=client#%E7%AC%AC%E4%BA%8C%E6%AD%A5%E6%B3%A8%E5%86%8C-im-%E8%B4%A6%E5%8F%B7";
    Intent intent = new Intent(Intent.ACTION_VIEW);
    intent.setData(Uri.parse(url));
    startActivity(intent);
  }

  private void login() {
    String accountId = mEdtAccountId.getText().toString().trim();
    String token = mEdtToken.getText().toString().trim();

    if (TextUtils.isEmpty(accountId)) {
      Toast.makeText(LoginActivity.this, R.string.login_account_id_cant_null, Toast.LENGTH_SHORT)
          .show();
      return;
    }

    if (TextUtils.isEmpty(token)) {
      Toast.makeText(LoginActivity.this, R.string.login_token_cant_null, Toast.LENGTH_SHORT).show();
      return;
    }

    if (!NetworkUtils.isConnected()) {
      Toast.makeText(
              LoginActivity.this,
              R.string.network_connect_error_please_try_again,
              Toast.LENGTH_SHORT)
          .show();
      return;
    }

    LoginManager.getInstance()
        .login(
            new LoginInfo(accountId, token),
            new NECallback<Void>() {

              @Override
              public void onSuccess(Void result) {
                Toast.makeText(LoginActivity.this, R.string.login_success, Toast.LENGTH_SHORT)
                    .show();
                startActivity(new Intent(LoginActivity.this, MainActivity.class));
                finish();
              }

              @Override
              public void onError(int code, String errorMsg) {
                ALog.e("LoginActivity", "login failed: " + code + ", msg: " + errorMsg);
                Toast.makeText(LoginActivity.this, errorMsg, Toast.LENGTH_SHORT).show();
              }
            });
  }
}
