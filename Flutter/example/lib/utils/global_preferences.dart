// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:shared_preferences/shared_preferences.dart';

class GlobalPreferences {
  static const String _keyLoginInfo = 'login_info';
  static const String _keyShowIncomingBanner = 'show_incoming_banner';
  static const String _keyRecordProviderEnabled = 'record_provider_enabled';
  static const String _keyCallApiAutoTestEnabled = 'call_api_auto_test_enabled';
  static const String _keyCallApiDelayedTestEnabled =
      'call_api_delayed_test_enabled';
  static const String _keyEnableFloatWindowOutOfApp =
      'enable_float_window_out_of_app';

  static GlobalPreferences? _instance;
  SharedPreferences? _prefs;

  factory GlobalPreferences() => _instance ??= GlobalPreferences._internal();

  GlobalPreferences._internal();

  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<String?> get loginInfo async {
    await _ensureInitialized();
    return _prefs?.getString(_keyLoginInfo);
  }

  Future<void> setLoginInfo(String loginInfo) async {
    await _ensureInitialized();
    await _prefs?.setString(_keyLoginInfo, loginInfo);
  }

  Future<bool> get showIncomingBanner async {
    await _ensureInitialized();
    return _prefs?.getBool(_keyShowIncomingBanner) ?? false;
  }

  Future<void> setShowIncomingBanner(bool value) async {
    await _ensureInitialized();
    await _prefs?.setBool(_keyShowIncomingBanner, value);
  }

  Future<bool> get recordProviderEnabled async {
    await _ensureInitialized();
    return _prefs?.getBool(_keyRecordProviderEnabled) ?? false;
  }

  Future<void> setRecordProviderEnabled(bool value) async {
    await _ensureInitialized();
    await _prefs?.setBool(_keyRecordProviderEnabled, value);
  }

  Future<bool> get callApiAutoTestEnabled async {
    await _ensureInitialized();
    return _prefs?.getBool(_keyCallApiAutoTestEnabled) ?? false;
  }

  Future<void> setCallApiAutoTestEnabled(bool value) async {
    await _ensureInitialized();
    await _prefs?.setBool(_keyCallApiAutoTestEnabled, value);
  }

  Future<bool> get callApiDelayedTestEnabled async {
    await _ensureInitialized();
    return _prefs?.getBool(_keyCallApiDelayedTestEnabled) ?? false;
  }

  Future<void> setCallApiDelayedTestEnabled(bool value) async {
    await _ensureInitialized();
    await _prefs?.setBool(_keyCallApiDelayedTestEnabled, value);
  }

  Future<bool> get enableFloatWindowOutOfApp async {
    await _ensureInitialized();
    return _prefs?.getBool(_keyEnableFloatWindowOutOfApp) ?? false;
  }

  Future<void> setEnableFloatWindowOutOfApp(bool value) async {
    await _ensureInitialized();
    await _prefs?.setBool(_keyEnableFloatWindowOutOfApp, value);
  }
}
