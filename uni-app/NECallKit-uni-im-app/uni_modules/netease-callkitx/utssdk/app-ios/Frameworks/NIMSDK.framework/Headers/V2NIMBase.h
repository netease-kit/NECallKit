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

NS_ASSUME_NONNULL_END
