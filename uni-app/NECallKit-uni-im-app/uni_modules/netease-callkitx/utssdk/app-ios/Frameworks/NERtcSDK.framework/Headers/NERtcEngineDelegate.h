/*
 * Copyright (c) 2021 NetEase, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "NERtcEngineErrorCode.h"
#import "NERtcEngineEnum.h"
#import "NERtcEngineBase.h"
#import <CoreVideo/CoreVideo.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"


NS_ASSUME_NONNULL_BEGIN

/**
 * @if English 
 * NERtcEngine Frequently used callbacks
 * @endif
 * @if Chinese
 * NERtcEngine 常用回调
 * @endif
 */
@protocol NERtcEngineDelegate <NSObject>

@optional

/**
 * @if English 
 * Occurs when an error occurs.
 * The callback is triggered to report an error related to network or media during SDK runtime.
 * In most cases, the SDK cannot fix the issue and resume running. The SDK requires the app to take action or informs the user of the issue.
 * @param errCode The error code. For more information, see {@link NERtcEngineErrorCode.NERtcError}.
 * @endif
 * @if Chinese
 * 发生错误回调。
 * 该回调方法表示 SDK 运行时出现了网络或媒体相关的错误。
 * 通常情况下，SDK上报的错误意味着 SDK 无法自动恢复，需要 App 干预或提示用户。
 * @param errCode 错误码。详细信息请参考 {@link NERtcEngineErrorCode.NERtcError}。
 * @endif
 */
- (void)onNERtcEngineDidError:(NERtcError)errCode;

 /**
  * @if English 
  * Occurs when a warning occurs.
  * The callback is triggered to report a warning related to network or media during SDK runtime.
  * In most cases, the SDK cannot fix the issue and resume running. The SDK requires the app to take action or informs the user of the issue.
  * @since V4.3.0
  * @param warnCode The warn code. For more information, see {@link NERtcWarning}.
  * @param msg The warning description.
  * @endif
  * @if Chinese
  * 发生警告回调。
  * 该回调方法表示 SDK 运行时出现了网络或媒体相关的警告。
  * 通常情况下，SDK上报的警告意味着 SDK 无法自动适配，需要 App 干预或提示用户。
  * @since V4.3.0
  * @param warnCode 错误码。详细信息请参考 {@link NERtcWarning}。
  * @param msg 警告描述。
  * @endif
  */
- (void)onNERtcEngineDidWarning:(NERtcWarning)warnCode msg:(NSString *)msg;

- (void)onNERtcEngineApiDidExecuted:(NSString *)apiName errCode:(NERtcError)errCode msg:(NSString *)msg;

  /**
   * @if English 
   * Occurs when the state of the network connection between the SDK and the server changes.
   * The callback is triggered when the state of the network connection changes. The callback returns the current state of connection and the reason why the network state changes.
   * @param state The state of the current connection. For more information, see {@link NERtcConnectionStateType}.
   * @param reason The reason why the state changes. For more information, see {@link NERtcReasonConnectionChangedType}.
   * @endif
   * @if Chinese
   * SDK和服务端的连接状态已改变回调。
   * 该回调在 SDK 和服务端的连接状态发生改变时触发，并告知用户当前的连接状态和引起状态改变的原因。
   * @param state 当前的连接状态。详细信息请参考  {@link NERtcConnectionStateType}。
   * @param reason 引起当前连接状态改变的原因。详细信息请参考 {@link NERtcReasonConnectionChangedType}。
   * @endif
   */
- (void)onNERtcEngineConnectionStateChangeWithState:(NERtcConnectionStateType)state
                                             reason:(NERtcReasonConnectionChangedType)reason;

   /**
    * @if English 
    * Occurs when a user leaves a room.
    * After an app invokes the leaveChannel method, SDK prompts whether the app successfully leaves the room. 
    * @param result The result of the leaveChannel operation. For more information, see {@link NERtcEngineErrorCode.NERtcError}.
    * @endif
    * @if Chinese
    * 退出房间回调。
    * App 调用 leaveChannel 方法后，SDK 提示 App 退出房间是否成功。 
    * @param result 退出房间结果。详细信息请参考  {@link NERtcEngineErrorCode.NERtcError}。在快速切换房间时 code 为 kNERtcErrChannelLeaveBySwitchAction。

    * @endif
    */
- (void)onNERtcEngineDidLeaveChannelWithResult:(NERtcError)result;

   /**
    * @if English 
    * After the connection breaks down and the SDK fails to connect to the server three consecutive times.
    * @note
    * - The callback is triggered if the SDK fails to connect to the server three consecutive times after you successfully call the joinChannel method.
    * - If the SDK fails to connect to the server three consecutive times, the SDK stops retries.
    * @param reason The reason why the network is disconnected. For more information, see {@link NERtcEngineErrorCode.NERtcError}.
    * @endif
    * @if Chinese
    * 与服务器连接中断，可能原因包括：网络连接失败、服务器关闭该房间、用户被踢出房间等。
    * @note
    * SDK 在调用 joinChannel 加入房间成功后，如果和服务器失去连接，就会触发该回调。
    * @param reason 网络连接中断原因。详细信息请查看  {@link NERtcEngineErrorCode.NERtcError}。
    * @endif
    */
- (void)onNERtcEngineDidDisconnectWithReason:(NERtcError)reason;

   /**
    * @if English 
    * Occurs when a user rejoins a room.
    * If a client is disconnected from the server due to poor network quality, the SDK starts reconnecting. If the client and server are reconnected, the callback is triggered.
    * @param result The result of reconnection. For more information, see {@link NERtcEngineErrorCode.NERtcError}.
    * @endif
    * @if Chinese
    * 重新加入房间回调。
    * 在弱网环境下，若客户端和服务器失去连接，SDK会自动重连。自动重连成功后触发此回调方法。
    * @param result 重连结果。详细信息请参考 {@link NERtcEngineErrorCode.NERtcError}。
    * @endif
    */
  - (void)onNERtcEngineRejoinChannel:(NERtcError)result;

   /**
    * @if English 
    * Occurs when a remote user joins the current room.
    * The callback prompts that a remote user joins the room and returns the ID of the user that joins the room. If the user ID already exists, the remote user also receives a message that the user already joins the room, which is returned by the callback.
    * The callback is triggered in the following cases:
    * - A remote user joins the room by calling the joinChannel method.
    * - A remote user rejoins the room after the client is disconnected.
    * @param userID The ID of a remote user.
    * @param userName The name of the user who joins the room. The field is deprecated. Ignore the field.
    * @endif
    * @if Chinese
    * 远端用户加入当前房间回调。
    * 该回调提示有远端用户加入了房间，并返回新加入用户的 ID；如果加入之前，已经有其他用户在房间中了，新加入的用户也会收到这些已有用户加入房间的回调。

    * 该回调在如下情况下会被触发：
    * - 远端用户调用 joinChannelWithToken 方法加入房间。
    * - 远端用户网络中断后重新加入房间。
    * @note
    * 直播场景下：
      * - 主播间能相互收到新主播加入频道的回调，并能获得该主播的用户 ID。
      * - 观众也能收到新主播加入频道的回调，并能获得该主播的用户 ID。
      * - 当 Web 端加入直播频道时，只要 Web 端有推流，SDK 会默认该 Web 端为主播，并触发该回调。
    * @param userID   用户 ID。
    * @param userName 新加入房间的远端用户名。废弃字段，无需关注。
    * @endif
    */
  - (void)onNERtcEngineUserDidJoinWithUserID:(uint64_t)userID userName:(NSString *)userName;

  /**
   * @if English
   * Occurs when a remote user joins the current room.
   * The callback prompts that a remote user joins the room and returns the ID of the user that joins the room. If the user ID already exists, the remote user also receives a message that the user already joins the room, which is returned by the callback.
   * The callback is triggered in the following cases:
   * - A remote user joins the room by calling the joinChannel method.
   * - A remote user rejoins the room after the client is disconnected.
   * @param userID The ID of a remote user.
   * @param userName The name of the user who joins the room. The field is deprecated. Ignore the field.
   * @endif
   * @if Chinese
   * 远端用户加入房间事件回调。
   * - 远端用户加入房间或断网重连后，SDK 会触发该回调，可以通过返回的用户 ID 订阅对应用户发布的音、视频流。
   *      - 通信场景下，该回调通知有远端用户加入了房间，并返回新加入用户的 ID；若该用户加入之前，已有其他用户在房间中，该新加入的用户也会收到这些已有用户加入房间的回调。
   *      - 直播场景下，该回调通知有主播加入了房间，并返回该主播的用户 ID；若该用户加入之前，已经有主播在频道中了，新加入的用户也会收到已有主播加入房间的回调。
   * @since V4.6.29
   * @par 使用前提
   * 请在 NERtcEngineDelegate 接口类中通过 {@link INERtcEngine#setupEngineWithContext:} 接口设置回调监听。
   * @note
   * - 同类型事件发生后，{@link NERtcEngineDelegate#onNERtcEngineUserDidJoinWithUserID:userName:} 回调可能会与该回调同时触发，建议您仅注册此回调，不能同时处理两个回调。
   * - 当 Web 端用户加入直播场景的房间中，只要该用户发布了媒体流，SDK 会默认该用户为主播，并触发此回调。
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
   *      <td>新加入房间的远端用户 ID。</td>
   *  </tr>
   *  <tr>
   *      <td>joinExtraInfo</td>
   *      <td>NERtcUserJoinExtraInfo *</td>
   *      <td>该远端用户加入的额外信息。</td>
   *  </tr>
   * </table> 
   * @endif
   */
- (void)onNERtcEngineUserDidJoinWithUserID:(uint64_t)userID userName:(NSString *)userName joinExtraInfo:(nullable NERtcUserJoinExtraInfo *)joinExtraInfo;


   /**
    * @if English 
    * Occurs when a remote user leaves a room.
    * A message is returned that a remote user leaves the room or becomes disconnected. A user leaves a room due to the following reasons: the user exit the room or connections time out.
    * - If a user leaves the room, the remote user receives a message that indicates that the user leaves the room.
    * - If the connection times out, and the user does not receive data packets for a time period of 40 to 50 seconds, then the user becomes disconnected.
    * @param userID The ID of the user that leaves the room.
    * @param reason The reason why the remote user leaves. For more information, see {@link NERtcSessionLeaveReason}.
    * @endif
    * @if Chinese
    * 远端用户离开当前房间回调。
    * 提示有远端用户离开了房间（或掉线）。用户离开房间有两个原因，即正常离开和超时掉线：
    * - 正常离开的时候，远端用户会收到相关消息消息，判断用户离开房间。
    * - 超时掉线的依据是，在一定时间内（40~50s），用户没有收到对方的任何数据包，则判定为对方掉线。
    * @param userID 离开房间的远端用户 ID。
    * @param reason 远端用户离开的原因。
    * - kNERtcSessionLeaveNormal(0)：正常离开。
    * - kNERtcSessionLeaveForFailOver(1)：用户断线导致离开房间。
    * - kNERTCSessionLeaveForUpdate(2)：用户因 Failover 导致离开房间，仅 SDK 内部使用。
    * - kNERtcSessionLeaveForKick(3)：用户被踢导致离开房间。
    * - kNERtcSessionLeaveTimeout(4)：用户超时退出房间。
    * @endif
    */
- (void)onNERtcEngineUserDidLeaveWithUserID:(uint64_t)userID reason:(NERtcSessionLeaveReason)reason;

 /**
   * @if English
   * Occurs when a remote user leaves a room.
   * A message is returned that a remote user leaves the room or becomes disconnected. A user leaves a room due to the following reasons: the user exit the room or connections time out.
   * - If a user leaves the room, the remote user receives a message that indicates that the user leaves the room.
   * - If the connection times out, and the user does not receive data packets for a time period of 40 to 50 seconds, then the user becomes disconnected.
   * @param userID The ID of the user that leaves the room.
   * @param reason The reason why the remote user leaves. For more information, see {@link NERtcSessionLeaveReason}.
   * @endif
   * @if Chinese
   * 远端用户离开房间事件回调。
   * - 远端用户离开房间或掉线（在 40 ~ 50 秒内本端用户未收到远端用户的任何数据包）后，SDK 会触发该回调。
   * @since V4.6.29
   * @par 使用前提
   * 请在 NERtcEngineDelegate 接口类中通过 {@link INERtcEngine#setupEngineWithContext:} 接口设置回调监听。
   * @note
   * 同类型事件发生后，{@link NERtcEngineDelegate#onNERtcEngineUserDidLeaveWithUserID:reason:} 回调可能会与该回调同时触发，建议您仅注册此回调，不能同时处理两个回调。
   * @par 参数说明
   * <table>
   *  <tr>
   *      <th>**参数名称**</th>
   *      <th>**类型**</th>
   *      <th>**描述**</th>
   *  </tr>
   *  <tr>
   *      <td>uid</td>
   *      <td>long</td>
   *      <td>离开房间的远端用户 ID。</td>
   *  </tr>
   *  <tr>
   *      <td>reason</td>
   *      <td>int</td>
   *      <td>该远端用户离开的原因，更多请参考 {@link NERtcEngineErrorCode.NERtcError}。<ul><li>kNERtcSessionLeaveNormal（0）：正常离开。<li>kNERtcSessionLeaveForFailOver（1）：用户断线导致离开房间。<li>kNERTCSessionLeaveForUpdate（2）：用户因 Failover 导致离开房间，仅 SDK 内部使用。<li>kNERtcSessionLeaveForKick（3）：用户被踢导致离开房间。<li>kNERtcSessionLeaveTimeout（4）：用户超时退出房间。</td>
   *  </tr>
   *  <tr>
   *      <td>leaveExtraInfo</td>
   *      <td>NERtcUserLeaveExtraInfo *</td>
   *      <td>该远端用户离开的额外信息。</td>
   *  </tr>
   * </table> 
   * @endif
   */
- (void)onNERtcEngineUserDidLeaveWithUserID:(uint64_t)userID reason:(NERtcSessionLeaveReason)reason  leaveExtraInfo:(nullable NERtcUserLeaveExtraInfo *)leaveExtraInfo;

    /**
     * @if English 
     * Occurs when a user changes the role in live streaming.
     * After the user joins a room, the user can call the setClientRole method to change the role. Then, the callback is triggered. For example, switching from host to audience, or from audience to host.
     * @note In live streaming, if you join a room and successfully call this method to change the role, the following callbacks are triggered.
     * - If the role changes from host to audience, the onClientRoleChange callback is triggered on the client, and the onUserLeave callback is triggered on a remote client.
     * - If the role changes from audience to host, the onClientRoleChange callback is triggered on the client, and the onUserJoined callback is triggered on a remote client.
     * @param oldRole The role before the user changes the role.
     * @param newRole The role after the user changes the role.
     * @endif
     * @if Chinese
     * 直播场景下用户角色已切换回调。
     * <br>用户加入房间后，通过 {@link INERtcEngine#setClientRole:} 切换用户角色后会触发此回调。例如从主播切换为观众、从观众切换为主播。
     * @note 直播场景下，如果您在加入房间后调用该方法切换用户角色，调用成功后，会触发以下回调：
     * - 主播切观众，本端触发 onNERtcEngineDidClientRoleChanged 回调，远端触发 {@link NERtcEngineDelegate#onNERtcEngineUserDidLeaveWithUserID:reason:} 回调。
     * - 观众切主播，本端触发 onNERtcEngineDidClientRoleChanged 回调，远端触发 {@link NERtcEngineDelegate#onNERtcEngineUserDidJoinWithUserID:userName:} 回调。
     * <p>@since V4.5.0
     * @param oldRole 切换前的角色。详细信息请参考 {@link NERtcClientRole}。
     * @param newRole 切换后的角色。详细信息请参考 {@link NERtcClientRole}。
     * @endif
     */
- (void)onNERtcEngineDidClientRoleChanged:(NERtcClientRole)oldRole newRole:(NERtcClientRole)newRole;

/**
 * @if English 
 * Occurs when reconnection starts.
 * If a client is disconnected from the server, the SDK starts reconnecting. The callback is triggered when the reconnection starts. For more information about the reconnection result, see onNERtcEngineRejoinChannel and onNERtcEngineDidDisconnectWithReason.
 * @endif
 * @if Chinese
 *重连开始回调。
 * 客户端和服务器断开连接时，SDK 会进行重连，重连开始时触发此回调。重连结果请参考 onNERtcEngineRejoinChannel 、onNERtcEngineDidDisconnectWithReason。
 * @endif
 */
- (void)onNERtcEngineReconnectingStart;

/**
 * @if English 
 * Occurs when a remote user enables audio.
 * @param userID The ID of a remote user.
 * @endif
 * @if Chinese
 * 远端用户开启音频回调。
 * @note 该回调由远端用户调用 enableLocalAudio 方法开启音频采集和发送触发。
 * @param userID 远端用户 ID。
 * @endif
 */
- (void)onNERtcEngineUserAudioDidStart:(uint64_t)userID;

/**
 * @if English 
 * Occurs when a remote user disables audio.
 * @param userID The ID of a remote user.
 * @endif
 * @if Chinese
 * 远端用户停用音频回调。
 * @note 该回调由远端用户调用 enableLocalAudio 方法关闭音频采集和发送触发。
 * @param userID 远端用户 ID。
 * @endif
 */
- (void)onNERtcEngineUserAudioDidStop:(uint64_t)userID;

/**
 * @if English 
 * Occurs when a remote user enables video.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @param userID The ID of the user whose video streams are sent.
 * @param profile The video profile of the remote user. For more information, see {@link NERtcVideoProfileType}.
 * @endif
 * @if Chinese
 * 远端用户开启视频回调。
 * <br> 启用后，用户可以进行视频通话或直播。
 * @note 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @param userID 用户 ID，提示是哪个用户的视频流。
 * @param profile 远端用户的视频 profile 档位。详细信息请参考  {@link NERtcVideoProfileType}。
 * @endif
 */
- (void)onNERtcEngineUserVideoDidStartWithUserID:(uint64_t)userID videoProfile:(NERtcVideoProfileType)profile;

/**
 * @if English 
 * Occurs when a remote user disables video.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @param userID The ID of a remote user.
 * @endif
 * @if Chinese
 * 远端用户停用视频回调。
 * <br> 关闭后，用户只能进行语音通话或者直播。
 * @note 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @param userID 远端用户 ID。
 * @endif
 */
- (void)onNERtcEngineUserVideoDidStop:(uint64_t)userID;

/**
 * @if English 
 * Occurs when a remote user enables screen sharing by using the substream.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @param userID The ID of a remote user.
 * @param profile The resolution of the remote video. For more information, see {@link NERtcVideoProfileType}.
 * @endif
 * @if Chinese
 *远端用户开启屏幕共享辅流通道的回调。
 * @note 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @param userID 远端用户 ID。
 * @param profile 远端视频分辨率等级。详细信息请参考  {@link NERtcVideoProfileType}。
 * @endif
 */
- (void)onNERtcEngineUserSubStreamDidStartWithUserID:(uint64_t)userID subStreamProfile:(NERtcVideoProfileType)profile;

/**
 * @if English 
 * Occurs when a remote user stops screen sharing by using the substream.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @param userID The ID of a remote user.
 * @endif
 * @if Chinese
 *远端用户停止屏幕共享辅流通道的回调。
 * @note 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @param userID 远端用户 ID。
 * @endif
 */
- (void)onNERtcEngineUserSubStreamDidStop:(uint64_t)userID;

/**
 * @if English
 * Audio/Video Callback when banned by server.
 * @since v4.6.0
 * @param isAudioBannedByServer indicates whether to ban the audio.
 * - true: banned
 * - false unbanned
 * @param isVideoBannedByServer indicates whether to ban the video.
 * - true: banned
 * - false unbanned
 * @endif
 * @if Chinese
 * 服务端禁言音视频权限变化回调。
 * @since v4.6.0
 * @param isAudioBannedByServer 是否禁用音频。
 * - true：禁用音频。
 * - false：取消禁用音频。
 * @param isVideoBannedByServer 是否禁用视频。
 * - true：禁用视频。
 * - false：取消禁用视频。
 * @endif
 */
- (void)onNERtcEngineMediaRightChangeWithAudio:(BOOL)isAudioBannedByServer
                                         video:(BOOL)isVideoBannedByServer;

/**
 * @if English
 * Occurs when a remote user enables the audio substream.
 * @since V4.6.10
 * @param userID Remote user ID.
 * @endif
 * @if Chinese
 * 远端用户开启音频辅流回调。
 * @since V4.6.10
 * @param userID 远端用户 ID。
 * @endif
 */
- (void)onNERtcEngineUserSubStreamAudioDidStart:(uint64_t)userID;

/**
 * @if English
 * Occurs when a remote user stops the audio substream.
 * @since V4.6.10
 * @param userID remote user ID.
 * @endif
 * @if Chinese
 * 远端用户停用音频辅流回调。
 * @since V4.6.10
 * @param userID 远端用户 ID。
 * @endif
 */
- (void)onNERtcEngineUserSubStreamAudioDidStop:(uint64_t)userID;

/**
 * @if English
 * Occurs when a remote user pauses or resumes publishing the audio substream.
 * @since V4.6.10
 * @param userID   User ID indicating which user performs the operation.
 * @param muted indicates if the audio substream is stopped.
 *               - YES: stops publishing the audio substream.
 *               - No: resumes publishing the audio substream.
 * @endif
 * @if Chinese
 * 远端用户暂停或恢复发送音频辅流的回调。
 * @since V4.6.10
 * @param userID 用户 ID，提示是哪个用户的音频辅流。
 * @param muted  是否停止发送音频辅流。
 *                - YES：该用户已暂停发送音频辅流。
 *                - NO：该用户已恢复发送音频辅流。
 * @endif
 */
- (void)onNERtcEngineUser:(uint64_t)userID subStreamAudioMuted:(BOOL)muted;

@end

 /**
  * @if English 
  * Returns the streaming status in live streaming.
  * If you want to listen for the streaming state in live streaming, you need to implement this protocol.
  * @endif
  * @if Chinese
  * 直播推流状态回调
  * 如果需要监听直播推流状态，需要实现这个 protocol
  * @endif
  */
@protocol NERtcEngineLiveStreamObserver <NSObject>

@optional
 /**
  * @if English 
  * Occurs when the streaming state in live streaming changes.
  * @param state The streaming state in live streaming. For more information, see {@link NERtcLiveStreamStateCode}.
  * @param taskID The ID of a streaming task.
  * @param url The URL for the streaming task.
  * @endif
  * @if Chinese
  * 推流状态已改变回调。
  * @param state 推流状态，详细信息请参考  {@link NERtcLiveStreamStateCode}。
  * @param taskID 推流任务 ID。
  * @param url 推流任务对应的 URL 地址。
  * @endif
  */
- (void)onNERTCEngineLiveStreamState:(NERtcLiveStreamStateCode)state taskID:(NSString *)taskID url:(NSString *)url;

@end

/**
 * @if English 
 * Returns the local video data captured.
 * If you need to add a beautifier effect to the captured data, you must implement this protocol.
 * @endif
 * @if Chinese
 *本地视频数据采集回调
 *如果需要对采集数据做美颜等处理，需要实现这个 protocol。
 * @endif
 */
@protocol NERtcEngineVideoFrameObserver <NSObject>

@optional

/**
 * @if English 
 * Returns the settings for video data capture and uses the settings for operations such as beautifiers.
 * The setting is returned synchronously. The engine continues to process the video data.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @param bufferRef CVPixelBufferRef, the iOS native format.
 * @param rotation The video orientation. For more information, see {@link NERtcVideoRotationType}.
 * @endif
 * @if Chinese
 * 设置视频采集数据回调，用于美颜等操作。
 * 同步返回，Engine 将会继续视频处理流程。
 * @note 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @param bufferRef CVPixelBufferRef，iOS 原生格式。
 * @param rotation 视频方向，详细信息请参考  {@link NERtcVideoRotationType}。
 * @endif
 */
- (void)onNERtcEngineVideoFrameCaptured:(CVPixelBufferRef)bufferRef rotation:(NERtcVideoRotationType)rotation;

@end

/**
 * @if English 
 * Occurs when the audio session is created.
 * @endif
 * @if Chinese
 * 音频会话回调
 * @endif
 */
@protocol NERtcEngineAudioSessionObserver <NSObject>

@optional
//
//- (void)onNERtcEngineAudioDeviceInterruptionBegan;
//
//- (void)onNERtcEngineAudioDeviceInterruptionEnded;

/**
 * @if English 
 * Occurs when the audio routing changes.
 * @param routing The current audio output routing.
 * @endif
 * @if Chinese
 * 音频路由变化回调。
 * @param routing 当前音频输出路由。
 * @endif
 */
- (void)onNERtcEngineAudioDeviceRoutingDidChange:(NERtcAudioOutputRouting)routing;

@end

/**
 * @if English 
 * External audio rendering.
 * @endif
 * @if Chinese
 * 外部视频渲染。
 * @endif
 */
@protocol NERtcEngineVideoRenderSink <NSObject>

@optional
/**
 * @if English 
 * Returns the external rendering video data.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @param frame The information about video frame data. For more information, see {@link NERtcVideoFrame}.
 * @endif
 * @if Chinese
 * 外部渲染视频数据回调
 * @note 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @param frame 视频帧的数据信息。详细信息请参考 {@link NERtcVideoFrame}。
 * @endif
 */
- (void)onNERtcEngineRenderFrame:(NERtcVideoFrame *_Nonnull)frame;

// 渲染所需的 buffer 类型，默认为 NERtcVideoBufferTypeRawData
- (NERtcVideoBufferType)getFrameBufferType;

@end
/**
 * @if English 
 * Register as an SEI observer.
 * After you register the observer and pull the stream successfully, when the remote client sends the SEI, the local client gets notified by the onNERtcEngineRecvSEIMsg callback.
 * @endif
 * @if Chinese
 * 注册 SEI 观测者。
 * 注册观测者并拉流成功后，当远端流发送 SEI，本端会收到 onNERtcEngineRecvSEIMsg 回调。
 * @endif
 */
@protocol NERtcEngineVideoSEIObserver <NSObject>

@optional

/**
 * @if English 
 * Occurs when the content of remote SEI is received.
 * After a remote client successfully sends SEI, the local client receives a message returned by the callback.
 * @note The audio-only SDK disables this callback. If you need to use the callback, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @param userID The ID of the user who sends SEI.
 * @param message The message that contains SEI.
 * @endif
 * @if Chinese
 * 收到远端流的 SEI 内容回调。
 * 当远端成功发送 SEI 后，本端会收到此回调。
 * @note 纯音频 SDK 禁用该回调，如需使用请前往云信官网下载并替换成视频 SDK。
 * @param userID 发送 SEI 的用户 ID。
 * @param message 对应用户的 SEI 信息。
 * @endif
 */
- (void)onNERtcEngineRecvSEIMsg:(uint64_t)userID message:(NSData *)message;

@end

@protocol NERtcEnginePreDecodeObserver <NSObject>
 @optional
/**
 * @if Chinese
 * 解码前媒体数据回调。
 * - 调用 {@link INERtcEngineEx#setPreDecodeObserver:} 方法注册解码前媒体数据观测器后，SDK会触发该回调，可以通过返回的用户 UID、媒体数据类型、数据长度等信息对媒体数据自行编码。
 * @since V4.6.29
 * @par 使用前提
 * 请在 NERtcEngineDelegate 接口类中通过 {@link INERtcEngineEx#setPreDecodeObserver:} 接口设置回调监听。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>preDecodeFrame</td>
 *      <td>NERtcPreDecodeFrameInfo *</td>
 *      <td>解码前媒体数据。</td>
 *  </tr>
 * </table>  
 * @endif
 */
- (void)onNERtcEnginePreDecoderFrame:(NERtcPreDecoderFrameInfo *)preDecoderFrame;

@end

@protocol NERtcEngineVideoEncoderQosObserver <NSObject>

 @optional

/**
 * @if Chinese
 * I 帧请求事件回调。
 * - 调用 {@link INERtcEngineEx#setPreDecodeObserver:} 方法注册解码前媒体数据观测器后，SDK 可能会在推送外部视频编码帧后触发该回调，此时请及时发送相应的 IDR 帧，否则对端无法渲染视频画面。
 * @since V4.6.29
 * @par 使用前提
 * 请通过 {@link INERtcEngineEx#setPreDecodeObserver:} 接口设置回调监听。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>videoStreamType</td>
 *      <td>{@link NERtcStreamChannelType}</td>
 *      <td>视频通道类型：<ul><li>kNERtcStreamChannelTypeMainStream：主流。<li>kNERtcStreamChannelTypeSubStream：辅流。</td>
 *  </tr>
 * </table>  
 * @endif
 */
- (void)onNERtcEngineRequestSendKeyFrame:(NERtcStreamChannelType)videoStreamType;

/**
 * @if Chinese
 * I 帧请求事件回调。
 * - 调用 {@link INERtcEngineEx#setPreDecodeObserver:} 方法注册解码前媒体数据观测器后，SDK 可能会在推送外部视频编码帧后触发该回调，此时可以调整对应的码率，防止出现超编，引发视频异常。
 * @since V4.6.29
 * @par 使用前提
 * 请通过 {@link INERtcEngineEx#setPreDecodeObserver:} 接口设置回调监听。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>bitrateBps</td>
 *      <td>int</td>
 *      <td>码率。单位为 kbps。</td>
 *  </tr>
 *  <tr>
 *      <td>videoStreamType</td>
 *      <td>{@link NERtcStreamChannelType}</td>
 *      <td>视频通道类型：<ul><li>kNERtcStreamChannelTypeMainStream：主流。<li>kNERtcStreamChannelTypeSubStream：辅流。</td>
 *  </tr>
 * </table>  
 * @endif
 */
- (void)onNERtcEngineBitrateUpdated:(int)bitrateBps
                    videoStreamType:(NERtcStreamChannelType)videoStreamType;

/**
 * @if Chinese
 * 视频编码器类型信息回调。
 * - 调用 {@link INERtcEngineEx#setPreDecodeObserver:} 方法注册解码前媒体数据观测器后，SDK 默认会在推送外部视频编码帧后触发一次该回调；后续若编码器类型发生变更时会再次触发此回调，此时请重置您的编码器。
 * @since V4.6.29
 * @par 使用前提
 * 请通过 {@link INERtcEngineEx#setPreDecodeObserver:} 接口设置回调监听。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>videoCodecType</td>
 *      <td>{@link NERtcVideoCodecType}</td>
 *      <td>视频编码器类型：<ul><li>kNERtcVideoCodecTypeH264(3)：H.264 编码器。</td>
 *  </tr>
 *  <tr>
 *      <td>videoStreamType</td>
 *      <td>{@link NERtcStreamChannelType}</td>
 *      <td>视频通道类型：<ul><li>kNERtcStreamChannelTypeMainStream：主流。<li>kNERtcStreamChannelTypeSubStream：辅流。</td>
 *  </tr>
 * </table>  
 * @endif
 */
- (void)onNERtcEngineVideoCodecUpdated:(NERtcVideoCodecType)videoCodecType
                       videoStreamType:(NERtcStreamChannelType)videoStreamType;

@end

/**
 * @if English 
 * NERtcEngine extended callback.
 * @endif
 * @if Chinese
 * NERtcEngine 扩展回调。
 * @endif
 */
@protocol NERtcEngineDelegateEx <NERtcEngineDelegate,
NERtcEngineVideoFrameObserver, // deprecated, USE setVideoFrameObserver:(id<NERtcEngineVideoFrameObserver>)videoframeObserver instead
NERtcEngineAudioSessionObserver,
NERtcEngineLiveStreamObserver,
NERtcEngineVideoSEIObserver>

@optional

/**
 * @if English 
 * Occurs when the profile of the video streams from a remote user is updated.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @param userID The ID of a remote user.
 * @param maxProfile The video encoding parameters. For more information, see {@link NERtcVideoProfileType}.
 * @endif
 * @if Chinese
 * 远端用户视频编码配置已更新回调。
 * @note 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @param userID 远端用户 ID。
 * @param maxProfile 视频编码配置，详细信息请参考 {@link NERtcVideoProfileType}。
 * @endif
 */
- (void)onNERtcEngineUserVideoProfileDidUpdate:(uint64_t)userID maxProfile:(NERtcVideoProfileType)maxProfile;

/**
 * @if English 
 * Occurs when a remote user stops or resumes sending video streams. 
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @param userID The ID of the user whose video streams are sent.
 * @param muted The option whether to pause sending video streams.
 * @endif
 * @if Chinese
 * 远端用户暂停或恢复发送视频流回调。 
 * <br>当远端用户调用 muteLocalVideo 取消或者恢复发布视频流时，SDK会触发该回调向本地用户报告远程用户的发流状况。
 * @note 该回调仅在远端用户的视频主流状态改变时会触发，若您希望同时接收到远端用户视频辅流状态变更的通知，请监听 {@link NERtcEngineDelegateEx#onNERtcEngineUser:videoMuted:streamType:} 回调。
 * @param userID 用户 ID，提示是哪个用户的视频流。
 * @param muted 是否暂停发送视频流。
     * - YES：该用户已暂停发送视频流。
     * = NO：该用户已恢复发送视频流。
 * @endif
 */
- (void)onNERtcEngineUser:(uint64_t)userID videoMuted:(BOOL)muted;

/**
 * @if Chinese
 * 远端用户暂停或恢复发送视频回调。
 * <br>当远端用户调用 {@link INERtcEngineEx#muteLocalVideo:streamType:} 方法取消或者恢复发布视频流时，SDK 会触发该回调向本地用户通知远端用户的发流情况。
 * @since V4.6.20
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
 *      <td>用户 ID，提示是哪个用户的视频流。</td>
 *  </tr>
 *  <tr>
 *      <td>muted</td>
 *      <td>BOOL</td>
 *      <td>是否暂停发送视频流：<ul><li>YES：该用户已暂停发送视频流。<li>NO：该用户已恢复发送视频流。</td>
 *  </tr>
 *  <tr>
 *      <td>streamType</td>
 *      <td>{@link NERtcStreamChannelType}</td>
 *      <td>视频通道类型：<ul><li>kNERtcStreamChannelTypeMainStream：主流。<li>kNERtcStreamChannelTypeSubStream：辅流。</td>
 *  </tr>
 * </table>
 * @endif
 */
- (void)onNERtcEngineUser:(uint64_t)userID videoMuted:(BOOL)muted streamType:(NERtcStreamChannelType)streamType;

/**
 * @if English 
 * Occurs when a remote user stops or resumes sending audio streams.
 * @param userID The ID of the user whose audio streams are sent.
 * @param muted The option whether to pause sending audio streams.
 * @endif
 * @if Chinese
 * 远端用户暂停或恢复发送音频流的回调。
 * @note 该回调由远端用户调用 muteLocalAudio 方法开启或关闭音频发送触发。
 * @param userID 用户 ID，提示是哪个用户的音频流。
 * @param muted 是否暂停发送音频流。
 * @endif
 */
- (void)onNERtcEngineUser:(uint64_t)userID audioMuted:(BOOL)muted;

/**
 * @if English 
 * Occurs when the first audio frame from a remote user is received.
 * If the first video frame from a remote user is displayed in the view, the callback is triggered.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @param userID The ID of a remote user whose video streams are sent. 
 * @endif
 * @if Chinese
 * 已接收到远端视频首帧回调。
 * SDK 收到远端第一帧视频并解码成功时，触发此调用。每次重新调用 enableLocalVideo 开启本地视频采集，也会触发该回调（V5.5.10版本开始）。App 可在此回调中设置该用户的视频画布。
 * @note 该回调仅在显示远端用户的主流视频首帧时会触发，若您希望同时接收到接收辅流的相关通知，请监听 {@link NERtcEngineDelegateEx#onNERtcEngineFirstVideoDataDidReceiveWithUserID:streamType:} 回调。
 * @param userID  远端用户 ID，指定是哪个用户的视频流。 
 * @endif
 */
- (void)onNERtcEngineFirstVideoDataDidReceiveWithUserID:(uint64_t)userID;

/**
 * @if Chinese
 * 已显示远端视频首帧的回调。
 * @since V4.6.20
  * @note 以下场景都会触发该回调：
  * - SDK 收到远端第一帧视频并解码成功时。
  * - 重新调用 enableLocalVideo 开启本地视频采集。（V5.5.10版本开始）
  * - 停止屏幕共享后再重新调用 startScreenCapture 接口共享屏幕。（V5.5.10版本开始）
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
 *      <td>用户 ID，提示是哪个用户的视频流。</td>
 *  </tr>
 *  <tr>
 *      <td>type</td>
 *      <td>{@link NERtcStreamChannelType}</td>
 *      <td>视频通道类型：<ul><li>kNERtcStreamChannelTypeMainStream：主流。<li>kNERtcStreamChannelTypeSubStream：辅流。</td>
 *  </tr>
 * </table>
 * @endif
 */
- (void)onNERtcEngineFirstVideoDataDidReceiveWithUserID:(uint64_t)userID streamType:(NERtcStreamChannelType)streamType;

/**
 * @if Chinese
 * 接收的远端视频分辨率变化回调。
 * @since V5.4.1
 * @par 触发时机
 * <br>当远端用户视频流的分辨率发生变化时，会触发此回调，例如推流端调用 SetVideoConfig 更改了编码分辨率设置，本地会收到该远端用户分辨率变化通知。
 * @par 业务场景
 * 开发者可根据视频流的最新分辨率来更新 UI。
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
  *      <td>远端用户ID，指定是哪个用户的视频流</td>
  *  </tr>
  *  <tr>
  *      <td>type</td>
  *      <td>{@link NERtcStreamChannelType}</td>
  *      <td>视频通道类型：<ul><li>kNERtcStreamChannelTypeMainStream：主流。<li>kNERtcStreamChannelTypeSubStream：辅流。</td>
  *  </tr>
  *  <tr>
  *      <td>width</td>
  *      <td>uint32_t</td>
  *      <td>视频采集的宽，单位为 px</td>
  *  </tr>
  *  <tr>
  *      <td>height</td>
  *      <td>uint32_t</td>
  *      <td>视频采集的高，单位为 px</td>
  *  </tr>
  * </table>
 * @endif
 */
- (void)onNERtcEngineRemoteVideoSizeDidChangedWithUserID:(uint64_t)userID width:(uint32_t)width height:(uint32_t)height streamType:(NERtcStreamChannelType)streamType;

/**
 * @if Chinese
 * 本地视频预览的分辨率变化回调, 与是否进入房间的状态无关，与硬件状态有关，也适用于预览。
 * @since V5.4.1
 * @par 触发时机
 * 当本地视频的分辨率发生变化，会触发此回调。当调用 SetCaptureConfig 设置采集分辨率或调用 SetVideoConfig 设置编码属性时可以触发该回调。回调的分辨率宽和高为本地预览的宽和高，和实际编码发送的分辨率不一定一致
 * @par 业务场景
 * 开发者可以根据该回调的分辨率来动态调整预览视图的比例等。
  * @par 参数说明
  * <table>
  *  <tr>
  *      <th>**参数名称**</th>
  *      <th>**类型**</th>
  *      <th>**描述**</th>
  *  </tr>
  *  <tr>
  *      <td>streamType</td>
  *      <td>NERtcStreamChannelType</td>
  *      <td>当前的流类型。<ul><li>kNERtcStreamChannelTypeMainStream：视频主流。<li>kNERtcStreamChannelTypeSubStream：视频辅流</td>
  *  </tr>
  *  <tr>
  *      <td>width</td>
  *      <td>uint32_t</td>
  *      <td>首帧视频的宽，单位为 px。</td>
  *  </tr>
  *  <tr>
  *      <td>height</td>
  *      <td>uint32_t</td>
  *      <td>首帧视频的高，单位为 px。</td>
  *  </tr>
  * </table>
 * @endif
 */
- (void)onNERtcEngineLocalVideoRenderSizeChanged:(NERtcStreamChannelType)streamType width:(uint32_t)width height:(uint32_t)height;

 /**
  * @if English 
  * Occurs when the first audio frame from a remote user is received.
  * @param userID The ID of a remote user whose audio streams are sent.
  * @endif
  * @if Chinese
  * 已接收到远端音频首帧回调。
  * @param userID 远端用户 ID，指定是哪个用户的音频流。  
  * @endif
  */
- (void)onNERtcEngineFirstAudioDataDidReceiveWithUserID:(uint64_t)userID;

 /**
  * @if English 
  * Occurs when the first audio frame from a remote user is decoded.
  * @param userID The ID of a remote user whose audio streams are sent.
  * @endif
  * @if Chinese
  * 已接收到远端音频首帧并完成解码的回调。
  * @note 该回调仅在接收远端用户的音频首帧并完成解码时会触发。
  * @param userID 远端用户 ID，指定是哪个用户的音频流。  
  * @endif
  */
- (void)onEngineFirstAudioFrameDecoded:(uint64_t)userID;

/**
 * @if English 
 * Occurs when the first video frame from a remote user is displayed.
 * If the engine receives the first frame of remote video streams, the callback is triggered. The callback allows the app to set the video canvas.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @param userID The ID of a remote user whose video streams are sent.
 * @param width The width of the first video frame. Unit: px.
 * @param height The height of the first video frame. Unit: px.
 * @endif
 * @if Chinese
 * 已接收到远端视频首帧并完成解码的回调。
 * 引擎收到第一帧远端视频流并解码成功时，触发此调用。 App 可在此回调中设置该用户的视频画布。
 * @note 该回调仅在接收远端用户的主流视频首帧并完成解码时会触发，若您希望同时接收到接收辅流的相关通知，请监听 {@link onEngineFirstVideoFrameDecoded:width:height:streamType:} 回调。
 * @param userID 远端用户 ID，指定是哪个用户的视频流。  
 * @param width  首帧视频宽，单位为 px。
 * @param height 首帧视频高，单位为 px。
 * @endif
 */
- (void)onEngineFirstVideoFrameDecoded:(uint64_t)userID width:(uint32_t)width height:(uint32_t)height;

/**
 * @if Chinese
 * 已接收到远端视频首帧并完成解码的回调。
 * <br>当 SDK 收到远端视频并解码成功时，会触发该回调。应用层可在该回调中设置此用户的视频画布。
 * @since V4.6.20
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
 *      <td>用户 ID，提示是哪个用户的视频流。</td>
 *  </tr>
 *  <tr>
 *      <td>width</td>
 *      <td>uint32_t</td>
 *      <td>首帧视频的宽度，单位为 px。</td>
 *  </tr>
 *  <tr>
 *      <td>height</td>
 *      <td>uint32_t</td>
 *      <td>首帧视频的高度，单位为 px。</td>
 *  </tr>
 *  <tr>
 *      <td>type</td>
 *      <td>{@link NERtcStreamChannelType}</td>
 *      <td>视频通道类型：<ul><li>kNERtcStreamChannelTypeMainStream：主流。<li>kNERtcStreamChannelTypeSubStream：辅流。</td>
 *  </tr>
 * </table>
 * @endif
 */
- (void)onEngineFirstVideoFrameDecoded:(uint64_t)userID width:(uint32_t)width height:(uint32_t)height streamType:(NERtcStreamChannelType)streamType;

/**
 * @if Chinese
 * 已接收到远端视频首帧并完成渲染的回调。
 * <br>当 SDK 第一帧远端视频流并渲染成功时，会触发该回调。
 * @since V5.5.10
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
 *      <td>用户 ID，提示是哪个用户的视频流。</td>
 *  </tr>
 *  <tr>
 *      <td>width</td>
 *      <td>uint32_t</td>
 *      <td>首帧视频的宽度，单位为 px。</td>
 *  </tr>
 *  <tr>
 *      <td>height</td>
 *      <td>uint32_t</td>
 *      <td>首帧视频的高度，单位为 px。</td>
 *  </tr>
 *  <tr>
 *      <td>elapsed</td>
 *      <td>uint64_t</td>
 *      <td>从订阅动作开始到发生此事件过去的时间（毫秒)。</td>
 *  </tr>
 *  <tr>
 *      <td>type</td>
 *      <td>{@link NERtcStreamChannelType}</td>
 *      <td>视频通道类型：<ul><li>kNERtcStreamChannelTypeMainStream：主流。<li>kNERtcStreamChannelTypeSubStream：辅流。</td>
 *  </tr>
 * </table>
 * @endif
 */
- (void)onEngineFirstVideoFrameRender:(uint64_t)userID width:(uint32_t)width height:(uint32_t)height elapsed:(uint64_t)elapsed streamType:(NERtcStreamChannelType)streamType;

/**
 * @if English 
 * Occurs when the state of the audio device changes.
 * @param deviceID The ID of the device.
 * @param deviceType The type of the device. For more information, see {@link NERtcAudioDeviceType}.
 * @param deviceState The state of the audio device. For more information, see {@link NERtcAudioDeviceState}.
 * @endif
 * @if Chinese
 * 音频设备状态已改变回调。
 * @param deviceID 设备 ID。
 * @param deviceType 设备类型。详细信息请参考 {@link NERtcAudioDeviceType}。
 * @param deviceState 设备状态。详细信息请参考 {@link NERtcAudioDeviceState}。
 * @endif
 */
- (void)onNERtcEngineAudioDeviceStateChangeWithDeviceID:(NSString *)deviceID deviceType:(NERtcAudioDeviceType)deviceType deviceState:(NERtcAudioDeviceState)deviceState;

/**
 * @if English 
 * Occurs when the video device changes.
 * The callback sends a message that the state of the video device changes. For example, the device is unplugged or removed. If an external camera that the device uses is unplugged, the video streaming is interrupted.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @param deviceID The ID of the device.
 * @param deviceType The type of the device. For more information, see {@link NERtcAudioDeviceType}.
 * @param deviceState The state of the audio device. For more information, see {@link NERtcAudioDeviceState}.
 * @endif
 * @if Chinese
 * 视频设备变化回调。
 * 该回调提示系统视频设备状态发生改变，比如被拔出或移除。如果设备已使用外接摄像头采集，外接摄像头被拔开后，视频会中断。
 * @note 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @param deviceID 设备 ID。
 * @param deviceType 设备类型。详细信息请参考 {@link NERtcAudioDeviceType}。
 * @param deviceState 设备状态。详细信息请参考 {@link NERtcAudioDeviceState}。
 * @endif
 */
- (void)onNERtcEngineVideoDeviceStateChangeWithDeviceID:(NSString *)deviceID deviceType:(NERtcVideoDeviceType)deviceType deviceState:(NERtcVideoDeviceState)deviceState;

/**
 * @if English 
 * Occurs when the local network type changes.
 * If the connection type of the local network changes, the callback is triggered and returns the network connection type that is used.
 * @param newConnectionType The current local network type. For more information, see {@link NERtcNetworkConnectionType}.
 * @endif
 * @if Chinese
 * 本地网络类型已改变回调。
 * 本地网络连接类型发生改变时，SDK 会触发该回调，并在回调中声明当前正在使用的网络连接类型。
 * @param newConnectionType 当前的本地网络类型，详细信息请参考 {@link NERtcNetworkConnectionType}。
 * @endif
 */
- (void)onNERtcEngineNetworkConnectionTypeChanged:(NERtcNetworkConnectionType)newConnectionType;

/**
 * @if English 
 * Occurs when the playback state of a local music file changes.
 * If you call the startAudioMixing method to play a mixing music file and the playback state changes, the callback is triggered.
 * -If the playback of the music file ends normally, the state parameter returned in the response contains the corresponding status code kNERtcAudioMixingStateFinished, and the error_code parameter contains kNERtcAudioMixingErrorOK.
 * - If an error occurs in the playback, the kNERtcAudioMixingStateFailed status code is returned, and the error_code parameter returned contains the corresponding reason.
 * -If the local music file does not exist, the file format is not supported, or the URL of the online music file cannot be accessed, the error_code parameter returned contains kNERtcAudioMixingErrorCanNotOpen.
 * @param state The playback state of the music file. For more information, see {@link NERtcAudioMixingState}.
 * @param errorCode The error code. For more information, see {@link NERtcAudioMixingErrorCode}.
 
 * @endif
 * @if Chinese
 * 本地用户的音乐文件播放状态改变回调。
 * 调用 startAudioMixing 播放混音音乐文件后，当音乐文件的播放状态发生改变时，会触发该回调。
 * - 如果播放音乐文件正常结束，state 会返回相应的状态码 kNERtcAudioMixingStateFinished，error_code 返回 kNERtcAudioMixingErrorOK。
 * - 如果播放出错，则返回状态码 kNERtcAudioMixingStateFailed，error_code 返回相应的出错原因。
 * - 如果本地音乐文件不存在、文件格式不支持、无法访问在线音乐文件 URL，error_code都会返回 kNERtcAudioMixingErrorCanNotOpen。
 * @param state 音乐文件播放状态，详细信息请参考 {@link NERtcAudioMixingState}。
 * @param errorCode 错误码，详细信息请参考 {@link NERtcAudioMixingErrorCode}。
   * @endif
   */
- (void)onAudioMixingStateChanged:(NERtcAudioMixingState)state errorCode:(NERtcAudioMixingErrorCode)errorCode;

/**
 * @if English 
 * Returns the playback position of a local music file.
 * If you call the startAudioMixing method to play back a mixing music file and the playback position changes, the callback is triggered.
 * @param timeStampMS  The playback progress of the music file. Unit: milliseconds.
 * @endif
 * @if Chinese
 * 本地用户的音乐文件播放进度回调。
 * 调用 startAudioMixingWithOption 播放混音音乐文件后，当音乐文件的播放进度改变时，会触发该回调。
 * @param timeStampMS  音乐文件播放进度，单位为毫秒。
 * @endif
 */
- (void)onAudioMixingTimestampUpdate:(uint64_t)timeStampMS;


 /**
  * @if English  
  * Occurs when the playback of a music file ends. 
  * @param effectId The ID of the specified audio effect. Each audio effect has a unique ID.

  * @endif
  * @if Chinese 
  * 本地音效文件播放已结束回调。 
  * @param effectId 指定音效的 ID。每个音效均有唯一的 ID。
  * @endif
  */
- (void)onAudioEffectFinished:(uint32_t)effectId;

/**
 * @if Chinese
 * 本地用户的指定音效文件播放进度回调。
 * - 调用 {@link INERtcEngineEx#playEffectWitdId:effectOption:} 方法播放音效文件后，SDK 会触发该回调，默认每 1s 返回一次。
 * @since V4.6.29
 * @par 使用前提
 * 请在 NERtcEngineDelegate 接口类中通过 {@link INERtcEngine#setupEngineWithContext:} 接口设置回调监听。
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
 *      <td>指定音效文件的 ID。每个音效均有唯一的 ID。</td>
 *  </tr>
 *  <tr>
 *      <td>timestampMs</td>
 *      <td>uint64_t</td>
 *      <td>指定音效文件的当前播放进度。单位为毫秒。</td>
 *  </tr>
 * </table> 
 * @endif
 */
- (void)onAudioEffectTimestampUpdateWithId:(uint32_t)effectId timeStampMS:(uint64_t)timeStampMS;

 /**
  * @if English 
  * Occurs when the system prompts the current local audio volume. 
  * This callback is disabled by default. You can enable the callback by calling the enableAudioVolumeIndication method.
  * After the callback is enabled, if a local user speaks, the SDK triggers the callback based on the time interval specified in the enableAudioVolumeIndication method. 
  * If the local user mutes the local audio by calling muteLocalAudio, the SDK no longer reports this callback.
  * @param volume The audio volume. Value range: 0 to 100.

  * @endif
  * @if Chinese
  * 提示房间内本地用户瞬时音量的回调。 
  * 该回调默认禁用。可以通过  enableAudioVolumeIndication 方法开启。
  * 开启后，本地用户说话，SDK 会按  enableAudioVolumeIndication 方法中设置的时间间隔触发该回调。 
  * 如果本地用户将自己静音，即调用了 muteLocalAudio，SDK 不再报告该回调。
  * @param volume 混音后的音量，范围为 0~100。

* @endif
*/
- (void)onLocalAudioVolumeIndication:(int)volume;

/**
 * @if English
 * Occurs when the system prompts the current local audio volume.
 * <br>By default, the callback is disabled. You can enable the callback by calling the {@link enableAudioVolumeIndication} method. After the callback is enabled, if a local user speaks, the SDK triggers the callback based on the time interval specified in the {@link enableAudioVolumeIndication} method.
 * <br>If the local audio is muted by calling {@link muteLocalAudioStream}, the SDK will set the volume to 0 and return to the application layer.
 * @since V4.6.10
 * @param volume  indicates the mixing audio volume. Value range: 0 to 100.
 * @param enableVad indicates whether voice activity detection is enabled.
 * @endif
 * @if Chinese
 * 提示房间内本地用户瞬时音量的回调。
 * <br>该回调默认为关闭状态。可以通过 {@link INERtcEngineEx#enableAudioVolumeIndication:interval:vad:} 方法开启；开启后，本地用户说话，SDK 会按该方法中设置的时间间隔触发该回调。
 * <br>如果本地用户将自己静音（调用了 {@link INERtcEngineEx#muteLocalAudio:}），SDK 将音量设置为 0 后回调给应用层。
 * @since V4.6.10
 * @param volume  混音后的音量，范围为 0 ~ 100。
 * @param enableVad 是否检测到人声。
 * @endif
 */
- (void)onLocalAudioVolumeIndication:(int)volume withVad:(BOOL)enableVad;


/**
 * @if English 
 * Occurs when the system prompts the active speaker and the audio volume.
 * By default, the callback is disabled. You can enable the callback by calling the enableAudioVolumeIndication method. After the callback is enabled, if a local user speaks, the SDK triggers the callback based on the time interval specified in the enableAudioVolumeIndication method.
 * In the array returned:
 * - If a uid is contained in the array returned in the last response but not in the array returned in the current response. The remote user with the uid does not speak by default. 
 * - If the volume is 0, the user does not speak.
 * - If the array is empty, the remote user does not speak.
 * @param speakers The array that contains the information about user IDs and volumes. For more information, see {@link NERtcAudioVolumeInfo}.
 * @param totalVolume The volume of the mixing audio. Value range: 0  to 100.
 * @endif
 * @if Chinese
 * 提示房间内谁正在说话及说话者瞬时音量的回调。
 * 该回调默认为关闭状态。可以通过 enableAudioVolumeIndication 方法开启。开启后，无论房间内是否有人说话，SDK 都会按 enableAudioVolumeIndication 方法中设置的时间间隔触发该回调。
 * 在返回的数组中：
 * - 如果有 uid 出现在上次返回的数组中，但不在本次返回的数组中，则默认该 uid 对应的远端用户没有说话。 
 * - 如果 volume 为 0，表示该用户没有说话。
 * - 如果数组为空，则表示此时远端没有人说话。
 * @param speakers 每个说话者的用户 ID 和音量信息的数组。详细信息请参考 {@link NERtcAudioVolumeInfo}。
 * @param totalVolume 混音后的总音量，范围为 0~100。
 * @endif
 */
-(void)onRemoteAudioVolumeIndication:(nullable NSArray<NERtcAudioVolumeInfo*> *)speakers totalVolume:(int)totalVolume;

/**
 * @if English 
 * Occurs when the hardware resources are released.
 * If the callback returns a successful result, the SDK has completely released the hardware resources.
 * can reconfigure or use hardware resources, such as AVAudioSession, after you receive the successful result.
 * @param result The result. For more information, see {@link NERtcEngineErrorCode.NERtcError}.
 * @endif
 * @if Chinese
 * 硬件资源已释放回调。
 * 如果回调结果成功，表示 SDK 已经完全释放了硬件资源。
 * 您可以在收到回调成功后重新配置或者使用硬件资源，例如 AVAudioSession 等配置。
 * @param result 释放结果。详细信息请参考 {@link NERtcEngineErrorCode.NERtcError}。
 * @endif
 */
- (void)onNERtcEngineHardwareResourceReleased:(NERtcError)result;

/**
 * @if English 
 * Occurs when the camera focus position changes.
 * The callback indicates that the camera focus position changes.
 * The callback is triggered if a local user calls the setCameraFocusPosition method to change the focus position.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @param focusPoint The new focus position.
 * @endif
 * @if Chinese
 * 摄像头对焦区域已改变回调。
 * 该回调表示相机的对焦区域发生了改变。
 * 该回调是由本地用户调用 setCameraFocusPosition 方法改变对焦位置触发的。
 * @note 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @param focusPoint 新的对焦区域位置。
 * @endif
 */
- (void)onNERtcCameraFocusChanged:(CGPoint)focusPoint;

/**
 * @if English 
 * Occurs when the camera exposure position changes.
 * The callback is triggered if a local user calls the setCameraExposurePosition method to change the exposure position.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @param exposurePoint The new exposure position.
 * @endif
 * @if Chinese
 * 摄像头曝光区域已改变回调。
 * 该回调是由本地用户调用 setCameraExposurePosition方法改变曝光位置触发的。
 * @note 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @param exposurePoint 新的曝光区域位置。
 * @endif
 */
- (void)onNERtcCameraExposureChanged:(CGPoint)exposurePoint;



/**
 * @if English 
 * @deprecated This callback is deprecated. Use {@link onNERtcEngineAudioHasHowling:} instead.
 * Occurs when howling is detected.
 * When the distance between the sound source and the PA equipment is too close, howling may occur. The NERTC SDK supports howling detection. When a howling signal is detected, the callback is automatically triggered until the howling stops. The application layer can prompt the user to mute the microphone or directly mute the microphone when the app receives the howling information returned by the callback.
 * @note Howling detection is used in human voice scenarios, such as voice chat rooms or online meetings. We recommend that you do not use howling detection in entertainment scenes that include background music.
 * @endif
 * @if Chinese
 * @deprecated 该回调将在未来版本中废弃，请使用`- (void)onNERtcEngineAudioHasHowling:(BOOL)flag`.
 * 检测到啸叫回调。
 * 当声源与扩音设备之间因距离过近时，可能会产生啸叫。NERTC SDK 支持啸叫检测，当检测到有啸叫信号产生的时候，自动触发该回调直至啸叫停止。App 应用层可以在收到啸叫回调时，提示用户静音麦克风，或直接静音麦克风。
 * @note 啸叫检测功能一般用于语音聊天室或在线会议等纯人声环境，不推荐在包含背景音乐的娱乐场景中使用。
 * @endif
 */
- (void)onNERtcEngineAudioHasHowling;

/**
 * @if English
 * Occurs after the local user join channel success.
 * When the distance between the sound source and the PA equipment is too close, howling may occur. The NERTC SDK supports howling detection. When a howling signal is detected, the callback is automatically triggered until the howling stops. The application layer can prompt the user to mute the microphone or directly mute the microphone when the app receives the howling information returned by the callback.
 * @note Howling detection is used in human voice scenarios, such as voice chat rooms or online meetings. We recommend that you do not use howling detection in entertainment scenes that include background music.
 * @endif
 * @if Chinese
 * 检测啸叫回调, 调用JoinChannel成功后，会一直周期性触发该回调, 不建议在该回调里做频繁的API调用和耗时操作。
 * 当声源与扩音设备之间因距离过近时，可能会产生啸叫。NERTC SDK 支持啸叫检测，当检测到有啸叫信号产生的时候，参数flag为 YES，无啸叫时参数flag为 NO。App 应用层可以在有啸叫时，提示用户静音麦克风，或直接静音麦克风。
 * @note 啸叫检测功能一般用于语音聊天室或在线会议等纯人声环境，不推荐在包含背景音乐的娱乐场景中使用。
 * @param flag 是否检测到啸叫。
 * @endif
 */
- (void)onNERtcEngineAudioHasHowling:(BOOL)flag;

/**
 * @if English 
 * Occurs when the state of the media stream relay changes.
 * @param state The state of the media stream relay. For more information, see {@link NERtcChannelMediaRelayState}.
 * @param channelName The name of the destination room where the media streams are relayed.
 * @endif
 * @if Chinese
 * 跨房间媒体流转发状态发生改变回调。
 * @param state 当前跨房间媒体流转发状态。详细信息请参考 {@link NERtcChannelMediaRelayState}。
 * @param channelName 媒体流转发的目标房间名。
 * @endif
 */
- (void)onNERtcEngineChannelMediaRelayStateDidChange:(NERtcChannelMediaRelayState)state channelName:(NSString *)channelName;

 /**
  * @if English 
  * Returns forwarding events during the media stream relay.
  * @param event The media stream relay event. For more information, see {@link NERtcChannelMediaRelayEvent}.
  * @param channelName The name of the destination room where the media streams are relayed.
  * @param error The specific error code. For more information, see {@link NERtcEngineErrorCode.NERtcError}.
  * @endif
  * @if Chinese
  * 媒体流相关转发事件回调。
  * @param event 当前媒体流转发事件。详细信息请参考 {@link NERtcChannelMediaRelayEvent}。
  * @param channelName 转发的目标房间名。
  * @param error 相关错误码。详细信息请参考 {@link NERtcEngineErrorCode.NERtcError}。
  * @endif
  */
- (void)onNERtcEngineDidReceiveChannelMediaRelayEvent:(NERtcChannelMediaRelayEvent)event channelName:(NSString *)channelName error:(NERtcError)error;

 /**
  * @if English 
  * Returns the audio recording state.
  * @param code The status code of the audio recording. For more information, see {@link NERtcAudioRecordingCode}.
  * @param filePath The path based on which the recording file is stored.

  * @endif
  * @if Chinese
  * 音频录制状态回调。
  * @param code 音频录制状态码。详细信息请参考 {@link NERtcAudioRecordingCode}。
  * @param filePath 音频录制文件保存路径。
  * @endif
  */
- (void)onNERtcEngineAudioRecording:(NERtcAudioRecordingCode)code filePath:(NSString *)filePath;


 /**
  * @if English 
  * Occurs when the published local media stream falls back to an audio-only stream due to poor network conditions or switches back to audio and video stream after the network conditions improve.
  * If you call setLocalPublishFallbackOption and set option to AUDIO_ONLY, this callback is triggered when the locally published stream falls back to audio-only mode due to poor uplink network conditions, or when the audio stream switches back to the audio and video stream after the uplink network conditions improve.
  * @since V4.3.0
  * @param isFallback The option whether the locally published stream falls back to audio-only mode or switches back to audio and video stream.
                         - YES: The published stream from a local client falls back to audio-only mode due to poor uplink network conditions.
                         - NO: The audio stream switches back to the audio and video stream after the uplink network condition improves.
  * @param streamType The type of the video stream, such as mainstream and substream. For more information, see {@link NERtcStreamChannelType}.
  * @endif
  * @if Chinese
  * 本地发布流已回退为音频流、或已恢复为音视频流回调。
  * 如果您调用了设置本地推流回退选项 setLocalPublishFallbackOption 接口，并将 option 设置为 kNERtcStreamFallbackOptionAudioOnly 后，当上行网络环境不理想、本地发布的媒体流回退为音频流时，或当上行网络改善、媒体流恢复为音视频流时，会触发该回调。  
  * @since V4.3.0
  * @param isFallback 本地发布流已回退或已恢复。
                         - YES： 由于网络环境不理想，发布的媒体流已回退为音频流。
                         - NO：由于网络环境改善，从音频流恢复为音视频流。
  * @param streamType 对应的视频流类型，即主流或辅流。详细信息请参考 {@link NERtcStreamChannelType}。
  * @endif
  */
- (void)onNERtcEngineLocalPublishFallbackToAudioOnly:(BOOL)isFallback streamType:(NERtcStreamChannelType)streamType;

/**
 * @if English 
 * Occurs when the subscribed remote media stream falls back to audio-only stream due to poor network conditions or switches back to the audio and video stream after the network conditions improve.
 * If you call setRemoteSubscribeFallbackOption and set option to AUDIO_ONLY, this callback is triggered when the subscribed remote media stream falls back to audio-only mode due to poor downlink network conditions, or when the subscribed remote media stream switches back to the audio and video stream after the downlink network conditions improve.
 * @since V4.3.0
 * @param uid        The ID of a remote user.
 * @param isFallback The option whether the subscribed remote media stream falls back to audio-only mode or switches back to the audio and video stream.
                           - YES: The subscribed remote media stream falls back to audio-only mode due to poor downstream network conditions.
                           - NO: The subscribed remote media stream switches back to the audio and video stream after the downstream network conditions improve.
 * @param streamType The type of the video stream, such as mainstream and substream. For more information, see {@link NERtcStreamChannelType}.
 * @endif
 * @if Chinese
 * 订阅的远端流已回退为音频流、或已恢复为音视频流回调。
 * 如果你调用了设置远端订阅流回退选项 setRemoteSubscribeFallbackOption 接口并将 option 设置 kNERtcStreamFallbackOptionAudioOnly 后，当下行网络环境不理想、仅接收远端音频流时，或当下行网络改善、恢复订阅音视频流时，会触发该回调。
 * @since V4.3.0
 * @param uid        远端用户 ID。
 * @param isFallback 远端订阅流已回退或恢复：
                           - YES： 由于网络环境不理想，订阅的远端流已回退为音频流。
                           - NO：由于网络环境改善，订阅的远端流从音频流恢复为音视频流。
 * @param streamType 对应的视频流类型，即主流或辅流。详细信息请参考 {@link NERtcStreamChannelType}。
 * @endif
 */

- (void)onNERtcEngineRemoteSubscribeFallbackToAudioOnly:(uint64_t)uid isFallback:(BOOL)isFallback streamType:(NERtcStreamChannelType)streamType;

/**
 * @if English 
 * Reports the last mile network quality of the local user once every two seconds before the user joins the channel.
 * <br> After the application calls the startLastmileProbeTest method, this callback reports once every five seconds the uplink and downlink last mile network conditions of the local user before the user joins the channel.
 * @since V4.5.0
 * @param quality       The last mile network quality.
 * @endif
 * @if Chinese
 * 通话前网络上下行 last mile 质量状态回调。
 * <br>该回调描述本地用户在加入房间前的 last mile 网络探测的结果，以打分形式描述上下行网络质量的主观体验，您可以通过该回调预估本地用户在音视频通话中的网络体验。
 * <br>在调用 startLastmileProbeTest 之后，SDK 会在约 5 秒内返回该回调。
 * @since V4.5.0
 * @param quality       网络上下行质量，基于上下行网络的丢包率和抖动计算，探测结果主要反映上行网络的状态。
 * @endif
 */
- (void)onNERtcEngineLastmileQuality:(NERtcNetworkQuality)quality;

/** 
 * @if English 
 * Reports the last-mile network probe result.
 * <br>This callback describes a detailed last-mile network detection report of a local user before joining a channel. The report provides objective data about the upstream and downstream network quality, including network jitter and packet loss rate.  You can use the report to objectively predict the network status of local users during an audio and video call. 
 * <br>The SDK triggers this callback within 30 seconds after the app calls the startLastmileProbeTest method.
 * @since V4.5.0
 * @param result        The uplink and downlink last-mile network probe test result. 
 * @endif
 * @if Chinese
 * 通话前网络上下行 Last mile 质量探测报告回调。
 * <br>该回调描述本地用户在加入房间前的 last mile 网络探测详细报告，报告中通过客观数据反馈上下行网络质量，包括网络抖动、丢包率等数据。您可以通过该回调客观预测本地用户在音视频通话中的网络状态。
 * <br>在调用 startLastmileProbeTest 之后，SDK 会在约 30 秒内返回该回调。
 * @since V4.5.0
 * @param result        上下行 Last mile 质量探测结果。
 * @endif
 */
- (void)onNERtcEngineLastmileProbeTestResult:(NERtcLastmileProbeResult *)result;

/**
 * @if English
 * Reports whether the virtual background is successfully enabled.
 * @param enabled Whether the virtual background is successfully enabled:
 * - true: The virtual background is successfully enabled.
 * - false: The virtual background is not successfully enabled.
 * @param reason The reason why the virtual background is not successfully enabled or the message that confirms success:
 * {@link NERtcConstants.NERtcVirtualBackgroundSourceStateReason}
 * @endif
 * @if Chinese
 * 通知虚拟背景是否成功开启的回调。
 * <br> 调用 {@link INERtcEngineEx#enableVirtualBackground:backData:} 接口启用虚拟背景功能后，SDK 会触发此回调。
 * @note 如果自定义虚拟背景是 PNG 或 JPG 格式的图片，SDK 会在读取图片后才会触发此回调，因此可能存在一定延时。
 * @param enabled 是否已成功开启虚拟背景。
 * - true：成功开启虚拟背景。
 * - false：未成功开启虚拟背景。
 * @param reason 虚拟背景开启出错的原因或开启成功的提示。详细信息请参考 {@link NERtcVirtualBackgroundSourceStateReason}
 * @endif
 */
- (void)onNERtcEngineVirtualBackgroundSourceEnabled:(BOOL)enabled reason:(NERtcVirtualBackgroundSourceStateReason)reason;

/**
 * @if English
 * Occurs when the local video watermark takes affect.
 * @since V4.6.10
 * @param type            Type of video stream, main stream or substream. For more information, see {@link NERtcStreamChannelType}.
 * @param state           Watermark status. For more information, see {@link NERtcLocalVideoWatermarkState}.
 * @endif
 * @if Chinese
 * 本地视频水印生效结果回调。
 * @since V4.6.10
 * @param type 对应的视频流类型，即主流或辅流。详细信息请参考 {@link NERtcStreamChannelType}。
 * @param state 水印状态。详细信息请参考 {@link NERtcLocalVideoWatermarkState}。
 * @endif
 */
- (void)onNERtcEngineLocalVideoWatermarkStateWithStreamType:(NERtcStreamChannelType)type
                                                      state:(NERtcLocalVideoWatermarkState)state;
/**
 * @if Chinese
 * 权限密钥即将过期事件回调。
 * - 由于 PermissionKey 具有一定的时效，在通话过程中如果 PermissionKey 即将失效，SDK 会提前 30 秒触发该回调，提醒用户更新 PermissionKey。
 * @since V4.6.29
 * @par 使用前提
 * 请在 INERtcEngine 接口类中通过 {@link INERtcEngine#setupEngineWithContext:} 接口设置回调监听。
 * @par 相关接口
 * 在收到此回调后可以调用 {@link INERtcEngineEx#updatePermissionKey:} 方法更新权限密钥。
 * @endif
 */
- (void)onNERtcEnginePermissionKeyWillExpire;

/**
 * @if Chinese
 * 更新权限密钥事件回调。
 * - 调用 {@link INERtcEngineEx#updatePermissionKey:} 方法主动更新权限密钥后，SDK 会触发该回调，返回权限密钥更新的结果。
 * @since V4.6.29
 * @par 使用前提
 * 请在 INERtcEngine 接口类中通过 {@link INERtcEngine#setupEngineWithContext:} 接口设置回调监听。
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
 *  <tr>
 *      <td>error</td>
 *      <td> {@link NERtcEngineErrorCode.NERtcError} </td>
 *      <td>错误码。<ul><li>kNERtcErrChannelPermissionKeyError（30901）：权限密钥错误。<li>kNERtcErrChannelPermissionKeyTimeout（30902）：权限密钥超时。</td>
 *  </tr>
 *  <tr>
 *      <td>timeout</td>
 *      <td>NSUInteger</td>
 *      <td>更新后的权限密钥剩余有效时间。单位为秒。</td>
 *  </tr>
 * </table> 
 * @endif
 */
- (void)onNERtcEngineUpdatePermissionKey:(NSString *)key error:(NERtcError)error timeout:(NSUInteger)timeout;

/**
 * @if English
 * Occurs when a remote user enables data channel.
 * @param userID           The ID of a remote user.
 * @since V5.0.0
 * @endif
 * @if Chinese
 * 远端用户开启数据通道的回调。
 * @param userID           远端用户ID。
 * @since V5.0.0
 * @endif
 */
- (void)onNERtcEngineUserDataDidStart:(uint64_t)userID;

/**
 * @if English
 * Occurs when a remote user disables data channel.
 * @param userID           The ID of a remote user.
 * @endif
 * @if Chinese
 * 远端用户停用数据通道的回调。
 * @param userID           远端用户ID。
 * @endif
 */
- (void)onNERtcEngineUserDataDidStop:(uint64_t)userID;

/**
 * @if English
 * Occurs when a remote user send data by data channel.
 * @param userID           The ID of a remote user.
 * @param data    The received data channel data.
 * @endif
 * @if Chinese
 * 远端用户通过数据通道发送数据的回调。
 * @param userID           远端用户ID。
 * @param data     数据。
 * @endif
 */
- (void)onNERtcEngineUserDataReceiveMessage:(uint64_t)userID data:(NSData *)data;

/**
 * @if English
 * Occurs when a Remote user data channel status changed.
 * @param userID           The ID of a remote user.
 * @endif
 * @if Chinese
 * 远端用户数据通道状态变更回调。
 * @param userID           远端用户ID。
 * @endif
 */
- (void)onNERtcEngineUserDataStateChanged:(uint64_t)userID;

/**
 * @if English
 * Occurs when a Remote user data channel buffer amount changed.
 * @param userID             The ID of a remote user.
 * @param previousAmount  The amount before changed.
 * @endif
 * @if Chinese
 * 远端用户数据通道buffer变更回调。
 * @param userID             远端用户ID。
 * @param previousAmount  变更前大小。
 * @endif
 */
- (void)onNERtcEngineUserDataBufferedAmountChanged:(uint64_t)userID previousAmount:(uint64_t)previousAmount;

/**
 * @if Chinese
 * 实验功能回调接口，用于回调一些非正式的事件及数据通知
 * @since V5.5.0
 * @param key 功能对应的key
 * @param param 回调的参数，每个key对应的参数，数据类型不一样，需要转换后使用，详情请联系技术支持
 * @endif
 */
- (void)onNERtcEngineLabFeatureDidCallbackWithKey:(NSString*)key param:(id)param;

@end

/**
 * @if English
 * Returns the audio data
 * <br>If you need to process audio data, you need to implement this protocol.
 * @endif
 * @if Chinese
 * 音频数据回调
 * <br>如果需要对音频数据做处理，需要实现这个 protocol 
 * @endif
 */
@protocol NERtcEngineAudioFrameObserver <NSObject>

@optional

/**
 * @if English 
 * Occurs when the audio data is captured. The callback is used to process the audio data.
 * - The returned audio data has read and write permissions.
 * - The callback is triggered when an operation is driven by the local audio data.
 * - The callback returns synchronously, and the engine continues the audio processing flow.
 * You cannot modify the content void *data points to in the frame and the format. If you want to modify the format, you can set the format by calling setParameter :  kNERtcKeyObserveRecordAudioFrameFormat.
 * @param frame The audio frame data. For more information, see {@link NERtcAudioFrame}.
 * @endif
 * @if Chinese
 * 采集音频数据回调，用于声音处理等操作。
 * - 返回音频数据支持读写。
 * - 有本地音频数据驱动就会回调。
 * - 需要同步返回，engine 将会继续音频处理流程。
 * 允许修改 frame 里 void *data 所指向的内容，不允许修改 format。如果对 format 有要求，请通过setParameter :  kNERtcKeyObserveRecordAudioFrameFormat 进行设置。
 * @param frame 音频帧数据，详细信息请参考 {@link NERtcAudioFrame}。
 * @endif
 */
- (void)onNERtcEngineAudioFrameDidRecord:(NERtcAudioFrame *)frame;


/**
 * @if English 
 * Occurs when the audio data is played back. The callback is used to process the audio data.
 * - The callback returns synchronously, and the engine continues the audio processing flow.
 * - The returned audio data has read and write permissions.
 * - The callback is triggered when an operation is driven by the local audio data.
 * <br>You cannot modify the content void *data points to in the frame and the format. If you want to modify the format, you can set the format by calling setParameter : kNERtcKeyObserveRecordAudioFrameFormat.
 * @param frame The audio frame data. For more information, see {@link NERtcAudioFrame}.
 * @endif
 * @if Chinese
 * 播放音频数据回调，用于声音处理等操作。
 * - 需要同步返回，engine 将会继续音频处理流程。
 * - 返回音频数据支持读写。
 * - 有本地音频数据驱动就会回调。
 * <br>允许修改 frame 里 void *data 所指向的内容，不允许修改 format。如果对 format 有要求，请通过setParameter :  kNERtcKeyObservePlaybackAudioFrameFormat 进行设置。
 * @param frame 音频帧数据，详细信息请参考 {@link NERtcAudioFrame}。
 * @endif
 */
- (void)onNERtcEngineAudioFrameWillPlayback:(NERtcAudioFrame *)frame;

/**
 * @if English 
 * Gets the raw audio data of a specified remote user before audio mixing.
 * <br>After the audio observer is registered, if the remote audio is subscribed by default and the remote user enables the audio, the SDK triggers this callback when the audio data before audio mixing is captured, and the audio data is returned to the user.
 * @note
 * - The returned audio data is read-only.
 * - You cannot modify the content that void *data pointed to in the frame and the format.
 * @deprecated This API is about to be deprecated. Use {@link NERtcEngineAudioFrameObserver#onNERtcEnginePlaybackAudioFrameBeforeMixingWithUserID:frame:channelId:} instead. In multi-channel scenarios, channelId is used to identify different channels.
 * @param userID The ID of a remote user.
 * @param frame The audio frame data. For more information, see {@link NERtcAudioFrame}.
 * @endif
 * @if Chinese
 * 获取某一远端用户混音前的音频数据。
 * <br>成功注册音频观测器后，如果订阅了远端音频（默认订阅）且远端用户开启音频后，SDK 会在捕捉到混音前的音频数据时，触发该回调，将音频数据回调给用户。
 * @note
 * - 返回音频数据只读。
 * - 不支持修改 frame 里 void *data 所指向的内容，不支持修改 format。
 * @deprecated 即将废弃，请改用接口 {@link NERtcEngineAudioFrameObserver#onNERtcEnginePlaybackAudioFrameBeforeMixingWithUserID:frame:channelId:}。在多房间场景下，此接口可通过 channelId 识别不同房间。 
 * @param userID 远端用户的 ID。
 * @param frame 音频帧数据，详细信息请参考 {@link NERtcAudioFrame}。
 * @endif
 */
- (void)onNERtcEnginePlaybackAudioFrameBeforeMixingWithUserID:(uint64_t)userID frame:(NERtcAudioFrame *)frame;

/**
 * @if English
 * Gets the raw audio data of a specified remote user before audio mixing.
 * <br>After the audio observer is registered, if the remote audio is subscribed by default and the remote user enables the audio, the SDK triggers this callback when the audio data before audio mixing is captured, and the audio data is returned to the user.
 * @note
 * - The returned audio data is read-only.
 * - You cannot modify the content that void *data pointed to in the frame and the format.
 * @since V4.5.0 
 * @param userID      The ID of a remote user.
 * @param frame       The audio frame data. For more information, see {@link NERtcAudioFrame}.
 * @param channelId   Channel ID. In multi-channel scenarios, channelId is used to identify different channels.   
 * @endif
 * @if Chinese
 * 获取某一远端用户混音前的音频数据。
 * <br>成功注册音频观测器后，如果订阅了远端音频（默认订阅）且远端用户开启音频后，SDK 会在捕捉到混音前的音频数据时，触发该回调，将音频数据回调给用户。
 * @note
 * - 返回音频数据只读。
 * - 不支持修改 frame 里 void *data 所指向的内容，不支持修改 format。
 * @since V4.5.0 
 * @param userID      远端用户的 ID。
 * @param frame       音频帧数据，详细信息请参考 {@link NERtcAudioFrame}。
 * @param channelId   房间 ID。在多房间场景下，channelId 用于识别不同的房间。 
 * @endif
 */
- (void)onNERtcEnginePlaybackAudioFrameBeforeMixingWithUserID:(uint64_t)userID frame:(NERtcAudioFrame *)frame channelId:(uint64_t)channelId;

/**
 * @if English 
 * Gets the raw audio data of the local user and all remote users after mixing.
 * @note
 * - The callback is in read-only mode.
 * - The returned audio data is read-only.
 * - The callback is triggered when an operation is driven by the local audio data.
 * You cannot modify the content that void *data points to in the frame and the format. If you need to modify the format, you can call setMixedAudioFrameParameters.
 * @param frame The audio frame data. For more information, see {@link NERtcAudioFrame}.
 * @endif
 * @if Chinese
 * 获取本地用户和所有远端用户混音后的原始音频数据。
 * @note
 * - 该回调为只读模式。
 * - 返回音频数据只读。
 * - 有本地音频数据驱动就会回调。
 * 不支持修改 frame 里 void *data 所指向的内容，不允许修改 format。如果对 format 有要求，请通过setMixedAudioFrameParameters进行设置
 * @param frame 音频帧数据，详细信息请参考 {@link NERtcAudioFrame}。
 * @endif
 */
- (void)onNERtcEngineMixedAudioFrame:(NERtcAudioFrame *)frame;


/**
 * @if English
 * Returns the data of the local audio substream, used for the custom audio substream.
 * @note
 * - If the substream is enabled, the SDK will return the data.
 * - The returned audio data supports the write or read modes. The callback is applied for custom audio substream. A write mode is recommended.
 * - You are allowed to edit the content in void *data of a frameid *data but cannot edit the format. If you want to change the format, set the format by calling setParameter:kNERtcKeyObserveRecordAudioFrameFormat.
 * @param frame PCM audio frame data. For more information, see {@link NERtcAudioFrame}.
 * @endif
 * @if Chinese
 * 本地音频辅流数据回调，用于自定义音频辅流数据。
 * @note
 * - 只要开启辅流，SDK 就会返回此回调。
 * - 返回音频数据支持读或写模式，由于该回调一般用于自定义音频辅流数据，建议使用写模式。
 * - 允许修改 frame 里 void *data 所指向的内容，不允许修改 format。如果对 format 有要求，请通过 setParameter:kNERtcKeyObserveRecordAudioFrameFormat 进行设置。
 * @param frame 音频帧数据，详细信息请参考 {@link NERtcAudioFrame}。
 * @endif
 */
- (void)onNERtcEngineSubStreamAudioFrameDidRecord:(NERtcAudioFrame *)frame;

/**
 * @if English
 * Gets the audio substream data from a specified remote user before mixing audio.
 * <br>After the audio observer is registered, the SDK will get the audio data from a specified remote user before mixing if the remote audio substream is subscribed to and the remote user publishes the audio substream.
 * @note
 * - The returned audio data can only be read.
 * - You are allowed to edit the content in void *data of a frameid *data but cannot edit the format.
 * @param userID     A remote user ID.
 * @param frame PCM audio frame data. For more information, see {@link NERtcAudioFrame}.
 * @param channelId  Room ID. For multiple rooms, channelId is used to identify the rooms.
 * @endif
 * @if Chinese
 * 获取指定远端用户混音前的音频辅流数据。
 * <br>成功注册音频观测器后，如果订阅了远端音频辅流（默认订阅）且远端用户开启音频辅流后，SDK 会在捕捉到混音前的音频数据时，触发该回调，将音频数据发送给您。
 * @note
 * - 返回的音频数据只读。
 * - 不支持修改 frame 里 void *data 所指向的内容，不支持修改 format。
 * @param userID     远端用户的 ID。
 * @param frame PCM 音频帧数据，详细信息请参考 {@link NERtcAudioFrame}。
 * @param channelId  房间 ID。在多房间场景下，channelId 用于识别不同的房间。
 * @endif
 */
- (void)onNERtcEnginePlaybackSubStreamAudioFrameBeforeMixingWithUserID:(uint64_t)userID frame:(NERtcAudioFrame *)frame channelId:(uint64_t)channelId;


@end

@protocol NERtcEnginePacketObserver <NSObject>

 @optional
/**
 * 音频包发送回调
 * 在音频包被发送给远端用户前触发
 * @param packet 数据包
 */
- (BOOL)onSendAudioPacket:(NERtcPacket *)packet;
/**
 * 视频包发送回调
 * 在视频包被发送给远端用户前触发
 * @param packet 数据包
 */
- (BOOL)onSendVideoPacket:(NERtcPacket *)packet;
/**
 * 接收音频包回调
 * 在收到远端用户的音频包前触发
 * @param packet 数据包
 */
- (BOOL)onReceiveAudioPacket:(NERtcPacket *)packet;
/**
 * 接收视频包回调
 * 在收到远端用户的视频包前触发
 * @param packet 数据包
 */
- (BOOL)onReceiveVideoPacket:(NERtcPacket *)packet;

@end

NS_ASSUME_NONNULL_END

#pragma clang diagnostic pop
