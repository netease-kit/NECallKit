## [4.4.0] - 2026.04.01
### Added
- 新增群呼（多人音视频通话）功能
  - `INECallUI.groupCall()` 发起群呼，选择多个联系人（最多 10 人）一键呼叫
  - `INECallUI.joinGroupCall()` 主动加入已存在的群呼
  - `GroupCallLaunchPage` 群呼发起/邀请页面
  - 支持被叫接听或拒绝来电邀请
  - 多人视频画面以宫格形式展示，支持点击放大
  - 音视频控制：麦克风开关、摄像头开关、扬声器切换
  - 主叫端显示成员拒绝/占线/超时等状态提示

### Changed
- 最低 API 级别从 12 升级到 13

### Compatibility
- 兼容 "@nertc/nertc_sdk" 5.9.15 版本
- 兼容 "@nimsdk/base" 10.9.50 版本

## [4.0.3] - 2026.01.06
### Changed
- RTC版本和callkit保持一致

### Compatibility
- 兼容 "@nertc/nertc_sdk" 5.9.11 版本
- 兼容 "@nimsdk/base" 10.9.50 版本


## [4.0.2] - 2026.01.06
### Changed
- 兼容最低鸿蒙API版本为12

### Compatibility
- 兼容 "@nertc/nertc_sdk" 5.9.15 版本
- 兼容 "@nimsdk/base" 10.9.50 版本

## [4.0.1] - 2025.12.29
### Changed
- 删除没用的依赖

### Compatibility
- 兼容 "@nertc/nertc_sdk" 5.9.11 版本
- 兼容 "@nimsdk/base" 10.9.50 版本

## [4.0.0] - 2025.12.29
### Added
云信呼叫组件UI套件首次发布，主要功能有： 
- 音频通话
    - 支持一对一音频通话
    - 支持扬声器/听筒切换
    - 支持静音功能

- 视频通话
    - 支持一对一视频通话
    - 支持前后摄像头切换
    - 支持本地/远程画面切换
    - 支持虚拟背景

- 通话管理
    - 呼叫超时处理
    - 通话状态管理
    - 通话时长显示

- UI 功能
    - 全屏通话界面
    - 通话状态提示
    - Toast 提示

### Compatibility
- 兼容 "@nertc/nertc_sdk" 5.9.11 版本
- 兼容 "@nimsdk/base" 10.9.50 版本
