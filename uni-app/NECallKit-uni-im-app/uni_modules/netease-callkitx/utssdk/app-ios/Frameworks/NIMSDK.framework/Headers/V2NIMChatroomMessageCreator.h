//
//  V2NIMChatroomMessageCreator.h
//  NIMLib
//
//  Created by Netease on 2023/11/20.
//  Copyright © 2023 Netease. All rights reserved.
//
#import <Foundation/Foundation.h>

@class V2NIMChatroomMessage;

NS_ASSUME_NONNULL_BEGIN

@interface V2NIMChatroomMessageCreator : NSObject
/// 构造文本消息
/// @param text 需要发送的文本内容
+ (V2NIMChatroomMessage *)createTextMessage:(NSString *)text;

/// 创建图片消息
/// @param imagePath 图片文件路径
/// @param name 文件显示名称
/// @param sceneName 场景名 自定义场景使用之前，需要先调用V2NIMStorageService.addCustomStorageScene新增自定义场景值 默认使用DEFAULT_IM对应的场景名
/// @param width 图片文件宽度
/// @param width 图片文件高度
+ (V2NIMChatroomMessage *)createImageMessage:(NSString *)imagePath
                                name:(nullable NSString *)name
                           sceneName:(nullable NSString *)sceneName
                               width:(int)width
                              height:(int)height;

/// 构造语音消息
/// @param audioPath 语音文件地址
/// @param name 语音文件显示名称
/// @param sceneName 场景名 自定义场景使用之前，需要先调用V2NIMStorageService.addCustomStorageScene新增自定义场景值 默认使用DEFAULT_IM对应的场景名
/// @param duration 语音文件播放长度

+ (V2NIMChatroomMessage *)createAudioMessage:(NSString *)audioPath
                                name:(nullable NSString *)name
                           sceneName:(nullable NSString *)sceneName
                            duration:(int)duration;


/// 构造视频消息
/// @param videoPath 视频文件地址 【必填】
/// @param name 视频文件显示名称 【选填】
/// @param sceneName 场景名 自定义场景使用之前，需要先调用V2NIMStorageService.addCustomStorageScene新增自定义场景值 默认使用DEFAULT_IM对应的场景名
/// @param duration 视频文件播放长度 【必填】
/// @param width 视频文件宽度 【选填】
/// @param height 视频文件高度【选填】
///
+ (V2NIMChatroomMessage *)createVideoMessage:(NSString *)videoPath
                                name:(nullable NSString *)name
                           sceneName:(nullable NSString *)sceneName
                            duration:(int)duration
                               width:(int)width
                              height:(int)height;

/// 构造文件消息
/// @param filePath 文件地址 【必填】
/// @param name 文件显示名称 【选填】
/// @param sceneName 场景名 自定义场景使用之前，需要先调用V2NIMStorageService.addCustomStorageScene新增自定义场景值 默认使用DEFAULT_IM对应的场景名
+ (V2NIMChatroomMessage *)createFileMessage:(NSString *)filePath
                               name:(nullable NSString *)name
                          sceneName:(nullable NSString *)sceneName;

/// 构造地理位置消息
/// @param latitude 纬度 【必填】
/// @param longitude 经度 【必填】
/// @param address 详细位置信息 【必填】
+ (V2NIMChatroomMessage *)createLocationMessage:(double)latitude
                              longitude:(double)longitude
                                address:(NSString *)address;

/// 构造自定义消息消息
/// @param text 需要发送的文本内容
/// @param rawAttachment 需要发送的附件
+ (V2NIMChatroomMessage *)createCustomMessage:(NSString *)rawAttachment;


/// 构造转发消息，消息内容与原消息一样
/// 转发消息类型不能为：
///     V2NIM_MESSAGE_TYPE_NOTIFICATION，
///     V2NIM_MESSAGE_TYPE_ROBOT，
///     V2NIM_MESSAGE_TYPE_TIP，
///     V2NIM_MESSAGE_TYPE_AVCHAT
/// 转发的消息消息必须为发送成功的消息
/// @param message 需要转发的消息体
+ (V2NIMChatroomMessage *)createForwardMessage:(V2NIMChatroomMessage *)message;

/// 构造提示消息
/// @param text 提示内容
+ (V2NIMChatroomMessage *)createTipsMessage:(NSString *)text;
@end

NS_ASSUME_NONNULL_END
