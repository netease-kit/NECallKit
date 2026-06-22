// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of 'package:netease_callkit/netease_callkit.dart';

/// Widget used to render CallKit video.
///
/// On Android, iOS, and macOS this widget wraps a native platform view that
/// displays the local or remote video stream managed by [NECallEngine].
/// On Windows it creates and displays a desktop texture renderer internally,
/// while still reporting the created renderer id through
/// [onPlatformViewCreated]. On unsupported platforms, a fallback text or empty
/// container is rendered.
class NECallkitVideoView extends StatefulWidget {
  /// Callback triggered when the underlying render target is created.
  ///
  /// On Android, iOS, and macOS the callback receives a platform view id. On
  /// Windows it receives the created texture renderer id.
  final PlatformViewCreatedCallback? onPlatformViewCreated;

  /// Callback triggered when the video view is ready (XComponent loaded).
  /// On HarmonyOS, this is called when the native NERtcVideoView's onLoad fires.
  /// You should call setupLocalView/setupRemoteView after this callback.
  final VoidCallback? onVideoViewReady;

  /// Gesture recognizers that should participate in the gesture arena for
  /// this platform view.
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  /// Desktop-only display mode.
  ///
  /// - `BoxFit.contain`: keep the full frame visible with letterboxing.
  /// - `BoxFit.cover`: crop-fill the view so the canvas is fully covered.
  ///
  /// On macOS this configures the native RTC canvas scaling mode. On Windows
  /// it controls the Flutter texture layout.
  final BoxFit desktopVideoFit;

  /// Constructs a new [NECallkitVideoView].
  const NECallkitVideoView({
    super.key,
    this.onPlatformViewCreated,
    this.onVideoViewReady,
    this.gestureRecognizers,
    this.desktopVideoFit = BoxFit.contain,
  });

  @override
  State<StatefulWidget> createState() {
    return NECallkitVideoViewState();
  }
}

/// State implementation for [NECallkitVideoView].
class NECallkitVideoViewState extends State<NECallkitVideoView> {
  static const int _desktopScalingModeFit = 0;
  static const int _desktopScalingModeCropFill = 2;
  int? _id;
  MethodChannel? _channel;
  final CallkitVideoRendererApi _rendererApi = CallkitVideoRendererApi();
  bool _desktopRendererCreating = false;
  StreamSubscription<dynamic>? _rendererEventSubscription;
  NECallkitVideoValue _videoValue = const NECallkitVideoValue.uninitialized();

  bool get _usesDesktopTextureRenderer =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  bool get _usesPlatformView =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const Text('Web is not yet supported by the plugin');
    }
    const viewType = 'callkit_video_view';
    final creationParams = <String, dynamic>{};

    if (_usesDesktopTextureRenderer) {
      if (_id != null) {
        return _buildDesktopTextureView(_id!);
      }
      return Container();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: UiKitView(
          viewType: viewType,
          onPlatformViewCreated: _onPlatformViewCreated,
          hitTestBehavior: PlatformViewHitTestBehavior.transparent,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          gestureRecognizers: widget.gestureRecognizers,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: AppKitView(
          viewType: viewType,
          onPlatformViewCreated: _onPlatformViewCreated,
          hitTestBehavior: PlatformViewHitTestBehavior.transparent,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          gestureRecognizers: widget.gestureRecognizers,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: AndroidView(
          viewType: viewType,
          onPlatformViewCreated: _onPlatformViewCreated,
          hitTestBehavior: PlatformViewHitTestBehavior.transparent,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          gestureRecognizers: widget.gestureRecognizers,
        ),
      );
    } else if (!kIsWeb && CallkitPlatformCompat.isOhos) {
      // OHOS 平台使用 OhosView
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: OhosView(
          viewType: viewType,
          onPlatformViewCreated: _onPlatformViewCreated,
          hitTestBehavior: PlatformViewHitTestBehavior.transparent,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          gestureRecognizers: widget.gestureRecognizers,
        ),
      );
    } else {
      // 其他未支持平台
      if (_id != null) {
        return Texture(textureId: _id!);
      }
      return Text('$defaultTargetPlatform is not yet supported by the plugin');
    }
  }

  @override
  void initState() {
    super.initState();
    if (_usesDesktopTextureRenderer) {
      _createDesktopRenderer();
    }
  }

  @override
  void didUpdateWidget(NECallkitVideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_usesPlatformView &&
        defaultTargetPlatform == TargetPlatform.macOS &&
        oldWidget.desktopVideoFit != widget.desktopVideoFit &&
        _id != null) {
      _applyDesktopPlatformViewRenderMode();
    }
  }

  @override
  void dispose() {
    if (_usesDesktopTextureRenderer) {
      _rendererEventSubscription?.cancel();
      final id = _id;
      if (id != null) {
        _rendererApi.disposeVideoRenderer(id);
      }
      super.dispose();
      return;
    }
    if (_usesPlatformView) {
      _channel?.invokeMethod('destroyVideoView', {});
    }
    super.dispose();
  }

  Future<void> _onPlatformViewCreated(int id) async {
    _id = id;
    _channel = MethodChannel('ne_call_kit/video_view_$id');
    // 监听 Native 端的 onLoad 回调
    _channel?.setMethodCallHandler(_handleMethodCall);
    await _applyDesktopPlatformViewRenderMode();
    widget.onPlatformViewCreated?.call(id);
    // Android/iOS does not send explicit `onLoad`, so trigger readiness after
    // platform view creation to keep behavior aligned with OHOS.
    if (!CallkitPlatformCompat.isOhos) {
      widget.onVideoViewReady?.call();
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onLoad':
        debugPrint('[NECallkitVideoView] onLoad received for viewId=$_id');
        widget.onVideoViewReady?.call();
        break;
    }
  }

  Future<void> _applyDesktopPlatformViewRenderMode() async {
    if (defaultTargetPlatform != TargetPlatform.macOS || _channel == null) {
      return;
    }
    try {
      await _channel!.invokeMethod('setDesktopScalingMode', <String, Object?>{
        'scalingMode': widget.desktopVideoFit == BoxFit.cover
            ? _desktopScalingModeCropFill
            : _desktopScalingModeFit,
      });
    } catch (_) {
      // Keep the existing platform-view fallback if native mode setup fails.
    }
  }

  Future<void> _createDesktopRenderer() async {
    if (_desktopRendererCreating || _id != null) {
      return;
    }
    _desktopRendererCreating = true;
    try {
      final rendererId = await _rendererApi.createVideoRenderer();
      if (!mounted) {
        await _rendererApi.disposeVideoRenderer(rendererId);
        return;
      }
      _rendererEventSubscription =
          EventChannel('NECallkitRenderer/Texture$rendererId')
              .receiveBroadcastStream()
              .listen(_onRendererEvent);
      setState(() {
        _id = rendererId;
        _videoValue = const NECallkitVideoValue.uninitialized();
      });
      widget.onPlatformViewCreated?.call(rendererId);
    } catch (_) {
      // Keep the existing empty-container fallback on renderer creation failure.
    } finally {
      _desktopRendererCreating = false;
    }
  }

  void _onRendererEvent(dynamic event) {
    if (!mounted || event is! Map) {
      return;
    }
    if (event['event'] == 'onFrameResolutionChanged') {
      setState(() {
        _videoValue = _videoValue.copyWith(
          width: event['width'] as int?,
          height: event['height'] as int?,
          rotation: event['rotation'] as int?,
        );
      });
    }
  }

  Widget _buildDesktopTextureView(int textureId) {
    final texture = Texture(textureId: textureId);
    final value = _videoValue;
    final isRotated = value.rotation == 90 || value.rotation == 270;
    final videoWidth = value.width > 0
        ? (isRotated ? value.height : value.width).toDouble()
        : 1.0;
    final videoHeight = value.height > 0
        ? (isRotated ? value.width : value.height).toDouble()
        : 1.0;

    return Container(
      color: Colors.black,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final containerWidth = constraints.maxWidth;
          final containerHeight = constraints.maxHeight;
          final videoAspectRatio = videoWidth / videoHeight;
          final containerAspectRatio = containerWidth / containerHeight;

          if (widget.desktopVideoFit == BoxFit.cover) {
            double width;
            double height;
            if (videoAspectRatio > containerAspectRatio) {
              height = containerHeight;
              width = height * videoAspectRatio;
            } else {
              width = containerWidth;
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
          }

          double width;
          double height;
          if (videoAspectRatio > containerAspectRatio) {
            width = containerWidth;
            height = width / videoAspectRatio;
          } else {
            height = containerHeight;
            width = height * videoAspectRatio;
          }

          return Center(
            child: SizedBox(
              width: width,
              height: height,
              child: texture,
            ),
          );
        },
      ),
    );
  }
}
