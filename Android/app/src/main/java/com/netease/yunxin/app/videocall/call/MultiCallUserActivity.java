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
import android.util.Log;
import android.view.Gravity;
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
import com.netease.yunxin.app.videocall.utils.SPUtils;
import com.netease.yunxin.app.videocall.user.UserModel;
import com.netease.yunxin.kit.call.group.GroupCallEndEvent;
import com.netease.yunxin.kit.call.group.GroupCallHangupEvent;
import com.netease.yunxin.kit.call.group.GroupCallMember;
import com.netease.yunxin.kit.call.group.GroupRtcInfo;
import com.netease.yunxin.kit.call.group.NEGroupCall;
import com.netease.yunxin.kit.call.group.NEGroupCallDelegate;
import com.netease.yunxin.kit.call.group.NEGroupCallInfo;
import com.netease.yunxin.kit.call.group.param.GroupCallParam;
import com.netease.yunxin.nertc.ui.CallKitUI;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

public class MultiCallUserActivity extends AppCompatActivity {
  private static final String TAG = "MultiCallUserActivity";
  private static final String KEY_CALL_MODE_TYPE = "key_call_mode_type";
  public static final String KEY_CALL_USER_LIST = "key_call_user_list";
  private static final int LIMIT_COUNT = 10;
  private static final int RECENT_INVITE_LIMIT = 20;
  private static final String RECENT_INVITE_SP = "multi_call_recent_invite_users";
  private static final String RECENT_INVITE_LIST = "recent_invite_list";
  private static final List<String> PRESET_ACCOUNT_IDS = new ArrayList<>();
  private final List<String> alreadyConnectionUserList = new ArrayList<>();
  private final List<String> recentInviteAccountIds = new ArrayList<>();
  private TextView tvSelfId;
  private TextView tvNickname;
  private EditText edtAccountId;
  private ImageView ivClear;

  private TextView tvCallRecord;
  TextView tvGroupCall;

  private LinearLayout containerToCallUsers; // 显示待呼叫用户列表
  private LinearLayout containerRecentInviteUsers;

  private int callModeType;
  private static final int REQ_GROUP_SETTING = 1001;
  private String rtcChannelNameFromSetting = null;
  private String groupIdFromSetting = null;
  private String extraInfoFromSetting = null;
  private boolean autoExtraInfoFromSetting;

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

        @Override
        public void onGroupRtcJoinSuccess(GroupRtcInfo info) {
          Log.i(
              TAG,
              "onGroupRtcJoinSuccess callId="
                  + info.callId
                  + " cid="
                  + info.cid
                  + " selfRtcUid="
                  + info.selfRtcUid);
          logCurrentGroupRtcInfo();
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

  private void logCurrentGroupRtcInfo() {
    GroupRtcInfo info = NEGroupCall.instance().currentGroupRtcInfo();
    if (info == null) {
      Log.i(TAG, "currentGroupRtcInfo null");
      return;
    }
    Log.i(
        TAG,
        "currentGroupRtcInfo callId="
            + info.callId
            + " cid="
            + info.cid
            + " selfRtcUid="
            + info.selfRtcUid);
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
          intent.putExtra(MultiCallSettingActivity.EXTRA_CALL_MODE_TYPE, callModeType);
          if (!TextUtils.isEmpty(rtcChannelNameFromSetting)) {
            intent.putExtra(
                MultiCallSettingActivity.EXTRA_RTC_CHANNEL_NAME, rtcChannelNameFromSetting);
          }
          if (!TextUtils.isEmpty(groupIdFromSetting)) {
            intent.putExtra(MultiCallSettingActivity.EXTRA_GROUP_ID, groupIdFromSetting);
          }
          if (callModeType == CallModeType.RTC_GROUP_CALL) {
            intent.putExtra(MultiCallSettingActivity.EXTRA_EXTRA_INFO, extraInfoFromSetting);
            intent.putExtra(
                MultiCallSettingActivity.EXTRA_AUTO_EXTRA_INFO, autoExtraInfoFromSetting);
          }
          startActivityForResult(intent, REQ_GROUP_SETTING);
        });

    // 初始化待呼叫用户显示区域
    containerToCallUsers = findViewById(R.id.container_to_call_users);
    containerRecentInviteUsers = findViewById(R.id.container_recent_invite_users);
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
            saveRecentInviteAccounts(userList);
            if (callModeType == CallModeType.RTC_GROUP_CALL) {
              String[] userArray = new String[userList.size()];
              userList.toArray(userArray);

              GroupCallParam param =
                  GroupCallParamFactory.create(
                      userArray,
                      rtcChannelNameFromSetting,
                      groupIdFromSetting,
                      extraInfoFromSetting);
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
    loadRecentInviteAccounts();
    renderRecentInviteUsers();
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
      if (!TextUtils.isEmpty(trimmedId)
          && (currentUser == null || !trimmedId.equals(currentUser.getAccount()))
          && !result.contains(trimmedId)) {
        result.add(trimmedId);
      }
    }

    return result;
  }

  private void loadRecentInviteAccounts() {
    recentInviteAccountIds.clear();
    String cache = SPUtils.getInstance(getRecentInviteSpName()).getString(RECENT_INVITE_LIST);
    if (!TextUtils.isEmpty(cache)) {
      for (String accountId : cache.split(",")) {
        appendRecentInviteAccount(recentInviteAccountIds, accountId);
      }
    }
    for (String accountId : PRESET_ACCOUNT_IDS) {
      appendRecentInviteAccount(recentInviteAccountIds, accountId);
    }
    trimRecentInviteAccounts(recentInviteAccountIds);
  }

  private void saveRecentInviteAccounts(List<String> accountIds) {
    if (accountIds == null || accountIds.isEmpty()) {
      return;
    }
    LinkedList<String> mergedAccounts = new LinkedList<>();
    for (String accountId : accountIds) {
      appendRecentInviteAccount(mergedAccounts, accountId);
    }
    for (String accountId : recentInviteAccountIds) {
      appendRecentInviteAccount(mergedAccounts, accountId);
    }
    for (String accountId : PRESET_ACCOUNT_IDS) {
      appendRecentInviteAccount(mergedAccounts, accountId);
    }
    trimRecentInviteAccounts(mergedAccounts);
    recentInviteAccountIds.clear();
    recentInviteAccountIds.addAll(mergedAccounts);
    SPUtils.getInstance(getRecentInviteSpName())
        .put(RECENT_INVITE_LIST, TextUtils.join(",", recentInviteAccountIds));
    renderRecentInviteUsers();
  }

  private String getRecentInviteSpName() {
    UserModel currentUser = LoginManager.getInstance().getUserModel();
    String account = currentUser == null ? "" : currentUser.getAccount();
    return RECENT_INVITE_SP + "_" + account;
  }

  private void appendRecentInviteAccount(List<String> accounts, String accountId) {
    if (TextUtils.isEmpty(accountId)) {
      return;
    }
    String trimmedAccountId = accountId.trim();
    if (TextUtils.isEmpty(trimmedAccountId) || accounts.contains(trimmedAccountId)) {
      return;
    }
    accounts.add(trimmedAccountId);
  }

  private void trimRecentInviteAccounts(List<String> accounts) {
    while (accounts.size() > RECENT_INVITE_LIMIT) {
      accounts.remove(accounts.size() - 1);
    }
  }

  private void renderRecentInviteUsers() {
    if (containerRecentInviteUsers == null) {
      return;
    }
    containerRecentInviteUsers.removeAllViews();
    List<String> selectedAccountIds = parseAccountIds(edtAccountId.getText().toString());
    for (String accountId : recentInviteAccountIds) {
      containerRecentInviteUsers.addView(createRecentInviteRow(accountId, selectedAccountIds));
    }
  }

  private View createRecentInviteRow(String accountId, List<String> selectedAccountIds) {
    LinearLayout row = new LinearLayout(this);
    row.setGravity(Gravity.CENTER_VERTICAL);
    row.setOrientation(LinearLayout.HORIZONTAL);
    row.setPadding(8, 8, 8, 8);
    row.setOnClickListener(v -> toggleAccountInInput(accountId));

    TextView accountView = new TextView(this);
    accountView.setText(accountId);
    accountView.setTextColor(getResources().getColor(R.color.colorWhite));
    accountView.setTextSize(16);
    LinearLayout.LayoutParams accountParams =
        new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1);
    row.addView(accountView, accountParams);

    TextView actionView = new TextView(this);
    boolean selected = selectedAccountIds.contains(accountId);
    actionView.setText(selected ? R.string.remove : R.string.add);
    actionView.setTextColor(getResources().getColor(R.color.colorWhite));
    actionView.setGravity(Gravity.CENTER);
    actionView.setBackgroundResource(
        selected ? R.drawable.btn_call_bg : R.drawable.shape_select_to_add_bg);
    row.addView(
        actionView,
        new LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT));

    return row;
  }

  private void toggleAccountInInput(String accountId) {
    List<String> accountIds = parseAccountIds(edtAccountId.getText().toString());
    if (accountIds.contains(accountId)) {
      accountIds.remove(accountId);
    } else {
      accountIds.add(accountId);
    }
    edtAccountId.setText(TextUtils.join(",", accountIds));
    edtAccountId.setSelection(edtAccountId.getText().length());
  }

  /** 更新待呼叫用户列表显示 */
  private void updateToCallUsersList(String accountIds) {
    // 清空现有的标签
    containerToCallUsers.removeAllViews();

    if (TextUtils.isEmpty(accountIds)) {
      containerToCallUsers.setVisibility(View.GONE);
      updateGroupCallButton();
      renderRecentInviteUsers();
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
    renderRecentInviteUsers();
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
      String groupId = data.getStringExtra(MultiCallSettingActivity.EXTRA_GROUP_ID);
      if (groupId != null) {
        groupIdFromSetting = groupId;
      }
      if (callModeType == CallModeType.RTC_GROUP_CALL) {
        String extraInfo = data.getStringExtra(MultiCallSettingActivity.EXTRA_EXTRA_INFO);
        if (extraInfo != null) {
          extraInfoFromSetting = extraInfo;
        }
        autoExtraInfoFromSetting =
            data.getBooleanExtra(MultiCallSettingActivity.EXTRA_AUTO_EXTRA_INFO, false);
      }
    }
  }
}
