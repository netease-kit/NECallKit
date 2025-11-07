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
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import com.netease.yunxin.app.videocall.R;
import com.netease.yunxin.app.videocall.login.LoginManager;
import com.netease.yunxin.app.videocall.user.UserModel;
import com.netease.yunxin.kit.call.group.GroupCallEndEvent;
import com.netease.yunxin.kit.call.group.GroupCallHangupEvent;
import com.netease.yunxin.kit.call.group.GroupCallMember;
import com.netease.yunxin.kit.call.group.NEGroupCall;
import com.netease.yunxin.kit.call.group.NEGroupCallDelegate;
import com.netease.yunxin.kit.call.group.NEGroupCallInfo;
import com.netease.yunxin.kit.call.group.param.GroupCallParam;
import com.netease.yunxin.nertc.ui.CallKitUI;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONObject;

public class MultiCallUserActivity extends AppCompatActivity {
  private static final String KEY_CALL_MODE_TYPE = "key_call_mode_type";
  public static final String KEY_CALL_USER_LIST = "key_call_user_list";
  private static final int LIMIT_COUNT = 10;
  private final List<String> alreadyConnectionUserList = new ArrayList<>();
  private TextView tvSelfId;
  private TextView tvNickname;
  private EditText edtAccountId;
  private ImageView ivClear;

  private TextView tvCallRecord;
  TextView tvGroupCall;

  private LinearLayout containerToCallUsers; // 显示待呼叫用户列表

  private int callModeType;
  private static final int REQ_GROUP_SETTING = 1001;
  private String rtcChannelNameFromSetting = null;

  private final NEGroupCallDelegate observer =
      new NEGroupCallDelegate() {
        @Override
        public void onReceiveGroupInvitation(NEGroupCallInfo info) {}

        @Override
        public void onGroupMemberListChanged(String callId, List<GroupCallMember> userList) {}

        @Override
        public void onGroupCallHangup(GroupCallHangupEvent hangupEvent) {
          if (callModeType == CallModeType.RTC_GROUP_INVITE) {
            finish();
          }
        }

        @Override
        public void onGroupCallEnd(GroupCallEndEvent endEvent) {
          if (callModeType == CallModeType.RTC_GROUP_INVITE) {
            finish();
          }
        }
      };

  public static void startSelectUser(
      Activity activity, int requestCode, int type, List<String> userList) {
    Intent intent = new Intent();
    intent.setClass(activity, MultiCallUserActivity.class);
    intent.putExtra(KEY_CALL_MODE_TYPE, type);
    if (userList != null) {
      intent.putStringArrayListExtra(KEY_CALL_USER_LIST, new ArrayList<>(userList));
    }
    activity.startActivityForResult(intent, requestCode);
  }

  public static void startSelectUser(Context context, int type, List<String> userList) {
    Intent intent = new Intent();
    intent.setClass(context, MultiCallUserActivity.class);
    intent.putExtra(KEY_CALL_MODE_TYPE, type);
    if (userList != null) {
      intent.putStringArrayListExtra(KEY_CALL_USER_LIST, new ArrayList<>(userList));
    }
    context.startActivity(intent);
  }

  public static void startSelectUser(Context context, int type) {
    startSelectUser(context, type, null);
  }

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    NEGroupCall.instance().addGroupCallDelegate(observer);
    callModeType = getIntent().getIntExtra(KEY_CALL_MODE_TYPE, CallModeType.RTC_GROUP_CALL);
    List<String> connectionUserList = getIntent().getStringArrayListExtra(KEY_CALL_USER_LIST);
    if (connectionUserList != null) {
      alreadyConnectionUserList.addAll(connectionUserList);
    }
    setContentView(R.layout.multi_call_select_layout);
    initView(callModeType);
    initData();
  }

  private void initView(int callModeType) {
    edtAccountId = findViewById(R.id.edt_account_id);
    ivClear = findViewById(R.id.iv_clear);
    tvSelfId = findViewById(R.id.tv_self_id);
    tvNickname = findViewById(R.id.tv_nickname);
    tvCallRecord = findViewById(R.id.tv_call_order);
    TextView tvCancel = findViewById(R.id.tv_cancel);
    tvCancel.setOnClickListener(v -> onBackPressed());

    // 设置输入框提示文本
    edtAccountId.setHint(getString(R.string.please_input_multiple_account_ids));

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
              updateToCallUsersList(editable.toString());
            } else {
              ivClear.setVisibility(View.GONE);
              updateToCallUsersList("");
            }
          }
        });
    ivClear.setOnClickListener(view -> edtAccountId.setText(""));

    tvGroupCall = findViewById(R.id.tv_to_group_call);
    View settingBtn = findViewById(R.id.iv_setting);

    TextView title = findViewById(R.id.tv_title);
    if (callModeType == CallModeType.RTC_GROUP_CALL) {
      title.setText(R.string.group_call);
    }

    settingBtn.setOnClickListener(
        v -> {
          Intent intent = new Intent(MultiCallUserActivity.this, MultiCallSettingActivity.class);
          if (!TextUtils.isEmpty(rtcChannelNameFromSetting)) {
            intent.putExtra(
                MultiCallSettingActivity.EXTRA_RTC_CHANNEL_NAME, rtcChannelNameFromSetting);
          }
          startActivityForResult(intent, REQ_GROUP_SETTING);
        });

    // 初始化待呼叫用户显示区域
    containerToCallUsers = findViewById(R.id.container_to_call_users);
    tvCallRecord.setVisibility(View.VISIBLE);
    tvCallRecord.setText(R.string.users_to_be_called);

    tvGroupCall.setVisibility(View.VISIBLE);
    updateGroupCallButton();

    tvGroupCall.setOnClickListener(
        v -> {
          if (!com.netease.yunxin.nertc.nertcvideocall.utils.NetworkUtils.isConnected()) {
            Toast.makeText(
                    MultiCallUserActivity.this,
                    R.string.network_connect_error_please_try_again,
                    Toast.LENGTH_SHORT)
                .show();
            return;
          }

          String accountIds = edtAccountId.getText().toString().trim();
          if (TextUtils.isEmpty(accountIds)) {
            Toast.makeText(
                    getApplicationContext(), R.string.please_input_account_id, Toast.LENGTH_SHORT)
                .show();
            return;
          }

          List<String> userList = parseAccountIds(accountIds);
          if (!userList.isEmpty()) {
            if (callModeType == CallModeType.RTC_GROUP_CALL) {
              String[] userArray = new String[userList.size()];
              userList.toArray(userArray);

              JSONObject extraInfo = new JSONObject();
              UserModel currentUser = LoginManager.getInstance().getUserModel();
              try {
                extraInfo.putOpt("key", "call");
                extraInfo.putOpt("value", "testValue");
                if (currentUser != null) {
                  extraInfo.putOpt("userName", currentUser.getAccount());
                }
              } catch (Throwable e) {
                e.printStackTrace();
              }
              GroupCallParam param;
              if (!TextUtils.isEmpty(rtcChannelNameFromSetting)) {
                param =
                    new GroupCallParam.Builder()
                        .callees(userArray)
                        .callId(rtcChannelNameFromSetting)
                        .extraInfo(extraInfo.toString())
                        .build();
              } else {
                param =
                    new GroupCallParam.Builder()
                        .callees(userArray)
                        .extraInfo(extraInfo.toString())
                        .build();
              }
              CallKitUI.startGroupCall(this, param);
            } else if (callModeType == CallModeType.RTC_GROUP_INVITE) {
              Intent intent = new Intent();
              intent.putStringArrayListExtra(KEY_CALL_USER_LIST, new ArrayList<>(userList));
              setResult(RESULT_OK, intent);
              finish();
            }
          } else {
            Toast.makeText(
                    getApplicationContext(), R.string.please_input_account_id, Toast.LENGTH_SHORT)
                .show();
          }
        });
    settingBtn.setVisibility(View.VISIBLE);
  }

  private void initData() {
    UserModel currentUser = LoginManager.getInstance().getUserModel();
    if (currentUser != null) {
      if (!TextUtils.isEmpty(currentUser.getName())) {
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
                            MultiCallUserActivity.this,
                            R.string.id_copied_to_clipboard,
                            Toast.LENGTH_SHORT)
                        .show();
                  }
                  return true;
                }
              });
      tvSelfId.setOnTouchListener((v, event) -> detector.onTouchEvent(event));
      tvSelfId.setClickable(true);
    }
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

  /** 解析逗号分隔的账号ID */
  private List<String> parseAccountIds(String accountIds) {
    List<String> result = new ArrayList<>();
    if (TextUtils.isEmpty(accountIds)) {
      return result;
    }

    String[] ids = accountIds.split(",");
    UserModel currentUser = LoginManager.getInstance().getUserModel();

    for (String id : ids) {
      String trimmedId = id.trim();
      if (!TextUtils.isEmpty(trimmedId) && !trimmedId.equals(currentUser.getAccount())) {
        result.add(trimmedId);
      }
    }

    return result;
  }

  /** 更新待呼叫用户列表显示 */
  private void updateToCallUsersList(String accountIds) {
    // 清空现有的标签
    containerToCallUsers.removeAllViews();

    if (TextUtils.isEmpty(accountIds)) {
      containerToCallUsers.setVisibility(View.GONE);
      return;
    }

    List<String> userList = parseAccountIds(accountIds);
    if (userList.isEmpty()) {
      containerToCallUsers.setVisibility(View.GONE);
    } else {
      // 为每个账号ID创建一个标签
      for (String userId : userList) {
        TextView tagView = new TextView(this);
        tagView.setText(userId);
        tagView.setTextSize(14);
        tagView.setTextColor(getResources().getColor(R.color.colorWhite));
        tagView.setPadding(16, 12, 16, 12);
        tagView.setBackgroundResource(R.drawable.tag_background);

        // 设置LinearLayout参数
        LinearLayout.LayoutParams params =
            new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        params.setMargins(0, 4, 12, 4);
        tagView.setLayoutParams(params);

        containerToCallUsers.addView(tagView);
      }
      containerToCallUsers.setVisibility(View.VISIBLE);
    }

    updateGroupCallButton();
  }

  /** 更新群组呼叫按钮文本 */
  private void updateGroupCallButton() {
    String accountIds = edtAccountId.getText().toString().trim();
    List<String> userList = parseAccountIds(accountIds);
    int count = userList.size();

    if (count > 0) {
      tvGroupCall.setText(getString(R.string.start_group_call_with_count, count));
      tvGroupCall.setEnabled(true);
    } else {
      tvGroupCall.setText(getString(R.string.start_group_call));
      tvGroupCall.setEnabled(false);
    }
  }

  @Override
  protected void onPause() {
    super.onPause();
    if (isFinishing()) {
      NEGroupCall.instance().removeGroupCallDelegate(observer);
    }
  }

  @Override
  protected void onDestroy() {
    super.onDestroy();
    NEGroupCall.instance().removeGroupCallDelegate(observer);
  }

  @Override
  protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
    super.onActivityResult(requestCode, resultCode, data);
    if (requestCode == REQ_GROUP_SETTING && resultCode == RESULT_OK && data != null) {
      String value = data.getStringExtra(MultiCallSettingActivity.EXTRA_RTC_CHANNEL_NAME);
      if (value != null) {
        rtcChannelNameFromSetting = value;
      }
    }
  }
}
