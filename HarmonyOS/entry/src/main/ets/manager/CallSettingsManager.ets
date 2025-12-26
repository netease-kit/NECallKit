import { NECallParam } from '@necallkit/callkit/src/main/ets/api/Models';
import common from '@ohos.app.ability.common';
import preferences from '@ohos.data.preferences';

/**
 * 设置数据模型（与 Settings.ets 中的 SettingsModel 保持一致）
 */
export class CallSettingsModel {
  // RTC 设置
  timeout: string = '30';                  // 超时时间
  globalCCParams: string = '';              // 全局抄送参数
  customChannelName: string = '';           // 自定义 channelname
  customRtcUid: string = '';                // 自定义 rtcUid

  enableBlur: boolean = false;              // 虚化

  // 推送设置
  pushEnabled: boolean = true;              // 是否启用推送
  pushTitle: string = '';                   // 推送标题
  pushContent: string = '';                 // 推送内容
  pushPayload: string = '';                  // 推送自定义字段（JSON 字符串）

  // 话单设置
  enableRecordProvider: boolean = false;    // 是否启用自定义话单
}

/**
 * 呼叫设置管理器
 * 负责加载设置数据并应用到呼叫参数
 */
export class CallSettingsManager {
  private static readonly TAG: string = 'CallSettingsManager';
  private preferences: preferences.Preferences | null = null;
  private callSettings: CallSettingsModel = new CallSettingsModel();

  /**
   * 加载设置数据
   * @param context 应用上下文
   */
  async loadSettings(context: common.Context): Promise<void> {
    try {
      const options: preferences.Options = { name: 'callkit_settings' };
      this.preferences = await preferences.getPreferences(context, options);

      // 加载所有设置项
      this.callSettings.timeout = await this.preferences.get('timeout', '30') as string;
      this.callSettings.globalCCParams = await this.preferences.get('globalCCParams', '') as string;
      this.callSettings.customChannelName = await this.preferences.get('customChannelName', '') as string;
      this.callSettings.customRtcUid = await this.preferences.get('customRtcUid', '') as string;
      this.callSettings.enableBlur = await this.preferences.get('enableBlur', false) as boolean;
      this.callSettings.pushEnabled = await this.preferences.get('pushEnabled', true) as boolean;
      this.callSettings.pushTitle = await this.preferences.get('pushTitle', '') as string;
      this.callSettings.pushContent = await this.preferences.get('pushContent', '') as string;
      this.callSettings.pushPayload = await this.preferences.get('pushPayload', '') as string;
      this.callSettings.enableRecordProvider = await this.preferences.get('enableRecordProvider', false) as boolean;

      console.info(`[${CallSettingsManager.TAG}] Settings loaded successfully`);
    } catch (error) {
      console.error(`[${CallSettingsManager.TAG}] loadSettings error:`, error);
    }
  }

  /**
   * 应用设置到呼叫参数
   * @param param 呼叫参数对象
   */
  applySettingsToCallParam(param: NECallParam): void {
    // 应用可以直接设置的参数
    if (this.callSettings.customChannelName) {
      param.rtcChannelName = this.callSettings.customChannelName;
      console.info(`[${CallSettingsManager.TAG}] Applied customChannelName: ${this.callSettings.customChannelName}`);
    }

    if (this.callSettings.globalCCParams) {
      param.globalExtraCopy = this.callSettings.globalCCParams;
      console.info(`[${CallSettingsManager.TAG}] Applied globalCCParams: ${this.callSettings.globalCCParams}`);
    }
  }

  /**
   * 获取设置模型（用于访问其他设置项）
   * @returns 设置模型对象
   */
  getSettings(): CallSettingsModel {
    return this.callSettings;
  }

  /**
   * 更新设置模型（用于从 UI 更新设置）
   * @param settings 新的设置模型
   */
  setSettings(settings: CallSettingsModel): void {
    this.callSettings = settings;
  }

  /**
   * 保存设置数据
   * @param context 应用上下文
   */
  async saveSettings(context: common.Context): Promise<void> {
    try {
      if (!this.preferences) {
        const options: preferences.Options = { name: 'callkit_settings' };
        this.preferences = await preferences.getPreferences(context, options);
      }

      // 保存所有设置项
      await this.preferences.put('timeout', this.callSettings.timeout);
      await this.preferences.put('globalCCParams', this.callSettings.globalCCParams);
      await this.preferences.put('customChannelName', this.callSettings.customChannelName);
      await this.preferences.put('customRtcUid', this.callSettings.customRtcUid);
      await this.preferences.put('enableBlur', this.callSettings.enableBlur);
      await this.preferences.put('pushEnabled', this.callSettings.pushEnabled);
      await this.preferences.put('pushTitle', this.callSettings.pushTitle);
      await this.preferences.put('pushContent', this.callSettings.pushContent);
      await this.preferences.put('pushPayload', this.callSettings.pushPayload);
      await this.preferences.put('enableRecordProvider', this.callSettings.enableRecordProvider);

      await this.preferences.flush();
      console.info(`[${CallSettingsManager.TAG}] Settings saved successfully`);
    } catch (error) {
      console.error(`[${CallSettingsManager.TAG}] saveSettings error:`, error);
    }
  }
}

