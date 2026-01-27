// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
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

+ (void)setLanguage:(NECallUILanguage)language;

+ (void)makeToast:(NSString *)message;

/// 检查权限
/// @param callType 通话类型，1-音频，2-视频
/// @param completion 完成回调，error 为 nil 表示权限已授予，否则表示权限被拒绝
+ (void)checkAuthorizationForCallType:(NSInteger)callType
                           completion:(void (^)(NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
