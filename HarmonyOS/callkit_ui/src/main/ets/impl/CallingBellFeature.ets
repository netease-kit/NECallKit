// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import { media } from '@kit.MediaKit';
import { common } from '@kit.AbilityKit';
import { CallState } from './CallState';
import { NECallRole } from '../CallDefine';
import audio from '@ohos.multimedia.audio'
import { CallUILog } from '../utils/CallUILog';

/**
 * 呼叫铃声功能服务
 * 负责管理通话铃声的播放和停止
 */
export class CallingBellFeature {
  private static readonly _tag = 'CallingBellFeature';
  private static _instance: CallingBellFeature = new CallingBellFeature();

  // 默认铃声文件名
  private static readonly DEFAULT_CALLER_RINGTONE = 'avchat_connecting.mp3';
  private static readonly DEFAULT_CALLED_RINGTONE = 'avchat_ring.mp3';

  private _ringtonePlayer: media.AVPlayer | null = null;
  private _context: common.Context | null = null;
  // 自定义接听铃声（仅用于被叫）
  private _customIncomingRingtone: media.AVFileDescriptor | string | null = null;

  /**
   * 私有构造函数，单例模式
   */
  private constructor() {}

  /**
   * 获取单例实例
   * @returns CallingBellFeature 实例
   */
  static get instance(): CallingBellFeature {
    return CallingBellFeature._instance;
  }

  /**
   * 设置 Context
   * @param context 应用上下文
   */
  setContext(context: common.Context): void {
    CallUILog.info(CallingBellFeature._tag, `setContext`);
    this._context = context;
  }

  /**
   * 设置自定义接听铃声
   * @param source 铃声源（AVFileDescriptor 或 string 路径），仅用于被叫时播放
   */
  setCustomIncomingRingtone(source: media.AVFileDescriptor | string): void {
    CallUILog.info(CallingBellFeature._tag, `setCustomIncomingRingtone`);
    this._customIncomingRingtone = source;
  }

  /**
   * 清除自定义接听铃声
   */
  clearCustomIncomingRingtone(): void {
    CallUILog.info(CallingBellFeature._tag, `clearCustomIncomingRingtone`);
    this._customIncomingRingtone = null;
  }

  /**
   * 开始播放铃声
   * 根据呼叫角色自动选择铃声文件：
   * - 呼叫（CALLER）：使用 avchat_connecting.mp3
   * - 被叫（CALLED）：优先使用自定义铃声，如果没有则使用 avchat_ring.mp3
   */
  async startRing(): Promise<void> {
    CallUILog.info(CallingBellFeature._tag, `startRing`);
    
    const callRole = CallState.instance.selfUser.callRole;

    //设置扬声器播放
    audio.getAudioManager().getRoutingManager().setCommunicationDevice(audio.CommunicationDeviceType.SPEAKER, true)

    // 被叫时，优先使用自定义铃声
    if (callRole === NECallRole.CALLED && this._customIncomingRingtone !== null) {
      CallUILog.info(CallingBellFeature._tag, `被叫方，使用自定义铃声`);
      await this.playRingtone(this._customIncomingRingtone);
      return;
    }

    // 获取默认铃声并播放
    const defaultRingtone = await this.getDefaultRingtone(callRole);
    if (defaultRingtone) {
      await this.playRingtone(defaultRingtone);
    }
  }

  /**
   * 获取默认铃声文件描述符
   * @param callRole 呼叫角色
   * @returns 铃声文件描述符，如果获取失败则返回 null
   */
  private async getDefaultRingtone(callRole: NECallRole): Promise<media.AVFileDescriptor | null> {
    if (!this._context) {
      CallUILog.error(CallingBellFeature._tag, `context 为空，无法获取资源文件`);
      return null;
    }

    const resourceMgr = this._context.resourceManager;
    if (!resourceMgr) {
      CallUILog.error(CallingBellFeature._tag, `resourceManager 为空，无法获取资源文件`);
      return null;
    }

    // 根据呼叫角色选择默认铃声文件名
    const ringtoneFileName = callRole === NECallRole.CALLER
      ? CallingBellFeature.DEFAULT_CALLER_RINGTONE
      : CallingBellFeature.DEFAULT_CALLED_RINGTONE;

    try {
      const fileDescriptor = await resourceMgr.getRawFd(ringtoneFileName);
      const avFileDescriptor: media.AVFileDescriptor = {
        fd: fileDescriptor.fd,
        offset: fileDescriptor.offset,
        length: fileDescriptor.length
      };
      CallUILog.info(CallingBellFeature._tag, `获取默认铃声成功: ${ringtoneFileName}`);
      return avFileDescriptor;
    } catch (error) {
      CallUILog.error(CallingBellFeature._tag, `获取铃声文件失败: ${ringtoneFileName}: ${String(error)}`);
      return null;
    }
  }

  /**
   * 停止播放铃声
   */
  stopRing(): void {
    CallUILog.info(CallingBellFeature._tag, `stopRing`);
    this.stopRingtone();
  }

  /**
   * 播放铃声
   * @param source 铃声源（AVFileDescriptor 或 string 路径）
   */
  private async playRingtone(source: media.AVFileDescriptor | string): Promise<void> {
    const sourceType = typeof source === 'string' ? 'URL' : 'FileDescriptor';
    CallUILog.info(CallingBellFeature._tag, `开始播放铃声，类型: ${sourceType}`);
    
    try {
      // 如果已有播放器正在播放，先停止
      if (this._ringtonePlayer) {
        this.stopRingtone();
      }

      // 创建新的 AVPlayer 实例
      this._ringtonePlayer = await media.createAVPlayer();

      // 根据 source 类型设置播放源
      if (typeof source === 'string') {
        this._ringtonePlayer.url = source;
        CallUILog.info(CallingBellFeature._tag, `使用 URL 播放: ${source}`);
      } else {
        this._ringtonePlayer.fdSrc = source;
        CallUILog.info(CallingBellFeature._tag, `使用文件描述符播放`);
      }

      // 注册状态变化监听
      this._ringtonePlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
        await this.handlePlayerStateChange(state, reason);
      });

      CallUILog.info(CallingBellFeature._tag, `播放器初始化完成，当前状态: ${this._ringtonePlayer.state}`);

    } catch (error) {
      CallUILog.error(CallingBellFeature._tag, `播放铃声失败:: ${String(error)}`);
      this.releasePlayer();
    }
  }

  /**
   * 处理播放器状态变化
   * @param state 播放器状态
   * @param reason 状态变化原因
   */
  private async handlePlayerStateChange(state: string, reason: media.StateChangeReason): Promise<void> {
    const player = this._ringtonePlayer;
    if (!player) {
      return;
    }

    switch (state) {
      case 'idle':
        CallUILog.info(CallingBellFeature._tag, `播放器状态: idle`);
        break;
      case 'initialized':
        CallUILog.info(CallingBellFeature._tag, `播放器状态: initialized，准备播放器`);
        try {
          player.audioRendererInfo = {
            usage: audio.StreamUsage.STREAM_USAGE_RINGTONE,
            rendererFlags: 0
          }

          await player.prepare();
        } catch (error) {
          CallUILog.error(CallingBellFeature._tag, `prepare 失败:: ${String(error)}`);
          this.releasePlayer();
        }
        break;
      case 'prepared':
        CallUILog.info(CallingBellFeature._tag, `播放器状态: prepared，开始播放`);
        try {
          // 设置循环播放
          player.loop = true;
          await player.play();
          CallUILog.info(CallingBellFeature._tag, `播放成功`);
        } catch (error) {
          CallUILog.error(CallingBellFeature._tag, `play 失败:: ${String(error)}`);
          this.releasePlayer();
        }
        break;
      case 'playing':
        CallUILog.info(CallingBellFeature._tag, `播放器状态: playing`);
        break;
      case 'paused':
        CallUILog.info(CallingBellFeature._tag, `播放器状态: paused`);
        break;
      case 'completed':
        CallUILog.info(CallingBellFeature._tag, `播放器状态: completed`);
        break;
      case 'stopped':
        CallUILog.info(CallingBellFeature._tag, `播放器状态: stopped`);
        break;
      case 'released':
        CallUILog.info(CallingBellFeature._tag, `播放器状态: released`);
        break;
      case 'error':
        CallUILog.error(CallingBellFeature._tag, `播放器状态: error, 原因: ${reason}`);
        this.releasePlayer();
        break;
      default:
        CallUILog.warn(CallingBellFeature._tag, `未知播放器状态: ${state}`);
        break;
    }
  }

  /**
   * 释放播放器资源
   */
  private releasePlayer(): void {
    if (this._ringtonePlayer) {
      try {
        this._ringtonePlayer.release();
      } catch (error) {
        CallUILog.error(CallingBellFeature._tag, `释放播放器失败:: ${String(error)}`);
      } finally {
        this._ringtonePlayer = null;
      }
    }
  }

  /**
   * 停止铃声
   */
  private stopRingtone(): void {
    if (!this._ringtonePlayer) {
      return;
    }

    try {
      this._ringtonePlayer.stop();
      CallUILog.info(CallingBellFeature._tag, `铃声已停止`);
    } catch (error) {
      CallUILog.error(CallingBellFeature._tag, `停止铃声失败:: ${String(error)}`);
    } finally {
      this.releasePlayer();
    }
  }
}

