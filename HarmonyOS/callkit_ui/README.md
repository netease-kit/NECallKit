# CallKit UI 快速入门

本文介绍在鸿蒙平台下如何快速集成 CallKit UI 到项目中。

## 环境要求

- **DevEco Studio**: 5.0.3.900 及以上版本

## 设备要求
- HarmonyOS 设备: 支持 HarmonyOS 5.0.0.102 或更高版本的手机设备
- 网络: 需要稳定的网络连接

## 下载安装

### 通过 ohpm 安装

```bash
ohpm install @yunxin/callkit_ui
```

> **注意**: OpenHarmony ohpm 环境配置等更多内容，请参考[如何安装 OpenHarmony ohpm 包](https://gitee.com/openharmony-tpc/docs/blob/master/OpenHarmony_har_usage.md)

## 需要权限

在 `module.json5` 中配置以下权限：

```json5
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.CAMERA",
        "reason": "用于视频通话",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "always"
        }
      },
      {
        "name": "ohos.permission.MICROPHONE",
        "reason": "用于音频/视频通话",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "always"
        }
      }
    ]
  }
}
```

## 快速集成

### 1. 导入模块

```typescript
import { NECallUI } from '@yunxin/callkit_ui';
import { NESetupConfig, NECallParam, NECallType } from '@yunxin/callkit';
import { NIMInterface } from '@nimsdk/base';
import common from '@ohos.app.ability.common';
```

### 2. 初始化 SDK

```typescript

// IM初始化
NIMSdk.registerCustomServices(V2NIMProvidedServiceType.V2NIM_PROVIDED_SERVICE_MESSAGE, (core, serviceName, serviceConfig) => new V2NIMMessageServiceImpl(core, serviceName, serviceConfig));
NIMSdk.registerCustomServices(V2NIMProvidedServiceType.V2NIM_PROVIDED_SERVICE_USER, (core, serviceName, serviceConfig) => new V2NIMUserServiceImpl(core, serviceName, serviceConfig));
NIMSdk.registerCustomServices(V2NIMProvidedServiceType.V2NIM_PROVIDED_SERVICE_SIGNALLING, (core, serviceName, serviceConfig) => new V2NIMSignallingServiceImpl(core, serviceName, serviceConfig));
this._nim = NIMSdk.newInstance(this._context, initializeOptions, serviceOptions)

// 获取 CallKit UI 实例
const callUI = NECallUI.getInstance();

// 准备配置信息
const setupConfig = new NESetupConfig(
  context,           // common.Context
  nim,               // NIMInterface 实例（需要先初始化 IM SDK）
  appKey,            // 云信 APP_KEY
  accountId          // 当前用户账号 ID
);

// 初始化引擎
await callUI.setupEngine(setupConfig);
```

### 3. 登录

```typescript
// 登录云信 IM
await callUI.login(
  appKey,        // 云信 APP_KEY
  accountId,     // 账号 ID
  token          // 账号 Token（从业务服务器获取）
);
```

### 4. 发起通话

```typescript
// 创建通话参数
const callParam = new NECallParam(
  targetAccountId,        // 目标用户账号 ID
  NECallType.VIDEO       // 通话类型：AUDIO 或 VIDEO
);

// 可选：设置额外信息
callParam.extraInfo = "自定义信息";
callParam.globalExtraCopy = "全局抄送信息";

// 发起通话（会自动跳转到通话页面）
await callUI.call(callParam);
```

### 5. 启用虚拟背景（可选）

```typescript
// 启用虚拟背景功能
callUI.enableVirtualBackground(true);
```

### 6. 释放资源

```typescript
// 登出
await callUI.logout();

// 释放引擎
callUI.releaseEngine();
```

## API 使用

### 核心 API

#### 初始化引擎

```typescript
setupEngine(config: NESetupConfig): Promise<void>
```

初始化 CallKit UI SDK，必须在其他 API 调用之前执行。

#### 释放引擎

```typescript
releaseEngine(): void
```

释放 CallKit UI SDK 资源，通常在应用退出时调用。

#### 登录

```typescript
login(
  appKey: string,
  accountId: string,
  token: string,
  certificateConfig?: NECertificateConfig,
  extraConfig?: NEExtraConfig
): Promise<NEResult>
```

登录云信 IM，登录成功后才能发起和接收通话。

**参数说明**：
- `appKey`: 云信 APP_KEY（必填）
- `accountId`: 账号 ID（必填）
- `token`: 账号 Token，从业务服务器获取（必填）
- `certificateConfig`: 证书配置（可选，用于推送）
- `extraConfig`: 额外配置（可选）

#### 登出

```typescript
logout(): Promise<void>
```

登出云信 IM。

#### 设置用户信息

```typescript
setSelfInfo(nickname: string, avatar: string): Promise<NEResult>
```

设置当前用户的显示信息，用于在通话界面显示。

**参数说明**：
- `nickname`: 用户昵称
- `avatar`: 用户头像 URL

#### 发起呼叫

```typescript
call(params: NECallParam): Promise<NEResult>
```

发起音频或视频通话，调用后会自动跳转到通话页面。

**参数说明**：
- `accountId`: 目标用户账号 ID（必填）
- `callType`: 通话类型，`NECallType.AUDIO` 或 `NECallType.VIDEO`（必填）
- `extraInfo`: 自定义信息（可选）
- `globalExtraCopy`: 全局抄送信息（可选）
- `pushConfig`: 推送配置（可选）

### 功能 API

#### 启用虚拟背景

```typescript
enableVirtualBackground(enable: boolean): void
```

启用或禁用虚拟背景功能。

**参数说明**：
- `enable`: `true` 启用虚拟背景，`false` 禁用

### 查询 API

#### 获取版本号

```typescript
NECallUI.version(): string
```

获取 SDK 版本号。

#### 获取实例

```typescript
NECallUI.getInstance(): INECallUI
// 或使用别名
NECallUI.instance
```

获取 NECallUI 实例。

## UI 组件说明

### 通话页面

CallKit UI 提供了完整的通话界面，包括：

- **CallMainPage**: 通话主页面容器，负责生命周期管理和路由跳转
- **CallMainWidget**: 通话主组件，负责状态管理和界面渲染
- **CallP2PUserWidget**: 一对一通话用户界面，显示用户信息和视频画面
- **CallFunctionWidget**: 通话功能按钮组件，包含静音、摄像头、挂断等功能按钮

### 自动跳转

当收到来电或发起通话时，CallKit UI 会自动跳转到通话页面，无需手动处理路由。

### 通话界面功能

通话界面提供以下功能按钮：

- **静音/取消静音** - 控制麦克风开关
- **扬声器** - 切换扬声器/听筒
- **摄像头开关** - 控制摄像头（仅视频通话）
- **翻转摄像头** - 前后摄像头切换（仅视频通话）
- **模糊背景** - 虚拟背景功能（仅视频通话，需启用）
- **挂断** - 结束通话

## 配置说明

### NESetupConfig 配置

```typescript
const setupConfig = new NESetupConfig(
  context,      // 应用上下文
  nim,          // NIM SDK 实例
  appKey,       // 云信 APP_KEY
  accountId,    // 当前用户账号 ID
  extraConfig   // 额外配置（可选）
);
```

### NECallParam 参数

```typescript
const callParam = new NECallParam(
  accountId,    // 目标用户账号 ID
  callType      // 通话类型
);

// 可选参数
callParam.rtcChannelName = "自定义 RTC 房间号";
callParam.extraInfo = "自定义信息";
callParam.globalExtraCopy = "全局抄送信息";

// 推送配置
callParam.pushConfig = {
  pushEnabled: true,
  pushTitle: "来电提醒",
  pushContent: "您有一个新的通话",
  pushPayload: JSON.stringify({ custom: "data" })
};
```

### 路由配置

在 `module.json5` 中配置通话页面路由：

```json5
{
  "module": {
    "pages": [
      "pages/CallMainPage"
    ],
    "routing": {
      "routes": [
        {
          "name": "callMainPage",
          "path": "pages/CallMainPage"
        }
      ]
    }
  }
}
```

> **注意**: CallKit UI 会自动处理路由跳转，但需要确保路由配置正确。

## 功能说明

### 核心功能

1. **音频通话**
   - 支持一对一音频通话
   - 支持扬声器/听筒切换
   - 支持静音功能
   - 自动显示通话时长

2. **视频通话**
   - 支持一对一视频通话
   - 支持前后摄像头切换
   - 支持本地/远程画面显示
   - 支持虚拟背景功能
   - 自动显示通话时长

3. **通话管理**
   - 自动处理来电跳转
   - 自动处理通话结束返回
   - 呼叫超时处理
   - 通话状态管理

4. **UI 功能**
   - 全屏通话界面
   - 通话状态提示（等待、连接中等）
   - Toast 提示
   - 用户信息显示（头像、昵称）
   - 通话时长显示

### 高级功能

1. **虚拟背景**
   - 支持启用/禁用虚拟背景
   - 需要在通话前调用 `enableVirtualBackground(true)`
   - 需要依赖 `@nertc/person_segment_plugin` 插件

2. **推送通知**
   - 支持离线推送配置
   - 支持自定义推送内容

## 常见问题

### 1. 编译错误：找不到模块

**问题**: 编译时提示找不到 `@yunxin/callkit_ui` 或 `@yunxin/callkit` 模块

**解决**:
```bash
# 清理并重新安装依赖
ohpm clean
ohpm install
```

### 2. 初始化失败

**问题**: `setupEngine()` 调用失败

**解决**:
- 检查 `appKey` 是否正确
- 检查 `NIMInterface` 是否已正确初始化
- 检查 `context` 是否有效
- 检查网络连接是否正常

### 3. 登录失败

**问题**: `login()` 调用失败

**解决**:
- 检查 `appKey`、`accountId`、`token` 是否正确
- 检查 Token 是否过期
- 检查网络连接是否正常
- 检查账号是否已在其他设备登录

### 4. 无法发起通话

**问题**: `call()` 调用后没有跳转到通话页面

**解决**:
- 检查目标用户账号 ID 是否正确
- 检查当前用户是否已登录
- 检查是否已正确初始化 SDK
- 检查路由配置是否正确
- 检查是否有正在进行的通话

### 5. 无法接听通话

**问题**: 收到来电但没有自动跳转

**解决**:
- 检查是否已调用 `setupEngine` 和 `login`
- 检查是否已授予麦克风权限（音频通话）
- 检查是否已授予摄像头权限（视频通话）
- 检查路由配置是否正确

### 6. 视频通话黑屏

**问题**: 视频通话时显示黑屏

**解决**:
- 检查是否已授予摄像头权限
- 检查摄像头是否被其他应用占用
- 检查网络连接是否稳定
- 检查是否已启用虚拟背景（如果使用）

### 7. 无声音

**问题**: 通话时没有声音

**解决**:
- 检查是否已授予麦克风权限
- 检查设备音量设置
- 检查是否开启了静音
- 检查扬声器设置是否正确

### 8. 虚拟背景不工作

**问题**: 启用虚拟背景后没有效果

**解决**:
- 检查是否已依赖 `@nertc/person_segment_plugin` 插件
- 检查是否在通话前调用了 `enableVirtualBackground(true)`
- 检查设备是否支持虚拟背景功能

### 9. 通话结束后无法返回

**问题**: 通话结束后停留在通话页面

**解决**:
- 检查路由配置是否正确
- 检查是否有路由栈问题
- 查看日志确认是否有错误信息

## 技术支持

- **云信文档**: [音视频呼叫(呼叫组件)](https://doc.yunxin.163.com/nertccallkit/concept?platform=client/)
- **问题反馈**: 通过 GitHub Issues 或联系云信技术支持
- **API 参考**: 查看 SDK 源码中的接口定义和注释