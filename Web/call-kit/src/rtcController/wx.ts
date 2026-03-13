import NERTC from '../sdk/NERTC_Miniapp_SDK_v4.6.10'
import EventEmitter from 'eventemitter3'
import { logger, createLoggerDecorator } from '../logger'

interface RTCChannelInfo {
  /**
   * 频道ID，可用于服务端API调用。
   */
  cid: number
  /**
   * 用户输入的频道名。
   */
  channelName: string
  /**
   * 用户输入的id。当用户输入的uid为0时，则可获取服务端随机分配的uid。
   */
  uid: number | string
  /**
   * 用户输入的token。
   */
  token: string
}

interface WXStream {
  url: string
  uid: string | number
}

interface VideoMuteOrUnmuteEvent {
  mute: boolean
  uid: string | number
}

interface RTCControllerEvents {
  streamSubscribed: [stream: WXStream]
  clientLeave: [uid: string | number]
  clientJoin: [uid: string | number]
  videoMuteOrUnmute: [event: VideoMuteOrUnmuteEvent]
  error: [errorName: string]
}

type JoinOptions = {
  channelName: string
  token?: string
  uid?: number | string
  rtmpRecord?: number // 是否开启互动直播录制，0不需要，1需要（默认0）
  recordAudio?: number // 是否开启音频实时音录制，0不需要，1需要（默认0）
  recordVideo?: number // 是否开启视频实时视频录制，0不需要，1需要（默认0）
  recordType?: string // 录制模式，0混单（产生混合录制文件+单独录制文件） 1只混（只产生混合录制文件） 2只单（只产生单独录制文件）
  liveEnable?: number // 是否旁路直播,0:不需要,1:需要
}

export type RTCConfig = {
  getToken?: (opt: JoinOptions) => Promise<string>
  joinOptions?: JoinOptions
}

const TAG_NAME = 'RTCController'

const loggerDecorator = createLoggerDecorator(TAG_NAME, logger)

class RTCController extends EventEmitter<RTCControllerEvents> {
  public client: any

  public localStreamUrl?: string // 本地流地址
  public remoteStreams: WXStream[] = [] // 远端流地址

  private _rtcConfig: RTCConfig = {}
  private _rtcSDK: typeof NERTC
  private _inTheRoom = false

  constructor({
    appkey,
    rtcConfig,
    debug = false,
  }: {
    appkey: string
    debug?: boolean
    rtcConfig?: RTCConfig
  }) {
    super()
    this._rtcSDK = NERTC
    this.client = this._rtcSDK.Client({ appkey, debug })

    if (rtcConfig) {
      this._rtcConfig = rtcConfig
    }

    this._addRtcEventListener()
  }

  public getChannelInfo(): RTCChannelInfo {
    return {
      cid: this.client._info.cid,
      channelName: this.client._info.joinChannelParam?.channelName,
      uid: this.client._info.joinChannelParam?.uid,
      token: this.client._info.joinChannelParam?.token,
    }
  }

  @loggerDecorator
  public async joinRTCChannel(options: JoinOptions): Promise<void> {
    try {
      if (this._inTheRoom) {
        logger.warn(TAG_NAME, 'joinRTCChannel in the room')
        return
      }

      const token = options.token ?? (await this._rtcConfig.getToken?.(options))
      const res = await this.client.join({
        ...options,
        token,
        ...this._rtcConfig.joinOptions,
      })

      this._inTheRoom = true
      logger.log(TAG_NAME, 'joinRTCChannel success: ', res)
    } catch (error) {
      logger.error(TAG_NAME, 'joinRTCChannel fail: ', error)
      throw error
    }
  }

  @loggerDecorator
  public async publishLocalStream(
    mediaType?: 'video' | 'audio'
  ): Promise<string | undefined> {
    try {
      if (!this._inTheRoom) {
        logger.warn(TAG_NAME, 'not in the room')
        return
      }

      return await this.client.publish(mediaType)
    } catch (error) {
      logger.error('joinRTCChannel fail: ', error)
      throw error
    }
  }

  @loggerDecorator
  public async muteLocalVideo(mute: boolean): Promise<void> {
    if (mute) {
      await this.client.mute('video')
    } else {
      await this.client.unmute('video')
    }
  }

  @loggerDecorator
  public async muteLocalAudio(mute: boolean): Promise<void> {
    if (mute) {
      await this.client.mute('audio')
    } else {
      await this.client.unmute('audio')
    }
  }

  @loggerDecorator
  public async leaveRTCChannel(): Promise<void> {
    try {
      this._inTheRoom && (await this.client.leave())
      this._inTheRoom = false
      this.resetState()
    } catch (error) {
      logger.error('leaveRTCChannel fail: ', error)
      throw error
    }
  }

  public resetState(): void {
    this.localStreamUrl = undefined
    this.remoteStreams = []
  }

  public destroy(): void {
    this.leaveRTCChannel()
    this.resetState()
  }

  /**
   * 新增流，如果以存在，则更新流
   * @param stream
   */
  private async _addStream(stream: {
    uid: number | string
    mediaType: string
  }): Promise<void> {
    // 发起订阅
    const { uid, mediaType } = stream
    const { url } = await this.client.subscribe(uid, mediaType)
    const remoteStream = this.remoteStreams.find((item) => item.uid === uid)

    if (remoteStream) {
      logger.log('stream-added：订阅的流已存在，更新流')
      remoteStream.url = url
    } else {
      logger.log('stream-added：新增需要订阅的流')
      this.remoteStreams.push({ uid, url: url })
    }

    this.emit('streamSubscribed', { uid, url })
  }

  private async _addRtcEventListener() {
    this.client.on('clientJoin', (evt) => {
      logger.log('clientJoin: ', evt)
      this.emit('clientJoin', evt.uid)
    })
    this.client.on('clientLeave', (evt) => {
      logger.log('clientLeave: ', evt)
      this.emit('clientLeave', evt.uid)
    })
    this.client.on('stream-added', async (evt) => {
      logger.log('stream-added: ', evt)
      this._addStream(evt)
    })
    this.client.on('stream-removed', (evt) => {
      logger.log('stream-removed: ', evt)
    })
    this.client.on('mute-video', (evt) => {
      logger.log('mute-video: ', evt)
      this.emit('videoMuteOrUnmute', { mute: true, uid: evt.uid })
    })
    this.client.on('unmute-video', (evt) => {
      logger.log('unmute-video: ', evt)
      this.emit('videoMuteOrUnmute', { mute: false, uid: evt.uid })
    })
    this.client.on('mute-audio', (evt) => {
      logger.log('mute-audio: ', evt)
    })
    this.client.on('unmute-audio', (evt) => {
      logger.log('unmute-audio: ', evt)
    })
    this.client.on('error', (evt) => {
      logger.log('error: ', evt)
      this.emit('error', evt)
    })
    this.client.on('disconnect', (evt) => {
      logger.log('disconnect: ', evt)
    })
  }
}

export default RTCController
