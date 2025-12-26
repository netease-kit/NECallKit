// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { NECallType } from '@necallkit/callkit/src/main/ets/api/Models';

/**
 * 通话记录JSON值类型
 */
export type CallRecordValueType = string | number | boolean | object;

/**
 * 通话记录数据模型
 */
export class CallRecord {
  accountId: string;
  isIncoming: boolean;
  timestamp: number; // 时间戳（毫秒）
  callType: NECallType;
  status: number; // 通话状态：1=完成，2=取消，3=拒绝，4=超时，5=忙线
  duration: number; // 通话时长（秒），仅当status=1时有效

  constructor(
    accountId: string, 
    isIncoming: boolean, 
    timestamp: number, 
    callType: NECallType = NECallType.AUDIO,
    status: number = 1,
    duration: number = 0
  ) {
    this.accountId = accountId;
    this.isIncoming = isIncoming;
    this.timestamp = timestamp;
    this.callType = callType;
    this.status = status;
    this.duration = duration;
  }

  /**
   * 转换为JSON对象
   */
  toJson(): Record<string, CallRecordValueType> {
    return {
      'accountId': this.accountId,
      'isIncoming': this.isIncoming,
      'timestamp': this.timestamp,
      'callType': this.callType === NECallType.AUDIO ? 0 : 1, // 0: audio, 1: video
      'status': this.status,
      'duration': this.duration,
    };
  }

  /**
   * 从JSON对象创建
   */
  static fromJson(json: Record<string, CallRecordValueType>): CallRecord {
    const callType = json['callType'] === 1 ? NECallType.VIDEO : NECallType.AUDIO;
    const status = (json['status'] as number) ?? 1; // 默认为完成状态
    const duration = (json['duration'] as number) ?? 0; // 默认为0
    return new CallRecord(
      json['accountId'] as string,
      json['isIncoming'] as boolean,
      json['timestamp'] as number,
      callType,
      status,
      duration
    );
  }

  /**
   * 判断两个记录是否相等
   */
  equals(other: CallRecord): boolean {
    return this.accountId === other.accountId &&
      this.isIncoming === other.isIncoming &&
      this.timestamp === other.timestamp &&
      this.callType === other.callType;
  }
}

