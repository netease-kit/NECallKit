import NERTC from 'nertc-web-sdk'
import { Stream } from 'nertc-web-sdk/types/stream'
import { Client } from 'nertc-web-sdk/types/client'
import { JoinOptions, StreamOptions } from 'nertc-web-sdk/types/types'
import EventEmitter from 'eventemitter3'
import { debounce } from '@xkit-yx/utils'
import { logger, createLoggerDecorator } from '../logger'
import { LOCAL_VIEW_NULL, LOCAL_STREAM_NULL, REMOTE_VIEW_NULL } from './error'
import {
  RTCControllerEvents,
  VIDEO_QUALITY,
  VIDEO_FRAME_RATE,
  RTCConfig,
  RTCChannelInfo,
} from './types'

const TAG_NAME = 'RTCController'

const loggerDecorator = createLoggerDecorator(TAG_NAME, logger)

class RTCController extends EventEmitter<RTCControllerEvents> {
  public client: Client
  public localStream?: Stream
  public remoteStreams: Stream[] = []

  private _localView?: HTMLElement
  private _remoteViews: {
    view: HTMLElement
    uid: string | number
  }[] = []
  private _rtcConfig: RTCConfig = {
    videoResolution: VIDEO_QUALITY.VIDEO_QUALITY_720p,
    videoFrameRate: VIDEO_FRAME_RATE.CHAT_VIDEO_FRAME_RATE_NORMAL,
    audioQuality: 'speech_low_quality',
  }
  private _rtcSDK: typeof NERTC
  private _inTheRoom = false

  constructor({
    appkey,
    rtcConfig,
    debug = false,
  }: {
    appkey: string
    rtcConfig?: RTCConfig
    debug?: boolean
  }) {
    super()
    this._rtcSDK = NERTC
    this.client = this._rtcSDK.createClient({ appkey, debug })

    if (rtcConfig) {
      this._rtcConfig = rtcConfig
    }

    this._addRtcEventListener()
  }

  public getChannelInfo(): RTCChannelInfo {
    return this.client.getChannelInfo()
  }

  @loggerDecorator
  public async initLocalStream(options: StreamOptions): Promise<void> {
    if (this.localStream) {
      return
    }

    this.localStream = this._rtcSDK.createStream({
      ...this._rtcConfig.streamOptions,
      uid: options.uid,
      audio: options.audio,
      video: options.video,
      screen: options.screen,
    }) as Stream
    logger.log(
      TAG_NAME,
      'localStream create success',
      this.localStream,
      options.audio,
      options.video
    )
    // 设置本地视频质量
    this.localStream.setVideoProfile({
      resolution:
        this._rtcConfig.videoResolution || VIDEO_QUALITY.VIDEO_QUALITY_720p,
      frameRate:
        this._rtcConfig.videoFrameRate ||
        VIDEO_FRAME_RATE.CHAT_VIDEO_FRAME_RATE_NORMAL, //设置视频帧率
    })
    // 设置本地音频质量
    this.localStream.setAudioProfile(
      this._rtcConfig.audioQuality || 'speech_low_quality'
    )
    await this.localStream.init()
  }

  @loggerDecorator
  public async leaveRTCChannel(): Promise<void> {
    try {
      this._inTheRoom && (await this.client.leave())
      this._inTheRoom = false
      this.resetState()
    } catch (error) {
      logger.error(TAG_NAME, 'leaveRTCChannel fail: ', error)
      throw error
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
      const neRtcServerAddresses =
        options.neRtcServerAddresses ?? this._rtcConfig.neRtcServerAddresses

      logger.log(
        TAG_NAME,
        'joinRTCChannel:',
        options,
        token,
        neRtcServerAddresses
      )
      const res = await this.client.join({
        ...options,
        neRtcServerAddresses,
        token,
      })

      this._inTheRoom = true
      logger.log(TAG_NAME, 'joinRTCChannel success: ', res)
    } catch (error) {
      logger.error(TAG_NAME, 'joinRTCChannel fail: ', error)
      throw error
    }
  }

  @loggerDecorator
  public async publishLocalStream(): Promise<void> {
    if (!this.localStream) {
      throw LOCAL_STREAM_NULL
    }

    try {
      await this.client.publish(this.localStream)
      logger.log(TAG_NAME, 'publishLocalStream success')
    } catch (error) {
      logger.error(TAG_NAME, 'publishLocalStream fail: ', error)
      throw error
    }
  }

  @loggerDecorator
  public async enableLocalVideo(
    enabled: boolean,
    deviceId?: string
  ): Promise<void> {
    try {
      if (!this.localStream) {
        throw LOCAL_STREAM_NULL
      }

      if (!this._localView) {
        throw LOCAL_VIEW_NULL
      }

      await this.localStream[enabled ? 'open' : 'close']({
        type: 'video',
        deviceId,
      })
      if (enabled) {
        await this._startStreamPreview(
          this.localStream,
          'local',
          this._localView
        )
      }

      logger.log(TAG_NAME, '_enableLocalVideo success:', enabled, deviceId)
    } catch (error) {
      logger.error(
        TAG_NAME,
        '_enableLocalVideo fail:',
        enabled,
        deviceId,
        error
      )
      throw error
    }
  }

  @loggerDecorator
  public async enableLocalAudio(
    enabled: boolean,
    deviceId?: string
  ): Promise<void> {
    try {
      if (!this.localStream) {
        throw LOCAL_STREAM_NULL
      }

      if (!this._localView) {
        throw LOCAL_VIEW_NULL
      }

      await this.localStream[enabled ? 'open' : 'close']({
        type: 'audio',
        deviceId,
      })
      if (enabled) {
        await this._startStreamPreview(
          this.localStream,
          'local',
          this._localView
        )
      }

      logger.log(TAG_NAME, '_enableLocalVideo success:', enabled, deviceId)
    } catch (error) {
      logger.error(
        TAG_NAME,
        '_enableLocalVideo fail:',
        enabled,
        deviceId,
        error
      )
      throw error
    }
  }

  @loggerDecorator
  public async muteLocalVideo(mute: boolean): Promise<void> {
    try {
      if (!this.localStream) {
        throw LOCAL_STREAM_NULL
      }

      await this.localStream[mute ? 'muteVideo' : 'unmuteVideo']()
      logger.log(TAG_NAME, 'muteLocalVideo success: ', mute)
    } catch (error) {
      logger.error(TAG_NAME, 'muteLocalVideo fail: ', mute)
      throw error
    }
  }

  @loggerDecorator
  public async muteLocalAudio(mute: boolean): Promise<void> {
    try {
      if (!this.localStream) {
        throw LOCAL_STREAM_NULL
      }

      await this.localStream[mute ? 'muteAudio' : 'unmuteAudio']()
      logger.log(TAG_NAME, 'muteLocalAudio success: ', mute)
    } catch (error) {
      logger.error(TAG_NAME, 'muteLocalAudio fail: ', mute)
      throw error
    }
  }

  @loggerDecorator
  public async playLocalStream(view?: HTMLElement): Promise<void> {
    if (!this.localStream) {
      throw LOCAL_STREAM_NULL
    }

    if (!this._localView) {
      throw LOCAL_VIEW_NULL
    }

    await this._startStreamPreview(
      this.localStream,
      'local',
      view || this._localView
    )
  }

  public setLocalView(view: HTMLElement): void {
    this._localView = view
  }

  public setRemoteView(view: HTMLElement, uid: string | number): void {
    const remoteView = this._remoteViews.find((item) => item.uid === uid)

    if (remoteView) {
      remoteView.view = view
    } else {
      this._remoteViews.push({
        view,
        uid,
      })
    }
  }

  @loggerDecorator
  public async playRemoteStream(stream: Stream): Promise<void> {
    const dom = this._remoteViews.find((item) => item.uid === stream.getId())

    if (!dom) {
      throw REMOTE_VIEW_NULL
    }

    try {
      await this._startStreamPreview(stream, 'remote', dom.view)
    } catch (error) {
      logger.error(TAG_NAME, '_playRemoteStream fail: ', error)
      throw error
    }
  }

  public resetState(): void {
    this.localStream?.destroy()
    this._localView = undefined
    this.localStream = undefined
    this._remoteViews = []
    this.remoteStreams = []
  }

  public destroy(): void {
    this.leaveRTCChannel()
  }
  /**
   * 播放流
   * @param stream
   * @param type
   * @param view
   */
  private async _startStreamPreview(
    stream: Stream,
    type: 'local' | 'remote',
    view: HTMLElement
  ): Promise<void> {
    try {
      stream.stop()
      await stream.play(view)
      const params = {
        // 设置视频窗口大小
        width: view.clientWidth,
        height: view.clientHeight,
        cut: true, // 是否裁剪
      }

      stream[type === 'local' ? 'setLocalRenderMode' : 'setRemoteRenderMode'](
        params
      )
      logger.log(
        TAG_NAME,
        type === 'local'
          ? 'setLocalRenderMode'
          : 'setRemoteRenderMode' + ' success',
        { params, type }
      )
    } catch (error) {
      logger.error(TAG_NAME, 'startStreamPreview fail: ', error)
      throw error
    }
  }
  /**
   * 新增流，如果以存在，则更新流
   * @param stream
   */
  private _addStream(stream: Stream): void {
    stream.setSubscribeConfig({
      audio: true,
      video: true,
    })
    // 发起订阅
    this.client.subscribe(stream)
    const uid = stream.getId()

    if (this.remoteStreams.some((item) => item.getId() === uid)) {
      logger.log(TAG_NAME, 'stream-added：订阅的流已存在，更新流')
      this._updateStream(stream)
    } else {
      logger.log(TAG_NAME, 'stream-added：新增需要订阅的流')
      this.remoteStreams.push(stream)
    }
  }
  /**
   * 更新流
   * @param stream
   */
  private _updateStream(stream: Stream): void {
    const uid = stream.getId()

    this.remoteStreams = this.remoteStreams.map((item) =>
      item.getId() === uid ? stream : item
    )
  }

  private async _addRtcEventListener() {
    // rtc 会触发多次，所以需要防抖
    const handlePeerOnline = debounce((evt) => {
      logger.log(TAG_NAME, 'peer-online: ', evt)
      this.emit('peerOnline', evt.uid)
    }, 100)

    this.client.on('peer-online', handlePeerOnline)

    this.client.on('peer-leave', (evt) => {
      logger.log(TAG_NAME, 'peer-leave: ', evt)
      this.emit('peerLeave', evt.uid)
    })
    this.client.on('stream-added', (evt) => {
      logger.log(TAG_NAME, 'stream-added: ', evt)
      this._addStream(evt.stream)
      this.emit('streamAdd', evt.stream)
    })
    this.client.on('stream-removed', (evt) => {
      logger.log(TAG_NAME, 'stream-removed: ', evt)
      const stream = evt.stream

      stream.stop(evt.mediaType)
      this._updateStream(stream)
    })
    this.client.on('stream-subscribed', (evt) => {
      logger.log(TAG_NAME, 'stream-subscribed: ', evt)
      this.emit('streamSubscribed', evt.stream)
    })
    this.client.on('mute-video', (evt) => {
      logger.log(TAG_NAME, 'mute-video: ', evt)
      const uid = evt.uid
      const stream = this.remoteStreams.find((item) => item.getId() === uid)

      stream?.stop('video')
    })
    this.client.on('unmute-video', (evt) => {
      logger.log(TAG_NAME, 'unmute-video: ', evt)
      const uid = evt.uid
      const view = this._remoteViews.find((item) => item.uid === uid)?.view
      const stream = this.remoteStreams.find((item) => item.getId() === uid)

      if (view && stream) {
        this._startStreamPreview(stream, 'remote', view)
      }
    })
    this.client.on('mute-audio', (evt) => {
      logger.log(TAG_NAME, 'mute-audio: ', evt)
    })
    this.client.on('unmute-audio', (evt) => {
      logger.log(TAG_NAME, 'unmute-audio: ', evt)
    })
    this.client.on('error', (evt) => {
      logger.log(TAG_NAME, 'error: ', evt)
      this.emit('error', evt)
    })
  }
}

export default RTCController
