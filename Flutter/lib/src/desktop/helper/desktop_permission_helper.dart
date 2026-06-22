import 'package:netease_callkit/netease_callkit.dart';

import '../../utils/permission.dart';
import 'desktop_permission_prompt.dart';

class DesktopPermissionHelper {
  const DesktopPermissionHelper();

  List<PermissionType> requiredPermissionsForCall(NECallType type) {
    if (type == NECallType.video) {
      return const <PermissionType>[
        PermissionType.camera,
        PermissionType.microphone,
      ];
    }
    return const <PermissionType>[PermissionType.microphone];
  }

  Future<PermissionResult> requestCallPermissions(NECallType type) async {
    final result = await Permission.request(type);
    if (result != PermissionResult.granted) {
      await DesktopPermissionPrompt.showForPermissions(
        requiredPermissionsForCall(type),
      );
    }
    return result;
  }

  Future<PermissionResult> requestCameraPermission() async {
    final result = await Permission.requestCamera();
    if (result != PermissionResult.granted) {
      await DesktopPermissionPrompt.showForPermissions(
        const <PermissionType>[PermissionType.camera],
      );
    }
    return result;
  }

  Future<bool> hasCallPermissions(NECallType type) {
    return Permission.has(permissions: requiredPermissionsForCall(type));
  }

  Future<bool> hasCameraPermission() {
    return Permission.has(permissions: const <PermissionType>[
      PermissionType.camera,
    ]);
  }
}
