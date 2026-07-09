## [4.8.1] - 2026-07-08
### New Features
* UTS-iOS 接入 iOS 既有 LiveCommunicationKit 系统来电横幅能力，支持在后台、锁屏、杀进程拉起场景通过系统横幅接听或拒绝来电。
* UTS-iOS 新增 LiveCommunicationKit 配置：
  * `init({ liveCommunicationKitConfig: { enabled: true, ringtoneName: 'xxx.mp3' } })`：初始化时开启系统来电横幅能力并设置铃声文件名，需在 native 登录成功后生效；`ringtoneName` 可选，铃声文件需放在 App bundle 中。

### Compatibility
* 兼容 Android `CallKit` 4.8.0 版本，Android 行为无变更。
* 兼容 iOS `CallKit` 4.8.1 版本。

## 4.7.5（2026-06-18）
## [4.7.5] - 2026-06-15
### New Features
* 新增来电横幅能力：Android 和 iOS 支持在屏幕顶部展示来电横幅，用户可直接接听或拒绝，无需打开全屏来电界面。
* 新增来电横幅开关：
  * `init({ enableIncomingBanner: true })`：初始化时开启来电横幅模式。
  * `uni.$NECallKit.enableIncomingBanner(enable)`：运行时开启或关闭来电横幅。
* 新增通话中音视频切换能力：
  * `uni.$NECallKit.switchAudioToVideo()`：语音通话中发起切换为视频通话。
  * `uni.$NECallKit.switchVideoToAudio()`：视频通话中发起切换为语音通话。
  * `uni.$NECallKit.setSwitchCallTypeConfirm(audioToVideoConfirm, videoToAudioConfirm)`：配置语音转视频、视频转语音时是否展示确认弹窗。
* Android 新增通话中悬浮窗能力：
  * `uni.$NECallKit.startFloatWindow()`：通话中开启小窗。
  * `uni.$NECallKit.stopFloatWindow()`：关闭小窗并返回通话页。
* iOS 新增退后台自动画中画配置：
  * `init({ enableAutoFloatingWindowWhenHome: true })`：视频通话退后台时自动启动系统画中画。使用前需在 Xcode 工程开启 Background Modes -> Picture in Picture。
## [4.7.5] - 2026-06-15
### New Features
* 新增来电横幅能力：Android 和 iOS 支持在屏幕顶部展示来电横幅，用户可直接接听或拒绝，无需打开全屏来电界面。
* 新增来电横幅开关：
  * `init({ enableIncomingBanner: true })`：初始化时开启来电横幅模式。
  * `uni.$NECallKit.enableIncomingBanner(enable)`：运行时开启或关闭来电横幅。
* 新增通话中音视频切换能力：
  * `uni.$NECallKit.switchAudioToVideo()`：语音通话中发起切换为视频通话。
  * `uni.$NECallKit.switchVideoToAudio()`：视频通话中发起切换为语音通话。
  * `uni.$NECallKit.setSwitchCallTypeConfirm(audioToVideoConfirm, videoToAudioConfirm)`：配置语音转视频、视频转语音时是否展示确认弹窗。
* Android 新增通话中悬浮窗能力：
  * `uni.$NECallKit.startFloatWindow()`：通话中开启小窗。
  * `uni.$NECallKit.stopFloatWindow()`：关闭小窗并返回通话页。
* iOS 新增退后台自动画中画配置：
  * `init({ enableAutoFloatingWindowWhenHome: true })`：视频通话退后台时自动启动系统画中画。使用前需在 Xcode 工程开启 Background Modes -> Picture in Picture。

### Compatibility
* 兼容 Android `CallKit` 4.7.5 版本
* 兼容 iOS `CallKit` 4.7.5 版本

## 4.0.0（2025-12-08）
UTS版本首次发布，支持1V1音视频通话
