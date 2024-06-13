//
//  NIMSignalingRequest.h
//  NIMLib
//
//  Created by taojinliang on 2018/10/25.
//  Copyright © 2018 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMSignalManagerProtocol.h"

@class NIMSignalingPushInfo;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 创建频道请求
/**
 *  创建频道请求
 */
@interface NIMSignalingCreateChannelRequest : NSObject

/**
 频道名，非必填
 */
@property(nullable, nonatomic, copy) NSString *channelName;

/**
 频道类型，必填
 */
@property(nonatomic, assign) NIMSignalingChannelType channelType;

/**
 额外字段，非必填（频道的自定义扩展信息）
 */
@property(nullable, nonatomic, copy) NSString *channelExt;

@end


#pragma mark - 延迟频道有效期（同时延迟操作者和频道）
/**
 *  延迟频道有效期（同时延迟操作者和频道）
 */
@interface NIMSignalingDelayChannelRequest : NSObject

/**
 频道id，必填
 */
@property(nonatomic, copy) NSString *channelId;

@end


#pragma mark - 关闭频道请求
/**
 *  关闭频道请求
 */
@interface NIMSignalingCloseChannelRequest : NSObject

/**
 频道id，必填
 */
@property(nonatomic, copy) NSString *channelId;

/**
 是否存离线，YES表示存离线，NO表示不存离线，非必填，默认为NO
 */
@property(nonatomic, assign) BOOL offlineEnabled;

/**
 通知事件额外字段，非必填 (操作者附加的自定义信息，透传给其他人)
 */
@property(nullable, nonatomic, copy) NSString *customInfo;

@end


#pragma mark - 加入频道请求
/**
 *  加入频道请求
 */
@interface NIMSignalingJoinChannelRequest : NSObject

/**
 频道id，必填
 */
@property(nonatomic, copy) NSString *channelId;

/**
 通知事件额外字段，非必填（操作者附加的自定义信息，透传给其他人）
 */
@property(nullable, nonatomic, copy) NSString *customInfo;

/**
 用户id，非必填 （自己在频道中对应的uid，大于零有效，无效时服务器会分配随机唯一的uid）
 */
@property(nonatomic, assign) uint64_t uid;

/**
 是否存离线，YES表示存离线，NO表示不存离线，非必填，默认为NO
 */
@property(nonatomic, assign) BOOL offlineEnabled;

/**
 nertc房间名，填了则会返回token
 */
@property(nullable, nonatomic, copy) NSString *nertcChannelName;

/**
 nertc的token有效期，表示token的过期时间，单位秒，选填，默认10分钟，会回填
 */
@property(nonatomic, assign)  long nertcTokenTtl;
/**
 nertc的加入房间的请求参数
 */
@property(nullable, nonatomic, copy)  NSString *nertcJoinRoomQueryParamMap;

@end


#pragma mark - 离开频道请求
/**
 *  离开频道请求
 */
@interface NIMSignalingLeaveChannelRequest : NSObject

/**
 频道id，必填
 */
@property(nonatomic, copy) NSString *channelId;

/**
 是否存离线，YES表示存离线，NO表示不存离线，非必填，默认为NO
 */
@property(nonatomic, assign) BOOL offlineEnabled;

/**
 通知事件额外字段，非必填 （操作者附加的自定义信息，透传给其他人）
 */
@property(nullable, nonatomic, copy) NSString *customInfo;

@end


#pragma mark - 邀请加入频道请求
/**
 *  邀请加入频道请求
 */
@interface NIMSignalingInviteRequest : NSObject

/**
 频道id，必填
 */
@property(nonatomic, copy) NSString *channelId;

/**
 对方，被邀请人，必填
 */
@property(nonatomic, copy) NSString *accountId;

/**
 是否存离线，YES表示存离线，NO表示不存离线，非必填，默认为NO
 */
@property(nonatomic, assign) BOOL offlineEnabled;

/**
 邀请唯一标识（用于标识持续呼叫）,必填（邀请者邀请的请求id，需要邀请者填写，之后取消邀请、拒绝、接受需要复用该标示，长度必须小于128，超出会报参数错误）
 */
@property(nonatomic, copy) NSString *requestId;

/**
 通知事件额外字段，非必填（邀请者附加的自定义信息，透传给被邀请者）
 */
@property(nullable, nonatomic, copy) NSString *customInfo;

/**
 推送信息
 */
@property(nonatomic, strong) NIMSignalingPushInfo *push;

@end


#pragma mark - 取消邀请请求
/**
 *  取消邀请请求
 */
@interface NIMSignalingCancelInviteRequest : NSObject

/**
 频道id，必填
 */
@property(nonatomic, copy) NSString *channelId;

/**
 对方，被邀请人，必填
 */
@property(nonatomic, copy) NSString *accountId;

/**
 邀请唯一标识（用于标识持续呼叫）,必填，长度必须小于128，超出会报参数错误
 */
@property(nonatomic, copy) NSString *requestId;

/**
 是否存离线，YES表示存离线，NO表示不存离线，非必填，默认为NO
 */
@property(nonatomic, assign) BOOL offlineEnabled;

/**
 通知事件额外字段，非必填
 */
@property(nullable, nonatomic, copy) NSString *customInfo;

@end



#pragma mark - 拒绝邀请请求
/**
 *  拒绝邀请请求
 */
@interface NIMSignalingRejectRequest : NSObject

/**
 频道id，必填
 */
@property(nonatomic, copy) NSString *channelId;

/**
 对方，被邀请人，必填
 */
@property(nonatomic, copy) NSString *accountId;

/**
 邀请唯一标识（用于标识持续呼叫）,必填，长度必须小于128，超出会报参数错误
 */
@property(nonatomic, copy) NSString *requestId;

/**
 是否存离线，YES表示存离线，NO表示不存离线，非必填，默认为NO
 */
@property(nonatomic, assign) BOOL offlineEnabled;

/**
 通知事件额外字段，非必填
 */
@property(nullable, nonatomic, copy) NSString *customInfo;

@end

#pragma mark - 接受邀请请求
/**
 *  接受邀请请求
 */
@interface NIMSignalingAcceptRequest : NSObject

/**
 频道id，必填 (对应的频道id)
 */
@property(nonatomic, copy) NSString *channelId;

/**
 对方，被邀请人，必填 (邀请者的账号)
 */
@property(nonatomic, copy) NSString *accountId;

/**
 邀请唯一标识（用于标识持续呼叫）,必填(邀请者邀请的请求id，用于被邀请者回传request_id_作对应的回应操作)，长度必须小于128，超出会报参数错误
 */
@property(nonatomic, copy) NSString *requestId;

/**
 是否存离线，YES表示存离线，NO表示不存离线，非必填，默认为NO
 */
@property(nonatomic, assign) BOOL offlineEnabled;

/**
 通知事件额外字段，非必填(被邀请者附加的自定义信息，透传给邀请者)
 */
@property(nullable, nonatomic, copy) NSString *acceptCustomInfo;

/**
 是否加入，默认不打开，打开后后续参数uid_、join_custom_info_有效
 */
@property(nonatomic, assign) BOOL autoJoin;

/**
 自己在频道中对应的uid，大于零有效，无效时服务器会分配随机唯一的uid
 */
@property(nonatomic, assign) uint64_t uid;

/**
 加入频道的自定义扩展信息，将在加入频道通知中带给其他频道成员
 */
@property(nullable, nonatomic, copy) NSString *joinCustomInfo;

/**
 nertc房间名，填了则会返回token
 */
@property(nullable, nonatomic, copy) NSString *nertcChannelName;

/**
 nertc的token有效期，表示token的过期时间，单位秒，选填，默认10分钟，会回填
 */
@property(nonatomic, assign)  long nertcTokenTtl;

@property(nullable, nonatomic, copy) NSString *nertcJoinRoomQueryParamMap;

@end

#pragma mark - 邀请并且加入请求
/**
 *  接受邀请请求
 */
@interface NIMSignalingJoinAndAcceptRequest : NSObject

/**
 频道id，必填 (对应的频道id)
 */
@property(nonatomic, copy) NSString *channelId;

/**
 对方，被邀请人，必填 (邀请者的账号)
 */
@property(nonatomic, copy) NSString *accountId;

/**
 邀请唯一标识（用于标识持续呼叫）,必填(邀请者邀请的请求id，用于被邀请者回传request_id_作对应的回应操作)，长度必须小于128，超出会报参数错误
 */
@property(nonatomic, copy) NSString *requestId;

/**
 是否存离线，YES表示存离线，NO表示不存离线，非必填，默认为NO
 */
@property(nonatomic, assign) BOOL offlineEnabled;

/**
 额外字段，非必填(被邀请者附加的自定义信息，透传给邀请者)
 */
@property(nullable, nonatomic, copy) NSString *customInfo;

/**
 自己在频道中对应的uid，大于零有效，无效时服务器会分配随机唯一的uid
 */
@property(nonatomic, assign) uint64_t uid;

/**
 nertc房间名，填了则会返回token
 */
@property(nullable, nonatomic, copy) NSString *nertcChannelName;

/**
 nertc的token有效期，表示token的过期时间，单位秒，选填，默认10分钟，会回填
 */
@property(nonatomic, assign)  long nertcTokenTtl;
/**
 nertc加入房间的请求参数，可以转成json , 非必填
 */
@property(nullable, nonatomic, copy) NSString *nertcJoinRoomQueryParamMap;

@end


#pragma mark - 呼叫请求
/**
 *  呼叫请求
 */
@interface NIMSignalingCallExRequest : NSObject
/**
 频道类型，必填
 */
@property(nonatomic, assign) NIMSignalingChannelType channelType;
/**
 被操作者（如被邀请者)，必填
 */
@property(nonatomic, copy) NSString *accountId;
/**
 邀请唯一标识（用于标识持续呼叫）, 必填(邀请者邀请的请求id，用于被邀请者回传request_id_作对应的回应操作)，长度必须小于128，超出会报参数错误
 */
@property(nonatomic, copy) NSString *requestId;
/**
 频道名，非必填
 */
@property(nullable, nonatomic, copy) NSString *channelName;
/**
 额外字段，非必填（频道的自定义扩展信息）
 */
@property(nullable, nonatomic, copy) NSString *channelExt;
/**
 自己在频道中对应的uid，大于零有效，无效时服务器会分配随机唯一的uid，非必填
 */
@property(nonatomic, assign) uint64_t uid;
/**
 附加自定义信息，非必填
 */
@property(nonatomic, copy) NSString *customInfo;
/**
 是否存离线，1表示存离线，0表示不存离线，非必填
 */
@property(nonatomic, assign) BOOL offlineEnabled;
/**
 nertc房间名，填了则会返回token
 */
@property(nullable, nonatomic, copy) NSString *nertcChannelName;
/**
 nertc的token有效期，是一个long，表示token的过期时间，单位秒，选填，默认10分钟，回包时会回填
 */
@property(nonatomic, assign)  long nertcTokenTtl;
/**
 nertc加入房间的请求参数，可以转成json
 */
@property(nullable, nonatomic, copy) NSString *nertcJoinRoomQueryParamMap;

/**
 推送信息
 */
@property(nonatomic, strong) NIMSignalingPushInfo *push;


@end


#pragma mark - 自定义控制指令请求
/**
 *  自定义控制指令请求
 */
@interface NIMSignalingControlRequest : NSObject

/**
 频道id，必填
 */
@property(nonatomic, copy) NSString *channelId;

/**
 若指定则只发给指定人，否则发给频道内所有人,非必填
 */
@property(nullable, nonatomic, copy) NSString *accountId;

/**
 通知事件额外字段，非必填
 */
@property(nullable, nonatomic, copy) NSString *customInfo;

@end


#pragma mark - 呼叫请求（组合：创建、加入、邀请）
/**
 *  呼叫请求（组合：创建、加入、邀请）
 */
@interface NIMSignalingCallRequest : NIMSignalingCreateChannelRequest

/**
 自己在频道中对应的uid
 */
@property(nonatomic, assign) uint64_t uid;

/**
 对方accid，被邀请者的账号
 */
@property(nonatomic, copy) NSString *accountId;

/**
 邀请唯一标识（用于标识持续呼叫）,必填，长度必须小于128，超出会报参数错误
 */
@property(nonatomic, copy) NSString *requestId;

/**
 是否存离线，YES表示存离线，NO表示不存离线，非必填，默认为NO
 */
@property(nonatomic, assign) BOOL offlineEnabled;

/**
 通知事件额外字段，非必填
 */
@property(nullable, nonatomic, copy) NSString *customInfo;

/**
 通知事件额外字段，非必填
 */
@property(nullable, nonatomic, strong) NIMSignalingPushInfo *push;

/**
 nertc房间名，填了则会返回token
 */
@property(nullable, nonatomic, copy) NSString *nertcChannelName;

/**
 nertc的token有效期，表示token的过期时间，单位秒，选填，默认10分钟，会回填
 */
@property(nonatomic, assign)  long nertcTokenTtl;

@end

#pragma mark - 查询请求
/**
 *  查询请求
 */
@interface NIMSignalingQueryChannelRequest : NSObject

/**
 频道名称，选填（对应的频道名称）(channelId两者必须要填一个，优先使用channelName查询)
 */
@property(nonatomic, copy) NSString *channelName;

/**
 频道id，选填 (对应的频道id)(channelName两者必须要填一个,必须进入房间后，才能使用channelId查询)
 */
@property(nonatomic, copy) NSString *channelId;

@end


NS_ASSUME_NONNULL_END
