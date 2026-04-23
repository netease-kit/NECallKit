// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:netease_callkit/netease_callkit.dart';
import 'package:netease_callkit/src/impl/pigeon.dart' as pigeon;
import 'package:netease_common/netease_common.dart';
import 'callkit_log.dart';
import '../ne_call_engine_desktop_impl.dart';

class NECallKitImpl implements NECallEngine, pigeon.CallKitEventSink {
  static const String _tag = 'NECallKitImpl';
  static const String fltVersion = '4.5.0';

  final _api = pigeon.CallKitApi();
  final _desktopImpl = NECallEngineDesktopImpl.instance;
  static NECallKitImpl? _instance;
  var delegates = List<NECallEngineDelegate>.empty(growable: true);
  NERecordProvider? _recordProvider;
  final _rtcRawEventController =
      StreamController<Map<String, dynamic>>.broadcast();

  // 单例模式
  static NECallKitImpl get instance {
    _instance ??= NECallKitImpl._();
    return _instance!;
  }

  NECallKitImpl._() {
    pigeon.CallKitEventSink.setup(this);
    _desktopImpl.bindEventHandlers(
      onReceiveInvited: _dispatchReceiveInvited,
      onCallEnd: _dispatchCallEnd,
      onCallConnected: _dispatchCallConnected,
      onCallTypeChange: _dispatchCallTypeChange,
      onVideoAvailable: _dispatchVideoAvailable,
      onVideoMuted: _dispatchVideoMuted,
      onAudioMuted: _dispatchAudioMuted,
      onLocalAudioMuted: _dispatchLocalAudioMuted,
      onRtcInitEnd: _dispatchRtcInitEnd,
      onRecordSend: _handleRecordSend,
      onRtcRaw: _dispatchRtcRaw,
    );
  }

  // MARK: - 转换函数：将 models.dart 中的类转换为 pigeon 中的类

  pigeon.SetupConfig _toPigeonSetupConfig(NESetupConfig config) {
    return pigeon.SetupConfig(
      appKey: config.appKey,
      currentUserRtcUid: config.currentUserRtcUid,
      enableJoinRtcWhenCall: config.enableJoinRtcWhenCall,
      initRtcMode: config.initRtcMode != null
          ? pigeon.CallInitRtcMode.values[config.initRtcMode!.index]
          : null,
      lckConfig: config.lckConfig != null
          ? pigeon.LCKConfig(
              enableLiveCommunicationKit:
                  config.lckConfig!.enableLiveCommunicationKit,
              ringtoneName: config.lckConfig!.ringtoneName,
            )
          : null,
    );
  }

  pigeon.CallParam _toPigeonCallParam(
    String accId,
    NECallType callType, {
    String? extraInfo,
    String? rtcChannelName,
    String? globalExtraCopy,
    NECallPushConfig? pushConfig,
  }) {
    return pigeon.CallParam(
      accId: accId,
      extraInfo: extraInfo,
      rtcChannelName: rtcChannelName,
      globalExtraCopy: globalExtraCopy,
      callType: pigeon.CallType.values[callType.index],
      pushConfig: pushConfig != null
          ? pigeon.CallPushConfig(
              pushTitle: pushConfig.pushTitle,
              pushContent: pushConfig.pushContent,
              pushPayload: pushConfig.pushPayload,
              needBadge: pushConfig.needBadge,
              needPush: pushConfig.needPush,
            )
          : null,
    );
  }

  pigeon.HangupParam _toPigeonHangupParam(
    String? channelId,
    String? extraString,
  ) {
    return pigeon.HangupParam(channelId: channelId, extraString: extraString);
  }

  pigeon.SwitchParam _toPigeonSwitchParam(
    NECallType callType,
    NECallSwitchState state,
  ) {
    return pigeon.SwitchParam(
      callType: pigeon.CallType.values[callType.index],
      state: pigeon.CallSwitchState.values[state.index],
    );
  }

  pigeon.ViewParam _toPigeonViewParam(int viewId) {
    return pigeon.ViewParam(viewId: viewId);
  }

  pigeon.CallConfig _toPigeonCallConfig({
    required bool enableOffline,
    required bool enableSwitchVideoConfirm,
    required bool enableSwitchAudioConfirm,
  }) {
    return pigeon.CallConfig(
      enableOffline: enableOffline,
      enableSwitchVideoConfirm: enableSwitchVideoConfirm,
      enableSwitchAudioConfirm: enableSwitchAudioConfirm,
    );
  }

  // MARK: - 转换函数：将 pigeon 中的类转换为 models.dart 中的类

  NECallInfo? _fromPigeonCallInfo(pigeon.CallInfo? info) {
    if (info == null) return null;
    return NECallInfo(
      callId: info.callId,
      currentAccId: info.currentAccId,
      callerInfo: info.callerInfo != null
          ? NEUserInfo(
              accId: info.callerInfo!.accId,
              uid: info.callerInfo!.uid,
            )
          : null,
      calleeInfo: info.calleeInfo != null
          ? NEUserInfo(
              accId: info.calleeInfo!.accId,
              uid: info.calleeInfo!.uid,
            )
          : null,
      callType: NECallType.values[info.callType.index],
      signalInfo: info.signalInfo != null
          ? NESignalInfo(
              channelId: info.signalInfo!.channelId,
              requestId: info.signalInfo!.requestId,
              channelName: info.signalInfo!.channelName,
              extraInfo: info.signalInfo!.extraInfo,
              globalExtraCopy: info.signalInfo!.globalExtraCopy,
            )
          : null,
      rtcInfo: info.rtcInfo != null
          ? NERtcInfo(
              channelName: info.rtcInfo!.channelName,
              token: info.rtcInfo!.token,
              channelId: info.rtcInfo!.cid,
              uid: info.rtcInfo!.uid,
            )
          : null,
      callStatus: NECallEngineStatus.values[info.callStatus.index],
    );
  }

  NECallConfig? _fromPigeonCallConfig(pigeon.CallConfig? config) {
    if (config == null) return null;
    return NECallConfig(
      enableOffline: config.enableOffline,
      enableSwitchVideoConfirm: config.enableSwitchVideoConfirm,
      enableSwitchAudioConfirm: config.enableSwitchAudioConfirm,
    );
  }

  @override
  Future<VoidResult> setup(NESetupConfig config) async {
    CallKitLog.i(
      _tag,
      'initialize: version=$fltVersion',
    );

    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.setup(config);
    }

    final pigeonConfig = _toPigeonSetupConfig(config);
    final result = await _api.setup(pigeonConfig);
    return VoidResult(code: result.code, msg: result.msg);
  }

  @override
  Future<String> getVersion() async {
    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.getVersion() ?? fltVersion;
    }
    return fltVersion;
  }

  @override
  Future<NEResult<NECallInfo>> call(
    String accId,
    NECallType callType, {
    String? extraInfo,
    String? rtcChannelName,
    String? globalExtraCopy,
    NECallPushConfig? pushConfig,
  }) async {
    CallKitLog.i(
      _tag,
      'call: accId=$accId, callType=$callType, pushConfig=$pushConfig',
    );

    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.call(
        accId,
        callType,
        extraInfo: extraInfo,
        rtcChannelName: rtcChannelName,
        globalExtraCopy: globalExtraCopy,
        pushConfig: pushConfig,
      );
    }

    final pigeonParam = _toPigeonCallParam(
      accId,
      callType,
      extraInfo: extraInfo,
      rtcChannelName: rtcChannelName,
      globalExtraCopy: globalExtraCopy,
      pushConfig: pushConfig,
    );
    final result = await _api.call(pigeonParam);

    return NEResult(
      code: result.code,
      msg: result.msg,
      data: _fromPigeonCallInfo(result.callInfo),
    );
  }

  @override
  Future<NEResult<NECallInfo>> accept() async {
    CallKitLog.i(_tag, 'accept');

    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.accept();
    }

    final result = await _api.accept();

    return NEResult(
      code: result.code,
      msg: result.msg,
      data: _fromPigeonCallInfo(result.callInfo),
    );
  }

  @override
  Future<VoidResult> hangup({String? channelId, String? extraString}) async {
    CallKitLog.i(
      _tag,
      'hangup: channelId=$channelId, extraString=$extraString',
    );

    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.hangup(
        channelId: channelId,
        extraString: extraString,
      );
    }

    final pigeonParam = _toPigeonHangupParam(channelId, extraString);
    final result = await _api.hangup(pigeonParam);

    return VoidResult(code: result.code, msg: result.msg);
  }

  @override
  Future<VoidResult> switchCallType(
    NECallType callType,
    NECallSwitchState state,
  ) async {
    CallKitLog.i(_tag, 'switchCallType: callType=$callType, state=$state');

    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.switchCallType(callType, state);
    }

    final pigeonParam = _toPigeonSwitchParam(callType, state);
    final result = await _api.switchCallType(pigeonParam);

    return VoidResult(code: result.code, msg: result.msg);
  }

  @override
  Future<VoidResult> setTimeout(int time) async {
    CallKitLog.i(_tag, 'setTimeout: time=$time');

    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.setTimeout(time);
    }

    final result = await _api.setTimeout(time);

    return VoidResult(code: result.code, msg: result.msg);
  }

  @override
  Future<VoidResult> setupLocalView(int viewId) async {
    CallKitLog.i(_tag, 'setupLocalView: viewId=$viewId');

    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.setupLocalView(viewId);
    }

    final pigeonParam = _toPigeonViewParam(viewId);
    final result = await _api.setupLocalView(pigeonParam);

    return VoidResult(code: result.code, msg: result.msg);
  }

  @override
  Future<VoidResult> setupRemoteView(int viewId) async {
    CallKitLog.i(_tag, 'setupRemoteView: viewId=$viewId');

    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.setupRemoteView(viewId);
    }

    final pigeonParam = _toPigeonViewParam(viewId);
    final result = await _api.setupRemoteView(pigeonParam);

    return VoidResult(code: result.code, msg: result.msg);
  }

  @override
  Future<VoidResult> enableLocalVideo(bool enable) async {
    CallKitLog.i(_tag, 'enableLocalVideo: enable=$enable');

    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.enableLocalVideo(enable);
    }

    final result = await _api.enableLocalVideo(enable);

    return VoidResult(code: result.code, msg: result.msg);
  }

  @override
  Future<VoidResult> muteLocalVideo(bool muted) async {
    CallKitLog.i(_tag, 'muteLocalVideo: muted=$muted');

    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.muteLocalVideo(muted);
    }

    final result = await _api.muteLocalVideo(muted);

    return VoidResult(code: result.code, msg: result.msg);
  }

  @override
  Future<VoidResult> muteLocalAudio(bool muted) async {
    CallKitLog.i(_tag, 'muteLocalAudio: muted=$muted');

    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.muteLocalAudio(muted);
    }

    final result = await _api.muteLocalAudio(muted);

    return VoidResult(code: result.code, msg: result.msg);
  }

  @override
  Future<VoidResult> switchCamera() async {
    CallKitLog.i(_tag, 'switchCamera');

    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.switchCamera();
    }

    final result = await _api.switchCamera();

    return VoidResult(code: result.code, msg: result.msg);
  }

  @override
  Future<List<NEDesktopVideoDevice>> getVideoCaptureDevices() async {
    CallKitLog.i(_tag, 'getVideoCaptureDevices');
    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.getVideoCaptureDevices();
    }
    return const <NEDesktopVideoDevice>[];
  }

  @override
  Future<String?> getCurrentVideoCaptureDeviceId() async {
    CallKitLog.i(_tag, 'getCurrentVideoCaptureDeviceId');
    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.getCurrentVideoCaptureDeviceId();
    }
    return null;
  }

  @override
  Future<VoidResult> setVideoCaptureDevice(String deviceId) async {
    CallKitLog.i(_tag, 'setVideoCaptureDevice deviceId: $deviceId');
    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.setVideoCaptureDevice(deviceId);
    }
    return _desktopImpl.unsupportedResult('setVideoCaptureDevice');
  }

  @override
  Future<List<NEDesktopAudioDevice>> getAudioRecordingDevices() async {
    CallKitLog.i(_tag, 'getAudioRecordingDevices');
    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.getAudioRecordingDevices();
    }
    return const <NEDesktopAudioDevice>[];
  }

  @override
  Future<String?> getCurrentAudioRecordingDeviceId() async {
    CallKitLog.i(_tag, 'getCurrentAudioRecordingDeviceId');
    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.getCurrentAudioRecordingDeviceId();
    }
    return null;
  }

  @override
  Future<VoidResult> setAudioRecordingDevice(String deviceId) async {
    CallKitLog.i(_tag, 'setAudioRecordingDevice deviceId: $deviceId');
    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.setAudioRecordingDevice(deviceId);
    }
    return _desktopImpl.unsupportedResult('setAudioRecordingDevice');
  }

  @override
  Future<List<NEDesktopAudioDevice>> getAudioPlaybackDevices() async {
    CallKitLog.i(_tag, 'getAudioPlaybackDevices');
    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.getAudioPlaybackDevices();
    }
    return const <NEDesktopAudioDevice>[];
  }

  @override
  Future<String?> getCurrentAudioPlaybackDeviceId() async {
    CallKitLog.i(_tag, 'getCurrentAudioPlaybackDeviceId');
    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.getCurrentAudioPlaybackDeviceId();
    }
    return null;
  }

  @override
  Future<VoidResult> setAudioPlaybackDevice(String deviceId) async {
    CallKitLog.i(_tag, 'setAudioPlaybackDevice deviceId: $deviceId');
    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.setAudioPlaybackDevice(deviceId);
    }
    return _desktopImpl.unsupportedResult('setAudioPlaybackDevice');
  }

  @override
  Future<bool> isSpeakerphoneOn() async {
    CallKitLog.i(_tag, 'isSpeakerphoneOn');
    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.isSpeakerphoneOn();
    }
    return await _api.isSpeakerphoneOn();
  }

  @override
  Future<VoidResult> setSpeakerphoneOn(bool enable) async {
    CallKitLog.i(_tag, 'setSpeakerphoneOn');
    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.setSpeakerphoneOn(enable);
    }
    final result = await _api.setSpeakerphoneOn(enable);
    return VoidResult(code: result.code, msg: result.msg);
  }

  @override
  Future<VoidResult> setCallConfig({
    bool enableOffline = true,
    bool enableSwitchVideoConfirm = false,
    bool enableSwitchAudioConfirm = false,
  }) async {
    CallKitLog.i(
      _tag,
      'setCallConfig: enableOffline=$enableOffline, enableSwitchVideoConfirm=$enableSwitchVideoConfirm, enableSwitchAudioConfirm=$enableSwitchAudioConfirm',
    );

    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.setCallConfig(
        enableOffline: enableOffline,
        enableSwitchVideoConfirm: enableSwitchVideoConfirm,
        enableSwitchAudioConfirm: enableSwitchAudioConfirm,
      );
    }

    final pigeonConfig = _toPigeonCallConfig(
      enableOffline: enableOffline,
      enableSwitchVideoConfirm: enableSwitchVideoConfirm,
      enableSwitchAudioConfirm: enableSwitchAudioConfirm,
    );
    final result = await _api.setCallConfig(pigeonConfig);

    return VoidResult(code: result.code, msg: result.msg);
  }

  @override
  void addCallDelegate(NECallEngineDelegate delegate) {
    CallKitLog.i(_tag, 'addCallDelegate');
    delegates.add(delegate);
  }

  @override
  void removeCallDelegate(NECallEngineDelegate delegate) {
    CallKitLog.i(_tag, 'removeCallDelegate');
    delegates.remove(delegate);
  }

  @override
  Future<NECallInfo?> getCallInfo() async {
    CallKitLog.i(_tag, 'getCallInfo');

    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.getCallInfo();
    }

    final pigeonInfo = await _api.getCallInfo();
    return _fromPigeonCallInfo(pigeonInfo);
  }

  @override
  Future<NECallConfig?> getCallConfig() async {
    CallKitLog.i(_tag, 'getCallConfig');

    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.getCallConfig();
    }

    final pigeonConfig = await _api.getCallConfig();
    return _fromPigeonCallConfig(pigeonConfig);
  }

  @override
  Future<NEUserInfo?> getUserWithRtcUid(int uid) async {
    CallKitLog.i(_tag, 'getUserWithRtcUid uid: $uid');
    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.getUserWithRtcUid(uid);
    }
    final pigeonUser = await _api.getUserWithRtcUid(uid);
    if (pigeonUser == null) {
      return null;
    }
    return NEUserInfo(accId: pigeonUser.accId, uid: pigeonUser.uid);
  }

  @override
  Future<VoidResult> destroy() async {
    CallKitLog.i(_tag, 'destroy');

    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.destroy();
    }

    final result = await _api.destroy();

    return VoidResult(code: result.code, msg: result.msg);
  }

  @override
  Future<VoidResult> startASRCaption(NEASRCaptionConfig config) async {
    CallKitLog.i(_tag, 'startASRCaption: config=$config');
    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.unsupportedResult('startASRCaption');
    }
    final pigeonConfig = pigeon.NERtcASRCaptionConfig(
      srcLanguage: config.srcLanguage,
      srcLanguages: config.srcLanguages,
      dstLanguage: config.dstLanguage,
      dstLanguages: config.dstLanguages,
      needTranslateSameLanguage: config.needTranslateSameLanguage,
    );

    final result = await _api.startASRCaption(pigeonConfig);
    return VoidResult(code: result.code, msg: result.msg);
  }

  @override
  Future<VoidResult> stopASRCaption() async {
    CallKitLog.i(_tag, 'stopASRCaption');
    if (_desktopImpl.isDesktopRuntime) {
      return _desktopImpl.unsupportedResult('stopASRCaption');
    }
    final result = await _api.stopASRCaption();
    return VoidResult(code: result.code, msg: result.msg);
  }

  // MARK: - CallKitListener 实现

  @override
  void onReceiveInvited(pigeon.InviteInfo info) {
    CallKitLog.i(_tag, 'onReceiveInvited: callerAccId=${info.callerAccId}');
    final rawInfo = NEInviteInfo(
      callerAccId: info.callerAccId,
      callType: NECallType.values[info.callType.index],
      extraInfo: info.extraInfo,
      channelId: info.channelId,
    );
    _dispatchReceiveInvited(_desktopImpl.mapReceiveInvited(rawInfo));
  }

  @override
  void onCallEnd(pigeon.CallEndInfo info) {
    CallKitLog.i(_tag, 'onCallEnd: reasonCode=${info.reasonCode}');
    final rawInfo = NECallEndInfo(
      reasonCode: NECallTerminalCode.values[info.reasonCode.index],
      extraString: info.extraString,
      message: info.message,
    );
    _dispatchCallEnd(_desktopImpl.mapCallEnd(rawInfo));
  }

  @override
  void onCallConnected(pigeon.CallInfo info) {
    CallKitLog.i(_tag, 'onCallConnected: callId=${info.callId}');
    final rawInfo = _fromPigeonCallInfo(info);
    if (rawInfo != null) {
      _dispatchCallConnected(_desktopImpl.mapCallConnected(rawInfo));
    }
  }

  @override
  void onLCKAccept(pigeon.CallResponse response) {
    CallKitLog.i(
        _tag, 'onLCKAccept: code=${response.code}, msg=${response.msg}');
    final result = NELCKAcceptResult(
      code: response.code,
      msg: response.msg,
      callInfo: _fromPigeonCallInfo(response.callInfo),
    );
    for (var delegate in delegates) {
      delegate.onLCKAccept?.call(result);
    }
  }

  @override
  void onLCKHangup(pigeon.SimpleResponse response) {
    CallKitLog.i(
        _tag, 'onLCKHangup: code=${response.code}, msg=${response.msg}');
    final result = NELCKHangupResult(
      code: response.code,
      msg: response.msg,
    );
    for (var delegate in delegates) {
      delegate.onLCKHangup?.call(result);
    }
  }

  @override
  void onCallTypeChange(pigeon.CallTypeChangeInfo info) {
    CallKitLog.i(
      _tag,
      'onCallTypeChange: callType=${info.callType}, state=${info.state}',
    );
    final rawInfo = NECallTypeChangeInfo(
      callType: NECallType.values[info.callType.index],
      state: NECallSwitchState.values[info.state.index],
    );
    _dispatchCallTypeChange(_desktopImpl.mapCallTypeChange(rawInfo));
  }

  @override
  void onVideoAvailable(bool available, String userID) {
    CallKitLog.i(
      _tag,
      'onVideoAvailable: available=$available, userID=$userID',
    );
    for (var delegate in delegates) {
      delegate.onVideoAvailable?.call(available, userID);
    }
  }

  @override
  void onVideoMuted(bool muted, String userID) {
    CallKitLog.i(_tag, 'onVideoMuted: muted=$muted, userID=$userID');
    for (var delegate in delegates) {
      delegate.onVideoMuted?.call(muted, userID);
    }
  }

  @override
  void onAudioMuted(bool muted, String userID) {
    CallKitLog.i(_tag, 'onAudioMuted: muted=$muted, userID=$userID');
    for (var delegate in delegates) {
      delegate.onAudioMuted?.call(muted, userID);
    }
  }

  @override
  void onLocalAudioMuted(bool muted) {
    CallKitLog.i(_tag, 'onLocalAudioMuted: muted=$muted');
    for (var delegate in delegates) {
      delegate.onLocalAudioMuted?.call(muted);
    }
  }

  @override
  void onRtcInitEnd() {
    CallKitLog.i(_tag, 'onRtcInitEnd');
    for (var delegate in delegates) {
      delegate.onRtcInitEnd?.call();
    }
  }

  @override
  void onRecordSend(pigeon.RecordConfig config) {
    final modelConfig = NERecordConfig(
      accId: config.accId,
      callType: NECallType.values[config.callType.index],
      callState: NIMCallStatus.values[config.callState.index],
    );
    _handleRecordSend(modelConfig);
  }

  void _handleRecordSend(NERecordConfig modelConfig) {
    CallKitLog.i(_tag, 'onRecordSend: accId=${modelConfig.accId}');
    // 如果设置了自定义话单提供者，调用自定义提供者并截断内部流程
    if (_recordProvider != null) {
      CallKitLog.i(_tag, '使用自定义话单提供者，截断内部话单流程');
      _recordProvider!.onRecordSend(modelConfig);
      return;
    }

    // 如果没有设置自定义话单提供者，使用默认流程（SDK 内部会自动处理话单发送）
    CallKitLog.i(_tag, '使用默认话单流程，SDK 内部自动处理');
  }

  @override
  void setCallRecordProvider(NERecordProvider? provider) {
    CallKitLog.i(
      _tag,
      'setCallRecordProvider: ${provider != null ? "设置自定义提供者" : "清除自定义提供者"}',
    );
    _recordProvider = provider;
    if (_desktopImpl.isDesktopRuntime) {
      _desktopImpl.setCallRecordProvider(provider != null);
      return;
    }
    // 通知原生层是否启用自定义提供者
    // 如果设置了自定义提供者，原生层会将 FLTCallkit 自己设置为提供者
    // 这样原生层会调用 FLTCallkit.onRecordSend，然后通过回调传递到 Flutter
    _api.setCallRecordProvider(provider != null).then((result) {
      if (result.code == 0) {
        CallKitLog.i(_tag, '原生层 setCallRecordProvider 设置成功');
      } else {
        CallKitLog.e(_tag, '原生层 setCallRecordProvider 设置失败: ${result.msg}');
      }
    }).catchError((error) {
      CallKitLog.e(_tag, '原生层 setCallRecordProvider 异常: $error');
    });
  }

  @override
  void onNERtcEngineVirtualBackgroundSourceEnabled(bool enabled, int reason) {
    CallKitLog.i(
      _tag,
      'onNERtcEngineVirtualBackgroundSourceEnabled: enabled=$enabled, reason=$reason',
    );
    for (var delegate in delegates) {
      delegate.onNERtcEngineVirtualBackgroundSourceEnabled?.call(
        enabled,
        reason,
      );
    }
  }

  @override
  void onAsrCaptionStateChanged(int asrState, int code, String message) {
    CallKitLog.i(
      _tag,
      'onAsrCaptionStateChanged: asrState=$asrState, code=$code, message=$message',
    );
    for (var delegate in delegates) {
      delegate.onAsrCaptionStateChanged?.call(asrState, code, message);
    }
  }

  @override
  void onAsrCaptionResult(List<pigeon.NERtcAsrCaptionResult?> result) {
    CallKitLog.i(_tag, 'onAsrCaptionResult: resultCount=${result.length}');
    final List<NEAsrCaptionResult?> modelResult = result
        .map(
          (e) => e == null
              ? null
              : NEAsrCaptionResult(
                  uid: e.uid,
                  isLocalUser: e.isLocalUser,
                  timestamp: e.timestamp,
                  content: e.content,
                  language: e.language,
                  haveTranslation: e.haveTranslation,
                  translatedText: e.translatedText,
                  translationLanguage: e.translationLanguage,
                  isFinal: e.isFinal,
                ),
        )
        .toList();

    for (var delegate in delegates) {
      delegate.onAsrCaptionResult?.call(modelResult);
    }
  }

  void _dispatchReceiveInvited(NEInviteInfo info) {
    for (var delegate in delegates) {
      delegate.onReceiveInvited?.call(info);
    }
  }

  void _dispatchCallEnd(NECallEndInfo info) {
    final normalizedInfo = _desktopImpl.mapCallEnd(info);
    for (var delegate in delegates) {
      delegate.onCallEnd?.call(normalizedInfo);
    }
  }

  void _dispatchCallConnected(NECallInfo info) {
    for (var delegate in delegates) {
      delegate.onCallConnected?.call(info);
    }
  }

  void _dispatchCallTypeChange(NECallTypeChangeInfo info) {
    for (var delegate in delegates) {
      delegate.onCallTypeChange?.call(info);
    }
  }

  void _dispatchVideoAvailable(bool available, String userId) {
    for (var delegate in delegates) {
      delegate.onVideoAvailable?.call(available, userId);
    }
  }

  void _dispatchVideoMuted(bool muted, String userId) {
    for (var delegate in delegates) {
      delegate.onVideoMuted?.call(muted, userId);
    }
  }

  void _dispatchAudioMuted(bool muted, String userId) {
    for (var delegate in delegates) {
      delegate.onAudioMuted?.call(muted, userId);
    }
  }

  void _dispatchLocalAudioMuted(bool muted) {
    for (var delegate in delegates) {
      delegate.onLocalAudioMuted?.call(muted);
    }
  }

  void _dispatchRtcInitEnd() {
    for (var delegate in delegates) {
      delegate.onRtcInitEnd?.call();
    }
  }

  void _dispatchRtcRaw(String eventName, String jsonData) {
    CallKitLog.i(_tag, '[rtcRaw] event=$eventName data=$jsonData');
    try {
      final payload = jsonDecode(jsonData);
      if (payload is Map<String, dynamic>) {
        payload['event'] = eventName;
        _rtcRawEventController.add(payload);
      }
    } catch (_) {
      // Malformed JSON from bridge — ignore silently.
    }
  }

  @override
  Stream<Map<String, dynamic>> get rtcRawEvents =>
      _rtcRawEventController.stream;
}
