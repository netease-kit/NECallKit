//
//  NIMSDKHeaders.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NIMSDKOption;
@class NIMQChatOption;
@class NIMServerSetting;

@protocol NIMCustomizedAPIManager;
/**
 *  压缩日志回调
 *
 *  @param error 执行结果，如果成功 error 为 nil
 *  @param path  压缩包的路径，只有当执行成功才有值，否则为 nil
 */
typedef void(^NIMArchiveLogsHandler)(NSError *error, NSString *path);

typedef void(^NIMUploadLogsHandler)(NSError *error, NSString *path);


/**
 *  SDK 核心类，提供初始化 SDK，获取各个服务能力接口，获取当前版本等接口
 */
@interface NIMSDK : NSObject
/**
 *  获取 NIM SDK 实例。
 *  @par 调用时机：
 *  IM 所有业务均通过 NIM SDK 单例进行调用。
 *  @par 注意事项：
 *  虽然所有的云信接口都是线程安全的，但为了防范于未然，推荐您在且只在主线程调用该接口。
 *  @par 返回： 
 *  NIM SDK: 实例
 */
+ (instancetype)sharedSDK;

/**
 *  获取当前 SDK 版本号。
 *
 *  @par 返回： 
 *  当前 SDK 版本号，如 "1.0.0"
 */
- (NSString *)sdkVersion;

/**
 *  获取当前 Git 的版本号。
 */
- (NSString *)gitVersion;

/**
 *  初始化 SDK，初始化时，可同时注册应用的 AppKey 和 APNs 推送证书名称。<br>
 *  如需要同时配置 PushKit 推送证书名称，请使用 - (void)registerWithOption:(NIMSDKOption *)option; 接口。
 *  @par 调用时机：
 *  建议在应用启动时初始化 NIM SDK。
 *  @par 参数说明：
 *  <table>
 *  <tr><th>参数名称</th><th>描述</th></tr>
 *  <tr><td>appKey</td><td>对应云信控制台应用的 AppKey，应用的唯一标识。使用相同 App Key 、不同 Bundle Id 的应用，消息仍可以互通</td></tr>
 *  <tr><td>cerName</td><td>对应云信控制台配置的推送证书名称，不超过 32 个字符，否则登录时会报 500 错误</td></tr>
 *  </table>
 *  
 */
- (void)registerWithAppID:(NSString *)appKey
                  cerName:(nullable NSString *)cerName;


/**
 *  初始化 SDK，初始化时，可同时注册 APNs 推送证书名称和 PushKit 推送证书名称。<br>
 *  @par 调用时机：
 *  建议在应用启动时初始化 NIM SDK。
 *  @par 参数说明：
 *  option：初始化的配置项，包括应用的 AppKey 、APNs 推送证书名称和 PushKit 推送证书名称
 */
- (void)registerWithOption:(NIMSDKOption *)option;

/**
 *  获取 AppKey。
 *
 *  @par 返回： 
 *  当前注册应用的 AppKey
 */
- (nullable NSString *)appKey;


/**
 *  是否正在使用 Demo 的 AppKey。
 *
 *  @par 返回：
 *  YES：正在使用；NO ：没有使用
 */
- (BOOL)isUsingDemoAppKey;

/**
 *  配置圈组的推送证书。通过配置推送证书的名称（对应云信控制台上的推送证书名称），与第三方推送厂商完成通信。
 *
 *  @par 参数说明：
 *  option：圈组选项，推送证书名称
 */
- (void)qchatWithOption:(NIMQChatOption *)option;

/**
 *  上传/更新 DeviceToken 至云信服务器，用于后续的 APNs 推送。若需要同时设置自定义推送文案，请使用 [updateApnsToken:customContentKey:](https://doc.yunxin.163.com/docs/interface/messaging/iOS/doxygen/Latest/zh/de/de3/interface_n_i_m_s_d_k.html#ab84b0a2d91225c8b10de070205fd9d2a)
       customContentKey:(nullable NSString *)key;
 *  @par 参数说明： 
 *  token：当前设备的 DeviceToken
 *  @par 返回：
 *  格式化后的 DeviceToken
 */
- (NSString *)updateApnsToken:(NSData *)token;

/**
 *  上传/更新 DeviceToken 至云信服务器，用于后续的 APNs 推送。该接口可同时设置自定义推送文案（对应云信控制台中的自定义推送文案类型）。若需要在圈组中使用自定义推送文案，请使用 [updateApnsToken:customContentKey:qchatCustomContentKey:](https://doc.yunxin.163.com/docs/interface/messaging/iOS/doxygen/Latest/zh/de/de3/interface_n_i_m_s_d_k.html#a76e4b4325d3ae560eedfab3e67e3afff)
 *  @par 参数说明：
 *  <table>
 *  <tr><th>参数名称</th><th>描述</th></tr>
 *  <tr><td>token</td><td>当前设备的 DeviceToken</td></tr>
 *  <tr><td>key</td><td>自定义的推送文案（对应云信控制台中的自定义推送文案类型，最多可设置 100 种，对应不同的业务场景）<br>不填（nil），则表示不更改，使用云信系统内默认的推送文案：“你收到一条新消息”；<br>填 “”（空值），则清空配置；</td></tr>
 *  </table>
 *  @par 返回：
 *  格式化后的 DeviceToken
 */
- (NSString *)updateApnsToken:(NSData *)token
       customContentKey:(nullable NSString *)key;

/**
 *  上传/更新 DeviceToken 至云信服务器，用于后续的 APNs 推送。该接口可同时设置自定义推送文案以及圈组自定义推送文案（对应云信控制台中的自定义推送文案类型）。
 *  @par 参数说明：
 *  <table>
 *  <tr><th>参数名称</th><th>描述</th></tr>
 *  <tr><td>token</td><td>当前设备的 DeviceToken</td></tr>
 *  <tr><td>key</td><td>自定义的推送文案（对应云信控制台中的自定义推送文案类型，最多可设置 100 种，对应不同的业务场景）<br>不填（nil），则表示不更改，使用云信系统内默认的推送文案：“你收到一条新消息”；<br>填 “”（空值），则清空配置</td></tr>
 *  <tr><td>qchatKey</td><td>圈组的自定义推送文案（对应云信控制台中的自定义推送文案类型，最多可设置 100 种，对应不同的业务场景）<br>不填（nil），则表示不更改，圈组使用云信系统内默认的推送文案：“你收到一条新消息”；<br>填 “”（空值），则清空配置</td></tr>
 *  </table>
 *  @par 返回：
 *  格式化后的 DeviceToken
 */
- (NSString *)updateApnsToken:(NSData *)token
             customContentKey:(nullable NSString *)key
        qchatCustomContentKey:(nullable NSString *)qchatKey;

/**
 *  上传/更新 PushKit Token 至云信服务器，用于后续的离线推送。目前仅支持 PKPushTypeVoIP 类型。
 *
 *  @par 参数说明：
 *  token ：VoIP Push Token
 *  @par 返回：
 *  格式化后的 VoIP Push Token
 */
- (void)updatePushKitToken:(NSData *)token;


/**
 *  获得 SDK 当前的 log 文件路径。
 *  @par 注意事项：
 *  SDK 每天会生成一个 log 文件，方便开发者定位和反馈问题。
 *  @par 返回： 
 *  SDK 当前的 log 文件路径（当前生成的最新的 log 文件路径）
 */
- (NSString *)currentLogFilepath;


/**
 *  打包当前所有的 log 文件，调用该接口后，SDK 将压缩当前所有的日志为 Zip 文件，并输出 Zip 路径，上层可以根据该文件进行上传反馈。
 *
 *  @par 参数说明： 
 *  completion：压缩日志的回调，回调信息包含 error（执行结果，如果成功将返回 nil）和 path（压缩包的路径，只有当执行成功才有值，否则将返回 nil）
 */
- (void)archiveLogs:(NIMArchiveLogsHandler)completion;

/**
 *  打包并上传当前所有的 log 文件，调用该接口后，SDK 将压缩当前所有的日志为 Zip 文件，输出 Zip 路径并上传，上层可以根据该文件进行上传反馈。
 *
 *  @par 参数说明： 
 *  completion：打包并上传日志的回调，回调信息包含 error（执行结果，如果成功将返回 nil）和 path（压缩包的路径，只有当执行成功才有值，否则将返回 nil）
 */
- (void)uploadLogs:(NIMUploadLogsHandler _Nullable)completion;

/**
 *  打包并上传目标聊天室的所有的 log 文件，调用该接口后，SDK 将压缩目标聊天室当前所有的日志为 Zip 文件，输出 Zip 路径并上传，上层可以根据该文件进行上传反馈。
 *
 *  @par 参数说明：
 *  <table>
 *  <tr><th>参数名称</th><th>描述</th></tr> 
 *  <tr><td>attach</td><td>附言，可为空</td></tr>
 *  <tr><td>roomId</td><td>目标聊天室 ID，可为空</td></tr>
 *  <tr><td>completion</td><td>打包并上传日志的回调，回调信息包含 error 和 path<br>error ：执行结果，如果成功将返回 nil<br>path ：压缩包的路径，只有当执行成功才有值，否则将返回 nil</td></tr>
 *  </table>
 */
- (void)uploadLogsWithAttach:(nullable NSString *)attach
                      roomId:(nullable NSString *)roomId
                  completion:(NIMUploadLogsHandler _Nullable)completion;

/**
 * 优化圈组表现。
 */
- (void)optimizeQChat;


/**
 *  开启控制台 Log。调用该接口开启控制台 Log 后，会将云信 SDK 的日志写进开发者调试工具的控制台日志文件中（Console Log）。
 */
- (void)enableConsoleLog;

/**
 *  当前服务器配置
 *  @discussion 私有化需要进行自定义设置，必须在注册 appkey 完成之前设置
 */
@property (nonatomic,strong)           NIMServerSetting    *serverSetting;

/**
 *  资源场景配置
 *  @discussion nos 预设场景和自定义场景规则
 *  可以覆盖设置，如果预设场景不设置，为系统默认设置
 *  sceneDict key-value，系统默认预设场景为3种，自定义场景数量不超过10种
 *  key 是场景，nsstring类型；value 是资源存活时间，nsnumber类型，精确到天，0为永久存活
 *  例如：@{@"nim_icon":@0,@"nim_msg":@0,@"nim_system":@0,@"nim_custom":@30}
 */
@property (nonatomic,strong)         NSMutableDictionary *sceneDict;

/**
 *  登录管理类，负责登录、注销和相关操作的通知收发，提供鉴权、登录、登出、踢人等接口
 */
@property (nonatomic,strong,readonly)   id<NIMLoginManager>   loginManager;

/**
 *  聊天管理类，提供消息发送、消息查询、消息撤回等相关接口
 */
@property (nonatomic,strong,readonly)   id<NIMChatManager>     chatManager;

/**
 *  会话管理类，负责消息、最近会话的读写和管理，提供获取/删除会话消息、设置会话消息已读等相关接口
 */
@property (nonatomic,strong,readonly)   id<NIMConversationManager>  conversationManager;

/**
 *  媒体管理类，提供语音录制和播放相关接口
 */
@property (nonatomic,strong,readonly)   id<NIMMediaManager>    mediaManager;

/**
 *  群组管理类,负责群组的操作:创建,拉人,踢人,同步等
 */
@property (nonatomic,strong,readonly)   id<NIMTeamManager>    teamManager;

/**
 *  超大群管理类，提供超大群成员管理、超大群消息发送、超大群资料管理等相关接口
 */
@property (nonatomic,strong,readonly) id<NIMSuperTeamManager> superTeamManager;

/**
 *  好友管理类，提供用户信息管理和好友关系管理相关接口
 */
@property (nonatomic,strong,readonly)   id<NIMUserManager>      userManager;

/**
 *  系统通知管理类，提供发送、标记、删除系统通知等接口
 */
@property (nonatomic,strong,readonly)   id<NIMSystemNotificationManager>    systemNotificationManager;

/**
 *  APNS 推送管理类，提供APNs 离线推送服务相关配置接口
 */
@property (nonatomic,strong,readonly)   id<NIMApnsManager> apnsManager;

/**
 *  资源管理器，提供下载、搜索、查询资源等接口
 */
@property (nonatomic,strong,readonly)   id<NIMResourceManager> resourceManager;

/**
 *  聊天室管理类，提供进出聊天室、发送聊天室消息、聊天室成员管理、聊天室队列服务、聊天室标签等接口
 */
@property (nonatomic,strong,readonly)   id<NIMChatroomManager> chatroomManager;

/**
 *  文档转码管理类，提供查询文档转码信息、删除转码文档等接口
 */
@property (nonatomic,strong,readonly)   id<NIMDocTranscodingManager> docTranscodingManager;

/**
 *  事件订阅管理类，提供发布、查询、订阅事件等接口
 */
@property (nonatomic,strong,readonly)   id<NIMEventSubscribeManager> subscribeManager;

/**
 *  智能机器人管理类，提供获取机器人信息等接口
 */
@property (nonatomic,strong,readonly)   id<NIMRobotManager> robotManager;

/**
 *  红包管理类，提供获取红包 token 的接口
 */
@property (nonatomic,strong,readonly)   id<NIMRedPacketManager> redPacketManager;

/**
 *  广播消息管理类，提供广播消息监听等接口
 */
@property (nonatomic,strong,readonly)   id<NIMBroadcastManager> broadcastManager;

/**
 *  反垃圾管理类，提供本地反垃圾检查接口
 */
@property (nonatomic,strong,readonly)   id<NIMAntispamManager> antispamManager;

/**
 *  通用音视频信令管理类，提供信令相关接口
 */
@property (nonatomic,strong,readonly)   id<NIMSignalManager> signalManager;

/**
 *   透传代理管理类
 */
@property (nonatomic,strong,readonly)   id<NIMPassThroughManager> passThroughManager;


/**
 *   Thread Talk（扩展消息）管理类，提供收藏消息、快捷评论等接口
 */
@property (nonatomic,strong,readonly)   id<NIMChatExtendManager> chatExtendManager;

/**
 *   索引管理类，提供消息检索相关接口
 */
@property (nonatomic,strong,readonly)   id<NIMIndexManager> indexManager;

/**
 *  圈组管理类
 */
@property (nonatomic,strong,readonly)   id<NIMQChatManager> qchatManager;

/**
 *  圈组APNS推送管理类
 */
@property (nonatomic,strong,readonly)   id<NIMQChatApnsManager> qchatApnsManager;

/**
 *  圈组服务器管理类
 */
@property (nonatomic,strong,readonly)   id<NIMQChatServerManager> qchatServerManager;

/**
 *  圈组频道管理类
 */
@property (nonatomic,strong,readonly)   id<NIMQChatChannelManager> qchatChannelManager;

/**
 *  圈组身份组管理类
 */
@property (nonatomic,strong,readonly)   id<NIMQChatRoleManager> qchatRoleManager;

/**
 *  圈组消息管理类
 */
@property (nonatomic,strong,readonly)   id<NIMQChatMessageManager> qchatMessageManager;

/**
 *  圈组消息扩展管理类
 */
@property (nonatomic,strong,readonly)   id<NIMQChatMessageExtendManager> qchatMessageExtendManager;

/**
 *  圈组rtc管理类
 */
@property (nonatomic,strong,readonly)   id<NIMQChatRTCChannelManager> qchatRTCChannelManager;

/**
 *  定制化接口调用管理类，提供调用定制化 API 接口
 */
@property (nonatomic,strong,readonly)   id<NIMCustomizedAPIManager> customizedAPIManager;

@end

NS_ASSUME_NONNULL_END
