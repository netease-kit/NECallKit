//
//  NIMQChatGetServersParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  查询服务器信息的参数
 */
@interface NIMQChatGetServersParam : NSObject
@property (nonnull, nonatomic, copy) NSArray * serverIds;
@end


NS_ASSUME_NONNULL_END
