/*
 * Copyright (c) 2021 NetEase, Inc. All rights reserved.
 */

#ifndef INERtcEngineEx_h
#define INERtcEngineEx_h

#import "INERtcEngine.h"
#import "NERtcEngineStatistics.h"
#import "NERtcEngineBase.h"
#import "NERtcEngineDelegate.h"

@class NERtcChannel;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"


NS_ASSUME_NONNULL_BEGIN

/**
 * @if English
 * NERtcEngine extended API
 * @endif
 * @if Chinese
 * NERtcEngine 扩展接口
 * @endif
 */
@protocol INERtcEngineEx <INERtcEngine>

/**
 * @if English
 * Enables or disables the dual-stream mode.
 * <br>The method sets the individual-stream mode or dual-stream mode. If the dual-stream mode is enabled on the publishing client, the receiver can choose to receive the high-quality stream or low-quality stream video. The high-quality stream has a high resolution and high bitrate. The low-quality stream has a low resolution and low bitrate.
 * @note
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * - The method applies to only camera data. Video streams from external input and screen sharing are not affected.
 * - You can call this method before or after you join a room.
 * @param enable A value of YES indicates that the dual-stream mode is enabled. A value of NO indicates that the dual stream mode is disabled.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置是否开启视频大小流模式。
 * <br> 
 * 通过本接口可以实现设置单流或者双流模式。发送端开启双流模式后，接收端可以选择接收大流还是小流。其中，大流指高分辨率、高码率的视频流，小流指低分辨率、低码率的视频流。
 * @since V3.5.0
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
 * @note
 * - 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
 * - 该方法只对摄像头数据生效，对自定义输入、屏幕共享等视频流无效。
 * - 该接口的设置会在摄像头重启后生效。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>enable</td>
 *      <td>BOOL</td>
 *      <td>是否开启双流模式：<ul><li>YES：开启双流模式。<li>NO：关闭双流模式。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine] enableDualStreamMode:YES];
 * @endcode
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *         - 30004（kNERtcErrNotSupported）：不支持的操作，比如当前使用的是纯音频 SDK。
 *         - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎尚未初始化。
 * @endif
 */
- (int)enableDualStreamMode:(BOOL)enable;

/**
 * @if English
 * Sets the priority of media streams from a local user.
 * <br>If a user has a high priority, the media stream from the user also has a high priority. In unreliable network connections, the SDK guarantees the quality of the media stream from users with a high priority.
 * @note 
 * - You must call the method before you call joinChannel.
 * - After you switch the room by calling switchChannel, the media stream priority is restored to the default normal priority.
 * @param priority The priority of the local media stream. The default value is #kNERtcMediaPriorityNormal, which indicates the normal priority. For more information, see {@link NERtcMediaPriorityType}. 
 * @param preemptive The option whether to enable the preempt mode.
 *                    - If the preempt mode is enabled, the local media stream preempts the high priority over other users. The priority of the media stream whose priority is taken becomes normal. After the user who preempts the priority leaves the room, other users still keep the normal priority.
 *                    - If the preempt mode is disabled, and a user in the room has a high priority, then, the high priority of the local client remains invalid and is still normal.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置本地用户的媒体流优先级。
 * <br>
 * 通过此接口可以实现设置某用户的媒体流优先级为高，从而弱网环境下 SDK 会优先保证其他用户收到的该用户媒体流的质量。
 * @since V4.2.0
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间前调用。
 * @note
 * - 一个音视频房间中只有一个高优先级的用户。建议房间中只有一位用户调用 setLocalMediaPriority 将本端媒体流设为高优先级，否则需要开启抢占模式，保证本地用户的高优先级设置生效。
 * - 调用 {@link INERtcEngine#switchChannelWithToken:channelName:channelOptions:completion:} 方法快速切换房间后，媒体优先级会恢复为默认值，即普通优先级。
 * @par 参数说明 
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>priority</td>
 *      <td>NERtcMediaPriorityType</td>
 *      <td>本地用户的媒体流优先级，默认为 kNERtcMediaPriorityNormal，即普通优先级。</td>
 *  </tr>
 *  <tr>
 *      <td>preemptive</td>
 *      <td>BOOL</td>
 *      <td>是否开启抢占模式：<ul><li>YES：开启抢占模式。抢占模式开启时，本地用户可以抢占其他用户的高优先级，被抢占的用户的媒体优先级变为普通优先级，在抢占者退出房间后，其他用户的优先级仍旧维持普通优先级。<li>NO：关闭抢占模式。抢占模式关闭时，如果房间中已有高优先级用户，则本地用户的高优先级设置不生效，仍旧为普通优先级。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine] setLocalMediaPriority:kNERtcMediaPriorityHigh preemptive:YES];
 * @endcode
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * @endif
 */
- (int)setLocalMediaPriority:(NERtcMediaPriorityType)priority preemptive:(BOOL)preemptive;


/**
 * @if English
 * Sets the fallback option for the published local video stream based on the network conditions.
 * <br>The quality of the published local audio and video streams is degraded with poor quality network connections. After you call this method and set the option to kNERtcStreamFallbackOptionAudioOnly:
 * - With unreliable uplink network connections and the quality of audio and video streams degraded, the SDK switches to receive a low-quality video stream or stops receiving video streams. This way, the audio quality is maintained or improved.
 * - The SDK monitors the network performance and recover audio and video streams if the network quality improves.
 * - If the published audio and video stream from the local client falls back to the audio stream, or recovers to the audio and video stream, the SDK triggers the onLocalPublishFallbackToAudioOnly callback.
 * @note You must call the method before you call joinChannel.
 * @since V4.3.0
 * @param option The fallback options for publishing audio and video streams. The default value is disabled. For more information, see {@link NERtcStreamFallbackOptions}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 设置弱网条件下发布的音视频流回退选项。
 * <br>在网络不理想的环境下，发布的音视频质量都会下降。使用该接口并将 option 设置为 kNERtcStreamFallbackOptionAudioOnly 后:
 * - SDK 会在上行弱网且音视频质量严重受影响时，自动关断视频流，尽量保证音频质量。
 * - 同时 SDK 会持续监控网络质量，并在网络质量改善时恢复音视频流。
 * - 当本地发布的音视频流回退为音频流时，或由音频流恢复为音视频流时，SDK 会触发本地发布的媒体流已回退为音频流 onLocalPublishFallbackToAudioOnly 回调。
 * @note 请在加入房间（joinChannel）前调用此方法。
 * @since V4.3.0
 * @param option   发布音视频流的回退选项，默认为不开启回退。 详细信息请参考 {@link NERtcStreamFallbackOptions}。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)setLocalPublishFallbackOption:(NERtcStreamFallbackOptions)option;

/**
 * @if English
 * Sets the fallback option for the subscribed remote audio and video stream with poor network connections.
 * <br>The quality of the subscribed audio and video streams is degraded with unreliable network connections. After you set the fallback options for the subscribed audio and video stream by using this method:
 * - With unreliable downstream network connections, the SDK switches to receive a low-quality video stream or stops receiving video streams. This way, the audio quality is maintained or improved.
 * - The SDK monitors the network quality and resumes the video stream when the network conditions improve.
 * - If the subscribed remote video stream falls back to an audio-only stream, or the audio-only stream switches back to the video stream, the SDK triggers the onNERtcEngineRemoteSubscribeFallbackToAudioOnly callback.
 * @note You must call the method before you call joinChannel.
 * @since V4.3.0
 * @param option The fallback option for subscribing to audio and video streams. The default setting is to fall back to the low-quality video stream in the poor network. For more information, see {@link NERtcStreamFallbackOptions}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 设置弱网条件下订阅的音视频流回退选项。
 * <br>弱网环境下，订阅的音视频质量会下降。通过该接口设置订阅音视频流的回退选项后：
 * - SDK 会在下行弱网且音视频质量严重受影响时，将视频流切换为小流，或关断视频流，从而保证或提高通信质量。
 * - SDK 会持续监控网络质量，并在网络质量改善时自动恢复音视频流。
 * - 当远端订阅流回退为音频流时，或由音频流恢复为音视频流时，SDK 会触发远端订阅流已回退为音频流回调。
 * @note 请在加入房间（joinChannel）前调用此方法。
 * @since V4.3.0
 * @param option  订阅音视频流的回退选项，默认为弱网时回退到视频小流。详细信息请参考 {@link NERtcStreamFallbackOptions}。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)setRemoteSubscribeFallbackOption:(NERtcStreamFallbackOptions)option;

/**
 * @if English
 * Stops or resumes publishing the local audio stream.
 * <br>The method is used to stop or resume publishing the local audio stream.
 * @note 
 * - This method does not change the audio capture state because the audio capture devices are not disabled.
 * - The mute state is reset to unmuted after the call ends.
 * @since V4.5.0
 * @param muted The option whether to enable publishing the local audio stream.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 开启或关闭本地音频主流的发送。
 * <br>该方法用于向网络发送或取消发送本地音频数据，不影响本地音频的采集状态，也不影响接收或播放远端音频流。
 * @since V3.5.0
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法在加入房间前后均可调用。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>mute</td>
 *      <td>BOOL</td>
 *      <td>是否关闭本地音频的发送：<ul><li>YES：不发送本地音频。<li>NO：发送本地音频。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //不发送本地音频
 * [[NERtcEngine sharedEngine] muteLocalAudio:YES];
 * //发送本地音频
 * [[NERtcEngine sharedEngine] muteLocalAudio:NO];
 * @endcode 
 * @par 相关回调
 * 若本地用户在说话，成功调用该方法后，房间内其他用户会收到 {@link NERtcEngineDelegateEx#onNERtcEngineUser:audioMuted:}  回调。
 * @par 相关接口
 * {@link INERtcChannel#enableMediaPub:withMediaType:}：
 *        - 在需要开启本地音频采集（监测本地用户音量）但不发送音频流的情况下，您也可以调用 enableMeidaPub(NO) 方法。
 *        - 两者的差异在于， muteLocalAudio(YES) 仍然保持与服务器的音频通道连接，而 enableMediaPub(NO) 表示断开此通道，因此若您的实际业务场景为多人并发的大房间，建议您调用 enableMediaPub 方法。  
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *         - 30001（kNERtcErrFatal）：引擎未初始化。
 * @endif
 */
- (int)muteLocalAudio:(BOOL)muted;

/**
 * @if English
 * Subscribes to or unsubscribes from audio streams from specified remote users.
 * <br>After a user joins a room, audio streams from all remote users are subscribed by default. You can call this method to subscribe to or unsubscribe from audio streams from all remote users.
 * @note You can call this method before or after you join a room.
 * @param subscribe The option whether to subscribe to specified audio streams.
 * @param userID The ID of a specified remote user.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 取消或恢复订阅指定远端用户的音频主流。
 * <br>加入房间时，默认订阅所有远端用户的音频主流，您也可以通过此方法取消或恢复订阅指定远端用户的音频主流。
 * @since V3.5.0
 * @par 调用时机
 * 该方法仅在加入房间后收到远端用户开启音频主流的回调 {@link NERtcEngineDelegate#onNERtcEngineUserAudioDidStart:} 后可调用。
 * @par 业务场景
 * 适用于需要手动订阅指定用户音频流的场景。
 * @note
 * 该方法设置内部引擎为启用状态，在 leaveChannel 后设置失效，将恢复至默认。
 * 在开启音频自动订阅且未打开服务端 ASL 自动选路的情况下，调用该接口无效。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>userID</td>
 *      <td>uint64_t</td>
 *      <td>指定用户的 ID。</td>
 *  </tr>
 *  <tr>
 *      <td>subscribe</td>
 *      <td>BOOL</td>
 *      <td>是否订阅指定用户的音频主流：<ul><li>YES：订阅音频主流。<li>NO：取消订阅音频主流。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //订阅对方uid为12345的音频主流
 * [[NERtcEngine sharedEngine] subscribeRemoteAudio:YES forUserID:12345];
 * //取消订阅对方uid为12345的音频主流
 * [[NERtcEngine sharedEngine] subscribeRemoteAudio:NO forUserID:12345];
 * @endcode
 * @par 相关接口
 * 若您希望订阅指定远端用户的音频辅流，请调用 {@link INERtcEngineEx#subscribeRemoteSubStreamAudio:forUserID:} 方法。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal)：引擎未创建成功。
 *      - 30005（kNERtcErrInvalidState)：当前状态不支持的操作，比如尚未加入房间。
 *      - 30105（kNERtcErrFatal)：未找到指定用户。
 * @endif
 */
- (int)subscribeRemoteAudio:(BOOL)subscribe forUserID:(uint64_t)userID;

/**
 * @if English
 * Subscribes to or unsubscribes from audio streams from all remote users.
 * @note
 * - After a user joins a room, audio streams from all remote users are subscribed by default. In this case, do not repeat subscribing to audio streams from all remote users by calling subscribeAllRemoteAudioStreams(YES).
 * - You must join a room before you can call the method.
 * - This setting applies to subsequent users that join the room.
 * @param subscribe The option whether to unsubscribe from audio streams from all remote users.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 取消或恢复订阅所有远端用户的音频主流。
 * <br>加入房间时，默认订阅所有远端用户的音频主流，即 {@link INERtcEngine#setParameters:} 方法的 kNERtcKeyAutoSubscribeAudio 参数默认设置为 YES；只有当该参数的设置为 NO 时，此接口的调用才会生效。
 * @since V3.5.0
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法在加入房间前后均可调用。
 * @par 业务场景
 * 适用于重要会议需要一键全体静音的场景。
 * @note
 * - 设置该方法的 subscribe 参数为 YES 后，对后续加入房间的用户同样生效。
 * - 在开启自动订阅（默认）时，设置该方法的 subscribe 参数为 NO 可以实现取消订阅所有远端用户的音频流，但此时无法再调用 {@link INERtcEngineEx#subscribeRemoteAudio:forUserID:} 方法单独订阅指定远端用户的音频流。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>subscribe</td>
 *      <td>BOOL</td>
 *      <td>是否订阅所有用户的音频主流：<ul><li>YES：订阅音频主流。<li>NO：取消订阅音频主流。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //订阅所有远端用户的音频主流
 * [[NERtcEngine sharedEngine] subscribeAllRemoteAudio:YES];
 * //取消订阅所有远端用户的音频主流
 * [[NERtcEngine sharedEngine] subscribeAllRemoteAudio:NO];
 * @endcode
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal)：引擎未创建成功。
 * @endif
 */
- (int)subscribeAllRemoteAudio:(BOOL)subscribe;

/**
 * @if English
 * Sets the local audio stream can be subscribed by specified participants in a room.
 * <br>All participants in the room can subscribe to the local audio stream by default.
 * @note
 *  - The API must be called after a user joins a room.
 *  - The API cannot be called by user IDs out of the room.
 * @since V4.6.10
 * @param uidArray The list of user IDs that can subscribe to the local audio stream.
 * @note The list contains all participants in a room. If the value is empty or null, all participants can subscribe to the local audio stream.
 * @return
 * - 0: success
 * - Others: failure.
 * @endif
 * @if Chinese
 * 设置自己的音频只能被房间内指定的人订阅。
 * <br>默认房间所有其他人都可以订阅自己的音频。
 * @note
 *  - 此接口需要在加入房间成功后调用。
 *  - 对于调用接口时不在房间的 uid 不生效。
 * @since V4.6.10
 * @param uidArray 可订阅自己音频的用户uid 列表。
 * @note 此列表为全量列表。如果列表为空或 null，表示其他所有人均可订阅自己的音频。
 * @return
 * - 0：方法调用成功。
 * - 其他：方法调用失败。
 * @endif
 */
- (int)setAudioSubscribeOnlyBy:(NSArray<NSNumber*> *)uidArray;

/**
 * @if English
 * Enables or disables the audio substream.
 * <br>If the audio substream is enabled, remote clients will get notified by {@link NERtcChannelDelegate#onNERtcChannelUserSubStreamAudioDidStart:}, and {@link NERtcChannelDelegate#onNERtcChannelUserSubStreamAudioDidStop:} when the audio stream is disabled.
 * @since V4.6.10
 * @param enabled specifies whether to enable the audio substream.
 * - true: enables the audio substream.
 * - false: disable the audio substream.
 * @return
 * - 0: success
 * - Others: failure
 * @endif
 * @if Chinese
 * 开启或关闭音频辅流。
 * <br>开启时远端会收到 {@link NERtcChannelDelegate#onNERtcChannelUserSubStreamAudioDidStart:} 回调 ，关闭时远端会收到 {@link NERtcChannelDelegate#onNERtcChannelUserSubStreamAudioDidStop:} 回调。
 * @since V4.6.10
 * @param enabled 是否开启音频辅流。
 * - YES：开启音频辅流。
 * - NO：关闭音频辅流。
 * @return
 * - 0 ：方法调用成功。
 * - 其他：方法调用失败。
 * @endif
 */
- (int)enableLocalSubStreamAudio:(BOOL)enabled;

/**
 * @if English
 * Subscribes or unsubscribes audio streams from specified remote users.
 * <br>After a user joins a room, audio streams from all remote users are subscribed by default. You can call this method to subscribe or unsubscribe audio streams from all remote users.
 * @note This method can be called only if a user joins a room.
 * @since V4.6.10
 * @param userID       indicates the user ID.
 * @param subscribe specifies whether to subscribe specified audio streams.
 *                  - true: subscribes audio steams. This is the default value.
 *                  - false: unsubscribes audio streams.
 * @return
 * - 0: success
 * - Others: failure
 * @endif
 * @if Chinese
 * 设置是否订阅指定远端用户的音频辅流。
 * @since V4.6.10
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间且收到远端用户开启音频辅流的回调 {@link NERtcEngineDelegate#onNERtcEngineUserSubStreamAudioDidStart:} 后调用。
 * @note
 * - 加入房间时，默认订阅所有远端用户的音频流。
 * - 请在指定远端用户加入房间后再调用此方法。
 * @par 参数说明 
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>uid</td>
 *      <td>uint64_t</td>
 *      <td>远端用户 ID。</td>
 * </tr>
 *  <tr>
 *      <td>subscribe</td>
 *      <td>BOOL</td>
 *      <td>是否订阅指定音频辅流：<ul><li>YES：订阅指定音频辅流。<li>NO：取消订阅指定音频辅流。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //订阅 userId 用户的音频辅流
 * [[NERtcEngine sharedEngine] subscribeRemoteSubStreamAudio forUserID:userId];
 * //取消订阅 userId 用户的音频辅流
 * [[NERtcEngine sharedEngine] subscribeRemoteSubStreamAudio forUserID:userId];
 * @endcode
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *         - 30001（kNERtcErrFatal）：操作不支持，比如已开启自动订阅音频辅流。
 *         - 30005（kNERtcErrInvalidState）：状态错误，比如引擎未初始化。
 *         - 30105（kNERtcErrUserNotFound）：指定用户尚未加入房间。
 * @endif
 */
- (int)subscribeRemoteSubStreamAudio:(BOOL)subscribe forUserID:(uint64_t)userID;

/**
 * @if English
 * Mutes or unmutes the local upstream audio stream.
 * @note The muted state will be reset to unmuted after a call ends.
 * @since V4.6.10
 * @param muted specifies whether to mute a local audio stream.
 *              - true (default): mutes a local audio stream.
 *              - false: unmutes a local audio stream.
 * @return
 * - 0: success
 * - Others: failure
 * @endif
 * @if Chinese
 * 静音或解除静音本地上行的音频辅流。
 * @note  静音状态会在通话结束后被重置为非静音。
 * @since V4.6.10
 * @param muted 是否静音本地音频辅流发送。
 *               - YES（默认）：静音本地音频辅流。
 *               - NO：取消静音本地音频辅流。
 * @return
 * - 0：方法调用成功。
 * - 其他：方法调用失败。
 * @endif
 */
- (int)muteLocalSubStreamAudio:(BOOL)muted;


/**
 * @if English
 * Enables or disables an external source input published over the audio substream.
 * <br>After the method is implemented, you can call {@link pushExternalSubStreamAudioFrame:} to send the PCM data of the audio substream.
 * @note
 * - Call the method before {@link pushExternalSubStreamAudioFrame:}.
 * - If the external audio substream is enabled, users can manage the audio substream and the setting becomes invalid after the user calls leaveChannel.
 * @since V4.6.10
 * @param enabled    specifies whether to enable an external source input as audio substream.
 *                   - true: enables an external source as audio substream. Users manage the audio substream.
 *                   - false(default): disable an external source. The SDK manages the audio substream.
 * @param sampleRate Sampling rate of an external audio source. Unit: Hz. 8000，16000，32000，44100, and 48000 are recommended.
 *                   @note You can set a random valid value when disabling an external source by calling this API. In this case, the setting is not applied.
 * @param channels   The number of channels of an external audio source.
 *                   - 1: mono
 *                   - 2: stereo
 *                   @note You can set a random valid value when disabling an external source by calling this API. In this case, the setting is not applied.
 * @return 
 * - 0: success
 * - Others: failure
 * @endif
 * @if Chinese
 * 开启或关闭外部音频辅流数据源输入。
 * <br>通过本接口可以实现创建自定义的外部音频源，并通过辅流通道传输该外部音频源的数据。
 * @since V4.6.10
 * @par 使用前提
 * 建议在通过 {@link INERtcEngine#enableLocalAudio:} 接口关闭本地音频采集之后调用该方法。
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
 * @par 业务场景
 * 实现由应用层而非 SDK 采集音频数据，比如在合唱过程中使用自定义的音乐文件。
 * @note
 * - 调用该方法关闭外部音频输入时可以传入任意合法值，此时设置不会生效，例如 setExternalAudioSource(false, 0, 0)。
 * - 该方法设置内部引擎为启用状态，在 {@link INERtcEngine#leaveChannel} 后仍然有效；如果需要关闭该功能，需要在下次通话前调用此接口关闭外部音频数据输入功能。
 * - 成功调用此方法后，将用虚拟设备代替麦克风工作，因此麦克风的相关设置会无法生效，例如进行 loopback 检测时，会听到外部输入的音频数据。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>enabled</td>
 *      <td>BOOL</td>
 *      <td>是否开启外部音频输入：<ul><li>YES：开启外部音频输入。<li>NO：关闭外部音频输入。</td>
 *  </tr>
 *  <tr>
 *      <td>sampleRate</td>
 *      <td>int32_t</td>
 *      <td>外部音频源的数据采样率，单位为 Hz。建议设置为 8000，16000，32000，44100 或 48000。</td>
 *  </tr>
 *  <tr>
 *      <td>channels</td>
 *      <td>int32_t</td>
 *      <td>外部音频源的数据声道数：<ul><li>1：单声道。<li>2：双声道。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 *  * @if Chinese
 * 开启或关闭外部音频源数据输入。
 * <br>通过本接口可以实现创建自定义的外部音频源，并通过主流通道传输该外部音频源的数据。
 * @since V3.9.0
 * @par 使用前提
 * 建议在通过 {@link INERtcEngine#enableLocalAudio:} 接口关闭本地音频采集之后调用该方法。
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
 * @par 业务场景
 * 实现由应用层而非 SDK 采集音频数据，比如在合唱过程中使用自定义的音乐文件。
 * @note
 * - 调用该方法关闭外部音频输入时可以传入任意合法值，此时设置不会生效，例如 setExternalAudioSource(false, 0, 0)。
 * - 该方法设置内部引擎为启用状态，在 {@link INERtcEngine#leaveChannel} 后仍然有效；如果需要关闭该功能，需要在下次通话前调用此接口关闭外部音频数据输入功能。
 * - 成功调用此方法后，将用虚拟设备代替麦克风工作，因此麦克风的相关设置会无法生效，例如进行 loopback 检测时，会听到外部输入的音频数据。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>enabled</td>
 *      <td>BOOL</td>
 *      <td>是否开启外部音频输入：<ul><li>YES：开启外部音频输入。<li>NO：关闭外部音频输入。</td>
 *  </tr>
 *  <tr>
 *      <td>sampleRate</td>
 *      <td>int32_t</td>
 *      <td>外部音频源的数据采样率，单位为 Hz。建议设置为 8000，16000，32000，44100 或 48000。</td>
 *  </tr>
 *  <tr>
 *      <td>channels</td>
 *      <td>int32_t</td>
 *      <td>外部音频源的数据声道数：<ul><li>1：单声道。<li>2：双声道。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //开启外部辅流音频输入，并设置输入采样率为 48k 单声道
 * [[NERtcEngine sharedEngine] setExternalSubStreamAudioSource:YES sampleRate:48000 channels:1];
 * @endcode
 * @par 相关接口
 * 该方法调用成功后可以调用 {@link INERtcEngineEx#pushExternalSubStreamAudioFrame:} 方法发送音频 PCM 数据。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal）：引擎尚未初始化。
 *      - 30003（kNERtcErrInvalidParam）：参数错误，比如声道数不是 1 或者 2，或者采样率设置有问题。
 * @endif
 */
- (int)setExternalSubStreamAudioSource:(BOOL)enabled sampleRate:(int32_t)sampleRate channels:(int32_t)channels;

/**
 * @if English
 * Pushes external audio source over the audio substream.
 * <br>The method pushes the audio frame data captured from an external source to the internal engine and enables the audio substream using {@link INERtcEngineEx.enableLocalSubStreamAudio:}. The method can send the PCM data of an audio substream.
 * @note
 * - The method must be called after a user joins a room
 * - We recommend the data frame match 10s as a cycle.
 * - The method is invalid after the audio substream is disabled.
 * @since V4.6.10
 * @param frame audio frame data.
 * @return 
 * - 0: success
 * - Others: failure
 * @endif
 * @if Chinese
 * 推送外部音频辅流数据帧。
 * <br>将外部音频辅流帧数据帧主动推送给内部引擎。通过 {@link INERtcEngineEx.enableLocalSubStreamAudio:} 启用音频辅流后，可以调用此接口发送音频辅流 PCM 数据。
 * @note
 * - 该方法需要在加入房间后调用。
 * - 数据帧时长建议匹配 10ms 周期。
 * - 该方法在音频辅流关闭后不再生效。
 * @since V4.6.10
 * @param frame 音频帧数据。
 * @return 
 * - 0: 方法调用成功。
 * - 其他: 方法调用失败。
 * @endif
 */
- (int)pushExternalSubStreamAudioFrame:(NERtcAudioFrame *)frame;

/**
 * @if English
 * Subscribes to or unsubscribes from video streams from specified remote users.
 * <br>After a user joins a room, the video streams from remote users are not subscribed by default. If you want to view video streams from specified remote users, you can call this method to subscribe to the video streams from the user when the user joins the room or publishes the video streams.
 * @note
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * - You must join a room before you can call the method.
 * @param subscribe The option whether to unsubscribe from local video streams.
 * @param userID The ID of a specified user.
 * @param streamType The type of the video streams. For more information, see {@link NERtcRemoteVideoStreamType}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 订阅或取消订阅指定远端用户的视频主流。
 * <br>加入房间后，默认不订阅所有远端用户的视频主流；若您希望看到指定远端用户的视频，可以在监听到对方加入房间或发布视频流之后，通过此方法订阅该用户的视频主流。
 * @since V3.5.0
 * @par 调用时机
 * 请在初始化后调用该方法，且该方法仅可在加入房间后调用。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>userID</td>
 *      <td>uint64_t</td>
 *      <td>指定用户的 ID。</td>
 *  </tr>
 *  <tr>
 *      <td>streamType</td>
 *      <td>{@link NERtcRemoteVideoStreamType}</td>
 *      <td>订阅的视频流类型：<ul><li>kNERtcRemoteVideoStreamTypeHigh：高清画质的大流。<li>kNERtcRemoteVideoStreamTypeLow：低清画质的小流。</td>
 *  </tr>
 *  <tr>
 *      <td>subscribe</td>
 *      <td>BOOL</td>
 *      <td>是否订阅远端用户的视频流：<ul><li>YES：订阅指定视频流。<li>NO：不订阅指定视频流。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //订阅对方uid为12345的大流
 * [[NERtcEngine sharedEngine] subscribeRemoteVideo:YES forUserID:12345 streamType:kNERtcRemoteVideoStreamTypeHigh];
 * @endcode
 * @par 相关接口
 * 若您希望订阅指定远端用户的视频辅流，请调用 {@link INERtcEngineEx#subscribeRemoteSubStreamVideo:forUserID:} 方法。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal）：引擎尚未初始化。
 *      - 30004（kNERtcErrNotSupported ）：纯音频 SDK 不支持该功能。
 *      - 30005（kNERtcErrInvalidState)：尚未加入房间。
 *      - 30009（kNERtcErrInvalidDeviceSourceID）：设备 ID 非法。
 *      - 30105（kNERtcErrUserNotFound）：未找到指定用户。
 *      - 30106（kNERtcErrInvalidUserID）：非法指定用户，比如订阅了本端。
 *      - 30107（kNERtcErrMediaNotStarted）：媒体会话未建立，比如对端未开启视频主流。
 *      - 30108（kNERtcErrSourceNotFound）：媒体源未找到，比如对端未开启视频主流。
 * @endif
 */
 - (int)subscribeRemoteVideo:(BOOL)subscribe forUserID:(uint64_t)userID streamType:(NERtcRemoteVideoStreamType)streamType;

/**
 * @if English
 * Enables video preview.
 * - The method is used to enable the local video preview before you join a room. Before you can call the API, you must call setupLocalVideoCanvas to set up a video canvas.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 开启视频预览。
 * <br>通过本接口可以实现在加入房间前启动本地视频预览，支持预览本地摄像头或外部输入视频。
 * @since V4.6.20
 * @par 使用前提
 * 请在通过 {@link INERtcEngine#setupLocalVideoCanvas:} 接口设置视频画布后调用该方法。
 * @par 调用时机
 * 请在初始化后调用该方法，且该方法仅可当不在房间内时可调用。
 * @par 业务场景
 * 适用于加入房间前检查设备状态是否可用、预览视频效果等场景。
 * @note 
 * - 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
 * - 在加入房间前预览视频效果时设置的美颜、虚拟背景等视频效果在房间内仍然生效；在房间内设置的视频效果在退出房间后预览视频时也可生效。
 * @par 示例代码
 * @code
 * //设置本端视频画布
 * UIView *localUserView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
 * NERtcVideoCanvas *canvas = [[NERtcVideoCanvas alloc] init];
 * canvas.container = localUserView;
 * [[NERtcEngine sharedEngine] setupLocalVideoCanvas:canvas];
 * //开启视频预览
 * [[NERtcEngine sharedEngine] startPreview];
 * @endcode
 * @par 相关接口
 * 该方法仅适用于视频主流，若您希望开启辅流通道的视频预览，请调用 {@link INERtcEngineEx#startPreview:} 方法。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal）：引擎尚未初始化。
 *      - 30004（kNERtcErrNotSupported）：不支持的操作，比如当前使用的是纯音频 SDK，或已经开启预览。
 *      - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎未初始化成功，或尚未设置画布。
 *      - 30027（kNERtcErrDeviceOccupied）：所选设备已被占用，比如已通过主流通道开启了摄像头，无法再通过辅流通道开启摄像头预览。
 *      - 30300（kNERtcErrOSAuthorize）：应用未获取到操作系统的摄像头权限。
 * @endif
 */
- (int)startPreview;

/**
 * @if Chinese
 * 开启视频预览。
 * <br>通过本接口可以实现在加入房间前启动本地视频预览，支持预览本地摄像头或外部输入视频。
 * @since V3.5.0
 * @par 使用前提
 * 请在通过 {@link INERtcEngine#setupLocalVideoCanvas:} 接口设置视频画布后调用该方法。
 * @par 调用时机
 * 请在初始化后调用该方法，且该方法仅可当不在房间内时可调用。
 * @par 业务场景
 * 适用于加入房间前检查设备状态是否可用、预览视频效果等场景。
 * @note 
 * - 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
 * - 在加入房间前预览视频效果时设置的美颜、虚拟背景等视频效果在房间内仍然生效；在房间内设置的视频效果在退出房间后预览视频时也可生效。
 * @par 参数说明 
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>streamType</td>
 *      <td>{@link video.NERtcStreamChannelType}</td>
 *      <td>视频通道类型：<ul><li>kNERtcStreamChannelTypeMainStream：主流。<li>kNERtcStreamChannelTypeSubStream：辅流。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //开启主流视频通道预览
 * NERtcVideoCanvas *canvas = [[NERtcVideoCanvas alloc] init];
 * canvas.container = self.renderView;
 * [NERtcEngine.sharedEngine setupLocalVideoCanvas:canvas];
 * [NERtcEngine.sharedEngine startPreview:kNERtcStreamChannelTypeMainStream];
 * //开启辅流视频通道预览
 * NERtcVideoCanvas *subCanvas = [[NERtcVideoCanvas alloc] init];
 * subCanvas.container = self.subRenderView;
 * [NERtcEngine.sharedEngine setupLocalSubStreamVideoCanvas:subCanvas];
 * [NERtcEngine.sharedEngine startPreview:kNERtcStreamChannelTypeSubStream];
 * @endcode 
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal）：引擎尚未初始化。
 *      - 30004（kNERtcErrNotSupported）：不支持的操作，比如当前使用的是纯音频 SDK，或已经开启预览。
 *      - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎未初始化成功，或尚未设置画布。
 *      - 30027（kNERtcErrDeviceOccupied）：所选设备已被占用，比如已通过主流通道开启了摄像头，无法再通过辅流通道开启摄像头预览。
 *      - 30300（kNERtcErrOSAuthorize）：应用未获取到操作系统的摄像头权限。
 * @endif
 */
- (int)startPreview:(NERtcStreamChannelType)streamType;

/**
 * @if English
 * Stops video preview.
 * @note <br>
 * - You must call the method before you join a room.
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 停止视频预览。
 * <br>通过此接口可以实现在预览本地视频后关闭预览。
 * @since V3.5.0
 * @par 使用前提
 * 建议在通过 {@link INERtcEngineEx#startPreview:} 接口开启视频预览后调用该方法。
 * @par 调用时机
 * 请在初始化后调用该方法，且该方法仅可当不在房间内时可调用。
 * @note 
 * - 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
 * - 该方法只适用于视频主流，若您希望停止辅流通道的视频预览，请调用 {@link INERtcEngineEx#stopPreview:} 方法。
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine] stopPreview]
 * @endcode 
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal）：状态错误，比如引擎尚未初始化。
 *      - 30004（kNERtcErrNotSupported）：不支持的操作，比如当前使用的是纯音频 SDK。
 * @endif
 */
- (int)stopPreview;

/**
 * @if Chinese
 * 停止视频预览。
 * <br>通过本接口可以实现在预览本地视频后关闭预览。
 * @since V4.6.20
 * @par 使用前提
 * 建议在通过 {@link INERtcEngineEx#startPreview:} 接口开启视频预览后调用该方法。
 * @par 调用时机
 * 请在初始化后调用该方法，且该方法仅可当不在房间内时可调用。
 * @note 
 * 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
 * @par 参数说明 
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>streamType</td>
 *      <td>{@link video.NERtcStreamChannelType}</td>
 *      <td>视频通道类型：<ul><li>kNERtcStreamChannelTypeMainStream：主流。<li>kNERtcStreamChannelTypeSubStream：辅流。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //关闭主流视频通道预览
 * [NERtcEngine.sharedEngine stopPreview:kNERtcStreamChannelTypeMainStream];
 * //关闭辅流视频通道预览
 * [NERtcEngine.sharedEngine stopPreview:kNERtcStreamChannelTypeSubStream];
 * @endcode 
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30004（kNERtcErrNotSupported）：不支持的操作，比如当前使用的是纯音频 SDK。
 * @endif
 */
- (int)stopPreview:(NERtcStreamChannelType)streamType;

/** 
 * @if English
 * Sets the local video display mode.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @param mode The video display mode. For more information, see {@link NERtcVideoRenderScaleMode}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置画布中本地视频画面的显示模式。
 * <br>
 * 通过本接口可以实现设置本地视频画面的适应性，即是否裁剪或缩放。
 * @since V3.5.0
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法仅可在加入房间后调用。
 * @note
 * - 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
 * - 该接口只有在调用 {@link INERtcEngine#setupLocalVideoCanvas:} 方法设置本地视图之后才生效。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>mode</td>
 *      <td>{@link NERtcVideoRenderScaleMode}</td>
 *      <td>视频显示模式类型：<ul><li>kNERtcVideoRenderScaleFit（0）:适应视频，视频尺寸等比缩放。优先保证视频内容全部显示。若视频尺寸与显示视窗尺寸不一致，视窗未被填满的区域填充背景色。<li> kNERtcVideoRenderScaleFullFill（1）：视频尺寸非等比缩放。保证视频内容全部显示，且填满视窗。<li>kNERtcVideoRenderScaleCropFill（2）：适应区域，视频尺寸等比缩放。保证所有区域被填满，视频超出部分会被裁剪。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine] setLocalRenderScaleMode:kNERtcVideoRenderScaleFit];
 * @endcode
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30004（kNERtcErrNotSupported）：不支持的操作，比如当前使用的是纯音频 SDK。
 *      - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎尚未初始化。
 * @endif
 */
- (int)setLocalRenderScaleMode:(NERtcVideoRenderScaleMode)mode;

/**
 * @if English
 * Sets the remote video display mode.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @param mode The video display mode. For more information, see {@link NERtcVideoRenderScaleMode}.
 * @param userID The ID of a remote user.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置画布中远端视频画面的显示模式。
 * <br>
 * 通过本接口可以实现设置远端视频画面的适应性，即是否裁剪或缩放。
 * @since V3.5.0
 * @par 使用前提
 * 请先调用 {@link INERtcEngineEx#subscribeRemoteVideo:forUserID:streamType:} 方法订阅指定远端用户的视频流。
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法仅可在加入房间后调用。
 * @note
 * - 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
 * - 该接口只有在调用 {@link INERtcEngine#setupRemoteVideoCanvas:forUserID:} 设置远端用户视图之后才生效。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>mode</td>
 *      <td>{@link NERtcVideoRenderScaleMode}</td>
 *      <td>视频显示模式类型：<ul><li>kNERtcVideoRenderScaleFit（0）:适应视频，视频尺寸等比缩放。优先保证视频内容全部显示。若视频尺寸与显示视窗尺寸不一致，视窗未被填满的区域填充背景色。<li> kNERtcVideoRenderScaleFullFill（1）：视频尺寸非等比缩放。保证视频内容全部显示，且填满视窗。<li>kNERtcVideoRenderScaleCropFill（2）：适应区域，视频尺寸等比缩放。保证所有区域被填满，视频超出部分会被裁剪。</td>
 *  </tr>
  *  <tr>
 *      <td>userID</td>
 *      <td>uint64_t</td>
 *      <td>远端用户 ID。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine] setRemoteRenderScaleMode:kNERtcVideoRenderScaleFit forUserID:userID];
 * @endcode
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30004（kNERtcErrNotSupported）：不支持的操作，比如当前使用的是纯音频 SDK。
 *      - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如尚未加入房间。
 * @endif
 */
- (int)setRemoteRenderScaleMode:(NERtcVideoRenderScaleMode)mode forUserID:(uint64_t)userID;

/**
 * @if English
 * Sets the orientation mode for the local video.
 * <br>This API is used to set the orientation mode of the local video screen on the local and remote devices. You can specify that the local screen adapts to the landscape or portrait mode of the system device, or the landscape or portrait mode of the app UI.
 * @note 
 * - You must call this method before you join a room.
 * - Regardless of which orientation mode you select, the modes of the capture client and the playback client must be the same. The local screen and the remote view of the local screen have the same mode.
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @since V4.3.0
 * @param rotationMode The video orientation mode. For more information, see {@link NERtcVideoRotationMode}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 设置本地视频画面的旋转模式。
 * <br>该接口用于设置本地视频画面在本地和远端设备上的旋转模式，可以指定本地画面和系统设备的横屏/竖屏模式一致、或者和 App UI的横屏/竖屏模式一致。
 * @note 
 * - 请在加入房间之前调用此接口。
 * - 无论在哪种旋转模式下，采集端和播放端的旋转模式均保持一致。即本地看到的本地画面和远端看到的本地画面总是同样横屏模式或同样竖屏模式。
 * - 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @since V4.3.0
 * @param rotationMode 视频旋转模式。详细信息请参考 {@link NERtcVideoRotationMode}。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
 - (int)setVideoRotationMode:(NERtcVideoRotationMode)rotationMode;

/**
 * @if English
 * Stops or resumes publishing the local video stream.
 * <br>If you call the method successfully, the remote client triggers the onNERtcEngineUser:videoMuted: callback.
 * @note
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * - If you call this method to stop publishing the local video stream, the SDK no longer publishes the local video stream.
 * -  You can call the method before or after you join a room.
 * - If you stop publishing the local video stream by calling this method, the setting is reset to the default state that allows the app to publish the local video stream.
 * - The method is different from enableLocalVideo. The enableLocalVideo method turns off local camera devices. The muteLocalVideovideo method does not affect local video capture, or disables cameras, and responds faster.
 * @param muted The option whether to stop publishing the local video stream.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 取消或恢复发布本端视频主流。
 * <br>调用该方法取消发布本地视频主流后，SDK 不再发送本地视频主流。
 * @since V3.5.0
 * @par 使用前提 
 * 一般在通过 {@link INERtcEngine#enableLocalVideo:streamType:} 接口开启本地视频采集并发送后调用该方法。
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
 * @note
 * - 调用该方法取消发布本地视频流时，设备仍然处于工作状态。
 * - 该方法设置内部引擎为启用状态，在 {@link INERtcEngine#leaveChannel} 后设置失效，将恢复至默认，即默认发布本地视频流。
 * - 该方法与 {@link INERtcEngine#enableLocalVideo:streamType:}(NO) 的区别在于，后者会关闭本地摄像头设备，该方法不禁用摄像头，不会影响本地视频流采集且响应速度更快。
 * @par 参数说明 
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>muted</td> 
 *      <td>BOOL</td> 
 *      <td>是否取消发布本地视频流：<ul><li>YES：取消发布本地视频流。<li>NO（默认）：恢复发布本地视频流。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine] muteLocalVideo:YES];
 * @endcode 
 * @par 相关回调
 * 取消发布本地视频主流或辅流后，远端会收到 {@link NERtcEngineDelegateEx#onNERtcEngineUser:videoMuted:streamType:} 回调。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal）：状态错误，比如引擎尚未初始化。
 *      - 30004（kNERtcErrNotSupported）：不支持的操作，比如当前使用的是纯音频 SDK。
 * @endif
 */
 - (int)muteLocalVideo:(BOOL)muted;

/**
 * @if Chinese
 * 取消或恢复发布本地视频。
 * <br>调用该方法取消发布本地视频主流或辅流后，SDK 不再发送本地视频流。
 * @since V4.6.20
 * @par 使用前提 
 * 一般在通过 {@link INERtcEngine#enableLocalVideo:streamType:} 接口开启本地视频采集并发送后调用该方法。
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
 * @note
 * - 调用该方法取消发布本地视频流时，设备仍然处于工作状态。
 * - 若调用该方法取消发布本地视频流，通话结束后会被重置为默认状态，即默认发布本地视频流。
 * - 该方法与 {@link INERtcEngine#enableLocalVideo:streamType:}(NO) 的区别在于，后者会关闭本地摄像头设备，该方法不禁用摄像头，不会影响本地视频流采集且响应速度更快。
 * @par 参数说明 
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>streamType</td>
 *      <td>{@link NERtcStreamChannelType}</td>
 *      <td>视频通道类型：<ul><li>kNERtcStreamChannelTypeMainStream：主流。<li>kNERtcStreamChannelTypeSubStream：辅流。</td>
 *  </tr>
 *  <tr>
 *      <td>muted</td> 
 *      <td>BOOL</td> 
 *      <td>是否取消发布本地视频流：<ul><li>YES：取消发布本地视频流。<li>NO（默认）：恢复发布本地视频流。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //取消发布本地视频主流
 * [[NERtcEngine sharedEngine] muteLocalVideo:YES streamType:kNERtcStreamChannelTypeMainStream];
 * //恢复发布本地视频主流
 * [[NERtcEngine sharedEngine] muteLocalVideo:NO streamType:kNERtcStreamChannelTypeMainStream];
 * //取消发布本地视频辅流
 * [[NERtcEngine sharedEngine] muteLocalVideo:YES streamType:kNERtcStreamChannelTypeSubStream];
 * //恢复发布本地视频辅流
 * [[NERtcEngine sharedEngine] muteLocalVideo:NO streamType:kNERtcStreamChannelTypeSubStream];
 * @endcode 
 * @par 相关回调
 * 取消发布本地视频主流或辅流后，远端会收到 {@link NERtcEngineDelegateEx#onNERtcEngineUser:videoMuted:streamType:} 回调。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30004（kNERtcErrNotSupported）：不支持的操作，比如当前使用的是纯音频 SDK。
 * @endif
 */
 - (int)muteLocalVideo:(BOOL)muted streamType:(NERtcStreamChannelType)streamType;

/**
 * @if English
 * Enables or disables the audio playback route to the speakerphone.
 * <br>The method is used to specify whether to route audio playback to the speakerphone.
 * @note You can call this method before or after you join a room.
 * @param enable The option whether to route the audio playback to the external loudspeaker.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置是否由扬声器播放声音。
 * <br>
 * 通过本接口可以实现设置是否将语音路由到扬声器，即设备外放。
 * @since V3.5.0
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法仅可在加入房间后调用。
 * @note 
 * - 平板设备暂时不支持此接口。
 * - 若设备连接了耳机或蓝牙，则无法开启外放。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>enable</td>
 *      <td>bool</td>
 *      <td>是否将音频路由到扬声器：<ul><li>YES：启用扬声器播放。<li>NO：关闭扬声器播放。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //打开外放
 * [[NERtcEngine sharedEngine] setLoudspeakerMode:YES];
 * //关闭外放 
 * [[NERtcEngine sharedEngine] setLoudspeakerMode:NO];
 * @endcode
 * @par 相关接口
 * {@link INERtcEngineEx#getLoudspeakerMode:}：检查扬声器的启用状态。
 * @par 相关回调
 * {@link NERtcEngineDelegateEx#onNERtcEngineAudioDeviceStateChangeWithDeviceID:deviceType:deviceState:}：音频路由改变回调，可以通过此回调判断当前音频播放设备。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30004（kNERtcErrNotSupported）：当前状态不支持的操作，比如引擎未初始化成功。
 * @endif
 */
- (int)setLoudspeakerMode:(bool)enable;

/**
 * @if English
 * Checks whether the speakerphone is enabled.
 * @note You can call this method before or after you join a room.
 * @param enabled The option whether to enable the speakerphone mode.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 检查扬声器状态启用状态。
 * @note 该方法可在加入房间前后调用。
 * @param enabled 是否正在使用扬声器模式。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)getLoudspeakerMode:(bool *)enabled;


/**
 * @if English
 * Starts recording an audio dump file.
 * <br>Audio dump files can be used to analyze audio issues.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 开始记录音频 dump。
 * <br>音频 dump 可用于分析音频问题。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)startAudioDump;

/**
 * @if English
 * Starts recording an audio dump file.
 * @note You can call the method can be called before or after joining a room.
 * @param type audio dump type. For more information, see {@link NERtcAudioDumpType}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 开始进行音频 dump。
 * @note 该方法可在加入房间前后调用。
 * @param type 音频dump类型。详细信息请参考 {@link NERtcAudioDumpType}。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)startAudioDumpWithType:(NERtcAudioDumpType)type;

/**
 * @if English
 * Stops recording an audio dump file.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 结束记录音频 dump。
 * @since V3.5.0
 * @par 使用前提
 * 请先调用 {@link INERtcEngineEx#startAudioDumpWithType:} 方法开始记录音频 dump。
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法在加入房间前后均可调用。
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine] stopAudioDump];
 * @endcode
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal）：状态错误，比如引擎尚未初始化。
 * @endif
 */
- (int)stopAudioDump;

/**
 * @if English
 * Sets a remote audio stream to high priority.
 * If a remote audio stream is set to high priority during automatic stream subscription, users can hear the audio stream with high priority.
 * @note
 * - You must set the API during calling with automatic subscription enabled (default)。
 * - The API can only set one audio stream to high priority. Subsequent settings will override the previous ones.
 * - If a call ends, the priority setting will be reset.
 * @since V4.6.0
 * @param enable enables or disables the high priority of a remote audio stream
 * - true：sets the high priority of a remote audio stream.
 * - false：Does not set the high priority of a remote audio stream.
 * @param userID    User ID
 * @param streamType The type of subscribed audio stream. The default type is kNERtcAudioStreamMain.
 * @return
 * - 0:success
 * - Others: failure
 * @endif
 * @if Chinese
 * 设置远端用户音频流的高优先级。
 * 支持在音频自动订阅的情况下，设置某一个远端用户的音频为最高优先级，可以优先听到该用户的音频。
 * @note
 * - 该接口需要通话中设置，并需要自动订阅打开（默认打开）。
 * - 该接口只能设置一个用户的优先级，后设置的会覆盖之前的设置。
 * - 该接口通话结束后，优先级设置重置。
 * @since V4.6.0
 * @param enable 是否设置音频订阅优先级。
 * - true：设置音频订阅优先级。
 * - false：取消设置音频订阅优先级。
 * @param userID 用户 ID
 * @param streamType 订阅音频流的类型。默认为 kNERtcAudioStreamMain。
 * @return 操作返回值，成功则返回 0。
 * @endif
 */
- (int)setRemoteHighPriorityAudioStream:(BOOL)enable forUserID:(uint64_t)userID streamType:(NERtcAudioStreamType)streamType;

/**
 * @if English
 * @endif
 * @if Chinese
 * 指定前置/后置摄像头。
 * <br>该方法需要在相机启动后调用，例如调用 startPreview 或 joinChannel 后。
 * @note 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @since V4.6.10
 * @param position 摄像头类型。详细信息请参考 {@link NERtcCameraPosition}。该参数为必填参数，若未赋值，SDK 会报错。
 * @return 
 * - 0：方法调用成功。
 * - 其他：方法调用失败。
 * @endif
 */
- (int)switchCameraWithPosition:(NERtcCameraPosition)position;


/**
 * @if Chinese 
 * 更新权限密钥。
 * - 通过本接口可以实现当用户权限被变更，或者收到权限密钥即将过期的回调 {@link NERtcEngineDelegateEx#onNERtcEnginePermissionKeyWillExpire} 时，更新权限密钥。
 * @since V4.6.29
 * @par 使用前提
 * 请确保已开通高级 Token 鉴权功能，具体请联系网易云信商务经理。
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
 * @par 业务场景
 * 适用于变更指定用户加入、创建房间或上下麦时发布流相关权限的场景。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>key</td>
 *      <td>NSString *</td>
 *      <td>新的权限密钥。</td>
 *  </tr>
 * </table>     
 * @par 示例代码
 * @code
 * //getPermToken为获取高级密钥方法，由您自行实现，具体请参考官方文档的高级 Token 鉴权章节。</a>
 * [self getToken];
 * [[NERtcEngine sharedEngine] updatePermissionKey:token];
 * @endcode
 * @par 相关回调
 * 调用此接口成功更新权限密钥后会触发 {@link NERtcEngineDelegateEx#onNERtcEngineUpdatePermissionKey:error:timeout:} 回调。
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal)：通用错误，比如引擎尚未初始化。
 * @endif
 */
- (int)updatePermissionKey:(NSString *)key;

/**
 * @if Chinese
 * 查询当前设备是否支持 SDK 中的某项功能
 *
 * @since v5.5.21
 *
 * @par 业务场景
 * 以虚拟背景为例，在用户跳转 UI 至直播之前，可调用此接口来判断当前设备是否支持虚拟背景功能，如果不支持，则隐藏相关的按钮。
 *
 * @par 调用时机
 * 请在引擎初始化之后调用此接口。
 *
 * @par 参数说明
 *
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>featureType</td>
 *      <td>NERtcFeatureType</td>
 *      <td>RTC 功能类型</td>
 *  </tr>
 * </table>
 *
 * @par 示例代码
 *
 * @code
 * NERtcFeatureType featureType = kNERtcFeatureTypeVirtualBackground;
 * BOOL supported = [[NERtcEngine sharedEngine] isFeatureSupportedWithType:featureType];
 * if (supported) {
 *     // 该设备支持
 * } else {
 *     // 该设备不支持
 * }
 * @endcode
 *
 * @par 相关回调
 * 无
 *
 * @return
 * YES: 表示支持
 * NO: 表示不支持
 *
 * @endif
 */
- (BOOL)isFeatureSupportedWithType:(NERtcFeatureType)featureType;

#pragma mark - External Video Input

/**
 * @if English
 * Enables or disables the external video input source.
 * - The method enables the internal engine. The setting remains unchanged after you call the leaveChannel method. If you want to disable the setting, you must disable the setting before the next call starts.
 * - If you want to use external video sources, you must call this method before you call startScreenCapture, enableLocalVideo, and startVideoPreview.
 * - By default, the external video source uses the substream for screen sharing and uses the mainstream in scenarios other than screen sharing. The external video source cannot use the same stream as the camera.
 * - If the mainstream is used and enabled for the external video source, do not change the setting. If the substream channel is used and enabled, do not change the setting.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @param enable The option whether to use the external video source.
 * - true: uses the external video source.
 * - false: does not use the external video source. This is the default value.
 * @param isScreen The option whether the external video source is used for screen sharing.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 开启或关闭外部视频源数据输入。
 * <br>
 * 通过本接口可以实现创建自定义的外部视频源，并通过主流通道传输该外部视频源的数据。
 * @since V3.5.0
 * @par 使用前提
 * 请在通过 {@link INERtcEngine#enableLocalVideo:streamType:} 接口关闭本地视频设备采集之后调用该方法。
 * @par 调用时机  
 * 请在通过 {@link INERtcEngineEx#startPreview:} 接口开启本地视频预览、通过 {@link INERtcEngine#enableLocalVideo:streamType:} 接口开启本地视频采集或通过 {@link INERtcEngineEx#startScreenCapture:} 接口开启屏幕共享之前调用该方法，且必须使用同一种视频通道，即同为主流。
 * @par 业务场景
 * 实现由应用层而非 SDK 采集视频数据，适用于对输入的视频数据做水印、美颜、马赛克等前处理的场景。
 * @note 
 * - 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
 * - 该方法设置内部引擎为启用状态，在 {@link INERtcEngine#leaveChannel} 后仍然有效；如果需要关闭该功能，需要在下次通话前调用此接口关闭外部视频数据输入功能。
 * - 屏幕共享时，外部输入视频源默认使用辅流通道；非屏幕共享时，外部输入视频源使用主流通道。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>enable</td>
 *      <td>BOOL</td>
 *      <td>是否开启外部视频输入：<ul><li>YES：开启外部视频输入。<li>NO：关闭外部视频输入。</td>
 *  </tr>
 *  <tr>
 *      <td>isScreen</td>
 *      <td>BOOL</td>
 *      <td>使用外部视频源时，外部视频源是否为屏幕共享数据：<ul><li>YES：是屏幕共享数据。<li>NO：不是屏幕共享数据。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * BOOL useExternalVideoSource = YES;
 * BOOL isScreen = YES;
 * [[NERtcEngine sharedEngine] setExternalVideoSource:useExternalVideoSource isScreen:isScreen];
 * @endcode
 * @par 相关接口
 * - 该方法调用成功后可以调用 {@link INERtcEngineEx#pushExternalAudioFrame:} 方法推送视频数据帧。
 * - 若您希望通过辅流通道输入外部输入视频源，可以调用 {@link INERtcEngineEx#setExternalVideoSource:streamType:} 方法。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal）：不支持的操作，比如已开启了同视频通道的本地视频采集。
 *      - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎未初始化成功。
 * @endif
 */
- (int)setExternalVideoSource:(BOOL)enable isScreen:(BOOL)isScreen;

/**
 * @if Chinese
 * 开启或关闭外部视频源数据输入。
 * <br>通过本接口可以实现创建自定义的外部视频源，您可以选择通过主流或辅流通道传输该外部视频源的数据，但暂不支持同时开启。
 * @since V4.6.20
 * @par 使用前提
 * 请在通过 {@link INERtcEngineEx#startPreview:} 接口开启本地视频预览、通过 {@link INERtcEngine#enableLocalVideo:streamType:} 接口开启本地视频采集或通过 {@link INERtcEngineEx#startScreenCapture:} 接口开启屏幕共享之前调用该方法，且必须使用同一种视频通道，即同为主流或辅流。
 * @par 调用时机
 * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
 * @par 业务场景
 * 实现由应用层而非 SDK 采集视频数据，适用于对输入的视频数据做水印、美颜、马赛克等前处理的场景。
 * @note
 * - 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
 * - 当外部视频源输入作为主流或辅流时，内部引擎为启用状态，在切换房间（switchChannelWithToken）、主动离开房间（leaveChannel）、触发断网重连失败回调（onNERtcChannelDidDisconnectWithReason）或触发重新加入房间回调（onNERtcChannelRejoinChannel）后仍然有效。如果需要关闭该功能，请在下次通话前调用接口关闭该功能。
 * - 请务必保证视频主流和辅流输入通道各最多只能有一种视频输入源，其中屏幕共享只能通过辅流通道开启，因此：
 *      - 若您开启了辅流形式的屏幕共享，请使用主流通道输入外部视频源数据，即设置 streamType 参数为 kNERtcStreamChannelTypeMainStream。
 *      - 若您已调用 {@link INERtcEngine#enableLocalVideo:streamType:} 方法开启本地主流视频采集，请勿再调用此接口创建主流形式的外部视频源输入，辅流通道同理。
 * @par 参数说明 
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>streamType</td>
 *      <td>{@link NERtcStreamChannelType}</td>
 *      <td>视频通道类型：<ul><li>kNERtcStreamChannelTypeMainStream：主流。<li>kNERtcStreamChannelTypeSubStream：辅流。</td>
 *  </tr>
 *  <tr>
 *      <td>enable</td>
 *      <td>BOOL</td>
 *      <td>是否使用外部视频源：<ul><li>YES：开启。<li>NO（默认）：关闭。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //通过主流通道输入外部视频源数据
 * [NERtcEngine.sharedEngine setExternalVideoSource:YES streamType:kNERtcStreamChannelTypeMainStream];
 * [NERtcEngine.sharedEngine.enableLocalVideo:YES streamType:kNERtcStreamChannelTypeMainStream];
 * [NERtcEngine.sharedEngine pushExternalVideoFrame:frame];
 *
 * //通过辅流通道输入外部视频源数据
 * [[NERtcEngine sharedEngine] setExternalVideoSource:YES streamType:kNERtcStreamChannelTypeSubStream];
 * NERtcVideoSubStreamEncodeConfiguration *config = [[NERtcVideoSubStreamEncodeConfiguration alloc] init];
 * config.maxProfile = kNERtcVideoProfileHD720P;
 * config.frameRate = kNERtcVideoFrameRateFps15;
 * [[NERtcEngine sharedEngine] startScreenCapture:config];
 * //屏幕共享视频帧回调，此方法来自屏幕共享的framework NERtcReplayKit.framework 
 * - (void)onReceiveVideoFrame:(NEScreenShareVideoFrame *)videoFrame
 * {
 * NERtcVideoFrame *frame = [[NERtcVideoFrame alloc] init];
 * frame.format = kNERtcVideoFormatI420;
 * frame.width = videoFrame.width;
 * frame.height = videoFrame.height;
 * frame.buffer = (void *)[videoFrame.videoData bytes];
 * frame.timestamp = videoFrame.timeStamp;
 * frame.rotation = rotation;
 * NERtcEngine.sharedEngine pushExternalVideoFrame:frame];
 * }
 * @endcode 
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal）：通用错误，比如已通过主流通道开启本地视频采集，又创建了主流通道的外部视频源。
 *      - 30004（kNERtcErrNotSupported）：不支持的操作，比如当前使用的是纯音频 SDK。
 * @endif
 */
- (int)setExternalVideoSource:(BOOL)enable streamType:(NERtcStreamChannelType)streamType;

/**
 * @if English
 * Publishes the external video frames.
 * <br>The method actively publishes the data of video frames that are encapsulated with the NERtcVideoFrame class to the SDK.
 * @note
 * - The method enables the internal engine. The setting remains unchanged after you call the leaveChannel method.
 * - Make sure that you have already called setExternalVideoSource with a value of YES before you call this method. Otherwise, an error message is repeatedly prompted if you call the method.
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @param frame The information about video frame data. For more information, see {@link NERtcVideoFrame}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 推送外部视频帧。
 * <br>该方法主动将视频帧数据用 NERtcVideoFrame 类封装后传递给 SDK。
 * @note
 * - 该方法设置内部引擎为启用状态，在 leaveChannel 后不再有效。
 * - 请确保在您调用本方法前已调用 setExternalVideoSource，并将参数设为 YES，否则调用本方法后会一直报错。
 * - 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @param frame 外部视频帧的数据信息。详细信息请参考 {@link NERtcVideoFrame}。
 * @return 
 * - 0：方法调用成功；
 * - 其他：方法调用失败。
 * @endif
 */
- (int)pushExternalVideoFrame:(NERtcVideoFrame*)frame;

/**
 * @if Chinese
 * 推送外部视频帧。
 * <br>该方法主动将视频帧数据用 NERtcVideoFrame 类封装后传递给 SDK。
 * @note
 * - 该方法设置内部引擎为启用状态，在 leaveChannel 后不再有效。
 * - 请确保在您调用本方法前已调用 setExternalVideoSource，并将参数设为 YES，否则调用本方法后会一直报错。
 * - 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @param frame 外部视频帧的数据信息。详细信息请参考 {@link NERtcVideoFrame}。
 * @param streamType 视频流通道类型，默认为主流kNERtcStreamChannelTypeMainStream。
 * @return
 * - 0：方法调用成功；
 * - 其他：方法调用失败。
 * @endif
 */
- (int)pushExternalVideoFrame:(NERtcVideoFrame*)frame streamType:(NERtcStreamChannelType)streamType;

#pragma mark - Sub Stream

/**
 * @if English
 * Sets the local substream canvas.
 * <br>This method is used to set the display information about the local screen sharing with the substream video. The app associates with the video view of local substream by calling this method. During application development, in most cases, before joining a room, you must first call this method to set the local video view after the SDK is initialized.
 * @note
 * - If the app uses external rendering, we recommend that you set the video view before you join the room.
 * - Before you join a room, you must call the method after the SDK is initialized.
 * - A canvas is configured for only one user.
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @param canvas The video canvas. For more information, see {@link NERtcVideoCanvas}. To delete the canvas setting, set the value to nil.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置本端用户的视频辅流画布。
 * <br>通过此接口可以实现设置本端用户的辅流显示视图。
 * @since V3.9.0
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法建议在加入房间前调用。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>canvas</td>
 *      <td>NERtcVideoCanvas *</td>
 *      <td>视频画布。详细信息请参考 {@link NERtcVideoCanvas}。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * UIView *localSubStreamView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
 * NERtcVideoCanvas *canvas = [[NERtcVideoCanvas alloc] init];
 * canvas.container = localSubStreamView;
 * canvas.renderMode = kNERtcVideoRenderScaleFit;
 * canvas.mirrorMode = kNERtcVideoMirrorModeAuto;
 * [[NERtcEngine sharedEngine] setupLocalSubStreamVideoCanvas:canvas];
 * @endcode
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal）：状态错误，比如引擎尚未初始化。
 *      - 30004（kNERtcErrNotSupported）：纯音频 SDK 不支持该功能。
 * @endif
 */
- (int)setupLocalSubStreamVideoCanvas:(nullable NERtcVideoCanvas *)canvas;

/**
 * @if English
 * Enables screen sharing. The content of the screen sharing is published through the substream.
 * <br>You can call the method only after you join a room.
 * <br>If you join a room and call this method to enable the substream, the onUserSubStreamVideoStart callback is triggered on the remote client.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @param config The encoding configuration of the local substream. For more information, see {@link NERtcVideoSubStreamEncodeConfiguration}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 开启屏幕共享。
 * <br>
 * 通过此接口开启屏幕共享后，屏幕共享内容以视频辅流的形式发送。
 * @since V3.5.0
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>config</td>
 *      <td>NERtcVideoSubStreamEncodeConfiguration *</td>
 *      <td>本地辅流发送配置，详细信息请参考 {@link NERtcVideoSubStreamEncodeConfiguration}。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * NERtcVideoSubStreamEncodeConfiguration *config = [[NERtcVideoSubStreamEncodeConfiguration alloc] init];
 * config.maxProfile = 视频编码的分辨率;
 * config.minBitrate = 最小编码码率
 * config.minFrameRate = 最小编码帧率
 * config.frameRate = 帧率
 * config.bitrate = 最小编码码率
 * config.contentPrefer = 屏幕共享功能的编码策略倾向;
 * [[NERtcEngine sharedEngine] startScreenCapture:config];
 * @endcode
 * @par 相关回调
 * 成功开启屏幕共享辅流后，远端会触发 {@link NERtcEngineDelegate#onNERtcEngineUserSubStreamDidStartWithUserID:subStreamProfile:} 回调。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30005（kNERtcErrInvalidState）：状态错误，比如引擎尚未初始化。
 *      - 50001（kNERtcRuntimeErrVDMNotScreenUseSubStream）：当前使用的非屏幕共享形式的辅流。
 * @endif
 */
- (int)startScreenCapture:(NERtcVideoSubStreamEncodeConfiguration *)config;

/**
 * @if English
 * Disables screen sharing with the substream transmission.
 * <br>If you use the method to disable the substream after you join a room, the onNERtcEngineUserSubStreamDidStop callback is triggered on the remote client.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 关闭屏幕共享。
 * <br>
 * 通过此接口可以实现关闭屏幕共享辅流。
 * @since V3.5.0
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine] stopScreenCapture];
 * @endcode
 * @par 相关回调
 * 成功调用此方法后，远端会触发 {@link NERtcEngineDelegate#onNERtcEngineUserSubStreamDidStop:} 回调。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎尚未初始化。
 *      - 50001（kNERtcRuntimeErrVDMNotScreenUseSubStream）：当前使用的非屏幕共享形式的辅流。
 * @endif
 */
- (int)stopScreenCapture;

/**
 * @if English
 * Sets the display mode of the local substream video for screen sharing.
 * <br>Use this method if you want to enable screen sharing through the local substream. Apps can call this method multiple times to change the display mode.
 * @note
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * - Before you can call this method, you must set up the canvas for the local substream by calling setupLocalSubStreamVideoCanvas.
 * @param mode The video display mode. For more information, see {@link NERtcVideoRenderScaleMode}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置画布中本地屏幕共享辅流视频画面的显示模式。
 * <br>
 * 通过本接口可以实现设置本地发布的屏幕共享视频画面的适应性，即是否裁剪或缩放。
 * @since V3.9.0
 * @par 使用前提
 * 请先调用 {@link INERtcEngineEx#setupLocalSubStreamVideoCanvas:} 方法设置本地辅流画布。
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法仅可在加入房间后调用。
 * @note
 * 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>mode</td>
 *      <td>{@link NERtcVideoRenderScaleMode}</td>
 *      <td>视频显示模式类型：<ul><li>kNERtcVideoRenderScaleFit（0）:适应视频，视频尺寸等比缩放。优先保证视频内容全部显示。若视频尺寸与显示视窗尺寸不一致，视窗未被填满的区域填充背景色。<li> kNERtcVideoRenderScaleFullFill（1）：视频尺寸非等比缩放。保证视频内容全部显示，且填满视窗。<li>kNERtcVideoRenderScaleCropFill（2）：适应区域，视频尺寸等比缩放。保证所有区域被填满，视频超出部分会被裁剪。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine] setLocalRenderSubStreamScaleMode:kNERtcVideoRenderScaleFit];
 * @endcode
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30004（kNERtcErrNotSupported）：不支持的操作，比如当前使用的是纯音频 SDK。
 *      - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎尚未初始化。
 * @endif
 */
- (int)setLocalRenderSubStreamScaleMode:(NERtcVideoRenderScaleMode)mode;

/**
 * @if English
 * Sets a remote substream canvas.
 * <br>The method associates a remote user with a substream view. You can assign a specified userID to use a corresponding canvas.
 * @note 
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * - If the app uses external rendering, we recommend that you set the canvas after you receive the return of onUserJoined.
 * - If the app does not retrieve the ID of a remote user, you can call the method after the remote user joins the room. You can retrieve the uid of the remote user from the return of onNERtcEngineUserDidJoinWithUserID. You can use this method to set the substream video canvas.
 * - If the remote user leaves the room, the SDK disassociates the remote user from the canvas. The setting automatically becomes invalid.
 * @param userID The ID of a remote user.
 * @param canvas The video canvas. For more information, see {@link NERtcVideoCanvas}. To delete the canvas setting, set the value to nil.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置远端用户的视频辅流画布。
 * <br>通过此接口可以实现绑定远端用户和对应辅流的显示视图，即指定某个 uid 使用对应的画布显示。
 * @since V3.9.0
 * @par 使用前提
 * 建议在收到远端用户加入房间的 {@link NERtcEngineDelegate#onNERtcEngineUserDidJoinWithUserID:userName:joinExtraInfo:} 回调后，再调用此接口通过回调返回的 uid 设置对应视图。
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法在加入房间前后均可调用。
 * @note 
 * - 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * - 退出房间后，SDK 会清除远端用户和画布的的绑定关系，该设置自动失效。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>canvas</td>
 *      <td>NERtcVideoCanvas *</td>
 *      <td>视频画布。详细信息请参考 {@link NERtcVideoCanvas}。</td>
 *  </tr>
 *  <tr>
 *      <td>userID</td>
 *      <td>uint64_t</td>
 *      <td>远端用户 ID。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * - (void)onNERtcEngineUserDidJoinWithUserID:(uint64_t)userID userName:(NSString *)userName {
 *     UIView *remoteUserView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
 *     NERtcVideoCanvas *canvas = [[NERtcVideoCanvas alloc] init];
 *     canvas.container = remoteUserView;
 *     canvas.renderMode = kNERtcVideoRenderScaleFit;
 *     canvas.mirrorMode = kNERtcVideoMirrorModeAuto;
 *     [[NERtcEngine sharedEngine] setupRemoteSubStreamVideoCanvas:canvas forUserID:userID];
 * }
 * @endcode
 * @par 相关接口
 * 可以调用 {@link INERtcEngineEx#setRemoteRenderScaleMode:forUserID:} 方法在通话过程中更新远端用户视图的渲染模式。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal）：状态错误，比如引擎尚未初始化。
 *      - 30004（kNERtcErrNotSupported）：不支持的操作，比如纯音频 SDK 不支持该功能。
 *      - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如尚未加入房间。
 * @endif
 */
- (int)setupRemoteSubStreamVideoCanvas:(nullable NERtcVideoCanvas *)canvas forUserID:(uint64_t)userID;

/**
 * @if English
 * Subscribes to or unsubscribes from remote video substream for screen sharing. You can receive the video substream data only after you subscribe to the video substream.
 * @note
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * - You can call the method only after you join a room.
 * @param subscribe The option whether to subscribe to remote video substream for screen sharing.
 * @param userID The ID of a remote user.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 订阅或取消订阅远端用户的视频辅流。
 * @since V3.9.0
 * @par 使用前提
 * - 请先调用 {@link INERtcEngineEx#setupRemoteSubStreamVideoCanvas:forUserID:}  设置远端用户的视频辅流画布。
 * - 建议在收到远端用户发布视频辅流的回调通知 {@link NERtcEngineDelegate#onNERtcEngineUserSubStreamDidStartWithUserID:subStreamProfile:}  后调用此接口。
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
 * @note 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>userID</td>
 *      <td>uint64_t</td>
 *      <td>远端用户 ID。</td>
 *  </tr>
 *  <tr>
 *      <td>subsribe</td>
 *      <td>BOOL</td>
 *      <td>是否订阅远端的视频辅流：<ul><li>YES：订阅远端视频辅流。<li>NO：取消订阅远端视频辅流。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine] subscribeRemoteSubStreamVideo:YES forUserID:userID];
 * @endcode
 * @par 相关回调
 * - {@link NERtcEngineDelegate#onNERtcEngineUserSubStreamDidStartWithUserID:subStreamProfile:}：远端用户发布视频辅流的回调。
 * - {@link NERtcEngineDelegate#onNERtcEngineUserSubStreamDidStop:}：远端用户停止发布视频辅流的回调。
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal）：状态错误，比如引擎尚未初始化。
 *      - 30004（kNERtcErrNotSupported）：不支持的操作。
 *      - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎尚未初始化。
 *      - 30105（kNERtcErrUserNotFound）：未找到该远端用户，可能对方还未加入房间。
 * @endif
 */
- (int)subscribeRemoteSubStreamVideo:(BOOL)subscribe forUserID:(uint64_t)userID;

/**
 * @if English
 * Sets the display mode of to remote substream video for screen sharing.
 * @note
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * - Before you call this API, you must subscribe to the remote video substream for screen sharing by using subscribeRemoteSubStreamVideo.
 * @param mode The video display mode. For more information, see {@link NERtcVideoRenderScaleMode}.
 * @param userID The ID of a remote user.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置画布中远端屏幕共享视频画面的显示模式。
 * <br>
 * 通过本接口可以实现设置远端发布的屏幕共享视频画面的适应性，即是否裁剪或缩放。
 * @since V3.5.0
 * @par 使用前提
 * 请先调用 {@link INERtcEngineEx#subscribeRemoteSubStreamAudio:forUserID:} 方法订阅指定远端用户的屏幕共享流。
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法仅可在加入房间后调用。
 * @note
 * 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>mode</td>
 *      <td>{@link NERtcVideoRenderScaleMode}</td>
 *      <td>视频显示模式类型：<ul><li>kNERtcVideoRenderScaleFit（0）:适应视频，视频尺寸等比缩放。优先保证视频内容全部显示。若视频尺寸与显示视窗尺寸不一致，视窗未被填满的区域填充背景色。<li> kNERtcVideoRenderScaleFullFill（1）：视频尺寸非等比缩放。保证视频内容全部显示，且填满视窗。<li>kNERtcVideoRenderScaleCropFill（2）：适应区域，视频尺寸等比缩放。保证所有区域被填满，视频超出部分会被裁剪。</td>
 *  </tr>
  *  <tr>
 *      <td>userID</td>
 *      <td>uint64_t</td>
 *      <td>远端用户 ID。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine] setRemoteRenderSubStreamVideoScaleMode:kNERtcVideoRenderScaleFit forUserID:userID];
 * @endcode
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30004（kNERtcErrNotSupported）：不支持的操作，比如当前使用的是纯音频 SDK。
 *      - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如尚未加入房间。
 * @endif
 */
- (int)setRemoteRenderSubStreamVideoScaleMode:(NERtcVideoRenderScaleMode)mode forUserID:(uint64_t)userID;

#pragma mark - Audio Session

/**
 * @if English
 * Sets permissions of the SDK over Audio Session.
 * <br>This method is only applicable to the iOS platform.
 * <br>This method controls the permissions of the SDK over Audio Session. By default, the SDK and the app have control over the Audio Session. However, in some cases, the app wants to restrict the SDK's permissions over Audio Session and uses other applications or third-party components to control Audio Session. The app can adjust the permissions of the SDK by calling this method.
 * <br>You can call this method only before you join the room.
 * @note If you call this method to restrict the SDK's permissions over Audio Session, the SDK cannot set Audio Session. You need to manage Audio Session or use a third-party component to operate Audio Session.
 * @param restriction The restriction applied to the SDK for Audio Session. For more information, see {@link NERtcAudioSessionOperationRestriction}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 设置 SDK 对 Audio Session 的控制权限。
 * <br>该方法仅适用于 iOS 平台。
 * <br>该方法限制  SDK 对 Audio Session 的操作权限。在默认情况下，SDK 和 App 对 Audio Session 都有控制权，但某些场景下，App 会希望限制  SDK 对 Audio Session 的控制权限，而使用其他应用或第三方组件对 Audio Session 进行操控。调用该方法可以实现该功能。
 * <br>该接口只能在入会之前调用。
 * @note 一旦调用该方法限制了 SDK 对 Audio Session 的控制权限， SDK 将无法对 Audio Session 进行相关设置，而需要用户自己或第三方组件进行维护。
 * @param restriction SDK 对 Audio Session 的控制权限。详细信息请参考 {@link NERtcAudioSessionOperationRestriction}。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)setAudioSessionOperationRestriction:(NERtcAudioSessionOperationRestriction)restriction;

#pragma mark - Audio Device Manager

/**
 * @if English
 * Mutes or unmutes the audio playback device.
 * @param muted The option whether to mute the playback device. By default, the setting is unmuted.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置是否静音音频播放设备。
 * @since V3.5.0
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法仅可在加入房间后调用。
 * @note
 * 此接口仅静音播放的音频数据，不影响播放设备的运行。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>muted</td>
 *      <td>bool</td>
 *      <td>是否静音音频播放设备：<ul><li>YES：静音音频播放设备。<li>NO：取消静音音频播放设备。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //设置播放设备静音
 * [[NERtcEngine sharedEngine] setPlayoutDeviceMute:YES];
 * //设置播放设备取消静音
 * [[NERtcEngine sharedEngine] setPlayoutDeviceMute:NO];
 * @endcode
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *         - 30001（kNERtcErrFatal）：音频模块尚未初始化。
 *         - 30005（kNERtcErrInvalidState ）：当前状态不支持的操作，比如引擎尚未初始化。
 * @endif
 */
- (int)setPlayoutDeviceMute:(bool)muted;


/**
 * @if English
 * Gets the mute status of the audio playback device.
 * @param muted The option whether the device is muted.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 获取音频播放设备的静音状态。
 * @param muted 是否静音。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)getPlayoutDeviceMute:(bool *)muted;


/**
 * @if English
 * Mutes or unmutes the audio capture device.
 * @param muted The option whether to mute the audio capture device. The default setting is unmuted.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置是否静音音频采集设备。
 * @since V3.5.0
 * @par 调用时机
 * 请在初始化后调用该方法，且该方法仅可在加入房间后调用。
 * @par 业务场景
 * 适用于麦克风采集和伴音同时开启时，只发送伴音音频的场景。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>muted</td>
 *      <td>bool</td>
 *      <td>是否静音音频采集设备：<ul><li>YES：静音音频采集设备。<li>NO：取消静音音频采集设备。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //设置采集设备静音
 * [[NERtcEngine sharedEngine] setRecordDeviceMute:YES];
 * //设置采集设备取消静音
 * [[NERtcEngine sharedEngine] setRecordDeviceMute:NO];
 * @endcode
 * @par 相关接口
 * - {@link INERtcEngine#enableLocalAudio:}：开启或关闭本地音频采集和发送
 * - {@link INERtcEngine#enableMediaPub:withMediaType:}：开启或关闭本地媒体流（主流）的发送；适用于单独开启麦克风但不发送音频的场景，比如会议场景、大房间。
 * - {@link INERtcEngineEx#muteLocalAudio:}：开启或关闭本地音频主流的发送；适用于需要频繁静音\取消静音操作的场景。
 * - {@link INERtcEngineEx#adjustRecordingSignalVolume:}：调节采集信号音量；适用于需要精确调整本地音频采集（包括外部输入）音量的场景，比如 KTV、语聊房。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal）：音频模块尚未初始化。
 *      - 30005（kNERtcErrInvalidState)：状态错误，比如引擎尚未初始化。
 * @endif
 */
- (int)setRecordDeviceMute:(bool)muted;


/**
 * @if English
 * Checks whether the audio capture device is muted.
 * @param muted The option whether the device is muted.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 查询当前音频采集设备是否静音。
 * @param muted 是否静音。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)getRecordDeviceMute:(bool *)muted;


#pragma mark - Camera & Torch Settings

/**
 * @if English
 * Checks whether the camera zooming feature is supported.
 * <br>Make sure that you call this method after the camera starts. For example, you can call this method after you call startPreview or joinChannel.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @return YES: The camera zooming feature is supported. NO: The camera zooming feature is not supported.
 * @endif
 * @if Chinese 
 * 检测设备当前使用的摄像头是否支持缩放功能。
 * <br>该方法需要在相机启动后调用，例如调用 startPreview 或 joinChannel 后。
 * @note 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @return YES 表示支持，NO 表示支持。
 * @endif
 */
- (BOOL)isCameraZoomSupported;

/**
 * @if English
 * Checks whether the camera flash feature is supported.
 * @note
 * - In most cases, the app opens the front camera by default. If the front camera does not support the flash feature and you call the method, a value of NO is returned. If you want to check whether the rear camera supports the flash feature, before you call this method, you must first call switchCamera to switch the camera.
 * - Make sure that you call this method after the camera starts. For example, you can call this method after you call startPreview or joinChannel.
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @return YES: The camera flash feature is supported. NO: The camera flash feature is not supported.
 * @endif
 * @if Chinese 
 * 检测设备是否支持闪光灯常亮。
 * @note
 * - 一般情况下，App 默认开启前置摄像头，因此如果设备前置摄像头不支持闪光灯，直接使用该方法会返回 NO。如果需要检查后置摄像头是否支持闪光灯，需要先使用switchCamera切换摄像头，再使用该方法。
 * - 该方法需要在相机启动后调用，例如调用 startPreview 或 joinChannel 后。
 * - 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @return YES 表示支持，NO 表示不支持。
 * @endif
 */
- (BOOL)isCameraTorchSupported;

/**
 * @if English
 * Checks whether the camera manual focus feature is supported.
 * @note
 * - Make sure that you call this method after the camera starts. For example, you can call this method after you call startPreview or joinChannel.
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @return YES: The camera manual focus feature is supported. NO: The camera manual focus feature is not supported.
 * @endif
 * @if Chinese 
 * 检测设备是否支持手动对焦功能。
 * @note
 * - 该方法需要在相机启动后调用，例如调用 startPreview 或 joinChannel 后。
 * - 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @return YES 表示支持，NO 表示不支持。
 * @endif
 */
- (BOOL)isCameraFocusSupported;

/**
 * @if English
 * Checks whether the camera exposure feature is supported.
 * @note
 * - Make sure that you call this method after the camera starts. For example, you can call this method after you call startPreview or joinChannel.
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @return YES: The camera exposure feature is supported. NO: The camera exposure feature is not supported.
 * @endif
 * @if Chinese 
 * 检测设备是否支持手动曝光功能。
 * @note
 * - 该方法需要在相机启动后调用，例如调用 startPreview 或 joinChannel 后。
 * - 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @return YES 表示支持，NO 表示不支持。
 * @endif
 */
- (BOOL)isCameraExposurePositionSupported;

/**
 * @if English
 * Sets the camera exposure position.
 * <br>After you call the method, the onCameraExposureChanged callback is triggered on the local client.
 * @note
 * - Make sure that you call this method after the camera starts. For example, you can call this method after you call startPreview or joinChannel.
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @param positionInView The exposure position point.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置摄像头的手动曝光位置。
 * <br>
 * 通过此接口实现设置摄像头的手动曝光位置前，建议先通过 {@link INERtcEngineEx#isCameraExposurePositionSupported} 接口检测设备是否支持手动曝光功能。
 * @since V3.5.0
 * @par 使用前提
 * 请在启用相机后调用此接口，例如调用 {@link INERtcEngineEx#startPreview:} 或 {@link INERtcEngine#enableLocalVideo:streamType:} 之后。
 * @par 调用时机  
 * 请在引擎初始化之后调用此接口，且该方法在加入房间前后均可调用。
 * @note 
 * 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>positionInView</td>
 *      <td>CGPoint</td>
 *      <td>曝光位置点。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * CGPoint position = CGPointMake(0.5, 0.5);
 * [[NERtcEngine sharedEngine] setCameraExposurePosition:position];
 * @endcode
 * @par 相关回调
 * 成功调用此方法后，本地会触发 {@link NERtcEngineDelegateEx#onNERtcCameraExposureChanged:} 回调。
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *        - 30001（kNERtcErrFatal）：引擎尚未初始化或未开启摄像头。
 *        - 30004（kNERtcErrNotSupported）：不支持的操作，比如当前使用的是纯音频 SDK。
 * @endif
 */
- (int)setCameraExposurePosition:(CGPoint)positionInView;

/**
 * @if English
 * Enables or disables the camera flash feature.
 * @note
 * - Make sure that you call this method after the camera starts. For example, you can call this method after you call startPreview or joinChannel.
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @param on YES: turn on. NO: turn off.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 设置是否打开闪光灯。
 * @note
 * - 该方法需要在相机启动后调用，例如调用 startPreview 或 joinChannel 后。
 * - 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @param on YES 表示开启；NO 表示关闭。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)setCameraTorchOn:(BOOL)on;

/**
 * @if English
 * Check whether the flash is turned on on the device.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @return YES: turned on; NO: turned off.
 * @endif
 * @if Chinese 
 * 查询设备是否开启了闪光灯。
 * @note 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @return YES 表示开启；NO 表示关闭。
 * @endif
 */
- (BOOL)isCameraTorchOn;

/**
 * @if English
 * Sets the current camera zoom ratio.
 * @note
 * - Make sure that you call this method after the camera starts. For example, you can call this method after you call startPreview or joinChannel.
 * - Before you call this method, we recommend that you view the maximum zoom ratio supported by the camera by calling getCameraMaxZoom and set a zooming ratio as required.
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @param factor The zoom ratio supported by the camera.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置摄像头缩放比例。
 * <br>
 * 通过此接口实现设置摄像头缩放比例前，建议先通过 {@link INERtcEngineEx#maxCameraZoomScale} 接口查看摄像头支持的最大缩放比例，并根据实际需求合理设置需要的缩放比例。
 * @since V3.5.0
 * @par 使用前提
 * 请在启用相机后调用此接口，例如调用 {@link INERtcEngineEx#startPreview:} 或 {@link INERtcEngine#enableLocalVideo:streamType:} 之后。
 * @par 调用时机  
 * 请在引擎初始化之后调用此接口，且该方法在加入房间前后均可调用。
 * @note 
 * 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>factor</td>
 *      <td>float</td>
 *      <td>摄像头缩放比例。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * float factor = 0.5;
 * [[NERtcEngine sharedEngine] setCameraZoomFactor:factor];
 * @endcode
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *        - 30001（kNERtcErrFatal）：引擎尚未初始化或未开启摄像头。
 *        - 30004（kNERtcErrNotSupported）：不支持的操作，比如当前使用的是纯音频 SDK。
 * @endif
 */
- (int)setCameraZoomFactor:(float)factor;

/**
 * @if English
 * Gets maximum zoom ratio supported by the camera.
 * @note
 * - Make sure that you call this method after the camera starts. For example, you can call this method after you call startPreview or joinChannel.
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @return The maximum zoom ratio is returned.
 * @endif
 * @if Chinese 
 * 获取摄像头支持最大缩放比例。
 * @note
 * - 该方法需要在相机启动后调用，例如调用 startPreview 或 joinChannel 后。
 * - 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @return 最大缩放比例。
 * @endif
 */
 - (float)maxCameraZoomScale;

/**
 * @if English
 * Sets the camera manual focus position.
 * <br>After you call the method, the onNERtcCameraFocusChanged callback is triggered on the local client.
 * @note
 * - Make sure that you call this method after the camera starts. For example, you can call this method after you call startPreview or joinChannel.
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @param focusX The horizontal coordinate of the touch point in the view. Value range: 0 to 1.
 * @param focusY The vertical coordinate of the touch point in the view. Value range: 0 to 1.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置摄像头的手动曝光位置。
 * <br>
 * 通过此接口实现设置摄像头的手动曝光位置前，建议先通过 {@link INERtcEngineEx#isCameraFocusSupported} 接口检测设备是否支持手动曝光功能。
 * @since V3.5.0
 * @par 使用前提
 * 请在启用相机后调用此接口，例如调用 {@link INERtcEngineEx#startPreview:} 或 {@link INERtcEngine#enableLocalVideo:streamType:} 之后。
 * @par 调用时机  
 * 请在引擎初始化之后调用此接口，且该方法在加入房间前后均可调用。
 * @note 
 * 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>focusX</td>
 *      <td>float</td>
 *      <td>触摸点相对于视图的横坐标，取值范围为 0 ~ 1。</td>
 *  </tr>
  *  <tr>
 *      <td>focusY</td>
 *      <td>float</td>
 *      <td>触摸点相对于视图的纵坐标，取值范围为 0 ~ 1。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine] setCameraFocusPosition X:0.5 Y:0.5];
 * @endcode
 * @par 相关回调
 * 成功调用此方法后，本地会触发 {@link NERtcEngineDelegateEx#onNERtcCameraFocusChanged:} 回调。
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *        - 30001（kNERtcErrFatal）：引擎尚未初始化或未开启摄像头。
 *        - 30004（kNERtcErrNotSupported）：不支持的操作，比如当前使用的是纯音频 SDK。
 * @endif
 */
- (int)setCameraFocusPositionX:(float)focusX Y:(float)focusY;

/**
 * @if English
 * Sets the camera capturer configuration.
 * <br>For a video call or live streaming, generally the SDK controls the camera output parameters. By default, the SDK matches the most appropriate resolution based on the user's setLocalVideoConfig configuration. When the default camera capture settings do not meet special requirements, we recommend using this method to set the camera capturer configuration:
 * - If you want better quality for the local video preview, we recommend setting config as kNERtcCameraOutputQuality. The SDK sets the camera output parameters with higher picture quality.
 * - To customize the width and height of the video image captured by the local camera, set the camera capture configuration as kNERtcCameraOutputManual.
 * @note 
 * - Call this method before or after joining the channel. The setting takes effect immediately without restarting the camera.
 * - Higher collection parameters means higher performance consumption, such as CPU and memory usage, especially when video pre-processing is enabled. 
 * @since V4.5.0
 * @param config The camera capturer configuration.
 * @return {@code 0} A value of 0 returned indicates that the method call is successful. Otherwise, the method call fails.
 * @endif
 * @if Chinese
 * 设置本地摄像头的视频主流采集配置。
 * <br>通过此接口可以设置本地摄像头采集的主流视频宽度、高度、旋转角度等。
 * @since V4.5.0
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
 * @par 业务场景
 * 在视频通话或直播中，SDK 自动控制摄像头的输出参数。默认情况下，SDK 会根据用户该接口的配置匹配最合适的分辨率进行采集。但是在部分业务场景中，如果采集画面质量无法满足实际需求，可以调用该接口调整摄像头的采集配置。
 * @note 
 * - 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
 * - 该方法仅适用于视频主流，若您希望为辅流通道设置摄像头的采集配置，请调用 {@link INERtcEngineEx#setCameraCaptureConfig:streamType:} 方法。
 * - 该方法支持在加入房间后动态调用，设置成功后，会自动重启摄像头采集模块。
 * - 若系统相机不支持您设置的分辨率，会自动调整为最相近一档的分辨率，因此建议您设置为常规标准的分辨率。
 * - 设置较高的采集分辨率会增加性能消耗，例如 CPU 和内存占用等，尤其是在开启视频前处理的场景下。
 * @par 参数说明 
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>config</td> 
 *      <td>{@link NERtcCameraCaptureConfiguration}</td> 
 *      <td>本地摄像头采集配置。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * NERtcCameraCaptureConfiguration *config = [[NERtcCameraCaptureConfiguration alloc] init];
 * config.captureWidth = 1280;
 * config.captureHeight = 720;
 * [[NERtcEngine sharedEngine] setCameraCaptureConfig:config];
 * @endcode 
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *        - 30003（kNERtcErrInvalidParam）：参数错误，比如 config 设置为空。
 *        - 30004（kNERtcErrNotSupported）：不支持的操作，比如当前使用的是纯音频 SDK。
 *        - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎未初始化成功。
 * @endif
 */
 - (int)setCameraCaptureConfig:(NERtcCameraCaptureConfiguration *)config;

/**
 * @if Chinese
 * 设置本地摄像头的视频主流或辅流采集配置。
 * <br>通过此接口可以设置本地摄像头采集的主流或辅流视频宽度、高度、旋转角度等。
 * @since V4.6.20
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
 * @par 业务场景
 * 在视频通话或直播中，SDK 自动控制摄像头的输出参数。默认情况下，SDK 会根据用户该接口的配置匹配最合适的分辨率进行采集。但是在部分业务场景中，如果采集画面质量无法满足实际需求，可以调用该接口调整摄像头的采集配置。
 * @note 调用该接口设置成功后，会自动重启摄像头采集模块。
 * @par 参数说明 
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>config</td> 
 *      <td>{@link NERtcCameraCaptureConfiguration}</td> 
 *      <td>本地摄像头采集配置。</td>
 *  </tr>
 *  <tr>
 *      <td>streamType</td>
 *      <td>{@link NERtcStreamChannelType}</td>
 *      <td>视频通道类型：<ul><li>kNERtcStreamChannelTypeMainStream：主流。<li>kNERtcStreamChannelTypeSubStream：辅流。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //设置本地摄像头主流采集配置
 * NERtcCameraCaptureConfiguration *capConfig = [[NERtcCameraCaptureConfiguration alloc] init];
 * capConfig.captureWidth = 1280;
 * capConfig.captureHeight = 720;
 * [[NERtcEngine sharedEngine] setCameraCaptureConfig:capConfig streamType:kNERtcStreamChannelTypeMainStream];
 * //设置本地摄像头辅流采集配置
 * NERtcCameraCaptureConfiguration *subCapConfig = [[NERtcCameraCaptureConfiguration alloc] init];
 * subCapConfig.captureWidth = 1280;
 * subCapConfig.captureHeight = 720;
 * [[NERtcEngine sharedEngine] setCameraCaptureConfig:subCapConfig streamType:kNERtcStreamChannelTypeSubStream];
 * @endcode 
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30003（kNERtcErrInvalidParam）：参数错误，比如 config 设置为空。
 *      - 30004（kNERtcErrNotSupported）：不支持的操作，比如当前使用的是纯音频 SDK。
 *      - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎未初始化成功。
 * @endif
 */
- (int)setCameraCaptureConfig:(NERtcCameraCaptureConfiguration *)config streamType:(NERtcStreamChannelType)streamType;

#pragma mark - Audio Mixing

/**
 * @if English
 * Starts to play or mix the music file.
 * <br>This method mixes the specified local or online audio file with the audio stream captured from the recording device.
 * - Supported audio formats: MP3, M4A, AAC, 3GP, WMA, and WAV. Files that are stored in local storage or URLs are supported.
 * - If the playback status changes, the onAudioMixingStateChanged callback is triggered on the local client.
 * @note 
 * - You can call this method after you join a room.
 * - Starting from V4.3.0, if you call this method to play a music file during a call, and manually set the playback volume or publishing volume of the mixing audio, the setting is applied when you call the method again during the current call.
 * - Starting from V4.4.0, the operation to turn on or off local audio capture no longer affects the playback of music files. The music file is still playing after you call enablingLocalAudio(NO).
 * @param option The options when you configure a mixing audio task, such as the type of audio mixing tasks, the full path of the mixing audio file, or URL. For more information, see {@link NERtcCreateAudioMixingOption}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 开启伴音。
 * <br>通过本接口可以实现指定本地或在线音频文件和录音设备采集的音频流进行混音。
 * @since V3.5.0
 * @par 使用前提
 * 发送伴音前必须前调用 {@link INERtcEngine#enableLocalAudio:} 方法开启本地音频采集（V4.4.0 版本除外）。
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法仅可在加入房间后调用。
 * @note
 * - 支持的音乐文件类型包括 MP3、M4A、AAC、3GP、WMA 、WAV 和 FLAC 格式，支持本地文件或在线 URL。
 * - 自 V4.3.0 版本起，若您在通话中途调用此接口播放音乐文件时，手动设置了伴音播放音量或发送音量，则当前通话中再次调用时默认沿用此设置。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>option</td>
 *      <td>{@link NERtcCreateAudioMixingOption}</td>
 *      <td>创建伴音任务的配置选项，包括伴音任务类型、伴音文件的绝对路径或 URL 等。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * NERtcCreateAudioMixingOption *option = [[NERtcCreateAudioMixingOption alloc] init];
 * option.loopCount = loopCount; //循环播放次数
 * option.playbackEnabled = playbackEnabled; //是否本地播放伴音
 * option.playbackVolume = playbackVolume;  //音乐文件的播放音量
 * option.sendEnabled = sendEnabled;  //是否将伴音发送远端
 * option.sendVolume = sendVolume;  //音乐文件的发送音量
 * option.path = path; //待播放的音乐文件的绝对路径或 URL 地址
 * option.sendWithAudioType = sendWithAudioType//伴音跟随音频主流还是辅流，默认跟随主流
 * [[NERtcEngine sharedEngine] startAudioMixingWithOption:option];
 * @endcode
 * @par 相关回调
 * - {@link NERtcEngineDelegateEx#onAudioMixingStateChanged:errorCode:}：本地用户的伴音文件播放状态改变时，本地会触发此回调；可通过此回调接收伴音文件播放状态改变的相关信息，若播放出错，可通过对应错误码排查故障，详细信息请参考 {@link NERtcAudioMixingErrorCode}。
 * - {@link NERtcEngineDelegateEx#onAudioMixingTimestampUpdate:}：本地用户的伴音文件播放进度回调。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *         - 30003（kNERtcErrInvalidParam）：参数错误。
 *         - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎尚未初始化。
 * @endif
 */
- (int)startAudioMixingWithOption:(NERtcCreateAudioMixingOption *)option;

/**
 * @if English
 * Stops playing or mixing the music file.
 * <br>The method stops playing mixing audio. You can call the method when you are in a room.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 停止伴音。
 * <br>
 * 通过本接口可以实现停止播放本地或在线音频文件，或者录音设备采集的混音音频流。
 * @since V3.5.0
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法仅可在加入房间后调用。
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine] stopAudioMixing];
 * @endcode
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *         - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎尚未初始化或当前未在播放伴音。
 * @endif
 */
- (int)stopAudioMixing;

/**
 * @if English
 * Pauses playing and mixing the music file.
 * <br>The method pauses playing mixing audio. You can call the method when you are in a room.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 暂停伴音。
 * <br>
 * 通过此接口可以实现暂停播放伴音文件。
 * @since V3.5.0
 * @par 使用前提
 * 请先调用 {@link INERtcEngineEx#startAudioMixingWithOption:} 开启伴音。
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法仅可在加入房间后调用。
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine] pauseAudioMixing]
 * @endcode
 * @par 相关接口
 * 可以继续调用 {@link INERtcEngineEx#resumeAudioMixing} 方法恢复播放伴音文件。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 * @endif
 */
- (int)pauseAudioMixing;

/**
 * @if English
 * The method resumes mixing audio playback and continues playing the mixing audio. You can call the method when you are in a room.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 恢复伴音。
 * <br>
 * 通过此接口可以实现恢复播放伴音文件。
 * @since V3.5.0
 * @par 使用前提
 * 请先调用 {@link INERtcEngineEx#startAudioMixingWithOption:} 开启伴音。
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法仅可在加入房间后调用。
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine] resumeAudioMixing];
 * @endcode
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *        - 30001（kNERtcErrFatal）：引擎尚未初始化。
 *        - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎尚未初始化或当前未在播放伴音。
 * @endif
 */
- (int)resumeAudioMixing;

/**
 * @if English
 * Sets the publishing volume of the mixing audio.
 * @param volume The volume of publishing mixing audio. Valid values: 0 to 100. The default value of 100 indicates the original volume.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 设置伴奏的发送音量。
 * @param volume 伴奏发送音量。取值范围为 0~200。默认 100，即原始文件音量。
 * @return 操作返回值，成功则返回 0 
 * @endif
 */
- (int)setAudioMixingSendVolume:(uint32_t)volume;

/**
 * @if English
 * Gets the volume for publishing mixing audio.
 * <br>The method gets the volume of mixing audio. You can call the method when you are in a room.
 * @param volume The volume of publishing audio mixing.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 获取伴奏发送音量。
 * <br>该方法获取混音里伴奏的发送音量大小。请在房间内调用该方法。
 * @param volume 伴奏发送音量。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)getAudioMixingSendVolume:(uint32_t *)volume;

/**
 * @if English
 * Adjusts the volume of mixing audio for local playback.
 * <br>The method adjusts the volume of mixing audio for local playback. You can call the method when you are in a room.
 * @param volume The playback volume of the mixing audio. Valid values: 0 to 100. The default value of 100 indicates the original volume.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 调节伴奏播放音量。
 * <br>该方法调节混音里伴奏的播放音量大小。请在房间内调用该方法。
 * @param volume  伴奏播放音量。取值范围为 0~200。默认 100，即原始文件音量。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)setAudioMixingPlaybackVolume:(uint32_t)volume;

/**
 * @if English
 * Gets the playback volume of the mixing audio.
 * <br>The method gets the playback volume of mixing audio. You can call the method when you are in a room.
 * @param volume The playback volume of the mixing audio. Valid values: 0 to 200.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 获取伴奏播放音量。
 * <br>该方法获取混音里伴奏的播放音量大小。请在房间内调用该方法。
 * @param volume  伴奏播放音量。范围为 0~200。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)getAudioMixingPlaybackVolume:(uint32_t *)volume;

/**
 * @if English
 * Gets the duration of the mixing audio file.
 * <br>The method gets the duration of the mixing audio file. Unit: milliseconds. You can call the method when you are in a room.
 * @param duration The duration of the mixing audio file. Unit: milliseconds.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 获取伴奏时长。
 * <br>该方法获取伴奏时长，单位为毫秒。请在房间内调用该方法。
 * @param duration 伴奏时长，单位为毫秒。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)getAudioMixingDuration:(uint64_t *)duration;

/**
 * @if English
 * Gets the playback position of the mixing audio file.
 * <br>The method gets the playback position of the audio file. Unit: milliseconds. You can call the method when you are in a room.
 * @param position The playback position of the mixing audio file. Unit: milliseconds.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 获取音乐文件的播放进度。
 * <br>该方法获取当前伴奏播放进度，单位为毫秒。请在房间内调用该方法。
 * @param position 音乐文件的播放位置，单位为毫秒。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)getAudioMixingCurrentPosition:(uint64_t *)position;

/**
 * @if English
 * Sets the playback position of the mixing audio file to a different starting position.
 * <br>The method sets the playback position of the mixing audio file to a different starting position. The method allows you to play the mixing audio file from the position based on your requirements rather than from the beginning.
 * @param position The playback position of the mixing audio file. Unit: milliseconds.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 设置音乐文件的播放位置。
 * <br>该方法可以设置音频文件的播放位置，这样你可以根据实际情况播放文件，而非从头到尾播放整个文件。
 * @param position 音乐文件的播放位置，单位为毫秒。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)setAudioMixingPosition:(uint64_t)position;

/**
 * @if Chinese 
 * 设置当前伴音文件的音调。
 * - 通过此接口可以实现当本地人声和播放的音乐文件混音时，仅调节音乐文件的音调。
 * @since V4.6.29
 * @par 使用前提
 * 请先调用 {@link INERtcEngineEx#startAudioMixingWithOption:} 方法开启伴音。
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
 * @par 业务场景
 * 适用于 K 歌中为了匹配人声，调节背景音乐音高的场景。
 * @note
 * 当前伴音任务结束后，此接口的设置会恢复至默认。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>pitch</td>
 *      <td>int32_t</td>
 *      <td>当前伴音文件的音调。默认值为 0，即不调整音调，取值范围为 -12 ~ 12，按半音音阶调整。每相邻两个值的音高距离相差半音；取值的绝对值越大，音调升高或降低得越多。</td>
 *  </tr>
 * </table>     
 * @par 示例代码
 * @code
 * int32_t pitch = 5;
 * [[NERtcEngine sharedEngine] setAudioMixingPitch:pitch];
 * @endcode
 * @par 相关接口
 * 可以调用 {@link INERtcEngineEx#getAudioMixingPitch:} 方法获取伴音文件的音调。
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal）：引擎尚未初始化。
 *      - 30003（kNERtcErrInvalidParam）：参数错误，比如 pitch 超出范围。
 *      - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如找不到对应的伴音任务。
 * @endif
 */
- (int)setAudioMixingPitch:(int32_t)pitch;

/**
 * @if Chinese 
 * 获取当前伴音文件的音调。
 * @since V4.6.29
 * @par 使用前提
 * 请先调用 {@link INERtcEngineEx#startAudioMixingWithOption:} 方法开启伴音。
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。   
 * @par 示例代码
 * @code
 * int32_t pitch = 0;
 * [[NERtcEngine sharedEngine] getAudioMixingPitch:&pitch];
 * @endcode
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal）：引擎尚未初始化。
 *      - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如找不到对应的伴音任务。
 * @endif
 */
- (int)getAudioMixingPitch:(int32_t *)pitch;

#pragma mark - Audio Effect
/**
 * @if English
 * Plays back a specified sound effect file.
 * <br>The method plays a specified local or online sound effect file.
 * - If you call the method and the playback ends, the onAudioEffectFinished playback is triggered.
 * - Supported audio formats: MP3, M4A, AAC, 3GP, WMA, and WAV. Files that are stored in local storage or URLs are supported.
 * @note
 * - You can call this method after you join a room.
 * - You can call the method multiple times. You can play multiple sound effect files simultaneously by passing in different effectId and options. Various sound effects are mixed. To gain optimal user experience, we recommend you play no more than three sound effect files at the same time.
 * @param effectId The ID of the specified sound effect. Each sound effect has a unique ID.
 * @param option The parameters, such as the type of mixing audio tasks, and the path of the mixing audio file. For more information, see {@link NERtcCreateAudioEffectOption}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 播放指定音效文件。
 * 通过此接口可以实现播放指定的本地或在线音效文件。
 * @since V3.5.0
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
 * @note
 * 支持的音效文件类型包括 MP3、M4A、AAC、3GP、WMA 和 WAV 格式，支持本地文件和在线 URL。
 * 您可以多次调用该方法，通过传入不同音效文件的 effectId 和 option，同时播放多个音效文件，实现音效叠加；但是为获得最佳用户体验，建议同时播放不超过 3 个音效文件。
 * 若通过此接口成功播放某指定音效文件后，反复停止或重新播放该 effectId 对应的音效文件，仅首次播放时设置的 option 有效，后续的 option 设置无效。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>effectId</td>
 *      <td>uint32_t</td>
 *      <td>指定音效的 ID。每个音效均应有唯一的 ID。</td>
 *  </tr>
 *  <tr>
 *      <td>option</td>
 *      <td>NERtcCreateAudioEffectOption *</td>
 *      <td>音效相关参数，包括混音任务类型、混音文件路径等。详细信息请参考 {@link NERtcCreateAudioEffectOption}。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //播放音效文件 1 taskId 需要自己管理
 * uint32_t taskId1 = 1;    
 * NERtcCreateAudioEffectOption *option = [[NERtcCreateAudioEffectOption alloc] init];
 * option.path = @"your effect file path 1";
 * option.loopCount = 1;
 * [[NERtcEngine sharedEngine] playEffectWitdId:taskId1 effectOption:option];
 * 
 * //播放音效文件2 taskId 需要自己管理
 * uint32_t taskId2 = 2;    
 * NERtcCreateAudioEffectOption *option = [[NERtcCreateAudioEffectOption alloc] init];
 * option.path = @"your effect file path 2";
 * option.loopCount = 1;
 * [[NERtcEngine sharedEngine] playEffectWitdId:taskId2 effectOption:option];
 * @endcode
 * @par 相关接口
 * {@link NERtcEngineDelegateEx#onAudioEffectTimestampUpdateWithId:timeStampMS:}：本地音效文件播放进度回调。
 * {@link NERtcEngineDelegateEx#onAudioEffectFinished:}：本地音效文件播放已结束回调。
 * @return 
 * - 0（kNERtcNoError）：方法调用成功；
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal）：状态错误，比如引擎尚未初始化。
 * @endif
 */
- (int)playEffectWitdId:(uint32_t)effectId effectOption:(NERtcCreateAudioEffectOption *)option;

/**
 * @if English
 * Stops playing all sound effect files.
 * <br>You can call this method after you join a room.
 * @param effectId The ID of the specified sound effect. Each sound effect has a unique ID.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 停止播放指定音效文件。
 * @since V3.5.0
 * @par 使用前提
 * 请先调用 {@link INERtcEngineEx#playEffectWitdId:effectOption:} 接口播放音效文件。
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>effectId</td>
 *      <td>uint32_t</td>
 *      <td>指定音效文件的 ID，每个音效文件均有唯一的 ID。</td>
 *  </tr>
 * </table>  
 * @par 示例代码
 * @code
 * //停止 effectId 为 0 的音效播放
 * [[NERtcEngine sharedEngine] stopEffectWitdId:0]
 * @endcode
 * @return
 * - 0（kNERtcNoError）：方法调用成功；
 * - 其他：方法调用失败。
 *        - 30001（kNERtcErrFatal）：引擎尚未初始化。
 *        - 30003（kNERtcErrInvalidParam）：未找到 ID 对应的音效文件。
 * @endif
 */
- (int)stopEffectWitdId:(uint32_t)effectId;

/**
 * @if English
 * Stops playing all sound effect files.
 * <br>You can call this method after you join a room.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 停止播放所有音效文件。
 * 通过此接口可以实现在同时播放多个音效文件时，可以一次性停止播放所有文件（含暂停播放的文件）。
 * @since V3.5.0
 * @par 使用前提
 * 请先调用 {@link INERtcEngineEx#playEffectWitdId:effectOption:} 接口播放音效文件。
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine] stopAllEffects];
 * @endcode
 * @par 相关接口
 * 可以调用 {@link INERtcEngineEx#stopEffectWitdId:} 方法停止播放指定音效文件。
 * @return
 * - 0（kNERtcNoError）：方法调用成功；
 * - 其他：方法调用失败。
 *        - 30005（kNERtcErrInvalidState）：引擎尚未初始化。
 * @endif
 */
- (int)stopAllEffects;

/**
 * @if English
 * Pauses playing a specified sound effect file.
 * <br>You can call this method after you join a room.
 * @param effectId The ID of a sound effect file.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 暂停播放指定音效文件。
 * <br>请在加入房间后调用该方法。
 * @param effectId 音效 ID。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)pauseEffectWitdId:(uint32_t)effectId;

/**
 * @if English
 * Resumes playing a specified sound effect file.
 * <br>You can call this method after you join a room.
 * @param effectId The ID of the specified sound effect. Each sound effect has a unique ID.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 恢复播放指定音效文件。
 * <br>请在加入房间后调用该方法。
 * @param effectId 指定音效的 ID。每个音效均有唯一的 ID。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)resumeEffectWitdId:(uint32_t)effectId;

/**
 * @if English
 * Pauses playing all sound effect files.
 * <br>You can call this method after you join a room.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 暂停播放所有音效文件。
 * <br>请在加入房间后调用该方法。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)pauseAllEffects;

/**
 * @if English
 * Resumes playing all sound effect files.
 * <br>You can call this method after you join a room.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 恢复播放所有音效文件。
 * <br>请在加入房间后调用该方法。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)resumeAllEffects;

/**
 * @if English
 * Sets the publishing volume of a sound effect file.
 * <br>You can call this method after you join a room.
 * @param effectId The ID of the specified sound effect. Each sound effect has a unique ID.
 * @param volume The publishing volume of the sound effect file. Valid values: 0 to 100. The default value of 100 indicates the original volume.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 设置音效文件发送音量。
 * <br>请在加入房间后调用该方法。
 * @param effectId 指定音效的 ID。每个音效均有唯一的 ID。
 * @param volume 音效发送音量。范围为0~100，默认为  100，表示原始音量。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)setEffectSendVolumeWithId:(uint32_t)effectId volume:(uint32_t)volume;

/**
 * @if English
 * Gets the publishing volume of a specified sound effect file.
 * <br>You can call this method after you join a room.
 * @param effectId The ID of the specified sound effect file. Each sound effect file has a unique ID.
 * @param volume The returned publishing volume of the sound effect file.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 获取指定音效文件发送音量。
 * <br>请在加入房间后调用该方法。
 * @param effectId 指定音效的 ID。每个音效均有唯一的 ID。
 * @param volume 返回的发送音量。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)getEffectSendVolumeWithId:(uint32_t)effectId volume:(uint32_t *)volume;

/**
 * @if English
 * Sets the playback volume of the sound effect files.
 * <br>You can call this method after you join a room.
 * @param effectId The ID of the specified audio effect file. Each sound effect file has a unique ID.
 * @param volume The playback volume of the sound effect file. Valid values: 0 to 100. The default value is 100.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 获取音效文件播放音量。
 * <br>请在加入房间后调用该方法。
 * @param effectId 指定音效的 ID。每个音效均有唯一的 ID。
 * @param volume 音效播放音量。范围为0~100，默认为100。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)setEffectPlaybackVolumeWithId:(uint32_t)effectId volume:(uint32_t)volume;

/**
 * @if English
 * Gets the playback volume of the sound effect files
 * @param effectId The ID of a sound effect file.
 * @param volume The returned volume of the sound effect file.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 获取音效的回放音量
 * @param effectId 音效 ID。
 * @param volume 返回的音量值
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)getEffectPlaybackVolumeWithId:(uint32_t)effectId volume:(uint32_t *)volume;

/**
 * @if English
 * Gets the duration of a sound effect file.
 * @since V4.4.0
 * The method gets the duration of the sound effect file. Unit: milliseconds.
 * @note You can call the method when you join in a room.
 * @param[in] effectId The ID of a sound effect file.
 * @param[out] duration The duration of the sound effect file. Unit: milliseconds.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 获取音效文件时长。
 * @since V4.4.0
 * 该方法获取音效文件时长，单位为毫秒。
 * @note 请在房间内调用该方法。
 * @param[in] effectId 音效 ID。
 * @param[out] duration 音效文件时长，单位为毫秒。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)getEffectDurationWithId:(uint32_t)effectId duration:(uint64_t *)duration;

/**
 * @if English
 * Gets the playback position of a sound effect file.
 * @since V4.4.0 
 * The method gets the playback position of the audio file. Unit: milliseconds.
 * @note You can call the method when you join a room.
 * @param[in] effectId The ID of a sound effect file.
 * @param[out] position The playback position of the sound effect file. Unit: milliseconds.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 获取音效的播放进度。
 * @since V4.4.0 
 * 该方法获取当前音效播放进度，单位为毫秒。
 * @note 请在房间中调用该方法。
 * @param[in]  effectId 音效 ID。
 * @param[out] position 音效文件的播放位置，单位为毫秒。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)getEffectCurrentPositionWithId:(uint32_t)effectId position:(uint64_t *)position;

/**
 * @if Chinese 
 * 设置指定音效文件的播放位置。
 * - 通过此接口可以实现根据实际情况播放音效文件，而非从头到尾播放整个文件。
 * @since V4.6.29
 * @par 使用前提
 * 请先调用 {@link INERtcEngineEx#playEffectWitdId:effectOption:} 方法播放音效。
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>effectId</td>
 *      <td>uint32_t</td>
 *      <td>指定音效文件的 ID。每个音效文件均对应唯一的 ID。</td>
 *  </tr>
 *  <tr>
 *      <td>position</td>
 *      <td>uint64_t</td>
 *      <td>指定音效文件的起始播放位置。单位为毫秒。</td>
 *  </tr>
 * </table>     
 * @par 示例代码
 * @code
 * @endcode
 * @par 相关接口
 * - {@link INERtcEngineEx#getEffectCurrentPositionWithId:position:}：获取指定音效文件的当前播放位置。
 * - {@link NERtcEngineDelegateEx#onAudioEffectTimestampUpdateWithId:timeStampMS:}：注册此回调实时获取指定音效文件的当前播放进度，默认为每隔 1s 返回一次。
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal）：引擎尚未初始化。
 *      - 30003（kNERtcErrInvalidParam）：参数错误，比如 effectId 错误。
 * @endif
 */
- (int)setEffectPositionWithId:(uint32_t)effectId position:(uint64_t)position;

/**
 * @if Chinese 
 * 设置指定音效文件的音调。
 * - 通过此接口可以实现当本地人声和播放的音乐文件混音时，仅调节音乐文件的音调。
 * @since V4.6.29
 * @par 使用前提
 * 请先调用 {@link INERtcEngineEx#playEffectWitdId:effectOption:} 方法播放音效。
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
 * @par 业务场景
 * 适用于 K 歌中为了匹配人声，调节背景音乐音高的场景。
 * @note
 * 当前音效任务结束后，此接口的设置会恢复至默认。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>effectId</td>
 *      <td>uint32_t</td>
 *      <td>指定音效文件的 ID。每个音效文件均对应唯一的 ID。</td>
 *  </tr>
 *  <tr>
 *      <td>pitch</td>
 *      <td>int32_t</td>
 *      <td>指定音效文件的音调。默认值为 0，即不调整音调，取值范围为 -12 ~ 12，按半音音阶调整。每相邻两个值的音高距离相差半音；取值的绝对值越大，音调升高或降低得越多。</td>
 *  </tr>
 * </table>     
 * @par 示例代码
 * @code
 * uint32_t effectId;
 * int32_t pitch = 5;
 * [[NERtcEngine sharedEngine] setEffectPitchWithId:effectId pitch:pitch];
 * @endcode
 * @par 相关接口
 * 可以调用 {@link INERtcEngineEx#getEffectPitchWithId:pitch:} 方法获取指定音效文件的音调。
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal）：引擎尚未初始化。
 *      - 30003（kNERtcErrInvalidParam）：参数错误，比如 pitch 超出范围或者 effectId 错误，没有对应的音效任务。
 * @endif
 */
- (int)setEffectPitchWithId:(uint32_t)effectId pitch:(int32_t)pitch;

/**
 * @if Chinese 
 * 获取指定音效文件的音调。
 * @since V4.6.29
 * @par 使用前提
 * 请先调用 {@link INERtcEngineEx#playEffectWitdId:effectOption:} 方法播放音效。
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>effectId</td>
 *      <td>uint32_t</td>
 *      <td>指定音效文件的 ID。每个音效文件均对应唯一的 ID。</td>
 *  </tr>
 * </table>     
 * @par 示例代码
 * @code
 * uint32_t effectId;
 * int32_t pitch = 0;
 * [[NERtcEngine sharedEngine] getEffectPitchWithId:effectId pitch:&pitch];
 * @endcode
 * @par 相关接口
 * 可以调用 {@link INERtcEngineEx#getEffectPitchWithId:pitch:} 方法获取指定音效文件的音调。
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal）：引擎尚未初始化。
 *      - 30003（kNERtcErrInvalidParam）：参数错误，比如 effectId 错误，没有对应的音效任务。
 * @endif
 */
- (int)getEffectPitchWithId:(uint32_t)effectId pitch:(int32_t *)pitch;

#pragma mark - In-ear monitoring
/**
 * @if English
 * Enables the in-ear monitoring feature.
 * @note
 * - You can call the method when you join in a room.
 * - After in-ear monitoring is enabled, you must wear a headset or earpieces to use the in-ear monitoring feature. We recommend that you call onAudioDeviceChanged to monitor the changes of audio devices. Only when the device changes to headset, you can enable in-ear monitoring.
 * - In the V4.0.0 release, the volume parameter in enableEarback is invalid. You can call setEarbackVolume to set the volume for in-ear monitoring.
 * @param enabled The option whether to enable in-ear monitoring.
 * @param volume The volume for in-ear monitoring. Valid values: 0 to 100. The default value is 100.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置是否开启耳返功能。
 * <br>
 * @since V3.5.0
 * @par 调用时机
 * 请在初始化后调用该方法，且该方法仅可在加入房间后调用。
 * @note 
 * - 加入房间后，耳返功能可以随时开启，但只有当插入耳机或耳麦时，耳返功能才会生效；当拔出耳机或耳麦时会自动暂停，再次插入耳机或耳麦自动恢复，且耳返功能可以实时关闭。
 * - 若您使用的是 V4.0.0 版本的 SDK，请注意此版本该方法的 `volume` 参数无效，请调用 {@link INERtcEngineEx#setEarbackVolume:} 接口设置耳返音量。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>enabled</td>
 *      <td>BOOL</td>
 *      <td>是否开启耳返功能：<ul><li>YES：开启耳返。<li>NO：关闭耳返。</td>
 *  </tr>
 *  <tr>
 *      <td>volume</td>
 *      <td>uint32_t</td>
 *      <td>设置耳返音量。取值范围为 0 ~ 100，默认值为 100。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //开启耳返并设置耳返音量为 100
 * 示例代码
 * [[NERtcEngine sharedEngine] enableEarback:YES volume:100];
 * @endcode
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30003（kNERtcErrInvalidParam）：参数错误。
 *      - 30005（kNERtcErrInvalidState)：当前状态不支持的操作，比如引擎尚未初始化。
 * @endif
 */
- (int)enableEarback:(BOOL)enabled volume:(uint32_t)volume;

/**
 * @if English
 * Sets the volume for in-ear monitoring.
 * @param volume The volume for in-ear monitoring. Valid values: 0 to 100. The default value is 100.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 设置耳返音量。
 * @param volume 设置耳返音量，可设置为0~100，默认为 100。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)setEarbackVolume:(uint32_t)volume;

#pragma mark - Audio Recording
/**
 * @if English
 * Starts an audio recording from a client.
 * <br>The method records the mixing audio from all room members in the room, and store the recording file locally. The onAudioRecording() callback is triggered when the recording starts or ends.
 * <br>If you specify a type of audio quality, the recording file is saved in different formats.
 * - A WAV file is large with high quality
 * - An AAC file is small with low quality.
 * @note
 * - You must call the method after you call joinChannel.
 * - A client can only run a recording task. If you repeatedly call the startAudioRecording method, the current recording task stops and a new recording task starts.
 * - If the current user leaves the room, audio recording automatically stops. You can call the stopAudioRecording method to manually stop recording during calls.
 * @param filePath The file path where the recording file is stored. The file name and format are required. For example, sdcard/xxx/audio.aac.
 *                   - Make sure that the path is valid and has the write permissions.
 *                   - Only WAV or AAC files are supported.
 * @param sampleRate The recording sample rate. Valid values: 16000,32000, 44100, and 48000. The default value is 32000.
 * @param quality The audio quality. The parameter is valid only the recording file is in AAC format. For more information, see {@link NERtcAudioRecordingQuality}.
   @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 开启客户端本地录音。
 * 通过此接口可以实现录制客户端房间内所有用户混音后的音频流，并将其保存在一个本地录音文件中。
 * @since V4.2.0
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
 * @note 
 * 客户端只能同时运行一个录音任务；若您在录音过程中重复调用 {@link INERtcEngineEx#startAudioRecording:sampleRate:quality:} 方法，会结束当前录制任务，并重新开始新的录音任务。
 * 本端用户离开房间时，自动停止录音；也可以在通话中随时调用 {@link INERtcEngineEx#stopAudioRecording}  方法以实现手动停止录音。
 * 请保证录音文件的保存路径存在并且可写，目前支持 WAV（音质保真度高，文件大）、AAC（音质保真度低，文件小）格式的文件。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>filePath</td>
 *      <td>NSString *</td>
 *      <td>录音文件在本地保存的绝对路径，需要精确到文件名及格式，例如：sdcard/xxx/audio.aac。</td>
 *  </tr>
 *  <tr>
 *      <td>sampleRate</td>
 *      <td>int</td>
 *      <td>录音采样率。单位为赫兹（Hz），可以设置为 16000、32000（默认）、44100 或 48000。</td>
 *  </tr>
 *  <tr>
 *      <td>quality</td>
 *      <td>{@link NERtcAudioRecordingQuality} </td>
 *      <td>录音音质。此参数仅在 AAC 格式下有效。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine] startAudioRecording:path sampleRate:sampleRate quality:quality];
 * @endcode
 * @par 相关回调
 * 调用此接口成功后会触发 {@link NERtcEngineDelegateEx#onNERtcEngineAudioRecording:filePath:} 回调，通知音频录制任务状态已更新。音频录制状态码请参考 {@link NERtcAudioRecordingCode}。
 * @return
 * - 0（kNERtcNoError）：方法调用成功；
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal）：状态错误，比如引擎尚未初始化。
 *      - 30003（kNERtcErrInvalidParam）： 参数错误，比如设置的采样率无效。
 * @endif
 */
- (int)startAudioRecording:(NSString *)filePath sampleRate:(int)sampleRate quality:(NERtcAudioRecordingQuality)quality;

/**
 * @if English
 * Starts an audio recording from a client.
 * <br>The method records the mixing audio from all room members in the room, and store the recording file locally. The onAudioRecording() callback is triggered when the recording starts or ends.
 * <br>If you specify a type of audio quality, the recording file is saved in different formats.
 * - A WAV file is large in size with high quality
 * - An AAC file is small in size with low quality.
 * @note
 * - You must call the method after you call joinChannel.
 * - A client can only run a recording task. If you repeatedly call the startAudioRecording method, the current recording task stops and a new recording task starts.
 * - If the current user leaves the room, audio recording automatically stops. You can call the stopAudioRecording method to manually stop recording during calls.
 * @param filePath The file path where the recording file is stored. The file name and format are required. For example, sdcard/xxx/audio.aac.
 *                   - Make sure that the path is valid and has the write permissions.
 *                   - Only WAV or AAC files are supported.
 * @param sampleRate The recording sample rate in Hz. Valid values: 16000,32000, 44100, and 48000. The default value is 32000.
 * @param quality The audio quality. The parameter is valid only the recording file is in AAC format. For more information, see {@link NERtcAudioRecordingQuality}.
 * @param position   The recording object. The mixed audio in the room is recorded by default.
 * @param cycleTime  The maximum number of seconds for loop caching. You can set the value to 0, 10, 60, 360, and 900. The default value is 0 indicates that the write operation runs in real time.
 * @return 
 * - 0: success
 * - Others: failure
 * @endif
 * @if Chinese
 * 开始客户端录音。
 * 调用该方法后，客户端会录制房间内所有用户混音后的音频流，并将其保存在本地一个录音文件中。录制开始或结束时，自动触发 onAudioRecording() 回调。
 * 指定的录音音质不同，录音文件会保存为不同格式：
 * - WAV：音质保真度高，文件大。
 * - AAC：音质保真度低，文件小。
 * @note
 * - 请在加入房间后调用此方法。
 * - 客户端只能同时运行一个录音任务，正在录音时，如果重复调用 startAudioRecordingWithConfig，会结束当前录制任务，并重新开始新的录音任务。
 * - 当前用户离开房间时，自动停止录音。您也可以在通话中随时调用 stopAudioRecording 手动停止录音。
 * @since V4.6.0
 * @param filePath   录音文件在本地保存的绝对路径，需要精确到文件名及格式。例如：sdcard/xxx/audio.aac。
 *                   - 请确保指定的路径存在并且可写。
 *                   - 目前仅支持 WAV 或 AAC 文件格式。
 * @param sampleRate 录音采样率（Hz），可以设为 16000、32000（默认）、44100 或 48000。
 * @param quality    录音音质，只在 AAC 格式下有效。详细信息请参考 {@link NERtcAudioRecordingQuality} 。
 * @param position   录音对象。详细信息请参考 {@link NERtcAudioRecordingPosition}。
 * @param cycleTime  循环缓存的最大时长跨度。该参数单位为秒，可以设为 0、10、60、360、900，默认值为 0，即实时写文件。
 * @return
 * - 0：方法调用成功。
 * - 其他：方法调用失败。
 * @endif
 */
- (int)startAudioRecordingWithConfig:(NERtcAudioRecordingConfiguration *_Nonnull)config;

/**
 * @if English
 * Stops the audio recording on the client.
 * <br>If the local client leaves the room, audio recording automatically stops. You can call the stopAudioRecording method to manually stop recording during calls.
 * @note You must call this method before you call leaveChannel.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 停止客户端本地录音。
 * 本端用户离开房间时会自动停止本地录音，也可以通过此接口实现在通话过程中随时停止录音。
 * @since V4.2.0
 * @par 使用前提
 * 请先调用 {@link INERtcEngineEx#startAudioRecordingWithConfig:} 方法开启客户端本地音频录制。
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine] stopAudioRecording];
 * @endcode
 * @par 相关回调
 * 调用此接口成功后会触发 {@link NERtcEngineDelegateEx#onNERtcEngineAudioRecording:filePath:} 回调，通知音频录制任务状态已更新。音频录制状态码请参考 {@link NERtcAudioRecordingCode}。
 * @return
 * - 0（kNERtcNoError）：方法调用成功；
 * - 其他：方法调用失败。
 *         - 30001（kNERtcErrFatal）：状态错误，比如引擎尚未初始化。
 * @endif
 */
- (int)stopAudioRecording;

#pragma mark - External Audio
/**
 * @if English
 * Sets the external audio input source.
 * <br>After you call the method, the setting becomes invalid if you choose an audio input device or a sudden restart occurs. After the method is called, you can call pushExternalAudioFrame to send the pulse-code modulation (PCM) data.
 * @note
 * - You can call this method before you join a room.
 * - The method enables the internal engine. The virtual component works instead of the physical speaker. The setting remains valid after you call the leaveChannel method. If you want to disable the feature, you must disable the setting before the next call starts.
 * - After you enable the external audio data input, some functionalities of the speakerphone supported by the SDK are replaced by the external audio source. Settings that are applied to the speakerphone become invalid or do not take effect in calls. For example, you can hear the external data input when you use loopback for testing.
 * @param enabled The option whether to enable external data input. The default value is NO.
 * @param sampleRate The sample rate of the external audio source. Unit: Hz. Recommended values: 8000, 16000, 32000, 44100, and 48000.
 * @param channels The number of sound channels. Valid values:
 * - 1: mono sound
 * - 2: stereo sound
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 开启或关闭外部音频源数据输入。
 * <br>通过本接口可以实现创建自定义的外部音频源，并通过主流通道传输该外部音频源的数据。
 * @since V3.9.0
 * @par 使用前提
 * 建议在通过 {@link INERtcEngine#enableLocalAudio:} 接口关闭本地音频采集之后调用该方法。
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
 * @par 业务场景
 * 实现由应用层而非 SDK 采集音频数据，比如在合唱过程中使用自定义的音乐文件。
 * @note
 * - 调用该方法关闭外部音频输入时可以传入任意合法值，此时设置不会生效，例如 setExternalAudioSource(false, 0, 0)。
 * - 该方法设置内部引擎为启用状态，在 {@link INERtcEngine#leaveChannel} 后仍然有效；如果需要关闭该功能，需要在下次通话前调用此接口关闭外部音频数据输入功能。
 * - 成功调用此方法后，将用虚拟设备代替麦克风工作，因此麦克风的相关设置会无法生效，例如进行 loopback 检测时，会听到外部输入的音频数据。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>enabled</td>
 *      <td>BOOL</td>
 *      <td>是否开启外部音频输入：<ul><li>YES：开启外部音频输入。<li>NO：关闭外部音频输入。</td>
 *  </tr>
 *  <tr>
 *      <td>sampleRate</td>
 *      <td>int32_t</td>
 *      <td>外部音频源的数据采样率，单位为 Hz。建议设置为 8000，16000，32000，44100 或 48000。</td>
 *  </tr>
 *  <tr>
 *      <td>channels</td>
 *      <td>int32_t</td>
 *      <td>外部音频源的数据声道数：<ul><li>1：单声道。<li>2：双声道。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * [[[NTESDemoLogic sharedLogic] getCoreEngine] setExternalAudioSource:enabled sampleRate:sampleRate channels:channels];
 * @endcode
 * @par 相关接口
 * - 该方法调用成功后可以调用 {@link INERtcEngineEx#pushExternalAudioFrame:} 方法发送音频 PCM 数据。
 * - 若您希望通过辅流通道输入外部输入视频源，可以调用 {@link INERtcEngineEx#setExternalSubStreamAudioSource:sampleRate:channels:} 方法。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal）：引擎尚未初始化。
 *      - 30003（kNERtcErrInvalidParam）：参数错误，比如声道数不是 1 或者 2，或者采样率设置有问题。
 * @endif
 */
- (int)setExternalAudioSource:(BOOL)enabled sampleRate:(int32_t)sampleRate channels:(int32_t)channels;

/**
 * @if English
 * Publishes the external audio frame.
 * <br>The method pushes the external audio frame data to the internal audio engine. If you enable the external audio data source by calling setExternalAudioSource, you can use pushExternalAudioFrame to send audio PCM data.
 * @note
 * - You must join a room before you can call the method.
 * - We recommend that you set the duration of data frames to match a cycle of 10 ms.
 * - The method becomes invalid if the audio input device is turned off. For example, disable local audio, end calls, and shut off the microphone test before calls.
 * @param frame The external audio frame data. The data cannot exceed 7,680 bytes.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 推送外部音频帧。
 * <br>将外部音频数据帧推送给内部引擎。 通过 setExternalAudioSource 启用外部音频数据输入功能成功后，可以使用 pushExternalAudioFrame 接口发送音频 PCM 数据。
 * @note
 * - 该方法需要在加入房间后调用。
 * - 数据帧时长建议匹配 10ms 周期。
 * - 该方法在音频输入设备关闭后不再生效。例如关闭本地音频、通话结束、通话前麦克风设备测试关闭等情况下，该设置不再生效。
 * @param frame 外部音频帧数据；数据长度不能超过 7680 字节，和调用周期时长一致。
 * @return
 * - 0: 方法调用成功；
 * - 其他: 方法调用失败。
 * @endif
 */

- (int)pushExternalAudioFrame:(NERtcAudioFrame *)frame;


/**
 * @if English
 * Sets external audio rendering.
 * <br>The method is suitable for scenarios that require personalized audio rendering. By default, the setting is disabled. If you choose an audio playback device or a sudden restart occurs, the setting becomes invalid.
 * <br>After you call the method, you can use pullExternalAudioFrame to get audio PCM data.
 * @note
 * - You can call this method before you join a room.
 * - The method enables the internal engine. The virtual component works instead of the physical speaker. The setting remains valid after you call the leaveChannel method. If you want to disable the functionality, you must disable the functionality before the next call starts.
 * - After you enable the external audio rendering, some functionalities of the speakerphone supported by the SDK are replaced by the external audio source. Settings that are applied to the speakerphone become invalid or do not take effect in calls. For example, external rendering is required to play the external audio when you use loopback for testing.
 * @param enabled The option whether to enable external audio rendering.
 * @param sampleRate The sample rate of the external audio rendering. Unit: Hz. Valid values: 16000, 32000, 44100, and 48000.
 * @param channels The number of channels for external audio rendering. Valid values:
 * - 1: mono sound 
 * - 2: stereo sound  
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置外部音频渲染。
 * <br>通过此接口可以实现启用外部音频渲染，并设置音频渲染的采样率、声道数等。
 * @since V3.9.0
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间前调用。
 * @par 业务场景
 * 适用于需要自行渲染音频的场景。
 * @note
 * - 该方法设置内部引擎为启用状态，在 {@link INERtcEngine#leaveChannel} 后仍然有效；如果需要关闭该功能，需要在下次通话前调用此接口关闭外部音频数据渲染功能。
 * - 成功调用此方法后，音频播放设备的选择和异常重启功能将失效， 且将用虚拟设备代替扬声器工作，因此扬声器的相关设置会无法生效，例如进行 loopback 检测时，需要由外部渲染播放。
 * - 设置 `enable` 参数为 NO 关闭该功能时，其他参数可传入任意合法值，均不会生效。
 * @par 参数说明 
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>enabled</td>
 *      <td>BOOL</td>
 *      <td>是否开启外部音频渲染：<ul><li>YES：开启外部音频渲染。<li>NO（默认）：关闭外部音频渲染。</td>
 *  <tr>
 *      <td>sampleRate</td>
 *      <td>int32_t</td>
 *      <td>外部音频渲染的采样率，单位为赫兹（Hz），可设置为 16000，32000，44100 或 48000。</td>
 *  </tr>
 *  <tr>
 *      <td>channels</td>
 *      <td>int32_t</td>
 *      <td>外部音频渲染的声道数，可设置为：<ul><li>1：单声道。<li>2：双声道。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //设置采样率为 16000 的双声道外部渲染
 * [[NERtcEngine sharedEngine] setExternalAudioRender:YES sampleRate:16000 channels:2];
 * @endcode
 * @par 相关接口
 * 可以继续调用 {@link INERtcEngineEx#pullExternalAudioFrame:length:} 方法获取音频 PCM 数据，用以后续自行渲染并播放。
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *        - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如已经加入了房间。
 * @endif
 */
 - (int)setExternalAudioRender:(BOOL)enabled sampleRate:(int32_t)sampleRate channels:(int32_t)channels;

/**
 * @if English
 * Pulls the external audio data.
 * <br>The method pulls the audio data from the internal audio engine. After you enable the external audio data rendering functionality by calling setExternalAudioRender, you can use pullExternalAudioFrame to get the audio PCM data.
 * @note
 * - You must join a room before you can call the method.
 * - We recommend that you set the duration of data frames to match a cycle of 10 ms.
 * - The method becomes invalid if the audio rendering device is turned off. In this case, no data is returned. For example, when calls end, and when the speakerphone is shut off before calls.
 * @param data The data pointer.
 * @param len The size of the audio data that are pulled. Unit: bytes. We recommend that the duration of the audio data at least last 10 ms, and the data size cannot exceed 7680 bytes. <br>Formula: len = sampleRate/1000 × 2 × channels × duration of the audio data in milliseconds
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 拉取外部音频数据。
 * <br>该方法将从内部引擎拉取音频数据。 通过 setExternalAudioRender 启用外部音频数据渲染功能成功后，可以使用 pullExternalAudioFrame 接口获取音频 PCM 数据。
 * @note
 * - 该方法需要在加入房间后调用。
 * - 数据帧时长建议匹配 10ms 周期。
 * - 该方法在音频渲染设备关闭后不再生效，此时会返回空数据。例如通话结束、通话前扬声器设备测试关闭等情况下，该设置不再生效。
 * @param data 数据指针。
 * @param len 待拉取音频数据的字节数，单位为 byte。建议音频数据的时长至少为 10 毫秒，数据长度不能超过 7680字节。<br>计算公式为： len = sampleRate/1000 × 2 × channels × 音频数据时长（毫秒）。
 * @return 操作返回值，成功则返回 0

* @endif
*/
- (int)pullExternalAudioFrame:(void *_Nonnull)data length:(int)len;

#pragma mark - 3D Audio

/**
* 设置玩家本人在房间中的范围语音模式，该设置不影响其他人。
* @since V5.5.10
* @par 调用时机
* 请在引擎初始化后调用此接口，且该方法在加入房间前后均可调用。
* @note 
* - 离开房间后，此参数不会自动重置为默认模式，所以请在每次加入房间之前都调用此方法设置语音模式。
* - 加入房间后，可以随时修改语音模式，并立即生效。
* @param[in] mode 范围语音模式，包括所有人和仅小队两种模式。具体请参见 {@link NERtcRangeAudioMode} 。
* @return
* - 0: 方法调用成功
* - 其他: 调用失败
*/
- (int)setRangeAudioMode:(NERtcRangeAudioMode)mode;

/**
* 设置范围语音的小队ID。
* @since V5.5.10
* @par 调用时机
* 请在引擎初始化后调用此接口，且该方法在加入房间前后均可调用。
* @note 
* - 离开房间后，TeamID 失效，需要重新配置TeamID ，请在每次加入房间之前都调用此方法设置队伍号。
* - 如果离开房间后再加入房间，请在收到退房成功回调（onLeaveChannel）后，再调用此方法设置队伍号。
* - 若加入房间后，调用此接口修改队伍号，设置后立即生效。
* - 请配合 {@link #setRangeAudioMode:} 接口一起使用。
* @param teamId 小队ID, 有效值: >=0。若team_id = 0，则房间内所有人（不论范围语音的模式是所有人还是仅小队）都可以听到该成员的声音。
* @return
* - 0: 方法调用成功
* - 其他: 调用失败
*/
-(int)setRangeAudioTeamID:(int32_t)teamId;

/**
  * 设置空间音效的距离衰减属性和语音范围。
  * @since V5.5.10
  * @par 调用时机
  * 请在引擎初始化后调用此接口，且该方法在加入房间前后均可调用。
  * @note 
  * - 若要使用范围语音或空间音效功能，加入房间前需要调用一次本接口。
  * - 仅使用范围语音时，只需要设置audibleDistance参数，其他参数设置不生效，填写默认值即可。
  * @param audibleDistance 监听器能够听到扬声器并接收其语音的距离扬声器的最大距离。距离有效范围：[1,max int) ，无默认值。
  * @param conversationalDistance 范围语音场景中，该参数设置的值不起作用，保持默认值即可。空间音效场景中，需要配置该参数。
  * 控制音频保持其原始音量的范围，超出该范围时，语音聊天的响度在被听到时开始淡出。
  * 默认值为 1。
  * @param rollOff 范围语音场景中，该参数设置的值不起作用，保持默认值即可。空间音效场景中，需要配置该参数。
  * 距离衰减模式，具体请参见 {@link #NERtcDistanceRolloffModel} ，默认值为 kNERtcDistanceRolloffNone。
 * @return
 * - 0: 方法调用成功
 * - 其他: 调用失败
 */
- (int)setAudioRecvRange:(int)audibleDistance conversationalDistance:(int)conversationalDistance rollOff:(NERtcDistanceRolloffModel)rollOff;

/**
 * 设置空间音效中说话者和接收者的空间位置信息。SDK 会根据该方法中的参数计算接收者和说话者之间的相对位置，进而渲染出空间音效。
 * @since V5.5.10
 * @par 调用时机
  * 请在引擎初始化后调用此接口，且该方法在加入房间前后均可调用。
  * @note 
  * - 请先调用 {@link #enableSpatializer:applyToTeam:} 接口后，再调用本接口。
  * - 调用 {@link #enableSpatializer:applyToTeam:} 接口关闭空间音效后，空间位置信息会重置为默认值，您需要重新设置位置信息。
  * @par 参数说明
  * 通过 info 参数设置空间音效中说话者和接收者的空间位置信息。#NERtcPositionInfo 的具体参数说明如下表所示。
    * <table>
    *  <tr>
    *      <th>**参数名称**</th>
    *      <th>**描述**</th>
    *  </tr>
    *  <tr>
    *      <td>speaker_position</td>
    *      <td>说话者的位置信息，三个值依次表示X、Y、Z的坐标值。默认值{0,0,0} </td>
    *  </tr>
    *  <tr>
    *      <td>speaker_quaternion</td>
    *      <td><note type="note">该参数设置的值暂时不起作用，保持默认值即可。</note>说话者的旋转信息，通过四元组来表示，数据格式为{w, x, y, z}。默认值{0,0,0,0} </td>
    *  </tr>
    *  <tr>
    *      <td>head_position</td>
    *      <td>接收者的位置信息，三个值依次表示X、Y、Z的坐标值。默认值{0,0,0} </td>
    *  </tr>
    *  <tr>
    *      <td>head_quaternion</td>
    *      <td>接收者的旋转信息，通过四元组来表示，数据格式为{w, x, y, z}。默认值{0,0,0,0}</td>
    *  </tr>
    * </table>   
 * @return
 * - 0: 方法调用成功
 * - 其他: 调用失败
 */
- (int)updateSelfPosition:(NERtcPositionInfo *)info;

/**
  * 开启或关闭空间音效的房间混响效果
  * @since V5.4.0
  * @par 调用时机
  * 请在引擎初始化后调用此接口，且该方法在加入房间前后均可调用。
  * @note 
  * 请先调用 {@link #enableSpatializer:applyToTeam:} 接口后，再调用本接口。
 * @param enabled 混响效果开关，默认值关闭
 * @return
 * - 0: 方法调用成功
 * - 其他: 调用失败
 */
- (int)enableSpatializerRoomEffects:(BOOL)enabled;

/**
  * 设置空间音效的房间混响属性
  * @since V5.4.0
  * @par 调用时机
  * 请在引擎初始化后调用此接口，且该方法在加入房间前才可调用。
  * @note 
  * 请先调用 {@link #enableSpatializer:applyToTeam:} 接口启用空间音效，再调用本接口。
 * @param roomProperty 房间属性，具体请参见 #NERtcSpatializerRoomProperty
 * @return
 * - 0: 方法调用成功
 * - 其他: 调用失败
 */
- (int)setSpatializerRoomProperty:(NERtcSpatializerRoomProperty *)roomProperty;

/**
 * 设置空间音效的渲染模式
  * @since V5.4.0
  * @par 调用时机
  * 请在引擎初始化后调用此接口，且该方法在加入房间前才可调用。
  * @note 
  * 请先调用 {@link #enableSpatializer:applyToTeam:} 接口启用空间音效，再调用本接口。
 * @param mode 渲染模式，具体请参见 #NERtcSpatializerRenderMode ，默认值 #kNERtcSpatializerRenderBinauralHighQuality
 * @return
 * - 0: 方法调用成功
 * - 其他: 调用失败
 */
- (int)setSpatializerRenderMode:(NERtcSpatializerRenderMode)mode;

/**
* 初始化引擎3D音效算法
* @since V5.5.10
* @par 调用时机
* 请在引擎初始化后调用此接口，此接口在加入房间前后均可调用。
* @return
* - 0: 方法调用成功
* - 其他: 调用失败
*/
- (int)initSpatializer;

/**
 * 开启或关闭空间音效
  * @since V5.4.0
  * @par 调用时机
  * 请在引擎初始化后调用此接口，且该方法在加入房间前才可调用。
  * @note 
  * - 开启空间音效后，通话结束时仍保留该开关状态，不重置。
  * - 请先调用  #initSpatializer 接口初始化空间音效算法，再调用本接口。
 * @param enabled 是否打开3D音效算法功能，默认为关闭状态。
 * @param apply_to_team 是否仅本小队开启3D音效。true: 仅仅和接收端同一个小队的人有3D音效；false: 接收到所有的语音都有3d音效
 * - YES：: 开启空间音效
 * - NO: 关闭空间音效
 * @return
 * - 0: 方法调用成功
 * - 其他: 调用失败
 */
- (int)enableSpatializer:(BOOL)enabled applyToTeam:(BOOL)applyToTeam;

#pragma mark - ASL black and white list
/**
     * @if Chinese
     * 你可以调用该方法指定不订阅的音频流。
     * @note
     *  - 此接口需要在加入房间成功后调用。
     *  - 对于调用接口时不在房间的 uid 不生效。
     * @since V5.5.10
     * @param[in] type 音频流类型。
     * @param[in] uidArray 不订阅此 用户uid列表 的音频。
     * 此列表为全量列表。如果列表为空或 null，取消订阅黑名单。
     * @return
     * - 0：方法调用成功。
     * - 其他：方法调用失败。
     * @endif
     */
- (int)setSubscribeAudioBlocklist:(NERtcAudioStreamType)type uidArray:(NSArray<NSNumber*> *)uidArray;

/**
     * @if Chinese
     * 你可以调用该方法指定只订阅的音频流。
     * @note
     *  - 此接口需要在加入房间成功后调用。
     *  - 对于调用接口时不在房间的 uid 不生效。
     * @since V5.5.10
     * @param[in] uid_array 只订阅此 用户uid列表 的音频。
     * 此列表为全量列表。如果列表为空或 null，取消订阅白名单。
     * @return
     * - 0：方法调用成功。
     * - 其他：方法调用失败。
     * @endif
     */
- (int)setSubscribeAudioAllowlist:(NSArray<NSNumber*> *)uidArray;

#pragma mark - Data Channel

/**
 * @if English
 * Enables or disables local data channel.
 * @note
 * - You can call this method after you join a room.
 * - After local data channel successfully enabled or disabled,  the onNERtcEngineUserDataDidStop or onNERtcEngineUserDataDidStart
 * @param[in] enabled Whether to enable local data channel.
 * - true: Enables local data channel.
 * - false: Disables local data channel
 * @since V5.0.0
 * @return
 * - 0: Success.
 * - Other values: Failure.
 * @endif
 * @if Chinese
 * 开启或关闭本地数据通道。
 * @note
 * - 该方法加入房间后才可调用。
 * - 成功启用或禁用本地数据通道后，远端会触发 onNERtcEngineUserDataDidStop 或 onNERtcEngineUserDataDidStart  回调。
 * @param[in] enabled 是否启用本地数据通道:
 * - true: 开启本地数据通道；
 * - false: 关闭本地数据通道。
 * @since V5.0.0
 * @return
 * - 0: 方法调用成功；
 * - 其他: 方法调用失败。
 * @endif
 */
- (int)enableLocalData:(BOOL)enabled;

/**
 * @if English
 * Unsubscribes from or subscribes to data channel from specified remote users.
 * <br>After a user joins a channel, data channel streams from all remote users are subscribed by default. You can call this method to unsubscribe from or subscribe to data channel streams from all remote users.
 * @note  When the kNERtcKeyAutoSubscribeData is enabled by default, users cannot manually modify the state of data channel subscription.
 * @param[in] uid           The user ID.
 * @param[in] subscribe
 * - true: Subscribes to specified data channel streams (default).
 * - false: Unsubscribes from specified data channel streams.
 *  @since V5.0.0
 *  @return
 * - 0: Success.
 * - Other values: Failure.
 * @endif
 * @if Chinese
 * 取消或恢复订阅指定远端用户数据通道流。
 * <br>加入房间时，默认订阅所有远端用户的数据通道流，您可以通过此方法取消或恢复订阅指定远端用户的数据通道流。
 * @note 当kNERtcKeyAutoSubscribeData默认打开时，用户不能手动修改数据通道订阅状态
 * @param[in] userID          指定用户的 ID。
 * @param[in] subscribe     是否订阅远端用户数据通道流。
 * - true: 订阅指定数据通道流（默认）。
 * - false: 取消订阅指定数据通道流。
 * @since V5.0.0
 * @return
 * - 0: 方法调用成功。
 * - 其他: 方法调用失败。
 * @endif
 */
- (int)subscribeRemoteData:(BOOL)subscribe forUserID:(uint64_t)userID;

/**
 * @if English
 * Send data by data channel.
 * @param[in] data    The custom data channel frame data.。
 * @since V5.0.0
 * @return
 * - 0: Success.
 * - Other values: Failure.
 * @endif
 * @if Chinese
 * 通过数据通道发送数据。
 * @param[in] data   自定义数据。
 * @since V5.0.0
 * @return
 * - 0: 方法调用成功。
 * - 其他: 方法调用失败。
 * @endif
 */
- (int)sendData:(NSData *)data;

#pragma mark - Media Statistic Observer

/**
 * @if English
 * Registers a stats observer.
 * @param observer The stats observer. For more information, see {@link NERtcEngineMediaStatsObserver}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 注册媒体统计信息观测器。
 * @param observer 统计信息观测器。详细信息请参考  {@link NERtcEngineMediaStatsObserver}。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)addEngineMediaStatsObserver:(id<NERtcEngineMediaStatsObserver>)observer;

/**
 * @if English
 * Removes the specified media stats observer.
 * @param observer The stats observer
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 移除指定媒体统计信息观测器。
 * @param observer 统计信息观测器
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)removeEngineMediaStatsObserver:(id<NERtcEngineMediaStatsObserver>)observer;

/**
 * @if English
 * Clears all media stats observers.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 清除全部媒体统计信息观测器。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)cleanupEngineMediaStatsObserver;


#pragma mark - Live Stream
/**
 * @if English
 * Adds a streaming task in a room.
 * <br>After you call the method, the current user can receive a notification about the status of live streaming.
 * @param taskInfo The information about the streaming task. For more information, {@link NERtcLiveStreamTaskInfo}.
 * @param completion The result. The callback is triggered after the method is called. For more information, see {@link NERtcLiveStreamCompletion}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @note
 * - The method is applicable to only live streaming.
 * - You can call the method when you are in a room. The method is valid for calls.
 * - Only one URL for the relayed stream is added in each call. You need to call the method multiple times if you want to push many streams. An RTC room with the same channelid can create three different streaming tasks.
 * @endif
 * @if Chinese
 * 添加房间内推流任务。
 * 通过此接口可以实现增加一路旁路推流任务；若需推送多路流，则需多次调用该方法。
 * @since V3.5.0
 * @par 使用前提
 * 请先通过 {@link INERtcEngine#setChannelProfile:} 接口设置房间模式为直播模式。
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
 * @note
 * - 仅角色为主播的房间成员能调用此接口，观众成员无相关推流权限。
 * - 同一个音视频房间（即同一个 channelId）可以创建 6 个不同的推流任务。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>taskInfo</td>
 *      <td>NERtcLiveStreamTaskInfo *</td>
 *      <td>推流任务信息。详细信息请参考 {@ NERtcLiveStreamTaskInfo}。</td>
 *  </tr>
 *  <tr>
 *      <td>compeltion</td>
 *      <td>{@link NERtcLiveStreamCompletion} </td>
 *      <td>操作结果回调，方法调用成功后会触发对应的 {@link NERtcEngineLiveStreamObserver#onNERTCEngineLiveStreamState:taskID:url:} 回调。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * NERtcLiveStreamTaskInfo *info = [[NERtcLiveStreamTaskInfo alloc] init];
 * //info的具体参数详见 NERtcLiveStreamTaskInfo的定义
 * [[NERtcEngine sharedEngine]  addLiveStreamTask:info compeltion:^(NSString * _Nonnull taskId, kNERtcLiveStreamError errorCode){
 *     }];
 * @endcode
 * @par 相关回调
 * 调用此接口成功后会触发 {@link NERtcEngineLiveStreamObserver#onNERTCEngineLiveStreamState:taskID:url:} 回调，通知推流任务状态已更新。
 * @return 
 * - 0（kNERtcNoError）：方法调用成功；
 * - 其他：方法调用失败。
 *      - 403（kNERtcErrChannelReservePermissionDenied）：权限不足，观众模式下不支持此操作。
 *      - 30003（kNERtcErrInvalidParam）： 参数错误，比如推流任务 ID 参数为空。
 *      - 30005（kNERtcErrInvalidState）：状态错误，比如引擎尚未初始化。
 * @endif
 */
- (int)addLiveStreamTask:(NERtcLiveStreamTaskInfo *)taskInfo compeltion:(NERtcLiveStreamCompletion)completion;

/**
 * @if English
 * Updates a streaming task.
 * @note
 * - The method is applicable to only live streaming.
 * - You can call the method when you are in a room. The method is valid for calls.
 * @param taskInfo The information about the streaming task. For more information, see {@link NERtcLiveStreamTaskInfo}.    
 * @param completion The result. The callback is triggered after the method is called. For more information, see {@link NERtcLiveStreamCompletion}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 更新房间内指定推流任务。
 * 通过此接口可以实现调整指定推流任务的编码参数、画布布局、推流模式等。
 * @since V3.5.0
 * @par 使用前提
 * 请先调用 {@link INERtcEngineEx#addLiveStreamTask:compeltion:} 方法添加推流任务。
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
 * @note
 * 仅角色为主播的房间成员能调用此接口，观众成员无相关推流权限。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>taskInfo</td>
 *      <td>NERtcLiveStreamTaskInfo *</td>
 *      <td>推流任务信息。详细信息请参考 {@ NERtcLiveStreamTaskInfo}。</td>
 *  </tr>
 *  <tr>
 *      <td>compeltion</td>
 *      <td>{@link NERtcLiveStreamCompletion} </td>
 *      <td>操作结果回调，方法调用成功后会触发对应的 {@link NERtcEngineLiveStreamObserver#onNERTCEngineLiveStreamState:taskID:url:} 回调。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine]  updateLiveStreamTask:info compeltion:^(NSString * _Nonnull taskId, kNERtcLiveStreamError errorCode){
 *     }];
 * @endcode
 * @par 相关回调
 * 调用此接口成功后会触发 {@link NERtcEngineLiveStreamObserver#onNERTCEngineLiveStreamState:taskID:url:} 回调，通知推流任务状态已更新。
 * @return 
 * - 0（kNERtcNoError）：方法调用成功；
 * - 其他：方法调用失败。
 *      - 403（kNERtcErrChannelReservePermissionDenied）：权限不足，观众模式下不支持此操作。
 *      - 30003（kNERtcErrInvalidParam）： 参数错误，比如推流任务 ID 参数为空。
 *      - 30005（kNERtcErrInvalidState）：状态错误，比如引擎尚未初始化。
 * @endif
 */
- (int)updateLiveStreamTask:(NERtcLiveStreamTaskInfo *)taskInfo compeltion:(NERtcLiveStreamCompletion)completion;

/**
 * @if English
 * Deletes a streaming task.
 * @note
 * - The method is applicable to only live streaming.
 * - You can call the method when you are in a room. The method is valid for calls.
 * @param taskId The ID of a streaming task.  
 * @param completion The result. The callback is triggered after the method is called. For more information, see {@link NERtcLiveStreamCompletion}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 删除房间内指定推流任务。
 * @since V3.5.0
 * @par 使用前提
 * 请先调用 {@link INERtcEngineEx#addLiveStreamTask:compeltion:} 方法添加推流任务。
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，该方法在加入房间前后均可调用。
 * @note
 * - 仅角色为主播的房间成员能调用此接口，观众成员无相关推流权限。
 * - 通话结束，房间成员全部离开房间后，推流任务会自动删除；如果房间内还有用户存在，则需要创建推流任务的用户删除推流任务。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>taskId</td>
 *      <td>NSString *</td>
 *      <td>推流任务 ID。</td>
 *  </tr>
 *  <tr>
 *      <td>completion</td>
 *      <td>{@link NERtcLiveStreamCompletion}</td>
 *      <td>操作结果回调，方法调用成功后会触发对应的 {@link NERtcEngineLiveStreamObserver#onNERTCEngineLiveStreamState:taskID:url:} 回调。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine]  removeLiveStreamTask:task_id compeltion:^(NSString * _Nonnull taskId, kNERtcLiveStreamError errorCode){
 *     }];
 * @endcode
 * @par 相关回调
 * 调用此接口成功后会触发 {@link NERtcEngineLiveStreamObserver#onNERTCEngineLiveStreamState:taskID:url:} 回调，通知推流任务已删除。
 * @return 
 * - 0（kNERtcNoError）：方法调用成功；
 * - 其他：方法调用失败。
 *      - 403（kNERtcErrChannelReservePermissionDenied）：权限不足，观众模式下不支持此操作。
 *      - 30003（kNERtcErrInvalidParam）： 参数错误，比如推流任务 ID 参数为空。
 *      - 30005（kNERtcErrInvalidState）：状态错误，比如引擎尚未初始化。
 * @endif
 */
- (int)removeLiveStreamTask:(NSString *)taskId compeltion:(NERtcLiveStreamCompletion)completion;

#pragma mark - Audio Frame Observer
/**
 * @if English
 * Sets the format of audio capture.
 * <br>The method sets the format of the recording for onNERtcEngineAudioFrameDidRecord.
 * @note
 * - You can set or modify the format before or after you join a room.
 * - To cancel listeners for the callback, reset the value to nil.
 * @param format The sample rate and the number of channels returned by onNERtcEngineAudioFrameDidRecord. <br>A value of nil is allowed. The default value is nil, which indicates that the original format of the audio file is used. For more information, see {@link NERtcAudioFrameRequestFormat}.   
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置采集的音频格式。
 * <br>通过本接口可以实现设置 {@link NERtcEngineAudioFrameObserver#onNERtcEngineAudioFrameDidRecord:} 回调的录制声音格式。
 * @since V3.5.0
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
 * @par 业务场景
 * 适用于需要监听音频 PCM 采集数据回调并指定回调的数据格式的场景。
 * @note 
 * 若您希望使用音频的原始格式，format 参数传 nil 即可。
 * @par 参数说明 
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>format</td> 
 *      <td>{@link NERtcAudioFrameRequestFormat}</td> 
 *      <td>指定 {@link NERtcEngineAudioFrameObserver#onNERtcEngineAudioFrameDidRecord:} 中返回数据的采样率和数据的通道数。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //设置 pcm 采集数据回调格式
 * NERtcAudioFrameRequestFormat *format = [[NERtcAudioFrameRequestFormat alloc] init];
 * format.channels = channels;
 * format.sampleRate = sampleRate;
 * format.mode = mode;
 * [[NERtcEngine sharedEngine] setRecordingAudioFrameParameters:format];
 * //开启监听 pcm 数据回调
 * [[NERtcEngine sharedEngine] setAudioFrameObserver:self];
 * @endcode 
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *        - 30003（kNERtcErrInvalidParam）：参数错误。
 * @endif
 */
- (int)setRecordingAudioFrameParameters:(nullable NERtcAudioFrameRequestFormat *)format;

  
/**
 * @if English
 * Sets the audio playback format.
 * <br>The method sets the playback format of the audio data returned by onNERtcEngineAudioFrameWillPlayback.
 * @note
 * - You can set or modify the format before or after you join a room.
 * - To cancel listeners for the callback, reset the value to nil.
 * @param format The sample rate and the number of channels returned by onNERtcEngineAudioFrameDidRecord. <br>A value of nil is allowed. The default value is nil, which indicates that the original format of the audio file is used. For more information, see {@link NERtcAudioFrameRequestFormat}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置音频播放回调的声音格式。
 * <br>
 * 通过此接口可以实现设置 SDK 播放音频 PCM 回调 {@link NERtcEngineAudioFrameObserver#onNERtcEngineAudioFrameWillPlayback:} 的采样率及声道数，同时还可以设置读写模式。在写模式下，您可以通过 {@link NERtcEngineAudioFrameObserver#onNERtcEngineAudioFrameWillPlayback:} 回调修改 PCM 数据，后续将播放修改后的音频数据。
 * @since V3.5.0
 * @par 调用时机
 * 请在初始化后调用该方法，且该方法仅可在加入房间后调用。
 * @par 业务场景
 * 适用于需要自行对待播放的声音进行二次处理的场景。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>format</td>
 *      <td>{@link NERtcAudioFrameRequestFormat}</td>
 *      <td>指定 {@link NERtcEngineAudioFrameObserver#onNERtcEngineAudioFrameWillPlayback:} 中返回数据的采样率和数据的通道数。允许传入 nil，默认为 nil，表示使用音频的原始格式。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //设置 pcm 播放数据回调格式
 * NERtcAudioFrameRequestFormat *format = [[NERtcAudioFrameRequestFormat alloc] init];
 * format.channels = channels;
 * format.sampleRate = sampleRate;
 * format.mode = mode;
 * [[NERtcEngine sharedEngine] setRecordingAudioFrameParameters:format];
 * //开启监听 pcm 数据回调   
 * [[NERtcEngine sharedEngine] setAudioFrameObserver:self];
 * @endcode
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30005（kNERtcErrInvalidState)：状态错误，比如引擎尚未初始化。
 * @endif
 */
- (int)setPlaybackAudioFrameParameters:(nullable NERtcAudioFrameRequestFormat *)format;

/**
 * @if English
 * Sets the format of the recording and mixing audio.
 * <br>The method sets the format of the audio frames returned by onNERtcEngineMixedAudioFrame.
 * - You can set or modify the format before or after you join a room. leaveChannel is reset to nil.
 * - You can set only the sample rate.
 * - If you do not use the method to set the format, the default value of the sample rate supported by the SDK is returned.
 * @param format The sample rate and the number of channels returned by onNERtcEngineMixedAudioFrame. A value of nil is allowed. The default value is nil, which indicates that the original format of the audio file is used. For more information, see {@link NERtcAudioFrameRequestFormat}.   
 * @return The value returned. A value of 0 indicates that the operation is successful. 
 * @endif
 * @if Chinese
 * 设置采集和播放声音混音后的音频数据格式。
 * <br>
 * 通过本接口可以实现设置 {@link NERtcEngineAudioFrameObserver#onNERtcEngineMixedAudioFrame:} 回调的混音音频格式。
 * @since V3.5.0
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
 * @par 业务场景
 * 适用于需要获取本地用户和远端所有用户的声音的场景，比如通话录音的场景。
 * @note 
 * - 该方法设置内部引擎为启用状态，在 {@link INERtcEngine#leaveChannel} 后设置会重置为默认状态。
 * - 目前仅支持设置对应回调的音频采样率；未调用该接口设置返回的音频数据格式时，回调中的采样率取默认值。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>format</td>
 *      <td>{@link NERtcAudioFrameRequestFormat}</td>
 *      <td>指定 {@link NERtcEngineAudioFrameObserver#onNERtcEngineMixedAudioFrame:} 中返回数据的采样率和数据的通道数。若您希望使用音频的原始格式，format 参数传 nil 即可，默认为 nil。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //设置 pcm 录制和播放声音混音后的数据回调格式
 * NERtcAudioFrameRequestFormat *format = [[NERtcAudioFrameRequestFormat alloc] init];
 * format.sampleRate = sampleRate;
 * [[NERtcEngine sharedEngine] setRecordingAudioFrameParameters:format];
 * //开启监听 pcm 数据回调   
 * [[NERtcEngine sharedEngine] setAudioFrameObserver:self];
 * @endcode
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30003（kNERtcErrInvalidParam）：参数错误。
 * @endif
 */
- (int)setMixedAudioFrameParameters:(nullable NERtcAudioFrameRequestFormat *)format;

/**
 * @if English
 * Registers the audio observer.
 * <br>The method can set audio capture or play PCM data callbacks. The method can process audio streams. The method can register the callback that is triggered by the audio engine, such as onPlaybackFrame.
 * @note You can set or modify the method before or after you join a room. 
 * @param observer The audio frame observer. <br> If you pass in NULL, you cancel the registration and clear the settings of NERtcAudioFrameRequestFormat. For more information, see {@link NERtcEngineAudioFrameObserver}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 注册语音观测器对象。
 * <br>通过此接口可以设置音频采集/播放 PCM 回调，可用于声音处理等操作。
 * @since V3.5.0
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间前调用。
 * @par 参数说明 
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>observer</td>
 *      <td>{@link NERtcEngineAudioFrameObserver}</td>
 *      <td>接口对象实例。如果传入参数为 NULL，取消注册，同时会清理 {@link NERtcAudioFrameRequestFormat} 的相关设置。</td>
 * </table>
 * @par 示例代码
 * @code
 * //开启监听 pcm 数据回调
 * [[NERtcEngine sharedEngine] setAudioFrameObserver:self];
 * @endcode
 * @par 相关回调
 * - {@link NERtcEngineAudioFrameObserver#onNERtcEngineAudioFrameDidRecord:}：采集音频数据回调，用于声音处理等操作。
 * - {@link NERtcEngineAudioFrameObserver#onNERtcEngineSubStreamAudioFrameDidRecord:}：本地音频辅流数据回调，用于自定义音频辅流数据。
 * - {@link NERtcEngineAudioFrameObserver#onNERtcEngineAudioFrameWillPlayback:}：播放音频数据回调，用于声音处理等操作。
 * - {@link NERtcEngineAudioFrameObserver#onNERtcEngineMixedAudioFrame:}：获取本地用户和所有远端用户混音后的原始音频数据。
 * - {@link NERtcEngineAudioFrameObserver#onNERtcEnginePlaybackAudioFrameBeforeMixingWithUserID:frame:channelId:}：获取指定远端用户混音前的音频数据。
 * - {@link NERtcEngineAudioFrameObserver#onNERtcEnginePlaybackSubStreamAudioFrameBeforeMixingWithUserID:frame:channelId:}：获取指定远端用户混音前的音频辅流数据。
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *         - 30005（kNERtcErrInvalidState）：状态错误，比如已经加入房间。
 * @endif
 */
- (int)setAudioFrameObserver:(nullable id<NERtcEngineAudioFrameObserver>)observer;


/**
 注册视频数据观察对象
 通过此接口可以设置视频数据采集回调对象，可以用于第三方美颜等操作
 @since V4.6.40
 @par 调用时机
 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
 设置空指针，表示不再监听视频数据采集回调。
 */
- (int)setVideoFrameObserver:(nullable id<NERtcEngineVideoFrameObserver>)videoframeObserver;


#pragma mark - Volume Indication
/**
 * @if English
 * Enables reporting users' volume indication.
 * <br>The method allows the SDK to report to the app the information about the volume of the user that publishes local streams and the remote users (up to three users) that have the highest instantaneous volume. The information about the current speaker and the volume is reported.
 * <br>If this method is enabled. When a user joins a room and pushes streams, the SDK triggers the onRemoteAudioVolumeIndication callback based on the preset time intervals.
 * @param enable The option whether to prompt the speaker volume.
 * @param interval The time interval at which the volume prompt is displayed. Unit: milliseconds. The value must be multiples of 100 milliseconds. We recommend that you set the value 200 milliseconds or more.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 启用说话者音量提示。
 * <br>通过此接口可以实现允许 SDK 定期向 App 反馈房间内发音频流的用户和瞬时音量最高的远端用户（最多 3 位，包括本端）的音量相关信息，即当前谁在说话以及说话者的音量。
 * @since V3.5.0
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法在加入房间前后均可调用。
 * @par 业务场景
 * 适用于通过发言者的人声相关信息做出 UI 上的音量展示的场景，或根据发言者的音量大小进行视图布局的动态调整。
 *  @note
 * 该方法在 leaveChannel 后设置失效，将恢复至默认。如果您离开房间后重新加入房间，需要重新调用本接口。
 * @par 参数说明 
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>enable</td>
 *      <td>BOOL</td>
 *      <td>是否启用说话者音量提示：<ul><li>YES：启用说话者音量提示。<li>NO：关闭说话者音量提示。</td>
 *  <tr>
 *      <td>interval</td>
 *      <td>uint64_t</td>
 *      <td>指定音量提示的时间间隔。单位为毫秒。必须设置为 100 毫秒的整数倍值，建议设置为 200 毫秒以上。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //设置间隔为500ms的人声音量提示
 * [[NERtcEngine sharedEngine] enableAudioVolumeIndication:YES interval:500];
 * @endcode
 * @par 相关回调
 * 启用该方法后，只要房间内有发流用户，无论是否有人说话，SDK 都会在加入房间后根据预设的时间间隔触发 {@link NERtcEngineDelegateEx#onRemoteAudioVolumeIndication:totalVolume:} 回调。
 * @par 相关接口
 * 若您希望在返回音量相关信息的同时检测是否有真实人声存在，请调用 {@link INERtcEngineEx#enableAudioVolumeIndication:interval:vad:} 方法。
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *         - 30003（kNERtcErrInvalidParam）：参数错误，比如时间间隔小于 100ms。
 * @endif
 */
- (int)enableAudioVolumeIndication:(BOOL)enable interval:(uint64_t)interval;

/**
 * @if English
 * Enables volume indication for the speaker.
 * <br>The method allows the SDK to report to the app the information about the volume of the user that pushes local streams and the remote user (up to three users) that has the highest instantaneous volume. The information about the current speaker and the volume is reported.
 * <br>If this method is enabled, the SDK triggers {@link NERtcEngineDelegateEx#onRemoteAudioVolumeIndication:totalVolume:} based on the preset time intervals when a user joins a room and pushes streams. 
 * @since V4.6.10
 * @param enable    Specify whether to indicate the speaker volume.
 *                       - true: indicates the speaker volume.
 *                       - false: does not indicate the speaker volume.
 * @param interval  The time interval at which volume prompt is displayed. Unit: milliseconds. The value must be the multiples of 100 milliseconds. A value of 200 milliseconds is recommended.
 * @param enableVad Specify whether to monitor the voice capture.
 *                       - true: monitors the voice capture.
 *                       - false: does not monitor the voice capture.
 * @return 
 * - 0: success
 * - Others: failure
 * @endif
 * @if Chinese
 * 启用说话者音量提示。
 * <br>通过此接口可以实现允许 SDK 定期向 App 反馈房间内发音频流的用户和瞬时音量最高的远端用户（最多 3 位，包括本端）的音量相关信息，即当前谁在说话以及说话者的音量。
 * @since V4.6.10
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法在加入房间前后均可调用。
 * @par 业务场景
 * 适用于通过发言者的人声相关信息做出 UI 上的音量展示的场景，或根据发言者的音量大小进行视图布局的动态调整。
 *  @note
 *  - 该方法设置内部引擎为启用状态，该方法在 leaveChannel 后设置失效，将恢复至默认。如果您离开房间后重新加入房间，需要重新调用本接口。
 *  - 建议设置本地采集音量为默认值（100）或小于该值，否则可能会导致音质问题。
 *  - 该方法仅设置应用程序中的采集信号音量，不修改设备音量，也不会影响伴音、音效等的音量；若您需要修改设备音量，请调用设备管理相关接口。 
 
 * @par 参数说明 
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>enable</td>
 *      <td>BOOL</td>
 *      <td>是否启用说话者音量提示：<ul><li>YES：启用说话者音量提示。<li>NO：关闭说话者音量提示。</td>
 *  <tr>
 *      <td>interval</td>
 *      <td>uint64_t</td>
 *      <td>指定音量提示的时间间隔。单位为毫秒。必须设置为 100 毫秒的整数倍值，建议设置为 200 毫秒以上。</td>
 *  </tr>
 *  <tr>
 *      <td>enableVad</td>
 *      <td>BOOL</td>
 *      <td>是否启用本地采集人声监测：<ul><li>YES：启用本地采集人声监测。<li>NO：关闭本地采集人声监测。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //设置间隔为500ms的人声音量提示
 * [[NERtcEngine sharedEngine] enableAudioVolumeIndication:YES interval:500 enableVad:YES];
 * @endcode
 * @par 相关回调
 * 启用该方法后，只要房间内有发流用户，无论是否有人说话，SDK 都会在加入房间后根据预设的时间间隔触发 {@link NERtcEngineDelegateEx#onRemoteAudioVolumeIndication:totalVolume:} 回调。
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *         - 30003（kNERtcErrInvalidParam）：参数错误，比如时间间隔小于 100ms。
 * @endif
 */
- (int)enableAudioVolumeIndication:(BOOL)enable interval:(uint64_t)interval vad:(BOOL)enableVad;


#pragma mark - Signal Volume
/**
 * @if English
 * Adjusts the volume of captured signals.
 * @param volume The volume of captured signals. Valid values: 0 to 400. Where:
 * - 0: muted.
 * - 100: the original volume. This is the default value.
 * - 400: The maximum value can be four times the original volume. The limit value is protected.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 调节采集信号音量。
 * 通过本接口可以实现设置录制声音的信号幅度，从而达到调节采集音量的目的。
 * @since V3.5.0
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法在加入房间前后均可调用。
 * @note
 * - 该方法设置内部引擎为启用状态，在 leaveChannel 后设置失效，将恢复至默认。
 * - 建议设置本地采集音量为默认值（100）或小于该值，否则可能会导致音质问题。
 * - 该方法仅设置应用程序中的采集信号音量，不修改设备音量，也不会影响伴音、音效等的音量；若您需要修改设备音量，请调用设备管理相关接口。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>volume</td>
 *      <td>uint32_t</td>
 *      <td>采集信号音量，取值范围为 0 ~ 400。<ul><li>0：静音。<li>100（默认）：原始音量。<li>400：最大音量值（自带溢出保护）。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //将采集音量设置为100
 * [[NERtcEngine sharedEngine] adjustRecordingSignalVolume:100];
 * @endcode
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 * @endif
 */
- (int)adjustRecordingSignalVolume:(uint32_t)volume;

/**
 * @if English
 * Adjusts the playback signal volume of all remote users.
 * @param volume The playback signal volume. Valid range: 0 to 400. Where:
 * - 0: muted.
 * - 100: the original volume. This is the default value.
 * - 400: The maximum value can be four times the original volume. The limit value is protected.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 调节本地播放的所有远端用户的信号音量。
 * <br>通过此接口可以实现调节所有远端用户在本地播放的混音音量。
 * @since V3.5.0
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法在加入房间前后均可调用。
 * @note
 * 建议设置本地播放音量时使用默认值（100）或小于该值，否则可能会导致音质问题。
 * @par 参数说明 
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>volume</td>
 *      <td>uint32_t</td>
 *      <td>播放音量，取值范围为 [0,400]。<ul><li>0：静音。<li>100：原始音量。<li>400：最大可为原始音量的 4 倍（自带溢出保护）。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //调整所有远端用户在本地的播放音量为50
 * [[NERtcEngine sharedEngine] adjustPlaybackSignalVolume:50];
 * //调整所有远端用户在本地的播放音量为0，静音所有用户
 * [[NERtcEngine sharedEngine] adjustPlaybackSignalVolume:0];
 * @endcode
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *         - 30001（kNERtcErrFatal）：状态错误，比如引擎未初始化。
 * @endif
 */
- (int)adjustPlaybackSignalVolume:(uint32_t)volume;

/**
 * @if English
 * Adjust the volume of local signal playback from a specified remote user.
 * <br>After you join the room, you can call the method to set the volume of local audio playback from different remote users or repeatedly adjust the volume of audio playback from a specified remote user.
 * @note
 * - You can call this method after you join a room.
 * - The method is valid in the current call. If a remote user exits the room and rejoins the room again, the setting is still valid until the call ends.
 * - The method adjusts the volume of the mixing audio published by a specified remote user. Only one remote user can be adjusted. If you want to adjust multiple remote users, you need to call the method for the required times.
 * @param userID The ID of a remote user.
 * @param volume The playback volume. Valid values: 0 to 400.
                  - 0: muted
                  - 100: the original volume
 *                - 400: The maximum value can be four times the original volume. The limit value is protected.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 调节本地播放的指定远端用户的信号音量。
 * <br>通过此接口可以实现在通话过程中随时调节指定远端用户在本地播放的混音音量。
 * @since V4.2.1
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
 * @note
 * - 该方法设置内部引擎为启用状态，在 leaveChannel 后失效，但在本次通话过程中有效，比如指定远端用户中途退出房间，则再次加入此房间时仍旧维持该设置。
 * - 该方法每次只能调整一位远端用户的播放音量，若需调整多位远端用户在本地播放的音量，则需多次调用该方法。
 * @par 参数说明 
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>userID</td>
 *      <td>uint64_t</td>
 *      <td>远端用户 ID。</td>
 * </tr>
 *  <tr>
 *      <td>volume</td>
 *      <td>uint64_t</td>
 *      <td>播放音量，取值范围为 0 ~ 400。<ul><li>0：静音。<li>100（默认）：原始音量。<li>400：最大音量值（自带溢出保护）。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //调整uid为12345的用户在本地的播放音量为50
 * [[NERtcEngine sharedEngine] adjustUserPlaybackSignalVolume:50 forUserID:12345];
 * //调整uid为12345的用户在本地的播放音量为0，静音该用户
 * [[NERtcEngine sharedEngine] adjustUserPlaybackSignalVolume:0 forUserID:12345];
 * @endcode
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *         - 30001（kNERtcErrFatal）：状态错误，比如引擎未初始化。
 * @endif
 */
- (int)adjustUserPlaybackSignalVolume:(uint32_t)volume forUserID:(uint64_t)userID;

/**
 * @if Chinese
 * 调节本地播放的指定房间的所有远端用户的信号音量。
 * <br>通过此接口可以实现在通话过程中随时调节本地播放的指定房间内所有用户的混音音量。
 * @since V4.6.50
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，该方法可在加入房间前后调用。
 * @note
 * - 该方法设置内部引擎为启用状态，在 leaveChannel 后失效，但在本次通话过程中有效
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>volume</td>
 *      <td>uint64_t</td>
 *      <td>播放音量，取值范围为 [0,400]。<ul><li>0：静音。<li>100：原始音量。<li>400：最大可为原始音量的 4 倍（自带溢出保护）。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //调整该房间内的的用户在本地的播放音量为50
 * [[NERtcEngine sharedEngine] adjustChannelPlaybackSignalVolume:50];
 * //调整该房间内的用户在本地的播放音量为0，静音该房间
 * [[NERtcEngine sharedEngine] adjustChannelPlaybackSignalVolume:0];
 * @endcode
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *         - 30001（kNERtcErrFatal）：状态错误，比如引擎未初始化。
 * @endif
 */
- (int)adjustChannelPlaybackSignalVolume:(uint32_t)volume;

#pragma mark - Voice Effect

/**
 * @if English
 * Sets the voice pitch of the local audio.
 * <br>The method changes the voice pitch of the local speaker.
 * @note
 * - After the call ends, the setting changes back to the default value 1.0.
 * - The method conflicts with setAudioEffectPreset. After you call this method, the preset voice beautifier effect will be removed.
 * @param pitch The voice frequency. Valid values: 0.5 to 2.0. Smaller values have lower pitches. The default value is 1, which indicates that the pitch is not changed.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 设置本地语音音调。
 * <br>该方法改变本地说话人声音的音调。
 * @note
 * - 通话结束后该设置会重置，默认为 1.0。
 * - 此方法与 setAudioEffectPreset 互斥，调用此方法后，已设置的变声效果会被取消。
 * @param pitch 语音频率。可以在 [0.5, 2.0] 范围内设置。取值越小，则音调越低。默认值为 1.0，表示不需要修改音调。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)setLocalVoicePitch:(double)pitch;

/**
 * @if English
 * Sets the local voice equalization effect, or customizes center frequencies of the local voice effects.
 * @note You can call this method before or after you join a room. By default, the audio effect is disabled after the call ends.
 * @param bandFrequency The band frequency. Value range: 0 to 9. The values represent the respective 10-band center frequencies of the voice effects, including 31, 62, 125, 250, 500, 1k, 2k, 4k, 8k, and 16k Hz.
 * @param gain The gain of each band (dB). Value range: -15 to 15. The default value is 0.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 设置本地语音音效均衡，即自定义设置本地人声均衡波段的中心频率。
 * @note 该方法在加入房间前后都能调用，通话结束后重置为默认关闭状态。
 * @param bandFrequency 频谱子带索引，取值范围是 [0-9]，分别代表 10 个频带，对应的中心频率是 [31，62，125，250，500，1k，2k，4k，8k，16k] Hz。
 * @param gain 每个 band 的增益，单位是 dB，每一个值的范围是 [-15，15]，默认值为 0。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)setLocalVoiceEqualizationOfBandFrequency:(NERtcAudioEqualizationBandFrequency)bandFrequency withGain:(NSInteger)gain;

/**
 * @if English
 * Sets an SDK preset voice beautifier effect.
 * <br>The method can set an SDK preset voice beautifier effect for a local user who publishes an audio stream.
 * @note You can call this method before or after you join a room. By default, the audio effect is disabled after the call ends.
 * @param type The type of the preset voice beautifier effect. By default, the voice beautifier effect is disabled. For more information, see {@link NERtcVoiceBeautifierType}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 预设美声效果。
 * 通过此接口可以实现为本地发流用户设置 SDK 预设的人声美声效果。
 * @since V4.0.0
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法在加入房间前后均可调用。
 * @par 业务场景
 * 适用于多人语聊或 K 歌房中需要美化主播或连麦者声音的场景。
 * @note 该方法设置内部引擎为启用状态，在 {@link INERtcEngine#leaveChannel} 后设置失效，将恢复至默认。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>type</td>
 *      <td>{@link NERtcVoiceBeautifierType}</td>
 *      <td>预设的美声效果模式。默认值为 kNERtcVoiceBeautifierOff，即关闭美声效果。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine] setVoiceBeautifierPreset:kNERtcVoiceBeautifierKTV];
 * @endcode
 * @return
 * - 0（kNERtcNoError）：方法调用成功；
 * - 其他：方法调用失败。
 *         - 30003（kNERtcErrInvalidParam）：参数错误。
 * @endif
 */
- (int)setVoiceBeautifierPreset:(NERtcVoiceBeautifierType)type;

/**
 * @if English
 * Sets an SDK preset voice changer effect.
 * <br>The method can apply multiple preset voice changer effects to original human voices and change audio profiles.
 * @note
 * - You can call this method either before or after joining a room. By default, the audio effect is disabled after the call ends.
 * - The method conflicts with setLocalVoicePitch. After you call this method, the voice pitch is reset to the default value 1.0.
 * @param type The type of the preset voice changer effect. By default, the sound effect is disabled. For more information, see {@link NERtcVoiceChangerType}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 预设变声效果。
 * <br>通过此接口可以实现将人声原音调整为多种特殊效果，改变声音特性。
 * @since V4.1.0
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法在加入房间前后均可调用。
 * @note
 * - 该方法设置内部引擎为启用状态，在 {@link INERtcEngine#leaveChannel} 后设置失效，将恢复至默认，即关闭变声音效。
 * - 该方法和 {@link INERtcEngineEx#setLocalVoicePitch:} 方法互斥，调用了其中任一方法后，另一方法的设置会被重置为默认值。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>type</td>
 *      <td>{@link NERtcVoiceChangerType}</td>
 *      <td>预设的变声音效。默认关闭变声音效。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine] setAudioEffectPreset:kNERtcVoiceChangerRobot];
 * @endcode
 * @return
 * - 0（kNERtcNoError）：方法调用成功；
 * - 其他：方法调用失败。
 *         - 30003（kNERtcErrInvalidParam）：参数错误，比如设置的音效无效。
 * @endif
 */
- (int)setAudioEffectPreset:(NERtcVoiceChangerType)type;

/**
 * @if English
 * Sets the reverb effect for the local audio stream.
 * @note The method can be called before or after a user joins a room. The setting will be reset to the default value after a call ends.
 * @since V4.6.10
 * @param param For more information, see {@link NERtcReverbParam}.
 * @return 
 * - 0: success
 * - Others: failure
 * @endif
 * @if Chinese
 * 设置本地语音混响效果。
 * @note 该方法在加入房间前后都能调用，通话结束后重置为默认的关闭状态。
 * @since V4.6.10
 * @param param 详细信息请参考 {@link NERtcReverbParam}。
 * @return
 * - 0：方法调用成功。
 * - 其他：方法调用失败。
 * @endif
 */
- (int)setLocalVoiceReverbParam:(NERtcReverbParam *)param;

#pragma mark - WaterMark
/**
 * @if English
 * Sets a video watermark. The watermark takes effect for local preview and publishing.
 * @note If you set a watermark, we recommend you notice the status callback {@link NERtcEngineDelegateEx#onNERtcEngineLocalVideoWatermarkStateWithStreamType:state:}.
 * @since V4.6.10
 * @param type   The type of the video stream on which a watermark is applied, mainstream or substream. For more information, see {@link NERtcStreamChannelType}.
 * @param config Watermark configuration. If the value is set to null, all previous watermarks are canceled. For more information, see {@link NERtcVideoWatermarkConfig}.
 * @return
 * - 0: success
 * - Others: failure
 * @endif
 * @if Chinese
 * 设置视频水印。水印在本地预览及发送过程中均生效。
 * @note 设置水印后，建议关注水印状态回调 {@link NERtcEngineDelegateEx#onNERtcEngineLocalVideoWatermarkStateWithStreamType:state:}。
 * @since V4.6.10
 * @param type   水印的视频流类型。支持设置为主流或辅流。详细信息请参考 {@link NERtcStreamChannelType}。
 * @param config 水印设置。设置为 nil 表示取消之前的水印。详细信息请参考 {@link NERtcVideoWatermarkConfig}。
 * @return
 * - 0：方法调用成功。
 * - 其他：方法调用失败。
 * @endif
 */
- (int)setLocalVideoWatermarkConfigs:(nullable NERtcVideoWatermarkConfig *)config 
                      withStreamType:(NERtcStreamChannelType)type;

#pragma mark - Snapshot
/**
 * @if English
 * Takes a local video snapshot.
 * <br>The takeLocalSnapshot method takes a local video snapshot on the local mainstream or local substream. The callback that belongs to the NERtcTakeSnapshotCallback class returns the data of the snapshot image.
 * @note<br>
 * - Before you call the method to capture the snapshot from the mainstream, you must first call startVideoPreview or enableLocalVideo, and joinChannel.
 * - Before you call the method to capture the snapshot from the substream, you must first call joinChannel and startScreenCapture.
 * - You can set text, timestamp, and image watermarks at the same time. If different types of watermarks overlap, the layers overlay previous layers in the image, text, and timestamp sequence.
 * @param streamType The video stream type of the snapshot. You can set the value to mainstream or substream.
 * @param callback The snapshot callback.
 * @note The API is disabled in the audio-only SDK. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 本地视频画面截图。
 * <br>调用 takeLocalSnapshot 截取本地主流或本地辅流的视频画面，并通过 NERtcTakeSnapshotCallback 的回调返回截图画面的数据。
 * @note<br>
 * - 本地主流截图，需要在 enableLocalVideo 并 joinChannel 成功之后调用。
 * - 本地辅流截图，需要在 joinChannel 并 startScreenCapture 之后调用。
 * - 同时设置文字、时间戳或图片水印时，如果不同类型的水印位置有重叠，会按照图片、文本、时间戳的顺序进行图层覆盖。
 * @param streamType 截图的视频流类型。支持设置为主流或辅流。
 * @param callback 截图回调。
 * @note 纯音频SDK禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @return 操作返回值，成功则返回 
 * @endif
 */
- (int)takeLocalSnapshot:(NERtcStreamChannelType)streamType callback:(NERtcTakeSnapshotCallback)callback;

/**
 * @if English
 * Takes a snapshot of a remote video.
 * <br>The takeRemoteSnapshot method takes a snapshot from the remote video published through the mainstream or substream with a specified uid. The callback that belongs to the NERtcTakeSnapshotCallback class returns the data of the snapshot image.
 * @note<br>
 * - Before you call takeRemoteSnapshot, you must first call onUserVideoStart and onNERtcEngineUserSubStreamDidStartWithUserID.
 * - You can set text, timestamp, and image watermarks at the same time. If different types of watermarks overlap, the layers overlay previous layers in the image, text, and timestamp sequence.
 * @param userID The ID of a remote user.
 * @param streamType The video stream type of the snapshot. You can set the value to mainstream or substream.
 * @param callback The snapshot callback.
 * @note The API is disabled in the audio-only SDK. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 远端视频画面截图。
 * <br>调用 takeRemoteSnapshot 截取指定 uid 远端主流和远端辅流的视频画面，并通过 NERtcTakeSnapshotCallback 的回调返回截图画面的数据。
 * @note<br>
 * - takeRemoteSnapshot 需要在收到 onUserVideoStart 与 onNERtcEngineUserSubStreamDidStartWithUserID 回调之后调用。
 * - 同时设置文字、时间戳或图片水印时，如果不同类型的水印位置有重叠，会按照图片、文本、时间戳的顺序进行图层覆盖。
 * @param userID 远端用户 ID。
 * @param streamType 截图的视频流类型。支持设置为主流或辅流。
 * @param callback 截图回调。
 * @note 纯音频SDK禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)takeRemoteSnapshot:(NERtcStreamChannelType)streamType forUserID:(uint64_t)userID callback:(NERtcTakeSnapshotCallback)callback;

#pragma mark - Other
/**
 * @if English
 * Uploads the SDK information.
 * <br>The data that is published contains the log file and the audio dump file.
 * @note You must join a room before you can call the method.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 上传 SDK 信息。
 * <br>上传的信息包括 log 和 Audio dump 等文件。
 * @note 只能在加入房间后调用。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)uploadSdkInfo;

/**
 * @if Chinese
 * 上报自定义事件
 * @param eventName      事件名 不能为空
 * @param customIdentify 自定义标识，比如产品或业务类型，如不需要填null
 * @param param          参数键值对 ，参数值支持String 及java基本类型(int 、bool....) ， 如不需要填null
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)reportCustomEvent:(NSString *)eventName
          customIdentify:(NSString *)customIdentify
                   param:(NSDictionary *)param;

#pragma mark - SEI

/**
 * @if English
 * Sends supplemental enhancement information (SEI) data through a specified mainstream or substream.
 * <br>When you publish the local audio and video stream, SEI data is also sent to sync some additional information. After SEI data is sent, the receiver can retrieve the content by listening for the onRecvSEIMsg callback.
 * - Condition: After you publish the video stream using the mainstream and substream, you can invoke the method.
 * - Data limit in length: The SEI data can contain a maximum of 4,096 bytes in size. Sending an SEI message fails if the data exceeds the size limit. If a large amount of data is sent, the video bitrate rises. This degrades the video quality or causes frozen frames.
 * - Frequency limit: We recommend that the maximum video frame rate does not exceed 10 fps.
 * - Time to take effect: After the method is called, the SEI data is sent from the next frame in the fastest fashion or after the next 5 frames at the slowest pace.
 * @note
 * - The SEI data is transmitted together with the video stream. If video frame loss occurs due to poor connection quality, the SEI data will also get dropped. We recommend that you increase the frequency within the transmission limits. This way, the receiver can get the data.
 * - Before you specify a channel to transmit the SEI data, you must first enable the data transmission channel.
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @param data The custom SEI data.
 * @param type The type of the channel with which the SEI data is transmitted. For more information, see {@link NERtcStreamChannelType}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * - Success: The SEI data joins the queue and is ready for delivery. The data will be sent after the most recent video frame.
 * - Failure: If the data is restricted, the frequency may be too high, the queue is full, or the data exceeds the maximum value of 4k.
 * @endif
 * @if Chinese 
 * 指定主流或辅流通道发送媒体增强补充信息（SEI）。
 * <br>在本端推流传输音视频流数据同时，发送流媒体补充增强信息来同步一些其他附加信息。当推流方发送 SEI 后，拉流方可通过监听 onRecvSEIMsg 的回调获取 SEI 内容。
 * - 调用时机：视频流（主流、辅流）开启后，可调用此函数。
 * - 数据长度限制： SEI 最大数据长度为 4096 字节，超限会发送失败。如果频繁发送大量数据会导致视频码率增大，可能会导致视频画质下降甚至卡顿。
 * - 发送频率限制：最高为视频发送的帧率，建议不超过 10 次/秒。
 * - 生效时间：调用本接口之后，最快在下一帧视频数据帧之后发送 SEI 数据，最慢在接下来的 5 帧视频之后发送。
 * @note
 * - SEI 数据跟随视频帧发送，由于在弱网环境下可能丢帧，SEI 数据也可能随之丢失，所以建议在发送频率限制之内多次发送，保证接收端收到的概率。
 * - 指定通道发送 SEI 之前，需要提前开启对应的数据流通道。
 * - 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @param data 自定义 SEI 数据。
 * @param type  发送 SEI 时，使用的流通道类型。详细信息请参考 {@link NERtcStreamChannelType}。
 * @return 操作返回值，成功则返回 0
 * - 成功:  成功进入待发送队列，会在最近的视频帧之后发送该数据。
 * - 失败:  数据被限制发送，可能发送的频率太高，队列已经满了，或者数据大小超过最大值 4k。
 * @endif
 */
- (int)sendSEIMsg:(NSData *)data streamChannelType:(NERtcStreamChannelType)type;

/**
 * @if English
 * Sends SEI data through the mainstream.
 * <br>When you publish the local audio and video stream, SEI data is also sent to sync some additional information. After SEI data is sent, the receiver can retrieve the content by listening for the onRecvSEIMsg callback.
 * - Condition: After you publish the video stream using the mainstream and substream, you can invoke the method.
 * - Data limit in length: The SEI data can contain a maximum of 4,096 bytes in size. Sending an SEI message fails if the data exceeds the size limit. If a large amount of data is sent, the video bitrate rises. This degrades the video quality or causes broken video frames.
 * - Frequency limit: We recommend that the maximum video frame rate does not exceed 10 fps.
 * - Time to take effect: After the method is called, the SEI data is sent from the next frame in the fastest fashion or after the next 5 frames at the slowest pace.
 * @note
 * - The SEI data is transmitted together with the video stream. If video frame loss occurs due to poor connection quality, the SEI data will also get dropped. We recommend that you increase the frequency within the transmission limits. This way, the receiver can get the data.
 * - By default, the SEI is transmitted by using the mainstream.
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @param data The custom SEI data.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * -Success: The SEI data joins the queue and is ready for delivery. The data will be sent after the most recent video frame.
 * -Failure: If the data is restricted, the frequency may be too high, the queue is full, or the data size exceeds the maximum value of 4k
 * @endif
 * @if Chinese 
 * 通过主流通道发送媒体增强补充信息（SEI）。
 * <br>在本端推流传输音视频流数据同时，发送流媒体补充增强信息来同步一些其他附加信息。当推流方发送 SEI 后，拉流方可通过监听 onRecvSEIMsg 的回调获取 SEI 内容。
 * - 调用时机：视频流（主流、辅流）开启后，可调用此函数。
 * - 数据长度限制： SEI 最大数据长度为 4096 字节，超限会发送失败。如果频繁发送大量数据会导致视频码率增大，可能会导致视频画质下降甚至卡顿。
 * - 发送频率限制：最高为视频发送的帧率，建议不超过 10 次/秒。
 * - 生效时间：调用本接口之后，最快在下一帧视频数据帧之后发送 SEI 数据，最慢在接下来的 5 帧视频之后发送。
 * @note
 * - SEI 数据跟随视频帧发送，由于在弱网环境下可能丢帧，SEI 数据也可能随之丢失，所以建议在发送频率限制之内多次发送，保证接收端收到的概率。
 * - 调用本接口时，默认使用主流通道发送 SEI。
 * - 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @param data 自定义 SEI 数据。
 * @return 操作返回值，成功则返回 0
 * - 成功:  成功进入待发送队列，会在最近的视频帧之后发送该数据
 * - 失败:  数据被限制发送，可能发送的频率太高，队列已经满了，或者数据大小超过最大值 4k
 * @endif
 */
- (int)sendSEIMsg:(NSData *)data;

#pragma mark- MediaRelay

/**
 * @if English
 * Starts to relay media streams across rooms.
 * - The method can invite co-hosts across rooms. Media streams from up to four rooms can be relayed. A room can receive multiple relayed media streams.
 * - After you call the method, the SDK triggers onNERtcEngineChannelMediaRelayStateDidChange and onNERtcEngineDidReceiveChannelMediaRelayEvent. The callback reports the status and events about the current relayed media streams across rooms.
 * @note
 * - You can call this method after you join a room. Before you call the method, you must set the destination room by calling setDestinationInfo in the config parameter.
 * - The method is applicable only to the host in live streaming.
 * - If you want to call the method again, you must first call the stopChannelMediaRelay method to exit the current relay status.
 * - If you succeed in relaying the media stream across rooms, and want to change the destination room, for example, add or remove the destination room, you can call updateChannelMediaRelay to update the information about the destination room.
 * @param config The configuration for media stream relay across rooms. For more information, see {@link NERtcChannelMediaRelayConfiguration}.
 * @return A value of 0 returned indicates that the operation is successful. Otherwise, the operation fails.
 * @endif
 * @if Chinese 
 * 开始跨房间媒体流转发。
 * - 该方法可用于实现跨房间连麦等场景。支持同时转发到 4 个房间，同一个房间可以有多个转发进来的媒体流。
 * - 成功调用该方法后，SDK 会触发 onNERtcEngineChannelMediaRelayStateDidChange 和 onNERtcEngineDidReceiveChannelMediaRelayEvent 回调，并在回调中报告当前的跨房间媒体流转发状态和事件。
 * @note
 * - 请在成功加入房间后调用该方法。调用此方法前需要通过 config 中的 setDestinationInfo 设置目标房间。
 * - 该方法仅对直播场景下的主播角色有效。
 * - 成功调用该方法后，若您想再次调用该方法，必须先调用 stopChannelMediaRelay 方法退出当前的转发状态。
 * - 成功开始跨房间转发媒体流后，如果您需要修改目标房间，例如添加或删减目标房间等，可以调用方法 updateChannelMediaRelay 更新目标房间信息。
 * @param config 跨房间媒体流转发参数配置信息。详细信息请参考 {@link NERtcChannelMediaRelayConfiguration}。
 * @return 成功返回0，其他则失败
 * @endif
 */
- (int)startChannelMediaRelay:(NERtcChannelMediaRelayConfiguration *_Nonnull)config;

/**
 * @if English
 * Updates the information of the destination room for media stream relay.
 * <br>You can call this method to relay the media stream to multiple rooms or exit the current room.
 * - You can call this method to change the destination room, for example, add or remove the destination room.
 * - If you call this method, the SDK triggers the onNERtcEngineChannelMediaRelayStateDidChange callback. If NERtcChannelMediaRelayStateRunning is returned, the media stream relay is successful.
 * @note
 * - Before you call the method, you must join the room and call startChannelMediaRelay to relay the media stream across rooms. Before you call the method, you must set the destination room by calling setDestinationInfo in the config parameter.
 * - You can relay the media stream up to four destination rooms. You can first call removeDestinationInfoForChannelName that belongs to the NERtcChannelMediaRelayConfiguration class to remove the rooms that you have no interest in and add new destination rooms.
 * @param config The configuration for media stream relay across rooms. For more information, see {@link NERtcChannelMediaRelayConfiguration}.
 * @return A value of 0 returned indicates that the operation is successful. Otherwise, the operation fails.
 * @endif
 * @if Chinese 
 * 更新媒体流转发的目标房间。
 * <br>成功开始跨房间转发媒体流后，如果你希望将流转发到多个目标房间，或退出当前的转发房间，可以调用该方法。
 * - 成功开始跨房间转发媒体流后，如果您需要修改目标房间，例如添加或删减目标房间等，可以调用此方法。
 * - 成功调用此方法后，SDK 会触发 onNERtcEngineChannelMediaRelayStateDidChange 回调。如果报告 NERtcChannelMediaRelayStateRunning，则表示已成功转发媒体流。
 * @note
 * - 请在加入房间并成功调用 startChannelMediaRelay 开始跨房间媒体流转发后，调用此方法。调用此方法前需要通过 config 中的 setDestinationInfo 设置目标房间。
 * - 跨房间媒体流转发最多支持 4 个目标房间，您可以在调用该方法之前，通过 NERtcChannelMediaRelayConfiguration 中的 removeDestinationInfoForChannelName 方法移除不需要的房间，再添加新的目标房间。
 * @param config 跨房间媒体流转发参数配置信息。详细信息请参考 {@link NERtcChannelMediaRelayConfiguration}。
 * @return 成功返回0，其他则失败
 * @endif
 */
- (int)updateChannelMediaRelay:(NERtcChannelMediaRelayConfiguration *_Nonnull)config;

/**
 * @if English
 * Stops media stream relay across rooms.
 * <br>If the host leave the room, media stream replay across rooms automatically stops. You can also call stopChannelMediaRelay. In this case, the host leaves all destination rooms.
 * - If you call this method, the SDK triggers the onNERtcEngineChannelMediaRelayStateDidChange callback. If NERtcChannelMediaRelayStateRunning is returned, the media stream relay stops.
 * - If the operation fails, the SDK triggers the onNERtcEngineChannelMediaRelayStateDidChange callback that returns the status code NERtcChannelMediaRelayStateFailure.
 * @return A value of 0 returned indicates that the operation is successful. Otherwise, the operation fails.
 * @endif
 * @if Chinese
 * 停止跨房间媒体流转发。
 * <br>
 * 通常在主播离开房间时，跨房间媒体流转发会自动停止；您也可以根据需要随时调用该方法，此时主播会退出所有目标房间。
 * @since V4.2.1
 * @par 使用前提
 * 请在调用 {@link INERtcEngineEx#startChannelMediaRelay:} 方法开启跨房间媒体流转发之后调用此接口。
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine] stopChannelMediaRelay];
 * @endcode
 * @par 相关回调
 * {@link NERtcEngineDelegateEx#onNERtcEngineChannelMediaRelayStateDidChange:channelName:}：跨房间媒体流转发状态发生改变回调。成功调用该方法后会返回 NERtcChannelMediaRelayStateIdle，否则会返回 NERtcChannelMediaRelayStateFailure。
 * {@link NERtcEngineDelegateEx#onNERtcEngineDidReceiveChannelMediaRelayEvent:channelName:error:}：跨房间媒体流相关转发事件回调。成功调用该方法后会返回 NERtcChannelMediaRelayEventDisconnect，否则会返回 NERtcChannelMediaRelayEventFailure。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *         - 30001（kNERtcErrFatal）：通用错误。
 *         - 30005（kNERtcErrInvalidState）：状态错误，比如引擎未初始化。
 * @endif
 */
- (int)stopChannelMediaRelay;

/**
 * @if English
 * Enables or disables AI super resolution.
 * @since V4.4.0
 * @note 
 * - Before you enable the AI super resolution feature, contact technical support to activate the AI super resolution feature.
 * - AI super resolution is only valid for the following types of video streams:
 * - The first 360p video stream received by the local client.
 * - The camera feeds captured into the mainstream. The AI super-resolution feature does not currently support restoration and reconstruction of small streams and screen sharing in the substream.
 * @param enabled The option whether to enable AI super resolution. By default, the setting is disabled.
 * @return {@code 0} operation is successful. Otherwise, the operation fails.
 
 * @endif
 * @if Chinese 
 * 启用或停止 AI 超分。
 * @since V4.4.0
 * @note 
 * - 使用 AI 超分功能之前，请联系技术支持开通 AI 超分功能。
 * - AI 超分仅对以下类型的视频流有效：
 * - 必须为本端接收到第一路 360P 的视频流。
 * - 必须为摄像头采集到的主流大流视频。AI 超分功能暂不支持复原重建小流和屏幕共享辅流。
 * @param enabled 是否启用 AI 超分。默认为关闭状态。
 * @return {@code 0} 方法调用成功，其他调用失败
 * @endif
 */
- (int)enableSuperResolution:(BOOL)enabled;

/**
 * @if English
 * Turns on or off media stream encryption.
 * @since V4.4.0
 * In scenarios with high security requirements such as finance, you can use this method to set the media stream encryption mode before you join the room.
 * @note 
 * - You must call this method before you join the room, the encryption mode and key cannot be modified after you join the room. After you leave the room, the SDK will automatically turn off encryption. If you need to turn on encryption again, you need to call this method before you join the room again.
 * - In the same room, all users who enable media stream encryption must use the same encryption mode and key. Otherwise, an error kNERtcErrEncryptNotSuitable (30113) occurs if the members have different keys. 
 * - For security, we recommend that you replace the new key every time the media stream encryption is enabled.
 * @param enable The option whether to enable media stream encryption.
 *              - YES: enables media stream encryption.
 *              - NO: disables media stream encryption. This is the default value.
 * @param config The configuration for media stream relay. For more information,  see NERtcEncryptionConfig.
 * @return {@code 0} operation is successful. Otherwise, the operation fails.
 * @endif
 * @if Chinese 
 * 开启或关闭媒体流加密。
 * @since V4.4.0
 * 在金融行业等安全性要求较高的场景下，您可以在加入房间前通过此方法设置媒体流加密模式。
 * @note 
 * - 请在加入房间前调用该方法，加入房间后无法修改加密模式与密钥。用户离开房间后，SDK 会自动关闭加密。如需重新开启加密，需要在用户再次加入房间前调用此方法。
 * - 同一房间内，所有开启媒体流加密的用户必须使用相同的加密模式和密钥，否则使用不同密钥的成员加入房间时会报错 kNERtcErrEncryptNotSuitable（30113）。 
 * - 安全起见，建议每次启用媒体流加密时都更换新的密钥。
 * @param enable 是否开启媒体流加密。
 *                  - YES: 开启
 *                  - NO:（默认）关闭
 * @param config 媒体流加密方案。详细信息请参考 NERtcEncryptionConfig。
 * @return {@code 0} 方法调用成功，其他调用失败
 * @endif
 */
- (int)enableEncryption:(BOOL)enable config:(NERtcEncryptionConfig *)config;

#pragma mark - NetworkQualiityTest

/** 
 * @if English 
 * Starts the last-mile network probe test.
 * <br>This method starts the last-mile network probe test before joining a channel to get the uplink and downlink last mile network statistics, including the bandwidth, packet loss, jitter, and round-trip time (RTT).This method is used to detect network quality before a call. Before a user joins a room, you can use this method to estimate the subjective experience and objective network status of a local user during an audio and video call. 
 * Once this method is enabled, the SDK returns the following callbacks:
 * - `onNERtcEngineLastmileQuality`: the SDK triggers this callback within five seconds depending on the network conditions. This callback rates the network conditions with a score and is more closely linked to the user experience.
 * - `onNERtcEngineLastmileProbeTestResult`: the SDK triggers this callback within 30 seconds depending on the network conditions. This callback returns the real-time statistics of the network conditions and is more objective.
 * @note 
 * - You can call this method before joining a channel(joinChannel).
 * - Do not call other methods before receiving the onNERtcEngineLastmileQuality and onNERtcEngineLastmileProbeTestResult callbacks. Otherwise, the callbacks may be interrupted.
 * @since V4.5.0
 * @param config    Sets the configurations of the last-mile network probe test.
 * @endif
 * @if Chinese
 * 开始通话前网络质量探测。
 * <br>启用该方法后，SDK 会通过回调方式反馈上下行网络的质量状态与质量探测报告，包括带宽、丢包率、网络抖动和往返时延等数据。一般用于通话前的网络质量探测场景，用户加入房间之前可以通过该方法预估音视频通话中本地用户的主观体验和客观网络状态。
 * <br>相关回调如下：
 * - `onNERtcEngineLastmileQuality`：网络质量状态回调，以打分形式描述上下行网络质量的主观体验。该回调视网络情况在约 5 秒内返回。
 * - `onNERtcEngineLastmileProbeTestResult`：网络质量探测报告回调，报告中通过客观数据反馈上下行网络质量。该回调视网络情况在约 30 秒内返回。
 * @note 
 * - 请在加入房间（joinChannel）前调用此方法。
 * - 调用该方法后，在收到 onNERtcEngineLastmileQuality 和 onNERtcEngineLastmileProbeTestResult 回调之前请不要调用其他方法，否则可能会由于 API 操作过于频繁导致此方法无法执行。
 * @since V4.5.0
 * @param config    Last mile 网络探测配置。
 * @return
 * - 0: 方法调用成功
 * - 其他: 调用失败
 * @endif
 */
- (int)startLastmileProbeTest:(NERtcLastmileProbeConfig *_Nullable)config;

/** 
 * @if English 
 * Stops the last-mile network probe test.
 * @since V4.5.0
 * @return
 * - 0: Success.
 * - Other values: Failure.
 * @endif
 * @if Chinese
 * 停止通话前网络质量探测。
 * @since V4.5.0
 * @return
 * - 0: 方法调用成功
 * - 其他: 调用失败
 * @endif
 */
- (int)stopLastmileProbeTest;

#pragma mark -
/** 
 * @if English 
 * Create an IRtcChannel.
 * @param[in] channelName      The name of the room. Users that use the same name can join the same room. The name must be of STRING type and must be 1 to 64 characters in length. The following 89 characters are supported: a-z, A-Z, 0-9, space,!#$%&()+-:;≤.,>?@[]^_{|}~”.
 * @return IRtcChannel
 * @endif
 * @if Chinese
 * 创建一个 IRtcChannel 对象
 * @param[in] channelName      房间名。设置相同房间名称的用户会进入同一个通话房间。字符串格式，长度为1~ 64 字节。支持以下89个字符：a-z, A-Z, 0-9, space, !#$%&()+-:;≤.,>?@[]^_{|}~”
 * @return 返回 IRtcChannel 对象
 * - 0: 方法调用失败。
* @endif
*/
- (nullable NERtcChannel *)createChannel:(NSString *)channelName;

#pragma mark - Video Effect

/**
 * @if English
 * Check if video correction is enabled
 * @since V4.6.0
 * @note
 * - If you use a camera to shoot an object, a mapping process from 3D to 2D images is implemented. the image of an object is deformed when the position of the camera changes.
 * - If you enable video correction with appropriate parameters, video images can be restored by algorithms.
 * - To use video correction, the rendering mode of the local canvas must be set to fit. Video frames keeps aspect ratio unchanged and are all displayed in the current view. Otherwise, video correction may not take effect.
 * - If the parameters of video correction are applied, the local and remote video frames are all corrected
 * @param enable Enables or disables local video correction.
 * - true：enabled
 * - false (default): disabled
 * @return 
 * - 0: success.
 * - Others: failure
 * @endif
 * @if Chinese
 * 是否启用视频图像畸变矫正。
 * @since V4.6.0
 * @note
 * - 当使用相机去拍摄物体时，存在着一个从三维世界到二维图像的映射过程，这个过程中由于相机位置的变化和移动，会对拍摄物体的成像产生一定的形变影响。
 * - 开启该功能时，根据合适的参数，可以通过算法把这个形变进行复原。
 * - 使用该功能时，本地画布的渲染模式需要为 fit（即视频帧保持自身比例不变全部显示在当前视图中），否则矫正功能可能不会正常生效。
 * - 矫正参数生效后，本地画面和对端看到的画面，均会是矫正以后的画面。
 * @param enable 是否开启视频图像矫正。
 * - true：开启视频图像矫正。
 * - false（默认）：关闭视频图像矫正。
 * @return 
 * - 0：方法调用成功。
 * - 其他：方法调用失败。
 * @endif
 */
- (int)enableVideoCorrection:(BOOL)enable;

/**
 * @if English
 * Sets the parameters for video correction.
 * @since V4.6.0
 * @note
 * - The first 4 parameters of the config schema represent coordinates of areas to be corrected on the screen. The x and y coordinates of each point ranges from 0 to 1.
 * - The last 3 parameters are required only if external video rendering is used.
 * - You can pass nill in config. If config is set to nil, the SDK clears previous configurations for video correction. The video graph will be restored to the state without correction.
 * @param config Correction parameters. For more information, see {@link NERtcVideoCorrectionConfiguration}.
 * @return 
 * - 0: success.
 * - Others: failure
 * @endif
 * @if Chinese
 * 设置视频图像矫正参数。
 * @since V4.6.0
 * @note
 * - 矫正参数结构体的前 4 个参数，代表了待矫正区域相对于屏幕上视图的坐标，每个坐标点的 x 和 y 的取值范围均为 0 ~ 1 的浮点数。
 * - 矫正参数结构体的后 3 个参数只有在使用了外部视频渲染功能时才需要传入。
 * - config 可以传入 nil，清空之前设置过的矫正参数，将画面恢复至矫正之前的效果。
 * @param config 视频图像矫正相关参数。详细说明请参考 {@link NERtcVideoCorrectionConfiguration}。
 * @return 
 * - 0：方法调用成功。
 * - 其他：方法调用失败。
 * @endif
 */
- (int)setVideoCorrectionConfig:(nullable NERtcVideoCorrectionConfiguration *)config;

/**
 * @if English
 * Enables/Disables the virtual background.
 *
 * After enabling the virtual background feature, you can replace the original background image of the local user
 * with a custom background image. After the replacement, all users in the channel can see the custom background
 * image. You can find out from the
 * RtcEngineEventHandlerEx::onVirtualBackgroundSourceEnabled "onVirtualBackgroundSourceEnabled" callback
 * whether the virtual background is successfully enabled or the cause of any errors.
 * -  Recommends that you use this function in scenarios that meet the following conditions:
 * - A high-definition camera device is used, and the environment is uniformly lit.
 * - The captured video image is uncluttered, the user's portrait is half-length and largely unobstructed, and the
 * background is a single color that differs from the color of the user's clothing.
 * - The virtual background feature does not support video in the Texture format or video obtained from custom video capture by the Push method.
 * @since V4.6.1
 * @param enable Sets whether to enable the virtual background:
 * - true: Enable.
 * - false: Disable.
 * @param backData The custom background image. See NERtcVirtualBackgroundSource.
 * Note: To adapt the resolution of the custom background image to the resolution of the SDK capturing video,
 * the SDK scales and crops
 * the custom background image while ensuring that the content of the custom background image is not distorted.
 * @return
 * - 0: Success.
 * - < 0: Failure.
 * @endif
 * @if Chinese
 * 开启/关闭虚拟背景。
 * <br>启用虚拟背景功能后，您可以使用自定义背景图片替换本地用户的原始背景图片。
 * <br>替换后，频道内所有用户都可以看到自定义背景图片。
 * @note 
 * - 您可以通过 {@link NERtcEngineDelegateEx#onNERtcEngineVirtualBackgroundSourceEnabled:reason:} 回调查看虚拟背景是否开启成功或出错原因。
 * - 建议您在满足以下条件的场景中使用该功能：
 *    - 采用高清摄像设备，环境光线均匀。
 *    - 捕获的视频图像整洁，用户肖像半长且基本无遮挡，并且背景是与用户衣服颜色不同的单一颜色。
 * - 虚拟背景功能不支持在 Texture 格式的视频或通过 Push 方法从自定义视频源获取的视频中设置虚拟背景。
 * - 若您设置背景图片为自定义本地图片，SDK 会在保证背景图片内容不变形的前提下，对图片进行一定程度上的缩放和裁剪，以适配视频采集分辨率。
 * @since V4.6.10
 * @param enable 设置是否开启虚拟背景。
 * - true：开启。
 * - false: 关闭。
 * @param backData 自定义背景图片。详细信息请参考 {@link NERtcVirtualBackgroundSource}。
 * @return
 * - 0：方法调用成功。
 * - 其他：方法调用失败。
 * @endif
 */
- (int)enableVirtualBackground:(BOOL)enable backData:(NERtcVirtualBackgroundSource *_Nullable)backData;

#pragma mark - Cloud Proxy

/**
 * @if English
 * Sets the Agora cloud proxy service.
 * <br>When the user's firewall restricts the IP address and port, refer to Use Cloud Proxy to add the specific IP addresses and ports to the firewall whitelist; then, call this method to enable the cloud proxy and set the proxyType parameter as NERtcTransportTypeUDPProxy(1), which is the cloud proxy for the UDP protocol.
 * - After a successfully cloud proxy connection, the SDK triggers the `onNERtcEngineConnectionStateChangeWithState(kNERtcConnectionStateConnecting, kNERtcReasonConnectionChangedSettingProxyServer)` callback.
 * - To disable the cloud proxy that has been set, call setCloudProxy(NERtcTransportTypeNoneProxy).
 * @note We recommend that you call this method before joining the channel or after leaving the channel.
 * @param proxyType The cloud proxy type. For more information, see {@link NERtcTransportType}. This parameter is required, and the SDK reports an error if you do not pass in a value.
 * @return A value of 0 returned indicates that the method call is successful. Otherwise, the method call fails.
 * @endif
 * @if Chinese
 * 开启并设置云代理服务。
 * <br>在内网环境下，如果用户防火墙开启了网络限制，请参考《使用云代理》将指定 IP 地址和端口号加入防火墙白名单，然后调用此方法开启云代理，并将 proxyType 参数设置为 NERtcTransportTypeUDPProxy(1)，即指定使用 UDP 协议的云代理。
 * - 成功连接云代理后，SDK 会触发 `onNERtcEngineConnectionStateChangeWithState(kNERtcConnectionStateConnecting, kNERtcReasonConnectionChangedSettingProxyServer)` 回调。
 * - 如果需要关闭已设置的云代理，请调用 `setCloudProxy(NERtcTransportTypeNoneProxy)`。
 * @note 请在加入房间前调用此方法。
 * @param proxyType 云代理类型。详细信息请参考 {@link NERtcTransportType}。该参数为必填参数，若未赋值，SDK 会报错。
 * @return {@code 0} 方法调用成功，其他失败。
 * @endif
 */
- (int)setCloudProxy:(NERtcTransportType)proxyType;

/**
 * @if English
 * Synchronizes the local time with the server time
 * @since V4.6.10
 * @param enable specifies whether to enable precise synchronization of the local time with the server time.
 * - true: enables the precise synchronization
 * - false: disables the precise synchronization.
 * @return 
 * - 0: success
 * - Others: failure
 * @endif
 * @if Chinese
 * 开启精准对齐。
 * 通过此接口可以实现精准对齐功能，对齐本地系统与服务端的时间。
 * @since V4.6.10
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间前调用。
 * @par 业务场景
 * 适用于 KTV 实时合唱的场景。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>enable</td>
 *      <td>BOOL</td>
 *      <td>是否开启精准对齐功能：<ul><li>YES：开启精准对齐功能。<li>NO：关闭精准对齐功能。</td>
 *  </tr>
 * </table> 
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine] setStreamAlignmentProperty:YES];
 * @endcode
 * @par 相关接口
 * 可以调用 {@link INERtcEngineEx#getNtpTimeOffset} 方法获取本地系统时间与服务端时间的差值。
 * @return 无返回值。
 * @endif
 */
- (void)setStreamAlignmentProperty:(BOOL)enable;

/**
 * @if English
 * Gets the difference between the local time and the server time.
 * <br>The method can sync the time between the client and server. To get the current server time, call (System.currentTimeMillis() - offset).
 * @since V4.6.10
 * @return Difference between the local time and the server time. Unit: milliseconds(ms). If a user fails to join a room, a value of 0 is returned.
 * @endif
 * @if Chinese
 * 获取本地系统时间与服务端时间差值。
 * <br>可以用于做时间对齐，通过 (毫秒级系统时间 - offset) 可能得到当前服务端时间。
 * @since V4.6.10
 * @return 本地与服务端时间差值，单位为毫秒（ms）。如果没有成功加入音视频房间，返回 0。
 * @endif
 */
- (int64_t)getNtpTimeOffset;

#pragma mark - encoder & decoder

/**
 * @if Chinese 
 * 注册解码前媒体数据观测器。
 * - 通过此接口可以设置 {@link NERtcEnginePreDecodeObserver#onNERtcEnginePreDecoderFrame:} 回调监听，返回相关解码前媒体数据。
 * @since V4.6.29
 * @par 使用前提
 * 若您需要接收未解码的视频数据，建议先调用 {@link INERtcEngine#setParameters:} 接口关闭 SDK 的视频解码功能。
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法在加入房间前后均可调用。
 * @par 业务场景
 * 适用于需要自行处理音、视频数据的解码与渲染的场景。
 * @note
 * 目前仅支持传输 OPUS 格式的音频数据和 H.264 格式的视频数据。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>observer</td>
 *      <td>{@link NERtcEnginePreDecodeObserver}</td>
 *      <td> 接口对象实例。可以传 nil 表示取消注册。</td>
 *  </tr>
 * </table>     
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine] setPreDecodeObserver:Observer];
 * @endcode
 * @par 相关回调
 * {@link NERtcEnginePreDecodeObserver#onNERtcEnginePreDecoderFrame:}：返回相关解码前媒体数据，包括用户的 UID、媒体数据类型、数据长度等。
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 * @endif
 */
- (int)setPreDecodeObserver:(nullable id<NERtcEnginePreDecodeObserver>)observer;


/**
 * @if Chinese 
 * 注册视频编码 QoS 信息监听器。
 * - 通过此接口可以设置 {@link NERtcEngineVideoEncoderQosObserver#onNERtcEngineRequestSendKeyFrame:}、{@link NERtcEngineVideoEncoderQosObserver#onNERtcEngineVideoCodecUpdated:videoStreamType:}、{@link NERtcEngineVideoEncoderQosObserver#onNERtcEngineBitrateUpdated:videoStreamType:} 回调监听，并通过返回的相关视频编码数据调整视频编码策略。
 * @since V4.6.29
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法在加入房间前后均可调用。
 * @par 业务场景
 * 适用于需要自行处理视频数据的采集与编码的场景。
 * @note
 * 该方法设置内部引擎为启用状态，在 {@link INERtcEngine#leaveChannel} 后仍然有效；如果需要关闭该功能，需要在下次通话前调用此接口关闭视频编码 QoS 信息监听。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>encoderQosObserver</td>
 *      <td>{@link NERtcEngineVideoEncoderQosObserver}</td>
 *      <td> 接口对象实例。可以传 nil 表示取消注册。</td>
 *  </tr>
 * </table>     
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine] setVideoEncoderQosObserver:observer];
 * @endcode
 * @par 相关回调
 * {@link NERtcEngineVideoEncoderQosObserver#onNERtcEngineRequestSendKeyFrame:}：I 帧请求回调。
 * {@link NERtcEngineVideoEncoderQosObserver#onNERtcEngineVideoCodecUpdated:videoStreamType:}：码率信息回调。
 * {@link NERtcEngineVideoEncoderQosObserver#onNERtcEngineBitrateUpdated:videoStreamType:}：视频编码器类型信息回调。
 * @return 
 * - 0（OK）：方法调用成功。
 * - 其他：方法调用失败。
 * @endif
 */
- (int)setVideoEncoderQosObserver:(nullable id<NERtcEngineVideoEncoderQosObserver>)encoderQosObserver;

/**
 * @if Chinese 
 * 推送外部音频主流编码帧。
 * - 通过此接口可以实现通过主流音频通道推送外部音频编码后的数据。
 * @since V4.6.29
 * @par 使用前提
 * 该方法仅在设置 {@link INERtcEngineEx#setExternalAudioSource:sampleRate:channels:} 接口的 enabled 参数为 YES 后调用有效。
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
 * @par 业务场景
 * 适用于需要自行处理音频数据的采集与编码的场景。
 * @note
 * - 目前仅支持传输 OPUS 格式的音频数据。
 * - 建议不要同时调用 {@link INERtcEngineEx#pushExternalAudioFrame:} 方法。
 * - 该方法在音频输入设备关闭后，例如在关闭本地音频、通话结束、通话前麦克风设备测试关闭等情况下，设置会恢复至默认。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>encodedAudioFrame</td>
 *      <td>NERtcAudioEncodedFrame *</td>
 *      <td>编码后的音频帧数据。</td>
 *  </tr>
 * </table>     
 * @par 示例代码
 * @code
 * NERtcAudioEncodedFrame *audioFrame = [[NERtcAudioEncodedFrame alloc] init];
 * audioFrame.sampleRate = 采样率
 * audioFrame.channels = 声道数
 * audioFrame.samplesPerChannel = 每个声道的样本数
 * audioFrame.payloadType = 数据类型，详见枚举 NERtcPayLoadType
 * audioFrame.timeStampUs = 时间戳
 * audioFrame.encodedTimestamp = 编码时间戳
 * [[NERtcEngine sharedEngine] pushExternalAudioEncodedFrame:audioFrame];
 * @endcode
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *         - 30001（kNERtcErrFatal）：未开启外部音频输入。
 *         - 30003（kNERtcErrInvalidParam）：参数错误，比如传入对象为空。
 *         - 30005（kNERtcErrInvalidState）：状态错误，比如引擎尚未初始化。
 * @endif
 */
- (int)pushExternalAudioEncodedFrame:(NERtcAudioEncodedFrame *)encodedAudioFrame;

/**
 * @if Chinese 
 * 推送外部音频辅流编码帧。
 * - 通过此接口可以实现通过辅流音频通道推送外部音频编码后的数据。
 * @since V4.6.29
 * @par 使用前提
 * 该方法仅在设置 {@link INERtcEngineEx#setExternalSubStreamAudioSource:sampleRate:channels:} 接口的 enabled 参数为 YES 后调用有效。
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
 * @par 业务场景
 * 适用于需要自行处理音频数据的采集与编码的场景。
 * @note
 * - 目前仅支持传输 OPUS 格式的音频数据。
 * - 建议不要同时调用 {@link INERtcEngineEx#pushExternalSubStreamAudioFrame:} 方法。
 * - 该方法在音频输入设备关闭后，例如在关闭本地音频、通话结束、通话前麦克风设备测试关闭等情况下，设置会恢复至默认。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>encodedAudioFrame</td>
 *      <td>NERtcAudioEncodedFrame *</td>
 *      <td>编码后的音频帧数据。</td>
 *  </tr>
 * </table>     
 * @par 示例代码
 * @code
 * NERtcAudioEncodedFrame *subAudioFrame = [[NERtcAudioEncodedFrame alloc] init];
 * subAudioFrame.sampleRate = 采样率
 * subAudioFrame.channels = 声道数
 * subAudioFrame.samplesPerChannel = 每个声道的样本数
 * subAudioFrame.payloadType = 数据类型，详见枚举 NERtcPayLoadType
 * subAudioFrame.timeStampUs = 时间戳
 * subAudioFrame.encodedTimestamp = 编码时间戳
 * [[NERtcEngine sharedEngine] pushExternalSubStreamAudioEncodedFrame:subAudioFrame];
 * @endcode
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *         - 30001（kNERtcErrFatal）：未开启外部音频输入。
 *         - 30003（kNERtcErrInvalidParam）：参数错误，比如传入对象为空。
 *         - 30005（kNERtcErrInvalidState）：状态错误，比如引擎尚未初始化。
 * @endif
 */
- (int)pushExternalSubStreamAudioEncodedFrame:(NERtcAudioEncodedFrame *)encodedAudioFrame;

/**
 * @if Chinese 
 * 推送外部视频编码帧。
 * - 通过此接口可以实现通过主流视频通道推送外部视频编码后的数据。
 * @since V4.6.29
 * @par 使用前提
 * 该方法仅在设置 {@link INERtcEngineEx#setExternalVideoSource:streamType:} 接口的 enable 参数为 YES 后调用有效。
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
 * @par 业务场景
 * 适用于需要自行处理视频数据的采集与编码的场景。
 * @note
 * - 目前仅支持传输 H.264 格式的视频数据。
 * - 该方法设置内部引擎为启用状态，在 {@link INERtcEngine#leaveChannel} 后设置会重置为默认状态。
 * - 建议先调用 {@link INERtcEngineEx#enableDualStreamMode:} 方法关闭视频大小流功能，否则远端可能无法正常接收下行流。
 * - 建议不要同时调用 {@link INERtcEngineEx#pushExternalVideoFrame:} 方法。
 * - 外部视频源数据的输入通道、本地视频采集通道与外部视频编码帧数据的推送通道必须同为主流或者辅流通道，否则 SDK 会报错。
 * - 暂不支持同时开启视频主、辅流通道推送外部视频编码帧数据。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>encodedVideoFrame</td>
 *      <td>NERtcVideoEncodedFrame *</td>
 *      <td>编码后的视频帧数据。</td>
 *  </tr>
 * </table>     
 * @par 示例代码
 * @code
 * NERtcVideoEncodedFrame *frame = [[NERtcVideoEncodedFrame alloc] init];
 * frame.frameType = 帧类型;
 * frame.width = 视频宽;
 * frame.height = 视频高;
 * frame.codecType = 视频编码类型;
 * frame.timestampUs = 时间戳;
 * frame.nalData = 帧数据;
 * frame.nalLengths = lengthArray;
 * [[NERtcEngine sharedEngine] pushExternalVideoEncodedFrame:frame];
 * @endcode
 * @par 相关接口
 * 可以调用 {@link INERtcEngineEx#setVideoEncoderQosObserver:} 接口设置视频编码 QoS 信息监听器，通过回调的数据信息调整编码策略。
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *         - 30001（kNERtcErrFatal）：未开启视频。
 *         - 30003（kNERtcErrInvalidParam）：参数错误，比如传入对象为空。
 *         - 30005（kNERtcErrInvalidState）：状态错误，比如引擎未初始化或未开启外部视频输入。
 * @endif
 */
- (int)pushExternalVideoEncodedFrame:(NERtcVideoEncodedFrame *)encodedVideoFrame;

/**
 * @if Chinese
 * 推送外部视频编码帧。
 * - 通过此接口可以实现通过辅流视频通道推送外部视频编码后的数据。
 * @since V4.6.29
 * @par 使用前提
 * 该方法仅在设置 {@link INERtcEngineEx#setExternalVideoSource:streamType:} 接口的 enable 参数为 YES 后调用有效。
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
 * @par 业务场景
 * 适用于需要自行处理视频数据的采集与编码的场景。
 * @note
 * - 目前仅支持传输 H.264 格式的视频数据。
 * - 该方法设置内部引擎为启用状态，在 {@link INERtcEngine#leaveChannel} 后设置会重置为默认状态。
 * - 建议先调用 {@link INERtcEngineEx#enableDualStreamMode:} 方法关闭视频大小流功能，否则远端可能无法正常接收下行流。
 * - 建议不要同时调用 {@link INERtcEngineEx#pushExternalVideoFrame:} 方法。
 * - 外部视频源数据的输入通道、本地视频采集通道与外部视频编码帧数据的推送通道必须同为主流或者辅流通道，否则 SDK 会报错。
 * - 暂不支持同时开启视频主、辅流通道推送外部视频编码帧数据。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>encodedVideoFrame</td>
 *      <td>NERtcVideoEncodedFrame *</td>
 *      <td>编码后的视频帧数据。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * NERtcVideoEncodedFrame *frame = [[NERtcVideoEncodedFrame alloc] init];
 * frame.frameType = 帧类型;
 * frame.width = 视频宽;
 * frame.height = 视频高;
 * frame.codecType = 视频编码类型;
 * frame.timestampUs = 时间戳;
 * frame.nalData = 帧数据;
 * frame.nalLengths = lengthArray;
 * [[NERtcEngine sharedEngine] pushExternalVideoEncodedFrame:frame];
 * @endcode
 * @par 相关接口
 * 可以调用 {@link INERtcEngineEx#setVideoEncoderQosObserver:} 接口设置视频编码 QoS 信息监听器，通过回调的数据信息调整编码策略。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *         - 30001（kNERtcErrFatal）：未开启视频。
 *         - 30003（kNERtcErrInvalidParam）：参数错误，比如传入对象为空。
 *         - 30005（kNERtcErrInvalidState）：状态错误，比如引擎未初始化或未开启外部视频输入。
 * @endif
 */
- (int)pushExternalSubStreamVideoEncodedFrame:(NERtcVideoEncodedFrame *)encodedVideoFrame;


@end

NS_ASSUME_NONNULL_END

#pragma clang diagnostic pop

#endif /* INERtcEngineEx_h */
