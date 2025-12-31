# 插件概述

网易云信音视频呼叫（netease-CallKit）是网易云信推出的含 UI 组件，您只需要几行代码，就可以快速实现音视频呼叫，在 App 中添加包括呼叫、接通、拒接、以及通话中音频和视频的开关控制功能，并包含呼叫的 UI 界面。

呼叫组件基于云信信令、音视频通话 2.0 和 IM 即时通讯产品封装的融合性场景组件，简化了呼叫流程，将呼叫功能以 UI 组件化的形式提供给客户，提高接入效率、降低使用成本。

呼叫组件（netease-CallKit）支持的功能如下表所示。

| <div style="width: 200px">功能</div> | 描述                                                         |
| ------------------------------------ | ------------------------------------------------------------ |
| 音视频呼叫                           | App 通过此功能通知被叫用户呼叫请求，呼叫请求类型包括音频和视频呼叫。 |
| 音视频通话                           | 接通后可依照呼叫类型进行实时通话。                           |
| 音视频控制                           | 通话过程中可以控制本端音频或视频的开关，以及摄像头方向等。   |
| 话单                                 | 每次通话结束后都会收到对应的话单消息，标记本次通话是否接通以及通话时间、类型等数据。 |

**技术支持**

网易云信提供多种服务，包括客服、技术支持、热线服务、全流程数据监控等，建议扫码添加我们的技术支持，协助接入、测试以及定制需求。
|                           微信咨询                           |                           在线咨询                           |   电话咨询   |
| :----------------------------------------------------------: | :----------------------------------------------------------: | :----------: |
| <img src="https://yx-web-nosdn.netease.im/common/c65201e8ca7a293ff9143ad7e9b37bc2/Dcloud.png" width=100 /> | [点击在线咨询](https://qiyukf.com/client?k=10f5d3378752b7b73aa90daf2bd4fc8a&u=&d=96oshbhiofhds8zt8ej3&uuid=emoobdra0otce0bnxjfz&gid=0&sid=0&qtype=0&welcomeTemplateId=0&dvctimer=0&robotShuntSwitch=0&hc=0&robotId=0&pageId=1691392062019BDH8BhIoTI&shuntId=0&ctm=LS0xNjkxMzkyMTI1NDg4&wxwId=&language=&isShowBack=0&shortcutTemplateId=&t=%25E7%25BD%2591%25E6%2598%2593%25E4%25BA%2591%25E4%25BF%25A1%2520-%2520IM%25E5%258D%25B3%25E6%2597%25B6%25E9%2580%259A%25E8%25AE%25AF%25E4%25BA%2591%2520-%25E9%259F%25B3%25E8%25A7%2586%25E9%25A2%2591%25E9%2580%259A%25E8%25AF%259D) | 4009-000-123 |



# 功能开通

**1. 申请 AppKey**

用户在使用本插件之前需要获取AppKey，AppKey 申请的具体流程请参见 [创建应用并获取AppKey](https://doc.yunxin.163.com/console/docs/TIzMDE4NTA?platform=console)。

**2. 获取账号**

本插件使用中需要 account 和 token，具体请参见 [注册云信IM账号](https://doc.yunxin.163.com/messaging-uikit/docs/Dc0NjI1MTA?platform=android#4-%E6%B3%A8%E5%86%8C-im-%E8%B4%A6%E5%8F%B7)。


**3. 开通服务**

使用音视频呼叫（呼叫组件）之前，需要开通部分能力，开通的具体流程请参见 [开通服务](https://doc.yunxin.163.com/nertccallkit/docs/DIzMzA0Nzk?platform=iOS)。

# 环境准备

> **说明：**
> 
> 本项目为App原生语言插件，请参考[原生语言插件](https://uniapp.dcloud.net.cn/plugin/native-plugin.html)的集成方式进行集成。

- [HBuilder X](https://www.dcloud.io/hbuilderx.html)
- sass（sass-loader 版本 <= 10.1.1）
- node（16.0.0 <= node 版本 <= 17.0.0, 推荐使用 Node.js 官方 LTS 版本 16.17.0）
- npm（版本请与 node 版本匹配）
- 两个移动设备： Android 5.0 以上的设备 / iOS 13.0 及以上设备。

# 快速接入

## 步骤一：下载源码，配置工程

1. 从 github 下载 [NECallKit Demo](https://github.com/netease-kit/NECallKit) 源码，或者直接在命令行运行以下命令：

   ```bash
   git clone https://github.com/netease-kit/NECallKit.git
   ```

2. 通过 HbuiderX 打开 **NECallKit/uni-app/NECallKit-app** 项目。

3. 安装依赖

   ```shell
   cd ./uni-app/NECallKit-app
   npm install
   ```

4. 配置 appKey 和 appSecret 在 `debug/AppConfig.js` 文件中填写 appKey。

   ```javascript
   // 应用Key - - 请替换为你的实际appKey
   appKey: "your_app_key",
   ```

## 步骤二：导入插件

1. 购买 uni-app 原生插件

   登录 uni 原生插件市场，并访问 netease-CallKit 插件，在插件详情页中购买（免费插件也可以在插件市场0元购）。购买后才能够云端打包使用插件。购买插件时请选择正确的 appid，以及绑定正确包名。

   <img width='400' src='https://yx-web-nosdn.netease.im/common/da168eb3dfa51c1584dbe52652f262f8/dcloud_uniapp_install_cloud_plugins.png' />

2. 制作自定义调试基座 （请使用真机运行自定义基座）

   购买插件后在项目的 manifest.json 页面的 App原生插件配置项下单击选择云端插件，选择netease-CallKit插件。

   <img width='700' src='https://yx-web-nosdn.netease.im/common/b58e3af8857bfa406396c3a8a9ff5a32/dcloud_uniapp_install_cloud_plugins3.png' />

   > **注意**
   > - 自定义基座不是正式版，真正发布时，需要再打正式包。使用自定义基座是无法正常升级替换 APK 的。
   > - 请尽量不要使用本地插件，插件包超过自定义基座的限制，可能导致调试收费。

## 步骤三：运行项目

1. 制作自定义调试基座，请选择**传统打包**方式进行打包。

2. 自定义调试基座成功后，**使用自定义基座运行**项目。

## 步骤四：拨打第一通电话

> **注意：**
> 
> 为了使您可以体验完整的音视频通话流程，请将 Demo 分别在两台设备上登录两个用户，一方作为主叫，一方作为被叫。

1. [获取账号（AccountId）和token](https://doc.yunxin.163.com/messaging2/guide/jU0Mzg0MTU?platform=client#%E7%AC%AC%E4%BA%8C%E6%AD%A5%E6%B3%A8%E5%86%8C-im-%E8%B4%A6%E5%8F%B7)

2. 登录应用

3. 在主叫方进入通话界面，输入被叫方的 accountId，发起通话

4. 被叫方收到通话的请求，点击接听后进行通话


## 常见问题

### 1、iOS需要配置麦克风和摄像头权限

需要在项目根目录的manifest.json中的“App权限配置”中配置麦克风和摄像头权限

### 2、同时集成呼叫组件和推送插件后无法正常呼叫

需要在控制台开通IM的多端登录
