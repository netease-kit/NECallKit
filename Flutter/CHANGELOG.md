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