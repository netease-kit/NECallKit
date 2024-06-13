/*
 * Copyright (c) 2021 NetEase, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "NERtcEngineEnum.h"

@protocol NERtcEngineVideoRenderSink;
@protocol NERtcEnginePacketObserver;

NS_ASSUME_NONNULL_BEGIN

/**
 * @if English
 * The following keys are used in INERtcEngine::setParameters.
 * @endif
 * @if Chinese
 * 以下 key 用于 INERtcEngine::setParameters
 * @endif
 */

// channel
/**
 * @if English
 * BOOL -- Specifies whether to enable 1V1 mode. The default value is NO.
 * @endif
 * @if Chinese
 * 是否开启双人通话模式。适用于 1v1 通话场景。
 * <br>布尔值，默认为 NO，即关闭状态。
 * @note 
 * - 开启了双人通话模式的客户端创建并加入房间时，该房间会成为一个双人通话房间，只允许同样开启了双通话模式的客户端加入。
 * - 请在加入房间前设置。
 * @endif
 */
NERTC_EXTERN_API NSString * const kNERtcKeyChannel1V1ModeEnabled;

// video
/**
 * @if English
 *  BOOL - Specifies whether to prefer using hardware to encode video data. The default value is YES. We recommend that you set this value before you call setupEngineWithContext to initialize the INERtcEngine instance. Otherwise, the setting is applied the next time.
 * @endif
 * @if Chinese
 * 是否优先使用硬件编码视频数据。
 * <br>布尔值，默认值 YES。
 * <br>请在初始化（setupEngineWithContext）之前设置该参数，否则该参数会在下次初始化之后生效。
 * @endif
 */
NERTC_EXTERN_API NSString * const kNERtcKeyVideoPreferHWEncode;
/**
 * @if English
 *  BOOL - Specifies whether to prefer using hardware to decode video data. The default value is YES. We recommend that you set this value before you call setupEngineWithContext to initialize the INERtcEngine instance. Otherwise, the setting is applied the next time.
 * @endif
 * @if Chinese
 * 是否优先使用硬件解码视频数据。
 * <br>布尔值，默认值 YES。
 * <br>请在初始化（setupEngineWithContext）之前设置该参数，否则该参数会在下次初始化之后生效。
 * @endif
 */
NERTC_EXTERN_API NSString * const kNERtcKeyVideoPreferHWDecode;
/**
 * @if English
 *  BOOL - Specifies whether to enable the callback to return captured video data. This enables developers to get the raw video data. You can clear the video data by calling destroyEngine. The default value is NO.
 * @endif
 * @if Chinese
 * 是否需要开启视频数据采集回调，开启后开发者可以获取到原始视频数据。
 * <br>布尔值，默认值 NO。
 * <br>开启后如果需要关闭，需要通过调用 destroyEngine 来清除。
 * @endif
 */
NERTC_EXTERN_API NSString * const kNERtcKeyVideoCaptureObserverEnabled;
/**
 * @if English
 *  BOOL - Specifies whether to turn on the rear camera if the camera is enabled for the first time. The default value is NO.
 * @endif
 * @if Chinese
 * 第一次开启摄像头时，是否使用后摄像头。
 * <br>布尔值，默认值 NO，即不使用后置摄像头。
 * @endif
 */
NERTC_EXTERN_API NSString * const kNERtcKeyVideoStartWithBackCamera;
/**
 * @if English
 *  BOOL - Specifies whether to use metal rendering first. Otherwise, OpenGL rendering is applied. The default value is NO.
 * @endif
 * @if Chinese
 * 是否优先使用 Metal 渲染。
 * <br>布尔值，默认值 NO，即使用OpenGL 渲染。
 * @endif
 */
NERTC_EXTERN_API NSString * const kNERtcKeyVideoPreferMetalRender;
/**
 * @if English
 *  int, the setting is valid before you make a call. The default value is 3, which indicates that a mainstream is published at the beginning.
 * @endif
 * @if Chinese
 * 通话开始时，默认发送的流类型，通话前设置有效。 
 * <br>int 类型，默认为 3，即大流。详细信息请参考 NERtcVideoPubMode。
 * @endif
 */
NERTC_EXTERN_API NSString * const kNERtcKeyVideoSendOnPubType;

/**
 * @if English
 *  BOOL - Specifies whether to automatically subscribe to video streams when other users turn on video. The setting is applied before you make a call. The setting is invalid if you specify the value during the call. The default value is NO.
 * @endif
 * @if Chinese
 * 是否自动订阅其他用户的视频流。
 * <br>布尔值，默认值 NO，即不自动订阅。
 * @note 请在加入房间前设置该参数，通话中设置无效。 
 * @endif
 */
NERTC_EXTERN_API NSString * const kNERtcKeyAutoSubscribeVideo;    // BOOL -- 其他用户打开视频时，自动订阅。只支持在通话前设置，通话中设置无效。 默认值 NO 。

// audio
/**
 * @if English
 *  BOOL - Specifies whether to automatically subscribe to audio streams when other users turn on audio. The setting is applied before you make a call. The setting is invalid If you specify the value during the call. The default value is YES. Note: The key of subscribeRemoteAudio must be set to NO if you use the method to control the audio in your business.
 * @endif
 * @if Chinese
 * 是否自动订阅其他用户的音频流。
 * <br>布尔值，默认为 YES，即自动订阅。
 * @note 
 * - 请在加入房间前设置该参数，通话中设置无效。 
 * - 如果业务场景中使用 subscribeRemoteAudio 控制音频订阅，则该 Key 必须设置为 NO。
 * @endif
 */
NERTC_EXTERN_API NSString * const kNERtcKeyAutoSubscribeAudio;

// data channel
/**
 * @if English
 *  BOOL - Specifies whether to automatically subscribe to data channel when other users turn on data channel. The setting is applied before you make a call. The setting is invalid If you specify the value during the call. The default value is NO. Note: The key of subscribeRemoteData must be set to NO if you use the method to control the data in your business.
 * @endif
 * @if Chinese
 * 是否自动订阅其他用户的数据通道。
 * <br>布尔值，默认为 NO，即非自动订阅。
 * @note
 * - 请在加入房间前设置该参数，通话中设置无效。
 * - 如果业务场景中使用 subscribeData 控制数据订阅，则该 Key 必须设置为 NO。
 * @endif
 */
NERTC_EXTERN_API NSString * const kNERtcKeyAutoSubscribeData;

/**
 * @if English
 * BOOL -- Specifies whether to disable switching to the speakerphone when the system switches to the earpieces. The default value is NO. If the value is set to YES, the SDK is not allowed to switch to the speakerphone when the system switches to earpieces. Users need to handle the earpieces switching event.
 * @endif
 * @if Chinese
 * 当系统切换听筒或扬声器时，SDK 是否以系统设置为准。
 * <br>布尔值，默认为 NO。 
 * - YES： 以系统设置为准。例如当系统切换为听筒时，应用的音频播放则自动转为听筒，开发者需要自行处理该切换事件。
 * - NO： 以 SDK 设置为准，SDK 不允许用户通过系统变更音频播放路由为听筒或扬声器。例如当 SDK 设置为扬声器时，即使系统切换为听筒模式，SDK 也会自动将系统修改回扬声器模式。
 * @endif
 */
NERTC_EXTERN_API NSString * const KNERtcKeyDisableOverrideSpeakerOnReceiver;

/**
 * 是否需要支持 Callkit 框架。
 * <br>布尔值，默认为 NO。
 * - YES： 需要支持，如果需要使用苹果 callkit 框架来实现发起通话，接听通话，需要设置 YES。
 * - NO： 不需要支持。
 */
NERTC_EXTERN_API NSString * const kNERtcKeySupportCallkit;

/**
 * @if English
 * Whether to return original volume when the local user is muted.  Boolean value, default: false. true：Return the original volume in `onLocalAudioVolumeIndication`. false：Return the recording volume(0) in `onLocalAudioVolumeIndication`. 
 * @endif
 * @if Chinese
 * 本地用户静音时是否返回原始音量。 布尔值，默认值为 false。
 * - true：返回 `onLocalAudioVolumeIndication` 中的原始音量。  
 * - false：返回 `onLocalAudioVolumeIndication` 中的录音音量，静音时为 0。
 * @note 请在加入房间前调用此接口。
 * @endif
 */
NERTC_EXTERN_API NSString * const KNERtcKeyEnableReportVolumeWhenMute;
/**
 * @if English
 * BOOL - Specifies whether to use echo reduction when the system sets the headset. The default value is NO. If the value is set to YES, the SDK does not use the echo reduction in headset mode. The setting affects the audio quality of the headset in some mobile models.
 * @endif
 * @if Chinese
 * 设置耳机时不使用软件回声消除功能，默认值 NO。如设置YES 则SDK在耳机模式下不使用软件回声消除功能，会对某些机型下 耳机的音质效果有影响
 * @endif
 */
NERTC_EXTERN_API NSString * const KNERtcKeyDisableSWAECOnHeadset;
/**
 * @if English
 * BOOL - Specifies whether to enable AI-powered noise reduction. If you enable AI-powered noise reduction, the peer can hear your voice in a noisy environment.
 * @endif
 * @if Chinese
 * 是否开启 AI 降噪。
 * <br>NERTC SDK 自研 AI 降噪算法，开启 AI 降噪之后，在嘈杂的环境中可以针对背景人声、键盘声等非稳态噪声进行定向降噪，同时也会提升对于环境稳态噪声的抑制，保留更纯粹的人声。
 * @endif
 */
NERTC_EXTERN_API NSString * const KNERtcKeyAudioAINSEnable;


// server record
/**
 * @if English
 *  BOOL - Specifies whether to record the audio of the host in the server. The default value is NO.
 * @endif
 * @if Chinese
 * 是否云端录制主讲人，默认值 NO
 * @endif
 */
NERTC_EXTERN_API NSString * const kNERtcKeyRecordHostEnabled;
/**
 * @if English
 *  BOOL - Specifies whether to enable the call server to record audio. The default value is NO
 * @endif
 * @if Chinese
 * 是否开启云端音频录制。默认值 NO，即关闭音频录制。
 * @endif
 */
NERTC_EXTERN_API NSString * const kNERtcKeyRecordAudioEnabled;
/**
 * @if English
 *  BOOL - Specifies whether to enable the call server to record video. The default value is NO
 * @endif
 * @if Chinese
 * 是否开启云端视频录制，默认值 NO，即关闭视频录制。
 * @endif
 */
NERTC_EXTERN_API NSString * const kNERtcKeyRecordVideoEnabled;
/**
 * @if English
 *  int - The server recording mode. For more information, see the definition of NERtcRecordType.
 * @endif
 * @if Chinese
 * 云端录制模式。详细信息请参考 NERtcRecordType。
 * @endif
 */
NERTC_EXTERN_API NSString * const kNERtcKeyRecordType;

// live stream
/**
 * @if English
 *  BOOL - Specifies whether to publish the media stream to CDN. The default value is YES.
 * @deprecated 
 * @endif
 * @if Chinese
 * 在旁路推流场景中，是否允许推送本地媒体流到 CDN。默认值 YES。
 * @deprecated 该参数已废弃。
 * @endif
 */
NERTC_EXTERN_API NSString * const kNERtcKeyPublishSelfStreamEnabled;

// log level
/**
 * @if English
 *  int - The SDK log level. For more information, see the definition of NERtcLogLevel. The default value is kNERtcLogLevelWarning.
 * @endif
 * @if Chinese
 * SDK 日志等级，默认为 kNERtcLogLevelInfo，详细信息请参考 NERtcLogLevel。
 * @endif
 */
NERTC_EXTERN_API NSString * const kNERtcKeyLogLevel;
/**
 * @if English
 * NSString - Identifies the app version that is used for reporting.
 * @endif
 * @if Chinese
 * Login 事件中的一个自定义字段，适用于标识一些额外信息，例如 App 版本。
 * @endif
 */
NERTC_EXTERN_API NSString * const kNERtcKeyExtraInfo;

/**
 * 是否关闭sdk 视频解码（默认不关闭），关闭后SDK 将不会解码远端视频，因此也无法渲染接收到的远端视频
 * <p>
 * note:需要在初始化前设置，释放SDK 后失效。一般配合 {@link INERtcEngineEx#setPreDecodeObserver:} 使用。
 * @since 4.6.25
 */
NERTC_EXTERN_API NSString * const kNERtcKeyDisableVideoDecoder;

/**
 * @if Chinese
 * 登录扩展参数，string，默认不设置。
 * @endif
 */
NERTC_EXTERN_API NSString * const kNERtcKeyLoginCustomData;


NERTC_EXTERN_API NSString * const kNERtcKeyDisableFirstJoinUserCreateChannel;

/**
 * @if English
 * Configures the video canvas.
 * @endif
 * @if Chinese
 * 视频画布设置。
 * @endif
 */
NERTC_EXPORT  @interface NERtcVideoCanvas : NSObject

/**
 * @if English
 * Specifies whether to use an external renderer. The default value is NO. If you want to use an external renderer, you can associate the renderer by calling externalVideoRender with the SDK. if not, you can associate the renderer based on the container with the SDK. Switching between the internal rendering and external rendering during a call is not supported.
 * @endif
 * @if Chinese
 * 是否使用外部渲染器，默认 NO 不使用，若使用SDK内部会根据externalVideoRender来进行绑定，若不使用SDK内部根据container来进行绑定。暂不支持在通话中切换内部渲染与外部渲染。
 * @endif
 */
@property (nonatomic, assign) BOOL useExternalRender;

/**
 * @if English
 * Video window container (SDK internal rendering)
 * @endif
 * @if Chinese
 * 视频窗口容器（SDK内部渲染）。
 * @endif
 */
@property (nonatomic, nullable, strong) VIEW_CLASS *container;

/**
 * @if English
 * Video rendering mode
 * @endif
 * @if Chinese
 * 视频渲染模式。
 * @endif
 */
@property (nonatomic, assign) NERtcVideoRenderScaleMode renderMode;

/**
 * @if English
 * Video mirror mode.
 * -Local view mirror mode: If you use the front camera, the local view mirror mode is enabled by default. If you use the rear camera, the local view mirror mode is disabled by default.
 * -Remote view mirror mode: By default, the remote view mirror mode is disabled.
 * @endif
 * @if Chinese
 * 视频镜像模式。
 * - 本地视图镜像模式：如果你使用前置摄像头，默认启动本地视图镜像模式；如果你使用后置摄像头，默认关闭本地视图镜像模式。
 * - 远端用户视图镜像模式：默认关闭远端用户的镜像模式。
 * @endif
 */
@property (nonatomic, assign) NERtcVideoMirrorMode mirrorMode;

/**
 * @if English
 * External renderer
 * @endif
 * @if Chinese
 * 外部渲染器。
 * @endif
 */
@property (nonatomic, strong) id<NERtcEngineVideoRenderSink> externalVideoRender;

// 背景颜色，格式为 0xRRGGBB，默认为黑色即 0x000000
@property (nonatomic, assign) uint32_t backgroundColor;

@end

/**
 * @if English
 * Local video basic publishing configuration
 * @endif
 * @if Chinese
 * 本地视频基础发送配置。
 * @endif
 */
NERTC_EXPORT  @interface NERtcBaseVideoEncodeConfiguration : NSObject

/**
 * @if English
 * Indicates the resolution of video encoding, used to measure encoding quality. For more information, see {@link NERtcVideoProfileType}.
 * @endif
 * @if Chinese
 * 视频编码的分辨率，用于衡量编码质量。详细信息请参考 {@link NERtcVideoProfileType}。
 * @endif
 */
@property (nonatomic, assign) NERtcVideoProfileType maxProfile;

/**
 * @if English
 * The frame rate of the video encoding. For more information, see {@link NERtcVideoFrameRate}.
 * - When you use the mainstream, the frame rate is determined based on maxProfile by default.
 * - maxProfile>= kNERtcVideoProfileStandard, frameRate = kNERtcVideoFrameRateFps30.
 * - maxProfile< kNERtcVideoProfileStandard, frameRate = kNERtcVideoFrameRateFps15.
 * - When you use the substream, frameRate is set to kNERtcVideoFrameRateFps7 by default. 
 * @endif
 * @if Chinese
 * 视频编码的帧率。详细信息请参考 {@link NERtcVideoFrameRate}。
 * - 使用主流时，默认根据设置的maxProfile决定帧率。
 * - maxProfile>= kNERtcVideoProfileStandard，frameRate = kNERtcVideoFrameRateFps30。
 * - maxProfile< kNERtcVideoProfileStandard，frameRate = kNERtcVideoFrameRateFps15。
 * - 使用辅流时，frameRate 默认为 kNERtcVideoFrameRateFps7。
 * @endif
 */
@property (nonatomic, assign) NERtcVideoFrameRate frameRate;

/**
 * @if English
 * The minimum frame rate for video encoding. The default value is 0, which indicates that the minimum frame rate is used by default.
 * @endif
 * @if Chinese
 * 视频编码的最小帧率。默认为 0，表示使用默认最小帧率。
 * @endif
 */
@property (nonatomic, assign) NSInteger minFrameRate;

/**
 * @if English
 * The bitrate of video encoding in kbps. You can manually set the required bitrate based on your business requirements.
 * - If the set video bit rate exceeds the reasonable range, the SDK will automatically process the bit rate according to the reasonable range.
 * - If the bitrate is set to 0, the SDK computes and processes automatically.
 * @endif
 * @if Chinese
 * 视频编码的码率，单位为 Kbps。
 * <br>您可以根据场景需要，手动设置想要的码率。详细码表请参考[设置视频属性](https://doc.yunxin.163.com/docs/jcyOTA0ODM/zcwMTY4MzM)。
 * - 若设置的视频码率超出合理范围，SDK 会自动按照合理区间处理码率。
 * - 若设置为 0，SDK将会自行计算处理。
 * 
 |**分辨率**|**帧率（fps）**|**通信场景码率(kbps)**|**直播场景码率(kbps)**|
 |:--|:--|:--|:--|
 |90 x 90|30|49|73|
 |90 x 90|15|32|48|
 |120 x 90|30|61|91|
 |120 x 90|15|40|60|
 |120 x 120|30|75|113|
 |120 x 120|15|50|75|
 |160 x 90|30|75|113|
 |160 x 90|15|50|75|
 |160 x 120|30|94|141|
 |160 x 120|15|62|93|
 |180 x 180|30|139|208|
 |180 x 180|15|91|137|
 |240 x 180|30|172|259|
 |240 x 180|15|113|170|
 |240 x 240|30|214|321|
 |240 x 240|15|141|212|
 |320 x 180|30|214|321|
 |320 x 180|15|141|212|
 |320 x 240|30|259|389|
 |320 x 240|15|175|263|
 |360 x 360|30|393|590|
 |360 x 360|15|259|389|
 |424 x 240|15|217|325|
 |480 x 360|30|488|732|
 |480 x 360|15|322|483|
 |480 x 480|30|606|909|
 |480 x 480|15|400|600|
 |640 x 360|30|606|909|
 |640 x 360|15|400|600|
 |640 x 480|30|752|1128|
 |640 x 480|15|496|744|
 |720 x 720|30|1113|1670|
 |720 x 720|15|734|1102|
 |848 x 480|30|929|1394|
 |720 x 720|15|613|919|
 |960 x 720|30|1382|2073|
 |960 x 720|15|911|1367|
 |1080 x 1080|30  |2046|3069|
 |1080 x 1080|15|1350|2025|
 |1280 x 720|30|1714|2572|
 |1280 x 720|15|1131|1697|
 |1440 x 1080|30|2538|3808|
 |1440 x 1080|15  |1675|2512|
 |1920 x 1080|30|3150|4725|
 |1920 x 1080|15|2078|3117|
 * @endif
 */
@property (nonatomic, assign) NSInteger bitrate;

/**
 * @if English
 * The minimum bitrate of video encoding in kbps. You can manually set the required minimum bitrate based on your business requirements. If the bitrate is set to 0, the SDK computes and processes automatically.
 * @endif
 * @if Chinese
 * 视频编码的最小码率，单位为 Kbps。您可以根据场景需要，手动设置想要的最小码率，若设置为0，SDK 将会自行计算处理。
 * @endif
 */
@property (nonatomic, assign) NSInteger minBitrate;

@end

/**
 * @if English 
 * The camera capturer configuration. 
 * @endif
 * @if Chinese
 * 摄像头采集配置。
 * @endif
 */
NERTC_EXPORT  @interface NERtcCameraCaptureConfiguration : NSObject

/**
 * @if English 
 * The width (px) of the video image captured by the local camera.
 * <br>The video encoding resolution is expressed in width x height. It is used to set the video encoding resolution and measure the encoding quality. 
 * - captureWidth: the pixels of the video frame on the horizontal axis, that is, the custom width.
 * - captureHeight： the pixels of the video frame on the horizontal axis, that is, the custom height.
 * @note 
 * - To customize the width of the video image, set preference as kNERtcCameraOutputManual first, and then use captureWidth and captureHeight.
 * - In manual mode, if the specified collection size is smaller than the encoding size, the encoding parameters will be aligned down to the collection size range. 
 * @endif
 * @if Chinese
 * 本地采集的视频宽度，单位为 px。
 * <br>视频编码分辨率以宽 x 高表示，用于设置视频编码分辨率，以衡量编码质量。
 * - captureWidth 表示视频帧在横轴上的像素，即自定义宽。
 * - captureHeight 表示视频帧在横轴上的像素，即自定义高。
 * @note 
 * - 如果您需要自定义本地采集的视频尺寸，请先将 preference 设为 kNERtcCameraOutputManual，再通过 captureWidth 和 captureHeight 设置采集的视频宽度。
 * - 手动模式下，如果指定的采集宽高小于编码宽高，编码参数会被下调对齐到采集的尺寸范围内。
 * @endif
 */
@property (nonatomic, assign) int captureWidth;
/**
 * @if English 
 * The height (px) of the video image captured by the local camera.
 * <br>The video encoding resolution is expressed in width x height. It is used to set the video encoding resolution and measure the encoding quality. 
 * - captureWidth: the pixels of the video frame on the horizontal axis, that is, the custom width.
 * - captureHeight： the pixels of the video frame on the horizontal axis, that is, the custom height.
 * @note 
 * - To customize the width of the video image, set preference as kNERtcCameraOutputManual first, and then use captureWidth and captureHeight.
 * - In manual mode, if the specified collection size is smaller than the encoding size, the encoding parameters will be aligned down to the collection size range. 
 * @endif
 * @if Chinese
 * 本地采集的视频高度，单位为 px。
 * <br>视频编码分辨率以宽 x 高表示，用于设置视频编码分辨率，以衡量编码质量。
 * - captureWidth 表示视频帧在横轴上的像素，即自定义宽。
 * - captureHeight 表示视频帧在横轴上的像素，即自定义高。
 * @note 
 * - 如果您需要自定义本地采集的视频尺寸，请先将 preference 设为 kNERtcCameraOutputManual，再通过 captureWidth 和 captureHeight 设置采集的视频宽度。
 * - 手动模式下，如果指定的采集宽高小于编码宽高，编码参数会被下调对齐到采集的尺寸范围内。
 * @endif
 */
@property (nonatomic, assign) int captureHeight;

@end
/**
 * @if English
 * Local video publishing configuration
 * @endif
 * @if Chinese
 * 本地视频发送配置
 * @endif
 */
NERTC_EXPORT  @interface NERtcVideoEncodeConfiguration : NERtcBaseVideoEncodeConfiguration

/**
 * @if English
 * Indicates the video encoding resolution, a measure of encoding quality, represented by width x height. You can select this profile or maxProfile.
 * <br>The width represents the pixels of the video frame on the horizontal axis. You can enter a custom width.
 * - If you set the value to a negative number, the maxProfile setting is used.
 * - If you need to customize the resolution, set this profile, and maxProfile becomes invalid.
 * If the custom width and height of the video input are invalid, the width and height are automatically scaled based on maxProfile.
 * @endif
 * @if Chinese
 * 视频编码分辨率，衡量编码质量，以宽x高表示。与maxProfile属性二选一。推荐优先使用自定义宽高设置。
 * <br>width表示视频帧在横轴上的像素，即自定义宽。
 * - 设置为负数时表示采用 maxProfile档位。
 * - 如果需要自定义分辨率场景，则设置此属性，maxProfile属性失效。
 * 自定义视频输入 width 和 height 无效，会自动根据 maxProfile缩放。
 * @endif
 */
@property (nonatomic, assign) int width;

/**
 * @if English
 * Video encoding resolution, a measure of encoding quality, represented by width x height. You can select this profile or maxProfile.
 * <br>The height represents the pixels of the video frame on the vertical axis. You can enter a custom height.
 * - If you set the value to a negative number, the maxProfile setting is used.
 * - If you need to customize the resolution, set this profile, and maxProfile becomes invalid.
 * If the custom width and height of the video input are invalid, the width and height are automatically scaled based on maxProfile.
 * @endif
 * @if Chinese
 * 视频编码分辨率，衡量编码质量，以宽x高表示。与maxProfile属性二选一。推荐优先使用自定义宽高设置。
 * <br>height表示视频帧在纵轴上的像素，即自定义高。
 * - 设置为负数时表示采用 maxProfile档位。
 * - 如果需要自定义分辨率场景，则设置此属性，maxProfile属性失效。
 * 自定义视频输入width和height无效，会自动根据 maxProfile缩放。
 * @endif
 */
@property (nonatomic, assign) int height;

/**
 * @if English
 * Video cropping mode. The default value is kNERtcVideoCropDefault. If you use a custom video input, the crop mode is not supported.
 * @endif
 * @if Chinese
 * 视频画面裁剪模式，默认为 kNERtcVideoCropDefault。自定义视频输入不支持设置裁剪模式。
 * @endif
 */
@property (nonatomic, assign) NERtcVideoCropMode cropMode;

/**
 * @if English
 * Video encoding degradation preference when the bandwidth is limited. For more information, see {@link NERtcDegradationPreference}.
 * - DEGRADATION_DEFAULT: (default) adjust the adaptation preference based on the scene mode.
 * - In communication scenarios, select DEGRADATION_BALANCED mode to maintain a balance between the encoding frame rate and video quality.
 * - In live streaming, select DEGRADATION_MAINTAIN_QUALITY mode and reduce the encoding frame rate to ensure video quality.
 * - DEGRADATION_MAINTAIN_FRAMERATE: Smoothness comes first. Reduce video quality to ensure encoding frame rate. In a weak network environment, you can reduce the video quality to ensure a smooth video playback. In this case, the image quality is reduced and the pictures becomes blurred, but the video can be kept smooth.
 * - DEGRADATION_MAINTAIN_QUALITY: Clarity comes first. Reduce the encoding frame rate to ensure video quality. In a weak network environment, you can reduce the video frame rate to ensure that the video is clear. In this case, a certain amount of freezes may occur at this time.
 * - DEGRADATION_BALANCED: Maintains a balance between encoding frame rate and video quality. 
 * @endif
 * @if Chinese
 * 带宽受限时的视频编码降级偏好。详细信息请参考 {@link NERtcDegradationPreference}。
 *  - DEGRADATION_DEFAULT：（默认）根据场景模式调整适应性偏好。
 *  - 通信场景中，选择DEGRADATION_BALANCED模式，在编码帧率和视频质量之间保持平衡。
 *  - 直播场景中，选择DEGRADATION_MAINTAIN_QUALITY模式，降低编码帧率以保证视频质量。
 *  - DEGRADATION_MAINTAIN_FRAMERATE：流畅优先，降低视频质量以保证编码帧率。在弱网环境下，降低视频清晰度以保证视频流畅，此时画质降低，画面会变得模糊，但可以保持视频流畅。
 *  - DEGRADATION_MAINTAIN_QUALITY：清晰优先，降低编码帧率以保证视频质量。在弱网环境下，降低视频帧率以保证视频清晰，此时可能会出现一定卡顿。
 *  - DEGRADATION_BALANCED：在编码帧率和视频质量之间保持平衡。
 * @endif
 */
@property (nonatomic, assign) NERtcDegradationPreference degradationPreference;

/**
 * @if English
 * Set the mirror mode for the local video encoding. The mirror mode is used for publishing the local video stream. The setting only affects the video picture seen by remote users.
 * <br>For more information, see {@link NERtcVideoMirrorMode}.
 * @endif
 * @if Chinese
 * 设置本地视频编码的镜像模式，即本地发送视频的镜像模式，只影响远端用户看到的视频画面。
 * @note 设置此参数前，请调用 {@link INERtcEngine#setupLocalVideoCanvas:} 设置本地视图。
 * <br>详细信息请参考 {@link NERtcVideoMirrorMode}。
 * @endif
 */
@property (nonatomic, assign) NERtcVideoMirrorMode mirrorMode;

/**
 * @if English
 * Set the orientation mode of the local video encoding, The orientation mode is used for publishing the local video stream, which only affects the video picture seen by remote users.
 * <br>For more information, see {@link NERtcVideoOutputOrientationMode}.
 * @endif
 * @if Chinese
 * 设置本地视频编码的方向模式，即本地发送视频的方向模式，同时影响本端用户的预览画面和远端用户看到的视频画面。
 * <br>详细信息请参考 {@link NERtcVideoOutputOrientationMode}。
 * @endif
 */
@property (nonatomic, assign) NERtcVideoOutputOrientationMode orientationMode;


@end

/**
 * @if English
 * Local substream publishing configuration
 * @endif
 * @if Chinese
 * 本地辅流发送配置。
 * @endif
 */
NERTC_EXPORT  @interface NERtcVideoSubStreamEncodeConfiguration : NERtcBaseVideoEncodeConfiguration

/**
 * @if English
 * The encoding strategy preference of the screen sharing feature is kNERtcSubStreamContentPreferMotion by default. For more information, see {@link NERtcSubStreamContentPrefer}.
 * @endif
 * @if Chinese
 * 屏幕共享功能的编码策略倾向，默认为 kNERtcSubStreamContentPreferMotion。详细信息请参考 {@link NERtcSubStreamContentPrefer}。
 * @endif
 */
@property (nonatomic, assign) NERtcSubStreamContentPrefer contentPrefer;

/**
 * @if English
 * Video encoding degradation preference when the bandwidth is limited. For more information, see {@link NERtcDegradationPreference}.
 * - DEGRADATION_DEFAULT: (default) adjust the adaptation preference based on the scene mode.
 * - In communication scenarios, select DEGRADATION_BALANCED mode to maintain a balance between the encoding frame rate and video quality.
 * - In live streaming, select DEGRADATION_MAINTAIN_QUALITY mode and reduce the encoding frame rate to ensure video quality.
 * - DEGRADATION_MAINTAIN_FRAMERATE: Smoothness comes first. Reduce video quality to ensure encoding frame rate. In a weak network environment, you can reduce the video quality to ensure a smooth video playback. In this case, the image quality is reduced and the pictures becomes blurred, but the video can be kept smooth.
 * - DEGRADATION_MAINTAIN_QUALITY: Clarity comes first. Reduce the encoding frame rate to ensure video quality. In a weak network environment, you can reduce the video frame rate to ensure that the video is clear. In this case, a certain amount of freezes may occur at this time.
 * - DEGRADATION_BALANCED: Maintains a balance between encoding frame rate and video quality. 
 * @endif
 * @if Chinese
 * 带宽受限时的视频编码降级偏好。详细信息请参考 {@link NERtcDegradationPreference}。
 *  - DEGRADATION_DEFAULT：（默认）根据场景模式调整适应性偏好。
 *  - 通信场景中，选择DEGRADATION_BALANCED模式，在编码帧率和视频质量之间保持平衡。
 *  - 直播场景中，选择DEGRADATION_MAINTAIN_QUALITY模式，降低编码帧率以保证视频质量。
 *  - DEGRADATION_MAINTAIN_FRAMERATE：流畅优先，降低视频质量以保证编码帧率。在弱网环境下，降低视频清晰度以保证视频流畅，此时画质降低，画面会变得模糊，但可以保持视频流畅。
 *  - DEGRADATION_MAINTAIN_QUALITY：清晰优先，降低编码帧率以保证视频质量。在弱网环境下，降低视频帧率以保证视频清晰，此时可能会出现一定卡顿。
 *  - DEGRADATION_BALANCED：在编码帧率和视频质量之间保持平衡。
 * @endif
 */
@property (nonatomic, assign) NERtcDegradationPreference degradationPreference;

@end

NERTC_EXTERN_API uint32_t const NERtcAudioMixingMaxVolume;
NERTC_EXTERN_API uint32_t const NERtcAudioMixingDefaultVolume;

/// Options for creating mixing audios
NERTC_EXPORT  @interface NERtcCreateAudioMixingOption : NSObject

/**
 * @if English
 * The absolute path or URL address of the music file for playback. The local absolute path or URL address is also supported.
 * - The file name and extension.
 * - Supported audio formats: MP3, M4A、AAC, 3GP, WMA, and WAV.
 * @endif
 * @if Chinese
 * 待播放的音乐文件的绝对路径或 URL 地址，支持本地绝对路径或 URL 地址。
 * - 需精确到文件名及后缀。
 * - 支持的音效文件类型包括 MP3、M4A、AAC、3GP、WMA 和 WAV 格式。
 * @endif
 */
@property (nonatomic, copy) NSString *path;

/**
 * @if English
 * The number of loops the mixing audio is played back:
 * 1: (default) Plays for one time.
 * ≤ 0: Plays in an infinite loop until stops by calling pauseAudioMixing or stopAudioMixing.
 * @endif
 * @if Chinese
 * 伴音循环播放的次数：
 * 1：（默认）播放一次。
 * ≤ 0：无限循环播放，直至调用 pauseAudioMixing 后暂停，或调用 stopAudioMixing 后停止。
 * @endif
 */
@property (nonatomic, assign) int loopCount;

/**
 * @if English
 * Specifies whether to send the mixing audio to the remote client. The default value is YES. The remote user can hear the mixing audio after the remote user subscribes to the local audio stream.
 * @endif
 * @if Chinese
 * 是否将伴音发送远端，默认为 YES，即远端用户订阅本端音频流后可听到该伴音。
 * @endif
 */
@property (nonatomic, assign) BOOL sendEnabled;

/**
 * @if English
 * Specifies whether to play back the mixing audio on the local client. The default value is YES. The local users can hear the mixing audio.
 * @endif
 * @if Chinese
 * 是否本地播放伴音。默认为 YES，即本地用户可以听到该伴音。
 * @endif
 */
@property (nonatomic, assign) BOOL playbackEnabled;

/**
 * @if English
 * Indicates the publishing volume of a music file. Valid values: 0 to 200. The default value is 100, which indicates that the original volume of the file is used.
 * @note If you modify the volume setting during a call, this setting will be used by default when you call the method again during the current call.
 * @endif
 * @if Chinese
 * 音乐文件的发送音量，取值范围为 0~200。默认为 100，表示使用文件的原始音量。
 * @note 若您在通话中途修改了音量设置，则当前通话中再次调用时默认沿用此设置。
 * @endif
 */
@property (nonatomic, assign) uint32_t sendVolume;

/**
 * @if English
 * Indicates the playback volume of a music file. Valid values: 0 to 200. The default value is 100, which indicates that the original volume of the file is used.
 * @note If you modify the volume setting during a call, this setting will be used by default when you call the method again during the current call.
 * @endif
 * @if Chinese
 * 音乐文件的播放音量，取值范围为 0~200。默认为 100，表示使用文件的原始音量。
 * @note 若您在通话中途修改了音量设置，则当前通话中再次调用时默认沿用此设置。
 * @endif
 */
@property (nonatomic, assign) uint32_t playbackVolume;

/**
 * @if English
 * The start of a playback position. Unit: milliseconds. Default value: 0.
 * @endif
 * @if Chinese
 * 音乐文件开始播放的时间，UTC 时间戳，即从1970 年 1 月 1 日 0 点 0 分 0 秒开始到事件发生时的毫秒数。默认值为 0，表示立即播放。
 * @endif
 */
@property (nonatomic, assign) int64_t startTimeStamp;

/**
 * @if English
 * Specifies if a mixing audio uses a mainstream or substream. The default value is mainstream.
 * @endif
 * @if Chinese
 * 伴音跟随音频主流还是辅流，默认跟随主流。
 * @endif
 */
@property (nonatomic, assign) NERtcAudioStreamType sendWithAudioType;

/**
 * @if Chinese
 * 伴音播放进度回调间隔，单位ms，取值范围为 100~10000, 默认1000ms
 * @endif
 */
@property (nonatomic, assign) uint64_t progressInterval;

/**
 * @if English
 * Checks the validity of the option value.
 * - NO: The value of the option parameter is valid.
 * - YES: The value of the option parameter is invalid. Check and try again.
 * @endif
 * @if Chinese
 * 检查 option 参数值的合法性。
 * - 返回 NO：option 参数值合法。
 * - 返回 YES：option 参数值设置错误，请检查后重试。
 * @endif
 */
- (BOOL)isInvalid;

@end

/// Options for creating audio effects
NERTC_EXPORT  @interface NERtcCreateAudioEffectOption : NSObject

/**
 * @if English
 * The path of the audio effect file. The local absolute paths or URL addresses are supported.
 * - The file name and extension.
 * - Supported audio formats: MP3, M4A、AAC, 3GP, WMA, and WAV.
 * @endif
 * @if Chinese
 * 待播放的音效文件路径，支持本地绝对路径或 URL 地址。
 * - 需精确到文件名及后缀。
 * - 支持的音效文件类型包括 MP3、M4A、AAC、3GP、WMA 和 WAV 格式。
 * @endif
 */
@property (nonatomic, copy) NSString *path;

/**
 * @if English
 * The number of loops the audio effect is played:
 * -1: (Default) plays the audio effect for one time.
 * -≤ 0: plays sound effects in an infinite loop until you stop the playback by calling stopEffect or stopAllEffects.
 * @endif
 * @if Chinese
 * 音效循环播放的次数：
 * - 1：（默认）播放音效一次。
 * - ≤ 0：无限循环播放音效，直至调用 stopEffect 或 stopAllEffects 后停止。
 * @endif
 */
@property (nonatomic, assign) int loopCount;

/**
 * @if English
 * Whether to send the sound effect to the far end. The default value is YES. The remote users can hear the audio effect.
 * @endif
 * @if Chinese
 * 是否将音效发送远端。默认为 YES，即远端用户可以听到该音效。
 * @endif
 */
@property (nonatomic, assign) BOOL sendEnabled;

/**
 * @if English
 * Specifies whether to play the audio effect on the client. The default value is YES. The local users can hear the audio effect.
 * @endif
 * @if Chinese
 * 是否本地播放该音效。默认为 YES，即本地用户可以听到该音效。
 * @endif
 */
@property (nonatomic, assign) BOOL playbackEnabled;

/**
 * @if English
 * Indicates the publishing volume of an audio effect file. Valid values: 0 to 100. The default value is 100, which indicates that the original volume of the audio file is used.
 * @note If you modify the volume setting during a call, this setting will be used by default when you call the method again during the current call.
 * @endif
 * @if Chinese
 * 音效文件的发送音量，取值范围为 0~100。默认为 100，表示使用文件的原始音量。
 * @note 若您在通话中途修改了音量设置，则当前通话中再次调用时默认沿用此设置。
 * @endif
 */
@property (nonatomic, assign) uint32_t sendVolume;

/**
 * @if English
 * Indicates the playback volume of an audio effect file. Valid values: 0 to 100. The default value is 100, which indicates that the original volume of the audio file is used.
 * @note If you modify the volume setting during a call, this setting will be used by default when you call the method again during the current call.
 * @endif
 * @if Chinese
 * 音效文件的播放音量，取值范围为 0~100。默认为 100，表示使用文件的原始音量。
 * @note 若您在通话中途修改了音量设置，则当前通话中再次调用时默认沿用此设置。
 * @endif
 */
@property (nonatomic, assign) uint32_t playbackVolume;

/**
 * @if Chinese
 * 音效文件开始播放的时间，UTC 时间戳，默认值为 0，表示立即播放。
 * @endif
 */
@property (nonatomic, assign) int64_t startTimeStamp;

/**
 * @if Chinese
 * 音效跟随音频主流还是辅流，默认跟随主流。
 * @endif
 */
@property (nonatomic, assign) NERtcAudioStreamType sendWithAudioType;

/**
 * @if Chinese
 * 音效播放进度回调间隔，单位ms，取值范围为 100~10000, 默认1000ms
 * @endif
 */
@property (nonatomic, assign) uint64_t progressInterval;

@end

NERTC_EXPORT  @interface NERtcAudioRecordingConfiguration : NSObject

// 录音文件在本地保存的绝对路径，需要精确到文件名及格式。例如：sdcard/xxx/audio.aac。请确保指定的路径存在并且可写。目前仅支持 WAV 或 AAC 文件格式。
@property (nonatomic, copy) NSString *filePath;

// 录音采样率（Hz），可以设为 16000、32000（默认）、44100 或 48000。
@property (nonatomic, assign) int sampleRate;

// 录音音质，只在 AAC 格式下有效。详细信息请参考 {@link NERtcAudioRecordingQuality}。
@property (nonatomic, assign) NERtcAudioRecordingQuality quality;

// 录音文件所包含的内容。详细信息请参考 {@link NERtcAudioRecordingPosition}。
@property (nonatomic, assign) NERtcAudioRecordingPosition position;

// 录制过程中，循环缓存的最大时间长度，单位(s)。详细信息请参考 {@link NERtcAudioRecordingCycleTime}。
@property (nonatomic, assign) NERtcAudioRecordingCycleTime cycleTime;

@end

#pragma mark - live stream
/**
 * @if English
 * Settings, such as encoding parameters of RTC streams
 * @endif
 * @if Chinese
 * 音视频流编码参数等设置
 * @endif
 */
NERTC_EXPORT  @interface NERtcLiveConfig: NSObject

/**
 * @if Chinese
 * 设置是否开启主播占位图模式。
 * <br>开启后会在主播离线的时候用占位图填补主播位置。
 * - YES：开启。
 * - NO（默认）：关闭。
 * @endif
 */
@property (nonatomic, assign) BOOL interruptedPlaceImage;

/**
 * @if English
 * Enables or disables single video pass-through. By default, the setting is disabled.
 * <br>If you enable video pass-through, and the room ingests only one video stream, then, the stream is not transcoded and does not follow the transcoding flow. The video stream is directly pushed to a CDN.
 * <br>If multiple video streams from different room members are mixed into one video stream, this setting becomes invalid, and will not be restored when the stream is restored to the single stream.
 * @endif
 * @if Chinese
 * 单路视频透传开关，默认为关闭状态。
 * <br>开启后，如果房间中只有一路视频流输入， 则不对输入视频流进行转码，不遵循转码布局，直接推流 CDN。
 * <br>如果有多个房间成员视频流混合为一路流，则该设置失效，并在恢复为一个成员画面（单路流）时也不会恢复。
 * @endif
 */
@property (nonatomic, assign) BOOL singleVideoPassthrough;
/**
 * @if English
 * The bitrate of the audio stream.
 * <br>Unit: kbps. Valid values: 10 to 192.
 * <br>We recommend that you set the bitrate to 64 or higher for voice scenarios and set 128 or higher for music scenarios.
 * @endif
 * @if Chinese
 * 音频推流码率。
 * <br>单位为 kbps，取值范围为 10~192。
 * <br>语音场景建议设置为 64 及以上码率，音乐场景建议设置为 128 及以上码率。
 * @endif
 */
@property (nonatomic, assign) NSInteger audioBitrate;

/**
 * @if English
 * The sample rate of the audio stream. Unit: Hz. Valid values:
 * - 32000: The sample rate is 32 kHz.
 * - 44100: The sample rate is 44.1 kHz.
 * - 48000 (default): The sample rate is 48 kHz.
 * @endif
 * @if Chinese
 * 音频推流采样率。单位为Hz，可设置为：
 * - 32000：采样率为 32 kHz。
 * - 44100：采样率为 44.1 kHz。
 * - （默认）48000：采样率为 48 kHz。
 * @endif
 */
@property (nonatomic, assign) NERtcLiveStreamAudioSampleRate sampleRate;

/**
 * @if English
 * The number of audio channels for pushing streams.
 * - 1: mono sound
 * - 2: (default) stereo sound 
 * @endif
 * @if Chinese
 * 音频推流声道数。
 * - 1：单声道。
 * - 2：（默认）双声道。
 * @endif
 */
@property (nonatomic, assign) NSInteger channels;

/**
 * @if English
 * The audio encoding profile.
 * -0: (default) LC-AAC that indicates the basic audio encoding specifications.
 * -1: HE-AAC that indicates high-efficiency audio encoding specifications. 
 * @endif
 * @if Chinese
 * 音频编码规格。
 * - 0：（默认）LC-AAC 规格，表示基本音频编码规格。
 * - 1：HE-AAC 规格，表示高效音频编码规格。 
 * @endif
 */
@property (nonatomic, assign) NERtcLiveStreamAudioCodecProfile audioCodecProfile;

@end

/**
 * @if English
 * The member layout in live streaming
 * @endif
 * @if Chinese
 * 直播成员布局。
 * @endif
 */
NERTC_EXPORT  @interface NERtcLiveStreamUserTranscoding: NSObject

/**
 * @if English
 * Pull the video stream of the user with the specified uid into the live event. If you add multiple users, the uid must be unique.
 * @endif
 * @if Chinese
 * 将指定uid对应用户的视频流拉入直播。如果添加多个 users，则 uid 不能重复。
 * @endif
 */
@property (nonatomic, assign) uint64_t uid;

/**
 * @if English
 * Specifies whether to play back the specific video stream from the user to viewers in the live event. Valid values:
 * - YES: (default) plays the video stream.
 * - NO: does not play the video stream.
 * <br>The setting becomes invalid when the streaming mode is set to kNERtcLsModeAudio. 
 * @endif
 * @if Chinese
 * 是否在直播中向观看者播放该用户的对应视频流。可设置为：
 * - YES：（默认）在直播中播放该用户的视频流。
 * - NO：在直播中不播放该用户的视频流。
 * <br>推流模式为kNERtcLsModeAudio时无效。
 * @endif
 */
@property (nonatomic, assign) BOOL videoPush;

/**
 * @if English
 * The X parameter is used to set the horizontal coordinate value of the user image. You can specify a point in the canvas with X and Y coordinates. This point is used as the anchor of the upper left corner of the user image.
 * <br>Value range: 0 to 1920. If the specified value is set to an odd value, the value is automatically rounded down to an even number.
 * <br>If the user image exceeds the canvas, an error occurs when you call the method.
 * @endif
 * @if Chinese
 * <br>x 参数用于设置用户图像的横轴坐标值。通过 x 和 y 指定画布坐标中的一个点，该点将作为用户图像的左上角。
 * <br>取值范围为 0~1920，若设置为奇数值，会自动向下取偶。
 * <br>用户图像范围如果超出超出画布，调用方法时会报错。
 * @endif
 */
@property (nonatomic, assign) NSInteger x;

/**
 * @if English
 * The Y parameter is used to set the vertical coordinate value of the user image. You can specify a point in the canvas with X and Y coordinates. This point is used as the anchor of the upper left corner of the user image.
 * Value range: 0 to 1920. If the specified value is set to an odd value, the value is automatically rounded down to an even number.
 * If the user image exceeds the canvas, an error occurs when you call the method.
 * @endif
 * @if Chinese
 * <br>Y参数用于设置用户图像的纵轴坐标值。通过 x 和 y 指定画布坐标中的一个点，该点将作为用户图像的左上角。
 * <br>取值范围为 0~1920，若设置为奇数值，会自动向下取偶。
 * <br>用户图像范围如果超出超出画布，调用方法时会报错。
 * @endif
 */
@property (nonatomic, assign) NSInteger y;

/**
 * @if English
 * The width of the user image in the canvas.
 * <br>Value range: 0 to 1920. The default value is 0. If the specified value is set to an odd value, the value is automatically rounded down to an even number.
 * <br>If the user image exceeds the canvas, an error occurs when you call the method.
 * @endif
 * @if Chinese
 * 该用户图像在画布中的宽度。
 * <br>取值范围为 0~1920，默认为0。若设置为奇数值，会自动向下取偶。
 * <br>用户图像范围如果超出超出画布，调用方法时会报错。
 * @endif
 */
@property (nonatomic, assign) NSInteger width;

/**
 * @if English
 * The height of the user image in the canvas.
 * <br>Value range: 0 to 1920. The default value is 0. If the specified value is set to an odd value, the value is automatically rounded down to an even number.
 * <br>If the user image exceeds the canvas, an error occurs when you call the method.
 * @endif
 * @if Chinese
 * 该用户图像在画布中的高度。
 * <br>取值范围为 0~1920，默认为0。若设置为奇数值，会自动向下取偶。
 * <br>用户图像范围如果超出超出画布，调用方法时会报错。
 * @endif
 */
@property (nonatomic, assign) NSInteger height;

/**
 * @if English
 * Specifies whether to mix the audio stream from the user in the live event. Valid values:
 * - YES: (default) mixes the audio stream from the user in the live event.
 * - NO: mute the audio stream from the user in the live event. 
 * @endif
 * @if Chinese
 * 是否在直播中混流该用户的对应音频流。可设置为：
 * - YES：（默认）在直播中混流该用户的对应音频流。
 * - NO：在直播中将该用户设置为静音。
 * @endif
 */
@property (nonatomic, assign) BOOL audioPush;

/**
 * @if English
 * The layer number is used to determine the rendering level. Value range: 0 to 100. A value of 0 indicates that the layer is at the bottom. A value of 100 indicates that the layer is at the top. The rendering area at the same level is overwritten based on the existing overlay strategy. (Rendering is performed in the order of the array, and the index increases in ascending order.)
 * @endif
 * @if Chinese
 * 图层编号，用来决定渲染层级, 取值 0-100 , 0位于最底层，100位于最顶层，相同层级的渲染区域按照现有的覆盖逻辑实现（按照数组中顺序进行渲染，index递增依次往上叠加）。
 * @endif
 */
@property (nonatomic, assign) NSInteger zOrder;

/**
 * @if English
 * The adaptation between the video and the canvas in live streaming. For more information, see {@link NERtcLiveStreamVideoScaleMode}.
 * @endif
 * @if Chinese
 * 直播推流视频和画布的适应属性。详细信息请参考 {@link NERtcLiveStreamVideoScaleMode}。
 * @endif
 */
@property (nonatomic, assign) NERtcLiveStreamVideoScaleMode adaption; 

@end

/**
 * @if English
 * Picture layout
 * @endif
 * @if Chinese
 * 图片布局。
 * @endif
 */
NERTC_EXPORT  @interface NERtcLiveStreamImageInfo: NSObject

/**
 * @if English
 * The URL of the placeholder image
 * @endif
 * @if Chinese
 * 占位图片的URL。
 * @endif
 */
@property (nonatomic, copy) NSString *url;

/**
 * @if English
 * The X parameter is used to set the horizontal coordinate value of the canvas.
 * <br>You can specify a point in the canvas with X and Y coordinates. This point is used as the anchor of the upper left corner of the placeholder image.
 * <br>Value range: 0 to 1920. If the specified value is set to an odd value, the value is automatically rounded down to an even number.
 * @endif
 * @if Chinese
 * X 参数用于设置画布的横轴坐标值。
 * <br>通过 x 和 y 指定画布坐标中的一个点，该点将作为占位图片的左上角。
 * <br>取值范围为 0~1920，若设置为奇数值，会自动向下取偶。
 * @endif
 */
@property (nonatomic, assign) NSInteger x;

/**
 * @if English
 * The Y parameter is used to set the vertical coordinate value of the canvas.
 * <br>You can specify a point in the canvas with X and Y coordinates. This point is used as the anchor of the upper left corner of the placeholder image.
 * <br>Value range: 0 to 1920. If the specified value is set to an odd value, the value is automatically rounded down to an even number.
 * @endif
 * @if Chinese
 * Y 参数用于设置画布的纵轴坐标值。
 * <br>通过 x 和 y 指定画布坐标中的一个点，该点将作为占位图片的左上角。
 * <br>取值范围为 0~1920，若设置为奇数值，会自动向下取偶。
 * @endif
 */
@property (nonatomic, assign) NSInteger y;

/**
 * @if English
 * The width of the placeholder image in the canvas.
 * <br>Value range: 0 to 1920. If the specified value is set to an odd value, the value is automatically rounded down to an even number.
 * @endif
 * @if Chinese
 * 该占位图片在画布中的宽度。
 * <br>取值范围为 0~1920，若设置为奇数值，会自动向下取偶。
 * @endif
 */
@property (nonatomic, assign) NSInteger width;

/**
 * @if English
 * The height of the placeholder image in the canvas.
 * <br>Value range: 0 to 1920. If the specified value is set to an odd value, the value is automatically rounded down to an even number.
 * @endif
 * @if Chinese
 * 该占位图片在画布中的高度。
 * <br>取值范围为 0~1920，若设置为奇数值，会自动向下取偶。
 * @endif
 */
@property (nonatomic, assign) NSInteger height;

/**
 * @if Chinese 
 * 占位图的图层编号，用来决定渲染层级。
 * <br>取值范围为 0~100，默认为 0。
 * - 最小值为 0（默认值），表示该区域图像位于最底层。
 * - 最大值为 100，表示该区域图像位于最顶层。
 * <br><b>注意</b>：相同层级的渲染区域会按照数组中顺序进行渲染，随着 index 递增，依次往上叠加。
 * @endif
 */
@property (nonatomic, assign) int zorder;

@end

/**
 * @if English
 * The live streaming layout.
 * @endif
 * @if Chinese
 * 直播布局。
 * @endif
 */
NERTC_EXPORT  @interface NERtcLiveStreamLayout: NSObject

/**
 * @if English
 * The width of the overall canvas. Unit: px. Value range: 0 to 1920. If the specified value is set to an odd value, the value is automatically rounded down to an even number.
 * @endif
 * @if Chinese
 * 整体画布的宽度，单位为 px。取值范围为 0~1920，若设置为奇数值，会自动向下取偶。
 * @endif
 */
@property (nonatomic, assign) NSInteger width;

/**
 * @if English
 * The height of the overall canvas. Unit: px. Value range: 0 to 1920. If the specified value is set to an odd value, the value is automatically rounded down to an even number.
 * @endif
 * @if Chinese
 * 整体画布的高度，单位为 px。取值范围为 0~1920，若设置为奇数值，会自动向下取偶。
 * @endif
 */
@property (nonatomic, assign) NSInteger height;

/**
 * @if English
 * The background color of the canvas. The formula that is used to calculate the value of the background color is the sum of 256 × 256 × R 256 × G + B. Enter the corresponding RGB values into this formula to calculate the value. If the value is unspecified, the default value is 0.
 * @endif
 * @if Chinese
 * 画面背景颜色，格式为 256 ✖ 256 ✖ R + 256 ✖ G + B的和。请将对应 RGB 的值分别带入此公式计算即可。若未设置，则默认为0。
 * @endif
 */
@property (nonatomic, assign) NSUInteger backgroundColor;

/**
 * @if English
 * The member layout array. For more information, see {@link NERtcLiveStreamUserTranscoding}.
 * @endif
 * @if Chinese
 * 成员布局数组，详细信息请参考 {@link NERtcLiveStreamUserTranscoding}。
 * @endif
 */
@property (nonatomic, strong) NSArray<NERtcLiveStreamUserTranscoding *> * users;

/**
 * @if English
 * The placeholder image For more information, see {@link NERtcLiveStreamImageInfo}.
 * @endif
 * @if Chinese
 * 占位图片。详细信息请参考 {@link NERtcLiveStreamImageInfo}。
 * @note 此字段仅可设置一张占位图，建议您使用新字段 bgImages，可以设置最多 6 张占位图。
 * @endif
 */
@property (nonatomic, nullable, strong) NERtcLiveStreamImageInfo* bgImage;

/**
 * @if Chinese
 * 占位图片列表。详细信息请参考 {@link NERtcLiveStreamImageInfo}。
 * @note 若您同时配置了 bgImage 和 bgImages 两个字段，则以 bgImages 配置为准。
 * @endif
 */
@property (nonatomic, nullable, strong) NSArray<NERtcLiveStreamImageInfo*> * bgImages;

@end

/**
 * @if English
 * Configuration of streaming tasks in a live event
 * @endif
 * @if Chinese
 * 直播推流任务的配置。
 * @endif
 */
NERTC_EXPORT  @interface NERtcLiveStreamTaskInfo: NSObject

/**
 * @if English
 * The ID of a custom streaming task. The ID must be up to 64 characters in length and can contain letters, numbers, and underscores. The ID must be unique.
 * @endif
 * @if Chinese
 * 自定义的推流任务ID。字母、数字、下划线组成的 64 位以内的字符串。请保证此ID唯一。
 * @endif
 */
@property (nonatomic, copy) NSString *taskID;

/**
 * @if English
 * The streaming URL, such as rtmp://test.url.
 * <br>The URL can be set to the value of the pushUrl response parameter of the server API used to create a room in NetEase CommsEase live streaming.
 * @endif
 * @if Chinese
 * 推流地址，例如 rtmp://test.url。
 * <br>此处的推流地址可设置为网易云信直播产品中服务端 API创建房间的返回参数pushUrl。
 * @endif
 */
@property (nonatomic, copy) NSString *streamURL;

/**
 * @if English
 * Specifies whether to enable audio and video recording in the CDN relayed streaming. By default, the setting is disabled.
 * @endif
 * @if Chinese
 * 旁路推流是否需要进行音视频录制。默认为关闭状态。
 * @endif
 */
@property (nonatomic, assign) BOOL serverRecordEnabled;

/**
 * @if English
 * The live streaming mode. The default value is kNERtcLsModeVideo. For more information, see {@link NERtcLiveStreamMode}.
 * @endif
 * @if Chinese
 * 直播推流模式。默认为 kNERtcLsModeVideo。详细信息请参考 {@link NERtcLiveStreamMode}。
 * @endif
 */
@property (nonatomic, assign) NERtcLiveStreamMode lsMode;

/**
 * @if English
 * Set the canvas layout of Interactive Live Streaming. For more information, see {@link NERtcLiveStreamLayout}.
 * @endif
 * @if Chinese
 * 设置互动直播的画面布局。详细信息请参考 {@link NERtcLiveStreamLayout}。
 * @endif
 */
@property (nonatomic, nullable, strong) NERtcLiveStreamLayout *layout;

/**
 * @if English
 * Settings such as encoding parameters of RTC streams. For more information, see {@link NERtcLiveConfig}.
 * @endif
 * @if Chinese
 * 音视频流编码参数等设置。详细信息请参考 {@link NERtcLiveConfig}。
 * @endif
 */
@property (nonatomic, nullable, strong) NERtcLiveConfig *config;

/**
 * @if English
 * The reserved parameter, user-defined information sent to the clients in CDN relayed streaming. The information is used to add to the SEI in the H264/H265 video. Length limit: 4096 bytes.
 * @endif
 * @if Chinese
 * 预留参数，用户自定义的发送到旁路推流客户端的信息，用于填充 H264/H265 视频中 SEI 帧内容。长度限制：4096 字节。
 * @endif
 */
@property (nonatomic, nullable, copy) NSString *extraInfo;

/**
 * @if English
 * Determines whether the options are invalid.
 * @endif
 * @if Chinese
 * 配置的选项是不是合法。
 * @endif
 */
- (BOOL)isInvalid;

@end


#pragma mark -- Audio Frame Observer
/**
 * @if English
 * The request format of the audio raw data callback (unspecified by default).
 * @endif
 * @if Chinese
 * 音频原始数据回调格式（默认不设置）。
 * @endif
 */
NERTC_EXPORT  @interface NERtcAudioFrameRequestFormat : NSObject

/**
 * @if English
 * The number of audio channels. If the audio is stereo, the data is interleaved.
 * <br>Valid values:
 * - 1: mono sound
 * - 2: stereo sound 
 * @endif
 * @if Chinese
 * 音频声道数量。如果是立体声，则数据是交叉的。
 * <br>可设置为：。
 * - 1: 单声道。
 * - 2: 双声道。
 * @endif
 */
@property (nonatomic, assign) uint32_t channels;

/**
 * @if English
 * The audio sample rate.
 * @endif
 * @if Chinese
 * 音频采样率。
 * @endif
 */
@property (nonatomic, assign) uint32_t sampleRate;

/**
 * @if English
 * The audio data read and write permissions. For more information, see {@link NERtcAudioFrameOpMode}.
 * @endif
 * @if Chinese
 * 音频数据读写权限。详细信息请参考 {@link NERtcAudioFrameOpMode}。
 * @endif
 */
@property (nonatomic, assign) NERtcAudioFrameOpMode mode;

@end

/**
 * @if English
 * The audio format
 * @endif
 * @if Chinese
 * 音频格式。
 * @endif
 */
NERTC_EXPORT  @interface NERtcAudioFormat : NSObject

/**
 * @if English
 * The audio PCM type. For more information, see {@link NERtcAudioType}.
 * @endif
 * @if Chinese
 * 音频 PCM 类型。详细信息请参考 {@link NERtcAudioType}。
 * @endif
 */
@property (nonatomic, assign) NERtcAudioType type;
/**
 * @if English
 * The number of audio channels.
 * 1: mono
 * 2: stereo
 * @endif
 * @if Chinese
 * 音频声道数。
 * 1：单声道。
 * 2：双声道。
 * @endif
 */
@property (nonatomic, assign) uint32_t channels;

/**
 * @if English
 * The audio sample rate.
 * @endif
 * @if Chinese
 * 音频采样率。
 * @endif
 */
@property (nonatomic, assign) uint32_t sampleRate;

/**
 * @if English
 * The number of bytes per sample.
 * @endif
 * @if Chinese
 * 每个采样点的字节数。
 * @endif
 */
@property (nonatomic, assign) uint32_t bytesPerSample;

/**
 * @if English
 * The number of samples for each channel.
 * @endif
 * @if Chinese
 * 每个声道的采样点数。
 * @endif
 */
@property (nonatomic, assign) uint32_t samplesPerChannel;

@end

/**
 * @if English
 * The audio frame
 * @endif
 * @if Chinese
 * 音频帧。
 * @endif
 */
NERTC_EXPORT  @interface NERtcAudioFrame : NSObject

/**
 * @if English
 * The audio format. For more information, see {@link NERtcAudioFormat}.
 * @endif
 * @if Chinese
 * 音频格式。详细信息请参考 {@link NERtcAudioFormat}。
 * @endif
 */
@property (nonatomic, strong) NERtcAudioFormat* format;

/**
 * @if English
 * The raw audio data
 * @endif
 * @if Chinese
 * 音频裸数据。
 * @endif
 */
@property (nonatomic, assign) void* data;

/**
 * @if English
 * Syncs the timestamps of the audio mainstream and substream. The method is applied when the mainstream and substream are used for external sources.
 * @endif
 * @if Chinese
 * 同步音频主辅流的时间戳，一般只有在同时开启外部音频主流及辅流输入时用到。
 * @endif
 */
@property (nonatomic, assign) int64_t syncTimestamp;

@end


#pragma mark - Volume info

/**
 * @if English
 * Audio volume information
 * @endif
 * @if Chinese
 * 声音音量信息。
 * @endif
 */
NERTC_EXPORT  @interface NERtcAudioVolumeInfo : NSObject

/**
 * @if English
 * The user ID that is used to identify the volume
 * @endif
 * @if Chinese
 * 用户 ID，指定是哪个用户的音量。
 * @endif
 */
@property (nonatomic, assign) uint64_t uid;

/**
 * @if English
 * The volume of the speaker. Value range: 0 to 100.
 * @endif
 * @if Chinese
 * 说话者的音量，范围为0~100。
 * @endif
 */
@property (nonatomic, assign) unsigned int volume;

/**
 * @if English
 * The volume of the speaker. Value range: 0 to 100.
 * @endif
 * @if Chinese
 * 远端用户音频辅流的音量，取值范围为 [0,100]。
 * <br>如果 subStreamVolume 为 0，表示该用户未发布音频辅流或音频辅流没有音量。
 * @endif
 */
@property (nonatomic, assign) unsigned int subStreamVolume;

@end

#pragma mark - Video Frame

/**
 * @if English
 * Video frame information
 * @endif
 * @if Chinese
 * 视频帧信息。
 * @endif
 */
NERTC_EXPORT  @interface NERtcVideoFrame : NSObject

/**
 * @if English
 * The video frame format. For more information, see {@link NERtcVideoFormatType}.
 * @endif
 * @if Chinese
 * 视频帧格式，详细信息请参考 {@link NERtcVideoFormatType}。
 * 视频外部渲染场景下，仅支持 kNERtcVideoFormatI420。
 * @endif
 */
@property(nonatomic, assign) NERtcVideoFormatType format;

/**
 * @if English
 * The video timestamp. Unit: milliseconds.
 * @endif
 * @if Chinese
 * 视频时间戳，单位为毫秒。
 * @endif
 */
@property(nonatomic, assign) uint64_t timestamp;

/**
 * @if English
 * The video height that contains the pixels of the video frame on the horizontal axis.
 * @endif
 * @if Chinese
 * 视频高，即视频帧在横轴上的像素。
 * @endif
 */
@property(nonatomic, assign) uint32_t width;

/**
 * @if English
 * The Video width that contains the pixels of the video frame on the vertical axis.
 * @endif
 * @if Chinese
 * 视频宽，即视频帧在纵轴上的像素。
 * @endif
 */
@property(nonatomic, assign) uint32_t height;

/**
 * @if English
 * The angle to which the video rotates in the clockwise direction. For more information, see {@link NERtcVideoRotationType}.
 * @endif
 * @if Chinese
 * 视频顺时针旋转角度。详细信息请参考 {@link NERtcVideoRotationType}。
 * @endif
 */
@property(nonatomic, assign) NERtcVideoRotationType rotation;

/**
 * @if English
 * Video data supports CVPixelBuffer and NSData.
 * @endif
 * @if Chinese
 * 视频数据指针。
 * 视频外部输入场景下，按照不同的格式，可支持 CVPixelBuffer、NSData 的 bytes；
 * 对于 I420 格式，代表 Y 分量的指针；
 * 对于 NV12 和 BGRA 格式，代表 CVPixelBuffer。
 * 视频外部渲染场景下，代表 I420 数据中 Y 分量的指针。
 * @endif
 */
@property(nonatomic) void * buffer;

/**
 * @if Chinese
 * 视频数据指针。
 * 目前该参数仅在外部渲染视频的场景下有实际意义。
 * 视频外部渲染场景下，代表 I420 数据中 U 分量的指针。
 * @endif
 */
@property(nonatomic) void * uBuffer;

/**
 * @if Chinese
 * 视频数据指针。
 * 目前该参数仅在外部渲染视频的场景下有实际意义。
 * 视频外部渲染场景下，代表 I420 数据中 V 分量的指针。
 * @endif
 */
@property(nonatomic) void * vBuffer;

/**
 * @if English
 * Line spacing of the plane(s) in video frame.Currently this parameter is only useful when using external video renderer.
 * @endif
 * @if Chinese
 * 视频帧各平面的行间距。
 * 目前该参数仅在外部渲染视频的场景下有实际意义。
 * @endif
 */
@property(nonatomic, strong) NSArray<NSNumber *> *strides;

// Metal 纹理
// 目前该参数仅在外部渲染视频的场景下有实际意义。
@property(nonatomic, strong) id<MTLTexture> texture;

@end

#pragma mark- MediaRelay

/**
 * @if English
 * Data structure related to media stream relay.
 * @endif
 * @if Chinese
 * 媒体流转发相关的数据结构。
 * @endif
 */
NERTC_EXPORT  @interface NERtcChannelMediaRelayInfo : NSObject

/**
 * @if English
 * The room name.
 * @endif
 * @if Chinese
 * 房间名。
 * @endif
 */
@property (nonatomic, copy)NSString *channelName;
/**
 * @if English
 * A token that can be used to join the room.
 * @endif
 * @if Chinese
 * 能加入房间的 Token。
 * @endif
 */
@property (nonatomic, copy)NSString *token;
/**
 * @if English
 * User ID.
 * @endif
 * @if Chinese
 * 用户 ID。
 * @endif
 */
@property (nonatomic, assign)uint64_t uid;

@end

NERTC_EXPORT  @interface NERtcChannelMediaRelayConfiguration : NSObject

/**
 * @if English
 * The settings of the destination room where the media stream is relayed. For more information, see {@link NERtcChannelMediaRelayInfo}.
 * - channelName: The name of the destination room.
 * - Token: A token that can be used to join the room.
 * - uid: Identifies the UID of the media stream in the room. Make sure that this parameter is not set to the UID of the host in the destination room, and all uids are different in the room.
 * @endif
 * @if Chinese
 * 转发媒体流的目标房间配置信息。详细信息请参考 {@link NERtcChannelMediaRelayInfo}。
 * - channelName：目标房间的房间名。
 * - token：可以加入目标房间的 token。
 * - uid：标识目标房间中的转发媒体流的 UID。请确保不要将该参数设为目标房间的主播的 UID，并与目标房间中的 所有 UID 都不同。
 * @endif
 */
@property(nonatomic, strong, readonly)NSDictionary<NSString *, NERtcChannelMediaRelayInfo *> * _Nullable destinationInfos;

/**
 * @if English
 * Information about the source room. For more information, see {@link NERtcChannelMediaRelayInfo}.
 * - channelName: the name of the source room.
 * - Token: The token that can be added to the source room.
 * - uid: Identifies the UID of the media stream in the room.
 * @endif
 * @if Chinese
 * 源房间的信息。详细信息请参考 {@link NERtcChannelMediaRelayInfo}。
 * - channelName：源房间名。
 * - token：能加入源房间的 token。
 * - uid：标识源房间中的转发媒体流的 UID。
 * @endif
 */
@property(nonatomic, strong)NERtcChannelMediaRelayInfo *sourceInfo;

/**
 * @if English
 * Set the information of the destination room for media stream relay across rooms.
 * <br>If you need to forward the media stream to multiple rooms, you can call this method multiple times to set the NERtcChannelMediaRelayInfo of multiple rooms. This method supports up to 4 rooms.
 * @param destinationInfo Destination room information. For more information, see {@link NERtcChannelMediaRelayInfo}.
 * @param channelName The name of the destination room where the media stream is relayed. This parameter is required and must be consistent with the channelName in the destinationInfo parameter of the method.
 * @return YES: success. NO: failure.
 * @endif
 * @if Chinese
 * 设置跨房间媒体流转发的目标房间信息。
 * <br>如果您需要将媒体流转发到多个房间，可以多次调用该方法，设置多个房间的 NERtcChannelMediaRelayInfo。该方法支持最多设置 4 个目标房间。
 * @param destinationInfo 目标房间信息。详细信息请参考 {@link NERtcChannelMediaRelayInfo}。
 * @param channelName     目标房间名称。该参数必填，且需与该方法 destinationInfo 参数中的 channelName 一致。
 * @return 成功返回YES，失败返回NO。
 * @endif
 */
- (BOOL)setDestinationInfo:(NERtcChannelMediaRelayInfo *_Nonnull)destinationInfo forChannelName:(NSString *_Nonnull)channelName;

/**
 * @if English
 * Delete the information of the destination room for media stream relay across rooms.
 * @param channelName The name of the destination room where you want to cancel the media stream relay.
 * @return YES: success. NO: failure.
 * @endif
 * @if Chinese
 * 删除跨房间媒体流转发的房间信息。
 * @param channelName 需要取消转发媒体流的目标房间名称。
 * @return 成功返回YES，失败返回NO。
 * @endif
 */
- (BOOL)removeDestinationInfoForChannelName:(NSString *_Nonnull)channelName;

@end

#pragma mark - watermark

/**
 * @if English
 * Image watermark configuration.
 * @note
 * - If the width or height of a watermark box is specified, the image will be resized to the width and height of the watermark box.
 * - If the width or height of a watermark box is unspecified, the image will be displayed in the original size. If the original size is greater than that of the video, the image will be resized to the video size.
 * - For performance considerations, we recommended you set a proper size.
 * @endif
 * @if Chinese
 * 视频图片水印配置。
 * @note
 * - 如果设置了水印框宽或高，图像将缩放至水印框的宽高尺寸。
 * - 如果设置了水印框宽高，按图像原始尺寸展示；原始尺寸大于视频尺寸时，缩放至视频尺寸。
 * - 出于性能的考虑，建议设置尺寸合适的图片。
 * @endif
 */
NERTC_EXPORT @interface NERtcVideoWatermarkImageConfig : NSObject

/**
 * @if English
 * Overall watermark transparency. Value range: 0.0 ~ 1.0. Default value: 1.0 represents no transparency.
 * @endif
 * @if Chinese
 * 整体水印透明度，取值范围为 0.0 ~ 1.0，默认值为 1.0，表示不透明。
 * @endif
 */
@property (nonatomic, assign) CGFloat wmAlpha;

/**
 * @if English
 * The width of a watermark box. Unit: pixel. Default value: 0, following the original width.
 * @endif
 * @if Chinese
 * 水印框的宽度，单位为像素，默认值为 0，表示按原始图宽。
 * @endif
 */
@property (nonatomic, assign) NSUInteger wmWidth;

/**
 * @if English
 * The height of a watermark box. Unit: pixels. Default value: 0, following the original height.
 * @endif
 * @if Chinese
 * 水印框的高度，单位为像素，默认值为 0，表示按原始图高。
 * @endif
 */
@property (nonatomic, assign) NSUInteger wmHeight;

/**
 * @if English
 * The horizontal distance between the upper left corner of the screen and the upper left corner of the video image. Unit: pixels. Default value: 0.
 * @endif
 * @if Chinese
 * 水平左上角与视频图像左上角的水平距离，单位为像素，默认值为 0。
 * @endif
 */
@property (nonatomic, assign) NSUInteger offsetX;

/**
 * @if English
 * The vertical distance between the upper left corner of the screen and the upper left corner of the video image. Unit: pixels. Default value: 0.
 * @endif
 * @if Chinese
 * 水平左上角与视频图像左上角的垂直距离，单位为像素，默认值为 0。
 * @endif
 */
@property (nonatomic, assign) NSUInteger offsetY;

/**
 * @if English
 * The absolute path of an image. Multiple paths are allowed.
 * @endif
 * @if Chinese
 * 图片绝对路径，支持多个图片路径。
 * @endif
 */
@property (nonatomic, strong) NSArray<NSString *> *imagePaths;

/**
 * @if English
 * Playback frame rate. The default value 0 indicates that images are not switched automatically. Images are displayed in a single frame.
 * <br>The maximum frame rate does not exceed 30fps. If the specified frame rate is higher than the video frame rate, images are displayed at the video frame rate.
 * @endif
 * @if Chinese
 * 播放帧率，默认值为 0，表示不自动切换图片，图片单帧静态展示。
 * <br>帧率最高不超过 30fps，如果设置帧率高于视频流帧率，则按照视频流帧率展示。
 * @endif
 */
@property (nonatomic, assign) NSUInteger fps;

/**
 * @if English
 * Specifies whether to set a loop. The default value is true. If the value is set to false, a watermark disappears when the playback of images ends.
 * @endif
 * @if Chinese
 * 是否设置循环，默认值为 true，设置为 false 时图像组播放完毕后水印消失。
 * @endif
 */
@property (nonatomic, assign) BOOL loop;

@end

NERTC_EXPORT @interface NERtcVideoWatermarkTextConfig : NSObject

/**
 * @if English
 * Text content. If the value is set to empty, the text watermark is not added.
 * @endif
 * @if Chinese
 * 文字内容，设置为空时，表示不添加文字水印。
 * @endif
 */
@property (nonatomic, copy) NSString *content;

/**
 * @if Chinese
 * 字体名称。
 * @endif
 */
@property (nonatomic, copy) NSString *fontName;

/**
 * @if English
 * font color in ARGB format. The default value is 0xffffffff, white.
 * @endif
 * @if Chinese
 * 字体颜色。ARGB 格式。默认值为 0xFFFFFFFF，即白色。
 * @endif
 */
@property (nonatomic, assign) NSUInteger fontColor;

/**
 * @if English
 * font size. The default value is 15. Unit: px.
 * @endif
 * @if Chinese
 * 字体大小。默认值为 15，单位为像素(px)。
 * @endif
 */
@property (nonatomic, assign) NSUInteger fontSize;

/**
 * @if English
 * Overall watermark transparency. Value range: 0.0 ~ 1.0. Default value: 1.0 represents no transparency.
 * @endif
 * @if Chinese
 * 整体水印透明度，取值范围为 0.0 ~ 1.0，默认值为 1.0，表示不透明。
 * @endif
 */
@property (nonatomic, assign) CGFloat wmAlpha;

/**
 * @if English
 * The background color of a watermark box. Format:ARGB. The format is 0x8888888888 by default, or gray. Supports transparency setting.
 * @endif
 * @if Chinese
 * 水印框内背景颜色。ARGB 格式，默认值为 0x88888888，即灰色。
 * <br>支持透明度设置。
 * @endif
 */
@property (nonatomic, assign) NSUInteger wmColor;

/**
 * @if English
 * The width of a watermark box. Unit: px. The value is O by default, representing no watermark box.
 * @endif
 * @if Chinese
 * 水印框宽度，单位为像素(px) ，默认值为 0，表示没有水印框。
 * @endif
 */
@property (nonatomic, assign) NSUInteger wmWidth;

/**
 * @if English
 * The height of a watermark box. Unit: px. The value is 0 by default, representing no watermark box.
 * @endif
 * @if Chinese
 * 水印框高度，单位为像素(px) ，默认值为 0，表示没有水印框。
 * @endif
 */
@property (nonatomic, assign) NSUInteger wmHeight;

/**
 * @if English
 * The horizontal distance between the upper left corner of the screen and the upper left corner of the video image. Unit: px. Default value: 0.
 * @endif
 * @if Chinese
 * 水平左上角与视频图像左上角的水平距离，单位为像素，默认值为 0。
 * @endif
 */
@property (nonatomic, assign) NSUInteger offsetX;

/**
 * @if English
 * The vertical distance between the upper left corner of the screen and the upper left corner of the video image. Unit: px. Default value: 0.
 * @endif
 * @if Chinese
 * 水平左上角与视频图像左上角的垂直距离，单位为像素，默认值为 0。
 * @endif
 */
@property (nonatomic, assign) NSUInteger offsetY;

@end

NERTC_EXPORT @interface NERtcVideoWatermarkTimestampConfig : NSObject

/**
 * @if Chinese
 * 字体名称。
 * @endif
 */
@property (nonatomic, copy) NSString *fontName;

/**
 * @if English
 * font color in ARGB format. The default value is 0xffffffff, white.
 * @endif
 * @if Chinese
 * 字体颜色。ARGB 格式。默认为 0xFFFFFFFF，即白色。
 * @endif
 */
@property (nonatomic, assign) NSUInteger fontColor;

/**
 * @if English
 * font size. The default value is 15. Unit: px.
 * @endif
 * @if Chinese
 * 字体大小。默认值为 15，单位为像素(px)。
 * @endif
 */
@property (nonatomic, assign) NSUInteger fontSize;

/**
 * @if English
 * Overall watermark transparency. Value range: 0.0 ~ 1.0. Default value 1.0 represents no transparency.
 * @endif
 * @if Chinese
 * 整体水印透明度，取值范围为 0.0 ~ 1.0，默认值为 1.0，表示不透明。
 * @endif
 */
@property (nonatomic, assign) CGFloat wmAlpha;

/**
 * @if English
 * The background color in a watermark box in ARGB format. The default value is 0x88888888, gray.
 * <br>Transparency setting is supported.
 * @endif
 * @if Chinese
 * 水印框内背景颜色。ARGB 格式，默认为 0x88888888，即灰色。
 * <br>支持透明度设置。
 * @endif
 */
@property (nonatomic, assign) NSUInteger wmColor;

/**
 * @if English
 * The width of a watermark box. Unit: px. The default value 0 indicates no watermark box is applied.
 * @endif
 * @if Chinese
 * 水印框宽度，单位为像素(px) ，默认值为 0，表示没有水印框。
 * @endif
 */
@property (nonatomic, assign) NSUInteger wmWidth;

/**
 * @if English
 * The height of a watermark box. Unit: px. The default value 0 indicates no watermark box is applied.
 * @endif
 * @if Chinese
 * 水印框高度，单位为像素(px) ，默认值为 0，表示没有水印框。
 * @endif
 */
@property (nonatomic, assign) NSUInteger wmHeight;

/**
 * @if English
 * The horizontal distance between the upper left corner of the screen and the upper left corner of the video image. Unit: px. Default value: 0.
 * @endif
 * @if Chinese
 * 水平左上角与视频图像左上角的水平距离，单位为像素，默认值为 0。
 * @endif
 */
@property (nonatomic, assign) NSUInteger offsetX;

/**
 * @if English
 * The vertical distance between the upper left corner  of the screen and the upper left corner of the video image. Unit: px. Default value: 0.
 * @endif
 * @if Chinese
 * 水平左上角与视频图像左上角的垂直距离，单位为像素，默认值为 0。
 * @endif
 */
@property (nonatomic, assign) NSUInteger offsetY;

@end

/**
 * @if English
 * Video watermark settings. Three types of watermarks are supported. You can select one of the three types.
 * @endif
 * @if Chinese
 * 视频水印设置，目前支持三种类型的水印，但只能其中选择一种水印生效。
 * @endif
 */
NERTC_EXPORT @interface NERtcVideoWatermarkConfig : NSObject

/**
 * @if English
 * Video watermark types
 * @endif
 * @if Chinese
 * 视频水印类型。
 * @endif
 */
@property (nonatomic, assign) NERtcVideoWatermarkType watermarkType;

/**
 * @if English
 * Image watermark configuration. The setting takes effect only when watermarkType is set to kNERtcWatermarkTypeImage
 * @endif
 * @if Chinese
 * 图片水印配置，watermarkType = kNERtcVideoWatermarkTypeImage 时生效。
 * @endif
 */
@property (nonatomic, strong) NERtcVideoWatermarkImageConfig *imageWatermark;

/**
 * @if English
 * Text watermark configuration. The setting takes effect only when watermarkType is set to kNERtcWatermarkTypeText
 * @endif
 * @if Chinese
 * 文字水印配置，watermarkType = kNERtcVideoWatermarkTypeText 时生效。
 * @endif
 */
@property (nonatomic, strong) NERtcVideoWatermarkTextConfig *textWatermark;

/**
 * @if English
 * Timestamp watermark configuration. The setting takes effect only when watermarkType is set to kNERtcWatermarkTypeTimestamp
 * @endif
 * @if Chinese
 * 时间戳水印配置，watermarkType = kNERtcVideoWatermarkTypeTimeStamp 时生效。
 * @endif
 */
@property (nonatomic, strong) NERtcVideoWatermarkTimestampConfig *timestampWatermark;

@end

#pragma mark - Encryption

/**
 * @if English
 * Configure the media stream encryption mode and key.
 * @endif
 * @if Chinese
 * 配置媒体流加密模式和密钥。
 * @endif
 */
NERTC_EXPORT  @interface NERtcEncryptionConfig : NSObject
 
/**
 * @if English
 * Media stream encryption mode.
 * @endif
 * @if Chinese
 * 媒体流加密模式。
 * @endif
 */
@property (nonatomic, assign) NERtcEncryptionMode mode;
 
/**
 * @if English
 * Media stream encryption key. The key is of string type. We recommend that you set the key to a string that contains letters.
 * @endif
 * @if Chinese
 * 媒体流加密密钥。字符串类型，推荐设置为英文字符串。
 * @endif
 */
@property (nonatomic, copy, nullable) NSString *key;

/**
 * @if Chinese
 * 自定义加密回调 observer, mode 为自定义加密时需要设置
 * @endif
 */
@property (nonatomic, weak, nullable) id<NERtcEnginePacketObserver> observer;

@end

#pragma mark - privatization

/**
 * @if English
 * Configure private servers.
 * @note To use private servers, contact technical support for help.
 * @endif
 * @if Chinese
 * 私有化服务器配置项
 * @note 如需启用私有化功能，请联系技术支持获取详情
 * @endif
 */
NERTC_EXPORT  @interface NERtcServerAddresses : NSObject

/**
 * @if English
 * Gets information about the channel server.
 * @endif
 * @if Chinese
 * 获取通道信息服务器
 * @endif
 */
@property (nonatomic, copy, nullable) NSString *channelServer;

/**
 * @if English
 * Stats server.
 * @endif
 * @if Chinese
 * 统计上报服务器
 * @endif
 */
@property (nonatomic, copy, nullable) NSString *statisticsServer;

/**
 * @if English
 * Stats dispatch server.
 * @endif
 * @if Chinese
 * 统计调度服务器
 * @endif
 */
@property (nonatomic, copy, nullable) NSString *statisticsDispatchServer;

/**
 * @if English
 * Stats Backup server.
 * @endif
 * @if Chinese
 * 统计备份服务器
 * @endif
 */
@property (nonatomic, copy, nullable) NSString *statisticsBackupServer;

/**
 * @if English
 * The room server
 * @endif
 * @if Chinese
 * roomServer服务器
 * @endif
 */
@property (nonatomic, copy, nullable) NSString *roomServer;

/**
 * @if English
 * Compatibility configuration server
 * @endif
 * @if Chinese
 * 兼容性配置服务器
 * @endif
 */
@property (nonatomic, copy, nullable) NSString *compatServer;

/**
 * @if English
 * nos DNS server
 * @endif
 * @if Chinese
 * nos 域名解析服务器
 * @endif
 */
@property (nonatomic, copy, nullable) NSString *nosLbsServer;

/**
 * @if English
 * Default nos upload server
 * @endif
 * @if Chinese
 * 默认nos 上传服务器
 * @endif
 */
@property (nonatomic, copy, nullable) NSString *nosUploadSever;

/**
 * @if English
 * Gets the NOS token server
 * @endif
 * @if Chinese
 * 获取NOS token 服务器
 * @endif
 */
@property (nonatomic, copy, nullable) NSString *nosTokenServer;

/**
 * @if English
 * Specifies whether to use IPv6 addresses. (The default value is NO.)
 * @endif
 * @if Chinese
 * 是否使用ipv6地址(默认为NO)
 * @endif
 */
@property (nonatomic, assign) BOOL useIPv6;

/**
* Cloud proxy server
*/
@property (nonatomic, copy, nullable) NSString *cloudProxyServer;

/**
* WebSocket proxy server
*/
@property (nonatomic, copy, nullable) NSString *webSocketProxyServer;

/**
* Quic proxy server
*/
@property (nonatomic, copy, nullable) NSString *quicProxyServer;

/**
* Media proxy server
*/
@property (nonatomic, copy, nullable) NSString *mediaProxyServer;

@end

#pragma mark - NERtcLastmileProbeConfig

/** 
 * @if English
 * Configurations of the last-mile network probe test.
 * @endif
 * @if Chinese
 * Last mile 网络探测配置。 
 * @endif
 */
NERTC_EXPORT  @interface NERtcLastmileProbeConfig : NSObject

/**
 * @if English
 * Sets whether to test the uplink network. 
 * <br>Some users, for example, the audience in a kNERtcChannelProfileLiveBroadcasting channel, do not need such a test。
 * - true: test.
 * - false: do not test.
 * @endif
 * @if Chinese
 * 是否探测上行网络。
 * <br>不发流的用户，例如直播房间中的普通观众，无需进行上行网络探测。
 * - true: 探测。
 * - false: 不探测。
 * @endif
 */
@property(nonatomic, assign) BOOL probeUplink;

/**
 * @if English
 * Sets whether to test the downlink network:
 * - true: test.
 * - false: do not test.
 * @endif
 * @if Chinese
 * 是否探测下行网络。
 * - true: 探测。
 * - false: 不探测。
 * @endif
 */
@property(nonatomic, assign) BOOL probeDownlink;

/**
 * @if English
 * The expected maximum sending bitrate (bps) of the local user. 
 * <br>The value ranges between 100000 and 5000000. 
 * <br>We recommend setting this parameter according to the bitrate value set by `setLocalVideoConfig`.
 * @endif
 * @if Chinese
 * 本端期望的最高发送码率。
 * <br>单位为 bps，范围为 [100000, 5000000]。
 * <br>推荐参考 `setLocalVideoConfig` 中的码率值设置该参数的值。
 * @endif
 */
@property(nonatomic, assign) NSUInteger expectedUplinkBitrate;

/**
 * @if English
 * The expected maximum receiving bitrate (bps) of the local user. The value ranges between 100000 and 5000000.
 * @endif
 * @if Chinese
 * 本端期望的最高接收码率。
 * <br>单位为 bps，范围为 [100000, 5000000]。 
 * @endif
 */
@property(nonatomic, assign) NSUInteger expectedDownlinkBitrate;

@end

#pragma mark - NERtcLastmileProbeOneWayResult

/**
 * @if English 
 * The uplink or downlink last-mile network probe test result.
 * @endif
 * @if Chinese
 * 单向 Last mile 网络质量探测结果报告。 
 * @endif
 */
NERTC_EXPORT  @interface NERtcLastmileProbeOneWayResult : NSObject

/**
 * @if English
 * The packet loss rate (%).
 * @endif
 * @if Chinese
 * 丢包率（%）。
 * @endif
 */
@property(nonatomic, assign) NSUInteger packetLossRate;

/**
 * @if English
 * The network jitter (ms).
 * @endif
 * @if Chinese
 * 网络抖动，单位为毫秒 (ms)。
 * @endif
 */
@property(nonatomic, assign) NSUInteger jitter;

/**
 * @if English
 * The available band width (bps).
 * @endif
 * @if Chinese
 * 可用网络带宽预估，单位为 bps。
 * @endif
 */
@property(nonatomic, assign) NSUInteger availableBandwidth;

@end

#pragma mark - NERtcLastmileProbeResult

/** 
 * @if English
 * The uplink and downlink last-mile network probe test result.
 * @endif
 * @if Chinese
 * 上下行 Last mile 网络质量探测结果。 
 * @endif
 */
NERTC_EXPORT  @interface NERtcLastmileProbeResult : NSObject

/**
 * @if English
 * The state of the probe test.
 * @endif
 * @if Chinese
 * Last mile 质量探测结果的状态。
 * @endif
 */
@property(nonatomic, assign) NERtcLastmileProbeResultState state;

/**
 * @if English
 * The round-trip delay time (ms).
 * @endif
 * @if Chinese
 * 往返时延，单位为毫秒(ms)。
 * @endif
 */
@property(nonatomic, assign) NSUInteger rtt;

/**
 * @if English
 * The uplink last-mile network probe test result.
 * @endif
 * @if Chinese
 * 上行网络质量报告。
 * @endif
 */
@property(nonatomic, strong) NERtcLastmileProbeOneWayResult *uplinkReport;

/**
 * @if English
 * The downlink last-mile network probe test result.
 * @endif
 * @if Chinese
 * 下行网络质量报告。
 * @endif
 */
@property(nonatomic, strong) NERtcLastmileProbeOneWayResult *downlinkReport;

@end

#pragma mark -- Log setting

/**
 * @if English
 * Log-related settings
 * @endif
 * @if Chinese
 * 日志相关设置。
 * @endif
 */
NERTC_EXPORT  @interface NERtcLogSetting : NSObject

/**
 * @if English
 * The full path of the log directory. UTF-8 encoding.
 * @endif
 * @if Chinese
 * 日志目录的完整路径，采用UTF-8 编码。
 * @endif
 */
@property (nonatomic, copy) NSString *logDir;

/**
 * @if English
 * The log level for printing. The default level is info. For more information, see {@link NERtcLogLevel}.
 * @endif
 * @if Chinese
 * 打印的日志级别。默认为 info 级别。详细信息请参考 {@link NERtcLogLevel}。
 * @endif
 */
@property (nonatomic, assign) NERtcLogLevel logLevel;

@end

#pragma mark - Video Correction Config

/**
 * @if English
 * Video correction configuration
 * @endif
 * @if Chinese
 * 视频图像畸变矫正相关设置。
 * @endif
 */
NERTC_EXPORT  @interface NERtcVideoCorrectionConfiguration : NSObject

// 矫正区域的左上顶点（x 和 y 的取值范围为 0 ~ 1 的浮点数）
@property (nonatomic, assign) CGPoint topLeft;

// 矫正区域的右上顶点（x 和 y 的取值范围为 0 ~ 1 的浮点数）
@property (nonatomic, assign) CGPoint topRight;

// 矫正区域的左下顶点（x 和 y 的取值范围为 0 ~ 1 的浮点数）
@property (nonatomic, assign) CGPoint bottomLeft;

// 矫正区域的右下顶点（x 和 y 的取值范围为 0 ~ 1 的浮点数）
@property (nonatomic, assign) CGPoint bottomRight;

// 画布宽度（单位 px，使用外部视频渲染时需要传递）
@property (nonatomic, assign) CGFloat canvasWidth;

// 画布高度（单位 px，使用外部视频渲染时需要传递）
@property (nonatomic, assign) CGFloat canvasHeight;

// 是否镜像显示（使用外部视频渲染时需要传递）
@property (nonatomic, assign) BOOL enableMirror;

@end

#pragma mark - NERtcVirtualBackgroundSource

/**
 * @if English
 * The custom background image.
 * @since v4.6.10
 * @endif
 * @if Chinese
 * 自定义背景图像。
 * @since v4.6.10
 * @endif
 */
NERTC_EXPORT @interface NERtcVirtualBackgroundSource : NSObject

/**
 * @if English
 * The type of the custom background image. See #NERtcVirtualBackgroundSourceType.
 * @endif
 * @if Chinese
 * 自定义背景图片的类型。 请参阅#NERtcVirtualBackgroundSourceType。
 * @endif
 */
@property (nonatomic, assign) NERtcVirtualBackgroundSourceType backgroundSourceType;

/**
 * @if English
 * The color of the custom background image. The format is a hexadecimal integer defined by RGB, without the # sign,
 * such as 0xFFB6C1 for light pink. The default value is 0xFFFFFF, which signifies white. The value range
 * is [0x000000,0xFFFFFF]. If the value is invalid, the SDK replaces the original background image with a white
 * background image.
 * @note This parameter takes effect only when the type of the custom background image is `kNERtcBackgroundColor`.
 * @endif
 * @if Chinese
 * 自定义背景图像的颜色。格式为 RGB 定义的十六进制整数，不带 # 号。
 * <br> 例如 0xFFB6C1 代表浅粉色。默认值为 0xFFFFFF，表示白色。取值范围是 [0x000000,0xFFFFFF]。如果该值无效，SDK 将原始背景图片替换为白色的图片
 * @note 该参数仅在自定义背景图片类型为 `kNERtcBackgroundColor` 时生效。
 * @endif
 */
@property (nonatomic, assign) NSUInteger color;

/**
 * @if English
 * The local absolute path of the custom background image. PNG and JPG formats are supported.
 * @note This parameter takes effect only when the type of the custom background image is `kNERtcBackgroundImage`.
 * @endif
 * @if Chinese
 * 自定义背景图片的本地绝对路径。支持 PNG 和 JPG 格式。
 * @note 该参数仅在自定义背景图片类型为 `kNERtcBackgroundImage` 时生效。
 * @endif
 */
@property (nonatomic, copy) NSString *source;

/**
 * @if English
 * Customize the bokeh level of the background image.
 * @note This parameter takes effect only when the type of the custom background image is `kNERtcBackgroundBlur`.
 * @endif
 * @if Chinese
 * 自定义背景图的虚化程度。
 * @note 该参数仅在自定义背景图片类型为 `kNERtcBackgroundBlur` 时生效。
 * @endif
 */
@property (nonatomic, assign) NERtcBlurDegree blur_degree;

@end

#pragma mark - Audio Effect

/**
* @if English 
* Reverb parameters
* @endif 
* @if Chinese 
* 混响参数
* @endif
 */
NERTC_EXPORT @interface NERtcReverbParam : NSObject

/**
 * @if English
 * Wet sound signal. Value range: 0 ~ 1. The default value is 0.0f.
 * @endif
 * @if Chinese
 * 湿信号，取值范围为 0 ~ 1，默认值为 0.0f。
 * @endif
 */
@property (nonatomic, assign) float wetGain;

/**
 * @if English
 * Dry sound signal. Value range: 0 ~ 1. The default value is 1.0f.
 * @endif
 * @if Chinese
 * 干信号，取值范围为 0 ~ 1，默认值为 1.0f。
 * @endif
 */
@property (nonatomic, assign) float dryGain;

/**
 * @if English
 * Reverb damping. Value range: 0 ~ 1. The default value is 0.0f.
 * @endif
 * @if Chinese
 * 混响阻尼，取值范围为 0 ~ 1，默认值为 0.0f。
 * @endif
 */
@property (nonatomic, assign) float damping;

/**
 * @if English
 * Room size. Value range: 0.1 ~ 2. The default value is 0.1f.
 * @endif
 * @if Chinese
 * 房间大小，取值范围为 0.1 ~ 2，默认值为 0.1f。
 * @endif
 */
@property (nonatomic, assign) float roomSize;

/**
 * @if English
 * Decay time. Value range: 0.1 ~ 20. The default value is 0.1f.
 * @endif
 * @if Chinese 
 * 持续强度（余响），取值范围为 0.1 ~ 20，默认值为 0.1f。
 * @endif
 */
@property (nonatomic, assign) float decayTime;

/**
 * @if English
 * Pre-delay. Value range: 0 ~ 1.
 * @endif
 * @if Chinese
 * 延迟长度，取值范围为 0 ~ 1，默认值为 0.0f。
 * @endif
 */
@property (nonatomic, assign) float preDelay;

@end

#pragma mark - extraInfo

/**
 joinChannel 时的一些可选信息
 */
NERTC_EXPORT @interface NERtcJoinChannelOptions : NSObject

/**
 * 自定义信息，最长支持127个字符, 若超过127个字符，该参数无效。
 */
@property (nonatomic, nullable, copy) NSString *customInfo;

/**
 * @if Chinese
 * 权限密钥。能控制通话时长及媒体权限能力。如果是高级Token 鉴权场景，用户加入时需要设置权限密钥，该参数的值由您的业务服务器提供。
 * @endif
 */
@property (nonatomic, nullable, copy) NSString *permissionKey;

@end

/**
 joinChannel 回调时的一些可选信息
 */
NERTC_EXPORT @interface NERtcJoinChannelExtraInfo : NSObject

/**
 * 自定义信息，最长支持127个字符
 */
@property (nonatomic, copy) NSString *customInfo;


@end

/**
 onUserJoined 回调时的一些可选信息
 */
NERTC_EXPORT @interface NERtcUserJoinExtraInfo : NSObject

/**
 * 自定义信息，最长支持127个字符
 */
@property (nonatomic, copy) NSString *customInfo;

@end

/**
 onUserLeave 回调时的一些可选信息
 */
NERTC_EXPORT @interface NERtcUserLeaveExtraInfo : NSObject

/**
 * 自定义信息，最长支持127个字符
 */
@property (nonatomic, copy) NSString *customInfo;

@end

#pragma mark - preDecoder

/**
 * 编码完的音频帧数据
*/
NERTC_EXPORT @interface NERtcPreDecoderVideoInfo : NSObject
/**
* 视频帧宽
*/
@property (nonatomic, assign) int width;

/**
* 视频帧高
*/
@property (nonatomic, assign) int height;

/**
* 是否为关键帧
*/
@property (nonatomic, assign) BOOL isKeyFrame;

@end


/**
* 编码完的视频帧数据
*/
NERTC_EXPORT @interface NERtcPreDecoderAudioInfo : NSObject

/**
 * 每帧音频数据时间间隔:ms
 */
@property (nonatomic, assign) uint32_t perTimeMs;

/**
 * Opus TOC Byte
 */
@property (nonatomic, assign) uint8_t toc;

@end


/**
 * 编码完的媒体数据帧
 */
NERTC_EXPORT @interface NERtcPreDecoderFrameInfo : NSObject
/**
 * 媒体数据类型
 */
@property (nonatomic, assign) NERtcPreDecoderMediaType mediaType;

/**
 * 用户uid
 */
@property (nonatomic, assign) uint64_t uid;

/**
 * 时间戳:ms
 */
@property (nonatomic, assign) int64_t timestampMs;

/**
 * 编码后的媒体数据
 */
@property (nonatomic, assign) uint8_t *data;

/**
 * 有效数据长度
 */
@property (nonatomic, assign) int length;

/**
 * 编码器名称
 */
@property (nonatomic, copy) NSString *codec;

/**
 * 数据是否为主流或辅流数据
 */
@property (nonatomic, assign) BOOL isMainStream;

/**
 * 视频相关信息，仅mediaType为video\screenshare\之一时有效，其他情况为nil
 */
@property (nonatomic, strong) NERtcPreDecoderVideoInfo *videoInfo;

/**
 * 音频相关信息，仅mediaType为audio时有效，其他情况为nil
 */
@property (nonatomic, strong) NERtcPreDecoderAudioInfo *audioInfo;

@end

NERTC_EXPORT @interface NERtcVideoEncodedFrame : NSObject

/***
* 编码器类型
*/
@property (nonatomic, assign) NERtcVideoCodecType codecType;

/**
 * 帧类型
 */
@property (nonatomic, assign) NERtcNalFrameType frameType;

/**
 * 每一个nal长度 ，按顺序记录每一个nal的数据长度，长度之和不能超过nalData 的长度
 */
@property (nonatomic, copy) NSArray<NSNumber *> *nalLengths;

/**
 * 所有nal 的数据
 */
@property (nonatomic, assign) unsigned char *nalData;

/**
 * 时间戳， 单位微秒
 */
@property (nonatomic, assign) int64_t timestampUs;

/**
 * 视频宽
 */
@property (nonatomic, assign) int width;

/**
 * 视频高
 */
@property (nonatomic, assign) int height;

@end

/**
* 编码好的音频数据
*/
NERTC_EXPORT @interface NERtcAudioEncodedFrame : NSObject

/**
* 编码好的数据
*/
@property (nonatomic, assign) unsigned char *data;

/**
 * 时间戳,微秒
 */
@property (nonatomic, assign) int64_t timeStampUs;

/**
 * 音频采样率
 */
@property (nonatomic, assign) int sampleRate;

/**
 * 声道数
 */
@property (nonatomic, assign) int channels;

/**
 * 该编码片段中每个声道的样本数
 */
@property (nonatomic, assign) int samplesPerChannel;

/**
 * 数据长度
 */
@property (nonatomic, assign) int encodedLen;

/**
 * 编码时间, 单位为样本数, 如0、960、1920...递增
 */
@property (nonatomic, assign) uint32_t encodedTimestamp;

/**
 * 数据类型，opus
 */
@property (nonatomic, assign) NERtcPayLoadType payloadType;

/**
 * 音频数据音量标记，有效值[0,100]，用于后台ASL选路时参考。默认100。
 */
@property (nonatomic, assign) uint8_t rmsLevel;

@end

/** 3D音效算法中坐标信息。*/
NERTC_EXPORT  @interface NERtcPositionInfo : NSObject

/**
 发声坐标，表示左右
 */
@property(nonatomic, assign) CGFloat speakerPositionX;

/**
 发声坐标，表示上下
 */
@property(nonatomic, assign) CGFloat speakerPositionY;

/**
 发声坐标，表示前后
 */
@property(nonatomic, assign) CGFloat speakerPositionZ;

/**
 发声旋转角度，4元素
 */
@property(nonatomic, assign) CGFloat speakerQuaternionX;

/**
 发声旋转角度，4元素
 */
@property(nonatomic, assign) CGFloat speakerQuaternionY;

/**
 发声旋转角度，4元素
 */
@property(nonatomic, assign) CGFloat speakerQuaternionZ;

/**
 发声旋转角度，4元素
 */
@property(nonatomic, assign) CGFloat speakerQuaternionW;

/**
 听觉坐标，表示左右
 */
@property(nonatomic, assign) CGFloat headPositionX;

/**
 听觉坐标，表示上下
 */
@property(nonatomic, assign) CGFloat headPositionY;

/**
 听觉坐标，表示前后
 */
@property(nonatomic, assign) CGFloat headPositionZ;

/**
 听觉旋转角度，4元素
 */
@property(nonatomic, assign) CGFloat headQuaternionX;

/**
 听觉旋转角度，4元素
 */
@property(nonatomic, assign) CGFloat headQuaternionY;

/**
 听觉旋转角度，4元素
 */
@property(nonatomic, assign) CGFloat headQuaternionZ;

/**
 听觉旋转角度，4元素
 */
@property(nonatomic, assign) CGFloat headQuaternionW;

@end

/** 3D音效房间属性设置。*/
NERTC_EXPORT  @interface NERtcSpatializerRoomProperty : NSObject

/**
 * 房间大小 #NERtcSpatializerRoomCapacity ，默认值 #kNERtcSpatializerRoomCapacitySmall
 */
@property (nonatomic, assign) NERtcSpatializerRoomCapacity roomCapacity;

/**
 * 房间材质 #NERtcSpatializerMaterialName ，默认值 #kNERtcSpatializerMaterialTransparent
 */
@property (nonatomic, assign) NERtcSpatializerMaterialName material;

/**
 * 反射比例，默认值1.0
 */
@property (nonatomic, assign) CGFloat reflectionScalar;

/**
 * 混响增益比例因子，默认值1.0
 */
@property (nonatomic, assign) CGFloat reverbGain;

/**
 * 混响时间比例因子，默认值1.0
 */
@property (nonatomic, assign) CGFloat reverbTime;

/**
 * 混响亮度，默认值1.0
 */
@property (nonatomic, assign) CGFloat reverbBrightness;

@end

NERTC_EXPORT @interface NERtcPacket : NSObject

/**
 * 需要发送或接收的数据
 */
@property (nonatomic, assign) const unsigned char* buffer;

/**
 * 需要发送或接收的数据大小
 */
@property (nonatomic, assign) long size;

@end


NS_ASSUME_NONNULL_END
