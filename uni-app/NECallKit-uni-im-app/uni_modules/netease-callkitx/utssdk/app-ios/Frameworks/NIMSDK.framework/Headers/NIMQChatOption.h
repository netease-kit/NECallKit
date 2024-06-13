//
//  NIMQChatOption.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 圈组选项
 */
@interface NIMQChatOption : NSObject

/**
 *  云信 Apns 推送证书名
 */
@property (nullable,nonatomic,copy)  NSString    *apnsCername;

/**
 *  云信 PushKit 推送证书名
 */
@property (nullable,nonatomic,copy)  NSString    *pkCername;

/**
 *  圈组选项初始化方法
 */
+ (instancetype)option;

@end

NS_ASSUME_NONNULL_END
