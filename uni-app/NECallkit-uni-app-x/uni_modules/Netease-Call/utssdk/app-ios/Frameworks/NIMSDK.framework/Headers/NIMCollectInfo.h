//
//  NIMCollectInfo.h
//  NIMLib
//
//  Created by 丁文超 on 2020/3/30.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NIMCollectInfo : NSObject

/**
 * 收藏项id
 */
@property (nonatomic, assign) NSUInteger id;

/**
 * 收藏类型
 */
@property (nonatomic, assign) NSInteger type;

/**
 * 数据，最大20KB
 */
@property (nonatomic, copy) NSString *data;

/**
 * 扩展字段,最大1KB
 */
@property (nonatomic, copy) NSString *ext;

/**
 * 去重唯一ID
 */
@property (nonatomic, copy) NSString *uniqueId;

/**
 * 创建时间(s)
 */
@property (nonatomic, assign) NSTimeInterval createTime;

/**
 * 更新时间(s)
 */
@property (nonatomic, assign) NSTimeInterval updateTime;

@end

NS_ASSUME_NONNULL_END
