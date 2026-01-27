//
//  V2NIMClientAntispamUtil.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class V2NIMClientAntispamResult;

NS_ASSUME_NONNULL_BEGIN

@interface V2NIMClientAntispamUtil : NSObject

/**
 *  对文本消息的文本进行检查，并可能替代
 *
 *  @param message 文本消息
 *  @param shield 屏蔽文本
 *
 *  @return 返回原消息或者nil
 *  @discussion 使用此方法，会对输入的文本消息的文本进行本地反垃圾检查，如果被本地拦截，返回nil。如果需要屏蔽关键字，将使用参数shield中指定的文本进行屏蔽，并修改消息文本。如果需要服务器拦截，会自动进行标记。
 */
+ (V2NIMClientAntispamResult *)checkTextAntispam:(NSString *)text
                                        replace:(nullable NSString *)replace;

@end

NS_ASSUME_NONNULL_END
