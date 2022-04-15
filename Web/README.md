# 网易云信 呼叫组件 API

## 下载

1. 通过[链接](https://yx-web-nosdn.netease.im/package/1628829743/nertc-calling.zip?download=nertc-calling.zip)下载组件。
2. 将下载后的组件解压，重命名后放入项目中
3. 添加到`eslintignore`或者`prettierignore`等忽略中，如没有可忽略这一步

## 引入

组件提供`es module`、`commonjs`、`umd`三种打包方式，可以根据你项目的情况按需引入其中的一种。若之前已集成 G2 sdk 或者 IM sdk，需要更换引用路径，使用组件提供的 sdk 路径。

**es module:**

```js
import NERTCCalling from 'yourPath';
const rtc = new NERTCCalling({
  debug: true, // 是否需要开启日志，默认开启
});
```

**commonjs:**

```js
const NERTCCalling = require('yourPath');
const rtc = new NERTCCalling({
  debug: true, // 是否需要开启日志，默认开启
});
```

**script 引入**

```html
<script src="/yourPath/assets/sdk/NIM_Web_SDK_v8.3.5.js"></script>
<script src="/yourPath/assets/sdk/NIM_Web_WebRTC2_v4.1.0.js"></script>
<script src="/yourPath/lib/index.umd.js"></script>
<script>
  var NERTCCalling = window.NERTCCalling.default;
  var rtc = new NERTCCalling({
    debug: true, // 是否需要开启日志，默认开启
  });
</script>
```

## 接口说明

```ts
/**
 * 初始化G2，需要在login之前调用，只需调用一次
 * @param options
 */
setupAppKey(options: {
  appKey: string; // G2的appkey
}): void;
/**
 * 登录IM，所有功能先进行登录才能使用
 * 用户若已经在 app 内实现了 IM 登录/登出逻辑，需要使用该方法替换，参数跟以前保持一致
 * @param params
 */
login({ account, token, ...opt }: {
  account: string; // IM的account账号
  token?: string; // IM的token
  [key: string]: any; // 其他IM的getInstance的参数
}): void;
/**
 * 登出IM
 * @param params
 */
logout(params?: {
  success?: () => void; // 成功回调
  failed?: (err: any) => void; // 失败回调
}): Promise<void>;
/**
 * 销毁组件
 */
destroy(): void;
/**
 * 设置TokenService，在call
 * 若 G2 sdk 采用安全模式则加入音视频房间时需要提供对应的 token，详细参考[Token 获取](https://doc.yunxin.163.com/docs/jcyOTA0ODM/TQ0MTI2ODQ?platformId=50002)。
 * 呼叫组件依赖 token，需要在用户在初始化时同时设置 token 服务，此 token 服务为用户服务端自己实现。若 G2 sdk 采用非安全模式，则无需调用该接口。
 * @param cb 获取token的异步函数
 */
setTokenService(cb: (uid: number) => Promise<string>): void;
/**
 * 设置通话参数，在发起呼叫或接受呼叫前调用，如果不需要可以不调用
 * @param params
 */
setCallProfile(params: {
  resolution?: 2 | 4 | 8 | 16; // 视频分辨率，可以参考[G2官方文档](https://doc.yunxin.163.com/docs/jcyOTA0ODM/zUxMDQzOTM?platformId=50082)
  frameRate?: 1 | 2 | 3 | 4 | 5; // 视频帧率，同上
  quality?: // 音频质量，可以参考[G2官方文档](https://doc.yunxin.163.com/docs/jcyOTA0ODM/TA1NDQwODk?platformId=50082)
    | 'speech_low_quality'
    | 'speech_standard'
    | 'music_standard'
    | 'standard_stereo'
    | 'high_quality'
    | 'high_quality_stereo';
  recordConfig?: { // 录制参数，可以参考[G2官方文档](https://dev.yunxin.163.com/docs/interface/NERTC_SDK/Latest/Web/api/interfaces/types.recordconfig.html)
    isHostSpeaker: boolean; // 当前用户是否是主讲人
    recordAudio: boolean; // 是否开启音频实时音录制，false 不需要，true 需要。默认 false。
    recordVideo: boolean; // 是否开启视频实时音录制，false 不需要，true 需要。默认 false。
    recordType: 0 | 1 | 2; // 0 混录+单录；1 混录；2 单录
  };
}): void;
/**
 * 设置呼叫超时时间，在发起呼叫或接受呼叫前调用，如果不需要可以不调用
 * @param t 超时时间，单位ms
 */
setCallTimeout(t: number): void;
/**
 * 设置本端视频播放节点，在发起呼叫或接受呼叫前调用
 * @param view 位于的DOM节点
 */
setupLocalView(view?: HTMLElement): void;
/**
 * 设置远端视频播放节点，在发起呼叫或接受呼叫前调用
 * @param userId IM的account账号
 * @param view 位于的DOM节点
 */
setupRemoteView(userId: string, view?: HTMLElement): void;
/**
 * 注册事件监听
 * @param eventCode
 * @param callback
 */
addDelegate(eventCode: EventCode, callback: (...args: any) => void): void;
/**
 * 移除事件监听
 * @param eventCode
 */
removeDelegate(eventCode: EventCode): void;
/**
 * 发起一对一呼叫
 * @param params
 */
call(params: {
    userId: string; // IM的account账号
    type: CallType; // 呼叫类型 1:音频;2:视频;3:其他
    attachment?: { // 自定义扩展字段
        [key: string]: any;
    };
    success?: () => void; // 成功回调
    failed?: (err: any) => void; // 失败回调
}): Promise<void>;
/**
 * 发起多人呼叫
 * @param params
 */
groupCall(params: {
    userIds: string[]; // IM的account账号
    type: CallType; // 呼叫类型 1:音频;2:视频;3:其他
    groupId?: string; // 群组id，不需要可以不传，后续该字段会废弃并入attachment中
    attachment?: string // 自定义扩展字段
    success?: () => void; // 成功回调
    failed?: (err: any) => void; // 失败回调
}): Promise<void>;
/**
 * 取消呼叫
 * 当发起呼叫成功后，可以调用该接口取消呼叫
 * @param params
 */
cancel(params?: {
  success?: () => void; // 成功回调
  failed?: (err: any) => void; // 失败回调
}): Promise<void>;
/**
 * 接受呼叫
 * 当收到呼叫邀请后，可以调用该接口接受呼叫
 * @param params
 */
accept(params?: {
  success?: () => void; // 成功回调
  failed?: (err: any) => void; // 失败回调
}): Promise<void>;
/**
 * 拒绝呼叫
 * 当收到呼叫邀请后，可以调用该接口拒绝呼叫
 * @param params
 */
reject(params?: {
  success?: () => void; // 成功回调
  failed?: (err: any) => void; // 失败回调
}): Promise<void>;
/**
 * 离开通话
 * 不影响通话中的其他人
 * @param params
 */
leave(params?: {
    channelId?: string;
    success?: () => void; // 成功回调
    failed?: (err: any) => void; // 失败回调
}): Promise<void>;
/**
 * 挂断通话
 * 会关闭该通通话
 * @param params
 */
hangup(params?: {
  success?: () => void; // 成功回调
  failed?: (err: any) => void; // 失败回调
}): Promise<void>;
/**
 * 通话中邀请其他人进入通话
 * 在多人通话发起或者接通后，可以调用该方法继续邀请其他人进入通话
 * @param params
 */
groupInvite(params: {
    userIds: string[]; // IM的account账号
    groupId?: string; // 群组id，不需要可以不传，后续该字段会废弃并入attachment中
    attachment?: { // 自定义扩展字段
        [key: string]: any;
    };
    success?: () => void; // 成功回调
    failed?: (err: any) => void; // 失败回调
}): Promise<void>;
/**
 * 开启/关闭摄像头
 * @param enabled true 打开 false 关闭
 */
enableLocalVideo(enabled: boolean): Promise<void>;
/**
 * 开启/关闭麦克风
 * @param enabled true 打开 false 关闭
 */
enableLocalAudio(enabled: boolean): Promise<void>;
/**
 * 禁用本地视频轨道
 * @param mute true 禁用 false 开启
 */
muteLocalVideo(mute: boolean): Promise<void>;
/**
 * 禁用本地音频轨道
 * @param mute true 禁用 false 开启
 */
muteLocalAudio(mute: boolean): Promise<void>;
/**
 * 切换通话类型
 * @param type // 呼叫类型 1:音频;2:视频;3:其他
 */
switchCallType(type: CallType): Promise<void>;
/**
 * 禁用远端音频轨道
 * @param mute true 禁用 false 开启
 * @param userId IM的account账号
 */
setAudioMute(mute: boolean, userId: string): Promise<void>;
/**
 * 获取设备列表
 */
getDevices(): Promise<{
  audioIn: {
    label: string;
    deviceId: string;
    active?: boolean;
  }[];
  audioOut: {
    label: string;
    deviceId: string;
    active?: boolean;
  }[];
  video: {
    label: string;
    deviceId: string;
    active?: boolean;
  }[];
}>;
/**
 * 切换设备
 * @param type 设备类型 'microphoneId' | 'cameraId' | 'speakerId'
 * @param deviceId 设备id
 */
switchDevice(type: DeviceType, deviceId: string): Promise<void>;
/**
 * 获取房间信息
 */
getRoomInfo(): Promise<{
  channelName: string; // 信令的channelName
  channelId: string; // 信令的channelId，同G2的channelName
  channelCreateTime: string; // 信令房间创建时间
  channelExpireTime: string; // 信令房间过期时间
  creator: string; // 信令房间创建者的IM account账号
  members: {
    uid: number; // G2的uid
    account: string; // IM account账号
    accid?: string; // IM account账号，sdk问题，字段没统一
    createTimestamp?: number;
    expireTimestamp?: number;
  }[]; // 信令房间内的成员信息
  uid?: number; // G2的uid
}>;
/**
 * 获取sdk实例
 */
getSdkInstance(): {
  signal: any; // 信令sdk实例
  rtcClient: any; // G2 sdk client实例
  WebRTC2: any; // G2 sdk
};
```

## 组件事件说明

```ts
/**
 * onInvited 收到通话邀请
 * 可以在此时调用accept或reject来接听或拒绝邀请
 * @param res
 */
rtc.addDelegate(
  'onInvited',
  (res: {
    invitor: string; // 邀请者的 IM account 账号
    userIds: string[]; // 同时被邀请者的 IM account 账号
    isFromGroup: boolean; // 是否是群呼
    groupId: string; // 群组id，后续该字段会废弃并入attachment
    attachment: { [key: string]: any }; // 自定义扩展字段
    type: CallType; // 呼叫类型 1:音频;2:视频;3:其他
  }) => {
    console.log(res);
    // rtc.accept()
    // or
    // rtc.reject()
  }
);

/**
 * onUserEnter 远端用户进入事件
 * @param userId 该用户的 IM account 账号
 */
rtc.addDelegate('onUserEnter', (userId: string) => {
  console.log(userId);
});

/**
 * onUserAccept 远端用户接受邀请事件
 * @param userId 该用户的 IM account 账号
 */
rtc.addDelegate('onUserAccept', (userId: string) => {
  console.log(userId);
});

/**
 * onUserReject 远端用户拒绝邀请事件
 * @param userId 该用户的 IM account 账号
 */
rtc.addDelegate('onUserReject', (userId: string) => {
  console.log(userId);
});

/**
 * onUserCancel 发起呼叫者取消呼叫事件
 * @param userId 呼叫者的 IM account 账号
 */
rtc.addDelegate('onUserCancel', (userId: string) => {
  console.log(userId);
});

/**
 * onUserBusy 远端用户占线事件
 * @param userId 该用户的 IM account 账号
 */
rtc.addDelegate('onUserBusy', (userId: string) => {
  console.log(userId);
});

/**
 * onUserLeave 远端用户离开房间事件
 * @param userId 该用户的 IM account 账号
 */
rtc.addDelegate('onUserLeave', (userId: string) => {
  console.log(userId);
});

/**
 * onCallingTimeOut 呼叫超时事件
 * @param reason 原因 
 * callTimeOut 点对点呼叫超时
 * groupCallTimeOut 群呼叫超时
 * groupInviteTimeOut 群邀请超时
 * beCallTimeOut 被叫超时
 */
rtc.addDelegate('onCallingTimeOut', (reason) => {
  console.log(reason)
});

/**
 * onCameraAvailable 远端用户摄像头开关事件
 * @param res
 */
rtc.addDelegate(
  'onCameraAvailable',
  (res: {
    userId: string; // 该用户的 IM account 账号
    uid: number; // 该用户的 G2 uid
    available: boolean; // 摄像头开关状态
  }) => {
    console.log(res);
  }
);

/**
 * onAudioAvailable 远端用户麦克风开关事件
 * @param res
 */
rtc.addDelegate(
  'onAudioAvailable',
  (res: {
    userId: string; // 该用户的 IM account 账号
    uid: number; // 该用户的 G2 uid
    available: boolean; // 麦克风开关状态
  }) => {
    console.log(res);
  }
);

/**
 * onUserNetworkQuality 网络状态回调
 * @param res
 */
rtc.addDelegate(
  'onUserNetworkQuality',
  (res: {
    [userId: string]: {
      // key 为 IM account 账号
      uplinkNetworkQuality: number; // 上行网络质量：0 质量未知、1 质量极好、2 用户主观感觉和极好差不多，但码率可能略低于极好、3 能沟通但不顺畅、4 网络质量差、5 完全无法沟通
      downlinkNetworkQuality: number; // 下行网络质量：0 质量未知、1 质量极好、2 用户主观感觉和极好差不多，但码率可能略低于极好、3 能沟通但不顺畅、4 网络质量差、5 完全无法沟通
    };
  }) => {
    console.log(res);
  }
);

/**
 * onCallTypeChange 通话类型变更事件
 * 目前只支持从视频切换为音频
 * @param type 1:音频;2:视频;3:其他
 */
rtc.addDelegate('onCallTypeChange', (type: CallType) => {
  console.log(type);
});

/**
 * onCallEnd 信令房间关闭事件
 */
rtc.addDelegate('onCallEnd', () => {});

/**
 * onDisconnect G2 断线事件
 */
rtc.addDelegate('onDisconnect', () => {});

/**
 * onOtherClientAccept 多端接受呼叫事件
 * 当同一个IM 账号 多端登录并被邀请时，在其他端接受了呼叫邀请后，本端收到的事件通知
 */
rtc.addDelegate('onOtherClientAccept', () => {});

/**
 * onOtherClientReject 多端拒绝呼叫事件
 * 当同一个IM 账号 多端登录并被邀请时，在其他端拒绝了呼叫邀请后，本端收到的事件通知
 */
rtc.addDelegate('onOtherClientReject', () => {});

/**
 * onMessageSent 本端发送话单通知
 * 当通话因为 取消、拒绝、超时或占线 结束时，组件会主动发送一条话单消息给对端，可以在此事件中更新本端的UI
 * @param userId 本端的 IM account 账号
 */
rtc.addDelegate('onMessageSent', (userId: string) => {
  console.log(userId);
});

/**
 * onJoinChannel 本端 G2 加入成功事件
 * @param res
 */
rtc.addDelegate(
  'onJoinChannel',
  (res: {
    uid: number; // 本端 G2 uid
    cid: string; // 本端 G2 cid
    channelName: string; // 本端 G2 的 channelName
    userId: string; // 本端的 IM的account账号
  }) => {
    console.log(res);
  }
);

/**
 * onVideoMuted 视频轨道禁用/开启事件
 * @param res
 */
rtc.addDelegate(
  'onVideoMuted',
  (res: {
    userId: string; // 该用户的 IM account 账号
    muted: boolean; // 是否禁用：true 禁用 false 开启
  }) => {
    console.log(res);
  }
);

/**
 * onAudioMuted 音频轨道禁用/开启事件
 * @param res
 */
rtc.addDelegate(
  'onAudioMuted',
  (res: {
    userId: string; // 该用户的 IM account 账号
    muted: boolean; // 是否禁用：true 禁用 false 开启
  }) => {
    console.log(res);
  }
);

/**
 * onError 错误事件
 * @param error
 */
rtc.addDelegate('onError', (error: ErrorMessage, ...args: any) => {
  console.log(error, ...args);
}
```

## 话单说明

当一对一通话因为 取消、拒绝、超时或占线 结束时，组件会在发起呼叫方发送一条话单消息给对端。此时，如果需要显示该话单消息：

- 在发送端，可以通过 onMessageSent 监听到发送话单的通知，从而通过 IM sdk 重新拉取消息来更新 UI
- 在接收端，可以通过 IM 的 onmsgs 回调获取到 type 为 'g2' 的消息，从而更新 UI
