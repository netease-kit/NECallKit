import { runningLock } from '@kit.BasicServicesKit';
import { CallUILog } from './CallUILog';

const TAG = 'WakeLock';

export class WakeLock {
  private lock: runningLock.RunningLock | null = null;

  /** 启用唤醒锁（幂等） */
  async enable(): Promise<void> {
    if (this.lock) return;
    try {
      this.lock = await runningLock.create('callkit_ui_wakelock', runningLock.RunningLockType.BACKGROUND);
      this.lock.hold(3600000); // 持有 1 小时，通话结束时主动释放
      CallUILog.i(TAG, 'WakeLock enabled');
    } catch (e) {
      CallUILog.e(TAG, `enable failed: ${(e as Error)?.message ?? e}`);
    }
  }

  /** 禁用唤醒锁（幂等） */
  disable(): void {
    if (!this.lock) return;
    try {
      this.lock.unhold();
      CallUILog.i(TAG, 'WakeLock disabled');
    } catch (e) {
      CallUILog.e(TAG, `disable failed: ${(e as Error)?.message ?? e}`);
    } finally {
      this.lock = null;
    }
  }

  /** 插件卸载时强制释放（防止资源泄漏） */
  release(): void {
    this.disable();
  }
}
