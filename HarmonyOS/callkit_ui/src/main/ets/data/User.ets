// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { NECallRole, NECallStatus } from '../CallDefine';

/**
 * 用户信息类
 */
export class User {
  /**
   * 用户ID
   */
  id: string = '';

  /**
   * 用户昵称
   */
  nickname: string = '';

  /**
   * 用户头像
   */
  avatar: string = '';

  /**
   * 通话角色
   */
  callRole: NECallRole = NECallRole.NONE;

  /**
   * 通话状态
   */
  callStatus: NECallStatus = NECallStatus.NONE;

  /**
   * 视频是否可用
   */
  videoAvailable: boolean = false;

  /**
   * 音频是否可用
   */
  audioAvailable: boolean = true;
}



