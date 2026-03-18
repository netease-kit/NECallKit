// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.apitest;

import com.google.gson.JsonDeserializationContext;
import com.google.gson.JsonElement;
import com.google.gson.JsonParseException;
import com.google.gson.JsonSerializationContext;
import com.netease.yunxin.kit.integrationtest.Hawk;
import com.netease.yunxin.kit.integrationtest.base.BaseParseAdapter;
import java.lang.reflect.Type;

public class CallKitParseAdapter<T> extends BaseParseAdapter<T> {

  @Override
  @SuppressWarnings("unchecked")
  public T deserialize(JsonElement json, Type typeOfT, JsonDeserializationContext context)
      throws JsonParseException {
    //            try {
    if (typeOfT.getTypeName().contains("JoinChannelCallBack")) {
      return (T) DataFactory.getInstance().joinChannelCallBack;
    } else if (typeOfT.getTypeName().contains("RequestCallback")) {
      return (T) DataFactory.getInstance().callback;
    } else if (typeOfT.getTypeName().contains("NERTCCallingDelegate")) {
      Hawk.getInstance().putListener(DataFactory.getInstance().nertcCallingDelegate);
      return (T) DataFactory.getInstance().nertcCallingDelegate;
    } else if (typeOfT.getTypeName().contains("NECallEngineDelegate")) {
      Hawk.getInstance().putListener(DataFactory.getInstance().callEngineDelegate);
      return (T) DataFactory.getInstance().callEngineDelegate;
    } else if (typeOfT.getTypeName().contains("NERecordProvider")) {
      return (T) DataFactory.getInstance().recordProvider;
    } else if (typeOfT.getTypeName().contains("NEResultObserver")) {
      return (T) DataFactory.getInstance().resultObserver;
    }
    //接口对创建meetingItem
    //                else if (typeOfT.getTypeName().contains("NEMeetingItem"))
    //                    return context.deserialize(json, Class.forName("com.netease.meetinglib.impl.model.MeetingItemImpl"));
    //            } catch (ClassNotFoundException cnfe) {
    //                throw new JsonParseException("Unknown element type");
    //            }
    return null;
  }

  @Override
  public JsonElement serialize(Object src, Type typeOfSrc, JsonSerializationContext context) {
    //            if (src instanceof NEMeetingItem)
    //                return context.serialize(src, src.getClass());
    return null;
  }
}
