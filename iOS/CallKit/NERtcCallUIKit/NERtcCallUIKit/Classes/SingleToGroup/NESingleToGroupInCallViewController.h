// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import <NERtcCallKit/NERtcCallKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NESingleToGroupInCallViewController : UIViewController

- (void)reloadWithMembers:(NSArray<NECallMemberInfo *> *)members callType:(NECallType)callType;

- (void)reloadWithMembers:(NSArray<NECallMemberInfo *> *)members
                 callType:(NECallType)callType
           elapsedSeconds:(NSInteger)elapsedSeconds;

- (void)updateMemberVideoMuted:(BOOL)muted userID:(NSString *)userID;

- (void)syncInitialMediaStateWithCurrentUser:(nullable NSString *)currentUser
                                  remoteUser:(nullable NSString *)remoteUser
                            currentUserRtcUid:(uint64_t)currentUserRtcUid
                                remoteRtcUid:(uint64_t)remoteRtcUid
                            currentVideoMuted:(BOOL)currentVideoMuted
                              remoteVideoMuted:(BOOL)remoteVideoMuted
                            currentAudioMuted:(BOOL)currentAudioMuted;

@end

NS_ASSUME_NONNULL_END
