// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import com.netease.lava.nertc.foreground.ForegroundKit;
import com.netease.lava.nertc.sdk.NERtc;
import com.netease.lava.nertc.sdk.NERtcEx;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.auth.LoginInfo;
import com.netease.nimlib.sdk.v2.V2NIMError;
import com.netease.nimlib.sdk.v2.auth.V2NIMLoginListener;
import com.netease.nimlib.sdk.v2.auth.V2NIMLoginService;
import com.netease.nimlib.sdk.v2.auth.enums.V2NIMLoginClientChange;
import com.netease.nimlib.sdk.v2.auth.enums.V2NIMLoginStatus;
import com.netease.nimlib.sdk.v2.auth.model.V2NIMKickedOfflineDetail;
import com.netease.nimlib.sdk.v2.auth.model.V2NIMLoginClient;
import com.netease.yunxin.app.videocall.call.CallModeType;
import com.netease.yunxin.app.videocall.call.MultiCallUserActivity;
import com.netease.yunxin.app.videocall.call.SettingActivity;
import com.netease.yunxin.app.videocall.call.SingleCallUserActivity;
import com.netease.yunxin.app.videocall.login.LoginManager;
import com.netease.yunxin.app.videocall.login.ui.LoginActivity;
import com.netease.yunxin.app.videocall.order.CallOrderManager;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.nertc.ui.CallKitUI;
import java.util.Collections;
import java.util.List;

public class MainActivity extends AppCompatActivity {
  private static final String TAG = "MainActivity";
  private static final int NOTIFICATION_PERMISSION_REQUEST_CODE = 1001;
  private TextView tvVersion;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_main);
    checkAndRequestNotificationPermission(this);
    initView();
    checkLogin();
    initData();
    initListeners();
    dumpTest();
  }

  private void initData() {
    CallOrderManager.getInstance().init();
  }

  private void dumpTest() {
    if (BuildConfig.DEBUG) {
      findViewById(R.id.btn)
          .setOnClickListener(
              v -> {
                Toast.makeText(MainActivity.this, R.string.start_dump_audio, Toast.LENGTH_LONG)
                    .show();
                NERtcEx.getInstance().startAudioDump();
              });
      findViewById(R.id.btn2)
          .setOnClickListener(
              v -> {
                Toast.makeText(MainActivity.this, R.string.dump_finished, Toast.LENGTH_LONG).show();
                NERtcEx.getInstance().stopAudioDump();
              });
    } else {
      findViewById(R.id.btn).setVisibility(View.GONE);
      findViewById(R.id.btn2).setVisibility(View.GONE);
    }
  }

  @Override
  protected void onResume() {
    super.onResume();
  }

  @Override
  protected void onDestroy() {
    super.onDestroy();
  }

  private void initListeners() {

    NIMClient.getService(V2NIMLoginService.class)
        .addLoginListener(
            new V2NIMLoginListener() {
              @Override
              public void onLoginStatus(V2NIMLoginStatus status) {
                if (status == V2NIMLoginStatus.V2NIM_LOGIN_STATUS_LOGINED) {
                  if (TextUtils.equals(
                      LoginManager.getInstance().getUserModel().getAccount(),
                      NIMClient.getCurrentAccount())) {
                    return;
                  }
                  ALog.e(TAG, "init " + LoginManager.getInstance().getUserModel().getAccount());
                  SettingActivity.toInit();
                }
              }

              @Override
              public void onLoginFailed(V2NIMError error) {}

              @Override
              public void onKickedOffline(V2NIMKickedOfflineDetail detail) {}

              @Override
              public void onLoginClientChanged(
                  V2NIMLoginClientChange change, List<V2NIMLoginClient> clients) {}
            });
  }

  private void checkLogin() {
    if (LoginManager.getInstance().isLogin()) {
      return;
    }

    if (LoginManager.getInstance().getUserModel() != null
        && !TextUtils.isEmpty(LoginManager.getInstance().getUserModel().getAccount())
        && !TextUtils.isEmpty(LoginManager.getInstance().getUserModel().getToken())) {

      LoginManager.getInstance()
          .login(
              new LoginInfo(
                  LoginManager.getInstance().getUserModel().getAccount(),
                  LoginManager.getInstance().getUserModel().getToken()),
              null);
    }
  }

  private void initView() {
    ImageView ivAccountIcon = findViewById(R.id.iv_account);
    RelativeLayout rlyVideoCall = findViewById(R.id.rly_video_call);
    RelativeLayout rlyGroupCall = findViewById(R.id.rly_group_call);

    tvVersion = findViewById(R.id.tv_version);

    ivAccountIcon.setOnClickListener(
        view -> {
          if (LoginManager.getInstance().isLogin()) {
            showLogoutDialog();
          } else {
            LoginActivity.startLogin(this);
          }
        });

    rlyVideoCall.setOnClickListener(
        view -> {
          if (!LoginManager.getInstance().isLogin()) {
            LoginActivity.startLogin(this);
          } else {
            SingleCallUserActivity.startActivity(this);
          }
        });

    rlyGroupCall.setOnClickListener(
        v -> {
          if (!LoginManager.getInstance().isLogin()) {
            LoginActivity.startLogin(this);
          } else {
            MultiCallUserActivity.startSelectUser(
                this,
                CallModeType.RTC_GROUP_CALL,
                Collections.singletonList(LoginManager.getInstance().getUserModel().getAccount()));
          }
        });
    rlyGroupCall.setVisibility(View.VISIBLE);

    RelativeLayout rlPermission = findViewById(R.id.rl_goto_permission_setting);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      rlPermission.setVisibility(View.VISIBLE);
    } else {
      rlPermission.setVisibility(View.GONE);
    }
    rlPermission.setOnClickListener(v -> ForegroundKit.getInstance(this).requestFloatPermission());

    initVersionInfo();
  }

  private void initVersionInfo() {
    String versionInfo =
        "NIM sdk version:"
            + NIMClient.getSDKVersion()
            + "\nnertc sdk version:"
            + NERtc.version().versionName
            + "\ncallKit version:"
            + CallKitUI.INSTANCE.currentVersion();
    tvVersion.setText(versionInfo);
  }

  private void showLogoutDialog() {
    final AlertDialog.Builder confirmDialog = new AlertDialog.Builder(MainActivity.this);
    confirmDialog.setTitle(
        String.format(
            getString(R.string.logout_account),
            LoginManager.getInstance().getUserModel().getAccount()));
    confirmDialog.setMessage(R.string.confirm_logout);
    confirmDialog.setPositiveButton(
        R.string.yes,
        (dialog, which) -> {
          LoginManager.getInstance().logout();
          Toast.makeText(MainActivity.this, R.string.logged_out, Toast.LENGTH_LONG).show();
        });
    confirmDialog.setNegativeButton(R.string.no, (dialog, which) -> {});

    confirmDialog.show();
  }

  private void checkAndRequestNotificationPermission(Context context) {
    // 检查是否需要请求通知权限
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      if (ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS)
          != PackageManager.PERMISSION_GRANTED) {
        // 请求权限
        ActivityCompat.requestPermissions(
            this,
            new String[] {Manifest.permission.POST_NOTIFICATIONS},
            NOTIFICATION_PERMISSION_REQUEST_CODE);
      }
    }
  }
}
