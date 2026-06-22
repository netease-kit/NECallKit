// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NECallViewController.h"
#import <NECommonKit/NECommonKit-Swift.h>
#import <NECommonUIKit/UIView+YXToast.h>
#import <NECoreKit/YXModel.h>
#import <NERtcSDK/NERtcSDK.h>
#import <NEXKitBase/NEXKitBase.h>
#import <SDWebImage/SDWebImage.h>
#include <mach/mach_time.h>
#import "NEAISubtitleView.h"
#import "NECallKitUtil.h"
#import "NECallStateManager.h"
#import "NECallUIStateController.h"
#import "NECustomButton.h"
#import "NEExpandButton.h"
#import "NERingPlayerManager.h"
#import "NERtcCallUIKit.h"
#import "NESingleToGroupCoordinator.h"
#import "NEVideoOperationView.h"
#import "NetManager.h"

NSString *const kCallKitDismissNoti = @"kCallKitDismissNoti";

NSString *const kCallKitShowNoti = @"kCallKitShowNoti";

@interface NECallViewController () <NERtcLinkEngineDelegate, NECallEngineRtcDelegateEx>

@property(nonatomic, strong) UIButton *switchCameraBtn;

@property(nonatomic, strong) NEVideoOperationView *operationView;

@property(nonatomic, strong) UILabel *timerLabel;

@property(nonatomic, strong) NSTimer *timer;

@property(nonatomic, strong) UIImageView *blurImage;

@property(nonatomic, strong) UIToolbar *toolBar;

@property(nonatomic, assign) int timerCount;

@property(nonatomic, strong) UIView *bannerView;

@property(nonatomic, weak) UIAlertController *alert;

@property(nonatomic, strong) UILabel *cnameLabel;

@property(nonatomic, assign) CGFloat factor;

@property(nonatomic, strong) UIButton *smallButton;

/// 通话状态视图
@property(nonatomic, strong) NEAudioCallingController *audioCallingController;

@property(nonatomic, strong) NEAudioInCallController *audioInCallController;

@property(nonatomic, strong) NEVideoCallingController *videoCallingController;

@property(nonatomic, strong) NEVideoInCallController *videoInCallController;

@property(nonatomic, strong) NECalledViewController *calledController;

@property(nonatomic, weak) NECallUIStateController *stateUIController;

@property(nonatomic, strong) NEAISubtitleView *aiSubtitleView;

@property(nonatomic, assign) BOOL isClickVirtual;

@property(nonatomic, strong) NESingleToGroupCoordinator *singleToGroupCoordinator;

@property(nonatomic, assign) BOOL restoringSingleToGroupFullScreen;
@property(nonatomic, strong) NSLayoutConstraint *switchCameraLeftToSmallConstraint;
@property(nonatomic, strong) NSLayoutConstraint *switchCameraLeftToViewConstraint;
@property(nonatomic, strong) NSLayoutConstraint *switchCameraTopConstraint;
@property(nonatomic, assign) BOOL didDetachSingleCallVideoCanvasForSingleToGroup;
@property(nonatomic, assign) BOOL didSyncSingleToGroupInitialMediaState;
@property(nonatomic, assign) BOOL didSyncSingleToGroupSpeakerState;
@property(nonatomic, assign) BOOL incomingBannerAcceptConnecting;
@property(nonatomic, assign) BOOL hasPendingSwitchCallTypeInvite;
@property(nonatomic, assign) NECallType pendingSwitchCallType;
@property(nonatomic, assign) NSInteger switchCallTypeInviteRevision;
@property(nonatomic, assign) BOOL switchCallTypeAlertDismissing;
@property(nonatomic, weak) UIViewController *switchCallTypeAlertPresenter;

+ (BOOL)shouldShowAcceptButtonForIncomingBannerAcceptConnecting;
+ (BOOL)shouldEnableAcceptButtonForIncomingBannerAcceptConnecting;

@end

@interface NECallKitUtil (NECallPresentationSettled)

+ (void)performAfterPresentationSettledInViewController:(UIViewController *)viewController
                                             retryCount:(NSInteger)retryCount
                                             completion:(dispatch_block_t)completion;

@end

@implementation NECallViewController

- (instancetype)init {
  self = [super init];
  if (self) {
    self.timerCount = 0;
    self.factor = 1.0;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [[NSNotificationCenter defaultCenter] postNotificationName:kCallKitShowNoti object:nil];
  [[NERtcEngine sharedEngine] setParameters:@{kNERtcKeyVideoStartWithBackCamera : @NO}];
  [self setupCommon];
  [self setupSmallWindown];
  [[NECallEngine sharedInstance] setValue:self forKey:@"engineDelegateEx"];
  [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  [[NECallEngine sharedInstance] setupLocalView:nil];
  if (self.callParam.enableVirtualBackground == YES && self.isClickVirtual == YES) {
    [[NERtcEngine sharedEngine] enableVirtualBackground:NO backData:nil];
  }
  [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

#pragma mark - SDK

- (void)setupCommon {
  [self setupUI];
  [self setupSDK];
  [self updateUIonStatus:self.status];
  [self showBannerAcceptConnectingStateIfNeeded];
  if (self.callParam.isCaller == NO &&
      [NECallEngine sharedInstance].callStatus == NERtcCallStatusIdle) {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
      [weakSelf destroy];
    });
  }

  [self.view addSubview:self.bannerView];
  [NSLayoutConstraint activateConstraints:@[
    [self.bannerView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:80],
    [self.bannerView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20],
    [self.bannerView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-20],
    [self.bannerView.heightAnchor constraintEqualToConstant:40]
  ]];
}

- (void)setupSDK {
  [[NECallEngine sharedInstance] addCallDelegate:self];
  // InCall 状态（横幅直接接听）时频道已 join，SDK 内部已按 channelType 调用 enableLocalVideo。
  // 多人音频邀请在接听前也不能预开本端视频，否则远端会看到视频而本端仍显示音频占位。
  BOOL shouldFollowCallTypeForLocalVideo =
      self.status == NERtcCallStatusInCall || self.callParam.multiCallInvite;
  BOOL videoEnable = shouldFollowCallTypeForLocalVideo
      ? (self.callParam.callType == NECallTypeVideo)
      : YES;
  [[NECallEngine sharedInstance] enableLocalVideo:videoEnable];

  __weak typeof(self) weakSelf = self;
  if (self.status == NERtcCallStatusCalling) {
    [self playRingWithType:CRTCallerRing];
    if (self.callParam.callType == NECallTypeAudio && self.callParam.isCaller == YES) {
      [self setAudioOutputToReceiver];
    }
    [self requestPermissionForCallType:self.callParam.callType
                         endCallOnFail:YES
                             onGranted:^{
                               [weakSelf startCallAfterPermissionGranted];
                             }];
  } else if (self.status == NERtcCallStatusCalled) {
    // 仅被叫等待接听状态才播放铃声；InCall 状态（横幅直接接听）不播放。
    // 横幅主体点击跳入全屏时不重复播放铃声，但仍需要做权限预检。
    if (!self.ringAlreadyPlaying) {
      [self playRingWithType:CRTCalleeRing];
    }
    NECallType permissionCallType =
        [NECallKitUtil requiredPermissionCallTypeForCallType:self.callParam.callType
                                             multiCallInvite:self.callParam.multiCallInvite];
    [self requestPermissionForCallType:permissionCallType
                         endCallOnFail:YES
                             onGranted:nil];
  } else if (self.status == NERtcCallStatusInCall) {
    // 横幅直接接听后跳入全屏 VC 时，通话已连接：
    // 1. onCallConnected 不会再次回调，需在此启动计时器
    // 2. updateUIonStatus(Called) 未执行，blurImage.image 未被赋值，需手动加载头像背景
    // 3. onCallConnected 未在此 VC 上触发，音频路由未配置，需在此补齐
    [self startTimer];
    [self setUrl:self.callParam.remoteAvatar withPlaceholder:@"avator"];
    if (self.callParam.callType == NECallTypeAudio) {
      [[NERtcEngine sharedEngine] setLoudspeakerMode:NO];
      self.isReceiver = YES;
      self.operationView.speakerBtn.selected = YES;  // selected=YES 对应听筒图标
    } else {
      [[NERtcEngine sharedEngine] setLoudspeakerMode:YES];
      self.isReceiver = NO;
      self.operationView.speakerBtn.selected = NO;   // selected=NO 对应扬声器图标
    }
  }
}

- (void)startCallAfterPermissionGranted {
  __weak typeof(self) weakSelf = self;
  NECallParam *param = [[NECallParam alloc] initWithAccId:self.callParam.remoteUserAccid
                                             withCallType:self.callParam.callType];
  param.globalExtraCopy = self.callParam.extra;
  param.rtcChannelName = self.callParam.channelName;
  param.extraInfo = self.callParam.attachment;
  param.pushConfig = self.callParam.pushConfig;

  [[NECallEngine sharedInstance]
            call:param
      completion:^(NSError *_Nullable error, NECallInfo *_Nullable callInfo) {
        NEXKitBaseLogInfo(@"callkit call callback ne call info : %@",
                          [callInfo yx_modelToJSONString]);
        if (weakSelf.callParam.callType == NERtcCallTypeVideo) {
          if ([weakSelf isGlobalInit] == YES) {
            dispatch_async(dispatch_get_main_queue(), ^{
              [[NECallEngine sharedInstance]
                  setupLocalView:weakSelf.videoCallingController.bigVideoView.videoView];
            });
          }
          weakSelf.videoCallingController.bigVideoView.userID =
              [[NIMSDK sharedSDK].v2LoginService getLoginUser];
        }

        if (error) {
          /// 对方离线时 通过APNS推送 UI不弹框提示
          NEXKitBaseLogInfo(@"call view controller call error : %@", error.localizedDescription);
          if (error.code == NIMRemoteErrorCodeSignalResPeerPushOffline ||
              error.code == NIMRemoteErrorCodeSignalResPeerNIMOffline) {
            return;
          } else {
            [weakSelf destroy];
          }
          [weakSelf.preiousWindow ne_makeToast:error.localizedDescription];
        }
      }];
}

#pragma mark - UI

- (void)setupUI {
  if (self.view.frame.size.height < 600) {
    self.factor = 0.5;
  }

  CGSize buttonSize = CGSizeMake(75, 103);
  CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
  CGFloat topButtonOffset = statusHeight + 20;

  self.blurImage = [[UIImageView alloc] init];
  self.blurImage.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:self.blurImage];
  [NSLayoutConstraint activateConstraints:@[
    [self.blurImage.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
    [self.blurImage.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
    [self.blurImage.topAnchor constraintEqualToAnchor:self.view.topAnchor],
    [self.blurImage.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
  ]];

  if (self.callParam.remoteAvatar.length <= 0) {
    UIView *cover = [self getDefaultHeaderView:self.callParam.remoteUserAccid
                                          font:[UIFont systemFontOfSize:200]
                                      showName:self.callParam.remoteShowName];
    [self.blurImage addSubview:cover];
    [NSLayoutConstraint activateConstraints:@[
      [cover.leftAnchor constraintEqualToAnchor:self.blurImage.leftAnchor],
      [cover.rightAnchor constraintEqualToAnchor:self.blurImage.rightAnchor],
      [cover.topAnchor constraintEqualToAnchor:self.blurImage.topAnchor],
      [cover.bottomAnchor constraintEqualToAnchor:self.blurImage.bottomAnchor]
    ]];
  }

  self.toolBar = [[UIToolbar alloc] initWithFrame:self.view.bounds];
  self.toolBar.barStyle = UIBarStyleBlackOpaque;
  [self.blurImage addSubview:self.toolBar];

  [self setupChildController];

  if (self.callParam.enableFloatingWindow == YES) {
    [self.view addSubview:self.smallButton];
    [NSLayoutConstraint activateConstraints:@[
      [self.smallButton.topAnchor constraintEqualToAnchor:self.view.topAnchor
                                                 constant:topButtonOffset],
      [self.smallButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20],
      [self.smallButton.widthAnchor constraintEqualToConstant:40],
      [self.smallButton.heightAnchor constraintEqualToConstant:40]
    ]];

    [self.view addSubview:self.switchCameraBtn];
    self.switchCameraLeftToSmallConstraint =
        [self.switchCameraBtn.leftAnchor constraintEqualToAnchor:self.smallButton.rightAnchor
                                                        constant:10];
    self.switchCameraLeftToViewConstraint =
        [self.switchCameraBtn.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20];
    self.switchCameraTopConstraint =
        [self.switchCameraBtn.topAnchor constraintEqualToAnchor:self.view.topAnchor
                                                       constant:topButtonOffset];
    [NSLayoutConstraint activateConstraints:@[
      self.switchCameraTopConstraint,
      self.switchCameraLeftToSmallConstraint,
      [self.switchCameraBtn.heightAnchor constraintEqualToConstant:40],
      [self.switchCameraBtn.widthAnchor constraintEqualToConstant:40]
    ]];

  } else {
    [self.view addSubview:self.switchCameraBtn];
    self.switchCameraTopConstraint =
        [self.switchCameraBtn.topAnchor constraintEqualToAnchor:self.view.topAnchor
                                                       constant:topButtonOffset];
    self.switchCameraLeftToViewConstraint =
        [self.switchCameraBtn.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20];
    [NSLayoutConstraint activateConstraints:@[
      self.switchCameraTopConstraint,
      self.switchCameraLeftToViewConstraint,
      [self.switchCameraBtn.heightAnchor constraintEqualToConstant:40],
      [self.switchCameraBtn.widthAnchor constraintEqualToConstant:40]
    ]];
  }

  [self.view addSubview:self.operationView];
  [NSLayoutConstraint activateConstraints:@[
    [self.operationView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
    [self.operationView.heightAnchor constraintEqualToConstant:60],
    [self.operationView.widthAnchor constraintEqualToConstant:self.view.frame.size.width * 0.8],
    [self.operationView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor
                                                    constant:-50.0 * self.factor]
  ]];

  [self.singleToGroupCoordinator installInviteEntryAboveOperationView:self.operationView];

  // 添加 ASR 字幕视图
  [self.view addSubview:self.aiSubtitleView];
  [NSLayoutConstraint activateConstraints:@[
    [self.aiSubtitleView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
    [self.aiSubtitleView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
    [self.aiSubtitleView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
    [self.aiSubtitleView.bottomAnchor constraintEqualToAnchor:self.operationView.topAnchor
                                                     constant:-10]
  ]];

  /// 未接通状态下的音视频切换按钮
  self.mediaSwitchBtn = [[NECustomButton alloc] init];
  self.mediaSwitchBtn.maskBtn.accessibilityIdentifier = @"inCallSwitch";

  [self.view addSubview:self.mediaSwitchBtn];
  [NSLayoutConstraint activateConstraints:@[
    [self.mediaSwitchBtn.centerXAnchor constraintEqualToAnchor:self.operationView.centerXAnchor],
    [self.mediaSwitchBtn.bottomAnchor constraintEqualToAnchor:self.operationView.topAnchor
                                                     constant:-150 * self.factor],
    [self.mediaSwitchBtn.heightAnchor constraintEqualToConstant:buttonSize.height],
    [self.mediaSwitchBtn.widthAnchor constraintEqualToConstant:buttonSize.width]
  ]];

  self.mediaSwitchBtn.hidden = YES;

  [self.mediaSwitchBtn.maskBtn addTarget:self
                                  action:@selector(mediaClick:)
                        forControlEvents:UIControlEventTouchUpInside];
  [self.singleToGroupCoordinator configureControlsWithOperationView:self.operationView
                                                  mediaSwitchButton:self.mediaSwitchBtn
                                                     aiSubtitleView:self.aiSubtitleView];

  [self.view addSubview:self.timerLabel];
  [NSLayoutConstraint activateConstraints:@[
    [self.timerLabel.centerYAnchor constraintEqualToAnchor:self.switchCameraBtn.centerYAnchor],
    [self.timerLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor]
  ]];
}

#pragma mark - inner function

- (void)setCallingTypeSwith:(BOOL)show {
  if (self.callParam.multiCallInvite == YES) {
    self.mediaSwitchBtn.hidden = YES;
    return;
  }
  if (show == YES && self.config.showCallingSwitchCallType == YES) {
    if ([self isSupportAutoJoinWhenCalled] == YES) {
      self.mediaSwitchBtn.hidden = NO;
    } else {
      self.mediaSwitchBtn.hidden = YES;
    }
  } else {
    self.mediaSwitchBtn.hidden = YES;
  }
}

- (void)setupChildController {
  if (self.callParam.isCaller == YES) {
    [self addChildViewController:self.videoCallingController];
    [self.view addSubview:self.videoCallingController.view];
    [self addChildViewController:self.audioCallingController];
    [self.view addSubview:self.audioCallingController.view];
  } else {
    [self addChildViewController:self.calledController];
    [self.view addSubview:self.calledController.view];
  }

  [self addChildViewController:self.audioInCallController];
  [self.view addSubview:self.audioInCallController.view];
  [self addChildViewController:self.videoInCallController];
  [self.view addSubview:self.videoInCallController.view];
  [self.singleToGroupCoordinator installMultiController];
}

- (void)setSwitchAudioStyle {
  self.mediaSwitchBtn.imageView.image = [UIImage imageNamed:@"switch_audio"
                                                   inBundle:self.bundle
                              compatibleWithTraitCollection:nil];
  self.mediaSwitchBtn.titleLabel.text = [NECallKitUtil localizableWithKey:@"switch_to_audio"];
  self.mediaSwitchBtn.tag = NERtcCallTypeAudio;
  [self showVideoView];
  [self setUrl:self.callParam.remoteAvatar withPlaceholder:@"avator"];
  [self.stateUIController refreshUI];
}

- (void)setSwitchVideoStyle {
  self.mediaSwitchBtn.imageView.image = [UIImage imageNamed:@"switch_video"
                                                   inBundle:self.bundle
                              compatibleWithTraitCollection:nil];
  self.mediaSwitchBtn.titleLabel.text = [NECallKitUtil localizableWithKey:@"switch_to_video"];
  self.mediaSwitchBtn.tag = NERtcCallTypeVideo;
  [self hideVideoView];
  [self setUrl:self.callParam.remoteAvatar withPlaceholder:@"avator"];
  [self.stateUIController refreshUI];
}

- (void)updateUIonStatus:(NERtcCallStatus)status {
  switch (status) {
    case NERtcCallStatusCalling: {
      [self setCallingTypeSwith:YES];
      self.operationView.hidden = YES;
      self.aiSubtitleView.hidden = YES;
      self.stateUIController.view.hidden = YES;
      if (self.callParam.callType == NECallTypeVideo) {
        self.stateUIController = self.videoCallingController;
        [self.videoCallingController refreshUI];
        [self setSwitchAudioStyle];

      } else {
        self.stateUIController = self.audioCallingController;
        [self setSwitchVideoStyle];
      }
      self.stateUIController.view.hidden = NO;

    } break;
    case NERtcCallStatusCalled: {
      [self setCallingTypeSwith:YES];
      self.operationView.hidden = YES;
      self.aiSubtitleView.hidden = YES;
      self.stateUIController.view.hidden = YES;
      self.stateUIController = self.calledController;
      self.stateUIController.view.hidden = NO;
      [self.calledController refreshUI];
      self.calledController.rejectBtn.userInteractionEnabled = YES;
      self.calledController.acceptBtn.userInteractionEnabled = YES;
      if (self.callParam.callType == NECallTypeVideo) {
        self.calledController.acceptBtn.imageView.image = [UIImage imageNamed:@"call_accept_video"
                                                                     inBundle:self.bundle
                                                compatibleWithTraitCollection:nil];
        self.mediaSwitchBtn.imageView.image = [UIImage imageNamed:@"switch_audio"
                                                         inBundle:self.bundle
                                    compatibleWithTraitCollection:nil];
        self.mediaSwitchBtn.titleLabel.text = [NECallKitUtil localizableWithKey:@"switch_to_audio"];
        [self setSwitchAudioStyle];
      } else {
        self.calledController.acceptBtn.imageView.image = [UIImage imageNamed:@"call_accept"
                                                                     inBundle:self.bundle
                                                compatibleWithTraitCollection:nil];
        self.mediaSwitchBtn.imageView.image = [UIImage imageNamed:@"switch_video"
                                                         inBundle:self.bundle
                                    compatibleWithTraitCollection:nil];
        self.mediaSwitchBtn.titleLabel.text = [NECallKitUtil localizableWithKey:@"switch_to_video"];
        [self setSwitchVideoStyle];
      }
      __weak typeof(self) weakSelf = self;
      [self.calledController checkCallePreview];
      [self.calledController.remoteBigAvatorView
          sd_setImageWithURL:[NSURL URLWithString:self.callParam.remoteAvatar]
                   completed:^(UIImage *_Nullable image, NSError *_Nullable error,
                               SDImageCacheType cacheType, NSURL *_Nullable imageURL) {
                     if (image == nil) {
                       image = [UIImage imageNamed:@"avator"
                                                inBundle:weakSelf.bundle
                           compatibleWithTraitCollection:nil];
                     }
                     if (weakSelf.callParam.isCaller == false &&
                         weakSelf.callParam.callType == NECallTypeVideo) {
                       [weakSelf.blurImage setHidden:NO];
                     }
                     weakSelf.blurImage.image = image;
                   }];

    } break;
    case NERtcCallStatusInCall: {
      [self setCallingTypeSwith:NO];
      self.operationView.hidden = NO;
      self.aiSubtitleView.hidden = NO;
      self.stateUIController.view.hidden = YES;
      self.calledController.rejectBtn.userInteractionEnabled = YES;
      self.calledController.acceptBtn.userInteractionEnabled = YES;
      self.smallButton.hidden = NO;
      self.smallButton.enabled = YES;
      self.smallButton.userInteractionEnabled = YES;
      if (self.callParam.callType == NECallTypeVideo) {
        self.stateUIController = self.videoInCallController;
        self.switchCameraBtn.hidden = NO;
        self.isRemoteMute = NO;
        self.videoInCallController.operationView.cameraBtn.selected = NO;
        self.videoInCallController.smallVideoView.imageView.hidden = YES;
        self.videoInCallController.bigVideoView.imageView.hidden = YES;
        [self.videoInCallController refreshUI];
        if (self.callParam.enableVideoToAudio == NO) {
          [self.operationView removeMediaBtn];
        }
      } else {
        [self.operationView changeAudioStyle];
        self.stateUIController = self.audioInCallController;
        self.switchCameraBtn.hidden = YES;
        if (self.callParam.enableAudioToVideo == NO) {
          [self.operationView removeMediaBtn];
        }
      }
      self.stateUIController.view.hidden = NO;

    } break;
    default:
      break;
  }
  self.status = status;
  if (status == NERtcCallStatusInCall && [[NECallEngine sharedInstance] isInMultiCall]) {
    [self enterSingleToGroupModeWithMembers:[[NECallEngine sharedInstance] currentMembers]];
  } else if (status != NERtcCallStatusInCall) {
    [self.singleToGroupCoordinator hideMultiController];
  }
  [self refreshInviteMembersButtonVisibility];
  [self refreshSingleToGroupTopButtons];
}

- (void)showVideoView {
  if (self.status == NERtcCallStatusCalling) {
    [[NECallEngine sharedInstance]
        setupLocalView:self.videoCallingController.bigVideoView.videoView];
  }
  if (self.status == NERtcCallStatusInCall) {
    [[NECallEngine sharedInstance]
        setupLocalView:self.videoInCallController.smallVideoView.videoView];
    [[NECallEngine sharedInstance]
        setupRemoteView:self.videoInCallController.bigVideoView.videoView];
    // 切回视频通话时摄像头自动开启，清空遗留的"关闭摄像头"文案
    self.videoInCallController.smallVideoView.titleLabel.text = @"";
    self.videoInCallController.bigVideoView.titleLabel.text = @"";
  }

  [[NECallEngine sharedInstance] muteLocalVideo:NO];
  [[NECallEngine sharedInstance] muteLocalAudio:NO];
  self.operationView.microPhone.selected = NO;
  self.operationView.cameraBtn.selected = NO;

  self.operationView.speakerBtn.selected = NO;
  self.operationView.microPhone.selected = NO;

  if (self.status != NERtcCallStatusCalling) {
    [[NERtcEngine sharedEngine] setLoudspeakerMode:YES];
  } else {
    [self setAudioOutputToSpeaker];
  }

  self.isReceiver = NO;
  [[NERtcEngine sharedEngine] muteLocalAudio:NO];
}

- (void)hideVideoView {
  [[NECallEngine sharedInstance] setupLocalView:nil];
  [[NECallEngine sharedInstance] setupRemoteView:nil];
  self.operationView.speakerBtn.selected = YES;
  self.operationView.microPhone.selected = NO;
  // calling状态时候，只需要记flag，等connected 的时候 设置给 RTC
  if (self.status != NERtcCallStatusCalling) {
    [[NERtcEngine sharedEngine] setLoudspeakerMode:NO];
  }
  self.isReceiver = YES;
  self.audioCallingController.speakerBtn.imageView.highlighted = NO;
  [[NERtcEngine sharedEngine] muteLocalAudio:NO];
  if (self.callParam.enableVirtualBackground == YES && self.isClickVirtual == YES) {
    [[NERtcEngine sharedEngine] enableVirtualBackground:NO backData:nil];
  }
}

#pragma mark - event

- (void)cancelEvent:(UIButton *)button {
  __weak typeof(self) weakSelf = self;
  NSLog(@"cancel rtc");
  if ([[NetManager shareInstance] isClose] == YES) {
    [self destroy];
  }
  NEHangupParam *param = [[NEHangupParam alloc] init];
  [[NECallEngine sharedInstance] hangup:param
                             completion:^(NSError *_Nullable error) {
                               NSLog(@"cancel error %@", error);
                               button.enabled = YES;
                               [weakSelf destroy];
                             }];
}

- (void)rejectEvent:(UIButton *)button {
  if ([[NetManager shareInstance] isClose] == YES) {
    [self destroy];
  }
  self.calledController.acceptBtn.userInteractionEnabled = NO;
  __weak typeof(self) weakSelf = self;

  NEHangupParam *param = [[NEHangupParam alloc] init];
  [[NECallEngine sharedInstance] hangup:param
                             completion:^(NSError *_Nullable error) {
                               weakSelf.calledController.acceptBtn.userInteractionEnabled = YES;
                             }];
}

- (void)acceptEvent:(UIButton *)button {
  if ([[NetManager shareInstance] isClose] == YES) {
    [self.view ne_makeToast:[NECallKitUtil localizableWithKey:@"network_error"]];
    return;
  }

  __weak typeof(self) weakSelf = self;
  NECallType permissionCallType =
      [NECallKitUtil requiredPermissionCallTypeForCallType:self.callParam.callType
                                           multiCallInvite:self.callParam.multiCallInvite];
  [self requestPermissionForCallType:permissionCallType
                       endCallOnFail:YES
                           onGranted:^{
                             [weakSelf acceptAfterPermissionGranted];
                           }];
}

- (void)acceptAfterPermissionGranted {
  self.calledController.rejectBtn.userInteractionEnabled = NO;
  self.calledController.acceptBtn.userInteractionEnabled = NO;
  __weak typeof(self) weakSelf = self;
  [[NECallEngine sharedInstance]
      accept:^(NSError *_Nullable error, NECallInfo *_Nullable callInfo) {
        if (error) {
          if (error.code != 10420) {
            [weakSelf.preiousWindow
                ne_makeToast:[NSString stringWithFormat:@"%@ %@",
                                                        [NECallKitUtil
                                                            localizableWithKey:@"accept_failed"],
                                                        error.localizedDescription]];
          }
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                         dispatch_get_main_queue(), ^{
                           [weakSelf destroy];
                         });
        } else {
          if (weakSelf.callParam.multiCallInvite ||
              [[NECallEngine sharedInstance] isInMultiCall]) {
            [weakSelf updateUIonStatus:NERtcCallStatusInCall];
          }
          self.calledController.connectingLabel.hidden = NO;
          [self stopCurrentPlaying];
          [self stopTransferredBannerRingIfNeeded];
        }
      }];
}

- (void)showBannerAcceptConnectingStateIfNeeded {
  if (!self.incomingBannerAcceptConnecting) {
    return;
  }
  [self stopCurrentPlaying];
  [self stopTransferredBannerRingIfNeeded];
  self.calledController.rejectBtn.userInteractionEnabled = YES;
  self.calledController.rejectBtn.titleLabel.text = [NECallKitUtil localizableWithKey:@"call_cancel"];
  self.calledController.acceptBtn.userInteractionEnabled =
      [[self class] shouldEnableAcceptButtonForIncomingBannerAcceptConnecting];
  self.calledController.rejectBtn.hidden = NO;
  self.calledController.acceptBtn.hidden =
      ![[self class] shouldShowAcceptButtonForIncomingBannerAcceptConnecting];
  self.calledController.connectingLabel.hidden = NO;
  self.mediaSwitchBtn.hidden = YES;
}

+ (BOOL)shouldShowAcceptButtonForIncomingBannerAcceptConnecting {
  return YES;
}

+ (BOOL)shouldEnableAcceptButtonForIncomingBannerAcceptConnecting {
  return NO;
}

- (void)requestPermissionForCallType:(NECallType)callType
                       endCallOnFail:(BOOL)endCallOnFail
                           onGranted:(dispatch_block_t)onGranted {
  __weak typeof(self) weakSelf = self;
  [NECallKitUtil requestAuthorizationForCallType:callType
                             fromViewController:self.isSmallWindow
                                                    ? UIApplication.sharedApplication.keyWindow
                                                          .rootViewController
                                                    : self
                                     completion:^(BOOL granted, BOOL openSettings) {
                                       if (granted) {
                                         if (onGranted) {
                                           onGranted();
                                         }
                                         return;
                                       }
                                       NEXKitBaseLogInfo(@"call view controller permission denied "
                                                         @"callType:%ld openSettings:%d "
                                                         @"endCallOnFail:%d",
                                                         (long)callType, openSettings,
                                                         endCallOnFail);
                                       if (endCallOnFail) {
                                         [weakSelf hangupForPermissionDenied];
                                       }
                                     }];
}

- (void)hangupForPermissionDenied {
  [self stopCurrentPlaying];
  [self stopTransferredBannerRingIfNeeded];
  NEHangupParam *param = [[NEHangupParam alloc] init];
  [[NECallEngine sharedInstance] hangup:param
                             completion:^(__unused NSError *_Nullable error) {
                               [self destroy];
                             }];
}

- (void)switchCameraBtn:(UIButton *)button {
  [[NECallEngine sharedInstance] switchCamera];
  button.selected = !button.selected;
  if (button.isSelected == YES) {
    [[NERtcEngine sharedEngine] setParameters:@{kNERtcKeyVideoStartWithBackCamera : @YES}];
  } else {
    [[NERtcEngine sharedEngine] setParameters:@{kNERtcKeyVideoStartWithBackCamera : @NO}];
  }
}

- (void)microPhoneClick:(UIButton *)button {
  button.selected = !button.selected;
  [[NECallEngine sharedInstance] muteLocalAudio:button.selected];
}

- (void)cameraBtnClick:(UIButton *)button {
  button.selected = !button.selected;
  NSLog(@"mute video select : %d", button.selected);
  if ([self isSingleToGroupModeActive] && button.selected == NO &&
      self.callParam.useEnableLocalMute == NO) {
    [[NECallEngine sharedInstance] enableLocalVideo:YES];
  }
  if (self.callParam.useEnableLocalMute == YES) {
    NSLog(@"enableLocalVideo: %d", !button.selected);
    [[NECallEngine sharedInstance] enableLocalVideo:!button.selected];
  } else {
    [[NECallEngine sharedInstance] muteLocalVideo:button.selected];
  }
  NSString *currentUser = [[NIMSDK sharedSDK].v2LoginService getLoginUser];
  if (![self isSingleToGroupModeActive]) {
    [self changeDefaultImage:button.selected];
    [self cameraAvailble:!button.selected userId:currentUser];
  } else {
    [self.singleToGroupCoordinator updateMemberVideoMuted:button.selected userID:currentUser];
  }
}

- (void)hangupBtnClick:(UIButton *)button {
  if ([[NetManager shareInstance] isClose] == YES) {
    [self destroy];
  }
  NEHangupParam *param = [[NEHangupParam alloc] init];
  [[NECallEngine sharedInstance] hangup:param
                             completion:^(NSError *_Nullable error){
                             }];
}

- (void)microphoneBtnClick:(UIButton *)button {
  NSLog(@"micro phone btn click : %d", button.imageView.highlighted);
  self.audioCallingController.microphoneBtn.imageView.highlighted =
      !self.audioCallingController.microphoneBtn.imageView.highlighted;
  [[NECallEngine sharedInstance]
      muteLocalAudio:self.audioCallingController.microphoneBtn.imageView.highlighted];
  _operationView.microPhone.selected =
      self.audioCallingController.microphoneBtn.imageView.highlighted;
}

- (void)speakerBtnClick:(UIButton *)button {
  NSLog(@"speaker btn click : %d", self.audioCallingController.speakerBtn.imageView.highlighted);
  self.audioCallingController.speakerBtn.imageView.highlighted =
      !self.audioCallingController.speakerBtn.imageView.highlighted;
  _operationView.speakerBtn.selected =
      !self.audioCallingController.speakerBtn.imageView.highlighted;
  if (_operationView.speakerBtn.isSelected == YES) {
    [self setAudioOutputToReceiver];
  } else {
    [self setAudioOutputToSpeaker];
  }
}

- (void)virtualBackgroundBtnClick:(UIButton *)button {
  NSLog(@"virtualBackgroundBtnClick");
  button.selected = !button.selected;
  self.isClickVirtual = YES;

  if (button.selected) {
    NERtcVirtualBackgroundSource *source = [[NERtcVirtualBackgroundSource alloc] init];
    source.backgroundSourceType = kNERtcVirtualBackgroundBlur;
    source.blur_degree = kNERtcBlurHigh;
    [[NERtcEngine sharedEngine] enableVirtualBackground:YES backData:source];
  } else {
    [[NERtcEngine sharedEngine] enableVirtualBackground:NO backData:nil];
  }
}

- (void)operationSwitchClick:(UIButton *)btn {
  if ([self isSingleToGroupModeActive]) {
    [self showSingleToGroupSwitchUnsupportedToast];
    return;
  }
  if ([[NetManager shareInstance] isClose] == YES) {
    [self.view ne_makeToast:[NECallKitUtil localizableWithKey:@"network_error"]];
    return;
  }
  __weak typeof(self) weakSelf = self;
  btn.enabled = NO;
  NECallType type = self.callParam.callType == NECallTypeVideo ? NECallTypeAudio : NECallTypeVideo;
  void (^switchAction)(void) = ^{
    [weakSelf inviteSwitchCallType:type
                        completion:^(NSError *_Nullable error) {
                          btn.enabled = YES;
                          if (error == nil) {
                            NSLog(@"切换成功 : %lu", type);
                            NSLog(@"switch : %d", btn.selected);
                            if (type == NECallTypeVideo &&
                                [[NECallEngine sharedInstance] getCallConfig]
                                    .enableSwitchVideoConfirm) {
                              [weakSelf showBannerView];
                            } else if (type == NECallTypeAudio &&
                                       [[NECallEngine sharedInstance] getCallConfig]
                                           .enableSwitchAudioConfirm) {
                              [weakSelf showBannerView];
                            }
                          } else {
                            [weakSelf.view
                                ne_makeToast:[NSString stringWithFormat:@"%@: %@",
                                                                        [NECallKitUtil
                                                                            localizableWithKey:@"switch_error"],
                                                                        error]];
                          }
                        }];
  };

  if (type == NECallTypeVideo) {
    [self requestPermissionForCallType:type
                         endCallOnFail:YES
                             onGranted:switchAction];
    return;
  }
  switchAction();
}

- (void)inviteSwitchCallType:(NECallType)type completion:(void (^)(NSError *_Nullable))completion {

  NESwitchParam *param = [[NESwitchParam alloc] init];
  param.state = NECallSwitchStateInvite;
  param.callType = type;

  [[NECallEngine sharedInstance]
      switchCallType:param
          completion:^(NSError *_Nullable error) {
            if (completion) {
              completion(error);
            }
          }];
}

- (void)operationSpeakerClick:(UIButton *)btn {
  int ret = [NERtcEngine.sharedEngine setLoudspeakerMode:btn.selected];
  if (ret == 0) {
    btn.selected = !btn.selected;
  } else {
    [self.view ne_makeToast:[NECallKitUtil localizableWithKey:@"operation_failed"]];
  }
}

- (void)mediaClick:(UIButton *)btn {
  if ([self isSingleToGroupModeActive]) {
    [self showSingleToGroupSwitchUnsupportedToast];
    return;
  }
  if ([[NetManager shareInstance] isClose] == YES) {
    [self.view ne_makeToast:[NECallKitUtil localizableWithKey:@"network_error"]];
    return;
  }
  __weak typeof(self) weakSelf = self;
  self.mediaSwitchBtn.maskBtn.enabled = NO;

  NECallType type =
      weakSelf.callParam.callType == NECallTypeVideo ? NECallTypeAudio : NECallTypeVideo;
  void (^switchAction)(void) = ^{
    [weakSelf inviteSwitchCallType:type
                        completion:^(NSError *_Nullable error) {
                          weakSelf.mediaSwitchBtn.maskBtn.enabled = YES;
                          if (error == nil) {
                            if (type == NECallTypeVideo &&
                                [[NECallEngine sharedInstance] getCallConfig]
                                    .enableSwitchVideoConfirm) {
                              [weakSelf showBannerView];
                            } else if (type == NECallTypeAudio &&
                                       [[NECallEngine sharedInstance] getCallConfig]
                                           .enableSwitchAudioConfirm) {
                              [weakSelf showBannerView];
                            }
                          } else {
                            [weakSelf.view
                                ne_makeToast:[NSString stringWithFormat:@"%@ : %@",
                                                                        [NECallKitUtil
                                                                            localizableWithKey:@"switch_error"],
                                                                        error]];
                          }
                        }];
  };

  if (type == NECallTypeVideo) {
    [self requestPermissionForCallType:type
                         endCallOnFail:YES
                             onGranted:switchAction];
    return;
  }
  switchAction();
}

- (void)agreeSwitchCallType:(NECallType)type completion:(void (^)(NSError *_Nullable))completion {

  NESwitchParam *param = [[NESwitchParam alloc] init];
  param.state = NECallSwitchStateAgree;
  param.callType = type;

  [[NECallEngine sharedInstance]
      switchCallType:param
          completion:^(NSError *_Nullable error) {
            if (completion) {
              completion(error);
            }
          }];
}

- (void)onCallTypeChangeWithType:(NECallType)callType {
  NSLog(@"onCallTypeChange:");
  if (self.callParam.callType == callType) {
    return;
  }
  self.callParam.callType = callType;
  if (self.isSmallWindow == YES) {
    [[NERtcCallUIKit sharedInstance] changeSmallModeWithTyple:self.callParam.callType];
  }
  [self updateUIonStatus:self.status];

  if (self.status == NERtcCallStatusInCall) {
    switch (callType) {
      case NECallTypeAudio:
        NSLog(@"NERtcCallTypeAudio");
        [self.operationView changeAudioStyle];
        [self hideVideoView];
        break;
      case NECallTypeVideo:
        NSLog(@"NERtcCallTypeVideo");
        [self.operationView changeVideoStyle];
        [self showVideoView];
        break;
      default:
        break;
    }
    return;
  }

  switch (callType) {
    case NECallTypeAudio:
      if (self.callParam.isCaller == YES && self.status == NERtcCallStatusCalling) {
        [self setAudioOutputToReceiver];
      }
      [self.operationView changeAudioStyle];
      [self setSwitchVideoStyle];
      break;
    case NECallTypeVideo:
      [self.operationView changeVideoStyle];
      [self setSwitchAudioStyle];
      break;
    default:
      break;
  }
}

- (void)enterSingleToGroupModeWithMembers:(NSArray<NECallMemberInfo *> *)members {
  [self expireSwitchCallTypeInviteWithReason:@"enterSingleToGroupMode"];
  [self prepareForSingleToGroupFullScreenIfNeeded];
  [self syncSingleToGroupInitialMediaStateIfNeeded];
  [self syncSingleToGroupSpeakerStateIfNeeded];
  [self detachSingleCallVideoCanvasForSingleToGroupIfNeeded];
  [self.singleToGroupCoordinator enterModeWithMembers:members
                                             callType:self.callParam.callType
                                            stateView:self.stateUIController.view
                                               status:self.status
                                        isSmallWindow:self.isSmallWindow
                                       elapsedSeconds:self.timerCount];
  [self refreshSingleToGroupTopButtons];
}

- (void)refreshInviteMembersButtonVisibility {
  [self.singleToGroupCoordinator
      updateInviteEntryLayoutForMultiMode:[self isSingleToGroupModeActive]];
  [self.singleToGroupCoordinator updateInviteEntryWithStatus:self.status
                                               isSmallWindow:self.isSmallWindow];
}

- (BOOL)isSingleToGroupModeActive {
  return [[NECallEngine sharedInstance] isInMultiCall] ||
         self.singleToGroupCoordinator.hasEnteredSingleToGroupMode;
}

- (void)syncSingleToGroupInitialMediaStateIfNeeded {
  if (self.didSyncSingleToGroupInitialMediaState) {
    return;
  }
  self.didSyncSingleToGroupInitialMediaState = YES;
  NSString *currentUser = [NIMSDK.sharedSDK.v2LoginService getLoginUser];
  NECallInfo *callInfo = [[NECallEngine sharedInstance] getCallInfo];
  uint64_t currentUid = 0;
  uint64_t remoteUid = 0;
  if ([callInfo.callerInfo.accId isEqualToString:currentUser]) {
    currentUid = callInfo.callerInfo.uid;
    remoteUid = callInfo.calleeInfo.uid;
  } else if ([callInfo.calleeInfo.accId isEqualToString:currentUser]) {
    currentUid = callInfo.calleeInfo.uid;
    remoteUid = callInfo.callerInfo.uid;
  }
  BOOL localVideoMuted = self.callParam.callType == NECallTypeVideo
                              ? self.operationView.cameraBtn.selected
                              : YES;
  BOOL remoteVideoMuted = self.callParam.callType == NECallTypeVideo ? self.isRemoteMute : YES;
  self.operationView.cameraBtn.selected = localVideoMuted;
  NEXKitBaseLogInfo(@"SingleToGroup UI sync initial media before enter multi current:%@ "
                    @"localUid:%llu localVideoMuted:%d localAudioMuted:%d remote:%@ "
                    @"remoteUid:%llu remoteVideoMuted:%d",
                    currentUser, (unsigned long long)currentUid,
                    localVideoMuted, self.operationView.microPhone.selected,
                    self.callParam.remoteUserAccid, (unsigned long long)remoteUid, remoteVideoMuted);
  [self.singleToGroupCoordinator syncInitialMediaStateWithCurrentUser:currentUser
                                                           remoteUser:self.callParam.remoteUserAccid
                                                     currentUserRtcUid:currentUid
                                                         remoteRtcUid:remoteUid
                                                     currentVideoMuted:localVideoMuted
                                                       remoteVideoMuted:remoteVideoMuted
                                                     currentAudioMuted:self.operationView.microPhone.selected];
}

- (void)syncSingleToGroupSpeakerStateIfNeeded {
  if (self.didSyncSingleToGroupSpeakerState || self.callParam.multiCallInvite == NO) {
    return;
  }
  self.didSyncSingleToGroupSpeakerState = YES;
  int ret = [[NERtcEngine sharedEngine] setLoudspeakerMode:YES];
  self.operationView.speakerBtn.selected = NO;  // selected=NO 对应扬声器图标
  self.isReceiver = NO;
  NEXKitBaseLogInfo(@"SingleToGroup UI enable speaker for invitee ret:%d", ret);
}

- (void)detachSingleCallVideoCanvasForSingleToGroupIfNeeded {
  if (self.didDetachSingleCallVideoCanvasForSingleToGroup ||
      self.callParam.callType != NECallTypeVideo) {
    return;
  }
  // F013 多人页由宫格 cell 独立绑定 RTC canvas。进入多人前先释放 1v1 大小画面，
  // 避免后续成员刷新把本端或远端视频继续渲染到已隐藏的 1v1 view。
  [[NECallEngine sharedInstance] setupLocalView:nil];
  [[NECallEngine sharedInstance] setupRemoteView:nil];
  self.didDetachSingleCallVideoCanvasForSingleToGroup = YES;
  NEXKitBaseLogInfo(@"SingleToGroup UI detach 1v1 video canvas before entering multi grid "
                    @"callType:%ld localViewDetached:1 remoteViewDetached:1",
                    (long)self.callParam.callType);
}

- (void)showSingleToGroupSwitchUnsupportedToast {
  NEXKitBaseLogInfo(@"SingleToGroup UI switch call type ignored in multi call.");
  [self.view ne_makeToast:[NECallKitUtil
                              localizableWithKey:
                                  @"single_to_group_switch_call_type_unsupported"]];
}

- (void)refreshSingleToGroupTopButtons {
  if (![self isSingleToGroupModeActive] || self.status != NERtcCallStatusInCall) {
    return;
  }
  self.timerLabel.hidden = YES;
  self.smallButton.hidden = YES;
  self.smallButton.enabled = NO;
  self.smallButton.userInteractionEnabled = NO;
  self.switchCameraBtn.hidden = NO;
  self.switchCameraTopConstraint.constant = 56;
  if (self.switchCameraLeftToSmallConstraint != nil) {
    self.switchCameraLeftToSmallConstraint.active = NO;
  }
  if (self.switchCameraLeftToViewConstraint != nil) {
    self.switchCameraLeftToViewConstraint.active = YES;
    self.switchCameraLeftToViewConstraint.constant = 12;
  }
  [self.singleToGroupCoordinator updateInviteEntryLayoutForMultiMode:YES];
}

- (void)prepareForSingleToGroupFullScreenIfNeeded {
  if (self.restoringSingleToGroupFullScreen) {
    return;
  }
  if (self.stopPipSEL != nil) {
    NEXKitBaseLogInfo(@"SingleToGroup UI stop PiP for single-to-group.");
    [NERtcCallUIKit.sharedInstance performSelector:self.stopPipSEL];
  }
  if (self.isSmallWindow == YES) {
    NEXKitBaseLogInfo(@"SingleToGroup UI restore single-to-group full screen.");
    self.restoringSingleToGroupFullScreen = YES;
    [self changeToNormal];
    self.restoringSingleToGroupFullScreen = NO;
  }
}

- (BOOL)shouldPrepareForSingleToGroupWithMembers:(NSArray<NECallMemberInfo *> *)members {
  if ([[NECallEngine sharedInstance] isInMultiCall] ||
      self.singleToGroupCoordinator.hasEnteredSingleToGroupMode || members.count >= 3) {
    return YES;
  }
  for (NECallMemberInfo *member in members) {
    if (member.state == NECallMemberStateWaiting) {
      return YES;
    }
  }
  return NO;
}

- (void)syncInCallStatusForSingleToGroupIfNeeded {
  if (self.status == NERtcCallStatusInCall ||
      [NECallEngine sharedInstance].callStatus != NERtcCallStatusInCall ||
      ![[NECallEngine sharedInstance] isInMultiCall]) {
    return;
  }
  NEXKitBaseLogInfo(@"SingleToGroup UI sync stale status to InCall current:%ld",
                    (long)self.status);
  [self updateUIonStatus:NERtcCallStatusInCall];
  [self stopCurrentPlaying];
  [self stopTransferredBannerRingIfNeeded];
  [self startTimer];
}

#pragma mark -  call engine delegate

- (void)onVideoMuted:(BOOL)muted userID:(NSString *)userId {
  NSString *currentUser = [[NIMSDK sharedSDK].v2LoginService getLoginUser];
  if (![userId isEqualToString:currentUser]) {
    self.isRemoteMute = muted;
  }
  [self cameraAvailble:!muted userId:userId];
  if ([userId isEqualToString:currentUser]) {
    [self.singleToGroupCoordinator updateMemberVideoMuted:muted userID:userId];
  }
}

- (void)onVideoAvailable:(BOOL)available userID:(NSString *)userId {
  NSString *currentUser = [[NIMSDK sharedSDK].v2LoginService getLoginUser];
  if (![userId isEqualToString:currentUser]) {
    self.isRemoteMute = !available;
  }
  [self cameraAvailble:available userId:userId];
  if ([userId isEqualToString:currentUser]) {
    [self.singleToGroupCoordinator updateMemberVideoMuted:!available userID:userId];
  }
}

- (void)onCallConnected:(NECallInfo *)info {
  if (self.callParam.isCaller == YES) {
    [self setCurrentAudioOutputToRTC];
  }
  [self updateUIonStatus:NERtcCallStatusInCall];
  [self stopCurrentPlaying];
  [self stopTransferredBannerRingIfNeeded];
  [self startTimer];
}

- (void)onCallModeChanged:(NECallModeChangeInfo *)info {
  [self syncInCallStatusForSingleToGroupIfNeeded];
  if (info.newMode == NECallModeMulti) {
    [self expireSwitchCallTypeInviteWithReason:@"onCallModeChanged"];
    [self syncTimerCountWithCallStartTime];
    [self prepareForSingleToGroupFullScreenIfNeeded];
    [self syncSingleToGroupInitialMediaStateIfNeeded];
    [self syncSingleToGroupSpeakerStateIfNeeded];
    [self detachSingleCallVideoCanvasForSingleToGroupIfNeeded];
  }
  [self.singleToGroupCoordinator handleModeChanged:info
                                          callType:self.callParam.callType
                                         stateView:self.stateUIController.view
                                            status:self.status
                                     isSmallWindow:self.isSmallWindow
                                    elapsedSeconds:self.timerCount];
  [self refreshSingleToGroupTopButtons];
}

- (void)onCallMembersChanged:(NECallMemberChangeInfo *)info {
  NSArray<NECallMemberInfo *> *members =
      info.members ?: [[NECallEngine sharedInstance] currentMembers];
  BOOL shouldPrepare = [self shouldPrepareForSingleToGroupWithMembers:members];
  if (shouldPrepare) {
    [self expireSwitchCallTypeInviteWithReason:@"onCallMembersChanged"];
    [self syncInCallStatusForSingleToGroupIfNeeded];
    [self syncTimerCountWithCallStartTime];
  }
  if (shouldPrepare) {
    [self prepareForSingleToGroupFullScreenIfNeeded];
    [self syncSingleToGroupInitialMediaStateIfNeeded];
    [self syncSingleToGroupSpeakerStateIfNeeded];
    [self detachSingleCallVideoCanvasForSingleToGroupIfNeeded];
  }
  [self.singleToGroupCoordinator handleMembersChanged:info
                                            callType:self.callParam.callType
                                           stateView:self.stateUIController.view
                                              status:self.status
                                       isSmallWindow:self.isSmallWindow
                                      elapsedSeconds:self.timerCount];
  [self refreshSingleToGroupTopButtons];
}

- (void)onCallInviteStateChanged:(NSArray<NECallInviteStateInfo *> *)infos {
  NSArray<NECallMemberInfo *> *members = [[NECallEngine sharedInstance] currentMembers];
  BOOL shouldPrepare = [self shouldPrepareForSingleToGroupWithMembers:members];
  if (shouldPrepare) {
    [self expireSwitchCallTypeInviteWithReason:@"onCallInviteStateChanged"];
    [self syncInCallStatusForSingleToGroupIfNeeded];
  }
  if (shouldPrepare) {
    [self prepareForSingleToGroupFullScreenIfNeeded];
    [self syncSingleToGroupInitialMediaStateIfNeeded];
    [self syncSingleToGroupSpeakerStateIfNeeded];
    [self detachSingleCallVideoCanvasForSingleToGroupIfNeeded];
  }
  [self.singleToGroupCoordinator handleInviteStateChanged:infos
                                                 callType:self.callParam.callType
                                                stateView:self.stateUIController.view
                                                   status:self.status
                                            isSmallWindow:self.isSmallWindow
                                           elapsedSeconds:self.timerCount];
  [self refreshSingleToGroupTopButtons];
}

- (void)onCallEnd:(NECallEndInfo *)info {
  switch (info.reasonCode) {
    case TerminalCodeTimeOut:
      if (self.callParam.isCaller == YES) {
        [self playRingWithType:CRTNoResponseRing];
      }
      if ([[NetManager shareInstance] isClose] == YES) {
        [self destroy];
        return;
      }
      if (self.callParam.isCaller == YES) {
        [self showToastWithContent:[NECallKitUtil localizableWithKey:@"remote_timeout"]];
      }
      break;
    case TerminalCodeBusy:
      [self showToastWithContent:[NECallKitUtil localizableWithKey:@"remote_busy"]];
      [self playRingWithType:CRTBusyRing];
      break;

    case TerminalCalleeCancel:
      [self showToastWithContent:[NECallKitUtil localizableWithKey:@"remote_cancel"]];
      break;

    case TerminalCallerRejcted:
      [self showToastWithContent:[NECallKitUtil localizableWithKey:@"remote_reject"]];
      [self playRingWithType:CRTRejectRing];
      break;

    case TerminalOtherRejected:
      [self.preiousWindow ne_makeToast:[NECallKitUtil localizableWithKey:@"other_client_reject"]];
      break;

    case TerminalOtherAccepted:
      [self.preiousWindow ne_makeToast:[NECallKitUtil localizableWithKey:@"other_client_accept"]];
      break;

    case TerminalCallerCancel:

      return;

    default:
      break;
  }
  NEXKitBaseLogInfo(@"call view controller oncallend : %@", [info yx_modelToJSONString]);
  [self destroy];
}

- (void)stopTransferredBannerRingIfNeeded {
  if (self.ringAlreadyPlaying) {
    [[NERingPlayerManager shareInstance] stopCurrentPlaying];
    self.ringAlreadyPlaying = NO;
  }
}

- (void)onCallTypeChange:(NECallTypeChangeInfo *)info {
  if ([self isSingleToGroupModeActive]) {
    [self expireSwitchCallTypeInviteWithReason:@"onCallTypeChangeInMulti"];
    NEXKitBaseLogInfo(@"SingleToGroup UI ignore onCallTypeChange in multi call: %@",
                      [info yx_modelToJSONString]);
    return;
  }
  NSLog(@"V2 onCallTypeChange : %@", [info yx_modelToJSONString]);
  switch (info.state) {
    case NECallSwitchStateAgree:
      [self hideBannerView];
      [self clearSwitchCallTypeInviteWithReason:@"switchAgree"];
      [self onCallTypeChangeWithType:info.callType];
      break;
    case NECallSwitchStateInvite: {
      NSInteger revision = [self recordSwitchCallTypeInvite:info.callType];
      if (self.alert != nil || self.switchCallTypeAlertDismissing) {
        NSLog(@"alert is showing");
        return;
      }
      UIAlertController *alert = [UIAlertController
          alertControllerWithTitle:[NECallKitUtil localizableWithKey:@"permission"]
                           message:info.callType == NECallTypeVideo
                                       ? [NECallKitUtil localizableWithKey:@"audio_to_video"]
                                       : [NECallKitUtil localizableWithKey:@"video_to_audio"]
                    preferredStyle:UIAlertControllerStyleAlert];
      self.alert = alert;
      __weak typeof(self) weakSelf = self;

      UIAlertAction *rejectAction = [UIAlertAction
          actionWithTitle:[NECallKitUtil localizableWithKey:@"reject"]
                    style:UIAlertActionStyleDefault
                  handler:^(UIAlertAction *_Nonnull action) {
                    if (![weakSelf isCurrentSwitchCallTypeInvite:info.callType
                                                        revision:revision]) {
                      [weakSelf showSwitchCallTypeRequestExpiredToast];
                      return;
                    }
                    NESwitchParam *param = [[NESwitchParam alloc] init];
                    param.callType = info.callType;
                    param.state = NECallSwitchStateReject;
                    [[NECallEngine sharedInstance]
                        switchCallType:param
                            completion:^(NSError *_Nullable error) {
                              if (error) {
                                [weakSelf.view ne_makeToast:error.localizedDescription];
                              }
                            }];
                    [weakSelf clearSwitchCallTypeInviteWithReason:@"rejectSwitchInvite"];
                  }];
      UIAlertAction *agreeAction = [UIAlertAction
          actionWithTitle:[NECallKitUtil localizableWithKey:@"agree"]
                    style:UIAlertActionStyleDefault
                  handler:^(UIAlertAction *_Nonnull action) {
                    void (^agreeSwitchAction)(void) = ^{
                      if (![weakSelf isCurrentSwitchCallTypeInvite:info.callType
                                                          revision:revision]) {
                        [weakSelf showSwitchCallTypeRequestExpiredToast];
                        return;
                      }
                      [weakSelf agreeSwitchCallType:info.callType
                                         completion:^(NSError *_Nullable error) {
                                           [weakSelf
                                               clearSwitchCallTypeInviteWithReason:@"agreeSwitchInvite"];
                                           [weakSelf onCallTypeChangeWithType:info.callType];
                                           if (error) {
                                             [weakSelf.view ne_makeToast:error.localizedDescription];
                                           } else {
                                             if (weakSelf.createPipSEL != nil &&
                                                 weakSelf.status == NECallStatusInCall) {
                                               if (info.callType == NECallTypeVideo) {
                                                 [NERtcCallUIKit.sharedInstance
                                                     performSelector:weakSelf.createPipSEL];
                                               } else {
                                                 [NERtcCallUIKit.sharedInstance
                                                     performSelector:weakSelf.stopPipSEL];
                                               }
                                             }
                                           }
                                         }];
                    };
                    if (info.callType == NECallTypeVideo) {
                      [weakSelf requestPermissionForCallType:info.callType
                                               endCallOnFail:YES
                                                   onGranted:agreeSwitchAction];
                    } else {
                      agreeSwitchAction();
                    }
                  }];

      [alert addAction:rejectAction];
      [alert addAction:agreeAction];
      if (self.isSmallWindow == YES) {
        UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
        self.switchCallTypeAlertPresenter = keyWindow.rootViewController;
        [self.switchCallTypeAlertPresenter presentViewController:alert animated:YES completion:nil];
      } else {
        self.switchCallTypeAlertPresenter = self;
        [self presentViewController:alert animated:YES completion:nil];
      }
      NSLog(@"NERtcSwitchStateInvite : %ld", info.callType);

    }

    break;
    case NECallSwitchStateReject:
      [self hideBannerView];
      [self clearSwitchCallTypeInviteWithReason:@"switchReject"];
      [self.view ne_makeToast:[NECallKitUtil localizableWithKey:@"reject_tip"]];
      break;
    default:
      break;
  }
}

#pragma mark - private mothed

- (NSInteger)recordSwitchCallTypeInvite:(NECallType)callType {
  if (!self.hasPendingSwitchCallTypeInvite || self.pendingSwitchCallType != callType) {
    self.switchCallTypeInviteRevision += 1;
  }
  self.hasPendingSwitchCallTypeInvite = YES;
  self.pendingSwitchCallType = callType;
  return self.switchCallTypeInviteRevision;
}

- (BOOL)isCurrentSwitchCallTypeInvite:(NECallType)callType revision:(NSInteger)revision {
  return self.hasPendingSwitchCallTypeInvite &&
         self.pendingSwitchCallType == callType &&
         self.switchCallTypeInviteRevision == revision;
}

- (void)clearSwitchCallTypeInviteWithReason:(NSString *)reason {
  if (!self.hasPendingSwitchCallTypeInvite) {
    return;
  }
  self.hasPendingSwitchCallTypeInvite = NO;
  self.switchCallTypeInviteRevision += 1;
  NEXKitBaseLogInfo(@"SingleToGroup UI clear switch invite reason:%@ revision:%ld",
                    reason, (long)self.switchCallTypeInviteRevision);
}

- (void)expireSwitchCallTypeInviteWithReason:(NSString *)reason {
  BOOL hadPendingInvite = self.hasPendingSwitchCallTypeInvite || self.alert != nil;
  [self clearSwitchCallTypeInviteWithReason:reason];
  [self dismissSwitchCallTypeAlertIfNeeded];
  [self hideBannerView];
  if (hadPendingInvite) {
    NEXKitBaseLogInfo(@"SingleToGroup UI expire switch invite reason:%@", reason);
  }
}

- (void)dismissSwitchCallTypeAlertIfNeeded {
  [self dismissSwitchCallTypeAlertIfNeededWithCompletion:nil];
}

- (void)dismissSwitchCallTypeAlertIfNeededWithCompletion:(dispatch_block_t)completion {
  if (self.alert == nil && !self.switchCallTypeAlertDismissing) {
    if (completion) {
      completion();
    }
    return;
  }
  self.alert = nil;
  self.switchCallTypeAlertDismissing = YES;
  UIViewController *presenter = self.switchCallTypeAlertPresenter ?: self;
  self.switchCallTypeAlertPresenter = nil;
  [NECallKitUtil performAfterPresentationSettledInViewController:presenter
                                                      retryCount:6
                                                      completion:^{
                                                        self.switchCallTypeAlertDismissing = NO;
                                                        if (completion) {
                                                          completion();
                                                        }
                                                      }];
}

- (void)showSwitchCallTypeRequestExpiredToast {
  [self.view ne_makeToast:[NECallKitUtil localizableWithKey:@"switch_call_type_request_expired"]];
}

- (void)cameraAvailble:(BOOL)available userId:(NSString *)userId {
  if ([self isSingleToGroupModeActive]) {
    // 多人页使用独立宫格 canvas；这里不能再刷新 1v1 大小画面，避免 RTC 画布被绑回隐藏视图。
    return;
  }
  if (!self.isSmallWindow) {
    [self.videoInCallController refreshVideoView];
  }
  if ([self.videoInCallController.bigVideoView.userID isEqualToString:userId]) {
    self.videoInCallController.bigVideoView.coverView.hidden = available;
    [self changeTitle:!available videoView:self.videoInCallController.bigVideoView];
  }

  if ([self.videoInCallController.smallVideoView.userID isEqualToString:userId]) {
    self.videoInCallController.smallVideoView.coverView.hidden = available;
    [self changeTitle:!available videoView:self.videoInCallController.smallVideoView];
  }

  if (self.showMyBigView) {
    [self changeRemoteMute:self.isRemoteMute videoView:self.stateUIController.smallVideoView];
  } else {
    [self changeRemoteMute:self.isRemoteMute videoView:self.stateUIController.bigVideoView];
  }
  if ([userId isEqualToString:self.callParam.remoteUserAccid] && self.isSmallWindow == YES &&
      self.callParam.callType == NECallTypeVideo) {
    self.coverView.hidden = available;
  }
}

- (void)setUrl:(NSString *)url withPlaceholder:(NSString *)holder {
  __weak typeof(self) weakSelf = self;
  UIImageView *remoteAvatorView = nil;
  if (self.callParam.callType == NECallTypeVideo) {
    remoteAvatorView = self.videoCallingController.remoteAvatorView;
  } else {
    remoteAvatorView = self.calledController.remoteBigAvatorView;
  }
  [remoteAvatorView sd_setImageWithURL:[NSURL URLWithString:url]
                             completed:^(UIImage *_Nullable image, NSError *_Nullable error,
                                         SDImageCacheType cacheType, NSURL *_Nullable imageURL) {
                               if (image == nil) {
                                 image = [UIImage imageNamed:holder
                                                          inBundle:weakSelf.bundle
                                     compatibleWithTraitCollection:nil];
                               }
                               if (weakSelf.callParam.isCaller == false &&
                                   weakSelf.callParam.callType == NECallTypeVideo) {
                                 [weakSelf.blurImage setHidden:NO];
                               }
                               weakSelf.blurImage.image = image;
                             }];
}

- (void)startTimer {
  if (self.timer != nil) {
    return;
  }
  [self syncTimerCountWithCallStartTime];
  if (self.timerLabel.hidden == YES) {
    self.timerLabel.hidden = NO;
  }
  NSString *timeString = [self timeFormatted:self.timerCount];
  if (![self isSingleToGroupModeActive]) {
    self.timerLabel.text = timeString;
  }
  self.audioSmallViewTimerLabel.text = timeString;
  self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                target:self
                                              selector:@selector(figureTimer)
                                              userInfo:nil
                                               repeats:YES];
}

- (BOOL)syncTimerCountWithCallStartTime {
  NECallStateManager *stateManager = [NECallStateManager sharedInstance];
  if (stateManager.callStartTime == nil || self.timerCount <= 0) {
    [stateManager syncCurrentState];
  }
  NSDate *callStartTime = stateManager.callStartTime;
  if (callStartTime == nil) {
    return NO;
  }
  NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:callStartTime];
  int elapsedSeconds = MAX((int)elapsed, 0);
  if (elapsedSeconds > self.timerCount) {
    self.timerCount = elapsedSeconds;
    NEXKitBaseLogInfo(@"call view sync timer from callStartTime elapsed:%d", elapsedSeconds);
    return YES;
  }
  return elapsedSeconds == self.timerCount;
}

- (void)figureTimer {
  if (![self syncTimerCountWithCallStartTime]) {
    self.timerCount++;
  }
  NSString *timeString = [self timeFormatted:self.timerCount];
  if (![self isSingleToGroupModeActive]) {
    self.timerLabel.text = timeString;
  }
  self.audioSmallViewTimerLabel.text = timeString;
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

- (NSString *)getInviteText {
  return [NECallKitUtil incomingInviteTextWithCallType:self.callParam.callType
                                      multiCallInvite:self.callParam.multiCallInvite];
}

- (void)hideBannerView {
  self.bannerView.hidden = YES;
}

- (void)showBannerView {
  self.bannerView.hidden = NO;
}

- (void)changeToSmall {
  if ([self isSingleToGroupModeActive]) {
    NEXKitBaseLogInfo(@"SingleToGroup UI ignore small window action in multi call.");
    [self refreshSingleToGroupTopButtons];
    return;
  }
  [super changeToSmall];
  [self.singleToGroupCoordinator hideInviteEntry];
}

- (void)changeToNormal {
  [super changeToNormal];
  if ([[NECallEngine sharedInstance] isInMultiCall] &&
      self.restoringSingleToGroupFullScreen == NO) {
    [self enterSingleToGroupModeWithMembers:[[NECallEngine sharedInstance] currentMembers]];
  } else if (self.callParam.callType == NECallTypeVideo) {
    [self.videoInCallController refreshVideoView];
  }
  [self refreshInviteMembersButtonVisibility];
  [self refreshSingleToGroupTopButtons];
}

#pragma mark - destroy
- (void)destroy {
  [self stopCurrentPlaying];
  [self stopTransferredBannerRingIfNeeded];
  [self dismissSwitchCallTypeAlertIfNeededWithCompletion:^{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCallKitDismissNoti object:nil];
  }];
  [[NECallEngine sharedInstance] removeCallDelegate:self];

  if (self.timer != nil) {
    [self.timer invalidate];
    self.timer = nil;
  }
  [self stopCurrentPlaying];
  [self stopTransferredBannerRingIfNeeded];
}

#pragma mark - property

/// 最小化按钮
- (UIButton *)smallButton {
  if (!_smallButton) {
    _smallButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _smallButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_smallButton setImage:[UIImage imageNamed:@"small_button"
                                                    inBundle:self.bundle
                               compatibleWithTraitCollection:nil]
                  forState:UIControlStateNormal];
    _smallButton.hidden = YES;
    [_smallButton addTarget:self
                     action:@selector(changeToSmall)
           forControlEvents:UIControlEventTouchUpInside];
  }
  return _smallButton;
}

- (UIView *)bannerView {
  if (!_bannerView) {
    _bannerView = [[UIView alloc] init];
    _bannerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    _bannerView.clipsToBounds = YES;
    _bannerView.layer.cornerRadius = 4.0;
    _bannerView.hidden = YES;
    _bannerView.translatesAutoresizingMaskIntoConstraints = NO;

    NEExpandButton *closeBtn = [NEExpandButton buttonWithType:UIButtonTypeCustom];
    [_bannerView addSubview:closeBtn];
    closeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    closeBtn.backgroundColor = [UIColor clearColor];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeBtn setTitle:@"X" forState:UIControlStateNormal];
    [closeBtn addTarget:self
                  action:@selector(hideBannerView)
        forControlEvents:UIControlEventTouchUpInside];

    [NSLayoutConstraint activateConstraints:@[
      [closeBtn.topAnchor constraintEqualToAnchor:_bannerView.topAnchor],
      [closeBtn.bottomAnchor constraintEqualToAnchor:_bannerView.bottomAnchor],
      [closeBtn.rightAnchor constraintEqualToAnchor:_bannerView.rightAnchor],
      [closeBtn.widthAnchor constraintEqualToConstant:40]
    ]];

    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [_bannerView addSubview:label];
    label.textColor = [UIColor whiteColor];
    [NSLayoutConstraint activateConstraints:@[
      [label.leftAnchor constraintEqualToAnchor:self.bannerView.leftAnchor constant:10],
      [label.centerYAnchor constraintEqualToAnchor:self.bannerView.centerYAnchor],
      [label.rightAnchor constraintEqualToAnchor:closeBtn.leftAnchor constant:-10]
    ]];

    label.adjustsFontSizeToFitWidth = YES;
    label.text = [NECallKitUtil localizableWithKey:@"waitting_remote_response"];
  }
  return _bannerView;
}

- (UIButton *)switchCameraBtn {
  if (!_switchCameraBtn) {
    _switchCameraBtn = [[UIButton alloc] init];
    [_switchCameraBtn setImage:[UIImage imageNamed:@"call_switch_camera"
                                                        inBundle:self.bundle
                                   compatibleWithTraitCollection:nil]
                      forState:UIControlStateNormal];
    [_switchCameraBtn addTarget:self
                         action:@selector(switchCameraBtn:)
               forControlEvents:UIControlEventTouchUpInside];
    _switchCameraBtn.translatesAutoresizingMaskIntoConstraints = NO;
    _switchCameraBtn.hidden = YES;
  }
  return _switchCameraBtn;
}

- (NEVideoOperationView *)operationView {
  if (!_operationView) {
    _operationView = [[NEVideoOperationView alloc] init];
    _operationView.enableVirtualBackground = self.callParam.enableVirtualBackground;
    _operationView.translatesAutoresizingMaskIntoConstraints = NO;
    _operationView.layer.cornerRadius = 30;
    [_operationView.microPhone addTarget:self
                                  action:@selector(microPhoneClick:)
                        forControlEvents:UIControlEventTouchUpInside];
    [_operationView.cameraBtn addTarget:self
                                 action:@selector(cameraBtnClick:)
                       forControlEvents:UIControlEventTouchUpInside];
    [_operationView.hangupBtn addTarget:self
                                 action:@selector(hangupBtnClick:)
                       forControlEvents:UIControlEventTouchUpInside];
    [_operationView.mediaBtn addTarget:self
                                action:@selector(operationSwitchClick:)
                      forControlEvents:UIControlEventTouchUpInside];
    [_operationView.speakerBtn addTarget:self
                                  action:@selector(operationSpeakerClick:)
                        forControlEvents:UIControlEventTouchUpInside];
    [_operationView.virtualBtn addTarget:self
                                  action:@selector(virtualBackgroundBtnClick:)
                        forControlEvents:UIControlEventTouchUpInside];
  }
  return _operationView;
}

- (UILabel *)timerLabel {
  if (nil == _timerLabel) {
    _timerLabel = [[UILabel alloc] init];
    _timerLabel.textColor = [UIColor whiteColor];
    _timerLabel.font = [UIFont systemFontOfSize:14.0];
    _timerLabel.textAlignment = NSTextAlignmentCenter;
    _timerLabel.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return _timerLabel;
}

- (NEAISubtitleView *)aiSubtitleView {
  if (!_aiSubtitleView) {
    _aiSubtitleView = [[NEAISubtitleView alloc] init];
    _aiSubtitleView.translatesAutoresizingMaskIntoConstraints = NO;
    _aiSubtitleView.hidden = YES;
  }
  return _aiSubtitleView;
}

- (NESingleToGroupCoordinator *)singleToGroupCoordinator {
  if (!_singleToGroupCoordinator) {
    _singleToGroupCoordinator =
        [[NESingleToGroupCoordinator alloc] initWithHostViewController:self
                                                         containerView:self.view
                                                             callParam:self.callParam
                                                                config:self.config
                                                                bundle:self.bundle];
    __weak typeof(self) weakSelf = self;
    _singleToGroupCoordinator.willStartInviteHandler = ^(NSString *reason) {
      [weakSelf expireSwitchCallTypeInviteWithReason:reason];
    };
  }
  return _singleToGroupCoordinator;
}

- (void)dealloc {
  [[NECallEngine sharedInstance] removeCallDelegate:self];
}

- (void)hideViews:(NSArray<UIView *> *)views {
  for (UIView *view in views) {
    [view setHidden:YES];
  }
}

- (void)showViews:(NSArray<UIView *> *)views {
  for (UIView *view in views) {
    [view setHidden:NO];
  }
}

- (void)changeDefaultImage:(BOOL)mute {
  NSLog(@"changeDefaultImage mute : %d", mute);
  NSLog(@"showMyBigView : %d", self.showMyBigView);

  UIImage *image = self.callParam.muteDefaultImage;
  if (image != nil) {
    if (mute == YES) {
      if (self.showMyBigView) {
        self.stateUIController.bigVideoView.imageView.image = image;
        self.stateUIController.bigVideoView.imageView.hidden = NO;
      } else {
        self.stateUIController.smallVideoView.imageView.image = image;
        self.stateUIController.smallVideoView.imageView.hidden = NO;
      }
    } else {
      if (self.showMyBigView) {
        self.stateUIController.bigVideoView.imageView.image = nil;
        self.stateUIController.bigVideoView.imageView.hidden = YES;
        self.stateUIController.smallVideoView.imageView.hidden = YES;
      } else {
        self.stateUIController.smallVideoView.imageView.image = nil;
        self.stateUIController.smallVideoView.imageView.hidden = YES;
      }
    }
  }
}

- (void)changeRemoteMute:(BOOL)mute videoView:(NEVideoView *)remoteVideo {
  UIImage *defaultImage = self.callParam.remoteDefaultImage;
  if (mute == true && defaultImage != nil) {
    remoteVideo.imageView.hidden = NO;
    remoteVideo.imageView.image = defaultImage;
  } else {
    remoteVideo.imageView.hidden = YES;
  }
}

- (void)changeTitle:(BOOL)cameraMute videoView:(NEVideoView *)videoView {
  // 获取当前用户ID
  NSString *currentUserId = [NIMSDK.sharedSDK.v2LoginService getLoginUser];
  BOOL isCurrentUser = [videoView.userID isEqualToString:currentUserId];

  if (cameraMute) {
    if (isCurrentUser) {
      videoView.titleLabel.text = [NECallKitUtil localizableWithKey:@"you_closed_camera"];
    } else {
      videoView.titleLabel.text = [NECallKitUtil localizableWithKey:@"remote_closed_camera"];
    }
  } else {
    videoView.titleLabel.text = @"";
  }
}

- (NEAudioCallingController *)audioCallingController {
  if (nil == _audioCallingController) {
    _audioCallingController =
        (NEAudioCallingController *)[self getCallStateInstanceWithClassKey:kAudioCalling];
  }
  if (nil == _audioCallingController) {
    _audioCallingController = [[NEAudioCallingController alloc] init];
    _audioCallingController.callParam = self.callParam;
    _audioCallingController.mainController = self;
    _audioCallingController.view.hidden = YES;
    _audioCallingController.operationView = self.operationView;
  }

  return _audioCallingController;
}

- (NEAudioInCallController *)audioInCallController {
  if (nil == _audioInCallController) {
    _audioInCallController =
        (NEAudioInCallController *)[self getCallStateInstanceWithClassKey:kAudioInCall];
  }
  if (nil == _audioInCallController) {
    _audioInCallController = [[NEAudioInCallController alloc] init];
    _audioInCallController.callParam = self.callParam;
    _audioInCallController.mainController = self;
    _audioInCallController.view.hidden = YES;
    _audioInCallController.operationView = self.operationView;
  }
  return _audioInCallController;
}

- (NEVideoCallingController *)videoCallingController {
  if (nil == _videoCallingController) {
    _videoCallingController =
        (NEVideoCallingController *)[self getCallStateInstanceWithClassKey:kVideoCalling];
  }
  if (nil == _videoCallingController) {
    _videoCallingController = [[NEVideoCallingController alloc] init];
    _videoCallingController.callParam = self.callParam;
    _videoCallingController.mainController = self;
    _videoCallingController.view.hidden = YES;
    _videoCallingController.operationView = self.operationView;
  }
  return _videoCallingController;
}

- (NEVideoInCallController *)videoInCallController {
  if (nil == _videoInCallController) {
    _videoInCallController =
        (NEVideoInCallController *)[self getCallStateInstanceWithClassKey:kVideoInCall];
  }
  if (nil == _videoInCallController) {
    _videoInCallController = [[NEVideoInCallController alloc] init];
    _videoInCallController.callParam = self.callParam;
    _videoInCallController.mainController = self;
    _videoInCallController.view.hidden = YES;
  }
  return _videoInCallController;
}

- (NECalledViewController *)calledController {
  if (nil == _calledController) {
    _calledController =
        (NECalledViewController *)[self getCallStateInstanceWithClassKey:kCalledState];
  }
  if (nil == _calledController) {
    _calledController = [[NECalledViewController alloc] init];
    _calledController.callParam = self.callParam;
    _calledController.mainController = self;
    _calledController.view.hidden = YES;
  }
  return _calledController;
}

#pragma mark - common fuction

- (NECallUIStateController *)getCallStateInstanceWithClassKey:(NSString *)key {
  Class cls = [self.uiConfigDic objectForKey:key];
  if (nil != cls) {
    NECallUIStateController *controller = [[cls alloc] init];
    controller.callParam = self.callParam;
    controller.mainController = self;
    controller.operationView = self.operationView;
    controller.view.hidden = YES;
    return controller;
  }
  return nil;
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

#pragma mark CallEngine Key Value

- (BOOL)isGlobalInit {
  return !([[[NECallEngine sharedInstance] valueForKeyPath:@"context.initRtcMode"] intValue] == 1);
}

- (BOOL)isSupportAutoJoinWhenCalled {
  return [[[NECallEngine sharedInstance] valueForKeyPath:@"context.supportAutoJoinWhenCalled"]
      boolValue];
}

#pragma mark Other Delegate
- (void)onNERtcEngineVirtualBackgroundSourceEnabled:(BOOL)enabled
                                             reason:
                                                 (NERtcVirtualBackgroundSourceStateReason)reason {
  if (reason == kNERtcVirtualBackgroundSourceStateReasonDeviceNotSupported) {
    [self.view ne_makeToast:[NECallKitUtil localizableWithKey:@"device_not_support"]];
    self.operationView.virtualBtn.selected = NO;
  }
}

- (void)onLocalAudioMuted:(BOOL)muted {
  self.operationView.microPhone.selected = muted;
  if ([self isSingleToGroupModeActive]) {
    [self syncSingleToGroupInitialMediaStateIfNeeded];
  }
}

@end
