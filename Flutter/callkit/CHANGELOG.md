## [4.5.0] - 2026-04-23
### Added
- 支持 Flutter 桌面端（macOS / Windows）接入。

### Compatibility
- 兼容 `callkit` Android 4.4.0 版本
- 兼容 `callkit` iOS 4.4.3 版本

## [4.4.5-beta.1] - 2026-04-21
### Changed
- 发布测试。

## [4.4.3] - 2026-04-08
### Added
- iOS 新增 LiveCommunicationKit `accept` / `hangup` response 回调透传能力，Flutter 业务层可监听系统来电界面的接听与拒绝结果。
- Flutter 新增 `NECallEngineDelegate.onLCKAccept` 与 `NECallEngineDelegate.onLCKHangup` 回调，以及对应结果模型，便于业务做状态推进、埋点与排障。

### Compatibility
- 兼容 `callkit` Android 4.4.0 版本
- 兼容 `callkit` iOS 4.4.3 版本

## [4.4.0] - 2026-04-01
### Added
- 新增群呼功能（`NEGroupCallEngine`）
  - 群呼基础操作：发起（`groupCall`）、接听（`groupAccept`）、拒绝/挂断（`groupHangup`）、邀请（`groupInvite`）、加入（`groupJoin`）
  - 群呼信息查询：查询群呼信息（`groupQueryCallInfo`）、查询成员列表（`groupQueryMembers`）
  - 媒体控制：音视频开关、扬声器切换、摄像头切换、音量回调
  - 事件回调：来电邀请、成员变更、通话结束、被踢出等

## [4.3.0] - 2026-03-17
### Added
- 新增来电横幅功能：收到来电时在屏幕顶部展示来电横幅，支持接听和拒绝操作。
- 新增 `enableIncomingBanner` 接口，用于开启或关闭来电横幅模式。

### Compatibility
- 兼容 `callkit` Android 4.3.0 版本
- 兼容 `callkit` iOS 4.3.0 版本

## [4.1.0] - 2025-12-19
### Added
- 支持通话中AI字幕功能，通过`NECallEngine.startASRCaption`开启字幕，通过`NECallEngine.stopASRCaption`关闭字幕。
- 新增方法`NECallEngine.getUserWithRtcUid(long uid)`，用来根据rtcUid获取用户信息。
- 新增方法`NECallEngine.setCallRecordProvider`，用来自定义话单信息。


### Changed
- 修改方法`NECallEngine.call(...)`返回值为`Future<NEResult<NECallInfo>>`，呼叫结果中可以获取呼叫信息
- 修改方法`NECallEngine.accept(...)`返回值为`Future<NEResult<NECallInfo>>`，接听结果中可以获取呼叫信息
- 修改方法`NECallEngine.hangup(...)`参数中的`channelId`为可选
- 删除 NECallEngineDelegate.onRecordSend` 回调，使用 NECallEngine.setCallRecordProvider 代替。

### Compatibility
- 兼容 `callkit` Android 4.1.0 版本
- 兼容 `callkit` iOS 4.1.0 版本

## [3.8.1-beta.2] - 2025-12-09
### Fixed
- iOS指定底层呼叫组件版本
### Compatibility
- 兼容 `callkit` Android 3.8.0 版本
- 兼容 `callkit` iOS 3.8.0 版本

## [3.8.1-beta.1] - 2025-12-09
### Fixed
- Android的onCallConnected的NECallInfo中返回 RTC Info
### Compatibility
- 兼容 `callkit` Android 3.8.0 版本
- 兼容 `callkit` iOS 3.8.0 版本

## [3.8.1+3] - 2025-12-03
### Changed
- 修改flutter的最低支持版本为2.5.0

### Compatibility
- 兼容 `callkit` Android 3.8.0 版本
- 兼容 `callkit` iOS 3.8.0 版本

## [3.8.1+2] - 2025-12-03
### Fix
- flutter analyze

### Compatibility
- 兼容 `callkit` Android 3.8.0 版本
- 兼容 `callkit` iOS 3.8.0 版本

## [3.8.1+1] - 2025-12-02
### Changed
- 文档修改

### Compatibility
- 兼容 `callkit` Android 3.8.0 版本
- 兼容 `callkit` iOS 3.8.0 版本

## [3.8.1] - 2025-11-25
### Changed
#### iOS specific
- callkit 组件（非UI），pod NERtcSDK, 取消使用指定版本依赖

### Compatibility
- 兼容 `callkit` Android 3.8.0 版本
- 兼容 `callkit` iOS 3.8.0 版本

## [3.8.1-beta.0] - 2025-11-06
### Added
- 支持展示字幕
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

## [3.7.1+1] - 2025-10-20
### Changed
- 升级Native SDK
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

## 3.6.2
### Added
- iOS 支持 LiveCommunicationKit 接听功能

## 3.6.0
### Added
- 首次发布
