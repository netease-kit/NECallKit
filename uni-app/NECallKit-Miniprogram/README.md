## 简介
本 demo 演示了如何在 uni-app 项目中集成 [NECallKit](https://www.npmjs.com/package/@xkit-yx/call-kit) 音视频通话组件。


## 环境准备

- 微信 App iOS 最低版本要求：8.0.40
- 微信 App Android 最低版本要求：8.0.40
- 小程序基础库最低版本要求：2.10.0
- 由于小程序测试号不具备 <live-pusher> 和 <live-player> 的使用权限，请使用企业小程序账号申请相关权限进行开发
- 由于微信开发者工具不支持原生组件（即 <live-pusher> 和 <live-player> 标签），需要在真机上进行运行体验


## 快速跑通
第一步：下载源码，编译运行
1. 克隆或者直接下载此仓库源码。
   ```
   git clone https://github.com/netease-kit/NECallKit.git
   ```
2. 进入 demo 目录
   ```
   cd ./NECallKit/uni-app/NECallKit-Miniprogram
   ```
3. 安装依赖
   ```
   npm install
   ```

4. HBuilder X 中导入项目

5. 修改 `./NECallKit/uni-app/NECallKit-Miniprogram/App.vue` 文件 的 appkey、account、token（阅读文末 [开通服务](#开通服务)）

6. 在manifest.json微信小程序配置中设置自己的微信小程序AppID，勾选ES6转ES5

7. 先去【微信开发者工具】中的设置-安全设置中打开服务端口，再从HBuilder X中点击运行到【微信开发者工具】


## 接入指引
### 步骤一：开通小程序权限
由于 NECallKit 所使用的小程序标签有更苛刻的权限要求，因此集成 NECallKit 的第一步就是要开通小程序的类目和标签使用权限，**否则无法使用**，这包括如下步骤：

- 小程序推拉流标签不支持个人小程序，只支持企业类小程序。需要在 [注册](https://developers.weixin.qq.com/community/business/doc/000200772f81508894e94ec965180d) 时填写主体类型为企业，如下图所示：
   <img width="480" height="480" src="https://main.qcloudimg.com/raw/a30f04a8983066fb9fdf179229d3ee31.png">

- 小程序推拉流标签使用权限暂时只开放给有限 [类目](https://developers.weixin.qq.com/miniprogram/dev/component/live-pusher.html)。
- 符合类目要求的小程序，需要在 **[微信公众平台](https://mp.weixin.qq.com/)** > **开发** > **开发管理** > **接口设置**中自助开通该组件权限，如下图所示：
  <img width="480" height="360" src="https://main.qcloudimg.com/raw/dc6d3c9102bd81443cb27b9810c8e981.png">


### 步骤二：在小程序控制台配置域名
在 **[微信公众平台](https://mp.weixin.qq.com/)** > **开发** > **开发管理** > **开发设置** > **服务器域名**中设置 **request 合法域名** 和 **socket 合法域名**，如下图所示：
- **request 合法域名**：
```javascript
https://lbs.netease.im
https://wlnimsc0.netease.im
https://wlnimsc0.netease.im:443
https://wlnimsc1.netease.im
https://wlnimsc1.netease.im:443
https://statistic.live.126.net
https://abt-online.netease.im
https://nrtc.netease.im
https://webrtcgwcn.netease.im
https://webrtcgwhz.netease.im
https://statistic.live.126.net
```
- **socket 合法域名**：
```javascript
wss://wlnimsc0.netease.im
wss://wlnimsc1.netease.im
wss://webrtcgwcn.netease.im
wss://webrtcgwhz.netease.im
```


### 步骤三：开通服务

**1. 申请 AppKey**

用户在使用本插件之前需要获取AppKey，AppKey 申请的具体流程请参见 [创建应用并获取AppKey](https://doc.yunxin.163.com/console/docs/TIzMDE4NTA?platform=console)。

**2. 获取账号**

本插件使用中需要 account 和 token，具体请参见 [注册云信IM账号](https://doc.yunxin.163.com/messaging-uikit/docs/Dc0NjI1MTA?platform=android#4-%E6%B3%A8%E5%86%8C-im-%E8%B4%A6%E5%8F%B7)。


**3. 开通服务**

使用音视频呼叫（呼叫组件）之前，需要开通部分能力，开通的具体流程请参见 [开通服务](https://doc.yunxin.163.com/nertccallkit/docs/DIzMzA0Nzk?platform=iOS)。


## 附录
- 如果您想要了解NECallKit，请阅读 [组件介绍 NECallKit](https://doc.yunxin.163.com/nertccallkit/concept)
- 如果您想要了解详细 API ，请阅读 [ API 概览](https://www.npmjs.com/package/@xkit-yx/call-kit)
- 如果发现了示例代码的 bug，欢迎提交 issue；