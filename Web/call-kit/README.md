# 网易云信 呼叫组件 API

基于云信 NIM V10 SDK（`nim-web-sdk-ng`）封装的一对一音视频呼叫组件，支持 Web 端和微信小程序端。

## 安装

```bash
npm install @xkit-yx/call-kit
# or
yarn add @xkit-yx/call-kit
```

---

## Web 端（单呼）

### 初始化

```typescript
import NIM from 'nim-web-sdk-ng'
import { NECall } from '@xkit-yx/call-kit'

const nim = NIM.getInstance({
  appkey: 'your_appkey',
  apiVersion: 'v2',
  debugLevel: 'debug',
})
await nim.V2NIMLoginService.login('accountId', 'token')

// 使用单例模式获取实例
const neCall = NECall.getInstance()
neCall.setup({
  nim,           // NIM V10 实例
  appkey: 'your_appkey',
  debug: true,
})
```

#### `setup` 参数说明

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `nim` | `V2NIM` | 必填 | NIM V10 实例 |
| `appkey` | `string` | 必填 | 应用 AppKey |
| `rtcContext` | `RTCConfig` | - | RTC 私有化配置 |
| `enableRecord` | `boolean` | `true` | 是否开启话单 |
| `enableAutoJoinSignalChannel` | `boolean` | `false` | 被叫是否自动加入信令频道 |
| `enableJoinRtcWhenCall` | `boolean` | `false` | 主叫发起呼叫时是否提前加入 RTC |
| `debug` | `boolean` | `false` | 是否打印日志 |

---

### 主叫方

```typescript
// 发起呼叫
await neCall.call({
  accId: 'calleeAccId',  // 被叫 accountId
  callType: '2',          // '1': 音频, '2': 视频
})

// 设置本地/远端视频视图（仅 Web 端）
const localView = document.getElementById('localView')
const remoteView = document.getElementById('remoteView')
neCall.setLocalView(localView)
neCall.setRemoteView(remoteView, 'calleeAccId')

// 取消呼叫
await neCall.hangup()
```

---

### 被叫方

```typescript
// 监听来电邀请
neCall.on('onReceiveInvited', (info) => {
  // info.callerAccId: 主叫 accountId
  // info.callType: '1' | '2'
  // info.channelId: 信令频道 id（挂断时使用）
  // info.extraInfo: 扩展信息（透传）
  console.log('来电:', info)
})

// 接听
await neCall.accept()

// 拒绝
await neCall.hangup()
```

---

### 通话中（主叫 & 被叫）

```typescript
// 通话建立成功
neCall.on('onCallConnected', (callInfo) => {
  console.log('通话已建立', callInfo)
})

// 开关本地视频
await neCall.enableLocalVideo(true)   // 开启
await neCall.enableLocalVideo(false)  // 关闭

// 开关本地音频
await neCall.enableLocalAudio(true)   // 开启
await neCall.enableLocalAudio(false)  // 关闭（静音）

// 切换通话类型（音频 ↔ 视频）
await neCall.switchCallType({ callType: '1', state: 1 }) // 发起切换请求
// state: 1=邀请, 2=同意, 3=拒绝

// 监听对端切换通话类型
neCall.on('onCallTypeChange', ({ callType, state }) => {
  // callType: '1' | '2'
  // state: 1=邀请, 2=同意, 3=拒绝
})

// 挂断
await neCall.hangup()
```

---

### 通话结束

```typescript
neCall.on('onCallEnd', ({ reasonCode, extraString }) => {
  // reasonCode 含义：
  // 2  - 呼叫超时（自动挂断）
  // 3  - 对方正在通话中（占线）
  // 11 - 本地主动取消呼叫
  // 12 - 对端主动取消呼叫
  // 13 - 本地主动拒绝
  // 14 - 对端主动拒绝
  // 15 - 本地主动挂断
  // 16 - 对端挂断 / RTC 房间关闭
  // 17 - 多端登录：其他端已拒绝
  // 18 - 多端登录：其他端已接听
  // 20 - 对端 RTC 断开（网络异常）
})

// 话单发送回调（通话结束时组件自动发送话单消息给对端）
neCall.on('onRecordSend', (record) => {
  // 可在此更新本端通话记录 UI
  console.log('话单已发送', record)
})
```

---

### 其他方法

```typescript
// 设置呼叫超时（秒）
neCall.setTimeout(30)

// 动态配置
neCall.setCallConfig({
  enableOffline: true,              // 是否支持离线推送
  enableSwitchVideoConfirm: false,  // 切换视频是否需要对端确认
  enableSwitchAudioConfirm: false,  // 切换音频是否需要对端确认
  enableJoinRtcWhenCall: false,     // 主叫是否提前加入 RTC
})

// 获取当前配置
const config = neCall.getCallConfig()

// 获取通话信息（通话中有效）
const callInfo = neCall.getCallInfo()
// callInfo.callStatus: 0=闲置 1=呼叫中 2=被叫中 3=通话中
// callInfo.callType: 1=音频 2=视频
// callInfo.callerInfo / calleeInfo: { accId, uid }

// IM 断线重连后调用（触发离线消息重新拉取）
neCall.reconnect()

// 销毁实例（退出登录时调用）
neCall.destroy()
```

---

## 微信小程序端

小程序端使用独立构建产物，通过 `live-pusher`（本地推流）和 `live-player`（远端拉流）实现音视频通话。

### 初始化

```typescript
// App.vue / app.js
import V2NIM from 'nim-web-sdk-ng/dist/v2/NIM_MINIAPP_SDK'
import { NECall } from '@xkit-yx/call-kit/miniprogram_dist/index'

const nim = V2NIM.getInstance({
  appkey: 'your_appkey',
  apiVersion: 'v2',
  debugLevel: 'debug',
})
await nim.V2NIMLoginService.login(accountId, token)

const neCall = NECall.getInstance()
neCall.setup({
  nim,
  appkey: 'your_appkey',
  debug: true,
})

// 监听来电（建议在 App 全局注册，防止重复注册）
neCall.off('onReceiveInvited')
neCall.on('onReceiveInvited', () => {
  const pages = getCurrentPages()
  const isOnCallPage = pages.some((p) => p.route === 'pages/call/call')
  if (!isOnCallPage) {
    wx.navigateTo({ url: '/pages/call/call' })
  }
})
```

### 小程序端特有事件

| 事件 | 回调参数 | 说明 |
|------|----------|------|
| `onStreamPublish` | `url: string` | 本地推流地址（赋值给 `live-pusher` 的 `url`） |
| `onStreamSubscribed` | `url: string` | 远端拉流地址（赋值给 `live-player` 的 `src`） |
| `onVideoMuteOrUnmute` | `mute: boolean` | 对端关闭/开启摄像头 |

### live-player mode 适配（鸿蒙系统）

鸿蒙系统的 `live-player` 需要使用 `'live'` 模式，其他平台使用 `'RTC'`：

```javascript
function getPlayerMode() {
  try {
    const info = wx.getDeviceInfo ? wx.getDeviceInfo() : wx.getSystemInfoSync()
    const platform = (info.platform || '').toLowerCase()
    const system = (info.system || '').toLowerCase()
    if (platform.includes('ohos') || system.includes('harmonyos')) {
      return 'live'
    }
  } catch (e) {}
  return 'RTC'
}
```

---

## 事件列表（完整）

| 事件名 | 回调参数 | 适用平台 | 说明 |
|--------|----------|----------|------|
| `onReceiveInvited` | `NEInviteInfo` | Web / 小程序 | 收到来电邀请 |
| `onCallConnected` | `NECallInfo \| undefined` | Web / 小程序 | 通话建立成功 |
| `onCallEnd` | `NECallEndInfo` | Web / 小程序 | 通话结束 |
| `onCallTypeChange` | `NECallTypeChangeInfo` | Web / 小程序 | 通话类型切换 |
| `onRecordSend` | `SignalControllerCallRecord` | Web / 小程序 | 话单发送完成 |
| `onStreamPublish` | `url: string` | 小程序 | 本地推流地址就绪 |
| `onStreamSubscribed` | `url: string` | 小程序 | 远端拉流地址就绪 |
| `onVideoMuteOrUnmute` | `mute: boolean` | 小程序 | 对端摄像头开关变化 |

### `onCallEnd` reasonCode 含义

| code | 说明 |
|------|------|
| 2 | 呼叫超时，自动挂断 |
| 3 | 对方正在通话中（占线） |
| 11 | 本地主动取消呼叫 |
| 12 | 对端主动取消呼叫 |
| 13 | 本地主动拒绝 |
| 14 | 对端主动拒绝 |
| 15 | 本地主动挂断 |
| 16 | 对端挂断 / RTC 房间关闭 |
| 17 | 多端登录：其他端已拒绝 |
| 18 | 多端登录：其他端已接听 |
| 20 | 对端 RTC 断开（网络异常） |

---

## 类型定义

```typescript
type NESetupConfig = {
  nim: V2NIM                          // NIM V10 实例
  appkey: string                      // 应用 AppKey
  rtcContext?: RTCConfig              // RTC 私有化配置
  enableRecord?: boolean              // 是否开启话单，默认 true
  enableAutoJoinSignalChannel?: boolean  // 被叫是否自动加入信令，默认 false
  enableJoinRtcWhenCall?: boolean     // 主叫是否提前加入 RTC，默认 false
  debug?: boolean                     // 打印日志，默认 false
}

type NECallParam = {
  accId: string                       // 被叫 accountId
  callType: '1' | '2'                 // '1': 音频, '2': 视频
  extraInfo?: string                  // 透传到被叫 onReceiveInvited
  rtcChannelName?: string             // 自定义 RTC 频道名
  globalExtraCopy?: string            // 服务端抄送自定义信息
  pushConfig?: SignalControllerPushInfo  // 离线推送配置
}

type NEHangupParam = {
  reason?: number                     // 挂断原因码
  extraString?: string                // 附加信息
  channelId?: string                  // 信令频道 id
  duration?: number                   // 通话时长（秒），用于话单生成
}

type NECallConfig = {
  enableOffline?: boolean             // 支持离线推送，默认 true
  enableSwitchVideoConfirm?: boolean  // 切换视频需对端确认，默认 false
  enableSwitchAudioConfirm?: boolean  // 切换音频需对端确认，默认 false
  enableJoinRtcWhenCall?: boolean     // 主叫提前加入 RTC，默认 false
}

type NEInviteInfo = {
  callerAccId: string                 // 主叫 accountId
  callType: '1' | '2'                 // 通话类型
  extraInfo?: string                  // 透传信息
  channelId: string                   // 信令频道 id
}

type NECallEndInfo = {
  reasonCode: number                  // 结束原因码（见上表）
  extraString?: string                // 附加信息
  message?: string                    // 结束消息
}
```
