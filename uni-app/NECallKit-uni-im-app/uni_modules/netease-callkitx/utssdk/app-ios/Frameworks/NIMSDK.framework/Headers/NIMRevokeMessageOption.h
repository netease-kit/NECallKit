//
//  NIMRevokeMessageOption.h
//  NIMSDK
//
//  Created by Genning on 2020/8/25.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NIMRevokeMessageOption : NSObject

/**
*  云信推送内容,长度限制500字
*/
@property (nullable, nonatomic, copy) NSString *apnsContent;

/**
*  云信推送payload信息,长度限制 2K
*/
@property (nullable, nonatomic, strong) NSDictionary *apnsPayload;

/**
*  是否计入未读数。默认：YES
*/
@property (nonatomic, assign) BOOL shouldBeCounted;

/**
 * 撤回的附言
 */
@property(nullable, nonatomic, copy) NSString *postscript;


/**
 * 撤回消息的扩展,撤回方填充
 */
@property(nullable, nonatomic, copy) NSString *attach;

@end

NS_ASSUME_NONNULL_END
