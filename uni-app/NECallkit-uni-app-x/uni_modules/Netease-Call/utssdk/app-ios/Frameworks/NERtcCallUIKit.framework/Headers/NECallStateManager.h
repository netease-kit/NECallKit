// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <NERtcCallKit/NERtcCallKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 通话状态管理器代理协议
@protocol NECallStateManagerDelegate <NSObject>

@optional

/// 通话类型变化回调
/// @param callType 新的通话类型
- (void)callStateManagerDidChangeCallType:(NECallType)callType;

/// 远端视频状态变化回调
/// @param userId 远端用户ID
- (void)callStateManagerDidChangeRemoteVideoState:(NSString *)userId;

/// 通话状态变化回调
/// @param callStatus 新的通话状态
- (void)callStateManagerDidChangeCallStatus:(NERtcCallStatus)callStatus;

/// 本端视频状态变化回调
- (void)callStateManagerDidChangeLocalVideoState;

@end

/// 通话状态管理器，用于存储和管理当前通话的状态信息
@interface NECallStateManager : NSObject

/// 单例
+ (instancetype)sharedInstance;

/// 当前通话状态
@property(nonatomic, assign, readonly) NERtcCallStatus callStatus;

/// 当前通话类型
@property(nonatomic, assign, readonly) NECallType callType;

/// 当前通话信息
@property(nonatomic, strong, readonly, nullable) NECallInfo *callInfo;

/// 当前邀请信息
@property(nonatomic, strong, readonly, nullable) NEInviteInfo *inviteInfo;

/// 本地视频是否可用
@property(nonatomic, assign, readonly) BOOL localVideoAvailable;

/// 远端视频是否可用（key: userId, value: BOOL）
@property(nonatomic, strong, readonly) NSDictionary<NSString *, NSNumber *> *remoteVideoAvailable;

/// 本地视频是否静音
@property(nonatomic, assign, readonly) BOOL localVideoMuted;

/// 远端视频是否静音（key: userId, value: BOOL）
@property(nonatomic, strong, readonly) NSDictionary<NSString *, NSNumber *> *remoteVideoMuted;

/// 本地音频是否静音
@property(nonatomic, assign, readonly) BOOL localAudioMuted;

/// 远端音频是否静音（key: userId, value: BOOL）
@property(nonatomic, strong, readonly) NSDictionary<NSString *, NSNumber *> *remoteAudioMuted;

/// 通话开始时间（用于计算已进行的时间）
@property(nonatomic, strong, readonly, nullable) NSDate *callStartTime;

/// 添加代理
/// @param delegate 代理对象
- (void)addDelegate:(id<NECallStateManagerDelegate>)delegate;

- (void)syncCurrentState;

/// 移除代理
/// @param delegate 代理对象
- (void)removeDelegate:(id<NECallStateManagerDelegate>)delegate;

/// 初始化并开始监听 NECallEngine 的回调
- (void)startObserving;

/// 停止监听并清理状态
- (void)stopObserving;

/// 同步本端视频启用状态（由 NECallKitBridge 调用）
/// @param enabled 是否启用
- (void)syncLocalVideoEnabled:(BOOL)enabled;

/// 同步本端视频静音状态（由 NECallKitBridge 调用）
/// @param muted 是否静音
- (void)syncLocalVideoMuted:(BOOL)muted;

/// 同步本端音频静音状态（由 NECallKitBridge 调用）
/// @param muted 是否静音
- (void)syncLocalAudioMuted:(BOOL)muted;

@end

NS_ASSUME_NONNULL_END
