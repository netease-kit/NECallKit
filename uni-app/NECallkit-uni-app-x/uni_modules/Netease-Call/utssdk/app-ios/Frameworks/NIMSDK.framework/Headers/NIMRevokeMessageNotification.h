//
//  NIMRevokeMessageNotification.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NIMSession;
@class NIMMessage;

/**
 *  消息撤回通知类型
 */
typedef NS_ENUM(NSInteger, NIMRevokeMessageNotificationType) {
    /**
     * 点对点消息撤回通知
     */
    NIMRevokeMessageNotificationTypeP2P         = 7,
    /**
    * 群消息撤回通知
    */
    NIMRevokeMessageNotificationTypeTeam        = 8,
    /**
    * 超大群撤回通知
    */
    NIMRevokeMessageNotificationTypeSuperTeam   = 12,
    /**
    * 点对点消息单向撤回
    */
    NIMRevokeMessageNotificationTypeP2POneWay   = 13,
    /**
    * 群消息单向撤回类型
    */
    NIMRevokeMessageNotificationTypeTeamOneWay  = 14,
};
/**
 * 撤回通知
 */
@interface NIMRevokeMessageNotification : NSObject

/**
 *  撤回消息类型
 */
@property (nonatomic,assign,readonly) NIMRevokeMessageNotificationType notificationType;

/**
 * 撤回消息发起者
 */
@property (nonatomic,copy,readonly)    NSString    *fromUserId;


/**
 * 消息的发送者，表示撤回的这条消息是谁发的
 */
@property (nonatomic,copy,readonly)    NSString    *messageFromUserId;

/**
 * 撤回消息所属会话
 */
@property (nonatomic,copy,readonly)    NIMSession   *session;

/**
 * 撤回消息时间点
 * @discussion 这里的时间点指的是被撤回的那条消息到底服务器的时间，而不是撤回指令到达服务器的时间点
 */
@property (nonatomic,assign,readonly)   NSTimeInterval timestamp;


/**
 * 撤回消息内容
 * @discussion 当撤回消息未被当前设备接收时，这个字段为 nil
 */
@property (nullable,nonatomic,strong,readonly)   NIMMessage *message;


/**
 * 撤回操作是否属于漫游消息
 */
@property (nonatomic,assign,readonly) BOOL roaming;


/**
 * 撤回操作是否属于离线消息
 */
@property (nonatomic,assign,readonly) BOOL offline;

/**
 * 撤回的附言
 */
@property(nullable, nonatomic,copy,readonly) NSString *postscript;

/**
 * 扩展,撤回方填充
 */
@property (nullable, nonatomic, copy, readonly) NSString *attach;

/**
 * 扩展,服务器填充消息
 */
@property (nonatomic, nonatomic, copy, readonly) NSString *callbackExt;

@end


NS_ASSUME_NONNULL_END
