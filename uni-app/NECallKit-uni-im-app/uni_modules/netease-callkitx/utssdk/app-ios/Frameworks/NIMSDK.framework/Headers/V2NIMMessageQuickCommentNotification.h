//
//  V2NIMMessageQuickCommnetNotification.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/9/4.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "V2NIMMessageEnum.h"
@class V2NIMMessageQuickComment;

NS_ASSUME_NONNULL_BEGIN

/// 消息快捷评论通知
@interface V2NIMMessageQuickCommentNotification : NSObject
/// 消息快捷评论状态
@property(nonatomic,assign) V2NIMMessageQuickCommentType operationType;
/// 消息相关的快捷评论
@property(nonatomic,strong) V2NIMMessageQuickComment *quickComment;
@end

NS_ASSUME_NONNULL_END
