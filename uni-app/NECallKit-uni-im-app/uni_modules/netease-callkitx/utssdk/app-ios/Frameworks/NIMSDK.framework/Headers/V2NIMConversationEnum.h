//
//  V2NIMConversationEnum.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 会话类型
typedef NS_ENUM(NSInteger, V2NIMConversationType) {
    V2NIM_CONVERSATION_TYPE_UNKNOWN                         = 0,
    V2NIM_CONVERSATION_TYPE_P2P                             = 1,  ///< 点对应会话
    V2NIM_CONVERSATION_TYPE_TEAM                            = 2,  ///< 群会话
    V2NIM_CONVERSATION_TYPE_SUPER_TEAM                      = 3,   ///< 超大群会话

};

NS_ASSUME_NONNULL_END
