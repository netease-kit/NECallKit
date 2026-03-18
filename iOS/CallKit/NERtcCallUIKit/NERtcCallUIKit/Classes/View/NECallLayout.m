// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NECallLayout.h"
#import <NEXKitBase/NEXKitBase.h>
#import <NIMSDK/NIMSDK.h>
#import "NECallLayoutAudioView.h"
#import "NECallLayoutVideoView.h"
#import "NECallStateManager.h"

static NSString *const kCallLayoutTag = @"CallLayout";

@interface NECallLayout () <NECallStateManagerDelegate>

/// 当前显示的视频视图
@property(nonatomic, strong, nullable) NECallLayoutVideoView *videoView;

/// 当前显示的音频视图
@property(nonatomic, strong, nullable) NECallLayoutAudioView *audioView;

/// 当前通话状态
@property(nonatomic, assign) NERtcCallStatus callStatus;

/// 空视图（用于音频呼叫中/接听中状态）
@property(nonatomic, strong, nullable) UIView *emptyView;

@end

@implementation NECallLayout

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    NEXKitBaseLogInfo(@"[%@] initWithFrame: %@", kCallLayoutTag, NSStringFromCGRect(frame));
    // 从 NECallStateManager 读取当前通话类型和状态
    NECallStateManager *stateManager = [NECallStateManager sharedInstance];
    // 注册为代理
    [stateManager addDelegate:self];
    [stateManager syncCurrentState];
    _callType = stateManager.callType;
    _callStatus = stateManager.callStatus;
    NEXKitBaseLogInfo(@"[%@] initWithFrame: callType = %lu, callStatus = %lu", kCallLayoutTag,
                      (unsigned long)_callType, (unsigned long)_callStatus);

    [self setupUI];
  }
  return self;
}

- (void)dealloc {
  // 移除代理
  [[NECallStateManager sharedInstance] removeDelegate:self];
}

- (void)setupUI {
  self.backgroundColor = [UIColor blackColor];
  [self updateViewForCallType:self.callType callStatus:self.callStatus];
}

- (void)updateViewForCallType:(NECallType)callType callStatus:(NERtcCallStatus)callStatus {
  NEXKitBaseLogInfo(@"[%@] updateViewForCallType: %lu, callStatus: %lu", kCallLayoutTag,
                    (unsigned long)callType, (unsigned long)callStatus);

  // 获取远端用户信息
  NECallStateManager *stateManager = [NECallStateManager sharedInstance];
  NECallInfo *callInfo = stateManager.callInfo;
  NEInviteInfo *inviteInfo = stateManager.inviteInfo;

  NSString *remoteAccId = nil;
  BOOL isCaller = NO;

  if (callInfo) {
    NSString *currentAccId = [NIMSDK.sharedSDK.v2LoginService getLoginUser];
    if ([callInfo.currentAccId isEqualToString:callInfo.callerInfo.accId]) {
      // 当前用户是主叫
      remoteAccId = callInfo.calleeInfo.accId;
      isCaller = YES;
    } else {
      // 当前用户是被叫
      remoteAccId = callInfo.callerInfo.accId;
      isCaller = NO;
    }
  } else if (inviteInfo) {
    // 被叫状态，还没有callInfo
    remoteAccId = inviteInfo.callerAccId;
    isCaller = NO;
  }

  // 判断是否需要切换视图类型
  BOOL needVideoView =
      (callStatus == NERtcCallStatusCalling || callStatus == NERtcCallStatusCalled ||
       callStatus == NERtcCallStatusInCall) &&
      callType == NECallTypeVideo;
  BOOL needAudioView =
      (callStatus == NERtcCallStatusCalling || callStatus == NERtcCallStatusCalled ||
       callStatus == NERtcCallStatusInCall) &&
      callType == NECallTypeAudio;
  BOOL needEmptyView = !needVideoView && !needAudioView;

  // 检查当前视图类型是否匹配
  BOOL hasVideoView = (self.videoView != nil);
  BOOL hasAudioView = (self.audioView != nil);
  BOOL hasEmptyView = (self.emptyView != nil);

  // 如果视图类型不匹配，需要切换
  BOOL needSwitchView = NO;
  if (needVideoView && !hasVideoView) {
    needSwitchView = YES;
  } else if (needAudioView && !hasAudioView) {
    needSwitchView = YES;
  } else if (needEmptyView && !hasEmptyView) {
    needSwitchView = YES;
  }

  if (needSwitchView) {
    // 移除所有旧视图
    if (self.videoView) {
      NEXKitBaseLogInfo(@"[%@] updateViewForCallType: removing old videoView", kCallLayoutTag);
      [self.videoView removeFromSuperview];
      self.videoView = nil;
    }
    if (self.audioView) {
      NEXKitBaseLogInfo(@"[%@] updateViewForCallType: removing old audioView", kCallLayoutTag);
      [self.audioView removeFromSuperview];
      self.audioView = nil;
    }
    if (self.emptyView) {
      NEXKitBaseLogInfo(@"[%@] updateViewForCallType: removing old emptyView", kCallLayoutTag);
      [self.emptyView removeFromSuperview];
      self.emptyView = nil;
    }
  }

  // 根据通话状态和类型创建或更新对应的视图
  if (callStatus == NERtcCallStatusCalling || callStatus == NERtcCallStatusCalled) {
    // 呼叫中或接听中状态
    if (callType == NECallTypeVideo) {
      // 视频：显示本地视频画面
      if (needSwitchView) {
        NEXKitBaseLogInfo(@"[%@] updateViewForCallType: creating videoView for calling/called "
                          @"state with bounds: %@",
                          kCallLayoutTag, NSStringFromCGRect(self.bounds));
        self.videoView = [[NECallLayoutVideoView alloc] initWithFrame:self.bounds];
        self.videoView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.videoView];
        [NSLayoutConstraint activateConstraints:@[
          [self.videoView.leftAnchor constraintEqualToAnchor:self.leftAnchor],
          [self.videoView.rightAnchor constraintEqualToAnchor:self.rightAnchor],
          [self.videoView.topAnchor constraintEqualToAnchor:self.topAnchor],
          [self.videoView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
        ]];
        NEXKitBaseLogInfo(@"[%@] updateViewForCallType: videoView created for calling/called state",
                          kCallLayoutTag);
      } else {
        NEXKitBaseLogInfo(
            @"[%@] updateViewForCallType: reusing existing videoView for calling/called state",
            kCallLayoutTag);
      }
      // 设置属性（会触发UI更新）
      self.videoView.showLocalVideoOnly = YES;  // 只显示本地视频，不能切换
      // 初始化时同步本端视频状态
      [self syncLocalVideoState];
      // 统一设置所有用户信息（会触发UI更新）
      [self setRemoteUserInfoToVideoView:remoteAccId isCaller:isCaller callStatus:callStatus];
    } else {
      // 音频：显示音频视图（呼叫中/接听中状态）
      if (needSwitchView) {
        NEXKitBaseLogInfo(@"[%@] updateViewForCallType: creating audioView for calling/called "
                          @"state with bounds: %@",
                          kCallLayoutTag, NSStringFromCGRect(self.bounds));
        self.audioView = [[NECallLayoutAudioView alloc] initWithFrame:self.bounds];
        self.audioView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.audioView];
        [NSLayoutConstraint activateConstraints:@[
          [self.audioView.leftAnchor constraintEqualToAnchor:self.leftAnchor],
          [self.audioView.rightAnchor constraintEqualToAnchor:self.rightAnchor],
          [self.audioView.topAnchor constraintEqualToAnchor:self.topAnchor],
          [self.audioView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
        ]];
        NEXKitBaseLogInfo(@"[%@] updateViewForCallType: audioView created for calling/called state",
                          kCallLayoutTag);
      } else {
        NEXKitBaseLogInfo(
            @"[%@] updateViewForCallType: reusing existing audioView for calling/called state",
            kCallLayoutTag);
      }
      // 统一设置所有用户信息（会触发UI更新）
      [self setRemoteUserInfoToAudioView:remoteAccId isCaller:isCaller callStatus:callStatus];
    }
  } else if (callStatus == NERtcCallStatusInCall) {
    // 通话中状态
    if (callType == NECallTypeVideo) {
      if (needSwitchView) {
        NEXKitBaseLogInfo(
            @"[%@] updateViewForCallType: creating videoView for inCall state with bounds: %@",
            kCallLayoutTag, NSStringFromCGRect(self.bounds));
        self.videoView = [[NECallLayoutVideoView alloc] initWithFrame:self.bounds];
        self.videoView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.videoView];
        [NSLayoutConstraint activateConstraints:@[
          [self.videoView.leftAnchor constraintEqualToAnchor:self.leftAnchor],
          [self.videoView.rightAnchor constraintEqualToAnchor:self.rightAnchor],
          [self.videoView.topAnchor constraintEqualToAnchor:self.topAnchor],
          [self.videoView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
        ]];
        NEXKitBaseLogInfo(@"[%@] updateViewForCallType: videoView created for inCall state",
                          kCallLayoutTag);
      } else {
        NEXKitBaseLogInfo(
            @"[%@] updateViewForCallType: reusing existing videoView for inCall state",
            kCallLayoutTag);
      }
      // 设置属性（会触发UI更新）
      self.videoView.showLocalBigView = NO;
      self.videoView.showLocalVideoOnly = NO;  // 正常模式，可以切换
      // 初始化时同步远端视频状态和本端视频状态
      [self syncRemoteVideoState];
      [self syncLocalVideoState];
    } else {
      if (needSwitchView) {
        NEXKitBaseLogInfo(
            @"[%@] updateViewForCallType: creating audioView for inCall state with bounds: %@",
            kCallLayoutTag, NSStringFromCGRect(self.bounds));
        self.audioView = [[NECallLayoutAudioView alloc] initWithFrame:self.bounds];
        self.audioView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.audioView];
        [NSLayoutConstraint activateConstraints:@[
          [self.audioView.leftAnchor constraintEqualToAnchor:self.leftAnchor],
          [self.audioView.rightAnchor constraintEqualToAnchor:self.rightAnchor],
          [self.audioView.topAnchor constraintEqualToAnchor:self.topAnchor],
          [self.audioView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
        ]];
        NEXKitBaseLogInfo(@"[%@] updateViewForCallType: audioView created for inCall state",
                          kCallLayoutTag);
      } else {
        NEXKitBaseLogInfo(
            @"[%@] updateViewForCallType: reusing existing audioView for inCall state",
            kCallLayoutTag);
      }
      // 统一设置所有用户信息（会触发UI更新）
      [self setRemoteUserInfoToAudioView:remoteAccId isCaller:isCaller callStatus:callStatus];
    }
  } else {
    // 其他状态（Idle等），显示空视图
    if (needSwitchView) {
      NEXKitBaseLogInfo(@"[%@] updateViewForCallType: creating emptyView for idle state",
                        kCallLayoutTag);
      self.emptyView = [[UIView alloc] initWithFrame:self.bounds];
      self.emptyView.backgroundColor = [UIColor blackColor];
      self.emptyView.translatesAutoresizingMaskIntoConstraints = NO;
      [self addSubview:self.emptyView];
      [NSLayoutConstraint activateConstraints:@[
        [self.emptyView.leftAnchor constraintEqualToAnchor:self.leftAnchor],
        [self.emptyView.rightAnchor constraintEqualToAnchor:self.rightAnchor],
        [self.emptyView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.emptyView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
      ]];
    } else {
      NEXKitBaseLogInfo(@"[%@] updateViewForCallType: reusing existing emptyView for idle state",
                        kCallLayoutTag);
    }
  }
}

- (void)createViewForCallType:(NECallType)callType {
  // 兼容旧方法，使用当前状态
  [self updateViewForCallType:callType callStatus:self.callStatus];
}

#pragma mark - NECallStateManagerDelegate

- (void)callStateManagerDidChangeCallType:(NECallType)callType {
  NEXKitBaseLogInfo(@"[%@] callStateManagerDidChangeCallType: %lu (current: %lu)", kCallLayoutTag,
                    (unsigned long)callType, (unsigned long)_callType);
  if (_callType != callType) {
    _callType = callType;
    // 使用当前状态更新视图
    [self updateViewForCallType:callType callStatus:self.callStatus];
  }
}

- (void)callStateManagerDidChangeCallStatus:(NERtcCallStatus)callStatus {
  NEXKitBaseLogInfo(@"[%@] callStateManagerDidChangeCallStatus: %lu (current: %lu)", kCallLayoutTag,
                    (unsigned long)callStatus, (unsigned long)_callStatus);
  if (_callStatus != callStatus) {
    _callStatus = callStatus;
    // 使用当前类型更新视图（会重新创建视图并设置所有信息）
    [self updateViewForCallType:self.callType callStatus:callStatus];
  }
}

- (void)callStateManagerDidChangeRemoteVideoState:(NSString *)userId {
  NEXKitBaseLogInfo(@"[%@] callStateManagerDidChangeRemoteVideoState: userId = %@", kCallLayoutTag,
                    userId);

  // 只处理视频通话的情况
  if (self.callType != NECallTypeVideo || !self.videoView) {
    return;
  }

  // 获取当前通话信息，确定远端用户ID
  NECallStateManager *stateManager = [NECallStateManager sharedInstance];
  NECallInfo *callInfo = stateManager.callInfo;
  if (!callInfo) {
    NEXKitBaseLogInfo(@"[%@] callStateManagerDidChangeRemoteVideoState: callInfo is nil",
                      kCallLayoutTag);
    return;
  }

  // 判断传入的 userId 是否是远端用户
  NSString *remoteUserId = nil;
  if ([callInfo.currentAccId isEqualToString:callInfo.callerInfo.accId]) {
    remoteUserId = callInfo.calleeInfo.accId;
  } else {
    remoteUserId = callInfo.callerInfo.accId;
  }

  // 如果 userId 不是远端用户，忽略
  if (![userId isEqualToString:remoteUserId]) {
    NEXKitBaseLogInfo(@"[%@] callStateManagerDidChangeRemoteVideoState: userId %@ is not remote "
                      @"user %@, ignoring",
                      kCallLayoutTag, userId, remoteUserId);
    return;
  }

  // 计算远端视频是否启用：available && !muted
  NSDictionary *remoteVideoAvailable = stateManager.remoteVideoAvailable;
  NSDictionary *remoteVideoMuted = stateManager.remoteVideoMuted;

  BOOL available = NO;
  if (remoteVideoAvailable[userId]) {
    available = [remoteVideoAvailable[userId] boolValue];
  }

  BOOL muted = NO;
  if (remoteVideoMuted[userId]) {
    muted = [remoteVideoMuted[userId] boolValue];
  }

  BOOL remoteVideoEnabled = available && !muted;
  NEXKitBaseLogInfo(@"[%@] callStateManagerDidChangeRemoteVideoState: remoteUserId=%@, "
                    @"available=%d, muted=%d, remoteVideoEnabled=%d",
                    kCallLayoutTag, remoteUserId, available, muted, remoteVideoEnabled);

  // 更新 videoView 的 remoteVideoEnabled，这会自动触发 refreshVideoView
  self.videoView.remoteVideoEnabled = remoteVideoEnabled;
}

- (void)callStateManagerDidChangeLocalVideoState {
  NEXKitBaseLogInfo(@"[%@] callStateManagerDidChangeLocalVideoState", kCallLayoutTag);

  // 只处理视频通话的情况
  if (self.callType != NECallTypeVideo || !self.videoView) {
    return;
  }

  // 从 NECallStateManager 获取本端视频状态
  NECallStateManager *stateManager = [NECallStateManager sharedInstance];
  BOOL localVideoEnabled = stateManager.localVideoAvailable && !stateManager.localVideoMuted;

  NEXKitBaseLogInfo(@"[%@] callStateManagerDidChangeLocalVideoState: localVideoAvailable=%d, "
                    @"localVideoMuted=%d, localVideoEnabled=%d",
                    kCallLayoutTag, stateManager.localVideoAvailable, stateManager.localVideoMuted,
                    localVideoEnabled);

  // 更新 videoView 的 localVideoEnabled，这会自动触发 refreshVideoView
  self.videoView.localVideoEnabled = localVideoEnabled;
}

- (void)syncRemoteVideoState {
  // 只处理视频通话的情况
  if (self.callType != NECallTypeVideo || !self.videoView) {
    return;
  }

  // 获取当前通话信息和状态
  NECallStateManager *stateManager = [NECallStateManager sharedInstance];
  NECallInfo *callInfo = stateManager.callInfo;
  if (!callInfo) {
    NEXKitBaseLogInfo(@"[%@] syncRemoteVideoState: callInfo is nil", kCallLayoutTag);
    return;
  }

  // 获取远端用户ID
  NSString *remoteUserId = nil;
  if ([callInfo.currentAccId isEqualToString:callInfo.callerInfo.accId]) {
    remoteUserId = callInfo.calleeInfo.accId;
  } else {
    remoteUserId = callInfo.callerInfo.accId;
  }

  if (!remoteUserId) {
    NEXKitBaseLogInfo(@"[%@] syncRemoteVideoState: remoteUserId is nil", kCallLayoutTag);
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
  NEXKitBaseLogInfo(
      @"[%@] syncRemoteVideoState: remoteUserId=%@, available=%d, muted=%d, remoteVideoEnabled=%d",
      kCallLayoutTag, remoteUserId, available, muted, remoteVideoEnabled);

  // 更新 videoView 的 remoteVideoEnabled，这会自动触发 refreshVideoView
  self.videoView.remoteVideoEnabled = remoteVideoEnabled;
}

- (void)syncLocalVideoState {
  // 只处理视频通话的情况
  if (self.callType != NECallTypeVideo || !self.videoView) {
    return;
  }

  // 从 NECallStateManager 获取本端视频状态
  NECallStateManager *stateManager = [NECallStateManager sharedInstance];
  BOOL localVideoEnabled = stateManager.localVideoAvailable && !stateManager.localVideoMuted;

  NEXKitBaseLogInfo(
      @"[%@] syncLocalVideoState: localVideoAvailable=%d, localVideoMuted=%d, localVideoEnabled=%d",
      kCallLayoutTag, stateManager.localVideoAvailable, stateManager.localVideoMuted,
      localVideoEnabled);

  // 更新 videoView 的 localVideoEnabled，这会自动触发 refreshVideoView
  self.videoView.localVideoEnabled = localVideoEnabled;
}

#pragma mark - User Info Set

- (void)setRemoteUserInfoToVideoView:(NSString *)remoteAccId
                            isCaller:(BOOL)isCaller
                          callStatus:(NERtcCallStatus)callStatus {
  if (!self.videoView) {
    return;
  }

  NEXKitBaseLogInfo(
      @"[%@] setRemoteUserInfoToVideoView: remoteAccId=%@, isCaller=%d, callStatus=%lu",
      kCallLayoutTag, remoteAccId, isCaller, (unsigned long)callStatus);

  // 先设置基本信息（这些会触发子视图内部的UI更新）
  self.videoView.remoteUserAccid = remoteAccId;
  self.videoView.isCaller = isCaller;

  // 如果有 remoteAccId，异步获取用户详细信息并设置
  if (remoteAccId) {
    __weak typeof(self) weakSelf = self;
    [NIMSDK.sharedSDK.userManager
        fetchUserInfos:@[ remoteAccId ]
            completion:^(NSArray<NIMUser *> *_Nullable users, NSError *_Nullable error) {
              if (error) {
                NEXKitBaseLogInfo(
                    @"[%@] setRemoteUserInfoToVideoView: failed to fetch user info, error=%@",
                    kCallLayoutTag, error);
                return;
              }

              NIMUser *user = users.firstObject;
              if (user && weakSelf.videoView) {
                // 设置详细信息（这些setter会自动触发UI更新）
                weakSelf.videoView.remoteShowName =
                    user.userInfo.nickName.length > 0 ? user.userInfo.nickName : user.userId;
                weakSelf.videoView.remoteAvatar = user.userInfo.avatarUrl;
                NEXKitBaseLogInfo(
                    @"[%@] setRemoteUserInfoToVideoView: set remoteShowName=%@, remoteAvatar=%@",
                    kCallLayoutTag, weakSelf.videoView.remoteShowName,
                    weakSelf.videoView.remoteAvatar);
              }
            }];
  }
}

- (void)setRemoteUserInfoToAudioView:(NSString *)remoteAccId
                            isCaller:(BOOL)isCaller
                          callStatus:(NERtcCallStatus)callStatus {
  if (!self.audioView) {
    return;
  }

  NEXKitBaseLogInfo(
      @"[%@] setRemoteUserInfoToAudioView: remoteAccId=%@, isCaller=%d, callStatus=%lu",
      kCallLayoutTag, remoteAccId, isCaller, (unsigned long)callStatus);

  // 先设置基本信息和状态（这些会触发子视图内部的UI更新）
  // 注意：callStatus 的设置会触发 setupUI，所以最后设置
  self.audioView.remoteUserAccid = remoteAccId;
  self.audioView.isCaller = isCaller;
  self.audioView.callStatus = callStatus;  // 这个会触发 setupUI

  // 如果有 remoteAccId，异步获取用户详细信息并设置
  if (remoteAccId) {
    __weak typeof(self) weakSelf = self;
    [NIMSDK.sharedSDK.userManager
        fetchUserInfos:@[ remoteAccId ]
            completion:^(NSArray<NIMUser *> *_Nullable users, NSError *_Nullable error) {
              if (error) {
                NEXKitBaseLogInfo(
                    @"[%@] setRemoteUserInfoToAudioView: failed to fetch user info, error=%@",
                    kCallLayoutTag, error);
                return;
              }

              NIMUser *user = users.firstObject;
              if (user && weakSelf.audioView) {
                // 设置详细信息（这些setter会自动触发UI更新）
                weakSelf.audioView.remoteShowName =
                    user.userInfo.nickName.length > 0 ? user.userInfo.nickName : user.userId;
                weakSelf.audioView.remoteAvatar = user.userInfo.avatarUrl;
                NEXKitBaseLogInfo(
                    @"[%@] setRemoteUserInfoToAudioView: set remoteShowName=%@, remoteAvatar=%@",
                    kCallLayoutTag, weakSelf.audioView.remoteShowName,
                    weakSelf.audioView.remoteAvatar);
              }
            }];
  }
}

@end
