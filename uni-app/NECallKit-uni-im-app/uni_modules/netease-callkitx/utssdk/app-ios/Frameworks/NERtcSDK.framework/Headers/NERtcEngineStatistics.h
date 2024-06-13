/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "NERtcEngineEnum.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"


NS_ASSUME_NONNULL_BEGIN

 /**
  * @if English 
  * Collects stats related to calls.
  * @endif
  * @if Chinese
  * 通话相关的统计信息
  * @endif
  */
NERTC_EXPORT  @interface NERtcStats : NSObject


 /**
  * @if English
  * The number of cumulative bytes sent (bytes).
  * @endif
  * @if Chinese
  * 发送字节数（bytes），累计值
  * @endif
  */
@property (nonatomic, assign) int64_t txBytes;

 /**
  * @if English 
  * The number of cumulative bytes received (bytes).
  * @endif
  * @if Chinese
  * 接收字节数（bytes），累计值
  * @endif
  */
@property (nonatomic, assign) int64_t rxBytes;

 /**
  * @if English 
  * The CPU usage of the current app (%).
  * @endif
  * @if Chinese
  * 当前 App 的 CPU 使用率 (%)
  * @endif
  */
@property (nonatomic, assign) uint32_t cpuAppUsage;

 /**
  * @if English 
  * The CPU usage of the current system (%).
  * @endif
  * @if Chinese
  * 当前系统的 CPU 使用率 (%)
  * @endif
  */
@property (nonatomic, assign) uint32_t cpuTotalUsage;

 /**
  * @if English 
  * The ratio of current memory usage by the app (%) with respect to the maximum available memory.
  * @endif
  * @if Chinese
  * 当前 App 的内存占比 (%) , 占最大可用内存
  * @endif
  */
@property (nonatomic, assign) uint32_t memoryAppUsageRatio;
 
 /**
  * @if English 
  * Percentage of the memory used by the current system (%).
  * @endif
  * @if Chinese
  * 当前系统的内存占比 (%)
  * @endif
  */
@property (nonatomic, assign) uint32_t memoryTotalUsageRatio;
 
 /**
  * @if English 
  * The memory size used by the current app (KB).
  * @endif
  * @if Chinese
  * 当前 App 的内存大小 (KB)
  * @endif
  */
@property (nonatomic, assign) uint32_t memoryAppUsageInKBytes;
 
 /**
  * @if English 
  * The duration of the call that starts from joining the room. If you leave and rejoin the room, the duration restarts. Unit: seconds.
  * @endif
  * @if Chinese
  * 自加入房间的通话时长 ， 退出后再加入重新计时 ( 单位：S)
* @endif
*/
@property (nonatomic, assign) uint64_t totalDuration;
 
 /**
  * @if English 
  * The number of cumulative bytes of audio data sent since a user joins the room (bytes).
  * @endif
  * @if Chinese
  * 自加入房间后累计的发送的音频字节数（Byte）
  * @endif
  */
@property (nonatomic, assign) uint64_t txAudioBytes;
 
 /**
  * @if English 
  * The number of cumulative bytes of video data sent since a user joins the room (bytes).
  * @endif
  * @if Chinese
  * 自加入房间后累计的发送的视频字节数（Byte）
  * @endif
  */
@property (nonatomic, assign) uint64_t txVideoBytes;
 
 
 /**
  * @if English 
  * The number of cumulative bytes of audio data received since a user joins the room (bytes).
  * @endif
  * @if Chinese
  * 自加入房间后累计的接收的音频字节数（Byte）
  * @endif
  */
@property (nonatomic, assign) uint64_t rxAudioBytes;
 
 
 /**
  * @if English 
  * The number of cumulative bytes of video data received since a user joins the room (bytes).
  * @endif
  * @if Chinese
  * 自加入房间后累计的接收的视频字节数（Byte）
  * @endif
  */
@property (nonatomic, assign) uint64_t rxVideoBytes;
 
 /**
  * @if English 
  * The bitrate of the audio stream received (kbps).
  * @endif
  * @if Chinese
  * 音频接收码率（kbps）
  * @endif
  */
@property (nonatomic, assign) uint64_t rxAudioKBitRate;
 
 /**
  * @if English 
  * The bitrate of the video stream received (kbps).
  * @endif
  * @if Chinese
  * 视频接收码率（kbps）
  * @endif
  */
@property (nonatomic, assign) uint64_t rxVideoKBitRate;
 
 /**
  * @if English 
  * The bitrate of the audio stream sent (kbps).
  * @endif
  * @if Chinese
  * 音频发送码率（kbps）
  * @endif
  */
@property (nonatomic, assign) uint64_t txAudioKBitRate;
 
 /**
  * @if English 
  * The bitrate of the video stream sent (kbps).
  * @endif
  * @if Chinese
  * 视频发送码率（kbps）
  * @endif
  */
@property (nonatomic, assign) uint64_t txVideoKBitRate;
 
 /**
  * @if English 
  * Average uplink round-trip latency (ms).
  * @endif
  * @if Chinese
  * 上行平均往返时延(ms)
  * @endif
  */
@property (nonatomic, assign) uint64_t upRtt;
 
 /**
  * @if English 
  * Average downlink round-trip latency (ms).
  * @endif
  * @if Chinese
  * 下行平均往返时延(ms)
 * @endif
 */
@property (nonatomic, assign) uint64_t downRtt;

 /**
  * @if English 
  * Packet loss rate of the local uplink audio stream (%).
  * @endif
  * @if Chinese
  * 本地上行音频丢包率(%)
  * @endif
  */
@property (nonatomic, assign) uint32_t txAudioPacketLossRate;
 
 /**
  * @if English 
  * Actual packet loss rate of the local uplink video stream (%).
  * @endif
  * @if Chinese
  * 本地上行视频实际丢包率(%)
  * @endif
  */
@property (nonatomic, assign) uint32_t txVideoPacketLossRate;
 
 /**
  * @if English 
  * The number of packets not received in the local uplink audio stream.
  * @endif
  * @if Chinese
  * 本地上行音频丢包数
  * @endif
  */
@property (nonatomic, assign) uint32_t txAudioPacketLossSum;
 
 /**
  * @if English 
  * The number of packets not received in the local uplink video stream.
  * @endif
  * @if Chinese
  * 本地上行视频丢包数
  * @endif
  */
@property (nonatomic, assign) uint32_t txVideoPacketLossSum;
 
 /**
  * @if English 
  * Local uplink audio jitter (ms)
  * @endif
  * @if Chinese
  * 本地上行音频抖动 (ms)
  * @endif
  */
@property (nonatomic, assign) uint32_t txAudioJitter;
 
 /**
  * @if English 
  * Local uplink video jitter (ms)
  * @endif
  * @if Chinese
  * 本地上行视频抖动 (ms)
  * @endif
  */
@property (nonatomic, assign) uint32_t txVideoJitter;
 
 /**
  * @if English 
  * Packet loss rate of the local downlink audio (%).
  * @endif
  * @if Chinese
  * 本地下行音频丢包率(%)
  * @endif
  */
@property (nonatomic, assign) uint32_t rxAudioPacketLossRate;
 
 /**
  * @if English 
  * Packet loss rate of the local downlink video stream (%).
  * @endif
  * @if Chinese
  * 本地下行视频丢包率(%)
  * @endif
  */
@property (nonatomic, assign) uint32_t rxVideoPacketLossRate;
 
 /**
  * @if English 
  * The number of packets not received in the local downlink audio stream.
  * @endif
  * @if Chinese
  * 本地下行音频丢包数
  * @endif
  */
@property (nonatomic, assign) uint64_t rxAudioPacketLossSum;
 
 /**
  * @if English 
  * The number of packets not received in the local downlink video stream.
  * @endif
  * @if Chinese
  * 本地下行视频丢包数
  * @endif
  */
@property (nonatomic, assign) uint32_t rxVideoPacketLossSum;
 
 /**
  * @if English 
  * Local downlink audio jitter (ms).
  * @endif
  * @if Chinese
  * 本地下行音频抖动 (ms)
  * @endif
  */
 
@property (nonatomic, assign) uint32_t rxAudioJitter;
 
 /**
  * @if English 
  * Local downlink video jitter (ms).
  * @endif
  * @if Chinese
  * 本地下行视频抖动 (ms)
  * @endif
  */
@property (nonatomic, assign) uint32_t rxVideoJitter;
@end

 /**
  * @if English 
  * Stats of an individual local video stream.
  * @endif
  * @if Chinese
  *本地视频单条流统计信息
  * @endif
  */
NERTC_EXPORT  @interface NERtcVideoLayerSendStats : NSObject

 /**
  * @if English 
  * The stream type. mainstream: 1. Substream: 2.
  * @endif
  * @if Chinese
  * 流类型： 主流（1） ， 辅流（2）
  * @endif
  */
@property (nonatomic, assign) int32_t layerType;

 /**
  * @if English 
  * The width of the video stream.
  * @endif
  * @if Chinese
  * 视频流宽
  * @endif
  */
@property (nonatomic, assign) int32_t width;
 
 /**
  * @if English 
  * The height of the video streams.
  * @endif
  * @if Chinese
  * 视频流高
  * @endif
  */
@property (nonatomic, assign) int32_t height;

 /**
  * @if English 
  * The width (px) of the video image captured by the local camera.
  * @endif
  * @if Chinese 
  * 本地采集的视频宽度 (px)。
  * @endif
  */
@property (nonatomic, assign) int32_t captureWidth;

 /**
  * @if English 
  * The height (px) of the video image captured by the local camera.
  * @endif
  * @if Chinese 
  * 本地采集的视频高度 (px)。
  * @endif
  */
@property (nonatomic, assign) int32_t captureHeight;

 /**
  * @if English 
  * Publishing bitrate after the last report (kbps).
  * @endif
  * @if Chinese
  *（上次统计后）发送码率(Kbps)
  * @endif
  */
@property (nonatomic, assign) int64_t sendBitrate;

 /**
  * @if English 
  * Publishing frame rate after the last report (fps).
  * @endif
  * @if Chinese
  *（上次统计后）发送帧率(fps)
  * @endif
  */
@property (nonatomic, assign) int32_t encoderOutputFrameRate;
  
 /**
  * @if English 
  * Video capture frame rate.
  * @endif
  * @if Chinese
  * 视频采集帧率
  * @endif
  */
@property (nonatomic, assign) int32_t captureFrameRate;
  
 /**
  * @if English 
  * The target bitrate of the encoder (kbps).
  * @endif
  * @if Chinese
  * 编码器的目标码率(kbps)
  * @endif
  */
@property (nonatomic, assign) int32_t targetBitrate;
 
 /**
  * @if English 
  * The actual bitrate of the encoder (kbps).
  * @endif
  * @if Chinese
  * 编码器的实际编码码率(kbps)
  * @endif
  */
@property (nonatomic, assign) int32_t encoderBitrate;

 /**
  * @if English 
  * Publishing video frame rate.
  * @endif
  * @if Chinese
  * 视频发送帧率
  * @endif
  */
@property (nonatomic, assign) int32_t sentFrameRate;

 /**
  * @if English 
  * Video rendering frame rate.
  * @endif
  * @if Chinese
  * 视频渲染帧率
  * @endif
  */
@property (nonatomic, assign) int32_t renderFrameRate;

 /**
  * @if English 
  * Encoder name.
  * @endif
  * @if Chinese
  * 编码器名字
  * @endif
  */
@property (nonatomic, copy) NSString *encoderName;

/**
 * @if English
 * whether super resolution drop bandwidth strategy is enabled.
 * @endif
 * @if Chinese
 * 超分降带宽策略是否开启
 * @endif
 */
@property (nonatomic, assign) BOOL dropBwStrategyEnabled;

@end

 /**
  * @if English 
  * The uplink stats of the local video stream.
  * @endif
  * @if Chinese
  *本地视频流上传统计信息
  * @endif
  */
NERTC_EXPORT  @interface NERtcVideoSendStats : NSObject

 /**
  * @if English 
  * For more information about stats for each uplink stream, see NERtcVideoLayerSendStats.
  * @endif
  * @if Chinese
  * 具体每条流的上行统计信息 详见 NERtcVideoLayerSendStats
  * @endif
  */
@property (nonatomic, strong)NSArray<NERtcVideoLayerSendStats *> *videoLayers;

@end

 /**
  * @if English 
  * Stats of each downlink stream received.
  * @endif
  * @if Chinese
  * 每条流的接收下行统计信息
  * @endif
  */
NERTC_EXPORT  @interface NERtcVideoLayerRecvStats : NSObject

 /**
  * @if English 
  * The stream type: Bigstream (1), substream (2).
  * @endif
  * @if Chinese
  * 流类型： 主流（1） ， 辅流（2）
  * @endif
  */
@property (nonatomic, assign) int32_t layerType;

 /**
  * @if English 
  * The width of the video streams.
  * @endif
  * @if Chinese
  * 视频流宽
  * @endif
  */
@property (nonatomic, assign) int32_t width;
 
 /**
  * @if English 
  * The height of the video streams.
  * @endif
  * @if Chinese
  * 视频流高
  * @endif
  */
@property (nonatomic, assign) int32_t height;

 /**
  * @if English 
  * The bitrate of each stream received after the last report (kbps)
  * @endif
  * @if Chinese
  *（上次统计后）接收码率(Kbps)
  * @endif
  */
@property (nonatomic, assign) int64_t receivedBitrate;

 /**
  * @if English 
  * The frame rate of the stream received.
  * @endif
  * @if Chinese
  * 接收到的帧率
 
 * @endif
 */
@property (nonatomic, assign) int32_t fps;

 /**
  * @if English 
  * Packet loss rate of the received video stream.
  * @endif
  * @if Chinese
  * 接收视频的丢包率
  * @endif
  */
@property (nonatomic, assign) int32_t packetLossRate;
  
 /**
  * @if English 
  * Decoder output frame rate
  * @endif
  * @if Chinese
  * 解码器输出帧率
  * @endif
  */
@property (nonatomic, assign) int32_t decoderOutputFrameRate;
 
 /**
  * @if English 
  * Renderer output frame rate.
  * @endif
  * @if Chinese
  * 渲染帧率
  * @endif
  */
@property (nonatomic, assign) int32_t rendererOutputFrameRate;
 
 /**
  * @if English 
  * The cumulative duration when received video frames freeze (ms), starting from receiving the video frames of a specific user.
  * @endif
  * @if Chinese
  * 接收视频卡顿累计时长（ms）， 从收到对应用户的视频算起
  * @endif
  */
@property (nonatomic, assign) int64_t totalFrozenTime;
 
 /**
  * @if English 
  * The average frozen rate of the received video frames, starting from receiving the video frames of a specific user.
  * @endif
  * @if Chinese
  * 接收视频的平均卡顿率， 从收到对应用户的视频算起
  * @endif
  */
@property (nonatomic, assign) int32_t frozenRate;

 /**
  * @if English 
  * The decoder name
  * @endif
  * @if Chinese
  * 解码器名字
  * @endif
  */
@property (nonatomic, copy) NSString *decoderName;

/**
 * @if English
 * The delay from the remote users'streams be captured to the local render. (ms)
 * @endif
 * @if Chinese
 * 远端用户的视频流从采集到本地播放的延迟。(ms)
 * @endif
 */
@property(nonatomic, assign) int32_t peerToPeerDelay;

@end

 /**
  * @if English 
  * The stats of the remote video stream.
  * @endif
  * @if Chinese
  * 远端视频流的统计信息
  * @endif
  */
NERTC_EXPORT  @interface NERtcVideoRecvStats : NSObject

 /**
  * @if English 
  * The user ID that is used to identify the video stream.
  * @endif
  * @if Chinese
  * 用户 ID，指定是哪个用户的视频流
  * @endif
  */
@property (nonatomic, assign) uint64_t uid;

 /**
 * @if English 
 * For more information about the downlink stats of each video stream that belongs to the user with the current uid, see NERtcVideoLayerRecvStats.
 * @endif
 * @if Chinese
 * 当前uid 每条流的接收下行统计信息 详见 NERtcVideoLayerRecvStats
 * @endif
 */
@property (nonatomic, strong) NSArray<NERtcVideoLayerRecvStats *> *videoLayers;

@end


/**
 * @if English
 * Local audio stream upload statistics.
 * @endif
 * @if Chinese
 * 本地音频流上传统计信息。
 * @endif
 */
NERTC_EXPORT @interface NERtcAudioLayerSendStats : NSObject

/**
 * @if English
 * Audio stream type.
 * @endif
 * @if Chinese
 * 音频流通道类型。
 * @endif
 */
@property (nonatomic, assign) NERtcAudioStreamType streamType;


/**
* @if English
* Sending bitrate after the last report (kbps).
* @endif
* @if Chinese
* 自上次统计后，发送码率的平均值，单位为 Kbps。
* @endif
*/
@property (nonatomic, assign) int64_t sentBitrate;

/**
* @if English
* Audio packet loss rate within a specific time.
* @endif
* @if Chinese
* 特定时间内的音频丢包率。
* @endif
*/
@property (nonatomic, assign) int16_t lossRate;

/**
* @if English
* RTT (Round-Trip Time) between the SDK and CommsEase server, in ms.
* @endif
* @if Chinese
* 往返时延，单位为毫秒。
* @endif
*/
@property (nonatomic, assign) int64_t rtt;

/**
* @if English
* volume level (0-100).
* @endif
* @if Chinese
* 音量等级(0-100)
* @endif
*/
@property (nonatomic, assign) int volume;

/**
* @if English
* The local user volume captured by the local device. The value ranges between 0 (lowest volume) and 100 (highest volume).
* camera.
* @endif
* @if Chinese
* 本地用户的采集音量，取值范围为 [0,100]。
* @endif
*/
@property (nonatomic, assign) int capVolume;

/**
* @if English
* The number of audio channels for audio capture.
* @endif
* @if Chinese
* 本地音频采集声道数
* @endif
*/
@property (nonatomic, assign) int16_t numChannels;

/**
* @if English
* The local audio sampling rate (Hz)
* @endif
* @if Chinese
* 本地音频采样率（Hz）
* @endif
*/
@property (nonatomic, assign) int32_t sentSampleRate;
@end


/**
 * @if English 
 * The uplink stats of the local audio stream.
 * @endif
 * @if Chinese
 * 本地音频流上传统计信息。
 * @endif
 */
NERTC_EXPORT  @interface NERtcAudioSendStats : NSObject

/**
 * @if English
 * Stats of upstream data of each remote audio stream. For more information, see {@link NERtcAudioLayerSendStats}. Determine the stream type by the streamType parameter.
 * @endif
 * @if Chinese
 * 具体每条音频流的上行统计信息。详细信息请参考 {@link NERtcAudioLayerSendStats}，通过其中的 streamType 参数来判断流类型。
 * @endif
 */
@property (nonatomic, strong)NSArray<NERtcAudioLayerSendStats *> *audioLayers;
@end

/**
 * @if English
 * Stats of a remote audio stream.
 * @endif
 * @if Chinese
 * 远端用户的音频统计。
 * @endif
 */
NERTC_EXPORT @interface NERtcAudioLayerRecvStats : NSObject

/**
 * 
 * @if Chinese
 * 音频流通道类型。
 * @endif
 */
@property (nonatomic, assign) NERtcAudioStreamType streamType;

/**
* @if English
* Bitrate of each stream received after the last report (kbps).
* @endif
* @if Chinese
*（上次统计后）接收码率(Kbps)
* @endif
*/
@property (nonatomic, assign) int64_t receivedBitrate;


/**
* @if English
* Audio packet loss rate within a specific time
* @endif
* @if Chinese
* 特定时间内的音频丢包率
* @endif
*/
@property (nonatomic, assign) int16_t audioLossRate;

/**
* @if English
* The volume level (0-100)
* @endif
* @if Chinese
* 音量等级(0-100)
* @endif
*/
@property (nonatomic, assign) int volume;

/**
* @if English
* The cumulative duration when the audio frames freeze, starting from receiving the audio stream from the remote user.
* @endif
* @if Chinese
* 音频卡顿累计时长，从收到远端用户音频算起
* @endif
*/
@property (nonatomic, assign) int64_t totalFrozenTime;

/**
* @if English
* Average audio frozen rate, starting from receiving the audio stream from the remote user.
* @endif
* @if Chinese
* 平均音频卡顿率，从收到远端用户音频算起
* @endif
*/
@property (nonatomic, assign) int32_t frozenRate;

/**
 * @if English
 * The timestamp difference between the audio stream and the video stream. range is [-150, 150]ms. available when audio and
 * video stream both received.
 * @endif
 * @if Chinese
 * 音视频流的时间戳差值，范围为 [-150, 150]ms。当音视频流都收到时有效。
 * @endif
 */
@property (nonatomic, assign) int32_t avTimeStampDiff;

/**
 * @if English
 * The delay from the remote users'streams be captured to the local render. (ms)
 * @endif
 * @if Chinese
 * 远端用户的音频流从采集到本地播放的延迟。(ms)
 * @endif
 */
@property(nonatomic, assign) int32_t peerToPeerDelay;

@end


/**
 * @if English 
 * The stats of the audio stream from a remote user.
 * @endif
 * @if Chinese
 * 远端用户的音频统计。
 * @endif
 */
NERTC_EXPORT  @interface NERtcAudioRecvStats : NSObject

/**
 * @if English 
 * The user ID that is used to identify the audio stream.
 * @endif
 * @if Chinese
 * 用户 ID，指定是哪个用户的音频流。
 * @endif
 */
@property (nonatomic, assign) uint64_t uid;


/**
 * @if English
 * Stats of downstream data of each remote audio stream. For more information, see {@link NERtcAudioLayerRecvStats}. Determine the stream type by the streamType parameter.
 * @endif
 * @if Chinese
 * 具体每条音频流的下行统计信息。详细信息请参考 {@link NERtcAudioLayerRecvStats}，通过其中的 streamType 参数来判断流类型。
 * @endif
 */
@property (nonatomic, strong)NSArray<NERtcAudioLayerRecvStats *> *audioLayers;
@end


 /**
 * @if English 
 * The stats of network quality
 * @endif
 * @if Chinese
 * 用户的网络质量
* @endif
*/
NERTC_EXPORT  @interface NERtcNetworkQualityStats : NSObject

 /**
 * @if English 
 * User ID
 * @endif
 * @if Chinese
 * 用户 ID
 * @endif
 */
@property (nonatomic, assign) uint64_t userId;

 /**
 * @if English 
 * Uplink network quality
 * @endif
 * @if Chinese
 * 上行的网络质量
 * @endif
 */
@property (nonatomic, assign) NERtcNetworkQuality txQuality;

 /**
 * @if English 
 * Downlink network quality
 * @endif
 * @if Chinese
 * 下行的网络质量
* @endif
*/
@property (nonatomic, assign) NERtcNetworkQuality rxQuality;

@end

 /**
 * @if English 
 * Occurs when the stats are collected.
 * @endif
 * @if Chinese
 * 统计信息回调
 * @endif
 */
@protocol NERtcEngineMediaStatsObserver<NSObject>

@optional

 /**
  * @if English 
  * Occurs when the stats of the current call is collected
  * <br>The SDK reports the stats of the current call to the app on a regular basis. The callback is triggered every 2 seconds.
  * @param stat NERTC engine statistics: NERtcStats
  * @endif
  * @if Chinese
  * 当前通话统计回调
  * <br>SDK 定期向 App 报告当前通话的统计信息，每 2 秒触发一次。
  * @param stat NERTC 引擎统计数据: NERtcStats
  * @endif
  */
-(void)onRtcStats:(NERtcStats *)stat;

 /**
  * @if English 
  * Occurs when the stats of the local audio stream are collected. 
  * <br>The message sent by this callback describes the stats of the audio stream published by the local device. The callback is triggered every 2 seconds.
  * @param stat The stats of the local audio stream. For more information, see NERtcAudioSendStats.
  * @endif
  * @if Chinese
  * 本地音频流统计信息回调
  * <br>该回调描述本地设备发送音频流的统计信息，每 2 秒触发一次。
  * @param stat 本地音频流统计信息。详见 NERtcAudioSendStats.
  * @endif
  */
- (void)onLocalAudioStat:(NERtcAudioSendStats *)stat;

 /**
  * @if English 
  * <td>Occurs when the stats of the remote audio stream in the call are collected.</td>
  * <br>The message sent by this callback describes the stats of the audio stream in a peer-to-peer call from the remote user. The callback is triggered every 2 seconds.
  * @param stats An array of audio stats of the audio stream from each remote user. For more information, see NERtcAudioRecvStats.
  * @endif
  * @if Chinese
  * 通话中远端音频流的统计信息回调。
  * <br>该回调描述远端用户在通话中端到端的音频流统计信息，每 2 秒触发一次。
  * @param stats 每个远端用户音频统计信息的数组。详见 NERtcAudioRecvStats.
  * @endif
  */
- (void)onRemoteAudioStats:(NSArray<NERtcAudioRecvStats*> *)stats;

 /**
  * @if English 
  * Occurs when the stats of the video stream are collected.
  * <br>The message sent by this callback describes the stats of the video stream published by the local device. The callback is triggered every 2 seconds.
  * @param stat The stats of the local video stream. For more information, see NERtcVideoSendStats.
  * @note The API is disabled in the audio-only SDK. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
  * @endif
  * @if Chinese
  * 本地视频流统计信息回调
  * <br>该回调描述本地设备发送视频流的统计信息，每 2 秒触发一次。
  * @param stat 本地视频流统计信息。详见 NERtcVideoSendStats.
  * @note 纯音频SDK禁用该接口，如需使用请前往云信官网下载并替换成视频SDK
  * @endif
  */
-(void)onLocalVideoStat:(NERtcVideoSendStats *)stat;

 /**
  * @if English 
  * Occurs when the stats of the remote video stream in the call are collected
  * <br>The message sent by this callback describes the stats of the video stream in a peer-to-peer call from the remote user. The callback is triggered every 2 seconds.
  * @param stats An array of stats of the video stream from a remote user. For more information, see NERtcVideoRecvStats
  * @note The API is disabled in the audio-only SDK. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
  * @endif
  * @if Chinese
  * 通话中远端视频流的统计信息回调
  * <br>该回调描述远端用户在通话中端到端的视频流统计信息，每 2 秒触发一次。
  * @param stats 远端用户视频统计信息的数组。详见 NERtcVideoRecvStats.
  * @note 纯音频SDK禁用该接口，如需使用请前往云信官网下载并替换成视频SDK
  * @endif
  */
- (void)onRemoteVideoStats:(NSArray<NERtcVideoRecvStats*> *)stats;

 /**
  * @if English 
  * Returns the uplink and downlink network quality report for each user during the call
  * <br>The message sent by this callback describes the network status of each user during the call. The callback is triggered every 2 seconds.
  * @param stats User network status array
  * @endif
  * @if Chinese
  * 通话中每个用户的网络上下行质量报告回调
  * <br>该回调描述每个用户在通话中的网络状态，每 2 秒触发一次。
  * @param stats 用户网络状态数组
  * @endif
  */
  - (void)onNetworkQuality:(NSArray<NERtcNetworkQualityStats *> *)stats;

@end

 /**
  * @if English 
  * The channel media stats observer.
  * @endif
  * @if Chinese
  * channel 统计信息回调。
  * @endif
  */
@protocol NERtcChannelMediaStatsObserver<NERtcEngineMediaStatsObserver>
@end



NS_ASSUME_NONNULL_END

#pragma clang diagnostic pop
