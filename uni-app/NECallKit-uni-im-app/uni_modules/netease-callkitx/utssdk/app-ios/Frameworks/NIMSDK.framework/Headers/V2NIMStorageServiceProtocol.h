//
//  V2NIMStorageServiceProtocol.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "V2NIMBase.h"

@class V2NIMStorageScene;
@class V2NIMUploadFileParams;
@class V2NIMUploadFileTask;

NS_ASSUME_NONNULL_BEGIN
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

/// 登录协议
@protocol V2NIMStorageService <NSObject>
/**
 *  添加自定义存储场景
 *
 *  @param sceneName 场景名
 *  @param expireTime 过期时间， 单位秒
 */
- (void)addCustomStorageScene:(NSString *)sceneName expireTime:(NSUInteger)expireTime;
/**
 *  创建文件上传任务
 *
 *  @param fileParams 文件上传的相关参数
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
 */
- (NSArray<V2NIMStorageScene *> *)getStorageSceneList;

@end
/// 文件存储场景
@interface V2NIMStorageScene : NSObject
/// 场景名
@property (nullable,nonatomic,strong) NSString *sceneName;
/// 过期时间， 单位秒
/// 0表示永远不过期,否则以该时间为过期时间
@property (nonatomic,assign) NSUInteger expireTime;

@end

/// 文件存储场景
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

/// 文件存储场景
@interface V2NIMUploadFileTask : NSObject
/// 场景名
@property (nonatomic,strong) NSString *taskId;
/// 过期时间， 单位秒
/// 0表示永远不过期,否则以该时间为过期时间
@property (nonatomic,strong) V2NIMUploadFileParams *uploadParams;

@end

@interface V2NIMUploadFileParams : NSObject
/// 文件地址
@property (nonatomic,strong) NSString *filePath;
/// 场景名
@property (nonatomic,strong) NSString *sceneName;

@end

NS_ASSUME_NONNULL_END
