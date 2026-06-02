// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 来电方信息
@interface NEIncomingCallerInfo : NSObject
/// 账号 ID
@property(nonatomic, copy) NSString *accountId;
/// 显示名称
@property(nonatomic, copy) NSString *displayName;
/// 头像 URL
@property(nonatomic, copy) NSString *avatarUrl;
/// 通话类型：0=音频, 1=视频, 2=群组
@property(nonatomic, assign) NSInteger callType;
/// 是否为多人通话邀请
@property(nonatomic, assign) BOOL multiCallInvite;
@end

typedef void (^NEIncomingCallBannerAcceptBlock)(void);
typedef void (^NEIncomingCallBannerRejectBlock)(void);
typedef void (^NEIncomingCallBannerBodyTapBlock)(void);

/// 来电横幅视图控制器
@interface NEIncomingCallBannerView : UIViewController

/// 接听回调
@property(nonatomic, copy) NEIncomingCallBannerAcceptBlock onAccept;
/// 拒绝回调
@property(nonatomic, copy) NEIncomingCallBannerRejectBlock onReject;
/// 点击主体回调
@property(nonatomic, copy) NEIncomingCallBannerBodyTapBlock onBodyTap;

- (instancetype)initWithCallerInfo:(NEIncomingCallerInfo *)callerInfo;

@end

NS_ASSUME_NONNULL_END
