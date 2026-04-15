# Flutter OHOS 权限提示功能实现说明

## 概述

本次更新为 Flutter OHOS 平台添加了完整的权限被拒绝后的引导提示功能，与 Android 和 iOS 平台保持一致。

## 实现的功能

### 1. 权限被拒绝检测
- 自动检测用户拒绝的权限类型（麦克风、摄像头、蓝牙）
- 收集所有被拒绝的权限列表

### 2. 权限引导对话框
- 当权限被拒绝时，自动弹出引导对话框
- 对话框包含两个按钮：
  - **"取消"**：用户放弃授权，返回 Denied 状态
  - **"去设置"**：自动跳转到系统设置页面，返回 Requesting 状态

### 3. 智能文案生成
根据被拒绝的权限类型，自动生成对应的提示文案：

#### 只缺少麦克风权限
```
标题：麦克风权限未开启
内容：无法使用麦克风，请前往"设置 > 应用和元服务 > 当前应用"中打开麦克风权限。
```

#### 只缺少摄像头权限
```
标题：摄像头权限未开启
内容：无法使用摄像头，请前往"设置 > 应用和元服务 > 当前应用"中打开摄像头权限。
```

#### 同时缺少麦克风和摄像头权限
```
标题：麦克风和摄像头权限未开启
内容：无法使用麦克风和摄像头，请前往"设置 > 应用和元服务 > 当前应用"中打开相应的权限。
```

#### 其他权限
```
标题：权限未开启
内容：无法使用[权限名称]，请前往"设置 > 应用和元服务 > 当前应用"中打开相应的权限。
```

## 代码改动

### 主要修改文件
`Flutter/callkit_ui/ohos/src/main/ets/components/plugin/permission/PermissionManager.ets`

### 新增功能

#### 1. 导入 promptAction 模块
```typescript
import { promptAction } from '@kit.ArkUI';
```

#### 2. 新增 getPermissionName 函数
```typescript
function getPermissionName(permission: Permissions): string {
  switch (permission) {
    case 'ohos.permission.CAMERA': return '摄像头';
    case 'ohos.permission.MICROPHONE': return '麦克风';
    case 'ohos.permission.USE_BLUETOOTH': return '蓝牙';
    default: return '权限';
  }
}
```

#### 3. 增强 requestPermissions 方法
- 权限被拒绝时，收集被拒绝的权限列表
- 调用 `showPermissionDeniedDialog` 显示引导对话框
- 根据用户选择返回不同的状态码：
  - `0`: Granted（已授权）
  - `1`: Denied（用户取消）
  - `2`: Requesting（用户选择去设置）

#### 4. 新增 showPermissionDeniedDialog 方法
```typescript
private showPermissionDeniedDialog(
  context: common.UIAbilityContext,
  deniedPermissions: Array<Permissions>
): Promise<boolean>
```
- 显示权限被拒绝的引导对话框
- 使用 `promptAction.showDialog` API
- 提供"取消"和"去设置"两个按钮
- 返回 Promise，表示用户是否选择去设置

#### 5. 新增 generatePermissionAlertContent 方法
```typescript
private generatePermissionAlertContent(
  deniedPermissions: Array<Permissions>
): { title: string, message: string }
```
- 根据被拒绝的权限类型生成对应的标题和内容
- 支持麦克风、摄像头的单独提示和组合提示
- 其他权限使用通用提示

## 使用方式

### Dart 层调用（无需修改）
```dart
final result = await Permission.request(NECallType.video);
if (result == PermissionResult.granted) {
  // 权限已授予
} else if (result == PermissionResult.requesting) {
  // 用户点击了"去设置"
} else {
  // 权限被拒绝
}
```

### 原生层自动处理
当用户拒绝权限后，`PermissionManager` 会：
1. 自动检测被拒绝的权限
2. 显示对应的引导对话框
3. 用户点击"去设置"后自动跳转
4. 返回相应的状态码给 Dart 层

## 与其他平台对比

| 功能 | Android | iOS | OHOS（本次更新前） | OHOS（本次更新后） |
|------|---------|-----|-------------------|-------------------|
| 权限请求 | ✅ | ✅ | ✅ | ✅ |
| 权限被拒绝检测 | ✅ | ✅ | ❌ | ✅ |
| 引导对话框 | ✅ | ✅ | ❌ | ✅ |
| 区分权限类型提示 | ✅ | ✅ | ❌ | ✅ |
| 跳转设置页面 | ✅ | ✅ | ✅ | ✅ |
| 自动跳转 | ✅ | ✅ | ❌ | ✅ |

## 测试场景

### 场景 1：首次请求权限
1. 用户首次发起视频通话
2. 系统弹出权限请求对话框
3. 用户点击"允许" → 通话正常进行
4. 用户点击"拒绝" → 显示引导对话框

### 场景 2：权限被拒绝后
1. 用户拒绝权限请求
2. 自动弹出引导对话框，显示对应的权限提示文案
3. 用户点击"去设置" → 跳转到系统设置页面
4. 用户点击"取消" → 关闭对话框，返回 Denied 状态

### 场景 3：部分权限被拒绝
1. 用户允许麦克风权限，拒绝摄像头权限
2. 引导对话框只提示摄像头权限未开启
3. 点击"去设置"跳转到设置页面

## 日志输出

权限处理过程会输出详细的日志：
```
[PermissionManager] All permissions granted
[PermissionManager] Permissions denied: ["ohos.permission.CAMERA"]
[PermissionManager] Showing permission denied dialog: 摄像头权限未开启
[PermissionManager] User chose to go to settings
[PermissionManager] User cancelled permission request
```

## 注意事项

1. **promptAction 模块**：需要 HarmonyOS API 9 或以上版本
2. **权限声明**：需在 `module.json5` 中声明相应权限
3. **用户体验**：引导对话框不可取消（点击外部区域不关闭），确保用户做出明确选择
4. **跳转时机**：点击"去设置"后会立即跳转，同时返回 Requesting 状态

## 版本兼容性

- **HarmonyOS API**: 9+
- **Flutter SDK**: 3.0+
- **向后兼容**: 完全兼容现有代码，无需修改业务层逻辑

## 未来优化方向

1. 支持国际化（英文文案）
2. 支持自定义对话框样式
3. 添加"不再提示"选项
4. 支持权限说明视频或图片

---

**更新时间**: 2026/4/14  
**维护者**: AI Assistant
