//
//  NIMQChatRTCChannelManagerProtocol.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN


@class NIMQChatRTCChannelInfo;
@class NIMQChatRTCChannelOnlineMember;
@class NIMQChatChannelIdInfo;
@class NIMQChatRTCUpdateChannelInfoParam;
@class NIMQChatRequestTokenResult;
/**
 *  获取token的结果回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatRequestRTCTokenHandler)(NSError *__nullable error, NIMQChatRequestTokenResult *__nullable result);

/**
 *  获取多媒体频道信息的结果回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetRTCChannelHandler)(NSError *__nullable error, NIMQChatRTCChannelInfo *__nullable result);

/**
 *  获取多媒体频道在线成员的结果回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetRTCChannelOnlineMembersHandler)(NSError *__nullable error, NSArray <NIMQChatRTCChannelOnlineMember *> *__nullable result);


/**
 *  圈组频道管理器
 */
@protocol NIMQChatRTCChannelManager <NSObject>

/**
 *  获取token
 *
 * @param deviceId id
 * @param completion 结果回调
 */
- (void)requestTokenWithDeviceId:(NSString *)deviceId completion:(nullable NIMQChatRequestRTCTokenHandler)completion;

/**
 * 修改圈组多频道信息
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)updateRTCChannel:(nonnull NIMQChatRTCUpdateChannelInfoParam *)param
           completion:(nullable NIMQChatHandler)completion;

/**
 * 获取多媒体频道信息
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getRTCChannelInfo:(nonnull NIMQChatChannelIdInfo *)param
           completion:(nullable NIMQChatGetRTCChannelHandler)completion;

/**
 * 查询多媒体频道在线成员信息
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getRTCChannelOnlineMembers:(nonnull NIMQChatChannelIdInfo *)param
         completion:(nullable NIMQChatGetRTCChannelOnlineMembersHandler)completion;
@end

NS_ASSUME_NONNULL_END
