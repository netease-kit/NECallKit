// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NERtcCallKitJoinChannelEvent : NSObject

/// IM userID
@property(nonatomic, copy) NSString *accid;

/// 音视频用户id
@property(nonatomic, assign) uint64_t uid;

/// 音视频channelId
@property(nonatomic, assign) uint64_t cid;

/// 音视频channelName
@property(nonatomic, copy) NSString *cname;

@end

NS_ASSUME_NONNULL_END
