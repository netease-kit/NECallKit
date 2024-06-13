//
//  NIMPassThroughOption.h

//  NIMLib
//
//  Created by Netease on 2019/12/19.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NIPassThroughHttpMethod){
    /*
     * Get
     */
    NIPassThroughHttpMethodGet     = 1,
    /*
     * POST
     */
    NIPassThroughHttpMethodPost    = 2,
    /*
     * Put
     */
    NIPassThroughHttpMethodPut     = 3,
    /*
     * Delete
     */
    NIPassThroughHttpMethodDelete  = 4,
};

/**
 *  透传的HTTP数据
 */
@interface NIMPassThroughHttpData : NSObject

/**
 *  映射一个视频云upstream host
 *  不传则用默认配置
 *  选填
 */
@property (nullable, nonatomic, copy) NSString *zone;

/**
 *  url中除了host的path
 *  必填
 */
@property (nonatomic, copy) NSString *path;

/**
 *  Http Method
 *  默认post
 *  选填
 */
@property (nonatomic, assign) NIPassThroughHttpMethod method;

/**
 *  Http Header
 *  必须为json格式
 *  选填
 */
@property (nullable, nonatomic, copy) NSString *header;

/**
 *  Http body
 *  格式自定
 *  GET时必须为空, POST和PUT时必须为非空
 */
@property (nullable, nonatomic, copy) NSString *body;

@end

/**
 *  收到的透传消息
 */
@interface NIMPassThroughMsgData : NSObject

/**
 *  发送方accid
 */
@property (nullable, nonatomic, copy) NSString *fromAccid;

/**
 *  透传内容
 */
@property (nonatomic, copy) NSString *body;

/**
 *  发送时间, 毫秒
 */
@property (nonatomic, assign) int64_t time;

@end

NS_ASSUME_NONNULL_END
