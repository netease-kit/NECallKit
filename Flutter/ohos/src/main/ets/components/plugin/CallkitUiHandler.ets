import { MethodCall, MethodResult, MethodChannel, Any } from '@ohos/flutter_ohos';
import { common } from '@kit.AbilityKit';
import { window, PiPWindow } from '@kit.ArkUI';
import ApplicationStateChangeCallback from '@ohos.app.ability.ApplicationStateChangeCallback';
import { CallState, CallUser, MediaType } from './state/CallState';
import { RingPlayer } from './utils/RingPlayer';
import { CallingVibrator } from './utils/CallingVibrator';
import { CallUILog } from './utils/CallUILog';
import { PermissionManager } from './permission/PermissionManager';
import { FloatWindowManager } from './view/FloatWindowManager';
import { IncomingBannerManager } from './view/IncomingBannerManager';
import { PipManager } from './view/PipManager';
import { commonEventManager } from '@kit.BasicServicesKit';
const TAG = 'CallkitUiHandler';

export class CallkitUiHandler {
  private context: common.UIAbilityContext;
  private ringPlayer: RingPlayer = new RingPlayer();
  private vibrator: CallingVibrator = new CallingVibrator();
  private permManager: PermissionManager = new PermissionManager();
  private isInForeground: boolean = true;
  private stateChangeCallback: ApplicationStateChangeCallback | null = null;
  private channel: MethodChannel | null = null;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
    // 设置 RingPlayer 的 context，用于读取 rawfile 资源
    this.ringPlayer.setContext(context);
    // 启动应用前后台状态监听
    this.startAppStateMonitor();
  }

  /** 启动应用前后台状态监听 */
  private startAppStateMonitor(): void {
    try {
      this.stateChangeCallback = {
        onApplicationForeground: () => {
          CallUILog.i(TAG, 'Application switched to foreground');
          this.isInForeground = true;
          // 通知 Flutter 端应用进入前台
          this.notifyAppEnterForeground();
        },
        onApplicationBackground: () => {
          CallUILog.i(TAG, 'Application switched to background');
          this.isInForeground = false;
          // 通知 Flutter 端应用进入后台
          this.notifyAppEnterBackground();
        }
      };
      const appContext = this.context.getApplicationContext();
      appContext.on('applicationStateChange', this.stateChangeCallback);
      CallUILog.i(TAG, 'App state monitor started');
    } catch (e) {
      CallUILog.e(TAG, `startAppStateMonitor error: ${(e as Error)?.message ?? e}`);
    }
  }

  /** 通知 Flutter 端应用进入前台 */
  private notifyAppEnterForeground(): void {
    if (this.channel !== null) {
      CallUILog.i(TAG, 'Notifying Flutter: appEnterForeground');
      this.channel.invokeMethod('appEnterForeground', {});
    } else {
      CallUILog.w(TAG, 'Cannot notify appEnterForeground: channel is null');
    }
  }

  /** 通知 Flutter 端应用进入后台 */
  private notifyAppEnterBackground(): void {
    if (this.channel !== null) {
      CallUILog.i(TAG, 'Notifying Flutter: appEnterBackground');
      this.channel.invokeMethod('appEnterBackground', {});
    } else {
      CallUILog.w(TAG, 'Cannot notify appEnterBackground: channel is null');
    }
  }

  /** 停止应用前后台状态监听 */
  private stopAppStateMonitor(): void {
    try {
      if (this.stateChangeCallback) {
        const appContext = this.context.getApplicationContext();
        appContext.off('applicationStateChange', this.stateChangeCallback);
        this.stateChangeCallback = null;
        CallUILog.i(TAG, 'App state monitor stopped');
      }
    } catch (e) {
      CallUILog.e(TAG, `stopAppStateMonitor error: ${(e as Error)?.message ?? e}`);
    }
  }

  // 9.2 startRing
  startRing(call: MethodCall, result: MethodResult): void {
    // 使用 call.argument() 方法获取参数，它能正确处理 Map 类型
    const filePathArg: Any = call.argument('filePath');
    const isCalledArg: Any = call.argument('isCalled');
    const filePath: string = (filePathArg !== null && filePathArg !== undefined) ? filePathArg as string : '';
    const isCalled: boolean = (isCalledArg !== null && isCalledArg !== undefined) ? isCalledArg as boolean : false;
    CallUILog.i(TAG, `startRing filePath=${filePath}, isCalled=${isCalled}`);
    this.ringPlayer.startRing(filePath, isCalled).then(() => result.success(0));
    this.vibrator.startVibrate();
  }

  // 9.3 stopRing
  stopRing(call: MethodCall, result: MethodResult): void {
    this.ringPlayer.stopRing().then(() => {});
    this.vibrator.stopVibrate();
    IncomingBannerManager.getInstance().cancelBanner().then(() => {});
    result.success(0);
  }

  // 9.4 updateCallStateToNative
  updateCallStateToNative(call: MethodCall, result: MethodResult): void {
    try {
      const state = CallState.getInstance();
      const previousCallStatus = state.selfUser.callStatus;

      // 使用 call.argument() 方法获取参数，它能正确处理 Map 类型
      const selfUserArg: Any = call.argument('selfUser');
      if (selfUserArg !== null && selfUserArg !== undefined) {
        const selfUser: Map<string, Object> = selfUserArg as Map<string, Object>;
        state.selfUser = {
          // Flutter 端使用 'id' 字段，不是 'accId'
          accId: (selfUser.get('id') ?? '') as string,
          callStatus: (selfUser.get('callStatus') ?? 0) as number,
        };
      }

      const remoteListArg: Any = call.argument('remoteUserList');
      if (remoteListArg !== null && remoteListArg !== undefined) {
        const remoteList: Array<Map<string, Object>> = remoteListArg as Array<Map<string, Object>>;
        state.remoteUserList = [];
        for (const u of remoteList) {
          const user: CallUser = {
            // Flutter 端使用 'id' 字段，不是 'accId'
            accId: (u.get('id') ?? '') as string,
            callStatus: (u.get('callStatus') ?? 0) as number,
            name: (u.get('nickname') ?? u.get('remark') ?? '') as string | undefined,
            avatar: u.get('avatar') as string | undefined,
            videoAvailable: (u.get('videoAvailable') ?? false) as boolean,
          };
          state.remoteUserList.push(user);
        }
      }

      const mediaTypeArg: Any = call.argument('mediaType');
      if (mediaTypeArg !== null && mediaTypeArg !== undefined) {
        state.mediaType = mediaTypeArg as number;
      }

      const startTimeArg: Any = call.argument('startTime');
      if (startTimeArg !== null && startTimeArg !== undefined) {
        state.startTime = startTimeArg as number;
      }

      const enableFloatWindowArg: Any = call.argument('enableFloatWindow');
      if (enableFloatWindowArg !== null && enableFloatWindowArg !== undefined) {
        state.enableFloatWindow = enableFloatWindowArg as boolean;
      }

      const enableFloatWindowOutOfAppArg: Any = call.argument('enableFloatWindowOutOfApp');
      if (enableFloatWindowOutOfAppArg !== null && enableFloatWindowOutOfAppArg !== undefined) {
        state.enableFloatWindowOutOfApp = enableFloatWindowOutOfAppArg as boolean;
      }

      // 检测通话结束（callStatus 从非 none 变为 none），停止画中画和悬浮窗
      // 这样在 logout 时，如果画中画或悬浮窗开着，会被正确关闭
      if (previousCallStatus !== 0 && state.selfUser.callStatus === 0) {
        CallUILog.i(TAG, 'updateCallStateToNative: call ended, stopping PiP and float window');
        PipManager.getInstance().stopPip().catch(() => {});
        FloatWindowManager.getInstance().hideFloatWindow().catch(() => {});
      }

      state.notifyListeners();
      result.success(0);
    } catch (e) {
      CallUILog.e(TAG, `updateCallStateToNative error: ${(e as Error)?.message ?? e}`);
      result.success(0);
    }
  }

  // 9.5 startFloatWindow
  startFloatWindow(call: MethodCall, result: MethodResult): void {
    CallUILog.i(TAG, 'startFloatWindow called');
    FloatWindowManager.getInstance().showFloatWindow(this.context)
      .then(() => {
        CallUILog.i(TAG, 'startFloatWindow success');
        result.success(0);
      })
      .catch((e: Error) => {
        CallUILog.e(TAG, `startFloatWindow failed: ${e?.message ?? e}`);
        result.success(-1);
      });
  }

  // 9.6 stopFloatWindow
  stopFloatWindow(call: MethodCall, result: MethodResult): void {
    FloatWindowManager.getInstance().hideFloatWindow()
      .then(() => result.success(0));
  }

  // 9.7 hasFloatPermission — 鸿蒙子窗口无需特殊权限
  hasFloatPermission(call: MethodCall, result: MethodResult): void {
    result.success(true);
  }

  // 9.8 hasBackgroundStartPermission
  hasBackgroundStartPermission(call: MethodCall, result: MethodResult): void {
    result.success(true);
  }

  // 9.9 requestFloatPermission
  requestFloatPermission(call: MethodCall, result: MethodResult): void {
    result.success(true);
  }

  // 9.10 startToPermissionSetting
  startToPermissionSetting(call: MethodCall, result: MethodResult): void {
    this.permManager.startToPermissionSetting(this.context);
    result.success(0);
  }

  // 9.11 isAppInForeground
  isAppInForeground(call: MethodCall, result: MethodResult): void {
    CallUILog.i(TAG, `isAppInForeground: ${this.isInForeground}`);
    result.success(this.isInForeground);
  }

  // 9.12 showIncomingBanner
  showIncomingBanner(call: MethodCall, result: MethodResult): void {
    IncomingBannerManager.getInstance().showBanner()
      .then(() => result.success(0));
  }

  // 9.13 hasPermissions
  hasPermissions(call: MethodCall, result: MethodResult): void {
    // 使用 call.argument() 方法获取参数，它能正确处理 Map 类型
    const indicesArg: Any = call.argument('permission');
    const indices: number[] = (indicesArg !== null && indicesArg !== undefined) ? indicesArg as number[] : [];
    CallUILog.i(TAG, `hasPermissions indices: ${JSON.stringify(indices)}`);
    const granted = this.permManager.hasPermissions(indices, this.context);
    result.success(granted);
  }

  // 9.14 requestPermissions
  requestPermissions(call: MethodCall, result: MethodResult): void {
    // 使用 call.argument() 方法获取参数，它能正确处理 Map 类型
    const indicesArg: Any = call.argument('permission');
    const indices: number[] = (indicesArg !== null && indicesArg !== undefined) ? indicesArg as number[] : [];
    CallUILog.i(TAG, `requestPermissions indices: ${JSON.stringify(indices)}`);
    this.permManager.requestPermissions(indices, this.context, (res: number) => {
      CallUILog.i(TAG, `requestPermissions result: ${res}`);
      result.success(res);
    });
  }

  // 9.15 pullBackgroundApp
  pullBackgroundApp(call: MethodCall, result: MethodResult): void {
    try {
      this.context.startAbility({
        bundleName: this.context.abilityInfo?.bundleName ?? '',
        abilityName: this.context.abilityInfo?.name ?? '',
      }).catch(() => {});
    } catch (e) { /* 最佳努力 */ }
    result.success(0);
  }

  // 9.16 openLockScreenApp
  openLockScreenApp(call: MethodCall, result: MethodResult): void {
    try {
      window.getLastWindow(this.context).then(w => {
        w.showWindow().catch(() => {});
      }).catch(() => {});
    } catch (e) { /* 最佳努力 */ }
    result.success(0);
  }

  // 9.17 isScreenLocked - 鸿蒙暂不支持检测锁屏状态，返回 false
  isScreenLocked(call: MethodCall, result: MethodResult): void {
    // screenLock API 在鸿蒙 Flutter 插件中不可用，直接返回 false
    result.success(false);
  }

  // 9.18 enableWakeLock
  // 鸿蒙平台已改用 Flutter 端的 wakelock 插件，此方法仅返回成功
  enableWakeLock(call: MethodCall, result: MethodResult): void {
    const enableArg: Any = call.argument('enable');
    const enable: boolean = (enableArg !== null && enableArg !== undefined) ? enableArg as boolean : false;
    CallUILog.i(TAG, `enableWakeLock: ${enable} (handled by Flutter wakelock plugin)`);
    result.success(0);
  }

  // 9.19 initResources
  initResources(call: MethodCall, result: MethodResult): void {
    try {
      // 使用 call.argument() 方法获取参数，它能正确处理 Map 类型
      const resourcesArg: Any = call.argument('resources');
      if (resourcesArg !== null && resourcesArg !== undefined) {
        const resources: Map<string, string> = resourcesArg as Map<string, string>;
        const state = CallState.getInstance();
        resources.forEach((value: string, key: string) => {
          state.resourceMap.set(key, value);
        });
      }
      result.success(0);
    } catch (e) {
      result.success(0);
    }
  }

  // 9.20 cancelIncomingBanner
  cancelIncomingBanner(call: MethodCall, result: MethodResult): void {
    IncomingBannerManager.getInstance().cancelBanner()
      .then(() => result.success(0));
  }

  // 9.21 setIncomingBannerEnabled
  setIncomingBannerEnabled(call: MethodCall, result: MethodResult): void {
    // 使用 call.argument() 方法获取参数，它能正确处理 Map 类型
    const enableArg: Any = call.argument('enable');
    const enable: boolean = (enableArg !== null && enableArg !== undefined) ? enableArg as boolean : true;
    IncomingBannerManager.getInstance().setEnabled(enable);
    result.success(0);
  }

  // 9.22 apiLog — 空实现
  apiLog(call: MethodCall, result: MethodResult): void {
    result.success(0);
  }

  // ==================== 画中画相关方法 ====================

  // 9.23 initPip - 初始化画中画
  initPip(call: MethodCall, result: MethodResult): void {
    try {
      const navigationIdArg: Any = call.argument('navigationId');
      const navigationId: string | undefined = (navigationIdArg !== null && navigationIdArg !== undefined) 
        ? navigationIdArg as string : undefined;
      CallUILog.i(TAG, `initPip: navigationId=${navigationId}`);
      PipManager.getInstance().init(this.context, navigationId);
      result.success(true);
    } catch (e) {
      CallUILog.e(TAG, `initPip error: ${(e as Error)?.message ?? e}`);
      result.success(false);
    }
  }

  // 9.24 startPip - 启动画中画
  startPip(call: MethodCall, result: MethodResult): void {
    CallUILog.i(TAG, 'startPip called');
    PipManager.getInstance().startPip()
      .then(() => result.success(true))
      .catch((e: Error) => {
        CallUILog.e(TAG, `startPip error: ${e?.message ?? e}`);
        result.success(false);
      });
  }

  // 9.25 stopPip - 停止画中画
  stopPip(call: MethodCall, result: MethodResult): void {
    CallUILog.i(TAG, 'stopPip called');
    PipManager.getInstance().stopPip()
      .then(() => result.success(0))
      .catch((e: Error) => {
        CallUILog.e(TAG, `stopPip error: ${e?.message ?? e}`);
        result.success(-1);
      });
  }

  // 9.26 isPipRunning - 检查画中画是否正在运行
  isPipRunning(call: MethodCall, result: MethodResult): void {
    const running = PipManager.getInstance().isPipRunning();
    CallUILog.i(TAG, `isPipRunning: ${running}`);
    result.success(running);
  }

  // 9.27 isPipEnabled - 检查系统是否支持画中画
  isPipEnabled(call: MethodCall, result: MethodResult): void {
    try {
      const enabled = PiPWindow.isPiPEnabled();
      CallUILog.i(TAG, `isPipEnabled: ${enabled}`);
      result.success(enabled);
    } catch (e) {
      CallUILog.e(TAG, `isPipEnabled error: ${(e as Error)?.message ?? e}`);
      result.success(false);
    }
  }

  /** 设置 MethodChannel，用于画中画和前后台状态回调 */
  setMethodChannel(channel: MethodChannel): void {
    this.channel = channel;
    PipManager.getInstance().setChannel(channel);
    FloatWindowManager.getInstance().setChannel(channel);
  }

  /** 插件卸载时释放所有资源 */
  release(): void {
    this.stopAppStateMonitor();
    this.ringPlayer.stopRing().then(() => {});
    this.vibrator.stopVibrate();
    PipManager.getInstance().release();
  }
}
