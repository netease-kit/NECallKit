import '../../call_define.dart';
import '../../extensions/calling_bell_feature.dart';

class DesktopRingHelper {
  const DesktopRingHelper();

  Future<void> startIncomingRing() async {
    await _startRingForRole(NECallRole.called);
  }

  Future<void> startOutgoingRing() async {
    await _startRingForRole(NECallRole.caller);
  }

  Future<void> _startRingForRole(NECallRole role) async {
    await stopRing();
    await CallingBellFeature.startRingByRole(role);
  }

  Future<void> stopRing() {
    return CallingBellFeature.stopRing();
  }
}
