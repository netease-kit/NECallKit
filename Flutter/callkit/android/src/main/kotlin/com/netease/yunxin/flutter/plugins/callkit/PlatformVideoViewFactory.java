// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.flutter.plugins.callkit;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.netease.yunxin.kit.alog.ALog;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import java.util.HashMap;
import java.util.Map;

public class PlatformVideoViewFactory extends PlatformViewFactory {
  private static final String TAG = "PlatformVideoViewFactory";
  public static final String SIGN = "callkit_video_view";

  private final BinaryMessenger mMessenger;
  public static Map<Integer, PlatformVideoView> mVideoViewMap;

  PlatformVideoViewFactory(BinaryMessenger messenger) {
    super(StandardMessageCodec.INSTANCE);
    this.mMessenger = messenger;
    mVideoViewMap = new HashMap<>();
  }

  @NonNull
  @Override
  public PlatformView create(Context context, int viewId, @Nullable Object args) {
    ALog.i(TAG, "create: viewId = " + viewId);
    PlatformVideoView platformVideoView = mVideoViewMap.get(viewId);
    if (platformVideoView == null) {
      platformVideoView = new PlatformVideoView(context, viewId, mMessenger);
      mVideoViewMap.put(viewId, platformVideoView);
    }
    return platformVideoView;
  }
}
