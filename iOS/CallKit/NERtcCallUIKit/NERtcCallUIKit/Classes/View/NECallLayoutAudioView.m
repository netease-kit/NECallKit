// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NECallLayoutAudioView.h"
#import <NECommonKit/NECommonKit-Swift.h>
#import <NERtcCallKit/NERtcCallKit.h>
#import <NEXKitBase/NEXKitBase.h>
#import <SDWebImage/SDWebImage.h>
#import "NECallKitUtil.h"
#import "NECallStateManager.h"
#import "NERtcCallUIKit.h"

static NSString *const kCallLayoutAudioViewTag = @"CallLayoutAudioView";

@interface NECallLayoutAudioView ()

/// 远端用户头像视图（通话中状态使用）
@property(nonatomic, strong) UIImageView *remoteAvatarView;

/// 用户名标签（通话中状态使用）
@property(nonatomic, strong) UILabel *titleLabel;

/// 中心标题标签（呼叫中/接听中状态使用）
@property(nonatomic, strong, nullable) UILabel *centerTitleLabel;

/// 中心子标题标签（呼叫中/接听中状态使用）
@property(nonatomic, strong, nullable) UILabel *centerSubtitleLabel;

/// 中心远端用户头像视图（呼叫中/接听中状态使用）
@property(nonatomic, strong, nullable) UIImageView *remoteBigAvatorView;

/// 资源包context
@property(nonatomic, strong) NSBundle *bundle;

@end

@implementation NECallLayoutAudioView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    NEXKitBaseLogInfo(@"[%@] initWithFrame: %@", kCallLayoutAudioViewTag,
                      NSStringFromCGRect(frame));
    self.bundle = [NSBundle bundleForClass:[NERtcCallUIKit class]];
    self.callStatus = NERtcCallStatusIdle;  // 默认值
    self.backgroundColor = [UIColor blackColor];
  }
  return self;
}

- (void)setupUI {
  self.backgroundColor = [UIColor blackColor];

  // 根据通话状态决定显示哪种UI
  if (self.callStatus == NERtcCallStatusCalling || self.callStatus == NERtcCallStatusCalled) {
    // 呼叫中/接听中状态：显示居中布局
    [self setupCallingUI];
  } else {
    // 通话中状态：显示原来的布局
    [self setupInCallUI];
  }
}

- (void)setupCallingUI {
  // 添加中心远端头像视图
  if (!self.remoteBigAvatorView) {
    self.remoteBigAvatorView = [[UIImageView alloc] init];
    self.remoteBigAvatorView.image = [UIImage imageNamed:@"avator"
                                                inBundle:self.bundle
                           compatibleWithTraitCollection:nil];
    self.remoteBigAvatorView.clipsToBounds = YES;
    self.remoteBigAvatorView.layer.cornerRadius = 4.0;
    self.remoteBigAvatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.remoteBigAvatorView];

    [NSLayoutConstraint activateConstraints:@[
      [self.remoteBigAvatorView.heightAnchor constraintEqualToConstant:90],
      [self.remoteBigAvatorView.widthAnchor constraintEqualToConstant:90],
      [self.remoteBigAvatorView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
      [self.remoteBigAvatorView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor
                                                             constant:-100]
    ]];
  }

  // 添加中心标题标签
  if (!self.centerTitleLabel) {
    self.centerTitleLabel = [[UILabel alloc] init];
    self.centerTitleLabel.font = [UIFont systemFontOfSize:20];
    self.centerTitleLabel.textColor = [UIColor whiteColor];
    self.centerTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.centerTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.centerTitleLabel];

    [NSLayoutConstraint activateConstraints:@[
      [self.centerTitleLabel.bottomAnchor constraintEqualToAnchor:self.remoteBigAvatorView.topAnchor
                                                         constant:-10],
      [self.centerTitleLabel.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:20],
      [self.centerTitleLabel.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-20],
      [self.centerTitleLabel.heightAnchor constraintEqualToConstant:22]
    ]];
  }

  // 添加中心子标题标签
  if (!self.centerSubtitleLabel) {
    self.centerSubtitleLabel = [[UILabel alloc] init];
    self.centerSubtitleLabel.font = [UIFont systemFontOfSize:14];
    self.centerSubtitleLabel.textColor = [UIColor whiteColor];
    self.centerSubtitleLabel.textAlignment = NSTextAlignmentCenter;
    self.centerSubtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.centerSubtitleLabel];

    [NSLayoutConstraint activateConstraints:@[
      [self.centerSubtitleLabel.topAnchor
          constraintEqualToAnchor:self.remoteBigAvatorView.bottomAnchor
                         constant:10],
      [self.centerSubtitleLabel.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:20],
      [self.centerSubtitleLabel.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-20],
      [self.centerSubtitleLabel.heightAnchor constraintEqualToConstant:16]
    ]];
  }

  // 更新UI内容
  [self updateCallingUI];
}

- (void)setupInCallUI {
  // 添加头像视图
  [self addSubview:self.remoteAvatarView];
  [NSLayoutConstraint activateConstraints:@[
    [self.remoteAvatarView.heightAnchor constraintEqualToConstant:90],
    [self.remoteAvatarView.widthAnchor constraintEqualToConstant:90],
    [self.remoteAvatarView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
    [self.remoteAvatarView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant:-50]
  ]];

  // 添加用户名标签
  [self addSubview:self.titleLabel];
  [NSLayoutConstraint activateConstraints:@[
    [self.titleLabel.topAnchor constraintEqualToAnchor:self.remoteAvatarView.bottomAnchor
                                              constant:20],
    [self.titleLabel.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:20],
    [self.titleLabel.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-20],
    [self.titleLabel.heightAnchor constraintEqualToConstant:30]
  ]];

  // 隐藏呼叫中/接听中的UI
  if (self.remoteBigAvatorView) {
    self.remoteBigAvatorView.hidden = YES;
  }
  if (self.centerTitleLabel) {
    self.centerTitleLabel.hidden = YES;
  }
  if (self.centerSubtitleLabel) {
    self.centerSubtitleLabel.hidden = YES;
  }
}

- (void)updateCallingUI {
  if (self.callStatus != NERtcCallStatusCalling && self.callStatus != NERtcCallStatusCalled) {
    return;
  }

  NEXKitBaseLogInfo(@"[%@] updateCallingUI, isCaller=%d, remoteShowName=%@",
                    kCallLayoutAudioViewTag, self.isCaller, self.remoteShowName);

  // 更新中心标题（昵称）
  if (self.centerTitleLabel) {
    if (self.isCaller) {
      // 主叫：显示 "正在呼叫 xxx"
      NSString *callingText = [NECallKitUtil localizableWithKey:@"calling"];
      self.centerTitleLabel.text =
          [NSString stringWithFormat:@"%@ %@", callingText,
                                     self.remoteShowName.length > 0 ? self.remoteShowName
                                                                    : self.remoteUserAccid];
    } else {
      // 被叫：只显示昵称
      self.centerTitleLabel.text =
          self.remoteShowName.length > 0 ? self.remoteShowName : self.remoteUserAccid;
    }
  }

  // 更新中心子标题（呼叫文案）
  if (self.centerSubtitleLabel) {
    if (self.isCaller) {
      // 主叫：显示 "等待对方接听"
      self.centerSubtitleLabel.text = [NECallKitUtil localizableWithKey:@"waitting_remote_accept"];
    } else {
      // 被叫：显示邀请文案
      NECallStateManager *stateManager = [NECallStateManager sharedInstance];
      if (stateManager.callType == NECallTypeVideo) {
        self.centerSubtitleLabel.text = [NECallKitUtil localizableWithKey:@"invite_video_call"];
      } else {
        self.centerSubtitleLabel.text = [NECallKitUtil localizableWithKey:@"invite_audio_call"];
      }
    }
  }

  // 更新中心头像
  NEXKitBaseLogInfo(@"[%@] updateCallingUI: updating avatar, remoteBigAvatorView=%@, "
                    @"remoteAvatar=%@, remoteUserAccid=%@",
                    kCallLayoutAudioViewTag, self.remoteBigAvatorView ? @"exists" : @"nil",
                    self.remoteAvatar, self.remoteUserAccid);
  if (self.remoteBigAvatorView) {
    NEXKitBaseLogInfo(
        @"[%@] updateCallingUI: remoteBigAvatorView exists, frame=%@, hidden=%d, superview=%@",
        kCallLayoutAudioViewTag, NSStringFromCGRect(self.remoteBigAvatorView.frame),
        self.remoteBigAvatorView.hidden, self.remoteBigAvatorView.superview ? @"exists" : @"nil");
    if (self.remoteAvatar.length > 0) {
      // 先清除所有子视图（可能是之前添加的默认头像 cover view）
      [self.remoteBigAvatorView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
      NSURL *avatarURL = [NSURL URLWithString:self.remoteAvatar];
      NEXKitBaseLogInfo(@"[%@] updateCallingUI: loading avatar from URL: %@, validURL=%d",
                        kCallLayoutAudioViewTag, self.remoteAvatar, avatarURL != nil);
      [self.remoteBigAvatorView
          sd_setImageWithURL:avatarURL
            placeholderImage:[UIImage imageNamed:@"avator"
                                                      inBundle:self.bundle
                                 compatibleWithTraitCollection:nil]
                   completed:^(UIImage *_Nullable image, NSError *_Nullable error,
                               SDImageCacheType cacheType, NSURL *_Nullable imageURL) {
                     if (error) {
                       NEXKitBaseLogInfo(@"[%@] updateCallingUI: failed to load avatar, error=%@",
                                         kCallLayoutAudioViewTag, error);
                     } else {
                       NEXKitBaseLogInfo(
                           @"[%@] updateCallingUI: avatar loaded successfully, image=%@",
                           kCallLayoutAudioViewTag, image ? @"exists" : @"nil");
                     }
                   }];
    } else if (self.remoteUserAccid.length > 0) {
      // 使用默认头像（根据accid生成颜色背景）
      UIView *cover = [self getDefaultHeaderView:self.remoteUserAccid
                                            font:[UIFont systemFontOfSize:20]
                                        showName:self.remoteShowName];
      [self.remoteBigAvatorView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
      [self.remoteBigAvatorView addSubview:cover];
      [NSLayoutConstraint activateConstraints:@[
        [cover.leftAnchor constraintEqualToAnchor:self.remoteBigAvatorView.leftAnchor],
        [cover.rightAnchor constraintEqualToAnchor:self.remoteBigAvatorView.rightAnchor],
        [cover.topAnchor constraintEqualToAnchor:self.remoteBigAvatorView.topAnchor],
        [cover.bottomAnchor constraintEqualToAnchor:self.remoteBigAvatorView.bottomAnchor]
      ]];
    }
  }
}

- (UIImageView *)remoteAvatarView {
  if (!_remoteAvatarView) {
    _remoteAvatarView = [[UIImageView alloc] init];
    _remoteAvatarView.image = [UIImage imageNamed:@"avator"
                                         inBundle:self.bundle
                    compatibleWithTraitCollection:nil];
    _remoteAvatarView.clipsToBounds = YES;
    _remoteAvatarView.layer.cornerRadius = 45;  // 90/2
    _remoteAvatarView.contentMode = UIViewContentModeScaleAspectFill;
    _remoteAvatarView.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return _remoteAvatarView;
}

- (UILabel *)titleLabel {
  if (!_titleLabel) {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont systemFontOfSize:20];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return _titleLabel;
}

- (void)refreshUI {
  NEXKitBaseLogInfo(@"[%@] refreshUI, remoteShowName=%@, remoteUserAccid=%@, remoteAvatar=%@",
                    kCallLayoutAudioViewTag, self.remoteShowName, self.remoteUserAccid,
                    self.remoteAvatar);

  // 设置用户名
  self.titleLabel.text =
      self.remoteShowName.length > 0 ? self.remoteShowName : self.remoteUserAccid;
  NEXKitBaseLogInfo(@"[%@] refreshUI: titleLabel.text = %@", kCallLayoutAudioViewTag,
                    self.titleLabel.text);

  // 设置头像
  NEXKitBaseLogInfo(
      @"[%@] refreshUI: updating avatar, remoteAvatarView=%@, remoteAvatar=%@, remoteUserAccid=%@",
      kCallLayoutAudioViewTag, self.remoteAvatarView ? @"exists" : @"nil", self.remoteAvatar,
      self.remoteUserAccid);
  if (self.remoteAvatar.length > 0) {
    // 先清除所有子视图（可能是之前添加的默认头像 cover view）
    [self.remoteAvatarView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSURL *avatarURL = [NSURL URLWithString:self.remoteAvatar];
    NEXKitBaseLogInfo(@"[%@] refreshUI: loading remote avatar from URL: %@, validURL=%d, "
                      @"remoteAvatarView.frame=%@, hidden=%d",
                      kCallLayoutAudioViewTag, self.remoteAvatar, avatarURL != nil,
                      NSStringFromCGRect(self.remoteAvatarView.frame),
                      self.remoteAvatarView.hidden);
    [self.remoteAvatarView
        sd_setImageWithURL:avatarURL
          placeholderImage:[UIImage imageNamed:@"avator"
                                                    inBundle:self.bundle
                               compatibleWithTraitCollection:nil]
                 completed:^(UIImage *_Nullable image, NSError *_Nullable error,
                             SDImageCacheType cacheType, NSURL *_Nullable imageURL) {
                   if (error) {
                     NEXKitBaseLogInfo(@"[%@] refreshUI: failed to load avatar, error=%@",
                                       kCallLayoutAudioViewTag, error);
                   } else {
                     NEXKitBaseLogInfo(@"[%@] refreshUI: avatar loaded successfully, image=%@",
                                       kCallLayoutAudioViewTag, image ? @"exists" : @"nil");
                   }
                 }];
  } else if (self.remoteUserAccid.length > 0) {
    // 如果没有头像URL，使用默认头像（根据accid生成颜色背景）
    NEXKitBaseLogInfo(@"[%@] refreshUI: using default header view for accid: %@",
                      kCallLayoutAudioViewTag, self.remoteUserAccid);
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

- (void)setRemoteAvatar:(NSString *)remoteAvatar {
  NEXKitBaseLogInfo(@"[%@] setRemoteAvatar: %@ -> %@, callStatus=%lu", kCallLayoutAudioViewTag,
                    _remoteAvatar, remoteAvatar, (unsigned long)self.callStatus);
  if (![_remoteAvatar isEqualToString:remoteAvatar]) {
    _remoteAvatar = remoteAvatar;
    [self refreshUI];
    [self updateCallingUI];
    NEXKitBaseLogInfo(@"[%@] setRemoteAvatar: after refreshUI and updateCallingUI, "
                      @"remoteAvatarView=%@, remoteBigAvatorView=%@",
                      kCallLayoutAudioViewTag, self.remoteAvatarView ? @"exists" : @"nil",
                      self.remoteBigAvatorView ? @"exists" : @"nil");
  }
}

- (void)setRemoteShowName:(NSString *)remoteShowName {
  if (![_remoteShowName isEqualToString:remoteShowName]) {
    _remoteShowName = remoteShowName;
    [self refreshUI];
    [self updateCallingUI];
  }
}

- (void)setRemoteUserAccid:(NSString *)remoteUserAccid {
  if (![_remoteUserAccid isEqualToString:remoteUserAccid]) {
    _remoteUserAccid = remoteUserAccid;
    [self refreshUI];
    [self updateCallingUI];
  }
}

- (void)setIsCaller:(BOOL)isCaller {
  if (_isCaller != isCaller) {
    _isCaller = isCaller;
    [self updateCallingUI];
  }
}

- (void)setCallStatus:(NERtcCallStatus)callStatus {
  if (_callStatus != callStatus) {
    NEXKitBaseLogInfo(@"[%@] setCallStatus: %lu -> %lu", kCallLayoutAudioViewTag,
                      (unsigned long)_callStatus, (unsigned long)callStatus);
    _callStatus = callStatus;
    // 重新设置UI布局（当状态变化时）
    [self setupUI];
  }
}

@end
