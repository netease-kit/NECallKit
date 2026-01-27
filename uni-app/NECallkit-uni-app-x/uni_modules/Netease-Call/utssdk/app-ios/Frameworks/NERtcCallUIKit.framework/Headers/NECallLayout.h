// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NERtcCallKit/NERtcCallKit.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NECallLayoutVideoView;
@class NECallLayoutAudioView;

/// NECallLayout 用于选择并显示通话中的页面
/// 根据通话类型（音频/视频）自动创建对应的UI
/// 自动从 NECallStateManager 读取状态并监听变化
@interface NECallLayout : UIView

/// 初始化方法
/// @param frame 视图frame
- (instancetype)initWithFrame:(CGRect)frame;

/// 当前通话类型
@property(nonatomic, assign, readonly) NECallType callType;

/// 当前通话状态
@property(nonatomic, assign, readonly) NERtcCallStatus callStatus;

/// 视频通话视图（当 callType 为 NECallTypeVideo 时有效）
@property(nonatomic, strong, readonly, nullable) NECallLayoutVideoView *videoView;

/// 音频通话视图（当 callType 为 NECallTypeAudio 时有效）
@property(nonatomic, strong, readonly, nullable) NECallLayoutAudioView *audioView;

@end

NS_ASSUME_NONNULL_END
