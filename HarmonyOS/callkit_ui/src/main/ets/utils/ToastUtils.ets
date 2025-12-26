import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { CallUILog } from './CallUILog';

/**
 * Resource 对象接口，用于访问资源ID
 */
interface ResourceWithId {
  id?: number;
}


export class ToastUtils {
  static TAG = "CallMainPage";
  /**
   * 获取国际化字符串
   * @param resId 资源对象
   * @returns 国际化字符串
   */
  private static getString(context: common.UIAbilityContext, resId: Resource): string {
    try {
      if (context && context.resourceManager) {
        // Resource 对象有 id 属性，使用类型断言访问
        const resourceObj = resId as ResourceWithId;
        if (resourceObj.id !== undefined) {
          return context.resourceManager.getStringSync(resourceObj.id);
        }
      }
    } catch (error) {
      CallUILog.error(ToastUtils.TAG, `getString error: ${error instanceof Error ? error.message : String(error)}`);
    }
    return '';
  }

  /**
   * 显示toast 提示
   * @param message 信息
   */
  public static showToast(context: common.UIAbilityContext, messageRes: Resource): void {
    try {
      const message = ToastUtils.getString(context, messageRes);
      promptAction.showToast({
        message: message,
        duration: 2000
      });
    } catch (error) {
      CallUILog.error(ToastUtils.TAG, `显示 toast 失败: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  /**
   * 显示toast 提示（使用字符串）
   * @param context 上下文
   * @param message 信息字符串
   */
  public static showToastWithString(context: common.UIAbilityContext, message: string): void {
    try {
      promptAction.showToast({
        message: message,
        duration: 2000
      });
    } catch (error) {
      CallUILog.error(ToastUtils.TAG, `显示 toast 失败: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

}