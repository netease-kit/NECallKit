// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NERtcCallKit/NERtcCallKit.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// NECallLayoutAudioView 用于显示音频通话中的页面
/// 显示远端用户头像和用户名
@interface NECallLayoutAudioView : UIView

/// 初始化方法
- (instancetype)initWithFrame:(CGRect)frame;

/// 刷新UI显示
- (void)refreshUI;

/// 远端用户头像URL
@property(nonatomic, strong, nullable) NSString *remoteAvatar;

/// 远端用户显示名称
@property(nonatomic, strong, nullable) NSString *remoteShowName;

/// 远端用户AccID（用于生成默认头像）
@property(nonatomic, strong, nullable) NSString *remoteUserAccid;

/// 是否是主叫（YES: 主叫/呼叫中, NO: 被叫/接听中）
@property(nonatomic, assign) BOOL isCaller;

/// 当前通话状态（用于判断是否显示呼叫中/接听中UI）
@property(nonatomic, assign) NERtcCallStatus callStatus;

@end

NS_ASSUME_NONNULL_END
