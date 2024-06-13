//
//  NIMQChatCreateChannelCategoryParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  创建频道分组入参
 */
@interface NIMQChatCreateChannelCategoryParam : NSObject

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long serverId;

/**
 * 名称
 */
@property (nonatomic, copy)   NSString *name;


/**
 * 自定义扩展
 */
@property (nonatomic, copy)   NSString *custom;

/**
 * 查看模式
 */
@property (nonatomic, assign) NIMQChatChannelViewMode viewMode;


@end


NS_ASSUME_NONNULL_END
