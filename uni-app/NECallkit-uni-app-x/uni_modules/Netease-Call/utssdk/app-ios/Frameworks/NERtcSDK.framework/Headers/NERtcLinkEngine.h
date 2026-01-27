//
//  NERtcLinkEngine.h
//  NERtcSDK
//
//  Created by Netease on 2021/9/7.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INERtcLinkEngine.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @endif
 * @if Chinese
 * NERtcLinkEngine 类。
 * @endif
 */
NERTC_EXPORT @interface NERtcLinkEngine : NSObject<INERtcLinkEngineEx>

/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @endif
 * @if Chinese
 * 获取 NERtcLink 实例。
 * 获取之后一直到调用 `destroyEngine` 之前，返回的实例都将是同一个。
 * @return NERtcLink 实例
 * @endif
 */
+ (instancetype)sharedEngine;

/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @endif
 * @if Chinese
 * 销毁 NERtcLink 实例，并释放资源。
 * - 调用该方法将会释放 NERtcLink 中所有资源，之后将无法调用其他方法和接收到 SDK 回调。
 * - 如果想在销毁 NERtcLink 实例之后再次创建 NERtcLink 实例，需要等待 destroyEngine 方法执行结束后再创建实例。
 * @endif
 */
+ (int)destroyEngine;

@end

NS_ASSUME_NONNULL_END
