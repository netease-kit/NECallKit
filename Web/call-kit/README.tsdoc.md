# 网易云信 呼叫组件

## 单呼

- [NECall](classes/NECall.html)

### 单呼 API

| 实例方法                                                 | 介绍                             |
| -------------------------------------------------------- | -------------------------------- |
| [constructor](classes/NECall.html#constructor)           | 初始化方法                       |
| [call](classes/NECall.html#call)                         | 发起呼叫                         |
| [accept](classes/NECall.html#accept)                     | 接受呼叫                         |
| [hangup](classes/NECall.html#hangup)                     | 取消、拒绝、挂断呼叫             |
| [setLocalView](classes/NECall.html#setLocalView)         | 设置本地视图                     |
| [setRemoteView](classes/NECall.html#setRemoteView)       | 设置远端视图                     |
| [enableLocalAudio](classes/NECall.html#enableLocalAudio) | 开关本地音频                     |
| [enableLocalVideo](classes/NECall.html#enableLocalVideo) | 开关本地视频                     |
| [setTimeout](classes/NECall.html#setTimeout)             | 配置超时取消、拒绝时间           |
| [switchCallType](classes/NECall.html#switchCallType)     | 切换通话方式                     |
| [getUidByAccId](classes/NECall.html#getUidByAccId)       | 通过 im accid 获取对应的 rtc uid |
| [destroy](classes/NECall.html#destroy)                   | 销毁实例，重置状态               |

### 单呼事件

> 通过 `on` 方法订阅事件

| 事件名称         | 值                                                            | 介绍                            |
| ---------------- | ------------------------------------------------------------- | ------------------------------- |
| onReceiveInvited | [NECallInfo](types/NECallInfo.html)                           | 接收到呼叫邀请                  |
| onSwtichCallType | [NESwtichCallTypeEvent](types/NESwtichCallTypeEvent.html)     | 接收到切换呼叫方式              |
| onCallConnected  | --                                                            | 连接建立，对方加入 rtc 房间通知 |
| onCallEnd        | [NECallEndInfo](types/NECallEndInfo.html)                     | 会话结束通知                    |
| onMessageSent    | [SignalControllerMessage](types/SignalControllerMessage.html) | 话单发送通知                    |
