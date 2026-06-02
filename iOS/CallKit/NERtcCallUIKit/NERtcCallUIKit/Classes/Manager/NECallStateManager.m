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
/// 通话开始时间是否来自接通回调
@property(nonatomic, assign) BOOL callStartTimeFromConnectedEvent;
/// NECallEngine 回调监听引用计数
@property(nonatomic, assign) NSInteger observingCount;
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
  self.observingCount += 1;
  if (self.observingCount > 1) {
    NEXKitBaseLogInfo(@"[%@] startObserving refresh because already observing, count:%ld",
                      kCallStateManagerTag, (long)self.observingCount);
    [[NECallEngine sharedInstance] addCallDelegate:self];
    [self syncCurrentState];
    if (_callStatus == NERtcCallStatusInCall) {
      [self ensureCallStartTime];
    }
    return;
  }
  NEXKitBaseLogInfo(@"[%@] startObserving", kCallStateManagerTag);
  [[NECallEngine sharedInstance] addCallDelegate:self];

  // 同步当前状态
  [self syncCurrentState];
  if (_callStatus == NERtcCallStatusInCall) {
    [self ensureCallStartTime];
  }
}

- (void)stopObserving {
  if (self.observingCount <= 0) {
    NEXKitBaseLogInfo(@"[%@] stopObserving skipped because not observing", kCallStateManagerTag);
    [self resetState];
    return;
  }
  self.observingCount -= 1;
  if (self.observingCount > 0) {
    NEXKitBaseLogInfo(@"[%@] stopObserving skipped because still referenced, count:%ld",
                      kCallStateManagerTag, (long)self.observingCount);
    return;
  }
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
  if (_callStatus == NERtcCallStatusInCall) {
    [self ensureCallStartTime];
  }
}

- (void)syncCallStatus {
  _callStatus = [[NECallEngine sharedInstance] callStatus];
}

- (void)ensureCallStartTime {
  NSDate *inferredStartTime = [self inferredCallStartTimeFromCurrentMembers];
  if (_callStartTime != nil) {
    if (!_callStartTimeFromConnectedEvent &&
        inferredStartTime != nil &&
        [_callStartTime timeIntervalSinceDate:inferredStartTime] > 1) {
      _callStartTime = inferredStartTime;
      NEXKitBaseLogInfo(@"[%@] ensureCallStartTime: adjusted callStartTime from members",
                        kCallStateManagerTag);
    }
    return;
  }
  _callStartTime = inferredStartTime ?: [NSDate date];
  _callStartTimeFromConnectedEvent = NO;
  NEXKitBaseLogInfo(@"[%@] ensureCallStartTime: recorded callStartTime source:%@",
                    kCallStateManagerTag, inferredStartTime != nil ? @"members" : @"now");
}

- (void)recordCallStartTimeFromConnectedEvent {
  if (_callStartTime != nil && _callStartTimeFromConnectedEvent) {
    return;
  }
  _callStartTime = [NSDate date];
  _callStartTimeFromConnectedEvent = YES;
  NEXKitBaseLogInfo(@"[%@] onCallConnected: recorded callStartTime", kCallStateManagerTag);
}

- (NSDate *)inferredCallStartTimeFromCurrentMembers {
  NSArray<NECallMemberInfo *> *members = [[NECallEngine sharedInstance] currentMembers];
  if (members.count <= 0) {
    return nil;
  }
  NSInteger joinedMemberCount = 0;
  NSTimeInterval latestInitialJoinedAt = 0;
  NSTimeInterval latestJoinedAt = 0;
  for (NECallMemberInfo *member in members) {
    if (member.state != NECallMemberStateJoined || member.joinedAt <= 0) {
      continue;
    }
    joinedMemberCount += 1;
    if (member.joinedAt > latestJoinedAt) {
      latestJoinedAt = member.joinedAt;
    }
    if (member.inviterUserID.length <= 0 && member.joinedAt > latestInitialJoinedAt) {
      latestInitialJoinedAt = member.joinedAt;
    }
  }
  if (joinedMemberCount < 2) {
    return nil;
  }
  NSTimeInterval joinedAt = latestInitialJoinedAt > 0 ? latestInitialJoinedAt : latestJoinedAt;
  return joinedAt > 0 ? [NSDate dateWithTimeIntervalSince1970:joinedAt] : nil;
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
  _callStartTimeFromConnectedEvent = NO;
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
  [self recordCallStartTimeFromConnectedEvent];

  // 通知代理
  [self notifyDelegatesCallTypeChanged:info.callType];
  if (oldStatus != _callStatus) {
    [self notifyDelegatesCallStatusChanged:_callStatus];
  }
}

- (void)onCallModeChanged:(NECallModeChangeInfo *)info {
  NEXKitBaseLogInfo(@"[%@] onCallModeChanged, oldMode = %ld, newMode = %ld",
                    kCallStateManagerTag, (long)info.oldMode, (long)info.newMode);
  NERtcCallStatus oldStatus = _callStatus;
  [self syncCurrentState];
  if (_callStatus == NERtcCallStatusInCall) {
    [self ensureCallStartTime];
  }
  [self notifyDelegatesCallTypeChanged:_callType];
  if (oldStatus != _callStatus) {
    [self notifyDelegatesCallStatusChanged:_callStatus];
  }
}

- (void)onCallMembersChanged:(NECallMemberChangeInfo *)info {
  NEXKitBaseLogInfo(@"[%@] onCallMembersChanged, memberCount = %lu, changeType = %ld",
                    kCallStateManagerTag, (unsigned long)info.members.count,
                    (long)info.changeType);
  NERtcCallStatus oldStatus = _callStatus;
  [self syncCurrentState];
  if (_callStatus == NERtcCallStatusInCall) {
    [self ensureCallStartTime];
  }
  [self notifyDelegatesCallTypeChanged:_callType];
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
