//
//  V2NIMCollectionOption.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/9/4.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "V2NIMBase.h"
#import  "V2NIMMessageEnum.h"

@class V2NIMCollection;

NS_ASSUME_NONNULL_BEGIN

@interface V2NIMCollectionOption : NSObject
/// 查询开始时间区间，闭区间
@property (nonatomic,assign) NSTimeInterval beginTime;
/// 查询结束时间区间，闭区间 endTime大于beginTime
@property (nonatomic,assign) NSTimeInterval endTime;
/// 查询方向,默认按时间从大到小查询
@property (nonatomic,assign) V2NIMQueryDirection direction;
/// 查询锚点
/// 如果anchor为空， 则以beginTime，endTime为准
/// 如果anchor不为空如果direction为DESC，
/// endTime不为0， 则必须等于anchor的时间， 否则报错
/// endTime为0， 则以anchor为准
/// 如果dirction为ASC
/// beginTime不为0， 则必须等于anchor的时间， 否则报错
/// beginTime为0， 则以anhor为准
/// 查询内部不包括anchor
@property (nonatomic,strong,nullable) V2NIMCollection *anchorCollection;
/// 每次查询收藏条数,不超过200，默认100
@property (nonatomic,assign) NSInteger limit;
/// 收藏类型,为0表示查询所有类型
@property (nonatomic,assign) NSInteger collectionType;

@end

NS_ASSUME_NONNULL_END
