//
//  NIMLoadRecentSessionsOptions.h
//  NIMLib
//
//  Created by 丁文超 on 2020/4/10.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NIMLoadRecentSessionsOptions : NSObject

/**
 * 是否按照置顶会话排序
 */
@property (nonatomic, assign) BOOL sortByStickTopInfos;

@end

NS_ASSUME_NONNULL_END
