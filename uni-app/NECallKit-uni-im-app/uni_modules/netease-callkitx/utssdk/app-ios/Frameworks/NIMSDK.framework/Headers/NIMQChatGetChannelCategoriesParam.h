//
//  NIMQChatGetChannelCategoriesParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  获取频道分组列表入参
 */
@interface NIMQChatGetChannelCategoriesParam : NSObject

/**
 * 分组id数组
 */
@property (nonatomic, copy) NSArray *categoryIdArray;

@end


NS_ASSUME_NONNULL_END
