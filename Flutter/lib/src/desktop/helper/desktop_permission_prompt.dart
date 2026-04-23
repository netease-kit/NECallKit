import 'dart:io';

import 'package:flutter/material.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';

import '../../platform/call_kit_platform_interface.dart';
import '../../utils/permission.dart';

class DesktopPermissionPrompt {
  DesktopPermissionPrompt._();

  static bool _isShowing = false;

  static Future<void> showForPermissions(
      List<PermissionType> permissions) async {
    if (_isShowing) {
      return;
    }

    final overlayContext =
        NECallKitNavigatorObserver.getInstance().navigator?.overlay?.context;
    if (overlayContext == null) {
      return;
    }

    final deniedPermission =
        await _resolveFirstDeniedPermission(permissions: permissions);
    if (deniedPermission == null) {
      return;
    }

    _isShowing = true;
    try {
      await showDialog<void>(
        context: overlayContext,
        barrierDismissible: false,
        builder: (BuildContext context) {
          final content = _contentForPermission(deniedPermission);
          return AlertDialog(
            title: Text(content.title),
            content: Text(content.message),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(NECallKitUI.localizations.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  NECallKitPlatform.instance.startToPermissionSetting();
                },
                child: Text(NECallKitUI.localizations.goToSettings),
              ),
            ],
          );
        },
      );
    } finally {
      _isShowing = false;
    }
  }

  static Future<PermissionType?> _resolveFirstDeniedPermission({
    required List<PermissionType> permissions,
  }) async {
    final prioritizedPermissions = List<PermissionType>.from(permissions)
      ..sort((PermissionType left, PermissionType right) {
        if (left == PermissionType.microphone &&
            right == PermissionType.camera) {
          return -1;
        }
        if (left == PermissionType.camera &&
            right == PermissionType.microphone) {
          return 1;
        }
        return 0;
      });

    for (final permission in prioritizedPermissions) {
      final hasPermission = await Permission.has(
        permissions: <PermissionType>[permission],
      );
      if (!hasPermission) {
        return permission;
      }
    }
    return null;
  }

  static bool get _isChinese =>
      NECallKitUI.localizations.localeName.toLowerCase().startsWith('zh');

  static _PermissionPromptContent _contentForPermission(
    PermissionType permission,
  ) {
    final settingsPath =
        Platform.isMacOS ? 'Mac 的“系统设置-隐私与安全性' : 'Windows 的“设置-隐私和安全性';
    switch (permission) {
      case PermissionType.microphone:
        return _PermissionPromptContent(
          title: _isChinese ? '无法使用麦克风' : 'Microphone Unavailable',
          message: _isChinese
              ? '请在$settingsPath-麦克风”中允许应用访问您的麦克风。'
              : Platform.isMacOS
                  ? 'Allow microphone access for this app in Mac System Settings > Privacy & Security > Microphone.'
                  : 'Allow microphone access for this app in Windows Settings > Privacy & security > Microphone.',
        );
      case PermissionType.camera:
        return _PermissionPromptContent(
          title: _isChinese ? '无法使用相机' : 'Camera Unavailable',
          message: _isChinese
              ? '请在$settingsPath-相机”中允许应用访问您的相机。'
              : Platform.isMacOS
                  ? 'Allow camera access for this app in Mac System Settings > Privacy & Security > Camera.'
                  : 'Allow camera access for this app in Windows Settings > Privacy & security > Camera.',
        );
      case PermissionType.bluetooth:
        return _PermissionPromptContent(
          title: _isChinese ? '权限申请' : 'Permission Required',
          message: _isChinese
              ? '需要访问您的相关权限后才能继续当前操作。'
              : 'Required permissions must be enabled before continuing.',
        );
    }
  }
}

class _PermissionPromptContent {
  const _PermissionPromptContent({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;
}
