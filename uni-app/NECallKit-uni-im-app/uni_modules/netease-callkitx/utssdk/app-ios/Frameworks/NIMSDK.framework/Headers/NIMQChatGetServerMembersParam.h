//
//  NIMQChatGetServerMembersParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN
@interface NIMQChatGetServerMemberItem: NSObject
/**
 *  服务器id
 */
@property (nonatomic, assign) unsigned long long serverId;
/**
 *  成员账号id
 */
@property (nonatomic, copy) NSString *accid;

@end


/**
 *  获取服务器成员
 */
@interface NIMQChatGetServerMembersParam : NSObject

/**
 * NIMQChatGetServerMemberItem列表
 */
@property (nonatomic, copy) NSArray <NIMQChatGetServerMemberItem *> *serverAccids;

@end


NS_ASSUME_NONNULL_END
