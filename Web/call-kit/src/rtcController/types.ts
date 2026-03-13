import NERTC from 'nertc-web-sdk'
import { Stream } from 'nertc-web-sdk/types/stream'
import {
  JoinOptions,
  NeRtcServerAddresses,
  StreamOptions,
} from 'nertc-web-sdk/types/types'

export interface RTCChannelInfo {
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

export enum VIDEO_QUALITY {
  VIDEO_QUALITY_1080p = NERTC.VIDEO_QUALITY.VIDEO_QUALITY_1080p,
  VIDEO_QUALITY_720p = NERTC.VIDEO_QUALITY.VIDEO_QUALITY_720p,
  VIDEO_QUALITY_480p = NERTC.VIDEO_QUALITY.VIDEO_QUALITY_480p,
  VIDEO_QUALITY_180p = NERTC.VIDEO_QUALITY.VIDEO_QUALITY_180p,
}

export enum VIDEO_FRAME_RATE {
  CHAT_VIDEO_FRAME_RATE_NORMAL = NERTC.VIDEO_FRAME_RATE
    .CHAT_VIDEO_FRAME_RATE_NORMAL,
  CHAT_VIDEO_FRAME_RATE_5 = NERTC.VIDEO_FRAME_RATE.CHAT_VIDEO_FRAME_RATE_5,
  CHAT_VIDEO_FRAME_RATE_10 = NERTC.VIDEO_FRAME_RATE.CHAT_VIDEO_FRAME_RATE_10,
  CHAT_VIDEO_FRAME_RATE_15 = NERTC.VIDEO_FRAME_RATE.CHAT_VIDEO_FRAME_RATE_15,
  CHAT_VIDEO_FRAME_RATE_20 = NERTC.VIDEO_FRAME_RATE.CHAT_VIDEO_FRAME_RATE_20,
  CHAT_VIDEO_FRAME_RATE_25 = NERTC.VIDEO_FRAME_RATE.CHAT_VIDEO_FRAME_RATE_25,
}

export type AUDIO_QUALITY =
  | 'speech_low_quality'
  | 'speech_standard'
  | 'music_standard'
  | 'standard_stereo'
  | 'high_quality'
  | 'high_quality_stereo'

export type RTCConfig = {
  videoResolution?: VIDEO_QUALITY
  videoFrameRate?: VIDEO_FRAME_RATE
  audioQuality?: AUDIO_QUALITY
  neRtcServerAddresses?: NeRtcServerAddresses
  getToken?: (opt: JoinOptions) => Promise<string>
  streamOptions?: StreamOptions
}

export interface RTCControllerEvents {
  streamAdd: [stream: Stream]
  streamSubscribed: [stream: Stream]
  peerLeave: [uid: string | number]
  peerOnline: [uid: string | number]
  error: [errorName: string]
}
