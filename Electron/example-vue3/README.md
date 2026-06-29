# Electron Vue 3 Demo

Vue 3 Electron 示例通过 `@xkit-yx/electron-callkit-vue3-uikit` 接入 CallKit UI。当前目录下的 `github/` 是 Vue 3 Electron UIKit 源码，CallKit 逻辑层通过 npm 依赖提供。

## 运行

```bash
npm install
npm start
```

启动后在登录页输入自己的 AppKey、账号、Token 和被叫账号。源码中不提供真实 AppKey 或测试账号。

## 目录

```text
example-vue3/
├── src/             # Electron main/preload/renderer demo
├── github/          # Vue 3 Electron UIKit 源码
└── package.json
```

`package.json` 里的 `@xkit-yx/electron-callkit-vue3-uikit` 版本使用 npm 上已发布的版本。`github/package.json` 中的 `@xkit-yx/electron-callkit-sdk`、`@xkit-yx/callkit-runtime-electron`、`@xkit-yx/callkit-vue3-core` 等依赖需要从 npm registry 或本地 tarball/path 解析。

## 敏感信息

不要把真实 AppKey、账号、Token、签名证书或私钥写入源码。Demo 运行后会在本地 `localStorage` 缓存登录信息，这些运行时数据不应提交。
