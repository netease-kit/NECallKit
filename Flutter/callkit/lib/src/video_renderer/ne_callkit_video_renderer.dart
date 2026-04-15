// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of 'package:netease_callkit/netease_callkit.dart';

/// 视频帧值，包含宽高和旋转角度
class NECallkitVideoValue {
  const NECallkitVideoValue({
    this.width = 0,
    this.height = 0,
    this.rotation = 0,
  });

  final int width;
  final int height;
  final int rotation;

  const NECallkitVideoValue.uninitialized()
      : this(
          width: 0,
          height: 0,
          rotation: 0,
        );

  NECallkitVideoValue copyWith({
    int? width,
    int? height,
    int? rotation,
  }) {
    return NECallkitVideoValue(
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
    );
  }

  double get aspectRatio {
    return width * height == 0
        ? 1.0
        : (rotation == 90 || rotation == 270)
            ? height / width
            : width / height;
  }

  @override
  String toString() {
    return 'NECallkitVideoValue{width: $width, height: $height, rotation: $rotation}';
  }
}

/// 渲染器事件监听
mixin NECallkitVideoRendererEventListener {
  /// 帧分辨率变化回调
  void onFrameResolutionChanged(int uid, int width, int height, int rotation) {}

  /// 首帧渲染回调
  void onFirstFrameRendered(int uid) {}
}

/// 视频渲染器接口
///
/// 用于渲染本地或远端视频流，基于 Flutter Texture 实现。
abstract class NECallkitVideoRenderer
    extends ValueNotifier<NECallkitVideoValue> {
  NECallkitVideoRenderer() : super(const NECallkitVideoValue.uninitialized());

  /// 渲染事件监听器（字段形式，可在使用时设置）
  NECallkitVideoRendererEventListener? rendererEventListener;

  /// 获取纹理 ID
  int? get textureId;

  /// 是否可以渲染（有有效尺寸且已绑定视频源）
  bool get canRender;

  /// 初始化渲染器
  Future<void> initialize();

  /// 绑定本地视频
  Future<int> attachToLocalVideo();

  /// 绑定远端视频
  Future<int> attachToRemoteVideo(int uid);

  /// 设置镜像
  Future<int> setMirror(bool mirror);

  /// 获取镜像状态
  bool getMirrored();

  /// 释放渲染器
  @override
  Future<void> dispose();
}

/// 视频渲染器工厂
class NECallkitVideoRendererFactory {
  NECallkitVideoRendererFactory._();

  /// 创建视频渲染器（自动初始化）
  static Future<NECallkitVideoRenderer> createVideoRenderer() async {
    final renderer = _NECallkitVideoRendererImpl();
    await renderer.initialize();
    return renderer;
  }
}
