// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:hawk/hawk.dart';
import 'package:netease_callkit/netease_callkit.dart';
import 'package:netease_common/netease_common.dart';
import 'case/call_listener_case.dart';
import 'case/group_call_delegate_case.dart';
import 'case/debug_service.hawk.dart';
import 'case/netease_callkit.hawk.dart';
import 'package:netease_callkit/src/debug/debug_service.dart';

void main() async {
  final handler =
      HawkMethodCallDispatcher(resultTransformer: (String method, result) {
    if (result is NEResult) {
      return ResultBean(
          code: result.code, message: result.msg, data: result.data);
    }
    return null;
  });
  handler.registerMethodCallHandler(
    'NECallEngine',
    instanceGetter: () async => NECallEngine(),
    handlers: [
      HawkNECallEngine.handleHawkMethodCall,
      HawkNECallEngineEx.handleHawkMethodCall
    ],
  );
  handler.registerMethodCallHandler(
    'DebugService',
    instanceGetter: () async => DebugService(),
    handlers: [HawkDebugService.handleHawkMethodCall],
  );
  handler.registerMethodCallHandler(
    'NEGroupCallEngine',
    instanceGetter: () async => NEGroupCallEngine.instance,
    handlers: [
      HawkCallbackRegister.createMethodCallHandler(
        'addGroupCallDelegate', 
        (notifier) {
          final proxy = GroupCallEngineDelegateCase(notifier: notifier);
          final delegate = NEGroupCallEngineDelegate(
            onReceiveGroupInvitation: proxy.onReceiveGroupInvitation,
            onGroupMemberListChanged: proxy.onGroupMemberListChanged,
            onGroupCallHangup: proxy.onGroupCallHangup,
            onGroupCallEnd: proxy.onGroupCallEnd,
          );
          NEGroupCallEngine.instance.addGroupCallDelegate(delegate);
          return delegate;
        }, 
        (delegate) {
          NEGroupCallEngine.instance.removeGroupCallDelegate(delegate as NEGroupCallEngineDelegate);
        }
      ),
      HawkCallbackRegister.createMethodCallHandler(
        'addGroupMediaDelegate', 
        (notifier) {
          final proxy = GroupCallMediaDelegateCase(notifier: notifier);
          final delegate = NEGroupMediaDelegate(
            onUserAudioStart: proxy.onUserAudioStart,
            onUserAudioStop: proxy.onUserAudioStop,
            onUserAudioMute: proxy.onUserAudioMute,
            onUserVideoStart: proxy.onUserVideoStart,
            onUserVideoStop: proxy.onUserVideoStop,
            onUserVideoMute: proxy.onUserVideoMute,
            onRemoteAudioVolumeIndication: proxy.onRemoteAudioVolumeIndication,
            onDisconnect: proxy.onDisconnect,
            onError: proxy.onError,
          );
          NEGroupCallEngine.instance.addGroupMediaDelegate(delegate);
          return delegate;
        },
        (delegate) {
          NEGroupCallEngine.instance.removeGroupMediaDelegate(delegate as NEGroupMediaDelegate);
        }
      ),
      HawkNEGroupCallEngine.handleHawkMethodCall,
    ],
  );
  handler.registerTypeConverter(
    fromMap: (map) async => const NEGroupCallEngineDelegate(),
  );
  handler.registerTypeConverter(
    fromMap: (map) async => const NEGroupMediaDelegate(),
  );
  handler.registerTypeConverter(
    fromMap: (map) async => NESetupConfig(
      appKey: map['appKey'] as String,
      currentUserRtcUid: map['currentUserRtcUid'] as int?,
      enableJoinRtcWhenCall: map['enableJoinRtcWhenCall'] as bool?,
    ),
  );
  handler.registerTypeConverter(
    fromMap: (map) async => NEGroupConfigParam(
      appKey: map['appKey'] as String,
      rtcSafeMode: map['rtcSafeMode'] as int?,
      timeout: map['timeout'] as int?,
      currentUserRtcUid: map['currentUserRtcUid'] as int?,
    ),
  );
  handler.registerTypeConverter(
    fromMap: (map) async => NEGroupCallParam(
      callId: map['callId'] as String?,
      calleeList: (map['calleeList'] as List).cast<String?>(),
      groupId: map['groupId'] as String?,
      groupType: map['groupType'] as int,
      inviteMode: map['inviteMode'] as int?,
      joinMode: map['joinMode'] as int?,
      extraInfo: map['extraInfo'] as String?,
    ),
  );
  handler.registerTypeConverter(
    fromMap: (map) async => NEGroupHangupParam(
      callId: map['callId'] as String,
      reason: map['reason'] as String?,
    ),
  );
  handler.registerTypeConverter(
    fromMap: (map) async => NEGroupAcceptParam(
      callId: map['callId'] as String,
    ),
  );
  handler.registerTypeConverter(
    fromMap: (map) async => NEGroupInviteParam(
      callId: map['callId'] as String,
      calleeList: (map['calleeList'] as List).cast<String?>(),
    ),
  );
  handler.registerTypeConverter(
    fromMap: (map) async => NEGroupJoinParam(
      callId: map['callId'] as String,
    ),
  );
  handler.registerTypeConverter(
    toMap: (NEGroupResult obj) => {
      'code': obj.code,
      'msg': obj.msg,
    },
  );
  handler.registerTypeConverter(
    toMap: (VoidResult obj) => {
      'code': obj.code,
      'msg': obj.msg,
    },
  );
  handler.registerTypeConverter(
    toMap: (NEGroupCallResult obj) => {
      'code': obj.code,
      'msg': obj.msg,
      'callInfo': obj.callInfo?.toMap(),
    },
  );
  handler.registerTypeConverter(
    toMap: (NEGroupAcceptResult obj) => {
      'code': obj.code,
      'msg': obj.msg,
      'callInfo': obj.callInfo?.toMap(),
    },
  );
  handler.registerTypeConverter(
    toMap: (NEGroupJoinResult obj) => {
      'code': obj.code,
      'msg': obj.msg,
      'callInfo': obj.callInfo?.toMap(),
    },
  );
  handler.registerTypeConverter(
    toMap: (NEGroupHangupResult obj) => {
      'code': obj.code,
      'msg': obj.msg,
    },
  );
  handler.registerTypeConverter(
    toMap: (NEGroupInviteResult obj) => {
      'code': obj.code,
      'msg': obj.msg,
    },
  );
  handler.registerTypeConverter(
    toMap: (NEGroupQueryCallInfoResult obj) => {
      'code': obj.code,
      'msg': obj.msg,
      'callInfo': obj.callInfo?.toMap(),
    },
  );
  handler.registerTypeConverter(
    toMap: (NEGroupQueryMembersResult obj) => {
      'code': obj.code,
      'msg': obj.msg,
      'members': obj.members?.map((e) => e.toMap()).toList() ?? [],
    },
  );

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group(
    'callkit flutter',
    () => test('callkit flutter test', () async {
      await IntegratedPermissionHelper.requestPermissions(
          IntegratedConfig.permissions);
      await IntegratedManager.instance.init(
        applicationName: 'callkit',
        version: '0.0.6',
        packageId: 'com.netease.yunxin.flutter.callkit.sampleapp',
        caseList: [handler],
      );
    }, timeout: const Timeout(Duration(minutes: 60))),
  );
}


extension on NEGroupCallInfo {
  Map<String, dynamic> toMap() {
    return {
      'callId': callId,
      'groupId': groupId,
      'groupType': groupType,
      'callerAccId': callerAccId,
      'callerRtcUid': callerRtcUid,
      'memberList': memberList?.map((e) => e?.toMap()).toList() ?? [],
      'inviteMode': inviteMode,
      'joinMode': joinMode,
      'extraInfo': extraInfo,
      'startTimestamp': startTimestamp,
    };
  }
}

extension on NEGroupCallMember {
  Map<String, dynamic> toMap() {
    return {
      'accId': accId,
      'rtcUid': rtcUid,
      'state': state,
      'action': action,
      'reason': reason,
    };
  }
}