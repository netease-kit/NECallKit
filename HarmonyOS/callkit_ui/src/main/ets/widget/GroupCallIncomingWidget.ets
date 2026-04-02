// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { CallState } from '../impl/CallState';
import { CallUILog } from '../utils/CallUILog';
import { Constants } from '../data/Constants';

/**
 * 群呼来电界面组件
 *
 * 当被叫方收到群呼邀请时显示此界面
 *
 * Figma 规格 (node-id=20095-7595, 屏幕 375x812)：
 * - 背景：主叫头像模糊 + rgba(0,0,0,0.5) 遮罩
 * - 忽略按钮：70x35vp，圆角 17.5vp，x=16, y=54，背景 rgba(255,255,255,0.1)
 * - 主叫头像：124x124vp，圆角 12vp，y=206
 * - 主叫名称：28fp，白色，y=342
 * - 邀请提示：16fp，50%透明，y=394
 * - 参与者提示：14fp，50%透明，y=450
 * - 参与者头像：40x40vp，圆角 4vp，间距 12vp，y=485
 * - 操作按钮：64x64vp，y=675
 * - 按钮标签：12fp，y=744
 *
 * @since 2.0.0
 */
@Component
export struct GroupCallIncomingWidget {
  private static readonly TAG = 'GroupCallIncomingWidget';

  /** 接听回调 */
  onAccept: () => void = () => {};
  /** 拒绝回调 */
  onReject: () => void = () => {};
  /** 忽略回调（仅关闭 UI，不发送服务端通知） */
  onIgnore: () => void = () => {};

  /** 主叫头像 */
  @State callerAvatar: string = '';
  /** 主叫名称 */
  @State callerName: string = '';
  /** 参与者数量（包含主叫） */
  @State participantCount: number = 0;
  /** 其他参与者列表（头像URL） */
  @State otherParticipants: string[] = [];
  /** 其他参与者的真实数量（不含主叫和自己） */
  @State otherParticipantsCount: number = 0;
  /** 按钮是否禁用（防止重复点击） */
  @State isButtonDisabled: boolean = false;

  aboutToAppear(): void {
    this.loadCallerInfo();
  }

  /**
   * 加载主叫信息
   */
  private loadCallerInfo(): void {
    const state = CallState.instance;
    this.callerAvatar = state.caller.avatar || Constants.defaultAvatar;
    this.callerName = state.caller.nickname || state.caller.id || '未知用户';
    this.participantCount = state.groupCallParticipantCount || 2;

    // 加载其他参与者头像（排除主叫，排除自己）
    // remoteUserList 包含主叫和其他被叫（不含自己）
    const otherUsers = state.remoteUserList.filter(u => u.id !== state.caller.id);
    this.otherParticipantsCount = otherUsers.length; // 真实数量
    this.otherParticipants = otherUsers
      .map(u => u.avatar || Constants.defaultAvatar);

    CallUILog.info(GroupCallIncomingWidget.TAG,
      `loadCallerInfo: caller=${this.callerName}, callerAvatar=${this.callerAvatar ? '有' : '无'}, ` +
      `participantCount=${this.participantCount}, ` +
      `remoteUserList.length=${state.remoteUserList.length}, ` +
      `otherUsers.length=${otherUsers.length}, ` +
      `otherParticipantsCount=${this.otherParticipantsCount}, ` +
      `otherParticipants.length=${this.otherParticipants.length}`);

    // 打印每个远端用户的详细信息
    state.remoteUserList.forEach((u, i) => {
      CallUILog.info(GroupCallIncomingWidget.TAG,
        `remoteUser[${i}]: id=${u.id}, nickname=${u.nickname}, avatar=${u.avatar ? '有' : '无'}`);
    });
  }

  /**
   * 处理接听
   */
  private handleAccept(): void {
    if (this.isButtonDisabled) return;
    this.isButtonDisabled = true;

    CallUILog.info(GroupCallIncomingWidget.TAG, '点击接听按钮');
    this.onAccept();
  }

  /**
   * 处理拒绝（发送拒绝通知给服务端）
   */
  private handleReject(): void {
    if (this.isButtonDisabled) return;
    this.isButtonDisabled = true;

    CallUILog.info(GroupCallIncomingWidget.TAG, '点击拒绝按钮');
    this.onReject();
  }

  /**
   * 处理忽略（仅关闭 UI，不发送服务端通知）
   */
  private handleIgnore(): void {
    if (this.isButtonDisabled) return;
    this.isButtonDisabled = true;

    CallUILog.info(GroupCallIncomingWidget.TAG, '点击忽略按钮');
    this.onIgnore();
  }

  build() {
    Stack() {
      // ========== 背景层 ==========
      // 1. 黑色底色
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#000000')

      // 2. 模糊背景图（主叫头像放大模糊）
      if (this.callerAvatar) {
        Image(this.callerAvatar)
          .width('200%')
          .height('200%')
          .objectFit(ImageFit.Cover)
          .blur(40)
          .position({ x: '-50%', y: '-50%' })
      }

      // 3. 半透明遮罩层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')

      // ========== 内容层 ==========
      Column() {
        // ========== 顶部忽略按钮 (y=54) ==========
        Row() {
          Row({ space: 4 }) {
            Image($r('app.media.ic_ignore'))
              .width(16)
              .height(16)
              .fillColor('#FFFFFF')
            Text('忽略')
              .fontSize(12)
              .fontColor('#FFFFFF')
          }
          .width(70)
          .height(35)
          .borderRadius(17.5)
          .backgroundColor('rgba(255, 255, 255, 0.1)')
          .justifyContent(FlexAlign.Center)
          .onClick(() => this.handleIgnore())

          Blank()
        }
        .width('100%')
        .padding({ left: 16 })
        .margin({ top: 54 })

        // ========== 主叫头像 (y=206, 从顶部算起) ==========
        // 54 + 35 = 89, 需要 206 - 89 = 117 的间距
        Column() {
          Image(this.callerAvatar)
            .width(124)
            .height(124)
            .borderRadius(12)
            .objectFit(ImageFit.Cover)
        }
        .margin({ top: 117 })

        // ========== 主叫名称 (y=342) ==========
        // 206 + 124 = 330, 需要 342 - 330 = 12 的间距
        Text(this.callerName)
          .fontSize(28)
          .fontColor('#FFFFFF')
          .margin({ top: 12 })

        // ========== 邀请提示 (y=394) ==========
        // 342 + 42(lineHeight) = 384, 需要 394 - 384 = 10 的间距
        Text('邀请你多人通话...')
          .fontSize(16)
          .fontColor('#FFFFFF')
          .opacity(0.5)
          .margin({ top: 10 })

        // ========== 参与者数量提示 (y=450) ==========
        // 394 + 24(lineHeight) = 418, 需要 450 - 418 = 32 的间距
        // 显示其他参与者数量（不含主叫和自己）= otherParticipantsCount
        Text(`还有 ${this.otherParticipantsCount} 人参与通话：`)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .opacity(0.5)
          .margin({ top: 32 })
          .visibility(this.otherParticipantsCount > 0 ? Visibility.Visible : Visibility.None)

        // ========== 参与者头像列表 (y=485) ==========
        // 每行最多 5 个头像（40vp * 5 + 12vp * 4 = 248vp）
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
          ForEach(this.otherParticipants, (avatar: string, index: number) => {
            Image(avatar)
              .width(40)
              .height(40)
              .borderRadius(4)
              .objectFit(ImageFit.Cover)
              .margin({ right: 12, bottom: 12 })
          }, (avatar: string, index: number) => `participant_${index}`)
        }
        .width(260) // 5 * (40 + 12) = 260
        .margin({ top: 13 })
        .visibility(this.otherParticipantsCount > 0 ? Visibility.Visible : Visibility.None)

        // 弹性空间
        Blank()

        // ========== 底部操作按钮 ==========
        Row() {
          // 挂断按钮
          // SVG 已包含完整样式：红色背景 #E5362C + 白色图标
          Column() {
            Image($r('app.media.ic_hangup'))
              .width(64)
              .height(64)
              .onClick(() => this.handleReject())

            Text('挂断')
              .fontSize(12)
              .fontColor('#FFFFFF')
              .margin({ top: 5 })
          }

          Blank()

          // 接听按钮
          // SVG 已包含完整样式：绿色背景 #1BBF52 + 白色图标
          Column() {
            Image($r('app.media.ic_accept'))
              .width(64)
              .height(64)
              .onClick(() => this.handleAccept())

            Text('接听')
              .fontSize(12)
              .fontColor('#FFFFFF')
              .margin({ top: 5 })
          }
        }
        .width('100%')
        .padding({ left: 73, right: 72 }) // 375 - 239 - 64 = 72
        .margin({ bottom: 68 }) // 812 - 675 - 64 - 5 = 68
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}
