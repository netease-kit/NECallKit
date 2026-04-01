// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.flutter.plugins.callkit.ui;

import androidx.activity.ComponentActivity;
import androidx.activity.OnBackPressedCallback;
import androidx.annotation.NonNull;
import com.netease.yunxin.flutter.plugins.callkit.ui.event.EventManager;
import com.netease.yunxin.flutter.plugins.callkit.ui.state.CallState;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.CallUILog;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.Constants;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.WakeLock;
import com.netease.yunxin.flutter.plugins.callkit.ui.view.incomingfloatwindow.IncomingFloatView;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import java.util.Map;

public class CallKitUIPlugin implements FlutterPlugin, ActivityAware, EventManager.INotifyEvent {
  public static final String TAG = "CallKitUIPlugin";

  private static boolean sIncomingBannerEnabled = false;

  public static void setIncomingBannerEnabled(boolean enable) {
    sIncomingBannerEnabled = enable;
  }

  public static boolean isIncomingBannerEnabled() {
    return sIncomingBannerEnabled;
  }

  private CallKitUIHandler mCallKitManager;
  private OnBackPressedCallback mBackPressedCallback;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    mCallKitManager = new CallKitUIHandler(flutterPluginBinding);
    registerObserver();
    // Dispatch any banner action that fired while the plugin was unregistered (e.g. Activity
    // was destroyed via the system back button before the user tapped the incoming banner).
    dispatchPendingBannerAction();
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    mCallKitManager.removeMethodChannelHandler();
    unRegisterObserver();
  }

  private void dispatchPendingBannerAction() {
    int action = CallState.getInstance().pendingBannerAction;
    if (action == CallState.BANNER_ACTION_NONE) {
      return;
    }
    CallState.getInstance().pendingBannerAction = CallState.BANNER_ACTION_NONE;
    if (action == CallState.BANNER_ACTION_ACCEPT) {
      mCallKitManager.bannerAcceptTapped();
    } else if (action == CallState.BANNER_ACTION_REJECT) {
      mCallKitManager.bannerRejectTapped();
    }
  }

  private void registerObserver() {
    EventManager.getInstance()
        .registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_GOTO_CALLING_PAGE, this);
    EventManager.getInstance()
        .registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, this);
    EventManager.getInstance()
        .registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_ENABLE_FLOAT_WINDOW, this);
    EventManager.getInstance()
        .registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_CALL, this);
    EventManager.getInstance()
        .registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_GROUP_CALL, this);
    EventManager.getInstance()
        .registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_LOGIN_SUCCESS, this);
    EventManager.getInstance()
        .registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_LOGOUT_SUCCESS, this);
    EventManager.getInstance()
        .registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_ENTER_FOREGROUND, this);
    EventManager.getInstance()
        .registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_ENTER_BACKGROUND, this);
    EventManager.getInstance()
        .registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_BANNER_ACCEPT, this);
    EventManager.getInstance()
        .registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_BANNER_REJECT, this);
  }

  private void unRegisterObserver() {
    EventManager.getInstance().unRegisterEvent(this);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    WakeLock.getInstance().setActivity(binding.getActivity());
    if (binding.getActivity() instanceof ComponentActivity) {
      attachBackPressedCallback((ComponentActivity) binding.getActivity());
    }
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    WakeLock.getInstance().setActivity(null);
    mBackPressedCallback = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    WakeLock.getInstance().setActivity(binding.getActivity());
    if (binding.getActivity() instanceof ComponentActivity) {
      attachBackPressedCallback((ComponentActivity) binding.getActivity());
    }
  }

  @Override
  public void onDetachedFromActivity() {
    WakeLock.getInstance().setActivity(null);
    mBackPressedCallback = null;
  }

  private void attachBackPressedCallback(ComponentActivity activity) {
    // Intercept back press while the incoming banner is showing to prevent the Activity from
    // being destroyed (which would tear down the Flutter engine and lose all Dart state).
    // Instead, move the task to background so the engine stays alive for the accept flow.
    mBackPressedCallback =
        new OnBackPressedCallback(true) {
          @Override
          public void handleOnBackPressed() {
            IncomingFloatView floatView = CallState.getInstance().mIncomingFloatView;
            if (floatView != null && floatView.isShowing()) {
              CallUILog.i(TAG, "back pressed while banner showing, moving task to background");
              activity.moveTaskToBack(true);
              return;
            }
            setEnabled(false);
            activity.getOnBackPressedDispatcher().onBackPressed();
            setEnabled(true);
          }
        };
    activity.getOnBackPressedDispatcher().addCallback(activity, mBackPressedCallback);
  }

  @Override
  public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
    CallUILog.i(TAG, "onNotifyEvent : key : " + key + ", subKey : " + subKey);
    if (!Constants.KEY_CALLKIT_PLUGIN.equals(key)) {
      return;
    }

    if (Constants.SUB_KEY_GOTO_CALLING_PAGE.equals(subKey)) {
      mCallKitManager.backCallingPageFromFloatWindow();
      return;
    }

    if (Constants.SUB_KEY_HANDLE_CALL_RECEIVED.equals(subKey)) {
      mCallKitManager.launchCallingPageFromIncomingBanner();
      return;
    }

    if (Constants.SUB_KEY_ENTER_FOREGROUND.equals(subKey)) {
      mCallKitManager.appEnterForeground();
    }

    if (Constants.SUB_KEY_ENTER_BACKGROUND.equals(subKey)) {
      mCallKitManager.appEnterBackground();
    }

    if (Constants.SUB_KEY_BANNER_ACCEPT.equals(subKey)) {
      CallState.getInstance().pendingBannerAction = CallState.BANNER_ACTION_NONE;
      mCallKitManager.bannerAcceptTapped();
      return;
    }

    if (Constants.SUB_KEY_BANNER_REJECT.equals(subKey)) {
      CallState.getInstance().pendingBannerAction = CallState.BANNER_ACTION_NONE;
      mCallKitManager.bannerRejectTapped();
      return;
    }
  }
}
