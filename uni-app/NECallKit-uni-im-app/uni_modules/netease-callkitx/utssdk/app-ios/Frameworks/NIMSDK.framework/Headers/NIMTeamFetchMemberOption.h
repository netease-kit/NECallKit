//
//  NIMTeamFetchMemberOption.h
//  NIMSDK
//
//  Created by Netease on 2019/5/27.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NIMTeamFetchMemberOption : NSObject

/**
 *  查询成员的开始位置, 要求 >=0 。
 */
@property (nonatomic, assign)  NSInteger offset;

/**
 *  查询成员的个数。如小于0, 查询从offset 开始至结尾的全部成员, 默认 -1。
 */
@property (nonatomic, assign)  NSInteger count;

/**
 *  从服务端拉取
 */
@property (nonatomic, assign) BOOL fromServer;

@end

NS_ASSUME_NONNULL_END
