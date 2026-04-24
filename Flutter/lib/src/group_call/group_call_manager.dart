// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:netease_callkit/netease_callkit.dart';

import '../call_define.dart';
import '../call_uikit.dart';
import '../data/constants.dart';
import '../extensions/calling_bell_feature.dart';
import '../ui/call_navigator_observer.dart';
import '../utils/callkit_ui_log.dart';
import '../utils/nim_utils.dart';
import '../utils/permission.dart';
import '../utils/string_stream.dart';
import 'group_call_member_ui.dart';
import 'group_call_state.dart';
import 'group_call_ui_state.dart';
import 'speaking_state_manager.dart';
import 'widget/group_call_incoming_page.dart';
import 'widget/group_calls_widget.dart';

/// 群呼业务逻辑管理器 (单例)
///
/// 负责：
/// - 群呼状态生命周期管理
/// - NEGroupCallEngine 回调处理
/// - 业务逻辑编排
class GroupCallManager {
  static const String _tag = 'GroupCallManager';
  static const int maxGroupCallParticipants = 10;

  GroupCallManager._();

  static final GroupCallManager _instance = GroupCallManager._();

  /// 获取单例实例
  static GroupCallManager get instance => _instance;

  /// 当前群呼状态
  GroupCallState? _currentState;

  /// 当前群呼状态 getter
  GroupCallState? get currentState => _currentState;

  /// 群呼引擎委托
  NEGroupCallEngineDelegate? _delegate;

  /// 媒体事件委托
  NEGroupMediaDelegate? _mediaDelegate;

  /// 讲话状态管理器
  SpeakingStateManager? _speakingStateManager;

  /// 本地用户 ID
  String? _localUserId;

  /// 邀请按钮回调（参数为当前通话的 callId）
  void Function(String callId)? _onInvitePressed;

  /// 全局邀请按钮回调（被叫收到来电时使用）
  void Function(String callId)? _globalInviteHandler;

  /// 设置全局邀请按钮回调
  void setGlobalInviteHandler(void Function(String callId)? handler) {
    _globalInviteHandler = handler;
  }

  /// 获取有效的邀请按钮回调：优先使用单次传入的，其次使用全局注册的
  void Function(String callId)? get onInvitePressed =>
      _onInvitePressed ?? _globalInviteHandler;

  /// 群呼页面是否已打开
  bool _isPageLaunched = false;

  /// 群呼 API 挂起的 Completer，用于处理 SDK 不回调 completion 的情况
  Completer<NEGroupCallResult>? _pendingGroupCallCompleter;

  /// 待响应的被叫人数（用于判断是否所有被叫都已离开）
  int _pendingCalleeCount = 0;

  /// 页面关闭回调
  VoidCallback? _onClosePageRequested;

  /// 1v1 回调委托（用于多端登录场景：其他设备接听/拒绝群呼时关闭本端来电页面）
  NECallEngineDelegate? _callDelegate;

  /// 初始化群呼管理器
  ///
  /// 注册 NEGroupCallEngine 的回调委托
  /// [localUserId] 本地用户 ID
  /// [config] 群呼引擎配置参数（可选）
  Future<void> setup({
    required String localUserId,
    NEGroupConfigParam? config,
  }) async {
    _localUserId = localUserId;

    // 如果提供了配置参数，则初始化群呼引擎
    if (config != null) {
      final result = await NEGroupCallEngine.instance.init(config);
      if (result.code == 0) {
        CallKitUILog.i(_tag, 'GroupCallEngine init success');
      } else {
        final errorMsg = 'GroupCallEngine init failed: ${result.msg ?? "code=${result.code}"}';
        CallKitUILog.e(_tag, errorMsg);
      }
    }

    // 创建并注册群呼委托
    _delegate = NEGroupCallEngineDelegate(
      onReceiveGroupInvitation: _handleReceiveGroupInvitation,
      onGroupMemberListChanged: _handleGroupMemberListChanged,
      onGroupCallHangup: _handleGroupCallHangup,
      onGroupCallEnd: _handleGroupCallEnd,
    );
    NEGroupCallEngine.instance.addGroupCallDelegate(_delegate!);

    // 创建讲话状态管理器
    _speakingStateManager = SpeakingStateManager(
      onSpeakingStateChanged: _handleSpeakingStateChanged,
    );
    _speakingStateManager!.setLocalUserId(localUserId);

    // 创建并注册媒体委托
    _mediaDelegate = NEGroupMediaDelegate(
      onUserAudioStart: _handleUserAudioStart,
      onUserAudioStop: _handleUserAudioStop,
      onUserVideoStart: _handleUserVideoStart,
      onUserVideoStop: _handleUserVideoStop,
      onUserVideoMute: _handleUserVideoMute,
      onRemoteAudioVolumeIndication: _handleRemoteAudioVolumeIndication,
    );
    NEGroupCallEngine.instance.addGroupMediaDelegate(_mediaDelegate!);

    // 注册 1v1 回调，处理多端登录场景（其他设备接听/拒绝群呼时关闭本端来电页面）
    _callDelegate = NECallEngineDelegate(
      onCallEnd: (NECallEndInfo info) async {
        if (_currentState == null) return;
        if (info.reasonCode == NECallTerminalCode.otherAccepted ||
            info.reasonCode == NECallTerminalCode.otherRejected) {
          CallKitUILog.i(_tag,
              'onCallEnd: 多端场景，其他设备已处理群呼 reason=${info.reasonCode}');
          _stopRing();
          _disposeCurrentState();
          _requestClosePage();
        }
      },
    );
    NECallEngine.instance.addCallDelegate(_callDelegate!);
  }

  /// 释放资源
  void release() {
    if (_delegate != null) {
      NEGroupCallEngine.instance.removeGroupCallDelegate(_delegate!);
      _delegate = null;
    }
    if (_mediaDelegate != null) {
      NEGroupCallEngine.instance.removeGroupMediaDelegate(_mediaDelegate!);
      _mediaDelegate = null;
    }
    if (_callDelegate != null) {
      NECallEngine.instance.removeCallDelegate(_callDelegate!);
      _callDelegate = null;
    }
    _speakingStateManager?.dispose();
    _speakingStateManager = null;
    _onClosePageRequested = null;
    _disposeCurrentState();
  }

  /// 注册页面关闭回调
  ///
  /// 由页面在 didChangeDependencies 中调用
  void registerClosePageCallback(VoidCallback callback) {
    _onClosePageRequested = callback;
    CallKitUILog.d(_tag, 'registerClosePageCallback: callback registered');
  }

  /// 注销页面关闭回调
  ///
  /// 由页面在 dispose 中调用
  /// 只有当前注册的回调与要注销的回调相同时才清空，避免页面切换时误清空
  void unregisterClosePageCallback(VoidCallback callback) {
    if (_onClosePageRequested == callback) {
      _onClosePageRequested = null;
      CallKitUILog.d(_tag, 'unregisterClosePageCallback: callback unregistered');
    } else {
      CallKitUILog.d(_tag, 'unregisterClosePageCallback: callback mismatch, ignored');
    }
  }

  // ============================================================================
  // 辅助方法
  // ============================================================================

  /// 显示错误提示
  ///
  /// [message] 错误信息
  void _showErrorToast(String message) {
    if (message.isNotEmpty) {
      Fluttertoast.showToast(msg: message);
    }
  }

  // ============================================================================
  // 公共 API 方法
  // ============================================================================

  /// 发起群呼
  ///
  /// [param] 群呼参数
  /// [onInvitePressed] 邀请按钮点击回调，参数为当前通话的 callId
  Future<NEGroupCallResult> groupCall(
    NEGroupCallParam param, {
    void Function(String callId)? onInvitePressed,
  }) async {
    _onInvitePressed = onInvitePressed;

    CallKitUILog.i(_tag, 'groupCall: callId=${param.callId}');

    // 人数限制：被叫人数 + 自己 ≤ maxGroupCallParticipants
    if (param.calleeList.length + 1 > maxGroupCallParticipants) {
      CallKitUILog.e(_tag, 'groupCall: exceed max participants (${param.calleeList.length + 1} > $maxGroupCallParticipants)');
      Fluttertoast.showToast(msg: NECallKitUI.localizations.groupCallMembersFull);
      return NEGroupCallResult(code: -1, msg: NECallKitUI.localizations.groupCallMembersFull);
    }

    // iOS SDK 内部会校验麦克风和摄像头权限，需提前请求
    if (Platform.isIOS) {
      await Permission.request(NECallType.video);
    }

    // 使用 Completer 模式：SDK 在被叫拒绝等场景下可能不回调 groupCall 的 completion，
    // 此时 onGroupCallEnd 会先触发。通过 Completer 确保 Future 一定能完成。
    _pendingCalleeCount = param.calleeList.length;
    _pendingGroupCallCompleter = Completer<NEGroupCallResult>();

    NEGroupCallEngine.instance.groupCall(param).then((result) {
      if (_pendingGroupCallCompleter != null && !_pendingGroupCallCompleter!.isCompleted) {
        _pendingGroupCallCompleter!.complete(result);
      }
    }).catchError((Object e) {
      if (_pendingGroupCallCompleter != null && !_pendingGroupCallCompleter!.isCompleted) {
        _pendingGroupCallCompleter!.complete(
          NEGroupCallResult(code: -1, msg: '${NECallKitUI.localizations.groupCallCreateFailed}: $e'),
        );
      }
    });

    final result = await _pendingGroupCallCompleter!.future;
    _pendingGroupCallCompleter = null;
    _pendingCalleeCount = 0;

    if (result.code == 0 && result.callInfo != null) {
      CallKitUILog.i(_tag, 'groupCall success: callId=${result.callInfo!.callId}');

      // 创建 calling 状态
      _createGroupCallState(
        callId: result.callInfo!.callId,
        initialState: GroupCallUIState.calling,
        callInfo: result.callInfo!,
      );

      // 启动呼叫中铃声
      _startGroupCallingRing();

      // 打开群呼页面（媒体设备初始化在 GroupCallsWidget.initState 中统一处理）
      _launchGroupCallPage();
    } else {
      final errorMsg = 'groupCall failed: ${result.msg ?? "code=${result.code}"}';
      CallKitUILog.e(_tag, errorMsg);
    }

    return result;
  }

  /// 加入群呼
  ///
  /// [param] 加入参数
  /// [onInvitePressed] 邀请按钮点击回调，参数为当前通话的 callId
  Future<NEGroupJoinResult> groupJoin(
    NEGroupJoinParam param, {
    void Function(String callId)? onInvitePressed,
  }) async {
    _onInvitePressed = onInvitePressed;

    // 调用引擎加入群呼
    final result = await NEGroupCallEngine.instance.groupJoin(param);

    if (result.code == 0 && result.callInfo != null) {
      CallKitUILog.i(_tag, 'groupJoin success: callId=${param.callId}');

      // 创建 inCall 状态（加入成功直接进入通话中）
      _createGroupCallState(
        callId: param.callId,
        initialState: GroupCallUIState.inCall,
        callInfo: result.callInfo!,
      );

      // 打开群呼页面（媒体设备初始化在 GroupCallsWidget.initState 中统一处理）
      _launchGroupCallPage();
    } else {
      final errorMsg = 'groupJoin failed: ${result.msg ?? "code=${result.code}"}';
      CallKitUILog.e(_tag, errorMsg);
    }

    return result;
  }

  /// 接听群呼
  Future<NEGroupAcceptResult> accept(String callId) async {
    CallKitUILog.i(_tag, 'accept: callId=$callId');
    final param = NEGroupAcceptParam(callId: callId);
    final result = await NEGroupCallEngine.instance.groupAccept(param);

    if (result.code == 0) {
      // 停止来电铃声
      _stopRing();

      // 更新状态为 inCall
      _currentState?.updateUIState(GroupCallUIState.inCall);

      // 合并 accept 返回的最新成员状态，修复邀请到接听期间
      // 已加入成员仍显示 loading 动画的问题
      if (result.callInfo != null) {
        _mergeMembersFromCallInfo(result.callInfo!);
      }

      // 媒体设备初始化在页面跳转后由 GroupCallsWidget.initState 统一处理
    }

    return result;
  }

  /// 拒绝群呼（带通知）
  Future<NEGroupHangupResult> reject(String callId) async {
    CallKitUILog.i(_tag, 'reject: callId=$callId');
    final param = NEGroupHangupParam(callId: callId);
    final result = await NEGroupCallEngine.instance.groupHangup(param);
    CallKitUILog.i(_tag, 'reject result: code=${result.code}');

    // 无论 reject 结果如何都执行清理和关闭页面
    // 场景：主叫取消同时被叫拒绝，groupHangup 可能返回错误码（通话已结束），
    // 但被叫端仍需关闭来电页面
    _stopRing();
    _disposeCurrentState();
    _requestClosePage();

    return result;
  }

  /// 忽略群呼（静默拒绝）
  Future<void> ignore(String callId) async {
    CallKitUILog.i(_tag, 'ignore: callId=$callId');
    // 忽略逻辑：静默拒绝，不发送通知
    _stopRing();
    _disposeCurrentState();

    // 关闭页面
    _requestClosePage();
  }

  /// 挂断群呼
  Future<NEGroupHangupResult> hangup(String callId) async {
    CallKitUILog.i(_tag, 'hangup: callId=$callId');
    final param = NEGroupHangupParam(callId: callId);
    final result = await NEGroupCallEngine.instance.groupHangup(param);

    if (result.code == 0) {
      _stopRing();
      _disposeCurrentState();
      _requestClosePage();
    }

    return result;
  }

  /// 切换麦克风
  ///
  /// 打开麦克风时会检查权限并初始化音频设备（如无权限会自动请求）
  Future<void> toggleMicrophone() async {
    if (_currentState == null) return;

    final isMuted = _currentState!.isMicrophoneMute;

    if (isMuted) {
      // 当前是静音状态，要打开麦克风
      // 检查权限并初始化音频设备（_checkAndInitializeAudio 会自动请求权限）
      final hasPermission = await _checkAndInitializeAudio();
      if (!hasPermission) {
        // 权限被拒绝或初始化失败
        CallKitUILog.i(_tag, 'toggleMicrophone: failed to initialize audio');
        return;
      }

      // 打开麦克风
      await NEGroupCallEngine.instance.muteLocalAudio(false);
      _currentState!.updateMicrophoneState(false);
    } else {
      // 当前是打开状态，要关闭麦克风
      await NEGroupCallEngine.instance.muteLocalAudio(true);
      _currentState!.updateMicrophoneState(true);
    }
  }

  /// 切换摄像头
  ///
  /// 打开摄像头时会检查权限（如无权限会自动请求）
  Future<void> toggleCamera() async {
    if (_currentState == null) return;

    final newCameraState = !_currentState!.isCameraOpen;

    if (newCameraState) {
      // 打开摄像头：先检查并请求相机权限
      final hasPermission = await _checkAndRequestCameraPermission();
      if (!hasPermission) {
        // 权限被拒绝，不打开摄像头
        CallKitUILog.i(_tag, 'toggleCamera: camera permission denied');
        return;
      }
      
      // 有权限，打开摄像头
      await NEGroupCallEngine.instance.enableLocalVideo(true);
      _currentState!.updateCameraState(true);
    } else {
      // 关闭摄像头
      await NEGroupCallEngine.instance.enableLocalVideo(false);
      _currentState!.updateCameraState(false);
    }
  }

  /// 检查并请求相机权限
  ///
  /// 如果没有权限，会主动请求相机权限
  /// 返回 true 表示权限可用
  Future<bool> _checkAndRequestCameraPermission() async {
    // 检查是否已有相机权限
    var hasPermission = await Permission.has(
      permissions: [PermissionType.camera],
    );

    if (!hasPermission) {
      CallKitUILog.i(_tag, '_checkAndRequestCameraPermission: no camera permission, requesting...');
      
      // 请求相机权限（使用 Permission.requestCamera 方法，支持国际化）
      final result = await Permission.requestCamera();
      
      if (result == PermissionResult.granted) {
        hasPermission = true;
        CallKitUILog.i(_tag, '_checkAndRequestCameraPermission: camera permission granted');
      } else {
        CallKitUILog.i(_tag, '_checkAndRequestCameraPermission: camera permission denied');
        _showErrorToast(NECallKitUI.localizations.startCameraPermissionDenied);
        return false;
      }
    }

    return true;
  }

  /// 切换扬声器
  Future<void> toggleSpeaker() async {
    if (_currentState == null) return;

    final newSpeakerState = !_currentState!.isSpeakerOn;
    await NEGroupCallEngine.instance.setSpeakerphoneOn(newSpeakerState);
    _currentState!.updateSpeakerState(newSpeakerState);
  }

  /// 切换前后摄像头
  Future<void> switchCamera() async {
    await NEGroupCallEngine.instance.switchCamera();
  }

  /// 邀请更多成员加入群呼
  ///
  /// [userIds] 被邀请用户的 ID 列表
  /// 返回 [NEGroupInviteResult] 结果
  Future<NEGroupInviteResult> inviteMembers(List<String> userIds) async {
    if (_currentState == null) {
      CallKitUILog.e(_tag, 'inviteMembers: currentState is null');
      return const NEGroupInviteResult(code: -1, msg: 'No active call');
    }

    // 过滤掉已在通话中的用户
    final existingUserIds = _currentState!.members
        .map((m) => m.userId)
        .toSet();
    final filteredUserIds = userIds.where((id) => !existingUserIds.contains(id)).toList();

    if (filteredUserIds.isEmpty) {
      CallKitUILog.i(_tag, 'inviteMembers: all users already in call');
      Fluttertoast.showToast(msg: NECallKitUI.localizations.userInCall);
      return const NEGroupInviteResult(code: -1, msg: 'All users already in call');
    }

    // 人数限制：当前成员数 + 新邀请人数 ≤ maxGroupCallParticipants
    if (existingUserIds.length + filteredUserIds.length > maxGroupCallParticipants) {
      CallKitUILog.e(_tag, 'inviteMembers: exceed max participants (${existingUserIds.length} + ${filteredUserIds.length} > $maxGroupCallParticipants)');
      Fluttertoast.showToast(msg: NECallKitUI.localizations.groupCallMembersFull);
      return NEGroupInviteResult(code: -1, msg: NECallKitUI.localizations.groupCallMembersFull);
    }

    CallKitUILog.i(_tag, 'inviteMembers: callId=${_currentState!.callId}, userIds=$filteredUserIds (filtered from $userIds)');

    final param = NEGroupInviteParam(
      callId: _currentState!.callId,
      calleeList: filteredUserIds,
    );

    final result = await NEGroupCallEngine.instance.groupInvite(param);

    if (result.code == 0) {
      CallKitUILog.i(_tag, 'inviteMembers success');
    } else {
      final errorMsg = 'inviteMembers failed: ${result.msg ?? "code=${result.code}"}';
      CallKitUILog.e(_tag, errorMsg);
    }

    return result;
  }

  // ============================================================================
  // 内部方法
  // ============================================================================

  /// 创建群呼状态
  void _createGroupCallState({
    required String callId,
    required GroupCallUIState initialState,
    required NEGroupCallInfo callInfo,
  }) {
    // 销毁旧状态
    _disposeCurrentState();

    // 创建新状态
    _currentState = GroupCallState(
      callId: callId,
      initialState: initialState,
      localUserId: _localUserId ?? '',
      callerUserId: callInfo.callerAccId,
    );

    // 初始化成员列表
    _syncMembersFromCallInfo(callInfo);
  }

  /// 销毁当前状态
  void _disposeCurrentState() {
    _currentState?.dispose();
    _currentState = null;
    _onInvitePressed = null;
  }

  /// 重置音视频设备状态
  ///
  /// 在通话页面 dispose 时调用，将音视频设备恢复到默认状态：
  /// - 关闭摄像头
  /// - 静音麦克风
  /// - 关闭音频采集
  /// - 关闭音量回调
  ///
  /// 与 [initializeMediaDevices] 配对使用
  Future<void> resetMediaDevices() async {
    CallKitUILog.i(_tag, 'resetMediaDevices');

    try {
      // 关闭摄像头
      await NEGroupCallEngine.instance.enableLocalVideo(false);
      CallKitUILog.d(_tag, 'resetMediaDevices: enableLocalVideo(false) success');

      // 静音麦克风
      await NEGroupCallEngine.instance.muteLocalAudio(true);
      CallKitUILog.d(_tag, 'resetMediaDevices: muteLocalAudio(true) success');

      // 关闭音频采集
      await NEGroupCallEngine.instance.enableLocalAudio(false);
      CallKitUILog.d(_tag, 'resetMediaDevices: enableLocalAudio(false) success');

      // 关闭音量回调
      await NEGroupCallEngine.instance.enableAudioVolumeIndication(false, 0);
      CallKitUILog.d(_tag, 'resetMediaDevices: enableAudioVolumeIndication(false) success');
    } catch (e) {
      CallKitUILog.e(_tag, 'resetMediaDevices: error=$e');
    }
  }

  /// 请求关闭页面
  ///
  /// 通过回调通知页面执行关闭，由页面决定使用 pop 还是 removeRoute
  void _requestClosePage() {
    if (!_isPageLaunched) {
      CallKitUILog.d(_tag, '_requestClosePage: page not launched, skip');
      return;
    }

    // 先重置标志位，确保锁屏等场景下回调未生效时不会阻塞后续逻辑
    _isPageLaunched = false;

    if (_onClosePageRequested != null) {
      _onClosePageRequested!();
      CallKitUILog.d(_tag, '_requestClosePage: callback invoked');
    } else {
      CallKitUILog.e(_tag, '_requestClosePage: no callback registered');
    }
  }

  /// 从 CallInfo 同步成员列表
  ///
  /// 注意：只有 JOINED 状态表示已加入成功，其他状态表示加入中
  /// LEAVING 状态的成员会被过滤掉
  void _syncMembersFromCallInfo(NEGroupCallInfo callInfo) {
    if (_currentState == null) return;

    final memberList = callInfo.memberList ?? [];
    final members = memberList
        .where((m) => m != null && m.state != NEGroupUserState.LEAVING)
        .map((member) {
      return GroupCallMemberUI(
        userId: member!.accId,
        rtcUid: member.rtcUid,
        isLocal: member.accId == _localUserId,
        isJoined: member.state == NEGroupUserState.JOINED,
        isMicOn: false, // 默认关闭
        isVideoStarted: false, // 默认未开启视频流
        isVideoMuted: false, // 默认不静音
      );
    }).toList();

    _currentState!.updateMembers(members);

    // 异步获取用户信息
    _fetchMembersUserInfo(members.map((m) => m.userId).toList());
  }

  /// 合并 CallInfo 中的成员状态到现有成员列表
  ///
  /// 与 [_syncMembersFromCallInfo] 不同，此方法保留现有成员的媒体状态和用户信息，
  /// 仅更新 isJoined 和 rtcUid 字段。用于 accept 后同步最新成员加入状态。
  void _mergeMembersFromCallInfo(NEGroupCallInfo callInfo) {
    if (_currentState == null) return;

    final memberList = callInfo.memberList ?? [];
    final existingMembers = {
      for (var m in _currentState!.members) m.userId: m
    };
    final newMemberIds = <String>[];

    for (final member in memberList) {
      if (member == null) continue;
      final userId = member.accId;
      final state = member.state;

      if (state == NEGroupUserState.LEAVING) {
        existingMembers.remove(userId);
        continue;
      }

      final isJoined = state == NEGroupUserState.JOINED;
      final existing = existingMembers[userId];

      if (existing != null) {
        // 已存在的成员：仅更新 isJoined 和 rtcUid，保留媒体状态和用户信息
        final newRtcUid = member.rtcUid;
        final existingRtcUid = existing.rtcUid;
        final shouldKeepExistingRtcUid = existingRtcUid != null &&
            existingRtcUid != 0 &&
            (newRtcUid == null || newRtcUid == 0);
        final finalRtcUid =
            shouldKeepExistingRtcUid ? existingRtcUid : newRtcUid;

        existingMembers[userId] = existing.copyWith(
          isJoined: isJoined,
          rtcUid: finalRtcUid,
        );
      } else {
        // 新成员：使用默认值创建
        existingMembers[userId] = GroupCallMemberUI(
          userId: userId,
          rtcUid: member.rtcUid,
          isLocal: userId == _localUserId,
          isJoined: isJoined,
          isMicOn: false,
          isVideoStarted: false,
          isVideoMuted: false,
        );
        newMemberIds.add(userId);
      }
    }

    final memberUIList = existingMembers.values.toList();
    _currentState!.updateMembers(memberUIList);

    // 获取新成员的用户信息
    if (newMemberIds.isNotEmpty) {
      _fetchMembersUserInfo(newMemberIds);
    }

    CallKitUILog.i(_tag,
        '_mergeMembersFromCallInfo: merged ${memberList.length} members');
  }

  /// 异步获取成员用户信息（昵称、头像）
  Future<void> _fetchMembersUserInfo(List<String> userIds) async {
    if (_currentState == null || userIds.isEmpty) return;

    try {
      final userInfoList = await NimUtils.getUserInfos(userIds);
      if (_currentState == null) return; // 再次检查，避免异步操作期间状态被销毁

      for (final userInfo in userInfoList) {
        final index = _currentState!.members.indexWhere((m) => m.userId == userInfo.id);
        if (index >= 0) {
          final member = _currentState!.members[index];
          final updatedMember = member.copyWith(
            nickname: StringStream.makeNull(userInfo.nickname, ''),
            avatar: StringStream.makeNull(userInfo.avatar, Constants.defaultAvatar),
          );

          // 更新单个成员
          final newMembers = List<GroupCallMemberUI>.from(_currentState!.members);
          newMembers[index] = updatedMember;
          _currentState!.updateMembers(newMembers);
        }
      }
    } catch (e) {
      CallKitUILog.e(_tag, '_fetchMembersUserInfo error: $e');
    }
  }

  /// 启动群呼页面
  void _launchGroupCallPage() {
    if (_currentState == null) {
      CallKitUILog.e(_tag, '_launchGroupCallPage: currentState is null');
      return;
    }

    if (_isPageLaunched) {
      CallKitUILog.i(_tag, '_launchGroupCallPage: page already launched, skip');
      return;
    }

    CallKitUILog.i(_tag, '_launchGroupCallPage: callId=${_currentState!.callId}, state=${_currentState!.uiState}');

    final navigator = NECallKitNavigatorObserver.getInstance().navigator;
    if (navigator == null) {
      CallKitUILog.e(_tag, '_launchGroupCallPage: navigator is null');
      return;
    }

    // 根据状态选择对应的页面
    final Widget page = _currentState!.uiState == GroupCallUIState.incoming
        ? GroupCallIncomingPage(groupCallState: _currentState!)
        : GroupCallsWidget(
            groupCallState: _currentState!,
            onMinimize: _handleMinimize,
            onInvitePressed: onInvitePressed,
          );

    navigator.push(
      MaterialPageRoute<void>(builder: (context) => page),
    );
    _isPageLaunched = true;
  }

  /// 启动群呼呼叫提示音（复用一对一通话铃声）
  void _startGroupCallingRing() {
    CallKitUILog.i(_tag, '_startGroupCallingRing');
    CallingBellFeature.startRingByRole(NECallRole.caller);
  }

  /// 启动群呼来电铃声（复用一对一通话铃声）
  void _startGroupIncomingRing() {
    CallKitUILog.i(_tag, '_startGroupIncomingRing');
    CallingBellFeature.startRingByRole(NECallRole.called);
  }

  /// 停止铃声
  void _stopRing() {
    CallKitUILog.i(_tag, '_stopRing');
    CallingBellFeature.stopRing();
  }

  /// 初始化媒体设备
  ///
  /// 在进入群呼通话页面时调用（发起、加入、接听场景统一在 GroupCallsWidget.initState 中调用）
  /// 在初始化音频设备前会检查麦克风权限
  Future<void> initializeMediaDevices() async {
    CallKitUILog.i(_tag, 'initializeMediaDevices');

    try {
      // 1. 启用音量回调（用于讲话状态检测）
      await NEGroupCallEngine.instance.enableAudioVolumeIndication(true, 200); // 200ms 间隔
      CallKitUILog.i(_tag, 'initializeMediaDevices: enableAudioVolumeIndication success');

      // 2. 打开扬声器
      await NEGroupCallEngine.instance.setSpeakerphoneOn(true);
      _currentState?.updateSpeakerState(true);
      CallKitUILog.i(_tag, 'initializeMediaDevices: setSpeakerphoneOn(true) success');

      // 3. 关闭摄像头
      await NEGroupCallEngine.instance.enableLocalVideo(false);
      CallKitUILog.i(_tag, 'initializeMediaDevices: enableLocalVideo(true) success');

      // 4. 检查麦克风权限并初始化音频设备
      final hasAudioPermission = await _checkAndInitializeAudio();
      if (hasAudioPermission) {
        // 3. 打开麦克风（取消静音）
        await NEGroupCallEngine.instance.muteLocalAudio(false);
        _currentState?.updateMicrophoneState(false);
        CallKitUILog.i(_tag, 'initializeMediaDevices: muteLocalAudio(false) success');
      } else {
        // 没有权限，保持麦克风静音状态
        _currentState?.updateMicrophoneState(true);
        CallKitUILog.i(_tag, 'initializeMediaDevices: no audio permission, mic stays muted');
      }
    } catch (e) {
      CallKitUILog.e(_tag, 'initializeMediaDevices: error=$e');
    }
  }

  /// 检查麦克风权限并初始化音频设备
  ///
  /// 如果没有权限，会主动请求麦克风权限
  /// 返回 true 表示权限可用且音频设备初始化成功
  Future<bool> _checkAndInitializeAudio() async {
    // 检查是否已有麦克风权限
    var hasPermission = await Permission.has(
      permissions: [PermissionType.microphone],
    );

    if (!hasPermission) {
      CallKitUILog.i(_tag, '_checkAndInitializeAudio: no microphone permission, requesting...');
      
      // 请求麦克风权限
      final result = await Permission.request(NECallType.audio);
      
      if (result == PermissionResult.granted) {
        hasPermission = true;
        CallKitUILog.i(_tag, '_checkAndInitializeAudio: microphone permission granted');
      } else {
        CallKitUILog.i(_tag, '_checkAndInitializeAudio: microphone permission denied');
        _showErrorToast(
          NECallKitUI.localizations.needToAccessMicrophonePermission,
        );
        return false;
      }
    }

    // 有权限，初始化音频设备
    await NEGroupCallEngine.instance.enableLocalAudio(true);
    CallKitUILog.i(_tag, '_checkAndInitializeAudio: enableLocalAudio success');
    return true;
  }

  /// 处理缩小按钮
  void _handleMinimize() {
    CallKitUILog.i(_tag, '_handleMinimize');
    // 默认关闭页面，接入方可通过 onMinimize 回调自定义浮窗逻辑
    _requestClosePage();
  }

  // ============================================================================
  // 群呼引擎回调处理
  // ============================================================================

  /// 处理收到群呼邀请
  void _handleReceiveGroupInvitation(NEGroupCallInfo info) {
    CallKitUILog.i(_tag, '_handleReceiveGroupInvitation: callId=${info.callId}, caller=${info.callerAccId}, memberCount=${info.memberList?.length ?? 0}');

    // 忽略重复邀请（首次登录数据同步可能导致回调多次触发）
    if (_currentState != null) {
      CallKitUILog.i(_tag, '_handleReceiveGroupInvitation: already in call ${_currentState!.callId}, ignore');
      return;
    }

    // 检查其他成员是否全部已离开（排除自己），如果是则忽略该邀请
    final memberList = info.memberList ?? [];
    final otherMembers = memberList.where((m) => m != null && m.accId != _localUserId).toList();
    if (otherMembers.isEmpty || otherMembers.every((m) => m!.state == NEGroupUserState.LEAVING)) {
      CallKitUILog.i(_tag, '_handleReceiveGroupInvitation: no active members, skip: callId=${info.callId}');
      return;
    }

    // 创建 incoming 状态
    _createGroupCallState(
      callId: info.callId,
      initialState: GroupCallUIState.incoming,
      callInfo: info,
    );

    // 播放来电铃声
    _startGroupIncomingRing();

    // 打开被叫页面
    _launchGroupCallPage();
  }

  /// 处理成员列表变更（增量回调）
  ///
  /// 注意：回调中的 members 是增量数据，不是完整的成员列表
  /// 需要根据成员状态进行增量更新：
  /// - state == LEAVING (3): 从列表中移除成员
  /// - 其他状态: 添加或更新成员
  ///   - state == JOINED (2): isJoined = true，表示已加入成功
  ///   - 其他状态（WAITING 等）: isJoined = false，表示加入中，UI 显示 loading
  void _handleGroupMemberListChanged(
      String callId, List<NEGroupCallMember> members) {
    // groupCall API 尚未返回时 _currentState 为 null，但仍需处理成员离开以完成 Completer
    // 注意：群呼是多人场景，单个成员拒绝不应导致整个通话失败，
    // 只有所有被叫都离开（拒绝/超时/占线）后才提前完成 Completer
    if (_pendingGroupCallCompleter != null && !_pendingGroupCallCompleter!.isCompleted) {
      String? lastLeaveMsg;
      for (final member in members) {
        if (member.state == NEGroupUserState.LEAVING) {
          if (member.action == NEGroupUserAction.REJECT) {
            lastLeaveMsg = NECallKitUI.localizations.remoteUserReject;
          } else if (member.reason == NEGroupHangupReason.BUSY) {
            lastLeaveMsg = NECallKitUI.localizations.userBusy;
          } else if (member.reason == NEGroupHangupReason.TIMEOUT) {
            lastLeaveMsg = NECallKitUI.localizations.remoteTimeout;
          }
          if (lastLeaveMsg != null) {
            _pendingCalleeCount--;
          }
        }
      }
      if (_pendingCalleeCount <= 0 && lastLeaveMsg != null) {
        CallKitUILog.i(_tag, '_handleGroupMemberListChanged: all callees left, completing pending groupCall future, msg=$lastLeaveMsg');
        _pendingGroupCallCompleter!.complete(
          NEGroupCallResult(code: -1, msg: lastLeaveMsg),
        );
      }
    }

    if (_currentState?.callId != callId) return;

    CallKitUILog.i(_tag, '_handleGroupMemberListChanged: callId=$callId, delta members=${members.length}');

    // 将现有成员列表转为可修改的 Map（userId -> member）
    final existingMembers = {for (var m in _currentState!.members) m.userId: m};

    // 记录需要获取用户信息的新成员
    final newMemberIds = <String>[];

    // 增量更新成员列表
    for (final member in members) {
      final userId = member.accId;
      final existing = existingMembers[userId];
      final state = member.state;

      if (state == NEGroupUserState.LEAVING) {
        // state == LEAVING (3): 从列表中移除成员
        // 如果成员不在当前列表中，说明已经处理过（SDK 可能重复回调已离开的成员），跳过
        if (existing == null) {
          CallKitUILog.d(_tag, '_handleGroupMemberListChanged: member $userId already left, skip');
          continue;
        }
        existingMembers.remove(userId);
        CallKitUILog.d(_tag, '_handleGroupMemberListChanged: member leaving: $userId, action=${member.action}, reason=${member.reason}');

        // 显示成员离开提示（用昵称或 userId）
        final nickname = existing.nickname ?? userId;
        String? leaveMsg;
        if (member.action == NEGroupUserAction.REJECT) {
          leaveMsg = '$nickname ${NECallKitUI.localizations.remoteUserReject}';
        } else if (member.reason == NEGroupHangupReason.BUSY) {
          leaveMsg = '$nickname ${NECallKitUI.localizations.userBusy}';
        } else if (member.reason == NEGroupHangupReason.TIMEOUT) {
          leaveMsg = '$nickname ${NECallKitUI.localizations.remoteTimeout}';
        }
        if (leaveMsg != null && _currentState?.callerUserId == _localUserId) {
          Fluttertoast.showToast(msg: leaveMsg);
        }
      } else {
        // 其他状态: 添加或更新成员
        // 只有 JOINED (2) 状态表示已加入成功，其他状态表示加入中
        final isJoined = state == NEGroupUserState.JOINED;
        
        // 保护 rtcUid：如果已存在有效的 rtcUid (不为 null 且不为 0)，
        // 而新值为 0 或 null，则保留旧值，避免被无效值覆盖
        final newRtcUid = member.rtcUid;
        final existingRtcUid = existing?.rtcUid;
        final shouldKeepExistingRtcUid = 
            existingRtcUid != null && 
            existingRtcUid != 0 && 
            (newRtcUid == null || newRtcUid == 0);
        final finalRtcUid = shouldKeepExistingRtcUid ? existingRtcUid : newRtcUid;
        
        final updatedMember = GroupCallMemberUI(
          userId: userId,
          rtcUid: finalRtcUid,
          nickname: existing?.nickname,
          avatar: existing?.avatar,
          isLocal: userId == _localUserId,
          isJoined: isJoined,
          isMicOn: existing?.isMicOn ?? false,
          isVideoStarted: existing?.isVideoStarted ?? false,
          isVideoMuted: existing?.isVideoMuted ?? false,
          isSpeaking: existing?.isSpeaking ?? false,
        );
        existingMembers[userId] = updatedMember;

        // 如果是新成员且没有用户信息，记录下来稍后获取
        if (existing == null && updatedMember.nickname == null) {
          newMemberIds.add(userId);
        }

        CallKitUILog.d(_tag, '_handleGroupMemberListChanged: member updated: $userId, state=$state, isJoined=$isJoined, rtcUid: $existingRtcUid -> $newRtcUid => $finalRtcUid');
      }
    }

    // 转换回列表并更新状态
    final memberUIList = existingMembers.values.toList();
    _currentState!.updateMembers(memberUIList);

    // 获取新成员的用户信息
    if (newMemberIds.isNotEmpty) {
      _fetchMembersUserInfo(newMemberIds);
    }

    // 检查放大模式的成员是否离开，如果离开则自动退出放大模式
    if (_currentState!.isEnlargedMode) {
      final enlargedUserId = _currentState!.enlargedMemberUserId;
      final enlargedMemberExists = memberUIList.any((m) => m.userId == enlargedUserId);

      if (!enlargedMemberExists) {
        CallKitUILog.i(_tag, '_handleGroupMemberListChanged: enlarged member left, exiting enlarged mode');
        _currentState!.exitEnlargedMode();
      }
    }

    // 更新状态迁移（基于更新后的完整成员列表）
    final joinedCount = memberUIList.where((m) => m.isJoined).length;
    final selfJoined = memberUIList.any((m) => m.isLocal && m.isJoined);

    final previousUIState = _currentState!.uiState;
    _currentState!.updateFromCallInfo(
      totalMembers: memberUIList.length,
      joinedMembers: joinedCount,
      isSelfJoined: selfJoined,
    );

    // 仅在状态刚切换到 inCall 时停止铃声，避免通话中重复调用导致 iOS 音频会话被反激活
    if (previousUIState != GroupCallUIState.inCall &&
        _currentState!.uiState == GroupCallUIState.inCall) {
      _stopRing();
    }
  }

  /// 处理自己被挂断（被踢出或通话中断）
  void _handleGroupCallHangup(NEGroupCallHangupEvent event) {
    CallKitUILog.i(_tag, '_handleGroupCallHangup: callId=${event.callId}, reason=${event.reason}');

    // 停止铃声、清理状态
    _stopRing();
    _speakingStateManager?.clearAll();
    _disposeCurrentState();

    // 关闭页面
    _requestClosePage();
  }

  /// 处理群呼结束
  void _handleGroupCallEnd(NEGroupCallEndEvent event) {
    CallKitUILog.i(_tag, '_handleGroupCallEnd: callId=${event.callId}, reason=${event.reason}');

    // 如果 groupCall API 尚未返回（SDK 不回调 completion 的场景），主动完成 Completer
    if (_pendingGroupCallCompleter != null && !_pendingGroupCallCompleter!.isCompleted) {
      CallKitUILog.i(_tag, '_handleGroupCallEnd: completing pending groupCall future');
      _pendingGroupCallCompleter!.complete(
        NEGroupCallResult(code: -1, msg: NECallKitUI.localizations.groupCallEnded),
      );
    }

    // 群呼结束，显示 toast、销毁状态并关闭页面
    _stopRing();
    _speakingStateManager?.clearAll();

    // 显示通话结束提示
    if (event.reason == 2) {
      // 超时
      Fluttertoast.showToast(msg: NECallKitUI.localizations.remoteTimeout);
    } else if (event.reason != 0) {
      Fluttertoast.showToast(msg: NECallKitUI.localizations.groupCallEnded);
    }

    _disposeCurrentState();

    // 关闭页面
    _requestClosePage();
  }

  // ============================================================================
  // 媒体事件回调处理
  // ============================================================================

  /// 处理远端用户开启音频
  void _handleUserAudioStart(int uid) {
    CallKitUILog.d(_tag, '_handleUserAudioStart: rtcUid=$uid');
    _currentState?.updateMemberMediaStateByRtcUid(rtcUid: uid, isMicOn: true);
  }

  /// 处理远端用户关闭音频
  void _handleUserAudioStop(int uid) {
    CallKitUILog.d(_tag, '_handleUserAudioStop: rtcUid=$uid');
    _currentState?.updateMemberMediaStateByRtcUid(rtcUid: uid, isMicOn: false);
    // 关闭音频时也清除讲话状态（SpeakingStateManager 使用 rtcUid.toString() 作为 key）
    _speakingStateManager?.clearUserState(uid.toString());
  }

  /// 处理远端用户开启视频流
  void _handleUserVideoStart(int uid, int maxProfile) {
    CallKitUILog.d(_tag, '_handleUserVideoStart: rtcUid=$uid, maxProfile=$maxProfile');
    _currentState?.updateMemberMediaStateByRtcUid(
      rtcUid: uid,
      isVideoStarted: true,
    );
  }

  /// 处理远端用户关闭视频流
  void _handleUserVideoStop(int uid) {
    CallKitUILog.d(_tag, '_handleUserVideoStop: rtcUid=$uid');
    _currentState?.updateMemberMediaStateByRtcUid(
      rtcUid: uid,
      isVideoStarted: false,
    );
  }

  /// 处理远端用户视频静音状态变化
  void _handleUserVideoMute(int uid, bool muted) {
    CallKitUILog.d(_tag, '_handleUserVideoMute: rtcUid=$uid, muted=$muted');
    _currentState?.updateMemberMediaStateByRtcUid(
      rtcUid: uid,
      isVideoMuted: muted,
    );
  }

  /// 处理音量回调
  void _handleRemoteAudioVolumeIndication(
      List<NEAudioVolumeInfo> volumes, int totalVolume) {
    _speakingStateManager?.handleVolumeIndication(volumes, totalVolume);
  }

  /// 处理讲话状态变更
  ///
  /// [rtcUidString] RTC 用户 ID 的字符串形式
  /// [isSpeaking] 是否正在讲话
  void _handleSpeakingStateChanged(String rtcUidString, bool isSpeaking) {
    final rtcUid = int.tryParse(rtcUidString);
    if (rtcUid != null) {
      _currentState?.updateMemberMediaStateByRtcUid(rtcUid: rtcUid, isSpeaking: isSpeaking);
    }
  }
}
