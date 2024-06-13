// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "NECallEngineConsts.h"

NS_ASSUME_NONNULL_BEGIN

@interface NEInviteInfo : NSObject

/// 呼叫者的accId
@property(nonatomic, strong) NSString *callerAccId;

/// 呼叫类型 1 音频 2 视频
@property(nonatomic, assign) NECallType callType;

/// 用户自定义信息(主叫发送被叫接收)
@property(nonatomic, strong) NSString *extraInfo;

/// 信令通道id
@property(nonatomic, strong) NSString *channelId;

@end

NS_ASSUME_NONNULL_END
