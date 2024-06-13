//
// Created by cqu227hk on 2022/12/08.
// Copyright (c) 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  统一类型调用参数定义
 */
@interface NIMGenericTypeAPICallParam : NSObject

/**
 * 调用序列号,调用方产生,在执行结果中带回
 */
@property (nonatomic,assign) NSInteger sn;
/**
 * 调用上下文数据,调用方产生,SDK不维护此数据的生命周期,在执行结果中带回
 */
@property (nonatomic,assign) id data;
/**
 * api名称
 */
@property (nonatomic,copy) NSString* name;
/**
 * api参数,json format
 */
@property (nonatomic,copy) NSString* param;

@end

/**
 *  统一类型调用结果参数定义
 */
@interface NIMGenericTypeAPICallResult : NSObject

/**
 * 调用序列号用户生成,与调用参数中的sn字段一致
 */
@property (nonatomic,assign) NSInteger sn;
/**
 * 调用上下文数据,与调用参数中的data字段一致
 */
@property (nonatomic,assign) id data;
/**
 * api名称
 */
@property (nonatomic,copy) NSString* name;
/**
 * api 结果参数,json format
 */
@property (nonatomic,copy) NSString* result;

@end

/**
 *  统一类型调用执行结果回调定义
 *
 *  @param error 错误信息,如果成功,error 为 nil
 *  @param result 调用结果,如果失败,result 可能为 nil
 */
typedef void(^NIMGenericTypeAPICallInvokeCallback)(NSError * __nullable error, NIMGenericTypeAPICallResult * __nullable result);


NS_ASSUME_NONNULL_END


