import { MethodChannel } from '@ohos/flutter_ohos';
import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { display } from '@kit.ArkUI';
import { CallState } from '../state/CallState';
import { CallUILog } from '../utils/CallUILog';

const TAG = 'IncomingBannerManager';

export class IncomingBannerManager {
  private static instance: IncomingBannerManager | null = null;
  private channel: MethodChannel | null = null;
  private context: common.UIAbilityContext | null = null;
  private bannerWidget: IncomingCallBannerWidget | null = null;

  private constructor() {}

  static getInstance(): IncomingBannerManager {
    if (!IncomingBannerManager.instance) {
      IncomingBannerManager.instance = new IncomingBannerManager();
    }
    return IncomingBannerManager.instance;
  }

  setChannel(channel: MethodChannel): void {
    this.channel = channel;
  }

  setContext(context: common.UIAbilityContext): void {
    this.context = context;
  }

  /**
   * 设置 WindowStage（必须由 EntryAbility.onWindowStageCreate 调用）
   * 原生 Banner 需要 WindowStage 来创建子窗口
   */
  setWindowStage(windowStage: window.WindowStage): void {
    BannerWindowStore.windowStage = windowStage;
    CallUILog.i(TAG, 'WindowStage set for banner');
  }

  /** 展示来电横幅（使用原生 HarmonyOS SDK 的 IncomingCallBannerWidget） */
  async showBanner(): Promise<void> {
    const state = CallState.getInstance();
    if (!state.incomingBannerEnabled) {
      CallUILog.i(TAG, 'incomingBanner disabled, skip');
      return;
    }
    if (!this.context) {
      CallUILog.w(TAG, 'context not set, skip showBanner');
      return;
    }

    // 如果横幅已经显示，先关闭
    if (this.bannerWidget?.isShowing()) {
      CallUILog.i(TAG, 'Banner already showing, dismissing old one');
      await this.bannerWidget.dismiss();
      this.bannerWidget = null;
    }

    const remoteUser = state.remoteUserList[0];
    if (!remoteUser) {
      CallUILog.w(TAG, 'No remote user found, skip showBanner');
      return;
    }

    // 构建来电信息
    const callerInfo: CallerInfo = {
      accountId: remoteUser.accId,
      displayName: remoteUser.name ? (remoteUser.name != "" ? remoteUser.name:remoteUser.accId):remoteUser.accId,
      avatarUrl: remoteUser.avatar,
      callType: state.mediaType === 2 ? 1 : 0, // 0=audio, 1=video
    };

    try {
      // 创建原生横幅组件
      this.bannerWidget = new IncomingCallBannerWidget(this.context);

      // 显示横幅，传入回调函数
      await this.bannerWidget.show(
        callerInfo,
        // onAccept 回调
        () => {
          CallUILog.i(TAG, 'Banner accept button tapped');
          this.handleAction('bannerAcceptTapped');
        },
        // onReject 回调
        () => {
          CallUILog.i(TAG, 'Banner reject button tapped');
          this.handleAction('bannerRejectTapped');
        },
        // onBodyTap 回调
        () => {
          CallUILog.i(TAG, 'Banner body tapped');
          this.handleAction('launchCallingPageFromIncomingBanner');
        }
      );

      CallUILog.i(TAG, `showBanner success: ${callerInfo.displayName}`);
    } catch (e) {
      CallUILog.e(TAG, `showBanner failed: ${(e as Error)?.message ?? e}`);
    }
  }

  /** 取消来电横幅 */
  async cancelBanner(): Promise<void> {
    try {
      if (this.bannerWidget?.isShowing()) {
        await this.bannerWidget.dismiss();
        this.bannerWidget = null;
        CallUILog.i(TAG, 'cancelBanner success');
      } else {
        CallUILog.i(TAG, 'cancelBanner: no banner to dismiss');
      }
    } catch (e) {
      CallUILog.e(TAG, `cancelBanner failed: ${(e as Error)?.message ?? e}`);
    }
  }

  /** 设置来电横幅开关 */
  setEnabled(enable: boolean): void {
    CallState.getInstance().incomingBannerEnabled = enable;
    CallUILog.i(TAG, `setEnabled: ${enable}`);
  }

  /** 处理横幅交互回调（由 banner 按钮触发） */
  handleAction(methodName: string): void {
    const ch = this.channel;
    if (!ch) {
      CallUILog.w(TAG, `handleAction: channel not set, method=${methodName}`);
      return;
    }

    CallUILog.i(TAG, `handleAction: ${methodName}`);

    switch (methodName) {
      case 'bannerAcceptTapped':
        // 先关闭横幅，再调用 Flutter 侧接听逻辑
        this.cancelBanner().then(() => {
          ch.invokeMethod('bannerAcceptTapped', {});
        });
        break;
      case 'bannerRejectTapped':
        // 先关闭横幅，再调用 Flutter 侧拒绝逻辑
        this.cancelBanner().then(() => {
          ch.invokeMethod('bannerRejectTapped', {});
        });
        break;
      case 'launchCallingPageFromIncomingBanner':
        // 点击横幅主体，关闭横幅并跳转到通话页面
        this.cancelBanner().then(() => {
          ch.invokeMethod('launchCallingPageFromIncomingBanner', {});
        });
        break;
      default:
        CallUILog.w(TAG, `handleAction: unknown method=${methodName}`);
        break;
    }
  }
}

// ========== Banner 组件实现 ==========

/**
 * 来电横幅中展示的主叫信息
 */
export interface CallerInfo {
  accountId: string;
  displayName: string;
  avatarUrl?: string;
  callType: number; // 0=audio, 1=video
}

/**
 * WindowStage 缓存：由 EntryAbility.onWindowStageCreate 注入
 */
export class BannerWindowStore {
  static windowStage: window.WindowStage | null = null;
}

/**
 * 横幅回调静态存储
 */
class BannerCallbackStore {
  static callerInfo: CallerInfo = { accountId: '', displayName: '', callType: 0 };
  static onAccept: (() => void) | null = null;
  static onReject: (() => void) | null = null;
  static onBodyTap: (() => void) | null = null;

  static clear(): void {
    BannerCallbackStore.onAccept = null;
    BannerCallbackStore.onReject = null;
    BannerCallbackStore.onBodyTap = null;
  }
}

/**
 * 来电横幅管理类
 */
export class IncomingCallBannerWidget {
  private static readonly _tag = 'IncomingCallBannerWidget';
  private _subWindow: window.Window | null = null;
  private _context: Context;
  private _isShowing: boolean = false;

  constructor(context: Context) {
    this._context = context;
  }

  /**
   * 展示来电横幅
   */
  async show(
    callerInfo: CallerInfo,
    onAccept: () => void,
    onReject: () => void,
    onBodyTap: () => void
  ): Promise<void> {
    try {
      // 先销毁旧窗口
      if (this._subWindow) {
        try {
          await this._subWindow.destroyWindow();
        } catch (e) {
          CallUILog.w(IncomingCallBannerWidget._tag, `destroy old window failed: ${JSON.stringify(e)}`);
        }
        this._subWindow = null;
      }

      const windowStage = BannerWindowStore.windowStage;
      if (!windowStage) {
        CallUILog.e(IncomingCallBannerWidget._tag, 'show: windowStage not set');
        return;
      }

      // 通过静态类传递来电信息和回调
      BannerCallbackStore.callerInfo = callerInfo;
      BannerCallbackStore.onAccept = onAccept;
      BannerCallbackStore.onReject = onReject;
      BannerCallbackStore.onBodyTap = onBodyTap;

      // 创建子窗口（使用时间戳确保唯一性）
      const windowName = `IncomingCallBanner_${Date.now()}`;
      const subWin = await windowStage.createSubWindow(windowName);
      CallUILog.i(IncomingCallBannerWidget._tag, `createSubWindow result: ${subWin ? 'OK' : 'null'}`);
      if (!subWin) {
        CallUILog.e(IncomingCallBannerWidget._tag, 'createSubWindow returned null');
        return;
      }
      this._subWindow = subWin;

      // 计算横幅尺寸与位置
      const mainWindow = await windowStage.getMainWindow();
      const props = mainWindow.getWindowProperties();
      const screenWidth = props.windowRect.width;
      const density = display.getDefaultDisplaySync().densityPixels;
      const bannerHeightPx = Math.ceil(116 * density);
      const avoidArea = await mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      const statusBarHeight = avoidArea.topRect.height;
      const bannerTopOffset = Math.ceil(20 * density);

      // 设置窗口
      await subWin.loadContent('pages/IncomingCallBannerPage');
      await subWin.setWindowBackgroundColor('#00000000');
      await subWin.resize(screenWidth, bannerHeightPx);
      await subWin.moveWindowTo(0, statusBarHeight + bannerTopOffset);
      await subWin.showWindow();

      this._isShowing = true;
      CallUILog.i(
        IncomingCallBannerWidget._tag,
        `showIncomingBanner callerAccId=${callerInfo.accountId} callType=${callerInfo.callType}`
      );
    } catch (e) {
      CallUILog.e(IncomingCallBannerWidget._tag, `show error: ${JSON.stringify(e)}`);
      this._isShowing = false;
    }
  }

  /**
   * 关闭横幅
   */
  async dismiss(): Promise<void> {
    try {
      if (this._subWindow) {
        await this._subWindow.destroyWindow();
        this._subWindow = null;
        BannerCallbackStore.clear();
        CallUILog.i(IncomingCallBannerWidget._tag, 'dismiss: banner dismissed');
      }
      this._isShowing = false;
    } catch (e) {
      CallUILog.e(IncomingCallBannerWidget._tag, `dismiss error: ${JSON.stringify(e)}`);
      this._isShowing = false;
    }
  }

  /**
   * 是否正在显示
   */
  isShowing(): boolean {
    return this._isShowing;
  }
}

/**
 * 横幅内容组件
 */
@Component
export struct IncomingCallBannerContent {
  callerInfo: CallerInfo = { accountId: '', displayName: '', callType: 0 };
  onAccept: () => void = () => {};
  onReject: () => void = () => {};
  onBodyTap: () => void = () => {};

  build() {
    Row() {
      // 头像：60vp × 60vp，圆角 7
      Image(this.callerInfo.avatarUrl && this.callerInfo.avatarUrl.length > 0
        ? this.callerInfo.avatarUrl
        : $r('app.media.ic_avatar_default'))
        .width(60)
        .height(60)
        .borderRadius(7)
        .margin({ left: 16 })

      Column() {
        // 昵称
        Text(this.callerInfo.displayName)
          .fontWeight(FontWeight.Bold)
          .fontSize(18)
          .fontColor('#FFFFFF')
          .maxLines(1)
          .width('100%')
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // 副标题
        Text(this.getSubtitle())
          .fontWeight(FontWeight.Bold)
          .fontSize(12)
          .fontColor('#C5CCDB')
          .width('100%')
      }
      .layoutWeight(1)
      .height(60)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ top: 10, bottom: 10 })

      // 拒绝按钮
      Image($r('app.media.ic_hangup'))
        .width(36)
        .height(36)
        .onClick(() => this.onReject())
        .accessibilityText('拒绝')
        .margin({ right: 22 })

      // 接听按钮（视频通话用绿底摄像头图标，音频通话用绿底电话图标）
      Image(this.callerInfo.callType === 1 ?
        $r('app.media.ic_accept_video') :
        $r('app.media.ic_accept'))
        .width(36)
        .height(36)
        .onClick(() => this.onAccept())
        .accessibilityText(this.callerInfo.callType === 1 ? '接听视频通话' : '接听')
        .margin({ right: 16 })
    }
    .width('100%')
    .height(92)
    .backgroundColor('#22262E')
    .borderRadius(10)
    .onClick(() => this.onBodyTap())
  }

  /**
   * 根据 callType 返回副标题文案
   */
  getSubtitle(): string {
    if (this.callerInfo.callType === 1) {
      return '邀请你进行视频通话';
    }
    return '邀请你进行语音通话';
  }
}

// 导出给外部使用
export { BannerCallbackStore };
