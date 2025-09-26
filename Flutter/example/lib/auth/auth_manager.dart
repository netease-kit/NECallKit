// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'package:callkit_example/auth/proto/base_proto.dart';
import 'package:callkit_example/config/app_config.dart';
import 'package:callkit_example/settings/settings_config.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import '../utils/global_preferences.dart';
import '../auth/auth_state.dart';
import 'login_info.dart';
import 'package:netease_callkit/netease_callkit.dart';

class AuthManager {
  static const String _tag = 'AuthManager';

  factory AuthManager() => _instance ??= AuthManager._internal();

  static AuthManager? _instance;
  LoginInfo? _loginInfo;

  final StreamController<LoginInfo?> _authInfoChanged =
      StreamController.broadcast();

  AuthManager._internal();

  Future<void> init() async {
    var loginInfo = await GlobalPreferences().loginInfo;
    if (loginInfo == null || loginInfo.isEmpty) return;

    try {
      final cachedLoginInfo =
          LoginInfo.fromJson(jsonDecode(loginInfo) as Map<String, dynamic>);
      _authInfoChanged.add(cachedLoginInfo);
      _loginInfo = cachedLoginInfo;

      AuthStateManager().updateState(state: AuthState.init);
    } catch (e) {
      print('LoginInfo.fromJson exception = $e');
    }
  }

  String? get accountId => _loginInfo?.accountId;
  String? get nickName => _loginInfo?.nickname;
  String? get accountToken => _loginInfo?.accountToken;
  String? get avatar => _loginInfo?.avatar;

  Future<bool> autoLogin() async {
    if (_loginInfo == null || _loginInfo!.accountId.isEmpty) {
      return Future.value(false);
    }

    if (isLogined()) {
      print('autoLogin but isLogined, using cached login info');
      return Future.value(true);
    }

    AuthStateManager().updateState(state: AuthState.init);
    var result = await loginCallKitWithToken(_loginInfo!);
    return Future.value(result.code == 0);
  }

  Future<Result<void>> loginCallKitWithToken(LoginInfo loginInfo) async {
    var completer = Completer<Result<void>>();

    // 创建证书配置
    final certificateConfig = NECertificateConfig(
      apnsCername: AppConfig().pushCerName,
      pkCername: AppConfig().voipCerName,
    );

    final extraConfig = NEExtraConfig(
      lckConfig: NELCKConfig(
        enableLiveCommunicationKit: true,
        ringtoneName: 'avchat_ring.mp3',
      ),
    );

    NECallKitUI.instance.enableFloatWindow(SettingsConfig.enableFloatWindow);
    NECallKitUI.instance
        .enableIncomingBanner(SettingsConfig.showIncomingBanner);
    NECallKitUI.instance
        .login(AppConfig().appKey, loginInfo.accountId, loginInfo.accountToken,
            certificateConfig: certificateConfig, extraConfig: extraConfig)
        .then((value) {
      if (value.code == 0) {
        AuthStateManager().updateState(state: AuthState.authed);
        _syncAuthInfo(loginInfo);
      }
      return completer
          .complete(Result(code: value.code, msg: value.message ?? ''));
    });
    return completer.future;
  }

  void _syncAuthInfo(LoginInfo loginInfo) {
    _loginInfo = loginInfo;
    GlobalPreferences().setLoginInfo(jsonEncode(loginInfo.toJson()));
    _authInfoChanged.add(loginInfo);
  }

  void logout() {
    // CallKit 没有直接的 logout 方法
    _loginInfo = null;
    GlobalPreferences().setLoginInfo('{}');
    _authInfoChanged.add(_loginInfo);
    AuthStateManager().updateState(state: AuthState.init);
  }

  Stream<LoginInfo?> authInfoStream() {
    return _authInfoChanged.stream;
  }

  void tokenIllegal(String errorTip) {
    logout();
    AuthStateManager()
        .updateState(state: AuthState.tokenIllegal, errorTip: errorTip);
  }

  bool isLogined() {
    return AuthStateManager().state == AuthState.authed;
  }
}
