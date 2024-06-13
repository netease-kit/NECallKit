// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <NERtcSDK/NERtcSDK.h>
#import <NIMSDK/NIMSDK.h>
#import "GroupCallParam.h"
#import "GroupCallResult.h"
#import "NEGroupCallInfo.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NEGroupCallKitDelegate <NSObject>

@optional
/// 收到邀请的回调
- (void)onGroupInvitedWithInfo:(NEGroupCallInfo *)info;

/// 用户列表变更回调
- (void)onGroupUserDidChange:(NSArray<GroupCallMember *> *)members;

/// 通话结束
- (void)onGroupEndCallWithReason:(NSInteger)reason withCallId:(NSString *)callId;

/// 挂断
- (void)onGroupHangupWithReason:(NSString *)reason;

/// 发生异常
- (void)onGroupError:(NSError *)error;

/// 远端用户视频开启/关闭变更
- (void)onGroupRemoteUserOpenVideo:(uint64_t)uid withOpen:(BOOL)isOpen;

@end

@interface NEGroupCallKit : NSObject <NIMSDKConfigDelegate>

@property(nonatomic, strong, readonly) NSString *callId;

+ (instancetype)sharedInstance;

/// 多人音视频呼叫
/// @param param 呼叫入参
/// @param completion 回调
- (void)groupCall:(GroupCallParam *)param
       completion:(nullable void (^)(NSError *_Nullable error,
                                     GroupCallResult *_Nullable result))completion;

/// 挂断
/// @param param 挂断入参
/// @param completion 回调
- (void)groupHangup:(GroupHangupParam *)param
         completion:(nullable void (^)(NSError *_Nullable error,
                                       GroupHangupResult *_Nullable result))completion;

/// 接受呼叫邀请
/// @param param 接受入参
/// @param completion 回调
- (void)groupAccept:(GroupAcceptParam *)param
         completion:(nullable void (^)(NSError *_Nullable error,
                                       GroupAcceptResult *_Nullable result))completion;

/// 邀请他人加入多人通话
/// @param param 邀请入参
/// @param completion 回调
- (void)groupInvite:(GroupInviteParam *)param
         completion:(nullable void (^)(NSError *_Nullable error,
                                       GroupInviteResult *_Nullable result))completion;

/// 主动加入多人通话
/// @param param 加入入参
/// @param completion 回调
- (void)groupJoin:(GroupJoinParam *)param
       completion:(nullable void (^)(NSError *_Nullable error,
                                     GroupJoinResult *_Nullable result))completion;

/// 查询多人通话信息
/// @param param 查询入参
/// @param completion 回调
- (void)groupQueryCallInfo:(GroupQueryCallInfoParam *)param
                completion:
                    (nullable void (^)(NSError *_Nullable error,
                                       GroupQueryCallInfoResult *_Nullable result))completion;

/// 查询多人通话成员列表
/// @param param 查询入参
/// @param completion 回调
- (void)groupQueryMembers:(GroupQueryMembersParam *)param
               completion:(nullable void (^)(NSError *_Nullable error,
                                             GroupQueryMembersResult *_Nullable result))completion;

/// 多人通话设置
/// @param param 设置参数
- (void)setupGroupCall:(GroupConfigParam *)param;

/// 添加代理 接受回调
/// @param delegate 代理对象
- (void)addDelegate:(id<NEGroupCallKitDelegate>)delegate;

/// 移除代理
/// @param delegate 代理对象
- (void)removeDelegate:(id<NEGroupCallKitDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
