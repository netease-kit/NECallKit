//
//  NEScreenSharePublicDefine.h
//  NEScreenShareKit
//
//  Created by IM.NetEase on 2021/5/14.
//  Copyright © 2021 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  视频数据的方向角度，竖屏状态下默认为0
 *  用来支持设备横竖屏
 */
typedef NS_ENUM(NSUInteger, NEScreenShareVideoRotationType) {
    kNEScreenShareVideoRotation_0 = 0,
    kNEScreenShareVideoRotation_90 = 90,
    kNEScreenShareVideoRotation_180 = 180,
    kNEScreenShareVideoRotation_270 = 270,
};

/**
 *  视频数据
 */
@interface NEScreenShareVideoFrame : NSObject

///视频数据分辨率宽
@property (nonatomic, assign)int width;
///视频数据分辨率高
@property (nonatomic, assign)int height;
///视频数据采集时间戳
@property (nonatomic, assign)uint64_t timeStamp;
///视频数据方向角度，横屏或竖屏下角度不同
@property (nonatomic, assign)NEScreenShareVideoRotationType rotation;
///视频数据Buffer
@property (nonatomic, strong)NSData *videoData;
///视频额外附加信息
@property (nonatomic, strong)NSDictionary *extraInfoDict;
///视频数据颜色空间. 0:bt601 limited range, 1:bt601 full range, 2:bt709 limited range, 3:bt709 full range
@property (nonatomic, assign)int colorSpace;

@end


/**
 *  音频数据
 */
@interface NEScreenShareAudioFrame : NSObject

///音频数据采样率，默认44.1k
@property (nonatomic, assign)int sampleRate;
///音频数据声道，默认stereo
@property (nonatomic, assign)int channels;
///每个声道的采样数
@property (nonatomic, assign)uint64_t samplesPerChannel;
///音频PCM数据Buffer
@property (nonatomic, strong)NSData *audioData;
///音频额外附加信息
@property (nonatomic, strong)NSDictionary *extraInfoDict;

@end
