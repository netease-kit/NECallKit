//
//  V2NIMCollectionListResult.h
//  NIMSDK
//
//  Created by 陈吉力 on 2024/12/6.
//  Copyright © 2024 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class V2NIMCollection;

NS_ASSUME_NONNULL_BEGIN
@interface V2NIMCollectionListResult : NSObject
/// 总收藏条数
@property(nonatomic, assign, readonly)NSInteger totalCount;

/// 本次分页查询返回的收藏列表
@property(nonatomic, strong, readonly)NSArray <V2NIMCollection *> *collectionList;
@end

NS_ASSUME_NONNULL_END
