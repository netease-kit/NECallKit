// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.nertc.ui.utils;

import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.alog.ParameterMap;

public class CallUILog {
  private static final String MODULE = "CallKit_UI";

  public static void dApi(String tag, ParameterMap msg) {
    ALog.d(tag, msg.toValue(), MODULE);
  }

  public static void i(String tag, String msg) {
    ALog.i(tag, msg, MODULE);
  }

  public static void d(String tag, String msg) {
    ALog.d(tag, msg, MODULE);
  }

  public static void w(String tag, String msg) {
    ALog.w(tag, msg, MODULE);
  }

  public static void e(String tag, String msg) {
    ALog.e(tag, msg, MODULE);
  }

  public static void e(String tag, String msg, Throwable throwable) {
    ALog.e(tag, msg + ":" + throwable.getMessage(), MODULE);
  }

  public static void flush(boolean isSync) {
    ALog.flush(isSync);
  }
}
