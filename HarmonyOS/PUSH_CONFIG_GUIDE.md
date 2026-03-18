# PushConfig 配置指南

本文档介绍如何在呼叫（call）时设置 pushConfig（推送配置）。提供两种开发方式的示例代码：
1. **基于 callkit 开发** - 直接使用底层 API
2. **基于 callkit_ui 开发** - 使用 UI 组件封装

## 目录

- [功能说明](#功能说明)
- [PushConfig 结构](#pushconfig-结构)
- [基于 callkit 开发](#基于-callkit-开发)
- [基于 callkit_ui 开发](#基于-callkit_ui-开发)
- [PushPayload 格式说明](#pushpayload-格式说明)
- [最佳实践](#最佳实践)
- [常见问题](#常见问题)

## 功能说明

PushConfig 用于配置离线推送功能，当被叫用户不在线时，可以通过推送通知提醒用户接听通话。

**主要功能**：
- 控制是否启用推送
- 自定义推送标题和内容
- 传递自定义数据（payload）

## PushConfig 结构

```typescript
export class NECallPushConfig {
  pushEnabled: boolean = true;    // 是否启用推送（默认 true）
  pushTitle?: string;              // 推送标题（可选）
  pushContent?: string;            // 推送内容（可选）
  pushPayload?: string;            // 推送自定义数据，JSON 字符串格式（可选）
}
```

## 基于 callkit 开发

如果您直接使用 `callkit` 模块进行开发，可以在创建 `NECallParam` 时设置 `pushConfig`。

### 1. 基本使用

```typescript
import { NECallEngine } from 'callkit';
import { NECallParam, NECallType, NECallPushConfig } from 'callkit';

// 创建推送配置
const pushConfig = new NECallPushConfig();
pushConfig.pushEnabled = true;
pushConfig.pushTitle = '视频通话邀请';
pushConfig.pushContent = '张三邀请你进行视频通话';

// 创建通话参数
const callParam = new NECallParam('target_user_id', NECallType.VIDEO);
callParam.pushConfig = pushConfig;

// 发起通话
const result = await NECallEngine.getInstance().call(callParam);
```

### 2. 完整示例

```typescript
import { NECallEngine } from 'callkit';
import { NECallParam, NECallType, NECallPushConfig } from 'callkit';

/**
 * 通话管理类
 */
export class CallService {
  /**
   * 发起视频通话（带推送配置）
   */
  async startVideoCall(targetUserId: string, callerName: string): Promise<void> {
    // 创建推送配置
    const pushConfig = new NECallPushConfig();
    pushConfig.pushEnabled = true;
    pushConfig.pushTitle = `${callerName}的视频通话`;
    pushConfig.pushContent = `${callerName}邀请你进行视频通话`;
    
    // 创建自定义 payload
    const payload = {
      userID: targetUserId,
      callType: 'video',
      timestamp: Date.now(),
      customField1: 'value1'
    };
    pushConfig.pushPayload = JSON.stringify(payload);

    // 创建通话参数
    const callParam = new NECallParam(targetUserId, NECallType.VIDEO);
    callParam.pushConfig = pushConfig;

    // 发起通话
    try {
      const result = await NECallEngine.getInstance().call(callParam);
      if (result.code === 0) {
        console.info('通话发起成功');
      } else {
        console.error(`通话发起失败: ${result.message}`);
      }
    } catch (error) {
      console.error('发起通话异常:', error);
    }
  }

  /**
   * 发起音频通话（带推送配置）
   */
  async startAudioCall(targetUserId: string, callerName: string): Promise<void> {
    const pushConfig = new NECallPushConfig();
    pushConfig.pushEnabled = true;
    pushConfig.pushTitle = `${callerName}的语音通话`;
    pushConfig.pushContent = `${callerName}邀请你进行语音通话`;

    const callParam = new NECallParam(targetUserId, NECallType.AUDIO);
    callParam.pushConfig = pushConfig;

    await NECallEngine.getInstance().call(callParam);
  }

  /**
   * 发起通话（不使用推送）
   */
  async startCallWithoutPush(targetUserId: string, callType: NECallType): Promise<void> {
    const pushConfig = new NECallPushConfig();
    pushConfig.pushEnabled = false;  // 禁用推送

    const callParam = new NECallParam(targetUserId, callType);
    callParam.pushConfig = pushConfig;

    await NECallEngine.getInstance().call(callParam);
  }
}
```

### 3. 工具类封装

```typescript
import { NECallParam, NECallType, NECallPushConfig } from 'callkit';

/**
 * PushConfig 工具类
 */
export class PushConfigHelper {
  /**
   * 创建默认推送配置
   */
  static createDefault(callerName: string, callType: NECallType): NECallPushConfig {
    const pushConfig = new NECallPushConfig();
    pushConfig.pushEnabled = true;
    
    const typeString = callType === NECallType.VIDEO ? '视频' : '语音';
    pushConfig.pushTitle = `${callerName}的${typeString}通话`;
    pushConfig.pushContent = `${callerName}邀请你进行${typeString}通话`;
    
    return pushConfig;
  }

  /**
   * 创建带自定义 payload 的推送配置
   */
  static createWithPayload(
    callerName: string,
    callType: NECallType,
    customData: Record<string, any>
  ): NECallPushConfig {
    const pushConfig = this.createDefault(callerName, callType);
    
    // 构建 payload
    const payload = {
      userID: '',  // 会在 SDK 内部填充
      ...customData
    };
    
    pushConfig.pushPayload = JSON.stringify(payload);
    return pushConfig;
  }
}

// 使用示例
function startCall(targetUserId: string): void {
  // 方式1: 使用默认配置
  const pushConfig = PushConfigHelper.createDefault('张三', NECallType.VIDEO);
  
  // 方式2: 使用自定义 payload
  // const pushConfig = PushConfigHelper.createWithPayload(
  //   '张三',
  //   NECallType.VIDEO,
  //   { customField1: 'value1', customField2: 'value2' }
  // );

  const callParam = new NECallParam(targetUserId, NECallType.VIDEO);
  callParam.pushConfig = pushConfig;

  NECallEngine.getInstance().call(callParam);
}
```

### 4. 动态构建 PushConfig

```typescript
import { NECallParam, NECallType, NECallPushConfig } from 'callkit';

/**
 * 通话页面组件
 */
@Entry
@Component
export struct CallPage {
  @State targetUserId: string = '';
  @State callerName: string = '我';

  /**
   * 发起通话
   */
  async startCall(callType: NECallType): Promise<void> {
    // 动态构建推送配置
    const pushConfig = this.buildPushConfig(callType);
    
    const callParam = new NECallParam(this.targetUserId, callType);
    callParam.pushConfig = pushConfig;

    await NECallEngine.getInstance().call(callParam);
  }

  /**
   * 构建推送配置
   */
  private buildPushConfig(callType: NECallType): NECallPushConfig {
    const pushConfig = new NECallPushConfig();
    
    // 根据通话类型设置不同的推送内容
    if (callType === NECallType.VIDEO) {
      pushConfig.pushTitle = `${this.callerName}的视频通话邀请`;
      pushConfig.pushContent = `${this.callerName}邀请你进行视频通话`;
    } else {
      pushConfig.pushTitle = `${this.callerName}的语音通话邀请`;
      pushConfig.pushContent = `${this.callerName}邀请你进行语音通话`;
    }
    
    // 添加自定义 payload
    const payload = {
      userID: this.targetUserId,
      callerName: this.callerName,
      callType: callType === NECallType.VIDEO ? 'video' : 'audio',
      timestamp: Date.now()
    };
    pushConfig.pushPayload = JSON.stringify(payload);
    
    return pushConfig;
  }
}
```

## 基于 callkit_ui 开发

如果您使用 `callkit_ui` 模块进行开发，可以通过 `NECallUI` API 来发起通话并设置 pushConfig。

### 1. 基本使用

```typescript
import { NECallUI } from 'callkit_ui';
import { NECallParam, NECallType, NECallPushConfig } from 'callkit';

// 创建推送配置
const pushConfig = new NECallPushConfig();
pushConfig.pushEnabled = true;
pushConfig.pushTitle = '视频通话邀请';
pushConfig.pushContent = '张三邀请你进行视频通话';

// 创建通话参数
const callParam = new NECallParam('target_user_id', NECallType.VIDEO);
callParam.pushConfig = pushConfig;

// 发起通话
const result = await NECallUI.getInstance().call(callParam);
```

### 2. 完整示例

```typescript
import { NECallUI } from 'callkit_ui';
import { NECallParam, NECallType, NECallPushConfig } from 'callkit';

/**
 * 通话页面组件
 */
@Entry
@Component
export struct SingleCallPage {
  @State targetUserId: string = '';
  @State callerName: string = '我';

  /**
   * 发起视频通话
   */
  async startVideoCall(): Promise<void> {
    const callParam = this.buildCallParam(NECallType.VIDEO);
    await NECallUI.getInstance().call(callParam);
  }

  /**
   * 发起音频通话
   */
  async startAudioCall(): Promise<void> {
    const callParam = this.buildCallParam(NECallType.AUDIO);
    await NECallUI.getInstance().call(callParam);
  }

  /**
   * 构建通话参数（包含 PushConfig）
   */
  private buildCallParam(callType: NECallType): NECallParam {
    const callParam = new NECallParam(this.targetUserId, callType);
    
    // 创建推送配置
    const pushConfig = new NECallPushConfig();
    pushConfig.pushEnabled = true;
    
    const typeString = callType === NECallType.VIDEO ? '视频' : '语音';
    pushConfig.pushTitle = `${this.callerName}的${typeString}通话`;
    pushConfig.pushContent = `${this.callerName}邀请你进行${typeString}通话`;
    
    // 可选：添加自定义 payload
    const payload = {
      userID: this.targetUserId,
      callerName: this.callerName,
      callType: callType === NECallType.VIDEO ? 'video' : 'audio'
    };
    pushConfig.pushPayload = JSON.stringify(payload);
    
    callParam.pushConfig = pushConfig;
    
    return callParam;
  }
}
```

### 3. 使用 CallManager（内部 API）

```typescript
import { CallManager } from 'callkit_ui/src/main/ets/impl/CallManager';
import { NECallParam, NECallType, NECallPushConfig } from 'callkit';

/**
 * 通话服务类
 */
export class CallService {
  /**
   * 发起通话（使用 CallManager）
   */
  async startCall(targetUserId: string, callType: NECallType): Promise<void> {
    // 创建推送配置
    const pushConfig = new NECallPushConfig();
    pushConfig.pushEnabled = true;
    pushConfig.pushTitle = '通话邀请';
    pushConfig.pushContent = '有人邀请你进行通话';

    // 创建通话参数
    const callParam = new NECallParam(targetUserId, callType);
    callParam.pushConfig = pushConfig;

    // 使用 CallManager 发起通话
    await CallManager.instance.call(callParam);
  }
}
```

### 4. 实际使用示例

```typescript
import { NECallUI } from 'callkit_ui';
import { NECallParam, NECallType, NECallPushConfig } from 'callkit';

/**
 * 通话服务类
 */
export class CallService {
  /**
   * 发起通话（带推送配置）
   */
  async startCall(
    targetUserId: string,
    callType: NECallType,
    callerName: string
  ): Promise<void> {
    // 创建通话参数
    const callParam = new NECallParam(targetUserId, callType);
    
    // 创建推送配置
    const pushConfig = new NECallPushConfig();
    pushConfig.pushEnabled = true;
    
    const typeString = callType === NECallType.VIDEO ? '视频' : '语音';
    pushConfig.pushTitle = `${callerName}的${typeString}通话`;
    pushConfig.pushContent = `${callerName}邀请你进行${typeString}通话`;
    
    // 可选：添加自定义 payload
    const payload = {
      userID: targetUserId,
      callerName: callerName,
      callType: callType === NECallType.VIDEO ? 'video' : 'audio',
      timestamp: Date.now()
    };
    pushConfig.pushPayload = JSON.stringify(payload);
    
    callParam.pushConfig = pushConfig;

    // 发起通话
    await NECallUI.getInstance().call(callParam);
  }
}
```

## PushPayload 格式说明

PushPayload 是一个 JSON 字符串，用于传递自定义数据。SDK 会自动添加一些内部字段。

### 1. 基本格式

```typescript
const payload = {
  userID: 'caller_user_id',  // 主叫用户ID（SDK 会自动填充）
  customField1: 'value1',
  customField2: 'value2',
  // 注意：SDK 会在内部添加 NECallPushPayload 字段
};

const pushConfig = new NECallPushConfig();
pushConfig.pushPayload = JSON.stringify(payload);
```

### 2. 完整示例

```typescript
// 创建自定义 payload
const payload = {
  userID: 'caller_123',           // 主叫用户ID
  callType: 'video',               // 通话类型
  timestamp: Date.now(),           // 时间戳
  businessId: 'order_12345',       // 业务ID
  customData: {                    // 自定义数据
    from: 'home_page',
    source: 'user_click'
  }
};

const pushConfig = new NECallPushConfig();
pushConfig.pushPayload = JSON.stringify(payload);
```

### 3. SDK 内部字段

SDK 会在 payload 中自动添加 `NECallPushPayload` 字段，包含：

```typescript
{
  userID: 'caller_user_id',
  NECallPushPayload: {
    callType: 1,              // 1=音频, 2=视频
    displayName: '主叫名称',
    userId: 'caller_user_id',
    requestId: 'call_request_id'
  },
  // 您的自定义字段...
}
```

## 最佳实践

### 1. 使用默认推送配置

如果不设置 pushConfig，SDK 会使用默认配置：

```typescript
// 不设置 pushConfig，使用默认值
const callParam = new NECallParam(targetUserId, NECallType.VIDEO);
// callParam.pushConfig 为 undefined，SDK 会使用默认配置
await NECallEngine.getInstance().call(callParam);
```

### 2. 根据通话类型设置不同内容

```typescript
function createPushConfig(callType: NECallType, callerName: string): NECallPushConfig {
  const pushConfig = new NECallPushConfig();
  pushConfig.pushEnabled = true;
  
  if (callType === NECallType.VIDEO) {
    pushConfig.pushTitle = `${callerName}的视频通话`;
    pushConfig.pushContent = `${callerName}邀请你进行视频通话`;
  } else {
    pushConfig.pushTitle = `${callerName}的语音通话`;
    pushConfig.pushContent = `${callerName}邀请你进行语音通话`;
  }
  
  return pushConfig;
}
```

### 3. 验证 PushPayload JSON 格式

```typescript
function createPushConfigWithPayload(customData: Record<string, any>): NECallPushConfig {
  const pushConfig = new NECallPushConfig();
  
  try {
    // 验证 JSON 格式
    const payload = {
      ...customData
    };
    pushConfig.pushPayload = JSON.stringify(payload);
    
    // 验证是否可以解析
    JSON.parse(pushConfig.pushPayload);
  } catch (error) {
    console.error('PushPayload JSON 格式错误:', error);
    // 使用空字符串或默认值
    pushConfig.pushPayload = '';
  }
  
  return pushConfig;
}
```

### 4. 根据业务需求构建

```typescript
function buildCallParam(
  targetUserId: string,
  callType: NECallType,
  callerName: string,
  customPayload?: Record<string, any>
): NECallParam {
  const callParam = new NECallParam(targetUserId, callType);
  
  // 创建推送配置
  const pushConfig = new NECallPushConfig();
  pushConfig.pushEnabled = true;
  
  const typeString = callType === NECallType.VIDEO ? '视频' : '语音';
  pushConfig.pushTitle = `${callerName}的${typeString}通话`;
  pushConfig.pushContent = `${callerName}邀请你进行${typeString}通话`;
  
  // 如果有自定义 payload，添加
  if (customPayload) {
    const payload = {
      userID: targetUserId,
      ...customPayload
    };
    pushConfig.pushPayload = JSON.stringify(payload);
  }
  
  callParam.pushConfig = pushConfig;
  
  return callParam;
}
```

## 常见问题

### 1. PushConfig 不生效

**问题**: 设置了 pushConfig 但推送没有发送

**解决**:
- 检查 `pushEnabled` 是否为 `true`
- 确保被叫用户确实不在线（在线时不会发送推送）
- 检查推送服务是否配置正确
- 查看日志确认 pushConfig 是否正确传递

### 2. PushPayload 解析失败

**问题**: PushPayload JSON 格式错误

**解决**:
- 确保 payload 是有效的 JSON 字符串
- 使用 `JSON.stringify()` 和 `JSON.parse()` 验证格式
- 避免在 payload 中包含循环引用

### 3. 推送标题/内容为空

**问题**: 推送通知显示为空

**解决**:
- 如果不设置 `pushTitle` 和 `pushContent`，SDK 会使用默认值
- 确保设置的值不为空字符串
- 检查设置是否正确保存和加载

### 4. 自定义 Payload 字段丢失

**问题**: 自定义的 payload 字段在接收端丢失

**解决**:
- 确保 payload 是有效的 JSON 对象
- 避免使用 SDK 保留的字段名（如 `NECallPushPayload`）
- 检查 payload 大小是否超过限制

### 5. 推送配置不生效

**问题**: 设置了 pushConfig 但推送没有发送

**解决**:
- 确保 `pushEnabled` 为 `true`
- 检查被叫用户是否不在线（在线时不会发送推送）
- 验证推送服务配置是否正确
- 查看日志确认 pushConfig 是否正确传递

## 示例代码位置

完整示例代码请参考：

- **PushConfig 构建**: `callkit/src/main/ets/impl/service/SignallingService.ets` (第 292-400 行)
- **API 定义**: `callkit/src/main/ets/api/Models.ets` (第 67-72 行)
- **使用示例**: `callkit/src/main/ets/impl/NECallEngineImpl.ets` (第 384-405 行)

## 技术支持

如有问题，请参考：
- [云信文档中心](https://doc.yunxin.163.com/)
- GitHub Issues

