# Changelog

本文件记录 `@xkit-yx/electron-callkit-vue3-uikit` 对外发布的版本与重要变更。

## [4.6.0-rc.3] - 2026-05-22

### Runtime 补包发布候选

- 依赖 `@xkit-yx/electron-callkit-sdk@4.6.0-rc.3`
- Vue3 UIKit tarball 继续只承载 UI / runtime 适配层，native runtime 由 bundled SDK -> node-addon 统一提供
- 修复已发布 npm 包缺少 RTC / observability runtime 导致安装后无法直接解析 native companion 的问题

## [4.6.0-rc.1] - 2026-05-11

### 首次对外发布候选（Release Candidate）

- 首次在 npm registry 发布 `@xkit-yx/electron-callkit-vue3-uikit`，dist-tag = `next`
- 提供 Electron Vue 3 1v1 通话 UI 组件
  - `CallViewProvider`
  - `createCallkitRuntime` / `createIpcCallkitRuntime`
  - `useCall` / `useCallState` / `useCallkitRuntime`
- 闭包带 `@xkit-yx/electron-callkit-sdk`、`@xkit-yx/callkit-vue3-core`、`@xkit-yx/callkit-runtime-electron`、`@xkit-yx/callkit-domain` 与 `@xkit-yx/electron-callkit-node-addon`
- 默认主叫呼叫音与被叫来电铃声随包发布到 `src/assets/audios/`，宿主可通过 preload host 自定义覆盖
- 提供 `runtime-env` 子路径 helper，简化宿主自动装配
- peer dependencies：`electron >=25`、`vue ^3.4.0`

### 已知限制

- 本 RC 仅包含打包机本地平台的 Release native addon；多平台 prebuilds 在 4.6.0 GA 一起发布
- 群呼能力暂不支持
