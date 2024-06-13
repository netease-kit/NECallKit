//
//  NIMSignalManagerProtocol.h
//  NIMLib
//
//  Created by taojinliang on 2018/10/24.
//  Copyright © 2018 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMSignalingChannelDetailedInfo;
@class NIMSignalingNotifyInfo;
@class NIMSignalingChannelInfo;
@class NIMSignalingCreateChannelRequest;
@class NIMSignalingDelayChannelRequest;
@class NIMSignalingCloseChannelRequest;
@class NIMSignalingJoinChannelRequest;
@class NIMSignalingLeaveChannelRequest;
@class NIMSignalingInviteRequest;
@class NIMSignalingCancelInviteRequest;
@class NIMSignalingRejectRequest;
@class NIMSignalingAcceptRequest;
@class NIMSignalingControlRequest;
@class NIMSignalingCallRequest;
@class NIMSignalingCallExRequest;
@class NIMSignalingAcceptJoinRequest;
@class NIMSignalingMemberInfo;
@class NIMSignalingQueryChannelRequest;
@class NIMSignalingJoinAndAcceptRequest;
@class NIMSignalingChannelCompositionInfo;

NS_ASSUME_NONNULL_BEGIN

/**
 *  创建频道回调
 *
 *  @param error 错误信息,如果成功,error 为 nil
 *  @param response 频道相关信息
 */
typedef void(^NIMSignalingCreateChannelBlock)(NSError * __nullable error, NIMSignalingChannelInfo * __nullable response);


/**
 *  加入频道回调
 *
 *  @param error 错误信息,如果成功,error 为 nil
 *  @param response 频道相关信息
 */
typedef void(^NIMSignalingJoinChannelBlock)(NSError * __nullable error, NIMSignalingChannelDetailedInfo * __nullable response);


/**
 *  呼叫回调
 *
 *  @param error 错误信息,如果成功,error 为 nil
 *  @param response 频道相关信息
 */
typedef void(^NIMSignalingCallBlock)(NSError * __nullable error, NIMSignalingChannelDetailedInfo * __nullable response);

/**
 *  接受回调
 *
 *  @param error 错误信息,如果成功,error 为 nil
 *  @param response 频道相关信息
 */
typedef void(^NIMSignalingAcceptBlock)(NSError * __nullable error, NIMSignalingChannelDetailedInfo * __nullable response);


/**
 *  信令操作回调
 *
 *  @param error 错误信息,如果成功,error 为 nil
 */
typedef void(^NIMSignalingOperationBlock)(NSError * __nullable error);

/**
 *  频道查询回调
 *
 *  @param error 错误信息,如果成功,error 为 nil
 */
typedef void(^NIMSignalingQueryChannelBlock)(NSError * __nullable error, NIMSignalingChannelDetailedInfo * __nullable response);


/**
 *  呼叫回调
 *
 *  @param error 错误信息,如果成功,error 为 nil
 *  @param response 频道相关信息
 */
typedef void(^NIMSignalingOptimizationCallBlock)(NSError * __nullable error, NIMSignalingChannelCompositionInfo * __nullable response);

/**
 *  频道类型
 */
typedef NS_ENUM(NSInteger, NIMSignalingChannelType){
    /**
     *  音频类型
     */
    NIMSignalingChannelTypeAudio = 1,
    /**
     *  视频类型
     */
    NIMSignalingChannelTypeVideo = 2,
    /**
     *  自定义类型
     */
    NIMSignalingChannelTypeCustom = 3,
};


/**
 *  信令通知事件定义类型
 */
typedef NS_ENUM(NSInteger, NIMSignalingEventType){
    /**
     *  关闭频道
     */
    NIMSignalingEventTypeClose           = 1,
    /**
     *  加入频道
     */
    NIMSignalingEventTypeJoin             = 2,
    /**
     *  邀请加入频道
     */
    NIMSignalingEventTypeInvite           = 3,
    /**
     *  取消邀请
     */
    NIMSignalingEventTypeCancelInvite     = 4,
    /**
     *  拒绝加入频道
     */
    NIMSignalingEventTypeReject           = 5,
    /**
     *  接受邀请
     */
    NIMSignalingEventTypeAccept           = 6,
    /**
     *  离开频道
     */
    NIMSignalingEventTypeLeave            = 7,
    /**
     *  自定义事件
     */
    NIMSignalingEventTypeContrl           = 8,
    
};


/**
 *  通用音视频信令相关回调
 */
@protocol NIMSignalManagerDelegate <NSObject>

@optional

/**
 在线通知

 @param eventType 信令操作事件类型
 @param notifyResponse 信令通知回调数据
 @discussion 用于通知信令相关的在线通知  NIMSignalingEventType 1-8有效
 */
- (void)nimSignalingOnlineNotifyEventType:(NIMSignalingEventType)eventType
                                 response:(NIMSignalingNotifyInfo *)notifyResponse;

/**
 在线多端同步通知

 @param eventType 信令操作事件类型：这里只有接受和拒绝
 @param notifyResponse 信令通知回调数据
 @discussion 用于通知信令相关的多端同步通知。比如自己在手机端接受邀请，PC端会同步收到这个通知  NIMSignalingEventType 5-6有效
 */
- (void)nimSignalingMultiClientSyncNotifyEventType:(NIMSignalingEventType)eventType
                                          response:(NIMSignalingNotifyInfo *)notifyResponse;


/**
 离线通知

 @param notifyResponse 信令通知回调数据
 @discussion 用于通知信令相关的离线通知信息。需要用户在调用相关接口时，打开存离线的开关。如果用户已经接收消息，该通知会在服务器标记已读，之后不会再收到该消息  NIMSignalingEventType 1-7有效
 */
- (void)nimSignalingOfflineNotify:(NSArray <NIMSignalingNotifyInfo *> *)notifyResponse;

/**
 频道列表同步通知
 
 @param notifyResponse 信令通知回调数据
 @discussion 在login或者relogin后，会通知该设备账号还未退出的频道列表，用于同步；如果没有在任何频道中，也会返回该同步通知，list为空
 */
- (void)nimSignalingChannelsSyncNotify:(NSArray <NIMSignalingChannelDetailedInfo *> *)notifyResponse;

/**
 房间成员同步通知

 @param notifyResponse 信令通知回调数据
 @discussion 用于同步频道内的成员列表变更，当前该接口为定时接口，2分钟同步一次，成员有变化时才上报。
 由于一些特殊情况，导致成员在离开或掉线前没有主动调用离开频道接口，使得该成员的离开没有对应的离开通知事件，由该回调接口【频道成员变更同步通知】告知用户
 */
- (void)nimSignalingMembersSyncNotify:(NIMSignalingChannelDetailedInfo *)notifyResponse;

@end

/**
 *  通用音视频信令协议
 */
@protocol NIMSignalManager <NSObject>

/**
 创建频道

 @param request 创建频道请求
 @param completion 完成回调
 @discussion 该接口用户创建频道，同一时刻频道名互斥，不能重复创建。但如果频道名缺省，服务器会自动分配频道id。对于频道在创建后如果没人加入，有效期2小时，当有成员加入后会自动延续频道有效期。当主动关闭频道或者最后一个成员退出后2小时后频道销毁。
 @discussion 错误码 200:成功  10405:房间已存在
 */
- (void)signalingCreateChannel:(NIMSignalingCreateChannelRequest *)request
                    completion:(nullable NIMSignalingCreateChannelBlock)completion;

/**
 关闭频道

 @param request 关闭频道请求
 @param completion 完成回调
 @discussion 该接口可以由创建者和频道内所有成员调用，无权限限制。调用该接口成功后，其他所有频道内的成员都回收到频道结束的通知，被动离开频道。此时其他成员需要调用离开接口，也不会收到别人的离开通知。
 @discussion 错误码 200:成功  10406:不在房间内
 */
- (void)signalingCloseChannel:(NIMSignalingCloseChannelRequest *)request
                   completion:(nullable NIMSignalingOperationBlock)completion;

/**
 加入频道

 @param request 加入频道请求
 @param completion 完成回调
 @discussion 错误码 200:成功  10407:已经房间内 10420:已经在房间内（自己的其他端） 10419:房间人数超限  10417:uid冲突
 */
- (void)signalingJoinChannel:(NIMSignalingJoinChannelRequest *)request
                  completion:(nullable NIMSignalingJoinChannelBlock)completion;

/**
 离开频道

 @param request 离开频道请求
 @param completion 完成回调
 @discussion 该接口用于自己退出频道，但不对频道进行销毁
 @discussion 错误码 200:成功  10406:不在房间内
 */
- (void)signalingLeaveChannel:(NIMSignalingLeaveChannelRequest *)request
                   completion:(nullable NIMSignalingOperationBlock)completion;

/**
 邀请加入频道

 @param request 邀请加入频道请求
 @param completion 完成回调
 @discussion 该接口用于邀请对方加入频道，邀请者必须是创建者或者是频道中成员。如果需要对离线成员邀请，可以打开离线邀请开关并填写推送信息。被邀请者在线后通过离线通知接收到该邀请，并通过房间信息中的invalid_字段判断房间的有效性，也可以对所有离线消息处理后判断该邀请是否被取消。
 @discussion 错误码 200:成功  10404:房间不存在 10406:不在房间内（自己）10407:已经房间内（对方）10419:房间人数超限  10201:对方云信不在线  10202:对方推送不可达
 */
- (void)signalingInvite:(NIMSignalingInviteRequest *)request
             completion:(nullable NIMSignalingOperationBlock)completion;

/**
 取消邀请

 @param request 取消邀请请求
 @param completion 完成回调
 @discussion 错误码 200:成功  10404:房间不存在 10408:邀请不存在或已过期 10409:邀请已经拒绝 10410:邀请已经接受
 */
- (void)signalingCancelInvite:(NIMSignalingCancelInviteRequest *)request
                   completion:(nullable NIMSignalingOperationBlock)completion;

/**
 拒绝邀请

 @param request 拒绝邀请请求
 @param completion 完成回调
 @discussion 拒绝邀请后用户也可以通过加入频道接口加入频道，接口的使用由用户的业务决定
 @discussion 错误码 200:成功  10404:房间不存在 10408:邀请不存在或已过期 10409:邀请已经拒绝 10410:邀请已经接受
 */
- (void)signalingReject:(NIMSignalingRejectRequest *)request
             completion:(nullable NIMSignalingOperationBlock)completion;

/**
 接受邀请

 @param request 接受邀请请求
 @param completion 完成回调
 @discussion 接受频道接口
 不开自动加入开关：该接口只接受邀请并告知邀请者，并同步通知自己的其他在线设备，但不会主动加入频道，需要单独调用加入接口
 打开自动加入开关：该接口为组合接口，等同于先调用接受邀请，成功后再加入房间。
 @discussion 错误码 200:成功 10404:房间不存在 10408:邀请不存在或已过期 10409:邀请已经拒绝 10410:邀请已经接受 10407:已经房间内 10420:已经在房间内（自己的其他端） 10419:房间人数超限 10417:uid冲突
 */
- (void)signalingAccept:(NIMSignalingAcceptRequest *)request
             completion:(nullable NIMSignalingAcceptBlock)completion;


/**
 接受邀请并加入
 
 @param request 接受邀请请求
 @param completion 完成回调
 @discussion 接受频道邀请并加入接口
 该接口接受邀请并告知邀请者，并同步通知自己的其他在线设备，并主动加入频道。
 @discussion 错误码 200:成功 10404:房间不存在 10408:邀请不存在或已过期 10409:邀请已经拒绝 10410:邀请已经接受 10407:已经房间内 10420:已经在房间内（自己的其他端） 10419:房间人数超限 10417:uid冲突
 */
- (void)signalingJoinAndAccept:(NIMSignalingJoinAndAcceptRequest *)request
                    completion:(nullable NIMSignalingOptimizationCallBlock)completion;

/**
 自定义控制指令

 @param request 自定义控制指令请求
 @param completion 完成回调
 @discussion 该接口用于在频道中透传一些自定义指令，协助频道管理。该接口允许非频道内成员调用，但接收者必须是频道内成员或创建者
 @discussion 错误码 200:成功 10404:房间不存在  10406:不在房间内（自己或者对方）
 */
- (void)signalingControl:(NIMSignalingControlRequest *)request
              completion:(nullable NIMSignalingOperationBlock)completion;



/**
 呼叫
 
 @param request 呼叫请求
 @param completion 完成回调
 @discussion 用于用户新开一个频道并邀请对方加入频道，该接口为组合接口，等同于用户先创建频道，成功后加入频道并邀请对方
 @discussion 错误码 200:成功 10405:房间已存在 10201:对方云信不在线 10202:对方推送不可达。该接口是用户呼叫场景的组合接口封装，调用该接口，sdk底层分别会 创建、加入、邀请，再返回用户结果，其中任何一步失败，就返回失败（其中邀请返回10201和10202，认为是成功，返回码还是10201和10202给上层），失败时，sdk需要主动close。常用于但不限于点对点呼叫发起。
 @discussion error的错误码为10201和10202时，返回的房间信息时有效的，需要用户主动close房间
 */
- (void)signalingCall:(NIMSignalingCallRequest *)request
           completion:(nullable NIMSignalingCallBlock)completion;

/**
 呼叫 （优化）
 
 @param request 呼叫请求
 @param completion 完成回调
 @discussion 用于用户新开一个频道并邀请对方加入频道，该接口为组合接口 ，对老接口进行优化。等同于用户先创建频道，成功后加入频道并邀请对方
 @discussion 错误码 200:成功 10405:房间已存在 10201:对方云信不在线 10202:对方推送不可达。该接口是用户呼叫场景的组合接口封装，调用该接口，sdk底层分别会 创建、加入、邀请，再返回用户结果，其中任何一步失败，就返回失败（其中邀请返回10201和10202，认为是成功，返回码还是10201和10202给上层），失败时，sdk需要主动close。常用于但不限于点对点呼叫发起。
 @discussion error的错误码为10201和10202时，返回的房间信息时有效的，需要用户主动close房间
 */
- (void)signalingCallEx:(NIMSignalingCallExRequest *)request
             completion:(nullable NIMSignalingOptimizationCallBlock)completion;

/**
 查询频道信息

 @param request 查询请求
 @param completion 完成回调
 */
- (void)signalingQueryChannelInfo:(NIMSignalingQueryChannelRequest *)request
                       completion:(nullable NIMSignalingQueryChannelBlock)completion;

/**
 *  添加通知对象
 *
 *  @param delegate 通知对象
 */
- (void)addDelegate:(id<NIMSignalManagerDelegate>)delegate;

/**
 *  移除通知对象
 *
 *  @param delegate 通知对象
 */
- (void)removeDelegate:(id<NIMSignalManagerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
