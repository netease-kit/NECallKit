// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall;

import android.content.Context;
import androidx.annotation.NonNull;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.RequestCallbackWrapper;
import com.netease.nimlib.sdk.auth.LoginInfo;
import com.netease.nimlib.sdk.uinfo.UserService;
import com.netease.nimlib.sdk.uinfo.model.NimUserInfo;
import com.netease.yunxin.app.videocall.user.UserCacheManager;
import com.netease.yunxin.nertc.ui.base.UserInfoHelper;
import java.util.Collections;
import java.util.List;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;
import kotlin.jvm.functions.Function2;
import org.jetbrains.annotations.NotNull;

class SelfUserInfoHelper implements UserInfoHelper {
  @Override
  public boolean fetchNickname(
      @NotNull String accId, @NotNull Function1<? super String, Unit> function1) {
    LoginInfo userModel = UserCacheManager.getInstance().getUserModelFromAccId(accId);
    if (userModel != null) {
      function1.invoke(userModel.getAccount());
    } else {
      NIMClient.getService(UserService.class)
          .fetchUserInfo(Collections.singletonList(accId))
          .setCallback(
              new RequestCallbackWrapper<List<NimUserInfo>>() {
                @Override
                public void onResult(int code, List<NimUserInfo> result, Throwable exception) {
                  if (result == null || result.isEmpty()) {
                    function1.invoke(accId);
                    return;
                  }
                  if (result.get(0).getMobile() != null && !result.get(0).getMobile().isEmpty()) {
                    function1.invoke(result.get(0).getMobile());
                  } else if ((result.get(0).getName() != null
                      && !result.get(0).getName().isEmpty())) {
                    function1.invoke(result.get(0).getName());
                  } else {
                    function1.invoke(result.get(0).getAccount());
                  }
                }
              });
    }
    return true;
  }

  @Override
  public boolean fetchAvatar(
      @NonNull Context context,
      @NonNull String accId,
      @NonNull Function2<? super String, ? super Integer, Unit> notify) {
    return false;
  }
}
