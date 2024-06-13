//
//  NIMQChatMessageServerIdInfo.h
//  NIMLib
//
//  Created by Evang on 2022/4/1.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NIMQChatMessageServerIdInfo : NSObject

/**
 *  消息服务端ID（服务端）
 */
@property (nonatomic,copy)                 NSString *serverID;

/**
 *  消息发送时间（服务端）
 */
@property (nonatomic,assign)               NSTimeInterval timestamp;

@end

NS_ASSUME_NONNULL_END
