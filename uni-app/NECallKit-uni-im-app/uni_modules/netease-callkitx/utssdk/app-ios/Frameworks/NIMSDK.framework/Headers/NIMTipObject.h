//
//  NIMTipObject.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMMessageObjectProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface NIMTipObject : NSObject<NIMMessageObject>

/**
 * 附件
 */
@property (nonatomic, copy, readonly, nullable) NSString *attach;

/**
 * 第三方回调回来的自定义扩展字段
 */
@property (nonatomic, copy, readonly, nullable) NSString *callbackExt;

/**
 *  tip消息附件对象构造方法
 *
 *  @param attach 附件
 *
 *  @param callbackExt 第三方回调回来的自定义扩展字段(可选)
 */
- (instancetype)initWithAttach:(nullable NSString *)attach callbackExt:(nullable NSString *)callbackExt;

@end

NS_ASSUME_NONNULL_END