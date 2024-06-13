//
//  V2NIMCollection.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/8/31.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface V2NIMCollection : NSObject
/// 收藏信息客户端 ID, 收藏时若存在相同客户端 ID 则覆盖
@property (nullable,nonatomic,strong) NSString *collectionId;
/// 收藏索引,大于 0， 可以按该字段分类
@property (nonatomic,assign) int collectionType;
/// 收藏数据, 最大 20480 字节
@property (nullable,nonatomic,strong,readonly) NSString *collectionData;
/// 收藏信息客户端 ID, 收藏时若存在相同客户端 ID 则覆盖
@property (nullable,nonatomic,strong) NSString *serverExtension;
/// 创建时间
@property (nonatomic,assign) NSTimeInterval createTime;
/// 更新时间
@property (nonatomic,assign) NSTimeInterval updateTime;
@end

NS_ASSUME_NONNULL_END
