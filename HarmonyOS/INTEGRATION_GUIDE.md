# NERTCCallKit HarmonyOS 集成开发指南

本文档详细说明如何将 NERTCCallKit 集成到您的 HarmonyOS 项目中。

## 目录

- [前置准备](#前置准备)
- [集成步骤](#集成步骤)
- [初始化配置](#初始化配置)
- [API 使用](#api-使用)
- [UI 集成](#ui-集成)
- [权限配置](#权限配置)
- [高级功能](#高级功能)
- [最佳实践](#最佳实践)

## 前置准备

### 1. 获取 APP_KEY

1. 登录 [云信控制台](https://console.yunxin.163.com/)
2. 创建应用或选择已有应用
3. 在应用详情中获取 APP_KEY

### 2. 准备账号系统

NERTCCallKit 需要配合云信 IM SDK 使用，您需要：

- 实现账号登录功能
- 获取账号的 accid 和 token
- 初始化 NIM SDK

## 集成步骤

### 步骤 1: 添加依赖

在您的项目根目录的 `oh-package.json5` 中添加依赖：

```json5
{
  "dependencies": {
    "callkit": "file:../callkit",
    "callkit_ui": "file:../callkit_ui"
  }
}
```

或者如果使用远程依赖：

```json5
{
  "dependencies": {
    "callkit": "^1.0.0",
    "callkit_ui": "^1.0.0"
  }
}
```

### 步骤 2: 安装依赖

```bash
ohpm install
```

### 步骤 3: 配置 APP_KEY

创建配置文件 `entry/src/main/ets/config/AppConfig.ets`：

```typescript
export class AppConfig {
  private static readonly APP_KEY: string = "your app key";
  
  public static getAppKey(): string {
    return AppConfig.APP_KEY;
  }
}
```

### 步骤 4: 配置权限

在 `entry/src/main/module.json5` 中添加必要权限：

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
      },
      {
        "name": "ohos.permission.KEEP_BACKGROUND_RUNNING",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "always"
        }
      }
    ]
  }
}
```

## 初始化配置

### 1. 初始化 NIM SDK

```typescript
import { NIMInitializeOptions } from '@nimsdk/base';
import { AppConfig } from './config/AppConfig';

// 初始化 NIM SDK
const initializeOptions: NIMInitializeOptions = {
  appkey: AppConfig.getAppKey(),
  logLevel: LogLevel.Debug,
  isOpenConsoleLog: true
};

// 使用您的 NIM SDK 初始化方法
nimRepository.initNim(initializeOptions);
```

### 2. 初始化 CallKit

```typescript
import { NECallUI } from 'callkit_ui';
import { NESetupConfig } from 'callkit/src/main/ets/api/Models';

// 创建配置
const setupConfig: NESetupConfig = {
  // 配置项
};

// 初始化 CallKit UI
NECallUI.setup(setupConfig);
```

## API 使用

### 发起通话

```typescript
import { NECallUI } from 'callkit_ui';
import { NECallParam, NECallType } from 'callkit/src/main/ets/api/Models';

// 创建通话参数
const callParam: NECallParam = {
  userId: 'target_user_id',  // 目标用户 ID
  callType: NECallType.VIDEO, // 或 NECallType.AUDIO
  // 其他参数...
};

// 发起通话
NECallUI.startCall(callParam);
```

### 监听通话事件

```typescript
import { NECallUI } from 'callkit_ui';
import { NECallDelegate } from 'callkit/src/main/ets/api/Models';

// 实现回调接口
class MyCallDelegate implements NECallDelegate {
  onCallStart(): void {
    console.log('通话开始');
  }
  
  onCallEnd(info: NECallEndInfo): void {
    console.log('通话结束', info);
  }
  
  // 其他回调方法...
}

// 设置回调
NECallUI.setCallDelegate(new MyCallDelegate());
```

### 接听通话

当收到来电时，CallKit 会自动显示接听界面。您也可以通过代码接听：

```typescript
import { NECallUI } from 'callkit_ui';

// 接听通话
NECallUI.accept();
```

### 挂断通话

```typescript
import { NECallUI } from 'callkit_ui';

// 挂断通话
NECallUI.hangup();
```

## UI 集成

### 方式一：使用默认 UI（推荐）

CallKit 提供了完整的 UI 组件，可以直接使用：

```typescript
import { CallMainPage } from 'callkit_ui/src/main/ets/pages/CallMainPage';

// 在路由中配置
router.pushUrl({
  url: 'pages/CallMainPage'
});
```

### 方式二：自定义 UI

如果需要对 UI 进行自定义，可以：

1. 继承 `CallMainWidget` 组件
2. 重写相关方法
3. 自定义样式和布局

```typescript
import { CallMainWidget } from 'callkit_ui/src/main/ets/widget/CallMainWidget';

@Component
export struct MyCustomCallWidget extends CallMainWidget {
  // 自定义实现
}
```

## 权限配置

### 动态申请权限

在发起通话前，需要动态申请权限：

```typescript
import AbilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';

async function requestPermissions(isVideoCall: boolean): Promise<boolean> {
  const context = getContext(this) as common.UIAbilityContext;
  const atManager = abilityAccessCtrl.createAtManager();
  
  const permissions: Array<Permissions> = isVideoCall 
    ? [Permissions.MICROPHONE, Permissions.CAMERA]
    : [Permissions.MICROPHONE];
  
  try {
    const result = await atManager.requestPermissionsFromUser(context, permissions);
    return result.authResults.every(result => result === 0);
  } catch (error) {
    console.error('申请权限失败', error);
    return false;
  }
}
```

## 高级功能

### 1. 虚拟背景

```typescript
import { CallManager } from 'callkit_ui';

// 启用虚拟背景
CallManager.instance.enableVirtualBackground(true);
```

### 2. 画中画功能

```typescript
import { PipManager } from 'callkit_ui/src/main/ets/utils/PipManager';

// 启动画中画
PipManager.getInstance().startPip();
```

### 3. 通话设置

```typescript
import { CallSettingsManager } from 'entry/src/main/ets/manager/CallSettingsManager';

const settingsManager = new CallSettingsManager();
await settingsManager.loadSettings(context);

// 应用设置
const settings = settingsManager.getSettings();
// 使用设置...
```

### 4. 自定义通话参数

```typescript
const callParam: NECallParam = {
  userId: 'target_user_id',
  callType: NECallType.VIDEO,
  rtcChannelName: 'custom_channel_name',  // 自定义频道名
  globalExtraCopy: 'custom_params',       // 自定义参数
  // 其他参数...
};
```

## 最佳实践

### 1. 错误处理

```typescript
try {
  await NECallUI.startCall(callParam);
} catch (error) {
  console.error('发起通话失败', error);
  // 显示错误提示
}
```

### 2. 状态管理

建议使用全局状态管理来管理通话状态：

```typescript
import { CallState } from 'callkit_ui/src/main/ets/impl/CallState';

// 监听状态变化
const state = CallState.instance;
// 使用状态...
```

### 3. 生命周期管理

确保在应用退出时清理资源：

```typescript
aboutToDisappear(): void {
  // 清理通话资源
  NECallUI.cleanup();
}
```

### 4. 网络状态处理

监听网络状态变化，处理网络异常：

```typescript
import { network } from '@kit.NetworkKit';

network.on('typeChange', (data) => {
  if (data.type === network.NetworkType.NONE) {
    // 网络断开，提示用户
  }
});
```

### 5. 后台运行

配置后台运行以支持通话：

在 `module.json5` 中配置：

```json5
{
  "abilities": [
    {
      "name": "EntryAbility",
      "backgroundModes": ["audioRecording", "audioPlayback"]
    }
  ]
}
```

## 常见集成问题

### 1. 模块找不到

**问题**: `Cannot find module 'callkit'`

**解决**: 检查 `oh-package.json5` 中的依赖配置，确保路径正确

### 2. 权限被拒绝

**问题**: 通话时提示权限不足

**解决**: 
- 检查 `module.json5` 中的权限声明
- 确保动态申请权限
- 检查系统设置中的权限状态

### 3. 登录失败

**问题**: 无法登录

**解决**:
- 检查 APP_KEY 是否正确
- 检查账号和 Token 是否有效
- 检查网络连接

### 4. 通话无法建立

**问题**: 发起通话后无法连接

**解决**:
- 检查双方是否都已登录
- 检查网络连接
- 检查防火墙设置
- 查看日志定位问题

## 示例代码

完整示例请参考项目中的：

- `entry/src/main/ets/pages/LoginPage.ets` - 登录示例
- `entry/src/main/ets/pages/SingleCallPage.ets` - 通话示例
- `entry/src/main/ets/pages/Index.ets` - 主页面示例

## 技术支持

- **文档中心**: [https://doc.yunxin.163.com/](https://doc.yunxin.163.com/)
- **问题反馈**: 通过 GitHub Issues 反馈

## 更新日志

查看各版本的更新内容，确保使用最新功能。

