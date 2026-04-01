// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.apitest;

import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.auth.AuthService;
import com.netease.nimlib.sdk.auth.AuthServiceObserver;
import com.netease.nimlib.sdk.event.EventSubscribeService;
import com.netease.nimlib.sdk.event.EventSubscribeServiceObserver;
import com.netease.nimlib.sdk.friend.FriendService;
import com.netease.nimlib.sdk.friend.FriendServiceObserve;
import com.netease.nimlib.sdk.msg.MsgService;
import com.netease.nimlib.sdk.msg.MsgServiceObserve;
import com.netease.nimlib.sdk.msg.SystemMessageObserver;
import com.netease.nimlib.sdk.msg.SystemMessageService;
import com.netease.nimlib.sdk.nos.NosService;
import com.netease.nimlib.sdk.nos.NosServiceObserve;
import com.netease.nimlib.sdk.passthrough.PassthroughService;
import com.netease.nimlib.sdk.passthrough.PassthroughServiceObserve;
import com.netease.nimlib.sdk.team.TeamService;
import com.netease.nimlib.sdk.team.TeamServiceObserver;
import com.netease.nimlib.sdk.uinfo.UserService;
import com.netease.yunxin.kit.call.group.NEGroupCall;
import com.netease.yunxin.kit.call.p2p.NECallEngine;
import com.netease.yunxin.kit.integrationtest.register.ClassRegister;
import com.netease.yunxin.nertc.nertcvideocall.model.NERTCVideoCall;
import java.util.HashMap;

public class CallKitClassRegister implements ClassRegister {

  /** 类Class映射表 */
  private static HashMap<String, Class<?>> classHashMap =
      new HashMap<String, Class<?>>() {
        {
          // SDK Service
          put("AuthService", AuthService.class);
          put("AuthServiceObserver", AuthServiceObserver.class);
          put("EventSubscribeService", EventSubscribeService.class);
          put("EventSubscribeServiceObserver", EventSubscribeServiceObserver.class);
          put("FriendService", FriendService.class);
          put("FriendServiceObserve", FriendServiceObserve.class);
          put("MsgService", MsgService.class);
          put("MsgServiceObserve", MsgServiceObserve.class);
          put("SystemMessageService", SystemMessageService.class);
          put("SystemMessageObserver", SystemMessageObserver.class);
          put("NosService", NosService.class);
          put("NosServiceObserve", NosServiceObserve.class);
          put("PassthroughService", PassthroughService.class);
          put("PassthroughServiceObserve", PassthroughServiceObserve.class);
          put("TeamService", TeamService.class);
          put("TeamServiceObserver", TeamServiceObserver.class);
          put("UserService", UserService.class);
          put("NERTCVideoCall", NERTCVideoCall.class);
          put("NECallEngine", NECallEngine.class);
          put("NEGroupCall", NEGroupCall.class);
        }
      };

  @Override
  public Class<?> getClass(String name) {
    if (name == null || name.length() == 0) {
      return null;
    }

    int index = name.indexOf("[]");
    if (index < 0) {
      return classHashMap.get(name);
    }

    String className = name.substring(0, index);
    Class<?> aClass = classHashMap.get(className);
    int lastIndex = name.lastIndexOf("[]");
    int count = 1;
    if (lastIndex > index) {
      count = (lastIndex - index + 2) / 2;
    }
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < count; i++) {
      sb.append("[");
    }
    sb.append(getClassDesciptor(aClass));
    String arrayClassName = sb.toString();
    try {
      return Class.forName(arrayClassName);
    } catch (ClassNotFoundException e) {
      e.printStackTrace();
    }
    return null;
  }

  /**
   * 获取类型的描述符
   *
   * @param aClass
   * @return
   */
  private static String getClassDesciptor(Class<?> aClass) {
    if (aClass.equals(boolean.class)) {
      return "Z";
    } else if (aClass.equals(int.class)) {
      return "I";
    } else if (aClass.equals(long.class)) {
      return "J";
    } else if (aClass.equals(float.class)) {
      return "F";
    } else if (aClass.equals(double.class)) {
      return "D";
    } else if (aClass.equals(byte.class)) {
      return "B";
    } else if (aClass.equals(char.class)) {
      return "C";
    } else if (aClass.equals(short.class)) {
      return "S";
    } else {
      return "L" + aClass.getName().replace('.', '/') + ";";
    }
  }

  @Override
  /** 通过类名获取对象 */
  public Object getObject(String name) {

    Class<?> clazz = null;
    if (AuthService.class.getSimpleName().equals(name)) {
      clazz = AuthService.class;
    } else if (FriendService.class.getSimpleName().equals(name)) {
      clazz = FriendService.class;
    } else if (MsgService.class.getSimpleName().equals(name)) {
      clazz = MsgService.class;
    } else if (TeamService.class.getSimpleName().equals(name)) {
      clazz = TeamService.class;
    } else if (UserService.class.getSimpleName().equals(name)) {
      clazz = UserService.class;
    } else if (SystemMessageService.class.getSimpleName().equals(name)) {
      clazz = SystemMessageService.class;
    } else if (PassthroughService.class.getSimpleName().equals(name)) {
      clazz = PassthroughService.class;
    } else if (NosService.class.getSimpleName().equals(name)) {
      clazz = NosService.class;
    } else if (EventSubscribeService.class.getSimpleName().equals(name)) {
      clazz = EventSubscribeService.class;
    } else if (NERTCVideoCall.class.getSimpleName().equals(name)) {
      return NERTCVideoCall.sharedInstance();
    } else if (NECallEngine.class.getSimpleName().equals(name)) {
      return NECallEngine.sharedInstance();
    } else if (NEGroupCall.class.getSimpleName().equals(name)) {
      return NEGroupCall.instance();
    }

    if (clazz != null) {
      return NIMClient.getService(clazz);
    } else {
      return null;
    }
  }
}
