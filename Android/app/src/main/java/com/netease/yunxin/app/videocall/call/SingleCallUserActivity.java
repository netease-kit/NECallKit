// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.call;

import android.app.Activity;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.RadioButton;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.netease.nimlib.sdk.auth.LoginInfo;
import com.netease.yunxin.app.videocall.R;
import com.netease.yunxin.app.videocall.call.adapter.CallOrderAdapter;
import com.netease.yunxin.app.videocall.call.adapter.RecentUserAdapter;
import com.netease.yunxin.app.videocall.login.LoginManager;
import com.netease.yunxin.app.videocall.order.CallOrder;
import com.netease.yunxin.app.videocall.order.CallOrderManager;
import com.netease.yunxin.app.videocall.user.UserCacheManager;
import com.netease.yunxin.app.videocall.user.UserModel;
import com.netease.yunxin.kit.call.p2p.NECallEngine;
import com.netease.yunxin.kit.call.p2p.model.NECallType;
import com.netease.yunxin.kit.common.utils.NetworkUtils;
import com.netease.yunxin.nertc.nertcvideocall.model.impl.state.CallState;
import com.netease.yunxin.nertc.ui.CallKitUI;
import com.netease.yunxin.nertc.ui.base.CallParam;
import java.util.List;
import org.json.JSONException;
import org.json.JSONObject;

public class SingleCallUserActivity extends AppCompatActivity {
  private TextView tvNickname;
  private TextView tvSelfId;
  private RadioButton rbVideoCall;
  private RecyclerView rvRecentUser;
  private RecentUserAdapter userAdapter;

  private Button btnCall;
  private EditText edtAccountId;
  private ImageView ivClear;

  private TextView tvRecentSearch;

  private CallOrderAdapter callOrderAdapter;
  private TextView tvCallRecord;

  public static void startActivity(Context context) {
    Intent intent = new Intent();
    intent.setClass(context, SingleCallUserActivity.class);
    context.startActivity(intent);
  }

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.single_call_layout);
    initView();
    initData();
  }

  private void initView() {
    btnCall = findViewById(R.id.btn_call);
    edtAccountId = findViewById(R.id.edt_account_id);
    ivClear = findViewById(R.id.iv_clear);
    rvRecentUser = findViewById(R.id.rv_recent_user);
    RecyclerView rvCallOrder = findViewById(R.id.rv_call_order);
    tvNickname = findViewById(R.id.tv_nickname);
    tvSelfId = findViewById(R.id.tv_self_id);
    tvCallRecord = findViewById(R.id.tv_call_order);
    tvRecentSearch = findViewById(R.id.tv_recently_search);
    rbVideoCall = findViewById(R.id.rb_video_call);
    TextView tvCancel = findViewById(R.id.tv_cancel);
    tvCancel.setOnClickListener(v -> onBackPressed());
    edtAccountId.addTextChangedListener(
        new TextWatcher() {
          @Override
          public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {}

          @Override
          public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {}

          @Override
          public void afterTextChanged(Editable editable) {
            if (!TextUtils.isEmpty(editable)) {
              ivClear.setVisibility(View.VISIBLE);
            } else {
              ivClear.setVisibility(View.GONE);
            }
          }
        });
    ivClear.setOnClickListener(view -> edtAccountId.setText(""));
    rvRecentUser.setLayoutManager(
        new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, true));
    View settingBtn = findViewById(R.id.iv_setting);

    TextView title = findViewById(R.id.tv_title);
    title.setText(R.string.one_on_one_video_call);

    callOrderAdapter = new CallOrderAdapter(this);
    LinearLayoutManager callOrderLayoutManager =
        new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, true);
    rvCallOrder.setLayoutManager(callOrderLayoutManager);
    rvCallOrder.setAdapter(callOrderAdapter);
    List<CallOrder> orderRecord = CallOrderManager.getInstance().getOrders();
    callOrderAdapter.updateItem(orderRecord);
    callOrderAdapter.setOnItemClickListener(
        order -> {
          UserModel currentUser = LoginManager.getInstance().getUserModel();
          if (currentUser == null || TextUtils.isEmpty(currentUser.getAccount())) {
            Toast.makeText(
                    getApplicationContext(),
                    R.string.current_user_login_problem,
                    Toast.LENGTH_SHORT)
                .show();
            return;
          }
          if (currentUser.getAccount().equals(order.getSessionId())) {
            Toast.makeText(
                    getApplicationContext(), R.string.cannot_call_yourself, Toast.LENGTH_SHORT)
                .show();
            return;
          }
          if (!NetworkUtils.isConnected()) {
            Toast.makeText(
                    SingleCallUserActivity.this,
                    R.string.network_connect_error_please_try_again,
                    Toast.LENGTH_SHORT)
                .show();
            return;
          }
          if (NECallEngine.sharedInstance().getCallInfo().callStatus != CallState.STATE_IDLE) {
            Toast.makeText(
                    getApplicationContext(), R.string.calling_in_progress, Toast.LENGTH_SHORT)
                .show();
            return;
          }

          int callType = rbVideoCall.isChecked() ? NECallType.VIDEO : NECallType.AUDIO;

          JSONObject extraInfo = new JSONObject();
          try {
            extraInfo.putOpt("key", "call");
            extraInfo.putOpt("value", "testValue");
            extraInfo.putOpt("userName", currentUser.getAccount());
          } catch (JSONException e) {
            e.printStackTrace();
          }

          CallParam param =
              new CallParam.Builder()
                  .callType(callType)
                  .calledAccId(order.getSessionId())
                  .callExtraInfo(extraInfo.toString())
                  .globalExtraCopy(SettingActivity.GLOBAL_EXTRA_COPY)
                  .rtcChannelName(SettingActivity.RTC_CHANNEL_NAME)
                  .build();
          CallKitUI.startSingleCall(SingleCallUserActivity.this, param);
        });
    if (!orderRecord.isEmpty()) {
      tvCallRecord.setVisibility(View.VISIBLE);
    }
    settingBtn.setOnClickListener(
        v -> startActivity(new Intent(SingleCallUserActivity.this, SettingActivity.class)));
    settingBtn.setVisibility(View.VISIBLE);
  }

  private void initData() {
    UserModel currentUser = LoginManager.getInstance().getUserModel();
    if (currentUser != null && !TextUtils.isEmpty(currentUser.getName())) {
      tvNickname.setText(String.format(getString(R.string.your_nick), currentUser.getName()));
    }
    tvSelfId.setText(String.format(getString(R.string.your_id), currentUser.getAccount()));

    // Double-tap to copy ID
    GestureDetector detector =
        new GestureDetector(
            this,
            new GestureDetector.SimpleOnGestureListener() {
              @Override
              public boolean onDoubleTap(MotionEvent e) {
                ClipboardManager clipboard =
                    (ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);
                ClipData clip = ClipData.newPlainText("imAccid", currentUser.getAccount());
                if (clipboard != null) {
                  clipboard.setPrimaryClip(clip);
                  Toast.makeText(
                          SingleCallUserActivity.this,
                          R.string.id_copied_to_clipboard,
                          Toast.LENGTH_SHORT)
                      .show();
                }
                return true;
              }
            });
    tvSelfId.setOnTouchListener((v, event) -> detector.onTouchEvent(event));
    tvSelfId.setClickable(true);

    CallOrderManager.getInstance()
        .getOrdersLiveData()
        .observe(
            this,
            orders -> {
              callOrderAdapter.updateItem(orders);
              if (!orders.isEmpty()) {
                tvCallRecord.setVisibility(View.VISIBLE);
              }
            });

    UserCacheManager.getInstance()
        .getLastSearchUser(
            users ->
                runOnUiThread(
                    () -> {
                      if (userAdapter == null) {
                        userAdapter = new RecentUserAdapter(SingleCallUserActivity.this);
                      }
                      rvRecentUser.setAdapter(userAdapter);
                      userAdapter.updateUsers(users);
                      if (users != null && !users.isEmpty()) {
                        tvRecentSearch.setVisibility(View.VISIBLE);
                      }
                      userAdapter.setItemStateListener(this::getItemState);
                      userAdapter.setItemClickListener(this::handleForClick);
                    }));

    btnCall.setOnClickListener(
        v -> {
          if (!NetworkUtils.isConnected()) {
            Toast.makeText(
                    SingleCallUserActivity.this, R.string.nertc_no_network, Toast.LENGTH_SHORT)
                .show();
            return;
          }
          String accountId = edtAccountId.getText().toString().trim();
          if (!TextUtils.isEmpty(accountId)) {
            // 直接使用账号ID进行呼叫
            if (TextUtils.isEmpty(currentUser.getAccount())) {
              Toast.makeText(
                      getApplicationContext(),
                      R.string.current_user_login_problem,
                      Toast.LENGTH_SHORT)
                  .show();
              return;
            }

            if (currentUser.getAccount().equals(accountId)) {
              Toast.makeText(
                      getApplicationContext(), R.string.cannot_call_yourself, Toast.LENGTH_SHORT)
                  .show();
              return;
            }

            if (NECallEngine.sharedInstance().getCallInfo().callStatus != CallState.STATE_IDLE) {
              Toast.makeText(
                      getApplicationContext(), R.string.calling_in_progress, Toast.LENGTH_SHORT)
                  .show();
              return;
            }

            // 根据选择的呼叫类型确定呼叫类型
            int callType = rbVideoCall.isChecked() ? NECallType.VIDEO : NECallType.AUDIO;

            // 自定义透传字段，被叫用户在收到呼叫邀请时通过参数进行解析
            JSONObject extraInfo = new JSONObject();
            try {
              extraInfo.putOpt("key", "call");
              extraInfo.putOpt("value", "testValue");
              extraInfo.putOpt("userName", currentUser.getAccount());
            } catch (JSONException e) {
              e.printStackTrace();
            }

            CallParam param =
                new CallParam.Builder()
                    .callType(callType)
                    .calledAccId(accountId)
                    .callExtraInfo(extraInfo.toString())
                    .globalExtraCopy(SettingActivity.GLOBAL_EXTRA_COPY)
                    .rtcChannelName(SettingActivity.RTC_CHANNEL_NAME)
                    .build();
            CallKitUI.startSingleCall(getApplicationContext(), param);
            hideKeyBoard();
          } else {
            Toast.makeText(
                    getApplicationContext(), R.string.please_input_account_id, Toast.LENGTH_SHORT)
                .show();
          }
        });
  }

  private void hideKeyBoard() {
    View view = getCurrentFocus();
    if (view != null) {
      InputMethodManager inputMethodManager =
          (InputMethodManager) getSystemService(Activity.INPUT_METHOD_SERVICE);
      inputMethodManager.hideSoftInputFromWindow(
          view.getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
    }
  }

  private int getItemState(LoginInfo data) {
    // 单呼叫模式下不需要状态管理
    return -1;
  }

  private void handleForClick(LoginInfo data) {
    UserModel currentUser = LoginManager.getInstance().getUserModel();
    if (currentUser == null || TextUtils.isEmpty(currentUser.getAccount())) {
      Toast.makeText(
              getApplicationContext(), R.string.current_user_login_problem, Toast.LENGTH_SHORT)
          .show();
      return;
    }

    if (currentUser.getAccount().equals(data.getAccount())) {
      Toast.makeText(getApplicationContext(), R.string.cannot_call_yourself, Toast.LENGTH_SHORT)
          .show();
      return;
    }
    if (NetworkUtils.isConnected()) {
      if (NECallEngine.sharedInstance().getCallInfo().callStatus != CallState.STATE_IDLE) {
        Toast.makeText(getApplicationContext(), R.string.calling_in_progress, Toast.LENGTH_SHORT)
            .show();
        return;
      }

      // 自定义透传字段，被叫用户在收到呼叫邀请时通过参数进行解析
      JSONObject extraInfo = new JSONObject();

      try {
        extraInfo.putOpt("key", "call");
        extraInfo.putOpt("value", "testValue");
        extraInfo.putOpt("userName", currentUser.getAccount());
      } catch (JSONException e) {
        e.printStackTrace();
      }

      CallParam param =
          new CallParam.Builder()
              .callType(rbVideoCall.isChecked() ? NECallType.VIDEO : NECallType.AUDIO)
              .calledAccId(data.getAccount())
              .callExtraInfo(extraInfo.toString())
              .globalExtraCopy(SettingActivity.GLOBAL_EXTRA_COPY)
              .rtcChannelName(SettingActivity.RTC_CHANNEL_NAME)
              .build();
      CallKitUI.startSingleCall(getApplicationContext(), param);
    } else {
      Toast.makeText(
              SingleCallUserActivity.this,
              R.string.network_connect_error_please_try_again,
              Toast.LENGTH_SHORT)
          .show();
    }
  }
}
