//
//  V2NIMNotificationAntispamConfig.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/8/30.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface V2NIMNotificationAntispamConfig : NSObject
/// 指定是否需要过安全通（对于已开通安全通的用户有效，默认通知都会走安全通，如果对单条通知设置 enable 为false，则此通知不会走安全通）。true：需要，false：不需要.该字段为true，其他字段才生效
@property(nonatomic,assign,readwrite) BOOL antispamEnabled;
/// 开发者自定义的反垃圾字段， content 必须是 json 格式，长度不超过 5000 字节，格式如下
/// { "type": 1, //1:文本，2：图片，3视频 "data": "" //文本内容or图片地址or视频地址 }
@property(nonatomic,strong,readwrite) NSString *antispamCustomNotification;
@end

NS_ASSUME_NONNULL_END
