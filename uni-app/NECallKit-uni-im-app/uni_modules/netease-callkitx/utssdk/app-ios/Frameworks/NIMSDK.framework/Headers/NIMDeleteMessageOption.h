//
//  NIMDeleteMessageOption.h
//  NIMLib
//
//  Created by 张根宁 on 2020/6/8.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NIMDeleteMessageOption : NSObject

/**
*  是否从数据库中删除
*  @discussion 默认情况下云信采用标记的方式进行消息删除，如果设置为 YES，将直接从数据库中移除该消息
*/
@property  (nonatomic,assign)  BOOL removeFromDB;

@end

NS_ASSUME_NONNULL_END
