//
//  V2NIMAntispamConfig.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 反垃圾配置
@interface V2NIMAntispamConfig : NSObject

/// 指定易盾业务ID，而不使用云信后台配置的安全通
@property(nonatomic,strong,readwrite) NSString *antispamBusinessId;

@end

NS_ASSUME_NONNULL_END
