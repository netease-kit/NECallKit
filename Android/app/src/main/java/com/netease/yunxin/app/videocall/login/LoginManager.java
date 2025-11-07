// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.login;

import android.app.ActivityManager;
import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.auth.LoginInfo;
import com.netease.nimlib.sdk.v2.V2NIMError;
import com.netease.nimlib.sdk.v2.V2NIMFailureCallback;
import com.netease.nimlib.sdk.v2.V2NIMSuccessCallback;
import com.netease.nimlib.sdk.v2.auth.V2NIMLoginListener;
import com.netease.nimlib.sdk.v2.auth.V2NIMLoginService;
import com.netease.nimlib.sdk.v2.auth.enums.V2NIMLoginClientChange;
import com.netease.nimlib.sdk.v2.auth.enums.V2NIMLoginStatus;
import com.netease.nimlib.sdk.v2.auth.model.V2NIMKickedOfflineDetail;
import com.netease.nimlib.sdk.v2.auth.model.V2NIMLoginClient;
import com.netease.nimlib.sdk.v2.user.V2NIMUser;
import com.netease.nimlib.sdk.v2.user.V2NIMUserService;
import com.netease.nimlib.sdk.v2.user.params.V2NIMUserUpdateParams;
import com.netease.yunxin.app.videocall.DemoApplication;
import com.netease.yunxin.app.videocall.R;
import com.netease.yunxin.app.videocall.im.NimUserUtils;
import com.netease.yunxin.app.videocall.login.ui.LoginActivity;
import com.netease.yunxin.app.videocall.user.UserModel;
import com.netease.yunxin.app.videocall.utils.SPUtils;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.call.common.callback.Callback;
import com.netease.yunxin.kit.common.ui.utils.ToastX;
import com.netease.yunxin.nertc.nertcvideocall.utils.GsonUtils;
import com.netease.yunxin.nertc.ui.callback.NECallback;
import java.util.ArrayList;
import java.util.List;

public final class LoginManager {
  private final String TAG = "LoginManager";
  public static final String PER_DATA = "per_profile_manager";
  private static final LoginManager instance = new LoginManager();
  private final List<V2NIMLoginListener> loginListeners = new ArrayList<>();

  public static LoginManager getInstance() {
    return instance;
  }

  private static final String PER_USER_MODEL = "per_user_model";
  private UserModel userModel;

  private LoginManager() {
    init();
  }

  private void init() {
    NIMClient.getService(V2NIMLoginService.class)
        .addLoginListener(
            new V2NIMLoginListener() {
              @Override
              public void onLoginStatus(V2NIMLoginStatus status) {
                ALog.i(TAG, "onLoginStatus " + status);
                for (V2NIMLoginListener listener : loginListeners) {
                  listener.onLoginStatus(status);
                }
              }

              @Override
              public void onLoginFailed(V2NIMError error) {
                ALog.e(TAG, "onLoginFailed " + error);
                for (V2NIMLoginListener listener : loginListeners) {
                  listener.onLoginFailed(error);
                }
              }

              @Override
              public void onKickedOffline(V2NIMKickedOfflineDetail detail) {
                ALog.e(TAG, "onKickedOffline " + detail);
                handleLogout();
                ToastX.showShortToast(R.string.kickoff_tips);
                for (V2NIMLoginListener listener : loginListeners) {
                  listener.onKickedOffline(detail);
                }
              }

              @Override
              public void onLoginClientChanged(
                  V2NIMLoginClientChange change, List<V2NIMLoginClient> clients) {
                ALog.i(TAG, "onLoginClientChanged " + change + ", clients: " + clients);
                for (V2NIMLoginListener listener : loginListeners) {
                  listener.onLoginClientChanged(change, clients);
                }
              }
            });
  }

  public void addLoginListener(V2NIMLoginListener listener) {
    if (listener != null && !loginListeners.contains(listener)) {
      loginListeners.add(listener);
    }
  }

  public void removeLoginListener(V2NIMLoginListener listener) {
    if (listener != null) {
      loginListeners.remove(listener);
    }
  }

  public boolean isLogin() {
    return NIMClient.getService(V2NIMLoginService.class).getLoginStatus()
        == V2NIMLoginStatus.V2NIM_LOGIN_STATUS_LOGINED;
  }

  public UserModel getUserModel() {
    if (userModel == null) {
      loadUserModel();
    }
    ALog.i(TAG, "getUserModel " + userModel);
    return userModel;
  }

  /** 是否是本用户 */
  public boolean isCurrentUser(String imAccId) {
    if (getUserModel() == null) {
      return false;
    }
    return TextUtils.equals(getUserModel().getAccount(), imAccId);
  }

  public void setUserModel(UserModel model) {
    ALog.e(TAG, "setUserModel " + model);
    userModel = model;
    saveUserModel();
  }

  private void loadUserModel() {
    ALog.e(TAG, "loadUserModel");
    try {
      String json = SPUtils.getInstance(PER_DATA).getString(PER_USER_MODEL);
      userModel = GsonUtils.fromJson(json, UserModel.class);
      ALog.e(TAG, "loadUserModel " + userModel);
    } catch (Exception e) {
      ALog.e(TAG, "loadUserModel failed");
    }
  }

  private void saveUserModel() {
    ALog.i(TAG, "saveUserModel " + userModel);
    try {
      if (userModel != null) {
        SPUtils.getInstance(PER_DATA).put(PER_USER_MODEL, GsonUtils.toJson(userModel));
      } else {
        SPUtils.getInstance(PER_DATA).put(PER_USER_MODEL, "");
      }
    } catch (Exception e) {
      ALog.e(TAG, "saveUserModel failed");
    }
  }

  public void login(LoginInfo loginInfo, NECallback<Void> callback) {
    NIMClient.getService(V2NIMLoginService.class)
        .login(
            loginInfo.getAccount(),
            loginInfo.getToken(),
            null,
            new V2NIMSuccessCallback<Void>() {
              @Override
              public void onSuccess(Void unused) {
                ALog.i(TAG, "login im success");
                UserModel userInfo = new UserModel();
                userInfo.setAccount(loginInfo.getAccount());
                userInfo.setToken(loginInfo.getToken());
                setUserModel(userInfo);
                updateUserNick(userInfo.getAccount());
                if (callback != null) {
                  callback.onSuccess(null);
                }
              }
            },
            new V2NIMFailureCallback() {
              @Override
              public void onFailure(V2NIMError error) {
                ALog.e(
                    TAG,
                    "login im failed code = " + error.getCode() + ", msg = " + error.getDesc());
                if (callback != null) {
                  callback.onError(error.getCode(), error.getDesc());
                }
              }
            });
  }

  public void updateUserNick(String accountId) {
    List<String> accounts = new ArrayList<>();
    accounts.add(accountId);
    NimUserUtils.getUserList(
        accounts,
        new Callback<List<V2NIMUser>>() {
          @Override
          public void onResult(int code, String msg, List<V2NIMUser> v2NIMUsers) {
            if (v2NIMUsers != null) {
              for (V2NIMUser user : v2NIMUsers) {
                if (user != null) {
                  userModel.setName(user.getName());
                  saveUserModel();
                }
              }
            }
          }
        });
  }

  /** 自动登录（使用本地保存的用户信息） */
  public void autoLogin(NECallback<Void> callback) {
    UserModel loginInfo = getUserModel();
    if (loginInfo != null
        && !TextUtils.isEmpty(loginInfo.getAccount())
        && !TextUtils.isEmpty(loginInfo.getToken())) {
      ALog.i(TAG, "Auto login with saved credentials");
      login(new LoginInfo(loginInfo.getAccount(), loginInfo.getToken()), callback);
    } else {
      ALog.i(TAG, "No saved credentials found for auto login");
      if (callback != null) {
        callback.onError(-1, "No saved credentials");
      }
    }
  }

  public void updateUserInfo(LoginInfo userModel, String avatar) {
    V2NIMUserUpdateParams params =
        V2NIMUserUpdateParams.V2NIMUserUpdateParamsBuilder.builder().withAvatar(avatar).build();

    NIMClient.getService(V2NIMUserService.class)
        .updateSelfUserProfile(
            params,
            new V2NIMSuccessCallback<Void>() {
              @Override
              public void onSuccess(Void unused) {
                ALog.i(TAG, "updateUserInfo success");
              }
            },
            new V2NIMFailureCallback() {
              @Override
              public void onFailure(V2NIMError error) {
                ALog.e(
                    TAG,
                    "updateUserInfo failed code = "
                        + error.getCode()
                        + ", msg = "
                        + error.getDesc());
              }
            });
  }

  public void logout() {
    ALog.e(TAG, "logout");
    userModel = null;
    NIMClient.getService(V2NIMLoginService.class)
        .logout(
            new V2NIMSuccessCallback<Void>() {
              @Override
              public void onSuccess(Void unused) {
                ALog.i(TAG, "logout success");
              }
            },
            new V2NIMFailureCallback() {
              @Override
              public void onFailure(V2NIMError error) {
                ALog.e(
                    TAG, "logout failed code = " + error.getCode() + ", msg = " + error.getDesc());
              }
            });
    SPUtils.getInstance(PER_DATA).put(PER_USER_MODEL, "", true);
  }

  /** 处理被踢下线，退出所有Activity并跳转到登录页 */
  private void handleLogout() {
    ALog.e(TAG, "handleLogout - User kicked off, clearing data and navigating to login");

    // 清理登录状态
    userModel = null;
    // 清理本地存储的用户信息
    SPUtils.getInstance(PER_DATA).put(PER_USER_MODEL, "", true);

    // 获取Application Context
    Context context = DemoApplication.getContext();
    if (context == null) {
      ALog.e(TAG, "Context is null, cannot handle logout");
      return;
    }

    // 先销毁所有Activity
    try {
      ActivityManager activityManager =
          (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
      if (activityManager != null) {
        // 获取当前运行的任务列表
        List<ActivityManager.AppTask> tasks = activityManager.getAppTasks();
        for (ActivityManager.AppTask task : tasks) {
          task.finishAndRemoveTask();
        }
      }
    } catch (Exception e) {
      ALog.e(TAG, "Failed to finish all activities: " + e.getMessage());
    }

    // 创建跳转到登录页的Intent
    Intent intent = new Intent(context, LoginActivity.class);
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK);
    intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);

    // 启动登录页
    context.startActivity(intent);
  }
}
