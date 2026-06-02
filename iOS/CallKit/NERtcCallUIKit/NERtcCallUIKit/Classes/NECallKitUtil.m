//// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NECallKitUtil.h"
#import <AVFoundation/AVFoundation.h>
#import <NECommonUIKit/UIView+YXToast.h>
#import <NERtcCallKit/NERtcCallKit.h>
#import "NERtcCallUIKit.h"

typedef NS_ENUM(NSInteger, NECallKitPermissionType) {
  NECallKitPermissionTypeMicrophone = 0,
  NECallKitPermissionTypeCamera = 1,
  NECallKitPermissionTypeAll = 2,
};

#pragma mark-- nertc main queue

void necallkit_async_main_safe(dispatch_block_t block) {
  if ([NSThread isMainThread]) {
    block();
  } else {
    dispatch_async(dispatch_get_main_queue(), block);
  }
}

void necallkit_sync_main_safe(dispatch_block_t block) {
  if ([NSThread isMainThread]) {
    block();
  } else {
    dispatch_sync(dispatch_get_main_queue(), block);
  }
}

void necallkit_async_main(dispatch_block_t block) {
  dispatch_async(dispatch_get_main_queue(), block);
}

static NECallUILanguage _language = NECallUILanguageAuto;

@implementation NECallKitUtil

+ (void)performAfterPresentationSettledInViewController:(UIViewController *)viewController
                                             retryCount:(NSInteger)retryCount
                                             completion:(dispatch_block_t)completion {
  if (!completion) {
    return;
  }
  if (![NSThread isMainThread]) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self performAfterPresentationSettledInViewController:viewController
                                                 retryCount:retryCount
                                                 completion:completion];
    });
    return;
  }
  UIAlertController *alertController = [self alertControllerInViewController:viewController];
  if (alertController == nil) {
    id<UIViewControllerTransitionCoordinator> coordinator =
        [self transitionCoordinatorInViewController:viewController];
    if (coordinator && retryCount > 0) {
      [self waitForTransitionCoordinator:coordinator
                              completion:^{
                                [self performAfterPresentationSettledInViewController:
                                          viewController
                                                                          retryCount:retryCount - 1
                                                                          completion:completion];
                              }];
      return;
    }
    completion();
    return;
  }

  if ([self isAlertControllerTransitioning:alertController]) {
    if (retryCount <= 0) {
      completion();
      return;
    }
    [self waitForAlertControllerTransition:alertController
                                completion:^{
                                  [self performAfterPresentationSettledInViewController:
                                            viewController
                                                                            retryCount:retryCount - 1
                                                                            completion:completion];
                                }];
    return;
  }

  if (alertController.presentingViewController != nil) {
    if (retryCount <= 0) {
      completion();
      return;
    }
    [alertController dismissViewControllerAnimated:NO
                                        completion:^{
                                          [self performAfterPresentationSettledInViewController:
                                                    viewController
                                                                                retryCount:retryCount - 1
                                                                                completion:completion];
                                        }];
    return;
  }

  completion();
}

// 16 进制颜色转换 转换成 UIColor
+ (UIColor *)colorWithHexString:(NSString *)hexString {
  unsigned int hexValue = 0;
  NSScanner *scanner = [NSScanner scannerWithString:hexString];
  [scanner setScanLocation:1];     // 跳过字符串开头的#
  [scanner scanHexInt:&hexValue];  // 将字符串转换为16进制整数
  UIColor *color = [UIColor colorWithRed:((hexValue & 0xFF0000) >> 16) / 255.0
                                   green:((hexValue & 0xFF00) >> 8) / 255.0
                                    blue:(hexValue & 0xFF) / 255.0
                                   alpha:1.0];
  return color;
}

+ (void)setLanguage:(NECallUILanguage)language {
  _language = language;
}

+ (NSString *)localizableWithKey:(NSString *)key {
  switch (_language) {
    case NECallUILanguageZhHans: {
      NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[NERtcCallUIKit class]]
                                                      pathForResource:@"zh-Hans"
                                                               ofType:@"lproj"]];
      return [bundle localizedStringForKey:key value:nil table:nil];
    }
    case NECallUILanguageEn: {
      NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[NERtcCallUIKit class]]
                                                      pathForResource:@"en"
                                                               ofType:@"lproj"]];
      return [bundle localizedStringForKey:key value:nil table:nil];
    }
    case NECallUILanguageAuto:
    default:
      break;
  }
  return [[NSBundle bundleForClass:NERtcCallUIKit.class] localizedStringForKey:key
                                                                         value:nil
                                                                         table:@"Localizable"];
}

+ (NSString *)incomingInviteTextWithCallType:(NECallType)callType
                             multiCallInvite:(BOOL)multiCallInvite {
  if (multiCallInvite) {
    return [self localizableWithKey:@"invite_single_to_group_call"];
  }
  return [self localizableWithKey:(callType == NECallTypeAudio ? @"invite_audio_call"
                                                               : @"invite_video_call")];
}

+ (NECallType)requiredPermissionCallTypeForCallType:(NECallType)callType
                                    multiCallInvite:(BOOL)multiCallInvite {
  // 单呼转多人邀请接听对齐 SDK accept: 需要同时具备麦克风和相机权限。
  return multiCallInvite ? NECallTypeVideo : callType;
}

+ (void)makeToast:(NSString *)message {
  UIWindow *window = nil;
  if (@available(iOS 13.0, *)) {
    for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes.allObjects) {
      if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone ||
          scene.activationState == UISceneActivationStateForegroundActive) {
        window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
      }
    }
  }

  if (!window) {
    window = UIApplication.sharedApplication.keyWindow;
  }

  if (window) {
    window.windowLevel = UIWindowLevelStatusBar - 1;
    [window makeKeyAndVisible];
    [window ne_makeToast:message];
  }
}

+ (void)checkAuthorizationForCallType:(NSInteger)callType
                           completion:(void (^)(NSError *_Nullable error))completion {
  NERtcCallType type = (callType == 2) ? NERtcCallTypeVideo : NERtcCallTypeAudio;
  NSMutableArray<AVMediaType> *mediaTypes = [NSMutableArray arrayWithObject:AVMediaTypeAudio];
  if (type == NERtcCallTypeVideo) {
    [mediaTypes addObject:AVMediaTypeVideo];
  }

  NSDictionary<AVMediaType, NSNumber *> *errorCodes = @{
    AVMediaTypeAudio : @(21000),  // kNERtcCallKitAudioAuthError
    AVMediaTypeVideo : @(21001)   // kNERtcCallKitVideoAuthError
  };
  NSDictionary<AVMediaType, NSString *> *errorDescriptions =
      @{AVMediaTypeAudio : @"未开启麦克风权限", AVMediaTypeVideo : @"未开启摄像头权限"};

  dispatch_queue_t queue =
      dispatch_queue_create("com.netease.yunxin.callkit.check_auth", DISPATCH_QUEUE_SERIAL);
  dispatch_semaphore_t sema = dispatch_semaphore_create(0);
  dispatch_async(queue, ^{
    __block NSError *error;
    for (AVMediaType mediaType in mediaTypes) {
      __block BOOL authGood = YES;
      AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
      switch (status) {
        case AVAuthorizationStatusNotDetermined: {
          [AVCaptureDevice requestAccessForMediaType:mediaType
                                   completionHandler:^(BOOL granted) {
                                     if (!granted) {
                                       authGood = NO;
                                     }
                                     dispatch_semaphore_signal(sema);
                                   }];
          dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
          break;
        }
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied: {
          authGood = NO;
          break;
        }
        case AVAuthorizationStatusAuthorized:
          break;
        default:
          break;
      }
      if (!authGood) {
        error =
            [NSError errorWithDomain:kNERtcCallKitUIErrorDomain
                                code:errorCodes[mediaType].integerValue
                            userInfo:@{NSLocalizedDescriptionKey : errorDescriptions[mediaType]}];
        break;
      }
    }
    if (completion) {
      dispatch_async(dispatch_get_main_queue(), ^{
        completion(error);
      });
    }
  });
}

+ (void)requestAuthorizationForCallType:(NSInteger)callType
                    fromViewController:(UIViewController *)viewController
                            completion:(void (^)(BOOL granted, BOOL openSettings))completion {
  NERtcCallType type = (callType == 2) ? NERtcCallTypeVideo : NERtcCallTypeAudio;
  NSMutableArray<AVMediaType> *mediaTypes = [NSMutableArray arrayWithObject:AVMediaTypeAudio];
  if (type == NERtcCallTypeVideo) {
    [mediaTypes addObject:AVMediaTypeVideo];
  }

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    __block BOOL granted = YES;
    __block NECallKitPermissionType deniedPermission = NECallKitPermissionTypeAll;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    for (AVMediaType mediaType in mediaTypes) {
      __block BOOL authGood = YES;
      AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
      switch (status) {
        case AVAuthorizationStatusNotDetermined: {
          [AVCaptureDevice requestAccessForMediaType:mediaType
                                   completionHandler:^(BOOL allowed) {
                                     authGood = allowed;
                                     dispatch_semaphore_signal(sema);
                                   }];
          dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
          break;
        }
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
          authGood = NO;
          break;
        case AVAuthorizationStatusAuthorized:
          break;
        default:
          break;
      }
      if (!authGood) {
        granted = NO;
        deniedPermission = [mediaType isEqualToString:AVMediaTypeAudio]
                               ? NECallKitPermissionTypeMicrophone
                               : NECallKitPermissionTypeCamera;
        break;
      }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      if (granted) {
        if (completion) {
          completion(YES, NO);
        }
        return;
      }
      [self showPermissionDeniedAlertWithType:deniedPermission
                           fromViewController:viewController
                                   completion:completion];
    });
  });
}

+ (void)showPermissionDeniedAlertWithType:(NECallKitPermissionType)type
                       fromViewController:(UIViewController *)viewController
                               completion:(void (^)(BOOL granted, BOOL openSettings))completion {
  [self showPermissionDeniedAlertWithType:type
                       fromViewController:viewController
                               retryCount:1
                               completion:completion];
}

+ (void)showPermissionDeniedAlertWithType:(NECallKitPermissionType)type
                       fromViewController:(UIViewController *)viewController
                               retryCount:(NSInteger)retryCount
                               completion:(void (^)(BOOL granted, BOOL openSettings))completion {
  UIViewController *presentingViewController =
      [self isPermissionPresenterUsable:viewController]
          ? viewController
          : [self topViewControllerExcludingWindow:viewController.view.window];
  if (!presentingViewController) {
    if (completion) {
      completion(NO, NO);
    }
    return;
  }
  if ([self isPermissionPresenterBusy:presentingViewController]) {
    if (retryCount > 0) {
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)),
                     dispatch_get_main_queue(), ^{
                       [self showPermissionDeniedAlertWithType:type
                                            fromViewController:viewController
                                                    retryCount:retryCount - 1
                                                    completion:completion];
                     });
      return;
    }
    if (completion) {
      completion(NO, NO);
    }
    return;
  }

  NSString *title = [self localizableWithKey:@"permission"];
  NSString *message = [self permissionDeniedMessageWithType:type];
  UIAlertController *alert =
      [UIAlertController alertControllerWithTitle:title
                                          message:message
                                   preferredStyle:UIAlertControllerStyleAlert];
  __weak UIAlertController *weakAlert = alert;
  void (^completeAfterAlertDismiss)(UIAlertController *, BOOL, BOOL, dispatch_block_t) =
      ^(UIAlertController *targetAlert, BOOL granted, BOOL openSettings,
        dispatch_block_t beforeCompletion) {
    void (^finish)(void) = ^{
      if (beforeCompletion) {
        beforeCompletion();
      }
      if (completion) {
        completion(granted, openSettings);
      }
    };
    id<UIViewControllerTransitionCoordinator> coordinator =
        targetAlert.transitionCoordinator ?: targetAlert.presentingViewController.transitionCoordinator;
    if (coordinator &&
        [coordinator animateAlongsideTransition:nil
                                     completion:^(__unused id<UIViewControllerTransitionCoordinatorContext>
                                                      context) {
                                       dispatch_async(dispatch_get_main_queue(), finish);
                                     }]) {
      return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), finish);
  };
  UIAlertAction *cancelAction =
      [UIAlertAction actionWithTitle:[self localizableWithKey:@"call_cancel"]
                               style:UIAlertActionStyleDefault
                             handler:^(__unused UIAlertAction *action) {
                               completeAfterAlertDismiss(weakAlert, NO, NO, nil);
                             }];
  UIAlertAction *settingsAction =
      [UIAlertAction actionWithTitle:[self localizableWithKey:@"go_to_settings"]
                               style:UIAlertActionStyleDefault
                             handler:^(__unused UIAlertAction *action) {
                               completeAfterAlertDismiss(weakAlert, NO, YES, ^{
                                 NSURL *url =
                                     [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                 if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
                                   [[UIApplication sharedApplication] openURL:url
                                                                      options:@{}
                                                            completionHandler:nil];
                                 }
                               });
                             }];
  [alert addAction:cancelAction];
  [alert addAction:settingsAction];
  [presentingViewController presentViewController:alert animated:YES completion:nil];
}

+ (NSString *)permissionDeniedMessageWithType:(NECallKitPermissionType)type {
  switch (type) {
    case NECallKitPermissionTypeMicrophone:
      return [self localizableWithKey:@"microphone_permission_denied"];
    case NECallKitPermissionTypeCamera:
      return [self localizableWithKey:@"camera_permission_denied"];
    case NECallKitPermissionTypeAll:
    default:
      return [self localizableWithKey:@"call_permission_denied"];
  }
}

+ (UIViewController *)topViewController {
  UIWindow *window = nil;
  if (@available(iOS 13.0, *)) {
    for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes.allObjects) {
      if (![scene isKindOfClass:UIWindowScene.class]) {
        continue;
      }
      if (scene.activationState != UISceneActivationStateForegroundActive &&
          scene.activationState != UISceneActivationStateForegroundInactive) {
        continue;
      }
      for (UIWindow *candidate in scene.windows) {
        if (candidate.isKeyWindow) {
          window = candidate;
          break;
        }
      }
      if (!window) {
        window = scene.windows.firstObject;
      }
      if (window) {
        break;
      }
    }
  }
  if (!window) {
    window = UIApplication.sharedApplication.keyWindow;
  }
  UIViewController *controller = window.rootViewController;
  while (controller.presentedViewController) {
    controller = controller.presentedViewController;
  }
  return controller;
}

+ (UIViewController *)topViewControllerExcludingWindow:(UIWindow *)excludedWindow {
  UIWindow *window = nil;
  if (@available(iOS 13.0, *)) {
    for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes.allObjects) {
      if (![scene isKindOfClass:UIWindowScene.class]) {
        continue;
      }
      if (scene.activationState != UISceneActivationStateForegroundActive &&
          scene.activationState != UISceneActivationStateForegroundInactive) {
        continue;
      }
      for (UIWindow *candidate in scene.windows) {
        if (candidate.isKeyWindow &&
            [self isPermissionWindowUsable:candidate excludingWindow:excludedWindow]) {
          window = candidate;
          break;
        }
      }
      if (!window) {
        for (UIWindow *candidate in scene.windows) {
          if ([self isPermissionWindowUsable:candidate excludingWindow:excludedWindow]) {
            window = candidate;
            break;
          }
        }
      }
      if (window) {
        break;
      }
    }
  }
  if (!window &&
      [self isPermissionWindowUsable:UIApplication.sharedApplication.keyWindow
                     excludingWindow:excludedWindow]) {
    window = UIApplication.sharedApplication.keyWindow;
  }
  UIViewController *controller = window.rootViewController;
  while (controller.presentedViewController) {
    controller = controller.presentedViewController;
  }
  return controller;
}

+ (BOOL)isPermissionPresenterUsable:(UIViewController *)viewController {
  return viewController &&
         [self isPermissionWindowUsable:viewController.view.window excludingWindow:nil];
}

+ (BOOL)isPermissionPresenterBusy:(UIViewController *)viewController {
  return viewController.isBeingDismissed || viewController.isMovingFromParentViewController ||
         viewController.presentedViewController != nil ||
         [viewController isKindOfClass:UIAlertController.class];
}

+ (UIAlertController *)alertControllerInViewController:(UIViewController *)viewController {
  if (viewController == nil) {
    return nil;
  }
  if ([viewController isKindOfClass:UIAlertController.class]) {
    return (UIAlertController *)viewController;
  }
  UIAlertController *alertController =
      [self alertControllerInViewController:viewController.presentedViewController];
  if (alertController != nil) {
    return alertController;
  }
  if ([viewController isKindOfClass:UINavigationController.class]) {
    UINavigationController *navigationController = (UINavigationController *)viewController;
    alertController = [self alertControllerInViewController:navigationController.topViewController];
    if (alertController != nil) {
      return alertController;
    }
  }
  if ([viewController isKindOfClass:UITabBarController.class]) {
    UITabBarController *tabBarController = (UITabBarController *)viewController;
    alertController =
        [self alertControllerInViewController:tabBarController.selectedViewController];
    if (alertController != nil) {
      return alertController;
    }
  }
  for (UIViewController *childViewController in viewController.childViewControllers) {
    alertController = [self alertControllerInViewController:childViewController];
    if (alertController != nil) {
      return alertController;
    }
  }
  return nil;
}

+ (BOOL)isAlertControllerTransitioning:(UIAlertController *)alertController {
  return alertController.transitionCoordinator != nil ||
         alertController.presentingViewController.transitionCoordinator != nil ||
         alertController.isBeingPresented || alertController.isBeingDismissed;
}

+ (void)waitForAlertControllerTransition:(UIAlertController *)alertController
                              completion:(dispatch_block_t)completion {
  id<UIViewControllerTransitionCoordinator> coordinator =
      alertController.transitionCoordinator ?:
          alertController.presentingViewController.transitionCoordinator;
  [self waitForTransitionCoordinator:coordinator completion:completion];
}

+ (id<UIViewControllerTransitionCoordinator>)transitionCoordinatorInViewController:
    (UIViewController *)viewController {
  if (viewController == nil) {
    return nil;
  }
  if (viewController.transitionCoordinator != nil) {
    return viewController.transitionCoordinator;
  }
  id<UIViewControllerTransitionCoordinator> coordinator =
      [self transitionCoordinatorInViewController:viewController.presentedViewController];
  if (coordinator != nil) {
    return coordinator;
  }
  if ([viewController isKindOfClass:UINavigationController.class]) {
    UINavigationController *navigationController = (UINavigationController *)viewController;
    coordinator = [self transitionCoordinatorInViewController:navigationController.topViewController];
    if (coordinator != nil) {
      return coordinator;
    }
  }
  if ([viewController isKindOfClass:UITabBarController.class]) {
    UITabBarController *tabBarController = (UITabBarController *)viewController;
    coordinator =
        [self transitionCoordinatorInViewController:tabBarController.selectedViewController];
    if (coordinator != nil) {
      return coordinator;
    }
  }
  for (UIViewController *childViewController in viewController.childViewControllers) {
    coordinator = [self transitionCoordinatorInViewController:childViewController];
    if (coordinator != nil) {
      return coordinator;
    }
  }
  return nil;
}

+ (void)waitForTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
                          completion:(dispatch_block_t)completion {
  if (!completion) {
    return;
  }
  if (coordinator &&
      [coordinator animateAlongsideTransition:nil
                                   completion:^(__unused id<UIViewControllerTransitionCoordinatorContext>
                                                    context) {
                                     dispatch_async(dispatch_get_main_queue(), completion);
                                   }]) {
    return;
  }
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), completion);
}

+ (BOOL)isPermissionWindowUsable:(UIWindow *)window excludingWindow:(UIWindow *)excludedWindow {
  if (!window || window == excludedWindow || window.hidden || window.alpha <= 0) {
    return NO;
  }
  CGSize screenSize = UIScreen.mainScreen.bounds.size;
  CGFloat screenWidth = MIN(screenSize.width, screenSize.height);
  CGFloat screenHeight = MAX(screenSize.width, screenSize.height);
  CGSize windowSize = window.bounds.size;
  CGFloat windowWidth = MIN(windowSize.width, windowSize.height);
  CGFloat windowHeight = MAX(windowSize.width, windowSize.height);
  return windowWidth >= screenWidth * 0.8 && windowHeight >= screenHeight * 0.8;
}
@end
