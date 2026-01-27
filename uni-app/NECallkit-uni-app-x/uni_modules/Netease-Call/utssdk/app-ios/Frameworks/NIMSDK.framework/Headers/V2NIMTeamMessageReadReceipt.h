//
//  V2NIMTeamMessageReadReceipt.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/8/14.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface V2NIMTeamMessageReadReceipt : NSObject
/// 会话ID
@property (nullable,nonatomic,strong,readonly) NSString *conversationId;
/// 消息ID， 群消息中，已读的消息ID
@property (nullable,nonatomic,strong,readonly) NSString *messageServerId;
/// 消息客户端ID， 群消息中，已读的消息ID
@property (nullable,nonatomic,strong,readonly) NSString *messageClientId;
/// 群消息已读人数
@property (nonatomic,assign,readonly) NSInteger readCount;
/// 群消息未读人数
@property (nonatomic,assign,readonly) NSInteger unreadCount;
/// 群消息最新已读账号
@property (nonatomic,strong,readonly) NSString *latestReadAccount;

@end

NS_ASSUME_NONNULL_END
