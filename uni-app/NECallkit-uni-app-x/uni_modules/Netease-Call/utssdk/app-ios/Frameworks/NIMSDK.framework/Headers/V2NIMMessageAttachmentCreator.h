//
//  V2NIMMessageAttachmentCreator.h
//  NIMSDK
//
//  Created by 陈吉力 on 2024/7/24.
//  Copyright © 2024 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class V2NIMMessageLocationAttachment;
@class V2NIMMessage;
@class V2NIMMessageCallAttachment;
@class V2NIMMessageCallDuration;
@class V2NIMMessageAttachment;


NS_ASSUME_NONNULL_BEGIN

@interface V2NIMMessageAttachmentCreator : NSObject
/// 构造地理位置消息附件
/// @param latitude 纬度 【必填】
/// @param longitude 经度 【必填】
/// @param address 详细位置信息 【必填】
+ (V2NIMMessageLocationAttachment *)createLocationMessageAttachment:(double)latitude
                                                          longitude:(double)longitude
                                                            address:(NSString *)address;

/// 构造自定义消息消息
/// @param text 需要发送的文本内容
/// @param rawAttachment 需要发送的附件
+ (V2NIMMessageAttachment *)createCustomMessageAttachment:(NSString *)rawAttachment;
@end

NS_ASSUME_NONNULL_END
