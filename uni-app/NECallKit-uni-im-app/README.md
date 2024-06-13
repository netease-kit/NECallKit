> 本文档介绍基于uni-id账号体系快速集成云端一体的网易云信 RTC 音视频通话系统。


## 简介

网易云信音视频呼叫是网易云信推出的含 UI 组件，您只需要几行代码，基于uni-id账号就可以快速实现音视频呼叫，在 App 中添加包括呼叫、接通、拒接、以及通话中音频和视频的开关控制功能，并包含呼叫的 UI 界面。

呼叫组件基于云信信令、音视频通话 2.0 和 IM 即时通讯产品封装的融合性场景组件，简化了呼叫流程，将呼叫功能以 UI 组件化的形式提供给客户，提高接入效率、降低使用成本。

支持的功能如下表所示。

| <div style="width: 200px">功能</div> | 描述                                                         |
| ------------------------------------ | ------------------------------------------------------------ |
| 自定义 UI                            | 开发者可以自行设计通话和呼叫页面 UI。                        |
| 音视频呼叫                           | App 通过此功能通知被叫用户呼叫请求，呼叫请求类型包括音频和视频呼叫。 |
| 音视频通话                           | 接通后可依照呼叫类型进行实时通话。                           |
| 音视频控制                           | 通话过程中可以控制本端音频或视频的开关，以及摄像头方向等。   |
| 话单                                 | 每次通话结束后都会收到对应的话单消息，标记本次通话是否接通以及通话时间、类型等数据。 |



**限时优惠活动**

如果您在 Dcloud 平台下载了该组件，您可[登录云信控制台（Dcloud专属链接）]()进行开通与管理。

此外通过以上 Dcloud 平台的专属链接成功注册账号并开通服务的用户，云信将提供特别的**优惠价**，可在开通账号后联系云信销售或技术支持。

**Demo 体验**

|  平台   |                            二维码                            |
| :-----: | :----------------------------------------------------------: |
| Android | <img src="https://yx-web-nosdn.netease.im/common/d4d82b48eed25fd351438dd08ac1ba5a/1%E5%AF%B91%E8%A7%86%E9%A2%91%E9%80%9A%E8%AF%9D-Android.png" width=100 /> |
|   iOS   | <img src="https://yx-web-nosdn.netease.im/common/e4ea0d59188c8c597e003540f33b6145/1%E5%AF%B91%E8%A7%86%E9%A2%91%E9%80%9A%E8%AF%9D-iOS.png" width=100 /> |

Demo 效果图
<img src="https://yx-web-nosdn.netease.im/quickhtml%2Fassets%2Fyunxin%2Fdefault%2F1v1-%E4%BA%A4%E4%BA%92.png" width=900 />

**技术支持**

网易云信提供多种服务，包括客服、技术支持、热线服务、全流程数据监控等，建议扫码添加我们的技术支持，协助接入、测试以及定制需求。
|                           微信咨询                           |                           在线咨询                           |   电话咨询   |
| :----------------------------------------------------------: | :----------------------------------------------------------: | :----------: |
| <img src="https://yx-web-nosdn.netease.im/common/c65201e8ca7a293ff9143ad7e9b37bc2/Dcloud.png" width=100 /> | [点击在线咨询](https://qiyukf.com/client?k=10f5d3378752b7b73aa90daf2bd4fc8a&u=&d=96oshbhiofhds8zt8ej3&uuid=emoobdra0otce0bnxjfz&gid=0&sid=0&qtype=0&welcomeTemplateId=0&dvctimer=0&robotShuntSwitch=0&hc=0&robotId=0&pageId=1691392062019BDH8BhIoTI&shuntId=0&ctm=LS0xNjkxMzkyMTI1NDg4&wxwId=&language=&isShowBack=0&shortcutTemplateId=&t=%25E7%25BD%2591%25E6%2598%2593%25E4%25BA%2591%25E4%25BF%25A1%2520-%2520IM%25E5%258D%25B3%25E6%2597%25B6%25E9%2580%259A%25E8%25AE%25AF%25E4%25BA%2591%2520-%25E9%259F%25B3%25E8%25A7%2586%25E9%25A2%2591%25E9%2580%259A%25E8%25AF%259D) | 4009-000-123 |


## 使用uniCloud产生的费用说明
yunxin-rtc-call本身并不收费，实际使用中需要依赖uniCloud云服务，会产生费用；



## 准备工作

**1. 申请 AppKey**

用户在使用本插件之前需要获取云信的AppKey，AppKey 申请的具体流程请参见 [创建应用并获取AppKey](https://doc.yunxin.163.com/console/docs/TIzMDE4NTA?platform=console)。

**2. 获取账号**

本系统的服务端代码托管在uniCloud下，账户体系是uni-id 4.0+的，代码是开源的，开发者可以根据需要修改成自己的账号体系。


**3. 开通服务**

使用音视频呼叫（呼叫组件）之前，需要开通部分能力，开通的具体流程请参见 [开通服务](https://doc.yunxin.163.com/nertccallkit/docs/DIzMzA0Nzk?platform=iOS)。


**4. 部署到uniCloud**

### 步骤1：对项目根目录uniCloud点右键，选择“关联云服务空间或项目” 按提示部署项目。
### 步骤2：在目录uniCloud/cloudfunctions/common/uni-config-center下面新建文件夹share-config，然后在share-config中新建文件config.json，在文件中添加如下配置：

```json
{
	"appKey": "云信控制台申请的appKey",
	"appSecret": "云信控制台申请的appSecret"
}
```
填好上文获取到的appKey和对应的appSecret，然后选中cloudfunctions点击右键“上传所有云函数、公共函数及Actions”。

参考：
[DCloud文档](https://doc.dcloud.net.cn/uniCloud/cf-common.html)。
[DCloud配置中心文档](https://doc.dcloud.net.cn/uniCloud/uni-config-center.html)

**5.开发环境**

- HBuilderX
- sass（sass-loader 版本 <= 10.1.1）
- node（16.0.0 <= node 版本 <= 17.0.0, 推荐使用 Node.js 官方 LTS 版本 16.17.0）
- npm（版本请与 node 版本匹配）


## 目录结构

```

uni_modules
    ├─其他module
    └─yunxin-rtc-call
      ├── readme.md
      └── uniCloud
          ├── cloudfunctions
          │   ├── common
          │   │   └── utils                 公共库：checksum的生成等方法
          │   │       ├── index.js
          │   │       └── package.json
          │   └── co1                       云信账号和uni账号映射
          │       ├── index.obj.js
          │       └── package.json
          └── database
```


## 运行客户端项目

### 初始化
参考index.vue中的initConfig方法

### 账号映射
参考index.vue中的registerAndLogin方法

### 呼叫
参考index.vue中的toAudioCall、toVideoCall方法


## 常见问题

#### 同时集成呼叫组件和推送插件后无法正常呼叫

需要在控制台开通IM的多端登录