//
//  NIMResourceExtraInfo.h
//  NIMLib
//
//  Created by He on 2019/9/4.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  资源辅助信息
 */

@interface NIMResourceExtraInfo :  NSObject

/**
 * MIME类型
 */
@property (nonatomic,copy,nullable) NSString *mime;

/**
 *  资源对应场景
 */
@property (nonatomic,copy,null_resettable) NSString *scene;

/**
 *  资源文件MD5值
 */
@property (nonatomic,copy,nullable) NSString *md5;

/**
 *  聊天室Id，通常在独立聊天室的资源文件时候使用
 */
@property (nonatomic,copy,nullable) NSString *roomId;

@end

NS_ASSUME_NONNULL_END
