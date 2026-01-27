//
//  V2NIMStatisticsServiceProtocol.h
//  NIMSDK
//
//  Created by 陈吉力 on 2025/7/28.
//  Copyright © 2025 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "V2NIMBase.h"

@class V2NIMDatabaseInfo;

@protocol V2NIMStatisticsListener;

NS_ASSUME_NONNULL_BEGIN

typedef void (^V2NIMGetDatabaseInfosCallback)(NSArray<V2NIMDatabaseInfo *> *result);

@protocol V2NIMStatisticsService <NSObject>

/**
 * 获取本端当前登录用户所有数据库信息
 *
 * @param success 成功回调，返回数据库信息数组
 * @param failure 失败回调，返回错误信息
 */
- (void)getDatabaseInfos:(V2NIMGetDatabaseInfosCallback)success
                 failure:(nullable V2NIMFailureCallback)failure;

@end

@protocol V2NIMStatisticsListener <NSObject>
@optional

@end

@interface V2NIMDatabaseInfo : NSObject
/// 数据库文件路径
@property(nonatomic, copy, readonly) NSString *path;
/// 数据库文件名称
@property(nonatomic, copy, readonly) NSString *name;
/// 数据库文件大小
@property(nonatomic, assign, readonly) NSInteger size;
@end

NS_ASSUME_NONNULL_END

