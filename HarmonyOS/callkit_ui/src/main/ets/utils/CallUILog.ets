// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import {xkitLogInfo as info, xkitLogDebug as debug, xkitLogWarn as warn, xkitLogError as error} from "libxkitbase.so";

/**
 * 日志类型枚举
 */
export enum LogType {
  Normal = 0,
  Api = 1,
}

/**
 * 日志服务
 * 提供统一的日志输出功能
 */
export class CallUILog {
  private static readonly MODULE_NAME = 'CallUIKit';

  /**
   * 输出 DEBUG 级别日志（普通类型）
   * @param tag 日志标签
   * @param message 日志消息
   */
  static debug(tag: string, message: string): void {
    debug(tag, LogType.Normal, CallUILog.MODULE_NAME, message);
  }

  /**
   * 输出 INFO 级别日志（普通类型）
   * @param tag 日志标签
   * @param message 日志消息
   */
  static info(tag: string, message: string): void {
    info(tag, LogType.Normal, CallUILog.MODULE_NAME, message);
  }

  /**
   * 输出 WARN 级别日志（普通类型）
   * @param tag 日志标签
   * @param message 日志消息
   */
  static warn(tag: string, message: string): void {
    warn(tag, LogType.Normal, CallUILog.MODULE_NAME, message);
  }

  /**
   * 输出 ERROR 级别日志（普通类型）
   * @param tag 日志标签
   * @param message 日志消息
   */
  static error(tag: string, message: string): void {
    error(tag, LogType.Normal, CallUILog.MODULE_NAME, message);
  }

  /**
   * 输出 API 类型 INFO 级别日志
   * @param tag 日志标签
   * @param message 日志消息
   */
  static infoApi(tag: string, message: string): void {
    info(tag, LogType.Api, CallUILog.MODULE_NAME, message);
  }

  /**
   * 输出 API 类型 WARN 级别日志
   * @param tag 日志标签
   * @param message 日志消息
   */
  static warnApi(tag: string, message: string): void {
    warn(tag, LogType.Api, CallUILog.MODULE_NAME, message);
  }

  /**
   * 输出 API 类型 ERROR 级别日志
   * @param tag 日志标签
   * @param message 日志消息
   */
  static errorApi(tag: string, message: string): void {
    error(tag, LogType.Api, CallUILog.MODULE_NAME, message);
  }
}

