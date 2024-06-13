//
//  NERtcLinkEngineDelegate.h
//  NERtcSDK
//
//  Created by Netease on 2021/9/24.
//  Copyright © 2021 Netease. All rights reserved.
//

#ifndef NERtcLinkEngineDelegate_h
#define NERtcLinkEngineDelegate_h

#import <Foundation/Foundation.h>
#import "NERtcLinkEngineEnum.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @endif
 * @if Chinese
 * NERtcLinkEngine 常用回调。
 * @endif
 */
@protocol NERtcLinkEngineDirectCallDelegate <NSObject>

 @optional

/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @endif
 * @if Chinese
 * 直呼时，对端开始振铃回调。
 * <br>主叫方发起直呼后，如果对端开始振铃，会触发此回调。
 * @endif
 */
- (void)onDirectCallRing;

/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @endif
 * @if Chinese
 * 直呼时，对端已接听回调。
 * <br>主叫方发起直呼后，如果对端接听通话，会触发此回调。
 * @endif
 */
- (void)onDirectCallAccept;

/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @endif
 * @if Chinese
 * 直呼时，对端已接听回调。
 * <br>主叫方发起直呼后，如果对端接听通话，会触发此回调。
 * @param mediaType 对端接听的媒体类型(发起视频呼叫的情况下，对端可能仅接听语音)
 * @endif
 */
- (void)onDirectCallAcceptWithMediaType:(NERtcLinkMediaType)mediaType;

/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @param reason        
 * @param error             
 * @param isCallEstablished     
 * @endif
 * @if Chinese
 * 直呼时，通话已挂断回调。
 * <br>以下场景会触发此回调：
 * - 主叫方发起直呼后，取消呼叫。此时 reason 为 1000。
 * - 主叫方发起直呼后，被叫方拒接。
 * - 主叫方发起直呼，呼叫接通后，任意一方挂断通话。
 * - 由于运营商信号或其他原因导致的通话中断。
 * <br>详细信息请参考[融合呼叫状态码](https://doc.yunxin.163.com/docs/jcyOTA0ODM/zg1MDI4MzE)
 * @param reason             挂断原因。   
 * @param error              错误信息，若状态正常则不返回 errMsg。   
 * @param isCallEstablished  呼叫是否已接通。
 * @endif
 */
- (void)onDirectCallHangupWithReason:(int)reason
                               error:(nullable NSError *)error
                   isCallEstablished:(BOOL)isCallEstablished;

/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @endif
 * @if Chinese
 * 直呼时，通话断开连接回调。
 * <br>呼叫接通后，对方断开连接时会触发此回调。
 * - 主叫方被 PSTN 服务端踢出通话。
 * - 由于网络状态或其他原因导致的通话中断。
 * <br>详细信息请参考[融合呼叫状态码](https://doc.yunxin.163.com/docs/jcyOTA0ODM/zg1MDI4MzE)
 * @param error     断开原因。其中，99999（kNERtcLinkKickOffDisconnect） 表示被 PSTN 服务端踢出导致断开连接。 请通过 error 的 userInfo 字段中的 reason 来确认被踢原因。
 * @endif
 */
- (void)onDirectCallDisconnectWithError:(NSError *)error;

@end

@protocol NERtcLinkEngineDelegate <NERtcLinkEngineDirectCallDelegate>

@end

NS_ASSUME_NONNULL_END

#endif /* NERtcLinkEngineDelegate_h */
