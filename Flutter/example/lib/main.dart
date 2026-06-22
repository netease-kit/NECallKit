// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:callkit_example/l10n/app_localizations.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:nim_core_v2/nim_core.dart';
import 'config/app_config.dart';
import 'base/device_manager.dart';
import 'auth/auth_manager.dart';
import 'utils/nav_register.dart';
import 'constants/router_name.dart';

const MethodChannel _desktopShutdownChannel =
    MethodChannel('callkit_example/app_shutdown');

bool _desktopShutdownPrepared = false;
const Duration _macDesktopShutdownSettleDelay = Duration(milliseconds: 500);

void main() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    _registerDesktopShutdownHandler();

    // 初始化应用配置
    await AppConfig().init();

    // 初始化设备管理器
    await DeviceManager().init();

    // 初始化认证管理器
    await AuthManager().init();

    runApp(const MyApp());
  }, (Object error, StackTrace stack) {
    debugPrint('crash exception: $error \ncrash stack: $stack');
  });
}

void _registerDesktopShutdownHandler() {
  _desktopShutdownChannel.setMethodCallHandler((call) async {
    if (call.method != 'prepareForExit') {
      throw MissingPluginException('Not implemented: ${call.method}');
    }
    await _prepareForDesktopExit();
    return null;
  });
}

Future<void> _prepareForDesktopExit() async {
  if (_desktopShutdownPrepared) {
    return;
  }
  _desktopShutdownPrepared = true;

  if (!(Platform.isMacOS || Platform.isWindows)) {
    return;
  }

  try {
    final result = await NECallEngine.instance.destroy();
    debugPrint('desktop exit destroy result: ${result.code}');
  } catch (error, stackTrace) {
    debugPrint(
      'desktop exit destroy error: $error\nstack: $stackTrace',
    );
  }

  try {
    final result = await NimCore.instance.releaseDesktop();
    debugPrint('desktop exit releaseDesktop result: ${result.code}');
  } catch (error, stackTrace) {
    debugPrint(
      'desktop exit releaseDesktop error: $error\nstack: $stackTrace',
    );
  }

  if (Platform.isMacOS) {
    // Give NIM/logger background teardown a moment to settle before the
    // process exits, otherwise macOS may still hit dylib finalizers mid-exit.
    await Future<void>.delayed(_macDesktopShutdownSettleDelay);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        NECallKitUI.delegate,
        ...AppLocalizations.localizationsDelegates
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      navigatorObservers: <NavigatorObserver>[
        // Demo only registers the shared public observer and does not install
        // any desktop-only navigation bypass.
        NECallKitUI.navigatorObserver,
      ],
      color: Colors.black,
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      themeMode: ThemeMode.light,
      home: const WelcomePage(),
      onGenerateRoute: (settings) {
        WidgetBuilder builder =
            RoutesRegister.routes(settings)[settings.name] as WidgetBuilder;
        return MaterialPageRoute(
          builder: (ctx) => builder(ctx),
          settings: RouteSettings(name: settings.name),
        );
      },
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    loadLoginInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.black);
  }

  void loadLoginInfo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      AuthManager().autoLogin().then((value) {
        if (!mounted) {
          return;
        }
        if (value) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            RouterName.homePage,
            (route) => false,
          );
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
            RouterName.loginPage,
            (route) => false,
          );
        }
      });
    });
  }
}
