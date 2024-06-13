//
//  V2NIMSDKOption.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface V2NIMSDKOption : NSObject

/// 使用旧的登录接口，默认NO，不使用
@property(nonatomic,assign,readwrite) BOOL useV1Login;

@end

NS_ASSUME_NONNULL_END
