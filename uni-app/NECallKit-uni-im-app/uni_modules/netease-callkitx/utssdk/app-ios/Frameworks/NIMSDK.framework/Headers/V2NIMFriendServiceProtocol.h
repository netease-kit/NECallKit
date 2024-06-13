//
//  V2NIMFriendServiceProtocol.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/10/30.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "V2NIMBase.h"

@class V2NIMFriendAddParams;
@class V2NIMFriend;
@class V2NIMFriendAddApplication;
@class V2NIMFriendAddRejection;
@class V2NIMFriendDeleteParams;
@class V2NIMFriendSetParams;
@class V2NIMFriendAddApplicationQueryOption;
@class V2NIMFriendAddApplicationResult;

@protocol V2NIMFriendListener;

NS_ASSUME_NONNULL_BEGIN
/**
 *  用户性别
 */
typedef NS_ENUM(NSInteger, V2NIMFriendAddMode) {
    /**
     *  直接添加对方为好友
     */
    V2NIM_FRIEND_MODE_TYPE_ADD = 1,
    /**
     *  请求添加对方为好友，对方需要验证
     */
    V2NIM_FRIEND_MODE_TYPE_APPLAY,
};

/**
 *  好友添加操作的类型
 */
typedef NS_ENUM(NSInteger, V2NIMFriendAddApplicationType) {
    /**
     *  自己收到了好友的添加申请
     */
    V2NIM_FRIEND_ADD_APPLICATION_TYPE_RECEIVED = 1,
    /**
     *  自己收到了对方拒绝我申请添加好友
     */
    V2NIM_FRIEND_ADD_APPLICATION_TYPE_REJECTED,
};
/**
 *  好友删除的类型
 */
typedef NS_ENUM(NSInteger, V2NIMFriendDeletionType) {
    /**
     *  自己删除好友
     */
    V2NIM_FRIEND_DELETION_TYPE_BY_SELF = 1,
    /**
     *  对方删除你
     */
    V2NIM_FRIEND_DELETION_TYPE_BY_FRIEDN,
};

/**
 *  好友添加的状态
 */
typedef NS_ENUM(NSInteger, V2NIMFriendAddApplicationStatus) {
    /**
     *  未处理
     */
    V2NIM_FRIEND_ADD_APPLICATION_STATUS_INIT = 0,
    /**
     *  已同意
     */
    V2NIM_FRIEND_ADD_APPLICATION_STATUS_AGREED,
    /**
     *  已拒绝
     */
    V2NIM_FRIEND_ADD_APPLICATION_STATUS_REJECED,
    /**
     *  已过期
     */
    V2NIM_FRIEND_ADD_APPLICATION_STATUS_EXPIRED
};

typedef void (^V2NIMCheckFriendSuccess)(NSDictionary <NSString *, NSNumber *> *result);

typedef void (^V2NIMGetFirendListSuccess)(NSArray <V2NIMFriend *> *result);

typedef void (^V2NIMGetApplicationListSuccess)(V2NIMFriendAddApplicationResult *result);

@protocol V2NIMFriendService <NSObject>
/**
 *  添加好友
 *
 *  @param accountId 被添加为好友的账号ID
 *  @param params 添加好友参数
 *  @param success  请求成功回调
 *  @param failure  请求失败回调
 */
- (void)addFriend:(NSString *)accountId
           params:(V2NIMFriendAddParams *)params
          success:(nullable V2NIMSuccessCallback)success
          failure:(nullable V2NIMFailureCallback)failure;
/**
 *  删除好友
 *
 *  @param accountId 被添加为好友的账号ID
 *  @param params 删除好友参数
 *  @param success  请求成功回调
 *  @param failure  请求失败回调
 */
- (void)deleteFriend:(NSString *)accountId
              params:(V2NIMFriendDeleteParams *)params
             success:(nullable V2NIMSuccessCallback)success
             failure:(nullable V2NIMFailureCallback)failure;
/**
 *  接受好友申请
 *
 *  @param application 申请添加好友的相关信息
 *  @param success  请求成功回调
 *  @param failure  请求失败回调
 */
- (void)acceptAddApplication:(V2NIMFriendAddApplication *)application
                     success:(nullable V2NIMSuccessCallback)success
                     failure:(nullable V2NIMFailureCallback)failure;
/**
 *  拒绝添加好友申请
 *
 *  @param application 申请添加好友的相关信息
 *  @param postscript 拒绝申请的附言
 *  @param success  请求成功回调
 *  @param failure  请求失败回调
 */
- (void)rejectAddApplication:(V2NIMFriendAddApplication *)application
                  postscript:(NSString *)postscript
                     success:(nullable V2NIMSuccessCallback)success
                     failure:(nullable V2NIMFailureCallback)failure;
/**
 *  设置好友信息
 *
 *  @param accountId 好友的账号ID
 *  @param params 设置好友信息参数
 *  @param success  请求成功回调
 *  @param failure  请求失败回调
 */
- (void)setFriendInfo:(NSString *)accountId
               params:(V2NIMFriendSetParams *)params
              success:(nullable V2NIMSuccessCallback)success
              failure:(nullable V2NIMFailureCallback)failure;
/**
 *  获取好友列表
 *
 *  @param success  请求成功回调
 *  @param failure  请求失败回调
 */
- (void)getFriendList:(nullable V2NIMGetFirendListSuccess)success
              failure:(nullable V2NIMFailureCallback)failure;
/**
 *  根据账号ID获取好友信息
 *
 *  @param accountIds  获取好友信息的账号ID列表
 *  @param success  请求成功回调
 *  @param failure  请求失败回调
 */
- (void)getFriendByIds:(NSArray <NSString *> *)accountIds
               success:(nullable V2NIMGetFirendListSuccess)success
               failure:(nullable V2NIMFailureCallback)failure;
/**
 *  根据账号ID检查好友状态
 *
 *  @param accountIds  检查好友状态的账号ID列表
 *  @param success  请求成功回调
 *  @param failure  请求失败回调
 */
- (void)checkFriend:(NSArray <NSString *> *)accountIds
            success:(nullable V2NIMCheckFriendSuccess)success
            failure:(nullable V2NIMFailureCallback)failure;
/**
 *  根据账号ID检查好友状态
 *
 *  @param option  检查好友状态的账号ID列表
 *  @param success  请求成功回调
 *  @param failure  请求失败回调
 */
- (void)getAddApplicationList:(V2NIMFriendAddApplicationQueryOption *)option
                      success:(nullable V2NIMGetApplicationListSuccess)success
                      failure:(nullable V2NIMFailureCallback)failure;
/**
 *  添加好友监听器
 *
 *  @param listener 监听器
 */
- (void)addFriendListener:(id<V2NIMFriendListener>)listener;

/**
 *  移除好友信息监听器
 *
 *  @param listener 监听器
 */
- (void)removeFriendListener:(id<V2NIMFriendListener>)listener;
@end

@protocol V2NIMFriendListener <NSObject>
/**
 * 已添加好友
 *
 - Parameter friendInfo:好友信息
 */
- (void)onFriendAdded:(V2NIMFriend *)friendInfo;
/**
 * 删除好友通知
 * 本端删除好友，多端同步
 - Parameter accountId:删除的好友账号ID
 */
- (void)onFriendDeleted:(NSString *)accountId deletionType:(V2NIMFriendDeletionType)deletionType;
/**
 * 好友添加申请回调
 - Parameter applicationInfo:申请添加好友信息
 */
- (void)onFriendAddApplication:(V2NIMFriendAddApplication *)application;
/**
 * 好友添加申请被拒绝回调
 * 本端删除好友，多端同步
 - Parameter rejectionInfo:添加好友被拒绝回调
 */
- (void)onFriendAddRejected:(V2NIMFriendAddRejection *)rejectionInfo;
/**
 * 更新好友信息
 - Parameter friendInfo:信息变更的好友
 */
- (void)onFriendInfoChanged:(V2NIMFriend *)friendInfo;
@end

@interface V2NIMFriend : NSObject
/**
*  好友账号ID
*/
@property (nullable,nonatomic,strong) NSString *accountId;
/**
*  好友备注
*/
@property (nullable,nonatomic,strong) NSString *alias;

/**
*  用户扩展字段，建议使用json格式
*/
@property (nullable,nonatomic,strong) NSString *serverExtension;
/**
*  用户扩展字段，建议使用json格式
*/
@property (nullable,nonatomic,strong) NSString *customerExtension;
/**
*  好友信息创建时间
*/
@property (nonatomic,assign) NSTimeInterval createTime;
/**
*  好友信息更新时间
*/
@property (nonatomic,assign) NSTimeInterval updateTime;
/// 好友来源
@property (nonatomic,assign) UInt8 source;

@end

@interface V2NIMFriendAddParams : NSObject
/**
 * 添加好友模式
 *  
 */
@property (nonatomic, assign) V2NIMFriendAddMode addMode;
/**
 *  添加/申请添加好友的附言
 *
 */
@property (nullable,nonatomic,strong) NSString *postscript;

@end

@interface V2NIMFriendAddApplication : NSObject
/**
 *  操作者账号
 *
 */
@property (nullable,nonatomic,strong,readonly) NSString *operatorAccountId;
/**
 *  申请添加好友的附言
 *
 */
@property (nullable,nonatomic,strong,readonly) NSString *postscript;
/**
 *  操作的状态
 *
 */
@property (nonatomic, assign, readonly) V2NIMFriendAddApplicationStatus status;
/**
 *  操作的时间
 *
 */
@property (nonatomic,assign) NSTimeInterval timestamp;
@end

@interface V2NIMFriendDeleteParams : NSObject
/**
 *  是否同步删除前置设置的备注
 *
 */
@property (nonatomic, assign) BOOL deleteAlias;
@end

/**
 *  申请添加好友拒绝信息
 */
@interface V2NIMFriendAddRejection : NSObject
/**
 *  操作者账号
 *
 */
@property (nullable,nonatomic,strong) NSString *operatorAccountId;
/**
 *  操作时的附言
 *
 */
@property (nullable,nonatomic,strong) NSString *postscript;
/**
 *  操作的时间
 *
 */
@property (nonatomic,assign) NSTimeInterval timestamp;

@end
/**
 *  设置好友信息参数
 */
@interface V2NIMFriendSetParams : NSObject
/**
 *  设置的别名
 *  不传表示不设置
 *  为空表示清空别名
 */
@property (nullable,nonatomic,strong) NSString *alias;
/**
 *  设置的扩展字段
 *  不传表示不设置
 *  为空表示清空扩展字段
 */
@property (nullable,nonatomic,strong) NSString *serverExtension;
@end
/**
 *  申请添加好友相关信息查询参数
 */
@interface V2NIMFriendAddApplicationQueryOption : NSObject

/**
 * 首次传0， 下一次传上一次返回的offset，不包含offset
 */
@property (nonatomic,nonatomic,assign) NSUInteger offset;
/**
 * 每次查询的数量
 */
@property (nonatomic,nonatomic,assign) NSUInteger limit;
/**
 *  V2NIMFriendAddApplicationStatus 枚举值， 或者size为0， 表示查询所有状态否则按输入状态查询
 *
 */
@property (nonatomic, strong) NSArray <NSNumber *> *status;
@end

/**
 *  查询申请添加好友相关信息列表返回结构
 *
 */
@interface V2NIMFriendAddApplicationResult : NSObject

/**
 *  查询返回的列表
 *
 */
@property (nullable,nonatomic,strong,readonly) NSArray <V2NIMFriendAddApplication*> *infos;
/**
 *  下一次的偏移量
 *
 */
@property (nonatomic, assign,readonly) NSUInteger offset;

@property (nonatomic, assign,readonly) BOOL finished;
@end


NS_ASSUME_NONNULL_END
