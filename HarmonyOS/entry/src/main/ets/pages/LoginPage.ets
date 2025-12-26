import { NECallUI } from '@necallkit/callkit_ui';
import { UserModel } from '../viewmodel/UserModel';
import common from '@ohos.app.ability.common';
import router from '@ohos.router';
import { NESetupConfig } from '@necallkit/callkit/src/main/ets/api/Models';
import { CallUILog } from '@necallkit/callkit_ui/src/main/ets/utils/CallUILog';
import { Want } from '@kit.AbilityKit';
import {
  V2NIMError,
} from '@nimsdk/base';

@Entry
@Component
export struct LoginPage {
  @State accountId: string = '';
  @State token: string = '';

  private getUserModel(): UserModel {
    return UserModel.getInstance(getContext(this));
  }

  build() {
    Column() {
      Text('账号登录')
        .fontSize(24)
        .margin({ top: 40, bottom: 20 })

      // 账号输入框
      Text('账号ID:')
        .fontSize(16)
        .width('80%')
        .textAlign(TextAlign.Start)
        .margin({ top: 10, bottom: 5 })
      TextInput({ placeholder: '请输入账号ID', text: this.accountId })
        .width('80%')
        .height(40)
        .margin({ bottom: 10 })
        .onChange((value: string) => {
          this.accountId = value;
        })

      // Token输入框
      Text('Token:')
        .fontSize(16)
        .width('80%')
        .textAlign(TextAlign.Start)
        .margin({ bottom: 5 })
      TextInput({ placeholder: '请输入Token', text: this.token })
        .width('80%')
        .height(40)
        .margin({ bottom: 10 })
        .onChange((value: string) => {
          this.token = value;
        })

      // 登录按钮
      Button('登录')
        .width('80%')
        .height(50)
        .margin(10)
        .onClick(() => {
          this.login(getContext(this) as common.Context);
        })

      Blank().layoutWeight(1)

      // 帮助链接
      Text('如何获取云信账号与Token')
        .fontSize(14)
        .fontColor('#007DFF')
        .decoration({ type: TextDecorationType.Underline })
        .margin({ bottom: 40 })
        .onClick(() => {
          this.openHelpLink();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }

  private async login(context: common.Context) {
    // 使用输入框中的账号ID和Token
    let accountId: string = this.accountId.trim();
    let token: string = this.token.trim();

    // 验证输入
    if (!accountId || !token) {
      AlertDialog.show({
        title: '提示',
        message: '请输入账号ID和Token',
        autoCancel: true,
        alignment: DialogAlignment.Bottom,
        confirm: {
          value: '确定',
          action: () => {
            console.info('确认回调')
          }
        }
      });
      return;
    }

    try {
      const userModel = this.getUserModel();
      if (!userModel.getNimSdk()) {
        userModel.nimRepository.createDefaultNim(context);
      }

      await userModel.getNimSdk().loginService.login(accountId, token);
      console.log('[LoginPage] 登录成功');

      console.log('[LoginPage] 初始化呼叫组件');
      let config: NESetupConfig = new NESetupConfig(
        context,
        userModel.getNimSdk(),
        userModel.getAppKey(),
        accountId
      );
      await NECallUI.getInstance().setupEngine(config);

      // 记录当前登录账号，供 HomePage 展示
      AppStorage.setOrCreate('currentAccountId', accountId);

      // 登录成功后，使用 replaceUrl 跳转到 HomePage 页面，销毁登录页，避免返回
      router.replaceUrl({
        url: 'pages/HomePage'
      }).catch((err: Error) => {
        console.error('[LoginPage] 跳转到 HomePage 页面失败:', err);
      });
    } catch (error) {
      CallUILog.error('LoginPage',
        `登录或初始化失败: ${error instanceof Error ? error.message : String(error)}`);
      AlertDialog.show({
        title: '登录失败',
        message: this.processV2ErrorForPrint(error),
        autoCancel: true,
        alignment: DialogAlignment.Bottom,
        confirm: {
          value: '确定',
          action: () => {
            console.info('确认回调')
          }
        }
      });
    }
  }

  /**
   * 打开帮助链接
   */
  private openHelpLink(): void {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      if (!context) {
        CallUILog.error('LoginPage', '无法获取 Context，无法打开链接');
        return;
      }

      const url = 'https://doc.yunxin.163.com/messaging2/guide/jU0Mzg0MTU?platform=client#%E7%AC%AC%E4%BA%8C%E6%AD%A5%E6%B3%A8%E5%86%8C-im-%E8%B4%A6%E5%8F%B7';
      
      const want: Want = {
        action: 'ohos.want.action.viewData',
        uri: url,
        type: 'text/html'
      };

      context.startAbility(want).then(() => {
        CallUILog.info('LoginPage', '成功打开帮助链接');
      }).catch((err: Error) => {
        CallUILog.error('LoginPage', `打开帮助链接失败: ${err.message}`);
      });
    } catch (error) {
      CallUILog.error('LoginPage',
        `打开帮助链接异常: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  private processV2ErrorForPrint(err: V2NIMError): string {
    if (err instanceof Error) {
      let desc = `code: ${err.code}\n message: "${err.message}"\n`
      return desc
    } else {
      return `Caught an exception: ${err}`
    }
  }
}


