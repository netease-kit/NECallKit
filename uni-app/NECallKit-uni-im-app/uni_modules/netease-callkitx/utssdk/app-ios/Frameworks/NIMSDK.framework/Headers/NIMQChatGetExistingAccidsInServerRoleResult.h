//
//  NIMQChatGetExistingAccidsInServerRoleResult.h
//  NIMLib
//
//  Created by Evang on 2022/2/16.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMQChatServerRole;
NS_ASSUME_NONNULL_BEGIN

@interface NIMQChatGetExistingAccidsInServerRoleResult : NSObject

@property (nullable, nonatomic, copy) NSDictionary <NSString *, NSArray <NIMQChatServerRole *> *> *accidServerRolesDic;

@end

NS_ASSUME_NONNULL_END
