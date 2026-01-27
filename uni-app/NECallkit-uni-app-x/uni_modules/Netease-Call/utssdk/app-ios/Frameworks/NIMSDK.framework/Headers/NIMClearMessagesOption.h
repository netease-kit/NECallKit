//
//  NIMClearMessagesOption.h
//  NIMLib
//
//  Created by He on 2019/3/20.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 清空消息选项
 */
@interface NIMClearMessagesOption : NSObject

/**
 *  是否同时删除服务端漫游消息, 默认为 YES
 */
@property   (nonatomic,assign)  BOOL    removeRoam;
@end

NS_ASSUME_NONNULL_END
