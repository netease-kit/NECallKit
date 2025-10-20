// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NERtcCallUIKit.h"
#import <NECommonUIKit/UIView+YXToast.h>
#import <NECoreKit/NECoreKit-Swift.h>
#import <NECoreKit/XKit.h>
#import <NERtcSDK/NERtcSDK.h>
#import <SDWebImage/SDWebImage.h>
#import <YXAlog_iOS/YXAlog.h>
#import "NEBufferDisplayView.h"
#import "NECallKitUtil.h"
#import "NEDataManager.h"
#import "NEGroupCallViewController.h"
#import "NEUIGroupCallParam.h"
#import "NetManager.h"

NSString *kAudioCalling = @"kAudioCalling";

NSString *kVideoCalling = @"kVideoCalling";

NSString *kAudioInCall = @"kAudioInCall";

NSString *kVideoInCall = @"kVideoInCall";

NSString *kCalledState = @"kCalledState";

NSString *kMouldName = @"NERtcCallUIKit";

NSString *kCallStatusResult = @"result";

NSString *kCallStatusQueryKey = @"imkit://call/state/isIdle";

NSString *kCallStatusCallBackKey = @"imkit://call/state/result";

// 群呼人数限制常量
const NSInteger kGroupCallMaxUsers = 10;

@interface NERtcCallUIKit () <NECallEngineDelegate,
                              XKitService,
                              NERtcEngineDelegateEx,
                              NERtcEngineVideoFrameObserver,
                              NERtcEngineVideoRenderSink,
                              AVPictureInPictureControllerDelegate,
                              NEGroupCallKitDelegate,
                              NEGroupCallViewControllerDelegate>

@property(nonatomic, strong) NECallUIKitConfig *config;

@property(nonatomic, strong) UIWindow *keywindow;

@property(nonatomic, weak) UIWindow *preiousKeywindow;

@property(nonatomic, strong, readwrite) NSMutableDictionary *uiConfigDic;

@property(nonatomic, strong) NSBundle *bundle;

@property(nonatomic, assign) CGRect originFrame;

@property(nonatomic, strong) UIView *parentView;

@property(nonatomic, strong) NECallViewBaseController *callViewController;

@property(nonatomic, strong) AVPictureInPictureController *pipController;

@property(nonatomic, strong) NEBufferDisplayView *displayView;

/// 视频小窗大小
@property(nonatomic, assign) CGSize smallVideoSize;

/// 音频小窗大小
@property(nonatomic, assign) CGSize smallAudioSize;

/// 转码协议
@property(nonatomic, strong) id<NETranscodingDelegate> transcodingDelegate;

@property(nonatomic, weak) NERtcVideoCanvas *canvas;

@property(nonatomic, strong) UIView *coverView;

@property(nonatomic, strong) UIImageView *remoteHeaderImageView;

@property(nonatomic, strong) NSString *currentRemoteAccid;

@property(nonatomic, assign) BOOL isCalling;

@property(nonatomic, assign) BOOL isCalled;

@end

@implementation NERtcCallUIKit

+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static NERtcCallUIKit *instance;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
  });
  return instance;
}

- (NSString *)serviceName {
  return kMouldName;
}

- (NSString *)versionName {
  return [NERtcCallUIKit version];
}

- (NSString *)appKey {
  return self.config.appKey;
}

- (void)setupWithConfig:(NECallUIKitConfig *)config {
  if (nil != config.config) {
    [[NECallEngine sharedInstance] setup:config.config];
  }
  [[XKit instance] registerService:self];
  self.config = config;

  NSString *className = @"NETranscodingEngine";
  Class class = NSClassFromString(className);
  if (class) {
    id instance = [[class alloc] init];
    if ([instance conformsToProtocol:@protocol(NETranscodingDelegate)]) {
      self.transcodingDelegate = instance;
    }
  }

  self.bundle = [NSBundle bundleForClass:NERtcCallUIKit.class];
  self.ringFile = [[NERingFile alloc] initWithBundle:self.bundle language:config.uiConfig.language];
  [NECallKitUtil setLanguage:config.uiConfig.language];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    [NetManager shareInstance];
    [[NECallEngine sharedInstance] addCallDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismiss:)
                                                 name:kCallKitDismissNoti
                                               object:nil];
    self.uiConfigDic = [[NSMutableDictionary alloc] init];
    [self.uiConfigDic setObject:NEAudioCallingController.class forKey:kAudioCalling];
    [self.uiConfigDic setObject:NEAudioInCallController.class forKey:kAudioInCall];
    [self.uiConfigDic setObject:NEVideoCallingController.class forKey:kVideoCalling];
    [self.uiConfigDic setObject:NEVideoInCallController.class forKey:kVideoInCall];
    [self registerRouter];

    [NERtcCallKit sharedInstance].recordHandler = ^(V2NIMMessage *message) {
      if ([[NetManager shareInstance] isClose] == YES) {
        V2NIMMessageCallAttachment *recordObject = (V2NIMMessageCallAttachment *)message.attachment;
        recordObject.status = 2;  // 表示取消
      }
    };

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    self.smallVideoSize = CGSizeMake(90, 160);
    self.smallAudioSize = CGSizeMake(70, 70);

    // 群呼
    [[NEGroupCallKit sharedInstance] addDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didGroupCallDismiss:)
                                                 name:kGroupCallKitDismissNoti
                                               object:nil];
  }
  return self;
}

- (void)registerRouter {
  [[Router shared] register:@"imkit://callkit.page"
                    closure:^(NSDictionary<NSString *, id> *_Nonnull param) {
                      if ([[NetManager shareInstance] isClose] == YES) {
                        [UIApplication.sharedApplication.keyWindow
                            ne_makeToast:[NECallKitUtil localizableWithKey:@"network_error"]];
                        return;
                      }
                      NEUICallParam *callParam = [[NEUICallParam alloc] init];
                      callParam.remoteUserAccid = [param objectForKey:@"remoteUserAccid"];
                      callParam.remoteShowName = [param objectForKey:@"remoteShowName"];
                      callParam.remoteAvatar = [param objectForKey:@"remoteAvatar"];

                      NSNumber *type = [param objectForKey:@"type"];
                      NECallType callType = NECallTypeAudio;
                      if (type.intValue == 1) {
                        callType = NECallTypeAudio;
                      } else if (type.intValue == 2) {
                        callType = NECallTypeVideo;
                      }
                      callParam.callType = callType;
                      [self callWithParam:callParam];
                    }];

  [[Router shared]
      register:kCallStatusQueryKey
       closure:^(NSDictionary<NSString *, id> *_Nonnull params) {
         BOOL result = NECallEngine.sharedInstance.callStatus == NECallStatusIdle ? true : false;
         [[Router shared]
                    use:kCallStatusCallBackKey
             parameters:@{kCallStatusResult : [NSNumber numberWithBool:result]}
                closure:^(id _Nullable obj, enum RouterState state, NSString *_Nonnull string){

                }];
       }];
}

- (void)setCustomCallClass:(NSMutableDictionary<NSString *, Class> *)customDic {
  for (NSString *key in customDic.allKeys) {
    Class cls = customDic[key];
    [self.uiConfigDic setObject:cls forKey:key];
  }
}

- (void)callWithParam:(NEUICallParam *)callParam {
  YXAlogInfo(@"call uikit callWithParam called : %d", self.isCalled);
  if (self.isCalled == YES) {
    return;
  }
  self.isCalling = YES;
  NECallViewController *callVC = [[NECallViewController alloc] init];
  if (callParam.remoteShowName.length <= 0) {
    callParam.remoteShowName = callParam.remoteUserAccid;
  }
  callParam.enableAudioToVideo = self.config.uiConfig.enableAudioToVideo;
  callParam.enableVideoToAudio = self.config.uiConfig.enableVideoToAudio;
  callParam.useEnableLocalMute = self.config.uiConfig.useEnableLocalMute;
  callParam.enableVirtualBackground = self.config.uiConfig.enableVirtualBackground;
  callParam.enableCalleePreview = self.config.uiConfig.enableCalleePreview;
  callParam.enableFloatingWindow = self.config.uiConfig.enableFloatingWindow;
  callParam.enableFloatingWindowOutOfApp = self.config.uiConfig.enableFloatingWindowOutOfApp;
  callParam.isCaller = YES;
  if (self.customControllerClass != nil) {
    [self showCustomClassController:callParam];
    return;
  }
  callVC.status = NERtcCallStatusCalling;
  callVC.callParam = callParam;
  callVC.uiConfigDic = self.uiConfigDic;
  callVC.config = self.config.uiConfig;
  [self showCallView:callVC];
}

- (void)onCallEnd:(NECallEndInfo *)info {
  YXAlogInfo(@"call ui kit oncallend");
  [self stopPip];
}

- (UIImageView *)getRemoteHeaderImage {
  UIImageView *remoteHeaderImage = [[UIImageView alloc] init];
  remoteHeaderImage.translatesAutoresizingMaskIntoConstraints = NO;
  remoteHeaderImage.contentMode = UIViewContentModeScaleAspectFit;
  remoteHeaderImage.clipsToBounds = YES;
  remoteHeaderImage.layer.cornerRadius = 4.0;
  return remoteHeaderImage;
}

// 设置应用外小窗远端关闭视频时候的占位视图
- (void)setRemoteWithUrl:(NSString *)url withAccid:(NSString *)accid {
  YXAlogInfo(@"set url %@  set accid %@", url, accid);
  [self.coverView removeFromSuperview];
  [self.remoteHeaderImageView removeFromSuperview];
  self.coverView = [self getCoverView];
  self.currentRemoteAccid = accid;
  self.remoteHeaderImageView = [self getRemoteHeaderImage];
  [self.remoteHeaderImageView sd_setImageWithURL:[NSURL URLWithString:url]
                                placeholderImage:[UIImage imageNamed:@"avator"
                                                                          inBundle:self.bundle
                                                     compatibleWithTraitCollection:nil]];
  [self.coverView addSubview:self.remoteHeaderImageView];
  [NSLayoutConstraint activateConstraints:@[
    [self.remoteHeaderImageView.centerXAnchor constraintEqualToAnchor:self.coverView.centerXAnchor],
    [self.remoteHeaderImageView.centerYAnchor constraintEqualToAnchor:self.coverView.centerYAnchor],
    [self.remoteHeaderImageView.widthAnchor constraintEqualToAnchor:self.coverView.widthAnchor
                                                         multiplier:0.5],
    [self.remoteHeaderImageView.heightAnchor constraintEqualToAnchor:self.coverView.widthAnchor
                                                          multiplier:0.5]
  ]];
}

- (void)onCallTypeChange:(NECallTypeChangeInfo *)info {
  NSLog(@"onCallTypeChange value :%lu  :%lu", (unsigned long)info.state,
        (unsigned long)info.callType);
  if (info.state == NECallSwitchStateAgree) {
    if (info.callType == NECallTypeAudio) {
      [self stopPip];
    } else {
      [self createPipController];
    }
  }
}

- (void)onCallConnected:(NECallInfo *)info {
  if (info.callType == NECallTypeVideo) {
    [self createPipController];
  }
}

- (void)onLocalAudioMuted:(BOOL)muted {
}

- (void)onReceiveInvited:(NEInviteInfo *)info {
  if (self.config.uiConfig.disableShowCalleeView == YES) {
    return;
  }
  YXAlogInfo(@"call uikit onReceiveInvited calling : %d", self.isCalling);
  if (self.isCalling == YES) {
    NEHangupParam *param = [[NEHangupParam alloc] init];
    [param setValue:[NSNumber numberWithInteger:TerminalCodeBusy] forKey:@"reasonCode"];
    [NECallEngine.sharedInstance hangup:param
                             completion:^(NSError *_Nullable error){

                             }];
    return;
  }
  self.isCalled = YES;
  [NIMSDK.sharedSDK.userManager
      fetchUserInfos:@[ info.callerAccId ]
          completion:^(NSArray<NIMUser *> *_Nullable users, NSError *_Nullable error) {
            if (error) {
              [UIApplication.sharedApplication.keyWindow ne_makeToast:error.description];
              return;
            } else {
              NIMUser *imUser = users.firstObject;
              NEUICallParam *callParam = [[NEUICallParam alloc] init];
              callParam.remoteUserAccid = imUser.userId;
              callParam.remoteShowName = self.config.uiConfig.calleeShowPhone == YES
                                             ? imUser.userInfo.mobile
                                             : imUser.userInfo.nickName;
              callParam.remoteAvatar = imUser.userInfo.avatarUrl;
              callParam.enableAudioToVideo = self.config.uiConfig.enableAudioToVideo;
              callParam.enableVideoToAudio = self.config.uiConfig.enableVideoToAudio;
              callParam.enableVirtualBackground = self.config.uiConfig.enableVirtualBackground;
              callParam.enableCalleePreview = self.config.uiConfig.enableCalleePreview;
              callParam.enableFloatingWindow = self.config.uiConfig.enableFloatingWindow;
              callParam.enableFloatingWindowOutOfApp =
                  self.config.uiConfig.enableFloatingWindowOutOfApp;
              callParam.callType = info.callType;
              callParam.isCaller = NO;
              if (self.customControllerClass != nil) {
                if (self.delegate != nil &&
                    [self.delegate respondsToSelector:@selector
                                   (didCallComingWithInviteInfo:withCallParam:withCompletion:)]) {
                  [self.delegate didCallComingWithInviteInfo:info
                                               withCallParam:callParam
                                              withCompletion:^(BOOL success) {
                                                if (success) {
                                                  [self showCustomClassController:callParam];
                                                }
                                              }];
                  return;
                }
                [self showCustomClassController:callParam];
                return;
              }
              NECallViewController *callVC = [[NECallViewController alloc] init];
              callVC.callParam = callParam;
              callVC.status = NERtcCallStatusCalled;
              callVC.uiConfigDic = self.uiConfigDic;
              callVC.config = self.config.uiConfig;
              if (self.delegate != nil &&
                  [self.delegate respondsToSelector:@selector
                                 (didCallComingWithInviteInfo:withCallParam:withCompletion:)]) {
                [self.delegate didCallComingWithInviteInfo:info
                                             withCallParam:callParam
                                            withCompletion:^(BOOL success) {
                                              if (success) {
                                                [self showCallView:callVC];
                                              }
                                            }];
                return;
              }
              [self showCallView:callVC];
            }
          }];
}

- (void)showCalled:(NIMUser *)imUser callType:(NECallType)type attachment:(NSString *)attachment {
  if (self.keywindow != nil) {
    return;
  }
  NECallViewController *callVC = [[NECallViewController alloc] init];
  NEUICallParam *callParam = [[NEUICallParam alloc] init];
  callParam.remoteUserAccid = imUser.userId;
  callParam.remoteShowName = imUser.userInfo.mobile;
  callParam.remoteAvatar = imUser.userInfo.avatarUrl;
  callParam.enableVideoToAudio = self.config.uiConfig.enableVideoToAudio;
  callParam.enableAudioToVideo = self.config.uiConfig.enableAudioToVideo;
  callParam.callType = type;
  callParam.isCaller = NO;
  if (self.customControllerClass != nil) {
    [self showCustomClassController:callParam];
    return;
  }
  callVC.callParam = callParam;
  callVC.status = NERtcCallStatusCalled;
  callVC.uiConfigDic = self.uiConfigDic;
  callVC.config = self.config.uiConfig;
  [self showCallView:callVC];
}

- (void)showCallView:(NECallViewBaseController *)callVC {
  if (self.config.uiConfig.enableFloatingWindowOutOfApp == YES) {
    [self setRemoteWithUrl:callVC.callParam.remoteAvatar
                 withAccid:callVC.callParam.remoteUserAccid];
  }
  callVC.createPipSEL = @selector(createPipController);
  callVC.stopPipSEL = @selector(stopPip);
  UINavigationController *nav = [self getKeyWindowNav];
  UINavigationController *callNav =
      [[UINavigationController alloc] initWithRootViewController:callVC];
  callNav.modalPresentationStyle = UIModalPresentationFullScreen;
  [callNav.navigationBar setHidden:YES];
  [nav presentViewController:callNav animated:YES completion:nil];
  YXAlogInfo(@"call uikit show call view caller : %d", callVC.callParam.isCaller);
}

- (void)stopPip {
  if (self.pipController != nil && [self.pipController isPictureInPictureActive]) {
    [self.pipController stopPictureInPicture];
  }
  self.pipController = nil;
}

- (UINavigationController *)getKeyWindowNav {
  YXAlogInfo(@"call uikit getKeyWindowNav");
  if (self.keywindow == nil) {
    UIWindow *window = [[UIWindow alloc] init];
    if (@available(iOS 13.0, *)) {
      for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes.allObjects) {
        if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone ||
            scene.activationState == UISceneActivationStateForegroundActive) {
          window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
        }
      }
    }
    window.frame = [[UIScreen mainScreen] bounds];
    window.windowLevel = UIWindowLevelStatusBar - 1;
    window.backgroundColor = [UIColor clearColor];
    self.keywindow = window;
    self.preiousKeywindow = UIApplication.sharedApplication.keyWindow;
    YXAlogInfo(@"create new window %@", self.keywindow);
    YXAlogInfo(@"self.preiousKeywindow %@", self.preiousKeywindow);
  }

  UIViewController *root = [[UIViewController alloc] init];
  root.view.backgroundColor = [UIColor clearColor];
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:root];
  nav.navigationBar.tintColor = [UIColor clearColor];
  nav.view.backgroundColor = [UIColor clearColor];
  [nav.navigationBar setHidden:YES];
  self.keywindow.rootViewController = nav;
  self.keywindow.backgroundColor = [UIColor clearColor];
  [self.keywindow makeKeyAndVisible];
  return nav;
}

- (void)didDismiss:(NSNotification *)noti {
  YXAlogInfo(@"call uikit didDismiss caller : %d called : %d", self.isCalling, self.isCalled);
  UINavigationController *nav = (UINavigationController *)self.keywindow.rootViewController;
  __weak typeof(self) weakSelf = self;
  [nav dismissViewControllerAnimated:YES
                          completion:^{
                            NSLog(@"self window %@", weakSelf.keywindow);
                            YXAlogInfo(@"call uikit didDismiss completion");
                          }];

  [self.keywindow resignKeyWindow];
  self.keywindow = nil;
  if (self.parentView != nil && self.callViewController.view != self.parentView) {
    [self.callViewController.view removeFromSuperview];
  }
  self.parentView = nil;
  self.callViewController = nil;
  [self.pipController stopPictureInPicture];
  self.pipController = nil;
  self.isCalled = NO;
  self.isCalling = NO;
}

- (void)showCustomClassController:(NEUICallParam *)callParam {
  NECallViewBaseController *callViewController = [[self.customControllerClass alloc] init];
  callViewController.callParam = callParam;
  if ([callViewController isKindOfClass:[NECallViewController class]]) {
    NECallViewController *callVC = (NECallViewController *)callViewController;
    callVC.status = callParam.isCaller == YES ? NERtcCallStatusCalling : NERtcCallStatusCalled;
    callVC.callParam = callParam;
    callVC.uiConfigDic = self.uiConfigDic;
    callVC.config = self.config.uiConfig;
  }
  [self showCallView:callViewController];
}

#pragma mark - Small Window

- (void)tryOpenWindowOutApp {
  // 处理应用程序进入后台的操作
  NERtcVideoCanvas *canvas = [[NERtcVideoCanvas alloc] init];
  canvas.renderMode = kNERtcVideoRenderScaleCropFill;
  canvas.useExternalRender = YES;
  canvas.externalVideoRender = self;
  [NERtcEngine.sharedEngine
      setupRemoteVideoCanvas:canvas
                   forUserID:self.isCalled
                                 ? [[NECallEngine sharedInstance] getCallInfo].callerInfo.uid
                                 : [[NECallEngine sharedInstance] getCallInfo].calleeInfo.uid];
  if (![self.pipController isPictureInPictureActive]) {
    NSLog(@"isPictureInPictureSupported");
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.pipController startPictureInPicture];
    });
  }
}

- (void)appDidEnterBackground {
  NSLog(@"appDidEnterBackground");

  if ([self checkoutOutOfAppWindownEnable] == NO) {
    return;
  }
  [self tryOpenWindowOutApp];
}

- (void)appDidEnterForeground {
  [self.pipController stopPictureInPicture];
  NECallEngine *engine = [NECallEngine sharedInstance];
  if (engine.callStatus == NECallStatusInCall && [engine getCallInfo].callType == NECallTypeVideo &&
      self.callViewController != nil) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [[NECallEngine sharedInstance] setupRemoteView:self.callViewController.recoveryView];
    });
  }
  if (self.pipController != nil && [self.pipController isPictureInPictureActive]) {
    [self.pipController stopPictureInPicture];
    self.pipController = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
      [self createPipController];
    });
  }
}

///  转为小窗模式
- (void)changeSmallModeWithTyple:(NECallType)callType {
  [self.keywindow resignKeyWindow];
  self.keywindow.hidden = YES;
  [self.preiousKeywindow makeKeyWindow];
  UINavigationController *nav = (UINavigationController *)self.keywindow.rootViewController;
  UINavigationController *rootNav = (UINavigationController *)nav.presentedViewController;
  UIViewController *rootViewController = rootNav.viewControllers.firstObject;
  UIScreen *screen = UIScreen.mainScreen;
  CGFloat width = screen.bounds.size.width;
  CGFloat height = screen.bounds.size.height;
  if (self.parentView == nil) {
    if ([rootViewController isKindOfClass:NECallViewBaseController.class]) {
      NECallViewBaseController *call = (NECallViewBaseController *)rootViewController;
      self.callViewController = call;
      self.originFrame = call.view.frame;
      self.parentView = call.view.superview;
      call.recoveryView.backgroundColor = [UIColor grayColor];
      if (callType == NECallTypeVideo) {
        call.view.frame = CGRectMake(width - self.smallVideoSize.width - call.floatMargin, 54,
                                     self.smallVideoSize.width, self.smallVideoSize.height);
      } else {
        call.view.frame = CGRectMake(width - self.smallAudioSize.width - call.floatMargin, 54,
                                     self.smallAudioSize.width, self.smallAudioSize.height);
      }
      [UIApplication.sharedApplication.keyWindow addSubview:call.view];
    }
  } else {
    NECallViewBaseController *call = (NECallViewBaseController *)self.callViewController;
    CGFloat centerX = call.view.frame.origin.x + call.view.frame.size.width / 2.0;
    if (callType == NECallTypeVideo &&
        !CGSizeEqualToSize(call.view.bounds.size, self.smallVideoSize)) {
      CGFloat x = centerX > width / 2.0 ? width - self.smallVideoSize.width - call.floatMargin
                                        : call.floatMargin;
      CGFloat y = call.view.frame.origin.y;
      if (y + call.view.frame.size.height + self.smallVideoSize.height + call.floatMargin >
          height) {
        y = height - self.smallVideoSize.height - call.floatMargin;
      }
      call.view.frame = CGRectMake(x, y, self.smallVideoSize.width, self.smallVideoSize.height);
      call.audioSmallView.hidden = YES;
      call.recoveryView.hidden = NO;
      call.view.layer.cornerRadius = 0;
      call.recoveryView.backgroundColor = [UIColor grayColor];
      dispatch_async(dispatch_get_main_queue(), ^{
        [[NECallEngine sharedInstance] setupRemoteView:call.recoveryView];
      });
    } else if (callType == NECallTypeAudio &&
               !CGSizeEqualToSize(call.view.bounds.size, self.smallAudioSize)) {
      CGFloat x = centerX > width / 2.0 ? width - self.smallAudioSize.width - call.floatMargin
                                        : call.floatMargin;
      call.view.frame = CGRectMake(x, call.view.frame.origin.y, self.smallAudioSize.width,
                                   self.smallAudioSize.height);
      call.audioSmallView.hidden = NO;
      call.view.layer.cornerRadius = 6;
      call.coverView.hidden = YES;
    }
  }
}

- (void)onVideoMuted:(BOOL)muted userID:(NSString *)userId {
  YXAlogInfo(@"callkit ui onVideoMuted current accid : %@  userid : %@ mute : %d mask view : %@",
             self.currentRemoteAccid, userId, muted, self.coverView);

  if (self.currentRemoteAccid.length > 0 && [self.currentRemoteAccid isEqualToString:userId]) {
    self.coverView.hidden = !muted;
  }
}

/// 恢复为非小窗模式
- (void)restoreNormalMode {
  [self.keywindow makeKeyWindow];
  self.keywindow.hidden = NO;
  UINavigationController *nav = (UINavigationController *)self.keywindow.rootViewController;
  UINavigationController *rootNav = (UINavigationController *)nav.presentedViewController;
  UIViewController *rootViewController = rootNav.viewControllers.firstObject;

  if ([rootViewController isKindOfClass:NECallViewBaseController.class]) {
    NECallViewController *call = (NECallViewController *)rootViewController;
    call.view.frame = self.originFrame;
    [self.parentView addSubview:call.view];
  }
  self.parentView = nil;
  self.callViewController = nil;
}

- (UIView *)getCoverView {
  UIView *coverView = [[UIView alloc] init];
  coverView.translatesAutoresizingMaskIntoConstraints = NO;
  CAGradientLayer *gradientLayer = [CAGradientLayer layer];
  gradientLayer.colors = @[
    (__bridge id)[NECallKitUtil colorWithHexString:@"#232529"].CGColor,
    (__bridge id)[NECallKitUtil colorWithHexString:@"#5E6471"].CGColor
  ];
  gradientLayer.locations = @[ @0.0, @1.0 ];
  gradientLayer.startPoint = CGPointMake(0, 0);
  gradientLayer.endPoint = CGPointMake(0, 1);
  CGFloat width = 360;
  CGSize size = CGSizeMake(width, width / 9 * 16);
  gradientLayer.frame = CGRectMake(0, 0, size.width, size.height);
  [coverView.layer addSublayer:gradientLayer];
  coverView.hidden = YES;
  return coverView;
}

- (void)createPipController {
  if (self.config.uiConfig.enableFloatingWindow == NO) {
    return;
  }

  if (self.config.uiConfig.enableFloatingWindowOutOfApp == NO) {
    return;
  }

  if (!_pipController) {
    if (![AVPictureInPictureController isPictureInPictureSupported]) {
      return;
    }
    UIView *sourceView = nil;
    if (self.preiousKeywindow != nil) {
      sourceView = self.preiousKeywindow.rootViewController.view;
    } else {
      sourceView = UIApplication.sharedApplication.keyWindow.rootViewController.view;
    }
    if (@available(iOS 15.0, *)) {
      AVPictureInPictureControllerContentSource *contentSource =
          [[AVPictureInPictureControllerContentSource alloc]
              initWithActiveVideoCallSourceView:sourceView
                          contentViewController:[self getVideoCallViewController]];
      _pipController = [[AVPictureInPictureController alloc] initWithContentSource:contentSource];
      _pipController.delegate = self;

      _pipController.canStartPictureInPictureAutomaticallyFromInline = NO;
      [_pipController stopPictureInPicture];
    }
  }
}

- (AVPictureInPictureVideoCallViewController *)getVideoCallViewController {
  AVPictureInPictureVideoCallViewController *videoCallViewController =
      [[AVPictureInPictureVideoCallViewController alloc] init];
  CGFloat width = 180;
  CGSize newSize = CGSizeMake(width, width / 9 * 16);
  videoCallViewController.preferredContentSize = CGSizeMake(newSize.width, newSize.height);

  self.displayView = [self createDisplayView];
  [videoCallViewController.view addSubview:self.displayView];
  [NSLayoutConstraint activateConstraints:@[
    [self.displayView.topAnchor constraintEqualToAnchor:videoCallViewController.view.topAnchor],
    [self.displayView.leadingAnchor
        constraintEqualToAnchor:videoCallViewController.view.leadingAnchor],
    [self.displayView.trailingAnchor
        constraintEqualToAnchor:videoCallViewController.view.trailingAnchor],
    [self.displayView.bottomAnchor
        constraintEqualToAnchor:videoCallViewController.view.bottomAnchor]
  ]];
  if (self.coverView != nil) {
    [videoCallViewController.view addSubview:self.coverView];
    [NSLayoutConstraint activateConstraints:@[
      [self.coverView.topAnchor constraintEqualToAnchor:videoCallViewController.view.topAnchor],
      [self.coverView.leadingAnchor
          constraintEqualToAnchor:videoCallViewController.view.leadingAnchor],
      [self.coverView.trailingAnchor
          constraintEqualToAnchor:videoCallViewController.view.trailingAnchor],
      [self.coverView.bottomAnchor
          constraintEqualToAnchor:videoCallViewController.view.bottomAnchor]
    ]];
  }
  return videoCallViewController;
}

- (NEBufferDisplayView *)createDisplayView {
  NEBufferDisplayView *displayView = [[NEBufferDisplayView alloc] initWithFrame:CGRectZero];
  displayView.translatesAutoresizingMaskIntoConstraints = NO;
  return displayView;
}

- (BOOL)checkoutOutOfAppWindownEnable {
  if ([NECallEngine sharedInstance].callStatus != NECallStatusInCall) {
    // 不在通话中，不需要处理进入后台逻辑
    NSLog(@"appDidEnterBackground call status : %lu",
          (unsigned long)NECallEngine.sharedInstance.callStatus);
    return NO;
  }

  NECallType calltype = [[NECallEngine sharedInstance] getCallInfo].callType;
  if (calltype != NECallTypeVideo) {
    // 音频呼叫没有应用外小窗
    return NO;
  }

  if (self.config.uiConfig.enableFloatingWindow == YES &&
      self.config.uiConfig.enableFloatingWindowOutOfApp == YES) {
    return YES;
  }
  return NO;
}

#pragma mark - Rtc Delegate

- (void)onNERtcEngineRenderFrame:(NERtcVideoFrame *_Nonnull)frame {
  if (self.transcodingDelegate != nil && self.pipController != nil &&
      [self.pipController isPictureInPictureActive]) {
    [self.transcodingDelegate renderFrame:frame withLayer:self.displayView.getLayer];
  }
}

#pragma mark - pip delegate

- (void)pictureInPictureControllerDidStopPictureInPicture:
    (AVPictureInPictureController *)pictureInPictureController {
  NSLog(@"call ui kit pictureInPictureControllerDidStopPictureInPicture");
}

- (void)pictureInPictureControllerDidStartPictureInPicture:
    (AVPictureInPictureController *)pictureInPictureController {
  NSLog(@"call ui kit pictureInPictureControllerDidStartPictureInPicture");
}

- (void)pictureInPictureControllerWillStopPictureInPicture:
    (AVPictureInPictureController *)pictureInPictureController {
  NSLog(@"call ui kit pictureInPictureControllerWillStopPictureInPicture");
}

- (void)pictureInPictureControllerWillStartPictureInPicture:
    (AVPictureInPictureController *)pictureInPictureController {
  NSLog(@"call ui kit pictureInPictureControllerWillStartPictureInPicture");
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
    failedToStartPictureInPictureWithError:(NSError *)error {
  NSLog(@"call ui kit pictureInPictureController  error : %@", error);
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
    restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:
        (void (^)(BOOL))completionHandler {
  if (self.callViewController != nil) {
    [self.callViewController changeToNormal];
  }
}

#pragma mark - Version

+ (NSString *)version {
  return @"3.7.0";
}

#pragma mark - Group Call
- (void)groupCallWithParam:(NEUIGroupCallParam *)callParam {
  NSString *selfAccid = [NIMSDK.sharedSDK.v2LoginService getLoginUser];

  // 对 remoteUsers 进行去重处理
  NSMutableArray<NSString *> *uniqueRemoteUsers = [[NSMutableArray alloc] init];
  NSMutableSet<NSString *> *userSet = [[NSMutableSet alloc] init];

  for (NSString *userId in callParam.remoteUsers) {
    if (userId.length > 0 && ![userSet containsObject:userId]) {
      [userSet addObject:userId];
      [uniqueRemoteUsers addObject:userId];
    }
  }

  // 自己不算在内
  if (uniqueRemoteUsers.count > kGroupCallMaxUsers - 1) {
    YXAlogInfo(@"call uikit group call remote users exceed limit");
    [NECallKitUtil makeToast:[NECallKitUtil localizableWithKey:@"ui_member_exceed_limit"]];
    return;
  }

  // 创建包含主叫用户ID的完整用户ID列表
  NSMutableArray<NSString *> *allUserIds = [[NSMutableArray alloc] init];
  [allUserIds addObject:selfAccid];                    // 添加主叫用户ID
  [allUserIds addObjectsFromArray:uniqueRemoteUsers];  // 添加去重后的被叫用户ID列表

  // 通过 getUserList 获取所有用户信息
  __weak typeof(self) weakSelf = self;
  [NIMSDK.sharedSDK.v2UserService getUserList:allUserIds
      success:^(NSArray<V2NIMUser *> *_Nonnull result) {
        NSMutableArray<NEGroupUser *> *allUsers = [[NSMutableArray alloc] init];
        NEGroupUser *caller = nil;

        // 转换 V2NIMUser 为 NEGroupUser
        for (V2NIMUser *user in result) {
          NEGroupUser *groupUser = [weakSelf convertV2NIMUserToGroupUser:user];

          if ([groupUser.imAccid isEqualToString:selfAccid]) {
            groupUser.state = GroupMemberStateInChannel;
            caller = groupUser;
          } else {
            groupUser.state = GroupMemberStateWaitting;
          }

          [allUsers addObject:groupUser];
        }

        // 创建群呼控制器
        NEGroupCallViewController *callController =
            [[NEGroupCallViewController alloc] initWithCalled:NO withCaller:caller];
        callController.delegate = weakSelf;

        // 根据全局配置设置邀请按钮显示状态
        if (weakSelf.config && weakSelf.config.uiConfig) {
          callController.showInviteButton =
              weakSelf.config.uiConfig.enableGroupCallInviteOthersWhenCalling;
        } else {
          callController.showInviteButton = NO;  // 默认不显示邀请按钮
        }

        // 设置推送参数
        if (callParam.pushParam) {
          callController.pushParam = callParam.pushParam;
        }

        [callController addUser:allUsers];
        [weakSelf showGroupCallView:callController];
      }
      failure:^(V2NIMError *_Nonnull error) {
        YXAlogInfo(@"获取用户信息失败: %@", error.desc);
        // 即使获取用户信息失败，也显示界面，但用户列表为空
        NEGroupCallViewController *callController =
            [[NEGroupCallViewController alloc] initWithCalled:NO withCaller:nil];
        callController.delegate = weakSelf;
        [weakSelf showGroupCallView:callController];
      }];
}

- (void)showGroupCallView:(NEGroupCallViewController *)callVC {
  UINavigationController *nav = [self getKeyWindowNav];
  UINavigationController *callNav =
      [[UINavigationController alloc] initWithRootViewController:callVC];
  callNav.modalPresentationStyle = UIModalPresentationFullScreen;
  [callNav.navigationBar setHidden:YES];
  [nav presentViewController:callNav animated:YES completion:nil];
  YXAlogInfo(@"call uikit show group call view");
}

- (void)didGroupCallDismiss:(NSNotification *)notification {
  YXAlogInfo(@"Group call uikit didDismiss caller : %d called : %d", self.isCalling, self.isCalled);
  UINavigationController *nav = (UINavigationController *)self.keywindow.rootViewController;

  __weak typeof(self) weakSelf = self;
  [nav dismissViewControllerAnimated:YES
                          completion:^{
                            NSLog(@"self window %@", weakSelf.keywindow);
                            YXAlogInfo(@"call uikit didDismiss completion");
                          }];
  [self.keywindow resignKeyWindow];
  self.keywindow = nil;
  if (self.parentView != nil && self.callViewController.view != self.parentView) {
    [self.callViewController.view removeFromSuperview];
  }
  self.parentView = nil;
}

#pragma mark group call delegate
- (void)onGroupInvitedWithInfo:(NEGroupCallInfo *)info {
  NSMutableArray<GroupCallMember *> *members = [[NSMutableArray alloc] init];
  for (GroupCallMember *member in info.calleeList) {
    YXAlogInfo(@"current member accid : %@", member.imAccid);
  }
  [members addObjectsFromArray:info.calleeList];

  __weak typeof(self) weakSelf = self;
  [NEDataManager.shareInstance
      fetchUserWithMembers:members
                completion:^(NSError *_Nullable error, NSArray<NEGroupUser *> *_Nonnull users) {
                  if ([NEGroupCallKit sharedInstance].callId == nil ||
                      ![[NEGroupCallKit sharedInstance].callId isEqualToString:info.callId]) {
                    YXAlogInfo(@"data come, but group call has end");
                    return;
                  }
                  NSMutableArray *neUsers = [[NSMutableArray alloc] init];
                  NEGroupUser *neUser;
                  for (NEGroupUser *user in users) {
                    if ([user.imAccid isEqualToString:info.callerInfo.imAccid]) {
                      neUser = user;
                    } else {
                      [neUsers addObject:user];
                    }
                  }

                  NEGroupCallViewController *groupCall =
                      [[NEGroupCallViewController alloc] initWithCalled:YES withCaller:neUser];
                  groupCall.callId = info.callId;
                  groupCall.startTimestamp = info.startTimestamp;

                  // 根据全局配置设置邀请按钮显示状态
                  if (weakSelf.config && weakSelf.config.uiConfig) {
                    groupCall.showInviteButton =
                        weakSelf.config.uiConfig.enableGroupCallInviteOthersWhenCalling;
                  }

                  [groupCall addUser:neUsers];
                  groupCall.modalPresentationStyle = UIModalPresentationOverFullScreen;
                  groupCall.delegate = weakSelf;  // 设置代理

                  [weakSelf showGroupCallView:groupCall];
                }];
}

#pragma mark - 转换方法
/// 将 V2NIMUser 转换为 NEGroupUser
- (NEGroupUser *)convertV2NIMUserToGroupUser:(V2NIMUser *)v2User {
  if (!v2User) {
    return nil;
  }

  NEGroupUser *groupUser = [[NEGroupUser alloc] init];

  // 基本属性转换
  groupUser.mobile = v2User.mobile ?: @"";
  groupUser.avatar = v2User.avatar ?: @"";
  groupUser.nickname = v2User.name ?: @"";
  groupUser.imAccid = v2User.accountId ?: @"";

  // 群组呼叫状态初始化
  groupUser.state = GroupMemberStateWaitting;
  groupUser.uid = 0;  // 需要后续设置
  groupUser.isShowLocalVideo = 0;
  groupUser.isOpenVideo = NO;

  return groupUser;
}

#pragma mark - NEGroupCallViewControllerDelegate

- (void)inviteUsersWithCallId:(NSString *)callId
                  inCallUsers:(NSArray<NSString *> *)inCallUsers
                   completion:(void (^)(NSArray<NSString *> *_Nullable users))completion {
  YXAlogInfo(@"NERtcCallUIKit 收到邀请用户请求，callId: %@, 当前通话用户数: %ld", callId,
             (long)inCallUsers.count);
  if (self.delegate &&
      [self.delegate respondsToSelector:@selector(inviteUsersWithCallId:inCallUsers:completion:)]) {
    [self.delegate inviteUsersWithCallId:callId inCallUsers:inCallUsers completion:completion];
  }
}

@end
