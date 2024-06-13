//
//  NIMQChatSendSystemNotificationParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMGlobalDefs.h"
#import "NIMQChatSystemNotification.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  发送自定义系统通知的参数
 */
@interface NIMQChatSendSystemNotificationParam : NSObject

//如果只填了serverId，则发送给serverId下的所有人
//如果填了serverId+channelId，则发送给serverId+channelId下的所有人
//如果填了serverId+toAccids，则发送给server下的指定账号列表
//如果填了serverId+channelId+toAccids，则发送给server下某个channel里的指定账号列表
//如果只填了toAccids serverId == 0 && channelId == 0，则发送给指定账号列表
/**
 * 目标
 */
@property(nonatomic, assign, readonly) NIMQChatSystemNotificationToType toType;

/**
 * 消息所属的服务器ID
 */
@property(nonatomic, assign, readonly) unsigned long long  serverId;

/**
 * 消息所属的频道ID
 */
@property(nonatomic, assign, readonly) unsigned long long  channelId;

/**
 * 通知接受者账号列表
 */
@property(nullable, nonatomic, copy, readonly) NSArray<NSString *> *toAccids;

/**
 * 通知内容
 */
@property(nullable, nonatomic, copy) NSString *body;

/**
 * 消息附件
 */
@property(nullable, nonatomic, copy) NSDictionary *attach;

/**
 * 消息自定义扩展字段，推荐使用json格式
 */
@property(nullable, nonatomic, copy) NSString *ext;

/**
 * 第三方自定义的推送属性，限制json
 */
@property(nonatomic, copy) NSString *pushPayload;

/**
 * 自定义推送文案
 */
@property(nullable, nonatomic, copy) NSString *pushContent;

/**
 *  环境变量
 */
@property (nullable, nonatomic, copy) NSString *env;

/**
 *  自定义系统通知设置
 *  @discussion 可以通过这个字段制定当前通知的各种设置,如是否需要计入推送未读，是否需要带推送前缀等等
 */
@property(nullable, nonatomic, copy) NIMQChatSystemNotificationSetting *setting;

- (instancetype)initWithServerId:(unsigned long long)serverId;

- (instancetype)initWithServerId:(unsigned long long)serverId
                       channelId:(unsigned long long)channelId;

- (instancetype)initWithServerId:(unsigned long long)serverId
                        toAccids:(NSArray<NSString *> *)toAccids;

- (instancetype)initWithServerId:(unsigned long long)serverId
                       channelId:(unsigned long long)channelId
                        toAccids:(NSArray<NSString *> *)toAccids;

- (instancetype)initWithAccids:(NSArray<NSString *> *)toAccids;

- (NIMQChatSystemNotification *)toQChatSystemNotification;

@end

NS_ASSUME_NONNULL_END
