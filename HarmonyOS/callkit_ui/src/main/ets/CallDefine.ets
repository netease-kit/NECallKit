// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { NECallType } from '@necallkit/callkit/src/main/ets/api/Models';

/**
 * Value callback interface
 */
export class NEValueCallback {
  onSuccess?: (data?: Object) => void;
  onError?: (code: number, message: string) => void;

  constructor(onSuccess?: (data?: Object) => void, onError?: (code: number, message: string) => void) {
    this.onSuccess = onSuccess;
    this.onError = onError;
  }
}

/**
 * Call define class
 */
export class NECallDefine {
  static readonly version: string = "0.0.0.0";
}

/**
 * Indicates the role in the calls.
 */
export enum NECallRole {
  /**
   * 0: Default value, no role.
   */
  NONE = 0,

  /**
   * 1: Caller, the member who initiated the calls.
   */
  CALLER = 1,

  /**
   * 2: Called, the member invited to the calls.
   */
  CALLED = 2
}

/**
 * Indicates the calls status
 */
export enum NECallStatus {
  /**
   * 0: Default value, Idle state.
   */
  NONE = 0,

  /**
   * 1: Waiting accept/reject state.
   */
  WAITING = 1,

  /**
   * 2: In calling state.
   */
  ACCEPT = 2
}

/**
 * Indicates the call scene, including 1v1 calls, group calls etc.
 */
export enum NECallScene {
  /**
   * 0: 1v1 calls.
   */
  SINGLE_CALL = 0,

  /**
   * 1: Group call.
   * notes: you need to create an IM group in advance
   */
  GROUP_CALL = 1
}

/**
 * Camera enumeration
 */
export enum NECamera {
  FRONT = 0,
  BACK = 1
}

/**
 * Audio playback device enumeration
 */
export enum NEAudioPlaybackDevice {
  SPEAKERPHONE = 0,
  EARPIECE = 1
}

/**
 * Call result type enumeration
 */
export enum NECallResultType {
  UNKNOWN = 0,
  MISSED = 1,
  INCOMING = 2,
  OUTGOING = 3
}

/**
 * Network quality enumeration
 */
export enum NENetworkQuality {
  /**
   * 0: unknown
   */
  UNKNOWN = 0,

  /**
   * 1: excellent
   */
  EXCELLENT = 1,

  /**
   * 2: good
   */
  GOOD = 2,

  /**
   * 3: poor
   */
  POOR = 3,

  /**
   * 4: bad
   */
  BAD = 4,

  /**
   * 5: very bad
   */
  VERY_BAD = 5,

  /**
   * 6: down
   */
  DOWN = 6
}

/**
 * Network quality info
 */
export class NENetworkQualityInfo {
  /**
   * User id
   */
  userId: string;

  /**
   * Network quality
   */
  quality: NENetworkQuality;

  constructor(userId: string, quality: NENetworkQuality) {
    this.userId = userId;
    this.quality = quality;
  }
}

/**
 * Generic function return type
 */
export class NEResult {
  code: number;
  message?: string;

  constructor(code: number, message?: string) {
    this.code = code;
    this.message = message;
  }
}


/**
 * Call records
 */
export class NECallRecords {
  callId?: string;
  inviter?: string;
  inviteList?: Array<string>;
  scene?: NECallScene;
  mediaType?: NECallType;
  groupId?: string;
  role?: NECallRole;
  result?: NECallResultType;
  beginTime?: number;
  totalTime?: number;
}

/**
 * Call recent calls filter
 */
export class NECallRecentCallsFilter {
  begin?: number;
  end?: number;
  resultType: NECallResultType = NECallResultType.UNKNOWN;

  /**
   * Convert to JSON object
   */
  toJson(): Record<string, Object> {
    let data: Record<string, Object> = {};
    if (this.begin != null) {
      data['begin'] = this.begin;
    }
    if (this.end != null) {
      data['end'] = this.end;
    }
    data['resultType'] = this.resultType;
    return data;
  }
}

/**
 * Call observer extra info
 */
export class CallObserverExtraInfo {
  role: NECallRole = NECallRole.NONE;
  userData: string = "";
  chatGroupId: string = "";

  /**
   * Create from JSON object
   */
  static fromJson(data: Record<string, Object>): CallObserverExtraInfo {
    let info = new CallObserverExtraInfo();
    let roleValue = data['role'];
    if (typeof roleValue === 'number') {
      info.role = roleValue as NECallRole;
    }
    info.userData = (data['userData'] as string) ?? "";
    info.chatGroupId = (data['chatGroupId'] as string) ?? "";
    return info;
  }

  /**
   * Convert to string
   */
  toString(): string {
    return `{ role: ${this.role}, userData: ${this.userData}, chatGroupId: ${this.chatGroupId} }`;
  }
}


export { NECallType };
