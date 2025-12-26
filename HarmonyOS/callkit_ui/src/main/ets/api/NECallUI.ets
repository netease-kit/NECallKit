// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { media } from '@kit.MediaKit';
import { NESetupConfig, VoidResult, NECallType, NECallPushConfig, NECallParam, NECertificateConfig,
  NEExtraConfig } from "@necallkit/callkit";
import { NECallUIImpl } from "../impl/NECallUIImpl";
import { NEResult } from "../impl/CallManager";

/**
 * NECallUI 接口
 */
export interface INECallUI {
  /**
   * 初始化引擎
   * @param appKey 应用 Key
   * @param accountId 账号ID
   * @param extraConfig 额外配置（可选）
   * @returns Promise<void>
   */
  setupEngine(config: NESetupConfig): Promise<void>;

  /**
   * 释放引擎
   */
  releaseEngine(): void;

  /**
   * 登录
   * @param appKey 应用 Key
   * @param accountId 账号ID
   * @param token 令牌
   * @param certificateConfig 证书配置（可选）
   * @param extraConfig 额外配置（可选）
   * @returns 结果
   */
  login(
    appKey: string,
    accountId: string,
    token: string,
    certificateConfig?: NECertificateConfig,
    extraConfig?: NEExtraConfig
  ): Promise<NEResult>;

  /**
   * 登出
   * @returns Promise<void>
   */
  logout(): Promise<void>;

  /**
   * 设置用户信息
   * @param nickname 昵称
   * @param avatar 头像
   * @returns 结果
   */
  setSelfInfo(nickname: string, avatar: string): Promise<NEResult>;

  /**
   * 发起呼叫
   * @param params 呼叫参数
   * @returns 结果
   */
  call(params: NECallParam): Promise<NEResult>;

  /**
   * 设置呼叫铃声
   * @param source 铃声源（AVFileDescriptor 或 string 路径），仅用于被叫时播放
   * @returns Promise<void>
   */
  setCallingBell(source: media.AVFileDescriptor | string): Promise<void>;

  /**
   * 启用/禁用虚拟背景
   * @param enable 是否启用
   */
  enableVirtualBackground(enable: boolean): void;
}

/**
 * NECallUI 命名空间，提供静态方法
 */
export namespace NECallUI {
  /**
   * 获取 NECallUI 实例
   * @returns NECallUI 实例
   */
  export function getInstance(): INECallUI {
    return NECallUIImpl.getInstance();
  }

  /**
   * 获取版本信息
   * @returns 版本号
   */
  export function version(): string {
    return "4.0.0";
  }

  /**
   * 获取实例（别名，与 Flutter 版本保持一致）
   */
  export const instance: INECallUI = NECallUIImpl.getInstance();
}