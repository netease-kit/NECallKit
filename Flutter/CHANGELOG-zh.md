## [4.3.0] - 2026-03-17
### Added
- 新增来电横幅功能：收到来电时在屏幕顶部展示来电横幅，支持一键接听或拒绝。
- 新增 `enableIncomingBanner` 接口，用于开启或关闭来电横幅模式。

### Compatibility
- 兼容 `callkit` Flutter 4.3.0 版本

## [4.1.0+3] - 2026-01-04
### Fix
- 修改 readme

### Compatibility
- Compatible with `callkit` Flutter 4.1.0

## [4.1.0+2] - 2025-12-31
### Fix
- 解决`flutter analyze`

### Compatibility
- 兼容 `callkit` Flutter 4.1.0 版本

## [4.1.0+1] - 2025-12-22
### Fix
- 解决`flutter analyze` 
### Changed
- 内部不再依赖common-ui

### Compatibility
- 兼容 `callkit` Flutter 4.1.0 版本

## [4.1.0] - 2025-12-19
### Added
- 支持通话中AI字幕功能

### Compatibility
- 兼容 `callkit` Flutter 4.1.0 版本

## [3.8.1-beta.1] - 2025-12-09
### Fixed
- Android的onCallConnected的NECallInfo中返回 RTC Info
### Compatibility
- 兼容 `callkit` Android 3.8.0 版本
- 兼容 `callkit` iOS 3.8.0 版本

## [3.8.1-beta.0] - 2025-11-06
### Added
- 支持展示字幕
### Compatibility
- 兼容 `callkit` Android 3.8.0 版本
- 兼容 `callkit` iOS 3.8.0 版本

## [3.8.1+5] - 2025-12-03
### Fix
- flutter analyze

### Compatibility
- 兼容 `callkit` Android 3.8.0 版本
- 兼容 `callkit` iOS 3.8.0 版本

## [3.8.1+4] - 2025-12-03
### Changed
- 升级common、common_ui，都不再指定intl具体版本

### Compatibility
- 兼容 `callkit` Android 3.8.0 版本
- 兼容 `callkit` iOS 3.8.0 版本

## [3.8.1+3] - 2025-12-03
### Changed
- 指定flutter版本区间为">=2.5.0"
- 不指定intl具体版本修改为"intl: any"

### Compatibility
- 兼容 `callkit` Android 3.8.0 版本
- 兼容 `callkit` iOS 3.8.0 版本

## [3.8.1+2] - 2025-12-03
### Changed
- 指定flutter版本区间为">=2.5.0 <= 3.22.3"

### Compatibility
- 兼容 `callkit` Android 3.8.0 版本
- 兼容 `callkit` iOS 3.8.0 版本

## [3.8.1+1] - 2025-12-03
### Fix
- flutter analyze

### Compatibility
- 兼容 `callkit` Android 3.8.0 版本
- 兼容 `callkit` iOS 3.8.0 版本

## [3.8.1] - 2025-12-03
### Changed
- 升级callkit
### Fix
- flutter analyze

### Compatibility
- 兼容 `callkit` Android 3.8.0 版本
- 兼容 `callkit` iOS 3.8.0 版本

## [3.8.0+1] - 2025-11-06
### Changed
- 对齐native版本
### Compatibility
- 兼容 `callkit` Android 3.8.0 版本
- 兼容 `callkit` iOS 3.8.0 版本

## [3.8.0] - 2025-11-06
### Added
- 支持退后台弹出悬浮窗（开关为NECallKitUI.instance.enableFloatWindowOutOfApp(bool enable)）
- 支持多端登录时，一方接听后，另外一方弹出toast提示
### Fixed
- 优化了通话页面大小画面切换黑屏的问题
- 修复部分机型（小米mix3）应用外小窗通话时，点击小窗无法调起通话页面，停留在应用外的问题
### Compatibility
- 兼容 `callkit` Android 3.8.0 版本
- 兼容 `callkit` iOS 3.8.0 版本

## [3.7.1+3] - 2025-10-21
### Added
- 添加多端登录，一方接听后，另外一方弹出toast提示
### Compatibility
- 兼容 `callkit` Android 3.7.2 版本
- 兼容 `callkit` iOS 3.7.1 版本

## [3.7.1+2] - 2025-10-20
### Changed
- 升级Native SDK
### Compatibility
- 兼容 `callkit` Android 3.7.2 版本
- 兼容 `callkit` iOS 3.7.1 版本

## [3.7.1+1] - 2025-10-17
### Fixed
- 防止出现未知的通话结束了，但是页面没有销毁的case
### Compatibility
- 兼容 `callkit` Android 3.7.2 版本
- 兼容 `callkit` iOS 3.7.1 版本

## [3.7.1] - 2025-10-17
### Changed
- 升级Native SDK
### Fixed
#### iOS specific
- LiveCommunicationKit相关问题
    - 修复收到来电，可能出现的铃声重复播放问题
    - 修复首次安装后，直接退后台，收到来电接听后，此时接听按钮不显示的问题
- 修复快速双击接听按钮，实际通话会建立，但通话界面消失的问题
### Compatibility
- 兼容 `callkit` Android 3.7.2 版本
- 兼容 `callkit` iOS 3.7.1 版本

## 3.6.2+2
### Changed
- 多语言优化
### Fixed
- 修复了修复只调用setupEngine情况下，无法展示被呼叫页面的case

## 3.6.2+1
### Added
- 不再依赖permission_handler

## 3.6.2
### Added
- 删除多余的toast
- 添加和优化权限提醒
- Android 支持前台服务
- iOS 支持LiveCommunicationKit 接听功能


## 3.6.0
### Added
- 首次发布.