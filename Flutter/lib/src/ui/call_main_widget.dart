// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:netease_callkit_ui/src/data/constants.dart';
import 'package:netease_callkit_ui/src/event/event_notify.dart';
import 'package:netease_callkit_ui/src/ui/widget/calls/calls_widget.dart';

bool shouldForceCloseDesktopCallingPage({
  required NECallStatus localStatus,
  required NECallEngineStatus? nativeStatus,
  required int consecutiveIdlePolls,
  int idlePollThreshold = 2,
}) {
  final nativeIsIdle =
      nativeStatus == null || nativeStatus == NECallEngineStatus.idle;
  if (!nativeIsIdle) {
    return false;
  }
  if (localStatus == NECallStatus.none) {
    return true;
  }
  return consecutiveIdlePolls >= idlePollThreshold;
}

class NECallKitWidget extends StatefulWidget {
  final Function close;

  const NECallKitWidget({super.key, required this.close});

  @override
  State<NECallKitWidget> createState() => _NECallKitWidgetState();
}

class _NECallKitWidgetState extends State<NECallKitWidget>
    with WidgetsBindingObserver {
  static const String _tag = 'NECallKitWidget';
  static const Duration _desktopCallStateSyncInterval =
      Duration(milliseconds: 500);
  static const int _desktopIdlePollThreshold = 2;
  NEEventCallback? onCallEndCallBack;
  Timer? _desktopCallStateSyncTimer;
  bool _desktopCallStateSyncInFlight = false;
  int _desktopIdlePolls = 0;

  @override
  void initState() {
    super.initState();
    CallKitUILog.i(_tag, 'NECallKitWidget initState');
    WidgetsBinding.instance.addObserver(this);
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      CallManager.instance
          .startForegroundService(callType: CallState.instance.callType);
    }
    if (CallState.instance.selfUser.callStatus == NECallStatus.none) {
      Future.microtask(() {
        CallKitUILog.i(
          _tag,
          'initState detected callStatus.none, closing calling page',
        );
        widget.close();
      });
    }
    onCallEndCallBack = (arg) {
      if (mounted) {
        CallKitUILog.i(
          _tag,
          'received setStateEventOnCallEnd, closing calling page',
        );
        widget.close();
      }
    };
    NEEventNotify().register(setStateEventOnCallEnd, onCallEndCallBack);
    _startDesktopCallStateSyncIfNeeded();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (CallState.instance.selfUser.callStatus == NECallStatus.none) {
        // 后台/锁屏期间通话已结束，恢复前台时关闭页面
        CallKitUILog.i(
          _tag,
          'app resumed with callStatus.none, closing calling page',
        );
        widget.close();
      } else {
        CallManager.instance
            .startForegroundService(callType: CallState.instance.callType);
      }
      _startDesktopCallStateSyncIfNeeded();
    }
    super.didChangeAppLifecycleState(state);
  }

  void _startDesktopCallStateSyncIfNeeded() {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.macOS &&
            defaultTargetPlatform != TargetPlatform.windows)) {
      return;
    }
    _desktopCallStateSyncTimer ??= Timer.periodic(
      _desktopCallStateSyncInterval,
      (_) => unawaited(_syncDesktopCallState()),
    );
    unawaited(_syncDesktopCallState());
  }

  Future<void> _syncDesktopCallState() async {
    if (!mounted || _desktopCallStateSyncInFlight) {
      return;
    }
    _desktopCallStateSyncInFlight = true;
    try {
      final callInfo = await NECallEngine.instance.getCallInfo();
      if (!mounted) {
        return;
      }
      final nativeStatus = callInfo?.callStatus;
      final nativeIsIdle =
          nativeStatus == null || nativeStatus == NECallEngineStatus.idle;
      if (!nativeIsIdle) {
        _desktopIdlePolls = 0;
        return;
      }

      _desktopIdlePolls++;
      if (!shouldForceCloseDesktopCallingPage(
        localStatus: CallState.instance.selfUser.callStatus,
        nativeStatus: nativeStatus,
        consecutiveIdlePolls: _desktopIdlePolls,
        idlePollThreshold: _desktopIdlePollThreshold,
      )) {
        return;
      }

      CallKitUILog.i(
        _tag,
        'desktop native call already idle, force closing stale calling page: '
        'nativeStatus=$nativeStatus, localStatus=${CallState.instance.selfUser.callStatus}, '
        'currentCallId=${CallState.instance.currentCallId}, idlePolls=$_desktopIdlePolls',
      );
      _desktopCallStateSyncTimer?.cancel();
      _desktopCallStateSyncTimer = null;
      CallState.instance.cleanState();
      NEEventNotify().notify(setStateEventOnCallEnd);
    } finally {
      _desktopCallStateSyncInFlight = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: CallsWidget(close: widget.close),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    CallKitUILog.i(_tag, 'NECallKitWidget dispose');
    _desktopCallStateSyncTimer?.cancel();
    _desktopCallStateSyncTimer = null;
    WidgetsBinding.instance.removeObserver(this);
    NEEventNotify().unregister(setStateEventOnCallEnd, onCallEndCallBack);
    CallManager.instance.enableWakeLock(false);
  }
}
