//
//  NERtcLinkEngineEnum.h
//  NERtcSDK
//
//  Created by Netease on 2021/9/13.
//  Copyright © 2021 Netease. All rights reserved.
//

#ifndef NERtcLinkEngineEnum_h
#define NERtcLinkEngineEnum_h

#import <Foundation/Foundation.h>
#import "NERtcEngineEnum.h"

/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @endif
 * @if Chinese
 * 被踢导致的onDisconnect
 * @endif
 */
#define kNERtcLinkKickOffDisconnect 99999

/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @endif
 * @if Chinese
 * 连接状态。
 * @endif
 */
typedef NS_ENUM(NSInteger, NERtcLinkResult) {
    /**
     * @if English
     * The feature is currently unavailable for overseas customers.
     * @endif
     * @if Chinese
     * 请求成功。
     * @endif
     */
    kNERtcLinkNoError = 0,
    /**
     * @if English
     * The feature is currently unavailable for overseas customers.
     * @endif
     * @if Chinese
     * 通用错误。
     * @endif
     */
    kNERtcLinkErrFatal,
    /**
     * @if English
     * The feature is currently unavailable for overseas customers.
     * @endif
     * @if Chinese
     * 非法错误。
     * <br>通常原因为呼叫状态冲突，例如：
     * - PSTN 引擎未初始化时，调用了 `setUpEngineWithContext` 以外的其他接口。
     * - 调用 `directCallHangupCall` 挂断直呼前，尚未调用 `directCallStartCallWithParam` 开启直呼。
     * @endif
     */
    kNERtcLinkErrorState,
    /**
     * @if English
     * The feature is currently unavailable for overseas customers.
     * @endif
     * @if Chinese
     * 连接失败。
     * <br>通常原因为 PSTN 服务器连接失败，例如网络中断导致连接服务器失败。
     * @endif
     */
    kNERtcLinkErrorConnect,
    /**
     * @if English
     * The feature is currently unavailable for overseas customers.
     * @endif
     * @if Chinese
     * 参数错误。
     * <br>请检查传参是否正确。
     * @endif
     */
    kNERtcLinkErrorParam,
    /**
     * @if English
     * Unsupported operation
     * @endif
     * @if Chinese
     * 不支持的操作。
     * @endif
     */
    kNERtcLinkErrNotSupported,
};

/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @endif
 * @if Chinese
 * 呼叫媒体类型。
 * @endif
 */
typedef NS_ENUM(NSInteger, NERtcLinkMediaType) {
    /**
     * @if English
     * The feature is currently unavailable for overseas customers.
     * @endif
     * @if Chinese
     * 语音呼叫
     * @endif
     */
    kNERtcLinkCallMediaTypeAudio = 0,
    /**
     * @if English
     * The feature is currently unavailable for overseas customers.
     * @endif
     * @if Chinese
     * 视频呼叫。
     * @note 此类型暂不支持，具体请联系网易云信商务经理。
     * @endif
     */
    kNERtcLinkCallMediaTypeVideo = 1,
};

/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @endif
 * @if Chinese
 * 被踢原因。
 * @endif
 */
typedef NS_ENUM(NSInteger, NERtcLinkKickOutReason) {
    /**
     * @if English
     * The feature is currently unavailable for overseas customers.
     * @endif
     * @if Chinese
     * 登录互踢。
     * <br>通常原因为同一个 uid 发起了两个或两个以上的直呼。
     * @endif
     */
    kNERtcLinkKickOutLogin = 1,
    /**
     * @if English
     * The feature is currently unavailable for overseas customers.
     * @endif
     * @if Chinese
     * 被 PSTN 服务端踢出直呼。
     * @endif
     */
    kNERtcLinkKickOutAdminOPerate = 2,
};

#endif /* NERtcLinkEngineEnum_h */
