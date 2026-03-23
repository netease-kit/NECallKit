# @xkit-yx/call-kit-vue3-ui

Vue 3 呼叫 UI 子包，目录结构与 `Web/basic-react/call-kit-ui/` 保持对齐。

## Usage

```vue
<template>
  <CallViewProvider :ne-call-config="neCallConfig" />
  <GroupCallViewProvider :ne-group-call-config="neGroupCallConfig" />
  <RouterView />
</template>
```

- 两个 Provider 都按根节点单例挂载，不包裹业务子树。
- 业务模块可直接调用全局 `call()`、`groupCall()`、`groupJoin()`。
- 音视频外呼与 React demo 对齐，点击发起后直接走 SDK 呼叫链路，不做前置摄像头权限拦截。
- 视频来电接听直接调用 SDK `accept()`，界面在 `onCallConnected` 后切到通话中页。

## Build

```bash
cd /Users/wangshaocong/workspace/NECallKit/Web/basic-vue3/call-kit-ui
npm install
npm run build
```

## Entry

- `src/index.ts`
- `src/components/call-view-provider/index.vue`
- `src/components/group-call-view-provider/index.vue`
