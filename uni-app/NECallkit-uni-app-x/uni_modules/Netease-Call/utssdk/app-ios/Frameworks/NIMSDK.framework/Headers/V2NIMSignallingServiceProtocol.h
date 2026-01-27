//
//  V2NIMSignallingServiceProtocol.h
//  NIMLib
//
//  Created by Netease on 2024/5/21.
//  Copyright © 2024 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "V2NIMBase.h"
#import "V2NIMSignallingRequest.h"

@protocol V2NIMSignallingListener;
@class V2NIMSignallingEvent;
@class V2NIMSignallingRoomInfo;
@class V2NIMSignallingCallParams;
@class V2NIMSignallingCallResult;
@class V2NIMSignallingCallSetupParams;
@class V2NIMSignallingCallSetupResult;

NS_ASSUME_NONNULL_BEGIN

typedef void (^V2NIMSignallingCallSuccess)(V2NIMSignallingCallResult *result);
typedef void (^V2NIMSignallingCallSetupSuccess)(V2NIMSignallingCallSetupResult *result);
typedef void (^V2NIMSignallingCreateRoomSuccess)(V2NIMSignallingChannelInfo *channelInfo);
typedef void (^V2NIMSignallingJoinRoomSuccess)(V2NIMSignallingJoinResult *result);
typedef void (^V2NIMSignallingGetRoomInfoByChannelNameSuccess)(V2NIMSignallingRoomInfo *result);

@protocol V2NIMSignallingService <NSObject>
/**
 * 直接呼叫对方加入房间
 * 信令正常流程：
 *  创建房间（createRoom），
 *  自己加入房间（join）
 *  邀请对方加入房间（invite）
 *  上述的房间是信令的房间，不是音视频的房间，因此需要三次向服务器交互才能建立相关流程
 * call接口同时实现了上诉三个接口的功能， 可以加速呼叫流程， 如果你需要精确控制每一步，则需要调用上述每一个接口
 *
 * @param param 呼叫参数
 * @param success 呼叫成功回调
 * @param failure 呼叫失败回调
 */
- (void)call:(V2NIMSignallingCallParams*)param
     success:(V2NIMSignallingCallSuccess)success
     failure:(V2NIMFailureCallback)failure;
/**
 * 呼叫建立， 包括加入信令频道房间， 同时接受对方呼叫
 *  组合接口（join+accept）
 *  如果需要详细处理每一步骤， 则可以单独调用join接口，之后再调用accept接口
 *
 *  @param param 接受呼叫参数
 *  @param success 接受成功回调
 *  @param failure 接受失败回调
 */
- (void)callSetup:(V2NIMSignallingCallSetupParams*)param
          success:(V2NIMSignallingCallSetupSuccess)success
          failure:(V2NIMFailureCallback)failure;

/**
 * 创建信令房间
 *  频道与房间一一对应， 可以理解为同一个东西
 *  相同的频道名，在服务器同时只能存在一个
 * @param channelType 频道类型。房间创建后跟频道类型绑定；必须为枚举类型之一， 否则返回参数错误
 * @param channelName 频道名称， 建议使用与业务有相关场景的名称，便于页面显示
 * @param channelExtension 频道相关扩展字段， 长度限制4096， 跟频道绑定。json格式
 * @param success 创建成功的回调
 * @param failure 创建失败的回调
 */
- (void)createRoom:(V2NIMSignallingChannelType)channelType
       channelName:(nullable NSString *)channelName
  channelExtension:(nullable NSString *)channelExtension
           success:(V2NIMSignallingCreateRoomSuccess)success
           failure:(V2NIMFailureCallback)failure;

/**
 * 关闭信令房间接口
 *  该接口调用后会触发关闭通知给房间内所有人
 *  房间内的所有人均可以调用该接口
 * @param channelId 频道ID。房间的唯一标识
 * @param offlineEnabled 是否需要存离线消息。YES：需要；NO：不需要。如果存离线，则用户离线再上线会收到该通知
 * @param serverExtension 服务端扩展字段， 长度限制4096
 * @param success 成功的回调
 * @param failure 失败的回调
 */
- (void)closeRoom:(NSString *)channelId
   offlineEnabled:(BOOL)offlineEnabled
  serverExtension:(nullable NSString *)serverExtension
          success:(V2NIMSuccessCallback)success
          failure:(V2NIMFailureCallback)failure;

/**
 * 加入信令房间接口
 *  该接口调用后会触发加入通知给房间内所有人
 * @param param 加入信令房间相关参数
 * @param success 成功的回调
 * @param failure 失败的回调
 */
- (void)joinRoom:(V2NIMSignallingJoinParams *)param
         success:(V2NIMSignallingJoinRoomSuccess)success
         failure:(V2NIMFailureCallback)failure;

/**
 * 离开信令房间接口
 *  该接口调用后会触发离开通知给房间内所有人
 * @param channelId 频道ID。房间的唯一标识
 * @param offlineEnabled 是否需要存离线消息。YES：需要；NO：不需要。如果存离线，则用户离线再上线会收到该通知
 * @param serverExtension 服务端扩展字段， 长度限制4096
 * @param success 成功的回调
 * @param failure 失败的回调
 */
- (void)leaveRoom:(NSString *)channelId
   offlineEnabled:(BOOL)offlineEnabled
  serverExtension:(nullable NSString *)serverExtension
          success:(V2NIMSuccessCallback)success
          failure:(V2NIMFailureCallback)failure;

/**
 * 邀请成员加入信令房间接口
 *  该接口调用后会触发邀请通知给对方， 发送方可以配置是否需要发送推送
 *      默认不推送
 *      如果不配置推送相关信息， 则服务器回填默认内容
 *          音频： xx邀请你进行语音通话
 *          视频：xx邀请你进行视频通话
 *          其它： xx邀请你进行音视频通话
 *  房间内的人均可以发送邀请
 * @param param 邀请成员加入信令房间接口参数
 * @param success 成功的回调
 * @param failure 失败的回调
 */
- (void)invite:(V2NIMSignallingInviteParams *)param
       success:(V2NIMSuccessCallback)success
       failure:(V2NIMFailureCallback)failure;

/**
 * 取消之前的邀请成员加入信令房间接口
 *  该接口调用后会触发取消邀请通知给对方
 * @param param 取消之前的邀请成员加入信令房间接口参数
 * @param success 成功的回调
 * @param failure 失败的回调
 */
- (void)cancelInvite:(V2NIMSignallingCancelInviteParams*)param
             success:(V2NIMSuccessCallback)success
             failure:(V2NIMFailureCallback)failure;

/**
 * 拒绝别人的邀请加入信令房间请求
 *  该接口调用后会触发拒绝邀请通知给对方
 * @param param 拒绝邀请加入信令房间接口参数
 * @param success 成功的回调
 * @param failure 失败的回调
 */
- (void)rejectInvite:(V2NIMSignallingRejectInviteParams*)param
             success:(V2NIMSuccessCallback)success
             failure:(V2NIMFailureCallback)failure;


/**
 * 接受别人的邀请加入信令房间请求。该接口调用后会触发接受邀请通知给对方
 * @param param 接受邀请加入信令房间接口参数
 * @param success 成功的回调
 * @param failure 失败的回调
 */
- (void)acceptInvite:(V2NIMSignallingAcceptInviteParams*)param
             success:(V2NIMSuccessCallback)success
             failure:(V2NIMFailureCallback)failure;

/**
 * 发送自定义控制指令，可以实现自定义相关的业务逻辑
 * 可以发送给指定用户， 如果不指定， 则发送给信令房间内的所有人
 * 该接口不做成员校验， 允许非频道房间内的成员调用， 但是接受者必须在频道房间内或者是创建者
 * 接口调用后会发送一个控制通知
 *  如果指定了接受者： 则通知发送给接受者
 *  如果未指定接受者：则发送给房间内的所有人
 *  通知仅发在线
 * @param channelId 频道ID。房间的唯一标识
 * @param receiverAccountId 接受者ID， 如果该字段为空， 则表示发送给房间内的所有人
 * @param serverExtension 服务端扩展字段， 长度限制4096。自定义控制数据；建议json格式
 * @param success 成功的回调
 * @param failure 失败的回调
 */
- (void)sendControl:(NSString *)channelId
  receiverAccountId:(nullable NSString *)receiverAccountId
    serverExtension:(nullable NSString *)serverExtension
            success:(V2NIMSuccessCallback)success
            failure:(V2NIMFailureCallback)failure;

/**
 * 根据频道名称查询频道房间信息
 * 相同的频道名，在服务器同时只能存在一个
 * @param channelName 频道名称，为空返回参数错误
 * @param success 成功的回调
 * @param failure 失败的回调
 */
- (void)getRoomInfoByChannelName:(NSString *)channelName
                         success:(V2NIMSignallingGetRoomInfoByChannelNameSuccess)success
                         failure:(V2NIMFailureCallback)failure;

/**
 * 添加信令监听器
 * @param listener 信令监听回调
 */
- (void)addSignallingListener:(id<V2NIMSignallingListener>)listener;
/**
 * 移除信令监听器
 * @param listener 信令监听回调
 */
- (void)removeSignallingListener:(id<V2NIMSignallingListener>)listener;
@end

@protocol V2NIMSignallingListener <NSObject>
@optional
/**
 * 在线事件回调
 * @param event 在线状态事件回调，包括以下状态：关闭房间、加入房间、离开房间、邀请加入房间、取消邀请加入房间、拒绝加入邀请、接受加入邀请、控制事件
 */
- (void)onOnlineEvent:(V2NIMSignallingEvent *)event;

/**
 * 离线事件回调
 * @param event 离线状态事件回调，包括以下状态：关闭房间、加入房间、离开房间、邀请加入房间、取消邀请加入房间、拒绝加入邀请、接受加入邀请、控制事件
 */
- (void)onOfflineEvent:(NSArray<V2NIMSignallingEvent *> *)event;

/**
 * 多端事件操作同步回调
 * @param event 多端事件操作回调，包括以下状态：拒绝加入邀请、接受加入邀请
 */
- (void)onMultiClientEvent:(V2NIMSignallingEvent *)event;

/**
 * 登录后，同步还在的信令频道房间列表
 * @param channelRooms 用户登录SDK后，同步获取当前未退出的信令频道列表
 */
- (void)onSyncRoomInfoList:(NSArray<V2NIMSignallingRoomInfo *> *)channelRooms;


@end

NS_ASSUME_NONNULL_END
