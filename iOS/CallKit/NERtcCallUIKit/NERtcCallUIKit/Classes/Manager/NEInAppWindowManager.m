// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEInAppWindowManager.h"
#import <NECommonKit/NECommonKit-Swift.h>
#import <NERtcCallKit/NECallEngine.h>
#import <NEXKitBase/NEXKitBase.h>
#import <NIMSDK/NIMSDK.h>
#import <SDWebImage/SDWebImage.h>
#import "NECallKitUtil.h"
#import "NECallStateManager.h"
#import "NERtcCallUIKit.h"

static NSString *const kInAppWindowManagerTag = @"InAppWindowManager";
static NSString *const kEventTapFloatWindow = @"EVENT_TAP_FLOATWINDOW";

/// 自定义视图类，用于管理渐变层的 frame 更新
@interface NEGradientCoverView : UIView
@property(nonatomic, strong) CAGradientLayer *gradientLayer;
@end

@implementation NEGradientCoverView

- (void)layoutSubviews {
  [super layoutSubviews];
  if (self.gradientLayer) {
    self.gradientLayer.frame = self.bounds;
  }
}

@end

@interface NEInAppWindowManager () <NECallStateManagerDelegate>

/// 应用内小窗窗口
@property(nonatomic, strong, nullable) UIWindow *inAppSmallWindow;

/// 视频小窗的恢复视图（用于显示远程视频）
@property(nonatomic, strong, nullable) UIView *recoveryView;

/// 音频小窗视图
@property(nonatomic, strong, nullable) UIView *audioSmallView;

/// 音频小窗计时器标签
@property(nonatomic, strong, nullable) UILabel *audioSmallViewTimerLabel;

/// 遮罩视图（用于视频关闭时显示）
@property(nonatomic, strong, nullable) UIView *videoCoverView;

/// 远程头像图片
@property(nonatomic, strong, nullable) UIImageView *remoteHeaderImageView;

/// 视频小窗大小
@property(nonatomic, assign) CGSize smallVideoSize;

/// 音频小窗大小
@property(nonatomic, assign) CGSize smallAudioSize;

/// 资源包
@property(nonatomic, strong, nullable) NSBundle *bundle;

/// 定时器（用于更新音频小窗计时器）
@property(nonatomic, strong, nullable) NSTimer *timer;

/// 通话时长计数（秒）
@property(nonatomic, assign) NSInteger timerCount;

/// 通话开始时间（用于计算已进行的时间）
@property(nonatomic, strong, nullable) NSDate *callStartTime;

@end

@implementation NEInAppWindowManager

+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static NEInAppWindowManager *instance;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
  });
  return instance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _smallVideoSize = CGSizeMake(90, 160);
    _smallAudioSize = CGSizeMake(70, 70);
    _bundle = [NSBundle bundleForClass:[NERtcCallUIKit class]];
    _timerCount = 0;
  }
  return self;
}

#pragma mark - Public Methods

- (void)showInAppSmallWindow {
  // 从 NECallStateManager 获取通话类型
  NECallStateManager *stateManager = [NECallStateManager sharedInstance];
  NECallType callType = stateManager.callType;

  NEXKitBaseLogInfo(@"[%@] showInAppSmallWindow, callType = %lu", kInAppWindowManagerTag,
                    (unsigned long)callType);

  // 如果已经存在小窗，先关闭
  if (self.inAppSmallWindow) {
    [self closeInAppSmallWindow];
  }

  // 创建小窗窗口
  UIWindow *smallWindow = [[UIWindow alloc] init];
  if (@available(iOS 13.0, *)) {
    for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes.allObjects) {
      if (scene.activationState == UISceneActivationStateForegroundActive) {
        smallWindow = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
        break;
      }
    }
  }
  smallWindow.windowLevel = UIWindowLevelAlert - 1;
  smallWindow.backgroundColor = [UIColor clearColor];
  smallWindow.hidden = NO;
  self.inAppSmallWindow = smallWindow;

  // 创建根视图控制器
  UIViewController *rootVC = [[UIViewController alloc] init];
  rootVC.view.backgroundColor = [UIColor clearColor];
  smallWindow.rootViewController = rootVC;

  // 计算小窗大小和位置
  CGSize windowSize = (callType == NECallTypeVideo) ? self.smallVideoSize : self.smallAudioSize;
  UIScreen *screen = UIScreen.mainScreen;
  CGFloat screenWidth = screen.bounds.size.width;
  CGFloat screenHeight = screen.bounds.size.height;
  CGFloat margin = 10.0;
  CGFloat x = screenWidth - windowSize.width - margin;
  CGFloat y = 54.0;  // 状态栏高度 + 一些间距

  smallWindow.frame = CGRectMake(x, y, windowSize.width, windowSize.height);

  // 根据通话类型创建内容视图
  UIView *contentView = nil;
  if (callType == NECallTypeVideo) {
    // 创建视频小窗视图
    UIView *recoveryView = [self createVideoSmallWindowView];
    recoveryView.translatesAutoresizingMaskIntoConstraints = NO;
    [rootVC.view addSubview:recoveryView];

    [NSLayoutConstraint activateConstraints:@[
      [recoveryView.topAnchor constraintEqualToAnchor:rootVC.view.topAnchor],
      [recoveryView.leadingAnchor constraintEqualToAnchor:rootVC.view.leadingAnchor],
      [recoveryView.trailingAnchor constraintEqualToAnchor:rootVC.view.trailingAnchor],
      [recoveryView.bottomAnchor constraintEqualToAnchor:rootVC.view.bottomAnchor]
    ]];

    // 创建并添加 coverView（后添加，显示在 recoveryView 上面）
    UIView *coverView = [self getVideoCoverView];
    self.videoCoverView = coverView;
    coverView.translatesAutoresizingMaskIntoConstraints = NO;
    [rootVC.view addSubview:coverView];

    [NSLayoutConstraint activateConstraints:@[
      [coverView.topAnchor constraintEqualToAnchor:rootVC.view.topAnchor],
      [coverView.leadingAnchor constraintEqualToAnchor:rootVC.view.leadingAnchor],
      [coverView.trailingAnchor constraintEqualToAnchor:rootVC.view.trailingAnchor],
      [coverView.bottomAnchor constraintEqualToAnchor:rootVC.view.bottomAnchor]
    ]];

    // 主动同步远端视频状态
    [self syncRemoteVideoState];
  } else {
    contentView = [self createAudioSmallWindowView];
    if (contentView) {
      contentView.translatesAutoresizingMaskIntoConstraints = NO;
      [rootVC.view addSubview:contentView];

      [NSLayoutConstraint activateConstraints:@[
        [contentView.topAnchor constraintEqualToAnchor:rootVC.view.topAnchor],
        [contentView.leadingAnchor constraintEqualToAnchor:rootVC.view.leadingAnchor],
        [contentView.trailingAnchor constraintEqualToAnchor:rootVC.view.trailingAnchor],
        [contentView.bottomAnchor constraintEqualToAnchor:rootVC.view.bottomAnchor]
      ]];
    }
  }

  // 设置圆角
  if (callType == NECallTypeAudio) {
    rootVC.view.layer.cornerRadius = 6.0;
    rootVC.view.clipsToBounds = YES;
  }

  // 添加拖拽手势
  UIPanGestureRecognizer *panGesture =
      [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
  [rootVC.view addGestureRecognizer:panGesture];

  // 添加点击手势（点击恢复大窗）
  UITapGestureRecognizer *tapGesture =
      [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
  [rootVC.view addGestureRecognizer:tapGesture];

  [smallWindow makeKeyAndVisible];

  // 注册为 NECallStateManager 的代理，监听远端视频状态变化
  [[NECallStateManager sharedInstance] addDelegate:self];

  // 初始化远端头像（如果是视频通话）
  if (callType == NECallTypeVideo) {
    [self updateRemoteAvatar];
  }

  // 检查通话状态并更新定时器（处理中途切换的情况）
  [self checkCallStatusAndUpdateTimer];
}

- (void)closeInAppSmallWindow {
  NEXKitBaseLogInfo(@"[%@] closeInAppSmallWindow", kInAppWindowManagerTag);

  if (self.inAppSmallWindow) {
    // 清理视频视图
    if (self.recoveryView) {
      [[NECallEngine sharedInstance] setupRemoteView:nil];
    }

    self.inAppSmallWindow.hidden = YES;
    self.inAppSmallWindow.rootViewController = nil;
    self.inAppSmallWindow = nil;
  }

  // 清理视图引用
  self.recoveryView = nil;
  self.audioSmallView = nil;
  self.audioSmallViewTimerLabel = nil;
  self.videoCoverView = nil;
  self.remoteHeaderImageView = nil;

  // 移除代理
  [[NECallStateManager sharedInstance] removeDelegate:self];

  // 停止定时器
  [self stopTimer];
}

#pragma mark - Private Methods

- (UIView *)createVideoSmallWindowView {
  // 创建恢复视图（用于显示远程视频）
  UIView *recoveryView = [[UIView alloc] init];
  recoveryView.translatesAutoresizingMaskIntoConstraints = NO;
  recoveryView.backgroundColor = [UIColor grayColor];
  self.recoveryView = recoveryView;

  // 设置远程视频视图
  dispatch_async(dispatch_get_main_queue(), ^{
    NEXKitBaseLogInfo(@"[%@] createVideoSmallWindowView: setupRemoteView with recoveryView: %@",
                      kInAppWindowManagerTag, recoveryView);
    [[NECallEngine sharedInstance] setupRemoteView:recoveryView];
    NEXKitBaseLogInfo(@"[%@] createVideoSmallWindowView: setupRemoteView completed",
                      kInAppWindowManagerTag);
  });

  return recoveryView;
}

- (UIView *)createAudioSmallWindowView {
  // 创建音频小窗视图
  UIView *audioView = [[UIView alloc] init];
  audioView.translatesAutoresizingMaskIntoConstraints = NO;
  audioView.backgroundColor = [UIColor whiteColor];
  self.audioSmallView = audioView;

  // 添加电话图标
  UIImage *callImage = [UIImage imageNamed:@"phone_image"
                                  inBundle:self.bundle
             compatibleWithTraitCollection:nil];
  if (callImage) {
    UIImageView *callImageView = [[UIImageView alloc] initWithImage:callImage];
    callImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [audioView addSubview:callImageView];

    [NSLayoutConstraint activateConstraints:@[
      [callImageView.centerXAnchor constraintEqualToAnchor:audioView.centerXAnchor],
      [callImageView.topAnchor constraintEqualToAnchor:audioView.topAnchor constant:11]
    ]];
  }

  // 添加计时器标签
  UILabel *timerLabel = [[UILabel alloc] init];
  timerLabel.translatesAutoresizingMaskIntoConstraints = NO;
  timerLabel.textColor = [NECallKitUtil colorWithHexString:@"#1BBF52"];
  timerLabel.adjustsFontSizeToFitWidth = YES;
  timerLabel.textAlignment = NSTextAlignmentCenter;
  timerLabel.text = @"00:00";
  self.audioSmallViewTimerLabel = timerLabel;
  [audioView addSubview:timerLabel];

  [NSLayoutConstraint activateConstraints:@[
    [timerLabel.centerXAnchor constraintEqualToAnchor:audioView.centerXAnchor],
    [timerLabel.bottomAnchor constraintEqualToAnchor:audioView.bottomAnchor constant:-15],
    [timerLabel.leadingAnchor constraintEqualToAnchor:audioView.leadingAnchor constant:3],
    [timerLabel.trailingAnchor constraintEqualToAnchor:audioView.trailingAnchor constant:-3]
  ]];

  // 如果通话已经连接，立即启动定时器
  NECallStateManager *stateManager = [NECallStateManager sharedInstance];
  if (stateManager.callStatus == NERtcCallStatusInCall) {
    // 从 NECallStateManager 获取 callStartTime
    if (stateManager.callStartTime) {
      self.callStartTime = stateManager.callStartTime;
      NEXKitBaseLogInfo(@"[%@] createAudioSmallWindowView: got callStartTime from stateManager",
                        kInAppWindowManagerTag);
    }
    [self startTimer];
  }

  return audioView;
}

- (UIView *)getVideoCoverView {
  // 使用自定义视图类来管理渐变层
  NEGradientCoverView *coverView = [[NEGradientCoverView alloc] init];
  coverView.translatesAutoresizingMaskIntoConstraints = NO;

  // 创建渐变层
  CAGradientLayer *gradientLayer = [CAGradientLayer layer];
  gradientLayer.colors = @[
    (__bridge id)[NECallKitUtil colorWithHexString:@"#232529"].CGColor,
    (__bridge id)[NECallKitUtil colorWithHexString:@"#5E6471"].CGColor
  ];
  gradientLayer.locations = @[ @0.0, @1.0 ];
  gradientLayer.startPoint = CGPointMake(0, 0);
  gradientLayer.endPoint = CGPointMake(0, 1);
  coverView.gradientLayer = gradientLayer;
  [coverView.layer addSublayer:gradientLayer];

  // 添加远程头像
  UIImageView *headerImageView = [[UIImageView alloc] init];
  headerImageView.translatesAutoresizingMaskIntoConstraints = NO;
  headerImageView.contentMode = UIViewContentModeScaleAspectFit;
  headerImageView.clipsToBounds = YES;
  headerImageView.layer.cornerRadius = 4.0;
  self.remoteHeaderImageView = headerImageView;
  [coverView addSubview:headerImageView];

  [NSLayoutConstraint activateConstraints:@[
    [headerImageView.centerXAnchor constraintEqualToAnchor:coverView.centerXAnchor],
    [headerImageView.centerYAnchor constraintEqualToAnchor:coverView.centerYAnchor],
    [headerImageView.widthAnchor constraintEqualToConstant:42],
    [headerImageView.heightAnchor constraintEqualToConstant:42]
  ]];

  // 头像将在 updateRemoteAvatar 中加载
  return coverView;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
  if (!self.inAppSmallWindow) {
    return;
  }

  CGPoint translation = [gesture translationInView:gesture.view.superview];
  CGPoint velocity = [gesture velocityInView:gesture.view.superview];

  CGRect windowFrame = self.inAppSmallWindow.frame;
  UIScreen *screen = UIScreen.mainScreen;
  CGFloat screenWidth = screen.bounds.size.width;
  CGFloat screenHeight = screen.bounds.size.height;
  CGFloat margin = 10.0;

  if (gesture.state == UIGestureRecognizerStateChanged) {
    CGFloat newX = windowFrame.origin.x + translation.x;
    CGFloat newY = windowFrame.origin.y + translation.y;

    // 限制在屏幕范围内
    newX = MAX(margin, MIN(newX, screenWidth - windowFrame.size.width - margin));
    newY = MAX(54.0, MIN(newY, screenHeight - windowFrame.size.height - margin));

    self.inAppSmallWindow.frame =
        CGRectMake(newX, newY, windowFrame.size.width, windowFrame.size.height);
    [gesture setTranslation:CGPointZero inView:gesture.view.superview];
  } else if (gesture.state == UIGestureRecognizerStateEnded ||
             gesture.state == UIGestureRecognizerStateCancelled) {
    // 计算当前窗口中心点
    CGPoint currentCenter = CGPointMake(windowFrame.origin.x + windowFrame.size.width / 2.0,
                                        windowFrame.origin.y + windowFrame.size.height / 2.0);

    // 计算到各边缘的距离
    CGFloat distanceToLeft = currentCenter.x;
    CGFloat distanceToRight = screenWidth - currentCenter.x;
    CGFloat distanceToTop = currentCenter.y;
    CGFloat distanceToBottom = screenHeight - currentCenter.y;

    // 找到最近的边缘
    CGFloat minDistance =
        MIN(MIN(distanceToLeft, distanceToRight), MIN(distanceToTop, distanceToBottom));

    CGFloat finalX = windowFrame.origin.x;
    CGFloat finalY = windowFrame.origin.y;

    // 根据最近的边缘确定目标位置
    if (minDistance == distanceToLeft) {
      // 吸附到左边缘
      finalX = margin;
    } else if (minDistance == distanceToRight) {
      // 吸附到右边缘
      finalX = screenWidth - windowFrame.size.width - margin;
    } else if (minDistance == distanceToTop) {
      // 吸附到上边缘
      finalY = 54.0;  // 状态栏高度 + 间距
    } else {
      // 吸附到下边缘
      finalY = screenHeight - windowFrame.size.height - margin;
    }

    // 执行吸附动画
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                       self.inAppSmallWindow.frame = CGRectMake(
                           finalX, finalY, windowFrame.size.width, windowFrame.size.height);
                     }
                     completion:nil];
  }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture {
  // 点击小窗可以触发恢复大窗的回调
  NEXKitBaseLogInfo(@"[%@] handleTapGesture: tapped small window, posting notification",
                    kInAppWindowManagerTag);

  // 发送点击悬浮窗的通知
  [[NSNotificationCenter defaultCenter] postNotificationName:kEventTapFloatWindow object:nil];
}

#pragma mark - 定时器管理

- (void)startTimer {
  if (self.timer != nil) {
    return;
  }

  NEXKitBaseLogInfo(@"[%@] startTimer", kInAppWindowManagerTag);

  // 如果已经有通话开始时间，计算已经经过的时间
  if (self.callStartTime) {
    NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:self.callStartTime];
    self.timerCount = (NSInteger)elapsed;
    NEXKitBaseLogInfo(@"[%@] startTimer with elapsed time: %ld seconds", kInAppWindowManagerTag,
                      (long)self.timerCount);
  } else {
    // 如果没有开始时间，从0开始（这种情况不应该发生，但为了安全起见）
    self.timerCount = 0;
    NEXKitBaseLogInfo(@"[%@] startTimer from 0 (no callStartTime)", kInAppWindowManagerTag);
  }

  // 立即更新一次显示
  if (self.audioSmallViewTimerLabel) {
    self.audioSmallViewTimerLabel.text = [self timeFormatted:(int)self.timerCount];
  }

  self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                target:self
                                              selector:@selector(updateTimer)
                                              userInfo:nil
                                               repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
  if (self.timer) {
    NEXKitBaseLogInfo(@"[%@] stopTimer", kInAppWindowManagerTag);
    [self.timer invalidate];
    self.timer = nil;
    // 注意：不重置 timerCount 和 callStartTime，因为通话可能还在进行
    // 只在 onCallEnd 时重置

    // 重置标签文本
    if (self.audioSmallViewTimerLabel) {
      self.audioSmallViewTimerLabel.text = @"00:00";
    }
  }
}

- (void)updateTimer {
  self.timerCount++;
  NSString *timeString = [self timeFormatted:(int)self.timerCount];

  dispatch_async(dispatch_get_main_queue(), ^{
    if (self.audioSmallViewTimerLabel) {
      self.audioSmallViewTimerLabel.text = timeString;
    }
  });
}

- (NSString *)timeFormatted:(int)totalSeconds {
  if (totalSeconds < 3600) {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
  }
  int seconds = totalSeconds % 60;
  int minutes = (totalSeconds / 60) % 60;
  int hours = totalSeconds / 3600;
  return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}

#pragma mark - 同步远端视频状态

- (void)syncRemoteVideoState {
  if (!self.videoCoverView) {
    return;
  }

  NECallStateManager *stateManager = [NECallStateManager sharedInstance];
  NECallInfo *callInfo = stateManager.callInfo;
  if (!callInfo) {
    // 如果没有 callInfo，默认显示 coverView
    self.videoCoverView.hidden = NO;
    NEXKitBaseLogInfo(@"[%@] syncRemoteVideoState: callInfo is nil, show coverView",
                      kInAppWindowManagerTag);
    return;
  }

  // 获取远端用户ID
  NSString *remoteUserId = nil;
  if ([callInfo.currentAccId isEqualToString:callInfo.callerInfo.accId]) {
    remoteUserId = callInfo.calleeInfo.accId;
  } else {
    remoteUserId = callInfo.callerInfo.accId;
  }

  if (!remoteUserId || remoteUserId.length == 0) {
    // 如果没有远端用户ID，默认显示 coverView
    self.videoCoverView.hidden = NO;
    NEXKitBaseLogInfo(@"[%@] syncRemoteVideoState: remoteUserId is nil, show coverView",
                      kInAppWindowManagerTag);
    return;
  }

  // 计算远端视频是否启用：available && !muted
  NSDictionary *remoteVideoAvailable = stateManager.remoteVideoAvailable;
  NSDictionary *remoteVideoMuted = stateManager.remoteVideoMuted;

  BOOL available = NO;
  if (remoteVideoAvailable[remoteUserId]) {
    available = [remoteVideoAvailable[remoteUserId] boolValue];
  }

  BOOL muted = NO;
  if (remoteVideoMuted[remoteUserId]) {
    muted = [remoteVideoMuted[remoteUserId] boolValue];
  }

  BOOL remoteVideoEnabled = available && !muted;

  // 如果远端视频未启用，显示 coverView（头像）
  self.videoCoverView.hidden = remoteVideoEnabled;

  NEXKitBaseLogInfo(@"[%@] syncRemoteVideoState: remoteUserId=%@, available=%d, muted=%d, "
                    @"remoteVideoEnabled=%d, coverView.hidden=%d",
                    kInAppWindowManagerTag, remoteUserId, available, muted, remoteVideoEnabled,
                    remoteVideoEnabled);
}

#pragma mark - NECallStateManagerDelegate

- (void)callStateManagerDidChangeRemoteVideoState:(NSString *)userId {
  NEXKitBaseLogInfo(@"[%@] callStateManagerDidChangeRemoteVideoState: userId=%@",
                    kInAppWindowManagerTag, userId);

  // 只在视频小窗模式下处理
  if (!self.inAppSmallWindow || !self.recoveryView || !self.videoCoverView) {
    return;
  }

  dispatch_async(dispatch_get_main_queue(), ^{
    NECallStateManager *stateManager = [NECallStateManager sharedInstance];
    NECallInfo *callInfo = stateManager.callInfo;
    if (!callInfo) {
      return;
    }

    // 获取远端用户ID
    NSString *remoteUserId = nil;
    if ([callInfo.currentAccId isEqualToString:callInfo.callerInfo.accId]) {
      remoteUserId = callInfo.calleeInfo.accId;
    } else {
      remoteUserId = callInfo.callerInfo.accId;
    }

    // 只处理当前远端用户的状态变化
    if (![userId isEqualToString:remoteUserId]) {
      return;
    }

    // 同步远端视频状态（会同时检查 available 和 muted）
    [self syncRemoteVideoState];
  });
}

#pragma mark - 更新远端头像

- (void)updateRemoteAvatar {
  if (!self.remoteHeaderImageView) {
    return;
  }

  NECallStateManager *stateManager = [NECallStateManager sharedInstance];
  NECallInfo *callInfo = stateManager.callInfo;
  if (!callInfo) {
    return;
  }

  // 获取远端用户ID
  NSString *remoteUserId = nil;
  if ([callInfo.currentAccId isEqualToString:callInfo.callerInfo.accId]) {
    remoteUserId = callInfo.calleeInfo.accId;
  } else {
    remoteUserId = callInfo.callerInfo.accId;
  }

  if (!remoteUserId || remoteUserId.length == 0) {
    return;
  }

  // 从 NIMSDK 获取用户信息
  __weak typeof(self) weakSelf = self;
  [NIMSDK.sharedSDK.userManager
      fetchUserInfos:@[ remoteUserId ]
          completion:^(NSArray<NIMUser *> *_Nullable users, NSError *_Nullable error) {
            if (error) {
              NEXKitBaseLogInfo(@"[%@] updateRemoteAvatar: failed to fetch user info, error=%@",
                                kInAppWindowManagerTag, error);
              return;
            }

            NIMUser *user = users.firstObject;
            if (user && weakSelf.remoteHeaderImageView) {
              NSString *avatarUrl = user.userInfo.avatarUrl;
              if (avatarUrl && avatarUrl.length > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                  [weakSelf.remoteHeaderImageView
                      sd_setImageWithURL:[NSURL URLWithString:avatarUrl]
                        placeholderImage:[UIImage imageNamed:@"avator"
                                                                  inBundle:weakSelf.bundle
                                             compatibleWithTraitCollection:nil]];
                  NEXKitBaseLogInfo(@"[%@] updateRemoteAvatar: loaded avatar from URL: %@",
                                    kInAppWindowManagerTag, avatarUrl);
                });
              } else {
                // 如果没有头像URL，使用默认头像（根据accid生成颜色背景）
                dispatch_async(dispatch_get_main_queue(), ^{
                  [weakSelf setDefaultAvatarForUserId:remoteUserId];
                });
              }
            }
          }];
}

- (void)setDefaultAvatarForUserId:(NSString *)userId {
  if (!self.remoteHeaderImageView || !userId || userId.length == 0) {
    return;
  }

  // 清除之前的子视图
  [self.remoteHeaderImageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

  // 创建默认头像视图
  UIView *headerView = [[UIView alloc] init];
  headerView.backgroundColor = [UIColor colorWithStringWithString:userId];
  headerView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.remoteHeaderImageView addSubview:headerView];

  // 添加文字标签（显示用户ID的后两位）
  NSString *showText =
      userId.length >= 2 ? [userId substringWithRange:NSMakeRange(userId.length - 2, 2)] : userId;
  UILabel *label = [[UILabel alloc] init];
  label.translatesAutoresizingMaskIntoConstraints = NO;
  label.textColor = [UIColor whiteColor];
  label.font = [UIFont systemFontOfSize:20];
  label.text = showText;
  [headerView addSubview:label];

  [NSLayoutConstraint activateConstraints:@[
    [headerView.leftAnchor constraintEqualToAnchor:self.remoteHeaderImageView.leftAnchor],
    [headerView.rightAnchor constraintEqualToAnchor:self.remoteHeaderImageView.rightAnchor],
    [headerView.topAnchor constraintEqualToAnchor:self.remoteHeaderImageView.topAnchor],
    [headerView.bottomAnchor constraintEqualToAnchor:self.remoteHeaderImageView.bottomAnchor],
    [label.centerYAnchor constraintEqualToAnchor:headerView.centerYAnchor],
    [label.centerXAnchor constraintEqualToAnchor:headerView.centerXAnchor]
  ]];

  NEXKitBaseLogInfo(@"[%@] setDefaultAvatarForUserId: created default avatar for userId: %@",
                    kInAppWindowManagerTag, userId);
}

#pragma mark - 监听通话状态变化

- (void)checkCallStatusAndUpdateTimer {
  NECallStateManager *stateManager = [NECallStateManager sharedInstance];

  // 如果通话已结束，停止定时器
  if (stateManager.callStatus != NERtcCallStatusInCall) {
    if (self.timer) {
      [self stopTimer];
      self.timerCount = 0;
      self.callStartTime = nil;
    }
    return;
  }

  // 如果通话已连接且显示音频小窗，确保定时器运行
  if (stateManager.callStatus == NERtcCallStatusInCall && self.inAppSmallWindow &&
      self.audioSmallView) {
    // 从 NECallStateManager 获取 callStartTime
    if (stateManager.callStartTime && !self.callStartTime) {
      self.callStartTime = stateManager.callStartTime;
      NEXKitBaseLogInfo(@"[%@] checkCallStatusAndUpdateTimer: got callStartTime from stateManager",
                        kInAppWindowManagerTag);
    }

    // 如果定时器未运行，启动它
    if (!self.timer) {
      [self startTimer];
    }
  }
}

@end
