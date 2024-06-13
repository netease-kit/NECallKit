//
//  NIMSignalingResponse.h
//  NIMLib
//
//  Created by taojinliang on 2018/10/25.
//  Copyright © 2018 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMSignalManagerProtocol.h"

@class NIMSignalingMemberInfo;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 频道相关对象
/**
 频道相关对象
 */
@interface NIMSignalingChannelInfo : NSObject

/**
 频道类型（通话类型）
 */
@property(nonatomic, assign) NIMSignalingChannelType channelType;

/**
 频道名称（创建时传入的频道名）
 */
@property(nonatomic, copy) NSString *channelName;

/**
 频道服务器名称，服务器生成，确保唯一（服务器生成的频道id）
 */
@property(nonatomic, copy) NSString *channelId;

/**
 频道创建时间（创建时间点）
 */
@property(nonatomic, assign) uint64_t createTimeStamp;

/**
 频道过期时间（失效时间点）
 */
@property(nonatomic, assign) uint64_t expireTimeStamp;

/**
 创建者（创建者的accid）
 */
@property(nonatomic, copy) NSString *creatorId;

/**
 额外字段 （创建时传入的扩展字段）
 */
@property(nonatomic, copy) NSString *channelExt;

/**
 频道是否有效，NO表示有效，YES表示无效，默认有效
 */
@property(nonatomic, assign) BOOL invalid;

/**
 nertc的token有效期，表示token的过期时间，单位秒，选填，默认10分钟，会回填
 */
@property(nonatomic, assign)  long nertcTokenTtl;

/**
 nertc的token,加入rtc房间使用
 */
@property(nonatomic, copy)  NSString *nertcToken;

/**
 nertc加入房间的请求参数，可以转成json
 */
@property(nullable, nonatomic, copy) NSString *nertcJoinRoomResponse;


@end

#pragma mark - 频道成员相关对象
/**
 频道成员相关对象
 */
@interface NIMSignalingChannelDetailedInfo : NIMSignalingChannelInfo

/**
 频道成员列表
 */
@property(nonatomic, strong) NSArray<NIMSignalingMemberInfo *> *members;

@end

#pragma mark - 频道成员详细信息
/**
 频道成员相关对象
 调用集成了CallEx 或者 AcceptAndJion 返回值
 */
@interface NIMSignalingChannelCompositionInfo : NIMSignalingChannelDetailedInfo

/**
 对应于invite协议的错误码：成功、不在线、推送不可达
 */
@property(nonatomic, assign) int callStatus;

@end

#pragma mark - 推送相关对象
/**
 推送相关对象
 */
@interface NIMSignalingPushInfo : NSObject

/**
 是否需要推送，YES表示推送，NO表示不推送，默认NO
 */
@property(nonatomic, assign) BOOL needPush;

/**
 推送标题
 */
@property(nonatomic, copy) NSString *pushTitle;

/**
 推送内容
 */
@property(nonatomic, copy) NSString *pushContent;

/**
 推送自定义字段
 */
@property(nonatomic, strong) NSDictionary *pushPayload;

/**
 是否计入未读计数，默认YES
 */
@property(nonatomic, assign) BOOL needBadge;

@end

#pragma mark - 通知回调基类对象
/**
 通知回调基类对象
 */
@interface NIMSignalingNotifyInfo : NSObject

/**
 通知事件类型
 */
@property(nonatomic, assign) NIMSignalingEventType eventType;

/**
 频道对象
 */
@property(nonatomic, strong) NIMSignalingChannelInfo *channelInfo;

/**
 操作者（如邀请者、关闭频道者）
 */
@property(nonatomic, copy) NSString *fromAccountId;

/**
 通知事件拓展字段
 */
@property(nonatomic, copy) NSString *customInfo;

/**
 通知时间戳
 */
@property(nonatomic, assign) int64_t time;

@end

#pragma mark - 关闭频道通知对象
/**
 关闭频道通知对象
 */
@interface NIMSignalingCloseNotifyInfo : NIMSignalingNotifyInfo
@end

#pragma mark - 加入频道通知对象
/**
 加入频道通知对象
 */
@interface NIMSignalingJoinNotifyInfo : NIMSignalingNotifyInfo
/**
 频道成员
 */
@property(nonatomic, strong) NIMSignalingMemberInfo *member;

@end

#pragma mark - 离开频道通知对象
/**
 离开频道通知对象
 */
@interface NIMSignalingLeaveNotifyInfo : NIMSignalingNotifyInfo
@end

#pragma mark - 邀请加入频道通知对象
/**
 *  邀请加入频道通知对象
 */
@interface NIMSignalingInviteNotifyInfo : NIMSignalingNotifyInfo

/**
 被操作者（如被邀请者）
 */
@property(nonatomic, copy) NSString *toAccountId;

/**
 推送对象
 */
@property(nonatomic, strong) NIMSignalingPushInfo *push;

/**
 邀请唯一标识（用于标识持续呼叫）
 */
@property(nonatomic, copy) NSString *requestId;

@end

#pragma mark - 取消邀请通知对象
/**
 *  取消邀请通知对象
 */
@interface NIMSignalingCancelInviteNotifyInfo : NIMSignalingNotifyInfo

/**
 被操作者（如被邀请者）
 */
@property(nonatomic, copy) NSString *toAccountId;

/**
 邀请唯一标识（用于标识持续呼叫）
 */
@property(nonatomic, copy) NSString *requestId;

@end

#pragma mark - 拒绝邀请通知对象
/**
 *  拒绝邀请通知对象
 */
@interface NIMSignalingRejectNotifyInfo : NIMSignalingNotifyInfo

/**
 被操作者（如被邀请者）
 */
@property(nonatomic, copy) NSString *toAccountId;

/**
 邀请唯一标识（用于标识持续呼叫）
 */
@property(nonatomic, copy) NSString *requestId;

@end

#pragma mark - 接受邀请通知对象
/**
 *  接受邀请通知对象
 */
@interface NIMSignalingAcceptNotifyInfo : NIMSignalingNotifyInfo

/**
 被操作者（如被邀请者）
 */
@property(nonatomic, copy) NSString *toAccountId;

/**
 邀请唯一标识（用于标识持续呼叫）
 */
@property(nonatomic, copy) NSString *requestId;

@end

#pragma mark - 自定义控制通知对象
/**
 *  自定义控制通知对象
 */
@interface NIMSignalingControlNotifyInfo : NIMSignalingNotifyInfo
@end

NS_ASSUME_NONNULL_END
