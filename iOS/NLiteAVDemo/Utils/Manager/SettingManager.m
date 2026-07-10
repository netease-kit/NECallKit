// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "SettingManager.h"
#import <NERtcCallKit/NERtcCallKit.h>
NSString *const kYXOTOTimeOut = @"kYXOTOTimeOut";

NSString *const kShowCName = @"kShowCName";

NSString *const kPrivateConfigUrl = @"kPrivateConfigUrl";

NSString *const kPrivateIMConfig = @"kPrivateIMConfig";

NSString *const kPrivateRTCConfig = @"kPrivateRTCConfig";

NSString *const kEnableSingleToGroupCall = @"kEnableSingleToGroupCall";

@interface SettingManager ()

@property(nonatomic, assign, readwrite) NSInteger timeout;

@property(nonatomic, assign, readwrite) BOOL supportAutoJoinWhenCalled;

@property(nonatomic, assign, readwrite) BOOL rejectBusyCode;

@property(nonatomic, assign, readwrite) BOOL openCustomTokenAndChannelName;

@property(nonatomic, assign, readwrite) bool incallShowCName;

@property(nonatomic, assign, readwrite) BOOL useEnableLocalMute;

@property(nonatomic, assign, readwrite) BOOL isGlobalInit;

@property(nonatomic, assign, readwrite) BOOL enableSingleToGroupCall;

@end

@implementation SettingManager

+ (id)shareInstance {
  static SettingManager *shareInstance = nil;
  static dispatch_once_t once_token;
  dispatch_once(&once_token, ^{
    if (!shareInstance) {
      shareInstance = [[self alloc] init];
    }
  });
  return shareInstance;
}

- (void)setCallKitUid:(uint64_t)uid {
  [[NECallEngine sharedInstance] setValue:[NSNumber numberWithUnsignedLongLong:uid]
                               forKeyPath:@"context.currentUserUid"];

  //  if ([[NECallEngine sharedInstance] respondsToSelector:@selector(changeStatusIdle)]) {
  //    [[NECallEngine sharedInstance] changeStatusIdle];
  //  }
}

- (uint64_t)getCallKitUid {
  return [[[NECallEngine sharedInstance] valueForKeyPath:@"context.currentUserUid"]
      unsignedLongLongValue];
}

- (void)setAutoJoin:(BOOL)autoJoin {
  [[NECallEngine sharedInstance] setValue:[NSNumber numberWithBool:autoJoin]
                               forKeyPath:@"context.supportAutoJoinWhenCalled"];
  [[NERtcCallUIKit sharedInstance] setValue:[NSNumber numberWithInt:autoJoin]
                                 forKeyPath:@"config.uiConfig.showCallingSwitchCallType"];
  self.supportAutoJoinWhenCalled = autoJoin;
}

- (void)setBusyCode:(BOOL)open {
  self.rejectBusyCode = open;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    self.isGroupPush = YES;
    self.supportAutoJoinWhenCalled = [[[NECallEngine sharedInstance]
        valueForKeyPath:@"context.supportAutoJoinWhenCalled"] boolValue];
    self.rejectBusyCode = NO;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSNumber *showCname = [userDefault objectForKey:kShowCName];
    if (showCname != nil) {
      self.incallShowCName = [showCname boolValue];
    }
    
    // 加载私有化配置
    NSString *configUrl = [userDefault objectForKey:kPrivateConfigUrl];
    if (configUrl.length > 0) {
      _privateConfigUrl = configUrl;
    }
    
    NSDictionary *imConfig = [userDefault objectForKey:kPrivateIMConfig];
    if (imConfig) {
      _privateIMConfig = imConfig;
    }
    
    NSDictionary *rtcConfig = [userDefault objectForKey:kPrivateRTCConfig];
    if (rtcConfig) {
      _privateRTCConfig = rtcConfig;
    }
    NSNumber *enableSingleToGroupCall = [userDefault objectForKey:kEnableSingleToGroupCall];
    _enableSingleToGroupCall = [enableSingleToGroupCall boolValue];
    
    NSLog(@"current accid : %@", [NIMSDK.sharedSDK.v2LoginService getLoginUser]);
  }
  return self;
}

- (void)setTimeoutWithSecond:(NSInteger)second {
  [[NECallEngine sharedInstance] setTimeOutSeconds:second];
}

- (NSInteger)timeout {
  return [[NECallEngine sharedInstance] timeOutSeconds];
}

- (BOOL)isGlobalInit {
  return !([[[NECallEngine sharedInstance] valueForKeyPath:@"context.initRtcMode"] intValue] == 1);
}

- (void)setIsGlobalInit:(BOOL)isGlobalInit
            withApnsCer:(NSString *)apnsCer
             withAppkey:(NSString *)appkey {
  NSNumber *number = [NSNumber numberWithInteger:2];
  if (isGlobalInit == NO) {
    number = [NSNumber numberWithInteger:1];
  }
  [[NECallEngine sharedInstance] setValue:number forKeyPath:@"context.initRtcMode"];
}

- (BOOL)isJoinRtcWhenCall {
  return [[[NECallEngine sharedInstance] valueForKeyPath:@"context.joinRtcWhenCall"] boolValue];
}

- (void)setIsJoinRtcWhenCall:(BOOL)isJoinRtcWhenCall {
  [[NECallEngine sharedInstance] setValue:[NSNumber numberWithBool:isJoinRtcWhenCall]
                               forKeyPath:@"context.joinRtcWhenCall"];
}

- (BOOL)isAudioConfirm {
  return [[[NECallEngine sharedInstance] valueForKeyPath:@"context.confirmAudio"] boolValue];
}

- (void)setIsAudioConfirm:(BOOL)isAudioConfirm {
  [[NECallEngine sharedInstance] setValue:[NSNumber numberWithBool:isAudioConfirm]
                               forKeyPath:@"context.confirmAudio"];
}

- (BOOL)isVideoConfirm {
  return [[[NECallEngine sharedInstance] valueForKeyPath:@"context.confirmVideo"] boolValue];
}

- (void)setIsVideoConfirm:(BOOL)isVideoConfirm {
  [[NECallEngine sharedInstance] setValue:[NSNumber numberWithBool:isVideoConfirm]
                               forKeyPath:@"context.confirmVideo"];
}

- (NSString *)getRtcCName {
  return [[NECallEngine sharedInstance] valueForKeyPath:@"context.channelInfo.channelName"];
}

- (void)setShowCName:(BOOL)show {
  self.incallShowCName = show;
  NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
  [userDefault setObject:[NSNumber numberWithBool:show] forKey:kShowCName];
  [userDefault synchronize];
}

// 1.5.6 add
- (void)setEnableLocal:(BOOL)enable {
  self.useEnableLocalMute = enable;
}

- (void)setEnableSingleToGroupCall:(BOOL)enable {
  _enableSingleToGroupCall = enable;
  NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
  [userDefault setObject:@(enable) forKey:kEnableSingleToGroupCall];
  [userDefault synchronize];
}

- (void)setPrivateConfigUrl:(NSString *)url {
  _privateConfigUrl = url;
  NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
  if (url.length > 0) {
    [userDefault setObject:url forKey:kPrivateConfigUrl];
  } else {
    [userDefault removeObjectForKey:kPrivateConfigUrl];
  }
  [userDefault synchronize];
}

- (void)setPrivateIMConfig:(NSDictionary *)config {
  _privateIMConfig = config;
  NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
  if (config) {
    [userDefault setObject:config forKey:kPrivateIMConfig];
  } else {
    [userDefault removeObjectForKey:kPrivateIMConfig];
  }
  [userDefault synchronize];
}

- (void)setPrivateRTCConfig:(NSDictionary *)config {
  _privateRTCConfig = config;
  NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
  if (config) {
    [userDefault setObject:config forKey:kPrivateRTCConfig];
  } else {
    [userDefault removeObjectForKey:kPrivateRTCConfig];
  }
  [userDefault synchronize];
}

- (void)clearPrivateConfig {
  self.privateConfigUrl = nil;
  self.privateIMConfig = nil;
  self.privateRTCConfig = nil;
}

@end
