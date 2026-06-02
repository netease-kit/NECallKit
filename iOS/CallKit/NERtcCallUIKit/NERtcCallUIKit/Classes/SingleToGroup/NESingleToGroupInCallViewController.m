// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NESingleToGroupInCallViewController.h"
#import <NIMSDK/NIMSDK.h>
#import <NEXKitBase/NEXKitBase.h>
#import <NERtcSDK/NERtcSDK.h>
#import "NEGroupCallFlowLayout.h"
#import "NECallStateManager.h"
#import "NEGroupUser.h"
#import "NEGroupUser+Private.h"
#import "NESingleToGroupUserInCallCell.h"

@interface NESingleToGroupInCallViewController () <UICollectionViewDelegate,
                                                   UICollectionViewDataSource,
                                                   UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UILabel *timerLabel;
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, strong) NSMutableArray<NEGroupUser *> *members;
@property(nonatomic, strong) NEGroupCallFlowLayout *layout;
@property(nonatomic, assign) NECallType callType;
@property(nonatomic, assign) NSInteger timerCount;
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *videoMutedStates;
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *audioMutedStates;
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *rtcUidStates;
@property(nonatomic, strong) NSMutableArray<NSString *> *memberDisplayOrder;
@property(nonatomic, strong) NSMutableDictionary<NSString *, NEGroupUser *> *memberProfileCache;
@property(nonatomic, strong) NSMutableSet<NSString *> *fetchingProfileUserIDs;
@property(nonatomic, assign) BOOL updatingLargeView;
@property(nonatomic, assign) NSInteger initialElapsedSeconds;

@end

@implementation NESingleToGroupInCallViewController

- (instancetype)init {
  self = [super init];
  if (self) {
    _members = [[NSMutableArray alloc] init];
    _videoMutedStates = [[NSMutableDictionary alloc] init];
    _audioMutedStates = [[NSMutableDictionary alloc] init];
    _rtcUidStates = [[NSMutableDictionary alloc] init];
    _memberDisplayOrder = [[NSMutableArray alloc] init];
    _memberProfileCache = [[NSMutableDictionary alloc] init];
    _fetchingProfileUserIDs = [[NSMutableSet alloc] init];
    _timerCount = 0;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setupUI];
}

- (void)setupUI {
  self.view.backgroundColor = UIColor.blackColor;
  [self.view addSubview:self.collectionView];
  [NSLayoutConstraint activateConstraints:@[
    [self.collectionView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
    [self.collectionView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
    [self.collectionView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:40],
    [self.collectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
  ]];
  [self.view addSubview:self.timerLabel];
  [NSLayoutConstraint activateConstraints:@[
    [self.timerLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
    [self.timerLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:60]
  ]];
}

- (void)reloadWithMembers:(NSArray<NECallMemberInfo *> *)members callType:(NECallType)callType {
  [self reloadWithMembers:members callType:callType elapsedSeconds:0];
}

- (void)reloadWithMembers:(NSArray<NECallMemberInfo *> *)members
                 callType:(NECallType)callType
           elapsedSeconds:(NSInteger)elapsedSeconds {
  self.callType = callType;
  [self startTimerOnMainThreadWithElapsedSeconds:elapsedSeconds];
  NSString *currentUser = [NIMSDK.sharedSDK.v2LoginService getLoginUser];
  uint64_t currentUid = [self currentRtcUidForUser:currentUser];
  [self resetRemovedRemoteVideoCanvasesWithMembers:members currentUser:currentUser];
  NSArray<NECallMemberInfo *> *orderedMembers = [self orderedMembersKeepingDisplayOrder:members];
  [self fetchUserProfilesIfNeededForMembers:orderedMembers];
  NSMutableArray<NEGroupUser *> *newMembers = [[NSMutableArray alloc] init];

  NSInteger currentIndex = 0;
  for (NECallMemberInfo *memberInfo in orderedMembers) {
    NEGroupUser *user = [[NEGroupUser alloc] init];
    user.imAccid = memberInfo.userID;
    [self applyProfileToUser:user fallbackUserID:memberInfo.userID];
    NSNumber *cachedRtcUid = self.rtcUidStates[memberInfo.userID];
    user.uid = memberInfo.uid > 0 ? memberInfo.uid : cachedRtcUid.unsignedLongLongValue;
    if (user.uid <= 0 && [memberInfo.userID isEqualToString:currentUser]) {
      user.uid = currentUid;
    }
    user.state = memberInfo.state == NECallMemberStateWaiting ? GroupMemberStateWaitting
                                                              : GroupMemberStateInChannel;
    user.isShowLocalVideo = [memberInfo.userID isEqualToString:currentUser];
    NSNumber *cachedMuted = self.videoMutedStates[memberInfo.userID];
    BOOL videoMuted = cachedMuted != nil ? cachedMuted.boolValue : memberInfo.videoMuted;
    BOOL videoAvailable = memberInfo.videoAvailable || cachedMuted != nil;
    user.isOpenVideo = [self isJoinedMemberVideoOpen:memberInfo.state == NECallMemberStateJoined
                                      videoAvailable:videoAvailable
                                      hasCachedMuted:cachedMuted != nil
                                               muted:videoMuted];
    user.originalIndex = currentIndex;
    NEXKitBaseLogInfo(@"SingleToGroup UI build grid member media user:%@ uid:%llu state:%ld "
                      @"callType:%ld memberVideoMuted:%d memberVideoAvailable:%d "
                      @"memberAudioMuted:%d hasCachedVideoMuted:%d hasCachedUid:%d "
                      @"isLocal:%d isOpenVideo:%d",
                      memberInfo.userID, (unsigned long long)user.uid, (long)memberInfo.state,
                      (long)callType, memberInfo.videoMuted, memberInfo.videoAvailable,
                      memberInfo.audioMuted, cachedMuted != nil, cachedRtcUid != nil,
                      user.isShowLocalVideo, user.isOpenVideo);
    [newMembers addObject:user];
    currentIndex++;
  }

  BOOL canRefreshVisibleCells = [self hasSameMemberOrderAsUsers:newMembers];
  NSArray<NSIndexPath *> *deletedIndexPaths = [self deletedIndexPathsForUsers:newMembers];
  NSArray<NSIndexPath *> *insertedIndexPaths = [self insertedIndexPathsForUsers:newMembers];
  BOOL canBatchRefreshMembers = [self canBatchRefreshToUsers:newMembers
                                           deletedIndexPaths:deletedIndexPaths
                                          insertedIndexPaths:insertedIndexPaths];
  BOOL shouldDisableInitialExpansionAnimation = self.members.count == 1 && newMembers.count > 1;
  self.layout.participantCount = newMembers.count;
  if (self.layout.largeViewIndex >= newMembers.count) {
    [self.layout clearLargeView];
  }
  NEXKitBaseLogInfo(@"SingleToGroup UI reload multi grid, memberCount:%lu sourceCount:%lu "
                    @"stableRefresh:%d batchRefresh:%d disableInitialExpansionAnimation:%d "
                    @"deletes:%lu inserts:%lu order:%@",
                    (unsigned long)newMembers.count, (unsigned long)members.count,
                    canRefreshVisibleCells, canBatchRefreshMembers,
                    shouldDisableInitialExpansionAnimation,
                    (unsigned long)deletedIndexPaths.count, (unsigned long)insertedIndexPaths.count,
                    [self currentMemberOrderDescription:newMembers]);
  if (canRefreshVisibleCells) {
    [self replaceMembersWithUsers:newMembers];
    [self refreshAllVisibleCells];
  } else if (shouldDisableInitialExpansionAnimation) {
    [self replaceMembersWithUsers:newMembers];
    [UIView performWithoutAnimation:^{
      [self.collectionView.collectionViewLayout invalidateLayout];
      [self.collectionView reloadData];
      [self.collectionView layoutIfNeeded];
    }];
    [self refreshAllVisibleCells];
  } else if (canBatchRefreshMembers) {
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView
        performBatchUpdates:^{
          [self replaceMembersWithUsers:newMembers];
          if (deletedIndexPaths.count > 0) {
            [self.collectionView deleteItemsAtIndexPaths:deletedIndexPaths];
          }
          if (insertedIndexPaths.count > 0) {
            [self.collectionView insertItemsAtIndexPaths:insertedIndexPaths];
          }
        }
        completion:^(BOOL finished) {
          [self refreshAllVisibleCells];
        }];
  } else {
    [self replaceMembersWithUsers:newMembers];
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView reloadData];
  }
}

- (void)startTimerOnMainThreadWithElapsedSeconds:(NSInteger)elapsedSeconds {
  if ([NSThread isMainThread]) {
    [self startTimerWithElapsedSeconds:elapsedSeconds];
    return;
  }
  __weak typeof(self) weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    [weakSelf startTimerWithElapsedSeconds:elapsedSeconds];
  });
}

- (void)startTimerWithElapsedSeconds:(NSInteger)elapsedSeconds {
  [self syncInitialElapsedSeconds:elapsedSeconds];
  if (self.timer != nil) {
    return;
  }
  [self syncTimerCountWithCallStartTime];
  self.timerLabel.hidden = NO;
  [self updateTimerLabel];
  __weak typeof(self) weakSelf = self;
  self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                               repeats:YES
                                                 block:^(NSTimer *_Nonnull timer) {
                                                   [weakSelf figureTimer];
                                                 }];
  [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)syncInitialElapsedSeconds:(NSInteger)elapsedSeconds {
  if (elapsedSeconds <= 0) {
    return;
  }
  self.initialElapsedSeconds = MAX(elapsedSeconds, self.initialElapsedSeconds);
  if (self.timer != nil && self.timerCount < self.initialElapsedSeconds) {
    self.timerCount = self.initialElapsedSeconds;
    [self updateTimerLabel];
  }
}

- (void)figureTimer {
  if (![self syncTimerCountWithCallStartTime]) {
    self.timerCount++;
  }
  [self updateTimerLabel];
}

- (BOOL)syncTimerCountWithCallStartTime {
  NECallStateManager *stateManager = [NECallStateManager sharedInstance];
  if (stateManager.callStartTime == nil || self.timerCount <= 0) {
    [stateManager syncCurrentState];
  }
  NSDate *callStartTime = stateManager.callStartTime;
  if (callStartTime != nil) {
    NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:callStartTime];
    NSInteger elapsedSeconds = MAX((NSInteger)elapsed, self.initialElapsedSeconds);
    if (elapsedSeconds > self.timerCount) {
      self.timerCount = elapsedSeconds;
      NEXKitBaseLogInfo(@"SingleToGroup UI sync timer from callStartTime elapsed:%ld",
                        (long)elapsedSeconds);
      return YES;
    }
    return elapsedSeconds == self.timerCount;
  }
  if (self.initialElapsedSeconds > 0 && self.timerCount < self.initialElapsedSeconds) {
    self.timerCount = self.initialElapsedSeconds;
    return YES;
  }
  return NO;
}

- (void)updateTimerLabel {
  self.timerLabel.text = [self timeFormatted:self.timerCount];
}

- (NSString *)timeFormatted:(NSInteger)totalSeconds {
  if (totalSeconds < 3600) {
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
  }
  NSInteger seconds = totalSeconds % 60;
  NSInteger minutes = (totalSeconds / 60) % 60;
  NSInteger hours = totalSeconds / 3600;
  return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes,
                                    (long)seconds];
}

- (NSArray<NECallMemberInfo *> *)orderedMembersKeepingDisplayOrder:
    (NSArray<NECallMemberInfo *> *)members {
  NSMutableDictionary<NSString *, NECallMemberInfo *> *membersByUserID =
      [[NSMutableDictionary alloc] init];
  NSMutableArray<NSString *> *incomingOrder = [[NSMutableArray alloc] init];
  for (NECallMemberInfo *member in members) {
    if (member.userID.length <= 0 || member.state == NECallMemberStateLeaving ||
        membersByUserID[member.userID] != nil) {
      continue;
    }
    membersByUserID[member.userID] = member;
    [incomingOrder addObject:member.userID];
  }

  NSMutableSet<NSString *> *incomingUsers = [NSMutableSet setWithArray:incomingOrder];
  for (NSInteger index = self.memberDisplayOrder.count - 1; index >= 0; index--) {
    NSString *userID = self.memberDisplayOrder[index];
    if (![incomingUsers containsObject:userID]) {
      [self.memberDisplayOrder removeObjectAtIndex:index];
    }
  }
  for (NSString *userID in incomingOrder) {
    if (![self.memberDisplayOrder containsObject:userID]) {
      [self.memberDisplayOrder addObject:userID];
    }
  }

  NSMutableArray<NECallMemberInfo *> *orderedMembers = [[NSMutableArray alloc] init];
  for (NSString *userID in self.memberDisplayOrder) {
    NECallMemberInfo *member = membersByUserID[userID];
    if (member != nil) {
      [orderedMembers addObject:member];
    }
  }
  return orderedMembers.copy;
}

- (void)applyProfileToUser:(NEGroupUser *)user fallbackUserID:(NSString *)userID {
  NEGroupUser *profile = self.memberProfileCache[userID ?: @""];
  user.mobile = profile.mobile ?: @"";
  user.avatar = profile.avatar ?: @"";
  NSString *nickname = profile.nickname.length > 0 ? profile.nickname : userID;
  user.nickname = nickname.length > 0 ? nickname : userID ?: @"";
}

- (void)fetchUserProfilesIfNeededForMembers:(NSArray<NECallMemberInfo *> *)members {
  NSMutableArray<NSString *> *accids = [[NSMutableArray alloc] init];
  for (NECallMemberInfo *member in members) {
    NSString *userID = member.userID;
    if (userID.length <= 0 || self.memberProfileCache[userID] != nil ||
        [self.fetchingProfileUserIDs containsObject:userID]) {
      continue;
    }
    [accids addObject:userID];
    [self.fetchingProfileUserIDs addObject:userID];
  }
  if (accids.count <= 0) {
    return;
  }

  NEXKitBaseLogInfo(@"SingleToGroup UI fetch member profiles, users:%@",
                    [accids componentsJoinedByString:@","]);
  __weak typeof(self) weakSelf = self;
  [NIMSDK.sharedSDK.v2UserService
      getUserList:accids
          success:^(NSArray<V2NIMUser *> *_Nonnull result) {
            dispatch_async(dispatch_get_main_queue(), ^{
              __strong typeof(weakSelf) self = weakSelf;
              if (self == nil) {
                return;
              }
              NSMutableSet<NSString *> *updatedUserIDs = [[NSMutableSet alloc] init];
              for (V2NIMUser *nimUser in result) {
                if (nimUser.accountId.length <= 0) {
                  continue;
                }
                NEGroupUser *profile = [[NEGroupUser alloc] init];
                profile.imAccid = nimUser.accountId;
                profile.mobile = nimUser.mobile ?: @"";
                profile.avatar = nimUser.avatar ?: @"";
                profile.nickname = nimUser.name ?: @"";
                self.memberProfileCache[nimUser.accountId] = profile;
                [updatedUserIDs addObject:nimUser.accountId];
              }
              for (NSString *accid in accids) {
                [self.fetchingProfileUserIDs removeObject:accid];
              }
              NEXKitBaseLogInfo(@"SingleToGroup UI fetched member profiles, request:%lu "
                                @"success:%lu",
                                (unsigned long)accids.count,
                                (unsigned long)updatedUserIDs.count);
              [self refreshMemberProfilesForUserIDs:updatedUserIDs];
            });
          }
          failure:^(V2NIMError *_Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
              __strong typeof(weakSelf) self = weakSelf;
              if (self == nil) {
                return;
              }
              for (NSString *accid in accids) {
                [self.fetchingProfileUserIDs removeObject:accid];
              }
              NEXKitBaseLogInfo(@"SingleToGroup UI fetch member profiles failed, users:%@ "
                                @"error:%@",
                                [accids componentsJoinedByString:@","], error);
            });
          }];
}

- (void)refreshMemberProfilesForUserIDs:(NSSet<NSString *> *)userIDs {
  if (userIDs.count <= 0) {
    return;
  }
  BOOL changed = NO;
  for (NEGroupUser *member in self.members) {
    if (member.imAccid.length <= 0 || ![userIDs containsObject:member.imAccid]) {
      continue;
    }
    NSString *oldAvatar = member.avatar ?: @"";
    NSString *oldNickname = member.nickname ?: @"";
    [self applyProfileToUser:member fallbackUserID:member.imAccid];
    if (![oldAvatar isEqualToString:member.avatar ?: @""] ||
        ![oldNickname isEqualToString:member.nickname ?: @""]) {
      changed = YES;
    }
  }
  if (changed) {
    NEXKitBaseLogInfo(@"SingleToGroup UI refresh member profiles, users:%@",
                      [[userIDs allObjects] componentsJoinedByString:@","]);
    [self refreshAllVisibleCells];
  }
}

- (BOOL)hasSameMemberOrderAsUsers:(NSArray<NEGroupUser *> *)users {
  if (self.members.count <= 0 || self.members.count != users.count) {
    return NO;
  }
  for (NSInteger index = 0; index < users.count; index++) {
    if (![self.members[index].imAccid isEqualToString:users[index].imAccid]) {
      return NO;
    }
  }
  return YES;
}

- (NSArray<NSIndexPath *> *)deletedIndexPathsForUsers:(NSArray<NEGroupUser *> *)users {
  NSMutableSet<NSString *> *newUserIDs = [NSMutableSet setWithArray:[self userIDsFromUsers:users]];
  NSMutableArray<NSIndexPath *> *indexPaths = [[NSMutableArray alloc] init];
  for (NSInteger index = 0; index < self.members.count; index++) {
    NSString *userID = self.members[index].imAccid ?: @"";
    if (![newUserIDs containsObject:userID]) {
      [indexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
    }
  }
  return indexPaths.copy;
}

- (NSArray<NSIndexPath *> *)insertedIndexPathsForUsers:(NSArray<NEGroupUser *> *)users {
  NSMutableSet<NSString *> *oldUserIDs =
      [NSMutableSet setWithArray:[self userIDsFromUsers:self.members]];
  NSMutableArray<NSIndexPath *> *indexPaths = [[NSMutableArray alloc] init];
  for (NSInteger index = 0; index < users.count; index++) {
    NSString *userID = users[index].imAccid ?: @"";
    if (![oldUserIDs containsObject:userID]) {
      [indexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
    }
  }
  return indexPaths.copy;
}

- (BOOL)canBatchRefreshToUsers:(NSArray<NEGroupUser *> *)users
             deletedIndexPaths:(NSArray<NSIndexPath *> *)deletedIndexPaths
            insertedIndexPaths:(NSArray<NSIndexPath *> *)insertedIndexPaths {
  if (self.members.count <= 0 || (deletedIndexPaths.count <= 0 && insertedIndexPaths.count <= 0)) {
    return NO;
  }
  NSMutableArray<NSString *> *simulatedUserIDs =
      [[self userIDsFromUsers:self.members] mutableCopy];
  NSArray<NSIndexPath *> *sortedDeletedIndexPaths =
      [deletedIndexPaths sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *obj1,
                                                                        NSIndexPath *obj2) {
        return [@(obj2.item) compare:@(obj1.item)];
      }];
  for (NSIndexPath *indexPath in sortedDeletedIndexPaths) {
    if (indexPath.item < 0 || indexPath.item >= simulatedUserIDs.count) {
      return NO;
    }
    [simulatedUserIDs removeObjectAtIndex:indexPath.item];
  }

  NSArray<NSIndexPath *> *sortedInsertedIndexPaths =
      [insertedIndexPaths sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *obj1,
                                                                         NSIndexPath *obj2) {
        return [@(obj1.item) compare:@(obj2.item)];
      }];
  for (NSIndexPath *indexPath in sortedInsertedIndexPaths) {
    if (indexPath.item < 0 || indexPath.item > simulatedUserIDs.count ||
        indexPath.item >= users.count) {
      return NO;
    }
    [simulatedUserIDs insertObject:users[indexPath.item].imAccid ?: @""
                           atIndex:indexPath.item];
  }
  return [simulatedUserIDs isEqualToArray:[self userIDsFromUsers:users]];
}

- (NSArray<NSString *> *)userIDsFromUsers:(NSArray<NEGroupUser *> *)users {
  NSMutableArray<NSString *> *userIDs = [[NSMutableArray alloc] init];
  for (NEGroupUser *user in users) {
    [userIDs addObject:user.imAccid ?: @""];
  }
  return userIDs.copy;
}

- (void)replaceMembersWithUsers:(NSArray<NEGroupUser *> *)users {
  [self.members removeAllObjects];
  [self.members addObjectsFromArray:users];
}

- (NSString *)currentMemberOrderDescription:(NSArray<NEGroupUser *> *)users {
  NSMutableArray<NSString *> *userIDs = [[NSMutableArray alloc] init];
  for (NEGroupUser *user in users) {
    if (user.imAccid.length > 0) {
      [userIDs addObject:user.imAccid];
    }
  }
  return [userIDs componentsJoinedByString:@","];
}

- (uint64_t)currentRtcUidForUser:(NSString *)currentUser {
  NECallInfo *callInfo = [[NECallEngine sharedInstance] getCallInfo];
  if ([callInfo.callerInfo.accId isEqualToString:currentUser]) {
    return callInfo.callerInfo.uid;
  }
  if ([callInfo.calleeInfo.accId isEqualToString:currentUser]) {
    return callInfo.calleeInfo.uid;
  }
  return 0;
}

- (void)resetRemovedRemoteVideoCanvasesWithMembers:(NSArray<NECallMemberInfo *> *)members
                                      currentUser:(NSString *)currentUser {
  NSMutableSet<NSString *> *currentRemoteUserIDs = [[NSMutableSet alloc] init];
  for (NECallMemberInfo *memberInfo in members) {
    if (memberInfo.userID.length <= 0 || [memberInfo.userID isEqualToString:currentUser] ||
        memberInfo.state == NECallMemberStateLeaving) {
      continue;
    }
    [currentRemoteUserIDs addObject:memberInfo.userID];
  }

  for (NEGroupUser *oldUser in self.members) {
    if (oldUser.uid <= 0 || oldUser.isShowLocalVideo == YES ||
        [currentRemoteUserIDs containsObject:oldUser.imAccid ?: @""]) {
      continue;
    }
    if (oldUser.imAccid.length > 0) {
      [self.videoMutedStates removeObjectForKey:oldUser.imAccid];
    }
    [NERtcEngine.sharedEngine setupRemoteVideoCanvas:nil forUserID:oldUser.uid];
    NEXKitBaseLogInfo(@"SingleToGroup UI reset removed remote canvas, user:%@", oldUser.imAccid);
  }
}

- (void)updateMemberVideoMuted:(BOOL)muted userID:(NSString *)userID {
  if (userID.length <= 0) {
    return;
  }
  self.videoMutedStates[userID] = @(muted);
  NSInteger targetIndex = NSNotFound;
  for (NSInteger index = 0; index < self.members.count; index++) {
    if ([self.members[index].imAccid isEqualToString:userID]) {
      targetIndex = index;
      self.members[index].isOpenVideo =
          [self isJoinedMemberVideoOpen:self.members[index].state == GroupMemberStateInChannel
                         videoAvailable:YES
                         hasCachedMuted:YES
                                  muted:muted];
      NEXKitBaseLogInfo(@"SingleToGroup UI update video muted, user:%@ muted:%d", userID, muted);
      break;
    }
  }
  if (targetIndex == NSNotFound) {
    return;
  }
  NSIndexPath *indexPath = [NSIndexPath indexPathForItem:targetIndex inSection:0];
  NESingleToGroupUserInCallCell *cell =
      (NESingleToGroupUserInCallCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
  if (cell != nil && [cell isDisplayingUserID:userID]) {
    [cell configure:self.members[targetIndex]];
  } else {
    [self.collectionView reloadItemsAtIndexPaths:@[ indexPath ]];
  }
}

- (void)syncInitialMediaStateWithCurrentUser:(NSString *)currentUser
                                  remoteUser:(NSString *)remoteUser
                            currentUserRtcUid:(uint64_t)currentUserRtcUid
                                remoteRtcUid:(uint64_t)remoteRtcUid
                            currentVideoMuted:(BOOL)currentVideoMuted
                              remoteVideoMuted:(BOOL)remoteVideoMuted
                            currentAudioMuted:(BOOL)currentAudioMuted {
  if (currentUser.length > 0) {
    self.videoMutedStates[currentUser] = @(currentVideoMuted);
    self.audioMutedStates[currentUser] = @(currentAudioMuted);
    if (currentUserRtcUid > 0) {
      self.rtcUidStates[currentUser] = @(currentUserRtcUid);
    }
  }
  BOOL hadRemoteVideoCache = NO;
  if (remoteUser.length > 0) {
    NSNumber *cachedRemoteMuted = self.videoMutedStates[remoteUser];
    hadRemoteVideoCache = cachedRemoteMuted != nil;
    if (remoteRtcUid > 0) {
      self.rtcUidStates[remoteUser] = @(remoteRtcUid);
    }
  }
  NEXKitBaseLogInfo(@"SingleToGroup UI sync initial media state current:%@ localVideoMuted:%d "
                    @"localAudioMuted:%d localUid:%llu remote:%@ remoteVideoMuted:%d "
                    @"remoteUid:%llu hasRemote:%d remoteCached:%d",
                    currentUser, currentVideoMuted, currentAudioMuted,
                    (unsigned long long)currentUserRtcUid, remoteUser, remoteVideoMuted,
                    (unsigned long long)remoteRtcUid, remoteUser.length > 0, hadRemoteVideoCache);
}

- (BOOL)isJoinedMemberVideoOpen:(BOOL)joined
                  videoAvailable:(BOOL)videoAvailable
                  hasCachedMuted:(BOOL)hasCachedMuted
                           muted:(BOOL)muted {
  return joined && (videoAvailable || hasCachedMuted) && !muted;
}

- (void)dealloc {
  [self.timer invalidate];
  self.timer = nil;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return self.members.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  NESingleToGroupUserInCallCell *cell =
      [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(
                                                                 NESingleToGroupUserInCallCell.class)
                                                forIndexPath:indexPath];
  if (indexPath.row < self.members.count) {
    [cell configure:self.members[indexPath.row]];
  }
  return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  NEXKitBaseLogInfo(@"SingleToGroup UI member selected, index:%ld", (long)indexPath.row);

  if (indexPath.row < self.members.count) {
    [self updateCollectionViewWithIndexPath:indexPath];
  }
}

#pragma mark - Cell Refresh Management

- (void)refreshAllVisibleCells {
  NSArray<NSIndexPath *> *visibleIndexPaths = [self.collectionView indexPathsForVisibleItems];

  for (NSIndexPath *indexPath in visibleIndexPaths) {
    if (indexPath.row < self.members.count) {
      NESingleToGroupUserInCallCell *cell =
          (NESingleToGroupUserInCallCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
      if (cell) {
        [cell configure:self.members[indexPath.row]];
      }
    }
  }
}

#pragma mark - Large View Management

- (void)updateCollectionViewWithIndexPath:(NSIndexPath *)indexPath {
  if (self.updatingLargeView) {
    NEXKitBaseLogInfo(@"SingleToGroup UI skip large view update while animating, row:%ld",
                      (long)indexPath.row);
    return;
  }
  NSInteger count = self.members.count;
  NSArray<NSDictionary *> *remoteUpdates = [self getRemoteUpdatesWithIndexPath:indexPath];

  NEXKitBaseLogInfo(@"SingleToGroup UI update large view, count:%ld row:%ld largeIndex:%ld",
                    (long)count, (long)indexPath.row, (long)self.layout.largeViewIndex);

  BOOL firstBigFlag = NO;
  if (count >= 2 && count <= 4 && indexPath.row != self.layout.largeViewIndex) {
    firstBigFlag = YES;
  }

  self.layout.largeViewIndex = (self.layout.largeViewIndex == indexPath.row) ? -1 : indexPath.row;
  if (firstBigFlag) {
    self.layout.largeViewIndex = 0;
  }

  NSString *showLargeViewUserId = @"";
  if (self.layout.largeViewIndex >= 0 && indexPath.row < self.members.count) {
    showLargeViewUserId = self.members[indexPath.row].imAccid ?: @"";
  }
  [self setShowLargeViewUserId:showLargeViewUserId];

  [self.collectionView cancelInteractiveMovement];

  self.updatingLargeView = YES;
  [self.collectionView
      performBatchUpdates:^{
        NSMutableArray<NSNumber *> *deletes = [NSMutableArray array];
        NSMutableArray<NSDictionary *> *inserts = [NSMutableArray array];
        NSMutableSet<NSNumber *> *movedFromIndexes = [NSMutableSet set];
        NSMutableSet<NSNumber *> *movedToIndexes = [NSMutableSet set];

        for (NSDictionary *update in remoteUpdates) {
          NSString *updateType = update[@"type"];
          if ([updateType isEqualToString:@"delete"]) {
            NSInteger index = [update[@"index"] integerValue];
            [self.collectionView deleteItemsAtIndexPaths:@[
              [NSIndexPath indexPathForItem:index inSection:0]
            ]];
            [deletes addObject:@(index)];
          } else if ([updateType isEqualToString:@"insert"]) {
            NEGroupUser *user = update[@"user"];
            NSInteger index = [update[@"index"] integerValue];
            [self.collectionView insertItemsAtIndexPaths:@[
              [NSIndexPath indexPathForItem:index inSection:0]
            ]];
            [inserts addObject:@{@"user" : user, @"index" : @(index)}];
          } else if ([updateType isEqualToString:@"move"]) {
            NSInteger fromIndex = [update[@"fromIndex"] integerValue];
            NSInteger toIndex = [update[@"toIndex"] integerValue];
            if (fromIndex >= 0 && fromIndex < self.members.count && toIndex >= 0 &&
                toIndex < self.members.count) {
              if (fromIndex == toIndex || [movedFromIndexes containsObject:@(fromIndex)] ||
                  [movedToIndexes containsObject:@(toIndex)]) {
                NEXKitBaseLogInfo(
                    @"SingleToGroup UI skip invalid large view move, from:%ld to:%ld",
                    (long)fromIndex, (long)toIndex);
                continue;
              }
              [movedFromIndexes addObject:@(fromIndex)];
              [movedToIndexes addObject:@(toIndex)];
              [self.collectionView
                  moveItemAtIndexPath:[NSIndexPath indexPathForItem:fromIndex inSection:0]
                          toIndexPath:[NSIndexPath indexPathForItem:toIndex inSection:0]];
              [deletes addObject:@(fromIndex)];
              [inserts addObject:@{
                @"user" : self.members[fromIndex],
                @"index" : @(toIndex)
              }];
              NEXKitBaseLogInfo(@"SingleToGroup UI move large view member, from:%ld to:%ld",
                                (long)fromIndex, (long)toIndex);
            }
          }
        }

        NSArray<NSNumber *> *sortedDeletes = [deletes
            sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
              return [obj2 compare:obj1];
            }];
        for (NSNumber *deletedIndex in sortedDeletes) {
          NSInteger index = [deletedIndex integerValue];
          if (index >= 0 && index < self.members.count) {
            [self.members removeObjectAtIndex:index];
          }
        }

        NSArray<NSDictionary *> *sortedInserts = [inserts
            sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
              NSNumber *index1 = obj1[@"index"];
              NSNumber *index2 = obj2[@"index"];
              return [index1 compare:index2];
            }];
        for (NSDictionary *insertion in sortedInserts) {
          NEGroupUser *user = insertion[@"user"];
          NSInteger index = [insertion[@"index"] integerValue];
          if (user && index >= 0 && index <= self.members.count) {
            [self.members insertObject:user atIndex:index];
          }
        }

        if (remoteUpdates.count == 0) {
          [self.collectionView.collectionViewLayout invalidateLayout];
        }
      }
      completion:^(BOOL finished) {
        self.updatingLargeView = NO;
        NEXKitBaseLogInfo(@"SingleToGroup UI large view update finished, largeIndex:%ld user:%@",
                          (long)self.layout.largeViewIndex, self.layout.showLargeViewUserId);
        [self refreshAllVisibleCells];
        [self.collectionView endInteractiveMovement];
      }];
}

- (void)setShowLargeViewUserId:(NSString *)userId {
  self.layout.showLargeViewUserId = userId ?: @"";
}

- (NSArray<NSDictionary *> *)getRemoteUpdatesWithIndexPath:(NSIndexPath *)indexPath {
  NSInteger count = self.members.count;
  NSInteger row = indexPath.row;

  if (count < 2 || count > 4 || row >= count) {
    return @[];
  }

  if (row == self.layout.largeViewIndex) {
    NEGroupUser *clickedUser = self.members[row];
    NSInteger originalIndex = [self getOriginalIndexForUser:clickedUser];
    if (originalIndex == row) {
      return @[];
    }
    return @[ @{@"type" : @"move", @"fromIndex" : @(0), @"toIndex" : @(originalIndex)} ];
  }

  if (row == 0 && ![self isFirstUserAtOriginalPosition]) {
    NEGroupUser *firstUser = self.members.firstObject;
    NSInteger originalIndex = [self getOriginalIndexForUser:firstUser];
    if (originalIndex == row) {
      return @[];
    }
    return @[ @{@"type" : @"move", @"fromIndex" : @(0), @"toIndex" : @(originalIndex)} ];
  }

  if (count == 2 || [self isFirstUserAtOriginalPosition]) {
    if (row == 0) {
      return @[];
    }
    return @[ @{@"type" : @"move", @"fromIndex" : @(row), @"toIndex" : @(0)} ];
  }

  NEGroupUser *firstUser = self.members.firstObject;
  NSInteger firstUserOriginalIndex = [self getOriginalIndexForUser:firstUser];
  return @[
    @{@"type" : @"move", @"fromIndex" : @(0), @"toIndex" : @(firstUserOriginalIndex)},
    @{@"type" : @"move", @"fromIndex" : @(row), @"toIndex" : @(0)}
  ];
}

- (BOOL)isFirstUserAtOriginalPosition {
  if (self.members.count <= 0) {
    return YES;
  }
  NEGroupUser *firstUser = self.members.firstObject;
  return firstUser.originalIndex == 0;
}

- (NSInteger)getOriginalIndexForUser:(NEGroupUser *)user {
  return user.originalIndex;
}

#pragma mark - Properties

- (UICollectionView *)collectionView {
  if (!_collectionView) {
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                         collectionViewLayout:self.layout];
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = UIColor.blackColor;
    _collectionView.bounces = NO;
    _collectionView.scrollEnabled = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    [_collectionView registerClass:NESingleToGroupUserInCallCell.class
        forCellWithReuseIdentifier:NSStringFromClass(NESingleToGroupUserInCallCell.class)];
  }
  return _collectionView;
}

- (NEGroupCallFlowLayout *)layout {
  if (!_layout) {
    _layout = [[NEGroupCallFlowLayout alloc] init];
    _layout.minimumLineSpacing = 0;
    _layout.minimumInteritemSpacing = 0;
    _layout.scrollDirection = UICollectionViewScrollDirectionVertical;
  }
  _layout.participantCount = self.members.count;
  return _layout;
}

- (UILabel *)timerLabel {
  if (nil == _timerLabel) {
    _timerLabel = [[UILabel alloc] init];
    _timerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _timerLabel.textColor = UIColor.whiteColor;
    _timerLabel.font = [UIFont systemFontOfSize:14.0];
    _timerLabel.textAlignment = NSTextAlignmentCenter;
    _timerLabel.text = @"00:00";
    _timerLabel.hidden = YES;
  }
  return _timerLabel;
}

@end
