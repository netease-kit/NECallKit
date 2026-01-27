//
//  V2NIMMessageConverter.h
//  NIMLib
//
//  Created by 崔生余 on 2024/3/20.
//  Copyright © 2024 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class V2NIMMessage;

NS_ASSUME_NONNULL_BEGIN

@interface V2NIMMessageConverter : NSObject
/**
 *  消息序列化为字符串
 *
 *  @param message 消息对象
 *  @return 返回字符串或者nil
 *  @discussion 如果传入的对象为空返回字符串为空
 */
+ (NSString * _Nullable)messageSerialization:(V2NIMMessage *)message;

/**
 *  消息字符串转换为消息
 *
 *  @param msg 消息字符串
 *  @return 消息对象
 *  @discussion 传入空串，或者不符合json格式的字符串，返回结果为nil
 */
+ (V2NIMMessage * _Nullable)messageDeserialization:(NSString *)msg;

@end

NS_ASSUME_NONNULL_END
