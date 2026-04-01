## 简介

本 demo 演示了如何在微信原生小程序项目中集成 [NECallKit](https://www.npmjs.com/package/@xkit-yx/call-kit) 音视频通话组件，实现一对一音频/视频通话功能。


## 环境准备

- 微信 App iOS 最低版本要求：8.0.40
- 微信 App Android 最低版本要求：8.0.40
- 小程序基础库最低版本要求：2.10.0
- 由于小程序测试号不具备 `<live-pusher>` 和 `<live-player>` 的使用权限，请使用企业小程序账号申请相关权限进行开发
- 由于微信开发者工具不支持原生组件（即 `<live-pusher>` 和 `<live-player>` 标签），需要在真机上进行运行体验


## 工程结构

```
MiniProgram/
├── miniprogram/
│   ├── app.ts                          # 全局入口：NIM V10 初始化、NECall 初始化、自动登录
│   ├── sdk/
│   │   └── NIM_MINIAPP_SDK.js          # 网易云信 IM 小程序专用 SDK（从 npm 包中提取）
│   ├── static/
│   │   └── ring.mp3                    # 来电/呼叫铃声
│   ├── pages/
│   │   ├── login/                      # 登录页（账号ID + Token）
│   │   ├── index/                      # 主页（发起呼叫，选择音/视频类型）
│   │   └── call/                       # 通话页（包裹 call-view 组件）
│   └── components/
│       └── call-kit-wx-ui/
│           ├── call-view/              # 通话 UI 组件（呼叫中/被叫/通话中三态）
│           │   └── assets/             # 按钮图标资源
│           └── utils/
│               └── index.js            # 通话时长格式化工具
├── package.json                        # npm 依赖（@xkit-yx/call-kit、nim-web-sdk-ng）
├── project.config.json                 # 微信开发者工具项目配置
└── tsconfig.json                       # TypeScript 编译配置
```


## 快速跑通

**第一步：下载源码**

```bash
git clone https://github.com/netease-kit/NECallKit.git
cd NECallKit/MiniProgram
```

**第二步：安装依赖**

```bash
npm install
```

**第三步：构建 npm**

打开微信开发者工具，导入 `NECallKit/MiniProgram` 目录，然后点击菜单栏：

**工具 → 构建 npm**

等待提示构建成功。

**第四步：填写 AppKey**

在 `miniprogram/app.ts` 中填写云信控制台的 AppKey（阅读文末[开通服务](#开通服务)）：

```ts
globalData: {
  appkey: '请填写你的AppKey',
  ...
}
```

**第五步：预览/真机调试**

由于 `<live-pusher>` 和 `<live-player>` 组件在开发者工具模拟器中不可用，请使用**真机调试**或**预览**功能在手机上体验。


## 接入指引

### 步骤一：开通小程序权限

由于 NECallKit 所使用的小程序标签有更苛刻的权限要求，因此集成 NECallKit 的第一步就是要开通小程序的类目和标签使用权限，**否则无法使用**，这包括如下步骤：

- 小程序推拉流标签不支持个人小程序，只支持企业类小程序。需要在 [注册](https://developers.weixin.qq.com/community/business/doc/000200772f81508894e94ec965180d) 时填写主体类型为企业。

- 小程序推拉流标签使用权限暂时只开放给有限 [类目](https://developers.weixin.qq.com/miniprogram/dev/component/live-pusher.html)。

- 符合类目要求的小程序，需要在 **[微信公众平台](https://mp.weixin.qq.com/)** > **开发** > **开发管理** > **接口设置** 中自助开通该组件权限。


### 步骤二：在小程序控制台配置域名

在 **[微信公众平台](https://mp.weixin.qq.com/)** > **开发** > **开发管理** > **开发设置** > **服务器域名** 中设置以下域名：

**request 合法域名：**

```
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
```

**socket 合法域名：**

```
wss://wlnimsc0.netease.im
wss://wlnimsc1.netease.im
wss://webrtcgwcn.netease.im
wss://webrtcgwhz.netease.im
```


### 步骤三：开通服务

**1. 申请 AppKey**

用户在使用本插件之前需要获取 AppKey，AppKey 申请的具体流程请参见 [创建应用并获取AppKey](https://doc.yunxin.163.com/console/docs/TIzMDE4NTA?platform=console)。

**2. 获取账号**

本插件使用中需要 account 和 token，具体请参见 [注册云信IM账号](https://doc.yunxin.163.com/messaging-uikit/docs/Dc0NjI1MTA?platform=android#4-%E6%B3%A8%E5%86%8C-im-%E8%B4%A6%E5%8F%B7)。

**3. 开通音视频服务**

使用音视频呼叫（呼叫组件）之前，需要开通部分能力，开通的具体流程请参见 [开通服务](https://doc.yunxin.163.com/nertccallkit/docs/DIzMzA0Nzk?platform=iOS)。


## 常见问题

**Q：构建 npm 时提示"NPM packages not found"**

确认 `project.config.json` 中已配置：

```json
"packNpmManually": true,
"packNpmRelationList": [
  {
    "packageJsonPath": "./package.json",
    "miniprogramNpmDistDir": "./miniprogram/"
  }
]
```

**Q：真机预览报错 `SyntaxError: Unexpected token .`**

可选链 `?.` 语法在部分微信版本中不支持。确认 `tsconfig.json` 的 `target` 为 `ES5`，并检查 `.js` 文件中是否存在 `?.` 语法需要手动替换。

**Q：`<live-pusher>` / `<live-player>` 在开发者工具中不显示**

这是微信开发者工具的限制，原生音视频组件仅支持真机。请使用**预览**或**真机调试**进行测试。

**Q：调用 `neCall.call()` 报错"呼叫功能未初始化"**

检查 `app.ts` 中的 `appkey` 是否已正确填写，并确认登录成功后 `globalData.neCall` 不为 `null`。


## 附录

- 了解 NECallKit 组件介绍：[组件介绍 NECallKit](https://doc.yunxin.163.com/nertccallkit/concept)
- 查阅详细 API：[API 概览](https://www.npmjs.com/package/@xkit-yx/call-kit)
- 发现示例代码的 bug，欢迎提交 [issue](https://github.com/netease-kit/NECallKit/issues)
