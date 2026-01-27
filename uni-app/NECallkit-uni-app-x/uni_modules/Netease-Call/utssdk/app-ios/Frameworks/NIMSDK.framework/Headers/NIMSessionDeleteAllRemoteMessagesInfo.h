//
//  NIMSessionDeleteAllRemoteMessagesInfo.h
//  NIMLib
//
//  Created by Wenchao Ding on 2020/9/1.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMSession;

NS_ASSUME_NONNULL_BEGIN

@interface NIMSessionDeleteAllRemoteMessagesInfo : NSObject

/**
 * 会话
 */
@property (nonatomic, copy) NIMSession *session;

/**
 * 消息发送方accid
 */
@property (nonatomic, copy) NSString *fromAccid;

/**
 * 删除时间(ms)
 */
@property (nonatomic, assign) uint64_t time;

/**
 * 扩展字段
 */
@property (nonatomic, copy) NSString *ext;

@end

NS_ASSUME_NONNULL_END
