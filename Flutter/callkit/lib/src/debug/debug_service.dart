// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.


import 'dart:io';
import 'package:netease_callkit/src/platform_compat.dart';

import 'package:flutter/cupertino.dart';
import 'package:hawk_meta/hawk_meta.dart';
import 'package:netease_common/netease_common.dart';
import 'package:nim_core_v2/nim_core.dart';

@visibleForTesting
@HawkEntryPoint()
class DebugService {
  static final DebugService _instance = DebugService._internal();

  factory DebugService() => _instance;

  DebugService._internal();

    Future<VoidResult> debugLogin(String appKey, String accountId, String token) async {

    late NIMSDKOptions options;
    if (Platform.isAndroid) {
      options = NIMAndroidSDKOptions(
        appKey: appKey,
      );
      //若需要使用云端会话，请提前开启云端会话
      //enableV2CloudConversation: true,
    } else if (Platform.isIOS) {
      options = NIMIOSSDKOptions(
        appKey: appKey,
        //若需要使用云端会话，请提前开启云端会话
        //enableV2CloudConversation: true,
        // apnsCername: certificateConfig?.apnsCername,
        // pkCername: certificateConfig?.pkCername,
      );
    } else if (CallkitPlatformCompat.isOhos) {
      options = NIMAndroidSDKOptions(
        appKey: appKey,
      );
    }
    final initRet = await NimCore.instance.initialize(options);
    if (initRet.code != 0) {
      return VoidResult(code: initRet.code, msg: initRet.errorDetails);
    }
    final loginRet = await NimCore.instance.loginService.login(
      accountId,
      token,
      NIMLoginOption(),
    );
    return VoidResult(code: loginRet.code, msg: loginRet.errorDetails);
  }

  Future<VoidResult> debugLogout() async {
    final logoutRet = await NimCore.instance.loginService.logout();
    return VoidResult(code: logoutRet.code, msg: logoutRet.errorDetails);
  }
}