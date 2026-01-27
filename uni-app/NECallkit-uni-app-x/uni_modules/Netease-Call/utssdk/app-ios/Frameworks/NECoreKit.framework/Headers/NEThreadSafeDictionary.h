// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 线程安全 字典
@interface NEThreadSafeDictionary<KeyType, ObjectType> : NSMutableDictionary <KeyType, ObjectType>

@end

NS_ASSUME_NONNULL_END
