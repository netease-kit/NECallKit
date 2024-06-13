//
//  NIMQChatUpdateMessageInfo.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NIMQChatMessageAntispamSetting;
/**
 * 更新内容
 */
@interface NIMQChatUpdateMessageInfo : NSObject

/**
 * 消息状态
 * @discussion 选填，仅允许设置状态值大于NIMQChatMessageStatusCustom
 */
@property(nonatomic, assign)           NSInteger status;

/**
 *  消息文本
 *  @discussion 选填
 */
@property(nullable, nonatomic, copy)   NSString *text;

/**
 *  服务器扩展
 *  @discussion 选填，上层需要保证 NSDictionary 可以转换为 JSON
 */
@property(nullable, nonatomic, copy)   NSDictionary *remoteExt;

/**
 *  反垃圾设置
 *  @discussion 选填
 */
@property (nullable, nonatomic, copy) NIMQChatMessageAntispamSetting *antispamSetting;

/**
 *  消息子类型
 *  @discussion 选填
 */
@property (nullable, nonatomic, copy) NSNumber *subType;

@end

NS_ASSUME_NONNULL_END
