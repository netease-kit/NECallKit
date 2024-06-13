

//
//  NIMQChatAreMentionedMeMessagesParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN

@class NIMQChatMessage;

/**
 *  批量查询消息是否 @ 当前用户的参数
 */
@interface NIMQChatAreMentionedMeMessagesParam : NSObject

/**
 * 要查询的圈组消息数组
 */
@property (nonatomic, copy)NSArray<NIMQChatMessage *> *messages;

@end


NS_ASSUME_NONNULL_END


