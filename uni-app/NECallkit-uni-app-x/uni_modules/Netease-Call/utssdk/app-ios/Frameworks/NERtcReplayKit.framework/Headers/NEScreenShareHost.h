//
//  NEScreenShareHost.h
//  NEScreenShareKit
//
//  Created by IM.NetEase on 2021/5/13.
//  Copyright © 2021 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NEScreenShareHostOptions.h"
#import "NEScreenSharePublicDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface NEScreenShareHost : NSObject

/**
 *  单例接口，在Host App中使用
 */
+ (instancetype)sharedInstance NS_EXTENSION_UNAVAILABLE_IOS("NEScreenShareHost is not supported in extensions");

/**
 *  设置屏幕共享相关参数，具体见`NEScreenShareHostOptions`
 */
- (void)setupScreenshareOptions:(NEScreenShareHostOptions *)options NS_EXTENSION_UNAVAILABLE_IOS("NEScreenShareHost is not supported in extensions");

/**
 *   开启录制插件，iOS12以后可用
 */
//- (void)launchBroadcaster API_AVAILABLE(ios(12.0)) NS_EXTENSION_UNAVAILABLE_IOS("NEScreenShareHost is not supported in extensions");

/**
 *   停止共享，系统停止共享文案显示默认为`屏幕共享已结束。`
 */
- (void)stopBroadcaster NS_EXTENSION_UNAVAILABLE_IOS("NEScreenShareHost is not supported in extensions");

/**
 *   停止共享，message用于显示在系统停止共享的弹窗文案，默认为`屏幕共享已结束。`
 */
- (void)stopBroadcasterWithMessage:(NSString *)message NS_EXTENSION_UNAVAILABLE_IOS("NEScreenShareHost is not supported in extensions");

/**
 *  是否使用Pull的形式拉取音频数据，默认为NO
 *  使用Pull的形式即业务侧使用`pullAudioData:(void *_Nonnull*_Nonnull)destBuffer length:(int)destLength sampleRate:(int&)sampleRate channels:(int&)channels`进行数据拉取
 *  设置YES，SDK将不会回调`onReceiveAudioFrame:(NEScreenShareAudioFrame *)audioFrame`和`onReceiveAudioFrameInfo:(NSDictionary<NSString *,id> *)audioFrameInfo`
 */
@property (nonatomic, assign) BOOL usePullAudioDataMode;

/**
 *   拉取音频共享数据
 *   如在`<NERtcReplayKit/NEScreenShareBroadcasterOptions.h>`中开启`needAudioSampleBuffer`
 *   并在`<NERtcReplayKit/NEScreenShareHost.h>`中开启`usePullAudioDataMode`
 *   SDK内部将会缓存系统的音频数据，数据长度为500ms
 *   业务侧可以通过此接口，向SDK拉取缓存的音频数据并混音到SDK中，达到共享系统音频的目的
 *   具体参见使用文档或SampleCode
 */
- (BOOL)pullAudioData:(void *_Nonnull*_Nonnull)destBuffer length:(int)destLength sampleRate:(int*)sampleRate channels:(int*)channels;

/**
 *   拉取音频共享数据
 *   如在`<NERtcReplayKit/NEScreenShareBroadcasterOptions.h>`中开启`needAudioSampleBuffer`
 *   并在`<NERtcReplayKit/NEScreenShareHost.h>`中开启`usePullAudioDataMode`
 *   SDK内部将会缓存系统的音频数据，数据长度为500ms
 *   业务侧可以通过此接口，向SDK拉取缓存的音频数据并混音到SDK中，达到共享系统音频的目的
 *   具体参见使用文档或SampleCode
 */
- (BOOL)pullAudioData:(void * _Nonnull *_Nonnull)destBuffer samplesPerChannel:(const int)samplesPerChannel sampleRate:(const int)sampleRate channels:(const int)channels;


@end

NS_ASSUME_NONNULL_END
