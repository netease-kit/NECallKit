// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:netease_callkit/netease_callkit.dart';
import 'package:netease_callkit_ui/src/call_define.dart';
import 'package:netease_callkit_ui/src/data/constants.dart';
import 'package:netease_callkit_ui/src/event/event_notify.dart';
import 'package:netease_callkit_ui/src/impl/call_manager.dart';
import 'package:netease_callkit_ui/src/impl/call_state.dart';
import 'package:netease_callkit_ui/src/platform/call_kit_platform_interface.dart';
import 'package:netease_callkit_ui/src/utils/permission.dart';

class MethodChannelNECallKit extends NECallKitPlatform {
  MethodChannelNECallKit() {
    methodChannel.setMethodCallHandler((call) async {
      _handleNativeCall(call);
    });
  }

  @visibleForTesting
  final methodChannel = const MethodChannel('call_kit_ui');

  @override
  Future<void> startForegroundService(NECallType type) async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod(
          'startForegroundService', <String, dynamic>{'mediaType': type.index});
    }
  }

  @override
  Future<void> stopForegroundService() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel
          .invokeMethod('stopForegroundService', <String, dynamic>{});
    }
  }

  @override
  Future<void> startRing(String filePath, {bool isCalled = false}) async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel
          .invokeMethod('startRing', <String, dynamic>{'filePath': filePath, 'isCalled': isCalled});
    }
  }

  @override
  Future<void> stopRing() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('stopRing', <String, dynamic>{});
    }
  }

  @override
  Future<void> updateCallStateToNative() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      var remoteUserList = <dynamic>[];
      for (var i = 0; i < CallState.instance.remoteUserList.length; ++i) {
        remoteUserList.add(CallState.instance.remoteUserList[i].toJson());
      }

      await methodChannel
          .invokeMethod('updateCallStateToNative', <String, dynamic>{
        'selfUser': CallState.instance.selfUser.toJson(),
        'remoteUserList':
            remoteUserList.isNotEmpty ? remoteUserList : <dynamic>[],
        'scene': CallState.instance.scene.index,
        'mediaType': CallState.instance.callType.index,
        'startTime': CallState.instance.startTime,
        'camera': CallState.instance.camera.index,
        'isCameraOpen': CallState.instance.isCameraOpen,
        'isMicrophoneMute': CallState.instance.isMicrophoneMute,
      });
    }
  }

  @override
  Future<void> startFloatWindow() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('startFloatWindow', <String, dynamic>{});
    }
  }

  @override
  Future<void> stopFloatWindow() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('stopFloatWindow', <String, dynamic>{});
    }
  }

  @override
  Future<bool> hasFloatPermission() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      final result = await methodChannel
          .invokeMethod('hasFloatPermission', <String, dynamic>{});
      return result as bool? ?? false;
    } else {
      return false;
    }
  }

  @override
  Future<void> requestFloatPermission() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel
          .invokeMethod('requestFloatPermission', <String, dynamic>{});
    }
  }

  @override
  Future<bool> hasBackgroundStartPermission() async {
    if (!kIsWeb && Platform.isAndroid) {
      final result = await methodChannel
          .invokeMethod('hasBackgroundStartPermission', <String, dynamic>{});
      return result as bool? ?? false;
    }
    return false;
  }

  @override
  Future<bool> isAppInForeground() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      final result = await methodChannel
          .invokeMethod('isAppInForeground', <String, dynamic>{});
      return result as bool? ?? false;
    } else {
      return false;
    }
  }

  @override
  Future<bool> showIncomingBanner() async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel
            .invokeMethod('showIncomingBanner', <String, dynamic>{});
      } else {
        return false;
      }
    } on PlatformException catch (_) {
      return false;
    } on Exception catch (_) {
      return false;
    }
    return true;
  }

  Future<bool> initResources(Map resources) async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel.invokeMethod(
            'initResources', <String, dynamic>{'resources': resources});
      } else {
        return false;
      }
    } on PlatformException catch (_) {
      return false;
    } on Exception catch (_) {
      return false;
    }
    return true;
  }

  @override
  Future<void> openMicrophone() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('openMicrophone', <String, dynamic>{});
    }
  }

  @override
  Future<void> closeMicrophone() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('closeMicrophone', <String, dynamic>{});
    }
  }

  @override
  Future<bool> hasPermissions(
      {required List<PermissionType> permissions}) async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      var permissionsList = <int>[];
      for (var element in permissions) {
        permissionsList.add(element.index);
      }
      final result = await methodChannel.invokeMethod(
          'hasPermissions', <String, dynamic>{'permission': permissionsList});
      return result as bool? ?? false;
    } else {
      return false;
    }
  }

  @override
  Future<PermissionResult> requestPermissions(
      {required List<PermissionType> permissions,
      String title = '',
      String description = '',
      String settingsTip = ''}) async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        var permissionsList = <int>[];
        for (var element in permissions) {
          permissionsList.add(element.index);
        }
        final dynamicResult = await methodChannel
            .invokeMethod('requestPermissions', <String, dynamic>{
          'permission': permissionsList,
          'title': title,
          'description': description,
          'settingsTip': settingsTip
        });
        final result = dynamicResult as int? ?? PermissionResult.denied.index;
        if (result == PermissionResult.granted.index) {
          return PermissionResult.granted;
        } else if (result == PermissionResult.denied.index) {
          return PermissionResult.denied;
        } else {
          return PermissionResult.requesting;
        }
      } else {
        return PermissionResult.denied;
      }
    } on PlatformException catch (_) {
      return PermissionResult.denied;
    } on Exception catch (_) {
      return PermissionResult.denied;
    }
  }

  @override
  Future<void> pullBackgroundApp() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel
          .invokeMethod('pullBackgroundApp', <String, dynamic>{});
    }
  }

  @override
  Future<void> openLockScreenApp() async {
    if (!kIsWeb && Platform.isAndroid) {
      await methodChannel
          .invokeMethod('openLockScreenApp', <String, dynamic>{});
    }
  }

  @override
  Future<void> enableWakeLock(bool enable) async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel
          .invokeMethod('enableWakeLock', <String, dynamic>{'enable': enable});
    }
  }

  @override
  Future<bool> setupPIP() async {
    if (!kIsWeb && Platform.isIOS) {
      final result =
          await methodChannel.invokeMethod('setupPIP', <String, dynamic>{});
      return result as bool? ?? false;
    }
    return false;
  }

  @override
  Future<void> disposePIP() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('disposePIP', <String, dynamic>{});
    }
  }

  @override
  Future<bool> startPIP() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      final result =
          await methodChannel.invokeMethod('startPIP', <String, dynamic>{});
      return result as bool? ?? false;
    }
    return false;
  }

  @override
  Future<void> stopPIP() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('stopPIP', <String, dynamic>{});
    }
  }

  @override
  Future<bool> isScreenLocked() async {
    if (!kIsWeb && (Platform.isAndroid)) {
      final result = await methodChannel
          .invokeMethod('isScreenLocked', <String, dynamic>{});
      return result as bool? ?? false;
    }
    return false;
  }

  @override
  Future<bool> isSamsungDevice() async {
    if (!kIsWeb && Platform.isAndroid) {
      final result = await methodChannel
          .invokeMethod('isSamsungDevice', <String, dynamic>{});
      return result as bool? ?? false;
    }
    return false;
  }

  @override
  Future<void> startToPermissionSetting() async {
    if (!kIsWeb && Platform.isAndroid) {
      await methodChannel
          .invokeMethod('startToPermissionSetting', <String, dynamic>{});
    }
  }

  @override
  Future<void> setIncomingBannerEnabled(bool enable) async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel
          .invokeMethod('setIncomingBannerEnabled', {'enable': enable});
    }
  }

  @override
  Future<void> cancelIncomingBanner() async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel.invokeMethod('cancelIncomingBanner', {});
      }
    } on PlatformException catch (_) {
      // ignore
    } on Exception catch (_) {
      // ignore
    }
  }

  void _handleNativeCall(MethodCall call) {
    debugPrint(
        'CallHandler method:${call.method}, arguments:${call.arguments}');
    switch (call.method) {
      case 'backCallingPageFromFloatWindow':
        _backCallingPageFromFloatWindow();
        break;
      case 'launchCallingPageFromIncomingBanner':
        _launchCallingPageFromIncomingBanner();
        break;
      case 'bannerAcceptTapped':
        _handleBannerAccept();
        break;
      case 'bannerRejectTapped':
        _handleBannerReject();
        break;
      case 'appEnterForeground':
        _appEnterForeground();
        break;
      case 'appEnterBackground':
        _appEnterBackground();
        break;
      case 'voipChangeMute':
        _handleVoipChangeMute(call);
        break;
      case 'voipChangeAudioPlaybackDevice':
        _handleVoipChangeAudioPlaybackDevice(call);
        break;
      case 'voipChangeHangup':
        _handleVoipHangup();
        break;
      case 'voipChangeAccept':
        _handleVoipAccept();
        break;
      default:
        debugPrint('flutter: MethodNotImplemented ${call.method}');
        break;
    }
  }

  void _backCallingPageFromFloatWindow() {
    CallManager.instance.backCallingPageFormFloatWindow();
  }

  void _launchCallingPageFromIncomingBanner() {
    CallState.instance.isInNativeIncomingBanner = false;
    CallManager.instance.clearBannerActiveState();
    if (CallState.instance.selfUser.callStatus != NECallStatus.none) {
      // 直接进入通话页，不走 launchCallingPage 避免重新触发 banner 逻辑死循环
      CallManager.instance.enterCallingPageFromBanner();
    }
  }

  void _handleBannerAccept() {
    CallManager.instance.handleBannerAccept();
  }

  void _handleBannerReject() {
    CallManager.instance.handleBannerReject();
  }

  void _appEnterForeground() {
    CallManager.instance.handleAppEnterForeground();
  }

  void _appEnterBackground() {
    CallManager.instance.handleAppEnterBackground();
  }

  void _handleVoipChangeMute(MethodCall call) {
    if (CallState.instance.selfUser.callStatus != NECallStatus.none) {
      final mute = call.arguments['mute'] as bool? ?? false;
      CallState.instance.isMicrophoneMute = mute;
      mute
          ? CallManager.instance.closeMicrophone(false)
          : CallManager.instance.openMicrophone(false);
      NEEventNotify().notify(setStateEvent);
    }
  }

  void _handleVoipChangeAudioPlaybackDevice(MethodCall call) {
    // if (CallState.instance.selfUser.callStatus != NECallStatus.none) {
    //   CallState.instance.audioDevice = call.arguments['audioPlaybackDevice'];
    //   CallManager.instance
    //       .setSpeakerphoneOn(CallState.instance.audioDevice);
    //   INENotification().notify(setStateEvent);
    // }
  }

  void _handleVoipHangup() {
    if (CallState.instance.selfUser.callStatus == NECallStatus.waiting) {
      CallManager.instance.reject();
    } else if (CallState.instance.selfUser.callStatus == NECallStatus.accept) {
      CallManager.instance.hangup();
    }
  }

  void _handleVoipAccept() {
    if (CallState.instance.selfUser.callStatus == NECallStatus.waiting) {
      CallManager.instance.accept();
    }
  }
}
