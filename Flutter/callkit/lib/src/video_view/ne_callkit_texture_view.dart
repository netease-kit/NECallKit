// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of 'package:netease_callkit/netease_callkit.dart';

/// 基于 Texture 的视频视图
///
/// 自动绑定本地或远端视频流，无需手动调用 attach 方法。
class NECallkitTextureView extends StatefulWidget {
  /// 用户 RTC UID
  /// - null: 本地视频（自动绑定 attachToLocalVideo）
  /// - 非 null: 远端视频（自动绑定 attachToRemoteVideo(uid)）
  final int? uid;

  /// 渲染器控制器（可选）
  /// - 不传：使用内部默认控制器（按需创建，不缓存）
  /// - 传入：使用自定义控制器（可实现缓存复用）
  final NECallkitVideoRendererController? controller;

  /// 视频缩放模式
  final BoxFit fitType;

  /// 背景色
  final Color backgroundColor;

  /// 占位 Widget 构建器（无视频帧时显示）
  final WidgetBuilder? placeholderBuilder;

  /// 渲染事件回调（可选）
  final NECallkitVideoRendererEventListener? rendererEventListener;

  /// 创建本地视频视图（自动绑定本地摄像头）
  const NECallkitTextureView.local({
    super.key,
    this.controller,
    this.fitType = BoxFit.cover,
    this.backgroundColor = const Color(0xFF292933),
    this.placeholderBuilder,
    this.rendererEventListener,
  }) : uid = null;

  /// 创建远端视频视图（自动绑定指定 uid 的远端视频）
  const NECallkitTextureView.remote({
    super.key,
    required int this.uid,
    this.controller,
    this.fitType = BoxFit.cover,
    this.backgroundColor = const Color(0xFF292933),
    this.placeholderBuilder,
    this.rendererEventListener,
  });

  /// 通用构造函数
  const NECallkitTextureView({
    super.key,
    this.uid,
    this.controller,
    this.fitType = BoxFit.cover,
    this.backgroundColor = const Color(0xFF292933),
    this.placeholderBuilder,
    this.rendererEventListener,
  });

  @override
  State<NECallkitTextureView> createState() => _NECallkitTextureViewState();
}

class _NECallkitTextureViewState extends State<NECallkitTextureView> {
  NECallkitDefaultRendererController? _internalController;
  NECallkitVideoRenderer? _renderer;
  bool _initialized = false;

  /// 获取实际使用的控制器
  NECallkitVideoRendererController get _effectiveController {
    if (widget.controller != null) return widget.controller!;
    _internalController ??= NECallkitDefaultRendererController();
    return _internalController!;
  }

  @override
  void initState() {
    super.initState();
    _initRenderer();
  }

  Future<void> _initRenderer() async {
    // 使用统一的 getRenderer(uid) 方法
    _renderer = await _effectiveController.getRenderer(widget.uid);

    // 设置事件监听器（字段形式）
    if (widget.rendererEventListener != null) {
      _renderer!.rendererEventListener = widget.rendererEventListener;
    }

    if (widget.uid == null) {
      _renderer?.attachToLocalVideo();
    } else {
      _renderer?.attachToRemoteVideo(widget.uid!);
    }

    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  void didUpdateWidget(NECallkitTextureView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // uid 或 controller 变化时重新初始化
    if (widget.controller != oldWidget.controller) {
      // 释放旧控制器（仅限内部创建的）
      if (oldWidget.controller == null) {
        _internalController?.dispose();
        _internalController = null;
      }
    }
    if (widget.uid != oldWidget.uid ||
        widget.controller != oldWidget.controller) {
      _initialized = false;
      _initRenderer();
    }

    if (widget.rendererEventListener != oldWidget.rendererEventListener) {
      _renderer?.rendererEventListener = widget.rendererEventListener;
    }
  }

  @override
  void dispose() {
    // 仅释放内部创建的控制器，外部传入的不释放
    if (widget.controller == null) {
      _internalController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final renderer = _renderer;

    if (!_initialized || renderer == null || renderer.textureId == null) {
      return _buildPlaceholder();
    }

    return ValueListenableBuilder<NECallkitVideoValue>(
      valueListenable: renderer,
      builder: (context, value, child) {
        if (!renderer.canRender) {
          return _buildPlaceholder();
        }
        return _buildTextureView(renderer.textureId!, value);
      },
    );
  }

  Widget _buildPlaceholder() {
    if (widget.placeholderBuilder != null) {
      return widget.placeholderBuilder!(context);
    }
    return Container(color: widget.backgroundColor);
  }

  Widget _buildTextureView(int textureId, NECallkitVideoValue value) {
    final texture = Texture(textureId: textureId);
    final videoWidth = value.width > 0 ? value.width.toDouble() : 1.0;
    final videoHeight = value.height > 0 ? value.height.toDouble() : 1.0;

    // cover 需要特殊处理（FittedBox 不支持超出边界裁剪）
    if (widget.fitType == BoxFit.cover) {
      return _buildCoverView(texture, videoWidth, videoHeight);
    }

    // 其他模式统一用 FittedBox
    return Container(
      color: widget.backgroundColor,
      child: Center(
        child: FittedBox(
          fit: widget.fitType,
          child: SizedBox(
            width: videoWidth,
            height: videoHeight,
            child: texture,
          ),
        ),
      ),
    );
  }

  /// 构建 cover 模式视图
  ///
  /// cover 模式需要视频填满容器，超出部分裁剪
  /// FittedBox 不支持此效果，需要使用 OverflowBox + ClipRect
  Widget _buildCoverView(Widget texture, double videoWidth, double videoHeight) {
    return Container(
      color: widget.backgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final videoAspectRatio = videoWidth / videoHeight;
          final containerAspectRatio =
              constraints.maxWidth / constraints.maxHeight;

          double width, height;
          if (videoAspectRatio > containerAspectRatio) {
            // 视频更宽，按高度填满，宽度超出后裁剪
            height = constraints.maxHeight;
            width = height * videoAspectRatio;
          } else {
            // 视频更高，按宽度填满，高度超出后裁剪
            width = constraints.maxWidth;
            height = width / videoAspectRatio;
          }

          return ClipRect(
            child: OverflowBox(
              alignment: Alignment.center,
              maxWidth: width,
              maxHeight: height,
              child: SizedBox(
                width: width,
                height: height,
                child: texture,
              ),
            ),
          );
        },
      ),
    );
  }
}
