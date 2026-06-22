import 'desktop_permission_helper.dart';
import 'desktop_ring_helper.dart';

class DesktopHelperRegistry {
  factory DesktopHelperRegistry({
    DesktopPermissionHelper? permission,
    DesktopRingHelper? ring,
  }) {
    final resolvedPermission = permission ?? const DesktopPermissionHelper();
    return DesktopHelperRegistry._(
      permission: resolvedPermission,
      ring: ring ?? const DesktopRingHelper(),
    );
  }

  const DesktopHelperRegistry._({
    required this.permission,
    required this.ring,
  });

  static final DesktopHelperRegistry instance = DesktopHelperRegistry();

  static const List<String> supportedScopes = <String>[
    'permission',
    'ring',
  ];

  final DesktopPermissionHelper permission;
  final DesktopRingHelper ring;

  bool ownsScope(String scope) => supportedScopes.contains(scope);
}
