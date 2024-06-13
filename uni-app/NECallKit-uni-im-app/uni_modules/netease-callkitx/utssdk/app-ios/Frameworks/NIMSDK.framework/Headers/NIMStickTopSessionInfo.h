//
//  NIMStickTopSessionInfo.h
//  NIMSDK
//
//  Created by 丁文超 on 2020/4/1.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMSession.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 置顶信息
 */
@interface NIMStickTopSessionInfo : NSObject

/**
 * 对应的会话
 */
@property (nonatomic, copy) NIMSession *session;

/**
 * 扩展字段，最大512字符
 */
@property (nonatomic, copy, nullable) NSString *ext;

/**
 * 创建时间(s)
 */
@property (nonatomic, assign) NSTimeInterval createTime;

/**
 * 更新时间(s)
 */
@property (nonatomic, assign) NSTimeInterval updateTime;

@end


NS_ASSUME_NONNULL_END
