// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:netease_callkit_ui/l10n/l10n.dart';
import 'package:netease_callkit_ui/l10n/call_ui_localization/call_ui_localizations.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:netease_callkit_ui/src/ui/call_navigator_observer.dart';
import 'package:netease_callkit_ui/src/group_call/group_call_manager.dart';

class NECallKitUI {
  static const String _tag = 'NECallKitUI';
  static final NECallKitUI _instance = NECallKitUI();

  static LocalizationsDelegate<CallKitClientLocalizations> get delegate {
    return S.delegate;
  }

  static CallKitClientLocalizations get localizations {
    return S.of();
  }

  static NECallKitUI get instance => _instance;

  static NECallKitNavigatorObserver navigatorObserver =
      NECallKitNavigatorObserver.getInstance();

  /// init NECallKit
  ///
  /// @param appKey      appKey
  /// @param accountId      accountId
  Future<void> setupEngine(String appKey, String accountId,
      {NEExtraConfig? extraConfig, NEGroupConfigParam? groupConfigParam}) async {
    return await CallManager.instance
        .setupEngine(appKey, accountId, extraConfig: extraConfig, groupConfigParam: groupConfigParam);
  }

  /// release NECallKit
  void releaseEngine() {
    CallManager.instance.destroyEngine();
  }

  /// login NECallKit
  ///
  /// @param appKey      appKey
  /// @param accountId   accountId
  /// @param token       token
  /// @param certificateConfig 证书配置参数
  /// @param extraConfig 额外配置参数，包含 lckConfig 等
  Future<NEResult> login(String appKey, String accountId, String token,
      {NECertificateConfig? certificateConfig,
      NEExtraConfig? extraConfig, NEGroupConfigParam? groupConfigParam}) async {
    return await CallManager.instance.login(appKey, accountId, token,
        certificateConfig: certificateConfig, extraConfig: extraConfig, groupConfigParam: groupConfigParam);
  }

  /// logout NECallKit
  ///
  Future<void> logout() async {
    return await CallManager.instance.logout();
  }

  /// Set user profile
  ///
  /// @param nickname User name, which can contain up to 500 bytes
  /// @param avatar   User profile photo URL, which can contain up to 500 bytes
  ///                 For example: https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar1.png
  /// @param callback Set the result callback
  Future<NEResult> setSelfInfo(String nickname, String avatar) async {
    return await CallManager.instance.setSelfInfo(nickname, avatar);
  }

  /// Make a call
  ///
  /// @param userId        callees
  /// @param callMediaType Call type
  Future<NEResult> call(String userId, NECallType callMediaType,
      [NECallParams? params]) async {
    return await CallManager.instance.call(userId, callMediaType, params);
  }

  /// 设置群呼邀请按钮回调（全局）
  ///
  /// 设置后，所有群呼场景（主叫、被叫、主动加入）通话页面中的邀请按钮
  /// 都会使用此回调。也可以在 [groupCall] 和 [groupJoin] 中单独传入覆盖。
  ///
  /// @param onInvitePressed 邀请按钮回调，参数为当前通话的 callId
  void setGroupInviteHandler(void Function(String callId)? onInvitePressed) {
    GroupCallManager.instance.setGlobalInviteHandler(onInvitePressed);
  }

  /// 发起群呼
  ///
  /// 创建群组音视频通话并邀请指定用户
  ///
  /// @param param 群呼参数，包含被邀请用户列表、群组类型等
  /// @param onInvitePressed 邀请按钮点击回调（可选）
  /// @return NEGroupCallResult 包含群呼信息
  ///
  /// 使用示例:
  /// ```dart
  /// final result = await NECallKitUI.instance.groupCall(
  ///   NEGroupCallParam(
  ///     calleeList: ['user1', 'user2', 'user3'],
  ///     groupType: NEGroupCallGroupType.NORMAL_TEAM,
  ///   ),
  ///   onInvitePressed: (callId) {
  ///     // 处理邀请按钮点击，callId 为当前通话 ID
  ///   },
  /// );
  /// ```
  Future<NEGroupCallResult> groupCall(
    NEGroupCallParam param, {
    void Function(String callId)? onInvitePressed,
  }) async {
    return await GroupCallManager.instance.groupCall(
      param,
      onInvitePressed: onInvitePressed,
    );
  }

  /// 加入群呼
  ///
  /// 主动加入一个已存在的群呼
  ///
  /// @param param 加入参数，包含群呼 ID
  /// @param onInvitePressed 邀请按钮点击回调（可选），参数为当前通话 callId
  /// @return NEGroupJoinResult 包含群呼信息
  ///
  /// 使用示例:
  /// ```dart
  /// final result = await NECallKitUI.instance.groupJoin(
  ///   NEGroupJoinParam(callId: 'group-call-id-123'),
  /// );
  /// ```
  Future<NEGroupJoinResult> groupJoin(
    NEGroupJoinParam param, {
    void Function(String callId)? onInvitePressed,
  }) async {
    return await GroupCallManager.instance.groupJoin(
      param,
      onInvitePressed: onInvitePressed,
    );
  }

  /// 通话中邀请新成员
  ///
  /// 自动过滤已在通话中的用户，检查人数上限
  ///
  /// @param userIds 被邀请用户的 ID 列表
  /// @return NEGroupInviteResult 邀请结果
  Future<NEGroupInviteResult> groupInvite(List<String> userIds) async {
    return await GroupCallManager.instance.inviteMembers(userIds);
  }

  /// Set the ringtone (preferably shorter than 30s)
  ///
  /// First introduce the ringtone resource into the project
  /// Then set the resource as a ringtone
  ///
  /// @param filePath Callee ringtone path
  Future<void> setCallingBell(String assetName) async {
    return await CallManager.instance.setCallingBell(assetName);
  }

  ///Enable the floating window
  Future<void> enableFloatWindow(bool enable) async {
    return await CallManager.instance.enableFloatWindow(enable);
  }

  /// 启用/禁用应用外悬浮窗（画中画）
  /// 前提：需要先调用 enableFloatWindow(true)
  Future<void> enableFloatWindowOutOfApp(bool enable) async {
    return await CallManager.instance.enableFloatWindowOutOfApp(enable);
  }

  Future<void> enableVirtualBackground(bool enable) async {
    return await CallManager.instance.enableVirtualBackground(enable);
  }

  void enableIncomingBanner(bool enable) {
    if (Platform.isAndroid || Platform.isIOS) {
      CallManager.instance.enableIncomingBanner(enable);
    } else {
      CallKitUILog.e(_tag, 'CallManager enableIncomingBanner not support');
    }
  }
}
