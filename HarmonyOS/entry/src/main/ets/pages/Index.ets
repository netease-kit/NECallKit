import { UserModel } from '../viewmodel/UserModel';
import AbilityAccessCtrl from '@ohos.abilityAccessCtrl';
import fs from '@ohos.file.fs';
import { taskpool } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';

import {
  V2NIMConnectStatus, V2NIMLoginStatus,
} from '@nimsdk/base';
import { Context } from '@kit.AbilityKit';
import common from '@ohos.app.ability.common';
import router from '@ohos.router';
import { LoginPage } from './LoginPage';
import { NECallUI } from '@yunxin/callkit_ui';
import { NESetupConfig } from '@yunxin/callkit/src/main/ets/api/Models';


@Concurrent
export async function copyFaceUnityModels(context: Context) {
  let beautyDir: string = context.filesDir + "/beauty"
  if (!fs.accessSync(beautyDir)) {
    fs.mkdirSync(beautyDir)
    console.info('=== Beauty dir mkdir ===')
  }

  let copyAssets = async (context: Context, file_path: string, file_name: string) => {
    try {
      let file_ready = false
      let file: string = file_path + "/" + file_name
      if (fs.accessSync(file)) {
        console.info('file: ' + file + ", is already exists, path: " + file_path)
        file_ready = true
      }

      if (!file_ready) {
        let data = await context.resourceManager.getRawFileContent(file_name)
        let writeLen: number = fs.createStreamSync(file, 'w').writeSync(data.buffer)
        console.info('write pcm file len: ' + writeLen)
      }
    } catch (e) {
      console.error('copy assets file failed, message: ' + JSON.stringify(e))
    }
  }

  copyAssets(context, beautyDir, 'ai_face_processor.bundle')
  copyAssets(context, beautyDir, 'face_beautification.bundle')
  copyAssets(context, beautyDir, 'ai_human_processor.bundle')
  copyAssets(context, beautyDir, 'face_makeup.bundle')
}


@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  @State loginStatus: string = 'loginStatus:init';
  @State accountId: string = 'wulei04';
  @State token: string = 'wulei04';
  @State isAutoLogging: boolean = false;

  getUserModel(): UserModel {
    return UserModel.getInstance(getContext(this));
  }

  /**
   * 组件初始化方法，类似于 Flutter 的 initState
   * 在组件即将出现时调用，用于执行初始化操作
   */
  aboutToAppear(): void {
    console.log('[Index] aboutToAppear: 组件初始化');
    this.initState();

    let task: taskpool.Task = new taskpool.Task(copyFaceUnityModels, getContext());
    taskpool.execute(task, taskpool.Priority.HIGH).then(() => {
      console.info('copyAppAssets end...')
    }).catch((err: BusinessError) => {
      console.error(`execute copyAppAssets err:${JSON.stringify(err)}`)
    })

    // 尝试自动登录
    this.tryAutoLogin();
  }

  /**
   * 初始化状态和监听器
   */
  private initState(): void {
    // 初始化 NIM SDK（如果还没有初始化）
    const context = getContext(this);
    if (context && !this.getUserModel().getNimSdk()) {
      this.getUserModel().nimRepository.createDefaultNim(context);
    }

    // 注册登录状态监听器
    this.registerLoginStatusListener();

    // 注册连接状态监听器
    this.registerConnectStatusListener();
  }

  /**
   * 注册登录状态监听器
   */
  private registerLoginStatusListener(): void {
    const nimSdk = this.getUserModel().getNimSdk();
    if (!nimSdk) {
      return;
    }

    nimSdk.loginService.on("onLoginStatus", (status: V2NIMLoginStatus) => {
      switch (status) {
        case V2NIMLoginStatus.V2NIM_LOGIN_STATUS_LOGOUT:
          console.log("status => logout");
          this.loginStatus = "logout";
          break;
        case V2NIMLoginStatus.V2NIM_LOGIN_STATUS_LOGINED:
          console.log("status => logined");
          this.loginStatus = "logined";
          break;
        case V2NIMLoginStatus.V2NIM_LOGIN_STATUS_LOGINING:
          console.log("status => logining");
          this.loginStatus = "logining";
          break;
      }
    });
  }

  /**
   * 注册连接状态监听器
   */
  private registerConnectStatusListener(): void {
    const nimSdk = this.getUserModel().getNimSdk();
    if (!nimSdk) {
      return;
    }

    nimSdk.loginService.on("onConnectStatus", (status: V2NIMConnectStatus) => {
      switch (status) {
        case V2NIMConnectStatus.V2NIM_CONNECT_STATUS_DISCONNECTED:
          console.log("status => DISCONNECTED");
          this.loginStatus = "DISCONNECTED";
          break;
        case V2NIMConnectStatus.V2NIM_CONNECT_STATUS_CONNECTING:
          console.log("status => CONNECTING");
          this.loginStatus = "CONNECTING";
          break;
        case V2NIMConnectStatus.V2NIM_CONNECT_STATUS_CONNECTED:
          console.log("status => CONNECTED");
          this.loginStatus = "CONNECTED";
          break;
        case V2NIMConnectStatus.V2NIM_CONNECT_STATUS_WAITING:
          console.log("status => WAITING");
          this.loginStatus = "WAITING";
          break;
      }
    });
  }

  /**
   * 组件销毁方法，类似于 Flutter 的 dispose
   * 在组件即将消失时调用，用于清理资源
   */
  aboutToDisappear(): void {
    console.log('[Index] aboutToDisappear: 组件即将销毁');
    // 可以在这里移除监听器、清理资源等
  }

  /**
   * 尝试自动登录
   * 读取上次保存的凭证，如果存在则自动执行登录流程
   */
  private async tryAutoLogin(): Promise<void> {
    try {
      const userModel = this.getUserModel();
      const savedAccid = await userModel.loadLastLoginAccount();
      const savedToken = await userModel.loadLastLoginToken();

      if (!savedAccid || !savedToken) {
        console.log('[Index] 无保存的登录凭证，显示登录页');
        return;
      }

      console.log(`[Index] 发现保存的凭证，尝试自动登录: ${savedAccid}`);
      this.isAutoLogging = true;

      const context = getContext(this) as common.Context;
      if (!userModel.getNimSdk()) {
        userModel.nimRepository.createDefaultNim(context);
      }

      await userModel.getNimSdk().loginService.login(savedAccid, savedToken);
      console.log('[Index] 自动登录成功');

      const config: NESetupConfig = new NESetupConfig(
        context,
        userModel.getNimSdk(),
        userModel.getAppKey(),
        savedAccid
      );
      await NECallUI.getInstance().setupEngine(config);

      AppStorage.setOrCreate('currentAccountId', savedAccid);

      router.replaceUrl({ url: 'pages/HomePage' }).catch((err: Error) => {
        console.error('[Index] 自动登录后跳转失败:', err);
      });
    } catch (error) {
      console.error(`[Index] 自动登录失败: ${error instanceof Error ? error.message : String(error)}`);
      // 自动登录失败，清除过期凭证，显示登录页
      this.getUserModel().clearLoginCredentials();
      this.isAutoLogging = false;
    }
  }

  build() {
    Column() {
      if (this.isAutoLogging) {
        // 自动登录中，显示加载状态
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
          Text('自动登录中...')
            .fontSize(16)
            .fontColor('#999')
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        // 显示登录页面
        LoginPage({})
      }
    }
  }

  private async doRequestPermissions(): Promise<void> {
    const atManager = AbilityAccessCtrl.createAtManager();
    const context = getContext(this);

    console.log('NECallEngine', '%{public}s', 'Start requesting media permissions');

    return new Promise((resolve, reject) => {
      if (!context) {
        console.error('NECallEngine 上下文无效：appContext未初始化');
        reject(Error("上下文无效：appContext未初始化"));
        return;
      }
      try {
        atManager.requestPermissionsFromUser(
          context,
          ["ohos.permission.MICROPHONE", "ohos.permission.CAMERA"],
          (err, data) => {
            // 此处已在主线程无需切换
            if (err) {
              console.log('NECallEngine', '请求权限失败');
              reject(err);
              return;
            }

            const micGranted = data.authResults[0] === AbilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
            const cameraGranted = data.authResults[1] === AbilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
            resolve();
          }
        );
      } catch (err) {
        console.log('NECallEngine', `请求权限异常: ${JSON.stringify(err)}`);
        reject(err);
      }
    });
  }
}