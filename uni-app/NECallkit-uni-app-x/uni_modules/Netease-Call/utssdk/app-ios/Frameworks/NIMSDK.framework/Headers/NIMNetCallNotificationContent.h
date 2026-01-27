//
//  NIMNetCallNotificationContent.h
//  NIMLib
//
//  Created by Netease
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMGlobalDefs.h"
#import "NIMNotificationContent.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  网络电话类型
 */
typedef NS_ENUM(NSInteger, NIMNetCallEventType){
    /**
     *  对方无人接听
     */
    NIMNetCallEventTypeNoResponse = -2,
    /**
     *  未接电话
     */
    NIMNetCallEventTypeMiss = 101,
    /**
     *  电话回单
     */
    NIMNetCallEventTypeBill = 102,
    /**
     *  对方拒接电话
     */
    NIMNetCallEventTypeReject = 103,
};


/**
 *  网络通话通知内容
 */
@interface NIMNetCallNotificationContent : NIMNotificationContent
/**
 *  网络通话类型
 */
@property (nonatomic,assign)   NIMNetCallType callType;
/**
 *  操作类型
 */
@property (nonatomic,assign)   NIMNetCallEventType eventType;
/**
 *  call channel ID
 */
@property (nonatomic,assign)   UInt64 callID;
/**
 *  呼叫方 ID
 */
@property (nonatomic,copy)     NSString *from;
/**
 *  发起时间
 */
@property (nonatomic,assign)   NSTimeInterval timetag;
/**
 *  时长
 */
@property (nonatomic,assign)   NSTimeInterval duration;

/**
 *  参与通话成员
 */
@property (nonatomic,strong)   NSArray *members;

/**
 *  扩展字段
 */
@property (nonatomic,copy)     NSString *extendMessage;

@end

NS_ASSUME_NONNULL_END
