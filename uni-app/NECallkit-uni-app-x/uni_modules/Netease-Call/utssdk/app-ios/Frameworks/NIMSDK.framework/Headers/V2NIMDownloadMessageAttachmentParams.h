//
//  V2NIMDownloadMessageAttachmentParams.h
//  NIMSDK
//
//  Created by 陈吉力 on 2024/6/12.
//  Copyright © 2024 Netease. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "V2NIMMessageAttachment.h"
#import "V2NIMStorageServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@interface V2NIMDownloadMessageAttachmentParams : NSObject
/**
 * 要下载的附件
 */
@property (nonatomic,strong,nonnull) V2NIMMessageAttachment *attachment;
/**
 * 下载附件的类型，如原始文件、缩略图、视频封面
 */
@property (nonatomic,assign) V2NIMDownloadAttachmentType type;
/**
 * 缩略图大小或视频封面大小
 * 如果下载的是缩略图或者视频封面，通过该参数指定缩略图大小或视频封面大小
 */
@property (nonatomic,strong,nullable) V2NIMSize *thumbSize;
/**
 * 消息的端侧ID
 * 可选参数，如果指定了该参数将下载完成后的本地附件保存路径更新到消息数据库中，下一次查询时将直接返回对应的路径
 */
@property (nonatomic,copy,nullable) NSString *messageClientId;
/**
 * 附件保存路径，如未指定 SDK 将下载到登录用户缓存目录，如指定该参数则以指定的路径为准
 */
@property (nonatomic,copy,nullable) NSString *saveAs;

- (instancetype)initWithAttachment:(V2NIMMessageAttachment *)attachment;
@end
NS_ASSUME_NONNULL_END
