// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { PiPWindow, BuilderNode, FrameNode, NodeController, UIContext } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { MethodChannel } from '@ohos/flutter_ohos';
import { CallState, CallStateListener, MediaType } from '../state/CallState';
import { CallUILog } from '../utils/CallUILog';
import { NERtcVideoView, NERtcConstants } from '@nertc/nertc_sdk';
import { NECallEngine } from '@yunxin/callkit';

const TAG = 'NECallKitPip';
const PIP_CANVAS_ID = 'pip_remote_canvas';

/**
 * 画中画 UI 参数
 */
class PIPUIParams {
  canvasId: string = PIP_CANVAS_ID;
  showAvatar: boolean = false;
  avatarUrl: string = '';
}

/**
 * 画中画视频视图 Builder
 * 显示远端视频（使用 NECallEngine.setupRemoteView，无需 UID）
 * 当对端关闭视频时，显示头像
 */
@Builder
function pipVideoViewBuilder(params: PIPUIParams) {
  Stack() {
    // 视频视图层（始终存在，但可能被头像遮挡）
    NERtcVideoView({
      canvasId: params.canvasId,
      onLoad: () => {
        CallUILog.i(TAG, `PiP NERtcVideoView onLoad, canvasId=${params.canvasId}`);
        
        // 使用 NECallEngine.setupRemoteView 设置远端视频画布
        // 这个接口不需要 UID，SDK 内部会自动处理 1v1 通话的远端用户
        const canvas: NERtcConstants.NERtcVideoCanvas = {
          canvasId: params.canvasId,
          scalingMode: NERtcConstants.NERtcVideoScalingMode.kNERtcVideoScaleCropFill
        };
        
        try {
          const ret = NECallEngine.getInstance().setupRemoteView(canvas);
          CallUILog.i(TAG, `NECallEngine.setupRemoteView ret=${ret}, canvasId=${params.canvasId}`);
        } catch (e) {
          CallUILog.e(TAG, `setupRemoteView error: ${e}`);
        }
      },
      onDestroy: () => {
        CallUILog.i(TAG, `PiP NERtcVideoView onDestroy, canvasId=${params.canvasId}`);
      }
    })
      .width('100%')
      .height('100%')
    
    // 头像遮罩层（当对端关闭视频时显示）
    if (params.showAvatar) {
      Column() {
        Image(params.avatarUrl && params.avatarUrl.length > 0 
          ? params.avatarUrl 
          : $r('app.media.ic_avatar_default'))
          .width(80)
          .height(80)
          .borderRadius(40)
          .objectFit(ImageFit.Cover)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#1A1A1A')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
  }
  .width('100%')
  .height('100%')
}

/**
 * 画中画视频 NodeController
 * 继承 NodeController 实现自定义 UI 控制器
 * 支持动态更新显示内容（视频/头像）
 */
export class PipVideoNodeController extends NodeController {
  private videoViewNode: BuilderNode<[PIPUIParams]> | null = null;
  private wrapBuilder: WrappedBuilder<[PIPUIParams]> = wrapBuilder(pipVideoViewBuilder);
  public params: PIPUIParams = new PIPUIParams();
  private uiContext: UIContext | null = null;

  makeNode(uiContext: UIContext): FrameNode | null {
    this.uiContext = uiContext;
    this.videoViewNode = new BuilderNode(uiContext);
    this.videoViewNode.build(this.wrapBuilder, this.params);
    const frameNode = this.videoViewNode.getFrameNode();
    return frameNode !== undefined ? frameNode : null;
  }

  aboutToResize(size: Size): void {
    CallUILog.i(TAG, `NodeController aboutToResize width=${size.width}, height=${size.height}`);
  }

  aboutToAppear(): void {
    CallUILog.i(TAG, 'NodeController aboutToAppear');
  }

  aboutToDisappear(): void {
    CallUILog.i(TAG, 'NodeController aboutToDisappear');
  }

  onTouchEvent(event: TouchEvent): void {
    CallUILog.i(TAG, 'NodeController onTouchEvent');
  }

  /**
   * 更新显示状态（视频/头像）
   * @param showAvatar 是否显示头像
   * @param avatarUrl 头像 URL
   */
  updateDisplay(showAvatar: boolean, avatarUrl: string): void {
    CallUILog.i(TAG, `NodeController updateDisplay showAvatar=${showAvatar}, avatarUrl=${avatarUrl}`);
    
    if (this.params.showAvatar === showAvatar && this.params.avatarUrl === avatarUrl) {
      CallUILog.i(TAG, 'NodeController updateDisplay: no change, skip rebuild');
      return;
    }
    
    this.params.showAvatar = showAvatar;
    this.params.avatarUrl = avatarUrl;
    
    // 重新构建视图
    if (this.uiContext !== null && this.videoViewNode !== null) {
      try {
        this.videoViewNode.build(this.wrapBuilder, this.params);
        CallUILog.i(TAG, 'NodeController view rebuilt successfully');
      } catch (e) {
        CallUILog.e(TAG, `NodeController rebuild error: ${e}`);
      }
    }
  }

  dispose(): void {
    CallUILog.i(TAG, 'NodeController dispose');
    if (this.videoViewNode !== null) {
      this.videoViewNode.dispose();
      this.videoViewNode = null;
    }
    this.uiContext = null;
  }
}

/**
 * 画中画管理器
 * 负责管理通话中的画中画窗口
 * 
 * 实现说明：
 * 参考华为文档和 rtc_harmony_demo 的实现方式
 * 使用 customUIController + NodeController 在画中画窗口中显示视频
 * 支持监听对端视频状态，在对端关闭视频时显示头像
 */
export class PipManager {
  private static inst: PipManager | null = null;
  private channel: MethodChannel | null = null;
  private pipConfig: PiPWindow.PiPConfiguration | undefined = undefined;
  private pipController: PiPWindow.PiPController | undefined = undefined;
  private nodeController: PipVideoNodeController = new PipVideoNodeController();
  private xComponentController: XComponentController = new XComponentController();
  private context: common.UIAbilityContext | null = null;
  private isPipActive: boolean = false;
  // 标记画中画是否已经手动启动（通过点击悬浮窗按钮）
  // 如果已手动启动，则退后台时不再自动启动
  private isManuallyStarted: boolean = false;
  // 状态监听器，用于监听 videoAvailable 变化
  private stateListener: CallStateListener | null = null;
  // 标记是否正在从画中画恢复应用（用户点击画中画窗口）
  // 用于区分用户点击恢复和用户拖到垃圾桶关闭的情况
  private isRestoringFromPip: boolean = false;

  private constructor() {}

  static getInstance(): PipManager {
    if (!PipManager.inst) {
      PipManager.inst = new PipManager();
    }
    return PipManager.inst;
  }

  setChannel(channel: MethodChannel): void {
    this.channel = channel;
  }

  /**
   * 初始化画中画配置并创建控制器
   * @param context 应用上下文
   * @param navigationId 导航 ID（可选）
   */
  async init(context: common.UIAbilityContext, navigationId?: string): Promise<void> {
    CallUILog.i(TAG, `init: context exists=${context !== null}`);
    this.context = context;

    // 检查系统是否支持画中画
    const isPiPEnabled = PiPWindow.isPiPEnabled();
    CallUILog.i(TAG, `PiPWindow.isPiPEnabled()=${isPiPEnabled}`);

    if (!isPiPEnabled) {
      CallUILog.e(TAG, 'Picture in Picture is disabled for current OS');
      return;
    }

    // 如果已经有控制器，先释放
    if (this.pipController !== undefined) {
      CallUILog.i(TAG, 'Releasing existing PiP controller before re-init');
      try {
        this.pipController.off('stateChange');
        this.pipController.off('controlPanelActionEvent');
      } catch (e) {
        // ignore
      }
      this.pipController = undefined;
    }

    // 配置画中画参数
    this.pipConfig = {
      context: context,
      componentController: this.xComponentController,
      templateType: PiPWindow.PiPTemplateType.VIDEO_CALL,
      contentWidth: 720,
      contentHeight: 1280,
      // 使用 customUIController 显示自定义视频视图
      customUIController: this.nodeController,
    };

    if (navigationId !== undefined && navigationId !== '') {
      this.pipConfig.navigationId = navigationId;
    }

    CallUILog.i(TAG, `PiP config initialized: templateType=${this.pipConfig.templateType}`);

    // 在前台时就创建画中画控制器
    try {
      CallUILog.i(TAG, 'Creating PiP controller in init...');
      this.pipController = await PiPWindow.create(this.pipConfig);
      CallUILog.i(TAG, 'PiP controller created successfully in init');

      // 初始化控制器回调
      this.initPipController();

      // 设置自动启动画中画（当应用退到后台时自动启动）
      this.pipController.setAutoStartEnabled(true);
      CallUILog.i(TAG, 'PiP auto start enabled');
    } catch (err) {
      const error = err as BusinessError;
      CallUILog.e(TAG, `Failed to create PiP controller in init. Code: ${error.code}, Message: ${error.message}`);
    }
  }

  /**
   * 设置远端用户的 RTC UID（从 Flutter 传递）
   * 注意：使用 NECallEngine.setupRemoteView 后，此方法不再需要，保留用于兼容
   * @param uid RTC UID（字符串格式的数字）
   */
  setRemoteUid(uid: string): void {
    CallUILog.i(TAG, `setRemoteUid: ${uid} (not used with NECallEngine.setupRemoteView)`);
  }

  /**
   * 启动画中画
   */
  async startPip(): Promise<void> {
    CallUILog.i(TAG, '========== startPip called ==========');

    if (this.pipConfig === undefined) {
      CallUILog.e(TAG, 'PiP config not initialized, call init() first');
      return;
    }

    // 检查是否为视频通话
    const state = CallState.getInstance();
    CallUILog.i(TAG, `startPip: mediaType=${state.mediaType}, VIDEO=${MediaType.VIDEO}`);
    if (state.mediaType !== MediaType.VIDEO) {
      CallUILog.w(TAG, `Only video call supports PiP, current mediaType=${state.mediaType}`);
      return;
    }

    // 检查是否有远端用户
    CallUILog.i(TAG, `startPip: remoteUserList.length=${state.remoteUserList.length}`);
    
    if (state.remoteUserList.length > 0) {
      const firstRemote = state.remoteUserList[0];
      CallUILog.i(TAG, `startPip: first remote user accId="${firstRemote.accId}", callStatus=${firstRemote.callStatus}, videoAvailable=${firstRemote.videoAvailable}`);
      
      // 初始化 NodeController 的显示状态
      const showAvatar = !(firstRemote.videoAvailable ?? false);
      const avatarUrl = firstRemote.avatar ?? '';
      this.nodeController.updateDisplay(showAvatar, avatarUrl);
    } else {
      CallUILog.w(TAG, 'No remote user found, cannot start PiP');
      return;
    }

    try {
      // 创建画中画控制器
      CallUILog.i(TAG, 'Creating PiP controller...');
      CallUILog.i(TAG, `PiP config: templateType=${this.pipConfig.templateType}, width=${this.pipConfig.contentWidth}, height=${this.pipConfig.contentHeight}`);
      
      this.pipController = await PiPWindow.create(this.pipConfig);
      CallUILog.i(TAG, 'PiP controller created successfully');

      // 初始化画中画控制器
      this.initPipController();
      
      // 重置恢复标志，确保新的画中画控制器有正确的初始状态
      this.isRestoringFromPip = false;

      // 启动画中画
      CallUILog.i(TAG, 'Starting PiP...');
      await this.pipController.startPiP();
      this.isPipActive = true;
      // 标记为手动启动，禁用自动启动
      this.isManuallyStarted = true;
      if (this.pipController !== undefined) {
        this.pipController.setAutoStartEnabled(false);
        CallUILog.i(TAG, 'PiP auto start disabled after manual start');
      }
      CallUILog.i(TAG, '========== PiP started successfully (manually) ==========');

      // 注册状态监听器，监听 videoAvailable 变化
      this.registerStateListener();

      // 通知 Flutter 层画中画已启动
      if (this.channel !== null) {
        this.channel.invokeMethod('onPipStarted', {});
      }
    } catch (err) {
      const error = err as BusinessError;
      CallUILog.e(TAG, `========== Failed to start PiP. Code: ${error.code}, Message: ${error.message} ==========`);
      this.isPipActive = false;
    }
  }

  /**
   * 注册状态监听器，监听 videoAvailable 变化
   */
  private registerStateListener(): void {
    if (this.stateListener !== null) {
      CallUILog.i(TAG, 'State listener already registered, skip');
      return;
    }

    this.stateListener = () => {
      this.onCallStateChanged();
    };
    CallState.getInstance().addListener(this.stateListener);
    CallUILog.i(TAG, 'State listener registered for PiP');
  }

  /**
   * 注销状态监听器
   */
  private unregisterStateListener(): void {
    if (this.stateListener !== null) {
      CallState.getInstance().removeListener(this.stateListener);
      this.stateListener = null;
      CallUILog.i(TAG, 'State listener unregistered for PiP');
    }
  }

  /**
   * 处理 CallState 变化
   * 主要监听对端 videoAvailable 变化，更新画中画显示内容
   */
  private onCallStateChanged(): void {
    if (!this.isPipActive) {
      return;
    }

    const state = CallState.getInstance();
    if (state.remoteUserList.length > 0) {
      const firstRemote = state.remoteUserList[0];
      const showAvatar = !(firstRemote.videoAvailable ?? false);
      const avatarUrl = firstRemote.avatar ?? '';
      
      CallUILog.i(TAG, `onCallStateChanged: videoAvailable=${firstRemote.videoAvailable}, showAvatar=${showAvatar}`);
      
      // 更新 NodeController 显示
      this.nodeController.updateDisplay(showAvatar, avatarUrl);
    }
  }

  /**
   * 停止画中画
   */
  async stopPip(): Promise<void> {
    CallUILog.i(TAG, 'stopPip called');

    // 注销状态监听器
    this.unregisterStateListener();

    if (this.pipController === undefined) {
      CallUILog.w(TAG, 'PiP controller not exists');
      return;
    }
    
    // 设置标志，避免 STOPPED 回调中重复挂断通话
    // 因为这是程序主动调用 stopPip，不是用户关闭画中画
    this.isRestoringFromPip = true;
    
    this.pipController.setAutoStartEnabled(false);

    try {
      await this.pipController.stopPiP();
      CallUILog.i(TAG, 'PiP stopped successfully');

      // 注销回调
      this.pipController.off('stateChange');
      this.pipController.off('controlPanelActionEvent');
      this.pipController = undefined;
      this.isPipActive = false;

      // 重置手动启动标志，以便下次退后台时可以自动启动画中画
      this.isManuallyStarted = false;
      CallUILog.i(TAG, 'isManuallyStarted reset to false after stopPip');

      // 清理 NodeController
      this.nodeController.dispose();

      // 通知 Flutter 层画中画已停止
      if (this.channel !== null) {
        this.channel.invokeMethod('onPipStopped', {});
      }
    } catch (err) {
      const error = err as BusinessError;
      CallUILog.e(TAG, `Failed to stop PiP. Code: ${error.code}, Message: ${error.message}`);
    }
  }

  /**
   * 初始化画中画控制器（注册回调）
   */
  private initPipController(): void {
    if (this.pipController === undefined) {
      return;
    }

    // 注册状态变化回调
    this.pipController.on('stateChange', (state: PiPWindow.PiPState, reason: string) => {
      this.onStateChange(state, reason);
    });

    // 注册控制面板事件回调
    this.pipController.on('controlPanelActionEvent', (event: PiPWindow.PiPActionEventType, status?: number) => {
      this.onActionEvent(event, status);
    });

    CallUILog.i(TAG, 'PiP controller callbacks registered');
  }

  /**
   * 处理画中画状态变化
   */
  private onStateChange(state: PiPWindow.PiPState, reason: string): void {
    CallUILog.i(TAG, `onStateChange called, state=${state}, reason=${reason}`);
    let curState: string = '';
    switch (state) {
      case PiPWindow.PiPState.ABOUT_TO_START:
        curState = 'ABOUT_TO_START';
        // 画中画即将启动，设置 isPipActive 为 true，以便状态监听器能正常工作
        this.isPipActive = true;
        // 画中画即将启动，通知 Flutter 层
        CallUILog.i(TAG, `PiP ABOUT_TO_START, channel=${this.channel !== null}, notifying Flutter`);
        if (this.channel !== null) {
          CallUILog.i(TAG, 'invokeMethod pipAboutToStart (from ABOUT_TO_START)');
          this.channel.invokeMethod('pipAboutToStart', {});
        } else {
          CallUILog.e(TAG, 'channel is null, cannot notify Flutter');
        }
        // 注册状态监听器，监听 videoAvailable 变化
        this.registerStateListener();
        break;
      case PiPWindow.PiPState.STARTED:
        curState = 'STARTED';
        this.isPipActive = true;
        // 画中画启动成功后，通知 Flutter 层退出通话页面
        // 这对于自动启动画中画（setAutoStartEnabled）的场景很重要
        // 手动启动时 Flutter 端已经自己处理了退出页面的逻辑，这里的通知也不会有副作用
        CallUILog.i(TAG, `PiP STARTED, channel=${this.channel !== null}, notifying Flutter`);
        if (this.channel !== null) {
          CallUILog.i(TAG, 'invokeMethod appEnterBackground');
          this.channel.invokeMethod('appEnterBackground', {});
        } else {
          CallUILog.e(TAG, 'channel is null, cannot notify Flutter');
        }
        break;
      case PiPWindow.PiPState.ABOUT_TO_STOP:
        curState = 'ABOUT_TO_STOP';
        // 清理 NodeController
        this.nodeController.dispose();
        // 注销状态监听器
        this.unregisterStateListener();
        break;
      case PiPWindow.PiPState.STOPPED:
        curState = 'STOPPED';
        this.isPipActive = false;
        // 用户主动关闭画中画（如拖到垃圾桶），需要挂断通话
        // 判断条件：不是因为 ABOUT_TO_RESTORE（恢复应用）导致的 STOPPED
        if (!this.isRestoringFromPip) {
          CallUILog.i(TAG, 'PiP STOPPED by user dismiss (not restore), hanging up call');
          // 清理资源
          this.unregisterStateListener();
          if (this.pipController !== undefined) {
            try {
              this.pipController.off('stateChange');
              this.pipController.off('controlPanelActionEvent');
            } catch (e) {
              // ignore
            }
            this.pipController = undefined;
          }
          this.nodeController.dispose();
          // 重置手动启动标志
          this.isManuallyStarted = false;
          // 通知 Flutter 层挂断通话
          if (this.channel !== null) {
            CallUILog.i(TAG, 'invokeMethod onPipHangUp (user dismissed PiP)');
            this.channel.invokeMethod('onPipHangUp', {});
          }
        } else {
          // 从 ABOUT_TO_RESTORE 转换到 STOPPED，重置标志
          CallUILog.i(TAG, 'PiP STOPPED after restore, skip hangup');
          this.isRestoringFromPip = false;
        }
        break;
      case PiPWindow.PiPState.ABOUT_TO_RESTORE:
        curState = 'ABOUT_TO_RESTORE';
        // 用户点击了画中画窗口，恢复通话页面
        // 系统会自动关闭画中画，不需要手动调用 stopPiP()
        // 设置标志，用于在 STOPPED 状态时区分用户点击恢复和用户拖到垃圾桶关闭
        this.isRestoringFromPip = true;
        // 清理状态并通知 Flutter 层
        this.cleanupPipState();
        CallUILog.i(TAG, 'PiP ABOUT_TO_RESTORE, notifying Flutter to restore call page');
        if (this.channel !== null) {
          this.channel.invokeMethod('backCallingPageFromFloatWindow', {});
        }
        break;
      case PiPWindow.PiPState.ERROR:
        curState = 'ERROR';
        this.isPipActive = false;
        break;
      default:
        break;
    }
    CallUILog.i(TAG, `onStateChange: ${curState}, reason: ${reason}`);
  }

  /**
   * 处理画中画控制面板事件
   * 参考 demo 中的事件类型：'playbackStateChanged', 'nextVideo', 'previousVideo'
   */
  private onActionEvent(event: PiPWindow.PiPActionEventType, status?: number): void {
    CallUILog.i(TAG, `onActionEvent: event=${event}, status=${status}`);

    switch (event) {
      case 'playbackStateChanged':
        // 开始或停止视频
        if (status === 0) {
          // 停止视频 - 可以理解为静音
          if (this.channel !== null) {
            this.channel.invokeMethod('onPipToggleMute', { muted: true });
          }
        } else if (status === 1) {
          // 播放视频 - 可以理解为取消静音
          if (this.channel !== null) {
            this.channel.invokeMethod('onPipToggleMute', { muted: false });
          }
        }
        break;
      case 'nextVideo':
        // 播放下一个视频 - 在通话场景中可以用于挂断
        CallUILog.i(TAG, 'PiP nextVideo action - hangUp');
        if (this.channel !== null) {
          this.channel.invokeMethod('onPipHangUp', {});
        }
        break;
      case 'previousVideo':
        // 播放上一个视频 - 暂不处理
        break;
      default:
        break;
    }
  }

  /**
   * 清理画中画状态（不调用 stopPiP）
   * 用于系统自动关闭画中画时（如 ABOUT_TO_RESTORE）
   */
  private cleanupPipState(): void {
    CallUILog.i(TAG, 'cleanupPipState called');

    // 注销状态监听器
    this.unregisterStateListener();

    // 注销回调
    if (this.pipController !== undefined) {
      try {
        this.pipController.off('stateChange');
        this.pipController.off('controlPanelActionEvent');
      } catch (e) {
        // ignore
      }
      this.pipController = undefined;
    }

    this.isPipActive = false;

    // 保存当前的手动启动标志，用于判断是否需要重新创建控制器
    const wasManuallyStarted = this.isManuallyStarted;
    
    // 重置手动启动标志，以便下次退后台时可以自动启动画中画
    this.isManuallyStarted = false;
    CallUILog.i(TAG, 'isManuallyStarted reset to false in cleanupPipState');
    
    // 重置恢复标志，以便下次画中画关闭时可以正确判断
    // 注意：由于 stateChange 回调已被注销，STOPPED 状态不会触发，需要在这里重置
    this.isRestoringFromPip = false;
    CallUILog.i(TAG, 'isRestoringFromPip reset to false in cleanupPipState');

    // 清理 NodeController
    this.nodeController.dispose();

    // 通知 Flutter 层画中画已停止
    if (this.channel !== null) {
      this.channel.invokeMethod('onPipStopped', {});
    }

    // 只有在非手动启动的情况下才重新创建画中画控制器
    // 如果是手动启动（点击悬浮窗按钮），说明用户主动关闭了画中画，不应该重新创建
    if (!wasManuallyStarted) {
      CallUILog.i(TAG, 'cleanupPipState: recreating PiP controller for auto-start');
      this.recreatePipController();
    } else {
      CallUILog.i(TAG, 'cleanupPipState: skip recreating PiP controller (was manually started)');
    }
  }

  /**
   * 重新创建画中画控制器
   * 在画中画关闭后调用，以便下次退后台时可以自动启动
   */
  private async recreatePipController(): Promise<void> {
    if (this.pipConfig === undefined || this.context === null) {
      CallUILog.w(TAG, 'Cannot recreate PiP controller: config or context is null');
      return;
    }

    // 检查是否仍在通话中
    const state = CallState.getInstance();
    if (state.remoteUserList.length === 0) {
      CallUILog.i(TAG, 'Not in call, skip recreating PiP controller');
      return;
    }

    // 检查是否为视频通话
    if (state.mediaType !== MediaType.VIDEO) {
      CallUILog.i(TAG, 'Not video call, skip recreating PiP controller');
      return;
    }

    // 重新创建 NodeController，因为之前的已经被 dispose 了
    this.nodeController = new PipVideoNodeController();

    // 更新 pipConfig 使用新的 nodeController
    this.pipConfig.customUIController = this.nodeController;

    // 初始化 NodeController 的显示状态
    if (state.remoteUserList.length > 0) {
      const firstRemote = state.remoteUserList[0];
      const showAvatar = !(firstRemote.videoAvailable ?? false);
      const avatarUrl = firstRemote.avatar ?? '';
      this.nodeController.updateDisplay(showAvatar, avatarUrl);
      CallUILog.i(TAG, `recreatePipController: init NodeController showAvatar=${showAvatar}`);
    }

    try {
      CallUILog.i(TAG, 'Recreating PiP controller...');
      this.pipController = await PiPWindow.create(this.pipConfig);
      CallUILog.i(TAG, 'PiP controller recreated successfully');

      // 重新注册画中画状态回调
      this.initPipController();
      
      // 重置恢复标志，确保新的画中画控制器有正确的初始状态
      this.isRestoringFromPip = false;

      // 启用自动启动
      this.pipController.setAutoStartEnabled(true);
      CallUILog.i(TAG, 'PiP auto start re-enabled');
    } catch (err) {
      const error = err as BusinessError;
      CallUILog.e(TAG, `Failed to recreate PiP controller. Code: ${error.code}, Message: ${error.message}`);
    }
  }

  /**
   * 判断画中画是否正在运行
   */
  isPipRunning(): boolean {
    return this.isPipActive;
  }

  /**
   * 释放资源
   */
  release(): void {
    CallUILog.i(TAG, 'release called');
    this.unregisterStateListener();
    this.stopPip().catch(() => {});
    this.pipConfig = undefined;
    this.context = null;
    // 重置标志，以便下次通话时状态正确
    this.isManuallyStarted = false;
    this.isRestoringFromPip = false;
  }
}
