// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NECallStateManager.h"
#import <NERtcCallKit/NECallEngine.h>
#import <NEXKitBase/NEXKitBase.h>

static NSString *const kCallStateManagerTag = @"CallStateManager";

@interface NECallStateManager () <NECallEngineDelegate>

@property(nonatomic, assign) NERtcCallStatus callStatus;
@property(nonatomic, assign) NECallType callType;
@property(nonatomic, strong, nullable) NECallInfo *callInfo;
@property(nonatomic, strong, nullable) NEInviteInfo *inviteInfo;
@property(nonatomic, assign) BOOL localVideoAvailable;
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *remoteVideoAvailable;
@property(nonatomic, assign) BOOL localVideoMuted;
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *remoteVideoMuted;
@property(nonatomic, assign) BOOL localAudioMuted;
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *remoteAudioMuted;
/// 通话开始时间
@property(nonatomic, strong, nullable) NSDate *callStartTime;
/// 代理集合（使用弱引用，支持多个代理）
@property(nonatomic, strong) NSHashTable<id<NECallStateManagerDelegate>> *delegates;

@end

@implementation NECallStateManager

+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static NECallStateManager *instance;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
  });
  return instance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _callStatus = NERtcCallStatusIdle;
    _callType = NECallTypeAudio;
    _localVideoAvailable = YES;  // 默认视频可用
    _remoteVideoAvailable = [NSMutableDictionary dictionary];
    _remoteVideoMuted = [NSMutableDictionary dictionary];
    _remoteAudioMuted = [NSMutableDictionary dictionary];
    // 使用弱引用存储代理，避免循环引用
    _delegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
  }
  return self;
}

- (void)addDelegate:(id<NECallStateManagerDelegate>)delegate {
  if (delegate) {
    [self.delegates addObject:delegate];
  }
}

- (void)removeDelegate:(id<NECallStateManagerDelegate>)delegate {
  if (delegate) {
    [self.delegates removeObject:delegate];
  }
}

- (void)notifyDelegatesCallTypeChanged:(NECallType)callType {
  for (id<NECallStateManagerDelegate> delegate in self.delegates) {
    if ([delegate respondsToSelector:@selector(callStateManagerDidChangeCallType:)]) {
      [delegate callStateManagerDidChangeCallType:callType];
    }
  }
}

- (void)notifyDelegatesRemoteVideoStateChanged:(NSString *)userId {
  for (id<NECallStateManagerDelegate> delegate in self.delegates) {
    if ([delegate respondsToSelector:@selector(callStateManagerDidChangeRemoteVideoState:)]) {
      [delegate callStateManagerDidChangeRemoteVideoState:userId];
    }
  }
}

- (void)notifyDelegatesCallStatusChanged:(NERtcCallStatus)callStatus {
  for (id<NECallStateManagerDelegate> delegate in self.delegates) {
    if ([delegate respondsToSelector:@selector(callStateManagerDidChangeCallStatus:)]) {
      [delegate callStateManagerDidChangeCallStatus:callStatus];
    }
  }
}

- (void)notifyDelegatesLocalVideoStateChanged {
  for (id<NECallStateManagerDelegate> delegate in self.delegates) {
    if ([delegate respondsToSelector:@selector(callStateManagerDidChangeLocalVideoState)]) {
      [delegate callStateManagerDidChangeLocalVideoState];
    }
  }
}

- (void)startObserving {
  NEXKitBaseLogInfo(@"[%@] startObserving", kCallStateManagerTag);
  [[NECallEngine sharedInstance] addCallDelegate:self];

  // 同步当前状态
  [self syncCurrentState];
}

- (void)stopObserving {
  NEXKitBaseLogInfo(@"[%@] stopObserving", kCallStateManagerTag);
  [[NECallEngine sharedInstance] removeCallDelegate:self];

  // 清理状态
  [self resetState];
}

- (void)syncCurrentState {
  [self syncCallStatus];

  NECallInfo *info = [[NECallEngine sharedInstance] getCallInfo];
  if (info) {
    _callInfo = info;
    _callType = info.callType;
  }
}

- (void)syncCallStatus {
  _callStatus = [[NECallEngine sharedInstance] callStatus];
}

- (void)resetState {
  _callStatus = NERtcCallStatusIdle;
  _callType = NECallTypeAudio;
  _callInfo = nil;
  _inviteInfo = nil;
  _localVideoAvailable = YES;  // 默认视频可用
  _localVideoMuted = NO;
  _localAudioMuted = NO;
  _callStartTime = nil;
  [_remoteVideoAvailable removeAllObjects];
  [_remoteVideoMuted removeAllObjects];
  [_remoteAudioMuted removeAllObjects];
}

#pragma mark - NECallEngineDelegate

- (void)onReceiveInvited:(NEInviteInfo *)info {
  NEXKitBaseLogInfo(@"[%@] onReceiveInvited, callerAccId = %@, callType = %lu",
                    kCallStateManagerTag, info.callerAccId, (unsigned long)info.callType);
  _inviteInfo = info;
  _callType = info.callType;
  NERtcCallStatus oldStatus = _callStatus;
  [self syncCallStatus];

  // 通知代理
  [self notifyDelegatesCallTypeChanged:info.callType];
  if (oldStatus != _callStatus) {
    [self notifyDelegatesCallStatusChanged:_callStatus];
  }
}

- (void)onCallEnd:(NECallEndInfo *)info {
  NEXKitBaseLogInfo(@"[%@] onCallEnd, reasonCode = %ld, message = %@", kCallStateManagerTag,
                    (long)info.reasonCode, info.message);
  NERtcCallStatus oldStatus = _callStatus;
  [self resetState];

  // 通知代理状态变化
  if (oldStatus != _callStatus) {
    [self notifyDelegatesCallStatusChanged:_callStatus];
  }
}

- (void)onCallConnected:(NECallInfo *)info {
  NEXKitBaseLogInfo(@"[%@] onCallConnected, callId = %@, callType = %lu", kCallStateManagerTag,
                    info.callId, (unsigned long)info.callType);
  _callInfo = info;
  _callType = info.callType;
  NERtcCallStatus oldStatus = _callStatus;
  [self syncCallStatus];

  // 记录通话开始时间
  if (!_callStartTime) {
    _callStartTime = [NSDate date];
    NEXKitBaseLogInfo(@"[%@] onCallConnected: recorded callStartTime", kCallStateManagerTag);
  }

  // 通知代理
  [self notifyDelegatesCallTypeChanged:info.callType];
  if (oldStatus != _callStatus) {
    [self notifyDelegatesCallStatusChanged:_callStatus];
  }
}

- (void)onCallTypeChange:(NECallTypeChangeInfo *)info {
  NEXKitBaseLogInfo(@"[%@] onCallTypeChange, callType = %lu, state = %lu", kCallStateManagerTag,
                    (unsigned long)info.callType, (unsigned long)info.state);

  // 只有在同意切换时才更新 callType
  if (info.state == NECallSwitchStateAgree) {
    _callType = info.callType;
    NERtcCallStatus oldStatus = _callStatus;
    // 同步最新的 callInfo
    [self syncCurrentState];

    // 通知代理
    [self notifyDelegatesCallTypeChanged:info.callType];
    if (oldStatus != _callStatus) {
      [self notifyDelegatesCallStatusChanged:_callStatus];
    }
  }
}

- (void)onVideoAvailable:(BOOL)available userID:(NSString *)userId {
  NEXKitBaseLogInfo(@"[%@] onVideoAvailable, available = %d, userId = %@", kCallStateManagerTag,
                    available, userId);

  // 这些回调都是远端的状态，直接存储到远端字典
  _remoteVideoAvailable[userId] = @(available);

  // 通知代理远端视频状态变化
  [self notifyDelegatesRemoteVideoStateChanged:userId];
}

- (void)onVideoMuted:(BOOL)muted userID:(NSString *)userId {
  NEXKitBaseLogInfo(@"[%@] onVideoMuted, muted = %d, userId = %@", kCallStateManagerTag, muted,
                    userId);

  // 这些回调都是远端的状态，直接存储到远端字典
  _remoteVideoMuted[userId] = @(muted);

  // 通知代理远端视频状态变化
  [self notifyDelegatesRemoteVideoStateChanged:userId];
}

- (void)onAudioMuted:(BOOL)muted userID:(NSString *)userId {
  NEXKitBaseLogInfo(@"[%@] onAudioMuted, muted = %d, userId = %@", kCallStateManagerTag, muted,
                    userId);

  // 这些回调都是远端的状态，直接存储到远端字典
  _remoteAudioMuted[userId] = @(muted);
}

- (void)onLocalAudioMuted:(BOOL)muted {
  NEXKitBaseLogInfo(@"[%@] onLocalAudioMuted, muted = %d", kCallStateManagerTag, muted);
  _localAudioMuted = muted;
}

#pragma mark - 同步本端状态

- (void)syncLocalVideoEnabled:(BOOL)enabled {
  NEXKitBaseLogInfo(@"[%@] syncLocalVideoEnabled, enabled = %d (current: %d)", kCallStateManagerTag,
                    enabled, _localVideoAvailable);
  if (_localVideoAvailable != enabled) {
    _localVideoAvailable = enabled;
    // 通知代理本端视频状态变化
    [self notifyDelegatesLocalVideoStateChanged];
  }
}

- (void)syncLocalVideoMuted:(BOOL)muted {
  NEXKitBaseLogInfo(@"[%@] syncLocalVideoMuted, muted = %d (current: %d)", kCallStateManagerTag,
                    muted, _localVideoMuted);
  if (_localVideoMuted != muted) {
    _localVideoMuted = muted;
    // 通知代理本端视频状态变化
    [self notifyDelegatesLocalVideoStateChanged];
  }
}

- (void)syncLocalAudioMuted:(BOOL)muted {
  NEXKitBaseLogInfo(@"[%@] syncLocalAudioMuted, muted = %d", kCallStateManagerTag, muted);
  _localAudioMuted = muted;
}

@end
