// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEIncomingCallBannerView.h"
#import <NERtcCallKit/NECallEngineConsts.h>
#import <SDWebImage/SDWebImage.h>
#import <YXAlog_iOS/YXAlog.h>

// 布局常量（参考 TUICallKit IncomingBannerViewController.swift）
static const CGFloat kBannerHeight = 92.0;
static const CGFloat kAvatarSize = 60.0;
static const CGFloat kAvatarCornerRadius = 7.0;
static const CGFloat kAvatarLeading = 16.0;
static const CGFloat kNameFontSize = 18.0;
static const CGFloat kSubtitleFontSize = 12.0;
static const CGFloat kTextLeadingOffset = 12.0;
static const CGFloat kButtonSize = 36.0;
static const CGFloat kAcceptButtonTrailing = 16.0;
static const CGFloat kRejectToAcceptSpacing = 22.0;
static const CGFloat kNameTopOffset = 10.0;
static const CGFloat kSubtitleBottomOffset = 10.0;

@implementation NEIncomingCallerInfo
@end

@interface NEIncomingCallBannerView ()

@property(nonatomic, strong) NEIncomingCallerInfo *callerInfo;
@property(nonatomic, strong) UIImageView *avatarImageView;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UILabel *subtitleLabel;
@property(nonatomic, strong) UIButton *acceptButton;
@property(nonatomic, strong) UIButton *rejectButton;

@end

@implementation NEIncomingCallBannerView

- (instancetype)initWithCallerInfo:(NEIncomingCallerInfo *)callerInfo {
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    _callerInfo = callerInfo;
    self.view.layer.cornerRadius = 10.0;
    self.view.layer.masksToBounds = YES;
    self.view.backgroundColor = [UIColor colorWithRed:0x22 / 255.0
                                                green:0x26 / 255.0
                                                 blue:0x2E / 255.0
                                                alpha:1.0];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self constructViewHierarchy];
  [self activateConstraints];
  [self bindInteraction];
  [self configureContent];
}

#pragma mark - View Hierarchy

- (void)constructViewHierarchy {
  [self.view addSubview:self.avatarImageView];
  [self.view addSubview:self.nameLabel];
  [self.view addSubview:self.subtitleLabel];
  [self.view addSubview:self.rejectButton];
  [self.view addSubview:self.acceptButton];
}

#pragma mark - Constraints

- (void)activateConstraints {
  self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
  self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
  self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
  self.acceptButton.translatesAutoresizingMaskIntoConstraints = NO;
  self.rejectButton.translatesAutoresizingMaskIntoConstraints = NO;

  [NSLayoutConstraint activateConstraints:@[
    // 头像：leading 16，垂直居中，60×60
    [self.avatarImageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                                       constant:kAvatarLeading],
    [self.avatarImageView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
    [self.avatarImageView.widthAnchor constraintEqualToConstant:kAvatarSize],
    [self.avatarImageView.heightAnchor constraintEqualToConstant:kAvatarSize],

    // 接听按钮：trailing 16，垂直居中，36×36
    [self.acceptButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor
                                                     constant:-kAcceptButtonTrailing],
    [self.acceptButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
    [self.acceptButton.widthAnchor constraintEqualToConstant:kButtonSize],
    [self.acceptButton.heightAnchor constraintEqualToConstant:kButtonSize],

    // 拒绝按钮：位于接听按钮左侧 22pt，垂直居中，36×36
    [self.rejectButton.trailingAnchor constraintEqualToAnchor:self.acceptButton.leadingAnchor
                                                     constant:-kRejectToAcceptSpacing],
    [self.rejectButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
    [self.rejectButton.widthAnchor constraintEqualToConstant:kButtonSize],
    [self.rejectButton.heightAnchor constraintEqualToConstant:kButtonSize],

    // 昵称：距头像右侧 12pt，距头像顶部 10pt，右侧不超过拒绝按钮
    [self.nameLabel.topAnchor constraintEqualToAnchor:self.avatarImageView.topAnchor
                                             constant:kNameTopOffset],
    [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.avatarImageView.trailingAnchor
                                                 constant:kTextLeadingOffset],
    [self.nameLabel.trailingAnchor constraintEqualToAnchor:self.rejectButton.leadingAnchor
                                                  constant:-kTextLeadingOffset],

    // 副标题：距头像右侧 12pt，距头像底部 10pt（底部对齐偏移）
    [self.subtitleLabel.leadingAnchor constraintEqualToAnchor:self.avatarImageView.trailingAnchor
                                                     constant:kTextLeadingOffset],
    [self.subtitleLabel.bottomAnchor constraintEqualToAnchor:self.avatarImageView.bottomAnchor
                                                    constant:-kSubtitleBottomOffset],
  ]];
}

#pragma mark - Interaction

- (void)bindInteraction {
  [self.acceptButton addTarget:self
                        action:@selector(acceptButtonTapped:)
              forControlEvents:UIControlEventTouchUpInside];
  [self.rejectButton addTarget:self
                        action:@selector(rejectButtonTapped:)
              forControlEvents:UIControlEventTouchUpInside];

  UITapGestureRecognizer *tap =
      [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bodyTapped:)];
  [self.view addGestureRecognizer:tap];
}

#pragma mark - Content Configuration

- (void)configureContent {
  // 加载头像
  NSBundle *bundle = [NSBundle bundleForClass:self.class];
  UIImage *placeholder = [UIImage imageNamed:@"avator" inBundle:bundle compatibleWithTraitCollection:nil];
  if (!placeholder) {
    placeholder = [UIImage imageNamed:@"avator"];
  }
  if (self.callerInfo.avatarUrl.length > 0) {
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.callerInfo.avatarUrl]
                           placeholderImage:placeholder];
  } else {
    self.avatarImageView.image = placeholder;
  }

  // 昵称
  self.nameLabel.text = self.callerInfo.displayName.length > 0 ? self.callerInfo.displayName
                                                               : self.callerInfo.accountId;

  // 副标题文案
  self.subtitleLabel.text = [self subtitleTextForCallType:self.callerInfo.callType];

  // 接听按钮图标
  NSString *acceptImageName =
      self.callerInfo.callType == NERtcCallTypeVideo ? @"call_accept_video" : @"call_accept";
  UIImage *acceptImage = [UIImage imageNamed:acceptImageName inBundle:bundle compatibleWithTraitCollection:nil];
  if (!acceptImage) {
    acceptImage = [UIImage imageNamed:acceptImageName];
  }
  [self.acceptButton setBackgroundImage:acceptImage forState:UIControlStateNormal];

  // 拒绝按钮图标
  UIImage *rejectImage = [UIImage imageNamed:@"call_hangup" inBundle:bundle compatibleWithTraitCollection:nil];
  if (!rejectImage) {
    rejectImage = [UIImage imageNamed:@"call_hangup"];
  }
  [self.rejectButton setBackgroundImage:rejectImage forState:UIControlStateNormal];
}

- (NSString *)subtitleTextForCallType:(NSInteger)callType {
  if (self.callerInfo.multiCallInvite) {
    return @"邀请你加入多人通话";
  }
  switch (callType) {
    case NERtcCallTypeVideo:
      return @"邀请你进行视频通话";
    case NERtcCallTypeAudio:
    default:
      return @"邀请你进行语音通话";
  }
}

#pragma mark - Actions

- (void)acceptButtonTapped:(UIButton *)sender {
  YXAlogInfo(@"bannerAcceptTapped");
  if (self.onAccept) {
    self.onAccept();
  }
}

- (void)rejectButtonTapped:(UIButton *)sender {
  YXAlogInfo(@"bannerRejectTapped");
  if (self.onReject) {
    self.onReject();
  }
}

- (void)bodyTapped:(UITapGestureRecognizer *)sender {
  // 仅当点击非按钮区域时触发
  CGPoint point = [sender locationInView:self.view];
  if (CGRectContainsPoint(self.acceptButton.frame, point) ||
      CGRectContainsPoint(self.rejectButton.frame, point)) {
    return;
  }
  YXAlogInfo(@"bannerBodyTapped");
  if (self.onBodyTap) {
    self.onBodyTap();
  }
}

#pragma mark - Lazy Views

- (UIImageView *)avatarImageView {
  if (!_avatarImageView) {
    _avatarImageView = [[UIImageView alloc] init];
    _avatarImageView.layer.cornerRadius = kAvatarCornerRadius;
    _avatarImageView.layer.masksToBounds = YES;
    _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
  }
  return _avatarImageView;
}

- (UILabel *)nameLabel {
  if (!_nameLabel) {
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.font = [UIFont boldSystemFontOfSize:kNameFontSize];
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.textAlignment = NSTextAlignmentLeft;
    _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _nameLabel.numberOfLines = 1;
  }
  return _nameLabel;
}

- (UILabel *)subtitleLabel {
  if (!_subtitleLabel) {
    _subtitleLabel = [[UILabel alloc] init];
    _subtitleLabel.textColor = [UIColor colorWithRed:0xC5 / 255.0
                                               green:0xCC / 255.0
                                                blue:0xDB / 255.0
                                               alpha:1.0];
    _subtitleLabel.font = [UIFont boldSystemFontOfSize:kSubtitleFontSize];
    _subtitleLabel.textAlignment = NSTextAlignmentLeft;
  }
  return _subtitleLabel;
}

- (UIButton *)acceptButton {
  if (!_acceptButton) {
    _acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _acceptButton.accessibilityLabel = self.callerInfo.callType == NERtcCallTypeVideo ? @"接听视频通话" : @"接听";
  }
  return _acceptButton;
}

- (UIButton *)rejectButton {
  if (!_rejectButton) {
    _rejectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rejectButton.accessibilityLabel = @"拒绝";
  }
  return _rejectButton;
}

@end
