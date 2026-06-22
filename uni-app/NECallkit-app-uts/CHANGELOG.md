## Changelog
## [4.7.5] - 2026-06-15
### New Features
* 新增来电横幅功能：iOS 和 Android 均支持在屏幕顶部以横幅形式展示来电，可直接接听或拒绝，无需打开全屏来电界面。
* 新增 `enableIncomingBanner` 接口，用于开启或关闭来电横幅模式。
* 新增音视频通话切换确认能力，支持通话中语音转视频、视频转语音时展示确认弹窗。
* Android 支持通话中悬浮窗能力，支持小窗展示和返回通话页。
* iOS 支持 `enableAutoFloatingWindowWhenHome`，开启后视频通话退后台自动启动系统画中画（需在 Xcode 工程配置 Background Modes → Picture in Picture）。


### Compatibility
* 兼容 Android `CallKit` 4.7.5 版本
* 兼容 iOS `CallKit` 4.7.5 版本
