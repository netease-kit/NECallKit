//
//  NIMSessionDeleteAllRemoteMessagesOptions.h
//  NIMLib
//
//  Created by Wenchao Ding on 2020/8/25.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NIMSessionDeleteAllRemoteMessagesOptions : NSObject

/**
 * 是否同时清空其他登录设备，默认为NO
 */
@property (nonatomic,assign)  BOOL removeOtherClients;

/**
 * 扩展字段
 */
@property (nonatomic,copy) NSString *ext;

@end

NS_ASSUME_NONNULL_END
