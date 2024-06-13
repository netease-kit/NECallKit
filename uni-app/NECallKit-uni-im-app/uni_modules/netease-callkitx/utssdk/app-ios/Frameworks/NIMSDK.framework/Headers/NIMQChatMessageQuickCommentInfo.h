//
//  NIMQChatMessageQuickCommentInfo.h
//  NIMLib
//
//  Created by Evang on 2022/3/18.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NIMQChatMessageQuickCommentsDetail;
/**
 *  查询消息附带的评论的结果
 */
@interface NIMQChatMessageQuickCommentInfo : NSObject <NSCopying>

/**
 *  服务器id
 */
@property (nonatomic, assign) unsigned long long serverId;

/**
 *  频道id
 */
@property (nonatomic, assign) unsigned long long channelId;

/**
 *  消息服务器id
 */
@property (nonatomic, copy) NSString *msgServerId;

/**
 *  评论条数
 */
@property (nonatomic, assign) NSInteger count;

/**
 *  最后一次操作评论的时间
 */
@property (nonatomic, assign) NSTimeInterval updateTime;

/**
 *  各评论详情
 */
@property (nonatomic, copy, readonly) NSArray <NIMQChatMessageQuickCommentsDetail *> *commentArray;

@end


/**
 *  查询消息附带的评论的结果中，单个评论详情
 */
@interface NIMQChatMessageQuickCommentsDetail : NSObject <NSCopying>

/**
 *  消息评论类型type
 */
@property (nonatomic, assign) NSInteger replyType;

/**
 *  评论次数
 */
@property (nonatomic, assign) NSInteger count;

/**
 *  自己是否添加过
 */
@property (nonatomic, assign) BOOL selfReplyed;

/**
 *  添加过的评论几位用户accid(注意：不是按照操作时间排序的，可以认为是随机取了N个)
 */
@property (nonatomic, copy, readonly) NSArray <NSString *> *replyAccIds;

/**
 *  创建时间
 */
@property (nonatomic, assign) NSTimeInterval createTime;

@end

NS_ASSUME_NONNULL_END
