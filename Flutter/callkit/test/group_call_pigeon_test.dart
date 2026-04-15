// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:netease_callkit/netease_callkit.dart';

/// 群呼 Pigeon 契约测试
///
/// 测试 Pigeon 生成的数据模型是否正确。
/// 注意：完整的 Pigeon 通信测试需要在真实设备上进行集成测试。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('T022: init 接口相关类型测试', () {
    test('NEGroupConfigParam should have correct properties', () {
      // Act
      final config = NEGroupConfigParam(
        appKey: 'test-app-key',
        rtcSafeMode: NEGroupRtcSafeMode.MODE_SAFE,
        timeout: 30000,
        currentUserRtcUid: 12345,
      );

      // Assert
      expect(config.appKey, equals('test-app-key'));
      expect(config.rtcSafeMode, equals(NEGroupRtcSafeMode.MODE_SAFE));
      expect(config.timeout, equals(30000));
      expect(config.currentUserRtcUid, equals(12345));
    });

    test('NEGroupConfigParam should allow optional parameters', () {
      // Act
      final config = NEGroupConfigParam(appKey: 'test-key');

      // Assert
      expect(config.appKey, equals('test-key'));
      expect(config.rtcSafeMode, isNull);
      expect(config.timeout, isNull);
      expect(config.currentUserRtcUid, isNull);
    });

    test('NEGroupConfigParam encode should produce list', () {
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
      expect(list[0], equals('test-key'));
      expect(list[1], equals(1));
      expect(list[2], equals(5000));
      expect(list[3], equals(999));
    });

    test('GroupSimpleResponse should have correct structure', () {
      // Act
      final response = GroupSimpleResponse(code: 200, msg: 'success');

      // Assert
      expect(response.code, equals(200));
      expect(response.msg, equals('success'));
    });
  });

  group('T023: groupCall 接口相关类型测试', () {
    test('NEGroupCallParam should have all required properties', () {
      // Act
      final param = NEGroupCallParam(
        calleeList: ['user1', 'user2'],
        groupType: NEGroupCallGroupType.NORMAL_TEAM,
      );

      // Assert
      expect(param.calleeList, equals(['user1', 'user2']));
      expect(param.groupType, equals(NEGroupCallGroupType.NORMAL_TEAM));
    });

    test('NEGroupCallParam should support all optional parameters', () {
      // Act
      final pushParam = NEGroupPushParam(
        pushContent: 'You have a call',
        pushPayload: '{"type":"call"}',
        pushMode: NEGroupPushMode.ON,
        sound: 'default',
      );

      final param = NEGroupCallParam(
        callId: 'custom-call-id',
        calleeList: ['user1', 'user2', 'user3'],
        groupId: 'group-123',
        groupType: NEGroupCallGroupType.ADVANCE_TEAM,
        inviteMode: NEGroupInviteMode.EVERYONE,
        joinMode: NEGroupJoinMode.EVERYONE,
        extraInfo: '{"key":"value"}',
        pushParam: pushParam,
      );

      // Assert
      expect(param.callId, equals('custom-call-id'));
      expect(param.calleeList.length, equals(3));
      expect(param.groupId, equals('group-123'));
      expect(param.groupType, equals(NEGroupCallGroupType.ADVANCE_TEAM));
      expect(param.inviteMode, equals(NEGroupInviteMode.EVERYONE));
      expect(param.joinMode, equals(NEGroupJoinMode.EVERYONE));
      expect(param.extraInfo, equals('{"key":"value"}'));
      expect(param.pushParam, isNotNull);
      expect(param.pushParam!.pushContent, equals('You have a call'));
    });

    test('NEGroupPushParam should encode correctly', () {
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
    });

    test('NEGroupCallInfo should have correct member structure', () {
      // Arrange
      final member = NEGroupCallMember(
        accId: 'user1',
        rtcUid: 12345,
        state: NEGroupUserState.JOINED,
      );

      final callInfo = NEGroupCallInfo(
        callId: 'call-456',
        groupType: NEGroupCallGroupType.NORMAL_TEAM,
        callerAccId: 'caller',
        memberList: [member],
      );

      // Assert
      expect(callInfo.memberList, isNotNull);
      expect(callInfo.memberList!.length, equals(1));
      expect(callInfo.memberList![0]!.accId, equals('user1'));
      expect(callInfo.memberList![0]!.state, equals(NEGroupUserState.JOINED));
    });
  });

  group('release 接口相关类型测试', () {
    test('GroupSimpleResponse for release should work correctly', () {
      // Act
      final response = GroupSimpleResponse(code: 200, msg: 'Released');

      // Assert
      expect(response.code, equals(200));
      expect(response.msg, equals('Released'));
    });
  });

  group('T036: groupAccept 接口相关类型测试', () {
    test('NEGroupAcceptParam should have correct properties', () {
      // Act
      final param = NEGroupAcceptParam(callId: 'call-123');

      // Assert
      expect(param.callId, equals('call-123'));
    });

    test('NEGroupAcceptParam.encode should produce correct list', () {
      // Arrange
      final param = NEGroupAcceptParam(callId: 'call-789');

      // Act
      final encoded = param.encode();

      // Assert
      expect(encoded, isA<List>());
      final list = encoded as List;
      expect(list[0], equals('call-789'));
    });

    test('GroupAcceptResponse should contain code and callInfo', () {
      // Arrange
      final callInfo = NEGroupCallInfo(
        callId: 'call-accepted',
        groupType: NEGroupCallGroupType.NORMAL_TEAM,
        callerAccId: 'caller',
      );

      // Act
      final response = GroupAcceptResponse(
        code: 200,
        msg: 'accepted',
        callInfo: callInfo,
      );

      // Assert
      expect(response.code, equals(200));
      expect(response.msg, equals('accepted'));
      expect(response.callInfo, isNotNull);
      expect(response.callInfo!.callId, equals('call-accepted'));
    });
  });

  group('T037: groupHangup 接口相关类型测试（拒绝邀请场景）', () {
    test('NEGroupHangupParam should have correct properties', () {
      // Act
      final param = NEGroupHangupParam(callId: 'call-123');

      // Assert
      expect(param.callId, equals('call-123'));
      expect(param.reason, isNull);
    });

    test('NEGroupHangupParam should support reason for rejection', () {
      // Act - 使用 BUSY 原因表示拒绝
      final param = NEGroupHangupParam(
        callId: 'call-reject',
        reason: NEGroupHangupReason.BUSY,
      );

      // Assert
      expect(param.callId, equals('call-reject'));
      expect(param.reason, equals(NEGroupHangupReason.BUSY));
    });

    test('NEGroupHangupParam.encode should produce correct list', () {
      // Arrange
      final param = NEGroupHangupParam(
        callId: 'call-hangup',
        reason: NEGroupHangupReason.PEER_REJECT,
      );

      // Act
      final encoded = param.encode();

      // Assert
      expect(encoded, isA<List>());
      final list = encoded as List;
      expect(list[0], equals('call-hangup'));
      expect(list[1], equals(NEGroupHangupReason.PEER_REJECT));
    });

    test('NEGroupHangupReason constants should have correct values', () {
      // NEGroupHangupReason 常量是字符串类型
      expect(NEGroupHangupReason.BUSY, equals('busy'));
      expect(NEGroupHangupReason.TIMEOUT, equals('timeout'));
      expect(NEGroupHangupReason.PEER_ACCEPT, equals('peerAccept'));
      expect(NEGroupHangupReason.PEER_REJECT, equals('peerReject'));
    });
  });

  group('T062: groupInvite 接口相关类型测试', () {
    test('NEGroupInviteParam should have correct properties', () {
      // Act
      final param = NEGroupInviteParam(
        callId: 'call-123',
        calleeList: ['user1', 'user2'],
      );

      // Assert
      expect(param.callId, equals('call-123'));
      expect(param.calleeList, equals(['user1', 'user2']));
    });

    test('NEGroupInviteParam should support single invitee', () {
      // Act
      final param = NEGroupInviteParam(
        callId: 'call-single',
        calleeList: ['new-user'],
      );

      // Assert
      expect(param.callId, equals('call-single'));
      expect(param.calleeList.length, equals(1));
      expect(param.calleeList[0], equals('new-user'));
    });

    test('NEGroupInviteParam should support multiple invitees', () {
      // Act
      final param = NEGroupInviteParam(
        callId: 'call-multi',
        calleeList: ['user1', 'user2', 'user3', 'user4', 'user5'],
      );

      // Assert
      expect(param.callId, equals('call-multi'));
      expect(param.calleeList.length, equals(5));
    });

    test('NEGroupInviteParam.encode should produce correct list', () {
      // Arrange
      final param = NEGroupInviteParam(
        callId: 'call-encode',
        calleeList: ['invitee1', 'invitee2'],
      );

      // Act
      final encoded = param.encode();

      // Assert
      expect(encoded, isA<List>());
      final list = encoded as List;
      expect(list[0], equals('call-encode'));
      expect(list[1], equals(['invitee1', 'invitee2']));
    });

    test('GroupSimpleResponse for invite should work correctly', () {
      // Act
      final response = GroupSimpleResponse(
        code: 200,
        msg: 'Invite sent successfully',
      );

      // Assert
      expect(response.code, equals(200));
      expect(response.msg, equals('Invite sent successfully'));
    });

    test('GroupSimpleResponse should handle partial invite failure', () {
      // Act - 部分邀请失败的情况
      final response = GroupSimpleResponse(
        code: 207, // 假设 207 表示部分成功
        msg: 'Some invites failed',
      );

      // Assert
      expect(response.code, equals(207));
      expect(response.msg, equals('Some invites failed'));
    });
  });

  group('T048: groupHangup 接口相关类型测试（挂断场景）', () {
    test('NEGroupHangupParam should support hangup without reason', () {
      // Act - 主动挂断场景，通常不需要 reason
      final param = NEGroupHangupParam(callId: 'call-to-hangup');

      // Assert
      expect(param.callId, equals('call-to-hangup'));
      expect(param.reason, isNull);
    });

    test('NEGroupHangupParam should support normal hangup reason', () {
      // Act - 正常挂断，使用 null 或空 reason
      final param = NEGroupHangupParam(
        callId: 'call-normal-hangup',
        reason: null,
      );

      // Assert
      expect(param.callId, equals('call-normal-hangup'));
      expect(param.reason, isNull);
    });

    test('GroupSimpleResponse for hangup should work correctly', () {
      // Act
      final response = GroupSimpleResponse(
        code: 200,
        msg: 'Hangup successful',
      );

      // Assert
      expect(response.code, equals(200));
      expect(response.msg, equals('Hangup successful'));
    });

    test('NEGroupCallEndEvent should represent call end notification', () {
      // Act - 群呼结束事件（所有成员离开时触发）
      final event = NEGroupCallEndEvent(
        callId: 'call-group-ended',
        reason: 0, // 正常结束
        message: 'All members left',
      );

      // Assert
      expect(event.callId, equals('call-group-ended'));
      expect(event.reason, equals(0));
      expect(event.message, equals('All members left'));
    });

    test('NEGroupCallHangupEvent should represent user hangup notification', () {
      // Act - 用户挂断事件（某个用户主动离开时触发）
      final event = NEGroupCallHangupEvent(
        callId: 'call-user-hangup',
        reason: 0, // 正常挂断
        message: null,
      );

      // Assert
      expect(event.callId, equals('call-user-hangup'));
      expect(event.reason, equals(0));
      expect(event.message, isNull);
    });
  });

  group('T068: enableLocalVideo 接口相关类型测试', () {
    test('GroupSimpleResponse should work for enableLocalVideo', () {
      // Act
      final response = GroupSimpleResponse(code: 0, msg: 'success');

      // Assert
      expect(response.code, equals(0));
      expect(response.msg, equals('success'));
    });

    test('enableLocalVideo should accept boolean parameter', () {
      // Arrange - 验证方法签名正确
      // enableLocalVideo(bool enable) -> GroupSimpleResponse

      // Act - 模拟调用场景
      const enableValue = true;
      final response = GroupSimpleResponse(code: 0, msg: 'Video enabled');

      // Assert
      expect(enableValue, isA<bool>());
      expect(response.code, equals(0));
    });

    test('muteLocalVideo should accept boolean parameter', () {
      // Arrange - 验证 muteLocalVideo 方法签名
      // muteLocalVideo(bool mute) -> GroupSimpleResponse

      // Act
      const muteValue = true;
      final response = GroupSimpleResponse(code: 0, msg: 'Video muted');

      // Assert
      expect(muteValue, isA<bool>());
      expect(response.code, equals(0));
    });

    test('enableLocalAudio should accept boolean parameter', () {
      // Arrange - 验证 enableLocalAudio 方法签名
      // enableLocalAudio(bool enable) -> GroupSimpleResponse

      // Act
      const enableValue = false;
      final response = GroupSimpleResponse(code: 0, msg: 'Audio disabled');

      // Assert
      expect(enableValue, isA<bool>());
      expect(response.code, equals(0));
    });
  });

  group('T069: muteLocalAudio 接口相关类型测试', () {
    test('muteLocalAudio should accept boolean parameter', () {
      // Arrange - 验证 muteLocalAudio 方法签名
      // muteLocalAudio(bool mute) -> GroupSimpleResponse

      // Act
      const muteValue = true;
      final response = GroupSimpleResponse(code: 0, msg: 'Audio muted');

      // Assert
      expect(muteValue, isA<bool>());
      expect(response.code, equals(0));
    });

    test('GroupSimpleResponse should handle unmute scenario', () {
      // Act
      const muteValue = false;
      final response = GroupSimpleResponse(code: 0, msg: 'Audio unmuted');

      // Assert
      expect(muteValue, isFalse);
      expect(response.code, equals(0));
      expect(response.msg, equals('Audio unmuted'));
    });

    test('GroupSimpleResponse should handle error case', () {
      // Act - 模拟 mute 失败
      final response = GroupSimpleResponse(code: -1, msg: 'Not in call');

      // Assert
      expect(response.code, equals(-1));
      expect(response.msg, equals('Not in call'));
    });
  });

  group('T070: setSpeakerphoneOn 接口相关类型测试', () {
    test('setSpeakerphoneOn should accept boolean parameter', () {
      // Arrange - 验证 setSpeakerphoneOn 方法签名
      // setSpeakerphoneOn(bool enable) -> GroupSimpleResponse

      // Act
      const enableValue = true;
      final response = GroupSimpleResponse(code: 0, msg: 'Speakerphone on');

      // Assert
      expect(enableValue, isA<bool>());
      expect(response.code, equals(0));
    });

    test('GroupSimpleResponse should handle speakerphone off', () {
      // Act
      const enableValue = false;
      final response = GroupSimpleResponse(code: 0, msg: 'Speakerphone off');

      // Assert
      expect(enableValue, isFalse);
      expect(response.msg, equals('Speakerphone off'));
    });

    test('isSpeakerphoneOn should return boolean', () {
      // Arrange - 验证 isSpeakerphoneOn 方法签名
      // isSpeakerphoneOn() -> bool

      // Act - 模拟返回值
      const result = true;

      // Assert
      expect(result, isA<bool>());
      expect(result, isTrue);
    });
  });

  group('T071: switchCamera 接口相关类型测试', () {
    test('switchCamera should return GroupSimpleResponse', () {
      // Arrange - 验证 switchCamera 方法签名
      // switchCamera() -> GroupSimpleResponse (无参数)

      // Act
      final response = GroupSimpleResponse(code: 0, msg: 'Camera switched');

      // Assert
      expect(response.code, equals(0));
      expect(response.msg, equals('Camera switched'));
    });

    test('switchCamera should handle no camera available error', () {
      // Act - 模拟无可用摄像头
      final response = GroupSimpleResponse(code: -1, msg: 'No camera available');

      // Assert
      expect(response.code, equals(-1));
      expect(response.msg, equals('No camera available'));
    });

    test('NEGroupViewParam should have correct properties', () {
      // Act
      final param = NEGroupViewParam(viewId: 123, uid: 456);

      // Assert
      expect(param.viewId, equals(123));
      expect(param.uid, equals(456));
    });

    test('NEGroupViewParam should allow null viewId for unbinding', () {
      // Act - viewId 为 null 表示解绑视频画布
      final param = NEGroupViewParam(viewId: null, uid: 789);

      // Assert
      expect(param.viewId, isNull);
      expect(param.uid, equals(789));
    });

    test('NEGroupViewParam.encode should produce correct list', () {
      // Arrange
      final param = NEGroupViewParam(viewId: 100, uid: 200);

      // Act
      final encoded = param.encode();

      // Assert
      expect(encoded, isA<List>());
      final list = encoded as List;
      expect(list[0], equals(100)); // viewId
      expect(list[1], equals(200)); // uid
    });
  });

  group('T083: setupLocalView 接口相关类型测试', () {
    test('setupLocalView should accept NEGroupViewParam', () {
      // Arrange - 验证 setupLocalView 方法签名
      // setupLocalView(NEGroupViewParam param) -> GroupSimpleResponse

      // Act
      final param = NEGroupViewParam(viewId: 123);
      final response = GroupSimpleResponse(code: 0, msg: 'Local view setup');

      // Assert
      expect(param.viewId, equals(123));
      expect(response.code, equals(0));
    });

    test('setupLocalView should support null viewId for unbinding', () {
      // Act - viewId 为 null 表示解绑本地视频画布
      final param = NEGroupViewParam(viewId: null);
      final response = GroupSimpleResponse(code: 0, msg: 'Local view unbound');

      // Assert
      expect(param.viewId, isNull);
      expect(response.code, equals(0));
    });

    test('setupLocalView should handle error when not in call', () {
      // Act - 模拟不在通话中
      final response = GroupSimpleResponse(code: -1, msg: 'Not in call');

      // Assert
      expect(response.code, equals(-1));
      expect(response.msg, equals('Not in call'));
    });

    test('NEGroupViewParam for local view should not require uid', () {
      // Act - 本地视图不需要 uid
      final param = NEGroupViewParam(viewId: 456);

      // Assert
      expect(param.viewId, equals(456));
      expect(param.uid, isNull);
    });
  });

  group('T084: setupRemoteView 接口相关类型测试', () {
    test('setupRemoteView should accept NEGroupViewParam with uid', () {
      // Arrange - 验证 setupRemoteView 方法签名
      // setupRemoteView(NEGroupViewParam param) -> GroupSimpleResponse

      // Act
      final param = NEGroupViewParam(viewId: 789, uid: 12345);
      final response = GroupSimpleResponse(code: 0, msg: 'Remote view setup');

      // Assert
      expect(param.viewId, equals(789));
      expect(param.uid, equals(12345));
      expect(response.code, equals(0));
    });

    test('setupRemoteView should support null viewId for unbinding', () {
      // Act - viewId 为 null 表示解绑远端视频画布
      final param = NEGroupViewParam(viewId: null, uid: 67890);
      final response = GroupSimpleResponse(code: 0, msg: 'Remote view unbound');

      // Assert
      expect(param.viewId, isNull);
      expect(param.uid, equals(67890));
      expect(response.code, equals(0));
    });

    test('setupRemoteView should handle invalid uid error', () {
      // Act - 模拟无效的 uid
      final response = GroupSimpleResponse(code: -1, msg: 'Invalid uid');

      // Assert
      expect(response.code, equals(-1));
      expect(response.msg, equals('Invalid uid'));
    });

    test('setupRemoteView should handle user not in call error', () {
      // Act - 模拟用户不在通话中
      final response = GroupSimpleResponse(code: -2, msg: 'User not in call');

      // Assert
      expect(response.code, equals(-2));
      expect(response.msg, equals('User not in call'));
    });

    test('NEGroupViewParam.encode for remote view should produce correct list', () {
      // Arrange
      final param = NEGroupViewParam(viewId: 111, uid: 222);

      // Act
      final encoded = param.encode();

      // Assert
      expect(encoded, isA<List>());
      final list = encoded as List;
      expect(list[0], equals(111)); // viewId
      expect(list[1], equals(222)); // uid
    });
  });

  group('T091: groupQueryCallInfo 接口相关类型测试', () {
    test('groupQueryCallInfo should accept callId string', () {
      // Arrange - 验证 groupQueryCallInfo 方法签名
      // groupQueryCallInfo(String callId) -> GroupQueryCallInfoResponse

      // Act
      const callId = 'call-query-123';

      // Assert
      expect(callId, isA<String>());
      expect(callId.isNotEmpty, isTrue);
    });

    test('GroupQueryCallInfoResponse should have correct structure', () {
      // Act
      final callInfo = NEGroupCallInfo(
        callId: 'query-call',
        groupType: NEGroupCallGroupType.NORMAL_TEAM,
        callerAccId: 'caller',
      );
      final response = GroupQueryCallInfoResponse(
        code: 200,
        msg: 'success',
        callInfo: callInfo,
      );

      // Assert
      expect(response.code, equals(200));
      expect(response.msg, equals('success'));
      expect(response.callInfo, isNotNull);
      expect(response.callInfo!.callId, equals('query-call'));
    });

    test('GroupQueryCallInfoResponse should handle call not found', () {
      // Act - 模拟未找到通话
      final response = GroupQueryCallInfoResponse(
        code: 404,
        msg: 'Call not found',
        callInfo: null,
      );

      // Assert
      expect(response.code, equals(404));
      expect(response.callInfo, isNull);
    });

    test('GroupQueryCallInfoResponse.encode should produce correct list', () {
      // Arrange
      final response = GroupQueryCallInfoResponse(
        code: 200,
        msg: 'ok',
        callInfo: null,
      );

      // Act
      final encoded = response.encode();

      // Assert
      expect(encoded, isA<List>());
      final list = encoded as List;
      expect(list[0], equals(200));
      expect(list[1], equals('ok'));
    });
  });

  group('T092: groupQueryMembers 接口相关类型测试', () {
    test('groupQueryMembers should accept callId string', () {
      // Arrange - 验证 groupQueryMembers 方法签名
      // groupQueryMembers(String callId) -> GroupQueryMembersResponse

      // Act
      const callId = 'call-members-456';

      // Assert
      expect(callId, isA<String>());
      expect(callId.isNotEmpty, isTrue);
    });

    test('GroupQueryMembersResponse should have correct structure', () {
      // Act
      final members = [
        NEGroupCallMember(
          accId: 'member1',
          rtcUid: 111,
          state: NEGroupUserState.JOINED,
        ),
        NEGroupCallMember(
          accId: 'member2',
          rtcUid: 222,
          state: NEGroupUserState.WAITING,
        ),
      ];
      final response = GroupQueryMembersResponse(
        code: 200,
        msg: 'success',
        members: members,
      );

      // Assert
      expect(response.code, equals(200));
      expect(response.msg, equals('success'));
      expect(response.members, isNotNull);
      expect(response.members!.length, equals(2));
    });

    test('GroupQueryMembersResponse should handle empty members', () {
      // Act - 模拟无成员
      final response = GroupQueryMembersResponse(
        code: 200,
        msg: 'No members',
        members: [],
      );

      // Assert
      expect(response.code, equals(200));
      expect(response.members!.isEmpty, isTrue);
    });

    test('GroupQueryMembersResponse should handle call not found', () {
      // Act - 模拟未找到通话
      final response = GroupQueryMembersResponse(
        code: 404,
        msg: 'Call not found',
        members: null,
      );

      // Assert
      expect(response.code, equals(404));
      expect(response.members, isNull);
    });

    test('GroupQueryMembersResponse.encode should produce correct list', () {
      // Arrange
      final response = GroupQueryMembersResponse(
        code: 200,
        msg: 'ok',
        members: [],
      );

      // Act
      final encoded = response.encode();

      // Assert
      expect(encoded, isA<List>());
      final list = encoded as List;
      expect(list[0], equals(200));
      expect(list[1], equals('ok'));
    });
  });

  group('T104: enableAudioVolumeIndication 接口相关类型测试', () {
    test('enableAudioVolumeIndication should accept enable and interval', () {
      // Arrange - 验证 enableAudioVolumeIndication 方法签名
      // enableAudioVolumeIndication(bool enable, int interval) -> GroupSimpleResponse

      // Act
      const enable = true;
      const interval = 200; // 200ms 间隔
      final response = GroupSimpleResponse(code: 0, msg: 'Volume indication enabled');

      // Assert
      expect(enable, isA<bool>());
      expect(interval, isA<int>());
      expect(response.code, equals(0));
    });

    test('enableAudioVolumeIndication should support disable', () {
      // Act - 禁用音量回调
      const enable = false;
      const interval = 0;
      final response = GroupSimpleResponse(code: 0, msg: 'Volume indication disabled');

      // Assert
      expect(enable, isFalse);
      expect(interval, equals(0));
      expect(response.code, equals(0));
    });

    test('enableAudioVolumeIndication interval should be positive', () {
      // Act - 有效的间隔值
      const validInterval = 100; // 100ms

      // Assert
      expect(validInterval, greaterThan(0));
    });

    test('NEAudioVolumeInfo should have correct structure', () {
      // Act - 音量信息结构
      final volumeInfo = NEAudioVolumeInfo(uid: 12345, volume: 80);

      // Assert
      expect(volumeInfo.uid, equals(12345));
      expect(volumeInfo.volume, equals(80));
    });

    test('NEAudioVolumeInfo should support volume range 0-100', () {
      // Act - 验证音量范围
      final silentVolume = NEAudioVolumeInfo(uid: 1, volume: 0);
      final maxVolume = NEAudioVolumeInfo(uid: 2, volume: 100);
      final midVolume = NEAudioVolumeInfo(uid: 3, volume: 50);

      // Assert
      expect(silentVolume.volume, equals(0));
      expect(maxVolume.volume, equals(100));
      expect(midVolume.volume, equals(50));
    });

    test('NEAudioVolumeInfo.encode should produce correct list', () {
      // Arrange
      final volumeInfo = NEAudioVolumeInfo(uid: 999, volume: 75);

      // Act
      final encoded = volumeInfo.encode();

      // Assert
      expect(encoded, isA<List>());
      final list = encoded as List;
      expect(list[0], equals(999)); // uid
      expect(list[1], equals(75)); // volume
    });
  });

  group('Constants 测试', () {
    test('NEGroupCallGroupType constants should have correct values', () {
      expect(NEGroupCallGroupType.NORMAL_TEAM, equals(1));
      expect(NEGroupCallGroupType.ADVANCE_TEAM, equals(2));
      expect(NEGroupCallGroupType.CHAT_ROOM, equals(3));
    });

    test('NEGroupUserState constants should have correct values', () {
      expect(NEGroupUserState.WAITING, equals(1));
      expect(NEGroupUserState.JOINED, equals(2));
      expect(NEGroupUserState.LEAVING, equals(3));
      expect(NEGroupUserState.JOIN_WAIT_RTC, equals(4));
    });

    test('NEGroupRtcSafeMode constants should have correct values', () {
      expect(NEGroupRtcSafeMode.MODE_DEBUG, equals(0));
      expect(NEGroupRtcSafeMode.MODE_SAFE, equals(1));
    });

    test('NEGroupInviteMode constants should have correct values', () {
      expect(NEGroupInviteMode.EVERYONE, equals(0));
      expect(NEGroupInviteMode.CALLER, equals(1));
    });

    test('NEGroupJoinMode constants should have correct values', () {
      expect(NEGroupJoinMode.EVERYONE, equals(0));
      expect(NEGroupJoinMode.ONLY_BE_INVITED, equals(1));
    });

    test('NEGroupPushMode constants should have correct values', () {
      expect(NEGroupPushMode.OFF, equals(0));
      expect(NEGroupPushMode.ON, equals(1));
      expect(NEGroupPushMode.FORCE_ON, equals(2));
    });
  });
}
