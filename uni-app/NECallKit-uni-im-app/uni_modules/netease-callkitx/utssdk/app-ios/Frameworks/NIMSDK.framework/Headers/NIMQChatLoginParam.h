//
//  NIMQChatLoginParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NIMQChatLoginAuthType) {
    NIMQChatLoginAuthTypeDefault = 0,
    NIMQChatLoginAuthTypeDynamicToken = 1,
};

/**
 * 动态token block
 */
typedef NSString*_Nonnull(^NIMProvideQChatDynamicTokenHandler)(NSString * __nullable account);

/**
 *  登录信息
 */
@interface NIMQChatLoginParam : NSObject

/**
 * 鉴权方式
 * 0：最初的loginToken的校验方式;
 * 1：基于appSecret计算的token鉴权方式;
 */
@property(nonatomic, assign) NIMQChatLoginAuthType authType;

/**
 * 动态token回调
 */
@property (nonatomic, strong) NIMProvideQChatDynamicTokenHandler dynamicTokenHandler;

@end

NS_ASSUME_NONNULL_END
