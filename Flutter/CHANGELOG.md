## [4.5.0+2] - 2026-04-24
### Fixed
- 修复 Windows 平台下 `callkit_ui` 缺少 `runtimeobject` 链接导致构建失败的问题。

### Compatibility
- Compatible with `callkit` Flutter 4.5.0+2

## [4.5.0+1] - 2026-04-24
### Changed
- 对齐 `callkit` Flutter 4.5.0+1 热修版本。

### Compatibility
- Compatible with `callkit` Flutter 4.5.0+1

## [4.5.0] - 2026-04-23
### Added
- 支持 Flutter 桌面端（macOS / Windows）接入。

### Compatibility
- Compatible with `callkit` Flutter 4.5.0

## [4.4.5-beta.1] - 2026-04-21
### Changed
- 发布测试。

## [4.4.3] - 2026-04-08
### Added
- 适配 `callkit` Flutter 4.4.3，支持 iOS LiveCommunicationKit `accept` / `hangup` response 回调上抛到 Flutter 层。
- 示例工程补充了对应回调的浮层提示展示，便于验证系统来电界面的接听与拒绝反馈链路。

### Compatibility
- Compatible with `callkit` Flutter 4.4.3

## [4.4.0] - 2026-04-01
### Added
- 新增群呼（多人音视频通话）功能
  - `groupCall` 发起群呼，选择多个联系人（最多 10 人）一键呼叫
  - `groupJoin` 主动加入已存在的群呼
  - `setGroupInviteHandler` 设置通话中邀请新成员的回调
  - 支持被叫接听或拒绝来电邀请
  - 多人视频画面以宫格形式展示，支持点击放大
  - 音视频控制：麦克风开关、摄像头开关、扬声器切换
  - 主叫端显示成员拒绝/占线/超时等状态提示

### Compatibility
- 兼容 `callkit` Flutter 4.3.0

## [4.3.0] - 2026-03-17
### Added
- Added incoming call banner feature: displays a compact banner at the top of the screen when a call arrives, allowing users to accept or reject without leaving the current interface.
- Added `enableIncomingBanner` API to enable/disable banner mode.

### Compatibility
- Compatible with `callkit` Flutter 4.3.0

## [4.1.0+3] - 2026-01-04
### Fix
- modify readme

### Compatibility
- Compatible with `callkit` Flutter 4.1.0

## [4.1.0+2] - 2025-12-31
### Fix
- `flutter analyze` issues

### Compatibility
- Compatible with `callkit` Flutter 4.1.0

## [4.1.0+1] - 2025-12-22
### Fix
- `flutter analyze` issues
- No longer internally dependent on common-ui

### Compatibility
- Compatible with `callkit` Flutter 4.1.0


## [4.1.0] - 2025-12-19
### Added
- Added AI subtitles during calls

### Compatibility
- Compatible with `callkit` Flutter 4.1.0

## [3.8.1-beta.1] - 2025-12-09
### Fixed
- On Android, `onCallConnected` now returns RTC info in `NECallInfo`
### Compatibility
- Compatible with `callkit` Android 3.8.0
- Compatible with `callkit` iOS 3.8.0

## [3.8.1-beta.0] - 2025-11-06
### Added
- Added support for displaying subtitles
### Compatibility
- Compatible with `callkit` Android 3.8.0
- Compatible with `callkit` iOS 3.8.0

## [3.8.1+5] - 2025-12-03
### Fix
- `flutter analyze` issues

### Compatibility
- Compatible with `callkit` Android 3.8.0
- Compatible with `callkit` iOS 3.8.0

## [3.8.1+4] - 2025-12-03
### Changed
- Upgraded `common` and `common_ui`, and stopped pinning a specific `intl` version

### Compatibility
- Compatible with `callkit` Android 3.8.0
- Compatible with `callkit` iOS 3.8.0

## [3.8.1+3] - 2025-12-03
### Changed
- Set Flutter version constraint to ">=2.5.0"
- Changed `intl` constraint to "intl: any" (no specific version)

### Compatibility
- Compatible with `callkit` Android 3.8.0
- Compatible with `callkit` iOS 3.8.0

## [3.8.1+2] - 2025-12-03
### Changed
- Set Flutter version constraint to ">=2.5.0 <= 3.22.3"

### Compatibility
- Compatible with `callkit` Android 3.8.0
- Compatible with `callkit` iOS 3.8.0

## [3.8.1+1] - 2025-12-03
### Fix
- `flutter analyze` issues

### Compatibility
- Compatible with `callkit` Android 3.8.0
- Compatible with `callkit` iOS 3.8.0

## [3.8.1] - 2025-12-03
### Changed
- Upgraded `callkit`
### Fix
- `flutter analyze` issues

### Compatibility
- Compatible with `callkit` Android 3.8.0
- Compatible with `callkit` iOS 3.8.0

## [3.8.0+1] - 2025-11-06
### Changed
- Aligned with native SDK version
### Compatibility
- Compatible with `callkit` Android 3.8.0
- Compatible with `callkit` iOS 3.8.0

## [3.8.0] - 2025-11-06
### Added
- Added support for showing a floating window when the app is in the background (controlled by `NECallKitUI.instance.enableFloatWindowOutOfApp(bool enable)`)
- Added toast notifications on other logged-in devices when a call is answered on one device
### Fixed
- Optimized black screen issues when switching between large and small video views during a call
- Fixed an issue on some devices (e.g. Xiaomi Mix 3) where tapping the floating window in a call outside the app could not bring the call page to the foreground
### Compatibility
- Compatible with `callkit` Android 3.8.0
- Compatible with `callkit` iOS 3.8.0

## [3.7.1+3] - 2025-10-21
### Added
- Added toast notifications on other logged-in devices when a call is answered on one device
### Compatibility
- Compatible with `callkit` Android 3.7.2
- Compatible with `callkit` iOS 3.7.1

## [3.7.1+2] - 2025-10-20
### Changed
- Upgraded native SDK
### Compatibility
- Compatible with `callkit` Android 3.7.2
- Compatible with `callkit` iOS 3.7.1

## [3.7.1+1] - 2025-10-17
### Fixed
- Prevented rare cases where an unknown call end event occurred but the call page was not destroyed
### Compatibility
- Compatible with `callkit` Android 3.7.2
- Compatible with `callkit` iOS 3.7.1

## [3.7.1] - 2025-10-17
### Changed
- Upgraded native SDK
### Fixed
#### iOS specific
- LiveCommunicationKit-related issues
    - Fixed an issue where the ringtone might play repeatedly when receiving a call
    - Fixed an issue where, after a fresh install followed by immediately going to the background, the answer button might not appear when receiving and answering a call
- Fixed an issue where double-tapping the answer button quickly would establish the call but close the call UI
### Compatibility
- Compatible with `callkit` Android 3.7.2
- Compatible with `callkit` iOS 3.7.1

## 3.6.2+2
### Changed
- Improved multi-language support
### Fixed
- Fixed an issue where the incoming call page could not be shown when only `setupEngine` was called

## 3.6.2+1
### Added
- Removed dependency on `permission_handler`

## 3.6.2
### Added
- Removed redundant toast messages
- Added and optimized permission prompts
- Added foreground service support on Android
- Added LiveCommunicationKit answering support on iOS


## 3.6.0
### Added
- Initial release.
