//
//  V2NIMUserServiceProtocol.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/10/26.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "V2NIMBase.h"

@class V2NIMUser;
@class V2NIMUserUpdateParams;
@protocol V2NIMUserListener;

NS_ASSUME_NONNULL_BEGIN

typedef void (^V2NIMGetUserListSuccess)(NSArray <V2NIMUser *> *result);

typedef void (^V2NIMGetBlockListSuccess)(NSArray <NSString *> *result);

@protocol V2NIMUserService <NSObject>
/**
 *  根据用户账号列表获取用户资料
 *
 *  @param accountIds 需要获取用户资料的账号列表 List为空， 或者size==0， 返回参数错误  注释写，单次最大150， 500以内不做强制校验，大于500返回参数错误
 *  @param success  获取列表成功的回调
 *  @param failure  获取列表失败的回调
 */
- (void)getUserList:(NSArray<NSString *> *)accountIds
            success:(nullable V2NIMGetUserListSuccess)success
            failure:(nullable V2NIMFailureCallback)failure;
/**
 *  更新自己的用户资料
 *
 *  @param updateParams 更新自己的用户资料参数
 *  @param success  更新用户资料成功的回调
 *  @param failure  更新用户资料失败的回调
 */
- (void)updateSelfUserProfile:(V2NIMUserUpdateParams *)updateParams
                      success:(nullable V2NIMSuccessCallback)success
                      failure:(nullable V2NIMFailureCallback)failure;

/**
 *  添加用户到黑名单中
 *
 *  @param accountId 需要添加进黑名单的用户ID
 *  @param success  添加成功的回调
 *  @param failure  添加失败的回调
 */
- (void)addUserToBlockList:(NSString *)accountId
                   success:(nullable V2NIMSuccessCallback)success
                   failure:(nullable V2NIMFailureCallback)failure;

/**
 *  从黑名单中移除用户
 *
 *  @param accountId 需要移除黑名单的用户ID
 *  @param success  移除成功的回调
 *  @param failure  移除失败的回调
 */
- (void)removeUserFromBlockList:(NSString *)accountId
                        success:(nullable V2NIMSuccessCallback)success
                        failure:(nullable V2NIMFailureCallback)failure;
/**
 *  获取黑名单列表
 *
 *  @param success  获取列表成功的回调
 *  @param failure  获取列表失败的回调
 */
- (void)getBlockList:(nullable V2NIMGetBlockListSuccess)success
             failure:(nullable V2NIMFailureCallback)failure;


/**
* 添加用户资料监听器
*
* @param listener 消息监听回调
*/
- (void)addUserListener:(id<V2NIMUserListener>)listener;

/**
* 移除用户资料监听器
*
* @param listener 消息监听回调
*/
- (void)removeUserListener:(id<V2NIMUserListener>)listener;

@end

/**
* 用户资料监听回调
*
*/
@protocol V2NIMUserListener <NSObject>
/**
 * 用户信息变更回调
 *
 * - Parameter users: 收到内容
 */
- (void)onUserProfileChanged:(NSArray <V2NIMUser *> *)users;
/**
 * 黑名单添加通知
 *
 * - Parameter user: 加入黑名单用户
 */
- (void)onBlockListAdded:(V2NIMUser*)user;
/**
 * 黑名单移除通知
 * - Parameter accountId: 移除黑名的用户账号ID
 */
- (void)onBlockListRemoved:(NSString *)accountId;

@end

/**
 *  用户性别
 */
typedef NS_ENUM(NSInteger, V2NIMGender) {
    /**
     *  未知性别
     */
    V2NIM_GENDER_UNKNOWN = 0,
    /**
     *  性别男
     */
    V2NIM_GENDER_MALE,
    /**
     *  性别女
     */
    V2NIM_GENDER_FEMALE,
};

/**
 *  云信用户
 */
@interface V2NIMUser : NSObject

/**
 *  账号ID
 */
@property (nullable,nonatomic,strong) NSString *accountId;

/**
 *  用户昵称
 */
@property (nullable,nonatomic,strong) NSString *name;

/**
 *  用户头像图片地址
 *  长度限制：1024字节
 */
@property (nullable,nonatomic,strong)   NSString  *avatar;

/**
 *  用户签名
 *
 */
@property (nullable,nonatomic,strong)   NSString  *sign;

/**
 *  用户邮箱
 */
@property (nullable,nonatomic,strong)   NSString  *email;
/**
 *  用户邮箱
 */
@property (nullable,nonatomic,strong)   NSString  *birthday;
/**
 *  用户邮箱
 */
@property (nullable,nonatomic,strong)   NSString  *mobile;
/**
 *  用户性别
 */
@property (nonatomic, assign)   NSInteger gender;

/**
 *  用户扩展字段，建议使用json格式
 */
@property (nullable,nonatomic,strong) NSString  *serverExtension;
/**
 *  用户资料创建时间
 */
@property (nonatomic, assign)   NSTimeInterval createTime;
/**
 *  用户资料更新时间
 */
@property (nonatomic, assign)   NSTimeInterval updateTime;

@end

/**
 *  好友请求
 */
@interface V2NIMUserUpdateParams : NSObject
/**
 *  用户昵称
 */
@property (nullable,nonatomic,strong) NSString *name;

/**
 *  用户头像图片地址
 */
@property (nullable,nonatomic,strong) NSString *avatar;

/**
 *  用户签名
 */
@property (nullable,nonatomic,strong) NSString *sign;

/**
 *  用户邮箱
 */
@property (nullable,nonatomic,strong) NSString *email;
/**
 *  用户生日
 */
@property (nullable,nonatomic,strong) NSString *birthday;
/**
 *  电话号码
 */
@property (nullable,nonatomic,strong) NSString *mobile;

/**
 *  用户性别
 */
@property (nonatomic,assign) V2NIMGender gender;

/**
 *  用户扩展字段，建议使用json格式
 */
@property (nullable,nonatomic,strong) NSString *serverExtension;

@end
NS_ASSUME_NONNULL_END
