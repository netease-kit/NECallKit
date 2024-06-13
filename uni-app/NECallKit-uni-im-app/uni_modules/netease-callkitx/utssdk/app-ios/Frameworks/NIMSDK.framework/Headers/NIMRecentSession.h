//
//  NIMRecentSession.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NIMMessage;
@class NIMSession;
@class NIMRevokeMessageNotification;

/**
*  最后一条消息的类型。
*/
typedef NS_ENUM(NSInteger, NIMLastMsgType){
    /*
     * 常规Message，NIMMessage类型，lastMessage字段
     */
    NIMLastMsgTypeNormalMessage,
    /*
     * 撤回通知，NIMRevokeMessageNotification类型，lastNotification字段
     */
    NIMLastMsgTypeRevokeNotication
};



/**
 *  最近会话
 */
@interface NIMRecentSession : NSObject

/**
 *  当前会话
 */
@property (nullable,nonatomic,readonly,copy)   NIMSession  *session;

/**
 *  最后一条消息
 */
@property (nullable,nonatomic,strong)   NIMMessage  *lastMessage;

/**
 *  未读消息数
 */
@property (nonatomic,readonly,assign)   NSInteger   unreadCount;

/**
 *  本地扩展
 */
@property (nullable,nonatomic,readonly,copy) NSDictionary *localExt;

/**
 * 服务端会话的最新更新时间,本地会话无效
 */
@property (nonatomic,readonly,assign) NSTimeInterval updateTime;


/**
 *  会话服务扩展字段(本地会话该字段无效)
 */
@property (nonatomic,copy) NSString *serverExt;

/**
*  最后一条消息的类型(本地会话该字段无效)
*/
@property (nonatomic, readonly, assign) NIMLastMsgType lastMessageType;

/**
*  最后一条撤回通知(本地会话该字段无效)
*  lastMessageType为NIMLastMsgTypeNormalMessage时，最后一条为普通消息，请使用lastMessage获取，本字段为nil
*  lastMessageType为NIMLastMsgTypeRevokeNotication时，lastMessage字段为nil，最后一条为撤回通知，请使用本字段获取
*/
@property (nullable, nonatomic, readonly, strong) NIMRevokeMessageNotification *lastRevokeNotification;

@end


/**
 *  检索最近会话选项
 */
@interface NIMRecentSessionOption : NSObject

/**
 *  最后一条消息过滤
 *  @discusssion 最近会话里lastMessage为非过滤类型里的最后一条。例：@[@(NIMMessageTypeNotification)],
 *  表示返回的最近会话里lastMessage是最后一条非NIMMessageTypeNotification类型的消息。
 */
@property (nonatomic, strong) NSArray<NSNumber *> *filterLastMessageTypes;

@end

/**
 *  获取服务端会话列表可选参数
 */
@interface NIMFetchServerSessionOption : NSObject

/**
 *  最小时间戳，作为请求参数时表示增量获取Session列表，单位毫秒
 */
@property (nonatomic, assign) NSTimeInterval minTimestamp;

/**
 *  最大时间戳，翻页时使用, 单位毫秒，默认为当前时间
 */
@property (nonatomic, assign) NSTimeInterval maxTimestamp;

/**
 *  是否需要lastMsg，默认 YES
 */
@property (nonatomic, assign) BOOL needLastMessage;


/**
 *  结果集limit，最大100，默认100
 */
@property (nonatomic, assign) NSInteger limit;

@end

NS_ASSUME_NONNULL_END
