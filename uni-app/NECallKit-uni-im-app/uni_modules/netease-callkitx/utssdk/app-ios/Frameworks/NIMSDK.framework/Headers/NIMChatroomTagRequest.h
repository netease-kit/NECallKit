//
// Created by Songwenhai on 2021/4/10.
// Copyright (c) 2021 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMChatroomMember;

/**
 *  禁言某个标签的用户的发言，只有管理员或创建者能操作
 */
@interface NIMChatroomTempMuteTagRequest : NSObject

/**
 *  聊天室ID
 */
@property(nullable, nonatomic, copy) NSString *roomId;

/**
 *  禁言的tag
 */
@property(nullable, nonatomic, copy) NSString *targetTag;

/**
 *  禁言的时长，单位秒，若设置为0，则表示取消禁言
 */
@property(nonatomic, assign) unsigned long long duartion;


/**
 *  是否需要通知
 */
@property(nonatomic, assign) BOOL needNotify;

/**
 *  操作通知事件扩展
 */
@property(nullable, nonatomic, copy) NSString *notifyExt;

/**
 *  禁言通知广播的目标标签，默认是targetTag
 */
@property(nullable, nonatomic, copy) NSString *notifyTargetTags;


@end

/**
 *  根据用户标签获取聊天室成员请求
 */
@interface NIMChatroomFetchMembersByTagRequest : NSObject

/**
 *  聊天室ID
 */
@property(nullable, nonatomic, copy) NSString *roomId;

/**
 *  标签
 */
@property(nullable, nonatomic, copy) NSString *tag;

/**
 *  最后一位成员锚点，不包括此成员。填nil会使用当前服务器最新时间开始查询，即第一页。
 */
@property(nullable, nonatomic, strong) NIMChatroomMember *lastMember;

/**
 *  获取聊天室成员个数
 */
@property(nonatomic, assign) NSUInteger limit;


@end


/**
 *  根据用户标签获取聊天室在线成员数量请求
 */
@interface NIMChatroomQueryMembersCountByTagRequest : NSObject

/**
 *  聊天室ID
 */
@property(nullable, nonatomic, copy) NSString *roomId;

/**
 *  标签
 */
@property(nullable, nonatomic, copy) NSString *tag;

@end

@interface NIMChatroomLocation : NSObject

/**
 *  聊天室ID
 */
@property(nullable, nonatomic, copy) NSString *roomId;
/**
 * X坐标
 */
@property (nonatomic, copy) NSNumber *locationX;
/**
 * Y坐标
 */
@property (nonatomic, copy) NSNumber *locationY;
/**
 * Z坐标
 */
@property (nonatomic, copy) NSNumber *locationZ;
/**
 * 距离
 */
@property (nonatomic, copy) NSNumber *distance;
@end

@interface NIMChatroomTagsUpdate : NSObject

/**
 *  聊天室ID
 */
@property(nullable, nonatomic, copy) NSString *roomId;
/**
 * 标签，可以设置多个，如果不传，则会删掉老的标签
 */
@property (nullable, nonatomic, copy) NSArray<NSString *> *tags;
/**
 * 更新标签的通知的目标标签，是一个标签表达式，同时也会改变该连接掉线时的通知对象，见TagCalculator和TagPattern，如果不传，则会删掉老的notifyTargetTags
 */
@property (nullable, nonatomic, copy) NSString *notifyTargetTags;
/**
 * 是否需要通知，填true则会产生一条通知，类型为325
 */
@property (nonatomic, assign) BOOL needNotify;
/**
 * 通知扩展字段
 */
@property (nullable, nonatomic, copy) NSString *ext;

@end
