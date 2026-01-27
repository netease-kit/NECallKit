// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <NERtcCallKit/NECallConfig.h>
#import <NERtcCallKit/NECallEngine.h>
#import <NERtcCallKit/NERtcCallKit.h>
#import <NERtcCallKit/NESwitchParam.h>
#import <NERtcSDK/NERtcSDK.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 回调 Block 定义
typedef void (^NECallKitSuccessBlock)(id _Nullable data);
typedef void (^NECallKitFailBlock)(NSInteger code, NSString *_Nullable message);

/// 悬浮窗观察者协议
@protocol NEFloatWindowObserver <NSObject>

/// 点击悬浮窗的回调
- (void)tapFloatWindow;

@end

/// CallKit Bridge 类，用于桥接 iOS 的调用接口
@interface NECallKitBridge : NSObject

/// 单例
+ (instancetype)instance;

/// 初始化
/// @param appKey 云信后台注册的appKey
/// @param frameWork 框架标识（暂未使用，保留参数）
/// @param channel 渠道标识（暂未使用，保留参数）
/// @param currentUserRtcUid 用户自定义rtc uid
- (void)initWithAppKey:(NSString *)appKey
             frameWork:(NSString *)frameWork
               channel:(NSString *)channel
           apnsCername:(NSString *)apnsCername
           voipCerName:(NSString *)voipCerName
     currentUserRtcUid:(uint64_t)currentUserRtcUid;

/// 登录
/// @param accountId IM用户accid
/// @param token IM用户token
/// @param successBlock 成功回调
/// @param failBlock 失败回调
- (void)loginWithAccountId:(NSString *)accountId
                     token:(NSString *)token
                 onSuccess:(nullable NECallKitSuccessBlock)successBlock
                    onFail:(nullable NECallKitFailBlock)failBlock;

/// 登出
/// @param successBlock 成功回调
/// @param failBlock 失败回调
- (void)logoutOnSuccess:(nullable NECallKitSuccessBlock)successBlock
                 onFail:(nullable NECallKitFailBlock)failBlock;

/// 检查权限
/// @param callType 通话类型，1-音频，2-视频
/// @param successBlock 成功回调
/// @param failBlock 失败回调
- (void)hasPermissionWithCallType:(NSInteger)callType
                        onSuccess:(nullable NECallKitSuccessBlock)successBlock
                           onFail:(nullable NECallKitFailBlock)failBlock;

/// 发起呼叫
/// @param param 呼叫参数
/// @param successBlock 成功回调，返回 NECallInfo
/// @param failBlock 失败回调
- (void)callWithParam:(NECallParam *)param
            onSuccess:(nullable NECallKitSuccessBlock)successBlock
               onFail:(nullable NECallKitFailBlock)failBlock;

/// 接受呼叫
/// @param successBlock 成功回调，返回 NECallInfo
/// @param failBlock 失败回调
- (void)acceptOnSuccess:(nullable NECallKitSuccessBlock)successBlock
                 onFail:(nullable NECallKitFailBlock)failBlock;

/// 挂断
/// @param param 挂断参数
/// @param successBlock 成功回调
/// @param failBlock 失败回调
- (void)hangupWithParam:(NEHangupParam *)param
              onSuccess:(nullable NECallKitSuccessBlock)successBlock
                 onFail:(nullable NECallKitFailBlock)failBlock;

/// 切换通话类型
/// @param param 切换参数
- (void)switchCallTypeWithParam:(NESwitchParam *)param;

/// 设置呼叫超时时间
/// @param second 超时时间（秒）
- (void)setTimeout:(int)second;

/// 开启/关闭摄像头
/// @param enable YES:开启，NO:关闭
/// @return 操作返回值，成功则返回 0
- (int)enableLocalVideo:(BOOL)enable;

/// 开启/关闭视频采集
/// @param mute YES:关闭，NO:开启
/// @return 操作返回值，成功则返回 0
- (int)muteLocalVideo:(BOOL)mute;

/// 静音本地音频采集
/// @param mute YES:静音，NO:开启
/// @return 操作返回值，成功则返回 0
- (int)muteLocalAudio:(BOOL)mute;

/// 切换摄像头
/// @param camera 摄像头类型 0: kNERtcCameraPositionBack 1: kNERtcCameraPositionFront
///
- (void)switchCamera:(NSInteger)camera;

/// 启动悬浮窗
- (void)startFloatWindow;

/// 停止悬浮窗
- (void)stopFloatWindow;

/// 获取扬声器是否开启
/// @return YES:扬声器，NO:听筒
- (BOOL)isSpeakerphoneOn;

/// 设置扬声器开关
/// @param enable YES:扬声器，NO:听筒
/// @return 操作返回值，成功则返回 0
- (int)setSpeakerphoneOn:(BOOL)enable;

/// 设置呼叫时的配置参数
/// @param config 呼叫配置
- (void)setCallConfig:(NECallConfig *)config;

/// 获取呼叫时的配置参数
/// @return 呼叫配置
- (nullable NECallConfig *)getCallConfig;

/// 通话过程中获取通话信息
/// @return 通话信息
- (nullable NECallInfo *)getCallInfo;

/// 设置AI降噪模式
/// @param mode 降噪模式
/// @return 操作返回值，成功则返回 0
- (int)setAINSMode:(NERtcAudioAINSMode)mode;

/// 组件销毁
- (void)destroy;

/// 获取当前版本号
+ (NSString *)getVersion;

/// 添加悬浮窗观察者
/// @param observer 观察者对象
- (void)addFloatWindowObserver:(id<NEFloatWindowObserver>)observer;

/// 移除悬浮窗观察者
/// @param observer 观察者对象
- (void)removeFloatWindowObserver:(id<NEFloatWindowObserver>)observer;

@end

NS_ASSUME_NONNULL_END
