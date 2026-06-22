// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:callkit_example/auth/auth_manager.dart';
import 'package:callkit_example/utils/global_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'call_record_service.dart';

/// CallRecordService的具体实现类
class CallRecordServiceImpl extends CallRecordService
    implements NERecordProvider {
  static final CallRecordServiceImpl _instance =
      CallRecordServiceImpl._internal();
  factory CallRecordServiceImpl() => _instance;
  CallRecordServiceImpl._internal();

  final AuthManager _authManager = AuthManager();
  final StreamController<bool> _recordProviderEnabledChanged =
      StreamController<bool>.broadcast();
  final StreamController<DemoRecordProviderPayload?>
      _recordProviderPayloadChanged =
      StreamController<DemoRecordProviderPayload?>.broadcast();
  bool _recordProviderPreferenceLoaded = false;
  bool _recordProviderEnabled = false;
  DemoRecordProviderPayload? _lastRecordProviderPayload;

  @override
  bool get isRecordProviderEnabled => _recordProviderEnabled;

  @override
  DemoRecordProviderPayload? get lastRecordProviderPayload =>
      _lastRecordProviderPayload;

  @override
  Future<String?> getCurrentAccountId() async {
    try {
      return _authManager.accountId;
    } catch (e) {
      print('Failed to get current account ID: $e');
      return null;
    }
  }

  /// 获取当前登录状态
  bool get isLoggedIn => _authManager.isLogined();

  /// 监听登录状态变化
  Stream<String?> get authInfoStream =>
      _authManager.authInfoStream().map((info) => info?.accountId);

  @override
  Stream<bool> recordProviderEnabledStream() {
    return _recordProviderEnabledChanged.stream;
  }

  @override
  Stream<DemoRecordProviderPayload?> recordProviderPayloadStream() {
    return _recordProviderPayloadChanged.stream;
  }

  @override
  Future<void> configureRecordProviderFromPreferences() async {
    if (!_recordProviderPreferenceLoaded) {
      _recordProviderEnabled = await GlobalPreferences().recordProviderEnabled;
      _recordProviderPreferenceLoaded = true;
    }
    await _applyRecordProviderEnabled(
      _recordProviderEnabled,
      persist: false,
    );
  }

  @override
  Future<void> setRecordProviderEnabled(bool enabled) async {
    await _applyRecordProviderEnabled(enabled, persist: true);
  }

  Future<void> _applyRecordProviderEnabled(
    bool enabled, {
    required bool persist,
  }) async {
    _recordProviderEnabled = enabled;
    if (persist) {
      await GlobalPreferences().setRecordProviderEnabled(enabled);
      _recordProviderPreferenceLoaded = true;
    }
    NECallEngine.instance.setCallRecordProvider(enabled ? this : null);
    debugPrint(
      'CallRecordServiceImpl: record provider mode='
      '${enabled ? "custom_onRecordSend" : "sdk_default"}',
    );
    _recordProviderEnabledChanged.add(_recordProviderEnabled);
    _recordProviderPayloadChanged.add(_lastRecordProviderPayload);
  }

  @override
  Future<DemoRecordProviderPayload> sendRecordWithProvider(
    NERecordConfig config,
  ) async {
    final payload = DemoRecordProviderPayload.fromRecordConfig(config);
    _lastRecordProviderPayload = payload;
    debugPrint(
      'CallRecordServiceImpl: provider payload '
      'accId=${payload.accId}, callType=${payload.callType}, '
      'callState=${payload.callState}, receivedAt=${payload.receivedAt}',
    );
    _recordProviderPayloadChanged.add(payload);
    return payload;
  }

  @override
  void onRecordSend(NERecordConfig config) {
    unawaited(sendRecordWithProvider(config));
  }
}
