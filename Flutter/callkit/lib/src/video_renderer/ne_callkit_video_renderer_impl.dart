// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of 'package:netease_callkit/netease_callkit.dart';

/// 视频渲染器实现（库私有）
class _NECallkitVideoRendererImpl extends NECallkitVideoRenderer {
  _NECallkitVideoRendererImpl();

  final CallkitVideoRendererApi _api = CallkitVideoRendererApi();

  int _textureId = -1;
  bool _mirror = false;
  StreamSubscription<dynamic>? _rendererEventSubscription;

  /// 绑定的用户 ID：null=未绑定, 0=本地视频, >0=远端视频
  int? _uid;
  bool _disposed = false;

  @override
  int? get textureId => _textureId >= 0 ? _textureId : null;

  @override
  bool get canRender => value.width * value.height != 0;

  @override
  Future<void> initialize() async {
    if (Platform.isAndroid || Platform.isIOS || Platform.isOhos) {
      _textureId = await _api.createVideoRenderer();
      _rendererEventSubscription =
          EventChannel('NECallkitRenderer/Texture$_textureId')
              .receiveBroadcastStream()
              .listen(_onRendererEvent);
    }
  }

  void _onRendererEvent(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'onFrameResolutionChanged':
        value = value.copyWith(
          width: map['width'],
          height: map['height'],
          rotation: map['rotation'],
        );
        rendererEventListener?.onFrameResolutionChanged(
          _uid ?? 0,
          value.width,
          value.height,
          value.rotation,
        );
        break;
      case 'onFirstFrameRendered':
        rendererEventListener?.onFirstFrameRendered(_uid ?? 0);
        break;
    }
  }

  @override
  Future<int> attachToLocalVideo() async {
    _uid = 0;
    if (textureId == null) return -1;
    return await _api.setupLocalVideoRenderer(_textureId);
  }

  @override
  Future<int> attachToRemoteVideo(int uid) async {
    _uid = uid;
    if (textureId == null) return -1;
    return await _api.setupRemoteVideoRenderer(uid, _textureId);
  }

  @override
  bool getMirrored() {
    return _mirror;
  }

  @override
  Future<int> setMirror(bool mirror) async {
    if (textureId == null) return -1;
    final result = await _api.setMirror(_textureId, mirror);
    if (result == 0) _mirror = mirror;
    return result;
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _rendererEventSubscription?.cancel();
    if (_textureId > 0) {
      await _api.disposeVideoRenderer(_textureId);
    }
    _textureId = -1;
    super.dispose();
  }
}
