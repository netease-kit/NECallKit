
//
//  NIMQChatGetExistingChannelBlackWhiteMembersResult.h
//  NIMLib
//
//  Created by Evang on 2022/2/16.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMQChatServerMember;
NS_ASSUME_NONNULL_BEGIN

@interface NIMQChatGetExistingChannelBlackWhiteMembersResult : NSObject

@property (nullable, nonatomic, copy) NSArray <NIMQChatServerMember *> *memberArray;

@end

NS_ASSUME_NONNULL_END

