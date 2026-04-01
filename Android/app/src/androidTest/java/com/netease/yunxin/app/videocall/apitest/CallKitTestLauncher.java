// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.apitest;

import android.os.Handler;
import android.os.Looper;
import androidx.test.core.app.ApplicationProvider;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import com.netease.yunxin.app.videocall.BuildConfig;
import com.netease.yunxin.app.videocall.config.AppConfig;
import com.netease.yunxin.kit.integrationtest.Hawk;
import com.netease.yunxin.nertc.nertcvideocall.model.NERTCVideoCall;
import com.netease.yunxin.nertc.nertcvideocall.model.VideoCallOptions;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

/**
 * Instrumented test, which will execute on an Android device.
 *
 * @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
 */
@RunWith(AndroidJUnit4.class)
public class CallKitTestLauncher {

  @Before
  public void init() {
    new Handler(Looper.getMainLooper())
        .post(
            () -> {
              // 注意：操作必须在主进程中进行
              //              NIMClient.getService(AuthService.class).logout();

              VideoCallOptions options = new VideoCallOptions(null);
              options.enableAutoJoinWhenCalled = true;
              NERTCVideoCall.sharedInstance()
                  .setupAppKey(
                      ApplicationProvider.getApplicationContext(), AppConfig.getAppKey(), options);
              NERTCVideoCall.sharedInstance().setTimeOut(119999);
              NERTCVideoCall.sharedInstance().enableSwitchCallTypeConfirm(false, false);
            });
    Hawk.getInstance().setContext(ApplicationProvider.getApplicationContext());
    Hawk.getInstance().setRequestInfo("callkit", BuildConfig.VERSION_NAME);
    Hawk.getInstance().registerClass(new CallKitClassRegister());
    Hawk.getInstance().registerParams(new CallKitParamsRegister());
    Hawk.getInstance().registerHandle(new CallbackManualParser());
    Hawk.getInstance().setInterceptor(new CallKitInterceptor());
  }

  @Test
  public void test() {
    Hawk.getInstance().start();
  }
}
