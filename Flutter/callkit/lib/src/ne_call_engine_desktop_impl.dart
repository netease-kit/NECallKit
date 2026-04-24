import 'dart:ffi';
import 'dart:io';

// ignore_for_file: sdk_version_since

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ffi/ffi.dart';
import 'package:netease_common/netease_common.dart';

import 'api/models.dart';
import 'desktop/desktop_bridge.dart';
import 'desktop/desktop_event_mapper.dart';
import 'desktop/desktop_platform_guard.dart';
import 'desktop/ffi_bindings.dart';

class NECallEngineDesktopImpl {
  NECallEngineDesktopImpl._();

  static final NECallEngineDesktopImpl instance = NECallEngineDesktopImpl._();

  static const int _unsupportedCode = -1;
  static const MethodChannel _macosVideoViewChannel =
      MethodChannel('ne_call_kit/macos_video_view');

  void Function(NEInviteInfo info)? _onReceiveInvited;
  void Function(NECallEndInfo info)? _onCallEnd;
  void Function(NECallInfo info)? _onCallConnected;
  void Function(NECallTypeChangeInfo info)? _onCallTypeChange;
  void Function(bool available, String userId)? _onVideoAvailable;
  void Function(bool muted, String userId)? _onVideoMuted;
  void Function(bool muted, String userId)? _onAudioMuted;
  void Function(bool muted)? _onLocalAudioMuted;
  void Function()? _onRtcInitEnd;
  void Function(NERecordConfig config)? _onRecordSend;
  void Function(String eventName, String jsonData)? _onRtcRaw;
  String? _lastKnownCallId;

  DesktopBridge get bridge => DesktopBridge.instance;
  DesktopEventMapper get eventMapper => const DesktopEventMapper();

  bool get isDesktopRuntime {
    if (kIsWeb) {
      return false;
    }
    return DesktopPlatformGuard.instance.isSupportedPlatform(
      Platform.operatingSystem,
    );
  }

  void bindEventHandlers({
    void Function(NEInviteInfo info)? onReceiveInvited,
    void Function(NECallEndInfo info)? onCallEnd,
    void Function(NECallInfo info)? onCallConnected,
    void Function(NECallTypeChangeInfo info)? onCallTypeChange,
    void Function(bool available, String userId)? onVideoAvailable,
    void Function(bool muted, String userId)? onVideoMuted,
    void Function(bool muted, String userId)? onAudioMuted,
    void Function(bool muted)? onLocalAudioMuted,
    void Function()? onRtcInitEnd,
    void Function(NERecordConfig config)? onRecordSend,
    void Function(String eventName, String jsonData)? onRtcRaw,
  }) {
    _onReceiveInvited = onReceiveInvited;
    _onCallEnd = onCallEnd;
    _onCallConnected = onCallConnected;
    _onCallTypeChange = onCallTypeChange;
    _onVideoAvailable = onVideoAvailable;
    _onVideoMuted = onVideoMuted;
    _onAudioMuted = onAudioMuted;
    _onLocalAudioMuted = onLocalAudioMuted;
    _onRtcInitEnd = onRtcInitEnd;
    _onRecordSend = onRecordSend;
    _onRtcRaw = onRtcRaw;
  }

  VoidResult setup(NESetupConfig config) {
    if (!isDesktopRuntime) {
      return _unsupported('setup');
    }
    try {
      DesktopPlatformGuard.instance.ensureSupportedPlatform(
        Platform.operatingSystem,
      );
      bridge.ensureCreated();
      bridge.setEventListener(handleNativeEvent);
      bridge.ensureEventCallbackBound();
      final result = bridge.setup(config);
      return _toVoidResult(result, 'setup');
    } catch (error, stackTrace) {
      debugPrint('NECallEngineDesktopImpl.setup error: $error\n$stackTrace');
      return _unsupported('setup', message: error.toString());
    }
  }

  String? getVersion() {
    if (!isDesktopRuntime) {
      return null;
    }
    return bridge.getVersion();
  }

  Future<NEResult<NECallInfo>> call(
    String accId,
    NECallType callType, {
    String? extraInfo,
    String? rtcChannelName,
    String? globalExtraCopy,
    NECallPushConfig? pushConfig,
  }) async {
    if (!isDesktopRuntime) {
      return _unsupportedCall('call');
    }
    try {
      final result = await bridge.call(
        accId: accId,
        callType: callType,
        extraInfo: extraInfo,
        rtcChannelName: rtcChannelName,
        globalExtraCopy: globalExtraCopy,
        pushConfig: pushConfig,
      );
      final callInfo = result.code == 0
          ? (result.callInfo != null
              ? eventMapper.mapBridgeCallInfo(result.callInfo!)
              : getCallInfo())
          : null;
      _rememberCallId(callInfo?.callId);
      return NEResult<NECallInfo>(
        code: result.code,
        msg: result.message,
        data: callInfo,
      );
    } catch (error, stackTrace) {
      debugPrint('NECallEngineDesktopImpl.call error: $error\n$stackTrace');
      return _unsupportedCall('call', message: error.toString());
    }
  }

  Future<NEResult<NECallInfo>> accept() async {
    if (!isDesktopRuntime) {
      return _unsupportedCall('accept');
    }
    try {
      final result = await bridge.accept();
      final callInfo = result.code == 0
          ? (result.callInfo != null
              ? eventMapper.mapBridgeCallInfo(result.callInfo!)
              : getCallInfo())
          : null;
      _rememberCallId(callInfo?.callId);
      return NEResult<NECallInfo>(
        code: result.code,
        msg: result.message,
        data: callInfo,
      );
    } catch (error, stackTrace) {
      debugPrint('NECallEngineDesktopImpl.accept error: $error\n$stackTrace');
      return _unsupportedCall('accept', message: error.toString());
    }
  }

  Future<VoidResult> hangup({String? channelId, String? extraString}) async {
    if (!isDesktopRuntime) {
      return _unsupported('hangup');
    }
    try {
      final result = await bridge.hangup(
        channelId: channelId,
        extraString: extraString,
      );
      return VoidResult(code: result.code, msg: result.message);
    } catch (error, stackTrace) {
      debugPrint('NECallEngineDesktopImpl.hangup error: $error\n$stackTrace');
      return _unsupported('hangup', message: error.toString());
    }
  }

  VoidResult switchCallType(NECallType callType, NECallSwitchState state) {
    if (!isDesktopRuntime) {
      return _unsupported('switchCallType');
    }
    try {
      final result = bridge.switchCallType(callType, state);
      return _toVoidResult(result, 'switchCallType');
    } catch (error, stackTrace) {
      debugPrint(
        'NECallEngineDesktopImpl.switchCallType error: $error\n$stackTrace',
      );
      return _unsupported('switchCallType', message: error.toString());
    }
  }

  VoidResult setTimeout(int time) {
    if (!isDesktopRuntime) {
      return _unsupported('setTimeout');
    }
    try {
      final result = bridge.setTimeout(time);
      return _toVoidResult(result, 'setTimeout');
    } catch (error, stackTrace) {
      debugPrint(
          'NECallEngineDesktopImpl.setTimeout error: $error\n$stackTrace');
      return _unsupported('setTimeout', message: error.toString());
    }
  }

  VoidResult setCallConfig({
    required bool enableOffline,
    required bool enableSwitchVideoConfirm,
    required bool enableSwitchAudioConfirm,
  }) {
    if (!isDesktopRuntime) {
      return _unsupported('setCallConfig');
    }
    try {
      final result = bridge.setCallConfig(
        enableOffline: enableOffline,
        enableSwitchVideoConfirm: enableSwitchVideoConfirm,
        enableSwitchAudioConfirm: enableSwitchAudioConfirm,
      );
      return _toVoidResult(result, 'setCallConfig');
    } catch (error, stackTrace) {
      debugPrint(
        'NECallEngineDesktopImpl.setCallConfig error: $error\n$stackTrace',
      );
      return _unsupported('setCallConfig', message: error.toString());
    }
  }

  NECallConfig? getCallConfig() {
    if (!isDesktopRuntime) {
      return null;
    }
    final config = bridge.getCallConfig();
    if (config == null) {
      return null;
    }
    return eventMapper.mapBridgeCallConfig(config);
  }

  NECallInfo? getCallInfo() {
    if (!isDesktopRuntime) {
      return null;
    }
    final info = bridge.getCallInfo();
    if (info == null) {
      return null;
    }
    return eventMapper.mapBridgeCallInfo(info);
  }

  VoidResult destroy() {
    if (!isDesktopRuntime) {
      return _unsupported('destroy');
    }
    try {
      bridge.setEventListener(null);
      bridge.releaseHandle();
      return const VoidResult(code: 0, msg: 'ok');
    } catch (error, stackTrace) {
      debugPrint('NECallEngineDesktopImpl.destroy error: $error\n$stackTrace');
      return _unsupported('destroy', message: error.toString());
    }
  }

  VoidResult setCallRecordProvider(bool enabled) {
    if (!isDesktopRuntime) {
      return _unsupported('setCallRecordProvider');
    }
    try {
      final result = bridge.setCallRecordProvider(enabled);
      return _toVoidResult(result, 'setCallRecordProvider');
    } catch (error, stackTrace) {
      debugPrint(
        'NECallEngineDesktopImpl.setCallRecordProvider error: $error\n$stackTrace',
      );
      return _unsupported('setCallRecordProvider', message: error.toString());
    }
  }

  VoidResult enableLocalVideo(bool enabled) {
    if (!isDesktopRuntime) {
      return _unsupported('enableLocalVideo');
    }
    try {
      final result = bridge.enableLocalVideo(enabled);
      return _toVoidResult(result, 'enableLocalVideo');
    } catch (error, stackTrace) {
      debugPrint(
        'NECallEngineDesktopImpl.enableLocalVideo error: $error\n$stackTrace',
      );
      return _unsupported('enableLocalVideo', message: error.toString());
    }
  }

  VoidResult muteLocalVideo(bool muted) {
    if (!isDesktopRuntime) {
      return _unsupported('muteLocalVideo');
    }
    try {
      final result = bridge.muteLocalVideo(muted);
      return _toVoidResult(result, 'muteLocalVideo');
    } catch (error, stackTrace) {
      debugPrint(
        'NECallEngineDesktopImpl.muteLocalVideo error: $error\n$stackTrace',
      );
      return _unsupported('muteLocalVideo', message: error.toString());
    }
  }

  VoidResult muteLocalAudio(bool muted) {
    if (!isDesktopRuntime) {
      return _unsupported('muteLocalAudio');
    }
    try {
      final result = bridge.muteLocalAudio(muted);
      return _toVoidResult(result, 'muteLocalAudio');
    } catch (error, stackTrace) {
      debugPrint(
        'NECallEngineDesktopImpl.muteLocalAudio error: $error\n$stackTrace',
      );
      return _unsupported('muteLocalAudio', message: error.toString());
    }
  }

  VoidResult switchCamera() {
    if (!isDesktopRuntime) {
      return _unsupported('switchCamera');
    }
    try {
      final result = bridge.switchCamera();
      return _toVoidResult(result, 'switchCamera');
    } catch (error, stackTrace) {
      debugPrint(
        'NECallEngineDesktopImpl.switchCamera error: $error\n$stackTrace',
      );
      return _unsupported('switchCamera', message: error.toString());
    }
  }

  List<NEDesktopVideoDevice> getVideoCaptureDevices() {
    if (!isDesktopRuntime) {
      return const <NEDesktopVideoDevice>[];
    }
    return bridge
        .listVideoCaptureDevices()
        .map(
          (device) => NEDesktopVideoDevice(
            deviceId: device.deviceId,
            deviceName: device.deviceName,
          ),
        )
        .toList(growable: false);
  }

  String? getCurrentVideoCaptureDeviceId() {
    if (!isDesktopRuntime) {
      return null;
    }
    return bridge.getCurrentVideoCaptureDeviceId();
  }

  VoidResult setVideoCaptureDevice(String deviceId) {
    if (!isDesktopRuntime) {
      return _unsupported('setVideoCaptureDevice');
    }
    try {
      final result = bridge.setVideoCaptureDevice(deviceId);
      return _toVoidResult(result, 'setVideoCaptureDevice');
    } catch (error, stackTrace) {
      debugPrint(
        'NECallEngineDesktopImpl.setVideoCaptureDevice error: $error\n$stackTrace',
      );
      return _unsupported('setVideoCaptureDevice', message: error.toString());
    }
  }

  List<NEDesktopAudioDevice> getAudioRecordingDevices() {
    if (!isDesktopRuntime) {
      return const <NEDesktopAudioDevice>[];
    }
    return bridge
        .listAudioRecordingDevices()
        .map(
          (device) => NEDesktopAudioDevice(
            deviceId: device.deviceId,
            deviceName: device.deviceName,
          ),
        )
        .toList(growable: false);
  }

  String? getCurrentAudioRecordingDeviceId() {
    if (!isDesktopRuntime) {
      return null;
    }
    return bridge.getCurrentAudioRecordingDeviceId();
  }

  VoidResult setAudioRecordingDevice(String deviceId) {
    if (!isDesktopRuntime) {
      return _unsupported('setAudioRecordingDevice');
    }
    try {
      final result = bridge.setAudioRecordingDevice(deviceId);
      return _toVoidResult(result, 'setAudioRecordingDevice');
    } catch (error, stackTrace) {
      debugPrint(
        'NECallEngineDesktopImpl.setAudioRecordingDevice error: $error\n$stackTrace',
      );
      return _unsupported('setAudioRecordingDevice', message: error.toString());
    }
  }

  List<NEDesktopAudioDevice> getAudioPlaybackDevices() {
    if (!isDesktopRuntime) {
      return const <NEDesktopAudioDevice>[];
    }
    return bridge
        .listAudioPlaybackDevices()
        .map(
          (device) => NEDesktopAudioDevice(
            deviceId: device.deviceId,
            deviceName: device.deviceName,
          ),
        )
        .toList(growable: false);
  }

  String? getCurrentAudioPlaybackDeviceId() {
    if (!isDesktopRuntime) {
      return null;
    }
    return bridge.getCurrentAudioPlaybackDeviceId();
  }

  VoidResult setAudioPlaybackDevice(String deviceId) {
    if (!isDesktopRuntime) {
      return _unsupported('setAudioPlaybackDevice');
    }
    try {
      final result = bridge.setAudioPlaybackDevice(deviceId);
      return _toVoidResult(result, 'setAudioPlaybackDevice');
    } catch (error, stackTrace) {
      debugPrint(
        'NECallEngineDesktopImpl.setAudioPlaybackDevice error: $error\n$stackTrace',
      );
      return _unsupported('setAudioPlaybackDevice', message: error.toString());
    }
  }

  VoidResult setSpeakerphoneOn(bool enabled) {
    if (!isDesktopRuntime) {
      return _unsupported('setSpeakerphoneOn');
    }
    try {
      final result = bridge.setSpeakerphoneOn(enabled);
      return _toVoidResult(result, 'setSpeakerphoneOn');
    } catch (error, stackTrace) {
      debugPrint(
        'NECallEngineDesktopImpl.setSpeakerphoneOn error: $error\n$stackTrace',
      );
      return _unsupported('setSpeakerphoneOn', message: error.toString());
    }
  }

  bool isSpeakerphoneOn() {
    if (!isDesktopRuntime) {
      return false;
    }
    return bridge.isSpeakerphoneOn() ?? false;
  }

  Future<VoidResult> setupLocalView(int viewId) async {
    if (!isDesktopRuntime) {
      return _unsupported('setupLocalView');
    }
    try {
      final result = Platform.isMacOS
          ? await _macosVideoViewChannel.invokeMethod<int>(
                'setupLocalView',
                <String, Object?>{'viewId': viewId},
              ) ??
              _unsupportedCode
          : bridge.setupLocalVideoRenderer(viewId);
      return _toVoidResult(result, 'setupLocalView');
    } catch (error, stackTrace) {
      debugPrint(
        'NECallEngineDesktopImpl.setupLocalView error: $error\n$stackTrace',
      );
      return _unsupported('setupLocalView', message: error.toString());
    }
  }

  Future<VoidResult> setupRemoteView(int viewId) async {
    if (!isDesktopRuntime) {
      return _unsupported('setupRemoteView');
    }
    try {
      final result = Platform.isMacOS
          ? await _macosVideoViewChannel.invokeMethod<int>(
                'setupRemoteView',
                <String, Object?>{'viewId': viewId},
              ) ??
              _unsupportedCode
          : bridge.setupRemoteVideoRenderer(viewId);
      return _toVoidResult(result, 'setupRemoteView');
    } catch (error, stackTrace) {
      debugPrint(
        'NECallEngineDesktopImpl.setupRemoteView error: $error\n$stackTrace',
      );
      return _unsupported('setupRemoteView', message: error.toString());
    }
  }

  NEUserInfo? getUserWithRtcUid(int rtcUid) {
    if (!isDesktopRuntime) {
      return null;
    }
    final info = bridge.getUserWithRtcUid(rtcUid);
    if (info == null) {
      return null;
    }
    return NEUserInfo(accId: info.userId, uid: info.rtcUid);
  }

  NECallEndInfo mapCallEnd(NECallEndInfo info) {
    if (!isDesktopRuntime) {
      return info;
    }
    return eventMapper.mapCallEnd(info);
  }

  NEInviteInfo mapReceiveInvited(NEInviteInfo info) {
    if (!isDesktopRuntime) {
      return info;
    }
    return eventMapper.mapReceiveInvited(info);
  }

  NECallInfo mapCallConnected(NECallInfo info) {
    if (!isDesktopRuntime) {
      return info;
    }
    return eventMapper.mapCallConnected(info);
  }

  NECallTypeChangeInfo mapCallTypeChange(NECallTypeChangeInfo info) {
    if (!isDesktopRuntime) {
      return info;
    }
    return eventMapper.mapCallTypeChange(info);
  }

  void handleNativeEvent(NECallBridgeEventNative event) {
    if (!isDesktopRuntime) {
      return;
    }
    switch (event.type) {
      case 1:
        final payload = event.payload.invited;
        final callerAccId = _readUtf8(payload.callerAccId);
        final channelId = _readNullableUtf8(payload.channelId);
        final extraInfo = _readNullableUtf8(payload.extraInfo);
        final callType = eventMapper.mapBridgeCallType(payload.callType);
        final currentCallInfo = _safeGetCallInfoForInvite(
          callerAccId: callerAccId,
          bridgeCallType: payload.callType,
          channelId: channelId,
        );
        final resolvedCallId = currentCallInfo?.callId;
        _rememberCallId(resolvedCallId);
        debugPrint(
          'NECallEngineDesktopImpl.receiveInvited: callerAccId=$callerAccId '
          'callType=$callType bridgeCallType=${payload.callType} '
          'channelId=${channelId ?? ''} resolvedCallId=${resolvedCallId ?? ''} '
          'callStatus=${currentCallInfo?.callStatus ?? 'null'}',
        );
        _onReceiveInvited?.call(
          NEInviteInfo(
            callerAccId: callerAccId,
            callType: callType,
            callId: resolvedCallId,
            extraInfo: extraInfo,
            channelId: channelId,
          ),
        );
        break;
      case 2:
        final payload = event.payload.connected;
        final bridgedCallInfo = bridge.readNativeConnectedPayload(payload);
        final mappedCallInfo = eventMapper.mapBridgeCallInfo(bridgedCallInfo);
        final resolvedCallInfo = mappedCallInfo.callId.isNotEmpty
            ? mappedCallInfo
            : (getCallInfo() ?? mappedCallInfo);
        _rememberCallId(resolvedCallInfo.callId);
        _onCallConnected?.call(resolvedCallInfo);
        break;
      case 3:
        final payload = event.payload.ended;
        final resolvedCallId = _resolveEndCallId();
        _onCallEnd?.call(
          eventMapper.mapBridgeCallEnd(
            reasonCode: payload.reasonCode,
            callId: resolvedCallId,
            extraString: _readNullableUtf8(payload.extraString),
            message: _readNullableUtf8(payload.message),
          ),
        );
        break;
      case 4:
        final payload = event.payload.typeChanged;
        _onCallTypeChange
            ?.call(eventMapper.mapBridgeTypeChange(payload.callType));
        break;
      case 5:
        final payload = event.payload.videoAvailable;
        _onVideoAvailable?.call(
          payload.available != 0,
          _readUtf8(payload.userId),
        );
        break;
      case 6:
        final payload = event.payload.videoMuted;
        _onVideoMuted?.call(
          payload.muted != 0,
          _readUtf8(payload.userId),
        );
        break;
      case 7:
        final payload = event.payload.audioMuted;
        _onAudioMuted?.call(
          payload.muted != 0,
          _readUtf8(payload.userId),
        );
        break;
      case 9:
        final payload = event.payload.localAudioMuted;
        _onLocalAudioMuted?.call(payload.muted != 0);
        break;
      case 10:
        _onRtcInitEnd?.call();
        break;
      case 11:
        final payload = event.payload.recordSend;
        _onRecordSend?.call(
          eventMapper.mapBridgeRecordConfig(
            accId: _readUtf8(payload.accId),
            callType: payload.callType,
            callState: payload.callState,
          ),
        );
        break;
      case 12: // NE_CALL_BRIDGE_EVENT_RTC_RAW
        final rawPayload = event.payload.rtcRaw;
        _onRtcRaw?.call(
          _readUtf8(rawPayload.eventName),
          _readNullableUtf8(rawPayload.jsonData) ?? '{}',
        );
        break;
      default:
        break;
    }
  }

  VoidResult unsupportedResult(String operation) => _unsupported(operation);

  static String _readUtf8(Pointer<Utf8> pointer) {
    if (pointer.address == 0) {
      return '';
    }
    return pointer.toDartString();
  }

  static String? _readNullableUtf8(Pointer<Utf8> pointer) {
    if (pointer.address == 0) {
      return null;
    }
    return pointer.toDartString();
  }

  void _rememberCallId(String? callId) {
    if (callId == null || callId.isEmpty) {
      return;
    }
    _lastKnownCallId = callId;
  }

  NECallInfo? _safeGetCallInfoForInvite({
    required String callerAccId,
    required int bridgeCallType,
    String? channelId,
  }) {
    try {
      return getCallInfo();
    } catch (error, stackTrace) {
      debugPrint(
        'NECallEngineDesktopImpl.receiveInvited getCallInfo failed: '
        'callerAccId=$callerAccId bridgeCallType=$bridgeCallType '
        'channelId=${channelId ?? ''} error=$error',
      );
      debugPrint(
        'NECallEngineDesktopImpl.receiveInvited getCallInfo error: '
        '$error\n$stackTrace',
      );
      return null;
    }
  }

  String? _resolveEndCallId() {
    final currentCallId = getCallInfo()?.callId;
    if (currentCallId != null && currentCallId.isNotEmpty) {
      _lastKnownCallId = currentCallId;
      return currentCallId;
    }
    return _lastKnownCallId;
  }

  static VoidResult _toVoidResult(int code, String operation) {
    return VoidResult(code: code, msg: _messageFor(operation, code));
  }

  static VoidResult _unsupported(String operation, {String? message}) {
    return VoidResult(
      code: _unsupportedCode,
      msg: message ?? 'desktop bridge does not support $operation yet',
    );
  }

  static NEResult<NECallInfo> _unsupportedCall(
    String operation, {
    String? message,
  }) {
    return NEResult<NECallInfo>(
      code: _unsupportedCode,
      msg: message ?? 'desktop bridge does not support $operation yet',
      data: null,
    );
  }

  static String _messageFor(String operation, int code) {
    if (code == 0) {
      return 'ok';
    }
    return '$operation failed with code=$code';
  }
}
