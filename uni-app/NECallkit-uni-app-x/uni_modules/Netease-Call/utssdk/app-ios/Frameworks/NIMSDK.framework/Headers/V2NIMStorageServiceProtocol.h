//
//  V2NIMStorageServiceProtocol.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2024 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "V2NIMBase.h"

@class V2NIMStorageScene;
@class V2NIMUploadFileParams;
@class V2NIMUploadFileTask;
@class V2NIMMessageAttachment;
@class V2NIMSize;
@class V2NIMDownloadMessageAttachmentParams;
@class V2NIMGetMediaResourceInfoResult;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, V2NIMDownloadAttachmentType) {
    V2NIM_DOWNLOAD_ATTACHMENT_TYPE_SOURCE           = 0,  ///< 原始资源，支持全部有附件的类型
    V2NIM_DOWNLOAD_ATTACHMENT_TYPE_THUMBNAIL        = 1,  ///< 图片缩略图，仅支持图片类附件
    V2NIM_DOWNLOAD_ATTACHMENT_TYPE_VIDEO_COVER      = 2,  ///< 视频封面，仅支持视频类附件
};

/**
 *  上传成功回调
 *
 *  @param urlString 上传后得到的URL
 */
typedef void(^V2NIMFileUploadSuccess)(NSString *urlString);

/**
 *  上传失败回调
 *
 *  @param error 上传失败信息
 */
typedef void(^V2NIMFileUploadFailure)(V2NIMError *error);

/**
 *  上传/下载进度
 *
 *  @param progress 进度 0%-100%
 */
typedef void(^V2NIMFileUploadProgress)(float progress);

/**
 *  下载成功回调
 *
 *  @param filePath 文件路径
 */
typedef void(^V2NIMFileDownloadSuccess)(NSString *filePath);

/**
 * 短链接转长链接成功回调
 *
 * @param url 可直接使用的链接，比短链长，对比之下称为长链
 */
typedef void(^V2NIMShortUrlToLongSuccess)(NSString *url);

/**
 * 下载消息附件成功回调
 *
 *  @param filePath 文件路径
 */
typedef void(^V2NIMDownloadAttachmentSuccess)(NSString *filePath);

/**
 * 获取图片消息中的图片缩略图成功回调
 *
 * @param result 获取图片缩略结果
 */
typedef void(^V2NIMGetImageThumbUrlSuccess)(V2NIMGetMediaResourceInfoResult *result);

/**
 * 获取视频消息中的视频封面成功回调
 *
 * @param result 获取视频封面结果
 */
typedef void(^V2NIMGetVideoCoverUrlSuccess)(V2NIMGetMediaResourceInfoResult *result);

/// 存储服务协议
@protocol V2NIMStorageService <NSObject>

/**
 *  添加自定义存储场景
 *
 *  @param sceneName 场景名
 *  @param expireTime 过期时间， 单位秒
 */
- (void)addCustomStorageScene:(NSString *)sceneName 
                   expireTime:(NSUInteger)expireTime;

/**
 *  创建文件上传任务
 *
 *  @param fileParams 文件上传的相关参数
 *
 *  @return 返回任务
 */
- (V2NIMUploadFileTask *)createUploadFileTask:(V2NIMUploadFileParams *)fileParams;

/*
 *  文件上传
 *  @param fileTask 文件上传的任务
 *  @param success 上传成功回调
 *  @param failure 上传失败回调
 *  @param progress 件上传进度回调
 */
- (void)uploadFile:(V2NIMUploadFileTask *)fileTask
           success:(V2NIMFileUploadSuccess)success
           failure:(V2NIMFileUploadFailure)failure
          progress:(V2NIMFileUploadProgress)progress;

/*
 *  取消文件上传
 *  @param fileTask 文件上传的任务
 *  @param success 取消上传成功回调
 *  @param failure 取消上传失败回调
 */
- (void)cancelUploadFile:(V2NIMUploadFileTask *)fileTask
                 success:(V2NIMSuccessCallback)success
                 failure:(V2NIMFailureCallback)failure;

/*
 *  查询存储场景列表
 
 *  @return 返回存储场景列表
 */
- (NSArray<V2NIMStorageScene *> *)getStorageSceneList;

/**
 *  短链接转长链接
 *
 *  @param url 短链
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)shortUrlToLong:(NSString *)url
               success:(V2NIMShortUrlToLongSuccess)success
               failure:(V2NIMFailureCallback)failure;

/**
 * 文件下载接口，可以下载指定连接对应的文件地址
 *
 * @param url 文件远程地址
 * @param filePath 文件存储地址
 * @param success 下载成功的回调
 * @param failure 下载失败的回调
 * @param progress 文件下载进度回调
 */
- (void)downloadFile:(NSString *)url
            filePath:(NSString *)filePath
             success:(V2NIMFileDownloadSuccess)success
             failure:(V2NIMFailureCallback)failure
            progress:(nullable V2NIMProgressCallback)progress;

/**
 * 下载消息附件
 *
 * @param downloadParam 下载参数
 * @param success 下载消息附件成功回调
 * @param failure 下载消息附件失败回调
 * @param progress 下载消息附件进度回调
 */
- (void)downloadAttachment:(V2NIMDownloadMessageAttachmentParams *)downloadParam
                   success:(V2NIMDownloadAttachmentSuccess)success
                   failure:(V2NIMFailureCallback)failure
                  progress:(nullable V2NIMProgressCallback)progress;

/**
 * 获取图片消息中的图片缩略图
 * 传入短链自动获取长链地址并携带缩略图相关 URL 查询参数
 * 旧的下载地址会做新的 CDN 加速域名地址替换
 * 开启自定义鉴权会返回对应的鉴权信息
 *
 * @param attachment 消息附件
 * @param thumbSize  缩略图尺寸
 * @param success    成功回调
 * @param failure    失败回调
 * @see V2NIMGetMediaResourceInfoResult
 */
- (void)getImageThumbUrl:(V2NIMMessageAttachment *)attachment
               thumbSize:(V2NIMSize *)thumbSize
                 success:(V2NIMGetImageThumbUrlSuccess)success
                 failure:(V2NIMFailureCallback)failure;

/**
 * 获取视频消息中的视频封面
 * 传入短链自动获取长链地址并携带视频封面相关 URL 查询参数
 * 旧的下载地址会做新的 CDN 加速域名地址替换
 * 开启自定义鉴权会返回对应的鉴权信息
 *
 * @param attachment 消息附件
 * @param thumbSize  缩略图尺寸
 * @param success    成功回调
 * @param failure    失败回调
 * @see V2NIMGetMediaResourceInfoResult
 */
- (void)getVideoCoverUrl:(V2NIMMessageAttachment *)attachment
               thumbSize:(V2NIMSize *)thumbSize
                 success:(V2NIMGetVideoCoverUrlSuccess)success
                 failure:(V2NIMFailureCallback)failure;

@end

/// 文件存储场景
@interface V2NIMStorageScene : NSObject

/// 场景名
@property (nullable,nonatomic,strong) NSString *sceneName;

/// 过期时间， 单位秒
/// 0表示永远不过期,否则以该时间为过期时间
@property (nonatomic,assign) NSUInteger expireTime;

@end

/// 文件存储场景配置
@interface V2NIMStorageSceneConfig : NSObject

/// 默认头像类型等场景, 默认不过期
+ (V2NIMStorageScene *)DEFAULT_PROFILE;

/// 默认文件类型等场景, 默认不过期
+ (V2NIMStorageScene *)DEFAULT_IM;

/// 默认日志类型等场景, 默认不过期
+ (V2NIMStorageScene *)DEFAULT_SYSTEM;

/// 安全链接，每次大家需要密钥才能查看,默认不过期
+ (V2NIMStorageScene *)SECURITY_LINK;

@end

/// 文件上传任务
@interface V2NIMUploadFileTask : NSObject

/// 任务id
@property (nonatomic,strong) NSString *taskId;

/// 上传参数
@property (nonatomic,strong) V2NIMUploadFileParams *uploadParams;

@end

/// 文件上传参数
@interface V2NIMUploadFileParams : NSObject

/// 文件路径
@property (nonatomic,strong) NSString *filePath;

/// 场景名
@property (nonatomic,strong) NSString *sceneName;

@end

NS_ASSUME_NONNULL_END
