// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../group_call_manager.dart';
import '../../utils/callkit_ui_log.dart';

/// 安全关闭页面的 Mixin
///
/// 提供安全的页面关闭机制：
/// - 如果页面在路由栈顶，执行 pop
/// - 如果页面不在栈顶，执行 removeRoute
///
/// 使用方式：
/// 1. State 类 with SafePageCloseMixin
/// 2. 在 didChangeDependencies 中调用 initSafePageClose(context)
/// 3. 在 dispose 中调用 disposeSafePageClose()
mixin SafePageCloseMixin<T extends StatefulWidget> on State<T> {
  static const String _tag = 'SafePageCloseMixin';

  ModalRoute<dynamic>? _safeCloseRoute;
  bool _safeCloseInitialized = false;

  /// 初始化安全关闭机制
  ///
  /// 在 didChangeDependencies 中调用
  void initSafePageClose(BuildContext context) {
    _safeCloseRoute = ModalRoute.of(context);

    if (!_safeCloseInitialized) {
      _safeCloseInitialized = true;
      GroupCallManager.instance.registerClosePageCallback(handleSafeClose);
      CallKitUILog.d(_tag, 'initSafePageClose: callback registered');
    }
  }

  /// 释放安全关闭机制
  ///
  /// 在 dispose 中调用
  void disposeSafePageClose() {
    GroupCallManager.instance.unregisterClosePageCallback(handleSafeClose);
    CallKitUILog.d(_tag, 'disposeSafePageClose: callback unregistered');
  }

  /// 处理安全关闭请求
  ///
  /// 可由 mixin 使用者直接调用（如锁屏恢复后检测到通话已结束）
  void handleSafeClose() {
    if (_safeCloseRoute == null) {
      CallKitUILog.e(_tag, '_handleSafeClose: route is null');
      return;
    }

    if (!mounted) {
      CallKitUILog.e(_tag, '_handleSafeClose: widget not mounted');
      return;
    }

    if (_safeCloseRoute!.isCurrent) {
      Navigator.of(context).pop();
      CallKitUILog.d(_tag, '_handleSafeClose: popped (was current)');
    } else {
      Navigator.of(context).removeRoute(_safeCloseRoute!);
      CallKitUILog.d(_tag, '_handleSafeClose: removed (was not current)');
    }
  }
}
