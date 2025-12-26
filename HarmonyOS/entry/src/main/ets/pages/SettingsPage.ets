import router from '@ohos.router';
import {SettingRow} from './view/SettingRow'
import { CallSettingsManager, CallSettingsModel } from '../manager/CallSettingsManager';

@Entry
@Component
export struct SettingPage {
  @State settingsModel: CallSettingsModel = new CallSettingsModel();
  private callSettingsManager: CallSettingsManager = new CallSettingsManager();
  private readonly TAG: string = 'Settings';

  aboutToAppear(): void {
    this.loadSettings();
  }

  /**
   * 加载设置数据
   */
  async loadSettings(): Promise<void> {
    try {
      const context = getContext(this);
      await this.callSettingsManager.loadSettings(context);
      // 从 CallSettingsManager 获取设置并更新到本地状态（创建新对象避免引用问题）
      const settings = this.callSettingsManager.getSettings();
      this.settingsModel.timeout = settings.timeout;
      this.settingsModel.globalCCParams = settings.globalCCParams;
      this.settingsModel.customChannelName = settings.customChannelName;
      this.settingsModel.customRtcUid = settings.customRtcUid;
      this.settingsModel.enableBlur = settings.enableBlur;
      this.settingsModel.pushEnabled = settings.pushEnabled;
      this.settingsModel.pushTitle = settings.pushTitle;
      this.settingsModel.pushContent = settings.pushContent;
      this.settingsModel.pushPayload = settings.pushPayload;
      this.settingsModel.enableRecordProvider = settings.enableRecordProvider;
    } catch (error) {
      console.error(`[${this.TAG}] loadSettings error:`, error);
    }
  }

  /**
   * 保存设置数据
   */
  async saveSettings(): Promise<void> {
    try {
      const context = getContext(this);
      // 更新 CallSettingsManager 中的设置
      this.callSettingsManager.setSettings(this.settingsModel);
      // 保存到 preferences
      await this.callSettingsManager.saveSettings(context);
      console.info(`[${this.TAG}] Settings saved successfully`);
    } catch (error) {
      console.error(`[${this.TAG}] saveSettings error:`, error);
    }
  }



  /**
   * 链接类型设置项组件（居中显示）
   */
  @Builder
  LinkRow(text: string, onClick: () => void) {
    Row() {
      Text(text)
        .fontSize(16)
        .fontColor('#007AFF')
        .onClick(onClick)
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }

  /**
   * 分类标题组件
   */
  @Builder
  SectionTitle(title: string) {
    Text(title)
      .fontSize(14)
      .fontColor('#8E8E93')
      .fontWeight(FontWeight.Medium)
      .width('100%')
      .padding({ left: 16, right: 16, top: 24, bottom: 8 })
      .textAlign(TextAlign.Start)
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('取消')
          .fontSize(16)
          .fontColor('#007AFF')
          .onClick(() => {
            router.back();
          })

        Text('设置')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('保存')
          .fontSize(16)
          .fontColor('#007AFF')
          .onClick(async () => {
            await this.saveSettings();
            // 保存后返回，SingleCall 页面会在 aboutToAppear 中重新加载设置
            router.back();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#1C1C1E')

      // 内容区域
      Scroll() {
        Column() {
          // ========== 组件设置 ==========
          this.SectionTitle('组件设置')

          // 超时时间
          SettingRow({ label: "超时时间" }) {
            TextInput({ text: this.settingsModel.timeout, placeholder: '30' })
              .width(100)
              .height(36)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .padding({ left: 8, right: 8 })
              .onChange((value: string) => {
                this.settingsModel.timeout = value;
              })
          }

          // 全局抄送参数
          SettingRow({ label: "全局抄送参数" }) {
            TextInput({ text: this.settingsModel.globalCCParams, placeholder: '' })
              .width(200)
              .height(36)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .padding({ left: 8, right: 8 })
              .onChange((value: string) => {
                this.settingsModel.globalCCParams = value;
              })
          }

          // 自定义 channelname
          SettingRow({ label: "自定义 channelname" }) {
            TextInput({ text: this.settingsModel.customChannelName, placeholder: '' })
              .width(200)
              .height(36)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .padding({ left: 8, right: 8 })
              .onChange((value: string) => {
                this.settingsModel.customChannelName = value;
              })
          }

          // 自定义 rtcUid
          SettingRow({ label: "自定义 rtcUid" }) {
            TextInput({ text: this.settingsModel.customRtcUid, placeholder: '' })
              .width(200)
              .height(36)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .padding({ left: 8, right: 8 })
              .onChange((value: string) => {
                this.settingsModel.customRtcUid = value;
              })
          }

          // ========== UI 设置 ==========
          this.SectionTitle('UI 设置')

          // 虚化
          SettingRow({ label: "虚化" }) {
            Toggle({ type: ToggleType.Switch, isOn: this.settingsModel.enableBlur })
              .onChange((isOn: boolean) => {
                this.settingsModel.enableBlur = isOn;
              })
          }

          // ========== 推送设置 ==========
          this.SectionTitle('推送设置')

          // 启用推送
          SettingRow({ label: "启用推送" }) {
            Toggle({ type: ToggleType.Switch, isOn: this.settingsModel.pushEnabled })
              .onChange((isOn: boolean) => {
                this.settingsModel.pushEnabled = isOn;
              })
          }

          // 推送标题
          SettingRow({ label: "推送标题" }) {
            TextInput({ text: this.settingsModel.pushTitle, placeholder: '推送标题' })
              .width(200)
              .height(36)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .padding({ left: 8, right: 8 })
              .onChange((value: string) => {
                this.settingsModel.pushTitle = value;
              })
          }

          // 推送内容
          SettingRow({ label: "推送内容" }) {
            TextInput({ text: this.settingsModel.pushContent, placeholder: '推送内容' })
              .width(200)
              .height(36)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .padding({ left: 8, right: 8 })
              .onChange((value: string) => {
                this.settingsModel.pushContent = value;
              })
          }

          // 推送自定义字段（JSON 字符串）
          SettingRow({ label: "推送Payload" }) {
            TextInput({ text: this.settingsModel.pushPayload, placeholder: '{"userID":"xxx","customField1":"value1"}' })
              .width(200)
              .height(36)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .padding({ left: 8, right: 8 })
              .onChange((value: string) => {
                this.settingsModel.pushPayload = value;
              })
          }

          // ========== 话单设置 ==========
          this.SectionTitle('话单设置')

          // 启用自定义话单
          SettingRow({ label: "启用自定义话单" }) {
            Toggle({ type: ToggleType.Switch, isOn: this.settingsModel.enableRecordProvider })
              .onChange((isOn: boolean) => {
                this.settingsModel.enableRecordProvider = isOn;
              })
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#1C1C1E')
  }
}

