//
//  V2NIMBase.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "V2NIMError.h"

NS_ASSUME_NONNULL_BEGIN

/// 成功通用回调
typedef void (^V2NIMSuccessCallback)(void);
/// 失败通用回调
typedef void (^V2NIMFailureCallback)(V2NIMError *error);
/// 完成进度回调，取值 0 -100
typedef void (^V2NIMProgressCallback)(NSUInteger);

/// 排序
typedef NS_ENUM(NSInteger, V2NIMSortOrder) {
    V2NIM_SORT_ORDER_DESC                         = 0,  ///< 降序
    V2NIM_SORT_ORDER_ASC                          = 1,  ///< 升序
};

/// 搜索关键字匹配条件
typedef NS_ENUM(NSInteger, V2NIMSearchKeywordMathType) {
    V2NIM_SEARCH_KEYWORD_MATH_TYPE_OR               = 0,  ///< 或
    V2NIM_SEARCH_KEYWORD_MATH_TYPE_AND              = 1,  ///< 与
};

/// 查询方向
typedef NS_ENUM(NSInteger, V2NIMQueryDirection) {
    V2NIM_QUERY_DIRECTION_DESC                           = 0,  ///< 按时间戳从大到小查询
    V2NIM_QUERY_DIRECTION_ASC                            = 1,  ///< 按时间戳从小到大查询
};

NS_ASSUME_NONNULL_END
