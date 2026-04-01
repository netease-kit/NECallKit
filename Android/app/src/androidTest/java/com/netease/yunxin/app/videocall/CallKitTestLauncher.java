// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall;

import androidx.test.core.app.ApplicationProvider;
import androidx.test.ext.junit.rules.ActivityScenarioRule;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import com.netease.yunxin.app.videocall.base.BaseTestUtils;
import com.netease.yunxin.app.videocall.base.TestHelper;
import com.netease.yunxin.app.videocall.callkit.CallKitTestUtils;
import com.netease.yunxin.kit.integrationtest.Hawk;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(AndroidJUnit4.class)
public class CallKitTestLauncher {

  @Rule
  public ActivityScenarioRule<MainActivity> mainRuler =
      new ActivityScenarioRule<>(MainActivity.class);

  @Before
  public void init() {

    Hawk.getInstance().setContext(ApplicationProvider.getApplicationContext());
    //业务线、版本、分支
    Hawk.getInstance().setRequestInfo("callkitUI", BuildConfig.VERSION_NAME);
    Hawk.getInstance().registerHandle(new CallKitTestParser());
  }

  @Test
  public void test() {
    TestHelper.registerClass(
        UITestBaseForCallKit.class, BaseTestUtils.class, CallKitTestUtils.class);
    Hawk.getInstance().start();
    TestHelper.releaseAll();
  }
}
