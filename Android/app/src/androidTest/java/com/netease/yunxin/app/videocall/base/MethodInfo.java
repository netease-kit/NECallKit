// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.base;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.List;

public class MethodInfo {
  public final String className;
  public final Method method;

  public MethodInfo(String className, Method method) {
    this.className = className;
    this.method = method;
  }

  public Object execute(Object obj, List<Object> param) {
    Object result = null;
    try {
      result =
          method.invoke(Modifier.isStatic(method.getModifiers()) ? null : obj, param.toArray());
    } catch (IllegalAccessException | InvocationTargetException e) {
      e.printStackTrace();
    }
    return result;
  }
}
