import { media } from '@kit.MediaKit';
import { audio } from '@kit.AudioKit';
import { avSession } from '@kit.AVSessionKit';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { CallUILog } from './CallUILog';

const TAG = 'RingPlayer';

// 默认铃声文件名
const DEFAULT_CALLER_RINGTONE = 'avchat_connecting.mp3';
const DEFAULT_CALLED_RINGTONE = 'avchat_ring.mp3';

export class RingPlayer {
  private player: media.AVPlayer | null = null;
  private playing: boolean = false;
  private context: common.Context | null = null;
  private session: avSession.AVSession | null = null;
  private isMutedBySystem: boolean = false;
  private volumeGroupManager: audio.AudioVolumeGroupManager | null = null;
  private ringerModeCallback: ((mode: audio.AudioRingMode) => void) | null = null;

  /**
   * 设置 Context，用于读取 rawfile 资源
   */
  setContext(context: common.Context): void {
    this.context = context;
  }

  /**
   * 初始化音量组管理器
   */
  private initVolumeGroupManager(): void {
    if (this.volumeGroupManager !== null) {
      return;
    }
    try {
      const audioManager: audio.AudioManager = audio.getAudioManager();
      const volumeManager: audio.AudioVolumeManager = audioManager.getVolumeManager();
      this.volumeGroupManager = volumeManager.getVolumeGroupManagerSync(audio.DEFAULT_VOLUME_GROUP_ID);
      CallUILog.i(TAG, 'VolumeGroupManager initialized');
    } catch (e) {
      CallUILog.e(TAG, `initVolumeGroupManager failed: ${(e as Error)?.message ?? e}`);
    }
  }

  /**
   * 注册铃声模式变化监听
   */
  private registerRingerModeListener(): void {
    if (this.volumeGroupManager === null || this.ringerModeCallback !== null) {
      return;
    }
    try {
      this.ringerModeCallback = (mode: audio.AudioRingMode): void => {
        CallUILog.i(TAG, `RingerModeChange: mode=${mode}`);
        if (mode === audio.AudioRingMode.RINGER_MODE_SILENT) {
          this.handleSystemMute(true);  // 静音模式
        } else if (mode === audio.AudioRingMode.RINGER_MODE_VIBRATE) {
          this.handleSystemMute(true);  // 振动模式也静音铃声
        } else {
          this.handleSystemMute(false); // 响铃模式
        }
      };
      this.volumeGroupManager.on('ringerModeChange', this.ringerModeCallback);
      CallUILog.i(TAG, 'Ringer mode listener registered');
    } catch (e) {
      CallUILog.e(TAG, `registerRingerModeListener failed: ${(e as Error)?.message ?? e}`);
    }
  }

  /**
   * 注销铃声模式变化监听
   */
  private unregisterRingerModeListener(): void {
    if (this.volumeGroupManager === null) {
      return;
    }
    try {
      if (this.ringerModeCallback !== null) {
        this.volumeGroupManager.off('ringerModeChange', this.ringerModeCallback);
        this.ringerModeCallback = null;
      }
      CallUILog.i(TAG, 'Ringer mode listener unregistered');
    } catch (e) {
      CallUILog.e(TAG, `unregisterRingerModeListener failed: ${(e as Error)?.message ?? e}`);
    }
  }

  /**
   * 处理系统静音事件
   */
  private handleSystemMute(isMuted: boolean): void {
    if (this.player === null) {
      return;
    }
    try {
      if (isMuted && !this.isMutedBySystem) {
        this.isMutedBySystem = true;
        this.player.setVolume(0);
        CallUILog.i(TAG, 'System muted - player volume set to 0');
      } else if (!isMuted && this.isMutedBySystem) {
        this.isMutedBySystem = false;
        this.player.setVolume(1);
        CallUILog.i(TAG, 'System unmuted - player volume restored to 1');
      }
    } catch (e) {
      CallUILog.e(TAG, `handleSystemMute failed: ${(e as Error)?.message ?? e}`);
    }
  }

  /**
   * 检查当前系统铃声模式是否为静音/振动
   */
  private checkInitialRingerMode(): boolean {
    if (this.volumeGroupManager === null) {
      return false;
    }
    try {
      const ringerMode: audio.AudioRingMode = this.volumeGroupManager.getRingerModeSync();
      CallUILog.i(TAG, `Current ringer mode: ${ringerMode}`);
      // 静音模式或振动模式都视为静音
      return ringerMode === audio.AudioRingMode.RINGER_MODE_SILENT || 
             ringerMode === audio.AudioRingMode.RINGER_MODE_VIBRATE;
    } catch (e) {
      CallUILog.e(TAG, `checkInitialRingerMode failed: ${(e as Error)?.message ?? e}`);
      return false;
    }
  }

  /**
   * 开始播放铃声（循环）
   * @param filePath Flutter 传入的文件路径
   * @param isCalled 是否为被叫方（用于选择 fallback 铃声）
   */
  async startRing(filePath: string, isCalled: boolean = false): Promise<void> {
    // 若已在播放，先停止
    if (this.playing) {
      await this.stopRing();
    }
    CallUILog.i(TAG, `qweqwe: ${filePath}, ${isCalled}`);
    try {
      // 检查文件是否存在
      let fileExists: boolean = false;
      if (filePath && filePath.length > 0) {
        try {
          fileExists = fileIo.accessSync(filePath);
        } catch (e) {
          fileExists = false;
        }
      }

      if (fileExists) {
        // 文件存在，使用 URL 方式播放
        CallUILog.i(TAG, `startRing with file: ${filePath}`);
        await this.playWithUrl(filePath);
      } else {
        // 文件不存在，使用 rawfile fallback
        CallUILog.i(TAG, `File not found: ${filePath}`);
      }
    } catch (e) {
      CallUILog.e(TAG, `startRing failed: ${(e as Error)?.message ?? e}`);
    }
  }

  /**
   * 创建并激活 AVSession，用于在后台保持音频播放
   */
  private async createSession(): Promise<void> {
    if (this.session !== null || this.context === null) {
      return;
    }
    try {
      // 创建 voice_call 类型的会话，这种类型在后台有更高优先级
      this.session = await avSession.createAVSession(this.context, 'CallKitRing', 'voice_call');
      // 激活会话
      await this.session.activate();
      CallUILog.i(TAG, 'AVSession created and activated');
    } catch (e) {
      CallUILog.e(TAG, `createSession failed: ${(e as Error)?.message ?? e}`);
      this.session = null;
    }
  }

  /**
   * 销毁 AVSession
   */
  private async destroySession(): Promise<void> {
    if (this.session === null) {
      return;
    }
    try {
      await this.session.deactivate();
      await this.session.destroy();
      CallUILog.i(TAG, 'AVSession destroyed');
    } catch (e) {
      CallUILog.e(TAG, `destroySession failed: ${(e as Error)?.message ?? e}`);
    } finally {
      this.session = null;
    }
  }

  /**
   * 使用文件路径方式播放铃声
   * OHOS AVPlayer 不支持直接使用文件路径，需要先打开文件获取 fd
   */
  private async playWithUrl(filePath: string): Promise<void> {
    // 初始化音量组管理器并注册铃声模式监听
    this.initVolumeGroupManager();
    this.registerRingerModeListener();
    
    // 检查初始铃声模式
    const isMuted: boolean = this.checkInitialRingerMode();
    if (isMuted) {
      this.isMutedBySystem = true;
      CallUILog.i(TAG, 'Initial state: system is in silent/vibrate mode');
    }
    
    // 创建并激活 AVSession，确保后台播放优先级
    await this.createSession();
    
    // 打开文件获取文件描述符
    const file: fileIo.File = fileIo.openSync(filePath, fileIo.OpenMode.READ_ONLY);
    const stat: fileIo.Stat = fileIo.statSync(file.fd);
    
    const avPlayer: media.AVPlayer = await media.createAVPlayer();
    this.player = avPlayer;
    
    // 设置音频渲染器信息，使用通知铃声类型，确保后台可以继续播放
    avPlayer.audioRendererInfo = {
      usage: audio.StreamUsage.STREAM_USAGE_NOTIFICATION_RINGTONE,
      rendererFlags: 0
    };
    
    // 设置音频中断模式为共享模式，避免被其他音频打断
    avPlayer.audioInterruptMode = audio.InterruptMode.SHARE_MODE;
    
    this.setupPlayerListeners(avPlayer, file.fd);
    
    // 使用文件描述符方式设置播放源
    avPlayer.fdSrc = {
      fd: file.fd,
      offset: 0,
      length: stat.size
    };
    
    this.playing = true;
    CallUILog.i(TAG, `playWithUrl (fd): ${filePath}, fd=${file.fd}, size=${stat.size}`);
  }

  /**
   * 设置播放器监听器
   * @param avPlayer 播放器实例
   * @param fd 文件描述符（可选，用于播放结束后关闭）
   */
  private setupPlayerListeners(avPlayer: media.AVPlayer, fd?: number): void {
    avPlayer.on('error', (err) => {
      CallUILog.e(TAG, `AVPlayer error: ${err?.message ?? err}`);
      // 关闭文件描述符
      if (fd !== undefined) {
        try { fileIo.closeSync(fd); } catch (e) { /* ignore */ }
      }
      this.player = null;
      this.playing = false;
    });

    avPlayer.on('stateChange', (state: string) => {
      CallUILog.i(TAG, `AVPlayer stateChange: ${state}`);
      if (state === 'initialized') {
        // 状态转换: idle -> initialized，需要调用 prepare
        avPlayer.prepare().catch((e: Error) => {
          CallUILog.e(TAG, `prepare failed: ${e?.message ?? e}`);
        });
      } else if (state === 'prepared') {
        avPlayer.loop = true;
        // 在 prepared 状态时应用初始静音状态
        if (this.isMutedBySystem) {
          avPlayer.setVolume(0);
          CallUILog.i(TAG, 'Applied initial mute state in prepared');
        }
        avPlayer.play().catch((e: Error) => {
          CallUILog.e(TAG, `play failed: ${e?.message ?? e}`);
        });
      } else if (state === 'completed') {
        // loop=true 时不会触发 completed，保留以防万一
        avPlayer.play().catch(() => {});
      } else if (state === 'released' || state === 'stopped') {
        // 播放结束后关闭文件描述符
        if (fd !== undefined) {
          try { fileIo.closeSync(fd); } catch (e) { /* ignore */ }
        }
      }
    });
  }

  /** 停止铃声并释放资源 */
  async stopRing(): Promise<void> {
    // 注销铃声模式监听
    this.unregisterRingerModeListener();
    this.isMutedBySystem = false;
    
    // 销毁 AVSession
    await this.destroySession();
    
    if (!this.player) {
      this.playing = false;
      return;
    }
    const p: media.AVPlayer = this.player;
    this.player = null;
    this.playing = false;
    try {
      await p.stop();
      await p.release();
      CallUILog.i(TAG, 'stopRing: released');
    } catch (e) {
      CallUILog.e(TAG, `stopRing error: ${(e as Error)?.message ?? e}`);
    }
  }
}