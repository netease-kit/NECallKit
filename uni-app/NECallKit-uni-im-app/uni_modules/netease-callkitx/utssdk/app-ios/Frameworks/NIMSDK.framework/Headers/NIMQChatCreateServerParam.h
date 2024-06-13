//
//  NIMQChatCreateServerParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  创建服务器的回调类型
 */
@interface NIMQChatCreateServerParam : NSObject

/**
* 名称
*/
@property (nullable, nonatomic, copy) NSString *name;

/**
 * 图标
 */
@property (nullable, nonatomic, copy) NSString *icon;

/**
 * 自定义扩展
 */
@property (nullable, nonatomic, copy) NSString *custom;

/**
 * 邀请模式：0-邀请需要同意(默认),1-邀请不需要同意
 */
@property (nonatomic, assign) NIMQChatServerInviteMode inviteMode;

/**
 * 申请模式：0-申请不需要同意(默认)，1-申请需要同意
 */
@property (nonatomic, assign) NIMQChatServerApplyMode applyMode;

/**
 * 服务器搜索类型，客户自定义：比如服务器行业类型等,大于0的正整数
 */
@property (nullable, nonatomic, copy) NSNumber *searchType;

/**
 * 服务器是否允许被搜索，默认允许
 */
@property (nonatomic, assign) BOOL searchEnable;

/**
 * 对某些资料内容另外的反垃圾的业务ID
 */
@property (nonatomic, copy)    NSString *antispamBusinessId;

@end


NS_ASSUME_NONNULL_END
