// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <AVKit/AVKit.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 基于 AVSampleBufferDisplayLayer 的显示视图（用于画中画）
@interface NECallKitSampleBufferDisplayView : UIView

/// 头像视图
@property(nonatomic, strong, readonly) UIImageView *avatarImageView;

- (void)setAvatarHidden:(BOOL)hidden;

- (void)setAvatarURL:(NSString *)avatarURL;

@end

NS_ASSUME_NONNULL_END
