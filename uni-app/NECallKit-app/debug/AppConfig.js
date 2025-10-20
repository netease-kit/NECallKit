// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/**
 * 应用配置文件
 */
export const AppConfig = {
  // 应用Key - - 请替换为你的实际appKey
  appKey: "your_app_key",
  
  // 应用Secret - 请替换为你的实际appSecret
  appSecret: "your_app_secret",
  
  // Nemo服务器地址 - 这个服务仅用来生成快速体验账号使用，上线前请替换成开发者自己的服务
  nemoServerUrl: "https://yiyong.netease.im/nemo/app/initAppAndUser",
  
  // 设备信息
  deviceInfo: {
    deviceId: "uniapp_device_id",
    clientType: "uniapp"
  }
};

export default AppConfig;
