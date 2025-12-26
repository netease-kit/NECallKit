import { NECallParam, NECallType, NECallPushConfig, NESelfInfo, NERecordProvider, NERecordConfig, NERtcCallStatus } from '@necallkit/callkit/src/main/ets/api/Models';
import { NECallEngine, NECallUI } from '@necallkit/callkit_ui';
import { CallState } from '@necallkit/callkit_ui/src/main/ets/impl/CallState';
import { CallManager } from '@necallkit/callkit_ui/src/main/ets/impl/CallManager';
import common from '@ohos.app.ability.common';
import router from '@ohos.router';
import { BeautyDataService, BeautyFilterView, BeautyShapeView, BeautySkinView, VideoFuRender } from 'faceunity';
import { NERtcConstants, NERtcSDK, NERtcVideoView } from '@nertc/nertc_sdk';
import { BaseEffectTabs,
  BytedRender,
  ComposerNode, EffectManagerData, EffectTabsController, TabItem  } from 'byteeffect'
import { NEErrorCode } from '@necallkit/callkit';
import { CallSettingsManager } from '../manager/CallSettingsManager';
import { CallRecord } from '../service/CallRecord';
import { CallRecordServiceImpl } from '../service/CallRecordServiceImpl';
import { CallRecordStorage } from '../service/CallRecordStorage';
import { RecordUtils } from '../utils/RecordUtils';
import { UserModel } from '../viewmodel/UserModel';
import { V2NIMMessage, V2NIMMessageService } from '@nimsdk/base';
import promptAction from '@ohos.promptAction';

/**
 * 自定义话单实现
 */
class TestRecordProvider implements NERecordProvider {
  private tag: string = 'TestRecordProvider';

  onRecordSend(config: NERecordConfig): void {
    const callTypeStr = config.callType === NECallType.AUDIO ? '音频' : '视频';
    const callStateStr = this.getCallStateString(config.callState);
    
    const message = `话单回调触发:\n接收者: ${config.accId}\n通话类型: ${callTypeStr}\n通话状态: ${callStateStr}`;
    
    console.info(`[${this.tag}] ${message}`);
    
    // 显示提示信息
    promptAction.showToast({
      message: message,
      duration: 3000,
      bottom: 200
    });
  }

  private getCallStateString(state: NERtcCallStatus): string {
    switch (state) {
      case NERtcCallStatus.COMPLETED:
        return '通话完成';
      case NERtcCallStatus.CANCELED:
        return '通话取消';
      case NERtcCallStatus.REJECTED:
        return '通话拒绝';
      case NERtcCallStatus.TIMEOUT:
        return '超时未接听';
      case NERtcCallStatus.BUSY:
        return '对方忙线';
      default:
        return `未知(${state})`;
    }
  }
}

/**
 * Resource 对象接口，用于访问资源ID
 */
interface ResourceWithId {
  id?: number;
}

/**
 * 本地 AlertDialog 按钮配置类型（与 AlertDialogButtonOptions 结构对齐）
 */
interface LocalAlertDialogButtonOptions {
  value: string;
  action: () => void;
}

@Entry
@Component
export struct SingleCallPage {
  @State targetAccountId: string = '';
  @State callType: NECallType = NECallType.AUDIO;
  @State callRecords: CallRecord[] = [];

  // @State FuBeautyType: config.FUBeautyType = config.FUBeautyType.Skin;
  private fuRender: VideoFuRender|null = null
  private bytedRender: BytedRender|null = null
  private callSettingsManager: CallSettingsManager = new CallSettingsManager();
  private callRecordService: CallRecordServiceImpl | null = null;
  private receiveMessageHandler: ((messages: V2NIMMessage[]) => void) | null = null;
  private sendMessageHandler: ((message: V2NIMMessage) => void) | null = null;
  private testRecordProvider: TestRecordProvider | null = null;

  /**
   * 获取UserModel实例
   */
  getUserModel(): UserModel {
    return UserModel.getInstance(getContext(this));
  }

  /**
   * 获取国际化字符串
   * @param resId 资源对象
   * @returns 国际化字符串
   */
  private getString(resId: Resource): string {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      if (context && context.resourceManager) {
        // Resource 对象有 id 属性，使用类型断言访问
        const resourceObj = resId as ResourceWithId;
        if (resourceObj.id !== undefined) {
          return context.resourceManager.getStringSync(resourceObj.id);
        }
      }
    } catch (error) {
      console.error(`[SingleCall] getString error:`, error);
    }
    return '';
  }

  async aboutToAppear(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    // 初始化通话记录服务
    await this.initCallRecordService(context);

    // 加载通话记录
    await this.loadCallRecords();

    // 注册消息监听
    this.registerMessageListeners();
  }

  async onPageShow(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    // 每次页面出现时都重新加载设置，确保使用最新值
    await this.callSettingsManager.loadSettings(context);

    // 等待加载完成后再应用引擎级别的设置
    this.applySettings();
  }


  aboutToDisappear(): void {
    this.enableBytedEffectBeauty(false)
    this.enableFuLiveBeauty(false)
    // 取消消息监听
    this.unregisterMessageListeners();
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        // 返回按钮
        Text('←')
          .fontSize(24)
          .fontColor('#182431')
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            router.back();
          })

        // 标题
        Text(this.getString($r('app.string.single_call_page_title')))
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 通话设置按钮
        Text(this.getString($r('app.string.single_call_settings_button')))
          .fontSize(16)
          .fontColor('#007DFF')
          .width(80)
          .textAlign(TextAlign.End)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/SettingsPage'
            }).catch((err: Error) => {
              console.error('跳转到设置页面失败:', err);
            });
          })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .padding({ left: 16, right: 16 })

      // 内容区域
      Column() {
          // 用户ID输入区域
          Row() {
            Text(this.getString($r('app.string.single_call_target_account_label')))
              .fontSize(16)
              .fontColor('#182431')
              .width(80)

            TextInput({ placeholder: this.getString($r('app.string.single_call_target_account_placeholder')), text: this.targetAccountId })
              .layoutWeight(1)
              .height(40)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .padding({ left: 12, right: 12 })
              .onChange((value: string) => {
                this.targetAccountId = value;
              })
          }
          .width('100%')
          .padding({
            left: 16,
            right: 16,
            top: 20,
            bottom: 20
          })
          .alignItems(VerticalAlign.Center)

          // 媒体类型选择区域
          Row() {
            Text(this.getString($r('app.string.single_call_type_label')))
              .fontSize(16)
              .fontColor('#182431')
              .width(80)

            Row() {
              // 视频通话选项
              Row() {
                Radio({ value: 'video', group: 'callType' })
                  .checked(this.callType === NECallType.VIDEO)
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.callType = NECallType.VIDEO;
                    }
                  })
                Text(this.getString($r('app.string.single_call_type_video')))
                  .fontSize(16)
                  .fontColor('#182431')
                  .margin({ left: 8 })
              }
              .onClick(() => {
                this.callType = NECallType.VIDEO;
              })
              .margin({ right: 24 })

              // 语音通话选项
              Row() {
                Radio({ value: 'audio', group: 'callType' })
                  .checked(this.callType === NECallType.AUDIO)
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.callType = NECallType.AUDIO;
                    }
                  })
                Text(this.getString($r('app.string.single_call_type_audio')))
                  .fontSize(16)
                  .fontColor('#182431')
                  .margin({ left: 8 })
              }
              .onClick(() => {
                this.callType = NECallType.AUDIO;
              })
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 20 })
          .alignItems(VerticalAlign.Center)

          // 通话记录区域
          Column() {
            Row() {
              Text(this.getString($r('app.string.single_call_history_title')))
                .fontSize(16)
                .fontColor('#182431')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)

              if (this.callRecords.length > 0) {
                Text(this.getString($r('app.string.single_call_history_clear')))
                  .fontSize(14)
                  .fontColor('#007DFF')
                  .onClick(() => {
                    this.clearCallRecords();
                  })
              }
            }
            .width('100%')
            .margin({ bottom: 16 })

            if (this.callRecords.length === 0) {
              Text(this.getString($r('app.string.single_call_history_empty')))
                .fontSize(14)
                .fontColor('#8E8E93')
                .width('100%')
                .textAlign(TextAlign.Center)
                .margin({ top: 40, bottom: 40 })
            } else {
              List() {
                ForEach(this.callRecords, (record: CallRecord, index: number) => {
                  ListItem() {
                    this.buildCallRecordItem(record)
                  }
                }, (record: CallRecord, index: number) => `${record.accountId}-${record.timestamp}-${index}`)
              }
              .width('100%')
              .layoutWeight(1)
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 20 })
          .layoutWeight(1)
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#FFFFFF')

        // 底部发起通话按钮
        Button() {
          Row() {
            Text('📞')
              .fontSize(20)
              .margin({ right: 8 })

          Text(this.getString($r('app.string.single_call_button')))
            .fontSize(16)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
      .type(ButtonType.Normal)
      .width('80%')
      .height(50)
      .backgroundColor('#007DFF')
      .borderRadius(8)
      .margin({ left: 16, right: 16, top: 16, bottom: 16 })
      .onClick(() => {
        this.call()
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  async call() {
    let accountId = this.targetAccountId.trim();

    // 验证输入
    if (!accountId) {
      this.getUIContext().showAlertDialog({
        title: $r('app.string.single_call_alert_title'),
        message: $r('app.string.single_call_alert_message'),
        autoCancel: true,
        alignment: DialogAlignment.Bottom,
        confirm: {
          value: $r('app.string.single_call_alert_confirm'),
          action: () => {
            console.info('[SingleCall] 用户点击了 请输入被呼叫账号ID 提示的确认按钮')
          }
        }
      });
      return;
    }

    // 检查是否呼叫自己
    try {
      const nim = this.getUserModel().getNimSdk();
      const currentUserId: string = nim?.loginService?.getLoginUser?.() ?? '';
      if (currentUserId && currentUserId === accountId) {
        // 不能呼叫自己，弹出国际化提示
        this.getUIContext().showAlertDialog({
          title: $r('app.string.single_call_alert_title'),
          message: $r('app.string.single_call_alert_self'),
          autoCancel: true,
          alignment: DialogAlignment.Bottom,
          confirm: {
            value: $r('app.string.single_call_alert_confirm'),
            action: () => {
              console.info('[SingleCall] 用户尝试呼叫自己，已提示不能呼叫自己');
            }
          }
        });
        return;
      }
    } catch (error) {
      console.error('[SingleCall] 检查是否呼叫自己时出错:', error);
      // 出错时不阻塞正常呼叫流程
    }

    this.enableFuLiveBeauty(true)
    
    // 发起呼叫
    let param = new NECallParam(accountId, this.callType)
    
    // 应用设置到呼叫参数（如 customChannelName, rtcUid, globalCCParams）
    this.callSettingsManager.applySettingsToCallParam(param)

    // 从设置中创建 pushConfig
    const settings = this.callSettingsManager.getSettings();
    if (settings.pushEnabled || settings.pushTitle || settings.pushContent || settings.pushPayload) {
      const pushConfig = new NECallPushConfig();
      pushConfig.pushEnabled = settings.pushEnabled;
      if (settings.pushTitle) {
        pushConfig.pushTitle = settings.pushTitle;
      }
      if (settings.pushContent) {
        pushConfig.pushContent = settings.pushContent;
      }
      if (settings.pushPayload) {
        pushConfig.pushPayload = settings.pushPayload;
      }
      param.pushConfig = pushConfig;
    }

    const result = await NECallUI.getInstance().call(param)

    // 如果权限被拒绝，弹出页面级别的提示对话框（区分麦克风/摄像头）
    if (result && result.code != NEErrorCode.SUCCESS) {
      // 根据错误码选择不同的标题和内容（支持国际化）
      let titleRes: Resource;
      let messageRes: Resource;

      if (result.code === NEErrorCode.ERROR_PERMISSION_DENIED_MICROPHONE) {
        titleRes = $r('app.string.permission_mic_title');
        messageRes = $r('app.string.permission_mic_message');
      } else if (result.code === NEErrorCode.ERROR_PERMISSION_DENIED_CAMERA) {
        titleRes = $r('app.string.permission_camera_title');
        messageRes = $r('app.string.permission_camera_message');
      } else {
        // 其他错误，使用通用文案
        titleRes = $r('app.string.permission_common_title');
        messageRes = $r('app.string.permission_common_message');
      }

      // 使用 UIContext.showAlertDialog(AlertDialogParamWithButtons) 展示两个按钮
      const buttons: LocalAlertDialogButtonOptions[] = [
        {
          // “我知道了” 按钮：仅关闭对话框
          value: this.getString($r('app.string.permission_button_iknow')),
          action: () => {
            console.info('[SingleCall] 用户点击了 我知道了')
          }
        } as LocalAlertDialogButtonOptions,
        {
          // “前往设置” 按钮：跳转到应用设置页面
          value: this.getString($r('app.string.permission_button_goto_settings')),
          action: () => {
            try {
              const context = getContext(this) as common.UIAbilityContext;
              context.startAbility({
                bundleName: 'com.huawei.hmos.settings',
                abilityName: 'com.huawei.hmos.settings.MainAbility',
                uri: 'application_info_entry'
              }).catch((err: Error) => {
                console.error('[SingleCall] 打开系统设置失败:', err);
              });
            } catch (error) {
              console.error('[SingleCall] 打开系统设置异常:', error);
            }
          }
        } as LocalAlertDialogButtonOptions
      ];

      this.getUIContext().showAlertDialog({
        title: titleRes,
        message: messageRes,
        autoCancel: true,
        alignment: DialogAlignment.Center,
        buttons: buttons
      });
      return;
    }

    const callingText = this.getString($r('app.string.single_call_log_calling'));
    const callTypeText = this.callType === NECallType.AUDIO 
      ? this.getString($r('app.string.single_call_log_audio_call'))
      : this.getString($r('app.string.single_call_log_video_call'));
    console.log(`${callingText}: ${accountId}, ${callTypeText}`)
  }

  private enableFuLiveBeauty(enable: boolean) {

    if (this.fuRender == null) {
      this.fuRender = new VideoFuRender()
      this.fuRender.setBundlePath(getContext().filesDir + '/beauty')
      BeautyDataService.sharedInstance().registerFuRender(this.fuRender)
    }

    if (enable) {
      let configMain: NERtcConstants.NERtcVideoEncodeConfiguration = new NERtcConstants.NERtcVideoEncodeConfiguration
      configMain.colorFormat = NERtcConstants.NERtcVideoColorFormat.kNERtcVideoColorFormatI420

      let ret = NERtcSDK.getInstance().setLocalVideoConfig(configMain, NERtcConstants.NERtcVideoStreamType.kNERtcVideoStreamTypeMain)
      if (ret != NERtcConstants.ErrorCode.NO_ERROR) {
      }
      let handle = this.fuRender.getNativeHandle();
      let result = NERtcSDK.getInstance().setExternalVideoProcessPlugin(handle);
      console.info(`Set External video process plugin: ${result}`)
      this.fuRender.enableBeauty(true)

      //set restore value.
      BeautyDataService.sharedInstance().skinViewModel.setAllSkinValues()
      BeautyDataService.sharedInstance().shapeViewModel.setAllShapeValues()
      BeautyDataService.sharedInstance().filterViewModel.setCurrentFilter()
    } else {
      NERtcSDK.getInstance().setExternalVideoProcessPlugin(0n);
      this.fuRender.enableBeauty(false)
    }
  }

  private enableBytedEffectBeauty(enable: boolean) {
    if (this.bytedRender == null) {
      this.bytedRender = new BytedRender()
      const licensePath = "/LicenseBag.bundle/xxxxxx.licbag"
      this.bytedRender.setBundlePath(getContext().filesDir, licensePath)
    }
    if (enable) {
      let configMain: NERtcConstants.NERtcVideoEncodeConfiguration = new NERtcConstants.NERtcVideoEncodeConfiguration
      configMain.colorFormat = NERtcConstants.NERtcVideoColorFormat.kNERtcVideoColorFormatTexture

      let ret = NERtcSDK.getInstance().setLocalVideoConfig(configMain, NERtcConstants.NERtcVideoStreamType.kNERtcVideoStreamTypeMain)
      if (ret != NERtcConstants.ErrorCode.NO_ERROR) {
      }

      let handle = this.bytedRender.getNativeHandle();
      let result = NERtcSDK.getInstance().setExternalVideoProcessPlugin(handle);
      console.info(`SetExternalProcessPlugin result: ${result}`)
      this.bytedRender.enableBeauty(true)
    } else {
      NERtcSDK.getInstance().setExternalVideoProcessPlugin(0n);
      this.bytedRender.enableBeauty(false)
    }
  }

  /**
   * 应用设置
   */
  private applySettings(): void {
    const settings = this.callSettingsManager.getSettings();
    
    // 设置超时时间
    if (settings.timeout) {
      try {
        const timeoutSeconds = parseInt(settings.timeout, 10);
        if (!isNaN(timeoutSeconds) && timeoutSeconds > 0) {
          const result = NECallEngine.getInstance().setTimeout(timeoutSeconds);
          console.info(`[SingleCall] Applied timeout: ${timeoutSeconds}s, result: ${result}`);
        } else {
          console.warn(`[SingleCall] Invalid timeout value: ${settings.timeout}`);
        }
      } catch (error) {
        console.error(`[SingleCall] Failed to apply timeout: ${settings.timeout}`, error);
      }
    }
    
    // 设置自定义 RTC UID
    if (settings.customRtcUid) {
      try {
        const customRtcUid = BigInt(settings.customRtcUid);
        const selfInfo = new NESelfInfo();
        selfInfo.customRtcUid = customRtcUid;
        NECallEngine.getInstance().setSelfInfo(selfInfo).then((result) => {
          if (result.code === 0) {
            console.info(`[SingleCall] Applied customRtcUid: ${settings.customRtcUid}`);
          } else {
            console.error(`[SingleCall] Failed to apply customRtcUid: ${result.message}`);
          }
        });
      } catch (error) {
        console.error(`[SingleCall] Failed to parse customRtcUid: ${settings.customRtcUid}`, error);
      }
    }

    // 设置话单提供者
    try {
      if (settings.enableRecordProvider) {
        // 启用自定义话单
        if (!this.testRecordProvider) {
          this.testRecordProvider = new TestRecordProvider();
        }
        NECallEngine.getInstance().setCallRecordProvider(this.testRecordProvider);
        console.info(`[SingleCall] Applied recordProvider: enabled`);
      } else {
        // 禁用自定义话单（设置为 null，使用默认话单发送）
        NECallEngine.getInstance().setCallRecordProvider(null);
        console.info(`[SingleCall] Applied recordProvider: disabled (use default)`);
      }
    } catch (error) {
      console.error(`[SingleCall] Failed to apply recordProvider:`, error);
    }

    // 设置虚化功能
    try {
      // 设置 CallState 中的 enableBlurBackground
      CallState.instance.enableBlurBackground = settings.enableBlur;
      console.info(`[SingleCall] Applied enableBlur: ${settings.enableBlur}, enableBlurBackground: ${CallState.instance.enableBlurBackground}`);
      
      // 如果启用虚化，调用 enableVirtualBackground
      if (settings.enableBlur) {
        CallManager.instance.enableVirtualBackground(true);
        console.info(`[SingleCall] Applied enableVirtualBackground: true`);
      } else {
        CallManager.instance.enableVirtualBackground(false);
        console.info(`[SingleCall] Applied enableVirtualBackground: false`);
      }
    } catch (error) {
      console.error(`[SingleCall] Failed to apply enableBlur:`, error);
    }
  }

  /**
   * 初始化通话记录服务
   */
  private async initCallRecordService(context: common.Context): Promise<void> {
    try {
      console.info('[SingleCall] Initializing call record service...');
      this.callRecordService = CallRecordServiceImpl.getInstance(context);
      const storage = CallRecordStorage.getInstance();
      await storage.ensureInitialized(context);
      console.info('[SingleCall] Call record service initialized');
    } catch (error) {
      console.error(`[SingleCall] Failed to init call record service: ${error}`);
    }
  }

  /**
   * 加载通话记录
   */
  private async loadCallRecords(): Promise<void> {
    try {
      if (!this.callRecordService) {
        console.warn('[SingleCall] Call record service not initialized');
        return;
      }
      console.info('[SingleCall] Loading call records...');
      // const accountId = await this.callRecordService.getCurrentAccountId();
      const accountId = this.getUserModel().getNimSdk().loginService.getLoginUser();
      console.info(`[SingleCall] Current account ID: ${accountId}`);
      const records = await this.callRecordService.loadCurrentAccountRecords();
      console.info(`[SingleCall] Loaded ${records.length} call records`);
      this.callRecords = records;
      console.info(`[SingleCall] UI updated with ${this.callRecords.length} records`);
    } catch (error) {
      console.error(`[SingleCall] Failed to load call records: ${error}`);
    }
  }

  /**
   * 添加通话记录
   */
  private async addCallRecord(record: CallRecord): Promise<void> {
    try {
      if (!this.callRecordService) {
        console.warn('[SingleCall] Call record service not initialized, cannot add record');
        return;
      }
      console.info(`[SingleCall] Adding call record: accountId=${record.accountId}, isIncoming=${record.isIncoming}, callType=${record.callType}`);
      // 先更新UI
      this.callRecords.unshift(record);
      console.info(`[SingleCall] UI updated, current records count: ${this.callRecords.length}`);
      // 限制记录数量
      if (this.callRecords.length > 100) {
        const removedCount = this.callRecords.length - 100;
        this.callRecords.splice(100);
        console.info(`[SingleCall] Removed ${removedCount} old records from UI`);
      }
      // 保存到存储
      const result = await this.callRecordService.addRecordToCurrentAccount(record);
      console.info(`[SingleCall] Save result: ${result}`);
    } catch (error) {
      console.error(`[SingleCall] Failed to add call record: ${error}`);
    }
  }

  /**
   * 清除通话记录
   */
  private async clearCallRecords(): Promise<void> {
    try {
      if (!this.callRecordService) {
        return;
      }
      this.callRecords = [];
      await this.callRecordService.clearCurrentAccountRecords();
    } catch (error) {
      console.error(`[SingleCall] Failed to clear call records: ${error}`);
    }
  }

  /**
   * 注册消息监听
   */
  private registerMessageListeners(): void {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const nimSdk = this.getUserModel().getNimSdk();
      const messageService: V2NIMMessageService | undefined = nimSdk.messageService;

      if (!messageService) {
        console.warn('[SingleCall] Message service not available');
        return;
      }

      // 监听接收消息
      this.receiveMessageHandler = (messages: V2NIMMessage[]) => {
        console.info(`[SingleCall] onReceiveMessages: received ${messages.length} messages`);
        const nimSdk = this.getUserModel().getNimSdk();
        for (const message of messages) {
          console.info(`[SingleCall] Processing message: messageType=${message.messageType}, messageClientId=${message.messageClientId}`);
          RecordUtils.parseForCallRecord(message, nimSdk).then((record: CallRecord | null) => {
            if (record) {
              console.info(`[SingleCall] Parsed call record from received message: accountId=${record.accountId}`);
              this.addCallRecord(record);
            } else {
              console.info(`[SingleCall] No call record parsed from received message`);
            }
          });
        }
      };

      // 监听发送消息
      this.sendMessageHandler = (message: V2NIMMessage) => {
        console.info(`[SingleCall] onSendMessage: messageType=${message.messageType}, messageClientId=${message.messageClientId}`);
        const nimSdk = this.getUserModel().getNimSdk();
        RecordUtils.parseForCallRecord(message, nimSdk).then((record: CallRecord | null) => {
          if (record) {
            console.info(`[SingleCall] Parsed call record from sent message: accountId=${record.accountId}`);
            this.addCallRecord(record);
          } else {
            console.info(`[SingleCall] No call record parsed from sent message`);
          }
        });
      };

      messageService.on('onReceiveMessages', this.receiveMessageHandler);
      messageService.on('onSendMessage', this.sendMessageHandler);

      console.info('[SingleCall] Message listeners registered');
    } catch (error) {
      console.error(`[SingleCall] Failed to register message listeners: ${error}`);
    }
  }

  /**
   * 取消消息监听
   */
  private unregisterMessageListeners(): void {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const nimSdk = this.getUserModel().getNimSdk();
      const messageService: V2NIMMessageService | undefined = nimSdk.messageService;

      if (!messageService) {
        return;
      }

      if (this.receiveMessageHandler) {
        messageService.off('onReceiveMessages', this.receiveMessageHandler);
        this.receiveMessageHandler = null;
      }

      if (this.sendMessageHandler) {
        messageService.off('onSendMessage', this.sendMessageHandler);
        this.sendMessageHandler = null;
      }

      console.info('[SingleCall] Message listeners unregistered');
    } catch (error) {
      console.error(`[SingleCall] Failed to unregister message listeners: ${error}`);
    }
  }

  /**
   * 构建通话记录项
   */
  @Builder
  buildCallRecordItem(record: CallRecord) {
    Row() {
      // 呼入/呼出图标 - 根据状态和方向决定颜色
      Text(record.isIncoming ? '↓' : '↑')
        .fontSize(20)
        .fontColor(record.status === 1 ? (record.isIncoming ? '#34C759' : '#007DFF') : '#FF3B30')
        .width(24)
        .height(24)
        .textAlign(TextAlign.Center)

      // 对方accountId - 根据状态决定颜色
      Text(record.accountId)
        .fontSize(16)
        .fontColor(record.status === 1 ? '#182431' : '#FF3B30')
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .margin({ left: 12 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      // 通话时长（仅当通话完成时显示）
      if (record.status === 1 && record.duration > 0) {
        Text(this.formatDuration(record.duration))
          .fontSize(14)
          .fontColor('#8E8E93')
          .margin({ right: 8 })
      }

      // 时间
      Text(this.formatTimestamp(record.timestamp))
        .fontSize(14)
        .fontColor('#8E8E93')
        .margin({ right: 8 })

      // 通话类型图标
      Text(record.callType === NECallType.VIDEO ? '📹' : '📞')
        .fontSize(16)
    }
    .width('100%')
    .height(56)
    .padding({ left: 12, right: 12 })
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
    .margin({ bottom: 8 })
    .onClick(() => {
      this.callFromRecord(record);
    })
  }

  /**
   * 格式化时间戳
   */
  private formatTimestamp(timestamp: number): string {
    const now = Date.now();
    const today = new Date(now);
    today.setHours(0, 0, 0, 0);
    const recordDate = new Date(timestamp);
    recordDate.setHours(0, 0, 0, 0);

    if (recordDate.getTime() === today.getTime()) {
      // 今天显示时间
      const date = new Date(timestamp);
      const hours = date.getHours().toString().padStart(2, '0');
      const minutes = date.getMinutes().toString().padStart(2, '0');
      const seconds = date.getSeconds().toString().padStart(2, '0');
      return `${hours}:${minutes}:${seconds}`;
    } else {
      // 其他日期显示完整日期和时间
      const date = new Date(timestamp);
      const month = date.getMonth() + 1;
      const day = date.getDate();
      const hours = date.getHours().toString().padStart(2, '0');
      const minutes = date.getMinutes().toString().padStart(2, '0');
      return `${month}月${day}日 ${hours}:${minutes}`;
    }
  }

  /**
   * 格式化通话时长（秒转换为 mm:ss 或 hh:mm:ss 格式）
   */
  private formatDuration(seconds: number): string {
    if (seconds <= 0) {
      return '00:00';
    }
    
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;
    
    if (hours > 0) {
      return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    } else {
      return `${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    }
  }

  /**
   * 从记录发起通话
   */
  private callFromRecord(record: CallRecord): void {
    // 设置被叫用户ID
    this.targetAccountId = record.accountId;
    // 设置通话类型
    this.callType = record.callType;
    // 发起通话
    this.call();
  }

}
