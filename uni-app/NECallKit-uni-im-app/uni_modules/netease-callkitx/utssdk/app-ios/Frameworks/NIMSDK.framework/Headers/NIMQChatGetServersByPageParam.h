//
//  NIMQChatGetServersByPageParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  分页查询服务器列表的参数
 */
@interface NIMQChatGetServersByPageParam : NSObject
/**
 * 时间戳
 * 拉取不晚于时间戳之前的服务器，传0表示拉最新的服务器
 */
@property (nonatomic, assign) NSTimeInterval timeTag;

/**
 * 条数限制
 */
@property (nonatomic, assign) NSInteger limit;
@end


NS_ASSUME_NONNULL_END
