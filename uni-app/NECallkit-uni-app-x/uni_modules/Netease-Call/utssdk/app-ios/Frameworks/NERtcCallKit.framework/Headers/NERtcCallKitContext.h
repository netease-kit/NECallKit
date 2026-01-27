// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "NECallEngineConsts.h"
#import "NERtcCallKitConsts.h"

NS_ASSUME_NONNULL_BEGIN

@interface NERtcCallKitContext : NSObject

/// appKey
@property(nonatomic, copy) NSString *appKey;

/// 是否是群组呼叫
@property(nonatomic, assign) BOOL isGroupCall;

/// 当前群组呼叫的groupID
@property(nonatomic, copy, nullable) NSString *groupID;

/// 当前用户IM accid
@property(nonatomic, copy) NSString *myAccid;

/// 当前用户音视频房间uid
@property(nonatomic, assign) uint64_t myUid;

/// 当前用户的显示名称
@property(nonatomic, copy) NSString *myDisplayName;

/// 1to1专用字段，对方accid. 群组呼叫下无效。
@property(nonatomic, copy, nullable) NSString *remoteAccid;

/// 音视频房间名
@property(nonatomic, copy) NSString *cname;

/// 呼叫类型。视频/音频
@property(nonatomic, assign) NERtcCallType callType;

@end

NS_ASSUME_NONNULL_END
