//
//  NIMQChatSearchServerChannelMemberResult.h
//  NIMLib
//
//  Created by 齐洪茹 on 2022/8/23.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMQChatChannelMember;

NS_ASSUME_NONNULL_BEGIN
/**
 *  查询服务器频道成员信息的结果
 */
@interface NIMQChatSearchServerChannelMemberResult : NSObject<NSCopying>

/**
 * 圈组服务器成员
 */
@property (nullable, nonatomic, copy)NSArray<NIMQChatChannelMember *> *serverMembers;

@end

NS_ASSUME_NONNULL_END
