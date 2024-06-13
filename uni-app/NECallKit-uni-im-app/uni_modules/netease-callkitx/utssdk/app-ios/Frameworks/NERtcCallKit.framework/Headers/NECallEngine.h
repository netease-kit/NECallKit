// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

#import "NECallConfig.h"
#import "NECallConnectedInfo.h"
#import "NECallEndInfo.h"
#import "NECallEngineConsts.h"
#import "NECallInfo.h"
#import "NECallParam.h"
#import "NECallPushConfig.h"
#import "NECallTypeChangeInfo.h"
#import "NEHangupParam.h"
#import "NEInviteInfo.h"
#import "NERecordConfig.h"
#import "NESetupConfig.h"
#import "NESwitchParam.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NECallEngineRtcDelegateEx <NSObject>

- (void)onNERtcEngineVirtualBackgroundSourceEnabled:(BOOL)enabled
                                             reason:(NERtcVirtualBackgroundSourceStateReason)reason;

@end

@protocol NERecordProvider <NSObject>

- (void)onRecordSend:(NERecordConfig *)config;

@end

@protocol NECallEngineDelegate <NSObject>

#pragma mark - 回调接口

@optional

/// 收到邀请的回调
/// @param info 邀请信息
- (void)onReceiveInvited:(NEInviteInfo *)info;

/// 通话结束
/// @param info 通话结束携带信息
- (void)onCallEnd:(NECallEndInfo *)info;

/// 通话建立的回调
/// @param info 通话建立回调信息
- (void)onCallConnected:(NECallInfo *)info;

/// 通话类型切换的回调
/// @param info 通话类型改变回调(本端调用或者远端调用此回调都会触发，可根据此回调做UI变更处理)
- (void)onCallTypeChange:(NECallTypeChangeInfo *)info;

/// 启用/禁用视频采集
/// @param available 是否可用
/// @param userId 用户ID
- (void)onVideoAvailable:(BOOL)available userID:(NSString *)userId;

/// 视频采集变更回调
/// @param muted 是否关闭采集
/// @param userId 用户ID
- (void)onVideoMuted:(BOOL)muted userID:(NSString *)userId;

/// 音频采集变更回调
/// @param muted 是否关闭采集
/// @param userId 用户ID
- (void)onAudioMuted:(BOOL)muted userID:(NSString *)userId;

#pragma mark - 内部周期回调接口

/// Rtc 初始化完成回调
- (void)onRtcInitEnd;

@end

@interface NECallEngine : NSObject

/// 通话状态
@property(nonatomic, assign, readonly) NERtcCallStatus callStatus;

/// 单位:秒,IM服务器邀请2分钟后无响应为超时,最大值不超过2分钟。
@property(nonatomic, assign) NSTimeInterval timeOutSeconds;

/// NERtcEngine 的回调接口，由用户提供
@property(nonatomic, weak) id<NERtcEngineDelegateEx> engineDelegate;

/// 中转NERtcEngine统计回调
@property(nonatomic, weak) id<NERtcEngineMediaStatsObserver> observer;

/// 初始化设置
@property(nonatomic, readonly, strong) NESetupConfig *config;

/// 单例
+ (instancetype)sharedInstance;

/// 销毁
- (void)destroy;

#pragma mark - 主流程

/// 初始化
/// @param config  初始化参数
- (void)setup:(NESetupConfig *)config;

/// 开始呼叫
/// @param param  呼叫参数
/// @param completion 完成回调
- (void)call:(NECallParam *)param
    completion:
        (nullable void (^)(NSError *_Nullable error, NECallInfo *_Nullable callInfo))completion;

/// 接受呼叫
/// @param completion 回调
- (void)accept:(nullable void (^)(NSError *_Nullable error,
                                  NECallInfo *_Nullable callInfo))completion;

/// 挂断(内部会自动根据状态机状态做取消呼叫  拒绝接听  挂断动作)
/// @param param 挂断参数
/// @param completion 结束回调
- (void)hangup:(NEHangupParam *)param
    completion:(nullable void (^)(NSError *_Nullable error))completion;

#pragma mark - 配置接口

/// 切换通话类型
/// @param param 切换参数
- (void)switchCallType:(NESwitchParam *)param
            completion:(nullable void (^)(NSError *_Nullable))completion;

/// 设置超时时间
/// @param time 超时时间，单位秒，不超过120s，超过内部会用120s处理
- (void)setTimeout:(int)time;

/// 设置自己画面
/// @param view 渲染自己画面的View
/// @discussion view上不建议有任何subview
/// @return 0 操作成功
- (int)setupLocalView:(nullable UIView *)view;

/// 设置其他用户画面
/// @param view 渲染其他画面的View
/// @discussion view上不建议有任何subview
/// @return 0 正常, -1 没有查询到 uid
- (int)setupRemoteView:(nullable UIView *)view;

/// 启动或关闭摄像头
/// @param enable YES:启动，NO:关闭
/// @return 操作返回值，成功则返回 0
- (int)enableLocalVideo:(BOOL)enable;

/// 启动或关闭视频流发送
/// @param muted  YES 开启 NO 关闭
/// @return 操作返回值，成功则返回 0
- (int)muteLocalVideo:(BOOL)muted;

/// 启动或关闭声音采集
/// @param muted  YES 开启 NO 关闭
/// @return 操作返回值，成功则返回 0
- (int)muteLocalAudio:(BOOL)muted;

/// 设置发送话单回调(如果实现会截断内部话单流程，请在此实现中自己处理话单发送相关功能)
///  @param provider 话单实现接口
- (void)setCallRecordProvider:(id<NERecordProvider>)provider;

/// 摄像头前后切换
- (void)switchCamera;

/// 设置呼叫时的配置参数，切换音视频是否需要切换，信令消息是否支持离线等
/// @param config   呼叫配置
- (void)setCallConfig:(NECallConfig *)config;

/// 添加代理
- (void)addCallDelegate:(id<NECallEngineDelegate>)delegate;

/// 移除代码
- (void)removeCallDelegate:(id<NECallEngineDelegate>)delegate;

#pragma mark - 状态信息获取

/// 获取当前通话信息
/// @return info 通话信息
- (nullable NECallInfo *)getCallInfo;

/// 获取当前通话配置
/// @return config 通话配置
- (NECallConfig *)getCallConfig;

/// 版本号
+ (NSString *)getVersion;

@end

NS_ASSUME_NONNULL_END
