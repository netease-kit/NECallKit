
//
//  NIMQChatGetExistingChannelRolesByServerRoleIdsResult.h
//  NIMLib
//
//  Created by Evang on 2022/2/16.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMQChatChannelRole;
NS_ASSUME_NONNULL_BEGIN

@interface NIMQChatGetExistingChannelRolesByServerRoleIdsResult : NSObject

@property (nullable, nonatomic, copy) NSArray <NIMQChatChannelRole *> *channelRoleArray;

@end

NS_ASSUME_NONNULL_END
