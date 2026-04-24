// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';
import 'package:callkit_example/auth/login_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:callkit_example/l10n/app_localizations.dart';
import 'auth_manager.dart';
import 'auth_state.dart';
import '../../utils/loading.dart';
import '../../utils/toast_utils.dart';
import '../../constants/router_name.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class LoginRoute extends StatefulWidget {
  const LoginRoute({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<LoginRoute> {
  final TextEditingController _accountIdController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  /// 用于 OHOS 平台打开 URL 的 MethodChannel
  static const _urlLauncherChannel = MethodChannel('com.netease.callkit/url_launcher');

  /// 检测是否为 OHOS 平台
  bool get _isOhos {
    try {
      return Platform.operatingSystem == 'ohos';
    } catch (e) {
      return false;
    }
  }

  /// 打开文档 URL
  Future<void> _launchDocUrl(BuildContext context) async {
    const docUrl =
        'https://doc.yunxin.163.com/messaging2/guide/jU0Mzg0MTU?platform=client#%E7%AC%AC%E4%BA%8C%E6%AD%A5%E6%B3%A8%E5%86%8C-im-%E8%B4%A6%E5%8F%B7';
    
    try {
      if (_isOhos) {
        // OHOS 平台使用 MethodChannel 调用原生代码打开 URL
        await _urlLauncherChannel.invokeMethod('openUrl', {'url': docUrl});
      } else {
        // 其他平台使用 url_launcher
        final uri = Uri.parse(docUrl);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Failed to launch URL: $e');
      if (context.mounted) {
        ToastUtils.showToast(context, '无法打开链接: $e');
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _accountIdController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = Scaffold(
      backgroundColor: const Color.fromRGBO(239, 241, 244, 1),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 80),
            const Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.phone_android,
                size: 80,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            if (_buildAuthStateHint() != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xffFFF4E5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffF5C16C)),
                ),
                child: Text(
                  _buildAuthStateHint()!,
                  style: const TextStyle(
                    color: Color(0xff8A4B08),
                  ),
                ),
              ),
            GestureDetector(
              onTap: () => _launchDocUrl(context),
              child: Text(
                AppLocalizations.of(context)!.how_to_get_account_token,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 20,
                child: Text(AppLocalizations.of(context)!.sample_login_desc),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _accountIdController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.enter_account,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _tokenController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.enter_token,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Colors.blue.withAlpha((255.0 * 0.5).round());
                    }
                    return Colors.blue;
                  }),
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 13),
                  ),
                  shape: MaterialStateProperty.all(
                    const RoundedRectangleBorder(
                      side: BorderSide(color: Colors.blue, width: 0),
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                  ),
                ),
                onPressed: () {
                  final accountId = _accountIdController.text.trim();
                  if (accountId.isEmpty) {
                    ToastUtils.showToast(context,
                        AppLocalizations.of(context)!.please_enter_account);
                    return;
                  }
                  final token = _tokenController.text.trim();
                  if (token.isEmpty) {
                    ToastUtils.showToast(context,
                        AppLocalizations.of(context)!.please_enter_token);
                    return;
                  }
                  login(accountId, token);
                },
                child: Text(
                  AppLocalizations.of(context)!.start_exploring,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark, // 深色图标
        systemStatusBarContrastEnforced: false,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark, // 浅色图标
        systemNavigationBarContrastEnforced: false,
      ),
      child: child,
    );
  }

  void login(String accountId, String token) async {
    // 创建账号并登录
    print("createAccountThenLogin");
    LoadingUtil.showLoading();
    LoginInfo loginInfo = LoginInfo(
      accountId: accountId,
      accountToken: token,
      nickname: accountId,
      avatar: "",
    );

    AuthManager().loginCallKitWithToken(loginInfo).then((result) {
      print('loginCallKitWithToken result = ${result.code}');
      LoadingUtil.hideLoading();
      if (result.code == 0) {
        ToastUtils.showToast(
            context, AppLocalizations.of(context)!.login_success);
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(RouterName.homePage);
      } else {
        ToastUtils.showToast(context,
            "${AppLocalizations.of(context)!.login_failed} code = ${result.code}, msg = ${result.message}");
      }
    });
  }

  String? _buildAuthStateHint() {
    final snapshot = AuthStateManager().snapshot;
    final tip = snapshot.errorTip;
    if (snapshot.state == AuthState.kicked && tip != null && tip.isNotEmpty) {
      return '当前账号已被其他端顶下线：$tip';
    }
    if (snapshot.state == AuthState.tokenIllegal &&
        tip != null &&
        tip.isNotEmpty) {
      return '登录态已失效：$tip';
    }
    return null;
  }
}
