//
//  NIMSyncStickTopSessionResponse.h
//  NIMLib
//
//  Created by 丁文超 on 2020/4/9.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NIMStickTopSessionInfo;

NS_ASSUME_NONNULL_BEGIN

@interface NIMSyncStickTopSessionResponse : NSObject

/**
 * 同步时间戳(s)
 */
@property (nonatomic, assign) NSTimeInterval timestamp;

/**
 * 是否有变更
 */
@property (nonatomic, assign) BOOL hasChange;

/**
 * 若有变更，返回所有置顶信息
 */
@property (nonatomic, copy) NSArray<NIMStickTopSessionInfo *> *allInfos;

@end

NS_ASSUME_NONNULL_END
