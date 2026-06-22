// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io' show Platform;
import 'package:uuid/uuid.dart';
import 'package:netease_callkit/netease_callkit.dart';
import 'callkit_log.dart';

const String _tag = 'NEGroupCallEngine';
const String _callbackTag = 'GroupCallCallback';

/// 群呼引擎实现类
class NEGroupCallEngineImpl
    implements NEGroupCallEngine, GroupCallKitEventSink, GroupMediaEventSink {
  NEGroupCallEngineImpl._() {
    // 注册 Pigeon 回调接收器
    GroupCallKitEventSink.setup(this);
    GroupMediaEventSink.setup(this);
  }

  /// 单例实例
  static final NEGroupCallEngineImpl _instance = NEGroupCallEngineImpl._();
  static NEGroupCallEngineImpl get instance => _instance;

  /// Pigeon API
  final GroupCallKitApi _api = GroupCallKitApi();

  /// 群呼业务回调代理列表
  final List<NEGroupCallEngineDelegate> _groupCallDelegates = [];

  /// 媒体事件回调代理列表
  final List<NEGroupMediaDelegate> _mediaDelegates = [];

  // ============================================================================
  // 响应码映射逻辑（200->0 转换）
  // ============================================================================

  /// 将平台层群呼业务接口响应码映射为 Flutter 层统一响应码
  /// 平台层成功码 200 -> Flutter 层成功码 0
  int _mapBusinessCode(int code) {
    return code == 200 ? 0 : code;
  }

  // ============================================================================
  // 初始化与释放
  // ============================================================================

  @override
  Future<NEGroupResult> init(NEGroupConfigParam config) async {
    CallKitLog.i(_tag, 'init');

    if (config.appKey.isEmpty) {
      CallKitLog.e(_tag, 'init failed: appKey cannot be empty');
      return const NEGroupResult(code: -1, msg: 'appKey cannot be empty');
    }

    final pigeonConfig = NEGroupConfigParam(
      appKey: config.appKey,
      rtcSafeMode: config.rtcSafeMode,
      timeout: config.timeout,
      currentUserRtcUid: config.currentUserRtcUid,
    );
    final response = await _api.init(pigeonConfig);
    final code = _mapBusinessCode(response.code);
    CallKitLog.i(_tag, 'init result: code=$code, msg=${response.msg}');
    return NEGroupResult(code: code, msg: response.msg);
  }

  @override
  Future<NEGroupResult> release() async {
    CallKitLog.i(_tag, 'release');
    final response = await _api.release();
    final code = _mapBusinessCode(response.code);
    CallKitLog.i(_tag, 'release result: code=$code, msg=${response.msg}');
    return NEGroupResult(code: code, msg: response.msg);
  }

  // ============================================================================
  // 群呼基础操作
  // ============================================================================

  @override
  Future<NEGroupCallResult> groupCall(NEGroupCallParam param) async {
    // 如果没有传入 callId，则生成一个（与 iOS 原生行为一致）
    final effectiveParam = (param.callId == null || param.callId!.isEmpty)
        ? NEGroupCallParam(
            callId: const Uuid().v4(),
            calleeList: param.calleeList,
            groupId: param.groupId,
            groupType: param.groupType,
            inviteMode: param.inviteMode,
            joinMode: param.joinMode,
            extraInfo: param.extraInfo,
            pushParam: param.pushParam,
          )
        : param;

    CallKitLog.i(_tag,
        'groupCall: callId=${effectiveParam.callId}, calleeList=${effectiveParam.calleeList.length}, groupType=${effectiveParam.groupType}');
    final response = await _api.groupCall(effectiveParam);
    final code = _mapBusinessCode(response.code);
    CallKitLog.i(_tag,
        'groupCall result: code=$code, msg=${response.msg}, callId=${response.callInfo?.callId}');

    // iOS 平台：补充 callInfo 的缺失字段
    // iOS 原生 SDK 的 GroupCallResult 只包含 callId, callerUid, startTimestamp
    final callInfo = Platform.isIOS && response.callInfo != null
        ? _completeCallInfoForIOS(response.callInfo!, param)
        : response.callInfo;

    return NEGroupCallResult(
      code: code,
      msg: response.msg,
      callInfo: callInfo,
    );
  }

  /// iOS 平台：补充 callInfo 的缺失字段
  ///
  /// iOS 原生 SDK 的 GroupCallResult 只包含 callId, callerRtcUid, startTimestamp
  /// 需要从传入参数补充其他字段
  NEGroupCallInfo _completeCallInfoForIOS(
      NEGroupCallInfo partialInfo, NEGroupCallParam param) {
    // 构建成员列表
    final members = <NEGroupCallMember>[];

    // 添加主叫方（caller），状态为 JOINED
    if (partialInfo.callerAccId != null) {
      members.add(NEGroupCallMember(
        accId: partialInfo.callerAccId!,
        rtcUid: partialInfo.callerRtcUid,
        state: NEGroupUserState.JOINED,
      ));
    }

    // 添加被叫成员，状态为 WAITING
    for (final accId in param.calleeList) {
      if (accId != null) {
        members.add(NEGroupCallMember(
          accId: accId,
          rtcUid: null, // 发起时未分配
          state: NEGroupUserState.WAITING,
        ));
      }
    }

    return NEGroupCallInfo(
      callId: partialInfo.callId,
      groupId: partialInfo.groupId ?? param.groupId,
      groupType: partialInfo.groupType ?? param.groupType,
      callerAccId: partialInfo.callerAccId,
      callerRtcUid: partialInfo.callerRtcUid,
      memberList: partialInfo.memberList ?? members,
      inviteMode: partialInfo.inviteMode ?? param.inviteMode,
      joinMode: partialInfo.joinMode ?? param.joinMode,
      extraInfo: partialInfo.extraInfo ?? param.extraInfo,
      startTimestamp: partialInfo.startTimestamp,
    );
  }

  @override
  Future<NEGroupAcceptResult> groupAccept(NEGroupAcceptParam param) async {
    CallKitLog.i(_tag, 'groupAccept: callId=${param.callId}');
    final response = await _api.groupAccept(param);
    final code = _mapBusinessCode(response.code);
    CallKitLog.i(_tag, 'groupAccept result: code=$code, msg=${response.msg}');
    return NEGroupAcceptResult(
      code: code,
      msg: response.msg,
      callInfo: response.callInfo,
    );
  }

  @override
  Future<NEGroupHangupResult> groupHangup(NEGroupHangupParam param) async {
    CallKitLog.i(
        _tag, 'groupHangup: callId=${param.callId}, reason=${param.reason}');
    final response = await _api.groupHangup(param);
    final code = _mapBusinessCode(response.code);
    CallKitLog.i(_tag, 'groupHangup result: code=$code, msg=${response.msg}');
    return NEGroupHangupResult(code: code, msg: response.msg);
  }

  @override
  Future<NEGroupInviteResult> groupInvite(NEGroupInviteParam param) async {
    CallKitLog.i(_tag,
        'groupInvite: callId=${param.callId}, calleeList=${param.calleeList.length}');
    final response = await _api.groupInvite(param);
    final code = _mapBusinessCode(response.code);
    CallKitLog.i(_tag, 'groupInvite result: code=$code, msg=${response.msg}');
    return NEGroupInviteResult(code: code, msg: response.msg);
  }

  @override
  Future<NEGroupJoinResult> groupJoin(NEGroupJoinParam param) async {
    CallKitLog.i(_tag, 'groupJoin: callId=${param.callId}');
    final response = await _api.groupJoin(param);
    final code = _mapBusinessCode(response.code);
    CallKitLog.i(_tag, 'groupJoin result: code=$code, msg=${response.msg}');
    return NEGroupJoinResult(
      code: code,
      msg: response.msg,
      callInfo: response.callInfo,
    );
  }

  @override
  Future<NEGroupQueryCallInfoResult> groupQueryCallInfo(String callId) async {
    CallKitLog.i(_tag, 'groupQueryCallInfo: callId=$callId');
    final response = await _api.groupQueryCallInfo(callId);
    final code = _mapBusinessCode(response.code);
    CallKitLog.i(
        _tag, 'groupQueryCallInfo result: code=$code, msg=${response.msg}');
    return NEGroupQueryCallInfoResult(
      code: code,
      msg: response.msg,
      callInfo: response.callInfo,
    );
  }

  @override
  Future<NEGroupQueryMembersResult> groupQueryMembers(String callId) async {
    CallKitLog.i(_tag, 'groupQueryMembers: callId=$callId');
    final response = await _api.groupQueryMembers(callId);
    final code = _mapBusinessCode(response.code);
    CallKitLog.i(_tag,
        'groupQueryMembers result: code=$code, msg=${response.msg}, members=${response.members?.length}');
    return NEGroupQueryMembersResult(
      code: code,
      msg: response.msg,
      members: response.members?.whereType<NEGroupCallMember>().toList(),
    );
  }

  // ============================================================================
  // 媒体操作接口
  // ============================================================================

  @override
  Future<NEGroupMediaResult> enableLocalVideo(bool enable) async {
    CallKitLog.i(_tag, 'enableLocalVideo: enable=$enable');
    final response = await _api.enableLocalVideo(enable);
    // 媒体接口响应码直接透传（成功码为 0）
    CallKitLog.i(_tag,
        'enableLocalVideo result: code=${response.code}, msg=${response.msg}');
    return NEGroupMediaResult(code: response.code, msg: response.msg);
  }

  @override
  Future<NEGroupMediaResult> muteLocalVideo(bool mute) async {
    CallKitLog.i(_tag, 'muteLocalVideo: mute=$mute');
    final response = await _api.muteLocalVideo(mute);
    CallKitLog.i(_tag,
        'muteLocalVideo result: code=${response.code}, msg=${response.msg}');
    return NEGroupMediaResult(code: response.code, msg: response.msg);
  }

  @override
  Future<NEGroupMediaResult> enableLocalAudio(bool enable) async {
    CallKitLog.i(_tag, 'enableLocalAudio: enable=$enable');
    final response = await _api.enableLocalAudio(enable);
    CallKitLog.i(_tag,
        'enableLocalAudio result: code=${response.code}, msg=${response.msg}');
    return NEGroupMediaResult(code: response.code, msg: response.msg);
  }

  @override
  Future<NEGroupMediaResult> muteLocalAudio(bool mute) async {
    CallKitLog.i(_tag, 'muteLocalAudio: mute=$mute');
    final response = await _api.muteLocalAudio(mute);
    CallKitLog.i(_tag,
        'muteLocalAudio result: code=${response.code}, msg=${response.msg}');
    return NEGroupMediaResult(code: response.code, msg: response.msg);
  }

  @override
  Future<NEGroupMediaResult> setSpeakerphoneOn(bool enable) async {
    CallKitLog.i(_tag, 'setSpeakerphoneOn: enable=$enable');
    final response = await _api.setSpeakerphoneOn(enable);
    CallKitLog.i(_tag,
        'setSpeakerphoneOn result: code=${response.code}, msg=${response.msg}');
    return NEGroupMediaResult(code: response.code, msg: response.msg);
  }

  @override
  Future<bool> isSpeakerphoneOn() async {
    CallKitLog.i(_tag, 'isSpeakerphoneOn');
    final result = await _api.isSpeakerphoneOn();
    CallKitLog.i(_tag, 'isSpeakerphoneOn result: $result');
    return result;
  }

  @override
  Future<NEGroupMediaResult> switchCamera() async {
    CallKitLog.i(_tag, 'switchCamera');
    final response = await _api.switchCamera();
    CallKitLog.i(_tag,
        'switchCamera result: code=${response.code}, msg=${response.msg}');
    return NEGroupMediaResult(code: response.code, msg: response.msg);
  }

  @override
  Future<NEGroupMediaResult> setupLocalView(int? viewId) async {
    CallKitLog.i(_tag, 'setupLocalView: viewId=$viewId');
    final param = NEGroupViewParam(viewId: viewId);
    final response = await _api.setupLocalView(param);
    CallKitLog.i(_tag,
        'setupLocalView result: code=${response.code}, msg=${response.msg}');
    return NEGroupMediaResult(code: response.code, msg: response.msg);
  }

  @override
  Future<NEGroupMediaResult> setupRemoteView(int uid, int? viewId) async {
    CallKitLog.i(_tag, 'setupRemoteView: uid=$uid, viewId=$viewId');
    final param = NEGroupViewParam(viewId: viewId, uid: uid);
    final response = await _api.setupRemoteView(param);
    CallKitLog.i(_tag,
        'setupRemoteView result: code=${response.code}, msg=${response.msg}');
    return NEGroupMediaResult(code: response.code, msg: response.msg);
  }

  @override
  Future<NEGroupMediaResult> enableAudioVolumeIndication(
      bool enable, int interval) async {
    CallKitLog.i(
        _tag, 'enableAudioVolumeIndication: enable=$enable, interval=$interval');
    final response = await _api.enableAudioVolumeIndication(enable, interval);
    CallKitLog.i(_tag,
        'enableAudioVolumeIndication result: code=${response.code}, msg=${response.msg}');
    return NEGroupMediaResult(code: response.code, msg: response.msg);
  }

  @override
  Future<NEGroupMediaResult> setParameters(Map<String, dynamic> params) async {
    CallKitLog.i(_tag, 'setParameters: params=$params');
    final response = await _api.setParameters(params);
    CallKitLog.i(_tag,
        'setParameters result: code=${response.code}, msg=${response.msg}');
    return NEGroupMediaResult(code: response.code, msg: response.msg);
  }

  // ============================================================================
  // 回调代理管理
  // ============================================================================

  @override
  void addGroupCallDelegate(NEGroupCallEngineDelegate delegate) {
    if (!_groupCallDelegates.contains(delegate)) {
      _groupCallDelegates.add(delegate);
      CallKitLog.i(_tag,
          'addGroupCallDelegate: total=${_groupCallDelegates.length}');
    }
  }

  @override
  void removeGroupCallDelegate(NEGroupCallEngineDelegate delegate) {
    _groupCallDelegates.remove(delegate);
    CallKitLog.i(_tag,
        'removeGroupCallDelegate: total=${_groupCallDelegates.length}');
  }

  @override
  void addGroupMediaDelegate(NEGroupMediaDelegate delegate) {
    if (!_mediaDelegates.contains(delegate)) {
      _mediaDelegates.add(delegate);
      CallKitLog.i(
          _tag, 'addGroupMediaDelegate: total=${_mediaDelegates.length}');
    }
  }

  @override
  void removeGroupMediaDelegate(NEGroupMediaDelegate delegate) {
    _mediaDelegates.remove(delegate);
    CallKitLog.i(
        _tag, 'removeGroupMediaDelegate: total=${_mediaDelegates.length}');
  }

  // ============================================================================
  // GroupCallKitEventSink 实现 (Pigeon 业务回调接收器)
  // ============================================================================

  @override
  void onReceiveGroupInvitation(NEGroupCallInfo info) {
    CallKitLog.i(_callbackTag,
        'onReceiveGroupInvitation: callId=${info.callId}, caller=${info.callerAccId}');
    for (final delegate in _groupCallDelegates) {
      delegate.onReceiveGroupInvitation?.call(info);
    }
  }

  @override
  void onGroupMemberListChanged(
      String callId, List<NEGroupCallMember?> members) {
    CallKitLog.i(_callbackTag,
        'onGroupMemberListChanged: callId=$callId, members=${members.map((e) => e?.description).join(',')}');
    final memberList = members.whereType<NEGroupCallMember>().toList();
    for (final delegate in _groupCallDelegates) {
      delegate.onGroupMemberListChanged?.call(callId, memberList);
    }
  }

  @override
  void onGroupCallHangup(NEGroupCallHangupEvent event) {
    CallKitLog.i(_callbackTag,
        'onGroupCallHangup: callId=${event.callId}, reason=${event.reason}');
    for (final delegate in _groupCallDelegates) {
      delegate.onGroupCallHangup?.call(event);
    }
  }

  @override
  void onGroupCallEnd(NEGroupCallEndEvent event) {
    CallKitLog.i(_callbackTag,
        'onGroupCallEnd: callId=${event.callId}, reason=${event.reason}');
    for (final delegate in _groupCallDelegates) {
      delegate.onGroupCallEnd?.call(event);
    }
  }

  // ============================================================================
  // GroupMediaEventSink 实现 (Pigeon 媒体回调接收器)
  // ============================================================================

  @override
  void onUserAudioStart(int uid) {
    CallKitLog.i(_callbackTag, 'onUserAudioStart: uid=$uid');
    for (final delegate in _mediaDelegates) {
      delegate.onUserAudioStart?.call(uid);
    }
  }

  @override
  void onUserAudioStop(int uid) {
    CallKitLog.i(_callbackTag, 'onUserAudioStop: uid=$uid');
    for (final delegate in _mediaDelegates) {
      delegate.onUserAudioStop?.call(uid);
    }
  }

  @override
  void onUserAudioMute(int uid, bool muted) {
    CallKitLog.i(_callbackTag, 'onUserAudioMute: uid=$uid, muted=$muted');
    for (final delegate in _mediaDelegates) {
      delegate.onUserAudioMute?.call(uid, muted);
    }
  }

  @override
  void onUserVideoStart(int uid, int maxProfile) {
    CallKitLog.i(
        _callbackTag, 'onUserVideoStart: uid=$uid, maxProfile=$maxProfile');
    for (final delegate in _mediaDelegates) {
      delegate.onUserVideoStart?.call(uid, maxProfile);
    }
  }

  @override
  void onUserVideoStop(int uid) {
    CallKitLog.i(_callbackTag, 'onUserVideoStop: uid=$uid');
    for (final delegate in _mediaDelegates) {
      delegate.onUserVideoStop?.call(uid);
    }
  }

  @override
  void onUserVideoMute(int uid, bool muted) {
    CallKitLog.i(_callbackTag, 'onUserVideoMute: uid=$uid, muted=$muted');
    for (final delegate in _mediaDelegates) {
      delegate.onUserVideoMute?.call(uid, muted);
    }
  }

  @override
  void onRemoteAudioVolumeIndication(
      List<NEAudioVolumeInfo?> volumes, int totalVolume) {
    // CallKitLog.i(_callbackTag,
    //     'onRemoteAudioVolumeIndication: volumes=${volumes.length}, totalVolume=$totalVolume');
    final volumeList = volumes.whereType<NEAudioVolumeInfo>().toList();
    for (final delegate in _mediaDelegates) {
      delegate.onRemoteAudioVolumeIndication?.call(volumeList, totalVolume);
    }
  }

  @override
  void onDisconnect(int reason) {
    CallKitLog.i(_callbackTag, 'onDisconnect: reason=$reason');
    for (final delegate in _mediaDelegates) {
      delegate.onDisconnect?.call(reason);
    }
  }

  @override
  void onError(int code) {
    CallKitLog.i(_callbackTag, 'onError: code=$code');
    for (final delegate in _mediaDelegates) {
      delegate.onError?.call(code);
    }
  }
}

extension on NEGroupCallMember {
  String get description {
    return 'GM(accId: $accId, rtcUid: $rtcUid, state: $state, action: $action, reason: $reason)';
  }
}
