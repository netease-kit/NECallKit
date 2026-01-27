//
//  V2NIMSignallingRequest.h
//  NIMSDK
//
//  Created by Netease on 2024/5/21.
//  Copyright © 2024 Netease. All rights reserved.
//
#import <Foundation/Foundation.h>

@class V2NIMSignallingConfig;
@class V2NIMSignallingPushConfig;
@class V2NIMSignallingRtcConfig;
@class V2NIMSignallingChannelInfo;
@class V2NIMSignallingRtcInfo;
@class V2NIMSignallingRoomInfo;
@class V2NIMSignallingMember;

NS_ASSUME_NONNULL_BEGIN
#pragma mark - 信令频道类型
typedef NS_ENUM(NSInteger,V2NIMSignallingChannelType) {
    /** 音频频道 */
    V2NIM_SIGNALLING_CHANNEL_TYPE_AUDIO = 1,
    /** 视频频道 */
    V2NIM_SIGNALLING_CHANNEL_TYPE_VIDEO,
    /** 自定义频道 */
    V2NIM_SIGNALLING_CHANNEL_TYPE_CUSTOM,
};
#pragma mark - 信令频道事件类型
typedef NS_ENUM(NSInteger,V2NIMSignallingEventType) {
    /** 未知 */
    V2NIM_SIGNALLING_EVENT_TYPE_UNKNOWN = 0,
    /** 关闭信令频道房间 */
    V2NIM_SIGNALLING_EVENT_TYPE_CLOSE = 1,
    /** 加入信令频道房间 */
    V2NIM_SIGNALLING_EVENT_TYPE_JOIN = 2,
    /** 邀请加入信令频道房间 */
    V2NIM_SIGNALLING_EVENT_TYPE_INVITE = 3,
    /** 取消邀请加入信令频道房间 */
    V2NIM_SIGNALLING_EVENT_TYPE_CANCEL_INVITE = 4,
    /** 拒绝邀请 */
    V2NIM_SIGNALLING_EVENT_TYPE_REJECT = 5,
    /** 接受邀请 */
    V2NIM_SIGNALLING_EVENT_TYPE_ACCEPT = 6,
    /** 离开信令频道房间 */
    V2NIM_SIGNALLING_EVENT_TYPE_LEAVE = 7,
    /** 自定义控制命令 */
    V2NIM_SIGNALLING_EVENT_TYPE_CONTROL = 8,
    /** 用户被踢 */
    V2NIM_SIGNALLING_EVENT_TYPE_KICK = 9,
};


#pragma makr - 直接呼叫请求参数
@interface V2NIMSignallingCallParams : NSObject
/**
 * 被呼叫者账号ID
 * 参数为空，或者为空串， 返回参数错误
 */
@property (nonatomic,copy) NSString *calleeAccountId;
/**
 * 请求ID，可以用UUID实现
 * 主要为了便于业务实现请求响应绑定
 * 参数为空，或者为空串， 返回参数错误
 */
@property (nonatomic,copy) NSString *requestId;
/**
 * 频道类型
 * 房间创建后跟频道类型绑定
 * 必须为枚举类型之一， 否则返回参数错误
 */
@property (nonatomic,assign) V2NIMSignallingChannelType channelType;
/**
 * 频道名称 建议使用与业务有相关场景的名称，便于页面显示
 */
@property (nonatomic,copy,nullable) NSString *channelName;
/**
 * 频道相关扩展字段， 长度限制4096， 跟频道绑定
 * json格式
 */
@property (nonatomic,copy,nullable) NSString *channelExtension;
/**
 * 服务器扩展字段， 长度限制4096
 * json格式
 */
@property (nonatomic,copy,nullable) NSString *serverExtension;
/**
 * 信令相关配置
 */
@property (nonatomic,strong,nullable) V2NIMSignallingConfig *signallingConfig;
/**
 * 推送相关配置
 */
@property (nonatomic,strong,nullable) V2NIMSignallingPushConfig *pushConfig;
/**
 * 音视频相关参数配置
 */
@property (nonatomic,strong,nullable) V2NIMSignallingRtcConfig *rtcConfig;
@end


#pragma makr - 信令相关配置
@interface V2NIMSignallingConfig : NSObject
/**
 * 是否需要存储离线消息。默认YES
 * YES：需要。
 * NO：不需要。
 */
@property (nonatomic,assign) BOOL offlineEnabled;

/**
 * 是否需要计算未读消息数。默认YES
 * YES：需要。
 * NO：不需要。
 */
@property (nonatomic,assign) BOOL unreadEnabled;

/**
 * 用户的UID。
 */
@property (nonatomic,assign) NSInteger selfUid;
@end


#pragma makr - 消息推送相关配置
@interface V2NIMSignallingPushConfig : NSObject
/**
 * 是否需要推送。默认为YES
 * YES：需要。
 * NO：不需要。
 */
@property (nonatomic,assign) BOOL pushEnabled;

/**
 * 推送标题
 * pushEnabled为YES必填
 */
@property (nonatomic,copy,nullable) NSString *pushTitle;

/**
 * 推送文案
 * pushEnabled为YES必填
 */
@property (nonatomic,copy,nullable) NSString *pushContent;

/**
 * 推送数据
 * pushEnabled为YES必填
 */
@property (nonatomic,copy,nullable) NSString *pushPayload;
@end


#pragma makr - 音视频相关配置
@interface V2NIMSignallingRtcConfig : NSObject
/**
 * 云信音视频房间频道名称
 * 注意与信令房间频道名称不同
 */
@property (nonatomic,copy,nullable) NSString *rtcChannelName;

/**
 * 音视频房间token过期时间
 */
@property (nonatomic,assign) long rtcTokenTtl;

/**
 * JSON格式字符串，音视频SDK相关参数，IM信令仅透传相关参数
 */
@property (nonatomic,copy,nullable) NSString *rtcParams;
@end


#pragma makr - 呼叫回包
@interface V2NIMSignallingCallResult : NSObject
/**
 * 频道房间相关信息
 */
@property (nonatomic,strong,readonly) V2NIMSignallingRoomInfo *roomInfo;

/**
 * 音视频房间相关信息
 */
@property (nonatomic,strong,nullable,readonly) V2NIMSignallingRtcInfo *rtcInfo;

/**
 * 呼叫状态
 * 200: 呼叫成功
 * 对方不在线（待定code）
 * 对方推送不可达（待定code）
 */
@property (nonatomic,assign,readonly) int callStatus;
@end


#pragma makr - 信令频道信息
@interface V2NIMSignallingChannelInfo : NSObject
/**
 * 信令频道名称， 如果请求时不传，则该字段为空
 */
@property (nonatomic, copy, nullable, readonly) NSString *channelName;

/**
 * 信令频道ID， 唯一标识了该频道房间，后续主要以该字段作为请求标识
 */
@property (nonatomic, copy, readonly) NSString *channelId;

/**
 * 频道类型
 * 房间创建后跟频道类型绑定
 */
@property (nonatomic, assign, readonly) V2NIMSignallingChannelType channelType;

/**
 * 频道相关扩展字段， 跟频道绑定，JSON格式，长度限制4096
 */
@property (nonatomic, copy, nullable) NSString *channelExtension;

/**
 * 频道房间创建时间
 */
@property (nonatomic, assign) NSTimeInterval createTime;

/**
 * 频道房间过期时间
 */
@property (nonatomic, assign) NSTimeInterval expireTime;

/**
 * 创建者账号ID
 */
@property (nonatomic, copy) NSString *creatorAccountId;
/**
 * 频道是否有效
 */
@property (nonatomic, assign, readonly) BOOL channelValid;
@end


#pragma makr - 音视频相关信息
@interface V2NIMSignallingRtcInfo : NSObject
/**
 * 进入音视频对应的Token
 */
@property (nonatomic, copy, nullable) NSString *rtcToken;

/**
 * 音视频房间token过期时间
 */
@property (nonatomic, assign) long rtcTokenTtl;

/**
 * JSON格式字符串，音视频SDK相关参数，IM信令仅透传相关参数
 */
@property (nonatomic, copy, nullable) NSString *rtcParams;
@end


#pragma makr - 呼叫建立请求参数
@interface V2NIMSignallingCallSetupParams : NSObject
/**
 * 信令频道ID， 唯一标识了该频道房间
 * 该字段为呼叫通知下发字段
 */
@property (nonatomic, copy) NSString *channelId;

/**
 * 接受的呼叫者账号ID
 * 参数为空，或者为空串， 返回参数错误
 */
@property (nonatomic, copy) NSString *callerAccountId;

/**
 * 请求ID，可以用UUID实现
 * 主要为了便于业务实现请求响应绑定
 * 参数为空，或者为空串， 返回参数错误
 */
@property (nonatomic, copy) NSString *requestId;

/**
 * 服务器扩展字段， 长度限制4096， JSON格式
 */
@property (nonatomic, copy, nullable) NSString *serverExtension;

/**
 * 信令相关配置
 * 未读配置字段在接受场景无效
 */
@property (nonatomic, strong, nullable) V2NIMSignallingConfig *signallingConfig;

/**
 * 音视频相关参数配置
 */
@property (nonatomic, strong, nullable) V2NIMSignallingRtcConfig *rtcConfig;
@end


#pragma makr - 接受呼叫请求回包
@interface V2NIMSignallingCallSetupResult : NSObject
/**
 * 频道房间相关信息
 */
@property (nonatomic, strong, readonly) V2NIMSignallingRoomInfo *roomInfo;

/**
 * 音视频房间相关信息
 */
@property (nonatomic, strong, readonly, nullable) V2NIMSignallingRtcInfo *rtcInfo;

/**
 * 呼叫状态
 * 200， 呼叫成功
 * 对方不在线（code 待定）
 * 对方推送不可达（code待定）
 */
@property (nonatomic, assign, readonly) int callStatus;
@end


#pragma makr - 信令相关配置
@interface V2NIMSignallingMember : NSObject
/**
 * 成员账号ID
 */
@property (nonatomic, copy, readonly) NSString *accountId;

/**
 * 成员UID，业务传入的参数，一般映射的为音视频的房间id
 */
@property (nonatomic, assign, readonly) long uid;

/**
 * 用户加入信令频道房间时间
 */
@property (nonatomic, assign, readonly) NSTimeInterval joinTime;

/**
 * 用户信令频道房间过期时间
 */
@property (nonatomic, assign, readonly) NSTimeInterval expireTime;

/**
 * 成员操作的设备ID
 */
@property (nonatomic, copy, readonly) NSString *deviceId;
@end


#pragma makr - 信令房间相关信息
@interface V2NIMSignallingRoomInfo : NSObject
/**
 * 频道房间相关信息
 * 过期时间会调整
 */
@property (nonatomic, strong, readonly) V2NIMSignallingChannelInfo *channelInfo;

/**
 * 成员列表信息
 */
@property (nonatomic, strong, readonly) NSArray<V2NIMSignallingMember *> *members;
@end


#pragma makr - 加入信令房间请求参数
@interface V2NIMSignallingJoinParams : NSObject
/**
 * 信令频道ID， 唯一标识了该频道房间
 * 该字段为呼叫通知下发字段
 */
@property (nonatomic, copy) NSString *channelId;

/**
 * 服务器扩展字段， 长度限制4096，json格式
 */
@property (nonatomic, copy, nullable) NSString *serverExtension;

/**
 * 信令相关配置
 */
@property (nonatomic, strong, nullable) V2NIMSignallingConfig *signallingConfig;

/**
 * 音视频相关参数配置
 */
@property (nonatomic, strong, nullable) V2NIMSignallingRtcConfig *rtcConfig;
@end


#pragma makr - 邀请成员加入信令房间请求参数
@interface V2NIMSignallingInviteParams : NSObject
/**
 * 信令频道ID， 唯一标识了该频道房间
 * 该字段为呼叫通知下发字段
 */
@property (nonatomic, copy) NSString *channelId;

/**
 * 被邀请者账号ID
 * 参数为空，或者为空串， 返回参数错误
 */
@property (nonatomic, copy) NSString *inviteeAccountId;

/**
 * 请求ID，可以用UUID实现
 * 主要为了便于业务实现请求响应绑定
 * 参数为空，或者为空串， 返回参数错误
 */
@property (nonatomic, copy) NSString *requestId;

/**
 * 服务器扩展字段， 长度限制4096，json格式
 */
@property (nonatomic, copy,nullable) NSString *serverExtension;

/**
 * 信令相关配置
 * selfUid无效
 */
@property (nonatomic, strong,nullable) V2NIMSignallingConfig *signallingConfig;

/**
 * 推送相关配置
 */
@property (nonatomic, strong,nullable) V2NIMSignallingPushConfig *pushConfig;
@end


#pragma makr - 取消之前的邀请成员加入信令房间请求参数
@interface V2NIMSignallingCancelInviteParams : NSObject
/**
 * 信令频道ID， 唯一标识了该频道房间
 * 该字段为呼叫通知下发字段
 */
@property (nonatomic, copy) NSString *channelId;

/**
 * 被邀请者账号ID
 * 参数为空，或者为空串， 返回参数错误
 */
@property (nonatomic, copy) NSString *inviteeAccountId;

/**
 * 请求ID，可以用UUID实现
 * 主要为了便于业务实现请求响应绑定
 * 参数为空，或者为空串， 返回参数错误
 */
@property (nonatomic, copy) NSString *requestId;

/**
 * 服务器扩展字段， 长度限制4096，json格式
 */
@property (nonatomic, copy, nullable) NSString *serverExtension;

/**
 * 是否需要存离线消息。
 * YES：需要。
 * NO：不需要。
 */
@property (nonatomic, assign) BOOL offlineEnabled;

/**
 * 推送相关配置
 */
@property (nonatomic, strong) V2NIMSignallingPushConfig *pushConfig;
@end


#pragma makr - 拒绝别人邀请加入信令房间请求参数
@interface V2NIMSignallingRejectInviteParams : NSObject
/**
 * 信令频道ID， 唯一标识了该频道房间
 * 该字段为呼叫通知下发字段
 */
@property (nonatomic, copy) NSString *channelId;

/**
 * 邀请者账号ID
 * 参数为空，或者为空串， 返回参数错误
 */
@property (nonatomic, copy) NSString *inviterAccountId;

/**
 * 请求ID，可以用UUID实现
 * 主要为了便于业务实现请求响应绑定
 * 参数为空，或者为空串， 返回参数错误
 */
@property (nonatomic, copy) NSString *requestId;

/**
 * 服务器扩展字段， 长度限制4096，json格式
 */
@property (nonatomic, copy, nullable) NSString *serverExtension;

/**
 * 是否需要存离线消息。
 * YES：需要。
 * NO：不需要。
 */
@property (nonatomic, assign) BOOL offlineEnabled;
@end


#pragma makr - 接受别人邀请加入信令房间请求参数
@interface V2NIMSignallingAcceptInviteParams : NSObject
/**
 * 信令频道ID， 唯一标识了该频道房间
 * 该字段为呼叫通知下发字段
 */
@property (nonatomic, copy) NSString *channelId;

/**
 * 邀请者账号ID
 * 参数为空，或者为空串， 返回参数错误
 */
@property (nonatomic, copy) NSString *inviterAccountId;

/**
 * 请求ID，可以用UUID实现
 * 主要为了便于业务实现请求响应绑定
 * 参数为空，或者为空串， 返回参数错误
 */
@property (nonatomic, copy) NSString *requestId;

/**
 * 服务器扩展字段， 长度限制4096，json格式
 */
@property (nonatomic, copy, nullable) NSString *serverExtension;

/**
 * 是否需要存离线消息。默认YES
 * YES：需要。
 * NO：不需要。
 */
@property (nonatomic, assign) BOOL offlineEnabled;
@end

#pragma makr - 加入信令房间相关信息回包
@interface V2NIMSignallingJoinResult : NSObject
/**
 * 频道房间相关信息
 */
@property (nonatomic, copy, readonly, nullable) V2NIMSignallingRoomInfo *roomInfo;
/**
 * 音视频房间相关信息
 */
@property (nonatomic, copy, readonly, nullable) V2NIMSignallingRtcInfo *rtcInfo;
@end


#pragma makr - 信令事件
@interface V2NIMSignallingEvent : NSObject
/**
 * 信令频道事件类型
 */
@property (nonatomic, assign, readonly) V2NIMSignallingEventType eventType;
/**
 * 信令频道房间相关信息
 */
@property (nonatomic, strong, readonly) V2NIMSignallingChannelInfo *channelInfo;
/**
 * 操作者ID，通知的来源账号ID
 */
@property (nonatomic, copy, readonly) NSString *operatorAccountId;
/**
 * 服务器扩展字段， 长度限制4096，json格式
 */
@property (nonatomic, copy, readonly, nullable) NSString *serverExtension;
/**
 * 操作的时间点
 */
@property (nonatomic, assign, readonly) NSTimeInterval time;
/**
 * 被邀请者账号ID，以下场景包含该字段: 邀请加入信令频道房间、取消邀请加入信令频道房间
 */
@property (nonatomic, copy, readonly, nullable) NSString *inviteeAccountId;
/**
 * 邀请者账号ID，以下场景包含该字段: 对方拒绝邀请、对方接受邀请
 */
@property (nonatomic, copy, readonly, nullable) NSString *inviterAccountId;
/**
 * 本次请求发起产生的请求ID, 以下场景包含该字段: 邀请加入信令房间、拒绝邀请、接受邀请、取消邀请
 */
@property (nonatomic, copy, readonly) NSString *requestId;
/**
 * 推送相关配置， 以下场景包含该字段，可能为空，依赖于发起方: 邀请加入信令房间
 */
@property (nonatomic, strong, readonly, nullable) V2NIMSignallingPushConfig *pushConfig;

/**
 * 是否需要计未读。默认YES
 * YES：需要。
 * NO：不需要。
 */
@property (nonatomic, assign, readonly) BOOL unreadEnabled;

/**
 * 成员信息，加入房间事件包括该信息
 */
@property (nonatomic, strong, readonly, nullable) V2NIMSignallingMember *member;
@end
NS_ASSUME_NONNULL_END
