import { vibrator } from '@kit.SensorServiceKit';
import { CallUILog } from './CallUILog';

const TAG = 'CallingVibrator';

export class CallingVibrator {
  private vibrating: boolean = false;

  /** 开始振动（来电铃声振动模式，循环） */
  startVibrate(): void {
    if (this.vibrating) return;
    try {
      vibrator.startVibration(
        { type: 'preset', effectId: 'haptic.ringtone.Ripple', count: -1, intensity: 100 },
        { usage: 'ring' }
      );
      this.vibrating = true;
      CallUILog.i(TAG, 'startVibrate');
    } catch (e) {
      CallUILog.w(TAG, `startVibrate failed (device may not support): ${(e as Error)?.message ?? e}`);
    }
  }

  /** 停止振动 */
  stopVibrate(): void {
    if (!this.vibrating) return;
    try {
      vibrator.stopVibration();
      CallUILog.i(TAG, 'stopVibrate');
    } catch (e) {
      CallUILog.w(TAG, `stopVibrate failed: ${(e as Error)?.message ?? e}`);
    } finally {
      this.vibrating = false;
    }
  }
}
