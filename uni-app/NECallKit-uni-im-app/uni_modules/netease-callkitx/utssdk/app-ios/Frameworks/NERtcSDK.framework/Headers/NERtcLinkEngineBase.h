//
//  NERtcLinkEngineBase.h
//  NERtcSDK
//
//  Created by Netease on 2021/9/13.
//  Copyright © 2021 Netease. All rights reserved.
//

#ifndef NERtcLinkEngineBase_h
#define NERtcLinkEngineBase_h

#import <Foundation/Foundation.h>
#import "NERtcLinkEngineEnum.h"

@protocol NERtcLinkEngineDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @endif
 * @if Chinese
 * 初始化设置 NERtcLinkEngineContext 的参数类。
 * @endif
 */
NERTC_EXPORT @interface NERtcLinkEngineContext : NSObject
/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @endif
 * @if Chinese
 * NERtcEngine 的回调接口，由用户提供。
 */
@property (nonatomic, weak, nullable) id<NERtcLinkEngineDelegate> delegate;

@end

/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @endif
 * @if Chinese
 * 直呼相关参数。
 */
NERTC_EXPORT @interface NERtcLinkEngineDirectCallCallParam : NSObject

/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @endif
 * @if Chinese
 * 被叫号码。
 * @endif
 */
@property (nonatomic, copy) NSString *callee;

/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @endif
 * @if Chinese
 * 应用的 App Key。在云信控制台创建应用后，可以查看对应的 App Key。
 * @endif
 */
@property (nonatomic, copy) NSString *appKey;

/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @endif
 * @if Chinese
 * Token，即安全认证签名（NERTC Token）。
 * @endif
 */
@property (nonatomic, copy) NSString *token;

/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @endif
 * @if Chinese
 * 房间名称。必须用主叫方 uid 指定房间名称。
 * @endif
 */
@property (nonatomic, copy) NSString *channelName;

/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @endif
 * @if Chinese
 * 用户的唯一标识 id，房间内每个用户的 uid 必须是唯一的。不可设置为 0 或负数。
 * @endif
 */
@property (nonatomic, assign) uint64_t uid;

/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @endif
 * @if Chinese
 * 外呼号码。
 * - 可选参数。未指定外呼号码时，会随机选取一个 AppKey 绑定的外呼号码发出呼叫。
 * - 外呼号码为开通高接通方案时，网易云信为您提供的主叫外呼号码。成功拨通外呼后，被叫方会收到主叫为外呼号码的来电。 
 * @endif
 */
@property (nonatomic, copy, nullable) NSString *didNumber;

/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @endif
 * @if Chinese
 * 呼叫类型。详细信息请参考 NERtcLinkMediaType 。
 * @endif
 */
@property (nonatomic, assign) NERtcLinkMediaType mediaType;

/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @endif
 * @if Chinese
 * 统计跟踪 ID。
 * @endif
 */
@property (nonatomic, copy, nullable) NSString *traceId;

/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @endif
 * @if Chinese
 * 是否加密号码(默认为NO)
 * @endif
 */
@property (nonatomic, assign) BOOL isNumberEncrypted;

@end

NS_ASSUME_NONNULL_END

#endif /* NERtcLinkEngineBase_h */
