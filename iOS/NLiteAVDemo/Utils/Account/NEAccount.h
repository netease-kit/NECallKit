// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "NEUser.h"

NS_ASSUME_NONNULL_BEGIN

// 登录操作
typedef enum NSUIntger {
  NEAccountActionLogin = 1,        // 登录
  NEAccountActionLogout = 1 << 1,  // 注销
  NEAccountActionAll = NEAccountActionLogin | NEAccountActionLogout
} NEAccountAction;

typedef void (^NEAccountComplete)(NSDictionary *_Nullable data, NSError *_Nullable error);
typedef void (^NEAccountActionBlock)(NEAccountAction action);

@interface NEAccount : NSObject

@property(nonatomic, readonly, assign) BOOL hasLogin;
@property(nonatomic, readonly, strong, nullable) NEUser *userModel;
/**
 获取账号实例
 */
+ (instancetype)shared;

@end

/**
 账号行为监听
 */

@interface NEAccount (Observer)

/**
 注册账户行为监听
 @param object      - 监听对象
 @param actionBlock - 监听闭包
 */
+ (void)addObserverForObject:(_Nonnull id)object
                 actionBlock:(_Nonnull NEAccountActionBlock)actionBlock;

/**
 注册账户行为监听
 @param object      - 监听对象
 @param action      - 登录行为
 @param actionBlock - 监听闭包
 */
+ (void)addObserverForObject:(_Nonnull id)object
                      action:(NEAccountAction)action
                 actionBlock:(_Nonnull NEAccountActionBlock)actionBlock;

/**
 移除账号监听
 @param object      - 监听对象
 */
+ (void)removeObserverForObject:(_Nonnull id)object;

@end

/**
 账号登录/登出
 */

@interface NEAccount (Login)

/**
 退出登录
 @param completion  - 回调闭包
*/
+ (void)logoutWithCompletion:(_Nullable NEAccountComplete)completion;

/**
 账号ID和Token登录
 @param accountId    - 账号ID
 @param token        - Token
 @param completion   - 回调闭包
 */
+ (void)loginWithAccountId:(NSString *)accountId
                     token:(NSString *)token
                completion:(_Nullable NEAccountComplete)completion;

@end

NS_ASSUME_NONNULL_END
