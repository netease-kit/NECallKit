//
//  NIMGlobalDefs.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#ifndef NIMLib_NIMGlobalDefs_h
#define NIMLib_NIMGlobalDefs_h

#import <Foundation/Foundation.h>

/**
 *  消息内容类型枚举
 */
typedef NS_ENUM(NSInteger, NIMMessageType){
    /**
     *  文本类型消息
     */
    NIMMessageTypeText          = 0,
    /**
     *  图片类型消息
     */
    NIMMessageTypeImage         = 1,
    /**
     *  声音类型消息
     */
    NIMMessageTypeAudio         = 2,
    /**
     *  视频类型消息
     */
    NIMMessageTypeVideo         = 3,
    /**
     *  位置类型消息
     */
    NIMMessageTypeLocation      = 4,
    /**
     *  通知类型消息
     */
    NIMMessageTypeNotification  = 5,
    /**
     *  文件类型消息
     */
    NIMMessageTypeFile          = 6,
    /**
     *  提醒类型消息
     */
    NIMMessageTypeTip           = 10,
    /**
     *  机器人类型消息
     */
    NIMMessageTypeRobot         = 11,
    /**
     *  Rtc通话单
     */
    NIMMessageTypeRtcCallRecord = 12,
    /**
     *  自定义类型消息
     */
    NIMMessageTypeCustom        = 100
};

/**
 *  网络通话类型
 */
typedef NS_ENUM(NSInteger, NIMNetCallType){
    /**
     *  音频通话
     */
    NIMNetCallTypeAudio = 1,
    /**
     *  视频通话
     */
    NIMNetCallTypeVideo = 2,
};

/**
 *  NIM本地Error Domain
 */
extern NSString *const NIMLocalErrorDomain;

/**
 *  NIM服务器Error Domain
 */
extern NSString *const NIMRemoteErrorDomain;



/**
 *  本地错误码 (IM 和通用) Domain NIMLocalErrorDomain
 */
typedef NS_ENUM(NSInteger, NIMLocalErrorCode) {
    /**
     *  错误的参数
     */
    NIMLocalErrorCodeInvalidParam                 = 1,
    /**
     *  多媒体文件异常
     */
    NIMLocalErrorCodeInvalidMedia                 = 2,
    /**
     *  图片异常
     */
    NIMLocalErrorCodeInvalidPicture               = 3,
    /**
     *  url异常
     */
    NIMLocalErrorCodeInvalidUrl                   = 4,
    /**
     *  读取/写入文件失败
     */
    NIMLocalErrorCodeIOError                      = 5,
    /**
     *  无效的token
     */
    NIMLocalErrorCodeInvalidToken                 = 6,
    /**
     *  Http请求失败
     */
    NIMLocalErrorCodeHttpReqeustFailed            = 7,
    /**
     *  无录音权限
     */
    NIMLocalErrorCodeAudioRecordErrorNoPermission = 8,
    /**
     *  录音初始化失败
     */
    NIMLocalErrorCodeAudioRecordErrorInitFailed   = 9,
    /**
     *  录音失败
     */
    NIMLocalErrorCodeAudioRecordErrorRecordFailed   = 10,
    /**
     *  播放初始化失败
     */
    NIMLocalErrorCodeAudioPlayErrorInitFailed     = 11,
    /**
     *  SQL语句执行失败
     */
    NIMLocalErrorCodeSQLFailed                    = 12,
    /**
     *  用户信息缺失 (未登录 或 未提供用户资料)
     */
    NIMLocalErrorCodeUserInfoNeeded               = 13,
    
    /**
     *  AppKey 缺失，未注册 AppKey 就进行登录行为之类的接口
     */
    NIMLocalErrorCodeAppKeyNeed                   = 14,
    
    /**
     *  自动登录超过次数限制，一般情况下都是当前网络有问题引起，如当前网络可以连接，但无法自由收发包等
     */
    
    NIMLocalErrorCodeAutoLoginRetryLimit          = 15,
    
    /**
     *  相同的操作正在执行，请不要多次调用
     */
    NIMLocalErrorCodeSameOperationInProgress      = 16,
    
    /**
     *  独立模式下获取聊天室服务器地址失败
     */
    NIMLocalErrorCodeRequestChatroomAddressesFailed= 17,
    
    /**
     *  群已读回执功能未开启，请使用 NIMSDKConfig 进行开启
     */
    NIMLocalErrorCodeTeamReceiptDisabled            = 18,
    
    /**
     *  主动取消任务
     */
    NIMLocalErrorCodeManualCancelTask = 19,
    /**
     *  资源过期
     */
    NIMLocalErrorCodeResourcesOverdue = 20,
    /**
     *  场景未注册
     */
    NIMLocalErrorCodeSceneUnregistered = 21,
    /**
     *  Database 读写异常
     */
    NIMLocalErrorCodeDatabaseError = 22,
    /**
     *  重复加入白板会议
     */
    NIMLocalErrorCodeJoinSameRTSConference = 23,
    
    /**
     *  功能不支持
     */
    NIMLocalErrorCodeNotSupported = 24,

    /**
     *  未知问题
     */
    NIMLocalErrorCodeUnknownError = 25,

    /**
     *  保存文件失败
     */
    NIMLocalErrorCodeSaveFileError = 26,
    /**
     *  接口调用过于频繁
     */
    NIMLocalErrorCodeFrequentCallError = 27,
    /**
     *   和设置冲突
     */
    NIMLocalErrorCodeSettingConflictError = 28,
};




/**
 *  服务器错误码 (IM 和通用) Doamin NIMRemoteErrorDomain
 *  @discussion 更多错误详见 [服务器端状态码](http://dev.netease.im/docs?doc=nim_status_code#服务器端状态码)
 *  用户第三方回调自定义错误码范围 20000-20099
 */
typedef NS_ENUM(NSInteger, NIMRemoteErrorCode) {
    /**
     *  客户端版本错误
     */
    NIMRemoteErrorCodeInvalidVersion      = 201,
    /**
     *  密码错误
     */
    NIMRemoteErrorCodeInvalidPass         = 302,
    /**
     *  CheckSum校验失败
     */
    NIMRemoteErrorCodeInvalidCRC          = 402,
    /**
     *  非法操作或没有权限
     */
    NIMRemoteErrorCodeForbidden           = 403,
    /**
     *  请求的目标（用户或对象）不存在
     */
    NIMRemoteErrorCodeNotExist            = 404,
    /**
     *  对象只读
     */
    NIMRemoteErrorCodeReadOnly            = 406,
    /**
     *  请求过程超时
     */
    NIMRemoteErrorCodeTimeoutError        = 408,
    /**
     *  参数错误
     */
    NIMRemoteErrorCodeParameterError      = 414,
    /**
     *  网络连接出现错误
     */
    NIMRemoteErrorCodeConnectionError     = 415,
    /**
     *  操作太过频繁
     */
    NIMRemoteErrorCodeFrequently          = 416,
    /**
     *  对象已经存在
     */
    NIMRemoteErrorCodeExist               = 417,
    /**
     *  数量超限
     */
    NIMRemoteErrorCodeBeyondLimit         = 419,
    /**
     *  账号被禁用
     */
    NIMRemoteErrorAccountBlock            = 422,
    /**
     *  未知错误
     */
    NIMRemoteErrorCodeUnknownError        = 500,
    /**
     *  服务器数据错误
     */
    NIMRemoteErrorCodeServerDataError     = 501,
    /**
     *  不足
     */
    NIMRemoteErrorCodeNotEnough           = 507,
    /**
     *  超过期限
     */
    NIMRemoteErrorCodeDomainExpireOld     = 508,
    /**
     *  无效协议
     */
    NIMRemoteErrorCodeInvalidProtocol     = 509,
    /**
     *  用户不存在
     */
    NIMRemoteErrorCodeUserNotExist        = 510,
    /**
     *  服务不可用
     */
    NIMRemoteErrorCodeServiceUnavailable  = 514,
    /**
     *  群人数超过上限
     */
    NIMRemoteErrorCodeTeamMemberLimit     = 801,
    /**
     *  没有操作群的权限
     */
    NIMRemoteErrorCodeTeamAccessError     = 802,
    /**
     *  群组不存在
     */
    NIMRemoteErrorCodeTeamNotExists       = 803,
    /**
     *  用户不在兴趣组内
     */
    NIMRemoteErrorCodeNotInTeam           = 804,
    /**
     *  群类型错误
     */
    NIMRemoteErrorCodeTeamInvaildType     = 805,
    /**
     *  超出群个数限制
     */
    NIMRemoteErrorCodeTeamCountLimit      = 806,
    /**
     *  已经在群里
     */
    NIMRemoteErrorCodeTeamAlreadyIn       = 809,
    /**
     *   不是群成员
     */
    NIMRemoteErrorCodeTeamNotMember       = 810,
    /**
     *  在群黑名单中
     */
    NIMRemoteErrorCodeTeamBlackList       = 812,
    /**
     *  请求群信息列表部分成功
     */
    NIMRemoteErrorCodeTeamsPartialSuccess = 816,
    /**
     *  解包错误
     */
    NIMRemoteErrorCodeEUnpacket           = 998,
    /**
     *  打包错误
     */
    NIMRemoteErrorCodeEPacket             = 999,
    
    /**
     *  在对方的黑名单中
     */
    NIMRemoteErrorCodeInBlackList         = 7101,
    
    /**
     *  聊天室状态异常
     */
    NIMRemoteErrorCodeInvalidChatroom     = 13002,
    /**
     *  账号在黑名单中,不允许进入聊天室
     */
    NIMRemoteErrorCodeInChatroomBlackList = 13003,
    /**
     *  在禁言列表中,不允许发言
     */
    NIMRemoteErrorCodeInChatroomMuteList  = 13004,
    /**
     *  聊天室处于整体禁言状态,只有管理员能发言
     */
    NIMRemoteErrorCodeInChatroomAllMute   = 13006,
    /**
     *  通用音视频协议：对方云信不在线
     */
    NIMRemoteErrorCodeSignalResPeerNIMOffline = 10201,
    /**
     *  通用音视频协议：对方推送亦不可达
     */
    NIMRemoteErrorCodeSignalResPeerPushOffline = 10202,
    /**
     *  通用音视频协议：房间不存在
     */
    NIMRemoteErrorCodeSignalResRoomNotExists = 10404,
    /**
     *  通用音视频协议：房间已存在
     */
    NIMRemoteErrorCodeSignalResRoomHasExists = 10405,
    /**
     *  通用音视频协议：不在房间内
     */
    NIMRemoteErrorCodeSignalResRoomMemberNotExists = 10406,
    /**
     *  通用音视频协议：已经在房间内
     */
    NIMRemoteErrorCodeSignalResRoomMemberHasExists = 10407,
    /**
     *  通用音视频协议：邀请不存在或已过期
     */
    NIMRemoteErrorCodeSignalResInviteNotExists = 10408,
    /**
     *  通用音视频协议：邀请已经拒绝
     */
    NIMRemoteErrorCodeSignalResInviteHasReject = 10409,
    /**
     *  通用音视频协议：邀请已经接受了
     */
    NIMRemoteErrorCodeSignalResInviteHasAccept = 10410,
    /**
     *  通用音视频协议：uid冲突
     */
    NIMRemoteErrorCodeSignalResUidConflict = 10417,
    /**
     *  通用音视频协议：房间人数超限
     */
    NIMRemoteErrorCodeSignalResRoomMemberExceed = 10419,
};

/**
 *  用户资料场景（头像等）
 */
extern NSString *const NIMNOSSceneTypeAvatar;

/**
 *  IM 消息 （图片，文件，音频，视频消息发送）
 */
extern NSString *const NIMNOSSceneTypeMessage;

/**
*  用户资料场景（下载权限）
*/
extern NSString *const NIMNOSSceneTypeSecurity;

#endif
