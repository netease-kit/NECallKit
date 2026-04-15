// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:hawk/hawk.dart';
import 'package:netease_callkit/netease_callkit.dart';

class GroupCallEngineDelegateCase {

  final HawkCallbackNotifier notifier;

  GroupCallEngineDelegateCase({
    required this.notifier,
  });

  void onReceiveGroupInvitation(NEGroupCallInfo info) {
    notifier.call('onReceiveGroupInvitation', [
      info.toMap(),
    ]);
  }

  void onGroupMemberListChanged(String callId, List<NEGroupCallMember> members) {
    notifier.call('onGroupMemberListChanged', [
      callId,
      members.map((e) => e.toMap()).toList(),
    ]);
  }

  void onGroupCallHangup(NEGroupCallHangupEvent event) {
    notifier.call('onGroupCallHangup', [
      event.toMap(),
    ]);
  }

  void onGroupCallEnd(NEGroupCallEndEvent event) {
    notifier.call('onGroupCallEnd', [
      event.toMap(),
    ]);
  }
}

class GroupCallMediaDelegateCase {

  final HawkCallbackNotifier notifier;

  GroupCallMediaDelegateCase({
    required this.notifier,
  });
  
  void onUserAudioStart(int uid) {
    notifier.call('onUserAudioStart', [
      uid,
    ]);
  }
  
  void onUserAudioStop(int uid) {
    notifier.call('onUserAudioStop', [
      uid,
    ]);
  }

  void onUserAudioMute(int uid, bool muted) {
    notifier.call('onUserAudioMute', [
      uid,
      muted,
    ]);
  }

  void onUserVideoStart(int uid, int maxProfile) {
    notifier.call('onUserVideoStart', [
      uid,
      maxProfile,
    ]);
  }

  void onUserVideoStop(int uid) {
    notifier.call('onUserVideoStop', [
      uid,
    ]);
  }

  void onUserVideoMute(int uid, bool muted) {
    notifier.call('onUserVideoMute', [
      uid,
      muted,
    ]);
  }

  void onRemoteAudioVolumeIndication(List<NEAudioVolumeInfo> volumes, int totalVolume) {
    notifier.call('onRemoteAudioVolumeIndication', [
      volumes.map((e) => e.toMap()).toList(),
      totalVolume,
    ]);
  }

  void onDisconnect(int reason) {
    notifier.call('onDisconnect', [
      reason,
    ]);
  }

  void onError(int code) {
    notifier.call('onError', [
      code,
    ]);
  }
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

extension on NEGroupCallHangupEvent {
  Map<String, dynamic> toMap() {
    return {
      'callId': callId,
      'reason': reason,
      'message': message,
    };
  }
}

extension on NEGroupCallEndEvent {
  Map<String, dynamic> toMap() {
    return {
      'callId': callId,
      'reason': reason,
      'message': message,
    };
  }
}

extension on NEAudioVolumeInfo {
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'volume': volume,
    };
  }
}