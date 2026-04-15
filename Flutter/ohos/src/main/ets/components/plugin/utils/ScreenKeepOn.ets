import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { CallUILog } from './CallUILog';

const TAG = 'ScreenKeepOn';

/**
 * 屏幕常亮管理器
 * 用于在音视频通话过程中保持屏幕常亮
 */
export class ScreenKeepOn {
  private isKeepScreenOn: boolean = false;

  /**
   * 设置屏幕常亮
   * @param enable 是否开启屏幕常亮
   * @param windowName 窗口名称，默认为 "mainWindow"
   * @returns Promise<boolean> 设置是否成功
   */
  async setKeepScreenOn(enable: boolean, windowName: string = "mainWindow"): Promise<boolean> {
    if (this.isKeepScreenOn === enable) {
      CallUILog.i(TAG, `ScreenKeepOn already ${enable ? 'enabled' : 'disabled'}`);
      return true;
    }

    try {
      const windowClass: window.Window = await window.getLastWindow(getContext());
      return new Promise<boolean>((resolve) => {
        windowClass.setWindowKeepScreenOn(enable, (err: BusinessError) => {
          if (err.code) {
            CallUILog.e(TAG, `Failed to set screen keep on. Cause: ${JSON.stringify(err)}`);
            resolve(false);
            return;
          }
          this.isKeepScreenOn = enable;
          CallUILog.i(TAG, `Succeeded in setting screen keep on: ${enable}`);
          resolve(true);
        });
      });
    } catch (exception) {
      CallUILog.e(TAG, `Failed to set screen keep on. Exception: ${JSON.stringify(exception)}`);
      return false;
    }
  }

  /**
   * 启用屏幕常亮（幂等）
   */
  async enable(): Promise<boolean> {
    return this.setKeepScreenOn(true);
  }

  /**
   * 禁用屏幕常亮（幂等）
   */
  async disable(): Promise<boolean> {
    return this.setKeepScreenOn(false);
  }

  /**
   * 获取当前屏幕常亮状态
   */
  isEnabled(): boolean {
    return this.isKeepScreenOn;
  }

  /**
   * 插件卸载时释放（防止资源泄漏）
   */
  release(): void {
    this.disable().catch(() => {});
  }
}
