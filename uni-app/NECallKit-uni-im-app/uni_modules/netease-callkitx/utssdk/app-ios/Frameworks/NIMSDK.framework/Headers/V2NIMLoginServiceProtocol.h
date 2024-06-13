//
//  V2NIMLoginServiceProtocol.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "V2NIMBase.h"

NS_ASSUME_NONNULL_BEGIN

@class V2NIMLoginOption;
@class V2NIMLoginClient;
@class V2NIMKickedOfflineDetail;
@class V2NIMDataSyncDetail;

@protocol V2NIMTokenProvider;
@protocol V2NIMLoginExtensionProvider;
@protocol V2NIMLoginListener;
@protocol V2NIMReconnectDelayProvider;
@protocol V2NIMLoginDetailListener;

/// 登录鉴权类型
typedef NS_ENUM(NSInteger, V2NIMLoginAuthType) {
    V2NIM_LOGIN_AUTH_TYPE_DEFAULT                       = 0,  ///< 默认
    V2NIM_LOGIN_AUTH_TYPE_DYNAMIC_TOKEN                 = 1,  ///< 动态token
    V2NIM_LOGIN_AUTH_TYPE_THIRD_PARTY                   = 2,  ///< 第三方
};

/// 登录客户端类型
typedef NS_ENUM(NSInteger, V2NIMLoginClientType) {
    V2NIM_LOGIN_CLIENT_TYPE_UNKNOWN                     = 0,  ///<未知类型
    V2NIM_LOGIN_CLIENT_TYPE_ANDROID                     = 1,  ///<Android
    V2NIM_LOGIN_CLIENT_TYPE_IOS                         = 2,  ///<iOS
    V2NIM_LOGIN_CLIENT_TYPE_PC                          = 4,  ///<PC
    V2NIM_LOGIN_CLIENT_TYPE_WINPHONE                    = 8,  ///<WINPHONE
    V2NIM_LOGIN_CLIENT_TYPE_WEB                         = 16,  ///<WEB
    V2NIM_LOGIN_CLIENT_TYPE_RESTFUL                     = 32,  ///<REST API
};

/// 登录状态
typedef NS_ENUM(NSInteger, V2NIMLoginStatus) {
    V2NIM_LOGIN_STATUS_LOGOUT                           = 0,  ///< 无登录
    V2NIM_LOGIN_STATUS_LOGINED                          = 1,  ///< 已登录
    V2NIM_LOGIN_STATUS_LOGINING                         = 2,  ///< 登录中
};

/// 被踢下线原因
typedef NS_ENUM(NSInteger, V2NIMKickedOfflineReason) {
    V2NIM_KICKED_OFFLINE_REASON_CLIENT_EXCLUSIVE        = 1,  ///<被另外一个客户端踢下线 (互斥客户端一端登录挤掉上一个登录中的客户端)
    V2NIM_KICKED_OFFLINE_REASON_SERVER                  = 2,  ///<被服务器踢下线
    V2NIM_KICKED_OFFLINE_REASON_CLIENT                  = 3,  ///<被另外一个客户端手动选择踢下线
};

/// 多端登录变动事件
typedef NS_ENUM(NSInteger, V2NIMLoginClientChange) {
    V2NIM_LOGIN_CLIENT_CHANGE_LIST                      = 1,  ///<端列表刷新
    V2NIM_LOGIN_CLIENT_CHANGE_LOGIN                     = 2,  ///<端登录
    V2NIM_LOGIN_CLIENT_CHANGE_LOGOUT                    = 3,  ///<端登出
};

/// 数据同步等级
typedef NS_ENUM(NSInteger, V2NIMDataSyncLevel) {
    V2NIM_DATA_SYNC_TYPE_LEVEL_FULL                     = 0,  ///< 完全同步
    V2NIM_DATA_SYNC_TYPE_LEVEL_BASIC                    = 1,  ///< 同步基础数据
};

/// 连接状态
typedef NS_ENUM(NSInteger, V2NIMConnectStatus) {
    V2NIM_CONNECT_STATUS_DISCONNECTED                   = 0,  ///< 未连接
    V2NIM_CONNECT_STATUS_CONNECTED                      = 1,  ///< 已连接
    V2NIM_CONNECT_STATUS_CONNECTING                     = 2,  ///< 连接中
    V2NIM_CONNECT_STATUS_WAITING                        = 3,  ///< 等待重连
};

/// 数据同步类型
typedef NS_ENUM(NSInteger, V2NIMDataSyncType) {
    V2NIM_DATA_SYNC_TYPE_MAIN                         = 1,  ///< 同步主数据
    V2NIM_DATA_SYNC_TYPE_TEAM_MEMBER                  = 2,  ///< 同步群组成员
    V2NIM_DATA_SYNC_TYPE_SUPER_TEAM_MEMBER            = 3,  ///< 同步超大群组成员
};

/// 数据同步状态
typedef NS_ENUM(NSInteger, V2NIMDataSyncState) {
    V2NIM_DATA_SYNC_STATE_WAITING                     = 1,  ///< 等待同步
    V2NIM_DATA_SYNC_STATE_SYNCING                     = 2,  ///< 同步中
    V2NIM_DATA_SYNC_STATE_COMPLETED                   = 3,  ///< 同步完成
};

/// 成功接收聊天室link地址回调
typedef void (^V2NIMChatroomLinkAddressCallback)(NSArray<NSString *> *links);

/// 登录协议
@protocol V2NIMLoginService <NSObject>

/**
 *  登录
 *
 *  @param accountId
 *  @param token
 *  @param option
 *  @param success
 *  @param failure
 */
- (void)login:(NSString *)accountId
        token:(nullable NSString *)token
       option:(nullable V2NIMLoginOption *)option
      success:(nullable V2NIMSuccessCallback)success
      failure:(nullable V2NIMFailureCallback)failure;

/**
 *  登出
 *
 *  @param success
 *  @param failure
 */
- (void)logout:(nullable V2NIMSuccessCallback)success
       failure:(nullable V2NIMFailureCallback)failure;

/**
 *  获取当前登录用户
 *
 *  @return 返回当前登录用户账号
 *
 *  @note
 */
- (nullable NSString *)getLoginUser;

/**
 *  获取登录状态
 *
 *  @return 返回当前登录状态
 */
- (V2NIMLoginStatus)getLoginStatus;

/**
 *  获取登录客户端列表
 *
 *  @return 返回当前登录客户端列表
 */
- (nullable NSArray<V2NIMLoginClient *> *)getLoginClients;

/**
 *  踢掉登录客户端下线
 *
 *  @param client
 *  @param success
 *  @param failure
 */
- (void)kickOffline:(V2NIMLoginClient *)client
            success:(nullable V2NIMSuccessCallback)success
            failure:(nullable V2NIMFailureCallback)failure;

/**
 *  获取被踢下线原因
 *
 *  @return 返回被踢下线原因
 */
- (nullable V2NIMKickedOfflineDetail *)getKickedOfflineDetail;

/**
 *  添加登录监听
 *
 *  @param listener
 */
- (void)addLoginListener:(id<V2NIMLoginListener>)listener;

/**
 *  移除登录监听
 *
 *  @param listener
 */
- (void)removeLoginListener:(id<V2NIMLoginListener>)listener;

/**
 *  获取连接状态
 *
 *  @return 返回当前连接状态
 */
- (V2NIMConnectStatus)getConnectStatus;

/**
 *  获取数据同步详情
 *
 *  @return 返回数据同步详情
 */
- (nullable NSArray<V2NIMDataSyncDetail *> *)getDataSync;

/**
 *  设置获取重连延时回调
 *
 *  @param provider
 */
- (void)setReconnectDelayProvider:(nullable id<V2NIMReconnectDelayProvider>)provider;

/**
 *  添加登录详情监听
 *
 *  @param listener
 */
- (void)addLoginDetailListener:(id<V2NIMLoginDetailListener>)listener;

/**
 *  移除登录详情监听
 *
 *  @param listener
 */
- (void)removeLoginDetailListener:(id<V2NIMLoginDetailListener>)listener;

/**
 *  获取聊天室link地址
 *
 *  @param roomId
 *  @param success
 *  @param failure
 */
- (void)getChatroomLinkAddress:(NSString *)roomId
                       success:(nullable V2NIMChatroomLinkAddressCallback)success
                       failure:(nullable V2NIMFailureCallback)failure;

@end

/// 登录选项
@interface V2NIMLoginOption : NSObject

/// 重试次数
@property(nonatomic,assign) NSInteger retryCount;

/// 登录超时时间，单位毫秒，>0表示有效的超时，其他表示不超时
@property(nonatomic,assign) NSInteger timeout;

/// 强制登录模式
@property(nonatomic,assign) BOOL forceMode;

/// 认证类型
@property(nonatomic,assign) V2NIMLoginAuthType authType;

/// 提供token
@property(nullable,nonatomic,strong) id<V2NIMTokenProvider> tokenProvider;

/// 提供登录扩展信息
@property(nullable,nonatomic,strong) id<V2NIMLoginExtensionProvider> loginExtensionProvider;

/// 数据同步等级
@property(nonatomic,assign) V2NIMDataSyncLevel syncLevel;

@end

/// 登录客户端信息
@interface V2NIMLoginClient : NSObject

/// 类型
@property(nonatomic,assign,readonly) V2NIMLoginClientType type;

/// 操作系统
@property(nullable,nonatomic,copy,readonly) NSString *os;

/// 登录时间
@property(nonatomic,assign,readonly) NSTimeInterval timestamp;

/// 自定义信息，最大32个字符；目前android多端登录，TV端和手表端，可以通过该字段区分
@property(nullable,nonatomic,copy,readonly) NSString *customTag;

/// 自定义类型
@property(nonatomic,assign,readonly) NSInteger customClientType;

/// 登录客户端唯一标识
@property(nullable,nonatomic,copy,readonly) NSString *clientId;

@end

/// 被踢下线详情
@interface V2NIMKickedOfflineDetail : NSObject

/// 原因
@property(nonatomic,assign,readonly) V2NIMKickedOfflineReason reason;
/// 说明
@property(nullable,nonatomic,copy,readonly) NSString *reasonDesc;
/// 登录客户端类型
@property(nonatomic,assign,readonly) V2NIMLoginClientType clientType;
/// 自定义登录客户端类型
@property(nonatomic,assign,readonly) NSInteger customClientType;

@end

/// 数据同步详情
@interface V2NIMDataSyncDetail : NSObject

/// 类型
@property(nonatomic,assign,readonly) V2NIMDataSyncType type;
/// 状态
@property(nonatomic,assign,readonly) V2NIMDataSyncState state;

@end

/// 获取token回调
@protocol V2NIMTokenProvider <NSObject>

- (nullable NSString *)getToken:(NSString *)accountId;

@end

/// 获取登录扩展回调
@protocol V2NIMLoginExtensionProvider <NSObject>

- (nullable NSString *)getLoginExtension:(NSString *)accountId;

@end

/// 登录回调协议
@protocol V2NIMLoginListener <NSObject>

@optional

- (void)onLoginStatus:(V2NIMLoginStatus)status;

- (void)onLoginFailed:(V2NIMError *)error;

- (void)onKickedOffline:(V2NIMKickedOfflineDetail *)detail;

- (void)onLoginClientChanged:(V2NIMLoginClientChange)change
                     clients:(nullable NSArray<V2NIMLoginClient *> *)clients;

@end

/// 获取重连延时回调
@protocol V2NIMReconnectDelayProvider <NSObject>

- (int)getReconnectDelay:(int)delay;

@end

/// 登录详情回调协议
@protocol V2NIMLoginDetailListener <NSObject>

@optional

- (void)onConnectStatus:(V2NIMConnectStatus)status;

- (void)onDisconnected:(nullable V2NIMError *)error;

- (void)onConnectFailed:(nullable V2NIMError *)error;

- (void)onDataSync:(V2NIMDataSyncType)type
             state:(V2NIMDataSyncState)state
             error:(nullable V2NIMError *)error;

@end

NS_ASSUME_NONNULL_END
