// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import { CallRecord, CallRecordValueType } from './CallRecord';

/**
 * 通话记录存储配置
 */
export class CallRecordStorageConfig {
  /// 存储键前缀
  static readonly KEY_PREFIX: string = 'call_records_';

  /// 最大记录数量
  static readonly MAX_RECORD_COUNT: number = 100;

  /// 是否启用自动清理过期记录
  static readonly ENABLE_AUTO_CLEANUP: boolean = true;

  /// 记录过期天数
  static readonly RECORD_EXPIRE_DAYS: number = 30;
}

/**
 * 通话记录存储管理类
 */
export class CallRecordStorage {
  private static instance: CallRecordStorage | null = null;
  private prefs: preferences.Preferences | null = null;
  private context: common.Context | null = null;

  private constructor() {
  }

  /**
   * 获取单例实例
   */
  static getInstance(): CallRecordStorage {
    if (!CallRecordStorage.instance) {
      CallRecordStorage.instance = new CallRecordStorage();
    }
    return CallRecordStorage.instance;
  }

  /**
   * 初始化存储
   */
  async ensureInitialized(context: common.Context): Promise<void> {
    if (!this.prefs) {
      this.context = context;
      this.prefs = await preferences.getPreferences(context, { name: 'call_records' });
      console.info('[CallRecordStorage] Storage initialized');
    } else {
      console.info('[CallRecordStorage] Storage already initialized');
    }
  }

  /**
   * 获取存储key
   */
  private getStorageKey(accountId: string): string {
    return `${CallRecordStorageConfig.KEY_PREFIX}${accountId}`;
  }

  /**
   * 保存通话记录列表
   */
  async saveCallRecords(accountId: string, records: CallRecord[]): Promise<boolean> {
    try {
      if (!this.prefs || !this.context) {
        console.error('[CallRecordStorage] Storage not initialized');
        return false;
      }

      const key = this.getStorageKey(accountId);
      const jsonList = records.map(record => record.toJson());
      const jsonString = JSON.stringify(jsonList);
      console.info(`[CallRecordStorage] Saving ${records.length} records for accountId=${accountId}, key=${key}`);
      await this.prefs.put(key, jsonString);
      await this.prefs.flush();
      console.info(`[CallRecordStorage] Successfully saved ${records.length} records`);
      return true;
    } catch (e) {
      console.error(`[CallRecordStorage] Failed to save call records: ${e}`);
      return false;
    }
  }

  /**
   * 加载通话记录列表
   */
  async loadCallRecords(accountId: string): Promise<CallRecord[]> {
    try {
      if (!this.prefs || !this.context) {
        console.error('[CallRecordStorage] Storage not initialized');
        return [];
      }

      const key = this.getStorageKey(accountId);
      console.info(`[CallRecordStorage] Loading records for accountId=${accountId}, key=${key}`);
      const jsonString = await this.prefs.get(key, '') as string;

      if (!jsonString || jsonString === '') {
        console.info(`[CallRecordStorage] No records found for accountId=${accountId}`);
        return [];
      }

      console.info(`[CallRecordStorage] Found JSON string, length=${jsonString.length}`);
      const jsonList = JSON.parse(jsonString) as Array<Record<string, CallRecordValueType>>;
      console.info(`[CallRecordStorage] Parsed ${jsonList.length} records from JSON`);
      const records = jsonList.map(json => CallRecord.fromJson(json));

      // 自动清理过期记录
      if (CallRecordStorageConfig.ENABLE_AUTO_CLEANUP) {
        const cleanedRecords = this.cleanupExpiredRecords(records);
        if (cleanedRecords.length !== records.length) {
          console.info(`[CallRecordStorage] Cleaned ${records.length - cleanedRecords.length} expired records`);
          await this.saveCallRecords(accountId, cleanedRecords);
        }
        console.info(`[CallRecordStorage] Returning ${cleanedRecords.length} records after cleanup`);
        return cleanedRecords;
      }

      console.info(`[CallRecordStorage] Returning ${records.length} records`);
      return records;
    } catch (e) {
      console.error(`[CallRecordStorage] Failed to load call records: ${e}`);
      return [];
    }
  }

  /**
   * 添加单个通话记录
   */
  async addCallRecord(accountId: string, record: CallRecord): Promise<boolean> {
    try {
      console.info(`[CallRecordStorage] Adding call record: accountId=${record.accountId}, isIncoming=${record.isIncoming}, callType=${record.callType}`);
      const records = await this.loadCallRecords(accountId);
      console.info(`[CallRecordStorage] Current records count: ${records.length}`);
      records.unshift(record); // 插入到开头

      // 限制记录数量
      if (records.length > CallRecordStorageConfig.MAX_RECORD_COUNT) {
        const removedCount = records.length - CallRecordStorageConfig.MAX_RECORD_COUNT;
        records.splice(CallRecordStorageConfig.MAX_RECORD_COUNT);
        console.info(`[CallRecordStorage] Removed ${removedCount} old records, keeping ${records.length} records`);
      }

      const result = await this.saveCallRecords(accountId, records);
      console.info(`[CallRecordStorage] Add call record result: ${result}`);
      return result;
    } catch (e) {
      console.error(`[CallRecordStorage] Failed to add call record: ${e}`);
      return false;
    }
  }

  /**
   * 批量添加通话记录
   */
  async addCallRecords(accountId: string, newRecords: CallRecord[]): Promise<boolean> {
    try {
      const records = await this.loadCallRecords(accountId);
      records.unshift(...newRecords); // 插入到开头

      // 限制记录数量
      if (records.length > CallRecordStorageConfig.MAX_RECORD_COUNT) {
        records.splice(CallRecordStorageConfig.MAX_RECORD_COUNT);
      }

      return await this.saveCallRecords(accountId, records);
    } catch (e) {
      console.error(`[CallRecordStorage] Failed to add call records: ${e}`);
      return false;
    }
  }

  /**
   * 删除指定记录
   */
  async deleteCallRecord(accountId: string, record: CallRecord): Promise<boolean> {
    try {
      const records = await this.loadCallRecords(accountId);
      const filteredRecords = records.filter(r => !r.equals(record));
      return await this.saveCallRecords(accountId, filteredRecords);
    } catch (e) {
      console.error(`[CallRecordStorage] Failed to delete call record: ${e}`);
      return false;
    }
  }

  /**
   * 清除所有通话记录
   */
  async clearCallRecords(accountId: string): Promise<boolean> {
    try {
      if (!this.prefs || !this.context) {
        console.error('[CallRecordStorage] Storage not initialized');
        return false;
      }

      const key = this.getStorageKey(accountId);
      await this.prefs.delete(key);
      await this.prefs.flush();
      return true;
    } catch (e) {
      console.error(`[CallRecordStorage] Failed to clear call records: ${e}`);
      return false;
    }
  }

  /**
   * 获取记录数量
   */
  async getRecordCount(accountId: string): Promise<number> {
    try {
      const records = await this.loadCallRecords(accountId);
      return records.length;
    } catch (e) {
      console.error(`[CallRecordStorage] Failed to get record count: ${e}`);
      return 0;
    }
  }

  /**
   * 清理过期记录
   */
  private cleanupExpiredRecords(records: CallRecord[]): CallRecord[] {
    const expireDate = Date.now() - (CallRecordStorageConfig.RECORD_EXPIRE_DAYS * 24 * 60 * 60 * 1000);
    return records.filter(record => record.timestamp > expireDate);
  }
}

