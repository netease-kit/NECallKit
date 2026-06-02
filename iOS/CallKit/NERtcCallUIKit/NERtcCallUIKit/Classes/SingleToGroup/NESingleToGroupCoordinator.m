// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NESingleToGroupCoordinator.h"
#import <NECommonUIKit/UIView+YXToast.h>
#import <NIMSDK/NIMSDK.h>
#import <NEXKitBase/NEXKitBase.h>
#import "NEAISubtitleView.h"
#import "NECallInviteUIContext.h"
#import "NECallKitUtil.h"
#import "NECallUIKitConfig.h"
#import "NECustomButton.h"
#import "NEExpandButton.h"
#import "NERtcCallUIKit.h"
#import "NESingleToGroupInCallViewController.h"
#import "NEUICallParam.h"
#import "NEVideoOperationView.h"
#import "NetManager.h"

@interface NESingleToGroupInviteFilterResult : NSObject

@property(nonatomic, copy) NSArray<NSString *> *userIDs;
@property(nonatomic, assign) BOOL hasAdded;
@property(nonatomic, assign) BOOL hasInCall;

@end

@implementation NESingleToGroupInviteFilterResult
@end

@interface NESingleToGroupCoordinator ()

@property(nonatomic, weak) UIViewController *hostViewController;
@property(nonatomic, weak) UIView *containerView;
@property(nonatomic, weak) NEVideoOperationView *operationView;
@property(nonatomic, weak) NECustomButton *mediaSwitchButton;
@property(nonatomic, weak) NEAISubtitleView *aiSubtitleView;
@property(nonatomic, strong) NEUICallParam *callParam;
@property(nonatomic, strong) NECallUIConfig *config;
@property(nonatomic, strong) NSBundle *bundle;
@property(nonatomic, strong) UIButton *inviteMembersButton;
@property(nonatomic, strong) NESingleToGroupInCallViewController *multiController;
@property(nonatomic, assign) BOOL multiStyleApplied;
@property(nonatomic, strong) NSMutableSet<NSString *> *closedInvitees;
@property(nonatomic, strong) NSLayoutConstraint *inviteButtonTopConstraint;
@property(nonatomic, strong) NSLayoutConstraint *inviteButtonRightConstraint;
@property(nonatomic, copy) NSString *lastInviteEntryLogState;

@end

@implementation NESingleToGroupCoordinator

- (instancetype)initWithHostViewController:(UIViewController *)hostViewController
                             containerView:(UIView *)containerView
                                 callParam:(NEUICallParam *)callParam
                                    config:(NECallUIConfig *)config
                                    bundle:(NSBundle *)bundle {
  self = [super init];
  if (self) {
    _hostViewController = hostViewController;
    _containerView = containerView;
    _callParam = callParam;
    _config = config;
    _bundle = bundle;
    _closedInvitees = [[NSMutableSet alloc] init];
  }
  return self;
}

- (BOOL)hasEnteredSingleToGroupMode {
  return self.multiStyleApplied || self.multiController.view.hidden == NO;
}

- (void)installMultiController {
  if (self.multiController.parentViewController != nil || self.hostViewController == nil ||
      self.containerView == nil) {
    return;
  }
  [self.hostViewController addChildViewController:self.multiController];
  self.multiController.view.frame = self.containerView.bounds;
  self.multiController.view.autoresizingMask =
      UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.containerView addSubview:self.multiController.view];
  self.multiController.view.hidden = YES;
}

- (void)installInviteEntryAboveOperationView:(NEVideoOperationView *)operationView {
  if (self.containerView == nil || self.inviteMembersButton.superview != nil) {
    return;
  }
  [self.containerView addSubview:self.inviteMembersButton];
  self.inviteButtonTopConstraint =
      [self.inviteMembersButton.topAnchor constraintEqualToAnchor:self.containerView.topAnchor
                                                         constant:[self inviteButtonTopConstantForMultiMode:NO]];
  self.inviteButtonRightConstraint =
      [self.inviteMembersButton.rightAnchor constraintEqualToAnchor:self.containerView.rightAnchor
                                                           constant:[self inviteButtonRightConstantForMultiMode:NO]];
  [NSLayoutConstraint activateConstraints:@[
    self.inviteButtonTopConstraint,
    self.inviteButtonRightConstraint,
    [self.inviteMembersButton.widthAnchor constraintEqualToConstant:40],
    [self.inviteMembersButton.heightAnchor constraintEqualToConstant:40]
  ]];
}

- (void)updateInviteEntryLayoutForMultiMode:(BOOL)isMultiMode {
  self.inviteButtonTopConstraint.constant = [self inviteButtonTopConstantForMultiMode:isMultiMode];
  self.inviteButtonRightConstraint.constant =
      [self inviteButtonRightConstantForMultiMode:isMultiMode];
}

- (CGFloat)inviteButtonTopConstantForMultiMode:(BOOL)isMultiMode {
  if (isMultiMode) {
    return 56;
  }
  return [UIApplication sharedApplication].statusBarFrame.size.height + 20;
}

- (CGFloat)inviteButtonRightConstantForMultiMode:(BOOL)isMultiMode {
  return isMultiMode ? -12 : -20;
}

- (void)configureControlsWithOperationView:(NEVideoOperationView *)operationView
                         mediaSwitchButton:(NECustomButton *)mediaSwitchButton
                            aiSubtitleView:(NEAISubtitleView *)aiSubtitleView {
  self.operationView = operationView;
  self.mediaSwitchButton = mediaSwitchButton;
  self.aiSubtitleView = aiSubtitleView;
}

- (void)hideInviteEntry {
  self.inviteMembersButton.hidden = YES;
}

- (void)hideMultiController {
  self.multiController.view.hidden = YES;
}

- (void)updateInviteEntryWithStatus:(NERtcCallStatus)status isSmallWindow:(BOOL)isSmallWindow {
  if (status != NERtcCallStatusInCall || isSmallWindow == YES) {
    NSString *logState = [NSString stringWithFormat:@"hide|%ld|%d", (long)status, isSmallWindow];
    if (![self.lastInviteEntryLogState isEqualToString:logState]) {
      NEXKitBaseLogInfo(@"SingleToGroup UI hide invite entry status:%ld isSmallWindow:%d",
                        (long)status, isSmallWindow);
      self.lastInviteEntryLogState = logState;
    }
    self.inviteMembersButton.hidden = YES;
    return;
  }
  id<NECallUIKitDelegate> delegate = [NERtcCallUIKit sharedInstance].delegate;
  BOOL hasSelector =
      delegate != nil &&
      [delegate respondsToSelector:@selector(selectInviteUsersWithContext:completion:)];
  BOOL enabled = self.config.singleToGroupInviteMode ==
                 NECallSingleToGroupInviteModeAfter1V1Connected;
  BOOL capabilityReady = [[NECallEngine sharedInstance] canInviteMembers];
  NSInteger remainingCount = [self remainingInviteCount];
  BOOL shouldShow = enabled && hasSelector && capabilityReady && remainingCount > 0;
  self.inviteMembersButton.hidden = !shouldShow;
  NSString *logState = [NSString stringWithFormat:@"show=%d|enabled=%d|selector=%d|cap=%d|"
                                                 @"remain=%ld|status=%ld|small=%d",
                                                 shouldShow, enabled, hasSelector, capabilityReady,
                                                 (long)remainingCount, (long)status, isSmallWindow];
  if (![self.lastInviteEntryLogState isEqualToString:logState]) {
    NEXKitBaseLogInfo(@"SingleToGroup UI update invite entry show:%d enabled:%d hasSelector:%d "
                      @"capabilityReady:%d remaining:%ld status:%ld isSmallWindow:%d",
                      shouldShow, enabled, hasSelector, capabilityReady, (long)remainingCount,
                      (long)status, isSmallWindow);
    self.lastInviteEntryLogState = logState;
  }
}

- (void)enterModeWithMembers:(NSArray<NECallMemberInfo *> *)members
                    callType:(NECallType)callType
                   stateView:(UIView *)stateView
                      status:(NERtcCallStatus)status
               isSmallWindow:(BOOL)isSmallWindow {
  [self enterModeWithMembers:members
                    callType:callType
                   stateView:stateView
                      status:status
               isSmallWindow:isSmallWindow
              elapsedSeconds:0];
}

- (void)enterModeWithMembers:(NSArray<NECallMemberInfo *> *)members
                    callType:(NECallType)callType
                   stateView:(UIView *)stateView
                      status:(NERtcCallStatus)status
               isSmallWindow:(BOOL)isSmallWindow
              elapsedSeconds:(NSInteger)elapsedSeconds {
  NSArray<NECallMemberInfo *> *visibleMembers = [self visibleMembersFromMembers:members];
  self.multiController.view.hidden = NO;
  self.operationView.hidden = NO;
  stateView.hidden = YES;
  self.aiSubtitleView.hidden = YES;
  [self.operationView setSingleToGroupStyle];
  if (!self.multiStyleApplied) {
    self.mediaSwitchButton.hidden = YES;
    self.multiStyleApplied = YES;
    NEXKitBaseLogInfo(@"SingleToGroup UI apply operation style with disabled switch.");
  }
  [self.multiController reloadWithMembers:visibleMembers
                                 callType:callType
                           elapsedSeconds:elapsedSeconds];
  [self updateInviteEntryWithStatus:status isSmallWindow:isSmallWindow];
}

- (void)handleModeChanged:(NECallModeChangeInfo *)info
                 callType:(NECallType)callType
                stateView:(UIView *)stateView
                   status:(NERtcCallStatus)status
            isSmallWindow:(BOOL)isSmallWindow {
  [self handleModeChanged:info
                 callType:callType
                stateView:stateView
                   status:status
            isSmallWindow:isSmallWindow
           elapsedSeconds:0];
}

- (void)handleModeChanged:(NECallModeChangeInfo *)info
                 callType:(NECallType)callType
                stateView:(UIView *)stateView
                   status:(NERtcCallStatus)status
            isSmallWindow:(BOOL)isSmallWindow
           elapsedSeconds:(NSInteger)elapsedSeconds {
  if (info.newMode != NECallModeMulti) {
    return;
  }
  NEXKitBaseLogInfo(@"SingleToGroup UI onCallModeChanged, memberCount:%ld",
                    (long)info.memberCount);
  [self enterModeWithMembers:[[NECallEngine sharedInstance] currentMembers]
                    callType:callType
                   stateView:stateView
                      status:status
               isSmallWindow:isSmallWindow
              elapsedSeconds:elapsedSeconds];
}

- (void)handleMembersChanged:(NECallMemberChangeInfo *)info
                    callType:(NECallType)callType
                   stateView:(UIView *)stateView
                      status:(NERtcCallStatus)status
               isSmallWindow:(BOOL)isSmallWindow {
  [self handleMembersChanged:info
                    callType:callType
                   stateView:stateView
                      status:status
               isSmallWindow:isSmallWindow
              elapsedSeconds:0];
}

- (void)handleMembersChanged:(NECallMemberChangeInfo *)info
                    callType:(NECallType)callType
                   stateView:(UIView *)stateView
                      status:(NERtcCallStatus)status
               isSmallWindow:(BOOL)isSmallWindow
              elapsedSeconds:(NSInteger)elapsedSeconds {
  if (![[NECallEngine sharedInstance] isInMultiCall]) {
    return;
  }
  NSArray<NECallMemberInfo *> *members =
      info.members ?: [[NECallEngine sharedInstance] currentMembers];
  NEXKitBaseLogInfo(@"SingleToGroup UI onCallMembersChanged memberCount:%lu changeType:%ld "
                    @"changed:%@ state:%ld uid:%llu",
                    (unsigned long)members.count, (long)info.changeType,
                    info.changedMember.userID, (long)info.changedMember.state,
                    (unsigned long long)info.changedMember.uid);
  BOOL shouldEnterAfterMemberChanged =
      info.changedMember != nil &&
      (info.changeType == NECallMemberChangeTypeJoin ||
       info.changeType == NECallMemberChangeTypeLeave) &&
      (info.changedMember.state == NECallMemberStateJoined ||
       info.changedMember.state == NECallMemberStateLeaving);
  if (self.hasEnteredSingleToGroupMode || members.count >= 3 || shouldEnterAfterMemberChanged ||
      [self shouldEnterModeWithMembers:members]) {
    [self enterModeWithMembers:members
                      callType:callType
                     stateView:stateView
                        status:status
                 isSmallWindow:isSmallWindow
                elapsedSeconds:elapsedSeconds];
  }
  [self updateInviteEntryWithStatus:status isSmallWindow:isSmallWindow];
}

- (void)handleInviteStateChanged:(NSArray<NECallInviteStateInfo *> *)infos
                        callType:(NECallType)callType
                       stateView:(UIView *)stateView
                          status:(NERtcCallStatus)status
                   isSmallWindow:(BOOL)isSmallWindow {
  [self handleInviteStateChanged:infos
                        callType:callType
                       stateView:stateView
                          status:status
                   isSmallWindow:isSmallWindow
                  elapsedSeconds:0];
}

- (void)handleInviteStateChanged:(NSArray<NECallInviteStateInfo *> *)infos
                        callType:(NECallType)callType
                       stateView:(UIView *)stateView
                          status:(NERtcCallStatus)status
                   isSmallWindow:(BOOL)isSmallWindow
                  elapsedSeconds:(NSInteger)elapsedSeconds {
  if (infos.count <= 0) {
    return;
  }
  NECallInfo *callInfo = [[NECallEngine sharedInstance] getCallInfo];
  NSString *currentUserID = callInfo.currentAccId.length > 0
                                ? callInfo.currentAccId
                                : ([NIMSDK.sharedSDK.v2LoginService getLoginUser] ?: @"");
  if (currentUserID.length <= 0) {
    NEXKitBaseLogInfo(@"SingleToGroup UI skip onCallInviteStateChanged for empty currentUser, count:%lu",
                      (unsigned long)infos.count);
    return;
  }
  NSMutableArray<NECallInviteStateInfo *> *currentInviteInfos = [NSMutableArray array];
  for (NECallInviteStateInfo *info in infos) {
    if ([info.inviterUserID isEqualToString:currentUserID]) {
      [currentInviteInfos addObject:info];
    }
  }
  if (currentInviteInfos.count <= 0) {
    return;
  }
  NSMutableArray<NSString *> *inviteStateLogs = [[NSMutableArray alloc] init];
  for (NECallInviteStateInfo *info in currentInviteInfos) {
    [inviteStateLogs addObject:[NSString stringWithFormat:@"%@:state=%ld:reason=%ld",
                                                          info.inviteeUserID ?: @"",
                                                          (long)info.state,
                                                          (long)info.reasonCode]];
  }
  NEXKitBaseLogInfo(@"SingleToGroup UI onCallInviteStateChanged count:%lu infos:[%@]",
                    (unsigned long)currentInviteInfos.count,
                    [inviteStateLogs componentsJoinedByString:@","]);
  BOOL needsReloadMembers = NO;
  for (NECallInviteStateInfo *info in currentInviteInfos) {
    if ((info.state == NECallInviteStateSent || info.state == NECallInviteStateJoined) &&
        info.inviteeUserID.length > 0) {
      [self.closedInvitees removeObject:info.inviteeUserID];
      needsReloadMembers = YES;
    } else if ([self isClosedInviteState:info.state] && info.inviteeUserID.length > 0) {
      [self.closedInvitees addObject:info.inviteeUserID];
      needsReloadMembers = YES;
    }
  }
  NSArray<NECallMemberInfo *> *members = [[NECallEngine sharedInstance] currentMembers];
  BOOL shouldEnterMode = [self shouldEnterModeWithMembers:members];
  BOOL shouldRefreshEnteredMode = needsReloadMembers && self.hasEnteredSingleToGroupMode;
  if (shouldEnterMode || shouldRefreshEnteredMode) {
    NEXKitBaseLogInfo(@"SingleToGroup UI refresh members after invite state, memberCount:%lu "
                      @"closedInvitees:%lu shouldEnter:%d entered:%d",
                      (unsigned long)members.count, (unsigned long)self.closedInvitees.count,
                      shouldEnterMode, self.hasEnteredSingleToGroupMode);
    [self enterModeWithMembers:members
                      callType:callType
                     stateView:stateView
                        status:status
                 isSmallWindow:isSmallWindow
                elapsedSeconds:elapsedSeconds];
  } else if (needsReloadMembers) {
    NEXKitBaseLogInfo(@"SingleToGroup UI skip entering mode after invite state, memberCount:%lu "
                      @"closedInvitees:%lu",
                      (unsigned long)members.count, (unsigned long)self.closedInvitees.count);
  }
  [self updateInviteEntryWithStatus:status isSmallWindow:isSmallWindow];
  NSString *toastMessage = [self toastMessageForInviteStateInfos:currentInviteInfos];
  if (toastMessage.length > 0) {
    [self.hostViewController.view ne_makeToast:toastMessage];
  }
}

- (void)updateMemberVideoMuted:(BOOL)muted userID:(NSString *)userID {
  [self.multiController updateMemberVideoMuted:muted userID:userID];
}

- (void)syncInitialMediaStateWithCurrentUser:(NSString *)currentUser
                                  remoteUser:(NSString *)remoteUser
                            currentUserRtcUid:(uint64_t)currentUserRtcUid
                                remoteRtcUid:(uint64_t)remoteRtcUid
                            currentVideoMuted:(BOOL)currentVideoMuted
                              remoteVideoMuted:(BOOL)remoteVideoMuted
                            currentAudioMuted:(BOOL)currentAudioMuted {
  [self.multiController syncInitialMediaStateWithCurrentUser:currentUser
                                                  remoteUser:remoteUser
                                            currentUserRtcUid:currentUserRtcUid
                                                remoteRtcUid:remoteRtcUid
                                            currentVideoMuted:currentVideoMuted
                                              remoteVideoMuted:remoteVideoMuted
                                            currentAudioMuted:currentAudioMuted];
}

- (void)inviteMembersButtonClick:(UIButton *)button {
  if ([[NetManager shareInstance] isClose] == YES) {
    [self.hostViewController.view ne_makeToast:[NECallKitUtil localizableWithKey:@"network_error"]];
    return;
  }
  NSInteger remainingCount = [self remainingInviteCount];
  if (remainingCount <= 0) {
    [self.hostViewController.view
        ne_makeToast:[NECallKitUtil localizableWithKey:@"ui_member_exceed_limit"]];
    [self updateInviteEntryWithStatus:NERtcCallStatusInCall isSmallWindow:NO];
    return;
  }
  if (![[NECallEngine sharedInstance] canInviteMembers]) {
    [self.hostViewController.view
        ne_makeToast:[NECallKitUtil localizableWithKey:@"single_to_group_invite_unsupported"]];
    [self updateInviteEntryWithStatus:NERtcCallStatusInCall isSmallWindow:NO];
    return;
  }
  if (self.willStartInviteHandler) {
    self.willStartInviteHandler(@"showInviteSelector");
  }
  id<NECallUIKitDelegate> delegate = [NERtcCallUIKit sharedInstance].delegate;
  if (delegate == nil ||
      [delegate respondsToSelector:@selector(selectInviteUsersWithContext:completion:)] == NO) {
    NEXKitBaseLogInfo(@"SingleToGroup UI invite selector is not configured.");
    [self updateInviteEntryWithStatus:NERtcCallStatusInCall isSmallWindow:NO];
    return;
  }
  NECallInviteUIContext *context = [self buildInviteUIContextWithRemainingCount:remainingCount];
  NEXKitBaseLogInfo(@"SingleToGroup UI invite selector start callId:%@ channelId:%@ "
                    @"remaining:%ld max:%ld inCallCount:%ld",
                    context.callId, context.channelId, (long)context.remainingCount,
                    (long)context.maxMembers, (long)context.inCallUserIDs.count);
  __weak typeof(self) weakSelf = self;
  [delegate selectInviteUsersWithContext:context
                              completion:^(NSArray<NSString *> *_Nullable userIDs) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                  NESingleToGroupInviteFilterResult *filterResult =
                                      [weakSelf filterInviteUserIDs:userIDs];
                                  NSArray<NSString *> *inviteUserIDs = filterResult.userIDs;
                                  NEXKitBaseLogInfo(
                                      @"SingleToGroup UI invite selector result selectedCount:%lu "
                                      @"invitees:%@ filteredAdded:%d filteredInCall:%d",
                                      (unsigned long)userIDs.count, inviteUserIDs,
                                      filterResult.hasAdded, filterResult.hasInCall);
                                  [weakSelf showInviteFilterToastIfNeeded:filterResult];
                                  if (inviteUserIDs.count <= 0) {
                                    NEXKitBaseLogInfo(
                                        @"SingleToGroup UI invite selector canceled or empty.");
                                    return;
                                  }
                                  if (inviteUserIDs.count > remainingCount) {
                                    [weakSelf.hostViewController.view
                                        ne_makeToast:[NECallKitUtil
                                                         localizableWithKey:
                                                             @"ui_member_exceed_limit"]];
                                    [weakSelf updateInviteEntryWithStatus:NERtcCallStatusInCall
                                                            isSmallWindow:NO];
                                    return;
                                  }
                                  [weakSelf inviteMembers:inviteUserIDs];
                                });
                              }];
}

- (void)inviteMembers:(NSArray<NSString *> *)inviteUserIDs {
  if (self.willStartInviteHandler) {
    self.willStartInviteHandler(@"inviteMembers");
  }
  NECallInviteParam *param = [[NECallInviteParam alloc] init];
  param.userIDs = inviteUserIDs;
  param.attachment = self.callParam.attachment;
  param.globalExtra = self.callParam.extra;
  param.pushConfig = self.callParam.pushConfig;
  param.maxMembers = kGroupCallMaxUsers;
  NEXKitBaseLogInfo(@"SingleToGroup UI invite button send, count:%lu",
                    (unsigned long)inviteUserIDs.count);
  __weak typeof(self) weakSelf = self;
  [[NECallEngine sharedInstance] inviteMembers:param
                                    completion:^(NSError *_Nullable error,
                                                 NECallInviteResult *_Nullable result) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                        if (error == nil &&
                                            [weakSelf successCountForInviteResult:result] > 0) {
                                          [weakSelf.closedInvitees
                                              minusSet:[NSSet setWithArray:inviteUserIDs]];
                                        }
                                        [weakSelf showInviteToastWithError:error result:result];
                                        [weakSelf updateInviteEntryWithStatus:NERtcCallStatusInCall
                                                                isSmallWindow:NO];
                                      });
                                    }];
}

- (NSInteger)remainingInviteCount {
  NSMutableSet<NSString *> *visibleUsers = [[NSMutableSet alloc] init];
  for (NECallMemberInfo *member in [[NECallEngine sharedInstance] currentMembers]) {
    if (member.userID.length > 0 && member.state != NECallMemberStateLeaving) {
      [visibleUsers addObject:member.userID];
    }
  }
  NSInteger currentCount = MAX((NSInteger)visibleUsers.count, 2);
  return MAX(kGroupCallMaxUsers - currentCount, 0);
}

- (NSArray<NSString *> *)currentInviteExcludedUserIDs {
  NSMutableOrderedSet<NSString *> *excluded = [[NSMutableOrderedSet alloc] init];
  NSString *currentUser = [NIMSDK.sharedSDK.v2LoginService getLoginUser];
  if (currentUser.length > 0) {
    [excluded addObject:currentUser];
  }
  NECallInfo *callInfo = [[NECallEngine sharedInstance] getCallInfo];
  if (callInfo.currentAccId.length > 0) {
    [excluded addObject:callInfo.currentAccId];
  }
  for (NECallMemberInfo *member in [[NECallEngine sharedInstance] currentMembers]) {
    if (member.userID.length > 0 && member.state != NECallMemberStateLeaving) {
      [excluded addObject:member.userID];
    }
  }
  return excluded.array.copy;
}

- (NSDictionary<NSString *, NSSet<NSString *> *> *)currentInviteFilterUsers {
  NSMutableSet<NSString *> *addedUsers = [[NSMutableSet alloc] init];
  NSMutableSet<NSString *> *inCallUsers = [[NSMutableSet alloc] init];
  NSString *currentUser = [NIMSDK.sharedSDK.v2LoginService getLoginUser];
  if (currentUser.length > 0) {
    [inCallUsers addObject:currentUser];
  }
  NECallInfo *callInfo = [[NECallEngine sharedInstance] getCallInfo];
  if (callInfo.currentAccId.length > 0) {
    [inCallUsers addObject:callInfo.currentAccId];
  }
  for (NECallMemberInfo *member in [[NECallEngine sharedInstance] currentMembers]) {
    if (member.userID.length <= 0) {
      continue;
    }
    if (member.state == NECallMemberStateWaiting) {
      [addedUsers addObject:member.userID];
    } else if (member.state == NECallMemberStateJoined) {
      [inCallUsers addObject:member.userID];
    }
  }
  return @{@"added" : addedUsers.copy, @"inCall" : inCallUsers.copy};
}

- (NECallInviteUIContext *)buildInviteUIContextWithRemainingCount:(NSInteger)remainingCount {
  NECallInfo *callInfo = [[NECallEngine sharedInstance] getCallInfo];
  NECallInviteUIContext *context = [[NECallInviteUIContext alloc] init];
  context.callId = callInfo.callId ?: @"";
  context.channelId = callInfo.signalInfo.channelId;
  context.currentUserID = callInfo.currentAccId.length > 0
                              ? callInfo.currentAccId
                              : ([NIMSDK.sharedSDK.v2LoginService getLoginUser] ?: @"");
  context.inCallUserIDs = [self currentInviteExcludedUserIDs];
  context.remainingCount = remainingCount;
  context.maxMembers = kGroupCallMaxUsers;
  return context;
}

- (NESingleToGroupInviteFilterResult *)filterInviteUserIDs:(NSArray<NSString *> *)userIDs {
  NESingleToGroupInviteFilterResult *filterResult =
      [[NESingleToGroupInviteFilterResult alloc] init];
  if (userIDs.count <= 0) {
    filterResult.userIDs = @[];
    return filterResult;
  }
  NSDictionary<NSString *, NSSet<NSString *> *> *filterUsers = [self currentInviteFilterUsers];
  NSSet<NSString *> *addedUsers = filterUsers[@"added"] ?: [NSSet set];
  NSSet<NSString *> *inCallUsers = filterUsers[@"inCall"] ?: [NSSet set];
  NSMutableArray<NSString *> *result = [[NSMutableArray alloc] init];
  NSMutableSet<NSString *> *seen = [[NSMutableSet alloc] init];
  for (NSString *raw in userIDs) {
    if (![raw isKindOfClass:NSString.class]) {
      continue;
    }
    NSString *userID = [raw stringByTrimmingCharactersInSet:
                                NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (userID.length <= 0) {
      continue;
    }
    if ([addedUsers containsObject:userID]) {
      filterResult.hasAdded = YES;
      continue;
    }
    if ([inCallUsers containsObject:userID]) {
      filterResult.hasInCall = YES;
      continue;
    }
    if ([seen containsObject:userID]) {
      filterResult.hasAdded = YES;
      continue;
    }
    [seen addObject:userID];
    [result addObject:userID];
  }
  filterResult.userIDs = result.copy;
  return filterResult;
}

- (void)showInviteFilterToastIfNeeded:(NESingleToGroupInviteFilterResult *)filterResult {
  if (filterResult.hasInCall) {
    [self.hostViewController.view
        ne_makeToast:[NECallKitUtil
                         localizableWithKey:@"single_to_group_invite_already_in_call"]];
  } else if (filterResult.hasAdded) {
    [self.hostViewController.view
        ne_makeToast:[NECallKitUtil localizableWithKey:@"single_to_group_invite_already_added"]];
  }
}

- (void)showInviteToastWithError:(NSError *)error result:(NECallInviteResult *)result {
  if (error != nil) {
    [self.hostViewController.view ne_makeToast:error.localizedDescription];
    return;
  }
  NSInteger successCount = [self successCountForInviteResult:result];
  NSInteger failedCount = [self failedCountForInviteResult:result];
  if (successCount > 0 && failedCount > 0) {
    [self.hostViewController.view
        ne_makeToast:[NECallKitUtil localizableWithKey:@"single_to_group_invite_partial"]];
    return;
  }
  if (failedCount > 0 || successCount <= 0) {
    [self.hostViewController.view
        ne_makeToast:[NECallKitUtil localizableWithKey:@"single_to_group_invite_failed"]];
    return;
  }
  [self.hostViewController.view
      ne_makeToast:[NECallKitUtil localizableWithKey:@"single_to_group_invite_success"]];
}

- (NSInteger)successCountForInviteResult:(NECallInviteResult *)result {
  NSInteger count = 0;
  for (NECallInviteItemResult *item in result.results) {
    if (item.isSuccess) {
      count += 1;
    }
  }
  return count;
}

- (NSInteger)failedCountForInviteResult:(NECallInviteResult *)result {
  NSInteger count = 0;
  for (NECallInviteItemResult *item in result.results) {
    if (!item.isSuccess) {
      count += 1;
    }
  }
  return count;
}

- (NSString *)toastMessageForInviteStateInfo:(NECallInviteStateInfo *)info {
  switch (info.state) {
    case NECallInviteStateRejected:
      return [NECallKitUtil localizableWithKey:@"single_to_group_invite_rejected"];
    case NECallInviteStateTimeout:
      return [NECallKitUtil localizableWithKey:@"single_to_group_invite_timeout"];
    case NECallInviteStateBusy:
      return [NECallKitUtil localizableWithKey:@"single_to_group_invite_busy"];
    case NECallInviteStateFailed:
      return info.message.length > 0
                 ? info.message
                 : [NECallKitUtil localizableWithKey:@"single_to_group_invite_failed"];
    case NECallInviteStateCanceled:
      return [NECallKitUtil localizableWithKey:@"single_to_group_invite_canceled"];
    case NECallInviteStateUnsupported:
      if (info.inviteeUserID.length > 0) {
        NSString *format =
            [NECallKitUtil localizableWithKey:@"single_to_group_invite_peer_unsupported"];
        return [NSString stringWithFormat:format, info.inviteeUserID];
      }
      return [NECallKitUtil localizableWithKey:@"single_to_group_invite_unsupported"];
    case NECallInviteStateSent:
    case NECallInviteStateJoined:
    default:
      return nil;
  }
}

- (NSString *)toastMessageForInviteStateInfos:(NSArray<NECallInviteStateInfo *> *)infos {
  for (NECallInviteStateInfo *info in infos) {
    NSString *message = [self toastMessageForInviteStateInfo:info];
    if (message.length > 0) {
      return message;
    }
  }
  return nil;
}

- (BOOL)isClosedInviteState:(NECallInviteState)state {
  switch (state) {
    case NECallInviteStateRejected:
    case NECallInviteStateTimeout:
    case NECallInviteStateBusy:
    case NECallInviteStateFailed:
    case NECallInviteStateCanceled:
    case NECallInviteStateUnsupported:
      return YES;
    case NECallInviteStateSent:
    case NECallInviteStateJoined:
    default:
      return NO;
  }
}

- (NSArray<NECallMemberInfo *> *)visibleMembersFromMembers:(NSArray<NECallMemberInfo *> *)members {
  if (self.closedInvitees.count <= 0) {
    return members;
  }
  NECallInfo *callInfo = [[NECallEngine sharedInstance] getCallInfo];
  NSString *currentUserID = callInfo.currentAccId.length > 0
                                ? callInfo.currentAccId
                                : ([NIMSDK.sharedSDK.v2LoginService getLoginUser] ?: @"");
  NSMutableArray<NECallMemberInfo *> *visibleMembers = [NSMutableArray array];
  for (NECallMemberInfo *member in members) {
    if (member.state == NECallMemberStateWaiting &&
        [self.closedInvitees containsObject:member.userID ?: @""] &&
        [member.inviterUserID isEqualToString:currentUserID]) {
      NEXKitBaseLogInfo(@"SingleToGroup UI hide closed waiting invitee:%@ inviter:%@ current:%@",
                        member.userID, member.inviterUserID, currentUserID);
      continue;
    }
    [visibleMembers addObject:member];
  }
  return visibleMembers.copy;
}

- (BOOL)shouldEnterModeWithMembers:(NSArray<NECallMemberInfo *> *)members {
  if ([[NECallEngine sharedInstance] isInMultiCall] || members.count >= 3) {
    return YES;
  }
  for (NECallMemberInfo *member in members) {
    if (member.state == NECallMemberStateWaiting) {
      return YES;
    }
  }
  return NO;
}

- (UIButton *)inviteMembersButton {
  if (!_inviteMembersButton) {
    _inviteMembersButton = [[NEExpandButton alloc] init];
    _inviteMembersButton.translatesAutoresizingMaskIntoConstraints = NO;
    UIImage *image = [UIImage imageNamed:@"group_add"
                                 inBundle:self.bundle
            compatibleWithTraitCollection:nil];
    if (image != nil) {
      [_inviteMembersButton setImage:image forState:UIControlStateNormal];
    } else {
      [_inviteMembersButton setTitle:@"+" forState:UIControlStateNormal];
      _inviteMembersButton.titleLabel.font = [UIFont systemFontOfSize:26 weight:UIFontWeightMedium];
      [_inviteMembersButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    }
    _inviteMembersButton.accessibilityIdentifier = @"single_to_group_invite";
    _inviteMembersButton.hidden = YES;
    [_inviteMembersButton addTarget:self
                             action:@selector(inviteMembersButtonClick:)
                   forControlEvents:UIControlEventTouchUpInside];
  }
  return _inviteMembersButton;
}

- (NESingleToGroupInCallViewController *)multiController {
  if (!_multiController) {
    _multiController = [[NESingleToGroupInCallViewController alloc] init];
  }
  return _multiController;
}

@end
