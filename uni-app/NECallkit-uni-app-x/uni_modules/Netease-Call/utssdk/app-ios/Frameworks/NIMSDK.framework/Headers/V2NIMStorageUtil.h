//
//  V2NIMStorageUtil.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2024 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 存储相关帮助类
@interface V2NIMStorageUtil : NSObject

/**
 *  生成图片缩略链接
 *
 *  @param url 图片原始链接
 *  @param thumbSize 缩放的尺寸
 *  @return 返回图片缩略链接
 *  @discussion
 */
+ (NSString *)imageThumbUrl:(NSString *)url
                  thumbSize:(NSInteger)thumbSize;

/**
 *  生成视频封面图链接
 *
 *  @param url 视频原始链接
 *  @param offset 从第几秒开始截
 *  @return 返回生成视频封面图链接
 *  @discussion
 */
+ (NSString *)videoCoverUrl:(NSString *)url
                     offset:(NSInteger)offset;

@end

NS_ASSUME_NONNULL_END
