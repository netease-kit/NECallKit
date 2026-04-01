// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.base;

import android.text.TextUtils;
import android.util.Log;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.netease.yunxin.kit.integrationtest.model.TestItem;
import java.lang.reflect.Method;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public final class TestHelper {
  private static final Map<String, MethodInfo> methodMap = new HashMap<>();

  public static void registerClass(Class<?>... classes) {
    for (Class<?> clazz : classes) {
      ClassRegister item = clazz.getDeclaredAnnotation(ClassRegister.class);
      if (item == null) {
        System.out.println(
            "Class# "
                + clazz.getCanonicalName()
                + " can't be registered without ClassRegister Annotation.");
        continue;
      }
      String className = item.value();
      if (TextUtils.isEmpty(className)) {
        className = clazz.getCanonicalName();
      }

      Method[] methods = clazz.getDeclaredMethods();
      for (Method method : methods) {
        if (method.isAnnotationPresent(MethodExclude.class)) {
          continue;
        }

        MethodOtherName otherName = method.getDeclaredAnnotation(MethodOtherName.class);
        String name;
        if (otherName != null) {
          name = otherName.value();
        } else {
          name = method.getName();
        }
        if (methodMap.containsKey(name)) {
          System.out.println(
              "Method# " + name + " had been registered. MethodInfo is " + methodMap.get(name));
          continue;
        }

        methodMap.put(name, new MethodInfo(className, method));
      }
    }
  }

  public static boolean handleMethod(Object obj, TestItem item) {
    if (item == null) {
      return false;
    }
    Log.e("!!!!!!!", item.getMethodName() + " start");
    boolean result = false;
    if (methodMap.containsKey(item.getMethodName())) {
      MethodInfo methodInfo = methodMap.get(item.getMethodName());
      if (methodInfo != null) {
        methodInfo.execute(obj, parseParams(methodInfo.method, item.getParams()));
        result = true;
      }
    }
    Log.e("!!!!!!!", item.getMethodName() + " end");
    return result;
  }

  private static List<Object> parseParams(Method method, List<JsonObject> params) {
    Log.e("!!!!!!!", "parseParams start");
    if (params == null || params.isEmpty()) {
      return new ArrayList<>();
    }
    List<Object> paramObjList = new ArrayList<>(params.size());

    try {
      Type[] genericParameterTypes = method.getGenericParameterTypes();
      for (int i = 0; i < params.size(); i++) {
        JsonObject object = params.get(i);
        Object item = new Gson().fromJson(object.get("").getAsString(), genericParameterTypes[i]);
        paramObjList.add(item);
      }
    } catch (Exception exception) {
      exception.printStackTrace();
    }
    Log.e("!!!!!!!", "parseParams end");
    return paramObjList;
  }

  public static void releaseAll() {
    methodMap.clear();
  }
}
