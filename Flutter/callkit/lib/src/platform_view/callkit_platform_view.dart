// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// CallKit PlatformView 工厂
class CallKitPlatformViewFactory {
  /// 注册 PlatformView 工厂
  static void register() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // iOS 平台注册
      const platform = MethodChannel('callkit_platform_view');
      platform.setMethodCallHandler(_handleMethodCall);
    }
  }

  /// 处理来自 native 的方法调用
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'createView':
        final int viewId = call.arguments['viewId'] as int;
        final String viewType = call.arguments['viewType'] as String;
        return _createNativeView(viewId, viewType);
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'Method ${call.method} not implemented',
        );
    }
  }

  /// 创建 native view
  static Future<int> _createNativeView(int viewId, String viewType) async {
    // 这里会调用 iOS 端创建 UIView
    return viewId;
  }
}

/// CallKit View Widget
class CallKitView extends StatelessWidget {
  final String viewID;
  final bool isLocal;
  final void Function(int)? onViewCreated;

  const CallKitView({
    super.key,
    required this.viewID,
    required this.isLocal,
    this.onViewCreated,
  });

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'callkit_video_view',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: {
          'viewID': viewID,
          'isLocal': isLocal,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      // Android 或其他平台返回占位符
      return Container(
        color: Colors.black,
        child: Center(
          child: Text(
            'CallKit View\n$viewID\n${isLocal ? 'Local' : 'Remote'}',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  void _onPlatformViewCreated(int id) {
    onViewCreated?.call(id);
  }
}
