// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { CallRecord } from '../service/CallRecord';
import { NECallType } from '@yunxin/callkit/src/main/ets/api/Models';
import { V2NIMMessage, V2NIMMessageType, V2NIMMessageSendingState, V2NIMMessageCallAttachment, V2NIMMessageCallDuration, NIMInterface } from '@nimsdk/base';

/**
 * 通话记录工具类
 */
export class RecordUtils {
  /**
   * 从NIM消息中解析通话记录
   * @param message NIM消息
   * @param nimSdk NIM SDK实例（可选，用于获取当前登录账号ID）
   */
  static async parseForCallRecord(message: V2NIMMessage, nimSdk?: NIMInterface | null): Promise<CallRecord | null> {
    console.info(`[RecordUtils] parseForCallRecord: messageType=${message.messageType}, sendingState=${message.sendingState}, isSelf=${message.isSelf}`);
    
    // 检查是否为话单消息类型
    if (message.messageType !== V2NIMMessageType.V2NIM_MESSAGE_TYPE_CALL) {
      console.info(`[RecordUtils] Not a call message, messageType=${message.messageType}, expected=${V2NIMMessageType.V2NIM_MESSAGE_TYPE_CALL}`);
      return null;
    }

    // 检查消息发送状态（只处理发送成功的消息）
    if (message.sendingState !== V2NIMMessageSendingState.V2NIM_MESSAGE_SENDING_STATE_SUCCEEDED) {
      console.info(`[RecordUtils] Message not succeeded, sendingState=${message.sendingState}`);
      return null;
    }

    // 检查附件
    const attachment = message.attachment;
    if (!attachment) {
      console.warn('[RecordUtils] handleNetCallAttachment attachment is null');
      return null;
    }

    // 检查是否为通话附件
    const callAttachment = attachment as V2NIMMessageCallAttachment;
    if (!callAttachment || !callAttachment.type) {
      console.warn(`[RecordUtils] Invalid call attachment: type=${callAttachment?.type}, channelId=${callAttachment?.channelId}`);
      return null;
    }

    console.info(`[RecordUtils] Call attachment found: type=${callAttachment.type}, channelId=${callAttachment.channelId}`);

    // 获取会话目标ID
    const targetId = await RecordUtils.getTargetIdFromConversation(message);
    if (!targetId || targetId === '') {
      console.warn(`[RecordUtils] handleNetCallAttachment targetId is null or empty, conversationId=${message.conversationId}, senderId=${message.senderId}, receiverId=${message.receiverId}`);
      return null;
    }

    console.info(`[RecordUtils] Target ID resolved: ${targetId}`);

    // 从通话附件中获取真实的通话类型
    // type: 1=音频，2=视频
    const callType = callAttachment.type === 2 ? NECallType.VIDEO : NECallType.AUDIO;

    // 判断是否为呼入：如果不是自己发送的，则为呼入
    const isIncoming = !message.isSelf;

    // 获取通话状态
    const status = callAttachment.status ?? 1; // 默认为完成状态

    // 获取通话时长（从durations数组中查找当前账号的时长）
    let duration = 0;
    if (status === 1 && callAttachment.durations && callAttachment.durations.length > 0) {
      try {
        // 获取当前登录账号ID
        let currentAccountId = '';
        if (nimSdk) {
          currentAccountId = nimSdk.loginService.getLoginUser() ?? '';
        } else {
          // 如果没有提供nimSdk，尝试从message中推断当前账号ID
          // 如果是自己发送的消息，senderId就是当前账号ID
          // 如果是接收的消息，receiverId可能是当前账号ID（P2P场景）
          if (message.isSelf && message.senderId) {
            currentAccountId = message.senderId;
          } else if (!message.isSelf && message.receiverId) {
            currentAccountId = message.receiverId;
          }
        }
        
        if (currentAccountId) {
          // 从durations数组中查找当前账号的时长
          const durationItem = callAttachment.durations.find((d: V2NIMMessageCallDuration) => d.accountId === currentAccountId);
          if (durationItem) {
            duration = durationItem.duration ?? 0;
            console.info(`[RecordUtils] Found duration for accountId=${currentAccountId}: ${duration} seconds`);
          } else {
            // 如果找不到当前账号的时长，使用第一个成员的时长（兼容处理）
            if (callAttachment.durations.length > 0) {
              duration = callAttachment.durations[0].duration ?? 0;
              console.info(`[RecordUtils] Using first duration item: ${duration} seconds`);
            }
          }
        } else {
          // 如果无法获取当前账号ID，使用第一个成员的时长（兼容处理）
          if (callAttachment.durations.length > 0) {
            duration = callAttachment.durations[0].duration ?? 0;
            console.info(`[RecordUtils] Cannot get current account ID, using first duration item: ${duration} seconds`);
          }
        }
      } catch (e) {
        console.warn(`[RecordUtils] Failed to get duration: ${e}`);
      }
    }

    // 创建通话记录
    const callRecord = new CallRecord(
      targetId,
      isIncoming,
      message.createTime || Date.now(),
      callType,
      status,
      duration
    );

    console.info(`[RecordUtils] Call record created: accountId=${callRecord.accountId}, isIncoming=${callRecord.isIncoming}, callType=${callRecord.callType}, status=${callRecord.status}, duration=${callRecord.duration}, timestamp=${callRecord.timestamp}`);
    return callRecord;
  }

  /**
   * 从会话中获取目标ID
   */
  private static async getTargetIdFromConversation(message: V2NIMMessage): Promise<string | null> {
    if (!message.conversationId) {
      console.warn('[RecordUtils] getTargetIdFromConversation: conversationId is null');
      return null;
    }

    try {
      console.info(`[RecordUtils] getTargetIdFromConversation: conversationId=${message.conversationId}, isSelf=${message.isSelf}, senderId=${message.senderId}, receiverId=${message.receiverId}`);
      
      // 对于P2P会话，优先从receiverId或senderId获取
      // 如果是自己发送的消息，目标ID是receiverId
      // 如果是接收的消息，目标ID是senderId
      if (message.isSelf) {
        // 自己发送的消息，目标ID是receiverId
        if (message.receiverId && message.receiverId !== '') {
          console.info(`[RecordUtils] Using receiverId: ${message.receiverId}`);
          return message.receiverId;
        }
      } else {
        // 接收的消息，目标ID是senderId
        if (message.senderId && message.senderId !== '') {
          console.info(`[RecordUtils] Using senderId: ${message.senderId}`);
          return message.senderId;
        }
      }

      // 如果无法从receiverId/senderId获取，尝试从conversationId解析
      // 对于P2P会话，conversationId格式可能是 "p2p-{accountId}" 或直接是 accountId
      const conversationId = message.conversationId;
      
      // 如果conversationId包含"-"，尝试提取后面的部分
      if (conversationId.includes('-')) {
        const parts = conversationId.split('-');
        if (parts.length > 1) {
          const targetId = parts[parts.length - 1];
          console.info(`[RecordUtils] Extracted from conversationId: ${targetId}`);
          return targetId;
        }
      }
      
      // 最后尝试直接使用conversationId
      console.info(`[RecordUtils] Using conversationId directly: ${conversationId}`);
      return conversationId;
    } catch (e) {
      console.error(`[RecordUtils] Failed to get target ID: ${e}`);
      return null;
    }
  }
}

