//
//  V2NIMModifyMessageParams.h
//  NIMSDK
//
//  Created by 陈吉力 on 2024/7/16.
//  Copyright © 2024 Netease. All rights reserved.
//
@class V2NIMMessageAttachment;
@class V2NIMMessageAntispamConfig;
@class V2NIMMessageRouteConfig;

NS_ASSUME_NONNULL_BEGIN

@interface V2NIMModifyMessageParams : NSObject
/// 消息子类型，默认0
@property (nonatomic, assign) NSInteger subType;
/// 消息内容
@property (nonatomic, copy, nullable) NSString *text;
/// 消息附属附件。根据消息类型继承实现
@property (nonatomic, strong, nullable) V2NIMMessageAttachment *attachment;
/// 消息服务端扩展，必须是Json 字符串
@property (nonatomic, copy, nullable) NSString *serverExtension;
/// 反垃圾相关配置
@property (nonatomic, strong, nullable) V2NIMMessageAntispamConfig *antispamConfig;
/// 路由抄送相关配置
@property (nonatomic, strong, nullable) V2NIMMessageRouteConfig *routeConfig;
/// 推送相关配置
@property (nonatomic, strong, nullable) V2NIMMessagePushConfig *pushConfig;
///是否启用本地反垃圾
///     只针对文本消息生效
///     发送消息时候，如果改字段为true，文本消息则走本地反垃圾检测，检测后返回V2NIMClientAntispamOperateType，
///     返回0，直接发送该消息
///     返回1，发送替换后的文本消息
///     返回2，消息发送失败， 返回本地错误码
///     返回3，消息正常发送，由服务端拦截
@property (nonatomic, assign) BOOL clientAntispamEnabled;
/// 本地反垃圾命中后替换的文本
///     clientAntispamEnabled为true， 且需要替换时必填
@property (nonatomic, copy, nullable) NSString *clientAntispamReplace;
@end

NS_ASSUME_NONNULL_END
