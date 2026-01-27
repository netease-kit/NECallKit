//
//  NIMTeamSearchOption.h
//  NIMSDK
//
//  Created by Genning-Work on 2019/12/6.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, NIMTeamSearchContentOption){
    /*
     * 匹配TeamName
     */
    NIMTeamSearchContentOptiontName = 1 << 0,
    /*
     * 匹配TeamID
     */
    NIMTeamSearchContentOptiontId = 1 << 1,
    /*
     * 匹配全部，默认
     */
    NIMTeamSearchContentOptionTeamAll = NIMTeamSearchContentOptiontName | NIMTeamSearchContentOptiontId
};

@interface NIMTeamSearchOption : NSObject

/**
*  搜索文本的匹配区域。（默认：NIMUserSearchContentOptiontTeamName）
*/
@property (nonatomic, assign) NIMTeamSearchContentOption searchContentOption;

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
