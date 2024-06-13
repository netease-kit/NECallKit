//
//  V2NIMClearHistoryNotification.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/9/13.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface V2NIMClearHistoryNotification : NSObject
/// 被清空的会话ID
@property(nonatomic,strong,readonly) NSString *conversationId;
/// 被删除的时间
@property(nonatomic,assign,readonly) NSTimeInterval deleteTime;
/// 被删除时填入的扩展字段
@property(nonatomic,strong,readonly) NSString *serverExtension;
@end

NS_ASSUME_NONNULL_END
