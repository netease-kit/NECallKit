// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef NERtcCallUIKit_h
#define NERtcCallUIKit_h

#import <AVKit/AVKit.h>
#import "NECallUIKitConfig.h"
#import "NECallInviteUIContext.h"
#import "NECallViewController.h"
#import "NECustomButton.h"
#import "NEExpandButton.h"
#import "NEUICallParam.h"
#import "NEVideoOperationView.h"
#import "NEVideoView.h"
#import "NetManager.h"

#import "NEAudioCallingController.h"
#import "NEAudioInCallController.h"
#import "NECallViewBaseController.h"
#import "NECalledViewController.h"
#import "NERingFile.h"
#import "NEVideoCallingController.h"
#import "NEVideoInCallController.h"

#import "NEUIGroupCallParam.h"

// 音频呼叫中UI状态
extern NSString *_Nonnull kAudioCalling;
// 视频呼叫中UI状态
extern NSString *_Nonnull kVideoCalling;
// 音频通话中UI状态
extern NSString *_Nonnull kAudioInCall;
// 视频通话中UI状态
extern NSString *_Nonnull kVideoInCall;
// 被叫UI状态(音频&视频)
extern NSString *_Nonnull kCalledState;

// 群呼人数限制 10人
extern const NSInteger kGroupCallMaxUsers;

#endif /* NERtcCallUIKit_h */

NS_ASSUME_NONNULL_BEGIN

@protocol NETranscodingDelegate <NSObject>

- (void)renderFrame:(NERtcVideoFrame *)frame withLayer:(AVSampleBufferDisplayLayer *)layer;

@end

@protocol NECallUIKitDelegate <NSObject>

@optional

/// 当有呼叫来到时候的回调，根据返回值决定内部是否返回，未实现此回调内部默认弹出被叫页面
- (void)didCallComingWithInviteInfo:(NEInviteInfo *)inviteInfo
                      withCallParam:(NEUICallParam *)callParam
                     withCompletion:(void (^)(BOOL success))completion;

/// 群组通话邀请用户回调
- (void)inviteUsersWithCallId:(NSString *)callId
                  inCallUsers:(NSArray<NSString *> *)inCallUsers
                   completion:(void (^)(NSArray<NSString *> *_Nullable users))completion;

/// 单呼转多人通话点击邀请入口后回调业务方选人。
/// completion 返回 nil 或空数组表示取消。
- (void)selectInviteUsersWithContext:(NECallInviteUIContext *)context
                          completion:(void (^)(NSArray<NSString *> *_Nullable userIDs))completion;

@end

@interface NERtcCallUIKit : NSObject

/// UI状态配置类，如果用户需要自定义某个状态的UI，需要继承通话状态类，通过对应key值覆盖对应Class
@property(nonatomic, strong, readonly) NSMutableDictionary<NSString *, Class> *uiConfigDic;

/// 自定义UI，UI完全自己重写，呼叫组件只负责拉起此页面，此参数的优先级高于 uiConfigDic 配置，
/// 传入的类型要继承自 NECallViewBaseController 类
@property(nonatomic, strong, nullable) Class customControllerClass;

/// 铃声文件配置，默认初始化内部资源路径，如果需要替换再初始化之后修改对应路径，如果想禁止铃声播放，对应路径置空即可
@property(nonatomic, strong) NERingFile *ringFile;

///  UI Kit 代理回调
@property(nonatomic, weak) id<NECallUIKitDelegate> delegate;

+ (instancetype)sharedInstance;

/// 初始化，所有功能需要先初始化
/// @param config 初始化参数
- (void)setupWithConfig:(NECallUIKitConfig *)config;

/// 主叫发起呼叫接口
/// @param callParam 呼叫参数
- (void)callWithParam:(NEUICallParam *)callParam;

/// 设置自定义UI类
- (void)setCustomCallClass:(NSMutableDictionary<NSString *, Class> *)customDic;

///  转为小窗模式
- (void)changeSmallModeWithTyple:(NECallType)callType;

/// 回复为非小窗模式
- (void)restoreNormalMode;

/// 版本号
+ (NSString *)version;

/// 发起群呼叫
- (void)groupCallWithParam:(NEUIGroupCallParam *)callParam;

/// 开启或关闭来电横幅模式。默认关闭（false）。
/// 开启后收到来电时以顶部悬浮横幅替代原全屏来电界面；关闭后恢复原有行为。
/// 可动态调用，下一次来电时生效。
- (void)enableIncomingBanner:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
