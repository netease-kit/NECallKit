//
//  V2NIMError.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#if defined(__cplusplus)
#define V2_NIM_ERROR_EXTERN extern "C"
#else
#define V2_NIM_ERROR_EXTERN extern
#endif

NS_ASSUME_NONNULL_BEGIN

/// 错误来源
typedef NS_ENUM(NSInteger, V2NIMErrorSource) {
    V2NIM_ERROR_SOURCE_UNKNOWN                          = 0,  ///< 未知来源
    V2NIM_ERROR_SOURCE_PROTOCOL                         = 1,  ///< 协议错误来源
    V2NIM_ERROR_SOURCE_LOCAL                            = 2,  ///< 本地错误来源
};

typedef NSString *V2NIMErrorDetailKey;

/// 错误信息
@interface V2NIMError : NSObject <NSCopying>

/// 错误来源
@property(nonatomic,assign,readonly) V2NIMErrorSource source;
/// 错误码
@property(nonatomic,assign,readonly) int code;
/// 错误描述
@property(nonatomic,strong,readonly) NSString *desc;
/// 错误详情
@property(nonatomic,strong,readonly) NSDictionary<V2NIMErrorDetailKey, id> *detail;

/**
 *  将NSError转换为V2NIMError
 *
 *  @param nserror
 *  @return 返回V2NIMError
 *  @discussion V2NIMError向前兼容，在V2之前的API中返回的NSError，可通过此获取到V2NIMError
 */
+ (nullable instancetype)errorWithNSError:(NSError *)nserror;

/// 将V2NIMError转换为NSError
@property(nonatomic,strong,readonly) NSError *nserror;

@end

/// 错误详情 账号
V2_NIM_ERROR_EXTERN V2NIMErrorDetailKey const V2NIM_ERROR_DETAIL_ACCOUNT;
/// 错误详情 群id
V2_NIM_ERROR_EXTERN V2NIMErrorDetailKey const V2NIM_ERROR_DETAIL_TEAM_ID;

typedef NS_ENUM(NSInteger, V2NIMErrorCode) {
    V2NIM_ERROR_CODE_UNKNOWN                              = 0,  ///< 未知错误
    V2NIM_ERROR_CODE_SUCCESS                              = 200,  ///< 请求成功
    
    V2NIM_ERROR_CODE_HANDSHAKE                            = 201,  ///< 握手错误
    V2NIM_ERROR_CODE_REQUEST_SERVER_TEMPERARY_FORBIDDEN   = 398,  ///< 请求被服务器暂时禁止
    V2NIM_ERROR_CODE_REQUEST_SERVER_UNIT_ERROR            = 399,  ///< 请求服务器单元错误
    V2NIM_ERROR_CODE_FORBIDDEN                            = 403,  ///< 客户端没有权限访问请求的资源
    V2NIM_ERROR_CODE_NOT_FOUND                            = 404,  ///< 资源不存在
    V2NIM_ERROR_CODE_PARAMETER_ERROR                      = 414,  ///< 参数错误
    V2NIM_ERROR_CODE_FREQUNENCY_LIMIT                     = 416,  ///< 频率超限
    V2NIM_ERROR_CODE_MULTI_LOGIN_FORBIDDEN                = 417,  ///< 多端登录被禁止
    V2NIM_ERROR_CODE_SERVER_INTERNAL_ERROR                = 500,  ///< 服务器内部错误
    V2NIM_ERROR_CODE_SERVER_BUSY                          = 503,  ///< 服务器繁忙
    V2NIM_ERROR_CODE_APP_UNREACHABLE                      = 511,  ///< app 服务不可达
    V2NIM_ERROR_CODE_SERVICE_UNAVAILABLE                  = 514,  ///< 服务不可用
    V2NIM_ERROR_CODE_PROTOCOL_BLACKHOLE_FILTERED          = 599,  ///< 协议被黑洞规则过滤
    V2NIM_ERROR_CODE_NO_PERMISSION                        = 997,  ///< appid 没有权限调用该协议
    V2NIM_ERROR_CODE_UNPACK_ERROR                         = 998,  ///< 解包错误
    V2NIM_ERROR_CODE_PACK_ERROR                           = 999,  ///< 打包错误

    V2NIM_ERROR_CODE_APPKEY_BLOCKED                       = 101403,  ///< appkey 被禁用
    V2NIM_ERROR_CODE_APPKEY_NOT_EXIST                     = 101404,  ///< appkey 不存在
    V2NIM_ERROR_CODE_BUNDLEID_CHECK_FAILED                = 101414,  ///< bundleid 校验失败
    
    V2NIM_ERROR_CODE_INVALID_TOKEN                        = 102302,  ///< 无效 token
    V2NIM_ERROR_CODE_ROBOT_NOT_ALLOWED                    = 102403,  ///< 机器人账号不得登录
    V2NIM_ERROR_CODE_ACCOUNT_NOT_EXIST                    = 102404,  ///< 用户不存在
    V2NIM_ERROR_CODE_SENDER_HAS_BEEN_MUTED                = 102421,  ///<发送方被禁言
    V2NIM_ERROR_CODE_ACCOUNT_BLOCKED                      = 102422,  ///< 账号被禁用
    V2NIM_ERROR_CODE_SENDER_HAS_BEEN_BLACKLISTED          = 102426,  ///< 消息发送方被设为黑名单
    V2NIM_ERROR_CODE_RECIPIENT_NOT_FRIEDN                 = 104404,  ///<接收方非好友
    V2NIM_ERROR_CODE_RECIPIENT_ACCEPETED_REQUEST          = 104405,  ///<接收方已添加好友
    V2NIM_ERROR_CODE_CANNOT_REVOKE_QIYU                   = 107301,  ///< 不能撤回七鱼的消息
    V2NIM_ERROR_CODE_NOT_SENDER_OR_ADMINISTRATOR          = 107315,  ///< 不是消息发送者或者群管理员
    V2NIM_ERROR_CODE_LIST_EXCEEDS_LIMIT                   = 107316,  ///< 强推列表超过上限
    V2NIM_ERROR_CODE_ACK_EXCEEDS_FREQUENCY_LIMIT          = 107317,  ///< ack消息超频
    V2NIM_ERROR_CODE_SNAPSHOT_NOT_FOUND                   = 107318,  ///< 快照未发现
    V2NIM_ERROR_CODE_EXCEEDS_UPPER_LIMIT                  = 107319,  ///< 数量超过上限
    V2NIM_ERROR_CODE_QUANTITY_EXCEEDS_LIMIT               = 107321,  ///< 数量超过上限
    V2NIM_ERROR_CODE_MESSAGE_NOT_EXIST                    = 107404,  ///< 消息不存在
    V2NIM_ERROR_CODE_APP_HAS_BEEN_MUTED                   = 107410,  ///< 应用被禁
    V2NIM_ERROR_CODE_CANNOT_REVOKE_YOURSELF               = 107429,  ///< 不能撤回自己给自己发的消息
    V2NIM_ERROR_CODE_SEVER_ANTISPAM                       = 107451,  ///< 服务器反垃圾
    V2NIM_ERROR_CODE_CLIENT_ANTISPAM                      = 107452,  ///< 客户端反垃圾
    V2NIM_ERROR_CODE_MUTE_ALL_REGULAR_MEMBERS             = 108306,  ///< 禁言所有群普通成员
    V2NIM_ERROR_CODE_GROUP_NOT_EXIST                      = 108404,  ///< 群不存在
    V2NIM_ERROR_CODE_GROUP_MUTE_MODE                      = 108423,  ///< 群整体禁言
    V2NIM_ERROR_CODE_ALREADY_IN_TEAM                      = 109311,  ///< 已经在群里
    V2NIM_ERROR_CODE_NOT_IN_GROUP                         = 109404,  ///< 不在群里
    V2NIM_ERROR_CODE_GROUP_MEMBER_MUTED                   = 109423,  ///< 群成员被禁言
    V2NIM_ERROR_CODE_EXCEEDS_MAXIMUM_LIMIT                = 189301,  ///< 超过个数上限
    V2NIM_ERROR_CODE_CONCURRENT_OPERATION_TRY_AGANI       = 189449,  ///< 并发操作请重试

    V2NIM_ERROR_CODE_INTERNAL                             = 190001,  ///< 内部错误
    V2NIM_ERROR_CODE_ILLEGAL_STATE                        = 190002,  ///< 非法状态
    V2NIM_ERROR_CODE_MISUSE                               = 191001,  ///< 使用姿势错误
    V2NIM_ERROR_CODE_CANCELLED                            = 191002,  ///< 操作取消
    V2NIM_ERROR_CODE_CALLBACK                             = 191003,  ///< 回调错误
    V2NIM_ERROR_CODE_INVALID_PARAMETER                    = 191004,  ///< 参数错误
    V2NIM_ERROR_CODE_TIMEOUT                              = 191005,  ///< 超时
    V2NIM_ERROR_CODE_REQUEST_RESOURCE_NOT_EXIST           = 191006,  ///< 请求资源不存在
    V2NIM_ERROR_CODE_REQUEST_RESOURCE_EXIST               = 191007,  ///< 请求资源已存在

    V2NIM_ERROR_CODE_CONNECT_FAILED                       = 192001,  ///< 连接错误
    V2NIM_ERROR_CODE_CONNECT_TIMEOUT                      = 192002,  ///< 连接超时
    V2NIM_ERROR_CODE_DISCONNECT                           = 192003,  ///< 连接断开
    V2NIM_ERROR_CODE_PROTOCOL_TIMEOUT                     = 192004,  ///< 协议超时
    V2NIM_ERROR_CODE_PROTOCOL_SEND_FAILED                 = 192005,  ///< 协议发送失败
    V2NIM_ERROR_CODE_REQUEST_FAILED                       = 192006,  ///< 请求失败
    
    V2NIM_ERROR_CODE_DATABASE_OPEN_FAILED                 = 193001,  ///<数据库打开失败
    V2NIM_ERROR_CODE_DATABASE_UPGRADE_FAILED              = 193002,  ///<数据库升级失败
    V2NIM_ERROR_CODE_DATABASE_WRITE_FAILED                = 193003,  ///<数据库写入失败
    V2NIM_ERROR_CODE_DATABASE_READ_FAILED                 = 193004,  ///<数据库读取失败

    V2NIM_ERROR_CODE_FILE_NOT_FOUND                       = 194001,  ///<文件不存在
    V2NIM_ERROR_CODE_FILE_CREATE_FAILED                   = 194002,  ///<文件创建失败
    V2NIM_ERROR_CODE_FILE_OPEN_FAILED                     = 194003,  ///<文件打开失败
    V2NIM_ERROR_CODE_FILE_WRITE_FAILED                    = 194004,  ///<文件写入失败
    V2NIM_ERROR_CODE_FILE_READ_FAILED                     = 194005,  ///<文件读取失败    
    V2NIM_ERROR_CODE_LOCAL_ANTISPAM                       = 195001   ///<命中本地反垃圾
};

NS_ASSUME_NONNULL_END
