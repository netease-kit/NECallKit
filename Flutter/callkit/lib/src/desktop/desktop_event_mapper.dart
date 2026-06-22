import '../api/models.dart';
import 'desktop_bridge.dart';

class DesktopEventMapper {
  const DesktopEventMapper();

  static const Map<int, NECallType> _bridgeCallTypes = <int, NECallType>{
    1: NECallType.audio,
    2: NECallType.video,
  };

  static const Map<int, NECallEngineStatus> _bridgeCallStates =
      <int, NECallEngineStatus>{
    0: NECallEngineStatus.idle,
    1: NECallEngineStatus.calling,
    2: NECallEngineStatus.called,
    3: NECallEngineStatus.inCall,
  };

  static const Map<int, NECallTerminalCode> _bridgeEndReasons =
      <int, NECallTerminalCode>{
    0: NECallTerminalCode.normal,
    1: NECallTerminalCode.tokenError,
    2: NECallTerminalCode.timeOut,
    3: NECallTerminalCode.busy,
    4: NECallTerminalCode.rtcInitError,
    5: NECallTerminalCode.joinRtcError,
    6: NECallTerminalCode.cancelErrorParam,
    7: NECallTerminalCode.callFailed,
    8: NECallTerminalCode.kicked,
    9: NECallTerminalCode.emptyUid,
    10: NECallTerminalCode.rtcDisconnected,
    11: NECallTerminalCode.callerCancel,
    12: NECallTerminalCode.calleeCancel,
    13: NECallTerminalCode.calleeReject,
    14: NECallTerminalCode.callerRejected,
    15: NECallTerminalCode.hangUp,
    16: NECallTerminalCode.beHangUp,
    17: NECallTerminalCode.otherRejected,
    18: NECallTerminalCode.otherAccepted,
    19: NECallTerminalCode.userRtcDisconnected,
    20: NECallTerminalCode.userRtcLeave,
    21: NECallTerminalCode.acceptFail,
  };

  static const Set<NECallTerminalCode> supportedBridgeEndReasons =
      <NECallTerminalCode>{
    NECallTerminalCode.normal,
    NECallTerminalCode.timeOut,
    NECallTerminalCode.busy,
    NECallTerminalCode.tokenError,
    NECallTerminalCode.rtcInitError,
    NECallTerminalCode.joinRtcError,
    NECallTerminalCode.rtcDisconnected,
    NECallTerminalCode.callerCancel,
    NECallTerminalCode.calleeCancel,
    NECallTerminalCode.calleeReject,
    NECallTerminalCode.callerRejected,
    NECallTerminalCode.hangUp,
    NECallTerminalCode.beHangUp,
    NECallTerminalCode.kicked,
    NECallTerminalCode.otherRejected,
    NECallTerminalCode.otherAccepted,
    NECallTerminalCode.userRtcDisconnected,
    NECallTerminalCode.userRtcLeave,
    NECallTerminalCode.acceptFail,
  };

  static const Map<int, NIMCallStatus> _bridgeRecordStates =
      <int, NIMCallStatus>{
    1: NIMCallStatus.completed,
    2: NIMCallStatus.cancelled,
    3: NIMCallStatus.rejected,
    4: NIMCallStatus.timeout,
    5: NIMCallStatus.busy,
  };

  static const NECallSwitchState bridgeDefaultTypeChangeState =
      NECallSwitchState.agree;

  NECallType mapBridgeCallType(int callType) {
    return _bridgeCallTypes[callType] ?? NECallType.none;
  }

  NECallEngineStatus mapBridgeCallState(int callState) {
    return _bridgeCallStates[callState] ?? NECallEngineStatus.idle;
  }

  NECallTerminalCode mapBridgeEndReason(int reasonCode) {
    return _bridgeEndReasons[reasonCode] ?? NECallTerminalCode.normal;
  }

  bool supportsBridgeEndReason(NECallTerminalCode reasonCode) {
    return supportedBridgeEndReasons.contains(reasonCode);
  }

  NECallTypeChangeInfo mapBridgeTypeChange(int callType) {
    // `desktop/bridge` currently only carries the target call type for this
    // event, so Flutter keeps the public payload shape by defaulting the
    // switch state to `agree`.
    return NECallTypeChangeInfo(
      callType: mapBridgeCallType(callType),
      state: bridgeDefaultTypeChangeState,
    );
  }

  NECallInfo mapBridgeCallInfo(
    DesktopBridgeCallInfo info, {
    String currentAccId = '',
  }) {
    final status = mapBridgeCallState(info.callStatus);
    final resolvedCurrentAccId =
        _firstNonEmpty(info.currentAccId, currentAccId) ?? '';
    return NECallInfo(
      callId: info.callId ?? '',
      currentAccId: resolvedCurrentAccId,
      callerInfo: _mapUserInfo(info.callerInfo),
      calleeInfo: _mapUserInfo(info.calleeInfo),
      callType: mapBridgeCallType(info.callType),
      signalInfo: _mapSignalInfo(info.signalInfo),
      rtcInfo: _mapRtcInfo(info.rtcInfo),
      callStatus: status,
    );
  }

  NECallConfig mapBridgeCallConfig(DesktopBridgeCallConfig config) {
    return NECallConfig(
      enableOffline: config.enableOffline,
      enableSwitchVideoConfirm: config.enableSwitchVideoConfirm,
      enableSwitchAudioConfirm: config.enableSwitchAudioConfirm,
    );
  }

  NERecordConfig mapBridgeRecordConfig({
    required String accId,
    required int callType,
    required int callState,
  }) {
    return NERecordConfig(
      accId: accId,
      callType: mapBridgeCallType(callType),
      callState: _bridgeRecordStates[callState] ?? NIMCallStatus.completed,
    );
  }

  NECallEndInfo mapCallEnd(NECallEndInfo info) {
    return NECallEndInfo(
      reasonCode: _normalizeReasonCode(info.reasonCode),
      callId: info.callId,
      extraString: info.extraString,
      message: info.message,
    );
  }

  NEInviteInfo mapReceiveInvited(NEInviteInfo info) {
    return NEInviteInfo(
      callerAccId: info.callerAccId,
      callType: info.callType,
      callId: info.callId,
      extraInfo: info.extraInfo,
      channelId: info.channelId,
    );
  }

  NECallTypeChangeInfo mapCallTypeChange(NECallTypeChangeInfo info) {
    return NECallTypeChangeInfo(
      callType: info.callType,
      state: info.state,
    );
  }

  NECallInfo mapCallConnected(NECallInfo info) {
    return NECallInfo(
      callId: info.callId,
      currentAccId: info.currentAccId,
      callerInfo: info.callerInfo,
      calleeInfo: info.calleeInfo,
      callType: info.callType,
      signalInfo: info.signalInfo,
      rtcInfo: info.rtcInfo,
      callStatus: info.callStatus,
    );
  }

  NECallEndInfo mapBridgeCallEnd({
    required int reasonCode,
    String? callId,
    String? extraString,
    String? message,
  }) {
    return NECallEndInfo(
      reasonCode: mapBridgeEndReason(reasonCode),
      callId: callId,
      extraString: extraString,
      message: message,
    );
  }

  NECallTerminalCode _normalizeReasonCode(NECallTerminalCode reasonCode) {
    switch (reasonCode) {
      case NECallTerminalCode.normal:
      case NECallTerminalCode.tokenError:
      case NECallTerminalCode.timeOut:
      case NECallTerminalCode.busy:
      case NECallTerminalCode.rtcInitError:
      case NECallTerminalCode.joinRtcError:
      case NECallTerminalCode.cancelErrorParam:
      case NECallTerminalCode.callFailed:
      case NECallTerminalCode.kicked:
      case NECallTerminalCode.emptyUid:
      case NECallTerminalCode.rtcDisconnected:
      case NECallTerminalCode.callerCancel:
      case NECallTerminalCode.calleeCancel:
      case NECallTerminalCode.calleeReject:
      case NECallTerminalCode.callerRejected:
      case NECallTerminalCode.hangUp:
      case NECallTerminalCode.beHangUp:
      case NECallTerminalCode.otherRejected:
      case NECallTerminalCode.otherAccepted:
      case NECallTerminalCode.userRtcDisconnected:
      case NECallTerminalCode.userRtcLeave:
      case NECallTerminalCode.acceptFail:
        return reasonCode;
    }
  }

  NEUserInfo? _mapUserInfo(DesktopBridgeCallUserInfo? userInfo) {
    final accId = userInfo?.accId;
    if (!_hasValue(accId)) {
      return null;
    }
    return NEUserInfo(accId: accId!, uid: userInfo?.uid ?? 0);
  }

  NESignalInfo? _mapSignalInfo(DesktopBridgeSignalInfo? signalInfo) {
    if (signalInfo == null) {
      return null;
    }
    return NESignalInfo(
      channelId: signalInfo.channelId,
      requestId: signalInfo.requestId,
      channelName: signalInfo.channelName,
      extraInfo: signalInfo.extraInfo,
      globalExtraCopy: signalInfo.globalExtraCopy,
    );
  }

  NERtcInfo? _mapRtcInfo(DesktopBridgeRtcInfo? rtcInfo) {
    if (rtcInfo == null) {
      return null;
    }
    return NERtcInfo(
      channelName: rtcInfo.channelName,
      token: rtcInfo.token,
      channelId: rtcInfo.cid,
      uid: rtcInfo.uid,
    );
  }

  bool _hasValue(String? value) {
    return value != null && value.isNotEmpty;
  }

  String? _firstNonEmpty(String? first, String? second) {
    if (_hasValue(first)) {
      return first;
    }
    if (_hasValue(second)) {
      return second;
    }
    return null;
  }
}
