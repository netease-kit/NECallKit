//
//  NIMSDKConfig.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NIMNotificationObject;
@class NIMMessage;
@class NIMChatroomCdnTrackInfo;
@protocol NIMMsgIndexProduceDelegate;
@class NIMLogDesensitizationConfig;

/**
 *  SDK 配置委托
 */
@protocol NIMSDKConfigDelegate <NSObject>

@optional

/**
 *  是否需要忽略某个通知
 *
 *  @param notification 通知对象
 *
 *  @return 是否忽略
 */
- (BOOL)shouldIgnoreNotification:(NIMNotificationObject *)notification;

/**
 *  是否需要忽略某条消息
 *
 *  @param message 消息对象
 *
 *  @return 是否忽略
 */
- (BOOL)shouldIgnoreMessage:(NIMMessage *)message;

/**
 * 聊天室cdn统计回调，回调时间间隔为NIMSDKConfig.cdnTrackInterval
 */
- (void)onChatroomCdnTrack:(NIMChatroomCdnTrackInfo *)trackInfo forRoom:(NSString *)roomID;

- (NSString *)tokenCallback:(const NSString *)url;

/**
 * 采用动态Token登录时，SDK通过该回调方法从App获取Token
 */
- (nullable NSString *)dynamicTokenForAccount:(NSString *)account;

/**
 * SDK通过该回调方法从App获取LoginExt
 */
- (nullable NSString *)dynamicLoginExtForAccount:(NSString *)account;

/**
 * 采用动态Token登录聊天室时，SDK通过该回调方法从App获取聊天室登陆Token
 */
- (nullable NSString *)dynamicChatRoomTokenForAccount:(NSString *)account room:(NSString *)roomId appKey:(NSString *)appKey;

/**
 * SDK通过该回调方法从App获取聊天室LoginExt
 */
- (nullable NSString *)dynamicChatRoomLoginExtForAccount:(NSString *)account room:(NSString *)roomId appKey:(NSString *)appKey;

@end

/**
 *  NIM SDK 配置项目
 */
@interface NIMSDKConfig : NSObject

/**
 *  返回配置项实例
 *
 *  @return 配置项
 */
+ (instancetype)sharedConfig;

/**
 *  设置禁用NIMSDK tracroute 能力
 *  @discussion 默认为NO,SDK会在请求失败时,进行 traceroute ,探测网路中各节点,以判断在哪个节点失去连接
 */
@property (nonatomic,assign)    BOOL    disableTraceroute;


/**
 *  是否在收到消息后自动下载附件 (群和个人)
 *  @discussion 默认为YES,SDK会在第一次收到消息是直接下载消息附件,上层开发可以根据自己的需要进行设置
 */
@property (nonatomic,assign)    BOOL    fetchAttachmentAutomaticallyAfterReceiving;


/**
 *  是否在收到聊天室消息后自动下载附件
 *  @discussion 默认为NO
 */
@property (nonatomic,assign)    BOOL    fetchAttachmentAutomaticallyAfterReceivingInChatroom;


/**
 *  是否使用 NSFileProtectionNone 作为云信文件的 NSProtectionKey
 *  @discussion 默认为 NO，只有在上层 APP 开启了 Data Protection 时才起效
 */
@property (nonatomic,assign)    BOOL    fileProtectionNone;

/**
 *  APP 是否开启 Data Protection
 *  @discussion 默认为 NO，如果开启，请将此设为YES
 */
@property (nonatomic,assign)    BOOL    enableDataProtection;


/**
 *  是否需要将被撤回的消息计入未读计算考虑
 *  @discussion 默认为 NO。设置成 YES 的情况下，如果被撤回的消息本地还未读，那么当消息发生撤回时，对应会话的未读计数将减 1 以保持最近会话未读数的一致性
 *  默认未读 NO 的原因是客户端常常需要直接再写入一条 tip 消息用于提醒显示，使用 NO 作为默认值直接写入一条已读 tip 消息，避免未读计数发生两次变化，最终导致界面重复刷新
 *  如果客户场景不需要写入 tip 消息，可以设置为 YES，以保持未读计数的一致性。
 */
@property (nonatomic,assign)    BOOL    shouldConsiderRevokedMessageUnreadCount;

/**
 *  是否需要多端同步未读数
 *  @discusssion 默认为 NO。设置成 YES 的情况下，同个账号多端（PC 和 移动端等）将同步未读计数。
 */
@property (nonatomic,assign)    BOOL    shouldSyncUnreadCount;


/**
 *  是否将群通知计入未读
 *  @discusssion 默认为 NO。设置成 YES 的情况下，收到的群通知也会计入未读数
 */
@property (nonatomic,assign)    BOOL    shouldCountTeamNotification;


/**
 *  针对用户信息开启 https 支持
 *  @discusssion 默认为 YES。在默认情况下，我们认为用户头像，群头像，聊天室类用户头像等信息都是默认托管在云信上，所以 SDK 会针对他们自动开启 https 支持。
 *                          但如果你需要将这些信息都托管在自己的服务器上，需要设置这个接口为 NO，避免 SDK 自动将你的 http url 自动转换为 https url。
 */
@property (nonatomic,assign)    BOOL    enabledHttpsForInfo;


/**
 *  针对消息内容开启 https 支持
 *  @discusssion 默认为 YES。在默认情况下，我们认为消息，包括图片，视频，音频信息都是默认托管在云信上，所以 SDK 会针对他们自动开启 https 支持。
 *                         但如果你需要将这些信息都托管在自己的服务器上，需要设置这个接口为 NO，避免 SDK 自动将你的 http url 自动转换为 https url。 (强烈不建议)
 *                         需要注意的是即时设置了这个属性，通过 iOS SDK 发出去的消息 URL 仍是 https 的，设置这个值只影响接收到的消息 URL 格式转换
 */
@property (nonatomic,assign)    BOOL    enabledHttpsForMessage;


/**
 *  自动登录重试次数
 *  @discusssion 默认为 0。即默认情况下，自动登录将无限重试。设置成大于 0 的值后，在没有登录成功前，自动登录将重试最多 maxAutoLoginRetryTimes 次，如果失败，则抛出错误 (NIMLocalErrorCodeAutoLoginRetryLimit)。
 */
@property (nonatomic,assign)    NSInteger   maxAutoLoginRetryTimes;


/**
 *  本地 log 存活期
 *  @discusssion 默认为 7 天。即超过 7 天的 log 将被清除。只能设置大于等于 2 的值。
 */
@property (nonatomic,assign)    NSInteger   maximumLogDays;

/**
 *  是否支持动图缩略
 *  @discusssion 默认为 NO。即默认情况下，从服务器获取原图缩略图时，如果原图为动图，我们将返回原图第一帧的缩略图。
 *               而开启这个选项后，我们将返回缩略图后的动图。这个选项只影响从服务器获取的缩略图，不影响本地生成的缩略图。
 */
@property (nonatomic,assign)    BOOL   animatedImageThumbnailEnabled;

/**
 *  是否禁止后台重连
 *  @discusssion 默认为 NO。即默认情况下，当程序退到后台断开连接后，如果 App 仍能运行，SDK 将继续执行自动重连机制。设置为 YES 后在后台将不自动重连，重连将被推迟到前台进行。
 *                  只有特殊用户场景才需要此设置，无明确原因请勿设置。
 *  @deprecated 功能已下线
 */
@property (nonatomic,assign)    BOOL    reconnectInBackgroundStateDisabled;

/**
 *  是否开启群回执功能
 *  @discusssion 默认为 NO。
 */
@property (nonatomic,assign)    BOOL    teamReceiptEnabled;

/**
 *  配置项委托
 */
@property (nullable,nonatomic,weak)    id<NIMSDKConfigDelegate>    delegate;

/**
 客户端自定义信息，用于多端登录时同步该信息
 */
@property (nonatomic,copy)  NSString *customTag;

/**
 *  文件快传本地开关，默认YES
 */
@property (nonatomic,assign) BOOL fileQuickTransferEnabled;

/**
*  是否开启异常错误上报， 默认 NO，不上报
*  @discussion 用户可以选择开启该选项，方便云信分析SDK发生的错误，优化SDK
*/
@property (nonatomic, assign) BOOL exceptionOptimizationEnabled;

/**
*  是否开启异步读取最近会话，默认NO，不开启
*  @discussion 对于最近会话比较多的用户，初始读取数据库时，可能影响到启动速度，用户可以选择开启该选项，开启异步读取最近会话，
*  allRecentSessions会优先返回一部分最近会话，等到全部读取完成时，通过回调通知用户刷新UI。
*/
@property (nonatomic, assign) BOOL asyncLoadRecentSessionEnabled;

/**
*  是否开启会话数据库备份，默认NO，不开启
*  @discussion 开启数据库备份后，如果遇到数据库文件损坏，SDK会恢复备份的数据库文件，并重置漫游时间戳
*/
@property (nonatomic, assign) BOOL sessionDatabaseBackupEnabled;

/**
 *  日志上传大小上限，默认 0，不限制，单位(byte)
 */
@property (nonatomic, assign)  unsigned long long maxUploadLogSize;

/**
 * 是否同步置顶会话记录，默认NO
 */
@property (nonatomic,assign) BOOL shouldSyncStickTopSessionInfos;

/**
 客户端自定义登录端类型，默认 0，需要设置大于0的值。
 */
@property (nonatomic,assign)  NSInteger customClientType;

/**
 * cdn统计回调触发间隔。触发cdn拉流前设置，触发拉流后改动将不生效。0s代表不统计。默认30s。
 */
@property (nonatomic, assign) NSTimeInterval cdnTrackInterval;

/**
 * 聊天室消息接收回调最小时间间隔，不设置时，采用默认值
 *  @discusssion SDK采纳的有效设置区间为：50毫秒到500毫秒，如果低于或高于边界值，采用边界值
 */
@property (nonatomic, assign) NSTimeInterval chatroomMessageReceiveMinInterval;

/**
 *  NIMSDK优化设置
 *  @discussion 此选项为高级设置，具体设置需要联系技术支持。
 */
@property (nullable,nonatomic,copy)  NSString    *optimizeSettings;

/**
 *  设置 SDK 根目录
 *
 *  @param sdkDir SDK 根目录
 *  @discussion 设置该值后 SDK 产生的数据(包括聊天记录，但不包括临时文件)都将放置在这个目录下，如果不设置，所有数据将放置于 $Document/NIMSDK目录下
 *              该配置项必须在 NIMSDK 任一一个 sharedSDK 方法调用之前调用，否则配置无法生效
 */
- (void)setupSDKDir:(NSString *)sdkDir;

/**
 * 配置无效
 * @deprecated
 */
@property (nonatomic,assign)    BOOL    linkQuickSwitch;

/**
 *  消息索引生成委托
 */
@property (nullable, nonatomic)    id<NIMMsgIndexProduceDelegate> msgIndexProducer;

@property (nonatomic, copy) NSString * flutterSDKVersion;

//@property (nonatomic, strong)  NIMFcsConfig * fcsConfig;
@property(nonatomic, assign) BOOL fcsEnable;
@property(nonatomic, assign) NSInteger fcsAuthType;
@property(nonatomic, strong) NSString *fcsUa;
@property(nonatomic, strong) NSString *fcsRefer;

@property (nonatomic, assign) BOOL isSingleTable;

/**
 * 是否开启设备指纹功能
 * 默认YES
 */
@property(nonatomic, assign) BOOL growDeviceEnabled;

/**
 * 日志脱敏配置
 */
@property (nonatomic, copy) NIMLogDesensitizationConfig *logDesensitizationConfig;

/**
 * 消息缩略图的尺寸
 * 默认350
 */
@property (nonatomic, assign) NSInteger thumbnailSize;

/**
 * 默认NO，如果为YES，则消息状态是否成功会结合是否被拉入黑名单进行判断
 */
@property (nonatomic, assign) BOOL fixMsgStatusByBlackList;

/**
 * 默认NO，如果为YES，会上报被过滤的消息
 */
@property (nonatomic, assign) BOOL reportIgnoredMessage;

@end


NS_ASSUME_NONNULL_END
