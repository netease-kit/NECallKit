// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.apitest;

import android.util.Log;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import com.netease.yunxin.kit.integrationtest.utils.DeviceInfoUtil;
import org.junit.Test;
import org.junit.runner.RunWith;

/**
 * Instrumented test, which will execute on an Android device.
 *
 * @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
 */
@RunWith(AndroidJUnit4.class)
public class GetDeviceIdTest {

  @Test
  public void test() {
    String deviceId = (new DeviceInfoUtil()).getDeviceName();
    Log.d("======> running on ", deviceId);
  }
}
