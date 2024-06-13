//
//  INERtcChannel.h
//  NERtcSDK
//
//  Created by yuan on 2021/6/6.
//  Copyright © 2021 Netease. All rights reserved.
//

#ifndef INERtcChannel_h
#define INERtcChannel_h

#import <Foundation/Foundation.h>
#import "NERtcChannelDelegate.h"
#import "NERtcEngineStatistics.h"
#import "INERtcEngine.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"

NS_ASSUME_NONNULL_BEGIN

/**
 * @if English
 * The `INERtcChannel` class provides methods that enable real-time communications in a specified channel. By creating multiple NERtcChannel instances, users can join multiple channels.
 * @since V4.5.0
 * @endif
 * @if Chinese
 * INERtcChannel 类在指定房间中实现实时音视频功能。通过创建多个 NERtcChannel 对象，用户可以同时加入多个房间。
 * @since V4.5.0
 * @endif
 */
@protocol INERtcChannel <NSObject>

/**
 * @if English 
 * Destroys an IRtcChannel instance to release resources.
 * @since V4.5.0
 * @endif
 * @if Chinese
 * @since V4.5.0
 * 销毁 IRtcChannel 实例，释放资源。
* @endif
*/
- (int)destroy;

/**
 * @if English 
 * Sets the channel delegate.
 * @since V4.5.0
 * @param channelDelegate The channel delegate.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置 channel 的回调。
 * @since V4.5.0
 * @param channelDelegate channel 的回调对象。
 * @return 操作返回值，成功则返回 0
* @endif
*/
- (int)setChannelDelegate:(nullable id<NERtcChannelDelegate>)channelDelegate;

/**
 *
 * @if Chinese
 * 设置驱动 NERtcChannelDelegate 事件回调队列
 * @since V5.5.10
 * @par 调用时机
 * 请在引擎初始化后调用此接口，且该方法在加入房间前后均可调用。
 * @note
 * - 如果您不指定自己的 delegateQueue 或者设置为 NULL, 默认会采用 MainQueue 作为驱动 NERtcCallback 事件回调的队列。
 * - 如果您指定了自己的 delegateQueue，请不要直接 NERtcEngineDelegateEx 回调函数中操作UI，会引发线程安全问题。且需要考虑线程的生命周期，如果线程提前终止，将无法收到 NERtcChannelDelegate 的回调。
 */
- (int)setDelegateQueue:(nullable dispatch_queue_t)delegateQueue;

/**
 * @if English 
 * Gets the current channel name.
 * @since V4.5.0
 * @return
 * - Success: Return IRtcChannel channel name.
 * - Fail: Return nothing.
 * @endif
 * @if Chinese
 * 获取当前房间名。
 * @since V4.5.0
 * @return
 * - 成功：当前 IRtcChannel 房间名。
 * - 失败：返回空。
 * @endif
 */
- (NSString *)getChannelName;

/**
 * @if English
 * Gets the connection status.
 * @since V4.5.0
 * @return The current channel status is returned.
 * @endif
 * @if Chinese
 * 获取当前房间连接状态。
 * @since V4.5.0
 * @return 当前房间连接状态。
 * @endif
 */
- (NERtcConnectionStateType)connectionState;

/**
 * @if English
 * Joins an RTC room.
 * <br>If the specified room does not exist when you join the room, a room with the specified name is automatically created in the server provided by CommsEase.
 * - After you join a room by calling the relevant method supported by the SDK, users in the same room can make audio or video calls. Users that join the same room can start a group chat. Apps that use different AppKeys cannot communicate with each other.
 * - If you join a room by calling this method, onNERtcEngineUserDidJoinWithUserID is triggered on a remote client.
 * - If you join a room, you subscribe to the audio streams from other users in the same room by default. In this case, the data usage is billed. To unsubscribe, you can call the mute method.
 * <p>@since V4.5.0
 * @param token The certification signature used in authentication (NERTC Token). Valid values:
 *                  - null。 You can set the value to null in the debugging mode. This poses a security risk. We recommend that you contact your business manager to change to the default safe mode before your product is officially launched.
 *                  - NERTC Token acquired. In safe mode, the acquired token must be specified. If the specified token is invalid, users are unable to join a room. We recommend that you use the safe mode.
 * @param completion The callback when the operation is complete.
 * @return The value returned. A value of 0 indicates that the operation is performed.
 * @endif
 * @if Chinese
 * 加入音视频房间。
 * <br>通过本接口可以实现加入音视频房间，加入房间后可以与房间内的其他用户进行音视频通话。
 * @since V3.6.0
 * @par 调用时机
 * 请在初始化后调用该方法。
 * @note
 * - 同一个房间内的用户可以互相通话，多个用户加入同一个房间，可以群聊。使用不同 App Key 的 App 之间不能互通。
 * - 用户成功加入房间后，默认订阅房间内所有其他用户的音频流，可能会因此产生用量并影响计费；若您想取消自动订阅，可以在通话前通过调用 {@link INERtcEngine#setParameters:} 方法实现。
 * - 加入音视频房间时，如果指定房间尚未创建，云信服务器内部会自动创建一个同名房间。
 * - 传参中 uId 可选，若不指定则默认为 0，SDK 会自动分配一个随机 uId，并在 {@link NERtcJoinChannelCompletion} 回调方法中返回；App 层必须记住该返回值并维护，SDK 不对该返回值进行维护。
 * - 网络测速过程中无法加入房间。
 * - 若使用了云代理功能，uid 不允许传 0，请用真实的 uid。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>token</td>
 *      <td>NSString</td>
 *      <td>安全认证签名（NERTC Token），可以设置为：<ul><li>null。调试模式下可设置为 null。安全性不高，建议在产品正式上线前在云信控制台中将鉴权方式恢复为默认的安全模式。<li>已获取的 NERTC Token。安全模式下必须设置为获取到的 Token 。若未传入正确的 Token 将无法进入房间。推荐使用安全模式。</td>
 *  </tr>
 *  <tr>
 *      <td>completion</td>
 *      <td>{@link NERtcJoinChannelCompletion}</td>
 *      <td>操作完成的 block 回调。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * NERtcChannel *channel = [NERtcEngine sharedEngine] createChannel:@"secondChannel"];
 * int result = [channel joinChannelWithToken:token completion:^(NSError * _Nullable error, uint64_t channelId, uint64_t elapesd, uint64_t uid) {
 *                 if (error) {
 *                    //join room failed
 *                 }
 *                 else {
 *                //join room success
 *                 }
 *             }];
 * if(kNERtcNoError != result) {
 *     //join room failed
 * }
 * @endcode
 * @par 相关接口
 * - 您可以调用 {@link INERtcChannel#leaveChannel} 方法离开房间。
 * - 直播场景中，观众角色可以通过 {@link INERtcEngine#switchChannelWithToken:channelName:completion:} 接口切换房间。
 * @par 相关回调
 * 成功调用该方法加入房间后，远端会触发 {@link NERtcEngineDelegate#onNERtcEngineUserDidJoinWithUserID:userName:} 回调。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30005（kNERtcErrInvalidState)：状态错误，比如引擎尚未初始化或正在进行网络探测。
 * @endif
 */
- (int)joinChannelWithToken:(NSString *)token
                 completion:(NERtcJoinChannelCompletion)completion;

/**
 * @if English
 * Joins an RTC room.
 * <br>If the specified room does not exist when you join the room, a room with the specified name is automatically created in the server provided by CommsEase.
 * - After you join a room by calling the relevant method supported by the SDK, users in the same room can make audio or video calls. Users that join the same room can start a group chat. Apps that use different AppKeys cannot communicate with each other.
 * - If you join a room by calling this method, onNERtcEngineUserDidJoinWithUserID is triggered on a remote client.
 * - If you join a room, you subscribe to the audio streams from other users in the same room by default. In this case, the data usage is billed. To unsubscribe, you can call the mute method.
 * <p>@since V4.5.0
 * @param token The certification signature used in authentication (NERTC Token). Valid values:
 *                  - null。 You can set the value to null in the debugging mode. This poses a security risk. We recommend that you contact your business manager to change to the default safe mode before your product is officially launched.
 *                  - NERTC Token acquired. In safe mode, the acquired token must be specified. If the specified token is invalid, users are unable to join a room. We recommend that you use the safe mode.
 * @param completion The callback when the operation is complete.
 * @return The value returned. A value of 0 indicates that the operation is performed.
 * @endif
 * @if Chinese
 * 加入音视频房间。
 * <br>通过本接口可以实现加入音视频房间，加入房间后可以与房间内的其他用户进行音视频通话。
 * @since V3.6.0
 * @par 调用时机
 * 请在初始化后调用该方法。
 * @note
 * - 同一个房间内的用户可以互相通话，多个用户加入同一个房间，可以群聊。使用不同 App Key 的 App 之间不能互通。
 * - 用户成功加入房间后，默认订阅房间内所有其他用户的音频流，可能会因此产生用量并影响计费；若您想取消自动订阅，可以在通话前通过调用 {@link INERtcEngine#setParameters:} 方法实现。
 * - 加入音视频房间时，如果指定房间尚未创建，云信服务器内部会自动创建一个同名房间。
 * - 传参中 uId 可选，若不指定则默认为 0，SDK 会自动分配一个随机 uId，并在 {@link NERtcJoinChannelCompletion} 回调方法中返回；App 层必须记住该返回值并维护，SDK 不对该返回值进行维护。
 * - 网络测速过程中无法加入房间。
 * - 若使用了云代理功能，uid 不允许传 0，请用真实的 uid。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>token</td>
 *      <td>NSString</td>
 *      <td>安全认证签名（NERTC Token），可以设置为：<ul><li>null。调试模式下可设置为 null。安全性不高，建议在产品正式上线前在云信控制台中将鉴权方式恢复为默认的安全模式。<li>已获取的 NERTC Token。安全模式下必须设置为获取到的 Token 。若未传入正确的 Token 将无法进入房间。推荐使用安全模式。</td>
 *  </tr>
 *  <tr>
 *      <td>uId</td>
 *      <td>uint64_t</td>
 *      <td>用户的唯一标识 ID。</td>
 *  </tr>
 *  <tr>
 *      <td>completion</td>
 *      <td>{@link NERtcJoinChannelCompletion}</td>
 *      <td>操作完成的 block 回调。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * NERtcChannel *channel = [NERtcEngine sharedEngine] createChannel:@"secondChannel"];
 * int result = [channel joinChannelWithToken:token myUid:uid completion:^(NSError * _Nullable error, uint64_t channelId, uint64_t elapesd, uint64_t uid) {
 *                 if (error) {
 *                    //join room failed
 *                 }
 *                 else {
 *                //join room success
 *                 }
 *             }];
 * if(kNERtcNoError != result) {
 *     //join room failed
 * }
 * @endcode
 * @par 相关接口
 * - 您可以调用 {@link INERtcChannel#leaveChannel} 方法离开房间。
 * - 直播场景中，观众角色可以通过 {@link INERtcEngine#switchChannelWithToken:channelName:completion:} 接口切换房间。
 * @par 相关回调
 * 成功调用该方法加入房间后，远端会触发 {@link NERtcEngineDelegate#onNERtcEngineUserDidJoinWithUserID:userName:} 回调。
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30005（kNERtcErrInvalidState)：状态错误，比如引擎尚未初始化或正在进行网络探测。
 * @endif
 */
- (int)joinChannelWithToken:(NSString *)token
                      myUid:(uint64_t)uId
                 completion:(NERtcJoinChannelCompletion)completion;

/**
 * @if English
 * Joins an RTC room.
 * <br>If the specified room does not exist when you join the room, a room with the specified name is automatically created in the server provided by CommsEase.
 * - After you join a room by calling the relevant method supported by the SDK, users in the same room can make audio or video calls. Users that join the same room can start a group chat. Apps that use different AppKeys cannot communicate with each other.
 * - If you join a room by calling this method, onNERtcEngineUserDidJoinWithUserID is triggered on a remote client.
 * - If you join a room, you subscribe to the audio streams from other users in the same room by default. In this case, the data usage is billed. To unsubscribe, you can call the mute method.
 * <p>@since V4.5.0
 * @param token The certification signature used in authentication (NERTC Token). Valid values:
 *                  - null。 You can set the value to null in the debugging mode. This poses a security risk. We recommend that you contact your business manager to change to the default safe mode before your product is officially launched.
 *                  - NERTC Token acquired. In safe mode, the acquired token must be specified. If the specified token is invalid, users are unable to join a room. We recommend that you use the safe mode.
 * @param completion The callback when the operation is complete.
 * @return The value returned. A value of 0 indicates that the operation is performed.
 * @endif
 * @if Chinese
 * 加入音视频房间。
 * <br>通过本接口可以实现加入音视频房间，加入房间后可以与房间内的其他用户进行音视频通话。
 * @since V3.6.0
 * @par 调用时机
 * 请在初始化后调用该方法。
 * @note
 * - 同一个房间内的用户可以互相通话，多个用户加入同一个房间，可以群聊。使用不同 App Key 的 App 之间不能互通。
 * - 用户成功加入房间后，默认订阅房间内所有其他用户的音频流，可能会因此产生用量并影响计费；若您想取消自动订阅，可以在通话前通过调用 {@link INERtcEngine#setParameters:} 方法实现。
 * - 加入音视频房间时，如果指定房间尚未创建，云信服务器内部会自动创建一个同名房间。
 * - 传参中 uId 可选，若不指定则默认为 0，SDK 会自动分配一个随机 uId，并在 {@link NERtcJoinChannelCompletion} 回调方法中返回；App 层必须记住该返回值并维护，SDK 不对该返回值进行维护。
 * - 网络测速过程中无法加入房间。
 * - 若使用了云代理功能，uid 不允许传 0，请用真实的 uid。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>token</td>
 *      <td>NSString</td>
 *      <td>安全认证签名（NERTC Token），可以设置为：<ul><li>null。调试模式下可设置为 null。安全性不高，建议在产品正式上线前在云信控制台中将鉴权方式恢复为默认的安全模式。<li>已获取的 NERTC Token。安全模式下必须设置为获取到的 Token 。若未传入正确的 Token 将无法进入房间。推荐使用安全模式。</td>
 *  </tr>
 *  <tr>
 *      <td>channelOptions</td>
 *      <td>NERtcJoinChannelOptions *</td>
 *      <td>加入房间时设置一些特定的房间参数。默认值为 NULL，详细信息请参考 {@link NERtcJoinChannelOptions}。</td>
 *  </tr>
 *  <tr>
 *      <td>completion</td>
 *      <td>{@link NERtcJoinChannelCompletion}</td>
 *      <td>操作完成的 block 回调。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * NERtcChannel *channel = [NERtcEngine sharedEngine] createChannel:@"secondChannel"];
 * int result = [channel joinChannelWithToken:token completion:^(NSError * _Nullable error, uint64_t channelId, uint64_t elapesd, uint64_t uid) {
 *                 if (error) {
 *                    //join room failed
 *                 }
 *                 else {
 *                //join room success
 *                 }
 *             }];
 * if(kNERtcNoError != result) {
 *     //join room failed
 * }
 * @endcode
 * @par 相关接口
 * - 您可以调用 {@link INERtcChannel#leaveChannel} 方法离开房间。
 * - 直播场景中，观众角色可以通过 {@link INERtcEngine#switchChannelWithToken:channelName:completion:} 接口切换房间。
 * @par 相关回调
 * 成功调用该方法加入房间后，远端会触发 {@link NERtcEngineDelegate#onNERtcEngineUserDidJoinWithUserID:userName:} 回调。
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30005（kNERtcErrInvalidState)：状态错误，比如引擎尚未初始化或正在进行网络探测。
 * @endif
 */
- (int)joinChannelWithToken:(NSString *)token
                      myUid:(uint64_t)uId
             channelOptions:(nullable NERtcJoinChannelOptions *)channelOptions
                 completion:(void(^)(NSError * _Nullable error, uint64_t channelId, uint64_t elapesd, uint64_t uid, NERtcJoinChannelExtraInfo * _Nullable info))completion;
/**
 * @if English
 * Leaves a room, such as hanging up or ending a call.
 * A user must call the leaveChannel method to end the call before the user makes another call.
 * After you leave the room by calling the method, the onNERtcEngineDidLeaveChannelWithResult callback is triggered on the local client, and the onNERtcEngineUserDidLeaveWithUserID callback is triggered on a remote client.
 * @since V4.5.0
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 离开音视频房间。
 * <br>通过本接口可以实现挂断或退出通话，并释放本房间内的相关资源。
 * @since V3.5.0
 * @par 调用时机
 * 请在初始化并成功加入房间后调用该方法。
 * @note
 * 结束通话时必须调用此方法离开房间，否则无法开始下一次通话。
 * @par 示例代码
 * @code
 * [channel leaveChannel];
 * @endcode
 * @par 相关回调
 * 成功调用该方法离开房间后，本地会触发 {@link NERtcEngineDelegate#onNERtcEngineDidLeaveChannelWithResult:} 回调，远端会触发 {@link NERtcEngineDelegate#onNERtcEngineUserDidLeaveWithUserID:reason:} 回调。
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal）：引擎尚未初始化。
 *      - 30005（kNERtcErrInvalidState)：状态错误，比如正在进行网络探测。
 * @endif
 */
- (int)leaveChannel;

/**
 * @if English
 * Enables or disables local audio capture.
 * <brWhen an app joins a room, the voice module is enabled by default.
 * <brThe method does not affect receiving or playing back the remote audio stream. The enableLocalAudio(NO) method is suitable for scenarios where a user wants to receive the remote audio stream without sending audio streams to other users in the room.
 * @note
 * - The enableLocalAudio method is different from muteLocalAudioStream. The enableLocalAudio method is used to enable local audio capture and processing whereas the muteLocalAudioStream method is used to stop or restart pushing the local audio stream.
 * - The method enables the internal engine. The setting remains unchanged after the leaveChannel method is called.
 * - Starting from V4.4.0, turning on or off local audio capture does not affect the playback of music files. You can still play music files by calling startAudioMixingWithOption after you set enableLocalAudio(NO).
 * @since V4.5.0
 * @param enabled The option whether to enable local Audio capture.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese 
 * 开启/关闭本地音频采集和发送。
 * <br>通过本接口可以实现开启或关闭本地语音功能，进行本地音频采集及处理。
 * @since V3.5.0
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法在加入房间前后均可调用。
 * @note
 * - 加入房间后，语音功能默认为开启状态。
 * - 该方法设置内部引擎为启用状态，在 leaveChannel 后仍然有效。
 * - 该方法不影响接收或播放远端音频流，enableLocalAudio(false) 适用于只下行不上行音频流的场景。
 * - 自 V4.4.0 版本起，开启或关闭本地音频采集的操作不会影响伴音/音效接口的使用，比如 enableLocalAudio(NO) 后仍可以调用 {@link INERtcEngineEx#startAudioMixingWithOption:} 方法播放音乐文件。
 * - 该方法会操作音频硬件设备，建议避免频繁开关，否则可能导致设备异常。
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
 *      <td>是否启用本地音频的采集和发送：<ul><li>YES：开启本地音频采集。<li>NO：关闭本地音频采集。关闭后，远端用户会接收不到本地用户的音频流；但本地用户依然可以接收到远端用户的音频流。</td>
 *  </tr>
 * </table>     
 * @par 示例代码
 * @code
 * //打开音频采集
 * [channel enableLocalAudio:YES];
 * //关闭音频采集
 * [channel enableLocalAudio:NO];
 * @endcode
 * @par 相关回调
 * - 开启音频采集后，远端会触发 {@link NERtcEngineDelegate#onNERtcEngineUserAudioDidStart:} 回调。
 * - 关闭音频采集后，远端会触发 {@link NERtcEngineDelegate#onNERtcEngineUserAudioDidStop:} 回调。
 * @par 相关接口
 * {@link INERtcChannel#muteLocalAudio:}：两者的差异在于，enableLocalAudio 用于开启本地语音采集及处理，而 muteLocalAudio 用于停止或继续发送本地音频流。
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *          - 30001（kNERtcErrFatal）：引擎尚未初始化。
 *          - 30004（kNERtcErrNotSupported）：多房间场景下，在其他房间内已经开启了音频。 
 *          - 30005（kNERtcErrInvalidState）：状态错误，比如引擎尚未初始化，或者正在进行网络测速。
 *          - 30101（kNERtcErrChannelNotJoined）：尚未加入房间。
 *          - 30300（kNERtcErrOSAuthorize）：未开启麦克风权限。
 * @endif
 */
- (int)enableLocalAudio:(BOOL)enabled;

/**
 * @if English
 * Specifies whether to enable local video capture.
 * @note
 * - You can call this method before or after you join a room.
 * - After you enable or disable local video capture, the onNERtcEngineUserVideoDidStartWithUserID or onNERtcEngineUserVideoDidStop callback is triggered on a remote client.
 * @param enabled The option whether to enable local video capture.
 * @since V4.5.0
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 开启或关闭本地视频的采集与发送。
 * <br>通过本接口可以实现开启或关闭本地视频，不影响接收远端视频。
 * @since V3.5.0
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
 * @note
 * 该方法设置内部引擎为开启或关闭状态, 在 {@link INERtcChannel#leaveChannel} 后仍然有效。
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
 *      <td>是否开启本地视频采集与发送：<ul><li>YES：开启本地视频采集。<li>NO：关闭本地视频采集。关闭后，远端用户无法接收到本地用户的视频流；但本地用户仍然可以接收到远端用户的视频流。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //打开视频
 * [channel enableLocalVideo:YES];
 * //关闭视频
 * [channel enableLocalVideo:NO];
 * @endcode 
 * @par 相关回调
 * - 开启本地视频采集后，远端会收到 {@link NERtcEngineDelegate#onNERtcEngineUserAudioDidStart:} 回调。
 * - 关闭本地视频采集后，远端会收到 {@link NERtcEngineDelegate#onNERtcEngineUserAudioDidStop:} 回调。
 * @par 相关接口
 * 若您希望开启辅流通道的视频采集，请调用 {@link INERtcChannel#enableLocalVideo:streamType:} 方法。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *        - 30001（kNERtcErrFatal）：通用错误，一般表示引擎错误，尝试再次调用此接口即可。
 *        - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如已开启外部视频采集。
 *        - 30300（kNERtcErrOSAuthorize）：应用未获取到操作系统的摄像头权限。
 * @endif
 */
- (int)enableLocalVideo:(BOOL)enabled;

/**
 * @if Chinese
 * 开启或关闭本地视频的采集与发送。
 * <br>通过主流或辅流视频通道进行本地视频流的采集与发送。
 * @since V4.6.20
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
 * @note
 * 该方法设置内部引擎为开启或关闭状态, 在 {@link INERtcEngine#leaveChannel} 后仍然有效。
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
 *      <td>enabled</td> 
 *      <td>BOOL</td> 
 *      <td>是否开启本地视频采集与发送：<ul><li>YES：开启本地视频采集。<li>NO：关闭本地视频采集。关闭后，远端用户无法接收到本地用户的视频流；但本地用户仍然可以接收到远端用户的视频流。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //打开视频主流
 * [channel enableLocalVideo:YES streamType:kNERtcStreamChannelTypeMainStream];
 * //关闭视频主流
 * [channel enableLocalVideo:NO streamType:kNERtcStreamChannelTypeMainStream];
 * //打开视频辅流
 * [channel enableLocalVideo:YES streamType:kNERtcStreamChannelTypeSubStream];
 * //关闭视频辅流
 * [channel enableLocalVideo:NO streamType:kNERtcStreamChannelTypeSubStream];
 * @endcode 
 * @par 相关回调
 * - streamType 为 kNERtcStreamChannelTypeMainStream（主流）时：
 *        - 开启本地视频采集后，远端会收到 {@link NERtcEngineDelegate#onNERtcEngineUserAudioDidStart:} 回调。
 *        - 关闭本地视频采集后，远端会收到 {@link NERtcEngineDelegate#onNERtcEngineUserAudioDidStop:} 回调。
 * - streamType 为 kNERtcStreamChannelTypeSubStream（辅流）时： 
 *        - 开启本地视频采集后，远端会收到 {@link NERtcEngineDelegate#onNERtcEngineUserSubStreamAudioDidStart:} 回调。
 *        - 关闭本地视频采集后，远端会收到 {@link NERtcEngineDelegate#onNERtcEngineUserSubStreamAudioDidStop:} 回调。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *        - 30001（kNERtcErrFatal）：通用错误，一般表示引擎错误，尝试再次调用此接口即可。
 *        - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如已开启外部视频采集。
 *        - 30027（kNERtcErrDeviceOccupied）: 所选设备已被占用。比如已通过主流通道开启了摄像头，无法再通过辅流通道开启摄像头。
 *        - 30300（kNERtcErrOSAuthorize）：应用未获取到操作系统的摄像头权限。
 * @endif
 */
- (int)enableLocalVideo:(BOOL)enabled streamType:(NERtcStreamChannelType)streamType;

/**
 * @if English
 * Publishes or unpublishes the local audio stream.
 * <br>When a user joins a room, the feature is enabled by default.
 * <br>The method does not affect receiving or playing the remote audio stream. The enableLocalAudio(false) method is suitable for scenarios where clients only receives remote media streams and does not publish any local streams.
 * @note 
 * - The method controls data transmitted over the main stream
 * - The method can be called before or after a user joins a room.
 * @since V4.6.10
 * @param enable specifies whether to publish the local audio stream.
 * - true(default): publishes the local audio stream.
 * - false: unpublishes the local audio stream.
 * @param mediaType  media type. Audio type is supported.
 * @return 
 * - 0: success
 * - Others: failure
 * @endif
 * @if Chinese
 * 开启或关闭本地媒体流（主流）的发送。
 * <br>该方法用于开始或停止向网络发送本地音频或视频数据。
 * <br>该方法不影响接收或播放远端媒体流，也不会影响本地音频或视频的采集状态。
 * @since V4.6.10
 * @note 
 * - 该方法暂时仅支持控制音频流的发送。
 * - 该方法在加入房间前后均可调用。
 * - 停止发送媒体流的状态会在通话结束后被重置为允许发送。
 * - 成功调用该方法切换本地用户的发流状态后，房间内其他用户会收到 {@link NERtcEngineDelegate#onNERtcEngineUserAudioDidStart:}（开启发送音频）或 {@link NERtcEngineDelegate#onNERtcEngineUserAudioDidStop:}（停止发送音频）的回调。
 * @par 相关接口
 * - {@link INERtcChannel#muteLocalAudio:}：
 *        - 在需要开启本地音频采集（监测本地用户音量）但不发送音频流的情况下，您也可以调用 muteLocalAudio(YES) 方法。
 *        - 两者的差异在于， muteLocalAudio(YES) 仍然保持与服务器的音频通道连接，而 enableMediaPub(NO) 表示断开此通道，因此若您的实际业务场景为多人并发的大房间，建议您调用 enableMediaPub 方法。  
 * @param enabled 是否发布本地媒体流。
 * - YES（默认）：发布本地媒体流。
 * - NO：不发布本地媒体流。
 * @param mediaType 媒体发布类型，暂时仅支持音频。
 * @return 
 * - 0：方法调用成功。
 * - 其他：方法调用失败。
 * @endif
 */
- (int)enableMediaPub:(BOOL)enabled withMediaType:(NERtcMediaPubType)mediaType;

/**
 * @if English
 * Enables or disables the dual-stream mode.
 * <br>The method sets the individual-stream mode or dual-stream mode. If the dual-stream mode is enabled on the publishing client, the receiver can choose to receive the high-quality stream or low-quality stream video. The high-quality stream has a high resolution and high bitrate. The low-quality stream has a low resolution and low bitrate.
 * @note
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * - The method applies to only camera data. Video streams from external input and screen sharing are not affected.
 * - You can call this method before or after you join a room.
 * @since V4.5.0
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
 * [channel enableDualStreamMode:YES];
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
 * Sets the camera capturer configuration.
 * <br>For a video call or live streaming, generally the SDK controls the camera output parameters. By default, the SDK matches the most appropriate resolution based on the user's setLocalVideoConfig configuration. When the default camera capture settings do not meet special requirements, we recommend using this method to set the camera capturer configuration:
 * - If you want better quality for the local video preview, we recommend setting config as kNERtcCameraOutputQuality. The SDK sets the camera output parameters with higher picture quality.
 * - To customize the width and height of the video image captured by the local camera, set the camera capture configuration as kNERtcCameraOutputManual.
 * <p>@note 
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
 * - 该方法仅适用于视频主流，若您希望为辅流通道设置摄像头的采集配置，请调用 {@link INERtcChannel#setCameraCaptureConfig:streamType:} 方法。
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
 * [channel setCameraCaptureConfig:config];
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
 * [channel setCameraCaptureConfig:capConfig streamType:kNERtcStreamChannelTypeMainStream];
 * //设置本地摄像头辅流采集配置
 * NERtcCameraCaptureConfiguration *subCapConfig = [[NERtcCameraCaptureConfiguration alloc] init];
 * subCapConfig.captureWidth = 1280;
 * subCapConfig.captureHeight = 720;
 * [channel setCameraCaptureConfig:subCapConfig streamType:kNERtcStreamChannelTypeSubStream];
 * @endcode 
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *        - 30003（kNERtcErrInvalidParam）：参数错误，比如 config 设置为空。
 *        - 30004（kNERtcErrNotSupported）：不支持的操作，比如当前使用的是纯音频 SDK。
 *        - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎未初始化成功。
 * @endif
 */
- (int)setCameraCaptureConfig:(NERtcCameraCaptureConfiguration *)config streamType:(NERtcStreamChannelType)streamType;

/**
 * @if English 
 * Sets the video encoding profile.
 * @note <br>
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * - You can call this method before or after you join the room.
 * - After the setting is configured. The setting takes effect the next time local video is enabled.
 * - Each profile has a set of video parameters, such as resolution, frame rate, and bitrate. All the specified values of the parameters are the maximum values in optimal conditions. If the video engine cannot use the maximum value of resolution, frame rate, or bitrate due to unreliable network conditions, the value closest to the maximum value is used.
 * @param config The video encoding profile. For more information, see {@link NERtcVideoEncodeConfiguration}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置视频编码属性。
 * <br>通过此接口可以设置视频主流的编码分辨率、裁剪模式、码率、帧率、带宽受限时的视频编码降级偏好、编码的镜像模式、编码的方向模式参数，详细信息请参考[设置视频属性](https://doc.yunxin.163.com/docs/jcyOTA0ODM/zcwMTY4MzM)。
 * @since V3.5.0
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
 * @note
 * - 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
 * - 每个属性对应一套视频参数，例如分辨率、帧率、码率等。所有设置的参数均为理想情况下的最大值。当视频引擎因网络环境等原因无法达到设置的分辨率、帧率或码率的最大值时，会取最接近最大值的那个值。
 * - 此接口为全量参数配置接口，重复调用此接口时，SDK 会刷新此前的所有参数配置，以最新的传参为准。所以每次修改配置时都需要设置所有参数，未设置的参数将取默认值。
 * - 自 V4.5.0 版本起，此方法设置实时生效；此前的版本中，此方法设置成功后，下次开启本端视频时生效。
 * @par 参数说明 
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>config</td> 
 *      <td>{@link NERtcVideoEncodeConfiguration}</td> 
 *      <td>视频编码属性配置。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //设置本地视频主流编码参数
 * NERtcVideoEncodeConfiguration *config = [[NERtcVideoEncodeConfiguration alloc] init];
 * config.width = 640;// 设置分辨率宽
 * config.height = 360;// 设置分辨率高
 * config.cropMode = kNERtcVideoCropMode16_9;      // 设置裁剪格式为16:9
 * config.frameRate = kNERtcVideoFrameRateFps30; //视频帧率
 * config.minFrameRate = mMinFrameRate; //视频最小帧率
 * config.bitrate = mBitrate; //视频编码码率
 * config.minBitrate = mMinBitrate; //视频编码最小码率
 * config.degradationPreference = kNERtcDegradationDefault; ;//带宽受限时的视频编码降级偏好
 * [channel setLocalVideoConfig:config];
 * @endcode 
 * @par 相关接口
 * 若您希望为视频辅流通道设置编码属性，请调用 {@link INERtcChannel#setLocalVideoConfig:streamType:} 方法。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *        - 30003（kNERtcErrInvalidParam）：参数错误，比如 config 设置为空。
 *        - 30004（kNERtcErrNotSupported）：不支持的操作，比如当前使用的是纯音频 SDK。
 *        - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎未初始化成功。
 * @endif
 */
- (int)setLocalVideoConfig:(NERtcVideoEncodeConfiguration *)config;

/**
 * @if Chinese
 * 设置视频编码属性。
 * <br>通过此接口可以设置视频主流或辅流的编码分辨率、裁剪模式、码率、帧率、带宽受限时的视频编码降级偏好、编码的镜像模式、编码的方向模式参数。
 * @since V4.6.20
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
 * @note
 * - 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
 * - 每个属性对应一套视频参数，例如分辨率、帧率、码率等。所有设置的参数均为理想情况下的最大值。当视频引擎因网络环境等原因无法达到设置的分辨率、帧率或码率的最大值时，会取最接近最大值的那个值。
 * - 此接口为全量参数配置接口，重复调用此接口时，SDK 会刷新此前的所有参数配置，以最新的传参为准。所以每次修改配置时都需要设置所有参数，未设置的参数将取默认值。
 * @par 参数说明 
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>config</td> 
 *      <td>{@link NERtcVideoEncodeConfiguration}</td> 
 *      <td>视频编码属性配置。</td>
 *  </tr>
 *  <tr>
 *      <td>streamType</td>
 *      <td>{@link NERtcStreamChannelType}</td>
 *      <td>视频通道类型：<ul><li>kNERtcStreamChannelTypeMainStream：主流。<li>kNERtcStreamChannelTypeSubStream：辅流。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //设置本地视频主流编码参数
 * NERtcVideoEncodeConfiguration *config = [[NERtcVideoEncodeConfiguration alloc] init];
 * config.width = 640;// 设置分辨率宽
 * config.height = 360;// 设置分辨率高
 * config.cropMode = kNERtcVideoCropMode16_9;      // 设置裁剪格式为16:9
 * config.frameRate = kNERtcVideoFrameRateFps30; //视频帧率
 * config.minFrameRate = mMinFrameRate; //视频最小帧率
 * config.bitrate = mBitrate; //视频编码码率
 * config.minBitrate = mMinBitrate; //视频编码最小码率
 * config.degradationPreference = kNERtcDegradationDefault; //带宽受限时的视频编码降级偏好
 * [channel setLocalVideoConfig:config streamType:kNERtcStreamChannelTypeMainStream];
 * //设置本地视频辅流编码参数
 * NERtcVideoEncodeConfiguration *subConfig = [[NERtcVideoEncodeConfiguration alloc] init];
 * subConfig.width = 640;
 * subConfig.height = 360;
 * subConfig.cropMode = kNERtcVideoCropMode16_9;      
 * subConfig.frameRate = kNERtcVideoFrameRateFps30; 
 * subConfig.minFrameRate = mMinFrameRate; 
 * subConfig.bitrate = mBitrate;
 * subConfig.minBitrate = mMinBitrate; 
 * subConfig.degradationPreference = kNERtcDegradationDefault;
 * [channel setLocalVideoConfig:subConfig streamType:kNERtcStreamChannelTypeSubStream];
 * @endcode 
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *        - 30003（kNERtcErrInvalidParam）：参数错误，比如 config 设置为空。
 *        - 30004（kNERtcErrNotSupported）：不支持的操作，比如当前使用的是纯音频 SDK。
 *        - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎未初始化成功。
 * @endif
 */
- (int)setLocalVideoConfig:(NERtcVideoEncodeConfiguration *)config streamType:(NERtcStreamChannelType)streamType;

/**
 * @if English
 * Switches between the front and rear cameras.
 * <br>Make sure that you call this method after the camera starts. For example, you can call this method after you call startPreview or joinChannel.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 切换前置/后置摄像头。
 * <br>该方法需要在相机启动后调用，例如调用 startPreview 或 joinChannel 后。
 * @note 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
 - (int)switchCamera;

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
 * @if English
 * Subscribes to or unsubscribes from audio streams from specified remote users.
 * <br>After a user joins a room, audio streams from all remote users are subscribed by default. You can call this method to subscribe to or unsubscribe from audio streams from all remote users.
 * @note You can call this method before or after you join a room.
 * @since V4.5.0
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
 * 退出房间后，此接口的设置将恢复至默认。
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
 * [channel subscribeRemoteAudio:YES forUserID:12345];
 * //取消订阅对方uid为12345的音频主流
 * [channel subscribeRemoteAudio:NO forUserID:12345];
 * @endcode
 * @par 相关接口
 * 若您希望订阅指定远端用户的音频辅流，请调用 {@link INERtcChannel#subscribeRemoteSubStreamAudio:forUserID:} 方法。
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
 * @since V4.5.0
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
 * [channel subscribeAllRemoteAudio:YES];
 * //取消订阅所有远端用户的音频主流
 * [channel subscribeAllRemoteAudio:NO];
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
 * [channel muteLocalAudio:YES];
 * //发送本地音频
 * [channel muteLocalAudio:NO];
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
 * <br>该方法允许 SDK 定期向 App 反馈本地发流用户和瞬时音量最高的远端用户（最多 3 位）的音量相关信息，即当前谁在说话以及说话者的音量。
 * <br>启用该方法后，只要房间内有发流用户，无论是否有人说话，SDK 都会在加入房间后根据预设的时间间隔触发 {@link NERtcEngineDelegateEx#onRemoteAudioVolumeIndication:totalVolume:} 回调。
 * @since V4.6.10
 * @param enable   是否启用说话者音量提示。
 *                  - YES：启用说话者音量提示。
 *                  - NO：关闭说话者音量提示。
 * @param interval 指定音量提示的时间间隔。单位为毫秒。必须设置为 100 毫秒的整数倍值，建议设置为 200 毫秒以上。
 * @param enableVad 是否启用本地采集人声监测。
 *                  - YES：启用本地采集人声监测。
 *                  - NO：关闭本地采集人声监测。
 * @return
 * - 0：方法调用成功。
 * - 其他：方法调用失败。
 * @endif
 */
- (int)enableAudioVolumeIndication:(BOOL)enable interval:(uint64_t)interval vad:(BOOL)enableVad;

/**
 * @if English
 * Sets the local view.
 * <br>This method is used to set the display information about the local video. The method is applicable only to local users. Remote users are not affected. Apps can call this API operation to associate with the view that plays local video streams. During application development, in most cases, before joining a room, you must first call this method to set the local video view after the SDK is initialized.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @since V4.5.0
 * @param canvas The video canvas. For more information, see {@link NERtcVideoCanvas}. If you want to delete the canvas, you can set the value to nil.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置本地用户视图。
 * <br>通过本接口可以实现绑定本地用户和显示视图，并设置本地用户视图在本地显示时的镜像模式和裁减比例，只影响本地用户看到的视频画面。
 * @since V3.5.0
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
 * @note
 * - 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
 * - 在实际业务中，通常建议在初始化后即调用该方法进行本地视图设置，然后再加入房间或开启预览。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>render</td>
 *      <td>{@link NERtcVideoCanvas}</td>
 *      <td>本地用户视频的画布。设置为 nil 表示取消并释放已设置的画布。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * UIView *localUserView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
 * NERtcVideoCanvas *canvas = [[NERtcVideoCanvas alloc] init];
 * canvas.container = localUserView;
 * canvas.renderMode = kNERtcVideoRenderScaleFit;
 * canvas.mirrorMode = kNERtcVideoMirrorModeAuto;
 * [channel setupLocalVideoCanvas:canvas];
 * @endcode
 * @par 相关接口
 * 若您希望在通话中更新本地用户视图的渲染或镜像模式，请调用 {@link INERtcEngineEx#setLocalRenderScaleMode:} 方法。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *         - 30001（kNERtcErrFatal）：引擎尚未初始化。
 *         - 30004（kNERtcErrNotSupported）：不支持的操作，比如纯音频 SDK 不支持该功能。
 *         - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如尚未加入房间。
 * @endif
 */
- (int)setupLocalVideoCanvas:(NERtcVideoCanvas * _Nullable)canvas;

/**
 * @if English
 * Sets the local video display mode.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @since V4.5.0
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
 * [channel setLocalRenderScaleMode:kNERtcVideoRenderScaleFit];
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
 * Sets views for remote users.
 * <br>This method is used to associate remote users with display views and configure the rendering mode and mirror mode for remote views displayed locally. The method affects only the video screen viewed by local users.
 * @note 
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * - If the user ID is not retrieved, you can set the user ID after the app receives a message delivered when the onNERtcEngineUserDidJoinWithUserID event is triggered.
 * - To disassociate a specified user from a view, you can leave the canvas parameter empty.
 * - After a user leaves the room, the association between a remote user and the view is cleared.
 * @since V4.5.0
 * @param userID The ID of a remote user.
 * @param canvas The video window. if you want to delete the canvas, you can set the value to nil.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置远端用户视图。
 * <br>通过本接口可以实现绑定远端用户和显示视图，并设置远端用户视图在本地显示时的镜像模式和裁减比例，只影响本地用户看到的视频画面。
 * @since V3.5.0
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
 * @note
 * 您可以通过设置 canvas 参数为空（传 nil）以解除远端用户视图绑定；退出房间后，SDK 也会主动清除远端用户和视图的绑定关系。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>canvas</td>
 *      <td> {@link NERtcVideoCanvas} </td>
 *      <td>远端用户视频的画布。</td>
 *  </tr>
 *  <tr>
 *      <td>userID</td>
 *      <td>uint64_t</td>
 *      <td>远端用户的 ID。可以在 {@link NERtcEngineDelegate#onNERtcEngineUserDidJoinWithUserID:userName:} 回调中获取。</td>
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
 *     [channel setupRemoteVideoCanvas:canvas forUserID:userID];
 * }
 * @endcode
 * @par 相关接口
 * 若您希望在通话中更新远端用户视图的渲染模式，请调用 {@link INERtcChannel#setRemoteRenderScaleMode:forUserID:}方法。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *         - 30001（kNERtcErrFatal）：引擎尚未初始化。
 *         - 30004（kNERtcErrNotSupported）：纯音频 SDK 不支持该功能。
 *         - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如尚未加入房间。
 * @endif
 */
- (int)setupRemoteVideoCanvas:(NERtcVideoCanvas * _Nullable)canvas forUserID:(uint64_t)userID;

/**
 * @if English
 * Sets the remote video display mode.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @since V4.5.0
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
 * 请先调用 {@link INERtcChannel#subscribeRemoteVideo:forUserID:streamType:} 方法订阅指定远端用户的视频流。
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
 * [channel setRemoteRenderScaleMode:kNERtcVideoRenderScaleFit forUserID:userID];
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
 * Subscribes to or unsubscribes from video streams from specified remote users.
 * <br>After a user joins a room, the video streams from remote users are not subscribed by default. If you want to view video streams from specified remote users, you can call this method to subscribe to the video streams from the user when the user joins the room or publishes the video streams.
 * @note
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * - You must join a room before you can call the method.
 * @since V4.5.0
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
 * [channel subscribeRemoteVideo:YES forUserID:12345 streamType:kNERtcRemoteVideoStreamTypeHigh];
 * @endcode
 * @par 相关接口
 * 若您希望订阅指定远端用户的视频辅流，请调用 {@link INERtcChannel#subscribeRemoteSubStreamVideo:forUserID:} 方法。
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
 * Stops or resumes publishing the local video stream.
 * <br>If you call the method successfully, the remote client triggers the onNERtcEngineUser:videoMuted: callback.
 * @note
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * - If you call this method to stop publishing the local video stream, the SDK no longer publishes the local video stream.
 * You can call the method before or after you join a room.
 * - If you stop publishing the local video stream by calling this method, the setting is reset to the default state that allows the app to publish the local video stream.
 * - The method is different from enableLocalVideo. The enableLocalVideo method turns off local camera devices. The muteLocalVideovideo method does not affect local video capture, or disables cameras, and responds faster.
 * @since V4.5.0
 * @param muted The option whether to stop publishing the local video stream.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 取消或恢复发布本端视频主流。
 * <br>调用该方法取消发布本地视频主流后，SDK 不再发送本地视频主流。
 * @since V3.5.0
 * @par 使用前提 
 * 一般在通过 {@link INERtcChannel#enableLocalVideo:streamType:} 接口开启本地视频采集并发送后调用该方法。
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
 * @note
 * - 调用该方法取消发布本地视频流时，设备仍然处于工作状态。
 * - 该方法设置内部引擎为启用状态，在 {@link INERtcChannel#leaveChannel} 后设置失效，将恢复至默认，即默认发布本地视频流。
 * - 该方法与 {@link INERtcChannel#enableLocalVideo:streamType:}(NO) 的区别在于，后者会关闭本地摄像头设备，该方法不禁用摄像头，不会影响本地视频流采集且响应速度更快。
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
 * [channel muteLocalVideo:YES];
 * @endcode 
 * @par 相关回调
 * 取消发布本地视频主流或辅流后，远端会收到 {@link NERtcChannelDelegate#onNERtcChannelUser:videoMuted:streamType:} 回调。
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
 * [channel muteLocalVideo:YES streamType:kNERtcStreamChannelTypeMainStream];
 * //恢复发布本地视频主流
 * [channel muteLocalVideo:NO streamType:kNERtcStreamChannelTypeMainStream];
 * //取消发布本地视频辅流
 * [channel muteLocalVideo:YES streamType:kNERtcStreamChannelTypeSubStream];
 * //恢复发布本地视频辅流
 * [channel muteLocalVideo:NO streamType:kNERtcStreamChannelTypeSubStream];
 * @endcode 
 * @par 相关回调
 * 取消发布本地视频主流或辅流后，远端会收到 {@link NERtcEngineDelegateEx#onNERtcEngineUser:videoMuted:streamType:} 回调。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *        - 30004（kNERtcErrNotSupported）：不支持的操作，比如当前使用的是纯音频 SDK。
 * @endif
 */
- (int)muteLocalVideo:(BOOL)muted streamType:(NERtcStreamChannelType)streamType;

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
 * - 该方法设置开启主流外部视频源输入时，内部引擎为启用状态，在切换房间（switchChannelWithToken）、主动离开房间（leaveChannel）、触发断网重连失败回调（onNERtcChannelDidDisconnectWithReason）或触发重新加入房间回调（onNERtcChannelRejoinChannel）后仍然有效。如果需要关闭该功能，请在下次通话前调用接口关闭该功能。
 * - 该方法设置开启辅流外部视频源输入时，在切换房间或触发重新加入房间回调后仍然有效；但在主动离开房间或触发断网重连失败回调后，该接口设置失效，将恢复至默认。
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
 * [channel setExternalVideoSource:YES streamType:kNERtcStreamChannelTypeMainStream];
 * [channel enableLocalVideo:YES streamType:kNERtcStreamChannelTypeMainStream];
 * [channel pushExternalVideoFrame:frame];
 *
 * //通过辅流通道输入外部视频源数据
 * [channel setExternalVideoSource:YES streamType:kNERtcStreamChannelTypeSubStream];
 * NERtcVideoSubStreamEncodeConfiguration *config = [[NERtcVideoSubStreamEncodeConfiguration alloc] init];
 * config.maxProfile = kNERtcVideoProfileHD720P;
 * config.frameRate = kNERtcVideoFrameRateFps15;
 * [channel startScreenCapture:config];
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
 * channel pushExternalVideoFrame:frame];
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

/**
 * @if English
 * Sets the role of a user in live streaming.
 * <br>The method sets the role to host or audience. The permissions of a host and an audience are different.
 * - A host has the permissions to open or close a camera, publish streams, call methods related to publishing streams in interactive live streaming. The status of the host is visible to the users in the room when the host joins or leaves the room.
 * - The audience has no permissions to open or close a camera, call methods related to publishing streams in interactive live streaming, and is invisible to other users in the room when the user that has the audience role joins or leaves the room.
 * <p>@note
 * - By default, a user joins a room as a host. Before a user joins a room, the user can call this method to change the client role to the audiences. After a user joins a room, the user can call this method to switch the client role.
 * - If the user switches the role to the audiences, the SDK automatically closes the audio and video devices.
 * @since V4.5.0
 * @param role The role of a user. For more information, see {@link NERtcClientRole}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置直播场景下的用户角色。
 * <br>通过本接口可以实现将用户角色在“主播”（kNERtcClientRoleBroadcaster）和“观众“（kNERtcClientRoleAudience）之间的切换，用户加入房间后默认为“主播”。
 * @since V3.9.0
 * @par 使用前提
 * 该方法仅在通过 {@link INERtcEngine#setChannelProfile:} 方法设置房间场景为直播场景（kNERtcChannelProfileLiveBroadcasting ）时调用有效。
 * @par 调用时机
 * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
 * @par 业务场景
 * 适用于观众上下麦与主播互动的互动直播场景。
 * @note
 * 用户切换为观众角色时，SDK 会自动关闭音视频设备。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>role</td>
 *      <td>{@link NERtcClientRole}</td>
 *      <td>用户角色：<ul><li>kNERtcClientRoleBroadcaster（0）：设置用户角色为主播。主播可以开关摄像头等设备、可以发布流、可以操作互动直播推流相关接口、加入或退出房间状态对其他房间内用户可见。<li>kNERtcClientRoleAudience（1）：设置用户角色为观众。观众只能收流不能发流、加入或退出房间状态对其他房间内用户不可见。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //切换用户角色为主播
 * [channel setClientRole:kNERtcClientRoleAudience];
 * //切换用户角色为观众
 * [channel setClientRole:kNERtcClientRoleBroadcaster];
 * @endcode
 * @par 相关回调
 * - 加入房间前调用该方法设置用户角色，不会触发任何回调，在加入房间成功后角色自动生效：
 *          - 设置用户角色为主播：加入房间后，远端用户触发 {@link NERtcEngineDelegate#onNERtcEngineUserDidJoinWithUserID:userName:} 回调。
 *          - 设置用户角色为观众：加入房间后，远端用户不触发任何回调。
 * - 加入房间后调用该方法切换用户角色：
 *          - 从观众角色切为主播：本端用户触发 {@link NERtcEngineDelegate#onNERtcEngineDidClientRoleChanged:newRole:} 回调，远端用户触发 {@link NERtcEngineDelegate#onNERtcEngineUserDidJoinWithUserID:userName:} 回调。
 *          - 从主播角色切为观众：本端用户触发 {@link NERtcEngineDelegate#onNERtcEngineDidClientRoleChanged:newRole:} 回调，远端用户触发 {@link NERtcEngineDelegate#onNERtcEngineUserDidLeaveWithUserID:reason:} 回调。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal)：引擎未创建成功。
 * @endif
 */
- (int)setClientRole:(NERtcClientRole)role;

/**
 * @if English
 * Adjust the volume of local signal playback from a specified remote user.
 * <br>After you join the room, you can call the method to set the volume of local audio playback from different remote users or repeatedly adjust the volume of audio playback from a specified remote user.
 * @note
 * - You can call this method after you join a room.
 * - The method is valid in the current call. If a remote user exits the room and rejoins the room again, the setting is still valid until the call ends.
 * - The method adjusts the volume of the mixing audio published by a specified remote user. Only one remote user can be adjusted. If you want to adjust multiple remote users, you need to call the method for the required times.
 * @since V4.5.0
 * @param userID The ID of a remote user.
 * @param volume The playback volume. Valid values: 0 to 400.
 *                 - 0: muted
 *                 - 100: the original volume
 *                 - 400: The maximum value can be four times the original volume. The limit value is protected
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
 * [channel adjustUserPlaybackSignalVolume:50 forUserID:12345];
 * //调整uid为12345的用户在本地的播放音量为0，静音该用户 
 * [channel adjustUserPlaybackSignalVolume:0 forUserID:12345];
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
 * <br>通过此接口可以实现在通话过程中随时调节指定房间内的所有远端用户在本地播放的混音音量。
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
 * [channel adjustChannelPlaybackSignalVolume:50];
 * //调整该房间内的用户在本地的播放音量为0，静音该房间
 * [channel adjustChannelPlaybackSignalVolume:0];
 * @endcode
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *         - 30001（kNERtcErrFatal）：状态错误，比如引擎未初始化。
 * @endif
 */
- (int)adjustChannelPlaybackSignalVolume:(uint32_t)volume;

#pragma mark - Audio Sub Stream

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
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间且收到远端用户开启音频辅流的回调 {@link NERtcChannelDelegate#onNERtcChannelUserSubStreamAudioDidStart:} 后调用。
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
 * [channel subscribeRemoteSubStreamAudio:YES forUserID:userId];
 * //取消订阅 userId 用户的音频辅流
 * [channel subscribeRemoteSubStreamAudio:NO forUserID:userId];
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


#pragma mark - Sub Stream

/**
 * @if English
 * Sets the local substream canvas.
 * This method is used to set the display information about the local screen sharing with the substream video. The app associates with the video view of local substream by calling this method. During application development, in most cases, before joining a room, you must first call this method to set the local video view after the SDK is initialized.
 * @note
 * - If the app uses external rendering, we recommend that you set the video view before you join the room.
 * - Before you join a room, you must call the method after the SDK is initialized.
 * - A canvas is configured for only one user.
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @since V4.5.0
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
 * [channel setupLocalSubStreamVideoCanvas:canvas];
 * @endcode
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal）：状态错误，比如引擎尚未初始化。
 *      - 30004（kNERtcErrNotSupported）：纯音频 SDK 不支持该功能。
 * @endif
 */
- (int)setupLocalSubStreamVideoCanvas:(NERtcVideoCanvas * _Nullable)canvas;

/**
 * @if English
 * Enables screen sharing. The content of the screen sharing is published through the substream.
 * <br>You can call the method only after you join a room.
 * <br>If you join a room and call this method to enable the substream, the onUserSubStreamVideoStart callback is triggered on the remote client.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @since V4.5.0
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
 * [channel startScreenCapture:config];
 * @endcode
 * @par 相关回调
 * 成功开启屏幕共享辅流后，远端会触发 {@link NERtcChannelDelegate#onNERtcChannelUserSubStreamDidStartWithUserID:subStreamProfile:} 回调。
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
 * If you use the method to disable the substream after you join a room, the onNERtcEngineUserSubStreamDidStop callback is triggered on the remote client.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @since V4.5.0
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
 * [channel stopScreenCapture];
 * @endcode
 * @par 相关回调
 * 成功调用此方法后，远端会触发 {@link NERtcChannelDelegate#onNERtcChannelUserSubStreamDidStop:} 回调。
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
 * Use this method if you want to enable screen sharing through the local substream. Apps can call this method multiple times to change the display mode.
 * @note
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * - Before you can call this method, you must set up the canvas for the local substream by calling setupLocalSubStreamVideoCanvas.
 * @since V4.5.0
 * @param mode The video display mode. For more information, see {@link NERtcVideoRenderScaleMode}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置画布中本地屏幕共享辅流视频画面的显示模式。
 * <br>
 * 通过本接口可以实现设置本地发布的屏幕共享视频画面的适应性，即是否裁剪或缩放。
 * @since V3.9.0
 * @par 使用前提
 * 请先调用 {@link INERtcChannel#setupLocalSubStreamVideoCanvas:} 方法设置本地辅流画布。
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
 * [channel setLocalRenderSubStreamScaleMode:kNERtcVideoRenderScaleFit];
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
 * The method associates a remote user with a substream view. You can assign a specified userID to use a corresponding canvas.
 * @note 
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * - If the app uses external rendering, we recommend that you set the canvas after you receive the return of onUserJoined.
 * - If the app does not retrieve the ID of a remote user, you can call the method after the remote user joins the room. You can retrieve the uid of the remote user from the return of onNERtcEngineUserDidJoinWithUserID. You can use this method to set the substream video canvas.
 * - If the remote user leaves the room, the SDK disassociates the remote user from the canvas. The setting automatically becomes invalid.
 * @since V4.5.0
 * @param userID The ID of a remote user.
 * @param canvas The video canvas. For more information, see {@link NERtcVideoCanvas}. To delete the canvas setting, set the value to nil.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置远端用户的视频辅流画布。
 * <br>通过此接口可以实现绑定远端用户和对应辅流的显示视图，即指定某个 uid 使用对应的画布显示。
 * @since V3.9.0
 * @par 使用前提
 * 建议在收到远端用户加入房间的 {@link NERtcChannelDelegate#onNERtcChannelUserDidJoinWithUserID:userName:joinExtraInfo:} 回调后，再调用此接口通过回调返回的 uid 设置对应视图。
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
 *     [channel setupRemoteSubStreamVideoCanvas:canvas forUserID:userID];
 * }
 * @endcode
 * @par 相关接口
 * 可以调用 {@link INERtcChannel#setRemoteRenderScaleMode:forUserID:} 方法在通话过程中更新远端用户视图的渲染模式。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal）：状态错误，比如引擎尚未初始化。
 *      - 30004（kNERtcErrNotSupported）：不支持的操作，比如纯音频 SDK 不支持该功能。
 *      - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如尚未加入房间。
 * @endif
 */
- (int)setupRemoteSubStreamVideoCanvas:(NERtcVideoCanvas * _Nullable)canvas forUserID:(uint64_t)userID;

/**
 * @if English
 * Subscribes to or unsubscribes from remote video substream for screen sharing. You can receive the video substream data only after you subscribe to the video substream.
 * @note
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * - You can call the method only after you join a room.
 * @since V4.5.0
 * @param subscribe The option whether to subscribe to remote video substream for screen sharing.
 * @param userID The ID of a remote user.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 订阅或取消订阅远端用户的视频辅流。
 * @since V3.9.0
 * @par 使用前提
 * - 请先调用 {@link INERtcChannel#setupRemoteSubStreamVideoCanvas:forUserID:}  设置远端用户的视频辅流画布。
 * - 建议在收到远端用户发布视频辅流的回调通知 {@link NERtcChannelDelegate#onNERtcChannelUserSubStreamDidStartWithUserID:subStreamProfile:} 后调用此接口。
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
 * [channel subscribeRemoteSubStreamVideo:YES forUserID:userID];
 * @endcode
 * @par 相关回调
 * - {@link NERtcChannelDelegate#onNERtcChannelUserSubStreamDidStartWithUserID:subStreamProfile:}：远端用户发布视频辅流的回调。
 * - {@link NERtcChannelDelegate#onNERtcChannelUserSubStreamDidStop:}：远端用户停止发布视频辅流的回调。
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
 * @since V4.5.0
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
 * 请先调用 {@link INERtcChannel#subscribeRemoteSubStreamAudio:forUserID:} 方法订阅指定远端用户的屏幕共享流。
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
 * [channel setRemoteRenderSubStreamVideoScaleMode:kNERtcVideoRenderScaleFit forUserID:userID];
 * @endcode
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30004（kNERtcErrNotSupported）：不支持的操作，比如当前使用的是纯音频 SDK。
 *      - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如尚未加入房间。
 * @endif
 */
- (int)setRemoteRenderSubStreamVideoScaleMode:(NERtcVideoRenderScaleMode)mode forUserID:(uint64_t)userID;

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

#pragma mark - 3D Audio

/**
* 设置范围语音模式
* @note 此接口在加入房间前后均可调用。
* @param[in] mode 范围语音模式
* @return
* - 0: 方法调用成功
* - 其他: 调用失败
*/
- (int)setRangeAudioMode:(NERtcRangeAudioMode)mode;

/**
* 设置范围语音小队
* @note 此接口在加入房间前后均可调用。
* @param teamId 小队ID
* @return
* - 0: 方法调用成功
* - 其他: 调用失败
*/
-(int)setRangeAudioTeamID:(int32_t)teamId;

/**
 * 引擎3D音效算法距离范围设置
 * @note 依赖enableSpatializer:applyToTeam接口开启，通话前调用
 * @param audibleDistance 监听器能够听到扬声器并接收其文本消息的距离扬声器的最大距离。[0,1000] 默认值为 32。
 * @param conversationalDistance 控制扬声器音频保持其原始音量的范围，超出该范围时，语音聊天的响度在被听到时开始淡出。
 * 默认值为 1。
 * @param rollOff:距离衰减模式 #NERtcDistanceRolloffModel ，默认值 #kNERtcDistanceRolloffNone
 * @return
 * - 0: 方法调用成功
 * - 其他: 调用失败
 */
- (int)setAudioRecvRange:(int)audibleDistance conversationalDistance:(int)conversationalDistance rollOff:(NERtcDistanceRolloffModel)rollOff;

/**
* 设置空间音效中说话者和接收者的空间位置信息。SDK 会根据该方法中的参数计算接收者和说话者之间的相对位置，进而渲染出空间音效。
 * @since V5.4.0
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
    *      <td>说话者的旋转信息，通过四元组来表示，数据格式为{w, x, y, z}。默认值{0,0,0,0} </td>
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
  * 请先调用 {@link #enableSpatializer()} 接口后，再调用本接口。
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
  * 请先调用 {@link #enableSpatializer:} 接口启用空间音效，再调用本接口。
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
  * 请先调用 {@link #enableSpatializer:} 接口启用空间音效，再调用本接口。
 * @param mode 渲染模式，具体请参见 #NERtcSpatializerRenderMode ，默认值 #kNERtcSpatializerRenderBinauralHighQuality
 * @return
 * - 0: 方法调用成功
 * - 其他: 调用失败
 */
- (int)setSpatializerRenderMode:(NERtcSpatializerRenderMode)mode;

/**
* 初始化引擎3D音效算法
* @note 此接口在加入房间前调用，退出房间后不重置
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
  * @note 开启空间音效后，通话结束时仍保留该开关状态，不重置。
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
     * @since V5.4.101
     * @param[in] type 音频流类型。
     * @param[in] uid_array 不订阅此 用户uid列表 的音频。
     * @note 此列表为全量列表。如果列表为空或 null，取消订阅黑名单。
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
     * @since V5.4.101
     * @param[in] uid_array 只订阅此 用户uid列表 的音频。
     *                      @note 此列表为全量列表。如果列表为空或 null，取消订阅白名单。
     * @return
     * - 0：方法调用成功。
     * - 其他：方法调用失败。
     * @endif
     */
- (int)setSubscribeAudioAllowlist:(NSArray<NSNumber*> *)uidArray;

#pragma mark - Snapshot
/**
 * @if English
 * Takes a local video snapshot.
 * <br>The takeLocalSnapshot method takes a local video snapshot on the local mainstream or local substream. The callback that belongs to the NERtcTakeSnapshotCallback class returns the data of the snapshot image.
 * @note<br>
 * - Before you call the method to capture the snapshot from the mainstream, you must first call startVideoPreview or enableLocalVideo, and joinChannel.
 * - Before you call the method to capture the snapshot from the substream, you must first call joinChannel and startScreenCapture.
 * - You can set text, timestamp, and image watermarks at the same time. If different types of watermarks overlap, the layers overlay previous layers in the image, text, and timestamp sequence.
 * @since V4.5.0
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
 * @since V4.5.0
 * @param streamType 截图的视频流类型。支持设置为主流或辅流。
 * @param callback 截图回调。
 * @note 纯音频SDK禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @return 操作返回值，成功则返回 0
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
 * @since V4.5.0
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
 * @since V4.5.0
 * @param userID 远端用户 ID。
 * @param streamType 截图的视频流类型。支持设置为主流或辅流。
 * @param callback 截图回调。
 * @note 纯音频SDK禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)takeRemoteSnapshot:(NERtcStreamChannelType)streamType forUserID:(uint64_t)userID callback:(NERtcTakeSnapshotCallback)callback;

#pragma mark - SEI

/**
 * @if English
 * Sends supplemental enhancement information (SEI) data through a specified mainstream or substream.
 * When you publish the local audio and video stream, SEI data is also sent to sync some additional information. After SEI data is sent, the receiver can retrieve the content by listening for the onRecvSEIMsg callback.
 * - Condition: After you publish the video stream using the mainstream and substream, you can invoke the method.
 * - Data limit in length: The SEI data can contain a maximum of 4,096 bytes in size. Sending an SEI message fails if the data exceeds the size limit. If a large amount of data is sent, the video bitrate rises. This degrades the video quality or causes frozen frames.
 * - Frequency limit: We recommend that the maximum video frame rate does not exceed 10 fps.
 * - Time to take effect: After the method is called, the SEI data is sent from the next frame in the fastest fashion or after the next 5 frames at the slowest pace.
 * <p>@note
 * - The SEI data is transmitted together with the video stream. If video frame loss occurs due to poor connection quality, the SEI data will also get dropped. We recommend that you increase the frequency within the transmission limits. This way, the receiver can get the data.
 * - Before you specify a channel to transmit the SEI data, you must first enable the data transmission channel.
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @since V4.5.0
 * @param data The custom SEI data.
 * @param type The type of the channel with which the SEI data is transmitted. For more information, see {@link NERtcStreamChannelType}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * -Success: The SEI data joins the queue and is ready for delivery. The data will be sent after the most recent video frame.
 * -Failure: If the data is restricted, the frequency may be too high, the queue is full, or the data exceeds the maximum value of 4k.
 * @endif
 * @if Chinese
 * 指定主流或辅流通道发送媒体增强补充信息（SEI）。
 * <br>在本端推流传输音视频流数据同时，发送流媒体补充增强信息来同步一些其他附加信息。当推流方发送 SEI 后，拉流方可通过监听 onRecvSEIMsg 的回调获取 SEI 内容。
 *  - 调用时机：视频流（主流、辅流）开启后，可调用此函数。
 *  - 数据长度限制： SEI 最大数据长度为 4096 字节，超限会发送失败。如果频繁发送大量数据会导致视频码率增大，可能会导致视频画质下降甚至卡顿。
 *  - 发送频率限制：最高为视频发送的帧率，建议不超过 10 次/秒。
 *  - 生效时间：调用本接口之后，最快在下一帧视频数据帧之后发送 SEI 数据，最慢在接下来的 5 帧视频之后发送。
 * <p>@note
 * - SEI 数据跟随视频帧发送，由于在弱网环境下可能丢帧，SEI 数据也可能随之丢失，所以建议在发送频率限制之内多次发送，保证接收端收到的概率。
 * - 指定通道发送 SEI 之前，需要提前开启对应的数据流通道。
 * - 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @since V4.5.0
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
 * When you publish the local audio and video stream, SEI data is also sent to sync some additional information. After SEI data is sent, the receiver can retrieve the content by listening for the onRecvSEIMsg callback.
 * - Condition: After you publish the video stream using the mainstream and substream, you can invoke the method.
 * - Data limit in length: The SEI data can contain a maximum of 4,096 bytes in size. Sending an SEI message fails if the data exceeds the size limit. If a large amount of data is sent, the video bitrate rises. This degrades the video quality or causes broken video frames.
 * - Frequency limit: We recommend that the maximum video frame rate does not exceed 10 fps.
 * - Time to take effect: After the method is called, the SEI data is sent from the next frame in the fastest fashion or after the next 5 frames at the slowest pace.
 * <p>@note
 * - The SEI data is transmitted together with the video stream. If video frame loss occurs due to poor connection quality, the SEI data will also get dropped. We recommend that you increase the frequency within the transmission limits. This way, the receiver can get the data.
 * - By default, the SEI is transmitted by using the mainstream.
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @since V4.5.0
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
 * <p>@note
 * - SEI 数据跟随视频帧发送，由于在弱网环境下可能丢帧，SEI 数据也可能随之丢失，所以建议在发送频率限制之内多次发送，保证接收端收到的概率。
 * - 调用本接口时，默认使用主流通道发送 SEI。
 * - 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * @since V4.5.0
 * @param data 自定义 SEI 数据。
 * @return 操作返回值，成功则返回 0。
 * - 成功: 成功进入待发送队列，会在最近的视频帧之后发送该数据。
 * - 失败: 数据被限制发送，可能发送的频率太高，队列已经满了，或者数据大小超过最大值 4k。
 * @endif
 */
- (int)sendSEIMsg:(NSData *)data;

#pragma mark - Live Stream

/**
 * @if English
 * Adds a streaming task in a room.
 * After you call the method, the current user can receive a notification about the status of live streaming.
 * @note
 * - The method is applicable to only live streaming.
 * - You can call the method when you are in a room. The method is valid for calls.
 * - Only one URL for the relayed stream is added in each call. You need to call the method multiple times if you want to push many streams. An RTC room with the same channelid can create three different streaming tasks.
 * @since V4.5.0
 * @param taskInfo The information about the streaming task. For more information, {@link NERtcLiveStreamTaskInfo}.
 * @param completion The result. The callback is triggered after the method is called. For more information, see {@link NERtcLiveStreamCompletion}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
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
 * [channel addLiveStreamTask:info compeltion:^(NSString * _Nonnull taskId, kNERtcLiveStreamError errorCode){
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
 * @since V4.5.0
 * @param taskInfo The information about the streaming task. For more information, see {@link NERtcLiveStreamTaskInfo}.
 * @param completion The result. The callback is triggered after the method is called. For more information, see {@link NERtcLiveStreamCompletion}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 更新房间内指定推流任务。
 * 通过此接口可以实现调整指定推流任务的编码参数、画布布局、推流模式等。
 * @since V3.5.0
 * @par 使用前提
 * 请先调用 {@link INERtcChannel#addLiveStreamTask:compeltion:} 方法添加推流任务。
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
 * [channel updateLiveStreamTask:info compeltion:^(NSString * _Nonnull taskId, kNERtcLiveStreamError errorCode){
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
 * @since V4.5.0
 * @param taskId The ID of a streaming task.  
 * @param completion The result. The callback is triggered after the method is called. For more information, see {@link NERtcLiveStreamCompletion}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 删除房间内指定推流任务。
 * @since V3.5.0
 * @par 使用前提
 * 请先调用 {@link INERtcChannel#addLiveStreamTask:compeltion:} 方法添加推流任务。
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
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
 * [channel removeLiveStreamTask:task_id compeltion:^(NSString * _Nonnull taskId, kNERtcLiveStreamError errorCode){
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

/**
 * @if English 
 * Registers a channel media stats observer.
 * @since V4.5.0
 * @param observer The stats observer. For more information, see {@link NERtcChannelMediaStatsObserver}。
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 注册媒体统计信息观测器。
 * @since V4.5.0
 * @param observer 统计信息观测器。详细信息请参考  {@link NERtcChannelMediaStatsObserver}。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)addChannelMediaStatsObserver:(id<NERtcChannelMediaStatsObserver>)observer;

/**
 * @if English 
 * Remove a channel media stats observer.
 * @since V4.5.0
 * @param observer The stats observer. For more information, see {@link NERtcChannelMediaStatsObserver}。
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 移除指定媒体统计信息观测器。
 * @since V4.5.0
 * @param observer 统计信息观测器
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)removeChannelMediaStatsObserver:(id<NERtcChannelMediaStatsObserver>)observer;

/**
 * @if English 
 * Remove all channel media stats observers.
 * @since V4.5.0
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 清除全部媒体统计信息观测器。
 * @since V4.5.0
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)cleanupChannelMediaStatsObserver;


/**
 * @if English
 * Starts to relay media streams across rooms.
 * - The method can invite co-hosts across rooms. Media streams from up to four rooms can be relayed. A room can receive multiple relayed media streams.
 * - After you call the method, the SDK triggers onNERtcEngineChannelMediaRelayStateDidChange and onNERtcEngineDidReceiveChannelMediaRelayEvent. The callback reports the status and events about the current relayed media streams across rooms.
 * <p>@note
 * - You can call this method after you join a room. Before you call the method, you must set the destination room by calling setDestinationInfo in the config parameter.
 * - The method is applicable only to the host in live streaming.
 * - If you want to call the method again, you must first call the stopChannelMediaRelay method to exit the current relay status.
 * - If you succeed in relaying the media stream across rooms, and want to change the destination room, for example, add or remove the destination room, you can call updateChannelMediaRelay to update the information about the destination room. 
 * <p>@since V4.5.0
 * @param config The configuration for media stream relay across rooms. For more information, see {@link NERtcChannelMediaRelayConfiguration}.
 * @return A value of 0 returned indicates that the operation is successful. Otherwise, the operation fails.
 * @endif
 * @if Chinese
 * 开始跨房间媒体流转发。
 * - 该方法可用于实现跨房间连麦等场景。支持同时转发到 4 个房间，同一个房间可以有多个转发进来的媒体流。
 * - 成功调用该方法后，SDK 会触发 onNERtcEngineChannelMediaRelayStateDidChange 和 onNERtcEngineDidReceiveChannelMediaRelayEvent 回调，并在回调中报告当前的跨房间媒体流转发状态和事件。
 * <p>@note
 * - 请在成功加入房间后调用该方法。调用此方法前需要通过 config 中的 setDestinationInfo 设置目标房间。
 * - 该方法仅对直播场景下的主播角色有效。
 * - 成功调用该方法后，若您想再次调用该方法，必须先调用 stopChannelMediaRelay 方法退出当前的转发状态。
 * - 成功开始跨房间转发媒体流后，如果您需要修改目标房间，例如添加或删减目标房间等，可以调用方法 updateChannelMediaRelay 更新目标房间信息。
 * <p>@since V4.5.0
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
 * <p>@note
 * - Before you call the method, you must join the room and call startChannelMediaRelay to relay the media stream across rooms. Before you call the method, you must set the destination room by calling setDestinationInfo in the config parameter.
 * - You can relay the media stream up to four destination rooms. You can first call removeDestinationInfoForChannelName that belongs to the NERtcChannelMediaRelayConfiguration class to remove the rooms that you have no interest in and add new destination rooms.
 * @since V4.5.0
 * @param config The configuration for media stream relay across rooms. For more information, see {@link NERtcChannelMediaRelayConfiguration}.
 * @return A value of 0 returned indicates that the operation is successful. Otherwise, the operation fails.
 * @endif
 * @if Chinese
 * 更新媒体流转发的目标房间。
 * <br>成功开始跨房间转发媒体流后，如果你希望将流转发到多个目标房间，或退出当前的转发房间，可以调用该方法。
 * - 成功开始跨房间转发媒体流后，如果您需要修改目标房间，例如添加或删减目标房间等，可以调用此方法。
 * - 成功调用此方法后，SDK 会触发 onNERtcEngineChannelMediaRelayStateDidChange 回调。如果报告 NERtcChannelMediaRelayStateRunning，则表示已成功转发媒体流。
 * <p>@note
 * - 请在加入房间并成功调用 startChannelMediaRelay 开始跨房间媒体流转发后，调用此方法。调用此方法前需要通过 config 中的 setDestinationInfo 设置目标房间。
 * - 跨房间媒体流转发最多支持 4 个目标房间，您可以在调用该方法之前，通过 NERtcChannelMediaRelayConfiguration 中的 removeDestinationInfoForChannelName 方法移除不需要的房间，再添加新的目标房间。
 * @since V4.5.0
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
 * <p>@since V4.5.0
 * @return A value of 0 returned indicates that the operation is successful. Otherwise, the operation fails.
 * @endif
 * @if Chinese
 * 停止跨房间媒体流转发。
 * <br>
 * 通常在主播离开房间时，跨房间媒体流转发会自动停止；您也可以根据需要随时调用该方法，此时主播会退出所有目标房间。
 * @since V4.2.1
 * @par 使用前提
 * 请在调用 {@link INERtcChannel#startChannelMediaRelay:} 方法开启跨房间媒体流转发之后调用此接口。
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
 * @par 示例代码
 * @code
 * [channel stopChannelMediaRelay];
 * @endcode
 * @par 相关回调
 * {@link NERtcChannelDelegate#onNERtcChannelMediaRelayStateDidChange:channelName:}：跨房间媒体流转发状态发生改变回调。成功调用该方法后会返回 NERtcChannelMediaRelayStateIdle，否则会返回 NERtcChannelMediaRelayStateFailure。
 * {@link NERtcChannelDelegate#onNERtcChannelDidReceiveChannelMediaRelayEvent:channelName:error:}：跨房间媒体流相关转发事件回调。成功调用该方法后会返回 NERtcChannelMediaRelayEventDisconnect，否则会返回 NERtcChannelMediaRelayEventFailure。
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
 * Sets the priority of media streams from a local user.
 * If a user has a high priority, the media stream from the user also has a high priority. In unreliable network connections, the SDK guarantees the quality of the media stream from users with a high priority.
 * @note 
 * - You must call the method before you call joinChannel.
 * - After you switch the room by calling switchChannel, the media stream priority is restored to the default normal priority.
 * @since V4.5.0
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
 * [channel setLocalMediaPriority:kNERtcMediaPriorityHigh preemptive:YES];
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
 * <p>@note You must call the method before you call joinChannel.
 * @since V4.5.0
 * @param option The fallback options for publishing audio and video streams. The default value is disabled. For more information, see {@link NERtcStreamFallbackOptions}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置弱网条件下发布的音视频流回退选项。
 * <br>在网络不理想的环境下，发布的音视频质量都会下降。使用该接口并将 option 设置为 kNERtcStreamFallbackOptionAudioOnly 后:
 * - SDK 会在上行弱网且音视频质量严重受影响时，自动关断视频流，尽量保证音频质量。
 * - 同时 SDK 会持续监控网络质量，并在网络质量改善时恢复音视频流。
 * - 当本地发布的音视频流回退为音频流时，或由音频流恢复为音视频流时，SDK 会触发本地发布的媒体流已回退为音频流 onLocalPublishFallbackToAudioOnly 回调。
 * <p>@note 请在加入房间（joinChannel）前调用此方法。
 * @since V4.5.0
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
 * <p>@note You must call the method before you call joinChannel.
 * @since V4.5.0
 * @param option The fallback option for subscribing to audio and video streams. The default setting is to fall back to the low-quality video stream in the poor network. For more information, see {@link NERtcStreamFallbackOptions}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置弱网条件下订阅的音视频流回退选项。
 * <br>弱网环境下，订阅的音视频质量会下降。通过该接口设置订阅音视频流的回退选项后：
 * - SDK 会在下行弱网且音视频质量严重受影响时，将视频流切换为小流，或关断视频流，从而保证或提高通信质量。
 * - SDK 会持续监控网络质量，并在网络质量改善时自动恢复音视频流。
 * - 当远端订阅流回退为音频流时，或由音频流恢复为音视频流时，SDK 会触发远端订阅流已回退为音频流回调。
 * <p>@note 请在加入房间（joinChannel）前调用此方法。
 * @since V4.5.0
 * @param option   订阅音视频流的回退选项，默认为弱网时回退到视频小流。详细信息请参考 {@link NERtcStreamFallbackOptions}。
 * @return 操作返回值，成功则返回 0
 * @endif
 */
- (int)setRemoteSubscribeFallbackOption:(NERtcStreamFallbackOptions)option;

/**
 * @if Chinese 
 * 更新权限密钥。
 * - 通过本接口可以实现当用户权限被变更，或者收到权限密钥即将过期的回调 {@link NERtcChannelDelegate#onNERtcChannelPermissionKeyWillExpire} 时，更新权限密钥。
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
 * NSString* token = [self getToken];
 * [channel updatePermissionKey:token];
 * @endcode
 * @par 相关回调
 * 调用此接口成功更新权限密钥后会触发 {@link NERtcChannelDelegate#onNERtcChannelUpdatePermissionKey:error:timeout:} 回调。
 * @return 
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30001（kNERtcErrFatal)：通用错误，比如引擎尚未初始化。
 * @endif
 */
- (int)updatePermissionKey:(NSString *)key;

#pragma mark - Other

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

@end

NS_ASSUME_NONNULL_END

#pragma clang diagnostic pop

#endif /* INERtcChannel_h */
