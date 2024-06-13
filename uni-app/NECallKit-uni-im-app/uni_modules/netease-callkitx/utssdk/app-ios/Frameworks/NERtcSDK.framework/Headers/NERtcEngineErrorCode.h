/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @if English
 * Engine Error Code
 * @endif
 * @if Chinese
 * Engine Error Code。
 * @endif
 */
typedef NS_ENUM(int, NERtcError) {

    /**
     * @if English
     * No errors
     * @endif
     * @if Chinese
     * 没有错误。
     * @endif
     */
    kNERtcNoError = 0,
    /**
     * @if English
     * No permissions. Reasons:
     * - The Audio and Video Call service is not activated. The trial period expires. The service is not renewed.
     * - Token is not set when a user joins a room in safe mode.
     * - Others issues.
     * @endif
     * @if Chinese
     * 权限不足。原因包括：。
     * - 未开通音视频通话 2.0 服务，或试用期已过、未及时续费等。
     * - 安全模式下加入房间时未设置 Token。
     * - 其他权限问题。 
     * @endif
     */
    KNERtcErrChannelReservePermissionDenied = 403,
    /**
     * @if English
     * The request timed out
     * @endif
     * @if Chinese
     * 请求超时。
     * @endif
     */  
    kNERtcErrChannelReserveTimeOut = 408,  
    /**
     * @if English
     * Request parameters error
     * @endif
     * @if Chinese
     * 服务器请求参数错误 。
     * @endif
     */          
    kNERtcErrChannelReserveErrorParam = 414,
    /**
     * @if English
     * Invalid APP KEY 
     * @endif
     * @if Chinese
     * 非法的APP KEY。
     * @endif
     */     
    kNERtcErrChannelReserveErrorAppKey = 417,
    /**
     * @if English
     * Server error in allocating rooms
     * @endif
     * @if Chinese
     * 分配房间的服务器未知错误。
     * @endif
     */
    kNERtcErrChannelReserveUnknownError = 500,
    /**
     * @if English
     * Only two users are supported. A third user tries to allocate a room with the same room name.
     * @endif
     * @if Chinese
     * 登录房间的用户数超过限制的两人。
     * @endif
     */     
    kNERtcErrChannelReserveMoreThanTwoUser = 600,
    /**
     * @if Chinese
     * 登录房间时权限密钥错误。
     * @endif
     */
    kNERtcErrChannelPermissionKeyError = 901,
    /**
     * @if Chinese
     * 登录房间时权限密钥过期。
     * @endif
     */
    kNERtcErrChannelPermissionKeyTimeout = 902,
  
    // LiveStream 操作失败错误
    /**
     * @if Chinese
     * task请求无效，被后续操作覆盖。
     * @endif
     */
    kNERtcErrLiveStreamInvaildRequest = 1301,
    /**
     * @if Chinese
     * task参数格式错误。
     * @endif
     */
    kNERtcErrLiveStreamInvaildParameters = 1400,
    /**
     * @if Chinese
     * 房间已经退出。
     * @endif
     */
    kNERtcErrLiveStreamRoomHasExited = 1401,
    /**
     * @if Chinese
     * 推流任务超出上限。
     * @endif
     */
    kNERtcErrLiveStreamExceedLimit = 1402,
    /**
     * @if Chinese
     * 推流 ID 重复。
     * @endif
     */
    kNERtcErrLiveStreamDuplicateId = 1403,
    /**
     * @if Chinese
     * taskId任务不存在，或房间不存在。
     * @endif
     */
    kNERtcErrLiveStreamNotFound = 1404,
    /**
     * @if Chinese
     * 请求失败。
     * @endif
     */
    kNERtcErrLiveStreamRequestFailed = 1417,
    /**
     * @if Chinese
     * 布局参数错误。
     * @endif
     */
    kNERtcErrLiveStreamInvalidLayout = 1501,
    /**
     * @if Chinese
     * 布局的图片错误。
     * @endif
     */
    kNERtcErrLiveStreamUserPictureError = 1502,
    /**
     * @if Chinese
     * 用户无发流权限。
     * @endif
     */
    kNERtcErrChannelNoPublishPermission = 1620,
    /**
     * @if Chinese
     * 用户无订阅权限。
     * @endif
     */
    kNERtcErrChannelNoSubscribePermission = 2803,
     /**
      * @if Chinese
      * 主播人数达到限制
      * @endif
      */
    kNERtcErrServerBroadcasterReachedTheLimit = 4001,
    /**
     * @if Chinese
     * 加入房间的人数达到限制
     * @endif
     */
    kNERtcErrServerPersonsInRoomReachedTheLimit = 4003,
    
    //Engine error code
    // 主业务操作失败错误码
    /**
     * @if English
     * Common error
     * @endif
     * @if Chinese
     * 通用错误。
     * @endif
     */
    kNERtcErrFatal = 30001, 
    /**
     * @if English
     * Out of memory
     * @endif
     * @if Chinese
     * 内存耗尽。
     * @endif
     */                  
    kNERtcErrOutOfMemory = 30002,  
    /**
     * @if English
     * Invalid parameter
     * @endif
     * @if Chinese
     * 参数错误。
     * @endif
     */           
    kNERtcErrInvalidParam = 30003,    
    /**
     * @if English
     * Unsupported operation
     * @endif
     * @if Chinese
     * 不支持的操作。
     * @endif
     */        
    kNERtcErrNotSupported = 30004,
    /**
     * @if English
     * Operations not supported by the current state
     * @endif
     * @if Chinese
     * 状态错误。
     * @endif
     */            
    kNERtcErrInvalidState = 30005,  
    /**
     * @if English
     * Resource exhausted
     * @endif
     * @if Chinese
     * 缺乏资源。
     * @endif
     */          
    kNERtcErrLackOfResource = 30006,  
    /**
     * @if English
     * Invalid index 
     * @endif
     * @if Chinese
     * index 序号非法。
     * @endif
     */        
    kNERtcErrInvalidIndex = 30007, 
    /**
     * @if English
     * Device not found
     * @endif
     * @if Chinese
     * 设备未找到。
     * @endif
     */           
    kNERtcErrDeviceNotFound = 30008,  
    /**
     * @if English
     * Invalid device ID 
     * @endif
     * @if Chinese
     * 设备 ID 不存在。
     * @endif
     */        
    kNERtcErrInvalidDeviceSourceID = 30009,  
    /**
     * @if English
     * Invalid video profile type 
     * @endif
     * @if Chinese
     * 视频能力profile type不符合要求。
     * @endif
     */ 
    kNERtcErrInvalidVideoProfile = 30010, 
     /**
     * @if English
     * Device source error
     * @endif
     * @if Chinese
     * 创建设备失败。
     * @endif
     */    
    kNERtcErrCreateDeviceSourceFail = 30011,   
    /**
     * @if English
     * Invalid rendering container
     * @endif
     * @if Chinese
     * 画布非法。
     * @endif
     */
    kNERtcErrInvalidRender = 30012,          
    /**
     * @if English
     * The device already turned on
     * @endif
     * @if Chinese
     * 本地视频预览已打开。
     * @endif
     */ 
    kNERtcErrDevicePreviewAlreadyStarted = 30013,  
    /**
     * @if English
     * Transmission error
     * @endif
     * @if Chinese
     * 传输错误。
     * @endif
     */
    kNERtcErrTransmitPendding = 30014,   
    /**
     * @if English
     * Connecting server error
     * @endif
     * @if Chinese
     * 连接服务器失败。
     * @endif
     */     
    kNERtcErrConnectFail = 30015,
    /**
     * @if English
     * Fails to create Audio dump file.
     * @endif
     * @if Chinese
     * 创建Audio dump文件失败。
     * @endif
     */
    kNERtcErrCreateDumpFileFail = 30016,
    /**
     * @if English
     * Fails to enable Audio dump file.
     * @endif
     * @if Chinese
     * 开启Audio dump失败。
     * @endif
     */
    kNERtcErrStartDumpFail = 30017,
    /**
     * @if English
     * Fails to enable desktop screen recording if camera is started at the same time.
     * @endif
     * @if Chinese
     * 启动桌面录屏失败，不能与摄像头同时启动。
     * @endif
     */
    kNERtcErrDesktopCaptureInvalidState = 30020,
    /**
     * @if English
     * Parameters are invalid when the desktop screen recording is implemented.
     * @endif
     * @if Chinese
     * 桌面录屏传入参数无效。
     * @endif
     */
    kNERtcErrDesktopCaptureInvalidParam = 30021,
    /**
     * @if English
     * Desktop screen recording is not ready.
     * @endif
     * @if Chinese
     * 桌面录屏未就绪。
     * @endif
     */
    kNERtcErrDesktopCaptureNotReady = 30022,
    /**
     * @if English
     * Selected device is occupied.
     * @endif
     * @if Chinese
     * 所选设备已被占用。
     * @endif
    */
    kNERtcErrDeviceOccupied = 30027,
    /**
     * @if English
     * Join operation was interrupted due to leave action.
     * @endif
     * @if Chinese
     * Join 流程因外部调用 leave API 而中断
     * @endif
     */
    kNERtcErrJoinInterruptedDueToLeaveAction = 30028,
    /**
     * @if English
     * Join operation was interrupted due to destroy action.
     * @endif
     * @if Chinese
     * Join 流程因外部调用 destroy API 而中断
     * @endif
     */
    kNERtcErrJoinInterruptedDueToDestroyAction = 30029,
    /**
     * @if English
     * Join operation was interrupted due to app termination.
     * @endif
     * @if Chinese
     * Join 流程因 App 进程退出而中断
     * @endif
     */
    kNERtcErrJoinInterruptedDueToAppTermination = 30030,
    /**
     * @if English
     * A user already joined a room.
     * @endif
     * @if Chinese
     * 重复加入房间。
     * @endif
     */
    kNERtcErrChannelAlreadyJoined = 30100,      
    /**
     * @if English
     * A user has not joined the room.
     * @endif
     * @if Chinese
     * 用户未加入房间。
     * @endif
     */
    kNERtcErrChannelNotJoined = 30101,   
    /**
     * @if English
     * A user repeatedly leaves the room.
     * @endif
     * @if Chinese
     * 重复离开房间。
     * @endif
     */     
    kNERtcErrChannelRepleatedlyLeave = 30102,  
    /**
     * @if English
     * Fail to join the room.
     * @endif
     * @if Chinese
     * 请求加入房间失败。
     * @endif
     */
    kNERtcErrRequestJoinChannelFail = 30103,    
    /**
     * @if English
     * Session not found.
     * @endif
     * @if Chinese
     * 会话未找到。
     * @endif
     */
    kNERtcErrSessionNotFound = 30104,      
    /**
     * @if English
     * User not found
     * @endif
     * @if Chinese
     * 用户不存在。
     * @endif
     */   
    kNERtcErrUserNotFound = 30105,        
    /**
     * @if English
     * Invalid user ID 
     * @endif
     * @if Chinese
     * 非法用户。
     * @endif
     */    
    kNERtcErrInvalidUserID = 30106,   
    /**
     * @if English
     * Multimedia data is not transmitted.
     * @endif
     * @if Chinese
     * 用户多媒体数据未连接。
     * @endif
     */        
    kNERtcErrMediaNotStarted = 30107,  
    /**
     * @if English
     * source not found
     * @endif
     * @if Chinese
     * 媒体源未找到。
     * @endif
     */       
    kNERtcErrSourceNotFound = 30108,        
    /**
     * @if English
     * Invalid room status during switching
     * @endif
     * @if Chinese
     * 切换房间时不在会议中。
     * @endif
     */  
    kNERtcErrSwitchChannelInvalidState = 30109,
    /**
     * @if English
     * Invalid status during the media stream relay.
     * <br>The typical reason is repeated calling startChannelMediaRelay. If you want to call the startChannelMediaRelay method for another time, you must first call the stopChannelMediaRelay method to exit the current relaying status.
     * @endif
     * @if Chinese
     * 媒体流转发状态无效。
     * <br>原因通常为重复调用 startChannelMediaRelay。成功调用startChannelMediaRelay后，必须先调用 stopChannelMediaRelay 方法退出当前的转发状态，才能再次调用该方法。
     * @endif
     */
    kNERtcErrChannelMediaRelayInvalidState = 30110,
    /**
     * @if English
     * No permissions to relay media stream.
     * <br>Reasons:
     * - The type of the original room is a double room (1V1 mode). The media stream cannot be relayed at this moment.
     * - The member role that calls startChannelMediaRelay to relay media stream is audience. Only the host role can relay the media stream. 
     * @endif
     * @if Chinese
     * 没有权限转发媒体流。
     * <br>原因通常包括：
     * - 源房间的房间类型为双人房间（1V1模式）。此时无法转发媒体流。
     * - 调用 startChannelMediaRelay 开启媒体流转发的成员角色为观众角色，仅主播角色可以转发媒体流。
     * @endif
     */
    kNERtcErrChannelMediaRelayPermissionDenied = 30111,
    /**
     * @if English
     * Failed to stop relaying media stream.
     * The typical reason is that the media stream relay is disabled. Before you call stopChannelMediaRelay, make sure that you have called startChannelMediaRelay to enable the media stream relay. 
     * @endif
     * @if Chinese
     * 停止媒体流转发操作失败。
     * 原因通常为未开启媒体流转发。请确认调用 stopChannelMediaRelay 前，是否已成功调用 startChannelMediaRelay 开启媒体流转发。
     * @endif
     */
    kNERtcErrChannelMediaRelayStopFailed= 30112,
    /**
     * @if English
     * Failed to join the room because the specified media stream encryption key is inconsistent with the key specified by one or more of the members who join the room.
     * Reset the encryption key by calling enableEncryption.
     * @endif
     * @if Chinese
     * 设置的媒体流加密密钥与房间中其他成员不一致，加入房间失败。
     * 请通过 enableEncryption 重新设置加密密钥。
     * @endif
     */
    kNERtcErrEncryptNotSuitable= 30113,
    /**
     * @if English
     * User permkey auth failed.
     * @endif
     * @if Chinese
     * 高级 Token 鉴权失败，用户权限验证错误。
     * @endif
     */
    kNERtcErrUserPermKeyAuthFailed = 30121,
    /**
     * @if Chinese
     * SEI 超过最大数据限制。
     * @endif
     */
    kNERtcErrSEIExceedMaxDataLimit = 30122,
    /**
     * @if Chinese
     * 数据通道发送大小超过最大限制。
     * @endif
     */
    kNERtcErrDataChannelExceedMaxDataLimit = 30123,
    /**
     * @if English
     * Connection not found.
     * @endif
     * @if Chinese
     * 连接未找到。
     * @endif
     */
    kNERtcErrConnectionNotFound = 30200, 
    /**
     * @if English
     * Media stream not found
     * @endif
     * @if Chinese
     * 媒体流未找到。
     * @endif
     */     
    kNERtcErrStreamNotFound = 30201,    
     /**
     * @if English
     * Failed to join track.
     * @endif
     * @if Chinese
     * 添加媒体播放器音轨失败。
     * @endif
     */      
    kNERtcErrAddTrackFail = 30202, 
    /**
     * @if English
     * Track not found.
     * @endif
     * @if Chinese
     * 媒体播放器音轨未找到。
     * @endif
     */          
    kNERtcErrTrackNotFound = 30203,  
    /**
     * @if English
     * Media stream disconnected. 
     * @endif
     * @if Chinese
     * 媒体连接已断开。
     * @endif
     */         
    kNERtcErrMediaConnectionDisconnected = 30204,  
    /**
     * @if English
     * Signaling disconnected. 
     * @endif
     * @if Chinese
     * 信令断开。
     * @endif
     */  
    kNERtcErrSignalDisconnected = 30205,       
    /**
     * @if English
     * Removed from the room.
     * @endif
     * @if Chinese
     * 用户被管理员移出房间。
     * @endif
     */  
    kNERtcErrServerKicked = 30206,       
    /**
     * @if English
     * The room is deleted.
     * @endif
     * @if Chinese
     * 房间已被关闭。
     * @endif
     */     
    kNERtcErrChannelBeClosed = 30207,          
    /**
     * @if English
     * The room was closed due to the operation of switching rooms.
     * @endif
     * @if Chinese
     * 因为切换房间而离开房间。
     * @endif
     */  
    kNERtcErrChannelLeaveBySwitchAction = 30208,
    /**
     * @if English
     * The room was closed due to duplicate uid logins
     * @endif
     * @if Chinese
     * 因为重复 UID 登录而离开房间。
     * @endif
     */
    kNERtcErrChannelLeaveByDuplicateUidLogin = 30209,
    /**
     * @if English
     * Operating system permissions issue
     * @endif
     * @if Chinese
     * 操作系统权限问题。
     * @endif
     */
    kNERtcErrOSAuthorize = 30300,
    /**
     * @if English
     * have no audio device permissions
     * @endif
     * @if Chinese
     * 没有音频设备权限。
     * @endif
     */
    kNERtcRuntimeErrADMNoAuthorize = 40000,  
    /**
     * @if English
     * Failed to initialize the audio capture device
     * @endif
     * @if Chinese
     * 初始化音频采集设备（麦克风）失败。
     * @endif
     */ 
    kNERtcRuntimeErrADMInitRecording = 40001,   
    /**
     * @if English
     * Failed to start the audio capture device
     * @endif
     * @if Chinese
     * 启动音频采集设备（麦克风）失败。
     * @endif
     */
    kNERtcRuntimeErrADMStartRecording = 40002, 
    /**
     * @if English
     * Failed to stop the audio capture device
     * @endif
     * @if Chinese
     * 停止音频采集设备（麦克风）失败。
     * @endif
     */  
    kNERtcRuntimeErrADMStopRecording= 40003,   
    /**
     * @if English
     * Failed to initialize the audio playback device
     * @endif
     * @if Chinese
     * 音频播放设备初始化失败。
     * @endif
     */  
    kNERtcRuntimeErrADMInitPlayout = 40004,  
    /**
     * @if English
     * Failed to start the audio playback device
     * @endif
     * @if Chinese
     * 音频播放设备启动失败。
     * @endif
     */ 
    kNERtcRuntimeErrADMStartPlayout = 40005,   
    /**
     * @if English
     * Failed to stop the audio playback device
     * @endif
     * @if Chinese
     * 音频播放设备停止失败
     * @endif
     */
    kNERtcRuntimeErrADMStopPlayout = 40006,
    /**
     * @if English
     * @endif
     * @if Chinese
     * 音频采集设备运行异常。
     * @endif
     */
    kNERtcRuntimeErrADMRecordingFailed = 40007,
    /**
     * @if English
     * @endif
     * @if Chinese
     * 音频播放设备运行异常。
     * @endif
     */
    kNERtcRuntimeErrADMPlayoutFailed = 40008,
    /**
     * @if English
     * audio device permissions is not determined
     * @endif
     * @if Chinese
     * 音频设备权限未确定。
     * @endif
     */
    kNERtcRuntimeErrADMAuthorizeNotDetermined = 40009,
    /**
     * @if English
     * Have no video device permissions
     * @endif
     * @if Chinese
     * 没有视频设备权限。
     * @endif
     */
    kNERtcRuntimeErrVDMNoAuthorize = 50000,     
    /**
     * @if English
     * Use substream without the screen-sharing stream
     * @endif
     * @if Chinese
     * 非屏幕共享使用辅流。
     * @endif
     */
    kNERtcRuntimeErrVDMNotScreenUseSubStream = 50001,
    /**
     * @if English
     * @endif
     * @if Chinese
     * 摄像头断开。
     * @endif
     */
    kNERtcRuntimeErrVDMCameraDisconnect = 50303,
    /**
     * @if English
     * @endif
     * @if Chinese
     * 摄像头死机。
     * @endif
     */
    kNERtcRuntimeErrVDMCameraFreezed = 50304,
    /**
     * @if English
     * @endif
     * @if Chinese
     * 未知摄像头错误。
     * @endif
     */
    kNERtcRuntimeErrVDMCameraUnknownError = 50305,
    /**
     * @if English
     * @endif
     * @if Chinese
     * 摄像头无数据帧。
     * @endif
     */
    kNERtcRuntimeErrVDMCameraNoFrame = 50306,
    /**
     * @if English
     * @endif
     * @if Chinese
     * 摄像头启动失败。
     * @endif
     */
    kNERtcRuntimeErrVDMCameraCreateFail = 50307,
    /**
     * @if English
     * @endif
     * @if Chinese
     * 没有录制视频权限。
     * @endif
     */
    kNERtcRuntimeErrVDMScreenCaptureNoAuthorize = 50400,
};

typedef NS_ENUM(int, NERtcWarning) {

    /**
     * @if English
     * No errors
     * @endif
     * @if Chinese
     * 没有错误
     * @endif
     */
    kNERtcNoWarning = 0,
    /**
     * @if English
     * The video encoding capability of the current client device does not match the encoding support of the room. For example, the device does not support encoding types such as VP8. In this room, video streams cannot be encoded and decoded. In this case, the local client may not be able to display some remote videos, and the remote client may be unable to display videos from the local client. 
     * @endif
     * @if Chinese
     * 当前客户端设备视频编解码能力与房间不匹配，例如设备不支持 VP8 等编码类型。在此房间中可能无法成功进行视频编解码，即本端可能无法正常显示某些远端的视频画面，同样远端也可能无法显示本端画面。
     * @endif
     */
    KNERtcWarningChannelAbilityNotMatch = 406,
    /**
     * @if English
     * Automatic audio quality fallback.
     * @endif
     * @if Chinese
     * 音频自动选路回退。
     * @endif
     */
    kNERtcWarningASLFallback = 407,
};

/**
 * @if English
 * LiveStream Error Code
 * @endif
 * @if Chinese
 * LiveStream Error Code。
 * @endif
 *
 *  Will be deprecated, please use NERtcError instead
 */

typedef NS_ENUM(int, kNERtcLiveStreamError) {

    /**
     * @if English
     * The task request is invalid and overwritten by subsequent operations
     * @endif
     * @if Chinese
     * task请求无效，被后续操作覆盖。
     * @endif
     */
    kNERtcLiveStreamErrorRequestIsInvaild = 1301, 

    /**
     * @if English
     * The task parameter has an invalid format
     * @endif
     * @if Chinese
     * task参数格式错误。
     * @endif
     */         
    kNERtcLiveStreamErrorIsInvaild = 1400, 
    /**
     * @if English
     * The client already leaves the room
     * @endif
     * @if Chinese
     * 房间已经退出。
     * @endif
     */               
    kNERtcLiveStreamErrorRoomExited = 1401, 

    /**
     * @if English
     * The number of streaming tasks reaches the upper limit.
     * @endif
     * @if Chinese
     * 推流任务超出上限。
     * @endif
     */
    kNERtcLiveStreamErrorNumLimit = 1402,   

    /**
     * @if English
     * Duplicate ID of a streaming task
     * @endif
     * @if Chinese
     * 推流ID重复。
     * @endif
     */                 
    kNERtcLiveStreamErrorDuplicateId = 1403, 

    /**
     * @if English
     * The task ID does not exist, or the room does not exist
     * @endif
     * @if Chinese
     * taskId任务不存在，或房间不存在。
     * @endif
     */        
    kNERtcLiveStreamErrorNotFound = 1404,        
    /**
     * @if English
     * Request failed
     * @endif
     * @if Chinese
     * 请求失败。
     * @endif
     */
    kNERtcLiveStreamErrorRequestErr = 1417,  

     /**
     * @if English
     * Server internal error
     * @endif
     * @if Chinese
     * 服务器内部错误。
     * @endif
     */  
    kNERtcLiveStreamErrorInternalServerErr = 1500,   

    /**
     * @if English
     * The layout parameter is invalid
     * @endif
     * @if Chinese
     * 布局参数错误。
     * @endif
     */    
    kNERtcErrLsTaskInvalidLayout = 1501,          
    /**
     * @if English
     * User picture error
     * @endif
     * @if Chinese
     * 用户图片错误。
     * @endif
     */        
    kNERtcErrLsTaskUserPicErr = 1512,                     
};


extern __attribute__((visibility("default"))) NSString * const NERtcReserveChannelErrorDomain;
extern __attribute__((visibility("default"))) NSString * const NERtcRoomServerErrorDomain;
extern __attribute__((visibility("default"))) NSString * const NERtcLocalErrorDomain;
extern __attribute__((visibility("default"))) NSString * const NERtcRemoteErrorDomain;

#ifdef __cplusplus
extern "C" {
#endif
    


    /**
     * @if English
     * Gets the error code description
     * @param errorCode The error codes. For more information, see {@link NERtcEngineErrorCode.NERtcError}.
     * @return The strings in the description.
     * @endif
     * @if Chinese
     * 获取错误码描述。
     * @param errorCode 错误码，详细信息请参考 {@link NERtcEngineErrorCode.NERtcError}。
     * @return 描述字符串。
     * @endif
     */
__attribute__((visibility("default")))  NSString * NERtcErrorDescription(int errorCode);
    
#ifdef __cplusplus
} // extern "C"
#endif

NS_ASSUME_NONNULL_END
