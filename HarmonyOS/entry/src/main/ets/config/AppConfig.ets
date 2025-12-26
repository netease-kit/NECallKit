/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * 应用配置类
 * 用于存储应用相关的配置信息，如 APP_KEY 等
 */
export class AppConfig {
  private static readonly APP_KEY: string = "your app key";

  /**
   * 获取 APP_KEY
   * @returns APP_KEY 字符串
   */
  public static getAppKey(): string {
    return AppConfig.APP_KEY;
  }
}
