// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:netease_callkit/netease_callkit.dart';

/// 群呼回调代理单元测试
///
/// 测试 NEGroupCallEngineDelegate 回调代理模式和数据结构。
/// 注意：完整的回调触发测试需要在真实设备上进行集成测试。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('T038: onReceiveGroupInvitation 回调测试', () {
    test('NEGroupCallEngineDelegate should define onReceiveGroupInvitation callback', () {
      // Arrange
      NEGroupCallInfo? receivedInfo;
      final delegate = NEGroupCallEngineDelegate(
        onReceiveGroupInvitation: (info) {
          receivedInfo = info;
        },
      );

      // Act - 模拟回调触发
      final testInfo = NEGroupCallInfo(
        callId: 'incoming-call-123',
        groupType: NEGroupCallGroupType.NORMAL_TEAM,
        callerAccId: 'caller-user',
        callerRtcUid: 12345,
      );
      delegate.onReceiveGroupInvitation?.call(testInfo);

      // Assert
      expect(receivedInfo, isNotNull);
      expect(receivedInfo!.callId, equals('incoming-call-123'));
      expect(receivedInfo!.callerAccId, equals('caller-user'));
    });

    test('NEGroupCallInfo should contain complete invitation info', () {
      // Arrange
      final member1 = NEGroupCallMember(
        accId: 'member1',
        rtcUid: 111,
        state: NEGroupUserState.WAITING,
      );
      final member2 = NEGroupCallMember(
        accId: 'member2',
        rtcUid: 222,
        state: NEGroupUserState.JOINED,
      );

      // Act
      final invitationInfo = NEGroupCallInfo(
        callId: 'invite-call-456',
        groupId: 'team-789',
        groupType: NEGroupCallGroupType.ADVANCE_TEAM,
        callerAccId: 'host-user',
        callerRtcUid: 99999,
        memberList: [member1, member2],
        inviteMode: NEGroupInviteMode.EVERYONE,
        joinMode: NEGroupJoinMode.EVERYONE,
        extraInfo: '{"meeting":"weekly"}',
        startTimestamp: 1700000000000,
      );

      // Assert
      expect(invitationInfo.callId, equals('invite-call-456'));
      expect(invitationInfo.groupId, equals('team-789'));
      expect(invitationInfo.groupType, equals(NEGroupCallGroupType.ADVANCE_TEAM));
      expect(invitationInfo.callerAccId, equals('host-user'));
      expect(invitationInfo.memberList, isNotNull);
      expect(invitationInfo.memberList!.length, equals(2));
      expect(invitationInfo.extraInfo, equals('{"meeting":"weekly"}'));
    });

    test('NEGroupCallEngineDelegate should allow null callbacks', () {
      // Act
      final delegate = NEGroupCallEngineDelegate();

      // Assert - 所有回调应该为 null
      expect(delegate.onReceiveGroupInvitation, isNull);
      expect(delegate.onGroupMemberListChanged, isNull);
      expect(delegate.onGroupCallHangup, isNull);
      expect(delegate.onGroupCallEnd, isNull);
    });

    test('NEGroupCallEngineDelegate should support multiple callbacks', () {
      // Arrange
      var invitationCalled = false;
      var memberChangedCalled = false;

      final delegate = NEGroupCallEngineDelegate(
        onReceiveGroupInvitation: (info) {
          invitationCalled = true;
        },
        onGroupMemberListChanged: (callId, members) {
          memberChangedCalled = true;
        },
      );

      // Act
      delegate.onReceiveGroupInvitation?.call(NEGroupCallInfo(
        callId: 'test',
        groupType: NEGroupCallGroupType.NORMAL_TEAM,
        callerAccId: 'caller',
      ));
      delegate.onGroupMemberListChanged?.call('test', []);

      // Assert
      expect(invitationCalled, isTrue);
      expect(memberChangedCalled, isTrue);
    });

    test('Invitation info should include caller details', () {
      // Arrange
      final inviteInfo = NEGroupCallInfo(
        callId: 'call-with-caller',
        groupType: NEGroupCallGroupType.CHAT_ROOM,
        callerAccId: 'vip-caller',
        callerRtcUid: 888888,
      );

      // Assert
      expect(inviteInfo.callerAccId, equals('vip-caller'));
      expect(inviteInfo.callerRtcUid, equals(888888));
      expect(inviteInfo.groupType, equals(NEGroupCallGroupType.CHAT_ROOM));
    });
  });

  group('T090: onGroupMemberListChanged 回调测试', () {
    test('NEGroupCallEngineDelegate should define onGroupMemberListChanged callback', () {
      // Arrange
      String? receivedCallId;
      List<NEGroupCallMember>? receivedMembers;

      final delegate = NEGroupCallEngineDelegate(
        onGroupMemberListChanged: (callId, members) {
          receivedCallId = callId;
          receivedMembers = members;
        },
      );

      // Act
      final members = [
        NEGroupCallMember(
          accId: 'user1',
          rtcUid: 111,
          state: NEGroupUserState.JOINED,
        ),
        NEGroupCallMember(
          accId: 'user2',
          rtcUid: 222,
          state: NEGroupUserState.WAITING,
        ),
      ];
      delegate.onGroupMemberListChanged?.call('call-123', members);

      // Assert
      expect(receivedCallId, equals('call-123'));
      expect(receivedMembers, isNotNull);
      expect(receivedMembers!.length, equals(2));
      expect(receivedMembers![0].accId, equals('user1'));
      expect(receivedMembers![0].state, equals(NEGroupUserState.JOINED));
    });

    test('onGroupMemberListChanged should notify when member joins', () {
      // Arrange - 新成员加入场景
      var callbackInvoked = false;
      List<NEGroupCallMember>? receivedMembers;

      final delegate = NEGroupCallEngineDelegate(
        onGroupMemberListChanged: (callId, members) {
          callbackInvoked = true;
          receivedMembers = members;
        },
      );

      // Act - 模拟新成员加入
      final members = [
        NEGroupCallMember(
          accId: 'existing-user',
          rtcUid: 100,
          state: NEGroupUserState.JOINED,
        ),
        NEGroupCallMember(
          accId: 'new-user',
          rtcUid: 200,
          state: NEGroupUserState.JOIN_WAIT_RTC,
        ),
      ];
      delegate.onGroupMemberListChanged?.call('call-join', members);

      // Assert
      expect(callbackInvoked, isTrue);
      expect(receivedMembers!.length, equals(2));
      expect(receivedMembers![1].state, equals(NEGroupUserState.JOIN_WAIT_RTC));
    });

    test('onGroupMemberListChanged should notify when member leaves', () {
      // Arrange - 成员离开场景
      var callbackInvoked = false;
      List<NEGroupCallMember>? receivedMembers;

      final delegate = NEGroupCallEngineDelegate(
        onGroupMemberListChanged: (callId, members) {
          callbackInvoked = true;
          receivedMembers = members;
        },
      );

      // Act - 模拟成员离开（状态变为 LEAVING）
      final members = [
        NEGroupCallMember(
          accId: 'remaining-user',
          rtcUid: 100,
          state: NEGroupUserState.JOINED,
        ),
        NEGroupCallMember(
          accId: 'leaving-user',
          rtcUid: 200,
          state: NEGroupUserState.LEAVING,
        ),
      ];
      delegate.onGroupMemberListChanged?.call('call-leave', members);

      // Assert
      expect(callbackInvoked, isTrue);
      expect(receivedMembers![1].state, equals(NEGroupUserState.LEAVING));
    });

    test('onGroupMemberListChanged should handle empty member list', () {
      // Arrange - 所有成员都离开
      List<NEGroupCallMember>? receivedMembers;

      final delegate = NEGroupCallEngineDelegate(
        onGroupMemberListChanged: (callId, members) {
          receivedMembers = members;
        },
      );

      // Act - 模拟空成员列表
      delegate.onGroupMemberListChanged?.call('call-empty', []);

      // Assert
      expect(receivedMembers, isNotNull);
      expect(receivedMembers!.isEmpty, isTrue);
    });

    test('NEGroupCallMember should have all state values', () {
      // Arrange - 验证所有状态值
      final waitingMember = NEGroupCallMember(
        accId: 'user1',
        rtcUid: 1,
        state: NEGroupUserState.WAITING,
      );
      final joinedMember = NEGroupCallMember(
        accId: 'user2',
        rtcUid: 2,
        state: NEGroupUserState.JOINED,
      );
      final leavingMember = NEGroupCallMember(
        accId: 'user3',
        rtcUid: 3,
        state: NEGroupUserState.LEAVING,
      );
      final joinWaitRtcMember = NEGroupCallMember(
        accId: 'user4',
        rtcUid: 4,
        state: NEGroupUserState.JOIN_WAIT_RTC,
      );

      // Assert
      expect(waitingMember.state, equals(NEGroupUserState.WAITING));
      expect(joinedMember.state, equals(NEGroupUserState.JOINED));
      expect(leavingMember.state, equals(NEGroupUserState.LEAVING));
      expect(joinWaitRtcMember.state, equals(NEGroupUserState.JOIN_WAIT_RTC));
    });
  });

  group('T051: onGroupCallHangup 回调测试', () {
    test('NEGroupCallEngineDelegate should define onGroupCallHangup callback', () {
      // Arrange
      NEGroupCallHangupEvent? receivedEvent;

      final delegate = NEGroupCallEngineDelegate(
        onGroupCallHangup: (event) {
          receivedEvent = event;
        },
      );

      // Act - reason 是 int 类型（表示挂断原因码）
      final event = NEGroupCallHangupEvent(
        callId: 'hangup-call',
        reason: 1, // 1 表示 busy
        message: 'User is busy',
      );
      delegate.onGroupCallHangup?.call(event);

      // Assert
      expect(receivedEvent, isNotNull);
      expect(receivedEvent!.callId, equals('hangup-call'));
      expect(receivedEvent!.reason, equals(1));
      expect(receivedEvent!.message, equals('User is busy'));
    });

    test('NEGroupCallHangupEvent should have correct structure', () {
      // Act - reason 使用整数值
      final event = NEGroupCallHangupEvent(
        callId: 'call-ended',
        reason: 2, // 2 表示 timeout
      );

      // Assert
      expect(event.callId, equals('call-ended'));
      expect(event.reason, equals(2));
      expect(event.message, isNull);
    });

    test('onGroupCallHangup should notify when user leaves call', () {
      // Arrange - 用户主动离开通话的场景
      var callbackInvoked = false;
      String? receivedCallId;
      int? receivedReason;

      final delegate = NEGroupCallEngineDelegate(
        onGroupCallHangup: (event) {
          callbackInvoked = true;
          receivedCallId = event.callId;
          receivedReason = event.reason;
        },
      );

      // Act - 模拟用户主动挂断
      final event = NEGroupCallHangupEvent(
        callId: 'user-left-call',
        reason: 0, // 正常离开
      );
      delegate.onGroupCallHangup?.call(event);

      // Assert
      expect(callbackInvoked, isTrue);
      expect(receivedCallId, equals('user-left-call'));
      expect(receivedReason, equals(0));
    });

    test('onGroupCallHangup should support network disconnection reason', () {
      // Arrange
      NEGroupCallHangupEvent? receivedEvent;

      final delegate = NEGroupCallEngineDelegate(
        onGroupCallHangup: (event) {
          receivedEvent = event;
        },
      );

      // Act - 网络断开导致的挂断
      final event = NEGroupCallHangupEvent(
        callId: 'network-hangup',
        reason: 10, // 假设 10 表示网络断开
        message: 'Network connection lost',
      );
      delegate.onGroupCallHangup?.call(event);

      // Assert
      expect(receivedEvent!.reason, equals(10));
      expect(receivedEvent!.message, equals('Network connection lost'));
    });
  });

  group('T050: onGroupCallEnd 回调测试', () {
    test('NEGroupCallEngineDelegate should define onGroupCallEnd callback', () {
      // Arrange
      NEGroupCallEndEvent? receivedEvent;

      final delegate = NEGroupCallEngineDelegate(
        onGroupCallEnd: (event) {
          receivedEvent = event;
        },
      );

      // Act
      final event = NEGroupCallEndEvent(
        callId: 'ended-call',
        reason: 1,
      );
      delegate.onGroupCallEnd?.call(event);

      // Assert
      expect(receivedEvent, isNotNull);
      expect(receivedEvent!.callId, equals('ended-call'));
      expect(receivedEvent!.reason, equals(1));
    });

    test('NEGroupCallEndEvent should have correct structure', () {
      // Act
      final event = NEGroupCallEndEvent(
        callId: 'group-call-finished',
        reason: 0,
      );

      // Assert
      expect(event.callId, equals('group-call-finished'));
      expect(event.reason, equals(0));
    });

    test('onGroupCallEnd should notify when all members leave', () {
      // Arrange - 所有成员离开后群呼结束的场景
      var callbackInvoked = false;
      String? receivedCallId;
      int? receivedReason;

      final delegate = NEGroupCallEngineDelegate(
        onGroupCallEnd: (event) {
          callbackInvoked = true;
          receivedCallId = event.callId;
          receivedReason = event.reason;
        },
      );

      // Act - 模拟所有成员离开
      final event = NEGroupCallEndEvent(
        callId: 'all-left-call',
        reason: 0, // 正常结束
        message: 'All participants left the call',
      );
      delegate.onGroupCallEnd?.call(event);

      // Assert
      expect(callbackInvoked, isTrue);
      expect(receivedCallId, equals('all-left-call'));
      expect(receivedReason, equals(0));
    });

    test('onGroupCallEnd should support timeout reason', () {
      // Arrange
      NEGroupCallEndEvent? receivedEvent;

      final delegate = NEGroupCallEngineDelegate(
        onGroupCallEnd: (event) {
          receivedEvent = event;
        },
      );

      // Act - 超时结束
      final event = NEGroupCallEndEvent(
        callId: 'timeout-call',
        reason: 2, // 假设 2 表示超时
        message: 'Call timeout',
      );
      delegate.onGroupCallEnd?.call(event);

      // Assert
      expect(receivedEvent!.reason, equals(2));
      expect(receivedEvent!.message, equals('Call timeout'));
    });

    test('onGroupCallEnd should support server terminated reason', () {
      // Arrange
      NEGroupCallEndEvent? receivedEvent;

      final delegate = NEGroupCallEngineDelegate(
        onGroupCallEnd: (event) {
          receivedEvent = event;
        },
      );

      // Act - 服务器强制结束
      final event = NEGroupCallEndEvent(
        callId: 'server-terminated',
        reason: 99, // 假设 99 表示服务器终止
        message: 'Server terminated the call',
      );
      delegate.onGroupCallEnd?.call(event);

      // Assert
      expect(receivedEvent!.callId, equals('server-terminated'));
      expect(receivedEvent!.reason, equals(99));
      expect(receivedEvent!.message, equals('Server terminated the call'));
    });
  });

  group('NEGroupCallEngine delegate management 测试', () {
    test('Engine should provide addGroupCallDelegate method', () {
      // Act
      final engine = NEGroupCallEngine.instance;

      // Assert - 方法应该存在
      expect(engine.addGroupCallDelegate, isA<Function>());
    });

    test('Engine should provide removeGroupCallDelegate method', () {
      // Act
      final engine = NEGroupCallEngine.instance;

      // Assert - 方法应该存在
      expect(engine.removeGroupCallDelegate, isA<Function>());
    });

    test('Delegate can be added and removed from engine', () {
      // Arrange
      final engine = NEGroupCallEngine.instance;
      final delegate = NEGroupCallEngineDelegate(
        onReceiveGroupInvitation: (info) {},
      );

      // Act & Assert - 不应抛出异常
      expect(() => engine.addGroupCallDelegate(delegate), returnsNormally);
      expect(() => engine.removeGroupCallDelegate(delegate), returnsNormally);
    });
  });
}
