//
//  NEScreenShareBroadcasterOptions.h
//  NEScreenShareKit
//
//  Created by IM.NetEase on 2021/5/12.
//  Copyright © 2021 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEScreenShareBroadcasterOptions : NSObject

/**
 *  AppGroup设置
 *  必须和Host App中设置一致，Broadcast需要依赖AppGroup与主HostApp进行通信
 *  AppGroup的相关设置可以参考文档：https://doc.yunxin.163.com/docs/jcyOTA0ODM/Tk2NDA0MTM?platformId=50192
 */
@property (nonatomic, copy) NSString *appGroup;

/**
 *  是否开启Debug模式，默认为NO
 *  设置为YES且`NEScreenShareHostOptions`中同时设置为YES时，开启Debug模式，可以不设置AppGroup，方便开发者临时调试
 *  Release环境必须设置为NO
 */
@property (nonatomic, assign) BOOL enableDebug;

/**
 *  Broadcast里视频数据分辨率，默认为0x0
 *  如设置此项，将按照设置参数进行Scale缩放
 *  建议设置成1920x1080或不设置，将按照真实设备屏幕分辨率进行采集缩放
 *  如设置成较小分辨率，如640x480, 将会按照真实设备屏幕分辨率与640x480进行缩放，以保证实际数据分辨率不超过640x480
 */
@property (nonatomic, assign) CGSize targetFrameSize;

/**
 *  设置Broadcast里的视频数据帧率
 *  建议按照业务场景设置，如屏幕共享主要分享静态画面，可设置为5；如分享主要是动画相关，对流畅性要求较高，可以设置为15
 *  最高设置上限为30
 */
@property (nonatomic, assign) NSUInteger frameRate;

/**
 *  Broadcast里是否采集音频数据，默认为NO
 *  可以采集系统或其他App正在播放的音频，以达到共享设备正在播放的音频到远端的目的
 *  需在Host App中组合使用，具体见`<NERtcReplayKit/NEScreenShareHost.h>`
 */
@property (nonatomic, assign) BOOL needAudioSampleBuffer;

/**
 *  Broadcast里是否采集麦克风音频数据，默认为NO
 *  支持扩展里面使用麦克风录音，必须与needAudioSampleBuffer同时开启，不支持单独设置needMicAudioSampleBuffer
 *  需在Host App中组合使用，具体见`<NERtcReplayKit/NEScreenShareHost.h>`
 */
@property (nonatomic, assign) BOOL needMicAudioSampleBuffer;

/**
 *  设置Broadcast里回调的音频数据采样率，默认是44.1k
 *  声道默认是Stereo
 */
@property (nonatomic, assign) int desiredSampleRate;

/**
 * 附加信息
 */
@property (nonatomic, strong) NSDictionary *extraInfoDict;

/**
 * Extension有50M内存限制，SDK内部会通过丢帧策略来避免触发系统的限制
 * 0: 不保护
 * 1 ~ 39: 无效，默认进行40M内存保护
 * 40: 当内存大于40M时，才进行丢帧保护
 * 45: 当内存大于45M时，才进行丢帧保护
 */
@property (nonatomic, assign) int memoryLimitProtectSize;

@end

NS_ASSUME_NONNULL_END
