//
//  V2NIMLocationInfo.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 空间坐标信息
@interface V2NIMLocationInfo : NSObject <NSCopying>

/// 空间坐标X
@property(nonatomic,assign,readwrite) double x;
/// 空间坐标Y
@property(nonatomic,assign,readwrite) double y;
/// 空间坐标Z
@property(nonatomic,assign,readwrite) double z;

@end

NS_ASSUME_NONNULL_END
