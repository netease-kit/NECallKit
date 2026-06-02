// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import <NERtcCallKit/NERtcCallKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NEAISubtitleView;
@class NECallUIConfig;
@class NECustomButton;
@class NEUICallParam;
@class NEVideoOperationView;

@interface NESingleToGroupCoordinator : NSObject

@property(nonatomic, assign, readonly) BOOL hasEnteredSingleToGroupMode;
@property(nonatomic, copy, nullable) void (^willStartInviteHandler)(NSString *reason);

- (instancetype)initWithHostViewController:(UIViewController *)hostViewController
                             containerView:(UIView *)containerView
                                 callParam:(NEUICallParam *)callParam
                                    config:(NECallUIConfig *)config
                                    bundle:(NSBundle *)bundle NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (void)installMultiController;

- (void)installInviteEntryAboveOperationView:(NEVideoOperationView *)operationView;

- (void)updateInviteEntryLayoutForMultiMode:(BOOL)isMultiMode;

- (void)configureControlsWithOperationView:(NEVideoOperationView *)operationView
                         mediaSwitchButton:(NECustomButton *)mediaSwitchButton
                            aiSubtitleView:(NEAISubtitleView *)aiSubtitleView;

- (void)hideInviteEntry;

- (void)hideMultiController;

- (void)updateInviteEntryWithStatus:(NERtcCallStatus)status isSmallWindow:(BOOL)isSmallWindow;

- (void)enterModeWithMembers:(NSArray<NECallMemberInfo *> *)members
                    callType:(NECallType)callType
                   stateView:(nullable UIView *)stateView
                      status:(NERtcCallStatus)status
               isSmallWindow:(BOOL)isSmallWindow;

- (void)enterModeWithMembers:(NSArray<NECallMemberInfo *> *)members
                    callType:(NECallType)callType
                   stateView:(nullable UIView *)stateView
                      status:(NERtcCallStatus)status
               isSmallWindow:(BOOL)isSmallWindow
              elapsedSeconds:(NSInteger)elapsedSeconds;

- (void)handleModeChanged:(NECallModeChangeInfo *)info
                 callType:(NECallType)callType
                stateView:(nullable UIView *)stateView
                   status:(NERtcCallStatus)status
            isSmallWindow:(BOOL)isSmallWindow;

- (void)handleModeChanged:(NECallModeChangeInfo *)info
                 callType:(NECallType)callType
                stateView:(nullable UIView *)stateView
                   status:(NERtcCallStatus)status
            isSmallWindow:(BOOL)isSmallWindow
           elapsedSeconds:(NSInteger)elapsedSeconds;

- (void)handleMembersChanged:(NECallMemberChangeInfo *)info
                    callType:(NECallType)callType
                   stateView:(nullable UIView *)stateView
                      status:(NERtcCallStatus)status
               isSmallWindow:(BOOL)isSmallWindow;

- (void)handleMembersChanged:(NECallMemberChangeInfo *)info
                    callType:(NECallType)callType
                   stateView:(nullable UIView *)stateView
                      status:(NERtcCallStatus)status
               isSmallWindow:(BOOL)isSmallWindow
              elapsedSeconds:(NSInteger)elapsedSeconds;

- (void)handleInviteStateChanged:(NSArray<NECallInviteStateInfo *> *)infos
                        callType:(NECallType)callType
                       stateView:(nullable UIView *)stateView
                          status:(NERtcCallStatus)status
                   isSmallWindow:(BOOL)isSmallWindow;

- (void)handleInviteStateChanged:(NSArray<NECallInviteStateInfo *> *)infos
                        callType:(NECallType)callType
                       stateView:(nullable UIView *)stateView
                          status:(NERtcCallStatus)status
                   isSmallWindow:(BOOL)isSmallWindow
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
