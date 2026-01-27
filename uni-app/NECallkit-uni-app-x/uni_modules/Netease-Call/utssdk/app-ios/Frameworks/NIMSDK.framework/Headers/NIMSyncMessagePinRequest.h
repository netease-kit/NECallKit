//
//  NIMSyncMessagePinRequest.h
//  NIMLib
//
//  Created by 丁文超 on 2020/4/9.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NIMSession;

NS_ASSUME_NONNULL_BEGIN

@interface NIMSyncMessagePinRequest : NSObject

/**
 * 会话
 */
@property (nonatomic, copy) NIMSession *session;

/**
 * 同步时间戳(s)
 */
@property (nonatomic, assign) NSTimeInterval timestamp;

/**
 * 默认初始化方法
 */
- (instancetype)initWithSession:(NIMSession *)session;

@end

NS_ASSUME_NONNULL_END
