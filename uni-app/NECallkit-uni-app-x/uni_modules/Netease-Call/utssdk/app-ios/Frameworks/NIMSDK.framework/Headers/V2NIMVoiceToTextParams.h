//
//  V2NIMVoiceToTextParams.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/9/15.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface V2NIMVoiceToTextParams : NSObject
/// 本地语音文件路径 voicePath/ voiceUrl必须二选一
@property (nonatomic, strong) NSString *voicePath;
/// 语音url，如果没有内部自动上传 voicePath/ voiceUrl必须二选一
@property (nonatomic, strong) NSString *voiceUrl;
/// 音频类型：语音类型，aac, wav, mp3, amr等
@property (nonatomic, strong) NSString *mimeType;
/// 采样率，8000kHz, 16000kHz等
@property (nonatomic, strong) NSString *sampleRate;
/// 语音时长, 单位毫秒
@property (nonatomic, assign) NSTimeInterval duration;
/// 文件存储场景
@property (nonatomic, strong) NSString *sceneName;
@end

NS_ASSUME_NONNULL_END
