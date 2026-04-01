// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.nertc.ui.service.foregroundservice;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ServiceInfo;
import android.os.Build.VERSION;
import android.os.IBinder;
import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import androidx.core.content.ContextCompat;
import com.netease.yunxin.kit.corekit.XKit;
import com.netease.yunxin.nertc.ui.R;
import com.netease.yunxin.nertc.ui.utils.CallUILog;

public class AudioForegroundService extends Service {
  private static final String TAG = "AudioForegroundService";
  private static final String TITLE = "title";
  private static final String ICON = "icon";
  private static final String DESCRIPTION = "description";
  private static final int NOTIFICATION_ID = 1001;
  private static ServiceState state;

  public static void start(Context context, String title, String description, int icon) {
    if (state != ServiceState.STARTING && state != ServiceState.RUNNING) {
      if (state == ServiceState.STOPPING) {
        state = ServiceState.STARTING;
        CallUILog.i(TAG, "start foreground service，service is stopping");
      } else {
        state = ServiceState.STARTING;
        if (!checkHasPermission(context)) {
          state = ServiceState.IDLE;
          CallUILog.e(TAG, "start foreground service failed, please grant microphone permission");
        } else {
          CallUILog.d(
              TAG, "start foreground service title=" + title + " description=" + description);
          Intent intent = new Intent(context, AudioForegroundService.class);
          intent.putExtra(TITLE, title);
          intent.putExtra(ICON, icon);
          intent.putExtra(DESCRIPTION, description);
          if (VERSION.SDK_INT >= 26) {
            context.startForegroundService(intent);
          } else {
            context.startService(intent);
          }
        }
      }
    } else {
      CallUILog.i(TAG, "start foreground service，service is running");
    }
  }

  public static void stop(Context context) {
    CallUILog.d(TAG, "stop foreground service, state = " + state);
    if (ServiceState.RUNNING == state) {
      Intent intent = new Intent(context, AudioForegroundService.class);
      context.stopService(intent);
      state = ServiceState.IDLE;
    } else if (ServiceState.STARTING == state) {
      state = ServiceState.STOPPING;
    }
  }

  public int onStartCommand(Intent intent, int flags, int startId) {
    if (intent == null) {
      CallUILog.e("AudioForegroundService", "onStartCommand intent == null, state = " + state);
      return Service.START_NOT_STICKY;
    } else {
      Context appContext = XKit.Companion.instance().getApplicationContext();
      String title = intent.getStringExtra(TITLE);
      String description = intent.getStringExtra(DESCRIPTION);
      int icon = intent.getIntExtra(ICON, appContext.getApplicationInfo().icon);
      Notification notification = this.createForegroundNotification(title, description, icon);
      if (VERSION.SDK_INT >= 30) {
        this.startForeground(1001, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE);
      } else {
        this.startForeground(1001, notification);
      }

      CallUILog.d(TAG, "onStartCommand end, state = " + state);
      if (state == ServiceState.STOPPING) {
        this.stopSelf();
        state = ServiceState.IDLE;
      } else {
        state = ServiceState.RUNNING;
      }

      return Service.START_NOT_STICKY;
    }
  }

  @Nullable
  public IBinder onBind(Intent intent) {
    throw new UnsupportedOperationException("Not yet implemented");
  }

  public void onTaskRemoved(Intent rootIntent) {
    super.onTaskRemoved(rootIntent);
    this.stopSelf();
    state = ServiceState.IDLE;
  }

  private Notification createForegroundNotification(String title, String description, int icon) {
    NotificationManager notificationManager =
        (NotificationManager) this.getSystemService(Context.NOTIFICATION_SERVICE);
    String notificationChannelId = "rtc_uikit_foreground_service";
    if (VERSION.SDK_INT >= 26) {
      String channelName = this.getApplicationContext().getString(R.string.ui_channel_name);
      String channelDescription =
          this.getApplicationContext().getString(R.string.ui_channel_description);
      NotificationChannel notificationChannel =
          new NotificationChannel(
              notificationChannelId, channelName, NotificationManager.IMPORTANCE_LOW);
      notificationChannel.setDescription(channelDescription);
      if (notificationManager != null) {
        notificationManager.createNotificationChannel(notificationChannel);
      }
    }

    boolean enableNotification = true;
    if (VERSION.SDK_INT >= 24 && notificationManager != null) {
      enableNotification = notificationManager.areNotificationsEnabled();
    }

    CallUILog.i("AudioForegroundService", "enableNotification: " + enableNotification);
    NotificationCompat.Builder builder =
        new NotificationCompat.Builder(this, notificationChannelId);
    builder.setSmallIcon(icon);
    builder.setContentTitle(title);
    builder.setContentText(description);
    builder.setWhen(System.currentTimeMillis());
    return builder.build();
  }

  private static boolean checkHasPermission(Context context) {
    return ContextCompat.checkSelfPermission(context, "android.permission.RECORD_AUDIO") == 0;
  }

  static {
    state = ServiceState.IDLE;
  }
}
