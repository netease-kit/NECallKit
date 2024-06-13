/*
 * Copyright (c) 2021 NetEase, Inc. All rights reserved.
 */

#ifndef INERtcEngine_h
#define INERtcEngine_h

#import <Foundation/Foundation.h>
#import "NERtcEngineEnum.h"
#import "NERtcEngineErrorCode.h"
#import "NERtcEngineDelegate.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"

NS_ASSUME_NONNULL_BEGIN

@class NERtcJoinChannelExtraInfo;

/**
 * @if English 
 * Joins the room.
 * @param error A specific error. If the operation is successful, a value of nil is returned.
 * @param channelId If the operation is successful, a valid channelId is returned.
 * @param elapesd The total time spent joining the room in milliseconds.
 * @param uid The local uid of the client.
 * @endif
 * @if Chinese
 * 加入房间 block。
 * @param error 错误，如果成功则为 nil。
 * @param channelId 如果成功，会返回有效的 channelId。
 * @param elapesd 加入操作总耗时(毫秒)。
 * @param uid 用户 ID。如果在 joinChannel 方法中指定了 uid，此处会返回指定的 ID; 如果未指定 uid（joinChannel 时uid=0），此处将返回云信服务器自动分配的 ID。
 * @endif
 */ 
typedef void(^NERtcJoinChannelCompletion)(NSError * _Nullable error, uint64_t channelId, uint64_t elapesd, uint64_t uid);

/**
 * @if English   
 * Interactive live streaming.
 * @param taskId The ID of a streaming task.
 * @param errorCode The status code of the streaming task. For more information, see {@link NERtcEngineErrorCode.kNERtcLiveStreamError}.
 * @endif
 * @if Chinese
 * 互动直播推流 block。
 * @param taskId 推流任务 id。
 * @param errorCode 状态码。详细信息请参考 {@link NERtcEngineErrorCode.kNERtcLiveStreamError}
 * @endif
 */
typedef void(^NERtcLiveStreamCompletion)(NSString *taskId, kNERtcLiveStreamError errorCode);

/**
 * @if English 
 * Returns the screenshot.
 * @param errorCode The error code. For more information, see {@link NERtcEngineErrorCode.NERtcError}.
 * @param image The screenshot image.
 * @endif
 * @if Chinese
 * 截图结果 block 回调。
 * @param errorCode 错误码。详细信息请参考 {@link NERtcEngineErrorCode.NERtcError}。
 * @param image 截图图片。
 * @endif
 */
typedef void(^NERtcTakeSnapshotCallback)(int errorCode, UIImage * _Nullable image);

@class NERtcEngineContext;
@class NERtcCameraCaptureConfiguration;
@class NERtcVideoEncodeConfiguration;
@class NERtcVideoCanvas;
@class NERtcJoinChannelOptions;

/**
 * @if English 
 * The common interface of NERtcEngine.
 * @endif
 * @if Chinese
 * NERtcEngine 的常用接口。
 * @endif
 */
@protocol INERtcEngine <NSObject>


@property (nonatomic, weak, readonly) id<NERtcEngineDelegateEx> engineDelegate;

/**
 * @if English 
 * Gets the connection status.
 * @return The current network status is returned.
 * @endif
 * @if Chinese
 * 获取当前房间连接状态。
 * @return 当前房间连接状态。
 * @endif
 */
- (NERtcConnectionStateType)connectionState;

/**
 * @if English 
 * Creates an NERtcEngine instance and initializes the NERTC SDK.
 * @note
 * - Before you call other APIs, you must first call this method to create and initialize an NERtc instance.
 * - Apps that use the same AppKey can make audio or video calls, or perform live events in the same room.
 * - One AppKey can be used to create only one NERtc instance. If you want to change the AppKey, you must first delete the current instance by calling the destroyEngine method, then, call this method to create a new instance.
 * - If you do not need the NERtc instance, you can delete the instance by calling the destroyEngine method.
 * @param context The RTC engine context object passed. For more information, see {@link NERtcEngineContext}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 创建 NERtc 实例。
 * <br>通过本接口可以实现创建 NERtc 实例并初始化 NERTC SDK 服务。
 * @since V3.5.0
 * @par 调用时机  
 * 请确保在调用其他 API 前先调用该方法创建并初始化 NERtc 实例。
 * @note
 * - 使用同一个 App Key 的 App 才能进入同一个房间进行通话或直播。
 * - 一个 App Key 只能用于创建一个 NERtc 实例；若您需要更换 App Key，必须先调用 {@link NERtcEngine#destroyEngine} 方法销毁当前实例，再调用本方法重新创建实例。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>context</td>
 *      <td>{@link NERtcEngineContext}</td>
 *      <td>传入的 RTC engine context 对象。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * NERtcEngineContext *context = [[NERtcEngineContext alloc] init];
 * context.appKey = appkey; //appkey
 * context.engineDelegate = delegate; //delegate处理对象        
 * NERtcLogSetting *logSetting = [[NERtcLogSetting alloc] init];
 * logSetting.logDir = logDir;//日志路径
 * logSetting.logLevel = kNERtcLogLevelWarning; //debug级别可选择kNERtcLogLevelInfo或者更高，有利于调试中的问题定位;release版本建议用warning级别
 * context.logSetting = logSetting;
 * [[NERtcEngine sharedEngine] setupEngineWithContext:context];
 * @endcode
 * @par 相关接口
 * 若您不再使用 NERtc 实例，需要调用 {@link NERtcEngine#destroyEngine} 方法进行销毁。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *          - 30003（kNERtcErrInvalidParam）：参数错误。
 *          - 30005（kNERtcErrInvalidState)：状态错误，比如正在重连。
 * @endif
 */
- (int)setupEngineWithContext:(NERtcEngineContext *)context;

/**
   * 设置SDK 主回调，调用此方法后会更新之前 setupEngineWithContext 及 setEngineEventDelegate 设置的回调。
   * 如果设置为空指针 ， 那么表示清空回调。
   * 注意： 需要在初始化之后调用 ， destroyEngine 之后自动失效。
 */
- (int)setEngineEventDelegate:(nullable id<NERtcEngineDelegateEx>)delegate;

/**
 *
 * @if Chinese
 * 设置驱动 NERtcEngineDelegateEx 事件回调队列
 * @since V5.5.10
 * @par 调用时机
 * 请在引擎初始化后调用此接口，且该方法在加入房间前后均可调用。
 * @note
 * - 如果您不指定自己的 delegateQueue 或者设置为 NULL, 默认会采用 MainQueue 作为驱动 NERtcCallback 事件回调的队列。
 * - 如果您指定了自己的 delegateQueue，请不要直接 NERtcEngineDelegateEx 回调函数中操作UI，会引发线程安全问题。且需要考虑线程的生命周期，如果线程提前终止，将无法收到 NERtcEngineDelegateEx 的回调。
 */
- (int)setDelegateQueue:(nullable dispatch_queue_t)delegateQueue;

/**
 * @if English 
 * Joins an RTC room.
 * <br>If the specified room does not exist when you join the room, a room with the specified name is automatically created in the server provided by CommsEase.
 * - After you join a room by calling the relevant method supported by the SDK, users in the same room can make audio or video calls. Users that join the same room can start a group chat. Apps that use different AppKeys cannot communicate with each other.
 * - If you join a room by calling this method, onNERtcEngineUserDidJoinWithUserID is triggered on a remote client.
 * - If you join a room, you subscribe to the audio streams from other users in the same room by default. In this case, the data usage is billed. To unsubscribe, you can call the mute method.
 * - In live streaming, the audience can switch rooms by calling switchChannelWithToken.
 * @param token The certification signature used in authentication (NERTC Token). Valid values:
                  - null. You can set the value to null in the debugging mode. This poses a security risk. We recommend that you contact your business manager to change to the default safe mode before your product is officially launched.
                  - NERTC Token acquired. In safe mode, the acquired token must be specified. If the specified token is invalid, users are unable to join a room. We recommend that you use the safe mode.
 * @param channelName The name of the room. Users that use the same name can join the same room. < br>The name must be of STRING type and must be 1 to 64 characters in length. The following 89 characters are supported: a-z, A-Z, 0-9, space, !#$%&()+-:;≤.,>? @[]^_{|}~”
 * @param uId The unique identifier of a user. The uId of each user in a room must unique.
            <br>uId is optional, The default value is 0. If the uId is not specified (set to 0), the SDK automatically assigns a random uId and returns the uId in NERtcJoinChannelCompletion. The application layer must keep and maintain the return value. The SDK does not maintain the return value.
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
 *      <td>安全认证签名（NERTC Token），可以设置为：<ul><li>null。调试模式下可设置为 null。安全性不高，建议在产品正式上线前在云信控制台中将鉴权方式恢复为默认的安全模式。<li>已获取的NERTC Token。安全模式下必须设置为获取到的 Token 。若未传入正确的 Token 将无法进入房间。推荐使用安全模式。</td>
 *  </tr>
 *  <tr>
 *      <td>channelName</td>
 *      <td>NSString</td>
 *      <td>房间名称，设置相同房间名称的用户会进入同一个通话房间。<ul><li>字符串格式，长度为 1 ~ 64 字节。<li>支持以下 89 个字符：a-z, A-Z, 0-9, space, !#$%&()+-:;≤.,>? @[]^_{|}~”</td>
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
 * int result = [[NERtcEngine sharedEngine] joinChannelWithToken:token channelName:channelName myUid:uid completion:^(NSError * _Nullable error, uint64_t channelId, uint64_t elapesd, uint64_t uid) {
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
 * - 您可以调用 {@link INERtcEngine#leaveChannel} 方法离开房间。
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
                channelName:(NSString *)channelName
                      myUid:(uint64_t)uId
                 completion:(NERtcJoinChannelCompletion)completion;

/**
 * @if English
 * Joins an RTC room.
 * <br>If the specified room does not exist when you join the room, a room with the specified name is automatically created in the server provided by CommsEase.
 * - After you join a room by calling the relevant method supported by the SDK, users in the same room can make audio or video calls. Users that join the same room can start a group chat. Apps that use different AppKeys cannot communicate with each other.
 * - If you join a room by calling this method, onNERtcEngineUserDidJoinWithUserID is triggered on a remote client.
 * - If you join a room, you subscribe to the audio streams from other users in the same room by default. In this case, the data usage is billed. To unsubscribe, you can call the mute method.
 * - In live streaming, the audience can switch rooms by calling switchChannelWithToken.
 * @param token The certification signature used in authentication (NERTC Token). Valid values:
                  - null. You can set the value to null in the debugging mode. This poses a security risk. We recommend that you contact your business manager to change to the default safe mode before your product is officially launched.
                  - NERTC Token acquired. In safe mode, the acquired token must be specified. If the specified token is invalid, users are unable to join a room. We recommend that you use the safe mode.
 * @param channelName The name of the room. Users that use the same name can join the same room. < br>The name must be of STRING type and must be 1 to 64 characters in length. The following 89 characters are supported: a-z, A-Z, 0-9, space, !#$%&()+-:;≤.,>? @[]^_{|}~”
 * @param uId The unique identifier of a user. The uId of each user in a room must unique.
            <br>uId is optional, The default value is 0. If the uId is not specified (set to 0), the SDK automatically assigns a random uId and returns the uId in NERtcJoinChannelCompletion. The application layer must keep and maintain the return value. The SDK does not maintain the return value.
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
 *      <td>安全认证签名（NERTC Token），可以设置为：<ul><li>null。调试模式下可设置为 null。安全性不高，建议在产品正式上线前在云信控制台中将鉴权方式恢复为默认的安全模式。<li>已获取的NERTC Token。安全模式下必须设置为获取到的 Token 。若未传入正确的 Token 将无法进入房间。推荐使用安全模式。</td>
 *  </tr>
 *  <tr>
 *      <td>channelName</td>
 *      <td>NSString</td>
 *      <td>房间名称，设置相同房间名称的用户会进入同一个通话房间。<ul><li>字符串格式，长度为 1 ~ 64 字节。<li>支持以下 89 个字符：a-z, A-Z, 0-9, space, !#$%&()+-:;≤.,>? @[]^_{|}~”</td>
 *  </tr>
 *  <tr>
 *      <td>uId</td>
 *      <td>uint64_t</td>
 *      <td>用户的唯一标识 ID。</td>
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
 * int result = [[NERtcEngine sharedEngine] joinChannelWithToken:token channelName:channelName myUid:uid completion:^(NSError * _Nullable error, uint64_t channelId, uint64_t elapesd, uint64_t uid) {
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
 * - 您可以调用 {@link INERtcEngine#leaveChannel} 方法离开房间。
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
                channelName:(NSString *)channelName
                      myUid:(uint64_t)uId
              channelOptions:(nullable NERtcJoinChannelOptions *)channelOptions
                 completion:(void(^)(NSError * _Nullable error, uint64_t channelId, uint64_t elapesd, uint64_t uid, NERtcJoinChannelExtraInfo * _Nullable info))completion;

/**
 * @if English 
 * Leaves a room, such as hanging up or ending a call.
 * <br>A user must call the leaveChannel method to end the call before the user makes another call.
 * <br>After you leave the room by calling the method, the onNERtcEngineDidLeaveChannelWithResult callback is triggered on the local client, and the onNERtcEngineUserDidLeaveWithUserID callback is triggered on a remote client.
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
 * [[NERtcEngine sharedEngine] leaveChannel];
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
 * Switches to a different RTC room.
 * <br>In live streaming, the audience can call this method to switch from the current room to another room.
 * <br>After you successfully switch to the destination room, the local client receives a message sent by onNERtcEngineDidLeaveChannelWithResult. The remote user receives messages sent by onNERtcEngineUserDidLeaveWithUserID and onNERtcEngineUserDidJoinWithUserID.
 * @note 
 * - By default, after a room member switches to another room, the room member subscribes to audio streams from other members of the new room. In this case, data usage is charged and billing is updated. If you want to unsubscribe from the previous audio stream, you can call the subscribeRemoteAudio method.
 * - The method applies to only live streaming. The role is the audience in the RTC room. The room scene is set to live streaming by calling the setchannelprofile method, and the role of room members is set to the audiences by calling the setClientRole method.
 * @param token The certification signature generated in the server and used for authentication. Valid values:
                  - null. You can set the value to null in the debugging mode. This poses a security risk. We recommend that you contact your business manager to change to the default safe mode before your product is officially launched.
                  - NERTC Token acquired. In safe mode, the acquired token must be specified. If the specified token is invalid, users are unable to join a channel. We recommend that you use the safe mode.
 * @param channelName The room name that a user wants to switch to.
 * @param completion The callback when the operation is complete.
 * @return The value returned. A value of 0 indicates that the operation is successful. A value that is less than 0 indicates that The operation fails.
 * @endif
 * @if Chinese
 * 快速切换音视频房间。
 * 通过此接口可以实现当房间场景为直播场景时，用户从当前房间快速切换至另一个房间。
 * @par 使用前提
 * 请先通过 {@link INERtcEngine#setChannelProfile:} 接口设置房间模式为直播模式。
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法仅可在加入房间后调用。
 * @note
 * - 房间成员成功切换房间后，将会保持切换前的音视频的状态。
 * - v5.5.10 及之后版本，主播和观众都支持调用本接口快速切换至另一个房间。
 * - v5.5.10 之前版本，只支持观众调用本接口快速切换至另一个房间。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>token</td>
 *      <td>NSString *</td>
 *      <td>在服务器端生成的用于鉴权的安全认证签名（Token），可设置为：<ul><li>已获取的 NERTC Token。安全模式下必须设置为获取到的 Token，默认 Token 有效期为 10min，也可以定期通过应用服务器向云信服务器申请 Token 或者申请长期且可复用的 Token。<li>null。调试模式下可设置为 null。安全性不高，建议在产品正式上线前在云信控制台中将鉴权方式恢复为默认的安全模式。</td>
 *  </tr>
 *  <tr>
 *      <td>channelName</td>
 *      <td>NSString *</td>
 *      <td>期望切换到的目标房间名称。</td>
 *  </tr>
 *  <tr>
 *      <td>completion</td>
 *      <td>{@link NERtcJoinChannelCompletion}</td>
 *      <td>操作完成的 block 回调。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * [self switchChannelWithToken:token channelName:channelName channelOptions:channelOption completion:^(NSError * _Nullable error, uint64_t channelId, uint64_t elapesd, uint64_t uid, NERtcJoinChannelExtraInfo * _Nullable info) {
 * }];
 * @endcode
 * @par 相关回调
 * 成功调用此接口切换房间后：
 *      - 本端用户会先收到 {@link NERtcEngineDelegate#onNERtcEngineDidLeaveChannelWithResult:} 回调，其中 result 参数为 {@link NERtcEngineErrorCode.NERtcError#kNERtcErrChannelLeaveBySwitchAction}；再收到成功加入新房间的回调 {@link NERtcJoinChannelCompletion}。
 *      - 远端用户会收到 {@link NERtcEngineDelegate#onNERtcEngineUserDidLeaveWithUserID:reason:leaveExtraInfo:} 和 {@link NERtcEngineDelegate#onNERtcEngineUserDidJoinWithUserID:userName:joinExtraInfo:} 的回调。
 * @return
 * - 0（kNERtcNoError）： 方法调用成功。
 * - 其他：方法调用失败。
 *          - 403（kNERtcErrChannelReservePermissionDenied）：没有权限，比如主播无法切换房间。
 *          - 30004（kNERtcErrNotSupported）：不支持的操作，比如当前是 1 对 1 模式。
 *          - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎尚未初始化。
 *          - 30100（kNERtcErrChannelAlreadyJoined）：重复加入房间。
 *          - 30103（kNERtcErrRequestJoinChannelFail）：加入房间操作失败。
 *          - 30109（kNERtcErrSwitchChannelInvalidState）：尚未加入房间。
 * @endif
 */
- (int)switchChannelWithToken:(NSString *)token channelName:(NSString *)channelName completion:(NERtcJoinChannelCompletion)completion;

/**
 * @if English 
 * Switches to a different RTC room.
 * <br>In live streaming, the audience can call this method to switch from the current room to another room.
 * <br>After you successfully switch to the destination room, the local client receives a message sent by onNERtcEngineDidLeaveChannelWithResult. The remote user receives messages sent by onNERtcEngineUserDidLeaveWithUserID and onNERtcEngineUserDidJoinWithUserID.
 * @note 
 * - By default, after a room member switches to another room, the room member subscribes to audio streams from other members of the new room. In this case, data usage is charged and billing is updated. If you want to unsubscribe from the previous audio stream, you can call the subscribeRemoteAudio method.
 * - The method applies to only live streaming. The role is the audience in the RTC room. The room scene is set to live streaming by calling the setchannelprofile method, and the role of room members is set to the audiences by calling the setClientRole method.
 * @param token The certification signature generated in the server and used for authentication. Valid values:
                  - null. You can set the value to null in the debugging mode. This poses a security risk. We recommend that you contact your business manager to change to the default safe mode before your product is officially launched.
                  - NERTC Token acquired. In safe mode, the acquired token must be specified. If the specified token is invalid, users are unable to join a channel. We recommend that you use the safe mode.
 * @param channelName The room name that a user wants to switch to.
 * @param completion The callback when the operation is complete.
 * @return The value returned. A value of 0 indicates that the operation is successful. A value that is less than 0 indicates that The operation fails.
 * @endif
 * @if Chinese
 * 快速切换音视频房间。
 * <br>房间场景为直播场景时，房间中角色为观众的成员可以调用该方法从当前房间快速切换至另一个房间。
 * <br>成功调用该方切换房间后，本端会收到离开房间的回调 onNERtcEngineDidLeaveChannelWithResult；远端用户会收到 onNERtcEngineUserDidLeaveWithUserID 和 onNERtcEngineUserDidJoinWithUserID 的回调。 
 * @note 
 * - 房间成员成功切换房间后，默认订阅房间内所有其他成员的音频流，因此产生用量并影响计费。如果想取消订阅，可以通过调用相应的 subscribeRemoteAudio 方法实现。
 * - 该方法仅适用于直播场景中，角色为观众的音视频房间成员。即已通过接口 setchannelprofile 设置房间场景为直播，通过 setClientRole 设置房间成员的角色为观众。
 * @param token 在服务器端生成的用于鉴权的安全认证签名（Token）。可设置为：
 *                  - null。调试模式下可设置为 null。安全性不高，建议在产品正式上线前在云信控制台中将鉴权方式恢复为默认的安全模式。
 *                  - 已获取的NERTC Token。安全模式下必须设置为获取到的 Token 。若未传入正确的 Token 将无法进入房间。推荐使用安全模式。
 * @param channelName 期望切换到的目标房间名称
 * @param channelOptions 加入房间时设置一些特定的房间参数
 * @param completion 操作完成的 block 回调
 * @return 
 * - 0({@link NERtcEngineErrorCode.kNERtcNoError})：方法调用成功。
 * - 30001({@link NERtcEngineErrorCode.kNERtcErrFatal})：通用错误。
 * - 30003({@link NERtcEngineErrorCode.kNERtcErrInvalidParam})：参数错误。
 * - 30109({@link NERtcEngineErrorCode.kNERtcErrSwitchChannelInvalidState}): 切换房间状态无效。
 * - 403({@link NERtcEngineErrorCode.KNERtcErrChannelReservePermissionDenied}): 用户角色不是观众。
 * - 30100({@link NERtcEngineErrorCode.kNERtcErrChannelAlreadyJoined}): 房间名无效，已在此房间中。
 * @endif
 */
- (int)switchChannelWithToken:(NSString *)token channelName:(NSString *)channelName channelOptions:(nullable NERtcJoinChannelOptions *)channelOptions completion:(void(^)(NSError * _Nullable error, uint64_t channelId, uint64_t elapesd, uint64_t uid, NERtcJoinChannelExtraInfo * _Nullable info))completion;

/**
 * @if English 
 * Enables or disables local audio capture.
 * <br>When an app joins a room, the voice module is enabled by default.
 * <br>The method does not affect receiving or playing back the remote audio stream. The enableLocalAudio(NO) method is suitable for scenarios where a user wants to receive the remote audio stream without sending audio streams to other users in the room.
 * @note
 * - The enableLocalAudio method is different from muteLocalAudioStream. The enableLocalAudio method is used to enable local audio capture and processing whereas the muteLocalAudioStream method is used to stop or restart pushing the local audio stream.
 * - The method enables the internal engine. The setting remains unchanged after the leaveChannel method is called.
 * - Starting from V4.4.0, turning on or off local audio capture does not affect the playback of music files. You can still play music files by calling startAudioMixingWithOption after you set enableLocalAudio(NO).
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
 * [[NERtcEngine sharedEngine] enableLocalAudio:YES];
 * //关闭音频采集
 * [[NERtcEngine sharedEngine] enableLocalAudio:NO];
 * @endcode
 * @par 相关回调
 * - 开启音频采集后，远端会触发 {@link NERtcEngineDelegate#onNERtcEngineUserAudioDidStart:} 回调。
 * - 关闭音频采集后，远端会触发 {@link NERtcEngineDelegate#onNERtcEngineUserAudioDidStop:} 回调。
 * @par 相关接口
 * {@link INERtcEngineEx#muteLocalAudio:}：两者的差异在于，enableLocalAudio 用于开启本地语音采集及处理，而 muteLocalAudio 用于停止或继续发送本地音频流。
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
 * [[NERtcEngine sharedEngine] enableLocalVideo:YES];
 * //关闭视频
 * [[NERtcEngine sharedEngine] enableLocalVideo:NO];
 * @endcode 
 * @par 相关回调
 * - 开启本地视频采集后，远端会收到 {@link NERtcEngineDelegate#onNERtcEngineUserAudioDidStart:} 回调。
 * - 关闭本地视频采集后，远端会收到 {@link NERtcEngineDelegate#onNERtcEngineUserAudioDidStop:} 回调。
 * @par 相关接口
 * 若您希望开启辅流通道的视频采集，请调用 {@link INERtcEngine#enableLocalVideo:streamType:} 方法。
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
 * [[NERtcEngine sharedEngine] enableLocalVideo:YES streamType:kNERtcStreamChannelTypeMainStream];
 * //关闭视频主流
 * [[NERtcEngine sharedEngine] enableLocalVideo:NO streamType:kNERtcStreamChannelTypeMainStream];
 * //打开视频辅流
 * [[NERtcEngine sharedEngine] enableLocalVideo:YES streamType:kNERtcStreamChannelTypeSubStream];
 * //关闭视频辅流
 * [[NERtcEngine sharedEngine] enableLocalVideo:NO streamType:kNERtcStreamChannelTypeSubStream];
 * @endcode 
 * @par 相关回调
 * - streamType 为 kNERtcStreamChannelTypeMainStream（主流）时：
 *          - 开启本地视频采集后，远端会收到 {@link NERtcEngineDelegate#onNERtcEngineUserAudioDidStart:} 回调。
 *          - 关闭本地视频采集后，远端会收到 {@link NERtcEngineDelegate#onNERtcEngineUserAudioDidStop:} 回调。
 * - streamType 为 kNERtcStreamChannelTypeSubStream（辅流）时： 
 *          - 开启本地视频采集后，远端会收到 {@link NERtcEngineDelegate#onNERtcEngineUserSubStreamAudioDidStart:} 回调。
 *          - 关闭本地视频采集后，远端会收到 {@link NERtcEngineDelegate#onNERtcEngineUserSubStreamAudioDidStop:} 回调。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *          - 30001（kNERtcErrFatal）：通用错误，一般表示引擎错误，尝试再次调用此接口即可。
 *          - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如已开启外部视频采集。
 *          - 30027（kNERtcErrDeviceOccupied）: 所选设备已被占用。比如已通过主流通道开启了摄像头，无法再通过辅流通道开启摄像头。
 *          - 30300（kNERtcErrOSAuthorize）：应用未获取到操作系统的摄像头权限。
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
 * - {@link INERtcEngineEx#muteLocalAudio:}：
 *          - 在需要开启本地音频采集（监测本地用户音量）但不发送音频流的情况下，您也可以调用 muteLocalAudio(YES) 方法。
 *          - 两者的差异在于， muteLocalAudio(YES) 仍然保持与服务器的音频通道连接，而 enableMediaPub(NO) 表示断开此通道，因此若您的实际业务场景为多人并发的大房间，建议您调用 enableMediaPub 方法。  
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
 * Sets a room scene.
 * <br>You can set a room scene for a call or live event. Different QoS policies are applied to different scenes.
 * @note You must call the method before you join a room. If you have joined a room, you cannot set the room scene.
 * @param channelProfile The room scene. For more information, see {@link NERtcEngineEnum.NERtcChannelProfileType}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置房间场景。
 * <br>
 * 通过此接口可以实现设置房间场景为通话（默认）或直播场景。针对不同场景采取的优化策略不同，如通话场景侧重语音流畅度，直播场景侧重视频清晰度。
 * @since V3.6.0
 * @par 调用时机
 * 请在初始化后调用该方法，且该方法仅可在加入房间前调用。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>channelProfile</td>
 *      <td>int</td>
 *      <td>设置房间场景：<ul><li>kNERtcChannelProfileCommunication：通话场景。<li>kNERtcChannelProfileLiveBroadcasting：直播场景。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //设置房间场景为直播场景
 * [[NERtcEngine sharedEngine] setChannelProfile:kNERtcChannelProfileLiveBroadcasting];
 * @endcode
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *      - 30003（kNERtcErrInvalidParam）：参数错误。
 *      - 30005（kNERtcErrInvalidState)：当前状态不支持的操作，比如已经加入房间。
 * @endif
 */
- (int)setChannelProfile:(NERtcChannelProfileType)channelProfile;


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
 * NERtcEngine *coreEngine = [NERtcEngine sharedEngine];
 * NERtcVideoEncodeConfiguration *config = [[NERtcVideoEncodeConfiguration alloc] init];
 * config.width = 640;// 设置分辨率宽
 * config.height = 360;// 设置分辨率高
 * config.cropMode = kNERtcVideoCropMode16_9;      // 设置裁剪格式为16:9
 * config.frameRate = kNERtcVideoFrameRateFps30; //视频帧率
 * config.minFrameRate = mMinFrameRate; //视频最小帧率
 * config.bitrate = mBitrate; //视频编码码率
 * config.minBitrate = mMinBitrate; //视频编码最小码率
 * config.degradationPreference = kNERtcDegradationDefault; ;//带宽受限时的视频编码降级偏好
 * [coreEngine setLocalVideoConfig:config];
 * @endcode 
 * @par 相关接口
 * 若您希望为视频辅流通道设置编码属性，请调用 {@link INERtcEngine#setLocalVideoConfig:streamType:} 方法。
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
 * NERtcEngine *coreEngine = [NERtcEngine sharedEngine];
 * NERtcVideoEncodeConfiguration *config = [[NERtcVideoEncodeConfiguration alloc] init];
 * config.width = 640;// 设置分辨率宽
 * config.height = 360;// 设置分辨率高
 * config.cropMode = kNERtcVideoCropMode16_9;      // 设置裁剪格式为16:9
 * config.frameRate = kNERtcVideoFrameRateFps30; //视频帧率
 * config.minFrameRate = mMinFrameRate; //视频最小帧率
 * config.bitrate = mBitrate; //视频编码码率
 * config.minBitrate = mMinBitrate; //视频编码最小码率
 * config.degradationPreference = kNERtcDegradationDefault; ;//带宽受限时的视频编码降级偏好
 * [coreEngine setLocalVideoConfig:config streamType:kNERtcStreamChannelTypeMainStream];
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
 * [coreEngine setLocalVideoConfig:config streamType:kNERtcStreamChannelTypeSubStream];
 * @endcode 
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *          - 30003（kNERtcErrInvalidParam）：参数错误，比如 config 设置为空。
 *          - 30004（kNERtcErrNotSupported）：不支持的操作，比如当前使用的是纯音频 SDK。
 *          - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎未初始化成功。
 * @endif
 */
- (int)setLocalVideoConfig:(NERtcVideoEncodeConfiguration *)config streamType:(NERtcStreamChannelType)streamType;

/**
 * @if English 
 * Sets the audio encoding profile.
 * @note You must call this method before you call the joinChannel method. Otherwise, the settings of joinChannel do not take effect.
 * @param profile The sample rate, bitrate, encoding mode, and the number of channels. For more information, see {@link NERtcAudioProfileType}.
 * @param scenario The type of an audio scenario. For more information, see {@link NERtcAudioScenarioType}.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置音频编码属性。
 * <br>通过此接口可以实现设置音频编码的采样率、码率、编码模式、声道数等，也可以设置音频属性的应用场景，包括聊天室场景、语音场景、音乐场景等。
 * @since V3.5.0
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法在加入房间前后均可调用。
 * @note
 * - 音乐场景下，建议将 profile 设置为 kNERtcAudioProfileHighQuality。
 * - 若您通过 {@link INERtcEngine#setChannelProfile:} 接口设置房间场景为直播模式，即 kNERtcChannelProfileLiveBroadcasting，但未调用此方法设置音频编码属性，或仅设置 profile 为 kNERtcAudioProfileDefault，则 SDK 会自动设置 profile 为 kNERtcAudioProfileHighQuality，且设置 scenario 为 kNERtcAudioScenarioMusic。
 * @par 参数说明 
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>profile</td>
 *      <td>{@link NERtcAudioProfileType}</td>
 *      <td>设置采样率、码率、编码模式和声道数。</td>
 *  </tr>
 *  <tr>
 *      <td>scenario</td>
 *      <td>{@link NERtcAudioScenarioType}</td>
 *      <td>设置音频应用场景。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * //设置profile为标准模式，scenario为语音场景
 * NERtcAudioScenarioType scenario = kNERtcAudioScenarioSpeech;
 * NERtcAudioProfileType profile = kNERtcAudioProfileStandard;
 * [[NERtcEngine sharedEngine] setAudioProfile:profile scenario:scenario];
 * @endcode
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *         - 30001（kNERtcErrFatal）：引擎尚未初始化或下发配置未更新。
 * @endif
 */
- (int)setAudioProfile:(NERtcAudioProfileType)profile scenario:(NERtcAudioScenarioType)scenario;

/**
 * @if English 
 * Sets the local view.
 * <br>This method is used to set the display information about the local video. The method is applicable only to local users. Remote users are not affected. Apps can call this API operation to associate with the view that plays local video streams. During application development, in most cases, before joining a room, you must first call this method to set the local video view after the SDK is initialized.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
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
 * [[NERtcEngine sharedEngine] setupLocalVideoCanvas:canvas];
 * @endcode
 * @par 相关接口
 * 若您希望在通话中更新本地用户视图的渲染或镜像模式，请调用 {@link INERtcEngineEx#setLocalRenderScaleMode:} 方法。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *         - 30001（kNERtcErrFatal）：引擎尚未初始化。
 *         - 30004（kNERtcErrNotSupported）：不支持的操作，比如纯音频 SDK 不支持该功能。
 *         - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引起尚未成功启动。
 * @endif
 */
- (int)setupLocalVideoCanvas:(NERtcVideoCanvas * _Nullable)canvas;

/**
 * @if English 
 * Sets views for remote users.
 * <br>This method is used to associate remote users with display views and configure the rendering mode and mirror mode for remote views displayed locally. The method affects only the video screen viewed by local users.
 * @note 
 * - The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * - If the user ID is not retrieved, you can set the user ID after the app receives a message delivered when the onNERtcEngineUserDidJoinWithUserID event is triggered.
 * - To disassociate a specified user from a view, you can leave the canvas parameter empty.
 * - After a user leaves the room, the association between a remote user and the view is cleared.
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
 *     [[NERtcEngine sharedEngine] setupRemoteVideoCanvas:canvas forUserID:userID];
 * }
 * @endcode
 * @par 相关接口
 * 若您希望在通话中更新远端用户视图的渲染模式，请调用 {@link INERtcEngineEx#setRemoteRenderScaleMode:forUserID:}方法。
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *         - 30001（kNERtcErrFatal）：引擎尚未初始化。
 *         - 30004（kNERtcErrNotSupported）：纯音频 SDK 不支持该功能。
 *         - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎尚未成功启动。
 * @endif
 */
- (int)setupRemoteVideoCanvas:(NERtcVideoCanvas * _Nullable)canvas forUserID:(uint64_t)userID;

/**
 * @if English 
 * Switches between the front and rear cameras.
 * <br>Make sure that you call this method after the camera starts. For example, you can call this method after you call startPreview or joinChannel.
 * @note The audio-only SDK disables this API. If you need to use the API, you can download the standard SDK from the official website of CommsEase and replace the audio-only SDK.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 切换前置或后置摄像头。
 * @since V3.5.0
 * @par 使用前提
 * 请在调用 {@link INERtcEngineEx#startPreview:} 或 {@link INERtcEngine#joinChannelWithToken:channelName:myUid:channelOptions:completion:} 方法且开启摄像头之后调用此接口。
 * @par 调用时机
 * 请在引擎初始化之后调用此接口，且该方法在加入房间前后均可调用。
 * @note
 * - 纯音频 SDK 禁用该接口，如需使用请前往云信官网下载并替换成视频 SDK。
 * - 该方法需要在相机启动后才可调用。
 * @par 示例代码
 * @code
 * [[NERtcEngine sharedEngine] switchCamera];
 * @endcode
 * @return
 *  - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *          - 30004（kNERtcErrNotSupported）：不支持的操作，比如纯音频 SDK 不支持该功能。
 *          - 30005（kNERtcErrInvalidState）：当前状态不支持的操作，比如引擎尚未初始化或者未开启摄像头。
 * @endif
 */
 - (int)switchCamera;

/**
 * @if English 
 * Sets the role of a user in live streaming.
 * <br>The method sets the role to host or audience. The permissions of a host and an audience are different.
 * - A host has the permissions to open or close a camera, publish streams, call methods related to publishing streams in *Interactive live streaming. The status of the host is visible to the users in the room when the host joins or leaves the room.
 * - The audience has no permissions to open or close a camera, call methods related to publishing streams in interactive live streaming, and is invisible to other users in the room when the user that has the audience role joins or leaves the room.
 * @note <br>
 * - By default, a user joins a room as a host. Before a user joins a room, the user can call this method to change the client role to the audiences. After a user joins a room, the user can call this method to switch the client role.
 * - If the user switches the role to the audiences, the SDK automatically closes the audio and video devices.
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
 * [[NERtcEngine sharedEngine] setClientRole:kNERtcClientRoleAudience];
 * //切换用户角色为观众
 * [[NERtcEngine sharedEngine] setClientRole:kNERtcClientRoleBroadcaster];
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
 * Sets parameters for audio and video calls.
 * @note<br>
 * - You can call the method only after you join a room. When you use kNERtcKeyVideoPreferHWEncode and kNERtcKeyVideoPreferHWDecode, you must call this method before you initialize the SDK.
 * - This method provides a technology preview or personalized features. If you want to use this API, contact technical support.
 * @param parameters The parameters that you want to specify. For more information about the key parameters, see the definition in NERtcEngineBase.h.
 * @return The value returned. A value of 0 indicates that the operation is successful.
 * @endif
 * @if Chinese
 * 设置音视频通话的相关参数。
 * <br>
 * 此接口提供技术预览或特别定制功能，详情请咨询技术支持。
 * @since V3.5.0
 * @par 调用时机  
 * 请在初始化后调用该方法，且该方法在加入房间前后均可调用。
 * @par 参数说明
 * <table>
 *  <tr>
 *      <th>**参数名称**</th>
 *      <th>**类型**</th>
 *      <th>**描述**</th>
 *  </tr>
 *  <tr>
 *      <td>parameters</td>
 *      <td>NSDictionary</td>
 *      <td>音视频通话的参数集合。详细信息请参考 NERtcEngineBase.h 中的定义。</td>
 *  </tr>
 * </table>
 * @par 示例代码
 * @code
 * NSDictionary *paramDic = @{kNERtcKeyVideoPreferHWEncode : @(YES)};
 * ...
 * [[NERtcEngine sharedEngine] setParameters:paramDic];
 * @endcode
 * @return
 * - 0（kNERtcNoError）：方法调用成功。
 * - 其他：方法调用失败。
 *         - 30001（kNERtcErrInvalidParam）：参数错误。
 * @endif
 */

- (int)setParameters:(NSDictionary *)parameters;

/**
  以String 的形式获取一些内部参数，此接口为隐藏接口，需要特定参数及特定时机，详情联系技术支持。
 
  @param parameterKey 参数key
  @param extraInfo    额外的信息
  @return 如果查询到相关参数，以String 形式返回，否则返回nil
 */
- (NSString * _Nullable)getParameter:(NSString * _Nonnull)parameterKey extraInfo:(NSString * _Nullable)extraInfo;

@end


NS_ASSUME_NONNULL_END

#pragma clang diagnostic pop

#endif /* INERtcEngine_h */
