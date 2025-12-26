import router from '@ohos.router';
import { UserModel } from '../viewmodel/UserModel';
import { NECallUI } from '@necallkit/callkit_ui';
import { CallUILog } from '@necallkit/callkit_ui/src/main/ets/utils/CallUILog';
import { NECallEngine } from '@necallkit/callkit';
import { BusinessError } from '@ohos.base';
import { systemDateTime } from '@kit.BasicServicesKit';
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager';
import wantAgent, { WantAgent } from '@ohos.app.ability.wantAgent';
import avSession from '@ohos.multimedia.avsession';
import common from '@ohos.app.ability.common';
import { CallRecord } from '../service/CallRecord';
import { CallRecordServiceImpl } from '../service/CallRecordServiceImpl';
import { CallRecordStorage } from '../service/CallRecordStorage';
import { RecordUtils } from '../utils/RecordUtils';
import { V2NIMMessage, V2NIMMessageService, V2NIMKickedOfflineDetail } from '@nimsdk/base';


let TAG: string = 'HomePage'

@Entry
@Component
export struct HomePage {
  @State accountId: string = '';
  @State nickname: string = '';
  @State avatar: string = '';
  @State version: string = '';

  private av_session: avSession.AVSession|null = null;
  private callRecordService: CallRecordServiceImpl | null = null;
  private receiveMessageHandler: ((messages: V2NIMMessage[]) => void) | null = null;
  private isPageVisible: boolean = false;
  private kickedOfflineHandler: ((detail: V2NIMKickedOfflineDetail) => void) | null = null;

  private getUserModel(): UserModel {
    return UserModel.getInstance(getContext(this));
  }

  async aboutToAppear(): Promise<void> {
    try {
      // 从全局存储中读取当前登录账号
      const storedAccountId = AppStorage.get<string>('currentAccountId');
      this.accountId = storedAccountId ?? '';
      this.nickname = storedAccountId ?? '';

      // 获取应用版本号
      try {
        this.version = NECallEngine.version();
        CallUILog.info('HomePage', `应用版本: ${this.version}`);
      } catch (error) {
        CallUILog.error('HomePage', `获取版本号失败: ${error instanceof Error ? error.message : String(error)}`);
        this.version = '';
      }

      // 异步加载用户资料（昵称、头像）
      if (this.accountId.length > 0) {
        this.loadUserProfile(this.accountId);
      }

      // 初始化通话记录服务并注册消息监听
      const context = getContext(this) as common.UIAbilityContext;
      await this.initCallRecordService(context);
      this.registerMessageListeners();

      // 注册被踢下线监听
      this.registerKickedOfflineListener();

      this.enableBackgroundRunning(true);
    } catch (error) {
      CallUILog.error('HomePage', `aboutToAppear error: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  onPageShow(): void {
    // 页面显示时，标记为可见
    this.isPageVisible = true;
    CallUILog.info('HomePage', 'onPageShow: page is visible');
  }

  onPageHide(): void {
    // 页面隐藏时，标记为不可见
    this.isPageVisible = false;
    CallUILog.info('HomePage', 'onPageHide: page is hidden');
  }

  private async loadUserProfile(accountId: string): Promise<void> {
    try {
      const userModel = this.getUserModel();
      const nim = userModel.getNimSdk();
      if (!nim || !nim.userService) {
        CallUILog.warn('HomePage', 'NIM userService 不可用，无法获取用户资料');
        return;
      }

      // 使用 NIM 接口获取用户资料列表
      const userProfiles = await nim.userService.getUserList([accountId]);
      if (userProfiles && userProfiles.length > 0) {
        const profile = userProfiles[0];
        // 根据实际字段名读取昵称和头像，这里假设为 name / avatar
        if (profile.name && profile.name.length > 0) {
          this.nickname = profile.name;
        }
        if (profile.avatar && profile.avatar.length > 0) {
          this.avatar = profile.avatar;
        }
        CallUILog.info('HomePage',
          `加载用户资料成功: accid=${accountId}, nickname=${this.nickname}, avatar=${this.avatar}`);
      } else {
        CallUILog.warn('HomePage', `未获取到用户资料: accid=${accountId}`);
      }
    } catch (error) {
      CallUILog.error('HomePage',
        `获取用户资料失败: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  private async doLogout(): Promise<void> {
    CallUILog.info('HomePage', '开始退出登录');
    try {
      const userModel = this.getUserModel();
      const nim = userModel.getNimSdk();
      if (nim) {
        await nim.loginService.logout();
        CallUILog.info('HomePage', 'NIM 登出成功');
      }
    } catch (error) {
      CallUILog.error('HomePage',
        `NIM 登出失败: ${error instanceof Error ? error.message : String(error)}`);
    }
    try {
      await NECallUI.getInstance().logout();
      CallUILog.info('HomePage', 'NECallUI.logout 成功');
    } catch (error) {
      CallUILog.error('HomePage',
        `NECallUI.logout 失败: ${error instanceof Error ? error.message : String(error)}`);
    }

    // 清除当前账号信息
    AppStorage.delete('currentAccountId');

    // 使用 replaceUrl 返回登录页面，销毁当前 HomePage
    router.replaceUrl({
      url: 'pages/Index'
    }).catch((err: Error) => {
      console.error('[HomePage] 跳转到登录页面失败:', err);
    });
  }

  private showLogoutDialog(): void {
    AlertDialog.show({
      title: '提示',
      message: '是否退出登录？',
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '确定',
        action: () => {
          this.doLogout();
        }
      },
      secondaryButton: {
        value: '取消',
        action: () => {
          CallUILog.info('HomePage', '用户取消退出登录');
        }
      }
    });
  }

  enableBackgroundRunning(enable:boolean): void {
    if (enable) {
      this.startBackgroundRunning();
    } else {
      this.stopBackgroundRunning();
    }
  }

  createAVSession(): void {
    avSession.createAVSession(getContext(this), TAG, "video").then((session: avSession.AVSession) => {
      console.info(TAG , "createAVSession succeed");
      this.av_session = session;
    }).catch((err: BusinessError) => {
      console.error(TAG, `createAVSession failed, code:${err.code}, message:${err.message}`);
    })
  }

  destroyAVSession(): void {
    this.av_session?.deactivate().then(() => {
      this.av_session?.destroy().then(() => {
        this.av_session = null;
      }).catch((err: BusinessError) => {
        console.error(TAG, `destroy avSession failed, code:${err.code}, message:${err.message}`);
      });
    }).catch((err: BusinessError) => {
      console.error(TAG, `deactivate avSession failed, code:${err.code}, message:${err.message}`);
    });
  }
  startBackgroundRunning(): void {
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      // 点击通知后，将要执行的动作列表
      // 添加需要被拉起应用的bundleName和abilityName
      wants: [
        {
          bundleName: "com.netease.yunxin.app.hm.videocall",
          abilityName: "EntryAbility"
        }
      ],
      // 指定点击通知栏消息后的动作是拉起ability
      actionType: wantAgent.OperationType.START_ABILITY,
      // 使用者自定义的一个私有值
      requestCode: 0,
      // 点击通知后，动作执行属性
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };
    // 通过wantAgent模块下getWantAgent方法获取WantAgent对象
    wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: WantAgent) => {
      let backgroundModes: string[] = ["audioRecording", "audioPlayback"];
      backgroundTaskManager.startBackgroundRunning(getContext(this), backgroundModes, wantAgentObj).then((taskNotification: backgroundTaskManager.ContinuousTaskNotification) => {
        console.info(TAG, `startBackgroundRunning succeed`);
      }).catch((err: BusinessError) => {
        console.error(TAG, `startBackgroundRunning failed, code:${err.code}, message:${err.message}`);
      });
    });
  }

  stopBackgroundRunning(): void {
    backgroundTaskManager.stopBackgroundRunning(getContext(this)).then(() => {
      console.info(TAG, `stopBackgroundRunning succeed`);
    }).catch((err: BusinessError) => {
      console.error(TAG, `stopBackgroundRunning failed, code:${err.code}, message:${err.message}`);
    });
  }

  aboutToDisappear(): void {
    try {
      // 取消消息监听
      this.unregisterMessageListeners();
      // 取消被踢下线监听
      this.unregisterKickedOfflineListener();
    } catch (error) {
      CallUILog.error('HomePage', `aboutToDisappear error: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  /**
   * 初始化通话记录服务
   */
  private async initCallRecordService(context: common.Context): Promise<void> {
    try {
      CallUILog.info('HomePage', 'Initializing call record service...');
      this.callRecordService = CallRecordServiceImpl.getInstance(context);
      const storage = CallRecordStorage.getInstance();
      await storage.ensureInitialized(context);
      CallUILog.info('HomePage', 'Call record service initialized');
    } catch (error) {
      CallUILog.error('HomePage', `Failed to init call record service: ${error}`);
    }
  }

  /**
   * 注册消息监听
   */
  private registerMessageListeners(): void {
    try {
      const nimSdk = this.getUserModel().getNimSdk();
      const messageService: V2NIMMessageService | undefined = nimSdk.messageService;

      if (!messageService) {
        CallUILog.warn('HomePage', 'Message service not available');
        return;
      }

      // 监听接收消息
      this.receiveMessageHandler = (messages: V2NIMMessage[]) => {
        // 如果页面处于 hide 状态，不处理回调
        if (!this.isPageVisible) {
          CallUILog.info('HomePage', `onReceiveMessages: page is hidden, skip processing ${messages.length} messages`);
          return;
        }

        CallUILog.info('HomePage', `onReceiveMessages: received ${messages.length} messages`);
        const nimSdk = this.getUserModel().getNimSdk();
        for (const message of messages) {
          CallUILog.info('HomePage', `Processing message: messageType=${message.messageType}, messageClientId=${message.messageClientId}`);
          RecordUtils.parseForCallRecord(message, nimSdk).then((record: CallRecord | null) => {
            if (record) {
              CallUILog.info('HomePage', `Parsed call record from received message: accountId=${record.accountId}`);
              this.addCallRecord(record);
            } else {
              CallUILog.info('HomePage', `No call record parsed from received message`);
            }
          });
        }
      };

      messageService.on('onReceiveMessages', this.receiveMessageHandler);

      CallUILog.info('HomePage', 'Message listeners registered');
    } catch (error) {
      CallUILog.error('HomePage', `Failed to register message listeners: ${error}`);
    }
  }

  /**
   * 取消消息监听
   */
  private unregisterMessageListeners(): void {
    try {
      const nimSdk = this.getUserModel().getNimSdk();
      const messageService: V2NIMMessageService | undefined = nimSdk.messageService;

      if (!messageService) {
        return;
      }

      if (this.receiveMessageHandler) {
        messageService.off('onReceiveMessages', this.receiveMessageHandler);
        this.receiveMessageHandler = null;
      }

      CallUILog.info('HomePage', 'Message listeners unregistered');
    } catch (error) {
      CallUILog.error('HomePage', `Failed to unregister message listeners: ${error}`);
    }
  }

  /**
   * 添加通话记录（只保存到本地，不更新UI）
   */
  private async addCallRecord(record: CallRecord): Promise<void> {
    try {
      if (!this.callRecordService) {
        CallUILog.warn('HomePage', 'Call record service not initialized, cannot add record');
        return;
      }
      CallUILog.info(`HomePage`, `Adding call record: accountId=${record.accountId}, isIncoming=${record.isIncoming}, callType=${record.callType}`);
      // 保存到存储
      const result = await this.callRecordService.addRecordToCurrentAccount(record);
      CallUILog.info('HomePage', `Save result: ${result}`);
    } catch (error) {
      CallUILog.error('HomePage', `Failed to add call record: ${error}`);
    }
  }

  /**
   * 注册被踢下线监听
   */
  private registerKickedOfflineListener(): void {
    try {
      // 如果已经注册过，先取消注册
      if (this.kickedOfflineHandler) {
        this.unregisterKickedOfflineListener();
      }

      const userModel = this.getUserModel();
      const nimSdk = userModel.getNimSdk();
      const loginService = nimSdk?.loginService;

      if (!loginService) {
        CallUILog.warn('HomePage', 'loginService not available');
        return;
      }

      // 监听被踢下线
      this.kickedOfflineHandler = (detail: V2NIMKickedOfflineDetail) => {
        CallUILog.info('HomePage', `onKickedOffline: reason=${detail.reason}, reasonDesc=${detail.reasonDesc}, clientType=${detail.clientType}, customClientType=${detail.customClientType}`);
        
        // 清除当前登录账号信息
        AppStorage.delete('currentAccountId');
        
        // 跳转回登录页面
        router.replaceUrl({
          url: 'pages/LoginPage'
        }).catch((err: Error) => {
          CallUILog.error('HomePage', `跳转到登录页面失败: ${err.message}`);
        });
      };

      loginService.on('onKickedOffline', this.kickedOfflineHandler);

      CallUILog.info('HomePage', 'Kicked offline listener registered');
    } catch (error) {
      CallUILog.error('HomePage', `Failed to register kicked offline listener: ${error}`);
    }
  }

  /**
   * 取消被踢下线监听
   */
  private unregisterKickedOfflineListener(): void {
    try {
      const userModel = this.getUserModel();
      const nimSdk = userModel.getNimSdk();
      const loginService = nimSdk?.loginService;

      if (!loginService) {
        return;
      }

      if (this.kickedOfflineHandler) {
        loginService.off('onKickedOffline', this.kickedOfflineHandler);
        this.kickedOfflineHandler = null;
      }

      CallUILog.info('HomePage', 'Kicked offline listener unregistered');
    } catch (error) {
      CallUILog.error('HomePage', `Failed to unregister kicked offline listener: ${error}`);
    }
  }


  build() {
    Column() {
      // 顶部用户信息区域
      Column() {
        Row() {
          // 头像（用首字母圆形占位）
          if (this.avatar.length > 0) {
            // 有头像地址时显示图片头像
            Image(this.avatar)
              .width(56)
              .height(56)
              .borderRadius(28)
              .objectFit(ImageFit.Cover)
          } else {
            // 无头像时使用首字母占位
            Column() {
              Text(this.nickname.length > 0 ? this.nickname.charAt(0) : '?')
                .fontSize(24)
                .fontColor(Color.White)
                .textAlign(TextAlign.Center)
            }
            .width(56)
            .height(56)
            .backgroundColor($r('app.color.home_avatar_background'))
            .borderRadius(28)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          }

          // 昵称和账号
          Column() {
            Text(this.nickname.length > 0 ? `昵称：${this.nickname}` : '未登录')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.home_text_primary'))
              .width('100%')
              .textAlign(TextAlign.Start)
            if (this.accountId.length > 0) {
              Text(`账号：${this.accountId}`)
                .fontSize(14)
                .fontColor($r('app.color.home_text_secondary'))
                .width('100%')
                .textAlign(TextAlign.Start)
            }
          }
          .margin({ left: 12 })
          .alignItems(HorizontalAlign.Start)

          Blank()
        }
        .width('100%')

        // 应用信息（放在头像下方，左边和头像对齐）
        if (this.version.length > 0) {
          Text(`应用信息：${this.version}`)
            .fontSize(14)
            .fontColor($r('app.color.home_text_secondary'))
            .margin({ top: 12 })
            .width('100%')
            .textAlign(TextAlign.Start)
        }
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 40,
        bottom: 20
      })
      .onClick(() => {
        this.showLogoutDialog();
      })

      Blank().layoutWeight(1)

      // 单人通话按钮
      Button('单人通话')
        .width('80%')
        .height(50)
        .margin({ bottom: 40 })
        .backgroundColor($r('app.color.home_button_background'))
        .fontColor($r('app.color.home_button_text'))
        .onClick(() => {
          router.pushUrl({
            url: 'pages/SingleCallPage'
          }).catch((err: Error) => {
            console.error('[HomePage] 跳转到呼叫页面失败:', err);
          });
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.start_window_background'))
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }
}


