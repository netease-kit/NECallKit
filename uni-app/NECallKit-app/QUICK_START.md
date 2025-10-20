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


## 步骤一：下载源码，配置工程
1. 克隆仓库

```shell
  git clone https://github.com/netease-kit/NEVideoCall-1to1.git
```

2. 安装依赖

```shell
	cd ./NEVideoCall-1to1/NLiteAVDemo-uni-app
	npm install
```
  
3. 配置 appKey 和 appSecret 在 `NEVideoCall-1to1/NLiteAVDemo-uni-app/debug/AppConfig.js` 文件中填写 appKey。
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
2. 自定义调试基座成功后，使用自定义基座运行项目。

## 实现音视频通话
- 分别在两台设备上登录两个用户，一方作为主叫，一方作为被叫。
- 在主叫方进入通话界面，输入被叫方的accoudId，发起通话。
- 被叫方收到通话的请求，点击接听后进行通话。


## 常见问题

### 1、iOS需要配置麦克风和摄像头权限

需要在项目根目录的manifest.json中的“App权限配置”中配置麦克风和摄像头权限

### 2、同时集成呼叫组件和推送插件后无法正常呼叫

需要在控制台开通IM的多端登录