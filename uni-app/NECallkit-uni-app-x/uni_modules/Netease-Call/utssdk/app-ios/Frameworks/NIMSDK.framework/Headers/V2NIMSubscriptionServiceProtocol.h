//
//  V2NIMSubscriptionServiceProtocol.h
//  NIMLib
//
//  Created by Netease on 2024/7/11.
//  Copyright © 2024 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "V2NIMBase.h"
#import "V2NIMLoginServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@class V2NIMSubscribeUserStatusOption;
@class V2NIMUnsubscribeUserStatusOption;
@class V2NIMCustomUserStatusParams;
@class V2NIMUserStatus;
@class V2NIMCustomUserStatusPublishResult;
@class V2NIMUserStatusSubscribeResult;
@protocol V2NIMSubscribeListener;


/// 用户在线状态
typedef NS_ENUM(NSInteger, V2NIMUserStatusType) {
    V2NIM_USER_STATUS_TYPE_UNKNOWN,    // 未知
    V2NIM_USER_STATUS_TYPE_LOGIN,      // 登录
    V2NIM_USER_STATUS_TYPE_LOGOUT,     // 登出
    V2NIM_USER_STATUS_TYPE_DISCONNECT  // 断开连接
};

/// 成功订阅用户状态回调
typedef void (^V2NIMSubscribeUserStatusCallback)(NSArray<NSString *>*failedList);

/// 成功取消订阅用户状态回调
typedef void (^V2NIMUnsubscribeUserStatusCallback)(NSArray<NSString *>*failedList);

/// 成功查询订阅用户状态回调
typedef void (^V2NIMSubscribeQueryCallback)(NSArray<V2NIMUserStatusSubscribeResult *>*resultList);

/// 用户自定义状态发布回调
typedef void (^V2NIMCustomUserStatusPublishCallback)(V2NIMCustomUserStatusPublishResult *resultList);

@protocol V2NIMSubscriptionService <NSObject>

/**
 * 订阅用户状态，包括在线状态，或自定义状态
 * 单次订阅人数最多100，如果有较多人数需要调用，需多次调用该接口
 * 如果同一账号多端重复订阅， 订阅有效期会默认后一次覆盖前一次时长
 * 总订阅人数最多3000， 被订阅人数3000，为了性能考虑
 * 在线状态事件订阅是单向的，双方需要各自订阅
 * 如果接口整体失败，则返回调用错误码
 * 如果部分账号失败，则返回失败账号列表
 * 订阅接口后，有成员在线状态变更会触发回调：onUserStatusChanged
 * 
 *  @param option 订阅请求参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)subscribeUserStatus:(V2NIMSubscribeUserStatusOption *_Nonnull)option
                    success:(nullable V2NIMSubscribeUserStatusCallback)success
                    failure:(nullable V2NIMFailureCallback)failure;

/**
 *  取消用户状态订阅请求
 *
 *  @param option 订阅请求参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)unsubscribeUserStatus:(V2NIMUnsubscribeUserStatusOption *_Nonnull)option
                      success:(nullable V2NIMUnsubscribeUserStatusCallback)success
                      failure:(nullable V2NIMFailureCallback)failure;


/**
 *  发布用户自定义状态，如果默认在线状态不满足业务需求，可以发布自定义用户状态
 *
 *  @param params 发布自定义状态事件
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)publishCustomUserStatus:(V2NIMCustomUserStatusParams *_Nonnull)params
                        success:(nullable V2NIMCustomUserStatusPublishCallback)success
                        failure:(nullable V2NIMFailureCallback)failure;

/**
 *  查询用户状态订阅关系
 *  输入账号列表，查询自己订阅了哪些账号列表， 返回订阅账号列表
 *
 *  @param accountIds 需要查询的账号列表，查询自己是否订阅了对应账号
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)queryUserStatusSubscriptions:(NSArray<NSString *>*_Nullable)accountIds
                             success:(nullable V2NIMSubscribeQueryCallback)success
                             failure:(nullable V2NIMFailureCallback)failure;


/**
* 添加用户状态订阅的监听器
*
* @param listener 消息监听回调
*/
- (void)addSubscribeListener:(id<V2NIMSubscribeListener>)listener;

/**
* 删除用户状态订阅的监听器
*
* @param listener 消息监听回调
*/
- (void)removeSubscribeListener:(id<V2NIMSubscribeListener>)listener;

@end


/**
 *  用户状态订阅监听
 */

@protocol V2NIMSubscribeListener <NSObject>

/**
 *  其它用户状态变更，包括在线状态，和自定义状态
 *  同账号发布时，指定了多端同步的状态
 *  在线状态默认值为：
 *  登录：1
 *  登出：2
 *  断开连接： 3
 *  在线状态事件会受推送的影响：如果应用被清理，但厂商推送（APNS、小米、华为、OPPO、VIVO、魅族、FCM）可达，则默认不会触发该用户断开连接的事件,若开发者需要该种情况下视为离线，请前往网易云信控制台>选择应用>IM 即时通讯>功能配置>全局功能>在线状态订阅
 *  @param data  用户状态列表
 */
- (void)onUserStatusChanged:(NSArray<V2NIMUserStatus *> *)data;

@end

/**
 *  订阅用户状态请求参数
 */
@interface V2NIMSubscribeUserStatusOption : NSObject

/// 订阅的成员列表， 为空返回参数错误，单次数量不超过100， 列表数量如果超限，默认截取前100个账号
@property(nonatomic,strong,nonnull) NSArray<NSString *> *accountIds;

/**
 *  订阅的有效期，时间范围为 60~2592000，单位：秒
 *
 *  过期后需要重新订阅。如果未过期的情况下重复订阅，新设置的有效期会覆盖之前的有效期
 */
@property(nonatomic,assign) NSInteger duration;

/**
 *  订阅后是否立即同步事件状态值， 默认为false
 *  为true：表示立即同步当前状态值
 *  但为了性能考虑， 30S内重复订阅，会忽略该参数
 */
@property(nonatomic,assign) BOOL immediateSync;

@end


/**
 * 取消订阅用户状态请求参数
 */
@interface V2NIMUnsubscribeUserStatusOption : NSObject

/**
 *  取消订阅的成员列表，为空，则表示取消所有订阅的成员， 否则取消指定的成员
 *  单次数量不超过100
 */
@property(nonatomic,strong,nullable) NSArray<NSString *> *accountIds;

@end

/**
 * 自定义用户状态
 */
@interface V2NIMCustomUserStatusParams : NSObject

/**
 *  自定义设置值： 10000以上,包括一万,一万以内为预定义值
 *  小于1万，返回参数错误
 */
@property(nonatomic,assign) int statusType;

/// 状态的有效期，单位秒，范围为 60s 到 7days
@property(nonatomic,assign) NSInteger duration;

/// 用户发布状态时设置的扩展字段
@property(nonatomic,assign,nullable) NSString *extension;

/// 用户发布状态时是否只广播给在线的订阅者
@property(nonatomic,assign) BOOL onlineOnly;

/// 用户发布状态时是否需要多端同步
@property(nonatomic,assign) BOOL multiSync;

@end

/**
 * 用户状态
 */
@interface V2NIMUserStatus : NSObject

/// 用户账号
@property(nonatomic,copy,nonnull,readonly) NSString *accountId;

/**
 *  在线状态参见：枚举名：V2NIMUserStatusType
 *
 *  自定义设置值： 10000以上,包括一万,一万以内为预定义值
 */
@property(nonatomic,assign,readonly) V2NIMUserStatusType statusType;

///  用户发布状态对应的终端
@property(nonatomic,assign,readonly) V2NIMLoginClientType clientType;

/// 用户发布状态的发布时间，服务器时间
@property(nonatomic,assign,readonly) NSTimeInterval publishTime;

/// 每次发布时，会生成一个唯一id， 发布自定义事件时会生成该参数，如果id相同，表示同一个事件
@property(nonatomic,copy,nullable,readonly) NSString * uniqueId;

/// 用户发布状态时设置的扩展字段
@property(nonatomic,copy,nullable,readonly) NSString *extension;

/**
 * 获取预留状态中的配置信息，由服务端填入
 * JsonArray格式
 */
@property(nonatomic,copy,nullable,readonly) NSString *serverExtension;

@end

/**
 * 用户状态订阅结果
 */
@interface V2NIMUserStatusSubscribeResult : NSObject

/// 用户账号
@property(nonatomic,copy,nonnull,readonly) NSString *accountId;

/// 状态的有效期，单位秒，范围为 60s 到 30days
@property(nonatomic,assign,readonly) NSInteger duration;

/// 我的订阅事件
@property(nonatomic,assign,readonly) NSTimeInterval subscribeTime;

@end

/**
 * 自定义用户状态发布回包
 */
@interface V2NIMCustomUserStatusPublishResult : NSObject

/// 发布自定义用户状态时， 内部生成的唯一ID
@property(nonatomic,copy,nonnull,readonly) NSString *uniqueId;

/// 服务器针对该状态事件生成的ID
@property(nonatomic,copy,nonnull,readonly) NSString *serverId;

/// 用户状态发布时的时间
@property(nonatomic,assign,readonly) NSTimeInterval publishTime;

@end

NS_ASSUME_NONNULL_END
