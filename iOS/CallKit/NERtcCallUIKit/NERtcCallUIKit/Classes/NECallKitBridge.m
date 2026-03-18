// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NECallKitBridge.h"
#import <NERtcCallKit/NECallEngine.h>
#import <NERtcCallKit/NERtcCallKit.h>
#import <NERtcCallKit/NERtcCallOptions.h>
#import <NEXKitBase/NEXKitBase.h>
#import <NIMSDK/NIMSDK.h>
#import "NECallKitUtil.h"
#import "NECallStateManager.h"
#import "NEInAppWindowManager.h"

//
static NSString *const kCallBridgeTag = @"CallBridge";
static NSString *const kEventTapFloatWindow = @"EVENT_TAP_FLOATWINDOW";

@interface NECallKitBridge ()

/// 悬浮窗观察者列表（弱引用）
@property(nonatomic, strong) NSHashTable<id<NEFloatWindowObserver>> *floatWindowObservers;

@end

@implementation NECallKitBridge

+ (instancetype)instance {
  static NECallKitBridge *instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[NECallKitBridge alloc] init];
  });
  return instance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    // 初始化观察者列表（使用弱引用，避免循环引用）
    _floatWindowObservers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];

    // 监听点击悬浮窗的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTapFloatWindow:)
                                                 name:kEventTapFloatWindow
                                               object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initWithAppKey:(NSString *)appKey
             frameWork:(NSString *)frameWork
               channel:(NSString *)channel
           apnsCername:(NSString *)apnsCername
           voipCerName:(NSString *)voipCerName
     currentUserRtcUid:(uint64_t)currentUserRtcUid {
  NEXKitBaseLogInfo(
      @"[%@] init appKey = %@, frameWork = %@, channel = %@, currentUserRtcUid = %llu",
      kCallBridgeTag, appKey, frameWork, channel, currentUserRtcUid);

  necallkit_async_main_safe(^{
    //        NERtcCallOptions *options = [[NERtcCallOptions alloc] init];
    // frameWork 和 channel 参数在 iOS 端暂未使用，可根据需要添加到 options 中
    NIMSDKOption *option = [NIMSDKOption optionWithAppKey:appKey];
    option.apnsCername = apnsCername;
    if (@available(iOS 17.4, *)) {
      option.pkCername = voipCerName;
    }
    option.v2 = YES;

    [NIMSDK.sharedSDK registerWithOptionV2:option v2Option:nil];
    NESetupConfig *setupConfig = [[NESetupConfig alloc] initWithAppkey:appKey];
    if (currentUserRtcUid > 0) {
      setupConfig.currentUserUid = currentUserRtcUid;
    }
    setupConfig.framework = frameWork;
    setupConfig.channel = channel;
    [[NECallEngine sharedInstance] setup:setupConfig];

    // 初始化并开始监听状态管理器
    [[NECallStateManager sharedInstance] startObserving];
  });
}

- (void)loginWithAccountId:(NSString *)accountId
                     token:(NSString *)token
                 onSuccess:(nullable NECallKitSuccessBlock)successBlock
                    onFail:(nullable NECallKitFailBlock)failBlock {
  NEXKitBaseLogInfo(@"[%@] login accountId = %@", kCallBridgeTag, accountId);
  necallkit_async_main_safe(^{
    [[NERtcCallKit sharedInstance]
             login:accountId
             token:token
        completion:^(NSError *_Nullable error) {
          if (error) {
            NEXKitBaseLogInfo(@"[%@] login im failed code = %ld, msg = %@", kCallBridgeTag,
                              (long)error.code, error.localizedDescription);
            if (failBlock) {
              failBlock(error.code, error.localizedDescription);
            }
          } else {
            NEXKitBaseLogInfo(@"[%@] login im success", kCallBridgeTag);
            if (successBlock) {
              successBlock(nil);
            }
          }
        }];
  });
}

- (void)logoutOnSuccess:(nullable NECallKitSuccessBlock)successBlock
                 onFail:(nullable NECallKitFailBlock)failBlock {
  NEXKitBaseLogInfo(@"[%@] logout", kCallBridgeTag);

  necallkit_async_main_safe(^{
    [[NERtcCallKit sharedInstance] logout:^(NSError *_Nullable error) {
      if (error) {
        NEXKitBaseLogInfo(@"[%@] logout im failed code = %ld, msg = %@", kCallBridgeTag,
                          (long)error.code, error.localizedDescription);
        if (failBlock) {
          failBlock(error.code, error.localizedDescription);
        }
      } else {
        NEXKitBaseLogInfo(@"[%@] logout im success", kCallBridgeTag);
        if (successBlock) {
          successBlock(nil);
        }
      }
    }];
  });
}

- (void)hasPermissionWithCallType:(NSInteger)callType
                        onSuccess:(nullable NECallKitSuccessBlock)successBlock
                           onFail:(nullable NECallKitFailBlock)failBlock {
  NEXKitBaseLogInfo(@"[%@] hasPermission callType = %ld", kCallBridgeTag, (long)callType);

  necallkit_async_main_safe(^{
    [NECallKitUtil
        checkAuthorizationForCallType:callType
                           completion:^(NSError *error) {
                             if (error) {
                               NEXKitBaseLogInfo(@"[%@] permission denied code = %ld, msg = %@",
                                                 kCallBridgeTag, (long)error.code,
                                                 error.localizedDescription);
                               if (failBlock) {
                                 failBlock(error.code,
                                           error.localizedDescription ?: @"Permission denied");
                               }
                             } else {
                               NEXKitBaseLogInfo(@"[%@] permission granted", kCallBridgeTag);
                               if (successBlock) {
                                 successBlock(nil);
                               }
                             }
                           }];
  });
}

- (void)callWithParam:(NECallParam *)param
            onSuccess:(nullable NECallKitSuccessBlock)successBlock
               onFail:(nullable NECallKitFailBlock)failBlock {
  NEXKitBaseLogInfo(@"[%@] call accId = %@, callType = %lu", kCallBridgeTag, param.accId,
                    (unsigned long)param.callType);

  necallkit_async_main_safe(^{
    [[NECallEngine sharedInstance]
              call:param
        completion:^(NSError *_Nullable error, NECallInfo *_Nullable callInfo) {
          if (error) {
            NEXKitBaseLogInfo(@"[%@] call failed code = %ld, msg = %@", kCallBridgeTag,
                              (long)error.code, error.localizedDescription);
            if (failBlock) {
              failBlock(error.code, error.localizedDescription);
            }
          } else {
            NEXKitBaseLogInfo(@"[%@] call success", kCallBridgeTag);
            if (successBlock) {
              successBlock(callInfo);
            }
          }
        }];
  });
}

- (void)acceptOnSuccess:(nullable NECallKitSuccessBlock)successBlock
                 onFail:(nullable NECallKitFailBlock)failBlock {
  NEXKitBaseLogInfo(@"[%@] accept.start", kCallBridgeTag);

  necallkit_async_main_safe(^{
    [[NECallEngine sharedInstance]
        accept:^(NSError *_Nullable error, NECallInfo *_Nullable callInfo) {
          if (error) {
            NEXKitBaseLogInfo(@"[%@] accept failed code = %ld, msg = %@", kCallBridgeTag,
                              (long)error.code, error.localizedDescription);
            if (failBlock) {
              failBlock(error.code, error.localizedDescription);
            }
          } else {
            NEXKitBaseLogInfo(@"[%@] accept success", kCallBridgeTag);
            if (successBlock) {
              successBlock(callInfo);
            }
          }
        }];
  });
}

- (void)hangupWithParam:(NEHangupParam *)param
              onSuccess:(nullable NECallKitSuccessBlock)successBlock
                 onFail:(nullable NECallKitFailBlock)failBlock {
  NEXKitBaseLogInfo(@"[%@] hangup.start, data: %@", kCallBridgeTag, param);

  necallkit_async_main_safe(^{
    [[NECallEngine sharedInstance]
            hangup:param
        completion:^(NSError *_Nullable error) {
          if (error) {
            NEXKitBaseLogInfo(@"[%@] hangup failed code = %ld, msg = %@", kCallBridgeTag,
                              (long)error.code, error.localizedDescription);
            if (failBlock) {
              failBlock(error.code, error.localizedDescription);
            }
          } else {
            NEXKitBaseLogInfo(@"[%@] hangup success", kCallBridgeTag);
            if (successBlock) {
              successBlock(nil);
            }
          }
        }];
  });
}

- (void)switchCallTypeWithParam:(NESwitchParam *)param {
  NEXKitBaseLogInfo(@"[%@] switchCallType.start, callType: %lu", kCallBridgeTag,
                    (unsigned long)param.callType);

  necallkit_async_main_safe(^{
    [[NECallEngine sharedInstance]
        switchCallType:param
            completion:^(NSError *_Nullable error) {
              if (error) {
                NEXKitBaseLogInfo(@"[%@] switchCallType failed code = %ld, msg = %@",
                                  kCallBridgeTag, (long)error.code, error.localizedDescription);
              } else {
                NEXKitBaseLogInfo(@"[%@] switchCallType success", kCallBridgeTag);
              }
            }];
  });
}

- (void)setTimeout:(int)second {
  NEXKitBaseLogInfo(@"[%@] setTimeout, second: %d", kCallBridgeTag, second);

  necallkit_async_main_safe(^{
    [[NECallEngine sharedInstance] setTimeout:second];
  });
}

- (int)enableLocalVideo:(BOOL)enable {
  NEXKitBaseLogInfo(@"[%@] enableLocalVideo, enable: %d", kCallBridgeTag, enable);

  __block int result = 0;
  necallkit_sync_main_safe(^{
    result = [[NECallEngine sharedInstance] enableLocalVideo:enable];
    // 同步本端视频启用状态
    [[NECallStateManager sharedInstance] syncLocalVideoEnabled:enable];
  });
  return result;
}

- (int)muteLocalVideo:(BOOL)mute {
  NEXKitBaseLogInfo(@"[%@] muteLocalVideo, mute: %d", kCallBridgeTag, mute);

  __block int result = 0;
  necallkit_sync_main_safe(^{
    result = [[NECallEngine sharedInstance] muteLocalVideo:mute];
    // 同步本端视频静音状态
    [[NECallStateManager sharedInstance] syncLocalVideoMuted:mute];
  });
  return result;
}

- (int)muteLocalAudio:(BOOL)mute {
  NEXKitBaseLogInfo(@"[%@] muteLocalAudio, mute: %d", kCallBridgeTag, mute);

  __block int result = 0;
  necallkit_sync_main_safe(^{
    result = [[NECallEngine sharedInstance] muteLocalAudio:mute];
    // 同步本端音频静音状态
    [[NECallStateManager sharedInstance] syncLocalAudioMuted:mute];
  });
  return result;
}

- (void)switchCamera:(NSInteger)camera {
  NEXKitBaseLogInfo(@"[%@] switchCamera.start, data: %ld", kCallBridgeTag, (long)camera);

  necallkit_async_main_safe(^{
    // 0 kNERtcCameraPositionBack 1 kNERtcCameraPositionFront
    [[NERtcEngine sharedEngine] switchCameraWithPosition:(NERtcCameraPosition)camera];
  });
}

- (void)startFloatWindow {
  NEXKitBaseLogInfo(@"[%@] startFloatWindow.start", kCallBridgeTag);

  necallkit_async_main_safe(^{
    [[NEInAppWindowManager sharedInstance] showInAppSmallWindow];
  });
}

- (void)stopFloatWindow {
  NEXKitBaseLogInfo(@"[%@] stopFloatWindow.start", kCallBridgeTag);

  necallkit_async_main_safe(^{
    [[NEInAppWindowManager sharedInstance] closeInAppSmallWindow];
  });
}

- (BOOL)isSpeakerphoneOn {
  __block BOOL result = NO;
  necallkit_sync_main_safe(^{
    result = [[NECallEngine sharedInstance] isSpeakerphoneOn];
  });
  return result;
}

- (int)setSpeakerphoneOn:(BOOL)enable {
  NEXKitBaseLogInfo(@"[%@] setSpeakerphoneOn, enable: %d", kCallBridgeTag, enable);

  __block int result = 0;
  necallkit_sync_main_safe(^{
    [[NECallEngine sharedInstance] setSpeakerphoneOn:enable];
    result = 0;  // setSpeakerphoneOn 方法没有返回值，默认返回成功
  });
  return result;
}

- (void)setCallConfig:(NECallConfig *)config {
  NEXKitBaseLogInfo(@"[%@] setCallConfig", kCallBridgeTag);

  necallkit_async_main_safe(^{
    [[NECallEngine sharedInstance] setCallConfig:config];
  });
}

- (nullable NECallConfig *)getCallConfig {
  __block NECallConfig *result = nil;
  necallkit_sync_main_safe(^{
    result = [[NECallEngine sharedInstance] getCallConfig];
  });
  return result;
}

- (nullable NECallInfo *)getCallInfo {
  __block NECallInfo *result = nil;
  necallkit_sync_main_safe(^{
    result = [[NECallEngine sharedInstance] getCallInfo];
  });
  return result;
}

- (int)setAINSMode:(NERtcAudioAINSMode)mode {
  NEXKitBaseLogInfo(@"[%@] setAINSMode, mode: %ld", kCallBridgeTag, (long)mode);

  __block int result = 0;
  necallkit_sync_main_safe(^{
    [[NECallEngine sharedInstance] setAINSMode:mode];
    result = 0;  // setAINSMode 方法没有返回值，默认返回成功
  });
  return result;
}

- (void)destroy {
  NEXKitBaseLogInfo(@"[%@] destroy", kCallBridgeTag);

  necallkit_async_main_safe(^{
    // 停止监听状态管理器
    [[NECallStateManager sharedInstance] stopObserving];
    [[NECallEngine sharedInstance] destroy];
  });
}

+ (NSString *)getVersion {
  __block NSString *result = nil;
  necallkit_sync_main_safe(^{
    result = [NECallEngine getVersion];
  });
  return result ?: @"";
}

#pragma mark - FloatWindow Observer

- (void)addFloatWindowObserver:(id<NEFloatWindowObserver>)observer {
  NEXKitBaseLogInfo(@"[%@] addFloatWindowObserver, observer: %@", kCallBridgeTag, observer);

  if (observer && ![self.floatWindowObservers containsObject:observer]) {
    [self.floatWindowObservers addObject:observer];
  }
}

- (void)removeFloatWindowObserver:(id<NEFloatWindowObserver>)observer {
  NEXKitBaseLogInfo(@"[%@] removeFloatWindowObserver, observer: %@", kCallBridgeTag, observer);

  if (observer) {
    [self.floatWindowObservers removeObject:observer];
  }
}

- (void)handleTapFloatWindow:(NSNotification *)notification {
  NEXKitBaseLogInfo(@"[%@] handleTapFloatWindow", kCallBridgeTag);

  // 通知所有观察者
  for (id<NEFloatWindowObserver> observer in self.floatWindowObservers) {
    if ([observer respondsToSelector:@selector(tapFloatWindow)]) {
      [observer tapFloatWindow];
    }
  }
}

@end
