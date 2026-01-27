//
//  NEScreenShareHostDelegate.h
//  NEScreenShareKit
//
//  Created by IM.NetEase on 2021/5/13.
//  Copyright © 2021 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NEScreenSharePublicDefine.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NEScreenShareHostDelegate <NSObject>

@optional

/// 共享开始的回调
- (void)onBroadcastStarted;

/// 共享暂停的回调
- (void)onBroadcastPaused;

/// 共享恢复的回调
- (void)onBroadcastResumed;

/// 共享完成的回调
- (void)onBroadcastFinished;

/// 自定义消息通知
- (void)onNERtcReplayKitNotifyCustomInfo:(NSDictionary *)Info;

/// 音频帧回调
- (void)onReceiveAudioFrame:(NEScreenShareAudioFrame *)audioFrame;

/// 音频帧回调，key详见`<NERtcReplayKit/NEScreenSharePublicDefine.h>`
/// 此接口废弃，建议使用`onReceiveVideoFrame:(NEScreenShareAudioFrame *)videoFrame`
- (void)onReceiveAudioFrameInfo:(NSDictionary<NSString *,id> *)audioFrameInfo;

/// 视频帧回调
- (void)onReceiveVideoFrame:(NEScreenShareVideoFrame *)videoFrame;

/// 视频帧回调，key详见`<NERtcReplayKit/NEScreenSharePublicDefine.h>`
/// 此接口废弃，建议使用`onReceiveVideoFrame:(NEScreenShareVideoFrame *)videoFrame`
- (void)onReceiveVideoFrameInfo:(NSDictionary<NSString *,id> *)videoFrameInfo;

@end

NS_ASSUME_NONNULL_END
