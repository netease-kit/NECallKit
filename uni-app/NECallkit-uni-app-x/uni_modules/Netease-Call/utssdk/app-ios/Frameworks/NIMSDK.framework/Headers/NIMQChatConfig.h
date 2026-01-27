//
//  NIMQChatConfig.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  NIM 圈组 配置项目
 */
@interface NIMQChatConfig : NSObject

/**
 *  返回配置项实例
 *
 *  @return 配置项
 */
+ (instancetype)sharedConfig;

/**
 *  开启消息缓存支持
 *  @discusssion 默认为 NO。
 */
@property (nonatomic,assign)    BOOL    enabledMessageCache;

/**
 * 默认NO，如果为YES，则开启圈组的自动订阅功能
 */
@property (nonatomic, assign) BOOL autoSubscribe;

@end

NS_ASSUME_NONNULL_END
