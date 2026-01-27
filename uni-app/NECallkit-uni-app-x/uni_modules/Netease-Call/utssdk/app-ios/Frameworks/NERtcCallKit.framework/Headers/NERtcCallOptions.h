// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NERtcCallOptions : NSObject

/// 推送证书名称
@property(nonatomic, copy) NSString *APNSCerName;

/// 呼叫推送证书名称
@property(nonatomic, copy) NSString *VoIPCerName;

/// 被叫是否自动加入channel
@property(nonatomic, assign) BOOL supportAutoJoinWhenCalled;

/// 是否关闭话单，默认NO不关闭
@property(nonatomic, assign) BOOL disableRecord;

/// 主叫是否在呼叫时加入rtc，默认为NO，不提前加入，在被叫接听时加入，如设置提前加入房间会带来通话费用的增加，同时提升首帧开画时间
@property(nonatomic, assign) BOOL joinRtcWhenCall;

/// 是否在初始化的时候初始化Rtc，默认为YES，设置为NO，主叫在呼叫时初始化，被叫在有呼叫到达的时候初始化
@property(nonatomic, assign) BOOL globalInit;

/// 是否初始化呼叫组件日志
@property(nonatomic, assign) BOOL isDisableLog;

@end

NS_ASSUME_NONNULL_END
