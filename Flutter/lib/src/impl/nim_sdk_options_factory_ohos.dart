import 'dart:io';
import 'package:netease_callkit_ui/src/platform/platform_compat.dart';

import 'package:nim_core_v2/nim_core.dart';

NIMSDKOptions buildNIMSDKOptions({
  required String appKey,
  String? apnsCername,
  String? pkCername,
}) {
  if (PlatformCompat.isOhos) {
    return NIMOHOSSDKOptions(
      appKey: appKey,
    );
  }
  if (Platform.isAndroid) {
    return NIMAndroidSDKOptions(
      appKey: appKey,
      //若需要使用云端会话，请提前开启云端会话
      //enableV2CloudConversation: true,
    );
  }
  if (Platform.isIOS) {
    return NIMIOSSDKOptions(
      appKey: appKey,
      //若需要使用云端会话，请提前开启云端会话
      //enableV2CloudConversation: true,
      apnsCername: apnsCername,
      pkCername: pkCername,
    );
  }
  throw UnsupportedError(
    'Unsupported platform for NIM SDK options: ${Platform.operatingSystem}',
  );
}
