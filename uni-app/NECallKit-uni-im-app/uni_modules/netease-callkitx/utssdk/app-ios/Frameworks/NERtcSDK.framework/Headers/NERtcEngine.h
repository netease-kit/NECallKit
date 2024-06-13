/*
 * Copyright (c) 2021 NetEase, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "INERtcEngineEx.h"
#import "NERtcEngineErrorCode.h"

NS_ASSUME_NONNULL_BEGIN


/**
 NERtcEngine 类
 */
NERTC_EXPORT @interface NERtcEngine : NSObject <INERtcEngineEx>

/**
  * @if English 
  * Gets the NERtcEngine instance.
  * <br>After you get the NERtcEngine instance, the instance remains the same until it is deleted by calling the destroyEngine method.
  * @return The NERtcEngine instance.
  * @endif
  * @if Chinese
  * 获取 NERtcEngine 实例
  * <br>获取之后一直到调用destroyEngine之前，返回的实例都将是同一个
  * @return NERtcEngine 实例
  * @endif
  */
+ (instancetype)sharedEngine;

/**
 * 销毁 NERtcEngine 实例，并释放资源。
 * <br>该方法释放 NERTC SDK 使用的所有资源。有些 App 只在用户需要时才进行实时音视频通信，完成音视频通话后，则将资源释放出来用于其他操作，该方法适用于此类情况。
 * - 该接口需要在调用 `leaveChannel`、并收到本端离开房间的回调后调用。或收到 `onNERtcEngineDidDisconnectWithReason:` 回调、重连失败时调用此接口销毁实例，并释放资源。
 * - 调用 `destroyEngine` 方法后，您将无法再使用 SDK 的其它方法和回调。如需再次使用实时音视频通话功能，您必须等待 `destroyEngine` 方法执行结束后，重新创建一个新的 NERtc 实例。
 * 
 * @note 
 * - 该方法为同步调用，需要等待 NERtcEngine 实例资源释放后才能执行其他操作。
 * - 该接口不得在 SDK 的回调中调用，在接口返回前也不允许调用 SDK 的其他任何接口。
 * - 如需在销毁后再次创建 NERtcEngine 实例、调用 SDK 接口，需要等待 `destroyEngine` 方法执行结束后，调用`sharedEngine` 获取一个新的 NERtcEngine 实例，再调用 `setupEngineWithContext` 初始化 SDK。
 */
+ (int)destroyEngine;

/**
 * @if Chinese
 * 查询 SDK 版本号， 该方法在加入房间前后都能调用
 * @since V4.6.10
 * @return 版本号，格式为字符串，如 1.0.0。
 * @endif
 */
+ (NSString *)getVersion;

@end

NS_ASSUME_NONNULL_END
