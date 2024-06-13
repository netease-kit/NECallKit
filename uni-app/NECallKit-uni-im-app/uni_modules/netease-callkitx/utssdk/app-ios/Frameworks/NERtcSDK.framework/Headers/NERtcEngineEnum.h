/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 */

#import <Foundation/Foundation.h>

#if __has_attribute(visibility)
#define NERTC_EXPORT __attribute__((visibility("default")))
#endif

#ifndef NERTC_EXPORT
#define NERTC_EXPORT
#endif

#if defined(__cplusplus)
#define NERTC_EXTERN_API extern "C" __attribute__((visibility("default")))
#else
#define NERTC_EXTERN_API extern __attribute__((visibility("default")))
#endif

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
typedef UIView VIEW_CLASS;
typedef UIColor COLOR_CLASS;
#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
typedef NSView VIEW_CLASS;
typedef NSColor COLOR_CLASS;
#endif


NS_ASSUME_NONNULL_BEGIN

#pragma mark -- ENGINE ENUM


/**
 * @if English
 * The connection status of the current channel.
 * @endif
 * @if Chinese
 * 当前房间的连接状态。
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcConnectionStateType) {
    /**
     * @if English
     * The engine is not initialized.
     * @endif
     * @if Chinese
     * 引擎尚未初始化。
     * <br>该状态表示 SDK 处于：
     * - 调用 {@link INERtcEngine#setupEngineWithContext:} 接口初始化之前。
     * - 调用 {@link NERtcEngine#destroyEngine} 接口之后。
     * @endif
     */
    kNERtcConnectionStateUnknown = 0,
    /**
     * @if English
     * No user joins the room.
     * @endif
     * @if Chinese
     * 尚未加入房间。
     * <br>该状态表示当前处于：
     * - 调用 {@link INERtcEngine#setupEngineWithContext:} 接口之后、调用 {@link INERtcEngine#joinChannelWithToken:channelName:myUid:completion:} 接口之前的阶段。
     * - 调用 {@link INERtcEngine#leaveChannel} 后离开房间的阶段。
     * @endif
     */
    kNERtcConnectionStateDisconnected = 1,
    /**
     * @if English
     * A user is joining the room.
     * @endif
     * @if Chinese
     * 正在加入房间。
     * <br>该状态表示 SDK 处于调用 {@link INERtcEngine#joinChannelWithToken:channelName:myUid:completion:} 接口之后，正在建立房间连接的阶段。如果加入房间成功 App 会收到 {@link NERtcEngineDelegate#onNERtcEngineConnectionStateChangeWithState:reason:} 回调，当前状态变为 kNERtcConnectionStateConnected。
     * @endif
     */
    kNERtcConnectionStateConnecting = 2,
    /**
     * @if English
     * A user successfully joined the room.
     * @endif
     * @if Chinese
     * 加入房间成功。
     * <br>该状态表示用户已经加入房间，如果因网络断开或切换而导致 SDK 与房间的连接中断，SDK 会自动重连，此时 App 会收到 {@link NERtcEngineDelegate#onNERtcEngineConnectionStateChangeWithState:reason:} 回调 ，当前状态变为 kNERtcConnectionStateReconnecting。
     * @endif
     */
    kNERtcConnectionStateConnected = 3,
    /**
     * @if English
     * A user is rejoining the room.
     * @endif
     * @if Chinese
     * 正在尝试重新加入房间。
     * <br>该状态表示 SDK 之前曾加入过房间，但因为网络原因中断了，此时 SDK 会自动尝试重新加入房间。如果重连还是没能加入房间会触发 {@link NERtcEngineDelegate#onNERtcEngineConnectionStateChangeWithState:reason:} 回调， 当前状态变为 kNERtcConnectionStateFailed，SDK 停止尝试重连。
     * @endif
     */
    kNERtcConnectionStateReconnecting = 4,
    /**
     * @if English
     * A user fails to join the room.
     * @endif
     * @if Chinese
     * 加入房间失败。
     * <br>该状态表示 SDK 已经不再尝试重新加入房间。如果用户还想重新加入房间，则需要再次调用 {@link INERtcEngine#joinChannelWithToken:channelName:myUid:completion:}。
     * @endif
     */
    kNERtcConnectionStateFailed = 5,
};


/**
 * @if English
 * The reasons why the user leaves the room.
 * @endif
 * @if Chinese
 * 用户离开房间的原因。
 * @endif
 */
typedef NS_ENUM(NSInteger, NERtcSessionLeaveReason) {
    /**
     * @if English
     * The user leaves the room normally.
     * @endif
     * @if Chinese
     * 正常离开。
     * @endif
     */
    kNERtcSessionLeaveNormal = 0,
    /**
     * @if English
     * The user leaves the room due to network failure.
     * @endif
     * @if Chinese
     * 用户断线导致离开房间。
     * @endif
     */
    kNERtcSessionLeaveForFailOver = 1,
    /**
     * @if English
     * The user leaves the room due to Failover. It is only used internally by the SDK.
     * @endif
     * @if Chinese
     * 用户因 Failover 导致离开房间，仅 SDK 内部使用。
     * @endif
     */
    kNERTCSessionLeaveForUpdate = 2,
    /**
     * @if English
     * The user is removed from the room.
     * @endif
     * @if Chinese
     * 用户被踢导致离开房间。
     * @endif
     */
    kNERtcSessionLeaveForKick = 3,
    /**
     * @if English
     * The user leaves the room due to connections timeout.
     * @endif
     * @if Chinese
     * 用户超时退出房间。
     * @endif
     */
    kNERtcSessionLeaveTimeout = 4,
};

/**
 * @if English
 * join3 type.
 * @endif
 * @if Chinese
 * join3 类型。
 * @endif
 */
typedef NS_ENUM(NSInteger, NERtcJoin3Type) {
    /**
     * @if English
     * join with publish video and subscribe video.
     * @endif
     * @if Chinese
     * join信令包含发布视频和订阅视频。
     * @endif
     */
    kNERtcJoin3WithPubVideo = 4,
    /**
     * @if English
     * join without publish video.
     * @endif
     * @if Chinese
     * join信令中不带发布视频信息
     * @endif
     */
    kNERtcJoin3NoPubVideo = 5,
};

/**
 * @if English
 * User role.
 * @endif
 * @if Chinese
 * 用户角色。
 * @endif
 */
typedef NS_ENUM(NSInteger, NERtcClientRole) {
    /**
     * @if English
     * The role of host in live streaming mode. The host has the permissions to open or close audio and video devices such as a camera, publish streams, and configure streaming tasks in interactive live streaming. The status of the host is visible to the users in the room when the host joins or leaves the room.
     * @endif
     * @if Chinese
     * （默认）直播模式中的主播，可以操作摄像头等音视频设备、发布流、配置互动直播推流任务、上下线对房间内其他用户可见。
     * @endif
     */
    kNERtcClientRoleBroadcaster = 0,
    /**
     * @if English
     * The role of audience in live streaming mode. The audiences can only receive audio and video streams, and cannot operate audio and video devices or configure streaming tasks in interactive live streaming. Other members are not notified when the audience joins or leaves the room. The status of an audience is invisible to the users in the room when the audience joins or leaves the room.
     * @endif
     * @if Chinese
     * 直播模式中的观众，观众只能接收音视频流，不支持操作音视频设备、配置互动直播推流任务、上下线不通知其他用户。
     * @endif
     */
    kNERtcClientRoleAudience = 1,
};

/**
 * @if English
 * Media pub type.
 * @endif
 * @if Chinese
 * 媒体 pub 类型。
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcMediaPubType) {
    /**
     * @if English
     * Audio pub type.
     * @endif
     * @if Chinese
     * 音频 pub 类型。
     * @endif
     */
    kNERtcMediaPubTypeAudio,
};

/**
 * @if English
 * The reason why the connection status of the engine connection changes.
 * @endif
 * @if Chinese
 * 当前engine连接状态变更的原因。
 * @endif
 */
typedef NS_ENUM(NSInteger, NERtcReasonConnectionChangedType) {
    /**
     * @if English
     * A user leaves the room.
     * @endif
     * @if Chinese
     * 离开房间。
     * @endif
     */
    kNERtcReasonConnectionChangedLeaveChannel = 1,
    /**
     * @if English
     * The room is closed.
     * @endif
     * @if Chinese
     * 房间被关闭。
     * @endif
     */
    kNERtcReasonConnectionChangedChannelClosed = 2,
    /**
     * @if English
     * The user is removed from the room.
     * @endif
     * @if Chinese
     * 用户被踢出。
     * @endif
     */
    kNERtcReasonConnectionChangedBeKicked = 3,
    /**
     * @if English
     * The connection times out.
     * @endif
     * @if Chinese
     * 连接超时。
     * @endif
     */
    kNERtcReasonConnectionChangedTimeOut = 4,
    /**
     * @if English
     * A user joins the room.
     * @endif
     * @if Chinese
     * 加入房间。
     * @endif
     */
    kNERtcReasonConnectionChangedJoinChannel = 5,
    /**
     * @if English
     * A user successfully joins the room.
     * @endif
     * @if Chinese
     * 加入房间成功。
     * @endif
     */
    kNERtcReasonConnectionChangedJoinSucceed = 6,
    /**
     * @if English
     * A user successfully rejoins the room.
     * @endif
     * @if Chinese
     * 重新加入房间成功。
     * @endif
     */
    kNERtcReasonConnectionChangedReJoinSucceed = 7,
    /**
     * @if English
     * Media stream disconnected.
     * @endif
     * @if Chinese
     * 媒体连接断开。
     * @endif
     */
    kNERtcReasonConnectionChangedMediaConnectionDisconnected = 8,
    /**
     * @if English
     * Signaling connection fails.
     * @endif
     * @if Chinese
     * 信令连接失败。
     * @endif
     */
    kNERtcReasonConnectionChangedSignalDisconnected = 9,
    /**
     * @if English
     * Fails to request a room.
     * @endif
     * @if Chinese
     * 请求房间失败。
     * @endif
     */
    kNERtcReasonConnectionChangedRequestChannelFailed = 10,
    /**
     * @if English
     * A user fails to join the room.
     * @endif
     * @if Chinese
     * 加入房间失败。
     * @endif
     */
    kNERtcReasonConnectionChangedJoinChannelFailed = 11,
    /**
     * @if English
     * The server IP is reassigned.
     * @endif
     * @if Chinese
     * 重新分配了服务端IP。
     * @endif
     */
    kNERtcReasonConnectionChangedReDispatch = 12,
    /**
     * @if English
     * Start connecting to server using the cloud proxy.
     * @endif
     * @if Chinese
     * 开始使用云代理进行连接。
     * @endif
     */
    kNERtcReasonConnectionChangedSettingProxyServer = 13,
    /**
     * @if English
     * The user is removed from the room due to same userId.
     * @endif
     * @if Chinese
     * 用户被踢因为使用相同uid登录同一房间。
     * @endif
     */
    kNERtcReasonConnectionChangedBeKickedDueToSameUserId = 14
};

/**
 * @if English
 * The feature type.
 * @endif
 * @if Chinese
 * 功能类型
 * @endif
 */
typedef NS_ENUM(NSInteger, NERtcFeatureType) {
  /**
   * @if English
   * virtual background.
   * @endif
   * @if Chinese
   * 虚拟背景
   * @endif
   */
  kNERtcFeatureTypeVirtualBackground = 0,
};

#pragma mark -- VIDEO ENUM


/**
 * @if English
 * Video profile type.
 * @endif
 * @if Chinese
 * 视频 profile 类型。
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcVideoProfileType) {
    /**
     * @if English
     * LD (160 × 120/90 @ 15fps)
     * @endif
     * @if Chinese
     * LD (160 × 120/90 @ 15fps)
     * @endif
     */
    kNERtcVideoProfileLowest = 0,          // 160x90/120
    /**
     * @if English
     * LD (320 x 180/240 @ 15 fps)
     * @endif
     * @if Chinese
     * LD (320 x 180/240 @ 15 fps)
     * @endif
     */
    kNERtcVideoProfileLow = 1,          // 320x180/240
    /**
     * @if English
     * SD (640 x 360/480 @3 0 fps)
     * @endif
     * @if Chinese
     * SD (640 x 360/480 @3 0 fps)
     * @endif
     */
    kNERtcVideoProfileStandard = 2,     // 640x360/480
    /**
     * @if English
     * HD (1280 x 720 @ 30 fps)
     * @endif
     * @if Chinese
     * HD (1280 x 720 @ 30 fps)
     * @endif
     */
    kNERtcVideoProfileHD720P = 3,       // 1280x720
    /**
     * @if English
     * 1080P (1920 x 1080 @30 fps)
     * @endif
     * @if Chinese
     * 1080P (1920 x 1080 @30 fps)
     * @endif
     */
    kNERtcVideoProfileHD1080P = 4,      // 1920x1080
    /**
     * @if English
     * LD (160 × 120/90 @ 15fps)
     * @endif
     * @if Chinese
     * LD (160 × 120/90 @ 15fps)
     * @endif
     */
    kNERtcVideoProfileMAX = kNERtcVideoProfileHD1080P,
};

/**
 * @if English
 * Video frame rate
 * - kNERtcVideoFrameRateFpsDefault: By default, the mainstream video frame rate is selected based on maxProfile, and substream video frame rate is set to kNERtcVideoFrameRateFps7.
 * @endif
 * @if Chinese
 * 视频帧率。
 * - kNERtcVideoFrameRateFpsDefault：主流默认根据设置的maxProfile选择 ， 辅流默认kNERtcVideoFrameRateFps7。
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcVideoFrameRate) {
    /**
     * @if English
     * 0 fps.
     * @endif
     * @if Chinese
     * 0 fps.
     * @endif
     */
    kNERtcVideoFrameRateFpsDefault = 0,
    /**
     * @if English
     * 7 fps.
     * @endif
     * @if Chinese
     * 7 fps.
     * @endif
     */
    kNERtcVideoFrameRateFps7  = 7,
    /**
     * @if English
     * 10 fps.
     * @endif
     * @if Chinese
     * 10 fps.
     * @endif
     */
    kNERtcVideoFrameRateFps10 = 10,
    /**
     * @if English
     * 15 fps.
     * @endif
     * @if Chinese
     * 15 fps.
     * @endif
     */
    kNERtcVideoFrameRateFps15 = 15,
    /**
     * @if English
     * 24 fps.
     * @endif
     * @if Chinese
     * 24 fps.
     * @endif
     */
    kNERtcVideoFrameRateFps24 = 24,
    /**
     * @if English
     * 30 fps.
     * @endif
     * @if Chinese
     * 30 fps.
     * @endif
     */
    kNERtcVideoFrameRateFps30 = 30,
    /**
     * @if English
     * 60 fps.
     * @endif
     * @if Chinese
     * 60 fps.
     * @endif
     */
    kNERtcVideoFrameRateFps60 = 60,
};

/**
 * @if English
 * Video encoding adaptation preference with limited bandwidth.
 * - kNERtcDegradationDefault:
 * <br>For communications (kNERtcChannelProfileCommunication), use Balanced.
 * <br>For live streaming (kNERtcChannelProfileLiveBroadcasting), use MaintainQuality
 * - kNERtcDegradationMaintainFramerate: Reduce the resolution to ensure the frame rate.
 * - kNERtcDegradationMaintainQuality: Reduce the frame rate to ensure the resolution.
 * - kNERtcDegradationBalanced: Adjust the frame rate and the resolution for balance.
 * @endif
 * @if Chinese
 * 带宽受限时视频编码适应性偏好
 * - kNERtcDegradationDefault:
 * <br>通信场景(kNERtcChannelProfileCommunication),使用Balanced。
 * <br>直播场景(kNERtcChannelProfileLiveBroadcasting),使用MaintainQuality。
 * - kNERtcDegradationMaintainFramerate: 降低视频分辨率以保证编码帧率。
 * - kNERtcDegradationMaintainQuality: 降低编码帧率以保证视频分辨率。
 * - kNERtcDegradationBalanced: 平衡调节。
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcDegradationPreference) {
    /**
     * @if English
     * By default, adjust the adaptation preference based on scenarios.
     * - In communication scenes, select DEGRADATION_BALANCED mode to maintain a balance between the frame rate and video quality.
     * - In live streaming scenes, select DEGRADATION_MAINTAIN_QUALITY mode and reduce the frame rate to ensure video quality.
     * @endif
     * @if Chinese
     * （默认）根据场景模式调整适应性偏好。
     * - 通信场景中，选择DEGRADATION_BALANCED模式，在编码帧率和视频质量之间保持平衡。
     * - 直播场景中，选择DEGRADATION_MAINTAIN_QUALITY模式，降低编码帧率以保证视频质量。
     * @endif
     */
    kNERtcDegradationDefault = 0,
    /**
     * @if English
     * Smooth stream comes first. Reduce video quality to ensure the frame rate. In an unstable network, reduce the video clarity to ensure smooth streams. At this time, the image quality is reduced and the images become blurred, but the video can be streamed smoothly.
     * @endif
     * @if Chinese
     * 流畅优先，降低视频质量以保证编码帧率。在弱网环境下，降低视频清晰度以保证视频流畅，此时画质降低，画面会变得模糊，但可以保持视频流畅。
     * @endif
     */
    kNERtcDegradationMaintainFramerate,
    /**
     * @if English
     * Clarity is prioritized. Reduce the frame rate to ensure video quality. In an unstable network, reduce the frame rate to ensure a clear view. A number of freezes occur at this time.
     * @endif
     * @if Chinese
     * 清晰优先，降低编码帧率以保证视频质量。在弱网环境下，降低视频帧率以保证视频清晰，此时可能会出现一定卡顿。
     * @endif
     */
    kNERtcDegradationMaintainQuality,
    /**
     * @if English
     * Maintain a balance between the frame rate and video quality.
     * @endif
     * @if Chinese
     * 在编码帧率和视频质量之间保持平衡。
     * @endif
     */
    kNERtcDegradationBalanced,
};

/**
 * @if English
 * Encoding strategy preference for screen sharing.
 * @endif
 * @if Chinese
 * 屏幕共享功能的编码策略倾向
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcSubStreamContentPrefer) {
    /**
     * @if English
     * (Default) The content type is animation.
     * - When the shared content is a video, movie, or game, we recommend that you select this content type.
     * - If a user sets the content type to animation, the user-defined frame rate is applied.
     * @endif
     * @if Chinese
     * （默认）内容类型为动画。
     * - 当共享的内容是视频、电影或游戏时，推荐选择该内容类型。
     * - 当用户设置内容类型为动画时，按用户设置的帧率处理。
     * @endif
     */
    kNERtcSubStreamContentPreferMotion = 0,
    /**
     * @if English
     * The content type is details.
     * - When the shared content is an image or text, we recommend that you select this content type.
     * - When the user sets the content type to details, the user is allowed to set up to 10 frames. If the setting exceeds 10 frames, the value of 10 frames is applied.
     * @endif
     * @if Chinese
     * 内容类型为细节。
     * - 当共享的内容是图片或文字时，推荐选择该内容类型。
     * - 当用户设置内容类型为细节时，最高允许用户设置到 10 帧，设置超过10帧时，按10帧处理。
     * @endif
     */
    kNERtcSubStreamContentPreferDetails,
};

/**
 * @if English
 * The type of the remote video stream.
 * @endif
 * @if Chinese
 * 远端视频流类型。
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcRemoteVideoStreamType) {
    /**
     * @if English
     * High-definition stream with HD video quality.
     * @endif
     * @if Chinese
     * 大流，高清画质。
     * @endif
     */
    kNERtcRemoteVideoStreamTypeHigh,
    /**
     * @if English
     * Low-definition stream with LD video quality.
     * @endif
     * @if Chinese
     * 小流，低清画质。
     * @endif
     */
    kNERtcRemoteVideoStreamTypeLow
};

/**
 * @if English
 * Video publishing mode.
 * @endif
 * @if Chinese
 * 视频发布模式。
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcVideoPubMode) {
    /**
     * @if English
     * Publish streams as the format subscribed by the remote peer.
     * @endif
     * @if Chinese
     * 按对端订阅格式发流。
     * @endif
     */
    kNERtcVideoSendOnPubWithNone = 0,
    /**
     * @if English
     * Initially publish a high-definition stream.
     * @endif
     * @if Chinese
     * 初始发送大流。
     * @endif
     */
    kNERtcVideoSendOnPubWithHigh,
    /**
     * @if English
     * Initially publish a low-definition stream.
     * @endif
     * @if Chinese
     * 初始发布小流。
     * @endif
     */
    kNERtcVideoSendOnPubWithLow,
    /**
     * @if English
     * Initially publish a high-definition stream and a low-definition stream at the same time.
     * @endif
     * @if Chinese
     * 初始大小流同时发送。
     * @endif
     */
    kNERtcVideoSendOnPubWithAll,
};

/**
 * @if English
 * Video rendering zoom mode.
 * @endif
 * @if Chinese
 * 视频渲染缩放模式。
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcVideoRenderScaleMode) {
    /**
     * @if English
     * Adaptive to the video. The video size is scaled proportionally. Give priority to ensuring that all video content is displayed. If the video size does not match the display window size, the unfilled area of the window is be filled with the background color.
     * @endif
     * @if Chinese
     * 适应视频，视频尺寸等比缩放。优先保证视频内容全部显示。若视频尺寸与显示视窗尺寸不一致，视窗未被填满的区域填充背景色。
     * @endif
     */
    kNERtcVideoRenderScaleFit      = 0,
    /**
     * @if English
     * Video size is scaled non-proportionally. Ensure that all video content is displayed and the window is filled.
     * @endif
     * @if Chinese
     * 视频尺寸非等比缩放。保证视频内容全部显示，且填满视窗。
     * @endif
     */
    kNERtcVideoRenderScaleFullFill = 1,
    /**
     * @if English
     * Adaptive to the area, the video size is scaled proportionally. Ensure that all areas are filled, and the extra part of the video will be cropped.
     * @endif
     * @if Chinese
     * 适应区域，视频尺寸等比缩放。保证所有区域被填满，视频超出部分会被裁剪。
     * @endif
     */
    kNERtcVideoRenderScaleCropFill = 2,
};

/**
 * @if English
 * Video rotation Mode.
 * @endif
 * @if Chinese
 * 视频旋转模式。
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcVideoRotationMode) {
    /**
     * @if English
     * (default) Determine the video orientation mode based on the orientation of the system device. If the local system device uses landscape, the local screen will be displayed in landscape mode on the local client and remote client.
     * @endif
     * @if Chinese
     * （默认）通过系统设备方向来判断视频旋转模式。如果本地系统设备横向放置，本地画面在本地和远端将展示为横屏模式。
     * @endif
     */
    NERtcVideoRotationModeBySystem = 0,
    /**
     * @if English
     * Determine the video rotation mode by the app direction. If the local App UI is switched to landscape mode, the local screen will also be displayed in landscape mode on the local client and remote client.
     * @endif
     * @if Chinese
     * 通过 App 方向来判断视频旋转模式。如果本地 App UI 切换到横屏，本地画面在本地和远端也将展示为横屏模式。
     * @endif
     */
    NERtcVideoRotationModeByApp = 1,
};


/**
 * @if English
 * Video mirror mode.
 * @endif
 * @if Chinese
 * 视频镜像模式。
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcVideoMirrorMode) {
    /**
     * @if English
     * (default) The mirror mode is determined by the SDK.
     * @endif
     * @if Chinese
     * （默认）由 SDK 决定镜像模式
     * @endif
     */
    kNERtcVideoMirrorModeAuto    = 0,
    /**
     * @if English
     * Enable mirror mode.
     * @endif
     * @if Chinese
     * 启用镜像模式。
     * @endif
     */
    kNERtcVideoMirrorModeEnabled = 1,
    /**
     * @if English
     * Disable mirror mode.
     * @endif
     * @if Chinese
     * 关闭镜像模式。
     * @endif
     */
    kNERtcVideoMirrorModeDisabled = 2,
};

/**
 * @if English
 * Video orientation mode.
 * @endif
 * @if Chinese
 * 视频旋转方向模式。
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcVideoOutputOrientationMode) {
    /**
     * @if English
     * (default) The direction of the video output by the SDK in this mode is consistent with the direction of the captured video. The receiver rotates the video based on the received video rotation information.
     * <br>This mode is suitable for scenarios where the receiver can adjust the video direction.
     * - If the captured video is in landscape mode, the output video is also in landscape mode.
     * - If the captured video is in portrait mode, the output video is also in portrait mode.
     * @endif
     * @if Chinese
     * （默认）该模式下 SDK 输出的视频方向与采集到的视频方向一致。接收端会根据收到的视频旋转信息对视频进行旋转。
     * <br>该模式适用于接收端可以调整视频方向的场景。
     * - 如果采集的视频是横屏模式，则输出的视频也是横屏模式。
     * - 如果采集的视频是竖屏模式，则输出的视频也是竖屏模式。
     * @endif
     */
    kNERtcVideoOutputOrientationModeAdaptative    = 0,
    /**
     * @if English
     * In this mode, the SDK always outputs videos in landscape mode. If the captured video is in portrait mode, the video encoder crops the video.
     * <br>This mode is suitable for scenes where the receiver cannot adjust the video direction, such as CDN relayed streaming.
     * @endif
     * @if Chinese
     * 该模式下 SDK 固定输出横屏模式的视频。如果采集到的视频是竖屏模式，则视频编码器会对其进行裁剪。
     * <br>该模式适用于接收端无法调整视频方向的场景，例如旁路推流。
     * @endif
     */
    kNERtcVideoOutputOrientationModeFixedLandscape = 1,
    /**
     * @if English
     * In this mode, the SDK always outputs videos in portrait mode. If the captured video is in landscape mode, the video encoder crops the video.
     * <br>This mode is suitable for scenes where the receiver cannot adjust the video direction, such as CDN relayed streaming.
     * @endif
     * @if Chinese
     * 该模式下 SDK 固定输出竖屏模式的视频，如果采集到的视频是横屏模式，则视频编码器会对其进行裁剪。
     * <br>该模式适用于接收端无法调整视频方向的场景，例如旁路推流。
     * @endif
     */
    kNERtcVideoOutputOrientationModeFixedPortrait = 2,
};

/**
 * @if English
 * Video crop mode.
 * @endif
 * @if Chinese
 * 视频裁剪模式
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcVideoCropMode) {
    /**
     * @if English
     * Do not crop.
     * @endif
     * @if Chinese
     * 不裁剪。
     * @endif
     */
    kNERtcVideoCropDefault,
    /**
     * @if English
     * 16:9
     * @endif
     * @if Chinese
     * 16:9
     * @endif
     */
    kNERtcVideoCropMode16_9,
    /**
     * @if English
     * 4:3
     * @endif
     * @if Chinese
     * 4:3
     * @endif
     */
    kNERtcVideoCropMode4_3,
    /**
     * @if English
     * 1:1
     * @endif
     * @if Chinese
     * 1:1
     * @endif
     */
    kNERtcVideoCropMode1_1,
};

/**
 * @if English
 * Video rendering type.
 * @endif
 * @if Chinese
 * 视频渲染类型。
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcRenderType) {
    /**
     * @if English
     * The default video rendering type.
     * @endif
     * @if Chinese
     * 默认视频渲染类型。
     * @endif
     */
    kNERtcRenderDefault = 0,
    /**
     * @if English
     * OpenGLES rendering.
     * @endif
     * @if Chinese
     * OpenGLES 渲染。
     * @endif
     */
    kNERtcRenderOpenGL,
    /**
     * @if English
     * Metal rendering.
     * @endif
     * @if Chinese
     * Metal 渲染。
     * @endif
     */
    kNERtcRenderMetal,
};

/**
 * @if English
 * Rotation direction of video data.
 * @endif
 * @if Chinese
 * 视频数据的旋转方向
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcVideoRotationType) {
    /**
     * @if English
     * 0°.
     * @endif
     * @if Chinese
     * 0 度。
     * @endif
     */
    kNERtcVideoRotation_0 = 0,
    /**
     * @if English
     * 90°.
     * @endif
     * @if Chinese
     * 90 度。
     * @endif
     */
    kNERtcVideoRotation_90 = 90,
    /**
     * @if English
     * 180°.
     * @endif
     * @if Chinese
     * 180 度。
     * @endif
     */
    kNERtcVideoRotation_180 = 180,
    /**
     * @if English
     * 270°.
     * @endif
     * @if Chinese
     * 270 度。
     * @endif
     */
    kNERtcVideoRotation_270 = 270,
};

typedef NS_ENUM(NSUInteger, NERtcVideoBufferType) {
    // 原始数据
    NERtcVideoBufferTypeRawData = 0,
    // Metal 纹理
    NERtcVideoBufferTypeMetalTexture
};

/**
 * @if English
 * Video format type.
 * @endif
 * @if Chinese
 * 视频格式类型
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcVideoFormatType) {
    /**
     * @if English
     * I420 video format.
     * @endif
     * @if Chinese
     * I420 视频格式。
     * @endif
     */
    kNERtcVideoFormatI420 = 0,
    /**
     * @if English
     * NV12 video format.
     * @endif
     * @if Chinese
     * NV12 视频格式。
     * @endif
     */
    kNERtcVideoFormatNV12,
    /**
     * @if English
     * BGRA video format.
     * @endif
     * @if Chinese
     * BGRA 视频格式。
     * @endif
     */
    kNERtcVideoFormatBGRA,
};

/**
 * @if English
 * Stream type for sending SEI.
 * @endif
 * @if Chinese
 * SEI发送的流通道类型。
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcStreamChannelType) {
    /**
     * @if English
     * Bigstream.
     * @endif
     * @if Chinese
     * 主流通道。
     * @endif
     */
    kNERtcStreamChannelTypeMainStream = 0,
    /**
     * @if English
     * Substream.
     * @endif
     * @if Chinese
     * 辅流通道。
     * @endif
     */
    kNERtcStreamChannelTypeSubStream,
};

/**
 * @if English
 * The reason why the virtual background is not successfully enabled or the message that confirms success.
 * @since v4.6.10
 * @endif
 * @if Chinese
 * 虚拟背景未成功启用的原因或确认成功的信息。
 * @since v4.6.10
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcVirtualBackgroundSourceStateReason) {
    /**
     * @if English
     * 0: The virtual background is successfully enabled.
     * @endif
     * @if Chinese
     * 0:  虚拟背景开启成功。
     * @endif
     */
    kNERtcVirtualBackgroundSourceStateReasonSuccess = 0,
    /**
     * @if English
     * 1: The custom background image does not exist. Please check the value of `source` in VirtualBackgroundSource.
     * @endif
     * @if Chinese
     * 1：自定义背景图片不存在。 请检查 VirtualBackgroundSource 中 `source` 的值。
     * @endif
     */
    kNERtcVirtualBackgroundSourceStateReasonImageNotExist = 1,
    /**
     * @if English
     * 2: The image format of the custom background image is invalid. Please check the value of `source` in VirtualBackgroundSource.
     * @endif
     * @if Chinese
     * 2：自定义背景图片的图片格式无效。 请检查 VirtualBackgroundSource 中 `source` 的值。
     * @endif
     */
    kNERtcVirtualBackgroundSourceStateReasonImageFormatNotSupported = 2,
    /**
     * @if English
     * 3: The color format of the custom background image is invalid. Please check the value of `color` in VirtualBackgroundSource.
     * @endif
     * @if Chinese
     * 3：自定义背景图片的颜色格式无效。 请检查 VirtualBackgroundSource 中 `color` 的值。
     * @endif
     */
    kNERtcVirtualBackgroundSourceStateReasonColorFormatNotSupported = 3,
    /**
     * @if English
     * 4: The device does not support using the virtual background.
     * @endif
     * @if Chinese
     * 4：该设备不支持使用虚拟背景。
     * @endif
     */
    kNERtcVirtualBackgroundSourceStateReasonDeviceNotSupported = 4
};

/**
 * @if English
 * The type of the custom background image.
 * @since v4.6.10
 * @endif
 * @if Chinese
 * 自定义背景图片的类型。
 * @since v4.6.10
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcVirtualBackgroundSourceType ) {
    
    /**
     * @if English
     * 1: (Default) The background image is a solid color.
     * @endif
     * @if Chinese
     * 1：（默认）背景图像为纯色。
     * @endif
     */
    kNERtcVirtualBackgroundColor = 1,
    
    /**
     * @if English
     * The background image is a file in PNG or JPG format.
     * @endif
     * @if Chinese
     * 背景图像只支持 PNG 或 JPG 格式的文件。
     * @endif
     */
    kNERtcVirtualBackgroundImg = 2,
    
    /**
     * @if English
     * The background image is the background image after blurring.
     * @endif
     * @if Chinese
     * 背景图为虚化处理后的背景图。
     * @endif
     */
    kNERtcVirtualBackgroundBlur = 3,
};

/**
 * @if English
 * Customize the bokeh level of the background image.
 * @since v4.6.10
 * @endif
 * @if Chinese
 * 自定义背景图的虚化程度。
 * @since v4.6.10
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcBlurDegree ) {
    
    /**
     * @if English
     * 1:  The bokeh level of the custom background image is low. The user can almost see the background clearly.
     * @endif
     * @if Chinese
     * 1：自定义背景图的虚化程度为低。用户差不多能看清背景。
     * @endif
     */
    kNERtcBlurLow = 1,
    
    /**
     * @if English
     * 2: The bokeh level of the custom background image is medium. It is more difficult for users to see the background.
     * @endif
     * @if Chinese
     * 2：自定义背景图的虚化程度为中。用户较难看清背景。
     * @endif
     */
    kNERtcBlurMedium = 2,
    
    /**
     * @if English
     * 1: (Default) The blur degree of the custom background image is high. It is difficult for users to see the background.
     * @endif
     * @if Chinese
     * 3：（默认）自定义背景图的虚化程度为高。用户很难看清背景。
     * @endif
     */
    kNERtcBlurHigh = 3,
};

/**
 * @if English
 * Video watermark types
 * @endif
 * @if Chinese
 * 视频水印类型。
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcVideoWatermarkType) {
    /**
     * @if English
     * Image
     * @endif
     * @if Chinese
     * 图片水印。图片水印的图片大小不能超过 640*360 px。
     * @endif
     */
    kNERtcVideoWatermarkTypeImage = 0,
    
    /**
     * @if English
     * Text
     * @endif
     * @if Chinese
     * 文字水印。
     * @endif
     */
    kNERtcVideoWatermarkTypeText,
    
    /**
     * @if English
     * Timestamp
     * @endif
     * @if Chinese
     * 时间戳水印。
     * @endif
     */
    kNERtcVideoWatermarkTypeTimeStamp
};

/**
 * @if English
 * Video watermark state.
 * @endif
 * @if Chinese
 * 视频水印状态。
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcLocalVideoWatermarkState) {
    /**
     * @if English
     * The local video watermark set successfully.
     * @endif
     * @if Chinese
     * 水印设置成功。
     * @endif
     */
    kNERtcLocalVideoWatermarkStateSetSuccess = 0,
  
    /**
     * @if English
     * The device is not supported.
     * @endif
     * @if Chinese
     * 设备不支持。
     * @endif
     */
    kNERtcLocalVideoWatermarkStateDeviceNotSupported = 1,
    
    /**
     * @if English
     * The image format is not supported.
     * @endif
     * @if Chinese
     * 图片格式不支持。
     * @endif
     */
    kNERtcLocalVideoWatermarkStateImageFormatNotSupported,
    
    /**
     * @if English
     * Image number error.
     * @endif
     * @if Chinese
     * 图片数量设置错误。
     * @endif
     */
    kNERtcLocalVideoWatermarkStateImageNumberError,
    
    /**
     * @if English
     * Image size error.
     * @endif
     * @if Chinese
     * 图片尺寸设置错误。图片水印的图片大小不能超过 640*360 px。
     * @endif
     */
    kNERtcLocalVideoWatermarkStateImageSizeError,
    
    /**
     * @if English
     * Image FPS error.
     * @endif
     * @if Chinese
     * 图片轮播帧率设置错误。
     * @endif
     */
    kNERtcLocalVideoWatermarkStateImageFpsError,
    
    /**
     * @if English
     * Font error.
     * @endif
     * @if Chinese
     * 字体设置错误。
     * @endif
     */
    kNERtcLocalVideoWatermarkStateFontError,
    
    /**
     * @if Chinese
     * 窗口透明度设置错误。
     * @endif
     */
    kNERtcLocalVideoWatermarkStateAlphaError,
    
    /**
     * @if Chinese
     * 文本内容为空。
     * @endif
     */
    kNERtcLocalVideoWatermarkStateTextContentEmpty,
    
    /**
     * @if English
     * Watermark canceled.
     * @endif
     * @if Chinese
     * 取消水印。
     * @endif
     */
    kNERtcLocalVideoWatermarkStateCancel = 20
};

/**
 * @if English
 * Position of a specified camera.
 * @endif
 * @if Chinese
 * 指定的摄像头位置。
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcCameraPosition) {
    /**
     * @if English
     * Front camera.
     * @endif
     * @if Chinese
     * 前置摄像头。
     * @endif
     */
    kNERtcCameraPositionBack = 0,
    
    /**
     * @if English
     * Rear camera.
     * @endif
     * @if Chinese
     * 后置摄像头。
     * @endif
     */
    kNERtcCameraPositionFront
};

#pragma mark -- AUDIO ENUM

/**
 * @if English
 * Audio route.
 * @endif
 * @if Chinese
 * 音频路由。
* @endif
*/
typedef NS_ENUM(NSInteger, NERtcAudioOutputRouting) {
    /**
     * @if English
     * System default
     * @endif
     * @if Chinese
     * 系统默认。
     * @endif
     */
    kNERtcAudioOutputRoutingDefault = 0,
    /**
     * @if English
     * Headset
     * @endif
     * @if Chinese
     * 耳机。
     * @endif
     */
    kNERtcAudioOutputRoutingHeadset,
    /**
     * @if English
     * Earpiece
     * @endif
     * @if Chinese
     * 听筒。
     * @endif
     */
    kNERtcAudioOutputRoutingEarpiece,
    /**
     * @if English
     * Speakerphone
     * @endif
     * @if Chinese
     * 扬声器。
     * @endif
     */
    kNERtcAudioOutputRoutingLoudspeaker,
    /**
     * @if English
     * Bluetooth device
     * @endif
     * @if Chinese
     * 蓝牙外设。
     * @endif
     */
    kNERtcAudioOutputRoutingBluetooth,
};

/**
 * @if English
 * Summary of audio quality capabilities
 * <br>Audio profile: sample rate, bitrate, encoding mode, and the number of channels.
 * @endif
 * @if Chinese
 * 音频质量能力概要
 * <br>音频属性:设置采样率，码率，编码模式和声道数
 * @endif
 */
typedef NS_ENUM(NSInteger, NERtcAudioProfileType) {
    /**
     * @if English
     * Default setting. STANDARD is selected for voice scenarios. HIGH_QUALITY is selected for music scenarios.
     * @endif
     * @if Chinese
     * 默认设置。语音场景下为 STANDARD，音乐场景下为 HIGH_QUALITY。
     * @endif
     */
    kNERtcAudioProfileDefault = 0,
    /**
     * @if English
     * Standard sound quality mode. Sample rate: 16 kHz, voice encoding, mono, and maximum bitrate: 20 kbps.
     * @endif
     * @if Chinese
     * 标准音质模式。采样率为 16 kHz、语音编码、单声道、编码码率最大值为 20 Kbps。
     * @endif
     */
    kNERtcAudioProfileStandard,
    /**
     * @if English
     * Standard extended mode. Sample rate: 16 kHz, voice encoding, mono, and maximum bitrate: 32 kbps.
     * @endif
     * @if Chinese
     * 标准扩展模式。采样率为 16 kHz、语音编码、单声道、编码码率最大值为 32 Kbps。
     * @endif
     */
    kNERtcAudioProfileStandardExtend,
    /**
     * @if English
     * Medium sound quality mode. Sample rate: 48 kHz, music encoding, mono, and maximum bitrate: 64 kbps.
     * @endif
     * @if Chinese
     * 中等音质模式。采样率为 48 kHz、音乐编码、单声道、编码码率最大值为 64 Kbps。
     * @endif
     */
    kNERtcAudioProfileMiddleQuality,
    /**
     * @if English
     * Medium sound quality mode (stereo). Sample rate: 48 kHz, music encoding, stereo, and maximum bitrate: 80 kbps.
     * @endif
     * @if Chinese
     * 中等音质模式（立体音）。采样率为 48 kHz、音乐编码、双声道、编码码率最大值为 80 Kbps。
     * @endif
     */
    kNERtcAudioProfileMiddleQualityStereo,
    /**
     * @if English
     * High sound quality mode. Sample rate: 48 kHz, music encoding, mono, and maximum bitrate: 96 kbps.
     * @endif
     * @if Chinese
     * 高音质模式。采样率为 48 kHz、音乐编码、单声道、编码码率最大值为 96 Kbps。
     * @endif
     */
    kNERtcAudioProfileHighQuality,
    /**
     * @if English
     * High sound quality mode (stereo). Sample rate: 48 kHz, music encoding, stereo, and maximum bitrate: 128 kbps.
     * @endif
     * @if Chinese
     * 高音质模式（立体音）。采样率为 48 kHz、音乐编码、双声道、编码码率最大值为 128 Kbps。
     * @endif
     */
    kNERtcAudioProfileHighQualityStereo,
};

/**
 * @if English
 * Audio scenarios
 * <br>Different audio scenarios use different audio capture modes (mobile platforms) and playback modes.
 * - kNERtcAudioScenarioDefault: The default setting is kNERtcAudioScenarioSpeech
 * - kNERtcAudioScenarioSpeech: Voice scenarios. Set NERtcAudioProfileType to kNERtcAudioProfileMiddleQuality or lower.
 * - kNERtcAudioScenarioMusic: Music scenarios. Set NERtcAudioProfileType to kNERtcAudioProfileMiddleQualityStereo or above
 * - kNERtcAudioScenarioChatRoom: Chat room scenarios. Set NERtcAudioProfileType to kNERtcAudioProfileMiddleQualityStereo or above
 * @endif
 * @if Chinese
 * 音频应用场景。
 * <br>不同的场景设置对应不同的音频采集模式（移动平台）、播放模式。
 * - kNERtcAudioScenarioDefault: 默认设置为 kNERtcAudioScenarioSpeech。
 * - kNERtcAudioScenarioSpeech: 语音场景. NERtcAudioProfileType 推荐使用 kNERtcAudioProfileMiddleQuality 及以下。
 * - kNERtcAudioScenarioMusic: 音乐场景。NERtcAudioProfileType 推荐使用 kNERtcAudioProfileMiddleQualityStereo 及以上。
 * - kNERtcAudioScenarioChatRoom: 语聊房场景。 NERtcAudioProfileType 推荐使用 kNERtcAudioProfileMiddleQualityStereo 及以上。
 * @endif
 */
typedef NS_ENUM(NSInteger, NERtcAudioScenarioType) {
    /**
     * @if English
     * The default audio scenario (voice).
     * @endif
     * @if Chinese
     * 默认的音频应用场景（语音）。
     * @endif
     */
    kNERtcAudioScenarioDefault = 0,
    /**
     * @if English
     * Voice
     * @endif
     * @if Chinese
     * 语音场景。
     * @endif
     */
    kNERtcAudioScenarioSpeech,
    /**
     * @if English
     * Music
     * @endif
     * @if Chinese
     * 音乐场景。
     * @endif
     */
    kNERtcAudioScenarioMusic,
    /**
     * @if English
     * Chat room
     * @endif
     * @if Chinese
     * 语音聊天室场景。
     * @endif
     */
    kNERtcAudioScenarioChatRoom,
};

/**
 * @if English
 * Sets a room scene.
 * @endif
 * @if Chinese
 * 房间场景。
 * @endif
 */
typedef NS_ENUM(NSInteger, NERtcChannelProfileType) {
    /**
     * @if English
     * (default) communications. In this scenario, all users in the room can publish and receive audio and video streams. The setting is suitable for scenarios such as audio calls and group video calls.
     * @endif
     * @if Chinese
     * （默认）通信场景。该场景下，房间内所有用户都可以发布和接收音、视频流。适用于语音通话、视频群聊等应用场景。
     * @endif
     */
    kNERtcChannelProfileCommunication = 0,
    /**
     * @if English
     * Live streaming. This scenario has two user roles: host and audience, which can be set through setClientRole. The host can publish and receive audio and video streams, and the audience can receive the streams. The setting is suitable for scenarios such as chat rooms, live streaming, and interactive remote learning for large classes.
     * @endif
     * @if Chinese
     * 直播场景。该场景有主播和观众两种用户角色，可以通过setClientRole设置。主播可以发布和接收音视频流，观众直接接收流。适用于语聊房、视频直播、互动大班课等应用场景。
     * @endif
     */
    kNERtcChannelProfileLiveBroadcasting,
};


/**
 * @if English
 * Audio session control permissions
 * <br>The SDK has the permissions of Audio Session.
 * @endif
 * @if Chinese
 * 音频会话控制权限。
 * <br>SDK 对 Audio Session 的控制权限。
 * @endif
 */
typedef NS_ENUM(NSInteger, NERtcAudioSessionOperationRestriction) {
    /**
     * @if English
     * The SDK has full permissions and can control the Audio Session
     * @endif
     * @if Chinese
     * 没有限制，SDK 可以完全控制 Audio Session 操作。
     * @endif
     */
    kNERtcAudioSessionOperationRestrictionNone = 0,
    /**
     * @if English
     * If you restrict the SDK to perform operations on the Audio Session, the SDK cannot configure the Audio Session
     * @endif
     * @if Chinese
     * 限制 SDK 对 Audio Session 进行任何操作，SDK 将不能再对 Audio Session 进行任何配置。
     * @endif
     */
    kNERtcAudioSessionOperationRestrictionAll,
    /**
     * @if English
     * When a user leaves the room, the SDK will keep the Audio Session active.
     * @endif
     * @if Chinese
     * 离开房间时，SDK 会保持 Audio Session 处于活动状态。
     * @endif
     */
    kNERtcAudioSessionOperationRestrictionDeactivateSession,
};

/**
 音频流类型，目前同时支持音频两路流：主流和辅流
*/
typedef NS_ENUM(int, NERtcAudioStreamType) {
    /**音频流主流*/
    kNERtcAudioStreamMain = 0,
    /**音频流辅流*/
    kNERtcAudioStreamSub,
    /**已废弃，请使用kNERtcAudioStreamMain*/
    kNERtcAudioStreamTypeMain = kNERtcAudioStreamMain,
    /**已废弃，请使用kNERtcAudioStreamSub*/
    kNERtcAudioStreamTypeSub = kNERtcAudioStreamSub
};

/**
 音频dump类型
 */
typedef NS_ENUM(NSInteger, NERtcAudioDumpType) {
    /** 仅输出.dump文件*/
    kNERtcAudioDumpTypePCM = 0,
    /** 输出.dump和.wav文件 */
    kNERtcAudioDumpTypeAll,
    /** 仅输出.wav文件（默认）  */
    kNERtcAudioDumpTypeWAV
};

/**
 * 空间音效房间大小
 */
typedef NS_ENUM(NSInteger, NERtcSpatializerRoomCapacity) {
    /**
     * 小房间
     */
    kNERtcSpatializerRoomCapacitySmall = 0,

    /**
     * 中等大小房间
     */
    kNERtcSpatializerRoomCapacityMedium = 1,

    /**
     * 大房间
     */
    kNERtcSpatializerRoomCapacityLarge = 2,

    /**
     * 巨大房间
     */
    kNERtcSpatializerRoomCapacityHuge = 3,

    /**
     * 无房间效果
     */
    kNERtcSpatializerRoomCapacityNone = 4
};

/**
 * 空间音效中房间材质名称
 */
typedef NS_ENUM(NSInteger, NERtcSpatializerMaterialName) {
    /**
     * 透明的
     */
    kNERtcSpatializerMaterialTransparent = 0,
    /**
     * 声学天花板，未开放
     */
    kNERtcSpatializerMaterialAcousticCeilingTiles,
    /**
     * 砖块，未开放
     */
    kNERtcSpatializerMaterialBrickBare,
    /**
     * 涂漆的砖块，未开放
     */
    kNERtcSpatializerMaterialBrickPainted,
    /**
     * 粗糙的混凝土块，未开放
     */
    kNERtcSpatializerMaterialConcreteBlockCoarse,
    /**
     * 涂漆的混凝土块，未开放
     */
    kNERtcSpatializerMaterialConcreteBlockPainted,
    /**
     * 厚重的窗帘
     */
    kNERtcSpatializerMaterialCurtainHeavy,
    /**
     * 茂密的草地，未开放
     */
    kNERtcSpatializerMaterialFiberGlassInsulation,
    /**
     * 薄的的玻璃，未开放
     */
    kNERtcSpatializerMaterialGlassThin,
    /**
     * 草地
     */
    kNERtcSpatializerMaterialGlassThick,
    /**
     * 铺装了油毡的混凝土，未开放
     */
    kNERtcSpatializerMaterialGrass,
    /**
     * 大理石
     */
    kNERtcSpatializerMaterialLinoleumOnConcrete,
    /**
     * 金属，未开放
     */
    kNERtcSpatializerMaterialMarble,
    /**
     * 镶嵌木板的混凝土，未开放
     */
    kNERtcSpatializerMaterialMetal,
    /**
     * 石膏，未开放
     */
    kNERtcSpatializerMaterialParquetOnConcrete,
    /**
     * 粗糙石膏，未开放
     */
    kNERtcSpatializerMaterialPlasterRough,
    /**
     * 光滑石膏，未开放
     */
    kNERtcSpatializerMaterialPlasterSmooth,
    /**
     * 木板，未开放
     */
    kNERtcSpatializerMaterialPlywoodPanel,
    /**
     * 光滑石膏，未开放
     */
    kNERtcSpatializerMaterialPolishedConcreteOrTile,
    /**
     * 石膏灰胶纸板，未开放
     */
    kNERtcSpatializerMaterialSheetrock,
    /**
     * 水面或者冰面，未开放
     */
    kNERtcSpatializerMaterialWaterOrIceSurface,
    /**
     * 木头天花板，未开放
     */
    kNERtcSpatializerMaterialWoodCeiling,
    /**
     * 木头枪板，未开放
     */
    kNERtcSpatializerMaterialWoodPanel,
    /**
     * 均匀分布，未开放
     */
    kNERtcSpatializerMaterialUniform
};

/**
 * 空间音效渲染模式
 */
typedef NS_ENUM(NSInteger, NERtcSpatializerRenderMode) {
    /**
     * 立体声
     */
    kNERtcSpatializerRenderStereoPanning = 0,
    /**
     * 双声道低
     */
    kNERtcSpatializerRenderBinauralLowQuality,
    /**
     * 双声道中
     */
    kNERtcSpatializerRenderBinauralMediumQuality,
    /**
     * 双声道高
     */
    kNERtcSpatializerRenderBinauralHighQuality,
    /**
     * 仅房间音效
     */
    kNERtcSpatializerRenderRoomEffectsOnly
};

/**
 * 空间音效衰减模式
 */
typedef NS_ENUM(NSInteger, NERtcDistanceRolloffModel) {
    /**
     * 指数模式
     */
    kNERtcDistanceRolloffLogarithmic = 0,
    /**
     * 线性模式
     */
    kNERtcDistanceRolloffLinear,
    /**
     * 无衰减
     */
    kNERtcDistanceRolloffNone,
    /**
     * 仅线性衰减,没有方位效果
     */
    kNERtcDistanceRolloffLinearOnly
};

typedef NS_ENUM(NSInteger, NERtcRangeAudioMode) {
    /**
     * @if Chinese
     * 默认模式
     * @note
     * - 设置后玩家附近一定范围的人都能听到该玩家讲话，如果范围内也有玩家设置为此模式，则也可以互相通话。
     * - TeamID相同的队友可以互相听到
     * @endif
     */
    NERtcRangeAudioModeDefault = 0,
    /**
     * @if Chinese
     * 小组模式
     * @note 仅TeamID相同的队友可以互相听到
     * @endif
     */
    NERtcRangeAudioModeTeam = 1,
};

#pragma mark - media

typedef NS_ENUM(NSInteger, NERtcMediaPriorityType){
    /**
     * @if English
     * High priority
     * @endif
     * @if Chinese
     * 高优先级。
     * @endif
     */
    kNERtcMediaPriorityHigh = 50,
    /**
     * @if English
     * (default) Normal priority
     * @endif
     * @if Chinese
     * （默认）普通优先级 。
     * @endif
     */
    kNERtcMediaPriorityNormal = 100,
};

typedef NS_ENUM(NSInteger, NERtcStreamFallbackOptions){
    /**
     * @if English
     * When the uplink or downlink network is unstable, the audio and video streams will not fallback, but the quality of the audio and video streams cannot be guaranteed.
     * @note This option is only valid for the setLocalPublishFallbackOption method, and invalid for the setRemoteSubscribeFallbackOption method.
     * @endif
     * @if Chinese
     * 上行或下行网络较弱时，不对音视频流作回退处理，但不能保证音视频流的质量。
     * @note 该选项只对 setLocalPublishFallbackOption 方法有效，对 setRemoteSubscribeFallbackOption 方法无效。
     * @endif
     */
    kNERtcStreamFallbackOptionDisabled = 0,
    /**
     * @if English
     * In an unstable downlink network, the SDK only receives low-definition streams, which have low resolution and bitrate.
     * @note This option is only valid for the setRemoteSubscribeFallbackOption method, and invalid for the setLocalPublishFallbackOption method.
     * @endif
     * @if Chinese
     * 在下行网络条件较差的情况下，SDK 将只接收视频小流，即低分辨率、低码率视频流。
     * @note 该选项只对 setRemoteSubscribeFallbackOption 方法有效，对 setLocalPublishFallbackOption 方法无效。
     * @endif
     */
    kNERtcStreamFallbackOptionVideoStreamLow = 1,
    /**
     * @if English
     * - In an unstable uplink network, only the audio stream is published.
     * - In an unstable downlink network, first try to receive only low-definition streams, which have low resolution and bitrate. If the video stream cannot be displayed due to network quality, then the stream falls back to the audio stream.
     * @endif
     * @if Chinese
     * - 上行网络较弱时，只发布音频流。
     * - 下行网络较弱时，先尝试只接收视频小流，即低分辨率、低码率视频流。如果网络环境无法显示视频，则再回退到只接收音频流。
     * @endif
     */
    kNERtcStreamFallbackOptionAudioOnly = 2,
};

/**
 * @if English
 * Recording sound quality.
 * @endif
 * @if Chinese
 * 录音音质。
 * @endif
 */
typedef NS_ENUM(NSInteger, NERtcAudioRecordingQuality) {
    /**
     * @if English
     * Low quality
     * @endif
     * @if Chinese
     * 低音质。
     * @endif
     */
    kNERtcAudioRecordingQualityLow = 0,
    /**
     * @if English
     * (default) medium quality
     * @endif
     * @if Chinese
     * （默认）中音质。
     * @endif
     */
    kNERtcAudioRecordingQualityMedium = 1,
    /**
     * @if English
     * High sound quality
     * @endif
     * @if Chinese
     * 高音质。
     * @endif
     */
    kNERtcAudioRecordingQualityHigh = 2,
};

/**
 * @if English
 * The status code of recording callbacks.
 * @endif
 * @if Chinese
 * 录音回调状态码。
 * @endif
 */
typedef NS_ENUM(NSInteger, NERtcAudioRecordingCode) {
    /**
     * @if English
     * Unsupported recording file format.
     * @endif
     * @if Chinese
     * 不支持的录音文件格式。
     * @endif
     */
    NERtcAudioRecordingCodeErrorSuffix = 1,
    /**
     * @if English
     * Unable to create a recording file. Possible reasons:
     * - The application does not have write permissions.
     * - The file path does not exist.
     * @endif
     * @if Chinese
     * 无法创建录音文件，原因通常包括：
     * - 应用没有磁盘写入权限。
     * - 文件路径不存在。
     * @endif
     */
    kNERtcAudioRecordingOpenFileFailed = 2,
    /**
     * @if English
     * Start recording.
     * @endif
     * @if Chinese
     * 开始录制。
     * @endif
     */
    kNERtcAudioRecordingCodeStart = 3,
    /**
     * @if English
     * Recording error. The typical reason is that the disk space is full and cannot be written.
     * @endif
     * @if Chinese
     * 录制错误。原因通常为磁盘空间已满，无法写入。
     * @endif
     */
    kNERtcAudioRecordingRecordError = 4,
    /**
     * @if English
     * Recording is complete.
     * @endif
     * @if Chinese
     * 完成录制。
     * @endif
     */
    kNERtcAudioRecordingCodeFinish = 5,
};

typedef NS_ENUM(NSInteger, NERtcAudioRecordingPosition) {
    // 录制本地和所有远端用户混音后的音频（默认）
    kNERtcAudioRecordingPositionMixedRecordingAndPlayback = 0,
    // 仅录制采集的音频
    kNERtcAudioRecordingPositionRecording = 1,
    // 仅录制播放的音频
    kNERtcAudioRecordingPositionMixedPlayback = 2
};

typedef NS_ENUM(NSInteger, NERtcAudioRecordingCycleTime) {
    // 音频录制缓存时间为0，实时写文件（默认）
    kNERtcAudioRecordingCycleTime0 = 0,
    // 音频录制缓存时间为10s，StopAudioRectording()后，将缓存都写到文件，文件数据时间跨度为: [0,10s]
    kNERtcAudioRecordingCycleTime10 = 10,
    // 音频录制缓存时间为60s，StopAudioRectording()后，将缓存都写到文件，文件数据时间跨度为: [0,60s]
    kNERtcAudioRecordingCycleTime60 = 60,
    // 音频录制缓存时间为360s，StopAudioRectording()后，将缓存都写到文件，文件数据时间跨度为: [0,360s]
    kNERtcAudioRecordingCycleTime360 = 360,
    // 音频录制缓存时间为900s，StopAudioRectording()后，将缓存都写到文件，文件数据时间跨度为: [0,900s]
    kNERtcAudioRecordingCycleTime900 = 900
};

/**
 * @if English
 * The media type.
 * @endif
 * @if Chinese
 * 媒体类型。
 * @endif
 */
typedef NS_ENUM(int, NERtcPreDecoderMediaType) {
    /**
         * @if English
         * Audio media type.
         * @endif
         * @if Chinese
         * Audio 媒体类型。
         * @endif
         */
    kNERtcPreDecoderMediaTypeAudio = 0,
    
    /**
         * @if English
         * Video media type.
         * @endif
         * @if Chinese
         * Video 媒体类型。
         * @endif
         */
    kNERtcPreDecoderMediaTypeVideo = 1,
    
    /**
         * @if English
         * Unknown media type.
         * @endif
         * @if Chinese
         * Unknown 媒体类型。
         * @endif
         */
    kNERtcPreDecoderMediaTypeUnknown = 100,
};

typedef NS_ENUM(int, NERtcVideoCodecType) {
    kNERtcVideoCodecTypeH264 = 3,
};

#pragma mark --Voice changer/beautifier

/**
 * @if English
 * The preset value of the spectrum subband index.
 * @endif
 * @if Chinese
 * 频谱子带索引 预设值。
 * @endif
 */
typedef NS_ENUM(NSInteger, NERtcAudioEqualizationBandFrequency ) {
    /**
     * @if English
     * 0: 31 Hz.
     * @endif
     * @if Chinese
     * 0: 31 Hz.
     * @endif
     */
    NERtcAudioEqualizationBand31 = 0,
    /**
     * @if English
     * 1: 62 Hz.
     * @endif
     * @if Chinese
     * 1: 62 Hz.
     * @endif
     */
    NERtcAudioEqualizationBand62 = 1,
    /**
     * @if English
     * 2: 125 Hz.
     * @endif
     * @if Chinese
     * 2: 125 Hz.
     * @endif
     */
    NERtcAudioEqualizationBand125 = 2,
    /**
     * @if English
     * 3: 250 Hz.
     * @endif
     * @if Chinese
     * 3: 250 Hz.
     * @endif
     */
    NERtcAudioEqualizationBand250 = 3,
    /**
     * @if English
     * 4: 500 Hz.
     * @endif
     * @if Chinese
     * 4: 500 Hz.
     * @endif
     */
    NERtcAudioEqualizationBand500 = 4,
    /**
     * @if English
     * 5: 1 kHz.
     * @endif
     * @if Chinese
     * 5: 1 kHz.
     * @endif
     */
    NERtcAudioEqualizationBand1K = 5,
    /**
     * @if English
     * 6: 2 kHz.
     * @endif
     * @if Chinese
     * 6: 2 kHz.
     * @endif
     */
    NERtcAudioEqualizationBand2K = 6,
    /**
     * @if English
     * 7: 4 kHz.
     * @endif
     * @if Chinese
     * 7: 4 kHz.
     * @endif
     */
    NERtcAudioEqualizationBand4K = 7,
    /**
     * @if English
     * 8: 8 kHz.
     * @endif
     * @if Chinese
     * 8: 8 kHz.
     * @endif
     */
    NERtcAudioEqualizationBand8K = 8,
    /**
     * @if English
     * 9: 16 kHz.
     * @endif
     * @if Chinese
     * 9: 16 kHz.
     * @endif
     */
    NERtcAudioEqualizationBand16K = 9,
};

/**
 * @if English
 * The preset value of the voice changer.
 * @endif
 * @if Chinese
 * 变声 预设值。
 * @endif
 */
typedef NS_ENUM(NSInteger, NERtcVoiceChangerType) {
    /**
     * @if English
     * By default, the voice changer effect is disabled.
     * @endif
     * @if Chinese
     * （默认）关闭变声音效。
     * @endif
     */
    kNERtcVoiceChangerOff = 0,
    /**
     * @if English
     * Robot.
     * @endif
     * @if Chinese
     * 机器人。
     * @endif
     */
    kNERtcVoiceChangerRobot,
    /**
     * @if English
     * Giant.
     * @endif
     * @if Chinese
     * 巨人。
     * @endif
     */
    kNERtcVoiceChangerGaint,
    /**
     * @if English
     * Horror.
     * @endif
     * @if Chinese
     * 恐怖。
     * @endif
     */
    kNERtcVoiceChangerHorror,
    /**
     * @if English
     * Mature.
     * @endif
     * @if Chinese
     * 成熟。
     * @endif
     */
    kNERtcVoiceChangerMature,
    /**
     * @if English
     * Male to female.
     * @endif
     * @if Chinese
     * 男变女。
     * @endif
     */
    kNERtcVoiceChangerManToWoman,
    /**
     * @if English
     * Female to male.
     * @endif
     * @if Chinese
     * 女变男。
     * @endif
     */
    kNERtcVoiceChangerWomanToMan,
    /**
     * @if English
     * Male to loli.
     * @endif
     * @if Chinese
     * 男变萝莉。
     * @endif
     */
    kNERtcVoiceChangerManToLoli,
    /**
     * @if English
     * Female to loli.
     * @endif
     * @if Chinese
     * 女变萝莉。
     * @endif
     */
    kNERtcVoiceChangerWomanToLoli
};

/**
 * @if English
 * The preset value of the voice beautifier.
 * @endif
 * @if Chinese
 * 美声 预设值。
 * @endif
 */
typedef NS_ENUM(NSInteger, NERtcVoiceBeautifierType) {
    /**
     * @if English
     * By default, the voice beautifier effect is disabled.
     * @endif
     * @if Chinese
     * （默认）关闭美声效果。
     * @endif
     */
    kNERtcVoiceBeautifierOff = 0,
    /**
     * @if English
     * Muffled
     * @endif
     * @if Chinese
     * 低沉。
     * @endif
     */
    kNERtcVoiceBeautifierMuffled,
    /**
     * @if English
     * Mellow
     * @endif
     * @if Chinese
     * 圆润。
     * @endif
     */
    kNERtcVoiceBeautifierMellow,
    /**
     * @if English
     * Clear
     * @endif
     * @if Chinese
     * 清澈。
     * @endif
     */
    kNERtcVoiceBeautifierClear,
    /**
     * @if English
     * Magnetic
     * @endif
     * @if Chinese
     * 磁性。
     * @endif
     */
    kNERtcVoiceBeautifierMagnetic,
    /**
     * @if English
     * Recording studio
     * @endif
     * @if Chinese
     * 录音棚。
     * @endif
     */
    kNERtcVoiceBeautifierRecordingStudio,
    /**
     * @if English
     * Nature
     * @endif
     * @if Chinese
     * 天籁。
     * @endif
     */
    kNERtcVoiceBeautifierNature,
    /**
     * @if English
     * KTV
     * @endif
     * @if Chinese
     * KTV。
     * @endif
     */
    kNERtcVoiceBeautifierKTV,
    /**
     * @if English
     * Remote
     * @endif
     * @if Chinese
     * 悠远。
     * @endif
     */
    kNERtcVoiceBeautifierRemote,
    /**
     * @if English
     * Church
     * @endif
     * @if Chinese
     * 教堂。
     * @endif
     */
    kNERtcVoiceBeautifierChurch,
    /**
     * @if English
     * Bedroom
     * @endif
     * @if Chinese
     * 卧室。
     * @endif
     */
    kNERtcVoiceBeautifierBedroom,
    /**
     * @if English
     * Live
     * @endif
     * @if Chinese
     * Live。
     * @endif
     */
    kNERtcVoiceBeautifierLive
};

#pragma mark -- RECORD ENUM

/**
 * @if English
 * The cloud recording mode that records streams published from the local client.
 * @endif
 * @if Chinese
 * 本端参与的云端录制模式。
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcRecordType) {
    /**
     * @if English
     * Composite and individual stream recording mode. In this mode, you can simultaneously record mixed streams and individual streams.
     * @endif
     * @if Chinese
     * 本端参与合流+单流录制。同时录制合流内容和单流内容。
     * @endif
     */
    kNERtcRecordTypeAll = 0,
    /**
     * @if English
     * Composite recording mode. In this mode, audio and video streams from room members are mixed into one audio and video stream.
     * @endif
     * @if Chinese
     * 本端参与合流录制模式。房间内参与合流录制的成员，其音视频流混合录制为一个音视频文件。
     * @endif
     */
    kNERtcRecordTypeMix = 1,
    /**
     * @if English
     * Individual recording mode. Members that participate in individual stream recording can record a separate audio and video stream. Each member has an independent audio and video file.
     * @endif
     * @if Chinese
     * 本端参与单流录制模式。房间内参与单流录制的成员，分开录制其音视频流，每位成员均有其对应的音视频文件。
     * @endif
     */
    kNERtcRecordTypeSingle = 2,
};

#pragma mark - AUDIO MIXING ENUM

/**
 * @if English
 * The status of the audio mixing task.
 * @endif
 * @if Chinese
 * 伴音任务状态。
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcAudioMixingState) {
    /**
     * @if English
     * The music file ends normally.
     * @endif
     * @if Chinese
     * 音乐文件正常结束播放。
     * @endif
     */
    kNERtcAudioMixingStateFinished = 0,
    /**
     * @if English
     * The playback of the music file fails.
     * @endif
     * @if Chinese
     * 音乐文件播放失败。
     * @endif
     */
    kNERtcAudioMixingStateFailed,
};

/**
 * @if English
 * Mixing audio error code.
 * @endif
 * @if Chinese
 * 伴音错误码。
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcAudioMixingErrorCode) {
    /**
     * @if English
     * Normal mixing audio .
     * @endif
     * @if Chinese
     * 伴音正常。
     * @endif
     */
    kNERtcAudioMixingErrorOK        = 0 ,
    /**
     * @if English
     * A fatal error occurs.
     * @endif
     * @if Chinese
     * 伴音出现严重错误。
     * @endif
     */
    kNERtcAudioMixingErrorFatal         ,
    /**
     * @if English
     * The mixing audio file cannot be opened normally.
     * @endif
     * @if Chinese
     * 伴音不能正常打开。
     * @endif
     */
    kNERtcAudioMixingErrorCanNotOpen    ,
    /**
     * @if English
     * Audio decoding error.
     * @endif
     * @if Chinese
     * 音频解码错误。
     * @endif
     */
    kNERtcAudioMixingErrorDecode        ,
    /**
     * @if English
     * Operation interruption code.
     * @endif
     * @if Chinese
     * 操作中断码。
     * @endif
     */
    kNERtcAudioMixingErrorInterrupt     ,
    /**
     * @if English
     * 404 file not found, only for http/https.
     * @endif
     * @if Chinese
     * 404 file not found，only for http/https。
     * @endif
     */
    kNERtcAudioMixingErrorHttpNotFound  ,
    /**
     * @if English
     * Fails to open stream/file.
     * @endif
     * @if Chinese
     * 打开流/文件失败。
     * @endif
     */
    kNERtcAudioMixingErrorOpen          ,
    /**
     * @if English
     * Fails to retrieve decoding information/timeout.
     * @endif
     * @if Chinese
     * 获取解码信息失败/超时。
     * @endif
     */
    kNERtcAudioMixingErrorNInfo         ,
    /**
     * @if English
     * No audio stream.
     * @endif
     * @if Chinese
     * 无音频流。
     * @endif
     */
    kNERtcAudioMixingErrorNStream       ,
    /**
     * @if English
     * No decoder.
     * @endif
     * @if Chinese
     * 无解码器。
     * @endif
     */
    kNERtcAudioMixingErrorNCodec        ,
    /**
     * @if English
     * No memory.
     * @endif
     * @if Chinese
     * 无内存。
     * @endif
     */
    kNERtcAudioMixingErrorNMem          ,
    /**
     * @if English
     * Decoder fails to open/timed out.
     * @endif
     * @if Chinese
     * 解码器打开失败/超时。
     * @endif
     */
    kNERtcAudioMixingErrorCodecOpen     ,
    /**
     * @if English
     * Invalid audio parameters (channels and sample rate).
     * @endif
     * @if Chinese
     * 无效音频参数（声道、采样率）。
     * @endif
     */
    kNERtcAudioMixingErrorInvalidInfo   ,
    /**
     * @if English
     * Opening stream/file timeout.
     * @endif
     * @if Chinese
     * 打开流/文件超时。
     * @endif
     */
    kNERtcAudioMixingErrorOpenTimeout   ,
    /**
     * @if English
     * Network I/O timeout.
     * @endif
     * @if Chinese
     * 网络io超时。
     * @endif
     */
    kNERtcAudioMixingErrorIoTimeout     ,
    /**
     * @if English
     * Network I/O error.
     * @endif
     * @if Chinese
     * 网络io错误。
     * @endif
     */
    kNERtcAudioMixingErrorIo            ,
};


#pragma mark -- Network Status ENUM
/**
 * @if English
 * Type of network connection.
 * @endif
 * @if Chinese
 * 网络连接的类型。
 * @endif
 */
typedef NS_ENUM(NSInteger, NERtcNetworkConnectionType) {
    /**
     * @if English
     * Not detected.
     * @endif
     * @if Chinese
     * 未检测到。
     * @endif
     */
    kNERtcNetworkConnectionTypeNone,
    /**
     * @if English
     * Unknown.
     * @endif
     * @if Chinese
     * 无法确定。
     * @endif
     */
    kNERtcNetworkConnectionTypeUnknown,
    /**
     * @if English
     * 2G.
     * @endif
     * @if Chinese
     * 2G。
     * @endif
     */
    kNERtcNetworkConnectionType2G,
    /**
     * @if English
     * 3G.
     * @endif
     * @if Chinese
     * 3G。
     * @endif
     */
    kNERtcNetworkConnectionType3G,
    /**
     * @if English
     * 4G.
     * @endif
     * @if Chinese
     * 4G。
     * @endif
     */
    kNERtcNetworkConnectionType4G,
    /**
     * @if English
     * 5G.
     * @endif
     * @if Chinese
     * 5G。
     * @endif
     */
    kNERtcNetworkConnectionType5G,
    /**
     * @if English
     * WiFi.
     * @endif
     * @if Chinese
     * WiFi。
     * @endif
     */
    kNERtcNetworkConnectionTypeWiFi,
    /**
     * @if English
     * The ISP network, but the ISP cannot be identified.
     * @endif
     * @if Chinese
     * 运营商网络，但是无法确定运营商。
     * @endif
     */
    kNERtcNetworkConnectionTypeWWAN,
};


#pragma mark -- Live Stream
/**
 * @if English
 * Live streaming audio sample rate.
 * @endif
 * @if Chinese
 * 直播推流音频采样率。
 * @endif
 */
typedef NS_ENUM(NSInteger, NERtcLiveStreamAudioSampleRate) {
    /**
     * @if English
     * 32K
     * @endif
     * @if Chinese
     * 32K。
     * @endif
     */
    kNERtcLiveStreamAudioSampleRate32000 = 32000,
    /**
     * @if English
     * 44.1K
     * @endif
     * @if Chinese
     * 44.1K。
     * @endif
     */
    kNERtcLiveStreamAudioSampleRate44100 = 44100,
    /**
     * @if English
     * 48K
     * @endif
     * @if Chinese
     * 48K。
     * @endif
     */
    kNERtcLiveStreamAudioSampleRate48000 = 48000,
};

/**
 * @if English
 * Live streaming audio codec profile.
 * @endif
 * @if Chinese
 * 直播推流音频编码规格。
 * @endif
 */
typedef NS_ENUM(NSInteger, NERtcLiveStreamAudioCodecProfile) {
    /**
     * @if English
     * NERtcLiveStreamAudioCodecProfileLCAAC: LC-AAC, basic audio codec
     * @endif
     * @if Chinese
     * NERtcLiveStreamAudioCodecProfileLCAAC: LC-AAC 规格，表示基本音频编码规格。
     * @endif
     */
    kNERtcLiveStreamAudioCodecProfileLCAAC = 0,
    /**
     * @if English
     * NERtcLiveStreamAudioCodecProfileHEAAC: HE-AAC, high-efficiency audio codec
     * @endif
     * @if Chinese
     * NERtcLiveStreamAudioCodecProfileHEAAC: HE-AAC 规格，表示高效音频编码规格。
     * @endif
     */
    kNERtcLiveStreamAudioCodecProfileHEAAC = 1,
};

/**
 * @if English
 * Streaming mode in live streaming.
 * @endif
 * @if Chinese
 * 直播推流模式。
 * @endif
 */
typedef NS_ENUM(NSInteger, NERtcLiveStreamMode) {
    /**
     * @if English
     * (Default) stream audio and video.
     * @endif
     * @if Chinese
     * （默认）推流音视频。
     * @endif
     */
    kNERtcLsModeVideo = 0,
    /**
     * @if English
     * Stream audio.
     * @endif
     * @if Chinese
     * 推流纯音频。
     * @endif
     */
    kNERtcLsModeAudio,
};

/**
 * @if English
 * Scale mode in live streaming.
 * @endif
 * @if Chinese
 * 直播推流模式。
 * @endif
 */
typedef NS_ENUM(NSInteger, NERtcLiveStreamVideoScaleMode) {
    /**
     * @if English
     * Adaptive to the video, the video size is scaled proportionally. Give priority to ensuring that all video content is displayed. If the video size does not match the display window size, the unfilled area of the window will be filled with the background color.
     * @endif
     * @if Chinese
     * 适应视频，视频尺寸等比缩放。优先保证视频内容全部显示。若视频尺寸与显示视窗尺寸不一致，视窗未被填满的区域填充背景色。
     * @endif
     */
    kNERtcLsModeVideoScaleFit = 0,
    /**
     * @if English
     * (default) Adaptive to the area, the video size is scaled proportionally. Make sure that all areas are filled, and the extra part of the video will be cropped.
     * @endif
     * @if Chinese
     * （默认）适应区域，视频尺寸等比缩放。保证所有区域被填满，视频超出部分会被裁剪。
     * @endif
     */
    kNERtcLsModeVideoScaleCropFill ,
};

/**
 * @if English
 * Live streaming status code.
 * @endif
 * @if Chinese
 * 直播推流状态。
 * @endif
 */
typedef NS_ENUM(NSInteger, NERtcLiveStreamStateCode) {
    /**
     * @if English
     * Publishing streams
     * @endif
     * @if Chinese
     * 推流中。
     * @endif
     */
    kNERtcLsStatePushing = 505,
    /**
     * @if English
     * Fails to publish streams in Interactive Live Streaming
     * @endif
     * @if Chinese
     * 互动直播推流失败。
     * @endif
     */
    kNERtcLsStatePushFail = 506,
    /**
     * @if English
     * Streaming ends
     * @endif
     * @if Chinese
     * 推流结束。
     * @endif
     */
    kNERtcLsStatePushStopped = 511,
};

#pragma mark -- Audio Frame Observer
/**
 * @if English
 * Audio type
 * - kNERtcAudioTypePCM16: PCM16.
 * @endif
 * @if Chinese
 * 音频类型
 * - kNERtcAudioTypePCM16: PCM16
 * @endif
 */
typedef NS_ENUM(NSInteger, NERtcAudioType) {
    /**
     * @if English
     * PCM 16.
     * @endif
     * @if Chinese
     * PCM 16。
     * @endif
     */
    kNERtcAudioTypePCM16 = 0 ,
};

/**
 * @if English
 * Audio data read and write mode
 * @endif
 * @if Chinese
 * 音频数据读写模式
 * @endif
 */
typedef NS_ENUM(NSInteger, NERtcAudioFrameOpMode) {
    /**
     * @if English
     * Read-only mode. The user only retrieves the original audio data from AudioFrame. For example, if the user collects data through the SDK and publishes RTMP/RTMPS streams, this mode can be selected.
     * @endif
     * @if Chinese
     * 只读模式。用户仅从 AudioFrame 获取原始音频数据。例如，如用户通过 SDK 采集数据，自己进行 RTMP/RTMPS 推流，则可以选择该模式。
     * @endif
     */
    kNERtcAudioFrameOpModeReadOnly    = 0 ,
    /**
     * @if English
     * Read and write mode. The user obtains and modifies the data from AudioFrame, and returns the data to the SDK for encoding and transmission. For example, if the user has a sound effect processing module and wants to pre-process the data based on the requirements such as voice change, you can select this mode.
     * @endif
     * @if Chinese
     * 读写模式。用户从 AudioFrame 获取并修改数据，并返回给 SDK 进行编码传输。例如，如用户自己有音效处理模块，且想要根据实际需要对数据进行前处理 （例如变声），则可以选择该模式。
     * @endif
     */
    kNERtcAudioFrameOpModeReadWrite   = 1 ,
};

#pragma mark -- Device type
/**
 * @if English
 * Audio device type
 * @endif
 * @if Chinese
 * 音频设备类型。
 * @endif
 */
typedef NS_ENUM(int, NERtcAudioDeviceType) {
    /**
     * @if English
     * Unknown device
     * @endif
     * @if Chinese
     * 未知设备。
     * @endif
     */
    kNERtcAudioDeviceTypeUnknown = 0,
    /**
     * @if English
     * Audio capture device
     * @endif
     * @if Chinese
     * 音频采集设备。
     * @endif
     */
    kNERtcAudioDeviceTypeRecord,
    /**
     * @if English
     * Audio playback device
     * @endif
     * @if Chinese
     * 音频播放设备。
     * @endif
     */
    kNERtcAudioDeviceTypePlayout,
};

/**
 * @if English
 * Video device type
 * @endif
 * @if Chinese
 * 视频设备类型。
 * @endif
 */
typedef NS_ENUM(int, NERtcVideoDeviceType) {
    /**
     * @if English
     * Unknown video device.
     * @endif
     * @if Chinese
     * 未知视频设备。
     * @endif
     */
    kNERtcVideoDeviceTypeUnknown = 0,
    /**
     * @if English
     * Video capture device
     * @endif
     * @if Chinese
     * 视频采集设备。
     * @endif
     */
    kNERtcVideoDeviceTypeCapture,
};

#pragma mark -- Device state
/**
 * @if English
 * Audio device state
 * @endif
 * @if Chinese
 * 音频设备状态。
 * @endif
 */
typedef NS_ENUM(int, NERtcAudioDeviceState) {
    /**
     * @if English
     * The audio device is initialized.
     * @endif
     * @if Chinese
     * 已初始化。
     * @endif
     */
    kNERtcAudioDeviceStateInitialized = 0,
    /**
     * @if English
     * The audio device is started.
     * @endif
     * @if Chinese
     * 已启动。
     * @endif
     */
    kNERtcAudioDeviceStateStarted,
    /**
     * @if English
     * The audio device is stopped.
     * @endif
     * @if Chinese
     * 已停止。
     * @endif
     */
    kNERtcAudioDeviceStateStoped,
    /**
     * @if English
     * The audio device is uninitialized.
     * @endif
     * @if Chinese
     * 反初始化。
     * @endif
     */
    kNERtcAudioDeviceStateUnInitialized,
};

/**
 * @if English
 * The video device status is unlimited, and the SDK has full control over the Audio Session.
 * @endif
 * @if Chinese
 * 视频设备状态无限制，SDK 可以完全控制 Audio Session。
 * @endif
 */
typedef NS_ENUM(int, NERtcVideoDeviceState) {
    /**
     * @if English
     * The video device is initialized.
     * @endif
     * @if Chinese
     * 已初始化。
     * @endif
     */
    kNERtcVideoDeviceStateInitialized = 0,
    /**
     * @if English
     * The video device is started.
     * @endif
     * @if Chinese
     * 已启动。
     * @endif
     */
    kNERtcVideoDeviceStateStarted,
    /**
     * @if English
     * The video device is stopped.
     * @endif
     * @if Chinese
     * 已停止。
     * @endif
     */
    kNERtcVideoDeviceStateStoped,
    /**
     * @if English
     * The video device is uninitialized.
     * @endif
     * @if Chinese
     * 反初始化。
     * @endif
     */
    kNERtcVideoDeviceStateUnInitialized,
};


/**
 * @if English
 * @enum NERtcNetworkQuality Network quality type.
 * @endif
 * @if Chinese
 * @enum NERtcNetworkQuality 网络质量类型。
 * @endif
 */
typedef NS_ENUM(int, NERtcNetworkQuality) {
    /**
     * @if English
     * Unknown network quality
     * @endif
     * @if Chinese
     * 网络质量未知。
     * @endif
     */
    kNERtcNetworkQualityUnknown = 0,
    /**
     * @if English
     * Excellent network quality
     * @endif
     * @if Chinese
     * 网络质量极好。
     * @endif
     */
    kNERtcNetworkQualityExcellent,
    /**
     * @if English
     * Good network quality is close to excellent but has the bitrate is lower an excellent network.
     * @endif
     * @if Chinese
     * 用户主观感觉和 `excellent` 差不多，但码率可能略低于 `excellent`。
     * @endif
     */
    kNERtcNetworkQualityGood,
    /**
     * @if English
     * Poor network does not affect communication
     * @endif
     * @if Chinese
     * 用户主观感受有瑕疵但不影响沟通。
     * @endif
     */
    kNERtcNetworkQualityPoor,
    /**
     * @if English
     * Users can communicate with each other without smoothness.
     * @endif
     * @if Chinese
     * 勉强能沟通但不顺畅。
     * @endif
     */
    kNERtcNetworkQualityBad,
    /**
     * @if English
     * The network quality is very poor. Users can hardly get connected.
     * @endif
     * @if Chinese
     * 网络质量非常差，基本不能沟通。
     * @endif
     */
    kNERtcNetworkQualityVeryBad,
    /**
     * @if English
     * Users are unable to communicate with each other.
     * @endif
     * @if Chinese
     * 完全无法沟通。
     * @endif
     */
    kNERtcNetworkQualityDown,
};

/**
 * @if English
 * State during media stream relay.
 * @endif
 * @if Chinese
 * 媒体流转发状态
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcChannelMediaRelayState) {
    /**
     * @if English
     * Initial state. After successfully calling stopChannelMediaRelay to stop the media stream forwarding across rooms, onNERtcEngineChannelMediaRelayStateDidChange will call back this state.
     * @endif
     * @if Chinese
     * 初始状态。在成功调用 stopChannelMediaRelay 停止跨房间媒体流转发后， onNERtcEngineChannelMediaRelayStateDidChange 会回调该状态。
     * @endif
     */
    NERtcChannelMediaRelayStateIdle = 0,
    /**
     * @if English
     * The SDK tries to relay media streams across rooms.
     * @endif
     * @if Chinese
     * SDK 尝试跨房间转发媒体流。
     * @endif
     */
    NERtcChannelMediaRelayStateConnecting = 1,
    /**
     * @if English
     * The host in the source room successfully joined the destination room.
     * @endif
     * @if Chinese
     * 源房间主播角色成功加入目标房间。
     * @endif
     */
    NERtcChannelMediaRelayStateRunning = 2,
    /**
     * @if English
     * An exception occurs. For more information about error messages, see onNERtcEngineDidReceiveChannelMediaRelayEvent.
     * @endif
     * @if Chinese
     * 发生异常，详见 onNERtcEngineDidReceiveChannelMediaRelayEvent 的 error 中提示的错误信息。
     * @endif
     */
    NERtcChannelMediaRelayStateFailure = 3,
};

/**
 * @if English
 * Events related to the media stream relay.
 * @endif
 * @if Chinese
 * 媒体流转发回调事件
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcChannelMediaRelayEvent) {
    /**
     * @if English
     * Stops media stream relay across rooms.
     * @endif
     * @if Chinese
     * 媒体流转发停止。
     * @endif
     */
    NERtcChannelMediaRelayEventDisconnect = 0,
    /**
     * @if English
     * The SDK is connecting to the server and is trying to relay the media stream.
     * @endif
     * @if Chinese
     * SDK 正在连接服务器，开始尝试转发媒体流。
     * @endif
     */
    NERtcChannelMediaRelayEventConnecting = 1,
    /**
     * @if English
     * The SDK has connected to the server successfully.
     * @endif
     * @if Chinese
     * 连接服务器成功。
     * @endif
     */
    NERtcChannelMediaRelayEventConnected = 2,
    /**
     * @if English
     * The video stream is relayed to the destination room.
     * @endif
     * @if Chinese
     * 视频媒体流成功转发到目标房间。
     * @endif
     */
    NERtcChannelMediaRelayEventVideoSentToDestChannelSuccess = 3,
    /**
     * @if English
     * The audio stream is relayed to the destination room.
     * @endif
     * @if Chinese
     * 音频媒体流成功转发到目标房间。
     * @endif
     */
    NERtcChannelMediaRelayEventAudioSentToDestChannelSuccess = 4,
    /**
     * @if English
     * Other media streams such as screen sharing are relayed to the destination room.
     * @endif
     * @if Chinese
     * 屏幕共享等其他媒体流成功转发到目标房间。
     * @endif
     */
    NERtcChannelMediaRelayEventOtherStreamSentToDestChannelSuccess = 5,
    /**
     * @if English
     * Fails to relay media streams. Reasons:
     * - kNERtcErrChannelReserveErrorParam(414): Invalid request parameters.
     * - kNERtcErrChannelMediaRelayInvalidState(30110): Repeatedly call startChannelMediaRelay.
     * - kNERtcErrChannelMediaRelayPermissionDenied(30111): No permissions to relay the media stream. For example, media stream relay is not allowed if the host calls startChannelMediaRelay, or the room hosts for one-to-one calls.
     * - kNERtcErrChannelMediaRelayStopFailed(30112): startChannelMediaRelay is not called before stopChannelMediaRelay.
     * @endif
     * @if Chinese
     * 媒体流转发失败。原因包括：
     * - kNERtcErrChannelReserveErrorParam(414)：请求参数错误。
     * - kNERtcErrChannelMediaRelayInvalidState(30110)：重复调用 startChannelMediaRelay。
     * - kNERtcErrChannelMediaRelayPermissionDenied(30111)：媒体流转发权限不足。例如调用 startChannelMediaRelay 的房间成员为主播角色、或房间为双人通话房间，不支持转发媒体流。
     * - kNERtcErrChannelMediaRelayStopFailed(30112)：调用 stopChannelMediaRelay 前，未调用 startChannelMediaRelay。
     * @endif
     */
    NERtcChannelMediaRelayEventFailure = 100,
};

/**
 * @if English
 * Encryption mode
 * @endif
 * @if Chinese
 * 加密模式
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcEncryptionMode) {
    /**
     * @if English
     * 128-bit SM4 encryption, ECB mode.
     * @endif
     * @if Chinese
     * 128 位 SM4 加密，ECB 模式。
     * @endif
     */
    NERtcEncryptionModeGMCryptoSM4ECB,
  
    /**
     * @if English
     * custom encryption mode.
     * @endif
     * @if Chinese
     * 自定义加密模式。
     * @endif
     */
    NERtcEncryptionModeCustom,
};

#pragma mark - last mile probe test
/**
 * @if English
 * States of the last-mile network probe test.
 * @endif
 * @if Chinese
 * Last mile 质量探测结果的状态。
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcLastmileProbeResultState) {
    /**
     * @if English
     * The last-mile network probe test is complete.
     * @endif
     * @if Chinese
     * 表示本次 last mile 质量探测的结果是完整的
     * @endif
     */
    kNERtcLastmileProbeResultComplete = 1,
    /**
     * @if English
     * The last-mile network probe test is incomplete and the bandwidth estimation is not available, probably due to limited test resources.
     * @endif
     * @if Chinese
     * 表示本次 last mile 质量探测未进行带宽预测，因此结果不完整。一个可能的原因是测试资源暂时受限
     * @endif
     */
    kNERtcLastmileProbeResultIncompleteNoBwe = 2,
    /**
     * @if English
     * The last-mile network probe test is not carried out, probably due to poor network conditions.
     * @endif
     * @if Chinese
     * 未进行 last mile 质量探测。一个可能的原因是网络连接中断
     * @endif
     */
    kNERtcLastmileProbeResultUnavailable = 3,
};

#pragma mark - Cloud Proxy

/**
 * @if English
 * Cloud proxy type.
 * @endif
 * @if Chinese
 * 云代理模式。
 * @endif
 */
typedef NS_ENUM(NSUInteger, NERtcTransportType) {
    /**
     * @if English
     * 0: Do not use the cloud proxy.
     * @endif
     * @if Chinese
     * 0：关闭已设置的云代理。
     * @endif
     */
    NERtcTransportTypeNoneProxy = 0,
    /**
     * @if English
     * 1: Sets the cloud proxy for the UDP protocol.
     * @endif
     * @if Chinese
     * 1: 开启 UDP 协议的云代理。
     * @endif
     */
    NERtcTransportTypeUDPProxy
};

#pragma mark -- decoder & encoder

typedef NS_ENUM(NSInteger, NERtcNalFrameType) {
    /**
     * H.264 IDR 帧
     */
    kNERtcNalFrameTypeIDR = 1,

    /**
     * I 帧
     */
    kNERtcNalFrameTypeI = 2,

    /**
     * P 帧
     */
    kNERtcNalFrameTypeP = 3,
};

typedef NS_ENUM(int, NERtcPayLoadType) {
    kNERtcPayLoadTypeOPUS = 111,
};

#pragma mark -- Log
/**
 * @if English
 * Log level
 * @endif
 * @if Chinese
 * 日志级别。
 * @endif
 */
typedef NS_ENUM(NSInteger, NERtcLogLevel) {
    /**
     * @if English
     * Fatal level log information.
     * @endif
     * @if Chinese
     * Fatal 级别日志信息。
     * @endif
     */
    kNERtcLogLevelFatal         = 0,
    /**
     * @if English
     * Error level log information.
     * @endif
     * @if Chinese
     * Error 级别日志信息。
     * @endif
     */
    kNERtcLogLevelError         = 1,
    /**
     * @if English
     * Warning level log information. The default level.
     * @endif
     * @if Chinese
     * Warning 级别日志信息。默认级别。
     * @endif
     */
    kNERtcLogLevelWarning       = 2,
    /**
     * @if English
     * Info level log information.
     * @endif
     * @if Chinese
     * Info 级别日志信息。
     * @endif
     */
    kNERtcLogLevelInfo          = 3,
    /**
     * @if English
     * Detail Info level log information.
     * @endif
     * @if Chinese
     * Detail Info 级别日志信息。
     * @endif
     */
    kNERtcLogLevelDetailInfo    = 4,
    /**
     * @if English
     * Debug level log information.
     * @endif
     * @if Chinese
     * Debug 级别日志信息。
     * @endif
     */
    kNERtcLogLevelDebug         = 5,
    /**
     * @if English
     * Verbose level log information.
     * @endif
     * @if Chinese
     * Verbose 级别日志信息。
     * @endif
     */
    kNERtcLogLevelVerbose       = 6,
    /**
     * @if English
     * Turn off log printing.
     * @endif
     * @if Chinese
     * 关闭日志打印。
     * @endif
     */
    kNERtcLogLevelOff           = 7,
};

#pragma mark - area

typedef NS_ENUM(int, NERtcAreaCodeType) {
    /**
     * 未指定
     */
    kNERtcAreaCodeTypeDefault = 0x00,
    /**
     * 中国大陆
     */
    kNERtcAreaCodeTypeCN = 0x01,
    /**
     * 海外通用
     */
    kNERtcAreaCodeTypeOverseaDefault = 0x02,
    
};

NS_ASSUME_NONNULL_END

