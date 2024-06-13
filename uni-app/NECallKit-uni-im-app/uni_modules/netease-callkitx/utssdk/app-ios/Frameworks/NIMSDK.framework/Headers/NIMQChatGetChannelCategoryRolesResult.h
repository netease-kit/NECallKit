//
//  NIMQChatGetChannelCategoryRolesResult.h
//  NIMSDK
//
//  Created by Evang on 2022/1/15.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NIMQChatChannelCategoryRole;
/**
 *  获取频道分组下身份组信息列表
 */
@interface NIMQChatGetChannelCategoryRolesResult : NSObject

@property (nonatomic, copy) NSArray <NIMQChatChannelCategoryRole *> *categoryRoleArray;

@end

NS_ASSUME_NONNULL_END

