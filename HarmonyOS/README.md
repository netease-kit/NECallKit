# NERTCCallKit HarmonyOS 集成指南

本文档将帮助您快速集成并运行 NERTCCallKit HarmonyOS 版本的示例项目。

## 环境要求

### 开发环境

- **DevEco Studio**: 5.0 或更高版本
- **HarmonyOS SDK**: API 12 或更高版本

### 设备要求

- **HarmonyOS 设备**: 支持 HarmonyOS 5.0.0.102 或更高版本的手机设备
- **网络**: 需要稳定的网络连接

## 快速开始

### 1. 获取项目

```bash
# 克隆或下载项目代码
git clone git@github.com:netease-kit/NECallKit.git
cd HarmonyOS
```

### 2. 配置 APP_KEY

1. 打开 `entry/src/main/ets/config/AppConfig.ets` 文件
2. 将 `APP_KEY` 替换为您的实际 APP_KEY：

```typescript
export class AppConfig {
  private static readonly APP_KEY: string = "your app key";  // 替换为您的 APP_KEY
  
  public static getAppKey(): string {
    return AppConfig.APP_KEY;
  }
}
```

> **注意**: APP_KEY 需要在云信控制台获取，请参考 [云信控制台](https://console.yunxin.163.com/) 获取您的 APP_KEY。

### 3. 安装依赖

在项目根目录执行：

```bash
ohpm install
```

### 4. 同步项目

在 DevEco Studio 中：
1. 点击菜单栏 `File` -> `Sync Project with Gradle Files`
2. 等待同步完成

### 5. 运行项目

1. 连接 HarmonyOS 设备或启动模拟器
2. 点击 `Run` 按钮或按 `Shift + F10`
3. 等待应用安装和启动

## 项目结构

```
nertccallkit/
├── entry/                    # 入口模块
│   ├── src/main/ets/
│   │   ├── config/          # 配置文件
│   │   │   └── AppConfig.ets  # APP_KEY 配置
│   │   ├── pages/           # 页面
│   │   │   ├── Index.ets    # 首页
│   │   │   ├── LoginPage.ets # 登录页
│   │   │   └── SingleCallPage.ets # 通话页
│   │   ├── viewmodel/       # 视图模型
│   │   └── model/           # 数据模型
│   └── src/main/module.json5
│
├── callkit_ui/               # UI 模块
│   ├── src/main/ets/
│   │   ├── pages/           # UI 页面
│   │   ├── widget/          # UI 组件
│   │   ├── impl/            # UI 实现
│   │   └── utils/           # UI 工具
│   └── oh-package.json5
│
├── ByteEffect/                # 字节跳动特效模块（可选）
├── FaceUnity/                 # FaceUnity 美颜模块（可选）
└── oh-package.json5           # 项目依赖配置
```

## 配置说明

### APP_KEY 配置

APP_KEY 是应用在云信平台的唯一标识，需要在以下位置配置：

**文件位置**: `entry/src/main/ets/config/AppConfig.ets`

```typescript
export class AppConfig {
  private static readonly APP_KEY: string = "your app key";
  
  public static getAppKey(): string {
    return AppConfig.APP_KEY;
  }
}
```

### 权限配置

应用需要以下权限，已在 `entry/src/main/module.json5` 中配置：

- `ohos.permission.CAMERA` - 摄像头权限（视频通话必需）
- `ohos.permission.MICROPHONE` - 麦克风权限（音频/视频通话必需）
- `ohos.permission.KEEP_BACKGROUND_RUNNING` - 后台运行权限
- `ohos.permission.GET_NETWORK_INFO` - 网络信息权限

### 依赖配置

主要依赖在 `oh-package.json5` 和各模块的 `oh-package.json5` 中配置：

- `@nertc/nertc_sdk` - 网易云信 RTC SDK
- `@nimsdk/*` - 网易云信 IM SDK 相关模块
- `@yunxin/xkit_base` - 云信基础库

## 运行项目

### 1. 登录应用

1. 启动应用后，进入登录页面
2. 输入账号 ID 和 Token
3. 点击登录按钮

> **注意**: 
> - 账号 ID 和 Token 需要在您的业务服务器生成
> - 测试环境可以使用云信提供的测试账号生成工具

### 2. 发起通话

登录成功后，可以：

1. **发起音频通话**：
   - 输入对方账号 ID
   - 选择音频通话
   - 点击呼叫

2. **发起视频通话**：
   - 输入对方账号 ID
   - 选择视频通话
   - 点击呼叫

### 3. 接听通话

当收到来电时：
- 点击接听按钮接听
- 点击挂断按钮拒绝

### 4. 通话功能

通话过程中可以使用以下功能：

- **静音/取消静音** - 控制麦克风开关
- **扬声器** - 切换扬声器/听筒
- **摄像头开关** - 控制摄像头（仅视频通话）
- **翻转摄像头** - 前后摄像头切换（仅视频通话）
- **模糊背景** - 虚拟背景功能（仅视频通话，需在设置中开启）
- **挂断** - 结束通话

### 5. 设置功能

在通话页面点击设置按钮，可以配置：

- **超时时间** - 呼叫超时时间（秒）
- **虚化** - 启用/禁用虚拟背景功能
- **推送设置** - 推送相关配置
- **话单设置** - 自定义话单配置

## 功能说明

### 核心功能

1. **音频通话**
   - 支持一对一音频通话
   - 支持扬声器/听筒切换
   - 支持静音功能

2. **视频通话**
   - 支持一对一视频通话
   - 支持前后摄像头切换
   - 支持本地/远程画面切换
   - 支持虚拟背景（需配置）

3. **通话管理**
   - 呼叫超时处理
   - 通话状态管理
   - 通话时长显示

4. **UI 功能**
   - 全屏通话界面
   - 通话状态提示
   - Toast 提示

### 可选功能

1. **美颜功能** (FaceUnity)
   - 需要配置 FaceUnity 相关资源
   - 在设置中启用

2. **特效功能** (ByteEffect)
   - 需要配置 ByteEffect 相关资源
   - 在设置中启用

## 技术支持

- **云信文档**: [音视频呼叫(呼叫组件)](https://doc.yunxin.163.com/nertccallkit/concept?platform=client/)
- **问题反馈**: 通过 GitHub Issues 或联系云信技术支持

