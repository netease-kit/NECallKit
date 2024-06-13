//
//  NIMLoginManagerProtocol.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMLoginClient.h"

#ifndef NIMDeprecated
#define NIMDeprecated(msg) __attribute__((deprecated(msg)))
#endif

@class NIMLoginKickoutResult;

NS_ASSUME_NONNULL_BEGIN
/**
 *  登录服务相关Block
 *
 *  @param error 执行结果,如果成功error为nil
 */
typedef void(^NIMLoginHandler)(NSError * __nullable error);

/**
 *  查询服务端时间Block
 *
 *  @param error 执行结果,如果成功error为nil
 */
typedef void(^NIMLoginGetServerTimeHandle)(NSError * __nullable error, NIMServerTime *time);

/**
 *  登录步骤枚举
 */
typedef NS_ENUM(NSInteger, NIMLoginStep)
{
    /**
     *  连接服务器
     */
    NIMLoginStepLinking = 1,
    /**
     *  连接服务器成功
     */
    NIMLoginStepLinkOK,
    /**
     *  连接服务器失败
     */
    NIMLoginStepLinkFailed,
    /**
     *  登录
     */
    NIMLoginStepLogining,
    /**
     *  登录成功
     */
    NIMLoginStepLoginOK,
    /**
     *  登录失败
     */
    NIMLoginStepLoginFailed,
    /**
     *  开始同步
     */
    NIMLoginStepSyncing,
    /**
     *  同步完成
     */
    NIMLoginStepSyncOK,
    /**
     *  连接断开
     */
    NIMLoginStepLoseConnection,
    /**
     *  网络切换
     *  @discussion 这个并不是登录步骤的一种,但是UI有可能需要通过这个状态进行UI展现
     */
    NIMLoginStepNetChanged,
    /**
     *  主动退出
     */
    NIMLoginStepLogout,
};

/**
 *  SDK 认证模式
 */
typedef NS_ENUM(NSInteger, NIMSDKAuthMode)
{
    /**
     *  未定义
     *  @discussion SDK 未调用任何登录接时或在 IM/聊天室 模式下调用 logout 接口后变化为未定义模式
     */
    NIMSDKAuthModeUndefined = 0,
    /**
     *  通过 IM 服务器鉴权
     *  @discussion 调用 NIMLoginManager login/autoLogin 接口进行登录即为 IM 鉴权模式
     */
    NIMSDKAuthModeIM,
    /**
     *  聊天室单独鉴权
     *  @discussion 调用 NIMChatroomManager 进入聊天室接口时设置 NIMChatroomIndependentMode 即为聊天室单独聊天鉴权模式
     */
    NIMSDKAuthModeChatroom,
};

/**
 *  SDK 认证类型
 *  0表示最初的loginToken的校验方式，1表示基于appSecret计算的token鉴权方式，2表示基于第三方回调的token鉴权方式，默认0
 */
typedef NS_ENUM(NSInteger, NIMSDKAuthType)
{
    NIMSDKAuthTypeDefault = 0,
    NIMSDKAuthTypeDynamicToken = 1,
    NIMSDKAuthTypeThirdParty = 2,
};

/**
 *  被踢下线的原因
 */
typedef NS_ENUM(NSInteger, NIMKickReason)
{
    /**
     *  被另外一个客户端踢下线 (互斥客户端一端登录挤掉上一个登录中的客户端)
     */
    NIMKickReasonByClient = 1,
    /**
     *  被服务器踢下线
     */
    NIMKickReasonByServer = 2,
    /**
     *  被另外一个客户端手动选择踢下线
     */
    NIMKickReasonByClientManually   = 3,
};

/**
*  多端登陆的状态
*/
typedef NS_ENUM(NSInteger, NIMMultiLoginType){
    /**
     *  目前已经有其他端登陆
     */
    NIMMultiLoginTypeInit   =   1,
    /**
     *  其他端上线
     */
    NIMMultiLoginTypeLogin  =   2,
    /**
     *  其他端下线
     */
    NIMMultiLoginTypeLogout =   3,
};

/**
 *  IM 登录相关回调接口，包括登录状态、多端登录、被踢下线、数据同步状态等事件的监听回调。
 */
@protocol NIMLoginManagerDelegate <NSObject>

@optional
/**
 *  被其他端（服务端/客户端）踢下线的回调。<br>
 *
 *  @deprecated 请使用- (void)onKickout:(NIMLoginKickoutResult *)result;
 *
 *  @par 参数说明：
 *  <table>
 *  <tr><th>参数名称</th><th>描述</th>
 *  </tr>
 *  <tr><td>code</td><td>被踢下线的原因</td>
 *  </tr>
 *  <tr><td>clientType</td><td>将其踢下线的设备端的类型</td>
 *  </tr>
 *  </table>
 */
- (void)onKick:(NIMKickReason)code clientType:(NIMLoginClientType)clientType NIMDeprecated("Use -onKickout: instead");

/**
 *  被其他端（服务端/客户端）踢下线的回调。
 *  @par 使用场景：
 *  在被踢下线时，需要知晓被踢原因以及将其踢下线的设备端类型（包括服务端和客户端）。
 *  @par 调用时机：
 *  建议在初始化 NIM SDK 后，登录 IM 前注册该回调。
 *  @par 触发时机：
 *  <ul><li>被同一个 IM 账号的服务端踢下线。</li><li>被同一个 IM 账号的其他客户端手动调用踢人接口踢下线。</li><li>被同一个 IM 账号的其他客户端踢下线（互斥客户端一端登录自动挤掉上一个登录中的客户端，该逻辑可通过云信控制台进行配置，目前支持四种不同的 [IM 多端登录策略](https://doc.yunxin.163.com/messaging/docs/jI1MzcwNTQ?platform=iOS)）。</li></ul>
 *  @par 注意事项：
 *  被踢下线后，若需要重新登录，建议先进行注销（登出），再切换到登录界面进行登录。
 *  @par 参数说明：
 *  result：被踢后收到的回调信息，包括被踢下线的原因（NIMKickReason）和将其踢下线的设备端的类型（NIMLoginClientType）
 *  @par 相关接口：
 *  [kickOtherClient:completion:](https://doc.yunxin.163.com/docs/interface/messaging/iOS/doxygen/Latest/zh/d9/d16/protocol_n_i_m_login_manager-p.html#adc1ca83617c1ace26541488881d90541) 主动将其他客户端踢下线
 */
- (void)onKickout:(NIMLoginKickoutResult *)result;

/**
 *  IM 登录状态的回调。
 *  @par 使用场景：
 *  该回调主要用于客户端登录页面的 UI 刷新。
 *  @par 调用时机：
 *  必须在创建 NIM SDK 实例（sharedSDK）之后，才能调用该接口；建议在初始化 NIM SDK 后，登录 IM 前注册该回调。
 *  @par 触发时机：
 *  从调用登录 IM 接口开始，到登录结束（包括成功和失败）之间符合任一状态（NIMLoginStep）时触发回调。
 *  @par 注意事项：
 *  登录成功后，SDK 会自动同步数据，数据同步完成后，整个登录过程才算真正完成。
 *  @par 参数说明：
 *  step：IM 登录状态信息，即登录进度，登录过程中的状态变更请参考[登录状态的转换流程](https://doc.yunxin.163.com/messaging/docs/TU3MTM2ODM?platform=iOS#登录状态转换流程)
 *  @par 相关接口：
 *  [login:token:authType:loginExt:completion:](https://doc.yunxin.163.com/docs/interface/messaging/iOS/doxygen/Latest/zh/d9/d16/protocol_n_i_m_login_manager-p.html#a7dedc10fcbadf36fb66ce9cc9710b8f6) 登录 IM<br>
 *  [autoLogin:](https://doc.yunxin.163.com/docs/interface/messaging/iOS/doxygen/Latest/zh/d9/d16/protocol_n_i_m_login_manager-p.html#a7239363d8c7d432e68261094b23081b7) 自动登录 IM<br>
 *  [logout:](https://doc.yunxin.163.com/docs/interface/messaging/iOS/doxygen/Latest/zh/d9/d16/protocol_n_i_m_login_manager-p.html#a60f99812a55cecb9069e748ed586513b) 登出（注销） IM
 */
- (void)onLogin:(NIMLoginStep)step;

/**
 *  IM 自动登录失败的回调。
 *  @par 使用场景：
 *  使用 IM 自动登录后，除了因为网络超时导致的错误（SDK 会在网络超时时启用<b>断网重连机制</b>进行重连，上层应用无需处理），如果发生其他错误（如 AppKey 未被设置，参数错误，密码错误，多端登录冲突，账号被封禁，操作过于频繁等），那么在集成时需要上层应用处理对应的逻辑。您可以通过注册该方法回调，获取自动登录失败的原因，并根据原因处理上层逻辑。<br>
 *  例如：自动登录失败的原因是用户名和密码不匹配，那么上层应用需实现<b>登出并提示用户手动登录</b>或是<b>从应用服务器刷新相应的用户名和密码</b>等逻辑。
 *  @par 调用时机：
 *  必须在创建 NIM SDK 实例（sharedSDK）之后，才能调用该接口；建议在初始化 NIM SDK 后，登录 IM 前注册该回调。
 *  @par 触发时机：
 *  自动登录失败时触发回调。
 *  @par 参数说明：
 *  error：自动登录失败的原因
 *  @par 相关接口：
 *  [autoLogin:](https://doc.yunxin.163.com/docs/interface/messaging/iOS/doxygen/Latest/zh/d9/d16/protocol_n_i_m_login_manager-p.html#a7239363d8c7d432e68261094b23081b7) 自动登录 IM
 */
- (void)onAutoLoginFailed:(NSError *)error;

/**
 *  多端登录变更的回调，监听同一账号的其他端的登录状态变更情况，即当用户通过某个客户端登录时，其他（同一账号）已经在线的客户端会收到该回调。
 *  @deprecated 请使用- (void)onMultiLoginClientsChangedWithType:(NIMMultiLoginType)type;
 */
- (void)onMultiLoginClientsChanged;

/**
*  多端登录变更的回调，监听同一账号的其他端的登录状态变更情况，即当用户通过某个客户端登录时，其他（同一账号）已经在线的客户端会收到该回调。
*  @par 使用场景：
*  若应用支持同一账号多端登录以及互踢下线等操作，建议同一账号的各个客户端在登录注册该回调，获取其他客户端的登录状态，可以搭配 [currentLoginClients](https://doc.yunxin.163.com/docs/interface/messaging/iOS/doxygen/Latest/zh/d9/d16/protocol_n_i_m_login_manager-p.html#a055c3df878ee55c5e492f43444e2f8f3) 一起使用，查询当前登录的其他设备列表，包含客户端类型、操作系统以及登录时间等信息。
*  @par 调用时机：
*  必须在创建 NIM SDK 实例（sharedSDK）之后，才能调用该接口；建议在初始化 NIM SDK 后，登录 IM 前注册该回调。
*  @par 参数说明：
*  type：同一账号其他端的登录状态信息，分为“其他端上线”，“其他端下线”，“目前已有其他端登录”
*  @par 相关接口：
*  [currentLoginClients](https://doc.yunxin.163.com/docs/interface/messaging/iOS/doxygen/Latest/zh/d9/d16/protocol_n_i_m_login_manager-p.html#a055c3df878ee55c5e492f43444e2f8f3) ：查询同一账号的其他已登录设备			
*/
- (void)onMultiLoginClientsChangedWithType:(NIMMultiLoginType)type;

/**
 *  群组用户信息同步完成的回调。
 *  @par 使用场景：
 *  若需要使用应用的群组成员信息，那么要确保群组用户信息已同步至SDK 的本地数据库，可以使用该接口回调知晓群组用户信息同步是否完成。
 *  @par 调用时机：
 *  必须在创建 NIM SDK 实例（sharedSDK）之后，才能调用该接口；建议在初始化 NIM SDK 后，登录 IM 前注册该回调。
 *  @par 注意事项：
 *  若同步失败，建议手动将群组用户信息同步至 SDK 的本地数据库，否则可能会影响 SDK 群组相关接口的使用。
 *  @par 参数说明：
 *  success：群组用户信息是否同步成功
 */
- (void)onTeamUsersSyncFinished:(BOOL)success;

/**
 *  超大群用户信息同步完成的回调。
 *  @par 使用场景：
 *  若需要使用应用的超大群成员信息，那么要确保超大群用户信息已同步至SDK 的本地数据库，可以使用该接口回调知晓超大群用户信息同步是否完成。
 *  @par 调用时机：
 *  必须在创建 NIM SDK 实例（sharedSDK）之后，才能调用该接口；建议在初始化 NIM SDK 后，登录 IM 前注册该回调。
 *  @par 注意事项：
 *  若同步失败，建议手动将超大群用户信息同步至 SDK 的本地数据库，否则可能会影响 SDK 超大群相关接口的使用。
 *  @par 参数说明：
 *  success：超大群用户信息是否同步成功
 */
- (void)onSuperTeamUsersSyncFinished:(BOOL)success;

/**
 *  动态 Token 回调，用于获取动态 Token，后续以动态 token 鉴权方式登录 IM。
 *  @par 使用场景：
 *  如果您有正式的生产环境，且您的业务对用户信息安全有较高的要求，可使用动态 Token 鉴权方式登录 IM。通过该方式登录前，需要调用该接口获取动态 Token。
 *  @par 调用时机：
 *  必须在创建 NIM SDK 实例（sharedSDK）之后，才能调用该接口；建议在初始化 NIM SDK 后，登录 IM 前注册该回调。
 *  @par 注意事项：
 *  <ul><li>通过该接口获取的 Token 是动态且临时有效的。您可以通过服务端设置该动态 token 的有效期，建议不要太长。</li><li>若选择动态 token 鉴权方式，在调用登录接口时需要传入登录方式（authType，1 为动态 token 鉴权方式）。</li></ul>
 *  @par 参数说明：
 *  account：用户的 IM 账号，即 accid
 *  @par 返回：
 *  对应账号的动态 token
 *  @par 相关接口：
 *  [login:token:authType:loginExt:completion:](https://doc.yunxin.163.com/docs/interface/messaging/iOS/doxygen/Latest/zh/d9/d16/protocol_n_i_m_login_manager-p.html#a7dedc10fcbadf36fb66ce9cc9710b8f6)  登录 IM
 *  @deprecated 请使用 NIMSDKConfigDelegate dynamicTokenForAccount:
 */
- (NSString *)provideDynamicTokenForAccount:(NSString *)account;


/**
 *  自定义重连策略回调。回调中返回自动重连的时间间隔，即当自动登录失败后多久后触发自动重连。<br>
 *  SDK 默认的自动重连策略：自动登录失败后 2 秒触发自动重连触，如果一直连不上，重连时间指数级增长，2、4、6、8、16、32、64 ...
 */
- (int)reconnectDelay;

/**
 * 消息数据库已经打开
 */
- (void)onDataReady;

@end

/**
 *  IM 登录相关接口，包括登录、登出、踢人下线等接口。
 */
@protocol NIMLoginManager <NSObject>

/**
 *  手动登录 IM。
 *  @deprecated 请使用 [login:token:authType:loginExt:completion:](https://doc.yunxin.163.com/docs/interface/messaging/iOS/doxygen/Latest/zh/d9/d16/protocol_n_i_m_login_manager-p.html#a7dedc10fcbadf36fb66ce9cc9710b8f6)
 *  @par 参数说明：
 *  <table>
 *  <tr><th>参数名称</th><th>描述</th>
 *  </tr>
 *  <tr><td>account</td><td>用户的 IM 账号，即 accid</td>
 *  </tr>
 *  <tr><td>token</td><td>IM 账号（accid）对应的登录 token</td>
 *  </tr>
 *  <tr><td>completion</td><td>登录服务相关回调</td>
 *  </tr>
 *  </table>
 */
- (void)login:(NSString *)account
        token:(NSString *)token
   completion:(NIMLoginHandler)completion;

/**
 * 手动登录 IM。
 * @par 使用场景：
 * <ul><li>在新设备上首次登录 IM。</li><li>被同时在线的其他设备踢下线后再次登录 IM。</li><li>切换 IM 账号后再次登录 IM。</li><li>注销登录后再次登录 IM。</li></ul>
 * @par 注意事项：
 * <ul><li>登录成功后，SDK 会自动同步数据，数据同步完成后，整个登录过程才算真正完成。</li><li>推荐在手动登录成功后，将 accid 和 token 保存到本地，方便下次应用启动自动登录时使用。如果登录失败，清除本地保存的用户登录信息，防止下次启动走自动登录逻辑。</li></ul>
 * @par 参数说明：
 *  <table>
 *  <tr><th>参数名称</th><th>描述</th>
 *  </tr>
 *  <tr><td>account</td><td>用户的 IM 账号，即 accid</td>
 *  </tr>
 *  <tr><td>token</td><td>IM 账号（accid）对应的登录 token</td>
 *  </tr>
 *  <tr><td>authType</td><td>登录鉴权方式，0（默认）：静态 token 鉴权；1：动态 token 鉴权；2：基于第三方回调的 token 鉴权</td>
 *  </tr>
 *  <tr><td>loginExt</td><td>登录自定义扩展字段。若选择基于第三方回调的 token 鉴权方式（authType 传入 3）时，该字段必传，如未传入，将报错</td>
 *  </tr>
 *  <tr><td>completion</td><td>登录服务相关回调</td>
 *  </tr>
 *  </table>
 * @par 相关回调：
 * [onLogin:](https://doc.yunxin.163.com/docs/interface/messaging/iOS/doxygen/Latest/zh/d5/dc6/protocol_n_i_m_login_manager_delegate-p.html#a70055366358595d63b0e1c07aedeb55f) 登录状态回调<br>
 * [onMultiLoginClientsChangedWithType:](https://doc.yunxin.163.com/docs/interface/messaging/iOS/doxygen/Latest/zh/d5/dc6/protocol_n_i_m_login_manager_delegate-p.html#a83f001bb0a5c477a72178f1c0b2585df) 多端登录设备列表
 * @par 相关接口：
 * [provideDynamicTokenForAccount:](https://doc.yunxin.163.com/docs/interface/messaging/iOS/doxygen/Latest/zh/d5/dc6/protocol_n_i_m_login_manager_delegate-p.html#a248519e2e4ea0328523db756cd538650) 获取动态 token<br>
 * [autoLogin:token:](https://doc.yunxin.163.com/docs/interface/messaging/iOS/doxygen/Latest/zh/d9/d16/protocol_n_i_m_login_manager-p.html#a8c05c17ff5369ce9b70c6c7d33d6622e) 自动登录 IM
 *
 *  @param account    帐号
 *  @param token      令牌 (authType为NIMSDKAuthTypeDefault时有效)
 *  @param authType   登陆类型，取值范围为NIMSDKAuthType
 *  @param loginExt   登录自定义字段 (authType为NIMSDKAuthTypeThirdParty时有效；authType为NIMSDKAuthTypeThirdPartyDynamic时，loginExt通过NIMSDKConfigDelegate中的dynamicLoginExtForAccount:来获取)
 *  @param completion 完成回调
 */
- (void)login:(NSString *)account
        token:(NSString *)token
     authType:(int)authType
     loginExt:(NSString *)loginExt
   completion:(NIMLoginHandler)completion;

/**
 *  自动登录 IM。
 *  @deprecated 请使用- (void)autoLogin:(NIMAutoLoginData *)loginData;
 *  @par 使用建议：
 *  启动 APP 时，如果已经保存了帐号和 token，那么建议使用自动登录方式，可以在无网络时直接打开会话窗口。
 *  @par 参数说明：
 *  <table>
 *  <tr><th>参数名称</th><th>描述</th>
 *  </tr>
 *  <tr><td>account</td><td>用户的 IM 账号，即 accid</td>
 *  </tr>
 *  <tr><td>token</td><td>IM 账号（accid）对应的登录 token</td>
 *  </tr>
 *  </table>
 */
- (void)autoLogin:(NSString *)account
            token:(NSString *)token; 


/**
 *  自动登录 IM。
 *  @par 前提条件：
 *  手动登录成功且将 accid 和 token 保存至本地。
 *  @par 使用场景：
 *  自动登录一般用于应用被清理后，用户再次点击应用图标启动应用，无需输入用户名和密码即可完成登录的场景。此时应用可以在无网络、未登录成功的状态下直接访问用户本地 SDK 数据。
 *  @par 注意事项：
 *  登录成功后，SDK 会自动同步数据，数据同步完成后，整个登录过程才算真正完成。
 *  @par 参数说明：
 *  loginData：自动登录参数，包括 account、token、 forcedMode 等信息。其中 forcedMode 为强制模式开关，默认为 NO，非强制模式下的自动登录，服务器将检查当前登录设备是否为上一次登录设备，如果不是，服务器将拒绝这次自动登录(（回 error code 为 417 的错误)。若设置为 YES， 那么自动登录时云信服务端将不检查当前登录设备是否为上一次登录设备，安全便捷，但安全性较低，请根据实际业务场景谨慎使用。
 *  @par 相关回调：
 *  [onAutoLoginFailed:](https://doc.yunxin.163.com/docs/interface/messaging/iOS/doxygen/Latest/zh/d5/dc6/protocol_n_i_m_login_manager_delegate-p.html#ab96ef125e18a7722668b30ddd0289e7f) 自动登录失败回调<br>
 *  [onMultiLoginClientsChangedWithType:](https://doc.yunxin.163.com/docs/interface/messaging/iOS/doxygen/Latest/zh/d5/dc6/protocol_n_i_m_login_manager_delegate-p.html#a83f001bb0a5c477a72178f1c0b2585df) 多端登录设备回调
 *  @par 相关接口：
 *  [login:token:authType:loginExt:completion:](https://doc.yunxin.163.com/docs/interface/messaging/iOS/doxygen/Latest/zh/d9/d16/protocol_n_i_m_login_manager-p.html#a7dedc10fcbadf36fb66ce9cc9710b8f6) 手动登录 IM
 */
- (void)autoLogin:(NIMAutoLoginData *)loginData;

/**
 *  注销 IM 登录（登出 IM），登出后，用户将不再接收 IM 的消息。
 *  @par 使用场景：
 *  一般情况下，如果您的应用生命周期跟 NIM SDK 生命周期一致，用户在退出应用前可以不登出，直接退出即可。些特殊场景，例如用户仅在进入特定界面后才调用 NIM SDK 的能力，退出界面后不再调用，此时需要调用 NIM SDK 的登出接口注销 IM 登录。
 *  @par 注意事项：
 *  <ul><li>调用该接口登出 IM 时，SDK 会同时通知云信服务端进行 APNs 推送的解绑操作，避免用户已登出但依然将消息推送到当前设备。</li><li>考虑到用户体验，登出的超时时间会比其他请求短一些。无论登出请求是否成功，上层应用在 UI 表现上都应该做出登出行为。如果登出失败，应用也需要跳转到登录界面。导致登出失败的原因是云信服务端解绑 APNs 推送信息失败，但此时本地信息是清理成功的。</li><li>用户在登出是需要调用这个接口进行 SDK 相关数据的清理，回调 Block 中的 error 只是指明和服务器的交互流程中可能出现的错误,但不影响后续的流程。 如用户登出时发生网络错误导致服务器没有收到登出请求，客户端仍可以登出(切换界面，清理数据等)，但会出现推送信息仍旧会发到当前手机的问题。</li></ul>
 *  @par 参数说明：
 *  completion：登出完成的回调。回调中的 NIMLoginHandler error 只是指明和服务器的交互流程中可能出现的错误，但不影响后续的流程。 如用户登出时发生网络错误导致服务器没有收到登出请求，客户端仍可以登出(切换界面，清理数据等)，但会出现推送信息仍旧会发到当前手机的问题。
 *  @par 相关回调：
 *  [onLogin:](https://doc.yunxin.163.com/docs/interface/messaging/iOS/doxygen/Latest/zh/d5/dc6/protocol_n_i_m_login_manager_delegate-p.html#a70055366358595d63b0e1c07aedeb55f) 登录状态回调<br>
 *  [onMultiLoginClientsChangedWithType:](https://doc.yunxin.163.com/docs/interface/messaging/iOS/doxygen/Latest/zh/d5/dc6/protocol_n_i_m_login_manager_delegate-p.html#a83f001bb0a5c477a72178f1c0b2585df) 多端登录设备列表
 */
- (void)logout:(nullable NIMLoginHandler)completion;

/**
 *  将当前账号的其他已登录客户端踢下线。
 *  @par 注意事项：
 *  被踢方收到被踢回调后，建议进行注销（logout）并切换到登录界面重新登录。
 *  @par 参数说明：
*   <table>
 *  <tr><th>参数名称</th><th>描述</th>
 *  </tr>
 *  <tr><td>client</td><td>需要踢下线的客户端信息</td>
 *  </tr>
 *  <tr><td>completion</td><td>踢人下线的相关回调</td>
 *  </tr>
 *  </table>
 *  @par 相关回调：
 *  [onKickout:](https://doc.yunxin.163.com/docs/interface/messaging/iOS/doxygen/Latest/zh/d5/dc6/protocol_n_i_m_login_manager_delegate-p.html#acd2ae586b5e4f0a9cec487727c164a63) 被其他端踢下线的回调<br>
 *  [onMultiLoginClientsChangedWithType:](https://doc.yunxin.163.com/docs/interface/messaging/iOS/doxygen/Latest/zh/d5/dc6/protocol_n_i_m_login_manager_delegate-p.html#a83f001bb0a5c477a72178f1c0b2585df) 多端登录设备列表
 */
- (void)kickOtherClient:(NIMLoginClient *)client
             completion:(nullable NIMLoginHandler)completion;

/**
 *  查询当前登录的帐号（accid）。
 *
 *  @par 返回：
 *  当前登录的帐号，如果当前账号未登录成功，将返回空字符串（""）
 */
- (NSString *)currentAccount;

/**
 *  查询当前的登录状态。
 *
 *  @par 返回：
 *  当前的登录状态，返回 YES，表示已登录；返回 NO，表示处于未登录状态
 */
- (BOOL)isLogined;

/**
 *  查询当前账号登录的鉴权方式。
 *
 *  @par 返回：
 *  当前账号登录的鉴权方式，如果当前账号未登录成功，将返回空字符串（""）
 */
- (NIMSDKAuthMode)currentAuthMode;

/**
 *  查询当前账号登录的客户端信息（NIMLoginClient），将返回当前登录的的设备列表，包括客户端类型、操作系统、登录时间等信息。
 *
 *  @par 返回： 
 *  当前登录的的设备列表，其中不包含本端。若除本端外，无其他登录设备，将返回空字符串（""）
 */
- (nullable NSArray<NIMLoginClient *> *)currentLoginClients;

/**
 * 查询云信服务端当前的时间。
 * @par 注意事项：
 * 该方法有调用频控，当调用失败时默认返回上一次调用成功时返回的时间。
 *
 * @par 参数说明：
 * completion：查询完成的回调
 */
- (void)queryServerTimeCompletion:(NIMLoginGetServerTimeHandle)completion;

/**
 *  通过在对应的管理类中添加委托（delegate）通知上层 API 调用结果。
 *  @par 使用场景：
 *  一般推荐在相应 ViewController 或管理类初始化进行委托注册，在其销毁时进行移除。
 *  @par 参数说明：
 *  delegate：登录相关的委托
 */
- (void)addDelegate:(id<NIMLoginManagerDelegate>)delegate;

/**
 *  在对应的管理类中移除委托（delegate），移除后，将不再通知上层 API 调用结果。
 *
 *  @par 参数说明：
 *  delegate：登录相关的委托
 */
- (void)removeDelegate:(id<NIMLoginManagerDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
