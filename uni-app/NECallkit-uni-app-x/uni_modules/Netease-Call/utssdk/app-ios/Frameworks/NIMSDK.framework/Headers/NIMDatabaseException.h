//
//  NIMDatabaseException.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMDatabaseException;

NS_ASSUME_NONNULL_BEGIN

/**
 *  数据库异常类型
 */
typedef NS_ENUM(NSInteger, NIMDatabaseExceptionType)
{
    /**
     *  损坏的DB
     *  @deprecated 请使用 NIMDatabaseExceptionTypeCorrupt
     */
    NIMDatabaseExceptionTypeBadDb = 1,

    /**
     *  未分类的通用错误
     */
    NIMDatabaseExceptionTypeGeneric = 0,

    /**
     *  数据库损坏
     */
    NIMDatabaseExceptionTypeCorrupt = 1,
    
    /**
     *  磁盘空间已满
     */
    NIMDatabaseExceptionTypeFull = 2,
};

/**
 *  数据库异常处理协议
 */
@protocol NIMDatabaseHandleExceptionProtocol <NSObject>

@optional

/**
 *  数据库异常处理方法
 */
- (void)handleException:(NIMDatabaseException *)exception;

@end

/**
 *  数据库异常信息
 */
@interface NIMDatabaseException : NSObject

/**
 * 异常
 */
@property (nonatomic,assign,readonly) NIMDatabaseExceptionType exception;

/**
 *  数据库异常信息
 */
@property (nullable,nonatomic,copy,readonly) NSString *message;

/**
 *  数据库文件沙盒路径
 */
@property (nullable,nonatomic,copy,readonly) NSString *databasePath;

/**
 *  注册数据库异常处理对象
 *  @param handler 用户自定义处理对象
 */
+ (void)registerExceptionHandler:(id<NIMDatabaseHandleExceptionProtocol>)handler;

@end

NS_ASSUME_NONNULL_END
