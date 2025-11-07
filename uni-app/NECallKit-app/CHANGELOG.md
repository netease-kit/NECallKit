## Changelog
## [3.8.0] - 2025-11-06
### New Features
* Uniapp 群呼支持自定义rtcChannelName
* Uniapp 支持推送配置
* Uniapp 支持ai降噪开关

### Bug Fixes
* 更新相关 framework，修复 iOS 可能出现的上架问题

### Compatibility
* 兼容 Android `CallKit` 3.8.0 版本
* 兼容 iOS`CallKit` 3.8.0 版本

## [3.7.0] - 2025-09-26
### New Features
* 支持1对1呼叫小窗拖拽
* 支持10人群呼
### Compatibility
* 兼容 Android `CallKit` 3.7.0 版本
* 兼容 iOS`CallKit` 3.7.0 版本

## 2.6.0(Jan 17, 2025)
### New Features
* 支持通话过程中，语音转视频增加询问弹
* 升级Android 呼叫组件，适配Target API 34
* 升级iOS 呼叫组件，适配iOS18上maskView冲突导致的crash问题
### Bug Fixes
* 修复首次呼叫的账号昵称没获取到无法展示的问题
### Compatibility
* 兼容 Android `CallKit` 2.6.0 版本
* 兼容 iOS`CallKit` 2.5.2 版本

## 2.4.5(Jan 2, 2025)
### Bug Fixes
* 修复iOS上全局监听不生效的问题
* 修复Android上昵称展示不对的问题
### Compatibility
* 兼容 Android `CallKit` 2.4.1 版本
* 兼容 iOS`CallKit` 2.4.0 版本

## 2.4.4(Dec 20, 2024)
### New Features
* 关闭Android默认的自启动

### Compatibility
* 兼容 `CallKit` 2.4.1 版本

## 2.4.3(Nov 01, 2024)
### New Features
* 支持外部传递rtc channel name和rtc uid

### Compatibility
* 兼容 `CallKit` 2.4.0 版本

## v2.4.2(June 19, 2024)
### New Features
* 修复了偶现铃声从听筒出来的问题
* 增加CallIdShowName功能

### Compatibility
* 兼容 `CallKit` 2.4.0 版本

## v2.4.1(June 7, 2024)
### New Features
* 支持通话状态通知

### Compatibility
* 兼容 `CallKit` 2.4.0 版本

## v2.4.0(May 26, 2024)
### New Features
* 支持配置隐藏和开启“音视频通话转换”功能：initConfig的入参里面添加enableAudio2Video、enableVideo2Audio功能
* toCallPage添加回调，支持呼叫成功或者失败的回调

### Compatibility
* 兼容 `CallKit` 2.4.0 版本

## v1.7.0(April 26, 2024)
### New Features
* 支持悬浮窗、退到后台自动显示悬浮窗、前台服务设置

## v1.6.0(March 28, 2024)
### New Features
* 添加平台、渠道埋点（Corekit支持平台、渠道埋点） 
* 支持中英文语言切换
* 支持切换中英文呼叫铃声

