//
//  NESrceenAudioMixerUtil.h
//  NERtcDemo
//
//  Created by IM.NetEase on 2021/10/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NESrceenAudioMixerUtil : NSObject

/**
 *  音频数据混音工具
 *  用来为共享系统音频进行混音
 */
+ (void)MixAudioFrameData:(int16_t *)dst_mix_data scr_data:(int16_t *)scr_data samplesPerChannel:(int)samples_per_channel channels:(int)num_channels;

@end

NS_ASSUME_NONNULL_END
