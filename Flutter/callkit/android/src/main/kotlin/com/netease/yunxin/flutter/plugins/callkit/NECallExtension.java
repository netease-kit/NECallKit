// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.flutter.plugins.callkit;

import com.netease.lava.nertc.sdk.NERtcAsrCaptionResult;
import com.netease.yunxin.nertc.nertcvideocall.model.NERtcCallExtension;

public class NECallExtension extends NERtcCallExtension {

  private CallKitPlatformCallback callback;

  public NECallExtension(CallKitPlatformCallback callback) {
    this.callback = callback;
  }

  @Override
  protected void onAsrCaptionResult(NERtcAsrCaptionResult[] result, int resultCount) {
    super.onAsrCaptionResult(result, resultCount);
    if (callback != null) {
      callback.onAsrCaptionResult(result, resultCount);
    }
  }

  @Override
  protected void onAsrCaptionStateChanged(int asrState, int code, String message) {
    super.onAsrCaptionStateChanged(asrState, code, message);
    if (callback != null) {
      callback.onAsrCaptionStateChanged(asrState, code, message);
    }
  }

  // 回调接口
  public interface CallKitPlatformCallback {
    void onAsrCaptionResult(NERtcAsrCaptionResult[] result, int resultCount);

    void onAsrCaptionStateChanged(int asrState, int code, String message);
  }
}
