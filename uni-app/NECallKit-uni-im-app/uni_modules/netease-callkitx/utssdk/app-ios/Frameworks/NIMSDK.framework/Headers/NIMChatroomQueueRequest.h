//
//  NIMChatroomQueueRequest.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

/**
 *  聊天室通用队列更新请求
 */
@interface NIMChatroomQueueUpdateRequest : NSObject

/**
 *  聊天室 ID
 */
@property (nonatomic,copy) NSString *roomId;

/**
 *  更新元素的 Key 值，如果 key 在队列中存在则更新，不存在则放到队列尾部 ，长度限制为 32 字节
 */
@property (nonatomic,copy) NSString *key;

/**
 *  更新元素的 Value 值，长度限制为 4096 字节
 */
@property (nonatomic,copy) NSString *value;

/**
 *  当提交这个新元素的用户从聊天室掉线或退出的时候，是否需要删除这个元素，默认为 NO 不删除。
 */
@property (nonatomic,assign) BOOL transient;

/**
 *  队列元素所属账号，默认不传表示队列元素属于当前操作人，管理员可以指定队列元素归属于其他合法账号。
 */
@property (nonatomic,copy) NSString *elementAccid;

@end




/**
 *  聊天室通用队列取出请求
 */
@interface NIMChatroomQueueRemoveRequest : NSObject

/**
 *  聊天室ID
 */
@property (nonatomic,copy) NSString *roomId;

/**
 *  拉去元素的Key值，如果要拉取第一个元素，则传空
 */
@property (nullable,nonatomic,copy) NSString *key;


@end



/**
 *  聊天室通用队列批量更新请求
 */
@interface NIMChatroomQueueBatchUpdateRequest : NSObject

/**
 *  聊天室 ID
 */
@property (nonatomic,copy) NSString *roomId;

/**
 *  批量更新元素的key-value对，key/value分别是elementKey和elementValue（elementKey限制128字节,elementValue限制4096字节），一次最多更新100个
 */
@property (nonatomic,copy) NSDictionary *elements;

/**
 *  是否需要发送广播通知
 */
@property (nonatomic,assign) BOOL needNotify;


/**
 *  通知中的自定义字段，长度限制2048
 */
@property (nonatomic,copy) NSString* notifyExt;

@end

NS_ASSUME_NONNULL_END
