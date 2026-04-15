// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.flutter.plugins.callkit;

import android.content.Context;
import android.view.View;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.netease.lava.nertc.sdk.NERtcConstants;
import com.netease.lava.nertc.sdk.video.NERtcTextureView;
import com.netease.yunxin.kit.alog.ALog;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class PlatformVideoView implements PlatformView, MethodChannel.MethodCallHandler {
  private static final String TAG = "PlatformVideoView";

  private NERtcTextureView mVideoView;
  private Context mContext;
  private int mViewId;
  private MethodChannel mChannel;
  private BinaryMessenger mMessenger;

  public PlatformVideoView(Context context, int id, BinaryMessenger messenger) {
    super();
    mContext = context;
    mViewId = id;
    mMessenger = messenger;
    mVideoView = new NERtcTextureView(context);
    mVideoView.setScalingType(NERtcConstants.VideoScalingType.SCALE_ASPECT_BALANCED);
    // 确保视图可见且可以接收触摸事件
    mVideoView.setVisibility(View.VISIBLE);
    mVideoView.setClickable(false);
    mVideoView.setFocusable(false);
    mChannel = new MethodChannel(mMessenger, "ne_call_kit/video_view_" + mViewId);
    mChannel.setMethodCallHandler(this);
  }

  /** 获取视频视图，供 CallKitPlatforms 使用 */
  public NERtcTextureView getVideoView() {
    return mVideoView;
  }

  @Nullable
  @Override
  public View getView() {
    return mVideoView;
  }

  @Override
  public void dispose() {}

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    ALog.i(
        TAG,
        "PlatformVideoView( "
            + mViewId
            + ")onMethodCall -> method:"
            + call.method
            + ", arguments:"
            + call.arguments);
    String method = call.method;
    switch (method) {
      case "destroyVideoView":
        destroyVideoView();
        break;
      default:
        break;
    }
  }

  private void destroyVideoView() {
    ALog.i(
        TAG,
        "destroyVideoView size = "
            + PlatformVideoViewFactory.mVideoViewMap.size()
            + ", viewId:"
            + mViewId);
    PlatformVideoViewFactory.mVideoViewMap.remove(mViewId);
  }
}
