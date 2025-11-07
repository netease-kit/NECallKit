// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.im;

import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.ResponseCode;
import com.netease.nimlib.sdk.v2.V2NIMError;
import com.netease.nimlib.sdk.v2.V2NIMFailureCallback;
import com.netease.nimlib.sdk.v2.V2NIMSuccessCallback;
import com.netease.nimlib.sdk.v2.user.V2NIMUser;
import com.netease.nimlib.sdk.v2.user.V2NIMUserService;
import com.netease.yunxin.kit.call.common.callback.Callback;
import com.netease.yunxin.nertc.nertcvideocall.utils.CallLog;
import java.util.List;

public final class NimUserUtils {
  public static final String TAG = "NimUserWrapper";

  public static void getUserList(List<String> accountIds, Callback<List<V2NIMUser>> callback) {
    CallLog.iApi(TAG, "getUserList accountIds: " + accountIds);
    NIMClient.getService(V2NIMUserService.class)
        .getUserList(
            accountIds,
            new V2NIMSuccessCallback<List<V2NIMUser>>() {
              @Override
              public void onSuccess(List<V2NIMUser> v2NIMUsers) {
                CallLog.i(TAG, "getUserList success");
                if (callback != null) {
                  callback.onResult(ResponseCode.RES_SUCCESS, "", v2NIMUsers);
                }
              }
            },
            new V2NIMFailureCallback() {
              @Override
              public void onFailure(V2NIMError error) {
                CallLog.e(
                    TAG,
                    "getUserList failed code = " + error.getCode() + ", msg = " + error.getDesc());
                if (callback != null) {
                  callback.onResult(error.getCode(), error.getDesc(), null);
                }
              }
            });
  }
}
