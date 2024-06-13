//
//  NIMUserSearchOption.h
//  NIMSDK
//
//  Created by Genning-Work on 2019/11/25.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NIMUserSearchRangeOption){
    /*
     * 在好友中查询
     */
    NIMUserSearchRangeOptionFriends = 0,
    /*
     * 在所有人中查询
     */
    NIMUserSearchRangeOptionAll,
};

typedef NS_OPTIONS(NSInteger, NIMUserSearchContentOption){
    /*
     * 匹配UserId
     */
    NIMUserSearchContentOptionUserId = 1 << 0,
    /*
     * 匹配备注名（只有好友支持备注名匹配）
     */
    NIMUserSearchContentOptionAlias = 1 << 1,
    /*
     * 匹配昵称
     */
    NIMUserSearchContentOptionNickName = 1 << 2,
    /*
     * 匹配全部
     */
    NIMUserSearchContentOptionAll = NIMUserSearchContentOptionUserId | NIMUserSearchContentOptionAlias | NIMUserSearchContentOptionNickName,
};

@interface NIMUserSearchOption : NSObject

/**
*  搜索文本的搜索范围。（默认：NIMUserSearchRangeOptionFriends）
*/
@property (nonatomic, assign) NIMUserSearchRangeOption searchRange;

/**
*  搜索文本的匹配区域。（默认：NIMUserSearchContentOptionAll）
*/
@property (nonatomic, assign) NIMUserSearchContentOption searchContentOption;

/**
*  忽略大小写。（默认：YES）
*/
@property (nonatomic, assign) BOOL ignoreingCase;

/**
*  搜索文本。
*/
@property (nullable,nonatomic,copy) NSString *searchContent;

@end

NS_ASSUME_NONNULL_END
