// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef NECallEngineConsts_h
#define NECallEngineConsts_h

@class NERtcCallKitPushConfig;
@class NERtcCallKitContext;

typedef NS_OPTIONS(NSUInteger, NECallType) {
  /// 音频
  NECallTypeAudio = 1,
  /// 视频
  NECallTypeVideo = 2,
};

/// 通话行为
typedef NS_ENUM(NSUInteger, NECallSwitchState) {
  /// 邀请
  NECallSwitchStateInvite = 1,
  /// 接受
  NECallSwitchStateAgree = 2,
  /// 拒绝
  NECallSwitchStateReject = 3,
};

/// 引擎状态
typedef NS_ENUM(NSUInteger, NECallEngineStatus) {
  /// 闲置
  NECallStatusIdle = 0,
  /// 呼叫中
  NECallStatusCalling,
  /// 正在被呼叫
  NECallStatusCalled,
  /// 通话中
  NECallStatusInCall,
};

/// 通话状态
typedef NS_ENUM(NSUInteger, NERtcCallStatus) {
  /// 闲置
  NERtcCallStatusIdle = 0,
  /// 呼叫中
  NERtcCallStatusCalling,
  /// 正在被呼叫
  NERtcCallStatusCalled,
  /// 通话中
  NERtcCallStatusInCall,
};

/// 通话结束错误码
typedef NS_ENUM(NSInteger, NERtcCallTerminalCode) {
  /// 正常流程
  TerminalCodeNormal = 0,
  /// token 请求失败
  TerminalCodeTokenError,
  /// 超时
  TerminalCodeTimeOut,
  /// 用户占线
  TerminalCodeBusy,
  /// rtc 初始化失败
  TerminalCodeRtcInitError,
  /// 加入rtc失败
  TerminalCodeJoinRtcError,
  /// cancel 取消参数错误
  TerminalCodeCancelErrorParam,
  /// 发起呼叫失败
  TerminalCodeCallFailed,
  /// 账号被踢
  TerminalCodeKicked,
  ///  uid 为空
  TerminalCodeEmptyUid,
  ///  Rtc 断连
  TerminalRtcDisconnected = 10,
  /// 取消呼叫
  TerminalCallerCancel = 11,
  /// 呼叫被取消
  TerminalCalleeCancel = 12,
  /// 拒绝呼叫
  TerminalCalleeReject = 13,
  /// 呼叫被拒绝
  TerminalCallerRejcted = 14,
  /// 挂断呼叫
  TerminalHuangUp = 15,
  /// 呼叫被挂断
  TerminalBeHuangUp = 16,
  /// 多端登录被其他端拒绝
  TerminalOtherRejected = 17,
  /// 多端登录被其他端接听
  TerminalOtherAccepted = 18,
  /// Rtc房间断开链接
  TerminalUserRtcDisconnected = 19,
  /// 离开Rtc房间
  TerminalUserRtcLeave = 20,
  /// 接听失败
  TerminalAcceptFail = 21,
};

typedef NS_OPTIONS(NSUInteger, NERtcCallType) {
  /// 音频
  NERtcCallTypeAudio = 1,
  /// 视频
  NERtcCallTypeVideo = 2,
};

/// 通话行为
typedef NS_ENUM(NSUInteger, NERtcSwitchState) {
  /// 邀请
  NERtcSwitchStateInvite = 1,
  /// 接受
  NERtcSwitchStateAgree = 2,
  /// 拒绝
  NERtcSwitchStateReject = 3,
};

/// RTCSDK初始化模式
typedef NS_ENUM(NSUInteger, NECallInitRtcMode) {
  /// 全局初始化一次
  GlobalInitRtc = 1,
  /// 主叫呼叫以及被叫接收到呼叫邀请时候初始化，结束通话后销毁Rtc
  InitRtcInNeed,
  /// 被叫初始化Rtc延迟到 accept 执行
  InitRtcInNeedDelayToAccept,
};

/// 引擎错误码
typedef NS_ENUM(NSInteger, NECallEngineErrorCode) {
  /// 当前状态不支持
  CurrentStatusNotSupport = 20026
};

typedef void (^NERtcCallKitTokenHandler)(uint64_t uid, NSString *channelName,
                                         void (^complete)(NSString *token, NSError *error));

typedef void (^NERtcCallKitPushConfigHandler)(NERtcCallKitPushConfig *config,
                                              NERtcCallKitContext *context);

#define kNERtcCallKitBusyCode @"601"

static const NSUInteger kNERtcCallKitMaxTimeOut = 2 * 60;

#endif /* NECallEngineConsts_h */
