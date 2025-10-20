> 本文档介绍基于 Vue 框架（支持 Vue 2&Vue 3）快速集成网易云信 RTC 音视频通话点对点呼叫组件。


# 插件概述

网易云信音视频呼叫（呼叫组件 NERtcCallKit）是网易云信推出的含 UI 组件，您只需要几行代码，就可以快速实现音视频呼叫，在 App 中添加包括呼叫、接通、拒接、以及通话中音频和视频的开关控制功能，并包含呼叫的 UI 界面。

呼叫组件基于云信信令、音视频通话 2.0 和 IM 即时通讯产品封装的融合性场景组件，简化了呼叫流程，将呼叫功能以 UI 组件化的形式提供给客户，提高接入效率、降低使用成本。

呼叫组件（NECallKit）支持的功能如下表所示。

| <div style="width: 200px">功能</div> | 描述                                                         |
| ------------------------------------ | ------------------------------------------------------------ |
| 音视频呼叫                           | App 通过此功能通知被叫用户呼叫请求，呼叫请求类型包括音频和视频呼叫。 |
| 音视频通话                           | 接通后可依照呼叫类型进行实时通话。                           |
| 音视频控制                           | 通话过程中可以控制本端音频或视频的开关，以及摄像头方向等。   |
| 话单                                 | 每次通话结束后都会收到对应的话单消息，标记本次通话是否接通以及通话时间、类型等数据。 |



**限时优惠活动**

如果您在 Dcloud 平台下载了该组件，您可[登录云信控制台（Dcloud专属链接）](https://id.grow.163.com/?h=media&t=media&clueFrom=nim&from=yongyou%7Chttps%3A%2F%2Fnetease.im%2F&locale=zh_CN&referrer=https%3A%2F%2Fapp.yunxin.163.com&i18nEnable=true)进行开通与管理。

此外通过以上 Dcloud 平台的专属链接成功注册账号并开通服务的用户，云信将提供特别的**优惠价**，可在开通账号后联系云信销售或技术支持。

**效果图**

<img src="https://yx-web-nosdn.netease.im/quickhtml%2Fassets%2Fyunxin%2Fdefault%2F1v1-%E4%BA%A4%E4%BA%92.png" width=900 />

**技术支持**

网易云信提供多种服务，包括客服、技术支持、热线服务、全流程数据监控等，建议扫码添加我们的技术支持，协助接入、测试以及定制需求。
|                           微信咨询                           |                           在线咨询                           |   电话咨询   |
| :----------------------------------------------------------: | :----------------------------------------------------------: | :----------: |
| <img src="https://yx-web-nosdn.netease.im/common/c65201e8ca7a293ff9143ad7e9b37bc2/Dcloud.png" width=100 /> | [点击在线咨询](https://qiyukf.com/client?k=10f5d3378752b7b73aa90daf2bd4fc8a&u=&d=96oshbhiofhds8zt8ej3&uuid=emoobdra0otce0bnxjfz&gid=0&sid=0&qtype=0&welcomeTemplateId=0&dvctimer=0&robotShuntSwitch=0&hc=0&robotId=0&pageId=1691392062019BDH8BhIoTI&shuntId=0&ctm=LS0xNjkxMzkyMTI1NDg4&wxwId=&language=&isShowBack=0&shortcutTemplateId=&t=%25E7%25BD%2591%25E6%2598%2593%25E4%25BA%2591%25E4%25BF%25A1%2520-%2520IM%25E5%258D%25B3%25E6%2597%25B6%25E9%2580%259A%25E8%25AE%25AF%25E4%25BA%2591%2520-%25E9%259F%25B3%25E8%25A7%2586%25E9%25A2%2591%25E9%2580%259A%25E8%25AF%259D) | 4009-000-123 |

# 准备工作

**1. 申请 AppKey**

用户在使用本插件之前需要获取AppKey，AppKey 申请的具体流程请参见 [创建应用并获取AppKey](https://doc.yunxin.163.com/console/docs/TIzMDE4NTA?platform=console)。

**2. 获取账号**

本插件使用中需要 account 和 token，具体请参见 [注册云信IM账号](https://doc.yunxin.163.com/messaging-uikit/docs/Dc0NjI1MTA?platform=android#4-%E6%B3%A8%E5%86%8C-im-%E8%B4%A6%E5%8F%B7)。


**3. 开通服务**

使用音视频呼叫（呼叫组件）之前，需要开通部分能力，开通的具体流程请参见 [开通服务](https://doc.yunxin.163.com/nertccallkit/docs/DIzMzA0Nzk?platform=iOS)。

**4.开发环境**

- HBuilderX
- sass（sass-loader 版本 <= 10.1.1）
- node（16.0.0 <= node 版本 <= 17.0.0, 推荐使用 Node.js 官方 LTS 版本 16.17.0）
- npm（版本请与 node 版本匹配）



# 快速接入

> **说明**
>
> 本项目为App原生语言插件，请参考[原生语言插件](https://uniapp.dcloud.net.cn/plugin/native-plugin.html)的集成方式进行集成。


## 步骤一：导入插件
1. 购买 uni-app 原生插件
登录 uni 原生插件市场，并访问 netease-CallKit 插件，在插件详情页中购买（免费插件也可以在插件市场0元购）。购买后才能够云端打包使用插件。购买插件时请选择正确的 appid，以及绑定正确包名。

<img width='400' src='https://yx-web-nosdn.netease.im/common/da168eb3dfa51c1584dbe52652f262f8/dcloud_uniapp_install_cloud_plugins.png' />

2. 制作自定义调试基座 （请使用真机运行自定义基座）
购买插件后在项目的 manifest.json 页面的 App原生插件配置项下单击选择云端插件，选择netease-CallKit插件。

<img width='700' src='https://yx-web-nosdn.netease.im/common/b58e3af8857bfa406396c3a8a9ff5a32/dcloud_uniapp_install_cloud_plugins3.png' />

> **注意**
> - 自定义基座不是正式版，真正发布时，需要再打正式包。使用自定义基座是无法正常升级替换 APK 的。
> - 请尽量不要使用本地插件，插件包超过自定义基座的限制，可能导致调试收费。


## 步骤二：在 vue 页面中引入原生插件
使用 uni.requireNativePlugin 的 API 在 vue 页面中引入原生插件，参数为插件的 ID。

```js
var callkit = uni.requireNativePlugin("netease-CallKit")
const callKitEvent = uni.requireNativePlugin('globalEvent');
```


## 步骤三：初始化并登录组件

### 接口

login({params}, callback(ret))

### params

appKey:

- 类型：String 
- 描述：云信IM应用APPKEY，获取方式请参见 [创建应用并获取AppKey](https://doc.yunxin.163.com/console/docs/TIzMDE4NTA?platform=console)。

account:

- 类型：String 
- 描述：账号ID，获取方法请参见 [注册云信IM账号](https://doc.yunxin.163.com/messaging-uikit/docs/Dc0NjI1MTA?platform=android#4-%E6%B3%A8%E5%86%8C-im-%E8%B4%A6%E5%8F%B7)。

token:

- 类型：String 
- 描述：账号token，获取方法请参见 [注册云信IM账号](https://doc.yunxin.163.com/messaging-uikit/docs/Dc0NjI1MTA?platform=android#4-%E6%B3%A8%E5%86%8C-im-%E8%B4%A6%E5%8F%B7)。

rtcUid:

- 类型：Number 
- 描述：（可选值）云信 RTC Uid

apnsCername:

- 类型：String 
- 描述：（可选值）云信 Apns 推送证书名

pkCername:

- 类型：String 
- 描述：（可选值）云信 PushKit 推送证书名

language

- 类型：String 
- 描述：（可选值）语言，zh为中文，en为英文，不填默认跟随系统

enableFloatingWindow

- 类型：布尔类型
- 描述：（可选值）是否开启悬浮窗，true开启，false不开启

enableAutoFloatingWindowWhenHome

- 类型：布尔类型
- 描述：（可选值）是否开启回到桌面自动开启悬浮窗，true开启，false不开启

enableForegroundService

- 类型：布尔类型
- 描述：（可选值）是否开启前台服务，true开启，false不开启

enableAudio2Video

- 类型：布尔类型
- 描述：（可选值）是否显示语音转视频的按钮，true开启，false不开启，默认显示

enableVideo2Audio

- 类型：布尔类型
- 描述：（可选值）是否显示视频转语音的按钮，true开启，false不开启，默认显示

audio2VideoConfirm

- 类型：布尔类型
- 描述：（可选值）是否开启语音转视频的时候需要同意，true开启，false不开启，默认不开启

video2AudioConfirm

- 类型：布尔类型
- 描述：（可选值）是否开启视频转语音的时候需要同意，true开启，false不开启，默认不开启

### callback(ret)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
    code:200,                      // Int类型；失败登录返回 code（登录成功返回 200）
    message:''                     // String 类型；失败登录接口信息    
}
```

### 示例代码

```js
callKit.login({
	appKey: AppConfig.appKey,
	account: this.account,
	token: this.currentToken,
	rtcUid: this.rtcUid ? Number(this.rtcUid) : undefined,
	apnsCername: this.apnsCername,
	pkCername: this.pkCername,
	language: this.language,
	enableFloatingWindow: true,
	enableAutoFloatingWindowWhenHome: true,
	enableForegroundService: true,
	enableAudio2Video: true,
	enableVideo2Audio: true,
	enableAudio2VideoConfirm: true,
	enableVideo2AudioConfirm: true
}, function(ret) {
    if (ret.code != 200) {
        var msg = '登录失败\n错误码：' + ret.code + '\n错误信息：' + ret.message;
		uni.showToast({
		  title: msg,
		  icon: 'none',
		})      
    } else {
		uni.showToast({
		  title: '登录成功',
		  icon: 'none',
		})
    }
})

```

### 可用性

- iOS系统：可提供的 11 及更高版本
- Android系统：可提供的 21 及更高版本

## 步骤四：拨打通话

### 接口

toCallPage({params}, callback(ret))

### params

calledAccount:

- 类型：String 
- 描述：被叫账号，即 account 账号

type:

- 类型：Int 
- 描述：呼叫类型(1: 音频呼叫, 2: 视频呼叫)

rtcChannelName: 

- 类型：String 
- 描述：云信 RTC 频道名称

### callback(ret)

ret：

- 类型：JSON 对象
- 内部字段：

```js
{
    code:200,                   // Int类型；错误码（呼叫成功返回 200）
    message:''                  // String 类型；错误信息（呼叫接口信息）
}
```

### 示例代码

```js
callKit.toCallPage({
    calledAccount:'123456',
    type:2
}, function(ret) {
    if (ret.code != 200) {
        var msg = '呼叫失败\n错误码：' + ret.code + '\n错误信息：' + ret.message;
		uni.showToast({
		  title: msg,
		  icon: 'none',
		})      
    } else {
		uni.showToast({
		  title: '呼叫成功',
		  icon: 'none',
		})
    }
})
```

### 可用性

- iOS系统：可提供的 11 及更高版本
- Android系统：可提供的 21 及更高版本


## 步骤五：更多特性

### 一、登出


```js
callKit.logout({}, (ret) => {
	if (ret.code != 200) {
		uni.showToast({
		  title: '登出失败 ' + ret.code,
		  icon: 'none',
		})
	} else {
		uni.showToast({
		  title: '登出成功 ',
		  icon: 'none',
		})
	}
})


```


### 二、通话状态监听
如果您的业务需要 监听通话的状态，例如：异常、通话开始、结束等，可以监听以下事件：

```js
//接收到邀请
// e.callType 呼叫类型，1: 语音呼叫；2: 视频呼叫
// e.callerAccount 呼叫账号
callKitEvent.addEventListener('onReceiveInvited', function(e) {
	  console.log('onReceiveInvited' + JSON.stringify(e));
});

//通话建立
// e.callType 呼叫类型，1: 语音呼叫；2: 视频呼叫
// e.callId 通话Id
// e.callerAccount 呼叫账号
// e.calledAccount 被呼账号
// e.currentAccount 当前账号
callKitEvent.addEventListener('onCallConnected', function(e) {
  console.log('onCallConnected' + JSON.stringify(e));
});

//通话类型变更
// e.callType 呼叫类型，1: 语音呼叫；2: 视频呼叫
callKitEvent.addEventListener('onCallTypeChange', function(e) {
  console.log('onCallTypeChange' + JSON.stringify(e));
});

//通话结束
//  e.code 错误码 
// (code:12 手动取消；code:2 超时取消；code:14 对方拒接通话；code:15 接听并自己结束通话；code:16 接听并对方结束通话)
//  e.message 错误信息
callKitEvent.addEventListener('onCallEnd', function(e) {
  console.log('onCallEnd' + JSON.stringify(e));
});

// 远端用户是否开启视频流采集
//  e.account 账号
//  e.mute 是否静音
callKitEvent.addEventListener('onVideoMuted', function(e) {
  console.log('onVideoMuted' + JSON.stringify(e));
});

// 远端用户是否开启音频流采集
//  e.account 账号
//  e.mute 是否静音
callKitEvent.addEventListener('onAudioMuted', function(e) {
  console.log('onAudioMuted' + JSON.stringify(e));
});
```


## 常见问题

### 1、iOS需要配置麦克风和摄像头权限

需要在项目根目录的manifest.json中的“App权限配置”中配置麦克风和摄像头权限

### 2、同时集成呼叫组件和推送插件后无法正常呼叫

需要在控制台开通IM的多端登录