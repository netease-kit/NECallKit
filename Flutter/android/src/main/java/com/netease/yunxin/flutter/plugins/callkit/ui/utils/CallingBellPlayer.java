// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.flutter.plugins.callkit.ui.utils;

import android.content.Context;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Handler;
import android.os.HandlerThread;

public class CallingBellPlayer {
  private static final String TAG = "CallingBellPlayer";
  private final Context mContext;

  private MediaPlayer mMediaPlayer;
  private Handler mHandler;
  private HandlerThread mHandlerThread;
  private Runnable mPlayRunnable;
  private Runnable mStopPlayRunnable;
  private String mRingFilePath = "";
  private int AUDIO_DIAL_ID = 48;
  private AudioManager mAudioManager;
  private boolean mHasAudioFocus = false;

  public CallingBellPlayer(Context mContext) {
    this.mContext = mContext;
    mMediaPlayer = new MediaPlayer();
    mAudioManager = (AudioManager) mContext.getSystemService(Context.AUDIO_SERVICE);
  }

  public void startRing(String filePath) {
    CallUILog.i(TAG, "startRing");
    mRingFilePath = filePath;
    startHandlerThread();
  }

  public void stopRing() {
    CallUILog.i(TAG, "stopRing");
    mRingFilePath = "";
    stopHandlerThread();
  }

  private void startHandlerThread() {
    CallUILog.i(TAG, "startHandlerThread");
    if (null != mHandler) {
      return;
    }
    mHandlerThread = new HandlerThread("CallingBell");
    mHandlerThread.start();
    mHandler = new Handler(mHandlerThread.getLooper());
    mPlayRunnable =
        new Runnable() {
          @Override
          public void run() {
            if (mMediaPlayer.isPlaying()) {
              mMediaPlayer.stop();
            }
            mMediaPlayer.reset();
            mMediaPlayer.setAudioStreamType(AudioManager.STREAM_RING);

            // 请求音频焦点，暂停其他正在播放的音乐
            int focusResult = mAudioManager.requestAudioFocus(
                null, AudioManager.STREAM_RING, AudioManager.AUDIOFOCUS_GAIN_TRANSIENT);
            mHasAudioFocus = (focusResult == AudioManager.AUDIOFOCUS_REQUEST_GRANTED);
            CallUILog.i(TAG, "requestAudioFocus result=" + focusResult);

            try {
              mMediaPlayer.setDataSource(mRingFilePath);
              mMediaPlayer.setLooping(true);
              mMediaPlayer.prepare();
              CallUILog.i(TAG, "MediaPlayer start");
              mMediaPlayer.start();

            } catch (Exception e) {
              e.printStackTrace();
            }
          }
        };
    mHandler.post(mPlayRunnable);
  }

  private void stopHandlerThread() {
    CallUILog.i("CallingBellPlayer", "stopHandlerThread");
    if (null == mHandler) {
      return;
    }
    mStopPlayRunnable =
        new Runnable() {
          @Override
          public void run() {
            CallUILog.i(TAG, "MediaPlayer stop");
            if (mMediaPlayer.isPlaying()) {
              mMediaPlayer.stop();
            }
            // 释放音频焦点，让其他音乐恢复播放
            if (mHasAudioFocus) {
              mAudioManager.abandonAudioFocus(null);
              mHasAudioFocus = false;
              CallUILog.i(TAG, "abandonAudioFocus");
            }
          }
        };
    mHandler.post(mStopPlayRunnable);
    mHandler.removeCallbacks(mPlayRunnable);
    mHandler = null;
    mPlayRunnable = null;
    if (mHandlerThread != null) {
      mHandlerThread.quitSafely();
      mHandlerThread = null;
    }
  }
}
