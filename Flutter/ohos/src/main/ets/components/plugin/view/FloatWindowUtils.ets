// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { window, display } from '@kit.ArkUI';
import { CallUILog } from '../utils/CallUILog';

const TAG = 'FloatWindowUtils';

/**
 * 悬浮窗位置信息
 */
export interface FloatWindowPosition {
  x: number;
  y: number;
}

/**
 * 悬浮窗常量配置
 */
export class FloatWindowConstants {
  // 音频悬浮窗尺寸（参考 Android: 72dp x 72dp）
  static readonly AUDIO_FLOAT_WIN_WIDTH: number = 72;   // vp
  static readonly AUDIO_FLOAT_WIN_HEIGHT: number = 72;  // vp
  // 悬浮窗圆角
  static readonly FLOAT_WIN_BORDER_RADIUS: number = 12;
  // 悬浮窗边距
  static readonly FLOAT_WIN_MARGIN: number = 16;        // vp
  // 初始位置（距顶部）
  static readonly INIT_POSITION_Y: number = 200;        // vp
  // 贴边动画时长
  static readonly EDGE_ANIMATION_DURATION: number = 200; // ms
  // 焦点切换延迟
  static readonly CHANGE_FOCUS_DELAY: number = 100;      // ms
}

/**
 * 悬浮窗工具类
 * 提供拖拽、贴边、焦点切换等功能
 */
export class FloatWindowUtils {
  private static uiContext: UIContext | null = null;

  /**
   * 设置 UIContext（用于单位转换）
   */
  static setUIContext(context: UIContext): void {
    FloatWindowUtils.uiContext = context;
  }

  /**
   * vp 转 px
   */
  static vp2px(vp: number): number {
    if (FloatWindowUtils.uiContext) {
      return FloatWindowUtils.uiContext.vp2px(vp);
    }
    // 降级使用 display 的 densityPixels
    const density = display.getDefaultDisplaySync().densityPixels;
    return Math.ceil(vp * density);
  }

  /**
   * 获取屏幕宽度（px）
   */
  static getScreenWidth(): number {
    return display.getDefaultDisplaySync().width;
  }

  /**
   * 获取屏幕高度（px）
   */
  static getScreenHeight(): number {
    return display.getDefaultDisplaySync().height;
  }

  /**
   * 贴边判断 - 将悬浮窗吸附到最近的屏幕边缘
   * @param floatWin 悬浮窗对象
   * @param position 当前位置信息
   */
  static edgeDetermination(floatWin: window.Window, position: FloatWindowPosition): void {
    const screenWidth = FloatWindowUtils.getScreenWidth();
    const winWidth = floatWin.getWindowProperties().windowRect.width;
    const halfWidth = screenWidth * 0.5;

    // 判断靠左还是靠右
    if (position.x + winWidth / 2 < halfWidth) {
      // 靠左贴边
      position.x = 0;
    } else {
      // 靠右贴边
      position.x = screenWidth - winWidth;
    }

    // 移动窗口
    floatWin.moveWindowTo(position.x, position.y);
    CallUILog.d(TAG, `edgeDetermination: moved to (${position.x}, ${position.y})`);
  }

  /**
   * 拖拽移动悬浮窗
   * @param event 手势事件
   * @param floatWin 悬浮窗对象
   * @param position 位置信息（会被修改）
   * @param topSafeArea 顶部安全区域高度
   * @param bottomSafeArea 底部安全区域高度
   */
  static dragToMove(
    event: GestureEvent,
    floatWin: window.Window,
    position: FloatWindowPosition,
    topSafeArea: number,
    bottomSafeArea: number
  ): void {
    const screenHeight = FloatWindowUtils.getScreenHeight();
    const winHeight = floatWin.getWindowProperties().windowRect.height;
    const bottomY = screenHeight - bottomSafeArea - winHeight;

    // 更新 X 坐标
    position.x += event.offsetX;

    // 更新 Y 坐标（限制在安全区域内）
    if (position.y > topSafeArea && position.y < bottomY) {
      position.y += event.offsetY;
    } else if (position.y <= topSafeArea && event.offsetY > 0) {
      position.y += event.offsetY;
    } else if (position.y >= bottomY && event.offsetY < 0) {
      position.y += event.offsetY;
    }

    // 边界限制
    const screenWidth = FloatWindowUtils.getScreenWidth();
    const winWidth = floatWin.getWindowProperties().windowRect.width;
    position.x = Math.max(0, Math.min(position.x, screenWidth - winWidth));
    position.y = Math.max(topSafeArea, Math.min(position.y, bottomY));

    // 移动窗口
    floatWin.moveWindowTo(position.x, position.y);
  }

  /**
   * 切换焦点到主窗口
   * @param windowStage 窗口管理器
   * @param subWindowName 子窗口名称
   */
  static changeFocusToMain(windowStage: window.WindowStage, subWindowName: string): void {
    setTimeout(() => {
      try {
        const subWin = window.findWindow(subWindowName);
        if (!subWin) {
          CallUILog.w(TAG, `changeFocusToMain: subWindow ${subWindowName} not found`);
          return;
        }
        const subWindowId: number = subWin.getWindowProperties().id;
        const mainWindowId: number = windowStage.getMainWindowSync().getWindowProperties().id;
        window.shiftAppWindowFocus(subWindowId, mainWindowId);
        CallUILog.d(TAG, 'changeFocusToMain: focus shifted to main window');
      } catch (e) {
        CallUILog.e(TAG, `changeFocusToMain error: ${(e as Error)?.message ?? e}`);
      }
    }, FloatWindowConstants.CHANGE_FOCUS_DELAY);
  }

  /**
   * 获取状态栏高度
   * @param mainWindow 主窗口
   */
  static async getStatusBarHeight(mainWindow: window.Window): Promise<number> {
    try {
      const avoidArea = await mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      return avoidArea.topRect.height;
    } catch (e) {
      CallUILog.e(TAG, `getStatusBarHeight error: ${(e as Error)?.message ?? e}`);
      return 0;
    }
  }

  /**
   * 获取导航栏高度
   * @param mainWindow 主窗口
   */
  static async getNavigationBarHeight(mainWindow: window.Window): Promise<number> {
    try {
      const avoidArea = await mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      return avoidArea.bottomRect.height;
    } catch (e) {
      CallUILog.e(TAG, `getNavigationBarHeight error: ${(e as Error)?.message ?? e}`);
      return 0;
    }
  }
}
