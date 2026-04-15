import { window, display } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { MethodChannel } from '@ohos/flutter_ohos';
import { CallState, CallStateListener, MediaType } from '../state/CallState';
import { CallUILog } from '../utils/CallUILog';
import { BannerWindowStore } from './IncomingBannerManager';
import { FloatWindowUtils, FloatWindowPosition, FloatWindowConstants } from './FloatWindowUtils';

const TAG = 'FloatWindowManager';
export const FLOAT_WIN_NAME = 'callkit_audio_float';

/**
 * 悬浮窗管理器
 * 用于管理音频通话的悬浮窗，支持拖拽、贴边功能
 * 
 * 参考 Android FloatingView 和 HarmonyOS SubWindow 示例实现
 */
export class FloatWindowManager {
  private static inst: FloatWindowManager | null = null;
  private channel: MethodChannel | null = null;
  private floatWin: window.Window | null = null;
  private stateListener: CallStateListener | null = null;
  
  // 悬浮窗位置信息
  private windowPosition: FloatWindowPosition = { x: 0, y: 0 };
  // 顶部安全区域高度（状态栏）
  private topSafeArea: number = 0;
  // 底部安全区域高度（导航栏）
  private bottomSafeArea: number = 0;
  // WindowStage 引用
  private windowStage: window.WindowStage | null = null;

  private constructor() {}

  static getInstance(): FloatWindowManager {
    if (!FloatWindowManager.inst) {
      FloatWindowManager.inst = new FloatWindowManager();
    }
    return FloatWindowManager.inst;
  }

  setChannel(channel: MethodChannel): void {
    this.channel = channel;
  }

  /**
   * 获取悬浮窗当前位置
   */
  getWindowPosition(): FloatWindowPosition {
    return this.windowPosition;
  }

  /**
   * 获取顶部安全区域高度
   */
  getTopSafeArea(): number {
    return this.topSafeArea;
  }

  /**
   * 获取底部安全区域高度
   */
  getBottomSafeArea(): number {
    return this.bottomSafeArea;
  }

  /**
   * 获取悬浮窗对象
   */
  getFloatWindow(): window.Window | null {
    return this.floatWin;
  }

  /**
   * 获取 WindowStage
   */
  getWindowStage(): window.WindowStage | null {
    return this.windowStage;
  }

  /** 显示通话浮窗（用于音频通话） */
  async showFloatWindow(context: common.UIAbilityContext): Promise<void> {
    if (this.floatWin) {
      CallUILog.i(TAG, 'float window already shown');
      return;
    }

    try {
      // 获取 WindowStage（与来电横幅使用相同方式）
      const windowStage = BannerWindowStore.windowStage;
      if (!windowStage) {
        CallUILog.e(TAG, 'showFloatWindow: windowStage not set');
        return;
      }
      this.windowStage = windowStage;

      // 获取当前通话类型（用于日志）
      const state = CallState.getInstance();

      const winWidthVp = FloatWindowConstants.AUDIO_FLOAT_WIN_WIDTH;
      const winHeightVp = FloatWindowConstants.AUDIO_FLOAT_WIN_HEIGHT;

      CallUILog.i(TAG, `showFloatWindow: mediaType=${state.mediaType}, size=${winWidthVp}x${winHeightVp}`);

      // 使用 windowStage.createSubWindow 创建子窗口
      const subWin = await windowStage.createSubWindow(FLOAT_WIN_NAME);
      if (!subWin) {
        CallUILog.e(TAG, 'showFloatWindow: createSubWindow returned null');
        return;
      }
      this.floatWin = subWin;

      // 计算尺寸和位置
      const mainWindow = await windowStage.getMainWindow();
      const props = mainWindow.getWindowProperties();
      const screenWidth = props.windowRect.width;
      const density = display.getDefaultDisplaySync().densityPixels;
      const winWidthPx = Math.ceil(winWidthVp * density);
      const winHeightPx = Math.ceil(winHeightVp * density);

      // 获取安全区域高度
      this.topSafeArea = await FloatWindowUtils.getStatusBarHeight(mainWindow);
      this.bottomSafeArea = await FloatWindowUtils.getNavigationBarHeight(mainWindow);

      // 存储安全区域到 AppStorage（供 FloatWindowPage 使用）
      AppStorage.setOrCreate('float_top_safe_area', this.topSafeArea);
      AppStorage.setOrCreate('float_bottom_safe_area', this.bottomSafeArea);

      // 初始化 AppStorage 状态（在 setUIContent 之前）
      AppStorage.setOrCreate('float_media_type', state.mediaType);
      const remote = state.remoteUserList[0];
      AppStorage.setOrCreate('float_remote_accid', remote?.accId ?? '');
      AppStorage.setOrCreate('float_remote_name', remote?.name ?? '');
      AppStorage.setOrCreate('float_start_time', state.startTime);

      // 设置窗口内容（使用 loadContent，与来电横幅一致）
      await subWin.loadContent('pages/FloatWindowPage');
      await subWin.setWindowBackgroundColor('#00000000');
      await subWin.resize(winWidthPx, winHeightPx);
      
      // 初始位置：右上角（距离右边 marginVp，顶部状态栏下方 initY）
      const marginPx = Math.ceil(FloatWindowConstants.FLOAT_WIN_MARGIN * density);
      const initYPx = this.topSafeArea + Math.ceil(FloatWindowConstants.INIT_POSITION_Y * density);
      this.windowPosition = {
        x: screenWidth - winWidthPx - marginPx,
        y: initYPx
      };
      
      // 存储初始位置到 AppStorage
      AppStorage.setOrCreate('float_position_x', this.windowPosition.x);
      AppStorage.setOrCreate('float_position_y', this.windowPosition.y);
      
      await subWin.moveWindowTo(this.windowPosition.x, this.windowPosition.y);
      await subWin.showWindow();

      // 切换焦点到主窗口，避免悬浮窗抢占焦点
      FloatWindowUtils.changeFocusToMain(windowStage, FLOAT_WIN_NAME);

      // 订阅 CallState 变化刷新浮窗
      this.stateListener = () => {
        this.refreshFloatWindowUI();
      };
      CallState.getInstance().addListener(this.stateListener);

      CallUILog.i(TAG, `showFloatWindow success, position=(${this.windowPosition.x}, ${this.windowPosition.y})`);
    } catch (e) {
      CallUILog.e(TAG, `showFloatWindow failed: ${(e as Error)?.message ?? e}`);
    }
  }

  /**
   * 更新悬浮窗位置（由 FloatWindowPage 拖拽时调用）
   */
  updateWindowPosition(x: number, y: number): void {
    this.windowPosition.x = x;
    this.windowPosition.y = y;
    AppStorage.setOrCreate('float_position_x', x);
    AppStorage.setOrCreate('float_position_y', y);
  }

  /**
   * 执行贴边吸附
   */
  performEdgeSnap(): void {
    if (!this.floatWin) return;
    FloatWindowUtils.edgeDetermination(this.floatWin, this.windowPosition);
    AppStorage.setOrCreate('float_position_x', this.windowPosition.x);
    AppStorage.setOrCreate('float_position_y', this.windowPosition.y);
    
    // 切换焦点到主窗口
    if (this.windowStage) {
      FloatWindowUtils.changeFocusToMain(this.windowStage, FLOAT_WIN_NAME);
    }
  }

  /** 隐藏/销毁浮窗 */
  async hideFloatWindow(): Promise<void> {
    if (!this.floatWin) return;

    // 注销状态监听
    if (this.stateListener) {
      CallState.getInstance().removeListener(this.stateListener);
      this.stateListener = null;
    }

    try {
      await this.floatWin.destroyWindow();
      CallUILog.i(TAG, 'hideFloatWindow: destroyed');
    } catch (e) {
      CallUILog.e(TAG, `hideFloatWindow error: ${(e as Error)?.message ?? e}`);
    } finally {
      this.floatWin = null;
      this.windowStage = null;
    }
  }

  /** 刷新浮窗 UI（媒体类型变化等） */
  private refreshFloatWindowUI(): void {
    // 通过 AppStorage 与浮窗页面共享状态
    const state = CallState.getInstance();
    AppStorage.setOrCreate('float_media_type', state.mediaType);
    const remote = state.remoteUserList[0];
    AppStorage.setOrCreate('float_remote_accid', remote?.accId ?? '');
    AppStorage.setOrCreate('float_remote_name', remote?.name ?? '');
    AppStorage.setOrCreate('float_start_time', state.startTime);
  }

  /** 处理浮窗点击（由 FloatWindowPage 页面调用） */
  onFloatWindowTapped(): void {
    CallUILog.i(TAG, 'float window tapped → close float window and back to calling page');
    // 先关闭悬浮窗，再通知 Flutter 返回通话页面（参考 iOS 实现）
    this.hideFloatWindow().then(() => {
      this.channel?.invokeMethod('backCallingPageFromFloatWindow', {});
    });
  }
}