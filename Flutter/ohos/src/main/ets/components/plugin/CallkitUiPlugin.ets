import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { CallkitUiHandler } from './CallkitUiHandler';
import { FloatWindowManager } from './view/FloatWindowManager';
import { IncomingBannerManager } from './view/IncomingBannerManager';
import { PipManager } from './view/PipManager';
import { CallUILog } from './utils/CallUILog';

const TAG = 'CallkitUiPlugin';
const CHANNEL_NAME = 'call_kit_ui';

/** CallkitUiPlugin — ohos P2P 通话 UI 插件主入口 */
export default class CallkitUiPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private handler: CallkitUiHandler | null = null;

  // 静态变量保存 UIAbilityContext（由宿主应用设置）
  private static uiAbilityContext: common.UIAbilityContext | null = null;

  /**
   * 设置 UIAbilityContext（必须在 Flutter 引擎初始化前调用）
   * 宿主应用需要在 EntryAbility 中调用此方法
   * @param context UIAbilityContext
   */
  public static setUIAbilityContext(context: common.UIAbilityContext): void {
    CallkitUiPlugin.uiAbilityContext = context;
    CallUILog.i(TAG, 'setUIAbilityContext called');
  }

  /**
   * 设置 WindowStage（必须在 EntryAbility.onWindowStageCreate 中调用）
   * 用于支持来电横幅 SubWindow 创建
   * @param windowStage WindowStage
   */
  public static setWindowStage(windowStage: window.WindowStage): void {
    IncomingBannerManager.getInstance().setWindowStage(windowStage);
    CallUILog.i(TAG, 'setWindowStage called for IncomingBanner');
  }

  /**
   * 获取 UIAbilityContext
   * @returns UIAbilityContext 或 null
   */
  public static getUIAbilityContext(): common.UIAbilityContext | null {
    return CallkitUiPlugin.uiAbilityContext;
  }

  getUniqueClassName(): string {
    return 'CallkitUiPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    // 优先使用通过 setUIAbilityContext 设置的 UIAbilityContext
    // 如果未设置，则回退使用 ApplicationContext（可能导致权限请求失败）
    let context: common.Context;
    if (CallkitUiPlugin.uiAbilityContext) {
      context = CallkitUiPlugin.uiAbilityContext;
      CallUILog.i(TAG, 'Using UIAbilityContext');
    } else {
      context = binding.getApplicationContext() as common.Context;
      CallUILog.w(TAG, 'UIAbilityContext not set, falling back to ApplicationContext. Permission requests may fail.');
    }

    // 10.1 注册 MethodChannel
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.channel.setMethodCallHandler(this);

    // 10.1 实例化 Handler
    this.handler = new CallkitUiHandler(context as common.UIAbilityContext);

    // 10.3 注入 channel 引用到 FloatWindowManager、IncomingBannerManager 和 PipManager
    FloatWindowManager.getInstance().setChannel(this.channel);
    IncomingBannerManager.getInstance().setChannel(this.channel);
    IncomingBannerManager.getInstance().setContext(context as common.UIAbilityContext);
    PipManager.getInstance().setChannel(this.channel);
    this.handler.setMethodChannel(this.channel);

    CallUILog.i(TAG, 'onAttachedToEngine');
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    // 10.4 释放所有资源
    this.handler?.release();
    this.handler = null;

    if (this.channel) {
      this.channel.setMethodCallHandler(null);
      this.channel = null;
    }
    CallUILog.i(TAG, 'onDetachedFromEngine');
  }

  // 10.2 方法路由 switch
  onMethodCall(call: MethodCall, result: MethodResult): void {
    const h = this.handler;
    if (!h) { result.notImplemented(); return; }

    switch (call.method) {
      case 'startRing':                 h.startRing(call, result); break;
      case 'stopRing':                  h.stopRing(call, result); break;
      case 'updateCallStateToNative':   h.updateCallStateToNative(call, result); break;
      case 'startFloatWindow':          h.startFloatWindow(call, result); break;
      case 'stopFloatWindow':           h.stopFloatWindow(call, result); break;
      case 'hasFloatPermission':        h.hasFloatPermission(call, result); break;
      case 'hasBackgroundStartPermission': h.hasBackgroundStartPermission(call, result); break;
      case 'startToPermissionSetting':  h.startToPermissionSetting(call, result); break;
      case 'requestFloatPermission':    h.requestFloatPermission(call, result); break;
      case 'isAppInForeground':         h.isAppInForeground(call, result); break;
      case 'showIncomingBanner':        h.showIncomingBanner(call, result); break;
      case 'hasPermissions':            h.hasPermissions(call, result); break;
      case 'requestPermissions':        h.requestPermissions(call, result); break;
      case 'pullBackgroundApp':         h.pullBackgroundApp(call, result); break;
      case 'openLockScreenApp':         h.openLockScreenApp(call, result); break;
      case 'isScreenLocked':            h.isScreenLocked(call, result); break;
      case 'enableWakeLock':            h.enableWakeLock(call, result); break;
      case 'initResources':             h.initResources(call, result); break;
      case 'cancelIncomingBanner':      h.cancelIncomingBanner(call, result); break;
      case 'setIncomingBannerEnabled':  h.setIncomingBannerEnabled(call, result); break;
      case 'apiLog':                    h.apiLog(call, result); break;
      // 画中画相关方法（使用大写 PIP 以匹配 Flutter 端调用）
      case 'setupPIP':                  h.initPip(call, result); break;
      case 'startPIP':                  h.startPip(call, result); break;
      case 'stopPIP':                   h.stopPip(call, result); break;
      case 'disposePIP':                h.stopPip(call, result); break;
      case 'isPipRunning':              h.isPipRunning(call, result); break;
      case 'isPipEnabled':              h.isPipEnabled(call, result); break;
      default:
        CallUILog.w(TAG, `notImplemented: ${call.method}`);
        result.notImplemented();
    }
  }
}