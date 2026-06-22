// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:callkit_example/base/platform_compat.dart';
import 'package:callkit_example/settings/settings_config.dart';
import 'package:callkit_example/settings/settings_detail_widget.dart';
import 'package:callkit_example/utils/global_preferences.dart';
import 'package:callkit_example/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:callkit_example/l10n/app_localizations.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  bool get _isDesktopRuntime => Platform.isMacOS || Platform.isWindows;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        leading: IconButton(
            onPressed: () => _goBack(),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),
        child: ListView(
          children: [
            if (!_isDesktopRuntime) _getBasicSettingsWidget(),
            _getCallParamsSettingsWidget(),
          ],
        ),
      ),
    );
  }

  _getBasicSettingsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: Text(
            AppLocalizations.of(context)!.settings,
            style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.normal,
                color: Colors.black54),
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.enable_floating,
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              Switch(
                  value: SettingsConfig.enableFloatWindow,
                  onChanged: (value) {
                    setState(() {
                      SettingsConfig.enableFloatWindow = value;
                      NECallKitUI.instance
                          .enableFloatWindow(SettingsConfig.enableFloatWindow);
                    });
                  })
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '应用外悬浮窗（画中画）',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              Switch(
                  value: SettingsConfig.enableFloatWindowOutOfApp,
                  onChanged: (value) {
                    setState(() {
                      SettingsConfig.enableFloatWindowOutOfApp = value;
                      GlobalPreferences().setEnableFloatWindowOutOfApp(value);
                      NECallKitUI.instance.enableFloatWindowOutOfApp(
                          SettingsConfig.enableFloatWindowOutOfApp);
                    });
                  })
            ],
          ),
        ),
        if (Platform.isAndroid || Platform.isIOS || PlatformCompat.isOhos)
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.show_incoming_banner,
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
                Switch(
                    value: SettingsConfig.showIncomingBanner,
                    onChanged: (value) {
                      setState(() {
                        SettingsConfig.showIncomingBanner = value;
                        GlobalPreferences().setShowIncomingBanner(value);
                        NECallKitUI.instance.enableIncomingBanner(
                            SettingsConfig.showIncomingBanner);
                      });
                    })
              ],
            ),
          ),
        const SizedBox(height: 10),
      ],
    );
  }

  _getCallParamsSettingsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: Text(
            AppLocalizations.of(context)!.call_custom_setiings,
            style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.normal,
                color: Colors.black54),
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.timeout,
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: TextField(
                      autofocus: true,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: '${SettingsConfig.timeout}',
                        border: InputBorder.none,
                      ),
                      onChanged: ((value) async {
                        try {
                          final timeout =
                              SettingsConfig.normalizeTimeout(int.parse(value));
                          SettingsConfig.timeout = timeout;
                          await NECallEngine.instance.setTimeout(timeout);
                        } catch (e) {
                          debugPrint('Failed to set timeout: $e');
                        }
                      })))
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.extended_info,
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              InkWell(
                  onTap: () => _goDetailSettings(SettingWidgetType.extendInfo),
                  child: Row(children: [
                    Text(
                      SettingsConfig.extendInfo.isEmpty
                          ? AppLocalizations.of(context)!.not_set
                          : SettingsConfig.extendInfo,
                      maxLines: 1,
                      style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(width: 10),
                    const Text('>')
                  ]))
            ],
          ),
        ),
        if (_isDesktopRuntime) _getDesktopLogPathWidget(),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _getDesktopLogPathWidget() {
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.desktop_log_directory,
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ),
          OutlinedButton(
            onPressed: _openDesktopLogDirectory,
            child: Text(AppLocalizations.of(context)!.open),
          ),
        ],
      ),
    );
  }

  Future<String> _resolveDesktopLogDirectory() async {
    if (Platform.isMacOS) {
      final home = Platform.environment['HOME'];
      if (home != null && home.isNotEmpty) {
        return '$home/Library/Application Support/NIM/log/CallKitCore';
      }
      final appSupportDirectory = await getApplicationSupportDirectory();
      return '${appSupportDirectory.path}/NIM/log/CallKitCore';
    }

    if (Platform.isWindows) {
      final localAppData = Platform.environment['LOCALAPPDATA'];
      if (localAppData != null && localAppData.isNotEmpty) {
        return '$localAppData\\NIM\\log\\CallKitCore';
      }
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null && userProfile.isNotEmpty) {
        return '$userProfile\\AppData\\Local\\NIM\\log\\CallKitCore';
      }
      final appSupportDirectory = await getApplicationSupportDirectory();
      return '${appSupportDirectory.path}\\NIM\\log\\CallKitCore';
    }

    throw UnsupportedError(
        'Desktop log directory is only available on desktop');
  }

  Future<void> _openDesktopLogDirectory() async {
    try {
      final logDirectory = await _resolveDesktopLogDirectory();
      await Directory(logDirectory).create(recursive: true);

      if (Platform.isWindows) {
        await _openWindowsDirectory(logDirectory);
        return;
      }

      final launched = await launchUrl(
        Uri.directory(logDirectory, windows: Platform.isWindows),
        mode: LaunchMode.externalApplication,
      );
      if (launched) {
        return;
      }

      ProcessResult? result;
      if (Platform.isMacOS) {
        result = await Process.run('open', [logDirectory]);
      }
      if (result == null || result.exitCode != 0) {
        final errorMessage = result == null
            ? 'launchUrl returned false for $logDirectory'
            : result.stderr.toString();
        throw Exception(errorMessage);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ToastUtils.showToast(
        context,
        '${AppLocalizations.of(context)!.open_log_directory_failed}: $error',
      );
    }
  }

  Future<void> _openWindowsDirectory(String logDirectory) async {
    final windowsPath = logDirectory.replaceAll('/', '\\');
    final windir = Platform.environment['WINDIR'];
    final explorerPath = windir == null || windir.isEmpty
        ? 'explorer.exe'
        : '$windir\\explorer.exe';

    final process = await Process.start(
      explorerPath,
      [windowsPath],
      mode: ProcessStartMode.detached,
    );
    if (process.pid <= 0) {
      throw Exception('Windows Explorer failed to open directory: $logDirectory');
    }
  }

  _goBack() {
    Navigator.of(context).pop();
  }

  _goDetailSettings(SettingWidgetType widgetType) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return SettingsDetailWidget(widgetType: widgetType);
      },
    ));
  }
}
