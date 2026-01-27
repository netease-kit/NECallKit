//
//  NIMQChatAPIDefs.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#ifndef NIMQChatAPIDefs_h
#define NIMQChatAPIDefs_h

#import <Foundation/Foundation.h>


/**
 *  圈组网络请求回调
 *
 *  @param error 错误信息
 */
typedef void(^NIMQChatHandler)(NSError *__nullable error);


/**
 *  消息引用类型
 */
typedef NS_ENUM(NSInteger, NIMQChatMessageReferType) {
    /**
     *  回复的
     *  @discussion
     */
    NIMQChatMessageReferTypeReply       =   1,
    
    /**
     *  Thread
     *  @discussion
     */
    NIMQChatMessageReferTypeThread      =   2,

    /**
     *  所有
     *  @discussion
     */
    NIMQChatMessageReferTypeAll         =   3,
};

#endif /* NIMQChatAPIDefs_h */
