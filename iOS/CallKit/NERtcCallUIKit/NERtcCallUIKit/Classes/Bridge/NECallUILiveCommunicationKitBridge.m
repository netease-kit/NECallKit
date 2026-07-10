// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NECallUILiveCommunicationKitBridge.h"

#import <AVFAudio/AVFAudio.h>
#import <NERtcCallKit/NECallEngine.h>
#import <NEXKitBase/NEXKitBase.h>
#import <NIMSDK/NIMSDK.h>
#import <PushKit/PushKit.h>
#import <UIKit/UIKit.h>
#import "NECallKitBridge.h"

NSNotificationName const NECallUILiveCommunicationKitIncomingStateChangedNotification =
    @"NECallUILiveCommunicationKitIncomingStateChangedNotification";
NSString *const NECallUILiveCommunicationKitIncomingStateKey = @"isIncoming";

static NSString *const kNECallUILCKBridgeTag = @"NECallUILiveCommunicationKitBridge";

@interface NECallUILiveCommunicationKitBridge () <PKPushRegistryDelegate>

@property(nonatomic, assign) BOOL enabled;
@property(nonatomic, strong, nullable) PKPushRegistry *pushRegistry;
@property(nonatomic, copy, nullable) NSString *ringtoneName;
@property(nonatomic, copy, nullable) NECallUILiveCommunicationKitIncomingStateHandler
    incomingStateChangedHandler;

@end

@implementation NECallUILiveCommunicationKitBridge

+ (instancetype)shared {
  static NECallUILiveCommunicationKitBridge *bridge = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    bridge = [[NECallUILiveCommunicationKitBridge alloc] init];
  });
  return bridge;
}

- (void)enableLiveCommunicationKit:(BOOL)enabled {
  NECallKitLiveCommunicationKitConfig *config = [[NECallKitLiveCommunicationKitConfig alloc] init];
  config.enabled = enabled;
  [self setLiveCommunicationKitConfig:config];
}

- (void)setLiveCommunicationKitConfig:(NECallKitLiveCommunicationKitConfig *)config {
  self.ringtoneName = config.ringtoneName.length > 0 ? config.ringtoneName : nil;
  self.enabled = config.enabled;
  if (!config.enabled) {
    [self stopPushRegistry];
    NEXKitBaseLogInfo(@"[%@] disable LiveCommunicationKit", kNECallUILCKBridgeTag);
    return;
  }

  if (@available(iOS 17.4, *)) {
    [self registerPushKitIfNeeded];
  } else {
    NEXKitBaseLogInfo(@"[%@] LiveCommunicationKit requires iOS 17.4+", kNECallUILCKBridgeTag);
  }
}

- (void)setIncomingStateChangedHandler:
    (nullable NECallUILiveCommunicationKitIncomingStateHandler)handler {
  _incomingStateChangedHandler = [handler copy];
}

- (void)registerPushKitIfNeeded {
  if (self.pushRegistry != nil) {
    return;
  }
  PKPushRegistry *registry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
  registry.delegate = self;
  registry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
  self.pushRegistry = registry;
  NEXKitBaseLogInfo(@"[%@] register PushKit", kNECallUILCKBridgeTag);
}

- (void)stopPushRegistry {
  self.pushRegistry.delegate = nil;
  self.pushRegistry.desiredPushTypes = nil;
  self.pushRegistry = nil;
}

- (void)notifyIncomingState:(BOOL)isIncoming {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self.incomingStateChangedHandler) {
      self.incomingStateChangedHandler(isIncoming);
    }
    [[NSNotificationCenter defaultCenter]
        postNotificationName:NECallUILiveCommunicationKitIncomingStateChangedNotification
                      object:self
                    userInfo:@{
                      NECallUILiveCommunicationKitIncomingStateKey : @(isIncoming),
                    }];
  });
}

- (void)prepareAudioSessionIfNeeded {
  if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
    return;
  }
  NSError *error = nil;
  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                          mode:AVAudioSessionModeDefault
                                       options:AVAudioSessionCategoryOptionMixWithOthers
                                         error:&error];
  if (error) {
    NEXKitBaseLogInfo(@"[%@] set audio session category failed: %@", kNECallUILCKBridgeTag,
                      error.localizedDescription);
    return;
  }
  [[AVAudioSession sharedInstance] setActive:YES error:&error];
  if (error) {
    NEXKitBaseLogInfo(@"[%@] active audio session failed: %@", kNECallUILCKBridgeTag,
                      error.localizedDescription);
  }
}

#pragma mark - PKPushRegistryDelegate

- (void)pushRegistry:(PKPushRegistry *)registry
    didUpdatePushCredentials:(PKPushCredentials *)credentials
                     forType:(PKPushType)type {
  if (credentials.token.length == 0) {
    NEXKitBaseLogInfo(@"[%@] PushKit token is empty", kNECallUILCKBridgeTag);
    return;
  }
  [[NIMSDK sharedSDK] updatePushKitToken:credentials.token];
}

- (void)pushRegistry:(PKPushRegistry *)registry
    didReceiveIncomingPushWithPayload:(PKPushPayload *)payload
                              forType:(PKPushType)type
                withCompletionHandler:(void (^)(void))completion {
  if (!self.enabled) {
    if (completion) {
      completion();
    }
    return;
  }

  NSDictionary *dictionaryPayload = payload.dictionaryPayload;
  if (![dictionaryPayload isKindOfClass:NSDictionary.class] || !dictionaryPayload[@"nim"]) {
    NEXKitBaseLogInfo(@"[%@] ignore non NIM VoIP payload", kNECallUILCKBridgeTag);
    if (completion) {
      completion();
    }
    return;
  }

  if (@available(iOS 17.4, *)) {
    [self prepareAudioSessionIfNeeded];
    [self notifyIncomingState:YES];

    NECallSystemIncomingCallParam *param = [[NECallSystemIncomingCallParam alloc] init];
    param.payload = dictionaryPayload;
    param.ringtoneName = self.ringtoneName;

    [[NECallEngine sharedInstance] reportIncomingCallWithParam:param
        acceptCompletion:^(NSError *_Nullable error, NECallInfo *_Nullable callInfo) {
          if (error) {
            NEXKitBaseLogInfo(@"[%@] LCK accept failed: %@", kNECallUILCKBridgeTag,
                              error.localizedDescription);
          } else {
            NEXKitBaseLogInfo(@"[%@] LCK accept success", kNECallUILCKBridgeTag);
          }
        }
        hangupCompletion:^(NSError *_Nullable error) {
          if (error) {
            NEXKitBaseLogInfo(@"[%@] LCK hangup failed: %@", kNECallUILCKBridgeTag,
                              error.localizedDescription);
          } else {
            NEXKitBaseLogInfo(@"[%@] LCK hangup success", kNECallUILCKBridgeTag);
          }
        }
        muteCompletion:^(NSError *_Nullable error, BOOL mute) {
          if (error) {
            NEXKitBaseLogInfo(@"[%@] LCK mute failed: %@", kNECallUILCKBridgeTag,
                              error.localizedDescription);
          } else {
            NEXKitBaseLogInfo(@"[%@] LCK mute success: %d", kNECallUILCKBridgeTag, mute);
          }
        }];
  } else {
    NEXKitBaseLogInfo(@"[%@] receive VoIP payload but iOS < 17.4", kNECallUILCKBridgeTag);
  }

  if (completion) {
    completion();
  }
}

@end
