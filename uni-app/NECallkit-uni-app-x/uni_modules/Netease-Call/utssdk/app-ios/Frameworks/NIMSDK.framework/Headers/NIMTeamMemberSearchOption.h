//
//  NIMTeamMemberSearchOption.h
//  NIMLib
//
//  Created by 崔生余 on 2024/1/14.
//  Copyright © 2024 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMTeamDefs.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  查询顺序
 */
typedef NS_ENUM(NSInteger,NIMTeamMemberSearchOrder) {
    /**
     *  入群时间从近到远
     */
    NIMTeamMemberSearchOrderDesc       =   0,
    
    /**
     *  入群时间从远到近
     */
    NIMTeamMemberSearchOrderAsc        =   1,
};

@interface NIMTeamMemberKeywordSearchOption : NSObject

/**
 *  查询指定群组id，为空查询所有群组。
 */
@property (nonatomic, strong)  NSString *teamId;
/**
 *  搜索关键字，不为空。
 */
@property (nonatomic, strong)  NSString *keyword;
/**
 *  查询成员的开始位置, 要求 >=0 。
 */
@property (nonatomic, assign)  NSInteger offset;
/**
 *  查询顺序，按照入群时间，默认按照入群时间降序。
 */
@property (nonatomic, assign)  NIMTeamMemberSearchOrder order;
/**
 *  查询成员的个数。 默认10。
 */
@property (nonatomic, assign)  NSInteger limit;

@end

@interface NIMTeamMemberRoleTypeSearchOption : NSObject

/**
 *  群成员类型
 */
@property (nonatomic, copy, nullable)  NSArray<NSNumber *> *roleTypes;
/**
 *  查询成员的开始位置, 要求 >=0 。
 */
@property (nonatomic, assign)  NSInteger offset;
/**
 *  查询顺序，按照入群时间，默认按照入群时间降序。
 */
@property (nonatomic, assign)  NIMTeamMemberSearchOrder order;
/**
 *  查询成员的个数。 默认10。
 */
@property (nonatomic, assign)  NSInteger limit;

@end

NS_ASSUME_NONNULL_END
