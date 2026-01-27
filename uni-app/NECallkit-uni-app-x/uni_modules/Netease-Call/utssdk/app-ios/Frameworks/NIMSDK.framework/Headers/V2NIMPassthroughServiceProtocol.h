//
//  V2NIMPassthroughServiceProtocol.h
//  NIMSDK
//
//  Created by 陈吉力 on 2024/10/27.
//  Copyright © 2024 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "V2NIMBase.h"

NS_ASSUME_NONNULL_BEGIN

@class V2NIMProxyRequest;
@class V2NIMProxyResponse;
@class V2NIMProxyNotify;

@protocol V2NIMPassthroughListener;

#pragma mark - V2NIMPassthrough enums
typedef NS_ENUM(NSInteger, V2NIMProxyRequestMethod) {
    V2NIM_PROXY_REQUEST_METHOD_GET = 1, ///< GET
    V2NIM_PROXY_REQUEST_METHOD_POST = 2, ///< POST
    V2NIM_PROXY_REQUEST_METHOD_PUT = 3, ///< PUT
    V2NIM_PROXY_REQUEST_METHOD_DELETE = 4, ///< DELETE
};

#pragma mark - V2NIMPassthrough callbacks
typedef void (^V2NIMHttpProxySuccess)(V2NIMProxyResponse *response);

#pragma mark - V2NIMPassthrough service
/// 透传协议
@protocol V2NIMPassthroughService <NSObject>

/**
 * http服务代理
 * @param request 代理的http请求
 * @param success 请求的成功回调
 * @param failure 请求失败的回调
 */
- (void)httpProxy:(V2NIMProxyRequest *)request
          success:(V2NIMHttpProxySuccess)success
          failure:(V2NIMFailureCallback)failure;

/**
 * 添加透传监听器
 * @param listener 透传监听器
 */
- (void)addPassthroughListener:(id<V2NIMPassthroughListener>)listener;

/**
 * 移除透传监听器
 * @param listener 透传监听器
 */
- (void)removePassthroughListener:(id<V2NIMPassthroughListener>)listener;

@end

#pragma mark - V2NIMPassthrough listener
/// 透传回调协议
@protocol V2NIMPassthroughListener <NSObject>
@optional
/**
 * 透传下行通知
 * @param notify 下行通知数据
 */
- (void)onProxyNotify:(V2NIMProxyNotify *)notify;
@end

#pragma mark - V2NIMPassthrough models
@interface V2NIMProxyRequest : NSObject

/**
 * upstream host, 不传使用默认配置
 * url中除了host的path
 * path不能为空为空返回参数错误
 */
@property (nullable, nonatomic, copy) NSString *zone;

/**
 * path不能为空为空返回参数错误
 * GET请求,如果body非空，则返回参数错误
 */
@property (nonatomic, copy) NSString *path;

/**
 * GET请求，如果body非空， 则返回参数错误
 * POST/PUT请求，如果body为空，则返回参数错误
 */
@property (nonatomic, assign) V2NIMProxyRequestMethod method;

/**
 * 请求头，要求json格式
 * 非json格式返回参数错误
 */
@property (nullable, nonatomic, copy) NSString *header;

/**
 * 请求体
 */
@property (nullable, nonatomic, copy) NSString *body;

@end

@interface V2NIMProxyResponse: NSObject

/**
 * 响应头，必须要求json格式
 */
@property (nullable, nonatomic, copy, readonly) NSString *header;

/**
 * 响应体
 */
@property (nullable, nonatomic, copy, readonly) NSString *body;

@end

@interface V2NIMProxyNotify: NSObject

/**
 * 发送方账号
 */
@property (nullable, nonatomic, copy, readonly) NSString *fromAccountId;

/**
 * 通知体
 */
@property (nullable, nonatomic, copy, readonly) NSString *body;

/**
 * 发送时间
 */
@property (nonatomic, assign, readonly) NSTimeInterval time;

@end


NS_ASSUME_NONNULL_END
