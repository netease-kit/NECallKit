// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:netease_callkit_ui/src/desktop/desktop_ui_reuse_adapter.dart';
import 'package:netease_callkit_ui/src/impl/boot.dart';
import 'package:netease_callkit_ui/src/platform/call_kit_runtime_adapter.dart';
import 'package:netease_callkit_ui/src/ui/call_main_widget.dart';

class NECallKitNavigatorObserver extends NavigatorObserver {
  static const _tag = 'NECallKitNavigatorObserver';
  static final NECallKitNavigatorObserver _instance =
      NECallKitNavigatorObserver();
  static const CallKitRuntimeAdapter _runtimeAdapter = CallKitRuntimeAdapter();
  static const DesktopUiReuseAdapter _desktopUiReuseAdapter =
      DesktopUiReuseAdapter();
  static bool isClose = true;
  static CallPage currentPage = CallPage.none;
  Route<void>? _callingPageRoute;

  static NECallKitNavigatorObserver getInstance() {
    return _instance;
  }

  NECallKitNavigatorObserver() {
    CallKitUILog.i(_tag, 'NECallKitNavigatorObserver Init');
    final _ = Boot.instance;
  }

  bool _isTrackedCallingPageRoute(Route<dynamic>? route) {
    return route != null && identical(route, _callingPageRoute);
  }

  void _resetCallingPageTracking(String reason) {
    CallKitUILog.i(
      _tag,
      'resetCallingPageTracking reason=$reason '
      'currentPage=$currentPage isClose=$isClose '
      'hasTrackedRoute=${_callingPageRoute != null}',
    );
    _callingPageRoute = null;
    currentPage = CallPage.none;
    isClose = true;
  }

  void resetCallingPageState({String reason = 'manual_reset'}) {
    if (currentPage != CallPage.callingPage &&
        isClose &&
        _callingPageRoute == null) {
      return;
    }
    _resetCallingPageTracking(reason);
  }

  @visibleForTesting
  void debugTrackCallingPageRouteForTest(Route<void>? route) {
    _callingPageRoute = route;
  }

  void enterCallingPage() {
    final attachedNavigator = navigator;
    final routeDecision = _desktopUiReuseAdapter.resolveCallingRouteDecision(
      hasNavigatorBinding: attachedNavigator != null,
      isCallingPageOpen: !isClose || currentPage == CallPage.callingPage,
    );
    CallKitUILog.i(
      _tag,
      'NECallKitNavigatorObserver enterCallingPage decision=$routeDecision',
    );
    switch (routeDecision) {
      case DesktopCallingRouteDecision.pushFlutterPage:
        break;
      case DesktopCallingRouteDecision.waitForNavigatorBinding:
        CallKitUILog.i(
          _tag,
          'NECallKitNavigatorObserver enterCallingPage skipped: navigator is null',
        );
        return;
      case DesktopCallingRouteDecision.skipDuplicatePage:
        CallKitUILog.i(
          _tag,
          'NECallKitNavigatorObserver enterCallingPage skipped: calling page already open',
        );
        return;
    }
    currentPage = CallPage.callingPage;
    final callingPageRoute = MaterialPageRoute<void>(builder: (widget) {
      return NECallKitWidget(close: () {
        CallKitUILog.i(
          _tag,
          'calling page close callback: isClose=$isClose, currentPage=$currentPage',
        );
        if (!isClose) {
          isClose = true;
          CallManager.instance.stopForegroundService();
          unawaited(_runtimeAdapter.stopRing());
          NECallKitNavigatorObserver.getInstance().exitCallingPage();
        } else {
          CallKitUILog.i(
            _tag,
            'calling page close callback skipped: page already marked closed',
          );
        }
      });
    });
    _callingPageRoute = callingPageRoute;
    attachedNavigator!.push(callingPageRoute);
    isClose = false;
  }

  void exitCallingPage({String reason = 'manual_exit'}) async {
    CallKitUILog.i(
        _tag,
        'NECallKitNavigatorObserver exitCallingPage reason=$reason '
        '[currentPage：$currentPage, isClose=$isClose]');
    if (currentPage == CallPage.callingPage && _callingPageRoute != null) {
      final attachedNavigator = navigator;
      final callingPageRoute = _callingPageRoute;
      if (attachedNavigator != null && callingPageRoute != null) {
        attachedNavigator.popUntil((route) {
          return route == callingPageRoute || route.isFirst;
        });
        if (callingPageRoute.isCurrent) {
          attachedNavigator.pop();
        }
      }
    } else if (currentPage == CallPage.callingPage) {
      CallKitUILog.i(
        _tag,
        'NECallKitNavigatorObserver exitCallingPage skipped navigator pop: '
        'tracked route missing',
      );
    }
    _resetCallingPageTracking(reason);
  }

  void _handleCallingPageRouteDetached(
    Route<dynamic>? route,
    String reason,
  ) {
    if (_isTrackedCallingPageRoute(route)) {
      _resetCallingPageTracking(reason);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _handleCallingPageRouteDetached(route, 'didPop');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _handleCallingPageRouteDetached(route, 'didRemove');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _handleCallingPageRouteDetached(oldRoute, 'didReplace');
  }
}

enum CallPage { none, callingPage }
