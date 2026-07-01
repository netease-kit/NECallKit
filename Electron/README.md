# NECallKit Electron Sample

本目录提供 Electron 场景的 CallKit UI 示例源码，保留 Vue 3 Electron demo 和本次需要上传的 UIKit 源码：

```text
Electron/
└── example-vue3/
    ├── src/
    └── github/
```

`example-vue3` 包含 Electron demo 与 Vue 3 Electron UIKit 源码。CallKit 逻辑层、native addon、SDK 源码和构建产物不在本目录内，由 npm 依赖提供。

## 功能开通

1. 申请 AppKey：参考 [创建应用并获取 AppKey](https://doc.yunxin.163.com/console/docs/TIzMDE4NTA?platform=console)。
2. 获取账号和 Token：参考 [注册云信 IM 账号](https://doc.yunxin.163.com/messaging-uikit/docs/Dc0NjI1MTA?platform=android#4-%E6%B3%A8%E5%86%8C-im-%E8%B4%A6%E5%8F%B7)。
3. 开通音视频呼叫能力：参考 [开通服务](https://doc.yunxin.163.com/nertccallkit/docs/DIzMzA0Nzk?platform=iOS)。

## 快速运行

Vue 3 Demo：

```bash
cd Electron/example-vue3
npm install
npm start
```

启动后在登录页输入自己的 AppKey、账号、Token 和被叫账号。源码中不提供真实 AppKey、测试账号或 Token。

Demo 的 `package.json` 优先使用 npm 上已发布的 Electron UIKit 版本。`github/` 是本次随 demo 上传的 Vue 3 Electron UIKit 源码；如需要本地源码联调，可临时改用本地 tarball 或本地 path，但不要把 CallKit 逻辑层源码提交到本目录。
