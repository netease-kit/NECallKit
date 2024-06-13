//
//  NIMQChatGetChannelCategoriesResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NIMQChatChannelCategory;
/**
 *  查询频道信息的回调类型
 */
@interface NIMQChatGetChannelCategoriesResult : NSObject

@property (nonatomic, copy) NSArray <NIMQChatChannelCategory *> *categories;

@end

NS_ASSUME_NONNULL_END
