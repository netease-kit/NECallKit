// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:netease_callkit/netease_callkit.dart';

/// 群呼引擎单元测试
///
/// 测试 NEGroupCallEngine 的核心逻辑和 Result 封装。
/// 注意：完整的 Pigeon 通信测试需要在真实设备上进行集成测试。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('T024: NEGroupCallEngine 单例和初始化测试', () {
    test('NEGroupCallEngine.instance should return singleton', () {
      // Act
      final engine1 = NEGroupCallEngine.instance;
      final engine2 = NEGroupCallEngine.instance;

      // Assert
      expect(identical(engine1, engine2), isTrue);
    });

    test('NEGroupConfigParam should construct with required appKey', () {
      // Act
      final config = NEGroupConfigParam(appKey: 'test-app-key');

      // Assert
      expect(config.appKey, equals('test-app-key'));
      expect(config.rtcSafeMode, isNull);
      expect(config.timeout, isNull);
      expect(config.currentUserRtcUid, isNull);
    });

    test('NEGroupConfigParam should construct with all parameters', () {
      // Act
      final config = NEGroupConfigParam(
        appKey: 'test-app-key',
        rtcSafeMode: NEGroupRtcSafeMode.MODE_SAFE,
        timeout: 60000,
        currentUserRtcUid: 12345,
      );

      // Assert
      expect(config.appKey, equals('test-app-key'));
      expect(config.rtcSafeMode, equals(NEGroupRtcSafeMode.MODE_SAFE));
      expect(config.timeout, equals(60000));
      expect(config.currentUserRtcUid, equals(12345));
    });

    test('NEGroupConfigParam.encode should produce correct list structure', () {
      // Arrange
      final config = NEGroupConfigParam(
        appKey: 'test-key',
        rtcSafeMode: 1,
        timeout: 5000,
        currentUserRtcUid: 999,
      );

      // Act
      final encoded = config.encode();

      // Assert
      expect(encoded, isA<List>());
      final list = encoded as List;
      expect(list.length, equals(4));
      expect(list[0], equals('test-key')); // appKey
      expect(list[1], equals(1)); // rtcSafeMode
      expect(list[2], equals(5000)); // timeout
      expect(list[3], equals(999)); // currentUserRtcUid
    });
  });

  group('T024: GroupSimpleResponse 测试', () {
    test('GroupSimpleResponse should have correct structure', () {
      // Act
      final response = GroupSimpleResponse(code: 200, msg: 'success');

      // Assert
      expect(response.code, equals(200));
      expect(response.msg, equals('success'));
    });

    test('GroupSimpleResponse should allow null msg', () {
      // Act
      final response = GroupSimpleResponse(code: 500, msg: null);

      // Assert
      expect(response.code, equals(500));
      expect(response.msg, isNull);
    });

    test('GroupSimpleResponse.encode should produce correct list', () {
      // Arrange
      final response = GroupSimpleResponse(code: 200, msg: 'ok');

      // Act
      final encoded = response.encode();

      // Assert
      expect(encoded, isA<List>());
      final list = encoded as List;
      expect(list[0], equals(200));
      expect(list[1], equals('ok'));
    });
  });

  group('T025: NEGroupCallParam 测试', () {
    test('NEGroupCallParam should construct with required parameters', () {
      // Act
      final param = NEGroupCallParam(
        calleeList: ['user1', 'user2'],
        groupType: NEGroupCallGroupType.NORMAL_TEAM,
      );

      // Assert
      expect(param.calleeList, equals(['user1', 'user2']));
      expect(param.groupType, equals(NEGroupCallGroupType.NORMAL_TEAM));
      expect(param.callId, isNull);
      expect(param.groupId, isNull);
    });

    test('NEGroupCallParam should construct with all parameters', () {
      // Arrange
      final pushParam = NEGroupPushParam(
        pushContent: 'Group call invitation',
        pushPayload: '{"type":"call"}',
        pushMode: NEGroupPushMode.FORCE_ON,
        sound: 'ring.mp3',
      );

      // Act
      final param = NEGroupCallParam(
        callId: 'custom-call-id',
        calleeList: ['user1', 'user2', 'user3'],
        groupId: 'group-123',
        groupType: NEGroupCallGroupType.ADVANCE_TEAM,
        inviteMode: NEGroupInviteMode.CALLER,
        joinMode: NEGroupJoinMode.ONLY_BE_INVITED,
        extraInfo: '{"custom":"data"}',
        pushParam: pushParam,
      );

      // Assert
      expect(param.callId, equals('custom-call-id'));
      expect(param.calleeList.length, equals(3));
      expect(param.groupId, equals('group-123'));
      expect(param.groupType, equals(NEGroupCallGroupType.ADVANCE_TEAM));
      expect(param.inviteMode, equals(NEGroupInviteMode.CALLER));
      expect(param.joinMode, equals(NEGroupJoinMode.ONLY_BE_INVITED));
      expect(param.extraInfo, equals('{"custom":"data"}'));
      expect(param.pushParam, isNotNull);
      expect(param.pushParam!.pushContent, equals('Group call invitation'));
    });

    test('NEGroupCallParam.encode should produce correct list structure', () {
      // Arrange
      final param = NEGroupCallParam(
        callId: 'call-id',
        calleeList: ['user1'],
        groupId: 'group-id',
        groupType: NEGroupCallGroupType.NORMAL_TEAM,
        inviteMode: NEGroupInviteMode.EVERYONE,
        joinMode: NEGroupJoinMode.EVERYONE,
        extraInfo: 'extra',
        pushParam: null,
      );

      // Act
      final encoded = param.encode();

      // Assert
      expect(encoded, isA<List>());
      final list = encoded as List;
      expect(list[0], equals('call-id')); // callId
      expect(list[1], equals(['user1'])); // calleeList
      expect(list[2], equals('group-id')); // groupId
      expect(list[3], equals(NEGroupCallGroupType.NORMAL_TEAM)); // groupType
    });
  });

  group('T025: GroupCallResponse 测试', () {
    test('GroupCallResponse should contain code and msg', () {
      // Act
      final response = GroupCallResponse(
        code: 200,
        msg: 'success',
        callInfo: null,
      );

      // Assert
      expect(response.code, equals(200));
      expect(response.msg, equals('success'));
      expect(response.callInfo, isNull);
    });

    test('GroupCallResponse should contain callInfo', () {
      // Arrange
      final callInfo = NEGroupCallInfo(
        callId: 'call-123',
        groupType: NEGroupCallGroupType.NORMAL_TEAM,
        callerAccId: 'caller-user',
      );

      // Act
      final response = GroupCallResponse(
        code: 200,
        msg: 'success',
        callInfo: callInfo,
      );

      // Assert
      expect(response.code, equals(200));
      expect(response.callInfo, isNotNull);
      expect(response.callInfo!.callId, equals('call-123'));
      expect(response.callInfo!.callerAccId, equals('caller-user'));
      expect(response.callInfo!.groupType, equals(NEGroupCallGroupType.NORMAL_TEAM));
    });
  });

  group('T025: NEGroupCallInfo 测试', () {
    test('NEGroupCallInfo should have correct structure', () {
      // Act
      final callInfo = NEGroupCallInfo(
        callId: 'call-456',
        groupId: 'group-789',
        groupType: NEGroupCallGroupType.ADVANCE_TEAM,
        callerAccId: 'caller',
        callerRtcUid: 12345,
        inviteMode: NEGroupInviteMode.EVERYONE,
        joinMode: NEGroupJoinMode.EVERYONE,
        extraInfo: '{"key":"value"}',
        startTimestamp: 1699000000000,
      );

      // Assert
      expect(callInfo.callId, equals('call-456'));
      expect(callInfo.groupId, equals('group-789'));
      expect(callInfo.groupType, equals(NEGroupCallGroupType.ADVANCE_TEAM));
      expect(callInfo.callerAccId, equals('caller'));
      expect(callInfo.callerRtcUid, equals(12345));
      expect(callInfo.inviteMode, equals(NEGroupInviteMode.EVERYONE));
      expect(callInfo.joinMode, equals(NEGroupJoinMode.EVERYONE));
      expect(callInfo.extraInfo, equals('{"key":"value"}'));
      expect(callInfo.startTimestamp, equals(1699000000000));
    });

    test('NEGroupCallInfo should contain memberList', () {
      // Arrange
      final member1 = NEGroupCallMember(
        accId: 'user1',
        rtcUid: 111,
        state: NEGroupUserState.JOINED,
      );
      final member2 = NEGroupCallMember(
        accId: 'user2',
        rtcUid: 222,
        state: NEGroupUserState.WAITING,
      );

      // Act
      final callInfo = NEGroupCallInfo(
        callId: 'call-789',
        groupType: NEGroupCallGroupType.NORMAL_TEAM,
        callerAccId: 'caller',
        memberList: [member1, member2],
      );

      // Assert
      expect(callInfo.memberList, isNotNull);
      expect(callInfo.memberList!.length, equals(2));
      expect(callInfo.memberList![0]!.accId, equals('user1'));
      expect(callInfo.memberList![0]!.state, equals(NEGroupUserState.JOINED));
      expect(callInfo.memberList![1]!.accId, equals('user2'));
      expect(callInfo.memberList![1]!.state, equals(NEGroupUserState.WAITING));
    });
  });

  group('T025: NEGroupCallMember 测试', () {
    test('NEGroupCallMember should have correct structure', () {
      // Act
      final member = NEGroupCallMember(
        accId: 'member-user',
        rtcUid: 54321,
        state: NEGroupUserState.JOIN_WAIT_RTC,
      );

      // Assert
      expect(member.accId, equals('member-user'));
      expect(member.rtcUid, equals(54321));
      expect(member.state, equals(NEGroupUserState.JOIN_WAIT_RTC));
    });

    test('NEGroupCallMember.encode should produce correct list', () {
      // Arrange
      final member = NEGroupCallMember(
        accId: 'user',
        rtcUid: 123,
        state: NEGroupUserState.JOINED,
      );

      // Act
      final encoded = member.encode();

      // Assert
      expect(encoded, isA<List>());
      final list = encoded as List;
      expect(list[0], equals('user'));
      expect(list[1], equals(123));
      expect(list[2], equals(NEGroupUserState.JOINED));
    });
  });

  group('NEGroupPushParam 测试', () {
    test('NEGroupPushParam should have correct structure', () {
      // Act
      final pushParam = NEGroupPushParam(
        pushContent: 'Call invitation',
        pushPayload: '{"action":"call"}',
        pushMode: NEGroupPushMode.ON,
        sound: 'notification.mp3',
      );

      // Assert
      expect(pushParam.pushContent, equals('Call invitation'));
      expect(pushParam.pushPayload, equals('{"action":"call"}'));
      expect(pushParam.pushMode, equals(NEGroupPushMode.ON));
      expect(pushParam.sound, equals('notification.mp3'));
    });

    test('NEGroupPushParam.encode should produce correct list', () {
      // Arrange
      final pushParam = NEGroupPushParam(
        pushContent: 'content',
        pushPayload: 'payload',
        pushMode: NEGroupPushMode.FORCE_ON,
        sound: 'ring.mp3',
      );

      // Act
      final encoded = pushParam.encode();

      // Assert
      expect(encoded, isA<List>());
      final list = encoded as List;
      expect(list[0], equals('content'));
      expect(list[1], equals('payload'));
      expect(list[2], equals(NEGroupPushMode.FORCE_ON));
      expect(list[3], equals('ring.mp3'));
    });
  });

  group('T039: NEGroupAcceptParam 和 GroupAcceptResponse 测试', () {
    test('NEGroupAcceptParam should construct with callId', () {
      // Act
      final param = NEGroupAcceptParam(callId: 'call-to-accept');

      // Assert
      expect(param.callId, equals('call-to-accept'));
    });

    test('NEGroupAcceptParam.encode should produce correct list', () {
      // Arrange
      final param = NEGroupAcceptParam(callId: 'call-encode');

      // Act
      final encoded = param.encode();

      // Assert
      expect(encoded, isA<List>());
      final list = encoded as List;
      expect(list[0], equals('call-encode'));
    });

    test('GroupAcceptResponse should have correct structure', () {
      // Arrange
      final callInfo = NEGroupCallInfo(
        callId: 'accepted-call',
        groupType: NEGroupCallGroupType.NORMAL_TEAM,
        callerAccId: 'caller',
      );

      // Act
      final response = GroupAcceptResponse(
        code: 200,
        msg: 'accepted successfully',
        callInfo: callInfo,
      );

      // Assert
      expect(response.code, equals(200));
      expect(response.msg, equals('accepted successfully'));
      expect(response.callInfo, isNotNull);
      expect(response.callInfo!.callId, equals('accepted-call'));
    });

    test('NEGroupAcceptResult should correctly wrap response', () {
      // Arrange
      final callInfo = NEGroupCallInfo(
        callId: 'result-call',
        groupType: NEGroupCallGroupType.ADVANCE_TEAM,
        callerAccId: 'test-caller',
      );

      // Act
      final result = NEGroupAcceptResult(
        code: 0,
        msg: 'success',
        callInfo: callInfo,
      );

      // Assert
      expect(result.code, equals(0));
      expect(result.isSuccess, isTrue);
      expect(result.callInfo, isNotNull);
      expect(result.callInfo!.callId, equals('result-call'));
    });
  });

  group('T040: NEGroupHangupParam 测试（拒绝场景）', () {
    test('NEGroupHangupParam should construct with callId', () {
      // Act
      final param = NEGroupHangupParam(callId: 'call-to-hangup');

      // Assert
      expect(param.callId, equals('call-to-hangup'));
      expect(param.reason, isNull);
    });

    test('NEGroupHangupParam should support BUSY reason for rejection', () {
      // Act - 使用 BUSY 表示忙线拒绝
      final param = NEGroupHangupParam(
        callId: 'call-busy',
        reason: NEGroupHangupReason.BUSY,
      );

      // Assert
      expect(param.callId, equals('call-busy'));
      expect(param.reason, equals(NEGroupHangupReason.BUSY));
    });

    test('NEGroupHangupParam should support PEER_REJECT reason', () {
      // Act - 使用 PEER_REJECT 表示主动拒绝
      final param = NEGroupHangupParam(
        callId: 'call-reject',
        reason: NEGroupHangupReason.PEER_REJECT,
      );

      // Assert
      expect(param.callId, equals('call-reject'));
      expect(param.reason, equals(NEGroupHangupReason.PEER_REJECT));
    });

    test('NEGroupHangupParam.encode should produce correct list', () {
      // Arrange
      final param = NEGroupHangupParam(
        callId: 'call-encode-hangup',
        reason: NEGroupHangupReason.TIMEOUT,
      );

      // Act
      final encoded = param.encode();

      // Assert
      expect(encoded, isA<List>());
      final list = encoded as List;
      expect(list[0], equals('call-encode-hangup'));
      expect(list[1], equals(NEGroupHangupReason.TIMEOUT));
    });

    test('NEGroupHangupResult should correctly wrap response', () {
      // Act
      final result = NEGroupHangupResult(
        code: 0,
        msg: 'hangup success',
      );

      // Assert
      expect(result.code, equals(0));
      expect(result.isSuccess, isTrue);
      expect(result.msg, equals('hangup success'));
    });

    test('NEGroupHangupResult should handle error case', () {
      // Act
      final result = NEGroupHangupResult(
        code: 400,
        msg: 'call not found',
      );

      // Assert
      expect(result.code, equals(400));
      expect(result.isSuccess, isFalse);
    });
  });

  group('T063: NEGroupInviteParam 和 NEGroupInviteResult 测试', () {
    test('NEGroupInviteParam should construct with required parameters', () {
      // Act
      final param = NEGroupInviteParam(
        callId: 'call-invite',
        calleeList: ['user1', 'user2'],
      );

      // Assert
      expect(param.callId, equals('call-invite'));
      expect(param.calleeList, equals(['user1', 'user2']));
    });

    test('NEGroupInviteParam should support empty callee list validation', () {
      // Act - 空列表应该被允许构造（验证逻辑在业务层）
      final param = NEGroupInviteParam(
        callId: 'call-empty',
        calleeList: [],
      );

      // Assert
      expect(param.callId, equals('call-empty'));
      expect(param.calleeList.isEmpty, isTrue);
    });

    test('NEGroupInviteParam.encode should produce correct list', () {
      // Arrange
      final param = NEGroupInviteParam(
        callId: 'call-encode-invite',
        calleeList: ['newUser1', 'newUser2', 'newUser3'],
      );

      // Act
      final encoded = param.encode();

      // Assert
      expect(encoded, isA<List>());
      final list = encoded as List;
      expect(list[0], equals('call-encode-invite'));
      expect(list[1], equals(['newUser1', 'newUser2', 'newUser3']));
    });

    test('NEGroupInviteResult should correctly wrap success response', () {
      // Act
      final result = NEGroupInviteResult(
        code: 0,
        msg: 'Invite sent',
      );

      // Assert
      expect(result.code, equals(0));
      expect(result.isSuccess, isTrue);
      expect(result.msg, equals('Invite sent'));
    });

    test('NEGroupInviteResult should handle permission denied error', () {
      // Act - 没有邀请权限的错误
      final result = NEGroupInviteResult(
        code: 403,
        msg: 'Permission denied: only caller can invite',
      );

      // Assert
      expect(result.code, equals(403));
      expect(result.isSuccess, isFalse);
      expect(result.msg, contains('Permission denied'));
    });

    test('NEGroupInviteResult should handle call not found error', () {
      // Act - 通话不存在的错误
      final result = NEGroupInviteResult(
        code: 404,
        msg: 'Call not found',
      );

      // Assert
      expect(result.code, equals(404));
      expect(result.isSuccess, isFalse);
    });

    test('NEGroupInviteResult should handle user already in call error', () {
      // Act - 用户已在通话中的错误
      final result = NEGroupInviteResult(
        code: 409,
        msg: 'User already in call',
      );

      // Assert
      expect(result.code, equals(409));
      expect(result.isSuccess, isFalse);
    });
  });

  group('T049: NEGroupHangupParam 测试（主动挂断场景）', () {
    test('NEGroupHangupParam for normal hangup should have no reason', () {
      // Act - 主动挂断不需要 reason
      final param = NEGroupHangupParam(callId: 'call-hangup-normal');

      // Assert
      expect(param.callId, equals('call-hangup-normal'));
      expect(param.reason, isNull);
    });

    test('NEGroupHangupParam.encode for hangup should produce correct list', () {
      // Arrange - 主动挂断场景
      final param = NEGroupHangupParam(
        callId: 'call-encode-hangup',
        reason: null, // 主动挂断不指定 reason
      );

      // Act
      final encoded = param.encode();

      // Assert
      expect(encoded, isA<List>());
      final list = encoded as List;
      expect(list[0], equals('call-encode-hangup'));
      expect(list[1], isNull);
    });

    test('NEGroupHangupResult for hangup should correctly wrap response', () {
      // Act - 主动挂断成功
      final result = NEGroupHangupResult(
        code: 0,
        msg: 'hangup success',
      );

      // Assert
      expect(result.code, equals(0));
      expect(result.isSuccess, isTrue);
      expect(result.msg, equals('hangup success'));
    });

    test('NEGroupHangupResult should handle call not in progress error', () {
      // Act - 挂断时通话不存在的错误
      final result = NEGroupHangupResult(
        code: 404,
        msg: 'Call not in progress',
      );

      // Assert
      expect(result.code, equals(404));
      expect(result.isSuccess, isFalse);
      expect(result.msg, equals('Call not in progress'));
    });
  });

  group('NEGroupCallEndEvent 测试', () {
    test('NEGroupCallEndEvent should represent normal call end', () {
      // Act - 所有成员离开，通话正常结束
      final event = NEGroupCallEndEvent(
        callId: 'call-ended-normal',
        reason: 0, // 正常结束
        message: 'All participants left',
      );

      // Assert
      expect(event.callId, equals('call-ended-normal'));
      expect(event.reason, equals(0));
      expect(event.message, equals('All participants left'));
    });

    test('NEGroupCallEndEvent should represent timeout end', () {
      // Act - 超时结束
      final event = NEGroupCallEndEvent(
        callId: 'call-ended-timeout',
        reason: 1, // 超时
      );

      // Assert
      expect(event.callId, equals('call-ended-timeout'));
      expect(event.reason, equals(1));
      expect(event.message, isNull);
    });

    test('NEGroupCallEndEvent.encode should produce correct list', () {
      // Arrange
      final event = NEGroupCallEndEvent(
        callId: 'call-encode-end',
        reason: 2,
        message: 'Server terminated',
      );

      // Act
      final encoded = event.encode();

      // Assert
      expect(encoded, isA<List>());
      final list = encoded as List;
      expect(list[0], equals('call-encode-end'));
      expect(list[1], equals(2));
      expect(list[2], equals('Server terminated'));
    });
  });

  group('NEGroupCallHangupEvent 测试', () {
    test('NEGroupCallHangupEvent should represent user leaving call', () {
      // Act - 用户主动离开通话
      final event = NEGroupCallHangupEvent(
        callId: 'call-user-left',
        reason: 0, // 正常离开
        message: null,
      );

      // Assert
      expect(event.callId, equals('call-user-left'));
      expect(event.reason, equals(0));
      expect(event.message, isNull);
    });

    test('NEGroupCallHangupEvent should support reason message', () {
      // Act - 带有原因消息的挂断事件
      final event = NEGroupCallHangupEvent(
        callId: 'call-hangup-reason',
        reason: 3,
        message: 'Network disconnected',
      );

      // Assert
      expect(event.callId, equals('call-hangup-reason'));
      expect(event.reason, equals(3));
      expect(event.message, equals('Network disconnected'));
    });

    test('NEGroupCallHangupEvent.encode should produce correct list', () {
      // Arrange
      final event = NEGroupCallHangupEvent(
        callId: 'call-encode-hangup-event',
        reason: 1,
        message: 'Timeout',
      );

      // Act
      final encoded = event.encode();

      // Assert
      expect(encoded, isA<List>());
      final list = encoded as List;
      expect(list[0], equals('call-encode-hangup-event'));
      expect(list[1], equals(1));
      expect(list[2], equals('Timeout'));
    });
  });
}
