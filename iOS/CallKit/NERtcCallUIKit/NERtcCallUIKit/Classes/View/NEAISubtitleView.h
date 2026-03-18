// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NERtcSDK/NERtcSDK.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// ASR 实时字幕视图
@interface NEAISubtitleView : UIView

/// 更新字幕内容
/// @param result ASR 字幕结果
- (void)updateSubtitle:(NERtcAsrCaptionResult *)result;

@end

NS_ASSUME_NONNULL_END
