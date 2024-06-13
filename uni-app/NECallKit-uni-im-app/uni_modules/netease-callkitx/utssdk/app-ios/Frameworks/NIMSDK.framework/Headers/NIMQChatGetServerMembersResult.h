//
//  NIMQChatGetServerMembersResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NIMQChatServerMember;
/**
 *  查询服务器成员的回调类型
 */
@interface NIMQChatGetServerMembersResult : NSObject

@property (nullable, nonatomic, copy) NSArray <NIMQChatServerMember *> *memberArray;

@end


NS_ASSUME_NONNULL_END
