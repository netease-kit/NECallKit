// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.call.adapter;

import com.netease.nimlib.sdk.auth.LoginInfo;

public interface ClickItemListener {
  void onClick(LoginInfo data);
}
