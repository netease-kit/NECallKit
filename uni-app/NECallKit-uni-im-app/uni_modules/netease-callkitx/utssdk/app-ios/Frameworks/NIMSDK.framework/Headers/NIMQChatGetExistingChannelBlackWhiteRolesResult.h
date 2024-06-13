
//
//  NIMQChatGetExistingChannelBlackWhiteRolesResult.h
//  NIMLib
//
//  Created by Evang on 2022/2/16.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMQChatServerRole;
NS_ASSUME_NONNULL_BEGIN

@interface NIMQChatGetExistingChannelBlackWhiteRolesResult : NSObject

@property (nullable, nonatomic, copy) NSArray <NIMQChatServerRole *> *serverRoleArray;

@end

NS_ASSUME_NONNULL_END

