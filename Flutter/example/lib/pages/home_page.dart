// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:callkit_example/auth/login_page.dart';
import 'package:callkit_example/l10n/app_localizations.dart';
import 'package:callkit_example/pages/group_call_page.dart';
import 'package:callkit_example/pages/single_call_page.dart';
import 'package:callkit_example/service/call_record_service.dart';
import 'package:callkit_example/service/call_record_service_impl.dart';
import 'package:callkit_example/settings/settings_config.dart';
import 'package:callkit_example/utils/toast_utils.dart';
import 'package:callkit_example/utils/record_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:nim_core_v2/nim_core.dart';
import 'package:permission_handler/permission_handler.dart';

import '../auth/auth_manager.dart';
import '../auth/auth_state.dart';

class HomePageRoute extends StatefulWidget {
  const HomePageRoute({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomePageRouteState();
  }
}

class _HomePageRouteState extends State<HomePageRoute> {
  static const _tag = "_HomePageRouteState";

  String _version = 'Unknown';
  final _callkitPlugin = NECallEngine.instance;
  late final NECallEngineDelegate _delegate;
  late StreamSubscription _messageSubscription;
  late StreamSubscription _messageModifiedSubscription;
  StreamSubscription? _authInfoSubscription;
  StreamSubscription<AuthStateSnapshot>? _authStateSubscription;
  StreamSubscription<bool>? _recordProviderEnabledSubscription;
  StreamSubscription<DemoRecordProviderPayload?>?
      _recordProviderPayloadSubscription;
  final CallRecordServiceImpl _callRecordService = CallRecordServiceImpl();
  bool get _isDesktopRuntime => Platform.isMacOS || Platform.isWindows;
  bool _recordProviderEnabled = false;
  int _storedRecordCount = 0;
  DemoRecordProviderPayload? _lastRecordProviderPayload;

  @override
  void initState() {
    super.initState();
    _messageSubscription = NimCore.instance.messageService.onReceiveMessages
        .listen(_handleRecordMessages);
    _messageModifiedSubscription = NimCore
        .instance.messageService.onReceiveMessagesModified
        .listen(_handleRecordMessages);

    // 订阅 AuthManager 用户信息变更事件
    _authInfoSubscription = AuthManager().authInfoStream().listen((loginInfo) {
      if (mounted) {
        setState(() {});
      }
      _refreshRecordStatus();
    });
    _authStateSubscription =
        AuthManager().authStateStream().listen(_handleAuthStateChanged);
    _recordProviderEnabledSubscription =
        _callRecordService.recordProviderEnabledStream().listen((enabled) {
      if (!mounted) {
        return;
      }
      setState(() {
        _recordProviderEnabled = enabled;
      });
    });
    _recordProviderPayloadSubscription =
        _callRecordService.recordProviderPayloadStream().listen((payload) {
      if (!mounted) {
        return;
      }
      setState(() {
        _lastRecordProviderPayload = payload;
      });
    });

    _delegate = NECallEngineDelegate(
      onLCKAccept: (NELCKAcceptResult result) {
        if (!mounted) {
          return;
        }
        ToastUtils.showFloatingToast(
          context,
          'LCK Accept: code=${result.code}, msg=${result.msg ?? "success"}',
        );
      },
      onLCKHangup: (NELCKHangupResult result) {
        if (!mounted) {
          return;
        }
        ToastUtils.showFloatingToast(
          context,
          'LCK Hangup: code=${result.code}, msg=${result.msg ?? "success"}',
        );
      },
    );
    _callkitPlugin.addCallDelegate(_delegate);

    getVersion();
    _requestNotificationPermissions();
    // 页面显示时更新用户信息（昵称和头像）
    updateUserInfo();
    _restoreRecordProviderStatus();
    _refreshRecordStatus();
  }

  void _requestNotificationPermissions() async {
    if (_isDesktopRuntime) {
      return;
    }
    [
      Permission.notification,
    ].request();
  }

  @override
  void dispose() {
    _messageSubscription.cancel();
    _messageModifiedSubscription.cancel();
    _authInfoSubscription?.cancel();
    _callkitPlugin.removeCallDelegate(_delegate);
    _authStateSubscription?.cancel();
    _recordProviderEnabledSubscription?.cancel();
    _recordProviderPayloadSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleRecordMessages(List<NIMMessage> messages) async {
    for (final message in messages) {
      final record = await RecordUtils.parseForCallRecord(message);
      if (record != null) {
        await _addCallRecord(record);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [_getUserInfo(), _getAppInfo(), _getBtnWidget()],
            ),
          )),
    );
  }

  _getUserInfo() {
    return Positioned(
        left: 10,
        top: 50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: Text(
                "${AppLocalizations.of(context)!.login_info}：",
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            Row(
              children: [
                Container(
                    width: 55,
                    height: 55,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(27.5)),
                    ),
                    child: InkWell(
                      child: Image(
                        image: NetworkImage(
                          (AuthManager().avatar?.isNotEmpty == true)
                              ? AuthManager().avatar!
                              : SettingsConfig.defaultAvatar,
                        ),
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stackTrace) =>
                            Image.asset('images/icon_avatar.png'),
                      ),
                      onTap: () => _showDialog(),
                    )),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    AuthManager().nickName ?? '',
                    style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.normal,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onDoubleTap: () {
                      final accountId = AuthManager().accountId;
                      if (accountId != null) {
                        Clipboard.setData(ClipboardData(text: accountId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Account ID copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'accountId: ${AuthManager().accountId}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                  )
                ])
              ],
            )
          ],
        ));
  }

  _getAppInfo() {
    return Positioned(
        left: 10,
        top: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: Text(
                "${AppLocalizations.of(context)!.app_info}:",
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(
              child: Text("Version:$_version"),
            ),
            const SizedBox(height: 8),
            SizedBox(
              child: Text("LoginEntry:${_buildLoginEntryStatus()}"),
            ),
            SizedBox(
              child: Text("Navigator:${_buildNavigatorStatus()}"),
            ),
            SizedBox(
              child: Text("RecordMode:${_buildRecordProviderStatus()}"),
            ),
            SizedBox(
              child: Text("StoredRecords:$_storedRecordCount"),
            ),
            SizedBox(
              child: Text(
                "Timeout:${SettingsConfig.timeout}s (default ${SettingsConfig.defaultTimeoutSeconds}s / max ${SettingsConfig.maxTimeoutSeconds}s)",
              ),
            ),
          ],
        ));
  }

  Future<void> getVersion() async {
    try {
      final version = await _callkitPlugin.getVersion();
      if (!mounted) {
        return;
      }
      setState(() {
        _version = version;
      });
    } catch (error) {
      CallKitUILog.i(_tag, 'getVersion failed: $error');
    }
  }

  String _buildLoginEntryStatus() {
    if (AuthManager().isLogined()) {
      return 'NECallKitUI.instance.login -> ready';
    }
    return 'NECallKitUI.instance.login -> pending';
  }

  String _buildNavigatorStatus() {
    if (NECallKitUI.instance.canDriveCallingNavigation) {
      return 'NECallKitUI.navigatorObserver -> attached';
    }
    return 'NECallKitUI.navigatorObserver -> waiting for binding';
  }

  String _buildRecordProviderStatus() {
    if (_recordProviderEnabled) {
      return 'custom onRecordSend';
    }
    return 'sdk default send';
  }

  _getBtnWidget() {
    return Positioned(
        left: 0,
        bottom: 32,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 5 / 6,
              child: Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _recordProviderEnabled,
                        title: const Text('Custom Record Provider'),
                        subtitle: Text(
                          _recordProviderEnabled
                              ? 'onRecordSend is enabled, demo host owns record dispatch.'
                              : 'SDK default record sending is enabled.',
                        ),
                        onChanged: _setRecordProviderEnabled,
                      ),
                      Text(
                        'Last provider payload: '
                        '${RecordUtils.describeRecordProviderPayload(_lastRecordProviderPayload)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 52,
              width: MediaQuery.of(context).size.width * 5 / 6,
              child: ElevatedButton(
                  onPressed: () => _goSingleCallWidget(),
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(const Color(0xff056DF6)),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_outline_outlined),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context)!.single_call,
                        style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ],
                  )),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              width: MediaQuery.of(context).size.width * 5 / 6,
              child: ElevatedButton(
                  onPressed:
                      _isDesktopRuntime ? null : () => _goGroupCallWidget(),
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.disabled)) {
                        return const Color(0xffA9D8B7);
                      }
                      return const Color(0xff28A745);
                    }),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group_outlined),
                      SizedBox(width: 10),
                      Text(
                        '群呼',
                        style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ],
                  )),
            ),
            if (_isDesktopRuntime)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Desktop demo currently supports single call only. Group call remains mobile-only.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ));
  }

  _showDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(AppLocalizations.of(context)!.logout),
            actions: [
              CupertinoDialogAction(
                  child: Text(AppLocalizations.of(context)!.cancel),
                  onPressed: () => Navigator.of(context).pop()),
              CupertinoDialogAction(
                  child: Text(AppLocalizations.of(context)!.confirm),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _logout();
                  })
            ],
          );
        });
  }

  _logout() {
    AuthManager().logout();
    NECallKitUI.navigatorObserver.navigator?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (widget) {
      return const LoginRoute();
    }), (route) => false);
  }

  _goSingleCallWidget() async {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return const SingleCallWidget();
      },
    ));
  }

  _goGroupCallWidget() async {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return const GroupCallPage();
      },
    ));
  }

  // 添加通话记录并保存
  Future<void> _addCallRecord(CallRecord record) async {
    CallKitUILog.i(_tag, "_addCallRecord: $record");
    await _callRecordService.addRecordToCurrentAccount(record);
    await _refreshRecordStatus();
  }

  /// 更新用户信息
  Future<void> updateUserInfo() async {
    final accountId = AuthManager().accountId;
    if (accountId == null || accountId.isEmpty) {
      CallKitUILog.i(_tag, "updateUserInfo: accountId is null or empty");
      return;
    }

    try {
      final userInfo =
          await NimCore.instance.userService.getUserList([accountId]);
      if (userInfo.data?.isNotEmpty ?? false) {
        final user = userInfo.data?.first;
        // 使用 AuthManager 的接口更新用户信息
        AuthManager().updateUserInfo(
          nickname: user?.name,
          avatar: user?.avatar,
        );
        // 更新 UI（如果 widget 还在 mounted 状态）
        if (mounted) {
          setState(() {});
        }
        CallKitUILog.i(_tag,
            "updateUserInfo: updated - nickname: ${user?.name}, avatar: ${user?.avatar}");
      } else {
        CallKitUILog.i(_tag, "updateUserInfo: userInfo data is empty");
      }
    } catch (e) {
      CallKitUILog.i(_tag, "updateUserInfo: error - $e");
    }
  }

  Future<void> _restoreRecordProviderStatus() async {
    await _callRecordService.configureRecordProviderFromPreferences();
    if (!mounted) {
      return;
    }
    setState(() {
      _recordProviderEnabled = _callRecordService.isRecordProviderEnabled;
      _lastRecordProviderPayload = _callRecordService.lastRecordProviderPayload;
    });
  }

  Future<void> _refreshRecordStatus() async {
    final count = await _callRecordService.getCurrentAccountRecordCount();
    if (!mounted) {
      return;
    }
    setState(() {
      _storedRecordCount = count;
    });
  }

  Future<void> _setRecordProviderEnabled(bool enabled) async {
    await _callRecordService.setRecordProviderEnabled(enabled);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enabled
              ? 'Custom record provider enabled'
              : 'SDK default record sending restored',
        ),
      ),
    );
  }

  void _handleAuthStateChanged(AuthStateSnapshot snapshot) {
    if (!mounted) {
      return;
    }
    if ((snapshot.state == AuthState.kicked ||
            snapshot.state == AuthState.tokenIllegal) &&
        snapshot.errorTip != null &&
        snapshot.errorTip!.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(snapshot.errorTip!)),
      );
    }
  }
}
