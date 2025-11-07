// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NECallKitSampleBufferDisplayView.h"
#import <netease_callkit_ui/netease_callkit_ui-Swift.h>
#import "SDWebImage/SDWebImage.h"

@interface NECallKitSampleBufferDisplayView ()
@property(nonatomic, strong) UIView *avatarBgView;
@property(nonatomic, strong) UIImageView *avatarImageView;
@end

@implementation NECallKitSampleBufferDisplayView

+ (Class)layerClass {
  return AVSampleBufferDisplayLayer.class;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setupSubviews];
  }
  return self;
}

- (void)setupSubviews {
  self.backgroundColor = UIColor.blackColor;

  // 创建头像背景视图
  self.avatarBgView = [[UIView alloc] initWithFrame:CGRectZero];
  self.avatarBgView.backgroundColor = [UIColor colorWithRed:64.0 / 255
                                                      green:64.0 / 255
                                                       blue:64.0 / 255
                                                      alpha:1];
  self.avatarBgView.translatesAutoresizingMaskIntoConstraints = NO;
  [self addSubview:self.avatarBgView];

  // 设置背景视图约束（填充整个视图）
  [NSLayoutConstraint activateConstraints:@[
    [self.avatarBgView.topAnchor constraintEqualToAnchor:self.topAnchor],
    [self.avatarBgView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
    [self.avatarBgView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
    [self.avatarBgView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
  ]];

  // 创建头像视图
  self.avatarImageView = [[UIImageView alloc] init];
  self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
  self.avatarImageView.clipsToBounds = YES;
  self.avatarImageView.backgroundColor = UIColor.darkGrayColor;
  self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
  [self addSubview:self.avatarImageView];

  // 设置头像约束
  [NSLayoutConstraint activateConstraints:@[
    [self.avatarImageView.widthAnchor constraintEqualToConstant:80],
    [self.avatarImageView.heightAnchor constraintEqualToConstant:80],
    [self.avatarImageView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
    [self.avatarImageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]
  ]];

  // 默认显示头像和背景
  self.avatarImageView.hidden = NO;
  self.avatarBgView.hidden = NO;
}

/// 设置头像
/// - Parameter avatarURL: 头像URL
- (void)setAvatarURL:(NSString *)avatarURL {
  if (avatarURL.length == 0) {
    return;
  }

  NSURL *url = [NSURL URLWithString:avatarURL];
  [self.avatarImageView
      sd_setImageWithURL:url
        placeholderImage:[NEBundleUtils getBundleImageWithName:@"icon_default_user"]];
}

/// 显示/隐藏头像（包括背景视图）
/// - Parameter hidden: 是否隐藏
- (void)setAvatarHidden:(BOOL)hidden {
  self.avatarImageView.hidden = hidden;
  self.avatarBgView.hidden = hidden;
}

@end
