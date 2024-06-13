//
//  V2NIMMessageSearchParams.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/9/11.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "V2NIMMessageEnum.h"

NS_ASSUME_NONNULL_BEGIN

/// 消息检索参数
@interface V2NIMMessageSearchParams : NSObject
/// 检索的关键字
@property (nonatomic,strong) NSString *keyword;
/// 查询开始时间，小于endTime
@property (nonatomic,assign) NSTimeInterval beginTime;
/// 查询结束时间吗，如果为0，表示当前时间
@property (nonatomic,assign) NSTimeInterval endTime;
/// 检索的会话条数如果>0： 按会话分组 否则：按时间排序，不按会话分组 note：协议 7-26   7-27
@property (nonatomic,assign) NSUInteger conversationLimit;
/// 返回的消息条数.最多不超过X， 跟当前版本对齐
@property (nonatomic,assign) NSUInteger messageLimit;
/// 消息排序规则
@property (nonatomic,assign) V2NIMSortOrder sortOrder;
/// P2P账号列表， 最大20个，超过20个返回参数错误
@property (nonatomic,strong) NSArray <NSString *> *p2pAccountIds;
/// 高级群账号列表， 最大20个， 超过20个返回参数错误.不支持超大群
@property (nonatomic,strong) NSArray <NSString *> *teamIds;
/// 检索的发送账号列表，最大20个， 超过20个返回参数错误
@property (nonatomic,strong) NSArray <NSString *> *senderAccountIds;
/// 根据消息类型检索消息， 为null或空列表， 则表示查询所有消息类型 V2NIMMessageType
@property (nonatomic,strong) NSArray *messageTypes;
/// 根据消息子类型检索消息， 为null或空列表， 则表示查询所有消息子类型
@property (nonatomic,strong) NSArray *messageSubtypes;

@end

NS_ASSUME_NONNULL_END
