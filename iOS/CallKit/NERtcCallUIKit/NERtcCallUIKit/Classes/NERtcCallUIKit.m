// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NERtcCallUIKit.h"
#import <NECommonUIKit/UIView+YXToast.h>
#import <NECoreKit/NECoreKit-Swift.h>
#import <NECoreKit/XKit.h>
#import <NERtcSDK/NERtcSDK.h>
#import <NEXKitBase/NEXKitBase.h>
#import <SDWebImage/SDWebImage.h>
#import "NEAISubtitleView.h"
#import "NEBufferDisplayView.h"
#import "NECallKitUtil.h"
#import "NECallViewController.h"
#import "NEDataManager.h"
#import "NEGroupCallViewController.h"
#import "NEUIGroupCallParam.h"
#import "NECallStateManager.h"
#import "NetManager.h"
#import "NEIncomingCallBannerView.h"
#import "NEIncomingCallBannerWindow.h"

@interface NECallViewController (NEIncomingBannerAccept)

@property(nonatomic, assign) BOOL incomingBannerAcceptConnecting;

- (void)updateUIonStatus:(NERtcCallStatus)status;

@end

NSString *kAudioCalling = @"kAudioCalling";

NSString *kVideoCalling = @"kVideoCalling";

NSString *kAudioInCall = @"kAudioInCall";

NSString *kVideoInCall = @"kVideoInCall";

NSString *kCalledState = @"kCalledState";

NSString *kMouldName = @"NERtcCallUIKit";

NSString *kCallStatusResult = @"result";

NSString *kCallStatusQueryKey = @"imkit://call/state/isIdle";

NSString *kCallStatusCallBackKey = @"imkit://call/state/result";

NSString *kNECallLCKJoinConversationActionNotification =
    @"NECallLCKJoinConversationActionNotification";

// 群呼人数限制常量
const NSInteger kGroupCallMaxUsers = 10;

@interface NECallKitUtil (NECallWindowDismiss)

+ (void)performAfterPresentationSettledInViewController:(UIViewController *)viewController
                                             retryCount:(NSInteger)retryCount
                                             completion:(dispatch_block_t)completion;

@end

@interface NERtcCallUIKit () <NECallEngineDelegate,
                              XKitService,
                              NERtcEngineDelegateEx,
                              NERtcEngineVideoFrameObserver,
                              NERtcEngineVideoRenderSink,
                              AVPictureInPictureControllerDelegate,
                              NEGroupCallKitDelegate,
                              NEGroupCallViewControllerDelegate>

@property(nonatomic, strong) NECallUIKitConfig *config;

@property(nonatomic, assign) BOOL incomingBannerEnabled;

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

@property(nonatomic, assign) BOOL hasLoggedPipRenderFrame;

@property(nonatomic, strong) NEUICallParam *incomingBannerCallParam;

@property(nonatomic, copy) NSString *incomingBannerChannelId;

@property(nonatomic, assign) BOOL incomingBannerAccepting;

@property(nonatomic, assign) BOOL callWindowDismissing;

- (BOOL)isCachedIncomingBannerCallMatched:(NECallInfo *)callInfo;

- (void)showFullScreenAfterSystemAcceptIfNeededWithCallInfo:(NECallInfo *)callInfo
                                                     source:(NSString *)source;

- (void)showIncomingBannerAcceptConnectingViewIfNeededWithCallParam:(NEUICallParam *)callParam;

- (void)performCallWindowDismiss;
- (void)cleanupCallWindowAfterDismiss;

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

+ (BOOL)shouldShowIncomingBannerForCallStatus:(NERtcCallStatus)callStatus
                              currentChannelId:(NSString *)currentChannelId
                               cachedChannelId:(NSString *)cachedChannelId
                                   callerAccId:(NSString *)callerAccId
                              cachedCallerAccId:(NSString *)cachedCallerAccId {
  if (callStatus != NERtcCallStatusCalled) {
    return NO;
  }
  if (cachedChannelId.length > 0) {
    if (currentChannelId.length <= 0 || ![cachedChannelId isEqualToString:currentChannelId]) {
      return NO;
    }
  }
  if (cachedCallerAccId.length > 0 && callerAccId.length > 0 &&
      ![cachedCallerAccId isEqualToString:callerAccId]) {
    return NO;
  }
  return YES;
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
  BOOL enableSingleToGroupCall =
      config.uiConfig.singleToGroupInviteMode != NECallSingleToGroupInviteModeDisabled;
  if (nil != config.config) {
    config.config.enableSingleToGroupCall = enableSingleToGroupCall;
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
    [[NECallStateManager sharedInstance] startObserving];
    [[NECallEngine sharedInstance] addCallDelegate:self];
    [NECallEngine sharedInstance].engineDelegate = self;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSystemIncomingCallAccepting:)
                                                 name:kNECallLCKJoinConversationActionNotification
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
  NEXKitBaseLogInfo(@"call uikit callWithParam called : %d", self.isCalled);
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
  NEXKitBaseLogInfo(@"call ui kit oncallend");
  [self stopPip];
  self.incomingBannerCallParam = nil;
  self.incomingBannerChannelId = nil;
  self.incomingBannerAccepting = NO;
  // 横幅模式下 keywindow 为 nil（未展示全屏通话界面），
  // didDismiss: 不会被触发，需在此手动重置标志位。
  if (self.keywindow == nil) {
    self.isCalled = NO;
    self.isCalling = NO;
  }
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
  NEXKitBaseLogInfo(@"set url %@  set accid %@", url, accid);
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
  NEXKitBaseLogInfo(@"call ui kit pip cover prepared remoteAccid:%@ cover:%@ hidden:%d",
                    self.currentRemoteAccid, self.coverView, self.coverView.hidden);
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
  [self showFullScreenAfterSystemAcceptIfNeededWithCallInfo:info source:@"onCallConnected"];
}

- (void)onLocalAudioMuted:(BOOL)muted {
}

- (void)onReceiveInvited:(NEInviteInfo *)info {
  if (self.config.uiConfig.disableShowCalleeView == YES) {
    return;
  }
  NEXKitBaseLogInfo(@"call uikit onReceiveInvited calling : %d", self.isCalling);
  if (self.isCalling == YES) {
    NEHangupParam *param = [[NEHangupParam alloc] init];
    [param setValue:[NSNumber numberWithInteger:TerminalCodeBusy] forKey:@"reasonCode"];
    [NECallEngine.sharedInstance hangup:param
                             completion:^(NSError *_Nullable error){

                             }];
    return;
  }
  self.isCalled = YES;
  NSString *inviteChannelId = info.channelId ?: @"";
  NSString *inviteCallerAccId = info.callerAccId ?: @"";
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
              callParam.multiCallInvite = info.multiCallInvite;
              if (self.incomingBannerEnabled == YES) {
                NECallEngine *engine = [NECallEngine sharedInstance];
                NECallInfo *currentCallInfo = [engine getCallInfo];
                NSString *currentChannelId = currentCallInfo.signalInfo.channelId ?: @"";
                NSString *currentCallerAccId = currentCallInfo.callerInfo.accId ?: @"";
                if (![NERtcCallUIKit shouldShowIncomingBannerForCallStatus:engine.callStatus
                                                           currentChannelId:currentChannelId
                                                            cachedChannelId:inviteChannelId
                                                                callerAccId:currentCallerAccId
                                                           cachedCallerAccId:inviteCallerAccId]) {
                  NEXKitBaseLogInfo(@"skipIncomingBanner stale invite callerAccId=%@ "
                                    @"inviteChannelId=%@ currentCallerAccId=%@ "
                                    @"currentChannelId=%@ callStatus:%lu",
                                    inviteCallerAccId, inviteChannelId, currentCallerAccId,
                                    currentChannelId, (unsigned long)engine.callStatus);
                  if (engine.callStatus != NERtcCallStatusCalled) {
                    self.isCalled = NO;
                  }
                  return;
                }
                if ([NEIncomingCallBannerWindow.sharedInstance isShowing]) {
                  NEXKitBaseLogInfo(@"secondCallIgnored replyBusy callerAccId=%@", callParam.remoteUserAccid);
                  NEHangupParam *busyParam = [[NEHangupParam alloc] init];
                  [busyParam setValue:[NSNumber numberWithInteger:TerminalCodeBusy] forKey:@"reasonCode"];
                  [[NECallEngine sharedInstance] hangup:busyParam completion:^(NSError *_Nullable e){}];
                  self.isCalled = NO;
                  return;
                }
                self.incomingBannerCallParam = callParam;
                self.incomingBannerChannelId = inviteChannelId;
                NEXKitBaseLogInfo(@"showIncomingBanner callerAccId=%@ callType=%ld",
                           callParam.remoteUserAccid, (long)callParam.callType);
                NEIncomingCallerInfo *callerInfo = [[NEIncomingCallerInfo alloc] init];
                callerInfo.accountId   = callParam.remoteUserAccid;
                callerInfo.displayName = callParam.remoteShowName;
                callerInfo.avatarUrl   = callParam.remoteAvatar;
                callerInfo.callType = callParam.callType;
                callerInfo.multiCallInvite = info.multiCallInvite;
                __weak typeof(self) weakSelf = self;
                void (^acceptBlock)(void) = ^{
                  weakSelf.incomingBannerCallParam = nil;
                  weakSelf.incomingBannerChannelId = nil;
                  UIViewController *permissionViewController =
                      [NEIncomingCallBannerWindow.sharedInstance presentingViewController];
                  NECallType permissionCallType =
                      [NECallKitUtil requiredPermissionCallTypeForCallType:callParam.callType
                                                           multiCallInvite:callParam.multiCallInvite];
                  [NECallKitUtil
                      requestAuthorizationForCallType:permissionCallType
                                  fromViewController:permissionViewController
                                          completion:^(BOOL granted, BOOL openSettings) {
                                            if (!granted) {
                                              NEXKitBaseLogInfo(@"incoming banner accept permission "
                                                                @"denied callType:%ld "
                                                                @"openSettings:%d",
                                                                (long)permissionCallType,
                                                                openSettings);
                                              [[NECallEngine sharedInstance]
                                                  hangup:[[NEHangupParam alloc] init]
                                              completion:^(__unused NSError *_Nullable error){}];
                                              weakSelf.isCalled = NO;
                                              [NEIncomingCallBannerWindow.sharedInstance dismiss];
                                              return;
                                            }
                                            [NEIncomingCallBannerWindow.sharedInstance dismiss];
                                            weakSelf.incomingBannerAccepting = YES;
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                              NECallViewController *connectingVC =
                                                  [[NECallViewController alloc] init];
                                              connectingVC.callParam = callParam;
                                              connectingVC.status = NERtcCallStatusCalled;
                                              connectingVC.uiConfigDic = weakSelf.uiConfigDic;
                                              connectingVC.config = weakSelf.config.uiConfig;
                                              connectingVC.ringAlreadyPlaying = YES;
                                              connectingVC.incomingBannerAcceptConnecting = YES;
                                              [[NECallEngine sharedInstance]
                                                  accept:^(NSError *_Nullable error,
                                                           NECallInfo *_Nullable callInfo) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                      weakSelf.incomingBannerAccepting = NO;
                                                      if (error) {
                                                        [weakSelf.preiousKeywindow
                                                            ne_makeToast:
                                                                [NSString
                                                                    stringWithFormat:
                                                                        @"%@ %@",
                                                                        [NECallKitUtil
                                                                            localizableWithKey:
                                                                                @"accept_failed"],
                                                                        error.localizedDescription]];
                                                        [connectingVC destroy];
                                                        return;
                                                      }
                                                      if (callParam.multiCallInvite ||
                                                          [[NECallEngine sharedInstance] isInMultiCall]) {
                                                        [connectingVC
                                                            updateUIonStatus:NERtcCallStatusInCall];
                                                      }
                                                    });
                                                  }];
                                              [weakSelf showCallView:connectingVC];
                                            });
                                          }];
                };
                void (^rejectBlock)(void) = ^{
                  weakSelf.incomingBannerCallParam = nil;
                  weakSelf.incomingBannerChannelId = nil;
                  [[NECallEngine sharedInstance] hangup:[[NEHangupParam alloc] init]
                                            completion:nil];
                  weakSelf.isCalled = NO;
                };
                void (^bodyTapBlock)(void) = ^{
                  dispatch_async(dispatch_get_main_queue(), ^{
                    NECallViewController *calledVC = [[NECallViewController alloc] init];
                    calledVC.callParam   = callParam;
                    calledVC.status      = NERtcCallStatusCalled;
                    calledVC.uiConfigDic = weakSelf.uiConfigDic;
                    calledVC.config      = weakSelf.config.uiConfig;
                    // 来自横幅主体点击，铃声已在播放，全屏 VC 不重新触发（FR-017）
                    calledVC.ringAlreadyPlaying = YES;
                    [weakSelf showCallView:calledVC];
                  });
                };
                [NEIncomingCallBannerWindow.sharedInstance showWithCallerInfo:callerInfo
                                                                     onAccept:acceptBlock
                                                                     onReject:rejectBlock
                                                                    onBodyTap:bodyTapBlock];
                return;
              }
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
  NECallEngine *engine = [NECallEngine sharedInstance];
  if (self.callWindowDismissing || self.keywindow != nil) {
    NEXKitBaseLogInfo(@"call uikit skip show call view busy dismissing:%d keywindow:%@",
                      self.callWindowDismissing, self.keywindow);
    return;
  }
  BOOL isCalledViewStale =
      [callVC isKindOfClass:NECallViewController.class] &&
      ((NECallViewController *)callVC).status == NERtcCallStatusCalled &&
      engine.callStatus != NERtcCallStatusCalled;
  if (isCalledViewStale) {
    NEXKitBaseLogInfo(@"call uikit skip show call view stale uiStatus:%lu engineStatus:%lu",
                      (unsigned long)((NECallViewController *)callVC).status,
                      (unsigned long)engine.callStatus);
    return;
  }
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
  NEXKitBaseLogInfo(@"call uikit show call view caller : %d", callVC.callParam.isCaller);
}

- (BOOL)isCachedIncomingBannerCallMatched:(NECallInfo *)callInfo {
  if (self.incomingBannerCallParam == nil || callInfo == nil) {
    return NO;
  }
  NSString *currentChannelId = callInfo.signalInfo.channelId ?: @"";
  NSString *cachedChannelId = self.incomingBannerChannelId ?: @"";
  if (cachedChannelId.length > 0 && currentChannelId.length > 0 &&
      ![cachedChannelId isEqualToString:currentChannelId]) {
    return NO;
  }
  NSString *callerAccId = callInfo.callerInfo.accId ?: @"";
  if (callerAccId.length > 0 &&
      ![callerAccId isEqualToString:self.incomingBannerCallParam.remoteUserAccid]) {
    return NO;
  }
  return YES;
}

- (void)showFullScreenAfterSystemAcceptIfNeededWithCallInfo:(NECallInfo *)callInfo
                                                     source:(NSString *)source {
  NECallEngine *engine = [NECallEngine sharedInstance];
  BOOL connectedEvent = [source isEqualToString:@"onCallConnected"];
  if (connectedEvent && [self.callViewController isKindOfClass:NECallViewController.class]) {
    NECallViewController *callVC = (NECallViewController *)self.callViewController;
    if (callVC.status == NERtcCallStatusCalled) {
      self.incomingBannerAccepting = NO;
      [callVC updateUIonStatus:NERtcCallStatusInCall];
      self.incomingBannerCallParam = nil;
      self.incomingBannerChannelId = nil;
      return;
    }
  }
  if (self.incomingBannerEnabled != YES ||
      (!connectedEvent && engine.callStatus != NECallStatusInCall) ||
      self.keywindow != nil || self.callViewController != nil ||
      ![self isCachedIncomingBannerCallMatched:callInfo]) {
    return;
  }

  self.incomingBannerAccepting = NO;

  NEXKitBaseLogInfo(
      @"call ui kit show full screen after system accept source:%@ callId:%@ channelId:%@ "
       @"remote:%@",
      source, callInfo.callId, callInfo.signalInfo.channelId,
      self.incomingBannerCallParam.remoteUserAccid);
  [NEIncomingCallBannerWindow.sharedInstance dismiss];

  NECallViewController *inCallVC = [[NECallViewController alloc] init];
  self.incomingBannerCallParam.callType = callInfo.callType;
  inCallVC.callParam = self.incomingBannerCallParam;
  inCallVC.status = NERtcCallStatusInCall;
  inCallVC.uiConfigDic = self.uiConfigDic;
  inCallVC.config = self.config.uiConfig;
  [self showCallView:inCallVC];

  self.incomingBannerCallParam = nil;
  self.incomingBannerChannelId = nil;
}

- (void)showIncomingBannerAcceptConnectingViewIfNeededWithCallParam:(NEUICallParam *)callParam {
  if (callParam == nil || self.keywindow != nil || self.callViewController != nil) {
    return;
  }
  [NEIncomingCallBannerWindow.sharedInstance dismiss];

  NECallViewController *connectingVC = [[NECallViewController alloc] init];
  connectingVC.callParam = callParam;
  connectingVC.status = NERtcCallStatusCalled;
  connectingVC.uiConfigDic = self.uiConfigDic;
  connectingVC.config = self.config.uiConfig;
  connectingVC.ringAlreadyPlaying = YES;
  connectingVC.incomingBannerAcceptConnecting = YES;
  [self showCallView:connectingVC];
}

- (BOOL)shouldReshowIncomingBannerOnForegroundWithCallStatus:(NERtcCallStatus)callStatus {
  if (self.incomingBannerAccepting) {
    NEXKitBaseLogInfo(@"call ui kit skip incoming banner reshow while accepting");
    return NO;
  }
  return self.incomingBannerEnabled == YES && callStatus == NERtcCallStatusCalled &&
         self.keywindow == nil && self.callViewController == nil;
}

- (void)stopPip {
  if (self.pipController != nil && [self.pipController isPictureInPictureActive]) {
    [self.pipController stopPictureInPicture];
  }
  self.pipController = nil;
}

- (UINavigationController *)getKeyWindowNav {
  NEXKitBaseLogInfo(@"call uikit getKeyWindowNav");
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
    UIWindow *previousWindow = UIApplication.sharedApplication.keyWindow;
    if ([NEIncomingCallBannerWindow.sharedInstance isBannerWindow:previousWindow]) {
      UIWindow *hostWindow = [NEIncomingCallBannerWindow.sharedInstance hostWindow];
      NEXKitBaseLogInfo(@"call uikit use banner host window:%@ instead of banner:%@",
                        hostWindow, previousWindow);
      previousWindow = hostWindow;
    }
    self.preiousKeywindow = previousWindow;
    NEXKitBaseLogInfo(@"create new window %@", self.keywindow);
    NEXKitBaseLogInfo(@"self.preiousKeywindow %@", self.preiousKeywindow);
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
  NEXKitBaseLogInfo(@"call uikit didDismiss caller : %d called : %d", self.isCalling,
                    self.isCalled);
  if (self.callWindowDismissing) {
    NEXKitBaseLogInfo(@"call uikit didDismiss ignored while dismissing");
    return;
  }
  self.callWindowDismissing = YES;
  __weak typeof(self) weakSelf = self;
  [NECallKitUtil performAfterPresentationSettledInViewController:self.keywindow.rootViewController
                                                      retryCount:8
                                                      completion:^{
                                                        [weakSelf performCallWindowDismiss];
                                                      }];
}

- (void)performCallWindowDismiss {
  UINavigationController *nav = (UINavigationController *)self.keywindow.rootViewController;
  if (nav == nil) {
    [self cleanupCallWindowAfterDismiss];
    return;
  }
  __weak typeof(self) weakSelf = self;
  [nav dismissViewControllerAnimated:YES
                          completion:^{
                            NSLog(@"self window %@", weakSelf.keywindow);
                            NEXKitBaseLogInfo(@"call uikit didDismiss completion");
                            [weakSelf cleanupCallWindowAfterDismiss];
                          }];
}

- (void)cleanupCallWindowAfterDismiss {
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
  self.callWindowDismissing = NO;
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
  NECallInfo *callInfo = [[NECallEngine sharedInstance] getCallInfo];
  uint64_t remoteUid = self.isCalled ? callInfo.callerInfo.uid : callInfo.calleeInfo.uid;
  self.hasLoggedPipRenderFrame = NO;
  NEXKitBaseLogInfo(
      @"call ui kit tryOpenWindowOutApp callId:%@ isCalled:%d remoteUid:%llu cover:%@ "
       @"coverHidden:%d pip:%@ pipActive:%d",
      callInfo.callId, self.isCalled, (unsigned long long)remoteUid, self.coverView,
      self.coverView ? self.coverView.hidden : -1, self.pipController,
      self.pipController ? self.pipController.isPictureInPictureActive : 0);
  NERtcVideoCanvas *canvas = [[NERtcVideoCanvas alloc] init];
  canvas.renderMode = kNERtcVideoRenderScaleCropFill;
  canvas.useExternalRender = YES;
  canvas.externalVideoRender = self;
  [NERtcEngine.sharedEngine setupRemoteVideoCanvas:canvas forUserID:remoteUid];
  if (![self.pipController isPictureInPictureActive]) {
    NEXKitBaseLogInfo(@"call ui kit startPictureInPicture request remoteUid:%llu pip:%@",
                      (unsigned long long)remoteUid, self.pipController);
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.pipController startPictureInPicture];
    });
  }
}

- (void)appDidEnterBackground {
  NECallEngine *engine = [NECallEngine sharedInstance];
  NECallInfo *callInfo = [engine getCallInfo];
  NEXKitBaseLogInfo(
      @"call ui kit appDidEnterBackground callStatus:%lu callType:%lu callId:%@ "
       @"enableFloat:%d enableFloatOut:%d cover:%@ coverHidden:%d",
      (unsigned long)engine.callStatus, (unsigned long)callInfo.callType, callInfo.callId,
      self.config.uiConfig.enableFloatingWindow, self.config.uiConfig.enableFloatingWindowOutOfApp,
      self.coverView, self.coverView ? self.coverView.hidden : -1);

  if ([self checkoutOutOfAppWindownEnable] == NO) {
    NEXKitBaseLogInfo(@"call ui kit appDidEnterBackground skip out-app floating window");
    return;
  }
  [self tryOpenWindowOutApp];
}

- (void)appDidEnterForeground {
  NECallEngine *engine = [NECallEngine sharedInstance];
  NECallInfo *callInfo = [engine getCallInfo];
  BOOL pipActive = self.pipController ? self.pipController.isPictureInPictureActive : NO;
  NEXKitBaseLogInfo(
      @"call ui kit appDidEnterForeground callStatus:%lu callType:%lu callId:%@ "
       @"pip:%@ pipActive:%d cover:%@ coverHidden:%d callVC:%@",
      (unsigned long)engine.callStatus, (unsigned long)callInfo.callType, callInfo.callId,
      self.pipController, pipActive, self.coverView, self.coverView ? self.coverView.hidden : -1,
      self.callViewController);
  [self showFullScreenAfterSystemAcceptIfNeededWithCallInfo:callInfo source:@"foreground"];
  // T040: 若有待显示的来电横幅（App 在后台收到来电），回到前台后重新展示
  if ([self shouldReshowIncomingBannerOnForegroundWithCallStatus:engine.callStatus]) {
    [NEIncomingCallBannerWindow.sharedInstance show];
  }
  [self.pipController stopPictureInPicture];
  if (engine.callStatus == NECallStatusInCall && [engine getCallInfo].callType == NECallTypeVideo &&
      self.callViewController != nil) {
    dispatch_async(dispatch_get_main_queue(), ^{
      NEXKitBaseLogInfo(@"call ui kit appDidEnterForeground setupRemoteView recoveryView:%@",
                        self.callViewController.recoveryView);
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

- (void)onSystemIncomingCallAccepting:(NSNotification *)notification {
  if (self.incomingBannerCallParam == nil) {
    return;
  }
  self.incomingBannerAccepting = YES;
  NEXKitBaseLogInfo(@"call ui kit system incoming call accepting");
  [self showIncomingBannerAcceptConnectingViewIfNeededWithCallParam:self.incomingBannerCallParam];
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
  NEXKitBaseLogInfo(
      @"callkit ui onVideoMuted current accid : %@  userid : %@ mute : %d mask view : %@ "
       @"hiddenBefore:%d pipActive:%d",
      self.currentRemoteAccid, userId, muted, self.coverView,
      self.coverView ? self.coverView.hidden : -1,
      self.pipController ? self.pipController.isPictureInPictureActive : 0);

  if (self.currentRemoteAccid.length > 0 && [self.currentRemoteAccid isEqualToString:userId]) {
    self.coverView.hidden = !muted;
    NEXKitBaseLogInfo(@"callkit ui onVideoMuted update pip cover userId:%@ hiddenAfter:%d",
                      userId, self.coverView.hidden);
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
    NEXKitBaseLogInfo(@"call ui kit createPipController skip enableFloatingWindow=NO");
    return;
  }

  if (self.config.uiConfig.enableFloatingWindowOutOfApp == NO) {
    NEXKitBaseLogInfo(@"call ui kit createPipController skip enableFloatingWindowOutOfApp=NO");
    return;
  }

  if (!_pipController) {
    if (![AVPictureInPictureController isPictureInPictureSupported]) {
      NEXKitBaseLogInfo(@"call ui kit createPipController skip PiP unsupported");
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
      NEXKitBaseLogInfo(@"call ui kit createPipController success sourceView:%@ pip:%@ cover:%@ "
                        @"coverHidden:%d displayView:%@",
                        sourceView, _pipController, self.coverView,
                        self.coverView ? self.coverView.hidden : -1, self.displayView);
    } else {
      NEXKitBaseLogInfo(@"call ui kit createPipController skip iOS < 15");
    }
  } else {
    NEXKitBaseLogInfo(@"call ui kit createPipController reuse pip:%@ active:%d cover:%@ "
                      @"coverHidden:%d",
                      _pipController, _pipController.isPictureInPictureActive, self.coverView,
                      self.coverView ? self.coverView.hidden : -1);
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
  NEXKitBaseLogInfo(@"call ui kit getVideoCallViewController displayView:%@ cover:%@ "
                    @"coverHidden:%d preferredSize:%@",
                    self.displayView, self.coverView, self.coverView ? self.coverView.hidden : -1,
                    NSStringFromCGSize(videoCallViewController.preferredContentSize));
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
    NEXKitBaseLogInfo(@"call ui kit checkoutOutOfAppWindownEnable false callStatus:%lu",
                      (unsigned long)NECallEngine.sharedInstance.callStatus);
    return NO;
  }

  NECallType calltype = [[NECallEngine sharedInstance] getCallInfo].callType;
  if (calltype != NECallTypeVideo) {
    // 音频呼叫没有应用外小窗
    NEXKitBaseLogInfo(@"call ui kit checkoutOutOfAppWindownEnable false callType:%lu",
                      (unsigned long)calltype);
    return NO;
  }

  if (self.config.uiConfig.enableFloatingWindow == YES &&
      self.config.uiConfig.enableFloatingWindowOutOfApp == YES) {
    NEXKitBaseLogInfo(@"call ui kit checkoutOutOfAppWindownEnable true");
    return YES;
  }
  NEXKitBaseLogInfo(
      @"call ui kit checkoutOutOfAppWindownEnable false enableFloat:%d enableFloatOut:%d",
      self.config.uiConfig.enableFloatingWindow, self.config.uiConfig.enableFloatingWindowOutOfApp);
  return NO;
}

#pragma mark - Rtc Delegate

- (void)onNERtcEngineRenderFrame:(NERtcVideoFrame *_Nonnull)frame {
  BOOL pipActive = self.pipController != nil && [self.pipController isPictureInPictureActive];
  if (pipActive && !self.hasLoggedPipRenderFrame) {
    self.hasLoggedPipRenderFrame = YES;
    NEXKitBaseLogInfo(@"call ui kit pip first render frame displayView:%@ cover:%@ coverHidden:%d "
                      @"transcodingDelegate:%@",
                      self.displayView, self.coverView, self.coverView ? self.coverView.hidden : -1,
                      self.transcodingDelegate);
  }
  if (self.transcodingDelegate != nil && self.pipController != nil && pipActive) {
    [self.transcodingDelegate renderFrame:frame withLayer:self.displayView.getLayer];
  }
}

- (void)onNERtcEngineAsrCaptionResult:(NSArray<NERtcAsrCaptionResult *> *)results {
  if (!results || results.count == 0) {
    return;
  }

  // 通过 keywindow 获取当前显示的 NECallViewController
  NECallViewController *callVC = [self getCurrentCallViewController];
  if (callVC && callVC.aiSubtitleView) {
    // 处理每个字幕结果
    for (NERtcAsrCaptionResult *result in results) {
      [callVC.aiSubtitleView updateSubtitle:result];
    }
  }
}

/// 获取当前显示的通话控制器
- (NECallViewController *)getCurrentCallViewController {
  if (!self.keywindow || !self.keywindow.rootViewController) {
    return nil;
  }

  // 从 keywindow 的 presentedViewController 中查找
  UIViewController *presentedVC = self.keywindow.rootViewController.presentedViewController;
  if ([presentedVC isKindOfClass:[UINavigationController class]]) {
    UINavigationController *nav = (UINavigationController *)presentedVC;
    UIViewController *topVC = nav.topViewController;
    if ([topVC isKindOfClass:[NECallViewController class]]) {
      return (NECallViewController *)topVC;
    }
  }

  return nil;
}

- (void)onNERtcEngineAsrCaptionStateChanged:(NERtcAsrCaptionState)state
                                       code:(int)code
                                    message:(NSString *)message {
}

#pragma mark - pip delegate

- (void)pictureInPictureControllerDidStopPictureInPicture:
    (AVPictureInPictureController *)pictureInPictureController {
  self.hasLoggedPipRenderFrame = NO;
  NEXKitBaseLogInfo(@"call ui kit pictureInPictureControllerDidStopPictureInPicture pip:%@ "
                    @"cover:%@ coverHidden:%d",
                    pictureInPictureController, self.coverView,
                    self.coverView ? self.coverView.hidden : -1);
}

- (void)pictureInPictureControllerDidStartPictureInPicture:
    (AVPictureInPictureController *)pictureInPictureController {
  self.hasLoggedPipRenderFrame = NO;
  NEXKitBaseLogInfo(@"call ui kit pictureInPictureControllerDidStartPictureInPicture pip:%@ "
                    @"cover:%@ coverHidden:%d displayView:%@",
                    pictureInPictureController, self.coverView,
                    self.coverView ? self.coverView.hidden : -1, self.displayView);
}

- (void)pictureInPictureControllerWillStopPictureInPicture:
    (AVPictureInPictureController *)pictureInPictureController {
  NEXKitBaseLogInfo(@"call ui kit pictureInPictureControllerWillStopPictureInPicture pip:%@ "
                    @"cover:%@ coverHidden:%d",
                    pictureInPictureController, self.coverView,
                    self.coverView ? self.coverView.hidden : -1);
}

- (void)pictureInPictureControllerWillStartPictureInPicture:
    (AVPictureInPictureController *)pictureInPictureController {
  NEXKitBaseLogInfo(@"call ui kit pictureInPictureControllerWillStartPictureInPicture pip:%@ "
                    @"cover:%@ coverHidden:%d displayView:%@",
                    pictureInPictureController, self.coverView,
                    self.coverView ? self.coverView.hidden : -1, self.displayView);
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
    failedToStartPictureInPictureWithError:(NSError *)error {
  NEXKitBaseLogInfo(@"call ui kit pictureInPictureController failed error:%@ pip:%@ cover:%@ "
                    @"coverHidden:%d",
                    error, pictureInPictureController, self.coverView,
                    self.coverView ? self.coverView.hidden : -1);
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
    restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:
        (void (^)(BOOL))completionHandler {
  NEXKitBaseLogInfo(@"call ui kit pictureInPicture restore UI pip:%@ callVC:%@ cover:%@ "
                    @"coverHidden:%d",
                    pictureInPictureController, self.callViewController, self.coverView,
                    self.coverView ? self.coverView.hidden : -1);
  if (self.callViewController != nil) {
    [self.callViewController changeToNormal];
  }
}

#pragma mark - Incoming Banner

- (void)enableIncomingBanner:(BOOL)enable {
  self.incomingBannerEnabled = enable;
  NEXKitBaseLogInfo(@"enableIncomingBanner: %d", enable);
}

#pragma mark - Version

+ (NSString *)version {
  return @"4.7.0";

}

#pragma mark - Group Call
- (void)groupCallWithParam:(NEUIGroupCallParam *)callParam {
  // 参数验证：防止崩溃
  if (!callParam) {
    NEXKitBaseLogInfo(@"call uikit group call param is nil");
    return;
  }

  if (!callParam.remoteUsers || callParam.remoteUsers.count == 0) {
    NEXKitBaseLogInfo(@"call uikit group call remote users is empty");
    return;
  }

  NSString *selfAccid = [NIMSDK.sharedSDK.v2LoginService getLoginUser];
  if (!selfAccid || selfAccid.length == 0) {
    NEXKitBaseLogInfo(@"call uikit group call self accid is nil");
    return;
  }

  // 对 remoteUsers 进行去重处理
  NSMutableArray<NSString *> *uniqueRemoteUsers = [[NSMutableArray alloc] init];
  NSMutableSet<NSString *> *userSet = [[NSMutableSet alloc] init];

  for (NSString *userId in callParam.remoteUsers) {
    if (userId && userId.length > 0 && ![userSet containsObject:userId]) {
      [userSet addObject:userId];
      [uniqueRemoteUsers addObject:userId];
    }
  }

  // 自己不算在内
  if (uniqueRemoteUsers.count > kGroupCallMaxUsers - 1) {
    NEXKitBaseLogInfo(@"call uikit group call remote users exceed limit");
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
        // 验证 result 的有效性
        if (!result || result.count == 0) {
          NEXKitBaseLogInfo(@"call uikit group call result is empty");
          return;
        }

        NSMutableArray<NEGroupUser *> *allUsers = [[NSMutableArray alloc] init];
        NEGroupUser *caller = nil;

        // 转换 V2NIMUser 为 NEGroupUser
        for (V2NIMUser *user in result) {
          if (!user) {
            continue;
          }

          NEGroupUser *groupUser = [weakSelf convertV2NIMUserToGroupUser:user];
          if (!groupUser) {
            continue;
          }

          if (groupUser.imAccid && [groupUser.imAccid isEqualToString:selfAccid]) {
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

        if (callParam.callId) {
          callController.callId = callParam.callId;
        }

        [callController addUser:allUsers];
        [weakSelf showGroupCallView:callController];
      }
      failure:^(V2NIMError *_Nonnull error) {
        NEXKitBaseLogInfo(@"获取用户信息失败: %@", error.desc);
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
  NEXKitBaseLogInfo(@"call uikit show group call view");
}

- (void)didGroupCallDismiss:(NSNotification *)notification {
  NEXKitBaseLogInfo(@"Group call uikit didDismiss caller : %d called : %d", self.isCalling,
                    self.isCalled);
  UINavigationController *nav = (UINavigationController *)self.keywindow.rootViewController;

  __weak typeof(self) weakSelf = self;
  [nav dismissViewControllerAnimated:YES
                          completion:^{
                            NSLog(@"self window %@", weakSelf.keywindow);
                            NEXKitBaseLogInfo(@"call uikit didDismiss completion");
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
    NEXKitBaseLogInfo(@"current member accid : %@", member.imAccid);
  }
  [members addObjectsFromArray:info.calleeList];

  __weak typeof(self) weakSelf = self;
  [NEDataManager.shareInstance
      fetchUserWithMembers:members
                completion:^(NSError *_Nullable error, NSArray<NEGroupUser *> *_Nonnull users) {
                  if ([NEGroupCallKit sharedInstance].callId == nil ||
                      ![[NEGroupCallKit sharedInstance].callId isEqualToString:info.callId]) {
                    NEXKitBaseLogInfo(@"data come, but group call has end");
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
  NEXKitBaseLogInfo(@"NERtcCallUIKit 收到邀请用户请求，callId: %@, 当前通话用户数: %ld", callId,
                    (long)inCallUsers.count);
  if (self.delegate &&
      [self.delegate respondsToSelector:@selector(inviteUsersWithCallId:inCallUsers:completion:)]) {
    [self.delegate inviteUsersWithCallId:callId inCallUsers:inCallUsers completion:completion];
  }
}

@end
