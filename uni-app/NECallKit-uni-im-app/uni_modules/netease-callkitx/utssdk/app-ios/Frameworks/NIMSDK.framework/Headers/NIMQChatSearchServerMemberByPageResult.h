//
//  NIMQChatGetServerMembersByPageParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMQChatServerMember;

NS_ASSUME_NONNULL_BEGIN

/**
 *  分页查询服务器成员信息的结果
 */
@interface NIMQChatSearchServerMemberByPageResult : NSObject <NSCopying>
/**
 * 圈组服务器成员
 */
@property (nullable, nonatomic, copy)NSArray<NIMQChatServerMember *> *serverMembers;
@end


NS_ASSUME_NONNULL_END
