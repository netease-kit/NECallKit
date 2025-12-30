// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { CallRecord } from './CallRecord';
import { CallRecordStorage } from './CallRecordStorage';
import { NECallType } from '@yunxin/callkit/src/main/ets/api/Models';

/**
 * 通话记录服务类 - 提供高级功能
 */
export abstract class CallRecordService {
  protected storage: CallRecordStorage = CallRecordStorage.getInstance();

  /**
   * 获取当前登录账号ID的抽象方法
   * 子类需要实现此方法来获取实际的账号ID
   */
  abstract getCurrentAccountId(): Promise<string | null>;

  /**
   * 加载当前账号的通话记录
   */
  async loadCurrentAccountRecords(): Promise<CallRecord[]> {
    const accountId = await this.getCurrentAccountId();
    if (!accountId) {
      return [];
    }
    return await this.storage.loadCallRecords(accountId);
  }

  /**
   * 为当前账号添加通话记录
   */
  async addRecordToCurrentAccount(record: CallRecord): Promise<boolean> {
    const accountId = await this.getCurrentAccountId();
    if (!accountId) {
      return false;
    }
    return await this.storage.addCallRecord(accountId, record);
  }

  /**
   * 清除当前账号的通话记录
   */
  async clearCurrentAccountRecords(): Promise<boolean> {
    const accountId = await this.getCurrentAccountId();
    if (!accountId) {
      return false;
    }
    return await this.storage.clearCallRecords(accountId);
  }

  /**
   * 获取当前账号的记录数量
   */
  async getCurrentAccountRecordCount(): Promise<number> {
    const accountId = await this.getCurrentAccountId();
    if (!accountId) {
      return 0;
    }
    return await this.storage.getRecordCount(accountId);
  }
}

