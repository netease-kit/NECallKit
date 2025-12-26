// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { media } from '@kit.MediaKit';
import { NESetupConfig, VoidResult, NECallType, NECallParam, NECallEngine, NECertificateConfig,
  NEExtraConfig } from "@necallkit/callkit";
import { INECallUI } from "../api/NECallUI";
import { CallUILog } from '../utils/CallUILog';
import { CallManager, NEResult } from "./CallManager";

/**
 * NECallUI 实现类
 * 参考 Flutter 版本的 call_uikit.dart
 */
export class NECallUIImpl implements INECallUI {
  private static readonly _tag = 'NECallUIImpl';
  private static _instance: NECallUIImpl | null = null;

  /**
   * 私有构造函数，单例模式
   */
  private constructor() {}

  /**
   * 获取 NECallUI 实例
   * @returns NECallUI 实例
   */
  static getInstance(): NECallUIImpl {
    if (NECallUIImpl._instance == null) {
      NECallUIImpl._instance = new NECallUIImpl();
    }
    return NECallUIImpl._instance;
  }

  /**
   * 初始化引擎
   * @param appKey 应用 Key
   * @param accountId 账号ID
   * @param extraConfig 额外配置（可选）
   * @returns Promise<void>
   */
  async setupEngine(
    config: NESetupConfig
  ): Promise<void> {
    CallUILog.infoApi(NECallUIImpl._tag, `setupEngine(appKey:${config.appKey}, accountId:${config.accountId})`);
    await CallManager.instance.setupEngine(config);
  }

  /**
   * 释放引擎
   */
  releaseEngine(): void {
    CallUILog.infoApi(NECallUIImpl._tag, `releaseEngine`);
    CallManager.instance.releaseEngine();
  }

  /**
   * 登录
   * @param appKey 应用 Key
   * @param accountId 账号ID
   * @param token 令牌
   * @param certificateConfig 证书配置（可选）
   * @param extraConfig 额外配置（可选）
   * @returns 结果
   */
  async login(
    appKey: string,
    accountId: string,
    token: string,
    certificateConfig?: NECertificateConfig,
    extraConfig?: NEExtraConfig
  ): Promise<NEResult> {
    CallUILog.infoApi(NECallUIImpl._tag, `login(appKey:${appKey}, accountId:${accountId})`);
    return await CallManager.instance.login(
      appKey,
      accountId,
      token,
      certificateConfig,
      extraConfig
    );
  }

  /**
   * 登出
   * @returns Promise<void>
   */
  async logout(): Promise<void> {
    CallUILog.infoApi(NECallUIImpl._tag, `logout`);
    await CallManager.instance.logout();
  }

  /**
   * 设置用户信息
   * @param nickname 昵称
   * @param avatar 头像
   * @returns 结果
   */
  async setSelfInfo(nickname: string, avatar: string): Promise<NEResult> {
    CallUILog.infoApi(NECallUIImpl._tag, `setSelfInfo(nickname:${nickname}, avatar:${avatar})`);
    return await CallManager.instance.setSelfInfo(nickname, avatar);
  }

  /**
   * 发起呼叫
   * @param params 呼叫参数
   * @returns 结果
   */
  async call(
    params: NECallParam
  ): Promise<NEResult> {
    CallUILog.infoApi(NECallUIImpl._tag, `call(params:${params})`);
    return await CallManager.instance.call(params);
  }

  /**
   * 设置呼叫铃声
   * @param source 铃声源（AVFileDescriptor 或 string 路径），仅用于被叫时播放
   * @returns Promise<void>
   */
  async setCallingBell(source: media.AVFileDescriptor | string): Promise<void> {
    CallUILog.infoApi(NECallUIImpl._tag, `setCallingBell`);
    await CallManager.instance.setCallingBell(source);
  }

  /**
   * 启用/禁用虚拟背景
   * @param enable 是否启用
   */
  enableVirtualBackground(enable: boolean): void {
    CallUILog.infoApi(NECallUIImpl._tag, `enableVirtualBackground(enable:${enable})`);
    CallManager.instance.enableVirtualBackground(enable);
  }

}
