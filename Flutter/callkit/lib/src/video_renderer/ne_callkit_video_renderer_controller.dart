// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of 'package:netease_callkit/netease_callkit.dart';

/// 视频渲染器控制器接口
///
/// 用于控制 NECallkitTextureView 如何获取和管理渲染器。
/// 不同实现可以提供不同的渲染器管理策略（按需创建 vs 缓存复用）。
abstract class NECallkitVideoRendererController {
  /// 获取渲染器
  ///
  /// [uid] - 用户 RTC UID
  ///   - null: 本地视频渲染器
  ///   - 非 null: 远端视频渲染器
  Future<NECallkitVideoRenderer> getRenderer(int? uid);

  /// 释放所有渲染器
  Future<void> dispose();
}

/// 默认渲染器控制器
///
/// 每次调用 [getRenderer] 都创建新的渲染器（不缓存）。
/// 适用于简单场景或需要独立管理每个渲染器生命周期的情况。
class NECallkitDefaultRendererController
    implements NECallkitVideoRendererController {
  NECallkitVideoRenderer? _renderer;

  @override
  Future<NECallkitVideoRenderer> getRenderer(int? uid) async {
    if (_renderer != null) {
      return _renderer!;
    }
    final renderer = await NECallkitVideoRendererFactory.createVideoRenderer();
    _renderer = renderer;
    return renderer;
  }

  @override
  Future<void> dispose() async {
    if (_renderer != null) {
      await _renderer!.dispose();
      _renderer = null;
    }
  }
}
