## 4.7.5（2026-06-25）

本插件为 uni-app-x UTS 接口层插件，仅提供 CallEngine，不包含 UI 组件。

### 新增接口

* `setup` 新增参数：
  * `enableIncomingBanner` — 初始化时开启来电横幅模式
  * `enableAutoFloatingWindowWhenHome` — 退后台自动悬浮窗/PiP
* `isFloatWindowVisible()` — 获取悬浮窗可见状态
* `setIncomingBannerEnabled(enable)` — 开启/关闭来电横幅
* `showIncomingBanner(caller, mediaType)` / `cancelIncomingBanner()` — 显示/取消来电横幅
* `setSwitchCallTypeConfirm(audioToVideo, videoToAudio)` — 配置音视频切换确认弹窗
* `setAutoFloatingWindowWhenHomeEnabled(enable)` — 退后台自动悬浮窗开关
* Android 独有：`startPictureInPicture(options)` — 启动画中画

### Compatibility
* 兼容 Android `CallKit` 4.7.5 版本
* 兼容 iOS `CallKit` 4.7.5 版本

## 4.0.0（2025-12-08）
UTS 版本首次发布，支持 1v1 音视频通话
