import 'dart:io';

import 'package:flutter/foundation.dart';

enum DesktopCallingRouteDecision {
  pushFlutterPage,
  waitForNavigatorBinding,
  skipDuplicatePage,
}

class DesktopUiReuseAdapter {
  const DesktopUiReuseAdapter({this.desktopRuntimeOverride});

  final bool? desktopRuntimeOverride;

  bool get isDesktopRuntime {
    if (desktopRuntimeOverride != null) {
      return desktopRuntimeOverride!;
    }
    if (kIsWeb) {
      return false;
    }
    return Platform.isWindows || Platform.isMacOS;
  }

  bool shouldReuseFlutterCallPages() {
    return isDesktopRuntime;
  }

  DesktopCallingRouteDecision resolveCallingRouteDecision({
    required bool hasNavigatorBinding,
    required bool isCallingPageOpen,
  }) {
    if (isCallingPageOpen) {
      return DesktopCallingRouteDecision.skipDuplicatePage;
    }
    if (!hasNavigatorBinding) {
      return DesktopCallingRouteDecision.waitForNavigatorBinding;
    }
    return DesktopCallingRouteDecision.pushFlutterPage;
  }

  bool canDriveCallingNavigation({
    required bool hasNavigatorBinding,
    bool isCallingPageOpen = false,
  }) {
    return resolveCallingRouteDecision(
          hasNavigatorBinding: hasNavigatorBinding,
          isCallingPageOpen: isCallingPageOpen,
        ) ==
        DesktopCallingRouteDecision.pushFlutterPage;
  }

  bool shouldUseDesktopNavigationOrchestration({
    required bool hasNavigatorBinding,
    bool isCallingPageOpen = false,
  }) {
    return isDesktopRuntime &&
        canDriveCallingNavigation(
          hasNavigatorBinding: hasNavigatorBinding,
          isCallingPageOpen: isCallingPageOpen,
        );
  }

  bool shouldAwaitNavigatorBinding({
    required bool hasNavigatorBinding,
    bool isCallingPageOpen = false,
  }) {
    return isDesktopRuntime &&
        resolveCallingRouteDecision(
              hasNavigatorBinding: hasNavigatorBinding,
              isCallingPageOpen: isCallingPageOpen,
            ) ==
            DesktopCallingRouteDecision.waitForNavigatorBinding;
  }

  bool shouldDelegatePlatformCoordinationToHelpers() {
    return isDesktopRuntime;
  }

  bool shouldShowSingleCallFloatWindowButton() {
    return !isDesktopRuntime;
  }

  bool shouldSyncCallStateToNative() {
    return !isDesktopRuntime;
  }
}
