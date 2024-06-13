//
//  NIMQChatFetchQuickCommentsByMsgsResult.h
//  NIMLib
//
//  Created by Evang on 2022/3/22.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 *  获取圈组快捷评论结果
 */
@class NIMQChatMessageQuickCommentInfo;

@interface NIMQChatFetchQuickCommentsByMsgsResult : NSObject

/**
 *  字典，[messageId: NIMQChatMessageCommentInfo]
 */
@property (nonatomic, copy) NSDictionary <NSString *, NIMQChatMessageQuickCommentInfo *> *msgIdQuickCommentDic;

@end

NS_ASSUME_NONNULL_END
