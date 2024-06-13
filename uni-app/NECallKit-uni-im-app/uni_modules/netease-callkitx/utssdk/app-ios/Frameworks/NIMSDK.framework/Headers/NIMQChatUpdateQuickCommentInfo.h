//
//  NIMQChatQuickComment.h
//  NIMLib
//
//  Created by Evang on 2022/3/17.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN
/**
 *  快捷评论
 */
@interface NIMQChatUpdateQuickCommentInfo : NSObject <NSCopying>

/**
 *  服务器id
 */
@property (nonatomic, assign) unsigned long long serverId;

/**
 *  频道id
 */
@property (nonatomic, assign) unsigned long long channelId;

/**
 *  时间
 */
@property (nonatomic, assign) NSTimeInterval timestamp;

/**
 *  评论者accid
 */
@property (nonatomic, copy) NSString *fromAccId;

/**
 *  msg serverId
 */
@property (nonatomic, copy) NSString *msgServerId;

/**
 *  评论类型
 */
@property (nonatomic, assign) int64_t replyType;

/**
 *  操作类型，添加、删除
 */
@property (nonatomic, assign) NIMQChatUpdateQuickCommentType opeType;


@end


NS_ASSUME_NONNULL_END
