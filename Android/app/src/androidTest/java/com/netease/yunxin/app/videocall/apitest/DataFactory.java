// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.apitest;

import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.util.Entry;
import com.netease.nimlib.sdk.v2.avsignalling.model.V2NIMSignallingRoomInfo;
import com.netease.yunxin.kit.call.NEResultObserver;
import com.netease.yunxin.kit.call.p2p.model.NECallEndInfo;
import com.netease.yunxin.kit.call.p2p.model.NECallEngineDelegate;
import com.netease.yunxin.kit.call.p2p.model.NECallInfo;
import com.netease.yunxin.kit.call.p2p.model.NECallTypeChangeInfo;
import com.netease.yunxin.kit.call.p2p.model.NEInviteInfo;
import com.netease.yunxin.kit.call.p2p.model.NERecordProvider;
import com.netease.yunxin.kit.integrationtest.Hawk;
import com.netease.yunxin.nertc.nertcvideocall.bean.CommonResult;
import com.netease.yunxin.nertc.nertcvideocall.bean.InvitedInfo;
import com.netease.yunxin.nertc.nertcvideocall.model.JoinChannelCallBack;
import com.netease.yunxin.nertc.nertcvideocall.model.NERTCCallingDelegate;
import com.netease.yunxin.nertc.nertcvideocall.model.NERTCVideoCall;
import com.netease.yunxin.nertc.nertcvideocall.model.impl.NERtcCallbackExTemp;
import com.netease.yunxin.nertc.nertcvideocall.model.impl.NERtcCallbackProxyMgr;
import java.util.HashMap;
import java.util.Map;

public class DataFactory {

  private static final DataFactory instance = new DataFactory();

  private DataFactory() {}

  public static DataFactory getInstance() {
    return instance;
  }

  //静态参数成员
  public final JoinChannelCallBack joinChannelCallBack =
      new JoinChannelCallBack() {

        @Override
        public void onJoinChannel(V2NIMSignallingRoomInfo roomInfo) {
          Hawk.getInstance().reportWithCurrentCaseId(0, "onJoinChannel", roomInfo);
        }

        @Override
        public void onJoinFail(String msg, int code) {
          Hawk.getInstance().reportWithCurrentCaseId(code, msg, null);
        }
      };

  public final RequestCallback callback =
      new RequestCallback() {

        @Override
        public void onSuccess(Object param) {
          Hawk.getInstance().reportWithCurrentCaseId(0, "onSuccess", param);
        }

        @Override
        public void onFailed(int code) {
          Hawk.getInstance().reportWithCurrentCaseId(code, "onFailed", null);
        }

        @Override
        public void onException(Throwable exception) {
          Hawk.getInstance().reportWithCurrentCaseId(-1, exception.getMessage(), null);
        }
      };

  public final Map<String, String> callbackMap = new HashMap<>();
  public final NERTCCallingDelegate nertcCallingDelegate =
      new NERTCCallingDelegate() {
        @Override
        public void onError(int errorCode, String errorMsg, boolean needFinish) {
          Hawk.getInstance()
              .reportWithCaseId(callbackMap.get("onError"), errorCode, errorMsg, needFinish);
        }

        @Override
        public void onInvited(InvitedInfo invitedInfo) {
          Hawk.getInstance()
              .reportWithCaseId(callbackMap.get("onInvited"), 0, "success", invitedInfo);
        }

        @Override
        public void onUserEnter(String userId) {
          Hawk.getInstance().reportWithCaseId(callbackMap.get("onUserEnter"), 0, "success", userId);
        }

        @Override
        public void onCallEnd(String userId) {
          Hawk.getInstance().reportWithCaseId(callbackMap.get("onCallEnd"), 0, "success", userId);
        }

        @Override
        public void onUserLeave(String userId) {
          Hawk.getInstance().reportWithCaseId(callbackMap.get("onUserLeave"), 0, "success", userId);
        }

        @Override
        public void onUserDisconnect(String userId) {
          Hawk.getInstance()
              .reportWithCaseId(callbackMap.get("onUserDisconnect"), 0, "success", userId);
        }

        @Override
        public void onRejectByUserId(String userId) {
          Hawk.getInstance()
              .reportWithCaseId(callbackMap.get("onRejectByUserId"), 0, "success", userId);
        }

        @Override
        public void onUserBusy(String userId) {
          Hawk.getInstance().reportWithCaseId(callbackMap.get("onUserBusy"), 0, "success", userId);
        }

        @Override
        public void onCancelByUserId(String userId) {
          Hawk.getInstance()
              .reportWithCaseId(callbackMap.get("onCancelByUserId"), 0, "success", userId);
        }

        @Override
        public void onCameraAvailable(String userId, boolean isVideoAvailable) {
          Hawk.getInstance()
              .reportWithCaseId(
                  callbackMap.get("onCameraAvailable"), 0, "success", isVideoAvailable);
        }

        @Override
        public void onVideoMuted(String userId, boolean isMuted) {
          Hawk.getInstance()
              .reportWithCaseId(callbackMap.get("onVideoMuted"), 0, "success", isMuted);
        }

        @Override
        public void onAudioMuted(String userId, boolean isMuted) {
          Hawk.getInstance()
              .reportWithCaseId(callbackMap.get("onAudioMuted"), 0, "success", isMuted);
        }

        @Override
        public void onJoinChannel(String accId, long uid, String channelName, long rtcChannelId) {
          //            Hawk.getInstance().reportInListener(0, "onJoinChannel", channelName, nertcCallingDelegate);
          Hawk.getInstance().reportWithCaseId(callbackMap.get("onJoinChannel"), 0, "success", null);
        }

        @Override
        public void onAudioAvailable(String userId, boolean isAudioAvailable) {
          Hawk.getInstance()
              .reportWithCaseId(
                  callbackMap.get("onAudioAvailable"), 0, "success", isAudioAvailable);
        }

        @Override
        public void onDisconnect(int res) {}

        @Override
        public void onUserNetworkQuality(Entry<String, Integer>[] stats) {}

        @Override
        public void onCallTypeChange(NECallTypeChangeInfo info) {
          Hawk.getInstance()
              .reportWithCaseId(callbackMap.get("onCallTypeChange"), 0, "success", info);
        }

        @Override
        public void timeOut() {
          Hawk.getInstance().reportWithCaseId(callbackMap.get("timeOut"), 0, "success", null);
        }

        @Override
        public void onFirstVideoFrameDecoded(String userId, int width, int height) {
          Hawk.getInstance()
              .reportWithCaseId(callbackMap.get("onFirstVideoFrameDecoded"), 0, "success", null);
        }

        @Override
        public void onLocalAction(int actionId, int resultCode) {}
      };

  public final NEResultObserver resultObserver =
      result -> {
        if (result instanceof CommonResult<?>) {
          CommonResult<?> commonResult = (CommonResult<?>) result;
          Hawk.getInstance()
              .reportWithCurrentCaseId(commonResult.code, "onResult", commonResult.data);
        } else {
          Hawk.getInstance().reportWithCurrentCaseId(-1, "onResult", null);
        }
      };

  public final NERecordProvider recordProvider =
      record ->
          Hawk.getInstance()
              .reportWithCaseId(callbackMap.get("onRecordSend"), 0, "success", record);

  public final NECallEngineDelegate callEngineDelegate =
      new NECallEngineDelegate() {
        @Override
        public void onReceiveInvited(NEInviteInfo info) {
          Hawk.getInstance()
              .reportWithCaseId(callbackMap.get("onReceiveInvited"), 0, "success", info);
        }

        @Override
        public void onCallConnected(NECallInfo info) {
          Hawk.getInstance()
              .reportWithCaseId(callbackMap.get("onCallConnected"), 0, "success", info);
        }

        @Override
        public void onCallTypeChange(NECallTypeChangeInfo info) {
          Hawk.getInstance()
              .reportWithCaseId(callbackMap.get("onCallTypeChange"), 0, "success", info);
        }

        @Override
        public void onCallEnd(NECallEndInfo info) {
          Hawk.getInstance().reportWithCaseId(callbackMap.get("onCallEnd"), 0, "success", info);
        }

        @Override
        public void onVideoAvailable(String userId, boolean available) {
          Map<String, Object> map = new HashMap<>();
          map.put("userId", userId);
          map.put("available", available);
          Hawk.getInstance()
              .reportWithCaseId(callbackMap.get("onVideoAvailable"), 0, "success", map);
        }

        @Override
        public void onVideoMuted(String userId, boolean mute) {
          Map<String, Object> map = new HashMap<>();
          map.put("userId", userId);
          map.put("muted", mute);
          Hawk.getInstance().reportWithCaseId(callbackMap.get("onVideoMuted"), 0, "success", map);
        }

        @Override
        public void onAudioMuted(String userId, boolean mute) {
          Map<String, Object> map = new HashMap<>();
          map.put("userId", userId);
          map.put("muted", mute);
          Hawk.getInstance().reportWithCaseId(callbackMap.get("onAudioMuted"), 0, "success", map);
        }
      };

  public final NERtcCallbackExTemp callbackExTemp =
      new NERtcCallbackExTemp() {
        @Override
        public void onJoinChannel(int i, long l, long l1, long l2) {
          super.onJoinChannel(i, l, l1, l2);
          Map<String, Object> data = new HashMap<>();
          data.put("result", i);
          data.put("rtcChannelId", l);
          data.put("time", l1);
          data.put("uid", l2);

          Hawk.getInstance()
              .reportWithCaseId(callbackMap.get("onRtcJoinChannel"), 0, "success", data);
        }
      };

  {
    NERtcCallbackProxyMgr.getInstance()
        .addCallback(
            new NERtcCallbackExTemp() {
              @Override
              public void onFirstAudioFrameDecoded(long l) {
                super.onFirstAudioFrameDecoded(l);
                NERTCVideoCall.sharedInstance().getAccIdByRtcUid(l);
              }
            });
  }
}
