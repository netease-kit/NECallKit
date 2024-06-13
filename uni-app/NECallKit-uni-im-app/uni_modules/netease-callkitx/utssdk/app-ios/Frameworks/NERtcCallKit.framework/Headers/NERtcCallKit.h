// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import "NECallEngine.h"
#import "NECallEngineConsts.h"
#import "NEGroupCallKit.h"
#import "NERtcCallKitConsts.h"
#import "NERtcCallKitContext.h"
#import "NERtcCallKitJoinChannelEvent.h"
#import "NERtcCallKitPushConfig.h"
#import "NERtcCallOptions.h"
// #import "NERtcCallKitDelegate.h"

//! Project version number for NERtcCallKit.
// FOUNDATION_EXPORT double NERtcCallKitVersionNumber;

//! Project version string for NERtcCallKit.
// FOUNDATION_EXPORT const unsigned char NERtcCallKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like
// #import <NERtcCallKit/PublicHeader.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^NERtcCallKitRecordMessageHander)(NIMMessage *message);

@protocol NERtcCallKitDelegate <NSObject>

@optional

/// 收到邀请的回调
/// @param invitor 邀请方
/// @param userIDs 房间中的被邀请的所有人（不包含邀请者）
/// @param isFromGroup 是否是群组
/// @param groupID 群组ID
/// @param type 通话类型
- (void)onInvited:(NSString *)invitor
          userIDs:(NSArray<NSString *> *)userIDs
      isFromGroup:(BOOL)isFromGroup
          groupID:(nullable NSString *)groupID
             type:(NERtcCallType)type
    NERtcCallKitDeprecate("use -onInvited:userIDs:isFromGroup:groupID:type:attachment: instead");

/// 收到邀请的回调
/// @param invitor 邀请方
/// @param userIDs 房间中的被邀请的所有人（不包含邀请者）
/// @param isFromGroup 是否是群组
/// @param groupID 群组ID
/// @param type 通话类型
- (void)onInvited:(NSString *)invitor
          userIDs:(NSArray<NSString *> *)userIDs
      isFromGroup:(BOOL)isFromGroup
          groupID:(nullable NSString *)groupID
             type:(NERtcCallType)type
       attachment:(nullable NSString *)attachment;

/// 接受邀请的回调
/// @param userID 接受者
- (void)onUserEnter:(NSString *)userID;

/// 拒绝邀请的回调
/// @param userID 拒绝者
- (void)onUserReject:(NSString *)userID;

/// 取消邀请的回调
/// @param userID 邀请方
- (void)onUserCancel:(NSString *)userID;

/// 用户离开的回调.
/// @param userID 用户userID
- (void)onUserLeave:(NSString *)userID;

/// 用户异常离开的回调
/// @param userID 用户userID
- (void)onUserDisconnect:(NSString *)userID;

/// 用户接受邀请的回调
/// @param userID 用户userID
- (void)onUserAccept:(NSString *)userID;

/// 忙线
/// @param userID 忙线的用户ID
- (void)onUserBusy:(NSString *)userID;

/// 通话类型切换的回调（仅1对1呼叫有效）
/// @param callType 切换后的类型
/// @param state 切换应答类型:  邀请/同意/拒绝
- (void)onCallTypeChange:(NERtcCallType)callType withState:(NERtcSwitchState)state;

/// 通话类型切换的回调（仅1对1呼叫有效）
/// @param callType 切换后的类型
- (void)onCallTypeChange:(NERtcCallType)callType
    NERtcCallKitDeprecate("use -onCallTypeChange:withState: instead");

/// 通话结束
- (void)onCallEnd;

/// 呼叫超时
- (void)onCallingTimeOut;

/// 连接断开
/// @param reason 断开原因
- (void)onDisconnect:(NSError *)reason;

/// 发生错误
- (void)onError:(NSError *)error;

/// 启用/禁用相机
/// @param available 是否可用
/// @param userID 用户ID
- (void)onCameraAvailable:(BOOL)available userID:(NSString *)userID;

/// 启用/禁用麦克风
/// @param available 是否可用
/// @param userID 用户userID
- (void)onAudioAvailable:(BOOL)available userID:(NSString *)userID;

/// 视频采集变更回调
/// @param muted 是否关闭采集
/// @param userID 用户ID
- (void)onVideoMuted:(BOOL)muted userID:(NSString *)userID;

/// 音频采集变更回调
/// @param muted 是否关闭采集
/// @param userID 用户ID
- (void)onAudioMuted:(BOOL)muted userID:(NSString *)userID;

/// 自己加入成功的回调，通常用来上报、统计等
/// @param event 回调参数
- (void)onJoinChannel:(NERtcCallKitJoinChannelEvent *)event;

/// 首帧解码成功的回调
/// @param userID 用户id
/// @param width 宽度
/// @param height 高度
- (void)onFirstVideoFrameDecoded:(NSString *)userID width:(uint32_t)width height:(uint32_t)height;

/// 网络状态监测回调
/// @param stats key为用户ID, value为对应网络状态
- (void)onUserNetworkQuality:(NSDictionary<NSString *, NERtcNetworkQualityStats *> *)stats;

/// 呼叫请求已被其他端接收的回调
- (void)onOtherClientAccept;

/// 呼叫请求已被其他端拒绝的回调
- (void)onOtherClientReject;

/// 远端用户暂停或恢复发送视频流回调。
- (void)onNERtcEngineUser:(uint64_t)userID videoMuted:(BOOL)muted;

- (void)onNERtcEngineUserVideoDidStartWithUserID:(uint64_t)userID
                                    videoProfile:(NERtcVideoProfileType)profile;

- (void)onRtcInitEnd;

@end

@interface NERtcCallKit : NSObject

/// 通话状态
@property(nonatomic, assign, readonly) NERtcCallStatus callStatus;

/// 单位:秒,IM服务器邀请2分钟后无响应为超时,最大值不超过2分钟。
@property(nonatomic, assign) NSTimeInterval timeOutSeconds;

/// 安全模式音视频房间token获取，nil表示非安全模式. Block中一定要调用complete
@property(nonatomic, copy, nullable) NERtcCallKitTokenHandler tokenHandler;

/// 推送配置定制化，修改config.pushTitle，config.pushContent来完成。需要的上下文内容在context对象中提供。
@property(nonatomic, copy, nullable) NERtcCallKitPushConfigHandler pushConfigHandler;

/// 话单自定义回调，如果需要修发送话单内容可以在此回调中修改message相关字段
@property(nonatomic, copy, nullable) NERtcCallKitRecordMessageHander recordHandler;

/// NERtcEngine 的回调接口，由用户提供
@property(nonatomic, weak) id<NERtcEngineDelegateEx> engineDelegate;

/// 中转NERtcEngine统计回调
@property(nonatomic, weak) id<NERtcEngineMediaStatsObserver> observer;

/// 单例
+ (instancetype)sharedInstance;

/// 初始化，所有功能需要先初始化
/// @param appKey 云信后台注册的appKey
- (void)setupAppKey:(NSString *)appKey options:(nullable NERtcCallOptions *)options;

/// 初始化，所有功能需要先初始化
/// @param appKey 云信后台注册的appKey
/// @param rtcUid  用户自定义rtc uid，如果不需要自定义传入 <= 0 任意整数(或者使用-
/// (void)setupAppKey:(NSString *)appKey options:(nullable NERtcCallOptions *)options
/// 初始化接口)，内部自动生成，如果初始化传入会优先使用外部传入
- (void)setupAppKey:(NSString *)appKey
         withRtcUid:(uint64_t)rtcUid
            options:(nullable NERtcCallOptions *)options;

/// 初始化，所有功能需要先初始化，支持私有化
/// @param appKey 云信后台注册的appKey
/// @param options  IM 推送配置，Rtc是否初始化
/// @param context  Rtc初始化配置，私有化参数配置
- (void)setupAppKey:(NSString *)appKey
            options:(nullable NERtcCallOptions *)options
        withContext:(nonnull NERtcEngineContext *)context;

/// 登录IM接口，所有功能需要先进行登录后才能使用
/// @param userID IM用户accid
/// @param token IM用户token
/// @param completion 回调
- (void)login:(NSString *)userID
         token:(NSString *)token
    completion:(nullable void (^)(NSError *_Nullable error))completion;

/// 更新APNS deviceToken
/// @param deviceToken 注册获得的deviceToken
- (void)updateApnsToken:(NSData *)deviceToken;

/// 更新 PushKit Token
/// @param pushkitToken 目前仅支持 PKPushTypeVoIP
- (void)updatePushKitToken:(NSData *)pushkitToken;

/// 登出
- (void)logout:(nullable void (^)(NSError *_Nullable error))completion;

/// 开始呼叫
/// @param userID 呼叫的用户ID
/// @param type 通话类型
/// @param completion 回调
- (void)call:(NSString *)userID
          type:(NERtcCallType)type
    completion:(nullable void (^)(NSError *_Nullable error))completion;

/// 开始呼叫
/// @param userID 呼叫的用户ID
/// @param type 通话类型  {@link NERtcCallKitConsts =>  NERtcCallType}
/// @param attachment 附件信息，透传到onInvited
/// @param completion 回调
- (void)call:(NSString *)userID
          type:(NERtcCallType)type
    attachment:(nullable NSString *)attachment
    completion:(nullable void (^)(NSError *_Nullable error))completion;

/// 开始呼叫
/// @param userID 呼叫的用户ID
/// @param type 通话类型 {@link NERtcCallKitConsts =>  NERtcCallType}
/// @param attachment 附件信息，透传到onInvited
/// @param extra 扩展
/// @param completion 回调
- (void)call:(NSString *)userID
           type:(NERtcCallType)type
     attachment:(nullable NSString *)attachment
    globalExtra:(nullable NSString *)extra
     completion:(nullable void (^)(NSError *_Nullable error))completion;

/// 开始呼叫
/// @param userID 呼叫的用户ID
/// @param type 通话类型 {@link NERtcCallKitConsts =>  NERtcCallType}
/// @param attachment 附件信息，透传到onInvited
/// @param extra 全局抄送
/// @param token  安全模式token，如果用户直接传入，不需要实现  tokenHandler  block回调
/// @param channelName  自定义channelName，不传会默认生成
/// @param completion 回调
- (void)call:(NSString *)userID
           type:(NERtcCallType)type
     attachment:(nullable NSString *)attachment
    globalExtra:(nullable NSString *)extra
      withToken:(nullable NSString *)token
    channelName:(nullable NSString *)channelName
     completion:(nullable void (^)(NSError *_Nullable error))completion;

/// 取消呼叫
/// @param completion 回调
- (void)cancel:(nullable void (^)(NSError *_Nullable error))completion;

/// 接受呼叫
/// @param completion 回调
- (void)accept:(nullable void (^)(NSError *_Nullable error))completion;

/// 接受呼叫
/// @param token 用户token，如果用户直接传入，不需要实现  tokenHandler  block回调
/// @param completion 回调
- (void)acceptWithToken:(nullable NSString *)token
         withCompletion:(nullable void (^)(NSError *_Nullable error))completion;

/// 拒绝呼叫
/// @param completion 回调
- (void)reject:(nullable void (^)(NSError *_Nullable error))completion;

/// 拒绝呼叫
/// @param completion 回调
/// @param reason  挂断原因
- (void)rejectWithReason:(NSInteger)reason
          withCompletion:(nullable void (^)(NSError *_Nullable error))completion;

/// 挂断
/// @param completion 回调
- (void)hangup:(nullable void (^)(NSError *_Nullable error))completion;

/// 设置自己画面
/// @param localView 渲染自己画面的View
/// @discussion localView上不建议有任何subview
- (void)setupLocalView:(nullable UIView *)localView;

/// 设置其他用户画面
/// @param remoteView 渲染其他画面的View
/// @param userID 其他用户ID
/// @discussion remoteView上不建议有任何subview
- (void)setupRemoteView:(nullable UIView *)remoteView forUser:(nullable NSString *)userID;

/// 启动或关闭摄像头
/// @param enable YES:启动，NO:关闭
/// @return 操作返回值，成功则返回 0
- (int)enableLocalVideo:(BOOL)enable;

/// 开启或关闭视频采集
/// @param muted YES：关闭，NO：开启
/// @return 操作返回值，成功则返回 0
- (int)muteLocalVideo:(BOOL)muted;

/// 切换摄像头
/// @return 操作返回值，成功则返回 0
- (int)switchCamera;

/// 麦克风静音
/// @param mute YES：静音 NO：开启
/// @return 操作返回值，成功则返回 0
- (int)muteLocalAudio:(BOOL)mute;

/// 在通话过程中切换通话类型。非通话过程中调用无效。仅支持1对1通话。
/// @param type 通话类型: 音频/视频
/// @param state 切换应答类型:  邀请/同意/拒绝
/// @param completion 回调
/// @discussion
/// 切换完成后，组件内部会将己端和对端调用-enableLocalVideo:，此时外部不建议再调用-enableLocalVideo:，防止状态错乱.
- (void)switchCallType:(NERtcCallType)type
             withState:(NERtcSwitchState)state
            completion:(nullable void (^)(NSError *_Nullable error))completion;

/// 是否使用扬声器模式
/// @param speaker YES：扬声器 NO：听筒
/// @param error 错误，成功为nil
- (void)setLoudSpeakerMode:(BOOL)speaker error:(NSError *_Nonnull *_Nonnull)error;

/// 指定对某个用户静音。
/// @param mute 是否静音
/// @param userID 用户ID
/// @param error 错误，成功为nil
/// @discussion 只能不接收指定用户的音频，并不影响房间中其他人接受该用户的音频
- (void)setAudioMute:(BOOL)mute forUser:(NSString *)userID error:(NSError *_Nonnull *_Nonnull)error;

/// 根据uid 获取 accid
/// @param uid 用户id
/// @discussion 只有在通话中才能通过uid获取accid
- (void)memberOfUid:(uint64_t)uid
         completion:(nullable void (^)(NIMSignalingMemberInfo *_Nullable info))completion;

/// 根据uid 获取 accid
/// @param accid  IM 用户id
/// @discussion 只有在通话中才能通过accid获取获取uid
- (void)memberOfAccid:(NSString *)accid
           completion:(nullable void (^)(NIMSignalingMemberInfo *_Nullable info))completion;

/// 添加代理 接受回调
/// @param delegate 代理对象
- (void)addDelegate:(id<NERtcCallKitDelegate>)delegate;

/// 移除代理
/// @param delegate 代理对象
- (void)removeDelegate:(id<NERtcCallKitDelegate>)delegate;

/// 音视频切换是否需要确认配置
/// @param video 切换到视频是否需要确认
/// @param audio 切换到音频是否需要确认
- (void)enableSwitchCallTypeConfirmVideo:(BOOL)video audio:(BOOL)audio;

/// 版本号
+ (NSString *)versionCode;

@end

NS_ASSUME_NONNULL_END
