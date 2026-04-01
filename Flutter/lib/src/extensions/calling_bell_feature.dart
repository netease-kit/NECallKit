// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:netease_callkit_ui/src/platform/call_kit_platform_interface.dart';
import 'package:netease_callkit_ui/src/utils/preference.dart';

class CallingBellFeature {
  static const _tag = "CallingBellFeature";
  static FileSystem fileSystem = const LocalFileSystem();
  static String keyRingPath = "key_ring_path";
  static String package = "packages/";
  static String pluginName = "netease_callkit_ui/";
  static String assetsPrefix = "assets/audios/";
  static String callerRingName = "avchat_connecting.mp3";
  static String calledRingName = "avchat_ring.mp3";
  static bool cancelStartRing = false;

  /// 播放铃声（根据 CallState 中的角色自动选择铃声类型）
  static Future<void> startRing() async {
    CallKitUILog.i(_tag, 'startRing');
    await _startRingInternal(CallState.instance.selfUser.callRole);
  }

  /// 根据指定角色播放铃声
  ///
  /// [role] 通话角色，caller 播放呼叫提示音，called 播放来电铃声
  static Future<void> startRingByRole(NECallRole role) async {
    CallKitUILog.i(_tag, 'startRingByRole, role=$role');
    await _startRingInternal(role);
  }

  /// 播放铃声的内部实现
  static Future<void> _startRingInternal(NECallRole role) async {
    cancelStartRing = false;

    final bool isCalled = NECallRole.called == role;

    // 被叫方优先使用自定义铃声
    String filePath =
        await PreferenceUtils.getInstance().getString(keyRingPath);
    if (filePath.isNotEmpty && isCalled) {
      NECallKitPlatform.instance.startRing(filePath, isCalled: isCalled);
      return;
    }

    // 根据角色选择默认铃声
    final String tempDirectory = await getTempDirectory();
    final String ringName = isCalled ? calledRingName : callerRingName;
    filePath = "$tempDirectory/$ringName";

    // 加载资源到临时文件
    final file = fileSystem.file(filePath);
    if (!await file.exists()) {
      ByteData byteData =
          await loadAsset('$package$pluginName$assetsPrefix$ringName');
      await file.create();
      await file.writeAsBytes(byteData.buffer.asUint8List());
    }

    if (!cancelStartRing) {
      NECallKitPlatform.instance.startRing(file.path, isCalled: isCalled);
    }
  }

  static Future<String> getAssetsFilePath(String assetName) async {
    if (assetName.isEmpty) {
      return "";
    }
    final String tempDirectory = await getTempDirectory();
    String filePath = "$tempDirectory/$assetName";
    final file = fileSystem.file(filePath);
    if (!await file.exists()) {
      ByteData byteData = await loadAsset(assetName);
      await file.create(recursive: true);
      await file.writeAsBytes(byteData.buffer.asUint8List());
    }
    return file.path;
  }

  /// 预加载铃声文件到临时目录，避免首次播放时因文件 IO 导致铃声被截断
  static Future<void> preloadRingFiles() async {
    try {
      final String tempDirectory = await getTempDirectory();
      for (final ringName in [callerRingName, calledRingName]) {
        final filePath = "$tempDirectory/$ringName";
        final file = fileSystem.file(filePath);
        if (!await file.exists()) {
          ByteData byteData =
              await loadAsset('$package$pluginName$assetsPrefix$ringName');
          await file.create();
          await file.writeAsBytes(byteData.buffer.asUint8List());
          CallKitUILog.i(_tag, 'preloadRingFiles: $ringName copied to temp');
        }
      }
    } catch (e) {
      CallKitUILog.e(_tag, 'preloadRingFiles failed: $e');
    }
  }

  static Future<void> stopRing() async {
    CallKitUILog.i(_tag, 'CallingBellFeature stopRing');
    cancelStartRing = true;
    NECallKitPlatform.instance.stopRing();
  }

  //path: The format of the path parameter in the plugin is 'package$pluginName$assetsPrefix$assetsName'
  @visibleForTesting
  static Future<ByteData> loadAsset(String path) => rootBundle.load(path);

  @visibleForTesting
  static Future<String> getTempDirectory() async =>
      (await getTemporaryDirectory()).path;
}
