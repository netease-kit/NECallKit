# 网易云信 CallKit Vue 3

`basic-vue3/` 目录按 `Web/basic-react/` 的结构组织。

- `call-kit-ui/`：Vue 3 UI 子包，提供 `CallViewProvider`、`GroupCallViewProvider` 和全局 `call()` / `groupCall()` / `groupJoin()`
- 其余宿主演示文件待后续补充；当前交付重点是 `call-kit-ui/`

## 接入约束

- `CallViewProvider`、`GroupCallViewProvider` 需要在宿主应用根节点与业务视图平级各挂载一次。
- 一对一音视频呼叫与 React demo 对齐，点击发起后直接走 SDK 呼叫链路，不做前置摄像头权限拦截。
- 视频来电接听直接走 SDK `accept()`，界面只在收到 `onCallConnected` 后进入通话中页。
- 群呼 `nim.on('msg')` 自定义消息由组件内部处理，宿主应用不需要再手动转发。

## 调试

```bash
cd /Users/wangshaocong/workspace/NECallKit/Web/basic-vue3/call-kit-ui
npm install
npm run build
```
