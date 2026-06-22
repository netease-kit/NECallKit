// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:callkit_example/service/call_record_service.dart';
import 'package:netease_callkit/netease_callkit.dart';
import 'package:nim_core_v2/nim_core.dart';

class RecordUtils {
  static Future<CallRecord?> parseForCallRecord(
    NIMMessage message, {
    bool requireSendSucceeded = false,
  }) async {
    if (message.messageType != NIMMessageType.call) {
      return null;
    }

    if (requireSendSucceeded &&
        message.sendingState != NIMMessageSendingState.succeeded) {
      return null;
    }

    final attachment = message.attachment;
    if (attachment == null) {
      debugPrint('handleNetCallAttachment attachment is null');
      return null;
    }

    if (attachment is! NIMMessageCallAttachment) {
      return null;
    }

    final targetId = await _getTargetIdFromMessage(message);
    if (targetId == null || targetId.isEmpty) {
      debugPrint('handleNetCallAttachment targetId is null or empty');
      return null;
    }

    final callType = attachment.type == 2 ? NECallType.video : NECallType.audio;

    return CallRecord(
      accountId: targetId,
      isIncoming: !(message.isSelf ?? false),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        message.createTime ?? DateTime.now().millisecondsSinceEpoch,
      ),
      callType: callType,
    );
  }

  static Future<String?> _getTargetIdFromMessage(NIMMessage message) async {
    final isSelf = message.isSelf ?? false;
    if (isSelf) {
      final receiverId = message.receiverId;
      if (receiverId != null && receiverId.isNotEmpty) {
        return receiverId;
      }
    } else {
      final senderId = message.senderId;
      if (senderId != null && senderId.isNotEmpty) {
        return senderId;
      }
    }

    if (message.conversationId == null) {
      return null;
    }

    try {
      final result = await NimCore.instance.conversationIdUtil
          .conversationTargetId(message.conversationId!);
      return result.data;
    } catch (e) {
      debugPrint('Failed to get target ID: $e');
      return null;
    }
  }

  static String formatCallType(NECallType callType) {
    switch (callType) {
      case NECallType.audio:
        return 'audio';
      case NECallType.video:
        return 'video';
      case NECallType.none:
        return 'none';
    }
  }

  static String formatCallState(NIMCallStatus callState) {
    switch (callState) {
      case NIMCallStatus.completed:
        return 'completed';
      case NIMCallStatus.cancelled:
        return 'cancelled';
      case NIMCallStatus.rejected:
        return 'rejected';
      case NIMCallStatus.timeout:
        return 'timeout';
      case NIMCallStatus.busy:
        return 'busy';
    }
  }

  static String describeRecordProviderPayload(
    DemoRecordProviderPayload? payload,
  ) {
    if (payload == null) {
      return 'waiting for onRecordSend';
    }
    final time = payload.receivedAt;
    final timeLabel = '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
    return 'accId=${payload.accId}, '
        'callType=${formatCallType(payload.callType)}, '
        'callState=${formatCallState(payload.callState)}, '
        'receivedAt=$timeLabel';
  }

  static String describeCallRecord(CallRecord record) {
    final direction = record.isIncoming ? 'incoming' : 'outgoing';
    return '$direction ${record.accountId} '
        '(${formatCallType(record.callType)})';
  }
}
