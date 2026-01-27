//
//  NIMAddStickTopSessionParams.h
//  NIMLib
//
//  Created by 丁文超 on 2020/4/1.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface NIMAddStickTopSessionParams : NSObject

/**
 * 会话
 */
@property (nonatomic, copy) NIMSession *session;

/**
 * 扩展信息，最大512字符
 */
@property (nonatomic, copy) NSString *ext;

/**
 * 初始化置顶信息
 * @param session 需要置顶的会话
 * @return 置顶信息对象
 */
- (instancetype)initWithSession:(NIMSession *)session;

@end

NS_ASSUME_NONNULL_END
