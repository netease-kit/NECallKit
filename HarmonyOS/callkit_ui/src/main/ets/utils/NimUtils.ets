// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { NIMInterface, V2NIMUser } from '@nimsdk/base';
import { User } from '../data/User';
import { CallUILog } from './CallUILog';

interface SelfUserProfileUpdateParams {
  name?: string;
  avatar?: string;
}

export class SelfUserProfileUpdateResult {
  success: boolean = false;
  message: string = '';

  constructor(success: boolean, message: string) {
    this.success = success;
    this.message = message;
  }
}

interface UserServiceWithProfileUpdate {
  updateSelfUserProfile?: (params: SelfUserProfileUpdateParams) => Promise<void>;
}

/**
 * NIM 工具类
 * NIM 工具类
 * 提供与 NIM SDK 交互的工具方法
 */
export class NimUtils {
  private static readonly TAG = 'NimUtils';
  private static _nimInstance: NIMInterface | null = null;

  /**
   * 设置 NIM SDK 实例
   * @param nim NIM SDK 实例
   */
  static setNimInstance(nim: NIMInterface | null): void {
    NimUtils._nimInstance = nim;
  }

  /**
   * 批量获取用户信息（内部实现）
   * @param accountIdList 用户账号ID列表
   * @returns 用户信息对象数组，每个对象包含 id, nickname, avatar
   */
  private static async getUserInfoList(accountIdList: string[]): Promise<User[]> {
    const userList: User[] = [];

    try {
      // 获取 NIM SDK 实例
      const nim = NimUtils._nimInstance;
      
      if (!nim) {
        CallUILog.warn(NimUtils.TAG, `NIM SDK 实例未找到，返回默认用户信息`);
        // 如果无法获取用户信息，至少返回账号ID作为昵称
        for (const accountId of accountIdList) {
          const user = new User();
          user.id = accountId;
          user.nickname = accountId;
          userList.push(user);
        }
        return userList;
      }

      // 使用 NIM SDK 的 userService 批量获取用户信息
      // getUserList 方法入参是一个账号ID数组
      if (nim.userService) {
        try {
          const nimUserList: V2NIMUser[] = await nim.userService.getUserList(accountIdList);
          
          // 创建一个映射，方便根据账号ID查找用户信息
          const userInfoMap = new Map<string, V2NIMUser>();
          if (nimUserList && nimUserList.length > 0) {
            for (const userInfo of nimUserList) {
              if (userInfo.accountId) {
                userInfoMap.set(userInfo.accountId, userInfo);
              }
            }
          }

          // 为每个账号ID创建 User 对象
          for (const accountId of accountIdList) {
            const user = new User();
            user.id = accountId;

            const userInfo = userInfoMap.get(accountId);
            if (userInfo) {
              user.nickname = userInfo.name || accountId;
              user.avatar = userInfo.avatar || '';
            } else {
              // 如果获取不到用户信息，使用账号ID作为昵称
              user.nickname = accountId;
            }
            userList.push(user);
          }
        } catch (error) {
          CallUILog.error(NimUtils.TAG, `批量获取用户信息失败: ${String(error)}`);
          // 返回默认用户信息
          for (const accountId of accountIdList) {
            const user = new User();
            user.id = accountId;
            user.nickname = accountId;
            userList.push(user);
          }
        }
      } else {
        CallUILog.warn(NimUtils.TAG, `NIM SDK userService 不可用`);
        // 返回默认用户信息
        for (const accountId of accountIdList) {
          const user = new User();
          user.id = accountId;
          user.nickname = accountId;
          userList.push(user);
        }
      }
    } catch (error) {
      CallUILog.error(NimUtils.TAG, `getUserInfo 异常: ${String(error)}`);
      // 返回默认用户信息
      for (const accountId of accountIdList) {
        const user = new User();
        user.id = accountId;
        user.nickname = accountId;
        userList.push(user);
      }
    }

    return userList;
  }

  /**
   * 批量获取用户信息（公共方法）
   * @param accountIdList 用户账号ID列表
   * @returns 用户信息对象数组，每个对象包含 id, nickname, avatar
   */
  static async getUserInfos(accountIdList: string[]): Promise<User[]> {
    return await NimUtils.getUserInfoList(accountIdList);
  }

  /**
   * 获取单个用户信息
   * @param accountId 用户账号ID
   * @returns 用户信息对象，包含 id, nickname, avatar
   */
  static async getUserInfo(accountId: string): Promise<User> {
    // 调用批量获取方法，然后返回第一个结果
    const userList = await NimUtils.getUserInfoList([accountId]);
    if (userList && userList.length > 0) {
      return userList[0];
    }
    
    // 如果获取失败，返回默认用户信息
    const user = new User();
    user.id = accountId;
    user.nickname = accountId;
    return user;
  }

  /**
   * 更新当前登录用户资料（昵称、头像）
   * @param nickname 昵称
   * @param avatar 头像 URL
   * @returns 更新结果
   */
  static async updateSelfUserProfile(
    nickname: string,
    avatar: string
  ): Promise<SelfUserProfileUpdateResult> {
    const nim = NimUtils._nimInstance;
    if (!nim || !nim.userService) {
      return new SelfUserProfileUpdateResult(false, 'NIM userService 不可用');
    }

    const userService = nim.userService as UserServiceWithProfileUpdate;
    if (!userService.updateSelfUserProfile) {
      return new SelfUserProfileUpdateResult(false, '当前 NIM SDK 不支持 updateSelfUserProfile');
    }

    const params: SelfUserProfileUpdateParams = {};
    params.name = nickname;
    params.avatar = avatar;

    try {
      await userService.updateSelfUserProfile(params);
      return new SelfUserProfileUpdateResult(true, 'success');
    } catch (error) {
      const errMsg = error instanceof Error ? error.message : String(error);
      CallUILog.warn(NimUtils.TAG, `updateSelfUserProfile failed: ${errMsg}`);
      return new SelfUserProfileUpdateResult(false, errMsg);
    }
  }
}
