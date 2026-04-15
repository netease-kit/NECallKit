// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.flutter.plugins.callkit.videorenderer;

import android.graphics.SurfaceTexture;
import android.os.Handler;
import android.os.Looper;
import androidx.annotation.NonNull;
import com.netease.lava.api.IVideoRender;
import com.netease.lava.webrtc.EglBase;
import com.netease.lava.webrtc.VideoFrame;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.view.TextureRegistry;
import java.util.HashMap;

/**
 * 基于 Flutter Texture 的视频渲染器
 *
 * 实现 IVideoRender 接口，通过 NERtcEx.setupLocalVideoCanvas(this) 绑定视频流
 */
public class CallkitFlutterVideoRenderer implements IVideoRender, EventChannel.StreamHandler {

  private final TextureRegistry.SurfaceTextureEntry entry;
  private final long id;
  private final EventChannel eventChannel;
  private EventChannel.EventSink eventSink;
  private volatile SurfaceTextureRenderer surfaceTextureRenderer;
  private final SurfaceTexture texture;
  private final EglBase.Context sharedEglContext;
  private final Handler mainHandler = new Handler(Looper.getMainLooper());

  private boolean isInitializeCalled = false;
  private boolean isInitialized = false;
  private VideoBufferType mVideoBufferType = VideoBufferType.VIDEO_BUFFER_TYPE_RAW_DATA;
  private boolean mIsExternalRender = true;

  private final SurfaceTextureRenderer.RendererEvents rendererEvents =
      new SurfaceTextureRenderer.RendererEvents() {

        @Override
        public void onFirstFrameRendered() {
          if (eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("id", id);
            map.put("event", "onFirstFrameRendered");
            eventSink.success(map);
          }
        }

        @Override
        public void onFrameResolutionChanged(int width, int height, int rotation) {
          if (eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("event", "onFrameResolutionChanged");
            map.put("id", id);
            map.put("width", width);
            map.put("height", height);
            map.put("rotation", rotation);
            eventSink.success(map);
          }
        }
      };

  public CallkitFlutterVideoRenderer(
      @NonNull BinaryMessenger messenger,
      @NonNull TextureRegistry.SurfaceTextureEntry entry,
      EglBase.Context sharedEglContext) {
    this.entry = entry;
    this.id = entry.id();
    this.texture = entry.surfaceTexture();
    this.surfaceTextureRenderer = new SurfaceTextureRenderer("CallkitRenderer/" + id);
    this.eventChannel = new EventChannel(messenger, "NECallkitRenderer/Texture" + entry.id());
    this.eventChannel.setStreamHandler(this);
    this.sharedEglContext = sharedEglContext;
  }

  public void dispose() {
    if (eventChannel != null) {
      eventChannel.setStreamHandler(null);
    }
    if (surfaceTextureRenderer != null) {
      surfaceTextureRenderer.release();
      surfaceTextureRenderer = null;
    }
    if (entry != null) {
      entry.release();
    }
  }

  @Override
  public void setScalingType(ScalingType scalingType) {}

  @Override
  public void setVideoBufferType(VideoBufferType videoBufferType) {
    mVideoBufferType = videoBufferType;
  }

  @Override
  public VideoBufferType getVideoBufferType() {
    return mVideoBufferType;
  }

  @Override
  public void setExternalRender(boolean b) {
    mIsExternalRender = b;
  }

  @Override
  public boolean isExternalRender() {
    return mIsExternalRender;
  }

  @Override
  public void setMirror(boolean mirror) {
    SurfaceTextureRenderer render = surfaceTextureRenderer;
    if (render != null) {
      render.setMirror(mirror);
    }
  }

  @Override
  public boolean isMirror() {
    return false;
  }

  @Override
  public void clearImage() {
    SurfaceTextureRenderer render = surfaceTextureRenderer;
    if (render != null) {
      surfaceTextureRenderer.clearImage();
    }
  }

  @Override
  public void onFrame(VideoFrame videoFrame) {
    ensureRenderInitialized();
    SurfaceTextureRenderer render = surfaceTextureRenderer;
    if (isInitialized && render != null) {
      render.onFrame(videoFrame);
    }
  }

  private void ensureRenderInitialized() {
    if (!isInitializeCalled && surfaceTextureRenderer != null) {
      isInitializeCalled = true;
      mainHandler.post(() -> {
        SurfaceTextureRenderer render = surfaceTextureRenderer;
        if (render != null) {
          render.init(sharedEglContext, rendererEvents);
          render.surfaceCreated(texture);
          isInitialized = true;
        }
      });
    }
  }

  public long id() {
    return id;
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    this.eventSink = new SafeEventSink(events);
  }

  @Override
  public void onCancel(Object arguments) {
    this.eventSink = null;
  }
}
