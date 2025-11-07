// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.flutter.plugins.callkit.ui.utils;

import android.app.AppOpsManager;
import android.app.NotificationManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import android.text.TextUtils;
import android.util.Log;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;

public class FloatWindowsPermission {
  private static final String TAG = "FloatWindowsPermission";

  // 权限常量定义
  public static final String FLOAT_PERMISSION = "android.permission.SYSTEM_ALERT_WINDOW";
  public static final String BG_START_PERMISSION = "android.permission.SYSTEM_ALERT_WINDOW";
  public static final String CAMERA_PERMISSION = "android.permission.CAMERA";
  public static final String RECORD_AUDIO_PERMISSION = "android.permission.RECORD_AUDIO";

  // 静态 Context 引用，需要在插件初始化时设置
  private static Context sApplicationContext;

  // 各厂商后台弹窗/权限设置页映射
  private static final LinkedHashMap<String, List<String>> BG_POP_HASH_MAP =
      new LinkedHashMap<String, List<String>>() {
        {
          put(
              "XIAOMI",
              Arrays.asList(
                  "com.miui.securitycenter/com.miui.permcenter.permissions.PermissionsEditorActivity",
                  "com.miui.securitycenter/com.miui.appmanager.ApplicationsDetailsActivity",
                  "com.miui.securitycenter"));

          put(
              "HUAWEI",
              Arrays.asList(
                  "com.huawei.systemmanager/.appcontrol.activity.StartupAppControlActivity",
                  "com.huawei.systemmanager"));

          // 荣耀
          put(
              "HONOR",
              Arrays.asList(
                  "com.hihonor.systemmanager/.appcontrol.activity.StartupAppControlActivity",
                  "com.hihonor.systemmanager/.startupmgr.ui.StartupNormalAppListActivity",
                  "com.hihonor.systemmanager"));

          put(
              "VIVO",
              Arrays.asList(
                  // 需要 com.vivo.permission.manage.permission.ACCESS 权限
                  "com.vivo.permissionmanager/.activity.StartBgActivityControlActivity",
                  "com.vivo.permissionmanager/.activity.SoftPermissionDetailActivity",
                  "com.vivo.permissionmanager/.activity.PurviewTabActivity",
                  "com.vivo.permissionmanager",
                  "com.iqoo.secure"));

          put(
              "MEIZU",
              Arrays.asList("com.meizu.safe/.permission.PermissionMainActivity", "com.meizu.safe"));

          put(
              "OPPO",
              Arrays.asList(
                  // not exported
                  "com.oplus.battery/com.oplus.powermanager.fuelgaue.PowerControlActivity",
                  "com.android.settings/com.oplus.settings.OplusSubSettings",
                  "com.android.settings/com.android.settings.SubSettings",
                  "com.coloros.oppoguardelf/com.coloros.powermanager.fuelgaue.PowerUsageModelActivity",
                  "com.coloros.safecenter/com.coloros.privacypermissionsentry.PermissionTopActivity",
                  "com.coloros.safecenter",
                  "com.oppo.safe",
                  "com.coloros.oppoguardelf"));

          put(
              "SAMSUNG",
              Arrays.asList(
                  "com.samsung.android.lool",
                  "com.samsung.android.sm_cn",
                  "com.samsung.android.sm"));

          put(
              "ONEPLUS",
              Arrays.asList(
                  "com.oneplus.security/.chainlaunch.view.ChainLaunchAppListActivity",
                  "com.oneplus.security"));

          put(
              "LETV",
              Arrays.asList(
                  "com.letv.android.letvsafe/.AutobootManageActivity",
                  "com.letv.android.letvsafe/.BackgroundAppManageActivity",
                  "com.letv.android.letvsafe"));

          put("ZTE", Arrays.asList("com.zte.heartyservice"));

          // 金立
          put("F", Arrays.asList("com.gionee.softmanager/.MainActivity", "com.gionee.softmanager"));

          // 以下为未确定(厂商名也不确定)
          put(
              "SMARTISANOS",
              Arrays.asList(
                  "com.smartisanos.security/.invokeHistory.InvokeHistoryActivity",
                  "com.smartisanos.security"));

          // 360
          put("360", Arrays.asList("com.yulong.android.coolsafe"));

          // 360
          put("ULONG", Arrays.asList("com.yulong.android.coolsafe"));

          // 酷派
          put(
              "COOLPAD",
              Arrays.asList(
                  "com.yulong.android.security/com.yulong.android.seccenter.tabbarmain",
                  "com.yulong.android.security"));

          // 联想
          put(
              "LENOVO",
              Arrays.asList(
                  "com.lenovo.security/.purebackground.PureBackgroundActivity",
                  "com.lenovo.security"));

          put(
              "HTC",
              Arrays.asList(
                  "com.htc.pitroad/.landingpage.activity.LandingPageActivity", "com.htc.pitroad"));

          // 华硕
          put(
              "ASUS",
              Arrays.asList("com.asus.mobilemanager/.MainActivity", "com.asus.mobilemanager"));

          // 酷派
          put(
              "YULONG",
              Arrays.asList(
                  "com.yulong.android.softmanager/.SpeedupActivity",
                  "com.yulong.android.security/com.yulong.android.seccenter.tabbarmain",
                  "com.yulong.android.security"));
        }
      };

  /** 设置应用上下文 */
  public static void setApplicationContext(Context context) {
    sApplicationContext = context.getApplicationContext();
    Log.i(TAG, "setApplicationContext: " + sApplicationContext);
  }

  /** 获取应用上下文 */
  private static Context getAppContext() {
    Log.i(TAG, "getAppContext: " + sApplicationContext);
    if (sApplicationContext == null) {
      throw new IllegalStateException(
          "Application context not set. Call Permission.setApplicationContext() first.");
    }
    return sApplicationContext;
  }

  /** 检查是否有指定权限 */
  public static boolean hasPermission(String permission) {
    if (FLOAT_PERMISSION.equals(permission)) {
      return hasOverlayPermission();
    } else if (BG_START_PERMISSION.equals(permission)) {
      return hasBackgroundStartPermission();
    } else {
      return false;
    }
  }

  /** 请求悬浮窗权限 */
  public static void requestFloatPermission() {
    if (hasOverlayPermission()) {
      return;
    }

    Context context = getAppContext();
    Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION);
    intent.setData(Uri.parse("package:" + context.getPackageName()));
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    context.startActivity(intent);
  }

  /** 检查是否有悬浮窗权限 */
  public static boolean hasOverlayPermission() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      return Settings.canDrawOverlays(getAppContext());
    }
    return true;
  }

  private static boolean isMiui() {
    return TextUtils.equals(Build.MANUFACTURER.toUpperCase(), "XIAOMI")
        || Build.DISPLAY.contains("MIUI");
  }

  /** 检查是否有后台启动权限 */
  public static boolean hasBackgroundStartPermission() {
    if (isMiui()) {
      return isBackgroundStartAllowed();
    }
    return true;
  }

  private static boolean isBackgroundStartAllowed() {
    // Only meaningful on MIUI; for non-MIUI devices, treat as allowed
    if (!isMiui()) {
      return true;
    }
    try {
      Context context = getAppContext();
      AppOpsManager ops = (AppOpsManager) context.getSystemService(Context.APP_OPS_SERVICE);
      if (ops == null) {
        return false;
      }
      // AppOps op code for MIUI background start permission
      int op = 10021;
      Method checkOpNoThrow =
          ops.getClass().getMethod("checkOpNoThrow", int.class, int.class, String.class);
      Object invokeResult =
          checkOpNoThrow.invoke(ops, op, android.os.Process.myUid(), context.getPackageName());
      if (!(invokeResult instanceof Integer)) {
        return false;
      }
      Integer result = (Integer) invokeResult;
      return result == AppOpsManager.MODE_ALLOWED;
    } catch (Exception e) {
      e.printStackTrace();
    }
    return false;
  }

  /** 检查通知权限是否开启 */
  public static boolean isNotificationEnabled() {
    Context context = getAppContext();
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      // For Android Oreo and above
      NotificationManager manager =
          (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
      return manager.areNotificationsEnabled();
    }
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      // For versions prior to Android Oreo
      AppOpsManager appOps = null;
      appOps = (AppOpsManager) context.getSystemService(Context.APP_OPS_SERVICE);
      ApplicationInfo appInfo = context.getApplicationInfo();
      String packageName = context.getApplicationContext().getPackageName();
      int uid = appInfo.uid;
      try {
        Class<?> appOpsClass = null;
        appOpsClass = Class.forName(AppOpsManager.class.getName());
        Method checkOpNoThrowMethod =
            appOpsClass.getMethod("checkOpNoThrow", Integer.TYPE, Integer.TYPE, String.class);
        Field opPostNotificationValue = appOpsClass.getDeclaredField("OP_POST_NOTIFICATION");
        int value = (int) opPostNotificationValue.get(Integer.class);
        return (int) checkOpNoThrowMethod.invoke(appOps, value, uid, packageName)
            == AppOpsManager.MODE_ALLOWED;
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
    return false;
  }

  /** 跳转到各厂商后台弹窗/权限设置页，找不到则回退到系统设置页 */
  public static void startToPermissionSetting(Context context) {
    // 其他常见中文品牌大写键
    String manufacturerUpper =
        Build.MANUFACTURER == null ? "" : Build.MANUFACTURER.toUpperCase(Locale.ROOT);

    if (!BG_POP_HASH_MAP.containsKey(manufacturerUpper)) {
      Intent intent = new Intent(Settings.ACTION_SETTINGS);
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      context.startActivity(intent);
      return;
    }

    List<String> actCompatList = BG_POP_HASH_MAP.get(manufacturerUpper);
    if (actCompatList == null || actCompatList.isEmpty()) {
      Intent intent = new Intent(Settings.ACTION_SETTINGS);
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      context.startActivity(intent);
      return;
    }

    for (String act : actCompatList) {
      try {
        Intent intent;
        if (act.contains("/")) {
          intent = new Intent();
          intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
          ComponentName componentName = ComponentName.unflattenFromString(act);
          if (componentName == null) {
            continue;
          }
          intent.setComponent(componentName);
          intent.putExtra("packagename", context.getPackageName());
          intent.putExtra("extra_pkgname", context.getPackageName());
          intent.putExtra("package_name", context.getPackageName());
        } else {
          // 直接拉起对应安全中心/管家
          intent = context.getPackageManager().getLaunchIntentForPackage(act);
          if (intent == null) {
            continue;
          }
          intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        }
        context.startActivity(intent);
        return;
      } catch (Exception e) {
        e.printStackTrace();
      }
    }

    // 兜底：系统设置页
    try {
      Intent intent = new Intent(Settings.ACTION_SETTINGS);
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      context.startActivity(intent);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
}
