

//
//  NIMQChatSearchMsgByPageParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  分页搜索圈组消息的参数
 */
@interface NIMQChatSearchMsgByPageParam : NSObject

/**
 * 关键字， 可选
 */
@property (nullable, nonatomic, strong) NSString *keyword;

/**
 * 服务器id，可选
 */
@property (nonatomic, assign) unsigned long long serverId;

/**
 * 频道id，可选
 */
@property (nonatomic, assign) unsigned long long channelId;

/**
 * 消息发送者id，可选
 */
@property (nullable, nonatomic, strong) NSString *fromAccount;

/**
 * 开始时间，可选
 */
@property (nonatomic, assign) NSTimeInterval fromTime;

/**
 * 结束时间，可选
 */
@property (nonatomic, assign) NSTimeInterval toTime;

/**
 * 消息类型数组，元素为 NIMMessageType 的NSNumber 包装
 */
@property (nonatomic, copy) NSArray <NSNumber *> *msgTypes;

/**
 * 消息子类型数组， 可选
 */
@property (nullable, nonatomic, copy) NSArray <NSNumber *> *subTypes;

/**
 * 是否包含自己的消息， 可选，默认不包含
 */
@property (nonatomic, assign) BOOL includeSelf;

/**
 * 排序，可选，默认倒序，YES为正序
 */
@property (nonatomic, assign)  BOOL order;

/**
 * 查询数量，可选，默认100
 */
@property (nonatomic, assign) NSInteger  limit;

/**
 * 排序方式，可选， 默认发送时间方式
 */
@property (nonatomic, assign) NIMQChatSearchMessageSortType sortType;

/**
 * 查询游标，可选
 */
@property (nullable, nonatomic, strong) NSString *cursor;


@end


NS_ASSUME_NONNULL_END


