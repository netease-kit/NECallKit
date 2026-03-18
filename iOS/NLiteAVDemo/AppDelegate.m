// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "AppDelegate.h"
#import <AVFAudio/AVAudioSession.h>
#import <NERtcCallKit/NECallEngine.h>
#import <NERtcCallUIKit/NERtcCallUIKit.h>
#import <NIMSDK/NIMSDK.h>
#import <PushKit/PushKit.h>
#import <UserNotifications/UserNotifications.h>
#import "CustomVideoCallingController.h"
#import "NECallCustomController.h"
#import "NEGroupContactsController.h"
#import "NEMenuViewController.h"
#import "NENavigator.h"
#import "NEPSTNViewController.h"
#import "SettingManager.h"

@interface AppDelegate () <NERtcCallKitDelegate,
                           UNUserNotificationCenterDelegate,
                           NIMSDKConfigDelegate,
                           NECallUIKitDelegate,
                           PKPushRegistryDelegate>

@property(nonatomic, strong) PKPushRegistry *pushRegistry;

@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  NSLog(@"YATLCK didFinishLaunchingWithOptions");
  [self initWindow];
  [self setupSDK];
  [self registerAPNS];
  __weak typeof(self) weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
#if DEBUG
    [weakSelf commonInit];
#else
      [weakSelf commonInit];
#endif
  });
  return YES;
}

- (void)initWindow {
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  self.window.backgroundColor = UIColor.whiteColor;
  NEMenuViewController *menuVC = [[NEMenuViewController alloc] init];
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:menuVC];
  self.window.rootViewController = nav;
  [NENavigator shared].navigationController = nav;
  [self.window makeKeyAndVisible];
  /*
// 外部注册自定义UI示例代码
NSMutableDictionary<NSNumber *, NSMutableDictionary<NSString *, NSString *> *> *stateConfigDic =
[[NSMutableDictionary alloc] init]; NSMutableDictionary<NSString *, NSString *> *uiConfig =
[[NSMutableDictionary alloc] init]; [uiConfig
setObject:NSStringFromClass(NEAudioCallingController.class) forKey:kAudioCalling]; [stateConfigDic
setObject:uiConfig forKey:@(kNormalUIType)];

// 内部初始化获取
NSMutableDictionary<NSString *, NSString *> *getConfig = [stateConfigDic
objectForKey:@(kNormalUIType)]; NSString *className = [getConfig objectForKey:kAudioCalling];
NSLog(@"class name : %@", className);

// 动态构建外部实例
Class cls = NSClassFromString(className);
UIViewController *controller = [[cls alloc] init];
NSLog(@"class instance : %@", controller);
   */
}

/*
- (void)setupCallKit {

    // 美颜设置
    NERtcEngine *coreEngine = [NERtcEngine sharedEngine];
    NSDictionary *params = @{
        kNERtcKeyPublishSelfStreamEnabled: @YES,    // 打开推流
        kNERtcKeyVideoCaptureObserverEnabled: @YES  // 将摄像头采集的数据回调给用户
    };
    [coreEngine setParameters:params];

    // 呼叫组件初始化
    NERtcCallOptions *option = [NERtcCallOptions new];
    option.APNSCerName = @"your apns cer name";
    NERtcCallKit *callkit = [NERtcCallKit sharedInstance];
    [callkit setupAppKey:@"your app key" options:option];

    //呼叫组件设置rtc代理中转
    callkit.engineDelegate = self;
}

// 在代理方法中对视频数据进行处理
- (void)onNERtcEngineVideoFrameCaptured:(CVPixelBufferRef)bufferRef
rotation:(NERtcVideoRotationType)rotation
{
    // 对视频数据 bufferRef 进行处理, 务必保证 CVPixelBufferRef 的地址值不变，分辨率不变
}*/

- (void)setupSDK {
  NIMSDKOption *option = [NIMSDKOption optionWithAppKey:kAppKey];
  option.apnsCername = kAPNSCerName;
  if (@available(iOS 17.4, *)) {
    option.pkCername = VoIPCerName;
  }
  option.v2 = YES;
  [NIMSDK.sharedSDK registerWithOptionV2:option v2Option:nil];

  NESetupConfig *setupConfig = [[NESetupConfig alloc] initWithAppkey:kAppKey];
  [[NECallEngine sharedInstance] setup:setupConfig];

  NECallUIKitConfig *config = [[NECallUIKitConfig alloc] init];
  config.uiConfig.showCallingSwitchCallType = YES;
  config.uiConfig.enableFloatingWindow = YES;
  config.uiConfig.enableFloatingWindowOutOfApp = YES;
  config.uiConfig.language = NECallUILanguageAuto;
  config.uiConfig.enableGroupCallInviteOthersWhenCalling = YES;
  [[NERtcCallUIKit sharedInstance] setupWithConfig:config];
  [NERtcCallUIKit sharedInstance].delegate = self;

  // 自定义UI示例
  [NERtcCallUIKit sharedInstance].customControllerClass = NECallCustomController.class;

  NSMutableDictionary *cusstomDic = [[NSMutableDictionary alloc] init];
  [cusstomDic setObject:CustomVideoCallingController.class forKey:kVideoCalling];
  [[NERtcCallUIKit sharedInstance] setCustomCallClass:cusstomDic];

  GroupConfigParam *param = [[GroupConfigParam alloc] init];
  param.appid = kAppKey;
  param.rtcSafeMode = YES;
  [[NEGroupCallKit sharedInstance] setupGroupCall:param];
}

- (void)didCallComingWithInviteInfo:(NEInviteInfo *)inviteInfo
                      withCallParam:(NEUICallParam *)callParam
                     withCompletion:(void (^)(BOOL))completion {
  callParam.remoteDefaultImage = [[SettingManager shareInstance] remoteDefaultImage];
  callParam.muteDefaultImage = [[SettingManager shareInstance] muteDefaultImage];
  completion(YES);
}

- (void)inviteUsersWithCallId:(NSString *)callId
                  inCallUsers:(NSArray<NSString *> *)inCallUsers
                   completion:(void (^)(NSArray<NSString *> *_Nullable users))completion {
  NSLog(@"[GroupCallLayout] 🔄 AppDelegate 收到邀请用户请求，callId: %@, 当前通话用户数: %ld",
        callId, (long)inCallUsers.count);
  NSLog(@"[GroupCallLayout] 🔄 AppDelegate 开始创建 NEGroupContactsController");

  // 创建群组联系人控制器
  NEGroupContactsController *group = [[NEGroupContactsController alloc] init];
  group.isInvite = YES;

  // 将用户ID字符串转换为 NEUser 并添加到 inCallUserDic
  for (NSString *userId in inCallUsers) {
    // 这里需要根据用户ID创建 NEUser 对象
    // 由于我们只有用户ID，可以创建一个基本的 NEUser 对象
    NEUser *neUser = [[NEUser alloc] init];
    neUser.imAccid = userId;
    neUser.mobile = @"";  // 需要后续获取
    neUser.avatar = @"";  // 需要后续获取
    [group.inCallUserDic setObject:neUser forKey:userId];
  }
  group.totalCount = GroupCallUserLimit - inCallUsers.count;
  group.hasJoinCount = inCallUsers.count;

  // 设置完成回调
  __weak typeof(self) weakSelf = self;
  group.completion = ^(NSArray<NEUser *> *_Nonnull users) {
    NSLog(@"[GroupCallLayout] 🔄 联系人选择完成，获得 %ld 个用户", (long)users.count);

    // 将 NEUser 转换为用户ID字符串
    NSMutableArray<NSString *> *userIds = [[NSMutableArray alloc] init];
    for (NEUser *user in users) {
      if (user.imAccid.length > 0) {
        [userIds addObject:user.imAccid];
      }
    }

    // 回调给调用方，返回用户ID字符串数组
    if (completion) {
      completion([userIds copy]);
    }
  };

  group.title = @"邀请";
  group.modalPresentationStyle = UIModalPresentationFullScreen;
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:group];

  // 获取当前窗口并展示
  UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
  UIViewController *rootVC = keyWindow.rootViewController;

  // 如果 keyWindow 为空，尝试使用 self.window
  if (!keyWindow) {
    keyWindow = self.window;
    rootVC = keyWindow.rootViewController;
    NSLog(@"[GroupCallLayout] 🔄 AppDelegate 使用 self.window: %@", keyWindow);
  }

  NSLog(@"[GroupCallLayout] 🔄 AppDelegate 准备弹出页面，keyWindow: %@, rootVC: %@", keyWindow,
        rootVC);
  NSLog(@"[GroupCallLayout] 🔄 AppDelegate rootVC.view: %@", rootVC.view);
  NSLog(@"[GroupCallLayout] 🔄 AppDelegate rootVC.view.window: %@", rootVC.view.window);
  NSLog(@"[GroupCallLayout] 🔄 AppDelegate nav: %@", nav);

  if (rootVC) {
    // 检查当前是否有模态页面正在展示
    UIViewController *presentedVC = rootVC.presentedViewController;
    if (presentedVC) {
      [presentedVC presentViewController:nav animated:YES completion:nil];
    } else {
      NSLog(@"[GroupCallLayout] 🔄 AppDelegate 没有模态页面在展示，直接弹出");
      @try {
        [rootVC presentViewController:nav
                             animated:YES
                           completion:^{
                             NSLog(@"[GroupCallLayout] 🔄 AppDelegate 页面弹出完成");
                           }];
      } @catch (NSException *exception) {
        NSLog(@"[GroupCallLayout] ⚠️ AppDelegate 弹出页面异常: %@", exception);
      }
    }
  } else {
    NSLog(@"[GroupCallLayout] ⚠️ AppDelegate rootVC 为空，无法弹出页面");
  }
}

/// 将 NEGroupUser 转换为 NEUser
- (NEUser *)convertToNEUser:(NEGroupUser *)groupUser {
  if (!groupUser) {
    return nil;
  }

  NEUser *neUser = [[NEUser alloc] init];

  // 基本属性转换
  neUser.mobile = groupUser.mobile ?: @"";
  neUser.avatar = groupUser.avatar ?: @"";
  neUser.imAccid = groupUser.imAccid ?: @"";

  // 群组呼叫状态转换
  neUser.state = groupUser.state;
  neUser.uid = groupUser.uid;
  neUser.isShowLocalVideo = groupUser.isShowLocalVideo;
  neUser.isOpenVideo = groupUser.isOpenVideo;

  return neUser;
}

/// 将 NEUser 转换为 NEGroupUser
- (NEGroupUser *)convertToGroupUser:(NEUser *)neUser {
  if (!neUser) {
    return nil;
  }

  NEGroupUser *groupUser = [[NEGroupUser alloc] init];

  // 基本属性转换
  groupUser.mobile = neUser.mobile ?: @"";
  groupUser.avatar = neUser.avatar ?: @"";
  groupUser.imAccid = neUser.imAccid ?: @"";

  // 群组呼叫状态转换
  groupUser.state = neUser.state;
  groupUser.uid = neUser.uid;
  groupUser.isShowLocalVideo = neUser.isShowLocalVideo;
  groupUser.isOpenVideo = neUser.isOpenVideo;

  return groupUser;
}

- (void)registerAPNS {
  // 1.申请权限
  if (@available(iOS 10.0, *)) {
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    [[UNUserNotificationCenter currentNotificationCenter]
        requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound |
                                        UNAuthorizationOptionAlert
                      completionHandler:^(BOOL granted, NSError *_Nullable error) {
                        if (!granted) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                            [UIApplication.sharedApplication.keyWindow
                                ne_makeToast:@"请到设置中开启推送功能"];
                          });
                        }
                      }];
  } else {
    UIUserNotificationType types =
        UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types
                                                                             categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
  }
  // 2.注册通知
  [[UIApplication sharedApplication] registerForRemoteNotifications];
  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

  self.pushRegistry = [[PKPushRegistry alloc]
      initWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
  //    self.pushRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];

  self.pushRegistry.delegate = self;
  self.pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
}

// 3.APNS注册回调
- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  [[NERtcCallKit sharedInstance] updateApnsToken:deviceToken];
  [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:deviceTokenKey];
}

- (void)application:(UIApplication *)application
    didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  [self.window ne_makeToast:[NSString stringWithFormat:@"注册devicetoken失败，Error%@", error]];
}

- (void)commonInit {
}

// 在后收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
    didReceiveNotificationResponse:(UNNotificationResponse *)response
             withCompletionHandler:(void (^)(void))completionHandler {
  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
  completionHandler();
}
// 低于iOS 10.0
- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo {
  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}
- (void)application:(UIApplication *)application
    didReceiveLocalNotification:(UILocalNotification *)notification {
  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

#pragma mark - PKPushRegistryDelegate
- (void)pushRegistry:(PKPushRegistry *)registry
    didUpdatePushCredentials:(PKPushCredentials *)credentials
                     forType:(PKPushType)type {
  if ([credentials.token length] == 0) {
    NSLog(@"voip token NULL");
    return;
  }

  [[NIMSDK sharedSDK] updatePushKitToken:credentials.token];
  [[NSUserDefaults standardUserDefaults] setObject:credentials.token forKey:pushKitDeviceTokenKey];
}

- (void)pushRegistry:(PKPushRegistry *)registry
    didReceiveIncomingPushWithPayload:(PKPushPayload *)payload
                              forType:(PKPushType)type
                withCompletionHandler:(void (^)(void))completion {
  NSDictionary *dictionaryPayload = payload.dictionaryPayload;
  // 判断是否是云信发的payload
  if (![dictionaryPayload objectForKey:@"nim"]) {
    NSLog(@"not found nim payload");
    return;
  }

  //  NSString *ringPath = [[NSBundle mainBundle] pathForResource:@"avchat_ring" ofType:@"mp3"];

  if (@available(iOS 17.4, *)) {
    NECallSystemIncomingCallParam *param = [[NECallSystemIncomingCallParam alloc] init];
    param.payload = dictionaryPayload;
    //    param.ringtoneName = ringPath;

    NECallSystemIncomingCustomCallParam *customParam =
        [[NECallSystemIncomingCustomCallParam alloc] init];
    customParam.callType = NECallTypeAudio;
    param.customPayload = customParam;

    [[NECallEngine sharedInstance] reportIncomingCallWithParam:param
        acceptCompletion:^(NSError *_Nullable error, NECallInfo *_Nullable callInfo) {
          if (error) {
            NSLog(@"lck accept failed %@", error);
          } else {
            NSLog(@"lck accept success %@", error);
          }
        }
        hangupCompletion:^(NSError *_Nullable error) {
          if (error) {
            NSLog(@"lck hangup error %@", error);
          } else {
            NSLog(@"lck hangup success");
          }
        }
        muteCompletion:^(NSError *_Nullable error, BOOL mute) {
          if (error) {
            NSLog(@"lck mute error %@", error);
          } else {
            NSLog(@"lck mute success %d", mute);
          }
        }];
  }

  completion();
}

@end
