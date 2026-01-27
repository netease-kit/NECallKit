//
//  V2NIMMessageQuickComment.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/8/31.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class V2NIMMessageRefer;
@class V2NIMMessageQuickCommentPushConfig;

NS_ASSUME_NONNULL_BEGIN

@interface V2NIMMessageQuickComment : NSObject
/// 快捷评论消息引用
@property(nonatomic,strong,readwrite) V2NIMMessageRefer *messageRefer;
/// 操作者 ID
@property(nonatomic,strong,readwrite) NSString *operatorId;
///评论类型
@property(nonatomic,assign,readwrite) NSTimeInterval index;
///评论时间
@property(nonatomic,assign,readwrite) NSTimeInterval createTime;
/// 扩展字段
@property(nonatomic,strong,readwrite) NSString *serverExtension;

@end

NS_ASSUME_NONNULL_END
