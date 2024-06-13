//
//  NIMQChatAddServerRoleMembersResult.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NIMQChatAddServerRoleMembersResult : NSObject

/**
 * 加入成功的accids
 */
@property (nonatomic, copy) NSArray <NSString *> *successfulAccidArray;
/**
 * 加入失败的accids
 */
@property (nonatomic, copy) NSArray <NSString *> *failedAccidArray;

@end

NS_ASSUME_NONNULL_END
