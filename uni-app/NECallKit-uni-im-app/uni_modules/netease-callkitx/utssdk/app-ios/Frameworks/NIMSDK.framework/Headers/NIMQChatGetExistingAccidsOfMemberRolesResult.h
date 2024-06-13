
//
//  NIMQChatGetExistingAccidsOfMemberRolesResult.h
//  NIMLib
//
//  Created by Evang on 2022/2/16.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMQChatMemberRole;
NS_ASSUME_NONNULL_BEGIN

@interface NIMQChatGetExistingAccidsOfMemberRolesResult : NSObject

/**
 *  存在的账号accid列表
 */
@property (nullable, nonatomic, copy) NSArray <NSString *> *accidArray;

@end

NS_ASSUME_NONNULL_END
