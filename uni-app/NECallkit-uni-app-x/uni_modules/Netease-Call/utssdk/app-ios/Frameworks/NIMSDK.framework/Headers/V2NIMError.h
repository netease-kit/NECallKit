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
    V2NIM_ERROR_CODE_ASYMMETRIC_ENCRYPTION_ALGORITHM      = 202,  ///< 非对称加密算法错误
    V2NIM_ERROR_CODE_SYMMETRIC_ENCRYPTION_ALGORITHM       = 203,  ///< 对称加密算法错误
    V2NIM_ERROR_CODE_HANDSHAKE_PROTOCOL_VERSION_NEED_FALLBACK = 204, ///<  握手协议版本需降级
    ///<
    V2NIM_ERROR_CODE_REQUEST_SERVER_TEMPERARY_FORBIDDEN   = 398,  ///< 请求被服务器暂时禁止
    V2NIM_ERROR_CODE_REQUEST_SERVER_UNIT_ERROR            = 399,  ///< 服务器单元错误
    V2NIM_ERROR_CODE_FORBIDDEN                            = 403,  ///< 没有权限
    V2NIM_ERROR_CODE_NOT_FOUND                            = 404,  ///< 资源不存在
    V2NIM_ERROR_CODE_PARAMETER_ERROR                      = 414,  ///< 参数错误
    V2NIM_ERROR_CODE_FREQUNENCY_LIMIT                     = 416,  ///< 频率超限
    V2NIM_ERROR_CODE_MULTI_LOGIN_FORBIDDEN                = 417,  ///< 多端登录被禁止
    V2NIM_ERROR_CODE_NEED_RETRY                           = 449,  ///< 请求需要重试
    V2NIM_ERROR_CODE_CALLBACK_FORBIDDEN                   = 463,  ///< 第三方回调被拒绝
    V2NIM_ERROR_CODE_SERVER_INTERNAL_ERROR                = 500,  ///< 服务器内部错误
    V2NIM_ERROR_CODE_SERVER_BUSY                          = 503,  ///< 服务器繁忙
    V2NIM_ERROR_CODE_APP_UNREACHABLE                      = 511,  ///< app 服务不可达
    V2NIM_ERROR_CODE_SERVICE_UNAVAILABLE                  = 514,  ///< 服务不可用
    V2NIM_ERROR_CODE_PROTOCOL_BLACKHOLE_FILTERED          = 599,  ///< 协议被黑洞规则过滤
    V2NIM_ERROR_CODE_NO_PERMISSION                        = 997,  ///< appid 没有权限调用该协议
    V2NIM_ERROR_CODE_UNPACK_ERROR                         = 998,  ///< 解包错误
    V2NIM_ERROR_CODE_PACK_ERROR                           = 999,  ///< 打包错误

    V2NIM_ERROR_CODE_IM_DISABLED                          = 101301,  ///< IM 未开通
    V2NIM_ERROR_CODE_SERVICE_ADDRESS_INVALID              = 101302,  ///< 服务地址非法
    V2NIM_ERROR_CODE_APPKEY_NOT_EXIST                     = 101303,  ///< appkey 不存在
    V2NIM_ERROR_CODE_BUNDLEID_CHECK_FAILED                = 101304,  ///< bundleid 校验失败
    V2NIM_ERROR_CODE_ILLEGAL_AUTH_TYPE                    = 101305,  ///< 非法的鉴权方式
    
    V2NIM_ERROR_CODE_APPKEY_BLOCKED                       = 101403,  ///< appkey 被禁用
    
    V2NIM_ERROR_CODE_LOGIN_RECORD_NOT_FOUND               = 102301,  ///< 找不到设备登陆记录
    V2NIM_ERROR_CODE_INVALID_TOKEN                        = 102302,  ///< 无效 token
    V2NIM_ERROR_CODE_ROBOT_NOT_ALLOWED                    = 102303,  ///< 机器人账号不得登录
    V2NIM_ERROR_CODE_IS_NOT_AI_ACCOUNT                    = 102304,  ///< 不是数字人账号
    V2NIM_ERROR_CODE_ACCOUNT_NOT_EXIST                    = 102404,  ///< 用户不存在
    V2NIM_ERROR_CODE_ACCOUNT_ALREADY_EXIST                = 102405,  ///< 用户已存在
    V2NIM_ERROR_CODE_ACCOUNT_CHAT_BANNED                  = 102421,  ///< 用户被禁言
    V2NIM_ERROR_CODE_ACCOUNT_BLOCKED                      = 102422,  ///< 账号被禁用
    V2NIM_ERROR_CODE_ACCOUNT_IN_BLOCK_LIST                = 102426,  ///< 用户被拉黑
    V2NIM_ERROR_CODE_ACCOUNT_COUNT_LIMIT                  = 102434,  ///< 超过最大账号数
    V2NIM_ERROR_CODE_ACCOUNT_OPERATION_NEED_RETRY         = 102449,  ///< 账号请求需要重试
    
    V2NIM_ERROR_CODE_USER_PROFILE_NOT_EXIST               = 103404,  ///< 用户资料不存在 
    V2NIM_ERROR_CODE_USER_PROFILE_HIT_ANTISPAM            = 103451,  ///< 用户资料反垃圾
    
    V2NIM_ERROR_CODE_PEER_FRIEND_LIMIT                    = 104301,  ///< 对方好友超限
    V2NIM_ERROR_CODE_FRIEND_APPLICATION_NOT_EXIST         = 104302,  ///< 好友申请不存在
    V2NIM_ERROR_CODE_FRIEND_NOT_EXIST                     = 104404,  ///< 好友不存在
    V2NIM_ERROR_CODE_RECIPIENT_ACCEPETED_REQUEST          = 104405,  ///< 好友已存在
    V2NIM_ERROR_CODE_SELF_FRIEND_OPERATION_NOT_ALLOWED    = 104429,  ///< 不允许对自己进行好友操作
    V2NIM_ERROR_CODE_FRIEND_LIMIT                         = 104435,  ///< 好友超限 
    V2NIM_ERROR_CODE_FRIEND_OPERATION_RATE_LIMIT          = 104449,  ///< 好友操作频率超限
    V2NIM_ERROR_CODE_FRIEND_HIT_ANTISPAM                  = 104451,  ///< 好友反垃圾
    
    V2NIM_ERROR_CODE_MUTE_LIST_LIMIT                      = 105435,  ///< 静音列表超限
    V2NIM_ERROR_CODE_SELF_MUTE_OPERATION_NOT_ALLOWED      = 105429,  ///< 不允许对自己进行静音操作
    
    // 黑名单
    V2NIM_ERROR_CODE_AI_ACCOUNT_BLOCKLIST_OPERATION_NOT_ALLOWED = 106403, ///< 不允许对数字人进行黑名单操作
    V2NIM_ERROR_CODE_BLOCKLIST_LIMIT                      = 106435,  ///< 黑名单超限
    V2NIM_ERROR_CODE_SELF_BLOCKLIST_OPERATION_NOT_ALLOWED = 106429,  ///< 不允许对自己进行黑名单操作
        
    
    V2NIM_ERROR_CODE_REVOKE_THIRD_PARTY_MESSAGE_NOT_ALLOWED                   = 107301,  ///< 不允许撤回第三方业务消息
    V2NIM_ERROR_CODE_TEAM_MARK_READ_FAILED                = 107302,  ///< 由于群成员过多导致标记已读失败，消息发送失败
    V2NIM_ERROR_CODE_SENDER_OR_MANAGER_PERMISSION_ONLY_REVOKE = 107303,  ///< 仅允许发送者或管理员撤回消息
    V2NIM_ERROR_CODE_HIGH_PRIORITY_MESSAGE_RATE_LIMIT     = 107304, ///< 高优消息超过频控限制
    V2NIM_ERROR_CODE_ACK_MESSAGE_BE_HIGH_PRIORITY         = 107305, ///< ack消息必须是高优消息
    V2NIM_ERROR_CODE_DUPLICATE_CLIENT_MESSAGE_ID          = 107306, ///< 消息ID重复
    V2NIM_ERROR_CODE_SHORT_TO_LONG_URL_FAILED             = 107307, ///< 短链转长链失败
    V2NIM_ERROR_CODE_URL_INVALID                          = 107308, ///< 无效 URL
    V2NIM_ERROR_CODE_DURATION_OUT_OF_RANGE                = 107309, ///< duration 超出范围
    V2NIM_ERROR_CODE_GET_FILE_META_INFO_FAILED            = 107310, ///< 获取文件 meta 信息失败
    V2NIM_ERROR_CODE_AUDIO_FILE_SIZE_LIMIT                = 107311, ///< 音频文件大小超限
    V2NIM_ERROR_CODE_VOICE_TO_TEXT_TIMEOUT                = 107312, ///< 语音转文字超时
    V2NIM_ERROR_CODE_VOICE_TO_TEXT_FAILED                 = 107313, ///< 语音转文字失败
    V2NIM_ERROR_CODE_REVOKE_EXCEED_TIME_LIMIT             = 107314, ///< 撤回消息超过时间限制
    V2NIM_ERROR_CODE_REVOKE_MESSAGE_NOT_ALLOWED           = 107315, ///< 不允许撤回指定消息
    V2NIM_ERROR_CODE_FORCE_PUSH_LIST_LIMIT                = 107316, ///< 强推列表超过上限
    V2NIM_ERROR_CODE_TEAM_MESSAGE_RECEIPT_RATE_LIMIT      = 107317, ///< 群消息已读操作超频
    V2NIM_ERROR_CODE_SNAPSHOT_NOT_EXIST                   = 107318, ///< 快照不存在
    V2NIM_ERROR_CODE_PIN_LIMIT                            = 107319, ///< PIN 数量超限
    V2NIM_ERROR_CODE_PIN_NOT_EXIST                        = 107320, ///< PIN 不存在
    V2NIM_ERROR_CODE_QUICK_COMMENT_LIMIT                  = 107321, ///< 快捷评论数量超限
    V2NIM_ERROR_CODE_PIN_ALREADY_EXIST                    = 107322, ///< PIN 已存在
    V2NIM_ERROR_CODE_RATE_LIMIT_FOR_MESSAGING_REACHED     = 107323, ///< 消息被流控
    V2NIM_ERROR_CODE_TEAM_READ_RECEIPT_FUNCTION_DISABLED  = 107324, ///< 该app未开启群消息已读功能
    V2NIM_ERROR_CODE_P2P_READ_RECEIPT_FUNCTION_DISABLED   = 107325, ///< 该app未开启单聊消息已读功能
    V2NIM_ERROR_CODE_QUICK_COMMENT_FUNCTION_DISABLED      = 107326, ///< 该app未开启快捷评论功能
    V2NIM_ERROR_CODE_PIN_FUNCTION_DISABLED                = 107327, ///< 该app未开启消息PIN功能
    V2NIM_ERROR_CODE_DELETE_SELF_MESSAGE_NOT_ALLOWED      = 107328, ///< 不允许删除发给自己的消息
    V2NIM_ERROR_CODE_NOT_CHATBOT_ACCOUNT                  = 107329, ///< 不是机器人账号
    V2NIM_ERROR_CODE_MESSAGE_SENSE_REQUIRED               = 107330, ///< 不允许发送方和接收方均无感知
    V2NIM_ERROR_CODE_TEAM_MESSAGE_READ_RECEIPT_DISABLED   = 107331, ///< 群消息已读功能未开启
    V2NIM_ERROR_CODE_TEAM_READ_RECEIPT_RECORD_NOT_FOUND   = 107332, ///< 群消息已读记录未找到
    V2NIM_ERROR_CODE_VOICE_TO_TEXT_FUNCTION_DISABLED      = 107333, ///< 语音转文字功能未开通
    V2NIM_ERROR_CODE_SERVER_SEARCH_FUNCTION_DISABLED      = 107334, ///< 云端搜索功能未开通
    V2NIM_ERROR_CODE_ONEWAY_DELETE_FUNCTION_DISABLED      = 107335, ///< 单向删除功能未开通
    V2NIM_ERROR_CODE_AI_MESSAGES_FUNCTION_DISABLED        = 107337, ///< AI消息功能未开通
    V2NIM_ERRPR_CODE_ONEWAY_DELETION_NOT_ALLOW_FOR_TARGETE_MESSAGES      = 107338, ///< 定向消息不允许单向删除
    V2NIM_ERRPR_CODE_TARGET_MESSAGE_INCLUDED_SELF         = 107339, ///< 定向列表包含消息发送者
    V2NIM_ERROR_CODE_CANNOT_SEND_TARGET_MESSAGE_TO_AI_ASSISTANT = 107340, ///< 数字人消息不能是定向消息
    V2NIM_ERROR_CODE_CANNOT_PIN_TARGETD_MESSAGE           = 107345, ///< 不支持PIN定向消息
    V2NIM_ERROR_CODE_CANNOT_REPLY_TARGETD_MESSAGE         = 107346, ///< 定向消息不支持回复
    V2NIM_ERROR_CODE_CANNOT_QUICK_COMMAND_TARGETD_MESSAGE = 107347, ///< 定向消息不支持快捷评论
    
    V2NIM_ERROR_CODE_MESSAGE_NOT_EXIST                    = 107404,  ///< 消息不存在
    V2NIM_ERROR_CODE_MESSAGING_FUNCTION_DISABLED          = 107410,  ///< 该app未开启发消息功能
    V2NIM_ERROR_CODE_REVOKE_MESSAGE_TO_SELF_NOT_ALLOWED   = 107429,  ///< 不允许撤回发给自己的消息
    V2NIM_ERROR_CODE_INVALID_TIME_RANGE                   = 107439,  ///< 无效的时间范围 
    V2NIM_ERROR_CODE_MESSAGE_HIT_ANTISPAM                 = 107451,  ///< 消息命中反垃圾
    V2NIM_ERROR_CODE_CLIENT_ANTISPAM                      = 107452,  ///< 客户端反垃圾
    ///群
    V2NIM_ERROR_CODE_TEAM_TARGETING_MESSAGE_DISABLED      = 108318,  ///< 群定向消息功能未开启
    V2NIM_ERROR_CODE_SUPER_TEAM_INCLUSIVE_AS_FALSE_NOT_ALLOWED        = 108319,  ///< 超级群定向消息不支持反选
    V2NIM_ERROR_CODE_SUPER_TEAM_TARGET_MESSAGE_NEW_MEMBER_INVISIBLE   = 108320,  ///< 超级群定向消不支持新成员可见
    V2NIM_ERROR_CODE_DISALLOW_TARGETED_MESSAGES_INCLUSIVE_NEW_MEMBERS = 108321,  ///< 定向消息成员正选不支持新成员可见
    V2NIM_ERROR_CODE_TEAM_NOT_EXIST                       = 108404,  ///< 群不存在
    V2NIM_ERROR_CODE_GET_ONLINE_USERS_COUNT_DISABLED      = 108406,  ///< 获取在线人数功能未开启
    V2NIM_ERROR_CODE_ALL_TEAM_MEMBERS_CHAT_BANNED         = 108423,  ///< 群全体禁言
    V2NIM_ERROR_CODE_ASSIGN_TEAM_OWNER_MANAGER_ROLE_NOT_ALLOWED  = 108430,  ///< 不允许添加群主为管理员
    V2NIM_ERROR_CODE_EXTENDED_SUPER_TEAM_LIMIT            = 108434,  ///< 大容量超大群数量超限
    V2NIM_ERROR_CODE_CREATED_TEAM_LIMIT                   = 108435,  ///< 创建群组超过上限
    V2NIM_ERROR_CODE_TEAM_INVITATION_LIMIT                = 108437,  ///< 群人数超过上限
    V2NIM_ERROR_CODE_TEAM_HIT_ANTISPAM                    = 108451,  ///< 群组反垃圾
    V2NIM_ERROR_CODE_TEAM_OPERATION_NEED_RETRY            = 108449,  ///< 群组请求需要重试
    V2NIM_ERROR_CODE_NOT_ADVANCED_TEAM                    = 108302,  ///< 非高级群
    V2NIM_ERROR_CODE_TEAM_MANAGER_LIMIT                   = 108303,  ///< 管理员超限
    V2NIM_ERROR_CODE_EXTENDED_SUPER_TEAM_LIMIT_NOT_CONFIGURED = 108304,  ///< 未配置大容量超大群的数量
    V2NIM_ERROR_CODE_JOINED_TEAM_LIMIT                    = 108305,  ///< 加入群组超过上限
    V2NIM_ERROR_CODE_TEAM_NORMAL_MEMBER_CHAT_BANNED       = 108306,  ///< 群普通成员禁言
    V2NIM_ERROR_CODE_INVITED_ACCOUNT_NOT_FRIEND           = 108307,  ///< 被邀请者非好友关系
    V2NIM_ERROR_CODE_REJECT_ALL_TEAM_APPLICATIONS         = 108308,  ///< 拒绝所有入群申请
    V2NIM_ERROR_CODE_TEAM_MEMBERS_COUNT_LIMIT             = 108309,  ///< 不允许创建超出 %s 人的群
    V2NIM_ERROR_CODE_OPERATOR_ALREADY_OWN_TEAM            = 108310,  ///< 当前操作者已是群主
    V2NIM_ERROR_CODE_SUPER_TEAM_SERVICE_DISABLED          = 108311,  ///< 超大群服务未开通
    V2NIM_ERROR_CODE_CREATE_EXTENDED_SUPER_TEAM_NOT_ALLOWED = 108313,  ///< 不允许创建大容量超大群
    V2NIM_ERROR_CODE_TEAM_PER_QUERY_LIMIT                 = 108314,  ///< 查询群的数量超限
    // 群成员
    V2NIM_ERROR_CODE_CHAT_BAN_LIST_CONTAIN_NOT_TEAM_MEMBER = 109301,  ///< 禁言列表包含非群成员
    V2NIM_ERROR_CODE_CHAT_BAN_LIST_CONTAIN_OPERATOR        = 109303,  ///< 禁言列表包含操作人
    V2NIM_ERROR_CODE_CHAT_BAN_LIST_CONTAIN_TEAM_OWNER      = 109304,  ///< 禁言列表包含群主
    V2NIM_ERROR_CODE_OPERATION_ON_TEAM_MANAGER_NOT_ALLOWED = 109305,  ///< 不允许操作管理员
    V2NIM_ERROR_CODE_NO_TEAM_INVITE_PERMISSION             = 109306,  ///< 没有群邀请权限
    V2NIM_ERROR_CODE_TEAM_OWNER_QUIT_NOT_ALLOWED           = 109307,  ///< 群主不允许退群
    V2NIM_ERROR_CODE_TEAM_OWNER_IN_KICK_LIST               = 109308,  ///< 群被踢列表包含群主
    V2NIM_ERROR_CODE_INVITE_ROBOT_ACCOUNT_NOT_ALLOWED      = 109309,  ///< 不允许邀请机器人账号进群
    V2NIM_ERROR_CODE_KICK_OPERATOR_NOT_ALLOWED             = 109310,  ///< 被踢的群成员列表中包含操作者
    V2NIM_ERROR_CODE_TEAM_MEMBER_ALREADY_EXIST             = 109311,  ///< 群成员已存在
    V2NIM_ERROR_CODE_TEAM_MEMBER_CAN_NOT_MODIFY_SELF       = 109312,  ///< 不允许操作自己
    V2NIM_ERROR_CODE_TEAM_INVITATION_OR_APPLICATION_NOT_EXIST = 109313,  ///< 群邀请或申请记录不存在
    V2NIM_ERROR_CODE_OPERATION_ON_TEAM_OWNER_NOT_ALLOWED   = 109314,  ///< 不允许操作群主
    V2NIM_ERROR_CODE_FORCED_PUSH_LIST_INCLUDES_NON_TARGETED_ACCOUNTS  = 109318,  ///< 强推列表包含非定向成员
    V2NIM_ERROR_CODE_TEAM_MEMBER_NOT_EXIST                 = 109404,  ///< 群成员不存在
    V2NIM_ERROR_CODE_TEAM_MEMBER_CHAT_BANNED               = 109424,  ///< 群成员被禁言
    V2NIM_ERROR_CODE_TEAM_OWNER_OPERATION_PERMISSION_REQUIRED = 109427,  ///< 仅允许群主操作
    V2NIM_ERROR_CODE_TEAM_OWNER_OR_MANAGER_OPERATION_PERMISSION_REQUIRED = 109432,  ///< 仅允许群主或管理员操作
    V2NIM_ERROR_CODE_TEAM_MEMBER_CONCURRENT_OPERATION_FAILED = 109449,  ///< 并发操作群成员失败
    V2NIM_ERROR_CODE_TEAM_MEMBER_HIT_ANTISPAM              = 109451,  ///< 群成员反垃圾
    
    V2NIM_ERROR_CODE_ACCOUNTS_FOR_CONVERSATIONS_NOT_UNIQUE = 110301,  ///< 会话所属账号不唯一
    V2NIM_ERROR_CODE_CONVERSATION_AND_ACCOUNT_MISMATCH     = 110302,  ///< 会话和账号不匹配
    V2NIM_ERROR_CODE_CONVERSATION_STICK_TOP_LIMIT          = 110303,  ///< 会话置顶数量超限
    V2NIM_ERROR_CODE_CONVERSATION_BELONGED_GROUP_LIMIT     = 110304,  ///< 会话所属会话分组数量超限
    V2NIM_ERROR_CODE_CONVERSATION_IS_NOT_STICK_TOP          = 110305, ///<当前会话未置顶
    V2NIM_ERROR_CODE_STICK_TOP_DISABLED                             = 110306, ///< 置顶功能未开通
    V2NIM_ERROR_CODE_CONVERSATION_NOT_EXIST                = 110404,  ///< 会话不存在
    V2NIM_ERROR_CODE_CONVERSATION_OPERATION_NEED_RETRY     = 110449,  ///< 会话请求需要重试
    V2NIM_ERROR_CODE_BROADCASTING_NOTIFICATION_DISABLED    = 111410,  ///< 广播通知未开启
    V2NIM_ERROR_CODE_BROADCASTING_NOTIFICATION_NOT_EXIST   = 111404,  ///< 广播通知不存在
    V2NIM_ERROR_CODE_CHATROOMBROADCASTING_HIT_ANTISPAM     = 111451,  ///< 反垃圾
    V2NIM_ERROR_CODE_NO_DUPBRODCASTMSG                     = 111301,  ///< 重发消息不存在

    V2NIM_ERROR_CODE_GET_CHATROOM_LINK_FAILED             = 113304,  ///< 获取有效的聊天室连接地址失败
    V2NIM_ERROR_CODE_IM_CONNECTION_ABNORMAL               = 113305,  ///< IM 连接状态异常
    V2NIM_ERROR_CODE_CHATROOM_NOT_EXIST                   = 113404,  ///< 聊天室不存在
    V2NIM_ERROR_CODE_CHATROOM_CLOSED                      = 113406,  ///< 聊天室已关闭
    V2NIM_ERROR_CODE_CHATROOM_REPEATED_OPERATION          = 113409,  ///< 聊天室重复操作
    V2NIM_ERROR_CODE_CHATROOM_SERVICE_DISABLED            = 113410,  ///< 聊天室服务未开通
    V2NIM_ERROR_CODE_ALL_CHATROOM_MEMBERS_CHAT_BANNED     = 113423,  ///< 聊天室全体禁言
    V2NIM_ERROR_CODE_CHATROOM_INFO_HIT_ANTISPAM           = 113451,  ///< 聊天室信息命中反垃圾
    V2NIM_ERROR_CODE_CHATROOM_ILLEGAL_AUTH_TYPE           = 113306,  ///< 非法的聊天室鉴权方式
    V2NIM_ERROR_CODE_IDENTICAL_FIELD_VALUES               = 113307,  ///< 参数与现有聊天室属性一致，无需更新
    V2NIM_ERROR_CODE_CHATROOM_MANAGER_OPERATION_REQUIRED  = 113428,  ///< 仅允许聊天室管理员操作
    V2NIM_ERROR_CODE_CHATROOM_COUNT_LIMIT                 = 113434,  ///< 聊天室数量超过限制
    V2NIM_ERROR_CODE_NOTIFICATION_FOR_MEMBER_IN_OUT_CHATROOM_DISALED = 113308,  ///< 聊天室成员进出通知功能未开启
    V2NIM_ERROR_CODE_CHATROOM_TEMP_CHAT_BANNED            = 113301,  ///< 聊天室被临时禁言
    V2NIM_ERROR_CODE_CHATROOM_TAGGED_MEMBERS_CHAT_BANNED  = 113302,  ///< 聊天室标签成员被禁言
    V2NIM_ERROR_CODE_CHATROOM_CLOSING                     = 113303,  ///< chat room closing, reopen not allowed
    V2NIM_ERROR_CODE_CHATROOM_BROADCASTING_NOTIFICATION_HIT_ANTISPAM = 113309,  ///< 广播通知命中反垃圾
    V2NIM_ERROR_CODE_CHATROOM_BROADCASTING_NOTIFICATION_DISABLED = 113310,  ///< 广播通知服务未开启
    
    V2NIM_ERROR_CODE_CHATROOM_MEMBER_NOT_EXIST             = 114404,  ///< 聊天室成员不存在
    V2NIM_ERROR_CODE_CHATROOM_MEMBER_REPEATED_OPERATION    = 114405,  ///< 聊天室成员重复操作
    V2NIM_ERROR_CODE_CHATROOM_MEMBER_CHAT_BANNED           = 114421,  ///< 聊天室成员禁言
    V2NIM_ERROR_CODE_ACCOUNT_IN_CHATROOM_BLOCK_LIST        = 114426,  ///< 账号在聊天室黑名单中
    V2NIM_ERROR_CODE_CHATROOM_OWNER_OPERATION_PERMISSION_REQUIRED = 114427,  ///< 仅允许聊天室所有者操作
    V2NIM_ERROR_CODE_OPERATOR_IN_CHATROOM_MEMBER_OPERATION_LIST = 114429,  ///< 聊天室成员操作列表包含操作者
    V2NIM_ERROR_CODE_CHATROOM_OWNER_OR_MANAGER_OPERATION_PERMISSION_REQUIRED = 114432,  ///< 仅允许聊天室所有者或管理员操作
    V2NIM_ERROR_CODE_CHATROOM_MEMBER_LIMIT                 = 114437,  ///< 聊天室成员数量超限
    V2NIM_ERROR_CODE_CHATROOM_MEMBER_CONCURRENT_OPERATION_FAILED = 114449,  ///< 并发操作聊天室成员失败
    V2NIM_ERROR_CODE_CHATROOM_MEMBER_INFO_HIT_ANTISPAM     = 114451,  ///< 聊天室成员命中反垃圾
    V2NIM_ERROR_CODE_CHATROOM_MEMBER_ALREADY_DELETED       = 114408,  ///< 聊天室成员已删除
    V2NIM_ERROR_CODE_CHATROOM_MEMBER_IN_BLOCKLIST_CHAT_BANNED_LIST = 114301,  ///< 目标账号在禁言或黑名单列表中
    V2NIM_ERROR_CODE_ANONYMOUS_MEMBER_OPERATION_FORBIDDEN  = 114303,  ///< 匿名成员禁止操作
    V2NIM_ERROR_CODE_CHATROOM_TARGET_MEMBER_OFFLINE        = 114304,  ///< 目标成员帐号不在线
    
    // 会话分组
    V2NIM_ERROR_CODE_CONVERSATION_GROUP_NOT_EXIST           = 116404,  ///< 会话分组不存在
    V2NIM_ERROR_CODE_CONVERSATION_GROUP_LIMIT               = 116435,  ///< 会话分组数量超限
    V2NIM_ERROR_CODE_CONVERSATIONS_IN_GROUP_LIMIT           = 116437,  ///< 会话分组中的会话数量超限
    V2NIM_ERROR_CODE_COLLECTION_LIMIT                       = 189301,  ///< 收藏数量超限
    V2NIM_ERROR_CODE_COLLECTION_NOT_EXIST                   = 189302,  ///< 收藏不存在
    V2NIM_ERROR_CODE_COLLECTION_CONCURRENT_OPERATION_FAILED = 189449,  ///< 收藏并发操作失败
    V2NIM_ERROR_CODE_CLIENT_ANTISPAM_FILE_NO_CHANGE         = 189303,  ///< 客户端反垃圾文件没有发生变化
    V2NIM_ERROR_CODE_CLIENT_ANTISPAM_FILE_SIZE_LIMIT        = 189304,  ///< 客户端反垃圾文件大小超限

    // 信令
    V2NIM_ERROR_CODE_SIGNALLING_ROOM_EXIST = 118301, ///<信令房间已存在@The signaling room already exists.
    V2NIM_ERROR_CODE_SIGNALLING_INVITE_ACCEPTED = 118302, ///<邀请已经被接受@The signaling invitation has been accepted.
    V2NIM_ERROR_CODE_SIGNALLING_MEMBER_NOT_EXIST = 118303, ///<信令成员不存在@The signaling member does not exist.
    V2NIM_ERROR_CODE_SIGNALLING_MEMBER_ALREADY_EXIST = 118304, ///<信令成员已存在@The signaling member already exists.
    V2NIM_ERROR_CODE_SIGNALLING_MEMBER_ALREADY_EXIST_AND_DEVICE_ID_NOT_UNIQUE = 118305, ///<信令成员已存在且设备ID不一致@The signaling member exists with a non-unique device ID.
    V2NIM_ERROR_CODE_SIGNALLING_UID_NOT_UNIQUE = 118306, ///<UID 不唯一@The signaling uid is not unique.
    V2NIM_ERROR_CODE_SIGNALLING_INVITE_REJECTED = 118307, ///<邀请已经被拒绝@The signaling invitation has been declined.
    V2NIM_ERROR_CODE_SIGNALLING_MEMBER_OFFLINE_BUT_PUSH_REACHABLE = 118308, ///<信令成员不在线， 但推送可达@The signaling member is offline but can be reached via push notifications.
    V2NIM_ERROR_CODE_SIGNALLING_MEMBER_OFFLINE_AND_PUSH_NOT_REACHABLE = 118309, ///<信令成员不在线， 且推送不可达@The signaling member is offline and unreachable via push notifications.
    V2NIM_ERROR_CODE_SIGNALLING_INVITE_NOT_EXIST = 118310, ///<邀请不存在@The signaling invitation does not exist.
    V2NIM_ERROR_CODE_SIGNALLING_ROOM_NOT_EXIST = 118404, ///<房间不存在@The signaling room does not exist.
    V2NIM_ERROR_CODE_SIGNALLING_ROOM_MEMBER_LIMIT = 118437, ///<房间成员数量超限@The signaling room has reached member limit.
    V2NIM_ERROR_CODE_SIGNALLING_SERVICE_DISABLED = 118410, ///<信令服务未开通@The signaling service is disabled. Please enable it first.
    
    V2NIM_ERROR_CODE_FAILED_TO_REQUEST_LLM                = 189308,  ///< 请求大语言模型失败
    V2NIM_ERROR_CODE_STREAM_OUTPUT_STOPPED          =189318, /// < 流式输出已停止
    V2NIM_ERROR_CODE_STREAM_OUTPUT_GENERATED            =189319, /// < 流式输出已完成
    V2NIM_ERROR_CODE_STREAM_OUTPUT_ABORTED          =189320, /// < 流式输出异常中断
    V2NIM_ERROR_CODE_INTERRUPTION_REJECTED          =189321, /// < 非流式消息无法中断
    
    V2NIM_ERROR_CODE_INTERNAL                             = 190001,  ///< 内部错误
    V2NIM_ERROR_CODE_ILLEGAL_STATE                        = 190002,  ///< 非法状态
    V2NIM_ERROR_CODE_MISUSE                               = 191001,  ///< 使用姿势错误
    V2NIM_ERROR_CODE_CANCELLED                            = 191002,  ///< 操作取消
    V2NIM_ERROR_CODE_CALLBACK                             = 191003,  ///< 回调错误
    V2NIM_ERROR_CODE_INVALID_PARAMETER                    = 191004,  ///< 参数错误
    V2NIM_ERROR_CODE_TIMEOUT                              = 191005,  ///< 超时
    V2NIM_ERROR_CODE_REQUEST_RESOURCE_NOT_EXIST           = 191006,  ///< 请求资源不存在
    V2NIM_ERROR_CODE_REQUEST_RESOURCE_EXIST               = 191007,  ///< 请求资源已存在
    V2NIM_ERROR_CODE_IN_OFFLINE_MODE                      = 191008,  ///< 处于离线模式
    V2NIM_ERROR_CODE_LAST_KICKED                          = 191009,  ///< 上次登录被踢

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
    V2NIM_ERROR_CODE_FILE_UPLOAD_FAILED                   = 194006,  ///<文件上传失败
    V2NIM_ERROR_CODE_FILE_DOWNLOAD_FAILED                 = 194007,  ///<文件下载失败
    V2NIM_ERROR_CODE_LOCAL_ANTISPAM                       = 195001,  ///<命中本地反垃圾
    V2NIM_ERROR_CODE_SERVER_ANTISPAM                      = 195002,  ///<云端反垃圾
};

NS_ASSUME_NONNULL_END
