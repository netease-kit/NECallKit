//
//  NIMSyncMessagePinResponse.h
//  NIMLib
//
//  Created by 丁文超 on 2020/4/9.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMMessagePinItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface NIMSyncMessagePinResponse : NSObject

/**
 * 同步时间戳
 */
@property (nonatomic, assign) NSTimeInterval timestamp;

/**
 * 是否有更新内容
 */
@property (nonatomic, assign) BOOL hasChange;

/**
 * 更新的内容
 */
@property (nonatomic, copy) NSArray<NIMMessagePinItem *> *items;

@end

NS_ASSUME_NONNULL_END
