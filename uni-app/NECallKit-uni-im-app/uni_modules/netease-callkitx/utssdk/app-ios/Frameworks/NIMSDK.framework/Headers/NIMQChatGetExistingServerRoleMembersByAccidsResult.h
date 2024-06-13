
//
//  NIMQChatGetExistingServerRoleMembersByAccidsResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NIMQChatServerRoleMember;

/**
 *  查询一批accids是否在某个服务器身份组的结果
 */
@interface NIMQChatGetExistingServerRoleMembersByAccidsResult : NSObject
/**
 *  存在的accid列表
 */
@property (nonatomic, copy) NSArray <NSString *> *accidArray;

@end

NS_ASSUME_NONNULL_END


