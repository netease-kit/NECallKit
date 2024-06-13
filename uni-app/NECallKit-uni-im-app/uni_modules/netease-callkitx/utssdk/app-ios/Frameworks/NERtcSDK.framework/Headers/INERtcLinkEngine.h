//
//  INERtcLinkEngine.h
//  NERtcSDK
//
//  Created by Netease on 2021/9/7.
//  Copyright © 2021 Netease. All rights reserved.
//

#ifndef INERtcLinkEngine_h
#define INERtcLinkEngine_h

#import <Foundation/Foundation.h>
#import "NERtcLinkEngineDelegate.h"
#import "NERtcLinkEngineBase.h"
#import "NERtcLinkEngineEnum.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^NERtcLinkDirectCallStartCallCompletion)(NSError * _Nullable error);

@protocol INERtcLinkEngine <NSObject>

/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @param context   
 * @endif
 * @if Chinese
 * 创建 NERtcLinkEngine 并初始化 NERTCLink SDK 服务。
 * @note
 * - 请确保在调用其他 API 前先调用该方法创建并初始化 NERtc 实例。
 * - 若不再使用 NERtcLink  实例，需要调用 destroyEngine 进行销毁。<br>
 * @param context   context 初始化相关参数。详细信息请参考 {@link NERtcLinkEngineContext}。
 * @return  操作返回值，成功则返回 0
 * @endif
 */
- (int)setUpEngineWithContext:(NERtcLinkEngineContext *)context;

@end

@protocol INERtcLinkEngineDirectCall <NSObject>

/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @param callParam   
 * @param completion   
 * @endif
 * @if Chinese
 * 发起直呼。
 * @param callParam     呼叫参数。详细信息请参考 NERtcLinkEngineDirectCallCallParam。
 * @param completion    完成回调。
 * @endif
 */
- (int)directCallStartCallWithParam:(NERtcLinkEngineDirectCallCallParam *)callParam
                    completionBlock:(nullable NERtcLinkDirectCallStartCallCompletion)completion;


/**
 * @if English
 * The feature is currently unavailable for overseas customers.
 * @endif
 * @if Chinese
 * 挂断或取消呼叫。
 * - 发起直呼后，如果对方未接听，可以调用此接口取消呼叫。
 * - 通话过程中，主叫方可以随时调用此接口挂断通话。
 * @note 发起直呼后如果需要取消通话，建议在 directCallStartCallWithParam 的 completionBlock 返回之后再调用 directCallHangup 取消通话，否则可能导致呼叫状态异常。
 * @endif
 */
- (int)directCallHangupCall;

@end

@protocol INERtcLinkEngineEx <INERtcLinkEngine, INERtcLinkEngineDirectCall>

@end

NS_ASSUME_NONNULL_END


#endif /* INERtcLinkEngine_h */
