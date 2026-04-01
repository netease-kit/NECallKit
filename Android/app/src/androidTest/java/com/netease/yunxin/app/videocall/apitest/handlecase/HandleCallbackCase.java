// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.apitest.handlecase;

import android.util.Log;
import com.netease.yunxin.app.videocall.apitest.DataFactory;
import com.netease.yunxin.kit.integrationtest.base.AbsHandleIntegratedEvent;
import com.netease.yunxin.kit.integrationtest.model.TestItem;

//占位过滤操作
public class HandleCallbackCase extends AbsHandleIntegratedEvent<TestItem> {
  @Override
  public boolean handle(TestItem testItem) throws Exception {
    super.handle(testItem);
    Log.d("=======>", "start");
    boolean res = false;
    switch (methodName) {
      case "onRecordSend":
        DataFactory.getInstance().callbackMap.put("onRecordSend", testItem.getCaseId());
        res = true;
        break;
      case "onVideoAvailable":
        DataFactory.getInstance().callbackMap.put("onVideoAvailable", testItem.getCaseId());
        res = true;
        break;
      case "onCallConnected":
        DataFactory.getInstance().callbackMap.put("onCallConnected", testItem.getCaseId());
        res = true;
        break;
      case "onReceiveInvited":
        DataFactory.getInstance().callbackMap.put("onReceiveInvited", testItem.getCaseId());
        res = true;
        break;
      case "onInvited":
        DataFactory.getInstance().callbackMap.put("onInvited", testItem.getCaseId());
        res = true;
        break;
      case "onAudioAvailable":
        DataFactory.getInstance().callbackMap.put("onAudioAvailable", testItem.getCaseId());
        res = true;
        break;
      case "onFirstVideoFrameDecoded":
        DataFactory.getInstance().callbackMap.put("onFirstVideoFrameDecoded", testItem.getCaseId());
        res = true;
        break;
      case "onCallTypeChange":
        DataFactory.getInstance().callbackMap.put("onCallTypeChange", testItem.getCaseId());
        res = true;
        break;
      case "onCancelByUserId":
        DataFactory.getInstance().callbackMap.put("onCancelByUserId", testItem.getCaseId());
        res = true;
        break;
      case "onUserEnter":
        DataFactory.getInstance().callbackMap.put("onUserEnter", testItem.getCaseId());
        res = true;
        break;
      case "onCallEnd":
        DataFactory.getInstance().callbackMap.put("onCallEnd", testItem.getCaseId());
        res = true;
        break;
      case "onRejectByUserId":
        DataFactory.getInstance().callbackMap.put("onRejectByUserId", testItem.getCaseId());
        res = true;
        break;
      case "onCameraAvailable":
        DataFactory.getInstance().callbackMap.put("onCameraAvailable", testItem.getCaseId());
        res = true;
        break;
      case "onVideoMuted":
        DataFactory.getInstance().callbackMap.put("onVideoMuted", testItem.getCaseId());
        res = true;
        break;
      case "onAudioMuted":
        DataFactory.getInstance().callbackMap.put("onAudioMuted", testItem.getCaseId());
        res = true;
        break;
      case "onJoinChannel":
        DataFactory.getInstance().callbackMap.put("onJoinChannel", testItem.getCaseId());
        res = true;
        break;
      case "onUserBusy":
        DataFactory.getInstance().callbackMap.put("onUserBusy", testItem.getCaseId());
        res = true;
        break;
      case "timeOut":
        DataFactory.getInstance().callbackMap.put("timeOut", testItem.getCaseId());
        res = true;
        break;
      default:
        break;
    }
    return res;
  }
}
