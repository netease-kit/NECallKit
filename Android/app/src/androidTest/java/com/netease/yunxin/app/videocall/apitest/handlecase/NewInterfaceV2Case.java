// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.apitest.handlecase;

import android.text.TextUtils;
import android.util.Log;
import androidx.test.core.app.ApplicationProvider;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.reflect.TypeToken;
import com.netease.yunxin.kit.call.p2p.NECallEngine;
import com.netease.yunxin.kit.call.p2p.model.NECallConfig;
import com.netease.yunxin.kit.call.p2p.model.NECallPushConfig;
import com.netease.yunxin.kit.call.p2p.model.NESetupConfig;
import com.netease.yunxin.kit.call.p2p.param.NECallParam;
import com.netease.yunxin.kit.call.p2p.param.NEHangupParam;
import com.netease.yunxin.kit.call.p2p.param.NESwitchParam;
import com.netease.yunxin.kit.integrationtest.Hawk;
import com.netease.yunxin.kit.integrationtest.base.AbsHandleIntegratedEvent;
import com.netease.yunxin.kit.integrationtest.model.TestItem;
import java.lang.reflect.Type;
import java.util.Map;

public class NewInterfaceV2Case extends AbsHandleIntegratedEvent<TestItem> {

  @Override
  public boolean handle(TestItem testItem) throws Exception {
    super.handle(testItem);
    Log.d(
        "NewInterfaceV2Case =======>",
        "start:" + methodName + ", className:" + testItem.getClassName());
    boolean res = false;
    if (!TextUtils.equals(testItem.getClassName(), "NECallEngine")) {
      return res;
    }

    JsonObject paramObj = new JsonObject();
    if (testItem.getParams() != null
        && !testItem.getParams().isEmpty()
        && testItem.getParams().get(0).get("param") != null) {
      Object tempObj = testItem.getParams().get(0).get("param");
      if (tempObj instanceof JsonObject) {
        paramObj = testItem.getParams().get(0).get("param").getAsJsonObject();
      }
    }
    if (TextUtils.equals(methodName, "setup")) {
      if (paramObj == null) {
        Hawk.getInstance().reportWithCurrentCaseId(-1, "param is error", null);
        return true;
      }
      NESetupConfig.Builder builder =
          new NESetupConfig.Builder(paramObj.get("appKey").getAsString());
      if (paramObj.get("enableJoinRtcWhenCall") != null) {
        builder.enableJoinRtcWhenCall(paramObj.get("enableJoinRtcWhenCall").getAsBoolean());
      }
      if (paramObj.get("currentUserRtcUid") != null) {
        builder.currentUserRtcUid(paramObj.get("currentUserRtcUid").getAsLong());
      }
      if (paramObj.get("initRtcMode") != null) {
        builder.initRtcMode(paramObj.get("initRtcMode").getAsInt());
      }
      if (paramObj.get("enableAutoJoinSignalChannel") != null) {
        builder.enableAutoJoinSignalChannel(
            paramObj.get("enableAutoJoinSignalChannel").getAsBoolean());
      }
      NESetupConfig setupConfig = builder.build();
      Log.d("NewInterfaceV2Case =======>", "start:" + methodName + ", NESetupConfig" + setupConfig);
      NECallEngine.sharedInstance().setup(ApplicationProvider.getApplicationContext(), setupConfig);
      Hawk.getInstance().reportWithCurrentCaseId(0, "setup", null);
      res = true;
    } else if (TextUtils.equals(methodName, "call")) {
      NECallParam.Builder builder = new NECallParam.Builder(paramObj.get("accId").getAsString());
      if (paramObj.get("callType") != null) {
        builder.callType(paramObj.get("callType").getAsInt());
      }
      if (paramObj.get("extraInfo") != null) {
        builder.extraInfo(paramObj.get("extraInfo").getAsString());
      }
      if (paramObj.get("rtcChannelName") != null) {
        builder.rtcChannelName(paramObj.get("rtcChannelName").getAsString());
      }
      if (paramObj.get("globalExtraCopy") != null) {
        builder.globalExtraCopy(paramObj.get("globalExtraCopy").getAsString());
      }
      if (paramObj.get("pushConfig") != null) {
        JsonObject pushConfigObj = paramObj.get("pushConfig").getAsJsonObject();
        boolean needPush = true;
        if (pushConfigObj.get("needPush") != null) {
          needPush = pushConfigObj.get("needPush").getAsBoolean();
        }
        String title = null;
        if (pushConfigObj.get("pushTitle") != null) {
          title = pushConfigObj.get("pushTitle").getAsString();
        }
        String content = null;
        if (pushConfigObj.get("pushContent") != null) {
          content = pushConfigObj.get("pushContent").getAsString();
        }
        Map<String, Object> payload = null;
        if (pushConfigObj.get("pushPayload") != null) {
          JsonObject payloadObj = pushConfigObj.get("pushPayload").getAsJsonObject();
          Gson gson = new Gson();
          Type type = new TypeToken<Map<String, Object>>() {}.getType();
          payload = gson.fromJson(payloadObj, type);
        }
        NECallPushConfig config = new NECallPushConfig(needPush, title, content, payload);
        builder.pushConfig(config);
      }
      NECallEngine.sharedInstance()
          .call(
              builder.build(),
              result ->
                  Hawk.getInstance().reportWithCurrentCaseId(result.code, "call", result.data));
      res = true;
    } else if (TextUtils.equals(methodName, "accept")) {
      NECallEngine.sharedInstance()
          .accept(
              result ->
                  Hawk.getInstance().reportWithCurrentCaseId(result.code, "accept", result.data));
      res = true;
    } else if (TextUtils.equals(methodName, "hangup")) {
      String extraInfo = null;
      if (paramObj.get("extraString") != null) {
        extraInfo = paramObj.get("extraString").getAsString();
      }
      String channelId = null;
      if (paramObj.get("channelId") != null) {
        channelId = paramObj.get("channelId").getAsString();
      }
      NECallEngine.sharedInstance()
          .hangup(
              new NEHangupParam(channelId, extraInfo),
              result ->
                  Hawk.getInstance().reportWithCurrentCaseId(result.code, "hangup", result.data));
      res = true;
    } else if (TextUtils.equals(methodName, "switchCallType")) {
      int callType = paramObj.get("callType").getAsInt();
      int state = paramObj.get("state").getAsInt();
      NECallEngine.sharedInstance()
          .switchCallType(
              new NESwitchParam(callType, state),
              result ->
                  Hawk.getInstance()
                      .reportWithCurrentCaseId(result.code, "switchCallType", result.data));
      res = true;
    } else if (TextUtils.equals(methodName, "setCallConfig")) {
      NECallConfig callConfig = NECallEngine.sharedInstance().getCallConfig();
      boolean enableOffline;
      if (paramObj.get("enableOffline") != null) {
        enableOffline = paramObj.get("enableOffline").getAsBoolean();
      } else {
        enableOffline = callConfig.enableOffline;
      }
      boolean enableSwitchVideoConfirm;
      if (paramObj.get("enableSwitchVideoConfirm") != null) {
        enableSwitchVideoConfirm = paramObj.get("enableSwitchVideoConfirm").getAsBoolean();
      } else {
        enableSwitchVideoConfirm = callConfig.enableSwitchVideoConfirm;
      }
      boolean enableSwitchAudioConfirm;
      if (paramObj.get("enableSwitchAudioConfirm") != null) {
        enableSwitchAudioConfirm = paramObj.get("enableSwitchAudioConfirm").getAsBoolean();
      } else {
        enableSwitchAudioConfirm = callConfig.enableSwitchAudioConfirm;
      }
      NECallEngine.sharedInstance()
          .setCallConfig(
              new NECallConfig(enableOffline, enableSwitchVideoConfirm, enableSwitchAudioConfirm));
      Hawk.getInstance().reportWithCurrentCaseId(0, "setCallConfig", null);
      res = true;
    }
    return res;
  }
}
