//
//  V2NIMThreadMessageListOption.h
//  NIMLib
//
//  Created by Netease on 2024/5/6.
//  Copyright © 2024 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "V2NIMBase.h"
#import "V2NIMMessageEnum.h"

@class V2NIMMessageRefer;

NS_ASSUME_NONNULL_BEGIN
@interface V2NIMThreadMessageListOption: NSObject

 /// 需要查询的消息引用， 如果该消息为根消息，则参数为当前消息；否则需要获取当前消息的根消息作为输入参数查询；否则查询失败
@property (nonnull,nonatomic,strong) V2NIMMessageRefer *messageRefer;
/// 查询开始时间，小于等于 endTime。
@property(nonatomic,assign) NSTimeInterval beginTime;
/// 查询结束时间。默认当前时间+1个小时
@property(nonatomic,assign) NSTimeInterval endTime;
/// 锚点消息ServerId, 该消息必须处于端点，暨消息时间必须等于beginTime或endTime
/// 如果是合法的消息id则表示排除该消息，否则不排除
@property (nullable,nonatomic,copy) NSString *excludeMessageServerId;
/// 每次查询条数
/// 默认50，必须大于 0
@property(nonatomic,assign) NSInteger limit;
/// 消息查询方向，如果其它参数都不填
/// DESC:  按时间从大到小查询
/// ASC:按时间从小到大查询
@property(nonatomic,assign) V2NIMQueryDirection direction;
@end

NS_ASSUME_NONNULL_END
