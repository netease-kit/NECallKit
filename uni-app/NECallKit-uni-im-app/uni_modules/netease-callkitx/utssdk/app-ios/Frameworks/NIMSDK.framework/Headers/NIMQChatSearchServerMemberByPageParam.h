//
// Created by chenjili on 2022/4/28.
// Copyright (c) 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * 检索服务器成员信息的参数
 */
@interface NIMQChatSearchServerMemberByPageParam : NSObject <NSCopying>
/**
* 检索关键字，目标检索昵称、账号，最大100个字符
*/
@property (nonnull, nonatomic, copy)NSString *keyword;

/**
 * 服务器ID
 */
@property (nonatomic, assign) unsigned long long serverId;

/**
 * 检索返回的最大记录数，最大和默认都是100
 */
@property (nullable, nonatomic, copy) NSNumber *limit;

@end

NS_ASSUME_NONNULL_END