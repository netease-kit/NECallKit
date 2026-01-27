// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// NECallLayoutVideoView 用于显示视频通话中的画面
/// 包含一个大画面和一个小画面，支持大小画面切换
@interface NECallLayoutVideoView : UIView

/// 初始化方法
- (instancetype)initWithFrame:(CGRect)frame;

/// 刷新视频视图显示
/// 根据当前是否显示本地大画面来设置本地和远端视频视图
- (void)refreshVideoView;

/// 切换大小画面
/// 点击小画面时调用此方法切换显示
- (void)switchVideoView;

/// 是否显示本地画面为大画面
/// YES: 本地画面显示在大画面，远端画面显示在小画面
/// NO: 远端画面显示在大画面，本地画面显示在小画面
@property(nonatomic, assign) BOOL showLocalBigView;

/// 本地视频是否开启
@property(nonatomic, assign) BOOL localVideoEnabled;

/// 远端视频是否开启
@property(nonatomic, assign) BOOL remoteVideoEnabled;

/// 是否只显示本地视频（用于呼叫中/接听中状态，此时不显示远端视频，且不能切换大小画面）
@property(nonatomic, assign) BOOL showLocalVideoOnly;

/// 远端用户显示名称（用于呼叫中/接听中状态显示）
@property(nonatomic, strong, nullable) NSString *remoteShowName;

/// 远端用户AccID（用于获取用户信息）
@property(nonatomic, strong, nullable) NSString *remoteUserAccid;

/// 远端用户头像URL（用于呼叫中/接听中状态显示）
@property(nonatomic, strong, nullable) NSString *remoteAvatar;

/// 是否是主叫（YES: 主叫/呼叫中, NO: 被叫/接听中）
@property(nonatomic, assign) BOOL isCaller;

@end

NS_ASSUME_NONNULL_END
