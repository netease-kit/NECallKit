// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NECallLayoutVideoView.h"
#import <NECommonKit/NECommonKit-Swift.h>
#import <NERtcCallKit/NECallEngine.h>
#import <NEXKitBase/NEXKitBase.h>
#import <NIMSDK/NIMSDK.h>
#import <SDWebImage/SDWebImage.h>
#import "NECallKitUtil.h"
#import "NECallStateManager.h"
#import "NERtcCallUIKit.h"
#import "NEVideoView.h"

static NSString *const kCallLayoutVideoViewTag = @"CallLayoutVideoView";

@interface NECallLayoutVideoView ()

/// 大画面视频视图
@property(nonatomic, strong) NEVideoView *bigVideoView;

/// 小画面视频视图
@property(nonatomic, strong) NEVideoView *smallVideoView;

/// 远端用户头像视图（用于呼叫中/接听中状态）
@property(nonatomic, strong, nullable) UIImageView *remoteAvatarView;

/// 标题标签（显示昵称）
@property(nonatomic, strong, nullable) UILabel *titleLabel;

/// 子标题标签（显示呼叫文案）
@property(nonatomic, strong, nullable) UILabel *subTitleLabel;

/// 资源包
@property(nonatomic, strong) NSBundle *bundle;

/// 小画面拖拽开始时的中心点位置
@property(nonatomic, assign) CGPoint smallVideoViewStartCenter;

/// 小画面是否已经手动定位（拖拽过）
@property(nonatomic, assign) BOOL smallVideoViewHasManualPosition;

/// 小画面是否已经设置了初始位置
@property(nonatomic, assign) BOOL smallVideoViewInitialPositionSet;

@end

@implementation NECallLayoutVideoView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    NEXKitBaseLogInfo(@"[%@] initWithFrame: %@", kCallLayoutVideoViewTag,
                      NSStringFromCGRect(frame));
    _showLocalBigView = NO;  // 默认远端画面显示在大画面
    _localVideoEnabled = YES;
    _remoteVideoEnabled = YES;
    _bundle = [NSBundle bundleForClass:[NERtcCallUIKit class]];
    [self setupUI];
  }
  return self;
}

- (void)dealloc {
  [[NECallEngine sharedInstance] setupLocalView:nil];
}

- (void)setupUI {
  NEXKitBaseLogInfo(@"[%@] setupUI, bounds=%@, frame=%@, showLocalVideoOnly=%d",
                    kCallLayoutVideoViewTag, NSStringFromCGRect(self.bounds),
                    NSStringFromCGRect(self.frame), self.showLocalVideoOnly);
  self.backgroundColor = [UIColor blackColor];

  // 设置 userID，用于判断是本地还是远端
  NSString *currentUserId = [NIMSDK.sharedSDK.v2LoginService getLoginUser];
  self.bigVideoView.userID = currentUserId;  // 初始设置为当前用户，后续会根据 showLocalBigView 调整
  self.smallVideoView.userID =
      currentUserId;  // 初始设置为当前用户，后续会根据 showLocalBigView 调整

  // 添加大画面
  [self addSubview:self.bigVideoView];
  [NSLayoutConstraint activateConstraints:@[
    [self.bigVideoView.leftAnchor constraintEqualToAnchor:self.leftAnchor],
    [self.bigVideoView.rightAnchor constraintEqualToAnchor:self.rightAnchor],
    [self.bigVideoView.topAnchor constraintEqualToAnchor:self.topAnchor],
    [self.bigVideoView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
  ]];

  // 添加小画面
  [self addSubview:self.smallVideoView];
  // 小画面位于右上角
  CGFloat smallViewWidth = 90;
  CGFloat smallViewHeight = 160;
  CGFloat margin = 20;
  CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;

  self.smallVideoView.translatesAutoresizingMaskIntoConstraints = YES;
  // 使用 frame 布局，不使用约束
  // 如果 bounds 已经正确，立即设置初始位置；否则在 layoutSubviews 中设置
  if (self.bounds.size.width > 0 && self.bounds.size.height > 0 && !self.showLocalVideoOnly) {
    CGFloat x = self.bounds.size.width - smallViewWidth - margin;
    CGFloat y = statusBarHeight + margin;
    self.smallVideoView.frame = CGRectMake(x, y, smallViewWidth, smallViewHeight);
    self.smallVideoViewInitialPositionSet = YES;
    NEXKitBaseLogInfo(
        @"[%@] setupUI: set initial position for smallVideoView immediately, frame=%@",
        kCallLayoutVideoViewTag, NSStringFromCGRect(self.smallVideoView.frame));
  } else {
    // 先设置宽高，位置在 layoutSubviews 中设置
    self.smallVideoView.frame = CGRectMake(0, 0, smallViewWidth, smallViewHeight);
    NEXKitBaseLogInfo(@"[%@] setupUI: skip setting initial position, bounds.size=%@, "
                      @"showLocalVideoOnly=%d, set frame size only",
                      kCallLayoutVideoViewTag, NSStringFromCGSize(self.bounds.size),
                      self.showLocalVideoOnly);
  }

  self.smallVideoView.clipsToBounds = YES;
  self.smallVideoView.layer.cornerRadius = 8;

  // 添加点击手势，点击小画面切换大小画面（只在非 showLocalVideoOnly 模式下启用）
  UITapGestureRecognizer *tap =
      [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchVideoView)];
  [self.smallVideoView addGestureRecognizer:tap];

  // 添加拖拽手势（只在非 showLocalVideoOnly 模式下启用）
  UIPanGestureRecognizer *pan =
      [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
  [self.smallVideoView addGestureRecognizer:pan];

  // 设置拖拽手势的优先级，确保点击和拖拽都能正常工作
  [tap requireGestureRecognizerToFail:pan];

  // 初始化时刷新视频视图
  NEXKitBaseLogInfo(
      @"[%@] setupUI: before refreshVideoView, smallVideoView.frame=%@, smallVideoView.center=%@",
      kCallLayoutVideoViewTag, NSStringFromCGRect(self.smallVideoView.frame),
      NSStringFromCGPoint(self.smallVideoView.center));
  [self refreshVideoView];
  NEXKitBaseLogInfo(
      @"[%@] setupUI: after refreshVideoView, smallVideoView.frame=%@, smallVideoView.center=%@",
      kCallLayoutVideoViewTag, NSStringFromCGRect(self.smallVideoView.frame),
      NSStringFromCGPoint(self.smallVideoView.center));

  // 如果只显示本地视频，设置呼叫中/接听中的UI
  if (self.showLocalVideoOnly) {
    [self setupCallingUI];
  }
}

- (NEVideoView *)bigVideoView {
  if (!_bigVideoView) {
    _bigVideoView = [[NEVideoView alloc] init];
    _bigVideoView.backgroundColor = [UIColor darkGrayColor];
    _bigVideoView.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return _bigVideoView;
}

- (NEVideoView *)smallVideoView {
  if (!_smallVideoView) {
    _smallVideoView = [[NEVideoView alloc] init];
    _smallVideoView.backgroundColor = [UIColor darkGrayColor];
    _smallVideoView.translatesAutoresizingMaskIntoConstraints = YES;
    _smallVideoView.userInteractionEnabled = YES;
  }
  return _smallVideoView;
}

- (void)refreshVideoView {
  NEXKitBaseLogInfo(
      @"[%@] refreshVideoView, showLocalBigView=%d, localVideoEnabled=%d, remoteVideoEnabled=%d, "
      @"showLocalVideoOnly=%d, smallVideoView.frame=%@, smallVideoView.center=%@",
      kCallLayoutVideoViewTag, self.showLocalBigView, self.localVideoEnabled,
      self.remoteVideoEnabled, self.showLocalVideoOnly,
      NSStringFromCGRect(self.smallVideoView.frame),
      NSStringFromCGPoint(self.smallVideoView.center));

  // 获取当前用户ID和远端用户ID
  NSString *currentUserId = [NIMSDK.sharedSDK.v2LoginService getLoginUser];
  NSString *remoteUserId = nil;
  NECallStateManager *stateManager = [NECallStateManager sharedInstance];
  NECallInfo *callInfo = stateManager.callInfo;
  if (callInfo) {
    if ([callInfo.currentAccId isEqualToString:callInfo.callerInfo.accId]) {
      remoteUserId = callInfo.calleeInfo.accId;
    } else {
      remoteUserId = callInfo.callerInfo.accId;
    }
  }

  // 如果只显示本地视频（呼叫中/接听中状态）
  if (self.showLocalVideoOnly) {
    NEXKitBaseLogInfo(
        @"[%@] refreshVideoView: showLocalVideoOnly mode, only setup local video on bigVideoView",
        kCallLayoutVideoViewTag);
    // 只显示本地视频在大画面，隐藏小画面
    [[NECallEngine sharedInstance]
        setupLocalView:self.localVideoEnabled ? self.bigVideoView.videoView : nil];
    [[NECallEngine sharedInstance] setupRemoteView:nil];

    // 设置 userID
    self.bigVideoView.userID = currentUserId;

    // 隐藏小画面
    self.smallVideoView.hidden = YES;

    // 更新 coverView 和 title
    self.bigVideoView.coverView.hidden = self.localVideoEnabled;
    [self updateTitleForVideoView:self.bigVideoView cameraMute:!self.localVideoEnabled];

    return;
  }

  // 正常模式：显示本地和远端视频
  self.smallVideoView.hidden = NO;  // 确保小画面可见

  if (self.showLocalBigView) {
    // 本地画面显示在大画面，远端画面显示在小画面
    NEXKitBaseLogInfo(
        @"[%@] refreshVideoView: 本地大画面模式, setupLocalView=%@, setupRemoteView=%@",
        kCallLayoutVideoViewTag, self.localVideoEnabled ? @"bigVideoView" : @"nil",
        self.remoteVideoEnabled ? @"smallVideoView" : @"nil");
    [[NECallEngine sharedInstance]
        setupLocalView:self.localVideoEnabled ? self.bigVideoView.videoView : nil];
    [[NECallEngine sharedInstance]
        setupRemoteView:self.remoteVideoEnabled ? self.smallVideoView.videoView : nil];

    // 设置 userID
    self.bigVideoView.userID = currentUserId;
    self.smallVideoView.userID = remoteUserId;

    // 更新 coverView 和 title
    self.smallVideoView.coverView.hidden = self.remoteVideoEnabled;
    self.bigVideoView.coverView.hidden = self.localVideoEnabled;
    [self updateTitleForVideoView:self.bigVideoView cameraMute:!self.localVideoEnabled];
    [self updateTitleForVideoView:self.smallVideoView cameraMute:!self.remoteVideoEnabled];
  } else {
    // 远端画面显示在大画面，本地画面显示在小画面
    NEXKitBaseLogInfo(
        @"[%@] refreshVideoView: 远端大画面模式, setupLocalView=%@, setupRemoteView=%@",
        kCallLayoutVideoViewTag, self.localVideoEnabled ? @"smallVideoView" : @"nil",
        self.remoteVideoEnabled ? @"bigVideoView" : @"nil");
    [[NECallEngine sharedInstance]
        setupLocalView:self.localVideoEnabled ? self.smallVideoView.videoView : nil];
    [[NECallEngine sharedInstance]
        setupRemoteView:self.remoteVideoEnabled ? self.bigVideoView.videoView : nil];

    // 设置 userID
    self.bigVideoView.userID = remoteUserId;
    self.smallVideoView.userID = currentUserId;

    // 更新 coverView 和 title
    self.bigVideoView.coverView.hidden = self.remoteVideoEnabled;
    self.smallVideoView.coverView.hidden = self.localVideoEnabled;
    [self updateTitleForVideoView:self.bigVideoView cameraMute:!self.remoteVideoEnabled];
    [self updateTitleForVideoView:self.smallVideoView cameraMute:!self.localVideoEnabled];
  }

  NEXKitBaseLogInfo(
      @"[%@] refreshVideoView: bigVideoView.coverView.hidden=%d, "
      @"smallVideoView.coverView.hidden=%d, smallVideoView.frame=%@, smallVideoView.center=%@",
      kCallLayoutVideoViewTag, self.bigVideoView.coverView.hidden,
      self.smallVideoView.coverView.hidden, NSStringFromCGRect(self.smallVideoView.frame),
      NSStringFromCGPoint(self.smallVideoView.center));
}

- (void)switchVideoView {
  // 如果只显示本地视频，不允许切换
  if (self.showLocalVideoOnly) {
    NEXKitBaseLogInfo(@"[%@] switchVideoView: ignored because showLocalVideoOnly is YES",
                      kCallLayoutVideoViewTag);
    return;
  }
  self.showLocalBigView = !self.showLocalBigView;
  [self refreshVideoView];
}

- (void)setShowLocalBigView:(BOOL)showLocalBigView {
  if (_showLocalBigView != showLocalBigView) {
    _showLocalBigView = showLocalBigView;
    [self refreshVideoView];
  }
}

- (void)setLocalVideoEnabled:(BOOL)localVideoEnabled {
  if (_localVideoEnabled != localVideoEnabled) {
    _localVideoEnabled = localVideoEnabled;
    [self refreshVideoView];
  }
}

- (void)setRemoteVideoEnabled:(BOOL)remoteVideoEnabled {
  if (_remoteVideoEnabled != remoteVideoEnabled) {
    NEXKitBaseLogInfo(@"[%@] setRemoteVideoEnabled: %d -> %d", kCallLayoutVideoViewTag,
                      _remoteVideoEnabled, remoteVideoEnabled);
    _remoteVideoEnabled = remoteVideoEnabled;
    [self refreshVideoView];
  }
}

- (void)setShowLocalVideoOnly:(BOOL)showLocalVideoOnly {
  if (_showLocalVideoOnly != showLocalVideoOnly) {
    NEXKitBaseLogInfo(
        @"[%@] setShowLocalVideoOnly: %d -> %d, smallVideoView.frame=%@, smallVideoView.center=%@",
        kCallLayoutVideoViewTag, _showLocalVideoOnly, showLocalVideoOnly,
        NSStringFromCGRect(self.smallVideoView.frame),
        NSStringFromCGPoint(self.smallVideoView.center));
    _showLocalVideoOnly = showLocalVideoOnly;
    // 如果只显示本地视频，强制设置为本地大画面
    if (showLocalVideoOnly) {
      self.showLocalBigView = YES;
      // 移除旧的UI，重新设置
      [self removeCallingUI];
      [self setupCallingUI];
      // 重置手动定位标记，因为隐藏了小画面
      self.smallVideoViewHasManualPosition = NO;
      self.smallVideoViewInitialPositionSet = NO;
    } else {
      [self removeCallingUI];
      // 当切换到正常模式时，如果之前没有手动定位，重置到默认位置
      self.smallVideoViewInitialPositionSet = NO;
      NEXKitBaseLogInfo(@"[%@] setShowLocalVideoOnly: reset smallVideoViewInitialPositionSet, "
                        @"calling setNeedsLayout",
                        kCallLayoutVideoViewTag);
      [self setNeedsLayout];
    }
    [self refreshVideoView];
    NEXKitBaseLogInfo(@"[%@] setShowLocalVideoOnly: after refreshVideoView, "
                      @"smallVideoView.frame=%@, smallVideoView.center=%@",
                      kCallLayoutVideoViewTag, NSStringFromCGRect(self.smallVideoView.frame),
                      NSStringFromCGPoint(self.smallVideoView.center));
  }
}

- (void)layoutSubviews {
  [super layoutSubviews];

  // 记录每次 layoutSubviews 的详细信息
  NEXKitBaseLogInfo(
      @"[%@] layoutSubviews: bounds=%@, showLocalVideoOnly=%d, smallVideoViewHasManualPosition=%d, "
      @"smallVideoViewInitialPositionSet=%d, smallVideoView.frame=%@, smallVideoView.center=%@",
      kCallLayoutVideoViewTag, NSStringFromCGRect(self.bounds), self.showLocalVideoOnly,
      self.smallVideoViewHasManualPosition, self.smallVideoViewInitialPositionSet,
      NSStringFromCGRect(self.smallVideoView.frame),
      NSStringFromCGPoint(self.smallVideoView.center));

  // 设置小画面的初始位置（只在没有手动定位时设置）
  BOOL condition1 = !self.showLocalVideoOnly;
  BOOL condition2 = !self.smallVideoViewHasManualPosition;
  BOOL condition3 = (self.smallVideoView != nil);
  BOOL condition4 = (self.smallVideoView.superview != nil);
  BOOL condition5 = (self.bounds.size.width > 0);
  BOOL condition6 = (self.bounds.size.height > 0);

  NEXKitBaseLogInfo(
      @"[%@] layoutSubviews: checking conditions, showLocalVideoOnly=%d, "
      @"smallVideoViewHasManualPosition=%d, smallVideoView=%@, superview=%@, bounds.size=%@, "
      @"allConditionsMet=%d",
      kCallLayoutVideoViewTag, self.showLocalVideoOnly, self.smallVideoViewHasManualPosition,
      self.smallVideoView ? @"exists" : @"nil", self.smallVideoView.superview ? @"exists" : @"nil",
      NSStringFromCGSize(self.bounds.size),
      (condition1 && condition2 && condition3 && condition4 && condition5 && condition6));

  if (condition1 && condition2 && condition3 && condition4 && condition5 && condition6) {
    CGFloat smallViewWidth = 90;
    CGFloat smallViewHeight = 160;
    CGFloat margin = 20;
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;

    // 计算期望的 frame（右上角位置）
    CGFloat expectedX = self.bounds.size.width - smallViewWidth - margin;
    CGFloat expectedY = statusBarHeight + margin;
    CGRect expectedFrame = CGRectMake(expectedX, expectedY, smallViewWidth, smallViewHeight);

    // 检查当前位置是否与期望位置一致（允许 1 像素的误差）
    CGRect currentFrame = self.smallVideoView.frame;
    CGFloat deltaX = fabs(currentFrame.origin.x - expectedFrame.origin.x);
    CGFloat deltaY = fabs(currentFrame.origin.y - expectedFrame.origin.y);

    NEXKitBaseLogInfo(@"[%@] layoutSubviews: checking position, currentFrame=%@, expectedFrame=%@, "
                      @"deltaX=%.2f, deltaY=%.2f, smallVideoViewInitialPositionSet=%d",
                      kCallLayoutVideoViewTag, NSStringFromCGRect(currentFrame),
                      NSStringFromCGRect(expectedFrame), deltaX, deltaY,
                      self.smallVideoViewInitialPositionSet);

    // 如果位置不正确（可能是首次设置，或者 bounds 变化后被重置），重新设置
    // 注意：即使 smallVideoViewInitialPositionSet=YES，如果位置被重置了（比如 bounds
    // 变化），也要重新设置
    if (!self.smallVideoViewInitialPositionSet || deltaX > 1.0 || deltaY > 1.0) {
      NEXKitBaseLogInfo(
          @"[%@] layoutSubviews: before setting frame, smallVideoView.frame=%@, expectedFrame=%@, "
          @"deltaX=%.2f, deltaY=%.2f, smallVideoViewInitialPositionSet=%d",
          kCallLayoutVideoViewTag, NSStringFromCGRect(currentFrame),
          NSStringFromCGRect(expectedFrame), deltaX, deltaY, self.smallVideoViewInitialPositionSet);
      self.smallVideoView.frame = expectedFrame;
      self.smallVideoViewInitialPositionSet = YES;

      NEXKitBaseLogInfo(@"[%@] layoutSubviews: set initial position for smallVideoView, frame=%@",
                        kCallLayoutVideoViewTag, NSStringFromCGRect(self.smallVideoView.frame));
    } else {
      NEXKitBaseLogInfo(@"[%@] layoutSubviews: position already correct, no need to update, "
                        @"currentFrame=%@, expectedFrame=%@",
                        kCallLayoutVideoViewTag, NSStringFromCGRect(currentFrame),
                        NSStringFromCGRect(expectedFrame));
    }
  } else {
    NEXKitBaseLogInfo(
        @"[%@] layoutSubviews: skip setting initial position, showLocalVideoOnly=%d, "
        @"smallVideoViewHasManualPosition=%d, smallVideoViewInitialPositionSet=%d, bounds.size=%@",
        kCallLayoutVideoViewTag, self.showLocalVideoOnly, self.smallVideoViewHasManualPosition,
        self.smallVideoViewInitialPositionSet, NSStringFromCGSize(self.bounds.size));
  }
}

#pragma mark - Calling/Called UI Setup

- (void)setupCallingUI {
  NEXKitBaseLogInfo(@"[%@] setupCallingUI, isCaller=%d", kCallLayoutVideoViewTag, self.isCaller);

  if (self.isCaller) {
    // calling（主叫）：右上角布局
    [self setupCallingUIForCaller];
  } else {
    // called（被叫）：中间布局
    [self setupCallingUIForCalled];
  }

  // 更新UI内容
  [self updateCallingUI];
}

- (void)setupCallingUIForCaller {
  // 添加远端头像视图（右上角）
  if (!self.remoteAvatarView) {
    self.remoteAvatarView = [[UIImageView alloc] init];
    self.remoteAvatarView.image = [UIImage imageNamed:@"avator"
                                             inBundle:self.bundle
                        compatibleWithTraitCollection:nil];
    self.remoteAvatarView.translatesAutoresizingMaskIntoConstraints = NO;
    self.remoteAvatarView.clipsToBounds = YES;
    self.remoteAvatarView.layer.cornerRadius = 4.0;
    [self addSubview:self.remoteAvatarView];

    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    [NSLayoutConstraint activateConstraints:@[
      [self.remoteAvatarView.widthAnchor constraintEqualToConstant:60],
      [self.remoteAvatarView.heightAnchor constraintEqualToConstant:60],
      [self.remoteAvatarView.topAnchor constraintEqualToAnchor:self.topAnchor
                                                      constant:statusBarHeight + 20],
      [self.remoteAvatarView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-20]
    ]];
  }

  // 添加标题标签（显示昵称，右对齐，在avatar左侧）
  if (!self.titleLabel) {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentRight;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.titleLabel];

    [NSLayoutConstraint activateConstraints:@[
      [self.titleLabel.topAnchor constraintEqualToAnchor:self.remoteAvatarView.topAnchor
                                                constant:5],
      [self.titleLabel.rightAnchor constraintEqualToAnchor:self.remoteAvatarView.leftAnchor
                                                  constant:-8],
      [self.titleLabel.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:20],
      [self.titleLabel.heightAnchor constraintEqualToConstant:25]
    ]];
  }

  // 添加子标题标签（显示呼叫文案，右对齐）
  if (!self.subTitleLabel) {
    self.subTitleLabel = [[UILabel alloc] init];
    self.subTitleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.subTitleLabel.textColor = [UIColor whiteColor];
    self.subTitleLabel.textAlignment = NSTextAlignmentRight;
    self.subTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.subTitleLabel];

    [NSLayoutConstraint activateConstraints:@[
      [self.subTitleLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor],
      [self.subTitleLabel.rightAnchor constraintEqualToAnchor:self.titleLabel.rightAnchor],
      [self.subTitleLabel.leftAnchor constraintEqualToAnchor:self.titleLabel.leftAnchor],
      [self.subTitleLabel.heightAnchor constraintEqualToConstant:20]
    ]];
  }
}

- (void)setupCallingUIForCalled {
  // 添加远端头像视图（中间，大尺寸）
  if (!self.remoteAvatarView) {
    self.remoteAvatarView = [[UIImageView alloc] init];
    self.remoteAvatarView.image = [UIImage imageNamed:@"avator"
                                             inBundle:self.bundle
                        compatibleWithTraitCollection:nil];
    self.remoteAvatarView.translatesAutoresizingMaskIntoConstraints = NO;
    self.remoteAvatarView.clipsToBounds = YES;
    self.remoteAvatarView.layer.cornerRadius = 4.0;
    [self addSubview:self.remoteAvatarView];

    [NSLayoutConstraint activateConstraints:@[
      [self.remoteAvatarView.widthAnchor constraintEqualToConstant:90],
      [self.remoteAvatarView.heightAnchor constraintEqualToConstant:90],
      [self.remoteAvatarView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
      [self.remoteAvatarView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant:-100]
    ]];
  }

  // 添加标题标签（显示昵称，居中）
  if (!self.titleLabel) {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.titleLabel];

    [NSLayoutConstraint activateConstraints:@[
      [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.remoteAvatarView.topAnchor
                                                   constant:-10],
      [self.titleLabel.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:20],
      [self.titleLabel.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-20],
      [self.titleLabel.heightAnchor constraintEqualToConstant:22]
    ]];
  }

  // 添加子标题标签（显示呼叫文案，居中）
  if (!self.subTitleLabel) {
    self.subTitleLabel = [[UILabel alloc] init];
    self.subTitleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.subTitleLabel.textColor = [UIColor whiteColor];
    self.subTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.subTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.subTitleLabel];

    [NSLayoutConstraint activateConstraints:@[
      [self.subTitleLabel.topAnchor constraintEqualToAnchor:self.remoteAvatarView.bottomAnchor
                                                   constant:10],
      [self.subTitleLabel.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:20],
      [self.subTitleLabel.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-20],
      [self.subTitleLabel.heightAnchor constraintEqualToConstant:16]
    ]];
  }
}

- (void)removeCallingUI {
  NEXKitBaseLogInfo(@"[%@] removeCallingUI", kCallLayoutVideoViewTag);
  if (self.remoteAvatarView) {
    [self.remoteAvatarView removeFromSuperview];
    self.remoteAvatarView = nil;
  }
  if (self.titleLabel) {
    [self.titleLabel removeFromSuperview];
    self.titleLabel = nil;
  }
  if (self.subTitleLabel) {
    [self.subTitleLabel removeFromSuperview];
    self.subTitleLabel = nil;
  }
}

- (void)updateCallingUILayout {
  // 当 isCaller 改变时，需要重新布局
  if (self.showLocalVideoOnly) {
    [self removeCallingUI];
    [self setupCallingUI];
  }
}

- (void)updateCallingUI {
  if (!self.showLocalVideoOnly) {
    return;
  }

  NEXKitBaseLogInfo(@"[%@] updateCallingUI, isCaller=%d, remoteShowName=%@",
                    kCallLayoutVideoViewTag, self.isCaller, self.remoteShowName);

  // 更新标题（昵称）
  if (self.titleLabel) {
    if (self.isCaller) {
      // 主叫：显示 "正在呼叫 xxx"
      NSString *callingText = [NECallKitUtil localizableWithKey:@"calling"];
      self.titleLabel.text =
          [NSString stringWithFormat:@"%@ %@", callingText,
                                     self.remoteShowName.length > 0 ? self.remoteShowName
                                                                    : self.remoteUserAccid];
    } else {
      // 被叫：只显示昵称
      self.titleLabel.text =
          self.remoteShowName.length > 0 ? self.remoteShowName : self.remoteUserAccid;
    }
  }

  // 更新子标题（呼叫文案）
  if (self.subTitleLabel) {
    if (self.isCaller) {
      // 主叫：显示 "等待对方接听"
      self.subTitleLabel.text = [NECallKitUtil localizableWithKey:@"waitting_remote_accept"];
    } else {
      // 被叫：显示邀请文案
      NECallStateManager *stateManager = [NECallStateManager sharedInstance];
      if (stateManager.callType == NECallTypeVideo) {
        self.subTitleLabel.text = [NECallKitUtil localizableWithKey:@"invite_video_call"];
      } else {
        self.subTitleLabel.text = [NECallKitUtil localizableWithKey:@"invite_audio_call"];
      }
    }
  }

  // 更新头像
  NEXKitBaseLogInfo(@"[%@] updateCallingUI: updating avatar, remoteAvatarView=%@, remoteAvatar=%@, "
                    @"remoteUserAccid=%@",
                    kCallLayoutVideoViewTag, self.remoteAvatarView ? @"exists" : @"nil",
                    self.remoteAvatar, self.remoteUserAccid);
  if (self.remoteAvatarView) {
    NEXKitBaseLogInfo(
        @"[%@] updateCallingUI: remoteAvatarView exists, frame=%@, hidden=%d, superview=%@",
        kCallLayoutVideoViewTag, NSStringFromCGRect(self.remoteAvatarView.frame),
        self.remoteAvatarView.hidden, self.remoteAvatarView.superview ? @"exists" : @"nil");
    if (self.remoteAvatar.length > 0) {
      // 先清除所有子视图（可能是之前添加的默认头像 cover view）
      [self.remoteAvatarView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
      NSURL *avatarURL = [NSURL URLWithString:self.remoteAvatar];
      NEXKitBaseLogInfo(@"[%@] updateCallingUI: loading avatar from URL: %@, validURL=%d",
                        kCallLayoutVideoViewTag, self.remoteAvatar, avatarURL != nil);
      [self.remoteAvatarView
          sd_setImageWithURL:avatarURL
            placeholderImage:[UIImage imageNamed:@"avator"
                                                      inBundle:self.bundle
                                 compatibleWithTraitCollection:nil]
                   completed:^(UIImage *_Nullable image, NSError *_Nullable error,
                               SDImageCacheType cacheType, NSURL *_Nullable imageURL) {
                     if (error) {
                       NEXKitBaseLogInfo(@"[%@] updateCallingUI: failed to load avatar, error=%@",
                                         kCallLayoutVideoViewTag, error);
                     } else {
                       NEXKitBaseLogInfo(
                           @"[%@] updateCallingUI: avatar loaded successfully, image=%@",
                           kCallLayoutVideoViewTag, image ? @"exists" : @"nil");
                     }
                   }];
    } else if (self.remoteUserAccid.length > 0) {
      // 使用默认头像（根据accid生成颜色背景）
      UIView *cover = [self getDefaultHeaderView:self.remoteUserAccid
                                            font:[UIFont systemFontOfSize:20]
                                        showName:self.remoteShowName];
      [self.remoteAvatarView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
      [self.remoteAvatarView addSubview:cover];
      [NSLayoutConstraint activateConstraints:@[
        [cover.leftAnchor constraintEqualToAnchor:self.remoteAvatarView.leftAnchor],
        [cover.rightAnchor constraintEqualToAnchor:self.remoteAvatarView.rightAnchor],
        [cover.topAnchor constraintEqualToAnchor:self.remoteAvatarView.topAnchor],
        [cover.bottomAnchor constraintEqualToAnchor:self.remoteAvatarView.bottomAnchor]
      ]];
    }
  }
}

- (UIView *)getDefaultHeaderView:(NSString *)accid
                            font:(UIFont *)font
                        showName:(NSString *)showName {
  UIView *headerView = [[UIView alloc] init];
  headerView.backgroundColor = [UIColor colorWithStringWithString:accid];
  headerView.translatesAutoresizingMaskIntoConstraints = NO;
  NSString *show = showName.length > 0 ? showName : accid;
  if (show.length >= 2) {
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:label];
    label.textColor = [UIColor whiteColor];
    label.font = font;
    label.text = [show substringWithRange:NSMakeRange(show.length - 2, 2)];
    [NSLayoutConstraint activateConstraints:@[
      [label.centerYAnchor constraintEqualToAnchor:headerView.centerYAnchor],
      [label.centerXAnchor constraintEqualToAnchor:headerView.centerXAnchor]
    ]];
  }
  return headerView;
}

#pragma mark - Private Methods

- (void)updateTitleForVideoView:(NEVideoView *)videoView cameraMute:(BOOL)cameraMute {
  if (!videoView) {
    return;
  }

  // 获取当前用户ID
  NSString *currentUserId = [NIMSDK.sharedSDK.v2LoginService getLoginUser];
  BOOL isCurrentUser = [videoView.userID isEqualToString:currentUserId];

  if (cameraMute) {
    if (isCurrentUser) {
      videoView.titleLabel.text = [NECallKitUtil localizableWithKey:@"you_closed_camera"];
      NEXKitBaseLogInfo(
          @"[%@] updateTitleForVideoView: set title to 'you_closed_camera' for local user",
          kCallLayoutVideoViewTag);
    } else {
      videoView.titleLabel.text = [NECallKitUtil localizableWithKey:@"remote_closed_camera"];
      NEXKitBaseLogInfo(
          @"[%@] updateTitleForVideoView: set title to 'remote_closed_camera' for remote user",
          kCallLayoutVideoViewTag);
    }
  } else {
    videoView.titleLabel.text = @"";
    NEXKitBaseLogInfo(@"[%@] updateTitleForVideoView: clear title", kCallLayoutVideoViewTag);
  }
}

#pragma mark - Property Setters

- (void)setRemoteShowName:(NSString *)remoteShowName {
  if (![_remoteShowName isEqualToString:remoteShowName]) {
    _remoteShowName = remoteShowName;
    [self updateCallingUI];
  }
}

- (void)setRemoteUserAccid:(NSString *)remoteUserAccid {
  if (![_remoteUserAccid isEqualToString:remoteUserAccid]) {
    _remoteUserAccid = remoteUserAccid;
    [self updateCallingUI];
  }
}

- (void)setRemoteAvatar:(NSString *)remoteAvatar {
  NEXKitBaseLogInfo(@"[%@] setRemoteAvatar: %@ -> %@, showLocalVideoOnly=%d",
                    kCallLayoutVideoViewTag, _remoteAvatar, remoteAvatar, self.showLocalVideoOnly);
  if (![_remoteAvatar isEqualToString:remoteAvatar]) {
    _remoteAvatar = remoteAvatar;
    [self updateCallingUI];
    NEXKitBaseLogInfo(@"[%@] setRemoteAvatar: after updateCallingUI, remoteAvatarView=%@",
                      kCallLayoutVideoViewTag, self.remoteAvatarView ? @"exists" : @"nil");
  } else {
    NEXKitBaseLogInfo(@"[%@] setRemoteAvatar: value unchanged, skipping update",
                      kCallLayoutVideoViewTag);
  }
}

- (void)setIsCaller:(BOOL)isCaller {
  if (_isCaller != isCaller) {
    _isCaller = isCaller;
    // 如果正在显示 calling/called UI，需要重新布局
    [self updateCallingUILayout];
    [self updateCallingUI];
  }
}

#pragma mark - Pan Gesture Handler

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
  // 如果只显示本地视频，不允许拖拽
  if (self.showLocalVideoOnly) {
    return;
  }

  if (!self.smallVideoView || !self.smallVideoView.superview) {
    return;
  }

  CGPoint translation = [panGesture translationInView:self];
  CGPoint velocity = [panGesture velocityInView:self];

  switch (panGesture.state) {
    case UIGestureRecognizerStateBegan:
      // 记录初始位置（使用 center）
      self.smallVideoViewStartCenter = self.smallVideoView.center;
      self.smallVideoViewHasManualPosition = YES;  // 标记为已手动定位
      NEXKitBaseLogInfo(@"[%@] handlePanGesture: began, startCenter=%@", kCallLayoutVideoViewTag,
                        NSStringFromCGPoint(self.smallVideoViewStartCenter));
      break;

    case UIGestureRecognizerStateChanged:
      // 更新小画面位置
      [self updateSmallVideoViewPositionWithTranslation:translation];
      break;

    case UIGestureRecognizerStateEnded:
    case UIGestureRecognizerStateCancelled:
      // 处理拖拽结束，可能需要吸附到边缘
      [self handlePanGestureEndedWithVelocity:velocity];
      break;

    default:
      break;
  }
}

- (void)updateSmallVideoViewPositionWithTranslation:(CGPoint)translation {
  if (!self.smallVideoView || !self.smallVideoView.superview) {
    return;
  }

  // 计算新位置（使用 center）
  CGPoint newCenter = CGPointMake(self.smallVideoViewStartCenter.x + translation.x,
                                  self.smallVideoViewStartCenter.y + translation.y);

  // 获取小画面的尺寸
  CGSize smallVideoSize = self.smallVideoView.frame.size;
  if (CGSizeEqualToSize(smallVideoSize, CGSizeZero)) {
    smallVideoSize = CGSizeMake(90, 160);  // 默认尺寸，与 setupUI 中的尺寸一致
  }

  // 获取父视图的边界
  CGRect parentBounds = self.bounds;

  // 计算边界限制（使用 center）
  CGFloat minX = smallVideoSize.width / 2.0;
  CGFloat maxX = parentBounds.size.width - smallVideoSize.width / 2.0;
  CGFloat minY = smallVideoSize.height / 2.0;
  CGFloat maxY = parentBounds.size.height - smallVideoSize.height / 2.0;

  // 限制在边界内
  newCenter.x = MAX(minX, MIN(maxX, newCenter.x));
  newCenter.y = MAX(minY, MIN(maxY, newCenter.y));

  // 更新位置（使用 center）
  self.smallVideoView.center = newCenter;
}

- (void)handlePanGestureEndedWithVelocity:(CGPoint)velocity {
  if (!self.smallVideoView || !self.smallVideoView.superview) {
    return;
  }

  // 获取当前中心点
  CGPoint currentCenter = self.smallVideoView.center;
  CGSize parentSize = self.bounds.size;

  // 计算到各边缘的距离
  CGFloat distanceToLeft = currentCenter.x;
  CGFloat distanceToRight = parentSize.width - currentCenter.x;
  CGFloat distanceToTop = currentCenter.y;
  CGFloat distanceToBottom = parentSize.height - currentCenter.y;

  // 找到最近的边缘
  CGFloat minDistance =
      MIN(MIN(distanceToLeft, distanceToRight), MIN(distanceToTop, distanceToBottom));

  CGPoint targetCenter = currentCenter;
  CGSize smallVideoSize = self.smallVideoView.frame.size;
  if (CGSizeEqualToSize(smallVideoSize, CGSizeZero)) {
    smallVideoSize = CGSizeMake(90, 160);  // 默认尺寸
  }

  // 根据最近的边缘确定目标位置（吸附到边缘）
  if (minDistance == distanceToLeft) {
    // 吸附到左边缘
    targetCenter.x = smallVideoSize.width / 2.0 + 20;  // 20像素边距，与 setupUI 中的 margin 一致
  } else if (minDistance == distanceToRight) {
    // 吸附到右边缘
    targetCenter.x = parentSize.width - smallVideoSize.width / 2.0 - 20;
  } else if (minDistance == distanceToTop) {
    // 吸附到上边缘
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    targetCenter.y = statusBarHeight + smallVideoSize.height / 2.0 + 20;  // 20像素边距
  } else {
    // 吸附到下边缘
    targetCenter.y = parentSize.height - smallVideoSize.height / 2.0 - 20;
  }

  NEXKitBaseLogInfo(@"[%@] handlePanGestureEnded: currentCenter=%@, targetCenter=%@",
                    kCallLayoutVideoViewTag, NSStringFromCGPoint(currentCenter),
                    NSStringFromCGPoint(targetCenter));

  // 执行吸附动画
  [UIView animateWithDuration:0.3
                        delay:0
                      options:UIViewAnimationOptionCurveEaseOut
                   animations:^{
                     self.smallVideoView.center = targetCenter;
                   }
                   completion:nil];
}

@end
