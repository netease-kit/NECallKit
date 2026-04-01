// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:netease_callkit/netease_callkit.dart';

/// 通用视频渲染器缓存管理（单例）
///
/// 实现 NECallkitVideoRendererController 接口，支持群呼和单呼场景的渲染器复用（带缓存）。
///
/// 支持场景：
/// - 群呼：多个远端成员 + 本地预览
/// - 单呼：一个远端成员 + 本地预览
///
/// 使用方式：
/// - 通话开始时：按需获取渲染器（自动创建并绑定）
/// - 通话中：复用已创建的渲染器
/// - 通话结束时：调用 releaseAll() 或 dispose() 统一释放
class NEVideoRendererCache implements NECallkitVideoRendererController {
  // 单例
  static final NEVideoRendererCache _instance = NEVideoRendererCache._();
  static NEVideoRendererCache get instance => _instance;
  NEVideoRendererCache._();

  /// 本地渲染器（仅一个，群呼/单呼共用）
  NECallkitVideoRenderer? _localRenderer;

  /// 远端渲染器缓存
  /// - 群呼：key = rtcUid（多个远端成员）
  /// - 单呼：key = rtcUid（单个远端成员，但使用相同 API）
  final Map<int, NECallkitVideoRenderer> _remoteRenderers = {};

  // ========== NECallkitVideoRendererController 实现 ==========

  /// 获取渲染器（带缓存）
  ///
  /// [uid] - 用户 RTC UID
  ///   - null: 本地视频渲染器（单例复用）
  ///   - 非 null: 远端视频渲染器（按 uid 缓存）
  @override
  Future<NECallkitVideoRenderer> getRenderer(int? uid) async {
    if (uid == null) {
      return await getLocalRenderer();
    } else {
      return await getRemoteRenderer(uid);
    }
  }

  /// 释放所有渲染器（NECallkitVideoRendererController 接口方法）
  @override
  Future<void> dispose() => releaseAll();

  // ========== 本地渲染器 ==========

  /// 获取或创建本地渲染器（自动绑定本地视频流）
  Future<NECallkitVideoRenderer> getLocalRenderer() async {
    _localRenderer ??= await NECallkitVideoRendererFactory.createVideoRenderer();
    return _localRenderer!;
  }

  /// 检查本地渲染器是否已创建
  bool hasLocalRenderer() => _localRenderer != null;

  /// 获取已创建的本地渲染器（不创建）
  NECallkitVideoRenderer? get localRenderer => _localRenderer;

  // ========== 远端渲染器 ==========

  /// 获取或创建远端渲染器（自动绑定指定 uid 的远端视频流）
  ///
  /// [rtcUid] - NERtc 用户 ID
  Future<NECallkitVideoRenderer> getRemoteRenderer(int rtcUid) async {
    if (!_remoteRenderers.containsKey(rtcUid)) {
      final renderer =
          await NECallkitVideoRendererFactory.createVideoRenderer();
      _remoteRenderers[rtcUid] = renderer;
    }
    return _remoteRenderers[rtcUid]!;
  }

  /// 检查指定远端渲染器是否已创建
  bool hasRemoteRenderer(int rtcUid) => _remoteRenderers.containsKey(rtcUid);

  /// 获取已创建的远端渲染器（不创建）
  NECallkitVideoRenderer? getRemoteRendererIfExists(int rtcUid) =>
      _remoteRenderers[rtcUid];

  /// 释放指定远端渲染器（成员离开时可选调用，群呼场景）
  Future<void> releaseRemoteRenderer(int rtcUid) async {
    final renderer = _remoteRenderers.remove(rtcUid);
    await renderer?.dispose();
  }

  // ========== 清理 ==========

  /// 释放所有渲染器（通话结束时调用）
  ///
  /// 适用场景：
  /// - 群呼结束：GroupCallManager.release()
  /// - 单呼结束：CallManager.release()
  Future<void> releaseAll() async {
    // 释放本地渲染器
    await _localRenderer?.dispose();
    _localRenderer = null;

    // 释放所有远端渲染器
    for (final renderer in _remoteRenderers.values) {
      await renderer.dispose();
    }
    _remoteRenderers.clear();
  }

  /// 获取缓存状态（调试用）
  Map<String, dynamic> get debugInfo => {
        'hasLocalRenderer': _localRenderer != null,
        'remoteRendererCount': _remoteRenderers.length,
        'remoteUids': _remoteRenderers.keys.toList(),
      };
}
