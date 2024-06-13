//
//  V2NIMSettingServiceProtocol.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "V2NIMBase.h"
#import "V2NIMTeamServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@class V2NIMDndConfig;
@protocol V2NIMSettingListener;

/// 群组消息免打扰模式
typedef NS_ENUM(NSInteger, V2NIMTeamMessageMuteMode) {
    V2NIM_TEAM_MESSAGE_MUTE_MODE_OFF                  = 0,  ///< 群组所有消息免打扰关闭
    V2NIM_TEAM_MESSAGE_MUTE_MODE_ON                   = 1,  ///< 所有消息均免打扰开启
    V2NIM_TEAM_MESSAGE_MUTE_MODE_MANAGER_OFF          = 2,  ///< 只群主，管理员消息免打扰关闭
};

/// 点对点消息免打扰模式
typedef NS_ENUM(NSInteger, V2NIMP2PMessageMuteMode) {
    V2NIM_P2P_MESSAGE_MUTE_MODE_OFF                   = 0,  ///< 点对点消息免打扰关闭
    V2NIM_P2P_MESSAGE_MUTE_MODE_ON                    = 1,  ///< 点对点消息免打扰开启
};

typedef void (^V2NIMGetMuteListSuccess)(NSArray <NSString *> *result);

/// 设置协议
@protocol V2NIMSettingService <NSObject>

/**
 *  获取会话消息免打扰状态
 *
 *  @param conversationId 会话id
 */
- (BOOL)getConversationMuteStatus:(NSString *)conversationId;

/**
 *  设置群组消息免打扰模式
 *
 *  @param teamId 群组Id
 *  @param teamType 群组类型
 *  @param muteMode 群组消息免打扰模式
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)setTeamMessageMuteMode:(NSString *)teamId
                      teamType:(V2NIMTeamType)teamType
                      muteMode:(V2NIMTeamMessageMuteMode)muteMode
                       success:(nullable V2NIMSuccessCallback)success
                       failure:(nullable V2NIMFailureCallback)failure;

/**
 *  获取群消息免打扰模式
 *
 *  @param teamId 群组id
 *  @param teamType 群组类型
 */
- (V2NIMTeamMessageMuteMode)getTeamMessageMuteMode:(NSString *)teamId
                                          teamType:(V2NIMTeamType)teamType;

/**
 *  设置点对点消息免打扰模式
 *
 *  @param accountId 账号Id
 *  @param muteMode 点对点消息免打扰模式
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)setP2PMessageMuteMode:(NSString *)accountId
                     muteMode:(V2NIMP2PMessageMuteMode)muteMode
                      success:(nullable V2NIMSuccessCallback)success
                      failure:(nullable V2NIMFailureCallback)failure;

/**
 *  获取点对点消息免打扰模式
 *
 *  @param accountId 账号id
 */
- (V2NIMP2PMessageMuteMode)getP2PMessageMuteMode:(NSString *)accountId;
/**
 *  获取点对点消息免打扰列表
 *
 *  @param success 返回V2NIMP2PMessageMuteMode状态为V2NIM_P2P_MESSAGE_MUTE_MODE_ON的用户
 */
- (void)getP2PMessageMuteList:(nullable V2NIMGetMuteListSuccess)success
                      failure:(nullable V2NIMFailureCallback)failure;

/**
 *  设置应用前后台状态
 *
 *  @param success 返回V2NIMP2PMessageMuteMode状态为V2NIM_P2P_MESSAGE_MUTE_MODE_ON的用户
 */
- (void)setAppBackground:(BOOL)isBackground badge:(NSInteger)badge;
/**
 *  设置当桌面端在线时，移动端是否需要推送
 *  运行在移动端时， 需要调用该接口
 *
 *  @param need 桌面端在线时，移动端是否需要推送 true： 需要 fasle：不需要
 */
- (void)setPushMobileOnDesktopOnline:(BOOL)need 
                             success:(nullable V2NIMSuccessCallback)success
                             failure:(nullable V2NIMFailureCallback)failure;
/**
 *  设置Apns免打扰与详情显示
 *
 *  @param config 免打扰与详情配置参数
 */
- (void)setDndConfig:(V2NIMDndConfig *)config;
/**
 *  添加设置监听
 *
 *  @param listener
 */
- (void)addSettingListener:(id<V2NIMSettingListener>)listener;

/**
 *  移除设置监听
 *
 *  @param listener
 */
- (void)removeSettingListener:(id<V2NIMSettingListener>)listener;

@end

/// 设置回调协议
@protocol V2NIMSettingListener <NSObject>

@optional

/**
 *  群组消息免打扰回调
 *
 *  @param teamId 群组id
 *  @param teamType 群组类型
 *  @param muteMode 群组免打扰模式
 */
- (void)onTeamMessageMuteModeChanged:(NSString *)teamId
                            teamType:(V2NIMTeamType)teamType
                            muteMode:(V2NIMTeamMessageMuteMode)muteMode;

/**
 *  点对点消息免打扰回调
 *
 *  @param accountId 账号id
 *  @param muteMode 用户免打扰模式
 */
- (void)onP2PMessageMuteModeChanged:(NSString *)accountId
                           muteMode:(V2NIMP2PMessageMuteMode)muteMode;

@end

@interface V2NIMDndConfig : NSObject
/**
 *  是否显示详情
 *  true： 显示
 *  false：不限制
 */
@property (nonatomic,assign) BOOL showDetail;
/**
 * 免打扰是否开启
 * true：开启
 * fasle：关闭
 */
@property (nonatomic,assign) BOOL dndOn;
/**
 * 如果开启免打扰，开始小时数(Integer)
 * dndOn， 该字段必传
 */
@property (nonatomic,assign) NSInteger fromH;
/**
 * 如果开启免打扰，开始分钟数(Integer)
 * dndOn， 该字段必传
 */
@property (nonatomic,assign) NSInteger fromM;
/**
 * 如果开启免打扰，截止小时数(Integer)
 * dndOn， 该字段必传
 */
@property (nonatomic,assign) NSInteger toH;
/**
 * 如果开启免打扰，截止分钟数(Integer)
 * dndOn， 该字段必传
 */
@property (nonatomic,assign) NSInteger toM;
@end
NS_ASSUME_NONNULL_END
