// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NESignalInfo : NSObject

/// 信令频道Id
@property(nonatomic, strong) NSString *channelId;

/// 信令邀请唯一标识
@property(nonatomic, strong) NSString *requestId;

/// 信令通道名称
@property(nonatomic, strong) NSString *channelName;

/// 扩展信息，透传到到被叫onReceiveInvited
@property(nonatomic, strong) NSString *extraInfo;

/// 定义的呼叫全局抄送信息，用户服务端接收抄送时设置自己的业务标识
@property(nonatomic, strong) NSString *globalExtraCopy;

@end

NS_ASSUME_NONNULL_END
