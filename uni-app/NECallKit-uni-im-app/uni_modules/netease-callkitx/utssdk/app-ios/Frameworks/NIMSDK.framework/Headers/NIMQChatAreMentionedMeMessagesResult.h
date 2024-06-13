

//
//  NIMQChatAreMentionedMeMessagesResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 批量查询消息是否 @ 当前用户的结果
 */
@interface NIMQChatAreMentionedMeMessagesResult : NSObject

/**
 * 查询到的数据 消息 key:uuid value:YES/NO
 */
@property (nullable, nonatomic, copy)NSDictionary<NSString *,NSNumber*> *result;



@end


NS_ASSUME_NONNULL_END


