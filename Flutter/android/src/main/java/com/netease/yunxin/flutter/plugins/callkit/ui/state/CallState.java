// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.flutter.plugins.callkit.ui.state;

import androidx.annotation.NonNull;
import com.netease.yunxin.flutter.plugins.callkit.ui.view.incomingfloatwindow.IncomingFloatView;
import com.netease.yunxin.kit.call.p2p.model.NECallType;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class CallState {
  /** Pending banner action set before notifyEvent so re-attached engine can replay it. */
  public static final int BANNER_ACTION_NONE = 0;
  public static final int BANNER_ACTION_ACCEPT = 1;
  public static final int BANNER_ACTION_REJECT = 2;
  public volatile int pendingBannerAction = BANNER_ACTION_NONE;

  public User mSelfUser = new User();
  public ArrayList<User> mRemoteUserList = new ArrayList<User>();
  public int mMediaType = NECallType.AUDIO;
  public int mStartTime = 0;
  public Map mResourceMap = new HashMap() {{
    put("k_0000002", "邀请你进行语音通话");
    put("k_0000002_1", "邀请你进行视频通话");
  }};
  public Boolean mIsMicrophoneMute = false;
  public Boolean mIsCameraOpen = false;
  public IncomingFloatView mIncomingFloatView;

  private CallState() {}

  public static CallState getInstance() {
    return NECallStateHolder.instance;
  }

  @NonNull
  @Override
  public String toString() {
    return "NECallState:{"
        + "mSelfUser: "
        + mSelfUser.toString()
        + ", mRemoteUser: "
        + mRemoteUserList
        + ", mMediaType: "
        + mMediaType
        + ", mStartTime: "
        + mStartTime
        + ", mIsMicrophoneMute"
        + mIsMicrophoneMute
        + ", mIsCameraOpen"
        + mIsCameraOpen
        + "}";
  }

  private static class NECallStateHolder {
    private static CallState instance = new CallState();
  }

  public enum CallStatus {
    None,
    Waiting,
    Accept,
  }

  public enum CallRole {
    None,
    Caller,
    Called,
  }
}
