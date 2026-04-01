// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:netease_callkit_ui/src/event/event_notify.dart';
import 'package:netease_callkit_ui/src/data/constants.dart';
import 'package:netease_callkit_ui/src/ui/widget/calls/calls_widget.dart';

class NECallKitWidget extends StatefulWidget {
  final Function close;

  const NECallKitWidget({super.key, required this.close});

  @override
  State<NECallKitWidget> createState() => _NECallKitWidgetState();
}

class _NECallKitWidgetState extends State<NECallKitWidget>
    with WidgetsBindingObserver {
  static const String _tag = "NECallKitWidget";
  NEEventCallback? onCallEndCallBack;

  @override
  void initState() {
    super.initState();
    CallKitUILog.i(_tag, 'NECallKitWidget initState');
    WidgetsBinding.instance.addObserver(this);
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      CallManager.instance.startForegroundService(callType: CallState.instance.callType);
    }
    if (CallState.instance.selfUser.callStatus == NECallStatus.none) {
      Future.microtask(() {
        widget.close();
      });
    }
    onCallEndCallBack = (arg) {
      if (mounted) {
        widget.close();
      }
    };
    NEEventNotify().register(setStateEventOnCallEnd, onCallEndCallBack);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (CallState.instance.selfUser.callStatus == NECallStatus.none) {
        // 后台/锁屏期间通话已结束，恢复前台时关闭页面
        widget.close();
      } else {
        CallManager.instance.startForegroundService(callType: CallState.instance.callType);
      }
    }
    super.didChangeAppLifecycleState(state);
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
    WidgetsBinding.instance.removeObserver(this);
    NEEventNotify().unregister(setStateEventOnCallEnd, onCallEndCallBack);
    CallManager.instance.enableWakeLock(false);
  }
}
