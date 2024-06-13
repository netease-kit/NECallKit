//
//  NIMQChatMessageUpdateContent.h
//  NIMLib
//
//  Created by Evang on 2022/5/26.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatMessage.h"


@class NIMQChatMessage;
NS_ASSUME_NONNULL_BEGIN
/**
 * 消息在上次更新后的内容，当消息曾被更新过/删除过/撤回过时存在。
 */
@interface NIMQChatMessageUpdateContent : NSObject

/**
 *  消息处理状态
 */
@property (nonatomic,assign)  NIMQChatMessageStatus status;

/**
 * 消息更新后的 扩展ext 内容
 */
@property (nonatomic, copy) NSString *remoteExt;

/**
 * 消息更新后的内容
 */
@property (nonatomic, copy) NSString *text;

@end



/**
 * 消息在上次更新后的操作信息
 */
@interface NIMQChatMessageUpdateOperatorInfo : NSObject

/**
 * 操作者账号
 */
@property(nullable, nonatomic, copy)  NSString *operatorAccid;

/**
 *  操作者客户端类型
 */
@property(nonatomic, assign) NIMLoginClientType operatorClientType;

/**
 * 操作附言
 */
@property(nullable, nonatomic, copy) NSString *postscript;

/**
 * 操作扩展字段
 */
@property(nullable, nonatomic, copy) NSString *extension;

/**
 * 推送文案
 */
@property(nullable, nonatomic, copy) NSString *pushContent;

/**
 * 推送payload
 */
@property(nullable, nonatomic, copy) NSString *pushPayload;


@end
NS_ASSUME_NONNULL_END
