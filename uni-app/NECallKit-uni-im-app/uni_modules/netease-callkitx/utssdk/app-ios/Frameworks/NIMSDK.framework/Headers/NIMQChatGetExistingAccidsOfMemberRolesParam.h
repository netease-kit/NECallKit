
//
//  NIMQChatGetExistingAccidsOfMemberRolesParam.h
//  NIMSDK
//
//  Created by Evang on 2022/2/15.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 *  
 */
@interface NIMQChatGetExistingAccidsOfMemberRolesParam : NSObject

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;

/**
 * 频道id
 */
@property (nonatomic, assign) unsigned long long  channelId;

/**
 * 用户accid数组
 */
@property (nonatomic, copy) NSArray <NSString *> *accids;

@end

NS_ASSUME_NONNULL_END

