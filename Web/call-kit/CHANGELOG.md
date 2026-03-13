## v2.1.3(2023-12-01)

### Bug Fixes

- **call-kit:** 修复多端情况下,邀请比拒绝后到的问题

## v2.1.2(2023-09-06)

**Note:** Version bump only for package @xkit-yx/call-kit

## v2.1.1(2023-08-11)

**Note:** Version bump only for package @xkit-yx/call-kit

## v2.1.0(2023-08-08)

### NEW Features

- **call-kit:** 🎸 2.1.0

## v2.0.3(2023-08-08)

**Note:** Version bump only for package @xkit-yx/call-kit

## v2.0.2(2023-08-07)

**Note:** Version bump only for package @xkit-yx/call-kit

## v2.0.1(2023-06-15)

**Note:** Version bump only for package @xkit-yx/call-kit

## v2.0.0(2023-06-01)

### NEW Features

- **call-kit:** 🎸 各端接口对齐

### Compatibility

- **call-kit:** ⚙️ Compatible with `NIM` version `9.6.1`
- **call-kit:** ⚙️ Compatible with `NERTC` version `4.6.25`

## v1.9.4(2023-05-08)

**Note:** Version bump only for package @xkit-yx/call-kit

## v1.9.3(2023-03-21)

**Note:** Version bump only for package @xkit-yx/call-kit

## v1.9.2(2023-02-10)

**Note:** Version bump only for package @xkit-yx/call-kit

## v1.9.1(2023-02-08)

**Note:** Version bump only for package @xkit-yx/call-kit

## v1.9.0(2023-01-17)

### NEW Features

- **im-flutter-kit:** 🎸 update

## v1.8.4(2022-12-27)

### Bug Fixes

- **im-kit-react-ui:** 🐛 fix reexported type

## v1.8.3(2022-12-23)

**Note:** Version bump only for package @xkit-yx/call-kit

## v1.8.2(2022-12-13)

### NEW Features

- **call-kit:** 🎸 对齐 RTC SDK 版本为 4.6.25

## v1.8.1(2022-11-15)

**Note:** Version bump only for package @xkit-yx/call-kit

## v1.8.0(2022-11-01)

### NEW Features

- **call-kit:** 🎸 群呼增加自定义推送
- **call-kit:** 🎸 主叫加入 RTC 房间时机配置，被叫接收后加入（默认）或呼叫后加入
- **call-kit:** 🎸 额外通话结束信息，exReason：附加原因 0：取消 1：被取消 2：拒绝 3：被拒绝 4：挂断 5：被挂断

### Bug Fixes

- **call-kit:** 🐛 额外 exraInfo 信息兼容
- **call-kit:** 🐛 修复 im 重连后，信令离线消息不处理的问题

### Compatibility

- **call-kit:** ⚙️ Compatible with `NIM` version `9.6.1`
- **call-kit:** ⚙️ Compatible with `NERTC` version `4.6.203`

## v1.7.1(2022-09-28)

### NEW Features

- **call-kit:** 🎸 增加大小窗口切换
- **call-kit:** 🎸 主叫发起视频呼叫，可以预览自己的视频

### Bug Fixes

- **call-kit:** 🐛 修复邀请事件中无法自动接听的问题

### Compatibility

- **call-kit:** ⚙️ Compatible with `NIM` version `9.5.0`
- **call-kit:** ⚙️ Compatible with `NERTC` version `4.6.203`

## v1.7.0(2022-09-16)

### NEW Features

- **call-kit:** 🎸 群组邀请监听事件调整，现在需要传入对应的内容字符串
- **call-kit:** 🎸 新增信令与 RTC 快呼叫能力
- **call-kit:** 🎸 rtc 层面新增 getChannelInfo 获取 cid 等信息

### Bug Fixes

- **call-kit:** 🐛 处理被叫接听失败的情况，如：被叫断网，由被叫定时器处理超时
- **call-kit:** 🐛 修复断网重连，或切换网络导致通话中断的问题
- **call-kit:** 🐛 fix uuid 依赖问题

### Compatibility

- **call-kit:** ⚙️ Compatible with `NIM` version `9.5.0`
- **call-kit:** ⚙️ Compatible with `NERTC` version `4.6.203`

## v1.6.5(2022-09-13)

### Bug Fixes

- **call-kit:** 🐛 增加 eventTracking 配置

## v1.6.4(2022-09-06)

**Note:** Version bump only for package @xkit-yx/call-kit

## v1.6.3(2022-08-31)

### Bug Fixes

- **call-kit:** 🐛 EventTracking cost time userAccId

## v1.6.2(2022-08-24)

### Bug Fixes

- **call-kit-react-ui:** 🐛 fix demo 话单页面页面渲染问题
- **call-kit:** 🐛 增加切换确认
- **call-kit:** 🐛 fix 话单逻辑

## v1.6.1(2022-08-19)

### Bug Fixes

- **call-kit-react-ui:** 🐛 群组呼叫，第三方直接加入，rtc 增加私有化配置
- **meeting-web-react-ui:** 🐛 storybook 引入方式

# 1.6.0 (2022-08-16)

### Bug Fixes

- **call-kit:** 🐛 1v1 话单
- **call-kit:** 🐛 本端镜像与移动端保持一致
- **call-kit:** 🐛 单呼，反复呼叫，被呼者丢失邀请页面的问题
- **call-kit:** 🐛 断网超时
- **call-kit:** 🐛 兼容移动端 添加 muteLocalVideo
- **call-kit:** 🐛 解决移动拖动导致按钮点不了的问题
- **call-kit:** 🐛 群聊 1v1 占线问题
- **call-kit:** 🐛 修复 7104 7097 7099 7091 bug
- **call-kit:** 🐛 修复 1v1 断网问题
- **call-kit:** 🐛 修复 1v1 多端问题，跟增加群呼查询接口
- **call-kit:** 🐛 修复单聊加入视频
- **call-kit:** 🐛 修复邀请问题
- **call-kit:** 🐛 action status
- **call-kit:** 🐛 core kit 依赖
- **call-kit:** 🐛 demo 登录后更新 im 账号，音视频控制
- **call-kit:** 🐛 demo 设备权限校验
- **call-kit:** 🐛 demo 通话时长显示小时
- **call-kit:** 🐛 demo 通话中 操作按钮 与 通话时间
- **call-kit:** 🐛 fix 1v1 切换通话语音与视频重新打开
- **call-kit:** 🐛 fix 多端与断网问题
- **call-kit:** 🐛 fix 群呼 demo ui 问题
- **call-kit:** 🐛 fix im 多订阅问题
- **call-kit:** 🐛 rtc 播放问题
- **chat-kit-react-ui:** 🐛 文件删除
- **search-kit-react-ui:** 🐛 升级 log 库,补充 search-kit 缺失的样式
- **search-kit-react-ui:** 🐛 修复 ts 报错
- **workspace:** 🐛 解决幽灵依赖和无用依赖

### NEW Features

- **call-kit:** 🎸 登录接入
- **call-kit:** 🎸 呼叫成功率 RTC 接通率 埋点
- **call-kit:** 🎸 群组呼叫提测
- **call-kit:** 🎸 占线 : 601 to reason 3
- **call-kit:** 🎸 call demo 呼叫
- **call-kit:** 🎸 demo ， 视频切换语音
- **call-kit:** 🎸 demo 接入登录，搜索用户
- **call-kit:** 🎸 global_extra and error reason
- **call-kit:** 🎸 release 1.5.5
- init
- login-ui-kit 迁移
- sdk 外面注入

## v1.5.8(2022-06-30)

**Note:** Version bump only for package @xkit-yx/call-kit

## v1.5.7(2022-06-30)

### Bug Fixes

- **search-kit-react-ui:** 🐛 升级 log 库,补充 search-kit 缺失的样式
