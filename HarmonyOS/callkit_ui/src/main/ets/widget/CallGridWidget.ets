// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { CallParticipantCell } from './CallParticipantCell';
import { CallState } from '../impl/CallState';
import { NECallType, NECallScene, NECallStatus } from '../CallDefine';
import { NEGroupCallConstants } from '@yunxin/callkit';
import { setStateEvent, Constants, AnimationConfig } from '../data/Constants';
import { NEEventNotify } from '../event/EventNotify';
import { CallUILog } from '../utils/CallUILog';
import { display } from '@kit.ArkUI';

/**
 * 参与者信息（用于Grid渲染）
 * 注意: isSpeaking 不在此类中，由 SpeakingIndicator 内部管理，实现局部更新
 */
class ParticipantInfo {
  accId: string = '';
  nickname: string = '';
  avatar: string = '';
  isLocal: boolean = false;
  isCameraOff: boolean = false;
  isMuted: boolean = false;
  isPending: boolean = false;

  constructor(accId: string, nickname: string, avatar: string, isLocal: boolean, isCameraOff: boolean, isMuted: boolean, isPending: boolean = false) {
    this.accId = accId;
    this.nickname = nickname;
    this.avatar = avatar;
    this.isLocal = isLocal;
    this.isCameraOff = isCameraOff;
    this.isMuted = isMuted;
    this.isPending = isPending;
  }
}

/**
 * Item 位置信息（用于动画布局）
 */
@Observed
class ItemPosition {
  x: number = 0;
  y: number = 0;
  width: number = 0;
  height: number = 0;

  constructor(x: number = 0, y: number = 0, width: number = 0, height: number = 0) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
  }
}


/**
 * 多宫格布局组件（支持放大模式动画）
 *
 * 参考 Android GroupCallGridLayout.kt 实现
 * 在同一个组件中支持宫格模式和放大模式，通过 animateTo 实现平滑过渡动画
 *
 * @since 2.0.0
 * @since 2.1.0 支持放大模式和过渡动画
 */
@Component
export struct CallGridWidget {
  private static readonly TAG = 'CallGridWidget';
  private static readonly DEFAULT_INDEX: number = -99;

  /** 单元格点击回调（用于进入放大模式）
   * @param accId 被点击成员的账号ID
   * @param cellIndex 单元格索引
   * @since 2.0.0
   */
  onCellClick?: (accId: string, cellIndex: number) => void;

  /** 退出放大模式回调
   * @since 2.1.0
   */
  onExitFocusMode?: () => void;

  /** 缩略图点击回调（放大模式下）
   * @param accId 被点击成员的账号ID
   * @since 2.1.0
   */
  onThumbnailClick?: (accId: string) => void;

  @State participants: ParticipantInfo[] = [];
  @State isAudioCall: boolean = false;

  /** 当前放大的 item 索引，-99 表示宫格模式 */
  @State focusedIndex: number = CallGridWidget.DEFAULT_INDEX;

  /** 是否正在执行动画 */
  @State isAnimating: boolean = false;

  /** 每个 item 的位置信息（用于动画） */
  @State itemPositions: ItemPosition[] = [];

  /** 容器宽度（用于计算布局） */
  @State containerWidth: number = 375;

  private stateEventCallback = () => {
    this.updateParticipants();
  }

  // 注意: speakingStateCallback 已移除，SpeakingIndicator 内部订阅事件实现局部更新

  aboutToAppear(): void {
    // 获取屏幕宽度
    try {
      const displayInfo = display.getDefaultDisplaySync();
      this.containerWidth = px2vp(displayInfo.width);
    } catch (e) {
      this.containerWidth = 375;
    }

    this.updateParticipants();
    NEEventNotify.getInstance().register(setStateEvent, this.stateEventCallback);
    // 注意: speakingStateChangedEvent 不再订阅，SpeakingIndicator 内部处理
  }

  aboutToDisappear(): void {
    NEEventNotify.getInstance().unregister(setStateEvent, this.stateEventCallback);
  }

  /**
   * 设置放大的 item 索引
   * @param index item 索引，-99 表示宫格模式
   * @param animated 是否使用动画
   */
  setFocusedIndex(index: number, animated: boolean = true): void {
    if (index < CallGridWidget.DEFAULT_INDEX || index >= this.participants.length) {
      return;
    }

    CallUILog.info(CallGridWidget.TAG, `setFocusedIndex: ${this.focusedIndex} -> ${index}, animated=${animated}`);

    if (animated) {
      this.isAnimating = true;
      // 先计算新布局的位置
      const newPositions = this.calculatePositions(index);

      // 使用 animateTo 执行动画
      this.getUIContext()?.animateTo({
        duration: AnimationConfig.DURATION,
        curve: AnimationConfig.CURVE,
        onFinish: () => {
          CallUILog.info(CallGridWidget.TAG, 'Animation finished');
          this.isAnimating = false;
        }
      }, () => {
        this.focusedIndex = index;
        this.itemPositions = newPositions;
      });
    } else {
      this.focusedIndex = index;
      this.itemPositions = this.calculatePositions(index);
    }
  }

  /**
   * 重置为宫格模式
   * @param animated 是否使用动画
   */
  resetFocusedIndex(animated: boolean = true): void {
    this.setFocusedIndex(CallGridWidget.DEFAULT_INDEX, animated);
  }

  /**
   * 计算所有 item 的位置
   * @param focusedIdx 放大的 item 索引
   */
  private calculatePositions(focusedIdx: number): ItemPosition[] {
    const count = this.participants.length;

    if (count === 0) {
      return [];
    }

    const baseSize = this.containerWidth / 3;

    // 如果是宫格模式（无放大），使用简单的宫格布局
    if (focusedIdx < 0 || focusedIdx >= count) {
      return this.calculateGridPositions(count, baseSize);
    }

    // 放大模式：focusedIdx 对应的 item 全屏，其他 item 作为缩略图
    return this.calculateFocusPositions(count, focusedIdx, baseSize);
  }

  /**
   * 计算宫格模式的布局位置
   */
  private calculateGridPositions(count: number, baseSize: number): ItemPosition[] {
    const positions: ItemPosition[] = [];
    const screenWidth = baseSize * 3;

    if (count === 1) {
      // 1人：全屏
      positions.push(this.fullWidth(0, 0, baseSize));
    } else if (count === 2) {
      // 2人：左右均分，正方形
      const cellSize = screenWidth / 2;
      positions.push(new ItemPosition(0, 0, cellSize, cellSize));
      positions.push(new ItemPosition(cellSize, 0, cellSize, cellSize));
    } else if (count === 3) {
      // 3人：上面两个50%，下面一个居中50%
      const cellSize = screenWidth / 2;
      positions.push(new ItemPosition(0, 0, cellSize, cellSize));
      positions.push(new ItemPosition(cellSize, 0, cellSize, cellSize));
      positions.push(new ItemPosition(cellSize / 2, cellSize, cellSize, cellSize));
    } else if (count === 4) {
      // 4人：2x2 宫格
      const cellSize = screenWidth / 2;
      positions.push(new ItemPosition(0, 0, cellSize, cellSize));
      positions.push(new ItemPosition(cellSize, 0, cellSize, cellSize));
      positions.push(new ItemPosition(0, cellSize, cellSize, cellSize));
      positions.push(new ItemPosition(cellSize, cellSize, cellSize, cellSize));
    } else if (count === 10) {
      // 10人：4列布局
      const cellSize = screenWidth / 4;
      for (let i = 0; i < count; i++) {
        const row = Math.floor(i / 4);
        const col = i % 4;
        positions.push(new ItemPosition(col * cellSize, row * cellSize, cellSize, cellSize));
      }
    } else {
      // 5-9人：3列布局
      const cellSize = screenWidth / 3;
      for (let i = 0; i < count; i++) {
        const row = Math.floor(i / 3);
        const col = i % 3;
        positions.push(new ItemPosition(col * cellSize, row * cellSize, cellSize, cellSize));
      }
    }

    return positions;
  }

  /**
   * 计算放大模式的布局位置
   * @param count 参与者总数
   * @param focusedIdx 被放大的 item 索引
   * @param baseSize 基础单元格大小（屏幕宽度/3）
   */
  private calculateFocusPositions(count: number, focusedIdx: number, baseSize: number): ItemPosition[] {
    const screenWidth = baseSize * 3;
    const thumbSize = screenWidth / 3;  // 小图尺寸 = 1/3 屏幕宽度

    // 5-10 人使用特殊布局
    if (count >= 5 && count <= 10) {
      return this.calculateMultiPersonFocusPositions(count, focusedIdx, screenWidth, thumbSize);
    }

    // 2-4 人：大图全屏 + 缩略图水平排列
    const positions: ItemPosition[] = new Array(count);
    positions[focusedIdx] = new ItemPosition(0, 0, screenWidth, screenWidth);

    const thumbnailY = screenWidth;
    let thumbnailX = 0;
    for (let i = 0; i < count; i++) {
      if (i !== focusedIdx) {
        positions[i] = new ItemPosition(thumbnailX, thumbnailY, thumbSize, thumbSize);
        thumbnailX += thumbSize;
      }
    }

    return positions;
  }

  /**
   * 5-10 人放大模式特殊布局
   * 按 Figma 规格：
   * - 5-9人: 3列布局，大图(2x2) + 右侧(2) + 底部按3列排列
   * - 10人: 4列布局，大图(3x3) + 右侧(3) + 底部按4列排列(4+2)
   */
  private calculateMultiPersonFocusPositions(count: number, focusedIdx: number, screenWidth: number, thumbSize: number): ItemPosition[] {
    const positions: ItemPosition[] = new Array(count);

    // 收集缩略图索引
    const thumbIndices: number[] = [];
    for (let i = 0; i < count; i++) {
      if (i !== focusedIdx) {
        thumbIndices.push(i);
      }
    }

    // 10人使用4列布局，其他使用3列布局
    const is10Person = count === 10;

    if (is10Person) {
      // 10人特殊布局：4列
      const thumbSize4 = screenWidth / 4;  // 4列时的小图尺寸
      const mainSize = thumbSize4 * 3;     // 大图占3x3格

      // 大图：3x3
      positions[focusedIdx] = new ItemPosition(0, 0, mainSize, mainSize);

      // 右侧3个小图
      for (let i = 0; i < 3 && i < thumbIndices.length; i++) {
        positions[thumbIndices[i]] = new ItemPosition(mainSize, i * thumbSize4, thumbSize4, thumbSize4);
      }

      // 底部6个小图：第一行4个，第二行2个
      const bottomStart = 3;
      for (let i = 0; i < 6 && (bottomStart + i) < thumbIndices.length; i++) {
        const row = Math.floor(i / 4);
        const col = i % 4;
        const x = col * thumbSize4;
        const y = mainSize + row * thumbSize4;
        positions[thumbIndices[bottomStart + i]] = new ItemPosition(x, y, thumbSize4, thumbSize4);
      }
    } else {
      // 5-9人布局：3列
      const mainHeight = thumbSize * 2;
      const mainWidth = thumbSize * 2;

      // 大图：2x2
      positions[focusedIdx] = new ItemPosition(0, 0, mainWidth, mainHeight);

      // 右侧2个小图
      for (let i = 0; i < 2 && i < thumbIndices.length; i++) {
        positions[thumbIndices[i]] = new ItemPosition(mainWidth, i * thumbSize, thumbSize, thumbSize);
      }

      // 剩余小图按3列排列（底部）
      const remainingStart = 2;
      const remainingCount = thumbIndices.length - 2;

      if (remainingCount > 0) {
        for (let i = 0; i < remainingCount; i++) {
          const row = Math.floor(i / 3);
          const col = i % 3;
          const x = col * thumbSize;
          const y = mainHeight + row * thumbSize;
          positions[thumbIndices[remainingStart + i]] = new ItemPosition(x, y, thumbSize, thumbSize);
        }
      }
    }

    return positions;
  }

  // ========== 布局计算辅助方法 ==========

  private fullWidth(x: number, y: number, baseSize: number): ItemPosition {
    const size = baseSize * 3;
    return new ItemPosition(x, y, size, size);
  }

  // 注意: updateSpeakingStates 已移除，SpeakingIndicator 内部订阅事件实现局部更新

  /**
   * 更新参与者列表
   */
  private updateParticipants(): void {
    const state = CallState.instance;
    this.isAudioCall = state.isGroupCall() ? false : (state.callType === NECallType.AUDIO);

    const newParticipants: ParticipantInfo[] = [];

    // 添加本地用户（isSpeaking 由 SpeakingIndicator 内部管理）
    newParticipants.push(new ParticipantInfo(
      state.selfUser.id,
      state.selfUser.nickname || '我',
      state.selfUser.avatar || Constants.defaultAvatar,
      true,
      !state.isCameraOpen,
      state.isMicrophoneMute,
      false
    ));

    // 添加远程用户，最多 9 人（自己占 1 个位置，总共最多 10 人）
    const maxRemoteUsers = NEGroupCallConstants.MAX_PARTICIPANTS - 1;
    const remoteUsers = state.remoteUserList.slice(0, maxRemoteUsers);
    for (const remoteUser of remoteUsers) {
      const isPending = remoteUser.callStatus === NECallStatus.WAITING;
      newParticipants.push(new ParticipantInfo(
        remoteUser.id,
        remoteUser.nickname || remoteUser.id,
        remoteUser.avatar || Constants.defaultAvatar,
        false,
        !remoteUser.videoAvailable,
        !remoteUser.audioAvailable,
        isPending
      ));
    }

    this.participants = newParticipants;

    // 更新位置信息
    this.itemPositions = this.calculatePositions(this.focusedIndex);

    CallUILog.info(CallGridWidget.TAG, `updateParticipants: count=${this.participants.length}`);
  }

  /**
   * 处理 item 点击
   */
  private handleItemClick(index: number): void {
    if (this.isAnimating) {
      CallUILog.info(CallGridWidget.TAG, 'handleItemClick ignored - animation in progress');
      return;
    }

    const participant = this.participants[index];

    if (this.focusedIndex === CallGridWidget.DEFAULT_INDEX) {
      // 宫格模式 -> 放大模式
      CallUILog.info(CallGridWidget.TAG, `Grid -> Focus: index=${index}, accId=${participant.accId}`);
      this.setFocusedIndex(index, true);
      this.onCellClick?.(participant.accId, index);
    } else if (this.focusedIndex === index) {
      // 点击放大的 item -> 返回宫格模式
      CallUILog.info(CallGridWidget.TAG, `Focus -> Grid: index=${index}`);
      this.resetFocusedIndex(true);
      this.onExitFocusMode?.();
    } else {
      // 放大模式下点击其他 item -> 切换焦点
      CallUILog.info(CallGridWidget.TAG, `Switch focus: ${this.focusedIndex} -> ${index}`);
      this.setFocusedIndex(index, true);
      this.onThumbnailClick?.(participant.accId);
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      ForEach(this.participants, (participant: ParticipantInfo, index: number) => {
        // 获取该 item 的位置
        if (index < this.itemPositions.length) {
          Column() {
            CallParticipantCell({
              accId: participant.accId,
              nickname: participant.nickname,
              avatar: participant.avatar,
              isLocal: participant.isLocal,
              isCameraOff: participant.isCameraOff,
              isMuted: participant.isMuted,
              isAudioCall: this.isAudioCall,
              cellIndex: index,
              isPending: participant.isPending,
              // 放大模式下，被放大的 item 显示昵称和摄像头反转按钮
              isFocused: this.focusedIndex === index,
              // 缩略图：放大模式下非焦点的 item（FR-034a: 缩略图不显示说话指示器）
              isThumbnail: this.focusedIndex !== CallGridWidget.DEFAULT_INDEX && this.focusedIndex !== index,
              onCellClick: (accId: string, cellIdx: number) => {
                this.handleItemClick(cellIdx);
              }
            })
          }
          .width(this.itemPositions[index].width)
          .height(this.itemPositions[index].height)
          .position({
            x: this.itemPositions[index].x,
            y: this.itemPositions[index].y
          })
          .id(`grid_cell_${index}_${participant.accId}`)
        }
      }, (participant: ParticipantInfo, index: number) => {
        // 注意: isSpeaking 不在 key 中，SpeakingIndicator 内部订阅事件实现局部更新
        // 注意: isFocused 不能放在 key 中！否则切换放大模式时组件会被重建，
        //       导致 NERtcVideoView 的 onDestroy 在新 onLoad 之后执行，取消视频渲染
        //       isFocused 通过 @Prop 传递，变化时会触发 build() 重新渲染底部信息栏
        return `${participant.accId}_${index}_${participant.isPending}_${participant.isCameraOff}_${participant.avatar}`;
      })
    }
    .width('100%')
    .height('100%')
  }
}
