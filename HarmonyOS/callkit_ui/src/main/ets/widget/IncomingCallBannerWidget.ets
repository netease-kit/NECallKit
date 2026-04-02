// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import window from '@ohos.window';
import display from '@ohos.display';
import { NECallEngine, NECallType } from '@yunxin/callkit';
import router from '@ohos.router';
import { CallUILog } from '../utils/CallUILog';

/**
 * 来电横幅中展示的主叫信息
 */
export interface CallerInfo {
  accountId: string;
  displayName: string;
  avatarUrl?: string;
  callType: number; // 0=audio, 1=video, 2=group
}

/**
 * 来电横幅内容组件（ArkUI @Component）
 * 布局：头像 + 昵称/副标题 + 拒绝按钮 + 接听按钮
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

      // 接听按钮（视频通话用绿底摄像头图标，音频通话用绿底电话图标，对齐 iOS call_accept_video / call_accept）
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
   * 0=音频, 1=视频, 2=群通话
   */
  getSubtitle(): string {
    if (this.callerInfo.callType === 2) {
      return '邀请你加入群通话';
    }
    if (this.callerInfo.callType === 1) {
      return '邀请你进行视频通话';
    }
    return '邀请你进行语音通话';
  }
}

/**
 * 横幅回调静态存储
 * AppStorage 不支持 function 类型，改用静态类传递回调
 */
export class BannerCallbackStore {
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
 * WindowStage 缓存：由 EntryAbility.onWindowStageCreate 注入
 * 用于创建 SubWindow（比 mainWindow.createSubWindowWithOptions 更可靠）
 */
export class BannerWindowStore {
  static windowStage: window.WindowStage | null = null;
}

/**
 * 来电横幅管理类
 * 通过 WindowStage.createSubWindow 创建悬浮覆盖层，可叠加在所有页面之上
 */
export class IncomingCallBannerWidget {
  private static readonly _tag = 'IncomingCallBannerWidget';
  private _subWindow: window.Window | null = null;
  private _context: Context;

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
      if (this._subWindow) {
        await this._subWindow.destroyWindow();
        this._subWindow = null;
      }

      const windowStage = BannerWindowStore.windowStage;
      if (!windowStage) {
        CallUILog.error(IncomingCallBannerWidget._tag, 'show: windowStage not set');
        return;
      }

      // 通过静态类传递来电信息和回调（AppStorage 不支持 function）
      BannerCallbackStore.callerInfo = callerInfo;
      BannerCallbackStore.onAccept = onAccept;
      BannerCallbackStore.onReject = onReject;
      BannerCallbackStore.onBodyTap = onBodyTap;

      // 用 windowStage.createSubWindow（比 mainWindow.createSubWindowWithOptions 兼容性更好）
      const subWin = await windowStage.createSubWindow('IncomingCallBanner');
      CallUILog.info(IncomingCallBannerWidget._tag, `createSubWindow result: ${subWin ? 'OK' : 'null'}`);
      if (!subWin) {
        CallUILog.error(IncomingCallBannerWidget._tag, 'createSubWindow returned null');
        return;
      }
      this._subWindow = subWin;

      // 计算横幅尺寸与位置
      const mainWindow = await windowStage.getMainWindow();
      const props = mainWindow.getWindowProperties();
      const screenWidth = props.windowRect.width;
      const density = display.getDefaultDisplaySync().densityPixels;
      const bannerHeightPx = Math.ceil(116 * density);
      // 状态栏高度（对齐 iOS kBannerWindowTopOffset=54pt，使用异步 API）
      const avoidArea = await mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      const statusBarHeight = avoidArea.topRect.height;

      // 官方推荐顺序：先 setUIContent，再 resize/move，最后 show
      await subWin.setUIContent('pages/IncomingCallBannerPage', null);
      await subWin.setWindowBackgroundColor('#00000000');
      await subWin.resize(screenWidth, bannerHeightPx);
      await subWin.moveWindowTo(0, statusBarHeight);
      await subWin.showWindow();

      CallUILog.info(
        IncomingCallBannerWidget._tag,
        `showIncomingBanner callerAccId=${callerInfo.accountId} callType=${callerInfo.callType}`
      );
    } catch (e) {
      const err = e as Record<string, Object>;
      CallUILog.error(
        IncomingCallBannerWidget._tag,
        `show error code=${err['code']} message=${err['message']}`
      );
    }
  }

  /**
   * 关闭来电横幅
   */
  async dismiss(): Promise<void> {
    try {
      if (this._subWindow) {
        await this._subWindow.destroyWindow();
        this._subWindow = null;
        BannerCallbackStore.clear();
        CallUILog.info(IncomingCallBannerWidget._tag, 'dismissIncomingBanner');
      }
    } catch (e) {
      const err = e as Record<string, Object>;
      CallUILog.error(IncomingCallBannerWidget._tag, `dismiss error: ${err['message']}`);
    }
  }

  /**
   * 返回横幅当前是否显示
   */
  isShowing(): boolean {
    return this._subWindow !== null;
  }
}
