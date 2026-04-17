// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io' show Platform;

part of 'package:netease_callkit/netease_callkit.dart';

/// Platform view widget used to render CallKit video.
///
/// This widget wraps a native Android/iOS view that displays the local or
/// remote video stream managed by [NECallEngine]. On unsupported platforms,
/// a fallback text or empty container is rendered.
class NECallkitVideoView extends StatefulWidget {
  /// Callback triggered when the underlying platform view is created.
  final PlatformViewCreatedCallback? onPlatformViewCreated;

  /// Callback triggered when the video view is ready (XComponent loaded).
  /// On HarmonyOS, this is called when the native NERtcVideoView's onLoad fires.
  /// You should call setupLocalView/setupRemoteView after this callback.
  final VoidCallback? onVideoViewReady;

  /// Gesture recognizers that should participate in the gesture arena for
  /// this platform view.
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  /// Constructs a new [NECallkitVideoView].
  const NECallkitVideoView({
    super.key,
    this.onPlatformViewCreated,
    this.onVideoViewReady,
    this.gestureRecognizers,
  });

  @override
  State<StatefulWidget> createState() {
    return NECallkitVideoViewState();
  }
}

/// State implementation for [NECallkitVideoView].
class NECallkitVideoViewState extends State<NECallkitVideoView> {
  int? _id;
  MethodChannel? _channel;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const Text('Web is not yet supported by the plugin');
    }
    const viewType = 'callkit_video_view';
    final creationParams = <String, dynamic>{};

    if (defaultTargetPlatform == TargetPlatform.iOS) {
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
  }

  @override
  void didUpdateWidget(NECallkitVideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint('[NECallkitVideoView] dispose() called, viewId=$_id, channel=${_channel?.name}');
    _channel?.invokeMethod("destroyVideoView", {}).then((_) {
      debugPrint('[NECallkitVideoView] destroyVideoView success, viewId=$_id');
    }).catchError((e) {
      debugPrint('[NECallkitVideoView] destroyVideoView error: $e, viewId=$_id');
    });
  }

  Future<void> _onPlatformViewCreated(int id) async {
    _id = id;
    _channel = MethodChannel('ne_call_kit/video_view_$id');
    // 监听 Native 端的 onLoad 回调
    _channel?.setMethodCallHandler(_handleMethodCall);
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
}
