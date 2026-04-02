// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';
import { NECallType, NECallParam, NEGroupCallConstants, NEGroupCall, GroupInviteParam, NEErrorCode } from '@yunxin/callkit';
import { CallManager } from '../impl/CallManager';
import { CallState } from '../impl/CallState';
import { CallUILog } from '../utils/CallUILog';
import { ToastUtils } from '../utils/ToastUtils';
import { User } from '../data/User';
import { NECallStatus, NECallRole } from '../CallDefine';
import { NEEventNotify } from '../event/EventNotify';
import { setStateEvent } from '../data/Constants';
import { NimUtils } from '../utils/NimUtils';
import common from '@ohos.app.ability.common';

/**
 * 路由参数接口
 */
interface GroupCallLaunchParams {
  /** 是否为邀请模式（在通话中邀请新成员） */
  isInviteMode?: boolean;
  /** 当前通话ID（邀请模式必需） */
  callId?: string;
}

/**
 * 账号输入项（用于保持 ForEach 的稳定 key）
 */
class AccountInput {
  id: number;
  value: string = '';

  constructor(id: number, value: string = '') {
    this.id = id;
    this.value = value;
  }
}

/**
 * 群呼发起页面
 * 允许用户输入多个账号ID并选择通话类型发起群呼
 * @since 2.0.0
 */
@Entry({ routeName: 'groupCallLaunchPage' })
@Component
export struct GroupCallLaunchPage {
  static TAG = 'GroupCallLaunchPage';

  // 账号输入列表 - 使用对象数组以支持稳定的 key
  @State accountInputs: AccountInput[] = [new AccountInput(0), new AccountInput(1)];
  // 下一个输入框的 ID（用于生成唯一 key）
  private nextInputId: number = 2;
  // 通话类型：true=视频，false=音频
  @State isVideoCall: boolean = true;
  // 是否正在呼叫中
  @State isCalling: boolean = false;
  // 是否为邀请模式（在通话中邀请新成员）
  @State isInviteMode: boolean = false;
  // 当前通话ID（邀请模式使用）
  private callId: string = '';

  aboutToAppear(): void {
    // 读取路由参数
    const params = router.getParams() as GroupCallLaunchParams | undefined;
    if (params) {
      this.isInviteMode = params.isInviteMode ?? false;
      this.callId = params.callId ?? '';
      CallUILog.info(GroupCallLaunchPage.TAG, `路由参数: isInviteMode=${this.isInviteMode}, callId=${this.callId}`);
    }

    // 邀请模式下，最少只需要邀请1人
    if (this.isInviteMode) {
      this.accountInputs = [new AccountInput(0)];
      this.nextInputId = 1;
    } else {
      // 发起模式下，默认显示一个空输入框
      this.accountInputs = [new AccountInput(0)];
      this.nextInputId = 1;
    }
  }

  /**
   * 添加新的账号输入框
   * 注：人数限制在 SDK 层的群呼接口中校验
   */
  private addAccountInput(): void {
    this.accountInputs.push(new AccountInput(this.nextInputId++));
  }

  /**
   * 删除账号输入框
   */
  private removeAccountInput(inputId: number): void {
    // 保持最少 MIN_PARTICIPANTS - 1 个输入框
    const minCallees = NEGroupCallConstants.MIN_PARTICIPANTS - 1;
    if (this.accountInputs.length > minCallees) {
      const indexToRemove = this.accountInputs.findIndex(item => item.id === inputId);
      if (indexToRemove >= 0) {
        this.accountInputs.splice(indexToRemove, 1);
      }
    }
  }

  /**
   * 更新账号输入（直接修改对象属性，不触发数组重建）
   */
  private updateAccountInput(inputId: number, value: string): void {
    const input = this.accountInputs.find(item => item.id === inputId);
    if (input) {
      input.value = value;
    }
  }

  /**
   * 获取有效的账号列表（去重、去空）
   */
  private getValidAccounts(): string[] {
    const accounts = this.accountInputs
      .map(item => item.value.trim())
      .filter(acc => acc.length > 0);
    // 去重 (ArkTS 兼容写法)
    const uniqueAccounts: string[] = [];
    for (const acc of accounts) {
      if (!uniqueAccounts.includes(acc)) {
        uniqueAccounts.push(acc);
      }
    }
    return uniqueAccounts;
  }

  /**
   * 验证输入并返回错误信息（如果有）
   * 注：人数限制在 SDK 层校验，这里只检查是否为空
   */
  private validateInputs(): string | null {
    const accounts = this.getValidAccounts();
    if (accounts.length === 0) {
      return this.getLocalizedString('group_call_invalid_param');
    }
    return null;
  }

  /**
   * 根据错误码获取国际化错误消息
   */
  private getErrorMessage(code: number): string {
    switch (code) {
      case NEErrorCode.ERROR_EXCEED_MAX_USERS:
        return this.getLocalizedString('group_call_exceed_max', NEGroupCallConstants.MAX_PARTICIPANTS);
      case NEErrorCode.ERROR_INVALID_PARAM:
        return this.getLocalizedString('group_call_invalid_param');
      default:
        return this.getLocalizedString('group_call_failed');
    }
  }

  /**
   * 获取国际化字符串
   */
  private getLocalizedString(name: string, ...args: (string | number)[]): string {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const resourceManager = context.resourceManager;
      // 使用资源 ID 获取字符串，支持格式化参数
      return resourceManager.getStringByNameSync(name, ...args);
    } catch (e) {
      CallUILog.error(GroupCallLaunchPage.TAG, `getLocalizedString failed: ${String(e)}`);
      // 降级返回默认值
      const defaults: Record<string, string> = {
        'group_call_exceed_max': `最多支持${NEGroupCallConstants.MAX_PARTICIPANTS}人通话`,
        'group_call_below_min': `至少需要${NEGroupCallConstants.MIN_PARTICIPANTS}人参与通话`,
        'group_call_invalid_param': '呼叫参数无效',
        'group_call_failed': '呼叫失败'
      };
      return defaults[name] ?? name;
    }
  }

  /**
   * 发起群呼
   */
  private async startGroupCall(): Promise<void> {
    // 验证输入
    const error = this.validateInputs();
    if (error) {
      ToastUtils.showToastWithString(getContext(this) as common.UIAbilityContext, error);
      return;
    }

    if (this.isCalling) {
      return;
    }

    this.isCalling = true;

    try {
      const accounts = this.getValidAccounts();
      const callType = this.isVideoCall ? NECallType.VIDEO : NECallType.AUDIO;

      // 人数限制：被叫人数 + 自己 ≤ MAX_PARTICIPANTS
      if (accounts.length + 1 > NEGroupCallConstants.MAX_PARTICIPANTS) {
        ToastUtils.showToastWithString(getContext(this) as common.UIAbilityContext, this.getLocalizedString('group_call_exceed_max', NEGroupCallConstants.MAX_PARTICIPANTS));
        return;
      }

      CallUILog.info(
        GroupCallLaunchPage.TAG,
        `[群呼调试] 发起群呼: accounts=${accounts.join(',')}, callType=${callType}`
      );

      // 创建群呼参数
      const param = NECallParam.createGroupCall(accounts, callType);
      CallUILog.info(
        GroupCallLaunchPage.TAG,
        `[群呼调试] NECallParam 创建完成: isGroupCall=${param.isGroupCall()}, calledAccIds=${JSON.stringify(param.calledAccIds)}`
      );

      // 调用 CallManager 发起群呼
      CallUILog.info(GroupCallLaunchPage.TAG, '[群呼调试] 开始调用 CallManager.startGroupCall()');
      const result = await CallManager.instance.startGroupCall(param);
      CallUILog.info(GroupCallLaunchPage.TAG, `[群呼调试] CallManager.startGroupCall() 返回: code=${result.code}, message=${result.message}`);

      if (result.code === 0) {
        // 群呼发起成功，通话页面由 CallManager.launchCallingPage() 打开
        // 不要在这里调用 router.back()，否则会关闭刚打开的通话页面
        CallUILog.info(GroupCallLaunchPage.TAG, '群呼发起成功');
      } else if (result.code === -1) {
        // 所有被叫均忙线（在通话中），呼叫立即结束，停留在发起页等待用户重试
        CallUILog.info(GroupCallLaunchPage.TAG, `群呼已提前结束（所有被叫忙线）: ${result.message}`);
        ToastUtils.showToastWithString(getContext(this) as common.UIAbilityContext, '呼叫失败，对方正在通话中');
      } else {
        // 群呼发起失败，使用国际化错误消息
        CallUILog.error(
          GroupCallLaunchPage.TAG,
          `群呼发起失败: code=${result.code}, message=${result.message}`
        );
        const errorMsg = this.getErrorMessage(result.code);
        ToastUtils.showToastWithString(getContext(this) as common.UIAbilityContext, errorMsg);
      }
    } catch (e) {
      CallUILog.error(GroupCallLaunchPage.TAG, `群呼异常: ${String(e)}`);
      ToastUtils.showToastWithString(
        getContext(this) as common.UIAbilityContext,
        this.getLocalizedString('group_call_failed')
      );
    } finally {
      this.isCalling = false;
    }
  }

  /**
   * 邀请新成员加入通话（邀请模式）
   */
  private async inviteMembers(): Promise<void> {
    // 验证输入
    const error = this.validateInputs();
    if (error) {
      ToastUtils.showToastWithString(getContext(this) as common.UIAbilityContext, error);
      return;
    }

    if (this.isCalling) {
      return;
    }

    this.isCalling = true;

    try {
      const accounts = this.getValidAccounts();

      // 过滤已在通话中的用户
      const existingIds = new Set(CallState.instance.remoteUserList.map(u => u.id));
      existingIds.add(CallState.instance.selfUser.id); // 排除自己
      const filteredAccounts = accounts.filter(id => !existingIds.has(id));

      if (filteredAccounts.length === 0) {
        ToastUtils.showToastWithString(getContext(this) as common.UIAbilityContext, this.getLocalizedString('user_already_in_call'));
        return;
      }

      // 人数限制：当前成员数（含自己）+ 新邀请人数 ≤ MAX_PARTICIPANTS
      const currentTotal = CallState.instance.remoteUserList.length + 1;
      if (currentTotal + filteredAccounts.length > NEGroupCallConstants.MAX_PARTICIPANTS) {
        ToastUtils.showToastWithString(getContext(this) as common.UIAbilityContext, this.getLocalizedString('group_call_exceed_max', NEGroupCallConstants.MAX_PARTICIPANTS));
        return;
      }

      CallUILog.info(
        GroupCallLaunchPage.TAG,
        `[群呼邀请] 邀请成员: callId=${this.callId}, accounts=${filteredAccounts.join(',')} (filtered from ${accounts.join(',')})`
      );

      // 创建邀请参数
      const param: GroupInviteParam = {
        callId: this.callId,
        inviteeList: filteredAccounts
      };

      // 调用 groupInvite 接口
      const result = await NEGroupCall.getInstance().groupInvite(param);
      CallUILog.info(GroupCallLaunchPage.TAG, `[群呼邀请] groupInvite 返回: code=${result.code}`);

      if (result.code === 0) {
        // 邀请成功，获取用户信息并添加到 remoteUserList
        CallUILog.info(GroupCallLaunchPage.TAG, '邀请成功，获取用户信息并添加到列表');

        // 过滤出不存在的用户
        const newAccIds = accounts.filter(accId =>
          !CallState.instance.remoteUserList.find(u => u.id === accId)
        );

        if (newAccIds.length > 0) {
          // 获取用户信息（头像、昵称）
          try {
            const userInfoList = await NimUtils.getUserInfos(newAccIds);
            for (const userInfo of userInfoList) {
              const newUser = new User();
              newUser.id = userInfo.id;
              newUser.nickname = userInfo.nickname || userInfo.id;
              newUser.avatar = userInfo.avatar || '';
              newUser.callRole = NECallRole.CALLED;
              newUser.callStatus = NECallStatus.WAITING;  // 待接听状态
              newUser.videoAvailable = false;
              newUser.audioAvailable = false;
              CallState.instance.remoteUserList.push(newUser);
              CallUILog.info(GroupCallLaunchPage.TAG, `添加被邀请用户: ${userInfo.id}, nickname=${userInfo.nickname}`);
            }
          } catch (e) {
            // 获取用户信息失败，使用 accId 作为昵称
            CallUILog.error(GroupCallLaunchPage.TAG, `获取用户信息失败: ${String(e)}`);
            for (const accId of newAccIds) {
              const newUser = new User();
              newUser.id = accId;
              newUser.nickname = accId;
              newUser.callRole = NECallRole.CALLED;
              newUser.callStatus = NECallStatus.WAITING;
              newUser.videoAvailable = false;
              newUser.audioAvailable = false;
              CallState.instance.remoteUserList.push(newUser);
            }
          }
        }

        // 触发 UI 刷新
        NEEventNotify.getInstance().notify(setStateEvent);

        ToastUtils.showToastWithString(getContext(this) as common.UIAbilityContext, '邀请已发送');
        router.back();
      } else {
        // 邀请失败
        CallUILog.error(
          GroupCallLaunchPage.TAG,
          `邀请失败: code=${result.code}, message=${result.message}`
        );
        ToastUtils.showToastWithString(
          getContext(this) as common.UIAbilityContext,
          result.message ?? '邀请失败'
        );
      }
    } catch (e) {
      CallUILog.error(GroupCallLaunchPage.TAG, `邀请异常: ${String(e)}`);
      ToastUtils.showToastWithString(getContext(this) as common.UIAbilityContext, '邀请异常');
    } finally {
      this.isCalling = false;
    }
  }

  /**
   * 处理提交按钮点击
   */
  private handleSubmit(): void {
    if (this.isInviteMode) {
      this.inviteMembers();
    } else {
      this.startGroupCall();
    }
  }

  build() {
    Column() {
      // 状态栏安全区域（仅邀请模式需要，因为从全屏通话页面跳转）
      if (this.isInviteMode) {
        Column()
          .width('100%')
          .height(44)
      }

      // 标题栏
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#333333')
          .margin({ left: 16 })
          .onClick(() => router.back())

        Text(this.isInviteMode ? '邀请成员' : '发起多人通话')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .margin({ left: 16 })
          .layoutWeight(1)

        if (!this.isInviteMode) {
          Image($r('app.media.ic_settings'))
            .width(24)
            .height(24)
            .fillColor('#333333')
            .margin({ right: 16 })
            .onClick(() => {
              router.pushNamedRoute({ name: 'groupCallSettingsPage' });
            })
        }
      }
      .width('100%')
      .height(56)
      .alignItems(VerticalAlign.Center)

      // 分隔线
      Divider()
        .width('100%')
        .height(1)
        .color('#E5E5E5')

      // 账号输入区域（可滚动）
      Scroll() {
        Column() {
          // 提示文字
          Text(`请输入被叫方账号（${NEGroupCallConstants.MIN_PARTICIPANTS - 1}-${NEGroupCallConstants.MAX_PARTICIPANTS - 1}人）`)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 16, bottom: 12, left: 16, right: 16 })

          // 账号输入列表
          ForEach(this.accountInputs, (item: AccountInput, index: number) => {
            Row() {
              TextInput({ placeholder: `账号 ${index + 1}`, text: item.value })
                .width(0)
                .layoutWeight(1)
                .height(44)
                .fontSize(16)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .padding({ left: 12, right: 12 })
                .onChange((value: string) => {
                  this.updateAccountInput(item.id, value);
                })

              // 删除按钮（保持最少输入框数量：邀请模式最少1个，发起模式最少 MIN_PARTICIPANTS-1 个）
              if (this.accountInputs.length > (this.isInviteMode ? 1 : NEGroupCallConstants.MIN_PARTICIPANTS - 1)) {
                Text('✕')
                  .fontSize(20)
                  .fontColor('#FF4444')
                  .width(32)
                  .height(32)
                  .textAlign(TextAlign.Center)
                  .margin({ left: 8 })
                  .onClick(() => this.removeAccountInput(item.id))
              }
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 6, bottom: 6 })
          }, (item: AccountInput) => item.id.toString())

          // 添加更多账号按钮（暂时放开限制，方便测试异常case）
          // if (this.accountInputs.length < NEGroupCallConstants.MAX_PARTICIPANTS - 1) {
          if (true) {
            Button('+ 添加更多')
              .type(ButtonType.Normal)
              .fontSize(14)
              .fontColor('#337EFF')
              .backgroundColor('#FFFFFF')
              .borderWidth(1)
              .borderColor('#337EFF')
              .borderRadius(8)
              .height(40)
              .width('90%')
              .margin({ top: 12 })
              .onClick(() => this.addAccountInput())
          }
        }
        .width('100%')
        .padding({ bottom: 20 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)

      // 底部按钮
      Button(this.isCalling ? '处理中...' : (this.isInviteMode ? '邀请' : '发起呼叫'))
        .type(ButtonType.Normal)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .backgroundColor(this.isCalling ? '#CCCCCC' : '#337EFF')
        .borderRadius(24)
        .height(48)
        .width('90%')
        .margin({ bottom: 32 })
        .enabled(!this.isCalling)
        .onClick(() => this.handleSubmit())
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
