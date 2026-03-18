//// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NECallKitUtil.h"
#import <AVFoundation/AVFoundation.h>
#import <NECommonUIKit/UIView+YXToast.h>
#import <NERtcCallKit/NERtcCallKit.h>
#import "NERtcCallUIKit.h"

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
@end
