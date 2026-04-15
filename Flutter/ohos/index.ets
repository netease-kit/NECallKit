import CallkitUiPlugin from './src/main/ets/components/plugin/CallkitUiPlugin';
export default CallkitUiPlugin;

// 导出横幅相关组件供页面使用
export { BannerCallbackStore, IncomingCallBannerContent, CallerInfo } from './src/main/ets/components/plugin/view/IncomingBannerManager';

// 导出悬浮窗相关组件供页面使用
export { FloatWindowManager, FLOAT_WIN_NAME } from './src/main/ets/components/plugin/view/FloatWindowManager';
export { FloatWindowUtils, FloatWindowPosition, FloatWindowConstants } from './src/main/ets/components/plugin/view/FloatWindowUtils';
