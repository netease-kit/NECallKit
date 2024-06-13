//
//  V2NIMP2PMessageReadReceipt.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/8/28.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 点对点消息已读回执
@interface V2NIMP2PMessageReadReceipt : NSObject
/// 会话ID
@property(nullable,nonatomic,strong,readonly) NSString *conversationId;

/// 最后一条已读消息的时间， 比该时间早的消息都可以认为已读
@property(nonatomic,assign,readonly) NSTimeInterval timestamp;
@end

NS_ASSUME_NONNULL_END
