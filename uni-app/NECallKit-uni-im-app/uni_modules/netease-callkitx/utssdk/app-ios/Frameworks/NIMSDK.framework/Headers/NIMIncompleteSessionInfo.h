//
//  NIMIncompleteSessionInfo.h
//  NIMLib
//
//  Created by He on 2020/3/18.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMSession;
NS_ASSUME_NONNULL_BEGIN

/**
 *  未完整会话信息
 */
@interface NIMIncompleteSessionInfo : NSObject <NSCopying>
/**
 *  会话
 */
@property (nonatomic,strong,readonly) NIMSession *session;
/**
 *  发送方
 */
@property (nonatomic,copy,readonly) NSString *from;
/**
 *  消息时间戳(单位:s)
 */
@property (nonatomic,assign,readonly) NSTimeInterval timestamp;
/**
 * 消息服务端ID
 */
@property (nonatomic,copy,readonly) NSString *serverId;
@end

NS_ASSUME_NONNULL_END
