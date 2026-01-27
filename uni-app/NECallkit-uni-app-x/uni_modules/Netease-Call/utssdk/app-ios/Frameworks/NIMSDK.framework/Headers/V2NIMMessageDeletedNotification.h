//
//  V2NIMMessageDeletedNotification.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/9/13.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class V2NIMMessageRefer;

NS_ASSUME_NONNULL_BEGIN

@interface V2NIMMessageDeletedNotification : NSObject
/// 被删除的消息引用
@property(nonatomic,strong,readonly) V2NIMMessageRefer *messageRefer;
/// 被删除的时间
@property(nonatomic,assign,readonly) NSTimeInterval deleteTime;
/// 被删除时填入的扩展字段
@property(nonatomic,strong,readonly) NSString *serverExtension;
@end

NS_ASSUME_NONNULL_END
