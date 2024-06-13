//
//  NIMQChatUpdateChannelCategoryParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"


NS_ASSUME_NONNULL_BEGIN

/**
 *  修改频道分组信息的参数
 */
@interface NIMQChatUpdateChannelCategoryParam : NSObject

/**
 * 频道分组id
 */
@property (nonatomic, assign) unsigned long long categoryId;

/**
 * 名称
 */
@property (nullable, nonatomic, copy)   NSString *name;

/**
 * 自定义扩展
 */
@property (nullable, nonatomic, copy)   NSString *custom;

/**
 * 查看模式
 */
@property (nonatomic, assign)   NIMQChatChannelViewMode viewMode;


@end


NS_ASSUME_NONNULL_END
