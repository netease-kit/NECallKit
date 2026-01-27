//
//  NEScreenShareSampleHandler.h
//  NEScreenShareBroadcaster
//
//  Created by IM.NetEase on 2021/5/28.
//

#import <ReplayKit/ReplayKit.h>
@class NEScreenShareBroadcasterOptions;

NS_ASSUME_NONNULL_BEGIN

@protocol NEScreenShareSampleHandlerDelegate <NSObject>

/**
 * Host主动要求停止Broadcast
 * 应在此方法内调用SampleHandle的`finishBroadcastWithError:(NSError *)error`
 */
@optional
- (void)onRequestToFinishBroadcastWithError:(NSError *)error;

@end

API_AVAILABLE(ios(11.0))
@interface NEScreenShareSampleHandler : NSObject

+ (instancetype)sharedInstance;
- (instancetype)init NS_UNAVAILABLE;

/**
 *  事件代理
 */
@property (nonatomic, weak)id<NEScreenShareSampleHandlerDelegate> delegate;

/**
 *  在Broadcast SampleHandler中`broadcastStartedWithSetupInfo:`中调用
 *  相关options参数，具体见NEScreenShareBroadcasterOptions
 */
- (void)broadcastStartedWithSetupInfo:(NEScreenShareBroadcasterOptions *)options;

/**
 *  在Broadcast SampleHandler中`broadcastPaused`中调用
 */
- (void)broadcastPaused;

/**
 *  在Broadcast SampleHandler中`broadcastPaused`中调用
 */
- (void)broadcastResumed;

/**
 *  在Broadcast SampleHandler中`broadcastResumed`中调用
 */
- (void)broadcastFinished;

/**
 *  在Broadcast SampleHandler中`processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType`中调用
 *  将Broadcast中系统扩展产生的数据，传递给SDK
 */
- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType;

@end

NS_ASSUME_NONNULL_END
