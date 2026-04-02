// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import router from '@ohos.router';
import { CallState } from '@yunxin/callkit_ui/src/main/ets/impl/CallState';
import { CallManager } from '@yunxin/callkit_ui/src/main/ets/impl/CallManager';
import { CallUILog } from '@yunxin/callkit_ui/src/main/ets/utils/CallUILog';
import { ToastUtils } from '@yunxin/callkit_ui/src/main/ets/utils/ToastUtils';
import common from '@ohos.app.ability.common';

/**
 * 路由参数接口
 */
interface GroupCallSettingsParams {
  callId?: string;
}

/**
 * 多人通话设置页面（demo 层）
 * 右上角设置按钮点击后跳转至此
 * 包含：加入群呼（输入 callId）、邀请成员等功能入口
 */
@Entry({ routeName: 'groupCallSettingsPage' })
@Component
export struct GroupCallSettingsPage {
  static TAG = 'GroupCallSettingsPage';

  @State private callId: string = '';
  @State private callIdInput: string = '';
  @State private isJoining: boolean = false;

  aboutToAppear(): void {
    const params = router.getParams() as GroupCallSettingsParams | undefined;
    if (params?.callId) {
      this.callId = params.callId;
    } else {
      this.callId = CallState.instance.callId;
    }
    // 预填当前 callId（方便直接使用）
    this.callIdInput = this.callId;
    CallUILog.info(GroupCallSettingsPage.TAG, `aboutToAppear: callId=${this.callId}`);
  }

  private handleInviteMembers(): void {
    CallUILog.info(GroupCallSettingsPage.TAG, `handleInviteMembers: callId=${this.callId}`);
    router.pushNamedRoute({
      name: 'groupCallLaunchPage',
      params: {
        isInviteMode: true,
        callId: this.callId
      }
    });
  }

  private async handleJoinGroupCall(): Promise<void> {
    const targetCallId = this.callIdInput.trim();
    if (targetCallId.length === 0) {
      ToastUtils.showToastWithString(
        getContext(this) as common.UIAbilityContext,
        '请输入 callId'
      );
      return;
    }
    if (this.isJoining) {
      return;
    }
    this.isJoining = true;
    try {
      CallUILog.info(GroupCallSettingsPage.TAG, `joinGroupCall: callId=${targetCallId}`);
      const result = await CallManager.instance.joinGroupCall(targetCallId);
      CallUILog.info(GroupCallSettingsPage.TAG, `joinGroupCall 返回: code=${result.code}`);
      if (result.code !== 0) {
        ToastUtils.showToastWithString(
          getContext(this) as common.UIAbilityContext,
          result.message.length > 0 ? result.message : '加入失败'
        );
      }
    } catch (e) {
      CallUILog.error(GroupCallSettingsPage.TAG, `joinGroupCall 异常: ${String(e)}`);
      ToastUtils.showToastWithString(
        getContext(this) as common.UIAbilityContext,
        '加入群呼异常'
      );
    } finally {
      this.isJoining = false;
    }
  }

  build() {
    Column() {
      // 状态栏安全区域（从全屏通话页面跳转过来）
      Column()
        .width('100%')
        .height(44)

      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .margin({ left: 16 })
          .onClick(() => router.back())

        Text('设置')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .margin({ left: 16 })
          .layoutWeight(1)
      }
      .width('100%')
      .height(56)
      .alignItems(VerticalAlign.Center)

      Divider()
        .width('100%')
        .strokeWidth(1)
        .color('#F0F0F0')

      // 设置列表
      Column() {
        // 加入群呼
        Column() {
          Row() {
            Image($r('app.media.ic_add_member'))
              .width(28)
              .height(28)
              .margin({ left: 16, right: 12 })
              .fillColor('#333333')

            Text('加入群呼')
              .fontSize(16)
              .fontColor('#1A1A1A')
              .fontWeight(FontWeight.Regular)
              .layoutWeight(1)
          }
          .width('100%')
          .height(48)
          .alignItems(VerticalAlign.Center)

          // callId 输入框 + 加入按钮
          Row() {
            TextInput({ placeholder: '请输入 callId', text: this.callIdInput })
              .width(0)
              .layoutWeight(1)
              .height(44)
              .fontSize(15)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .padding({ left: 12, right: 12 })
              .margin({ left: 16 })
              .onChange((value: string) => {
                this.callIdInput = value;
              })

            Button(this.isJoining ? '加入中...' : '加入')
              .type(ButtonType.Normal)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .backgroundColor(this.isJoining ? '#CCCCCC' : '#337EFF')
              .borderRadius(8)
              .height(44)
              .width(72)
              .margin({ left: 8, right: 16 })
              .enabled(!this.isJoining)
              .onClick(() => this.handleJoinGroupCall())
          }
          .width('100%')
          .margin({ bottom: 16 })
        }
        .width('100%')

        Divider()
          .width('100%')
          .strokeWidth(1)
          .color('#F0F0F0')

        // 邀请成员
        this.SettingsRow(
          $r('app.media.ic_add_member'),
          '邀请成员',
          '邀请新成员加入通话',
          () => this.handleInviteMembers()
        )

        Divider()
          .width('100%')
          .strokeWidth(1)
          .color('#F0F0F0')
          .margin({ left: 56 })
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  SettingsRow(icon: Resource, title: string, description: string, onTap: () => void) {
    Row() {
      Image(icon)
        .width(28)
        .height(28)
        .margin({ left: 16, right: 12 })
        .fillColor('#333333')

      Column() {
        Text(title)
          .fontSize(16)
          .fontColor('#1A1A1A')
          .fontWeight(FontWeight.Regular)

        if (description.length > 0) {
          Text(description)
            .fontSize(13)
            .fontColor('#999999')
            .margin({ top: 2 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('>')
        .fontSize(18)
        .fontColor('#C0C0C0')
        .margin({ right: 16 })
    }
    .width('100%')
    .height(64)
    .alignItems(VerticalAlign.Center)
    .onClick(onTap)
  }
}
