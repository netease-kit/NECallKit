//
//  NIMQChatCreateServerRoleParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  新增服务器身份组
 */
@interface NIMQChatCreateServerRoleParam : NSObject
/**
 *  服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;
/**
 * 名称
 */
@property (nonnull, nonatomic, copy) NSString *name;
/**
 * 类型
 */
@property (nonatomic, assign) NIMQChatRoleType type;
/**
 * icon图
 */
@property (nonatomic, copy) NSString *icon;
/**
 * 自定义扩展
 */
@property (nonatomic, copy) NSString *ext;
/**
 * 优先级，数值越大，优先级越小。默认当前最大数值+1
 */
@property (nonatomic, strong) NSNumber *priority;

/**
 * 对某些资料内容另外的反垃圾的业务ID
 */
@property (nonatomic, copy)    NSString *antispamBusinessId;


@end


NS_ASSUME_NONNULL_END
