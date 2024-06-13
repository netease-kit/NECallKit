//
//  NIMQChatUpdateParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NIMQChatUpdateParam : NSObject<NSCopying>

/**
 * 操作附言
 */
@property(nullable, nonatomic, copy) NSString *postscript;

/**
 * 操作扩展字段
 */
@property(nullable, nonatomic, copy) NSString *extension;

/**
 * 推送文案
 */
@property(nullable, nonatomic, copy) NSString *pushContent;

/**
 * 推送payload
 */
@property(nullable, nonatomic, copy) NSDictionary *pushPayload;

/**
 * 环境变量
 */
@property(nullable, nonatomic, copy) NSString *env;

/**
 * 是否需要抄送
 */
@property(nonatomic, assign) BOOL routeEnable;


/**
 * 操作者账号
 */
@property(nullable, nonatomic, copy, readonly)  NSString *operatorAccid;

/**
 *  操作者客户端类型
 */
@property(nonatomic, assign, readonly) NSInteger operatorClientType;



@end

NS_ASSUME_NONNULL_END
