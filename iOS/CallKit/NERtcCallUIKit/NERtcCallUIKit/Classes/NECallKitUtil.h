// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import <NERtcCallKit/NERtcCallKit.h>
#import "NECallUIKitConfig.h"

NS_ASSUME_NONNULL_BEGIN

#define kNERtcCallKitUIErrorDomain @"com.netease.nertc.callkit.ui.error"

#ifdef __cplusplus
extern "C" {
#endif
void necallkit_async_main_safe(dispatch_block_t block);
void necallkit_sync_main_safe(dispatch_block_t block);

void necallkit_async_main(dispatch_block_t block);

#ifdef __cplusplus
}
#endif

@interface NECallKitUtil : NSObject

+ (UIColor *)colorWithHexString:(NSString *)hexString;

+ (NSString *)localizableWithKey:(NSString *)key;

+ (NSString *)incomingInviteTextWithCallType:(NECallType)callType
                             multiCallInvite:(BOOL)multiCallInvite;

+ (NECallType)requiredPermissionCallTypeForCallType:(NECallType)callType
                                    multiCallInvite:(BOOL)multiCallInvite;

+ (void)setLanguage:(NECallUILanguage)language;

+ (void)makeToast:(NSString *)message;

/// 检查权限
/// @param callType 通话类型，1-音频，2-视频
/// @param completion 完成回调，error 为 nil 表示权限已授予，否则表示权限被拒绝
+ (void)checkAuthorizationForCallType:(NSInteger)callType
                           completion:(void (^)(NSError *_Nullable error))completion;

/// 检查并申请权限；权限已拒绝时展示取消 / 去设置引导
/// @param callType 通话类型，1-音频，2-视频
/// @param viewController 弹窗所在控制器；传 nil 时自动查找当前顶层控制器
/// @param completion granted 为 YES 表示权限已授予；openSettings 为 YES 表示用户选择去设置
+ (void)requestAuthorizationForCallType:(NSInteger)callType
                    fromViewController:(nullable UIViewController *)viewController
                            completion:(void (^)(BOOL granted, BOOL openSettings))completion;

@end

NS_ASSUME_NONNULL_END
