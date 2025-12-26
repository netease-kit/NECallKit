// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { CallRecordService } from './CallRecordService';
import { UserModel } from '../viewmodel/UserModel';
import common from '@ohos.app.ability.common';
import { NIMInterface } from '@nimsdk/base';

/**
 * CallRecordService的具体实现类
 */
export class CallRecordServiceImpl extends CallRecordService {
  private static instance: CallRecordServiceImpl | null = null;
  private context: common.Context | null = null;

  private constructor() {
    super();
  }

  /**
   * 获取单例实例
   */
  static getInstance(context: common.Context): CallRecordServiceImpl {
    if (!CallRecordServiceImpl.instance) {
      CallRecordServiceImpl.instance = new CallRecordServiceImpl();
    }
    CallRecordServiceImpl.instance.context = context;
    return CallRecordServiceImpl.instance;
  }

  /**
   * 获取当前登录账号ID
   */
  async getCurrentAccountId(): Promise<string | null> {
    try {
      if (!this.context) {
        console.warn('[CallRecordServiceImpl] Context is null');
        return null;
      }
      const userModel = UserModel.getInstance(this.context);
      const nimSdk: NIMInterface | null = userModel.getNimSdk();
      if (!nimSdk) {
        console.warn('[CallRecordServiceImpl] NIM SDK is not initialized');
        return null;
      }
      const accountId = nimSdk.loginService.getLoginUser();
      console.info(`[CallRecordServiceImpl] Current logged in account ID: ${accountId}`);
      return accountId || null;
    } catch (e) {
      console.error(`[CallRecordServiceImpl] Failed to get current account ID: ${e}`);
      return null;
    }
  }
}

