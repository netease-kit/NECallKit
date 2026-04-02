// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { CallState } from '../impl/CallState';
import { CallManager } from '../impl/CallManager';
import { NECallStatus } from '../CallDefine';
import { setStateEventOnCallEnd } from '../data/Constants';
import { NEEventNotify } from '../event/EventNotify';
import router from '@ohos.router';
import { CallMainWidget } from '../widget/CallMainWidget';
import common from '@ohos.app.ability.common';
import { CallUILog } from '../utils/CallUILog';
import { NECallEndInfo, NECallEndReason, NEGroupCall } from '@yunxin/callkit';
import { promptAction } from '@kit.ArkUI';
import { ToastUtils } from '../utils/ToastUtils';

/**
 * Resource 对象接口，用于访问资源ID
 */
interface ResourceWithId {
  id?: number;
}


/**
 * 通话主页面容器
 * 对应 Flutter 版本的 NECallKitWidget
 * 负责生命周期管理、事件监听、防止返回等
 */
@Entry({ routeName: 'callMainPage' })
@Component
export struct CallMainPage {
  static TAG = "CallMainPage";
  private endCallback = (arg?: Record<string, Object>) => {
    CallUILog.info(CallMainPage.TAG, `[诊断] endCallback called, isActiveHangup=${CallState.instance.isActiveHangup}`);
    // 主动挂断由 CallManager.hangup() 处理页面关闭，跳过回调中的重复关闭
    if (CallState.instance.isActiveHangup) {
      CallUILog.info(CallMainPage.TAG, `endCallback: 主动挂断，跳过重复关闭`);
      return;
    }

    // 显示通话结束的 toast 提示
    if (arg) {
      let showToast = arg['showToast'] as boolean;
      if (showToast && arg['info']) {
        const info = arg['info'] as NECallEndInfo;
        const isGroupCall = CallState.instance.isGroupCall();

        // 群呼场景下，本端拒绝不显示 toast
        const isRejectReason = info.reason == NECallEndReason.TERMINAL_CALLEE_REJECT
          || info.reason == NECallEndReason.TERMINAL_CALLER_REJECTED;

        if (isGroupCall && isRejectReason) {
          CallUILog.info(CallMainPage.TAG, `群呼拒绝，不显示 toast`);
        } else if (info.reason == NECallEndReason.TERMINAL_CALLEE_REJECT
          || info.reason == NECallEndReason.TERMINAL_CALLER_REJECTED
          || info.reason == NECallEndReason.TERMINAL_OTHER_ACCEPTED
          || info.reason == NECallEndReason.TERMINAL_OTHER_REJECTED
          || info.reason == NECallEndReason.TERMINAL_CODE_TIME_OUT
          || info.reason == NECallEndReason.TERMINAL_CALLER_CANCEL
          || info.reason == NECallEndReason.TERMINAL_CODE_BUSY
        ) {
          this.showCallEndToast(info);
        }
      }
    }

    this.close()
  }

  onBackPress(): boolean | void {
    return true
  }
  
  private originalFullScreen: boolean = false;
  private isClosing: boolean = false; // 标志：确保 close() 只被调用一次
  private hasCheckedCallState: boolean = false; // 标志：onPageShow 首次检查用

  aboutToAppear(): void {
    // 设置全屏和透明状态栏
    this.setFullScreenWithTransparentStatusBar();

    // 注册通话结束事件监听
    NEEventNotify.getInstance().register(setStateEventOnCallEnd, this.endCallback);
  }

  onPageShow(): void {
    const groupCallInfo = NEGroupCall.getInstance().currentGroupCallInfo();
    CallUILog.info(CallMainPage.TAG, `[诊断] onPageShow: hasChecked=${this.hasCheckedCallState}, currentGroupCallInfo=${groupCallInfo ? groupCallInfo.callId : 'null'}`);
    // 页面完全显示后（路由栈已稳定），仅首次执行检查
    // 场景：群呼所有被叫在 launchCallingPage 与 aboutToAppear 之间全部 BUSY 拒绝，
    // setStateEventOnCallEnd 可能已在注册前触发，此时 currentGroupCallInfo 已为 null
    if (!this.hasCheckedCallState) {
      this.hasCheckedCallState = true;
      // 仅群呼场景才需要此检查：1v1 通话时 currentGroupCallInfo() 必然为 null
      if (CallState.instance.isGroupCall() && NEGroupCall.getInstance().currentGroupCallInfo() === null) {
        CallUILog.warn(CallMainPage.TAG, 'onPageShow: group call already ended, closing');
        this.close();
      }
    }
  }

  aboutToDisappear(): void {
    // 恢复窗口设置
    this.restoreWindowSettings();
    
    // 注销事件监听
    NEEventNotify.getInstance().unregister(setStateEventOnCallEnd, this.endCallback);
  }
  
  /**
   * 设置全屏显示和透明状态栏
   */
  private async setFullScreenWithTransparentStatusBar(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      if (!context) {
        CallUILog.warn(CallMainPage.TAG, '无法获取 context，跳过窗口设置');
        return;
      }
      
      // 获取窗口阶段
      const windowStage = context.windowStage;
      if (!windowStage) {
        CallUILog.warn(CallMainPage.TAG, '无法获取 windowStage，跳过窗口设置');
        return;
      }
      
      // 获取主窗口（异步）
      const mainWindow = await windowStage.getMainWindow();
      if (!mainWindow) {
        CallUILog.warn(CallMainPage.TAG, '无法获取主窗口，跳过窗口设置');
        return;
      }
      
      // 保存原始全屏状态（如果需要恢复）
      // 注意：HarmonyOS 可能没有直接获取当前全屏状态的 API，这里假设初始为 false
      this.originalFullScreen = false;
      
      // 设置全屏布局（隐藏状态栏和导航栏）
      mainWindow.setWindowLayoutFullScreen(true).catch(() => {
        CallUILog.error(CallMainPage.TAG, 'setWindowLayoutFullScreen error')
      });
      
      // 设置状态栏和导航栏为透明
      // ContentColor: 'auto'=CONTENT_COLOR_AUTO, 'light'=CONTENT_COLOR_LIGHT, 'dark'=CONTENT_COLOR_DARK
      mainWindow.setWindowSystemBarProperties({
        statusBarColor: '#00000000', // 完全透明
        navigationBarColor: '#00000000', // 完全透明
        statusBarContentColor: 'light', // CONTENT_COLOR_LIGHT (浅色/白色内容)
        navigationBarContentColor: 'light' // CONTENT_COLOR_LIGHT (浅色/白色内容)
      }).catch(() => {
        CallUILog.error(CallMainPage.TAG, 'setWindowSystemBarProperties error')
      });
      
      CallUILog.info(CallMainPage.TAG, '已设置全屏和透明状态栏');
    } catch (error) {
      CallUILog.error(CallMainPage.TAG, `设置全屏和透明状态栏失败: ${JSON.stringify(error)}`);
    }
  }
  
  /**
   * 恢复窗口设置
   */
  private async restoreWindowSettings(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      if (!context) {
        return;
      }
      
      const windowStage = context.windowStage;
      if (!windowStage) {
        return;
      }
      
      // 获取主窗口（异步）
      const mainWindow = await windowStage.getMainWindow();
      if (!mainWindow) {
        return;
      }
      
      // 恢复全屏状态
      mainWindow.setWindowLayoutFullScreen(this.originalFullScreen).catch(() => {
        CallUILog.error(CallMainPage.TAG, `setWindowLayoutFullScreen error`);
      });
      
      // 恢复状态栏属性（如果需要）
      // 注意：这里可以根据实际需求决定是否恢复
      // 如果页面退出后不需要恢复，可以注释掉这部分代码
      
      CallUILog.info(CallMainPage.TAG, '已恢复窗口设置');
    } catch (error) {
      CallUILog.error(CallMainPage.TAG, `恢复窗口设置失败: ${JSON.stringify(error)}`);
    }
  }

  build() {
    // @Entry 组件必须有一个容器组件作为根节点
    Stack() {
      CallMainWidget({ close: this.close })
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 显示通话结束的 toast 提示
   * @param info 通话结束信息
   */
  private showCallEndToast(info: NECallEndInfo): void {
    const reason = info.reason;
    let messageRes: Resource;

    switch (reason) {
      // 正常流程 - 不显示提示
      case NECallEndReason.TERMINAL_CODE_NORMAL:
        return;

      // 挂断相关
      case NECallEndReason.TERMINAL_HANG_UP:
      case NECallEndReason.TERMINAL_BE_HANG_UP:
        messageRes = $r('app.string.call_end_hangup');
        break;

      // 拒绝相关
      case NECallEndReason.TERMINAL_CALLEE_REJECT:
        messageRes = $r('app.string.callee_end_reject');
        break;
      
      case NECallEndReason.TERMINAL_CALLER_REJECTED:
        messageRes = $r('app.string.callee_end_reject');
        break;

      // 超时
      case NECallEndReason.TERMINAL_CODE_TIME_OUT:
        messageRes = $r('app.string.call_end_no_response');
        break;

      // 忙线
      case NECallEndReason.TERMINAL_CODE_BUSY:
        messageRes = $r('app.string.call_end_line_busy');
        break;

      // 取消相关
      case NECallEndReason.TERMINAL_CALLER_CANCEL:
      case NECallEndReason.TERMINAL_CALLEE_CANCEL:
        messageRes = $r('app.string.call_end_canceled');
        break;

      // 多端登录相关
      case NECallEndReason.TERMINAL_OTHER_ACCEPTED:
        messageRes = $r('app.string.call_end_other_device_accepted');
        break;
      case NECallEndReason.TERMINAL_OTHER_REJECTED:
        messageRes = $r('app.string.call_end_other_device_reject');
        break;

      // RTC 断开相关
      case NECallEndReason.TERMINAL_USER_RTC_DISCONNECTED:
      case NECallEndReason.TERMINAL_RTC_DISCONNECTED:
      case NECallEndReason.TERMINAL_USER_RTC_LEAVE:
        messageRes = $r('app.string.call_end_server');
        break;

      // 错误相关 - 使用通用错误提示
      case NECallEndReason.TERMINAL_CODE_TOKEN_ERROR:
      case NECallEndReason.TERMINAL_CODE_RTC_INIT_ERROR:
      case NECallEndReason.TERMINAL_CODE_JOIN_RTC_ERROR:
      case NECallEndReason.TERMINAL_CODE_CANCEL_ERROR_PARAM:
      case NECallEndReason.TERMINAL_CODE_CALL_FAILED:
      case NECallEndReason.TERMINAL_CODE_KICKED:
      case NECallEndReason.TERMINAL_CODE_EMPTY_UID:
      case NECallEndReason.TERMINAL_ACCEPT_FAIL:
        messageRes = $r('app.string.call_end_unknown');
        break;

      // 默认情况
      default:
        messageRes = $r('app.string.call_end_unknown');
        break;
    }

    ToastUtils.showToast(getContext(this) as common.UIAbilityContext, messageRes)
  }
  private close(): void {
    // 如果已经正在关闭或已经关闭，直接返回，确保只调用一次
    if (this.isClosing) {
      CallUILog.warn(CallMainPage.TAG, `close() 已被调用，忽略重复调用`);
      return;
    }

    // 设置标志，防止重复调用
    this.isClosing = true;

    // 清除保存的路由信息
    CallManager.instance.clearPreviousRoute();

    // 检查路由栈长度，决定返回方式
    // router.getLength() 返回路由栈中的页面数量（字符串类型）
    // 如果只有当前页面（length <= 1），back() 会导致应用退出
    const routerLengthStr = router.getLength();
    const routerLength = parseInt(routerLengthStr, 10) || 0;
    CallUILog.info(CallMainPage.TAG, `关闭通话页面，路由栈长度=${routerLength}`);

    if (routerLength > 1) {
      // 有上一页，直接返回
      router.back();
    } else {
      // 没有上一页（可能是从通知直接打开）
      // 尝试返回到路由栈中的第一页（通常是应用首页）
      CallUILog.info(CallMainPage.TAG, `没有上一页，尝试返回到路由栈底部`);
      try {
        // 使用 router.clear() 清空路由栈并返回到入口页面
        router.clear();
      } catch (error) {
        CallUILog.error(CallMainPage.TAG, `router.clear() 失败: ${String(error)}`);
        // 如果 clear 失败，尝试 back()
        router.back();
      }
    }
  }
}
