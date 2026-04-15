import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0001;
const TAG = 'CallkitUI';

export class CallUILog {
  static d(tag: string, msg: string): void {
    hilog.debug(DOMAIN, TAG, `[${tag}] ${msg}`);
  }

  static i(tag: string, msg: string): void {
    hilog.info(DOMAIN, TAG, `[${tag}] ${msg}`);
  }

  static w(tag: string, msg: string): void {
    hilog.warn(DOMAIN, TAG, `[${tag}] ${msg}`);
  }

  static e(tag: string, msg: string): void {
    hilog.error(DOMAIN, TAG, `[${tag}] ${msg}`);
  }
}
