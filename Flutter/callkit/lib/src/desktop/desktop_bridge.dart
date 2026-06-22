import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

// ignore_for_file: sdk_version_since

import 'package:ffi/ffi.dart';

import '../api/models.dart';
import 'ffi_bindings.dart';

typedef DesktopBridgeNativeEventListener = void Function(
  NECallBridgeEventNative event,
);

class DesktopBridgeCallResult {
  const DesktopBridgeCallResult({
    required this.code,
    required this.message,
    this.callInfo,
  });

  final int code;
  final String message;
  final DesktopBridgeCallInfo? callInfo;
}

class DesktopBridgeHangupResult {
  const DesktopBridgeHangupResult({
    required this.code,
    required this.message,
  });

  final int code;
  final String message;
}

class DesktopBridgeCallConfig {
  const DesktopBridgeCallConfig({
    required this.enableOffline,
    required this.enableSwitchVideoConfirm,
    required this.enableSwitchAudioConfirm,
  });

  final bool enableOffline;
  final bool enableSwitchVideoConfirm;
  final bool enableSwitchAudioConfirm;
}

class DesktopBridgeCallInfo {
  const DesktopBridgeCallInfo({
    this.callId,
    this.currentAccId,
    this.callerInfo,
    this.calleeInfo,
    required this.callType,
    this.signalInfo,
    this.rtcInfo,
    required this.callStatus,
  });

  final String? callId;
  final String? currentAccId;
  final DesktopBridgeCallUserInfo? callerInfo;
  final DesktopBridgeCallUserInfo? calleeInfo;
  final int callType;
  final DesktopBridgeSignalInfo? signalInfo;
  final DesktopBridgeRtcInfo? rtcInfo;
  final int callStatus;
}

class DesktopBridgeCallUserInfo {
  const DesktopBridgeCallUserInfo({
    this.accId,
    this.uid = 0,
  });

  final String? accId;
  final int uid;
}

class DesktopBridgeSignalInfo {
  const DesktopBridgeSignalInfo({
    this.channelId,
    this.requestId,
    this.channelName,
    this.extraInfo,
    this.globalExtraCopy,
  });

  final String? channelId;
  final String? requestId;
  final String? channelName;
  final String? extraInfo;
  final String? globalExtraCopy;
}

class DesktopBridgeRtcInfo {
  const DesktopBridgeRtcInfo({
    this.channelName,
    this.token,
    this.cid = 0,
    this.uid = 0,
  });

  final String? channelName;
  final String? token;
  final int cid;
  final int uid;
}

class DesktopBridgeUserInfo {
  const DesktopBridgeUserInfo({
    required this.userId,
    required this.rtcUid,
  });

  final String userId;
  final int rtcUid;
}

class DesktopBridgeVideoCaptureDevice {
  const DesktopBridgeVideoCaptureDevice({
    required this.deviceId,
    required this.deviceName,
  });

  final String deviceId;
  final String deviceName;
}

class DesktopBridgeAudioDevice {
  const DesktopBridgeAudioDevice({
    required this.deviceId,
    required this.deviceName,
  });

  final String deviceId;
  final String deviceName;
}

void _desktopBridgeEventCallback(
  Pointer<NECallBridgeEventNative> eventPointer,
  Pointer<Void> userData,
) {
  // `desktop/bridge` is a singleton in current Flutter desktop runtime, so
  // generic events can be routed through the shared bridge instance.
  DesktopBridge.instance.dispatchNativeEvent(eventPointer);
}

void _desktopBridgeCallCompletionCallback(
  Pointer<NECallBridgeErrorNative> errorPointer,
  Pointer<NECallBridgeCallInfoParamNative> callInfoPointer,
  Pointer<Void> userData,
) {
  DesktopBridge.instance.dispatchCallCompletion(errorPointer, callInfoPointer);
}

void _desktopBridgeAcceptCompletionCallback(
  Pointer<NECallBridgeErrorNative> errorPointer,
  Pointer<NECallBridgeCallInfoParamNative> callInfoPointer,
  Pointer<Void> userData,
) {
  DesktopBridge.instance
      .dispatchAcceptCompletion(errorPointer, callInfoPointer);
}

void _desktopBridgeHangupCompletionCallback(
  Pointer<NECallBridgeErrorNative> errorPointer,
  Pointer<Void> userData,
) {
  DesktopBridge.instance.dispatchHangupCompletion(errorPointer);
}

class _DesktopBridgeErrorResult {
  const _DesktopBridgeErrorResult({
    required this.code,
    required this.message,
  });

  final int code;
  final String message;
}

class DesktopBridge {
  DesktopBridge._();

  static final DesktopBridge instance = DesktopBridge._();
  static final NativeCallable<NeCallBridgeEventCallbackNative> _eventCallback =
      NativeCallable<NeCallBridgeEventCallbackNative>.listener(
    _desktopBridgeEventCallback,
  );
  static final NativeCallable<NeCallBridgeCallCompletionNative>
      _callCompletionCallback =
      NativeCallable<NeCallBridgeCallCompletionNative>.listener(
    _desktopBridgeCallCompletionCallback,
  );
  static final NativeCallable<NeCallBridgeCallCompletionNative>
      _acceptCompletionCallback =
      NativeCallable<NeCallBridgeCallCompletionNative>.listener(
    _desktopBridgeAcceptCompletionCallback,
  );
  static final NativeCallable<NeCallBridgeHangupCompletionNative>
      _hangupCompletionCallback =
      NativeCallable<NeCallBridgeHangupCompletionNative>.listener(
    _desktopBridgeHangupCompletionCallback,
  );
  static const int _busyCode = -2;

  Pointer<Void>? _handle;
  bool _eventCallbackBound = false;
  DesktopBridgeNativeEventListener? _eventListener;
  Completer<DesktopBridgeCallResult>? _pendingCallCompleter;
  Completer<DesktopBridgeCallResult>? _pendingAcceptCompleter;
  Completer<DesktopBridgeHangupResult>? _pendingHangupCompleter;

  Pointer<Void>? get handle => _handle;

  bool get isReady => _handle != null && _handle!.address != 0;

  int get unavailableCode => -1;

  bool attachHandle(Pointer<Void> handle) {
    if (handle.address == 0) {
      return false;
    }
    _handle = handle;
    return true;
  }

  void ensureCreated() {
    if (isReady) {
      return;
    }
    final handle = DesktopFfiBindings.instance.create();
    if (handle.address != 0) {
      _handle = handle;
    }
  }

  void ensureEventCallbackBound() {
    if (!isReady || _eventCallbackBound) {
      return;
    }
    final result = DesktopFfiBindings.instance.registerEventCallback(
      _handle!,
      _eventCallback.nativeFunction,
      nullptr,
    );
    if (result == 0) {
      _eventCallbackBound = true;
    }
  }

  void setEventListener(DesktopBridgeNativeEventListener? listener) {
    _eventListener = listener;
  }

  void dispatchNativeEvent(Pointer<NECallBridgeEventNative> eventPointer) {
    if (eventPointer.address == 0) {
      return;
    }
    try {
      _eventListener?.call(eventPointer.ref);
    } finally {
      DesktopFfiBindings.instance.releaseEvent(eventPointer);
    }
  }

  int getCapabilities() {
    return DesktopFfiBindings.instance.getCapabilities();
  }

  bool supportsCapability(int capability) {
    return DesktopFfiBindings.instance.supportsCapability(capability) == 1;
  }

  void releaseHandle() {
    _failPendingCompletions();
    if (!isReady) {
      _handle = null;
      _eventCallbackBound = false;
      _eventListener = null;
      return;
    }
    DesktopFfiBindings.instance.destroy();
    _handle = null;
    _eventCallbackBound = false;
    _eventListener = null;
  }

  int setup(NESetupConfig config) {
    ensureCreated();
    if (!isReady) {
      return unavailableCode;
    }
    final nativeConfig = calloc<NECallBridgeSetupConfigNative>();
    final appKey = _toNativeUtf8(config.appKey);
    final framework = _toNativeUtf8('Flutter');
    try {
      nativeConfig.ref
        ..appKey = appKey
        ..framework = framework
        ..channel = nullptr.cast<Utf8>()
        ..currentUserRtcUid = config.currentUserRtcUid ?? 0
        ..enableJoinRtcWhenCall = config.enableJoinRtcWhenCall == true ? 1 : 0
        ..initRtcMode = _toDesktopInitRtcMode(config.initRtcMode)
        ..preferredVideoRenderMode =
            _toDesktopVideoRenderMode(config.desktopVideoRenderMode);
      return DesktopFfiBindings.instance.setup(_handle!, nativeConfig);
    } finally {
      calloc.free(nativeConfig);
      _freeUtf8(appKey);
      _freeUtf8(framework);
    }
  }

  Future<DesktopBridgeCallResult> call({
    required String accId,
    required NECallType callType,
    String? extraInfo,
    String? rtcChannelName,
    String? globalExtraCopy,
    NECallPushConfig? pushConfig,
  }) {
    if (!isReady) {
      return Future<DesktopBridgeCallResult>.value(
        _callResultFromCode('call', unavailableCode),
      );
    }
    if (_pendingCallCompleter != null) {
      return Future<DesktopBridgeCallResult>.value(
        _callResultFromCode('call', _busyCode),
      );
    }
    final completer = Completer<DesktopBridgeCallResult>();
    _pendingCallCompleter = completer;
    final nativeParam = calloc<NECallBridgeCallParamNative>();
    final nativeAccId = _toNativeUtf8(accId);
    final nativeExtraInfo = _toNativeUtf8(extraInfo);
    final nativeGlobalExtraCopy = _toNativeUtf8(globalExtraCopy);
    final nativeRtcChannelName = _toNativeUtf8(rtcChannelName);
    final nativePushConfig =
        pushConfig == null ? nullptr : calloc<NECallBridgePushConfigNative>();
    final nativePushTitle = _toNativeUtf8(pushConfig?.pushTitle);
    final nativePushContent = _toNativeUtf8(pushConfig?.pushContent);
    final nativePushPayload = _toNativeUtf8(pushConfig?.pushPayload);
    try {
      try {
        if (nativePushConfig != nullptr) {
          nativePushConfig.ref
            ..needPush = pushConfig!.needPush ? 1 : 0
            ..pushTitle = nativePushTitle
            ..pushContent = nativePushContent
            ..pushPayload = nativePushPayload
            ..needBadge = pushConfig.needBadge ? 1 : 0;
        }
        nativeParam.ref
          ..accId = nativeAccId
          ..callType = callType.index
          ..extraInfo = nativeExtraInfo
          ..rtcChannelName = nativeRtcChannelName
          ..globalExtraCopy = nativeGlobalExtraCopy
          ..pushConfig = nativePushConfig;
        DesktopFfiBindings.instance.call(
          _handle!,
          nativeParam,
          _callCompletionCallback.nativeFunction,
          nullptr,
        );
      } catch (_) {
        _pendingCallCompleter = null;
        rethrow;
      }
    } finally {
      calloc.free(nativeParam);
      _freeUtf8(nativeAccId);
      _freeUtf8(nativeExtraInfo);
      _freeUtf8(nativeGlobalExtraCopy);
      _freeUtf8(nativeRtcChannelName);
      _freeUtf8(nativePushTitle);
      _freeUtf8(nativePushContent);
      _freeUtf8(nativePushPayload);
      if (nativePushConfig != nullptr) {
        calloc.free(nativePushConfig);
      }
    }
    return completer.future;
  }

  Future<DesktopBridgeCallResult> accept() {
    if (!isReady) {
      return Future<DesktopBridgeCallResult>.value(
        _callResultFromCode('accept', unavailableCode),
      );
    }
    if (_pendingAcceptCompleter != null) {
      return Future<DesktopBridgeCallResult>.value(
        _callResultFromCode('accept', _busyCode),
      );
    }
    final completer = Completer<DesktopBridgeCallResult>();
    _pendingAcceptCompleter = completer;
    try {
      DesktopFfiBindings.instance.accept(
        _handle!,
        _acceptCompletionCallback.nativeFunction,
        nullptr,
      );
    } catch (_) {
      _pendingAcceptCompleter = null;
      rethrow;
    }
    return completer.future;
  }

  Future<DesktopBridgeHangupResult> hangup({
    String? channelId,
    String? extraString,
  }) {
    if (!isReady) {
      return Future<DesktopBridgeHangupResult>.value(
        _hangupResultFromCode(unavailableCode),
      );
    }
    if (_pendingHangupCompleter != null) {
      return Future<DesktopBridgeHangupResult>.value(
        _hangupResultFromCode(_busyCode),
      );
    }
    final completer = Completer<DesktopBridgeHangupResult>();
    _pendingHangupCompleter = completer;
    try {
      return _withHangupParam(
        channelId: channelId,
        extraString: extraString,
        invoke: (param) {
          DesktopFfiBindings.instance.hangup(
            _handle!,
            param,
            _hangupCompletionCallback.nativeFunction,
            nullptr,
          );
          return completer.future;
        },
      );
    } catch (_) {
      _pendingHangupCompleter = null;
      rethrow;
    }
  }

  void dispatchCallCompletion(
    Pointer<NECallBridgeErrorNative> errorPointer,
    Pointer<NECallBridgeCallInfoParamNative> callInfoPointer,
  ) {
    try {
      final completer = _pendingCallCompleter;
      _pendingCallCompleter = null;
      completer?.complete(
        _readCallResult('call', errorPointer, callInfoPointer),
      );
    } finally {
      _releaseCallCompletionPayload(errorPointer, callInfoPointer);
    }
  }

  void dispatchAcceptCompletion(
    Pointer<NECallBridgeErrorNative> errorPointer,
    Pointer<NECallBridgeCallInfoParamNative> callInfoPointer,
  ) {
    try {
      final completer = _pendingAcceptCompleter;
      _pendingAcceptCompleter = null;
      completer?.complete(
        _readCallResult('accept', errorPointer, callInfoPointer),
      );
    } finally {
      _releaseCallCompletionPayload(errorPointer, callInfoPointer);
    }
  }

  void dispatchHangupCompletion(
    Pointer<NECallBridgeErrorNative> errorPointer,
  ) {
    try {
      final completer = _pendingHangupCompleter;
      _pendingHangupCompleter = null;
      completer?.complete(_readHangupResult(errorPointer));
    } finally {
      if (errorPointer.address != 0) {
        DesktopFfiBindings.instance.releaseError(errorPointer);
      }
    }
  }

  int switchCallType(NECallType callType, NECallSwitchState state) {
    if (!isReady) {
      return unavailableCode;
    }
    return DesktopFfiBindings.instance.switchCallType(
      _handle!,
      callType.index,
      state.index,
    );
  }

  int setCallConfig({
    required bool enableOffline,
    required bool enableSwitchVideoConfirm,
    required bool enableSwitchAudioConfirm,
  }) {
    if (!isReady) {
      return unavailableCode;
    }
    final nativeConfig = calloc<NECallBridgeConfigParamNative>();
    try {
      nativeConfig.ref
        ..enableOffline = enableOffline
        ..enableSwitchVideoConfirm = enableSwitchVideoConfirm
        ..enableSwitchAudioConfirm = enableSwitchAudioConfirm;
      return DesktopFfiBindings.instance.setCallConfig(_handle!, nativeConfig);
    } finally {
      calloc.free(nativeConfig);
    }
  }

  DesktopBridgeCallConfig? getCallConfig() {
    if (!isReady) {
      return null;
    }
    final nativeConfig = calloc<NECallBridgeConfigParamNative>();
    try {
      final result = DesktopFfiBindings.instance.getCallConfig(
        _handle!,
        nativeConfig,
      );
      if (result != 0) {
        return null;
      }
      return DesktopBridgeCallConfig(
        enableOffline: nativeConfig.ref.enableOffline,
        enableSwitchVideoConfirm: nativeConfig.ref.enableSwitchVideoConfirm,
        enableSwitchAudioConfirm: nativeConfig.ref.enableSwitchAudioConfirm,
      );
    } finally {
      calloc.free(nativeConfig);
    }
  }

  DesktopBridgeCallInfo? getCallInfo() {
    if (!isReady) {
      return null;
    }
    final nativeInfo = calloc<NECallBridgeCallInfoParamNative>();
    try {
      final result =
          DesktopFfiBindings.instance.getCallInfo(_handle!, nativeInfo);
      if (result != 0) {
        return null;
      }
      return DesktopBridgeCallInfo(
        callId: _fromNativeUtf8(nativeInfo.ref.callId),
        currentAccId: _fromNativeUtf8(nativeInfo.ref.currentAccId),
        callerInfo: _readCallUserInfo(nativeInfo.ref.callerInfo),
        calleeInfo: _readCallUserInfo(nativeInfo.ref.calleeInfo),
        callType: nativeInfo.ref.callType,
        signalInfo: _readSignalInfo(nativeInfo.ref.signalInfo),
        rtcInfo: _readRtcInfo(nativeInfo.ref.rtcInfo),
        callStatus: nativeInfo.ref.callStatus,
      );
    } finally {
      calloc.free(nativeInfo);
    }
  }

  DesktopBridgeCallInfo readNativeCallInfo(
    NECallBridgeCallInfoParamNative nativeInfo,
  ) {
    return DesktopBridgeCallInfo(
      callId: _fromNativeUtf8(nativeInfo.callId),
      currentAccId: _fromNativeUtf8(nativeInfo.currentAccId),
      callerInfo: _readCallUserInfo(nativeInfo.callerInfo),
      calleeInfo: _readCallUserInfo(nativeInfo.calleeInfo),
      callType: nativeInfo.callType,
      signalInfo: _readSignalInfo(nativeInfo.signalInfo),
      rtcInfo: _readRtcInfo(nativeInfo.rtcInfo),
      callStatus: nativeInfo.callStatus,
    );
  }

  DesktopBridgeCallInfo readNativeConnectedPayload(
    NECallBridgeConnectedPayloadNative nativeInfo,
  ) {
    return DesktopBridgeCallInfo(
      callId: _fromNativeUtf8(nativeInfo.callId),
      currentAccId: _fromNativeUtf8(nativeInfo.currentAccId),
      callerInfo: _readCallUserInfo(nativeInfo.callerInfo),
      calleeInfo: _readCallUserInfo(nativeInfo.calleeInfo),
      callType: nativeInfo.callType,
      signalInfo: _readSignalInfo(nativeInfo.signalInfo),
      rtcInfo: _readRtcInfo(nativeInfo.rtcInfo),
      callStatus: nativeInfo.callStatus,
    );
  }

  String? getVersion() {
    if (!isReady) {
      return null;
    }
    const bufferLength = 128;
    final versionBuffer = calloc<Int8>(bufferLength);
    try {
      final result = DesktopFfiBindings.instance.getVersion(
        _handle!,
        versionBuffer,
        bufferLength,
      );
      if (result != 0) {
        return null;
      }
      return versionBuffer.cast<Utf8>().toDartString();
    } finally {
      calloc.free(versionBuffer);
    }
  }

  int setTimeout(int seconds) {
    if (!isReady) {
      return unavailableCode;
    }
    return DesktopFfiBindings.instance.setTimeout(_handle!, seconds);
  }

  int setCallRecordProvider(bool enabled) {
    if (!isReady) {
      return unavailableCode;
    }
    return DesktopFfiBindings.instance.setCallRecordProvider(
      _handle!,
      enabled ? 1 : 0,
    );
  }

  int enableLocalVideo(bool enabled) {
    if (!isReady) {
      return unavailableCode;
    }
    return DesktopFfiBindings.instance.enableLocalVideo(
      _handle!,
      enabled ? 1 : 0,
    );
  }

  int muteLocalVideo(bool muted) {
    if (!isReady) {
      return unavailableCode;
    }
    return DesktopFfiBindings.instance.muteLocalVideo(
      _handle!,
      muted ? 1 : 0,
    );
  }

  int muteLocalAudio(bool muted) {
    if (!isReady) {
      return unavailableCode;
    }
    return DesktopFfiBindings.instance.muteLocalAudio(
      _handle!,
      muted ? 1 : 0,
    );
  }

  int switchCamera() {
    if (!isReady) {
      return unavailableCode;
    }
    return DesktopFfiBindings.instance.switchCamera(_handle!);
  }

  int setSpeakerphoneOn(bool enabled) {
    if (!isReady) {
      return unavailableCode;
    }
    return DesktopFfiBindings.instance.setSpeakerphoneOn(
      _handle!,
      enabled ? 1 : 0,
    );
  }

  bool? isSpeakerphoneOn() {
    if (!isReady) {
      return null;
    }
    final nativeEnabled = calloc<Uint8>();
    try {
      final result =
          DesktopFfiBindings.instance.isSpeakerphoneOn(_handle!, nativeEnabled);
      if (result != 0) {
        return null;
      }
      return nativeEnabled.value != 0;
    } finally {
      calloc.free(nativeEnabled);
    }
  }

  int setupLocalVideoRenderer(int rendererId) {
    if (!isReady) {
      return unavailableCode;
    }
    return DesktopFfiBindings.instance.setupLocalVideoRenderer(
      _handle!,
      rendererId,
    );
  }

  int setupRemoteVideoRenderer(int rendererId) {
    if (!isReady) {
      return unavailableCode;
    }
    return DesktopFfiBindings.instance.setupRemoteVideoRenderer(
      _handle!,
      rendererId,
    );
  }

  int setupRemoteVideoRendererWithUid(int rtcUid, int rendererId) {
    if (!isReady) {
      return unavailableCode;
    }
    return DesktopFfiBindings.instance.setupRemoteVideoRendererWithUid(
      _handle!,
      rtcUid,
      rendererId,
    );
  }

  int setVideoRendererMirror(int rendererId, bool mirror) {
    if (!isReady) {
      return unavailableCode;
    }
    return DesktopFfiBindings.instance.setVideoRendererMirror(
      _handle!,
      rendererId,
      mirror ? 1 : 0,
    );
  }

  DesktopBridgeUserInfo? getUserWithRtcUid(int rtcUid) {
    if (!isReady) {
      return null;
    }
    final nativeInfo = calloc<NECallBridgeUserInfoParamNative>();
    try {
      final result = DesktopFfiBindings.instance.getUserWithRtcUid(
        _handle!,
        rtcUid,
        nativeInfo,
      );
      if (result != 0) {
        return null;
      }
      final userId = _fromNativeUtf8(nativeInfo.ref.userId);
      if (userId == null || userId.isEmpty) {
        return null;
      }
      return DesktopBridgeUserInfo(
        userId: userId,
        rtcUid: nativeInfo.ref.rtcUid,
      );
    } finally {
      calloc.free(nativeInfo);
    }
  }

  List<DesktopBridgeVideoCaptureDevice> listVideoCaptureDevices() {
    if (!isReady) {
      return const <DesktopBridgeVideoCaptureDevice>[];
    }
    final devicesJson = _readNativeString(
      (buffer, bufferLength, outRequiredLength) =>
          DesktopFfiBindings.instance.listVideoCaptureDevices(
        _handle!,
        buffer,
        bufferLength,
        outRequiredLength,
      ),
    );
    return _parseNamedDeviceList(
      devicesJson,
      (deviceId, deviceName) => DesktopBridgeVideoCaptureDevice(
        deviceId: deviceId,
        deviceName: deviceName,
      ),
    );
  }

  String? getCurrentVideoCaptureDeviceId() {
    if (!isReady) {
      return null;
    }
    final deviceId = _readNativeString(
      (buffer, bufferLength, outRequiredLength) =>
          DesktopFfiBindings.instance.getCurrentVideoCaptureDevice(
        _handle!,
        buffer,
        bufferLength,
        outRequiredLength,
      ),
    );
    if (deviceId == null || deviceId.isEmpty) {
      return null;
    }
    return deviceId;
  }

  int setVideoCaptureDevice(String deviceId) {
    if (!isReady) {
      return unavailableCode;
    }
    final nativeDeviceId = _toNativeUtf8(deviceId);
    try {
      return DesktopFfiBindings.instance.setVideoCaptureDevice(
        _handle!,
        nativeDeviceId,
      );
    } finally {
      _freeUtf8(nativeDeviceId);
    }
  }

  List<DesktopBridgeAudioDevice> listAudioRecordingDevices() {
    if (!isReady) {
      return const <DesktopBridgeAudioDevice>[];
    }
    final devicesJson = _readNativeString(
      (buffer, bufferLength, outRequiredLength) =>
          DesktopFfiBindings.instance.listAudioRecordingDevices(
        _handle!,
        buffer,
        bufferLength,
        outRequiredLength,
      ),
    );
    return _parseNamedDeviceList(
      devicesJson,
      (deviceId, deviceName) => DesktopBridgeAudioDevice(
        deviceId: deviceId,
        deviceName: deviceName,
      ),
    );
  }

  String? getCurrentAudioRecordingDeviceId() {
    if (!isReady) {
      return null;
    }
    final deviceId = _readNativeString(
      (buffer, bufferLength, outRequiredLength) =>
          DesktopFfiBindings.instance.getCurrentAudioRecordingDevice(
        _handle!,
        buffer,
        bufferLength,
        outRequiredLength,
      ),
    );
    if (deviceId == null || deviceId.isEmpty) {
      return null;
    }
    return deviceId;
  }

  int setAudioRecordingDevice(String deviceId) {
    if (!isReady) {
      return unavailableCode;
    }
    final nativeDeviceId = _toNativeUtf8(deviceId);
    try {
      return DesktopFfiBindings.instance.setAudioRecordingDevice(
        _handle!,
        nativeDeviceId,
      );
    } finally {
      _freeUtf8(nativeDeviceId);
    }
  }

  List<DesktopBridgeAudioDevice> listAudioPlaybackDevices() {
    if (!isReady) {
      return const <DesktopBridgeAudioDevice>[];
    }
    final devicesJson = _readNativeString(
      (buffer, bufferLength, outRequiredLength) =>
          DesktopFfiBindings.instance.listAudioPlaybackDevices(
        _handle!,
        buffer,
        bufferLength,
        outRequiredLength,
      ),
    );
    return _parseNamedDeviceList(
      devicesJson,
      (deviceId, deviceName) => DesktopBridgeAudioDevice(
        deviceId: deviceId,
        deviceName: deviceName,
      ),
    );
  }

  String? getCurrentAudioPlaybackDeviceId() {
    if (!isReady) {
      return null;
    }
    final deviceId = _readNativeString(
      (buffer, bufferLength, outRequiredLength) =>
          DesktopFfiBindings.instance.getCurrentAudioPlaybackDevice(
        _handle!,
        buffer,
        bufferLength,
        outRequiredLength,
      ),
    );
    if (deviceId == null || deviceId.isEmpty) {
      return null;
    }
    return deviceId;
  }

  int setAudioPlaybackDevice(String deviceId) {
    if (!isReady) {
      return unavailableCode;
    }
    final nativeDeviceId = _toNativeUtf8(deviceId);
    try {
      return DesktopFfiBindings.instance.setAudioPlaybackDevice(
        _handle!,
        nativeDeviceId,
      );
    } finally {
      _freeUtf8(nativeDeviceId);
    }
  }

  Future<DesktopBridgeHangupResult> _withHangupParam({
    String? channelId,
    String? extraString,
    required Future<DesktopBridgeHangupResult> Function(
      Pointer<NECallBridgeHangupParamNative> param,
    ) invoke,
  }) {
    if (!isReady) {
      return Future<DesktopBridgeHangupResult>.value(
        _hangupResultFromCode(unavailableCode),
      );
    }
    final nativeParam = calloc<NECallBridgeHangupParamNative>();
    final nativeChannelId = _toNativeUtf8(channelId);
    final nativeExtraString = _toNativeUtf8(extraString);
    try {
      nativeParam.ref
        ..channelId = nativeChannelId
        ..extraString = nativeExtraString;
      return invoke(nativeParam);
    } finally {
      calloc.free(nativeParam);
      _freeUtf8(nativeChannelId);
      _freeUtf8(nativeExtraString);
    }
  }

  void _failPendingCompletions() {
    final pendingCallCompleter = _pendingCallCompleter;
    _pendingCallCompleter = null;
    pendingCallCompleter?.complete(
      _callResultFromCode(
        'call',
        unavailableCode,
        message: 'bridge released',
      ),
    );

    final pendingAcceptCompleter = _pendingAcceptCompleter;
    _pendingAcceptCompleter = null;
    pendingAcceptCompleter?.complete(
      _callResultFromCode(
        'accept',
        unavailableCode,
        message: 'bridge released',
      ),
    );

    final pendingHangupCompleter = _pendingHangupCompleter;
    _pendingHangupCompleter = null;
    pendingHangupCompleter?.complete(
      _hangupResultFromCode(unavailableCode, message: 'bridge released'),
    );
  }

  DesktopBridgeCallResult _readCallResult(
    String operation,
    Pointer<NECallBridgeErrorNative> errorPointer,
    Pointer<NECallBridgeCallInfoParamNative> callInfoPointer,
  ) {
    final error = _readError(errorPointer);
    return _callResultFromCode(
      operation,
      error?.code ?? 0,
      message: error?.message,
      callInfo: callInfoPointer.address == 0
          ? null
          : readNativeCallInfo(callInfoPointer.ref),
    );
  }

  DesktopBridgeHangupResult _readHangupResult(
    Pointer<NECallBridgeErrorNative> errorPointer,
  ) {
    final error = _readError(errorPointer);
    return _hangupResultFromCode(
      error?.code ?? 0,
      message: error?.message,
    );
  }

  static _DesktopBridgeErrorResult? _readError(
    Pointer<NECallBridgeErrorNative> errorPointer,
  ) {
    if (errorPointer.address == 0) {
      return null;
    }
    return _DesktopBridgeErrorResult(
      code: errorPointer.ref.code,
      message: _fromNativeUtf8(errorPointer.ref.message) ?? '',
    );
  }

  void _releaseCallCompletionPayload(
    Pointer<NECallBridgeErrorNative> errorPointer,
    Pointer<NECallBridgeCallInfoParamNative> callInfoPointer,
  ) {
    if (errorPointer.address != 0) {
      DesktopFfiBindings.instance.releaseError(errorPointer);
    }
    if (callInfoPointer.address != 0) {
      DesktopFfiBindings.instance.releaseCallInfo(callInfoPointer);
    }
  }

  static DesktopBridgeCallResult _callResultFromCode(
    String operation,
    int code, {
    String? message,
    DesktopBridgeCallInfo? callInfo,
  }) {
    return DesktopBridgeCallResult(
      code: code,
      message: _resolveMessage(operation, code, message),
      callInfo: callInfo,
    );
  }

  static DesktopBridgeHangupResult _hangupResultFromCode(
    int code, {
    String? message,
  }) {
    return DesktopBridgeHangupResult(
      code: code,
      message: _resolveMessage('hangup', code, message),
    );
  }

  static Pointer<Utf8> _toNativeUtf8(String? value) {
    if (value == null || value.isEmpty) {
      return nullptr.cast<Utf8>();
    }
    return value.toNativeUtf8();
  }

  static String? _fromNativeUtf8(Pointer<Utf8> pointer) {
    if (pointer.address == 0) {
      return null;
    }
    return pointer.toDartString();
  }

  static String _resolveMessage(String operation, int code, String? message) {
    if (message != null && message.isNotEmpty) {
      return message;
    }
    if (code == 0) {
      return 'ok';
    }
    return '$operation failed with code=$code';
  }

  static void _freeUtf8(Pointer<Utf8> pointer) {
    if (pointer.address == 0) {
      return;
    }
    calloc.free(pointer);
  }

  static DesktopBridgeCallUserInfo? _readCallUserInfo(
    NECallBridgeCallUserInfoNative nativeInfo,
  ) {
    final accId = _fromNativeUtf8(nativeInfo.accId);
    if ((accId == null || accId.isEmpty) && nativeInfo.uid == 0) {
      return null;
    }
    return DesktopBridgeCallUserInfo(
      accId: accId,
      uid: nativeInfo.uid,
    );
  }

  static DesktopBridgeSignalInfo? _readSignalInfo(
    NECallBridgeSignalInfoNative nativeInfo,
  ) {
    final channelId = _fromNativeUtf8(nativeInfo.channelId);
    final requestId = _fromNativeUtf8(nativeInfo.requestId);
    final channelName = _fromNativeUtf8(nativeInfo.channelName);
    final extraInfo = _fromNativeUtf8(nativeInfo.extraInfo);
    final globalExtraCopy = _fromNativeUtf8(nativeInfo.globalExtraCopy);
    if ((channelId == null || channelId.isEmpty) &&
        (requestId == null || requestId.isEmpty) &&
        (channelName == null || channelName.isEmpty) &&
        (extraInfo == null || extraInfo.isEmpty) &&
        (globalExtraCopy == null || globalExtraCopy.isEmpty)) {
      return null;
    }
    return DesktopBridgeSignalInfo(
      channelId: channelId,
      requestId: requestId,
      channelName: channelName,
      extraInfo: extraInfo,
      globalExtraCopy: globalExtraCopy,
    );
  }

  static DesktopBridgeRtcInfo? _readRtcInfo(
      NECallBridgeRtcInfoNative nativeInfo) {
    final channelName = _fromNativeUtf8(nativeInfo.channelName);
    final token = _fromNativeUtf8(nativeInfo.token);
    if ((channelName == null || channelName.isEmpty) &&
        (token == null || token.isEmpty) &&
        nativeInfo.cid == 0 &&
        nativeInfo.uid == 0) {
      return null;
    }
    return DesktopBridgeRtcInfo(
      channelName: channelName,
      token: token,
      cid: nativeInfo.cid,
      uid: nativeInfo.uid,
    );
  }

  static String? _readNativeString(
    int Function(Pointer<Int8> buffer, int bufferLength,
            Pointer<Uint32> outRequiredLength)
        invoke,
  ) {
    final requiredLength = calloc<Uint32>();
    try {
      int result = invoke(nullptr.cast<Int8>(), 0, requiredLength);
      if (result != 0) {
        return null;
      }
      if (requiredLength.value == 0) {
        return '';
      }

      final buffer = calloc<Int8>(requiredLength.value);
      try {
        result = invoke(buffer, requiredLength.value, requiredLength);
        if (result != 0) {
          return null;
        }
        return buffer.cast<Utf8>().toDartString();
      } finally {
        calloc.free(buffer);
      }
    } finally {
      calloc.free(requiredLength);
    }
  }

  static List<T> _parseNamedDeviceList<T>(
    String? devicesJson,
    T Function(String deviceId, String deviceName) builder,
  ) {
    if (devicesJson == null || devicesJson.isEmpty) {
      return <T>[];
    }

    final decoded = jsonDecode(devicesJson);
    if (decoded is! List) {
      return <T>[];
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(
          (item) {
            final deviceId = item['id'] as String? ?? '';
            if (deviceId.isEmpty) {
              return null;
            }
            final deviceName = item['name'] as String? ?? '';
            return builder(deviceId, deviceName);
          },
        )
        .whereType<T>()
        .toList(growable: false);
  }

  static int _toDesktopInitRtcMode(NECallInitRtcMode? mode) {
    switch (mode) {
      case null:
      case NECallInitRtcMode.global:
        return 0;
      case NECallInitRtcMode.inNeed:
      case NECallInitRtcMode.inNeedDelayToAccept:
        return 1;
    }
  }

  static int _toDesktopVideoRenderMode(NEDesktopVideoRenderMode? mode) {
    switch (mode) {
      case null:
      case NEDesktopVideoRenderMode.auto:
        return 0;
      case NEDesktopVideoRenderMode.externalRenderer:
        return 1;
      case NEDesktopVideoRenderMode.platformWindow:
        return 2;
    }
  }
}
