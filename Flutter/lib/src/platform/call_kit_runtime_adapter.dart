import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';

import '../desktop/helper/desktop_helper_registry.dart';
import '../extensions/calling_bell_feature.dart';
import '../utils/permission.dart';

/// Dispatches call UI helpers by runtime, using desktop helpers on desktop
/// and shared Flutter fallbacks on other platforms.
class CallKitRuntimeAdapter {
  const CallKitRuntimeAdapter({
    DesktopHelperRegistry? helperRegistry,
    this.desktopRuntimeOverride,
  }) : _helperRegistry = helperRegistry;

  final DesktopHelperRegistry? _helperRegistry;
  final bool? desktopRuntimeOverride;

  DesktopHelperRegistry get _resolvedHelperRegistry =>
      _helperRegistry ?? DesktopHelperRegistry.instance;

  static List<String> get helperScopes => DesktopHelperRegistry.supportedScopes;

  bool get isDesktopRuntime {
    if (desktopRuntimeOverride != null) {
      return desktopRuntimeOverride!;
    }
    if (kIsWeb) {
      return false;
    }
    return Platform.isWindows || Platform.isMacOS;
  }

  bool get usesHelperOnlyBoundary =>
      isDesktopRuntime && helperScopes.every(_resolvedHelperRegistry.ownsScope);

  bool get handlesCoreCallSemantics => false;

  Future<PermissionResult> requestPermissions(NECallType type) {
    if (!isDesktopRuntime) {
      return Permission.request(type);
    }
    return _resolvedHelperRegistry.permission.requestCallPermissions(type);
  }

  Future<PermissionResult> requestCameraPermission() {
    if (!isDesktopRuntime) {
      return Permission.requestCamera();
    }
    return _resolvedHelperRegistry.permission.requestCameraPermission();
  }

  Future<bool> hasCallPermissions(NECallType type) {
    if (!isDesktopRuntime) {
      if (type == NECallType.video) {
        return Permission.has(
          permissions: [PermissionType.camera, PermissionType.microphone],
        );
      }
      return Permission.has(permissions: [PermissionType.microphone]);
    }
    return _resolvedHelperRegistry.permission.hasCallPermissions(type);
  }

  Future<bool> hasCameraPermission() {
    if (!isDesktopRuntime) {
      return Permission.has(permissions: const <PermissionType>[
        PermissionType.camera,
      ]);
    }
    return _resolvedHelperRegistry.permission.hasCameraPermission();
  }

  Future<void> startIncomingRing() {
    if (!isDesktopRuntime) {
      return CallingBellFeature.startRingByRole(NECallRole.called);
    }
    return _resolvedHelperRegistry.ring.startIncomingRing();
  }

  Future<void> startOutgoingRing() {
    if (!isDesktopRuntime) {
      return CallingBellFeature.startRing();
    }
    return _resolvedHelperRegistry.ring.startOutgoingRing();
  }

  Future<void> stopRing() {
    if (!isDesktopRuntime) {
      return CallingBellFeature.stopRing();
    }
    return _resolvedHelperRegistry.ring.stopRing();
  }
}
