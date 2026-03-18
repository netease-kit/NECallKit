// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.apitest;

import com.netease.nimlib.sdk.InvocationFuture;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.ResponseCode;
import com.netease.yunxin.kit.integrationtest.intercept.InterceptResultCallback;
import com.netease.yunxin.kit.integrationtest.intercept.ResultInterceptor;
import java.util.concurrent.CountDownLatch;

public class CallKitInterceptor implements ResultInterceptor {

  @Override
  public boolean onIntercept(Object obj, InterceptResultCallback callback) {

    if (obj instanceof InvocationFuture) {
      CountDownLatch latch = new CountDownLatch(1);
      ((InvocationFuture<Object>) obj)
          .setCallback(
              new RequestCallback<Object>() {
                @Override
                public void onSuccess(Object param) {
                  callback.onResult(ResponseCode.RES_SUCCESS, "onSuccess", param);
                  latch.countDown();
                }

                @Override
                public void onFailed(int code) {
                  callback.onResult(code, "onFailed", null);
                  latch.countDown();
                }

                @Override
                public void onException(Throwable exception) {
                  callback.onResult(
                      ResponseCode.RES_EXCEPTION, "onException " + exception.getMessage(), null);
                  latch.countDown();
                }
              });

      //      try {
      //        if (!latch.await(30, TimeUnit.SECONDS)) {
      //          callback.onResult(ResponseCode.RES_ETIMEOUT, "Time out", null);
      //        }
      //      } catch (InterruptedException e) {
      //        e.printStackTrace();
      //      }

    } else {
      //      callback.onResult(ResponseCode.RES_SUCCESS, "onSuccess", obj);
      return false;
    }

    return true;
  }
}
