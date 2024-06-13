//
//  NIMQChatRoleManagerProtocol.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN

@class NIMQChatCreateServerRoleParam;
@class NIMQChatDeleteServerRoleParam;
@class NIMQChatUpdateServerRoleParam;
@class NIMQChatGetServerRolesParam;
@class NIMQChatAddChannelRoleParam;
@class NIMQChatRemoveChannelRoleParam;
@class NIMQChatUpdateChannelRoleParam;
@class NIMQChatGetChannelRolesParam;
@class NIMQChatAddMemberRoleParam;
@class NIMQChatRemoveMemberRoleParam;
@class NIMQChatUpdateMemberRoleParam;
@class NIMQChatGetMemberRolesParam;
@class NIMQChatAddServerRoleMembersParam;
@class NIMQChatRemoveServerRoleMemberParam;
@class NIMQChatGetServerRoleMembersParam;
@class NIMQChatGetServerRolesByAccidParam;
@class NIMQChatGetExistingAccidsInServerRoleParam;
@class NIMQChatGetExistingChannelRolesByServerRoleIdsParam;
@class NIMQChatGetExistingAccidsOfMemberRolesParam;
@class NIMQChatupdateServerRolePrioritiesParam;
@class NIMQChatGetExistingServerRoleMembersByAccidsParam;
@class NIMQChatCheckPermissionParam;
@class NIMQChatCheckPermissionsParam;

@class NIMQChatServerRole;
@class NIMQChatGetServerRolesResult;
@class NIMQChatChannelRole;
@class NIMQChatGetChannelRolesResult;
@class NIMQChatMemberRole;
@class NIMQChatGetMemberRolesResult;
@class NIMQChatGetServerRoleMembersResult;
@class NIMQChatAddServerRoleMembersResult;
@class NIMQChatRemoveServerRoleMembersResult;
@class NIMQChatGetServerRolesByAccidResult;
@class NIMQChatGetExistingAccidsInServerRoleResult;
@class NIMQChatGetExistingAccidsInServerRoleResult;
@class NIMQChatGetExistingChannelRolesByServerRoleIdsResult;
@class NIMQChatGetExistingAccidsOfMemberRolesResult;
@class NIMQChatupdateServerRolePrioritiesResult;
@class NIMQChatGetExistingServerRoleMembersByAccidsResult;
@class NIMQChatCheckPermissionsResult;



typedef NIMQChatHandler NIMQChatDeleteServerRoleHandler;
typedef NIMQChatHandler NIMQChatRemoveChannelRoleHandler;
typedef NIMQChatHandler NIMQChatRemoveMemberRoleHandler;


@class NIMQChatAddChannelCategoryRoleParam;
@class NIMQChatRemoveChannelCategoryRoleParam;
@class NIMQChatUpdateChannelCategoryRoleParam;
@class NIMQChatGetChannelCategoryRolesParam;
@class NIMQChatAddChannelCategoryMemberRoleParam;
@class NIMQChatRemoveChannelCategoryMemberRoleParam;
@class NIMQChatUpdateChannelCategoryMemberRoleParam;
@class NIMQChatGetChannelCategoryMemberRolesParam;

@class NIMQChatChannelCategoryRole;
@class NIMQChatChannelCategoryMemberRole;
@class NIMQChatGetChannelCategoryRolesResult;
@class NIMQChatGetChannelCategoryMemberRolesResult;

typedef NIMQChatHandler NIMQChatRemoveChannelCategoryRoleHandler;
typedef NIMQChatHandler NIMQChatRemoveChannelCategoryMemberRoleHandler;

/**
 * 创建服务器身份组的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatCreateServerRoleHandler)(NSError *__nullable error, NIMQChatServerRole *__nullable result);

/**
 * 更新服务器身份组的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatUpdateServerRoleHandler)(NSError *__nullable error, NIMQChatServerRole *__nullable result);

/**
 * 查询服务器下身份组列表的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetServerRolesHandler)(NSError *__nullable error, NIMQChatGetServerRolesResult *__nullable result);

/**
 * 将某身份组加入某频道的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatAddChannelRoleHandler)(NSError *__nullable error, NIMQChatChannelRole *__nullable result);

/**
 * 更新某身份组加入某频道的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatUpdateChannelRoleHandler)(NSError *__nullable error, NIMQChatChannelRole *__nullable result);

/**
 * 查询某频道下的身份组信息列表的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetChannelRolesHandler)(NSError *__nullable error, NIMQChatGetChannelRolesResult *__nullable result);

/**
 * 为某个人定制某频道的权限的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatAddMemberRoleHandler)(NSError *__nullable error, NIMQChatMemberRole *__nullable result);

/**
 * 更新某个人定制某频道的权限的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatUpdateMemberRoleHandler)(NSError *__nullable error, NIMQChatMemberRole *__nullable result);

/**
 * 查询channel下人的定制权限的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetMemberRolesHandler)(NSError *__nullable error, NIMQChatGetMemberRolesResult *__nullable result);

/**
 * 查询某服务器下某身份组下的成员列表的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetServerRoleMembersHandler)(NSError *__nullable error, NIMQChatGetServerRoleMembersResult *__nullable result);

/**
 * 通过accid查询自定义身份组列表的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetServerRolesByAccidHandler)(NSError *__nullable error, NIMQChatGetServerRolesByAccidResult *__nullable result);

/**
 * 将某些人加入某服务器身份组的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatAddServerRoleMembersHandler)(NSError *__nullable error, NIMQChatAddServerRoleMembersResult *__nullable result);

/**
 * 将某些人移除某服务器身份组的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatRemoveServerRoleMembersHandler)(NSError *__nullable error, NIMQChatRemoveServerRoleMembersResult *__nullable result);

/**
 * 查询一批accids的自定义身份组列表的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetExistingAccidsInServerRoleHandler)(NSError *__nullable error, NIMQChatGetExistingAccidsInServerRoleResult *__nullable result);

/**
 * 查询一批服务器身份组在频道中的身份组信息的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetExistingChannelRolesByServerRoleIdsHandler)(NSError *__nullable error, NIMQChatGetExistingChannelRolesByServerRoleIdsResult *__nullable result);

/**
 * 查询一批accids在频道中配置了权限的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetExistingAccidsOfMemberRolesHandler)(NSError *__nullable error, NIMQChatGetExistingAccidsOfMemberRolesResult *__nullable result);

/**
 * 批量更新服务器身份组的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatupdateServerRolePrioritiesHandler)(NSError *__nullable error, NIMQChatupdateServerRolePrioritiesResult *__nullable result);

/**
 * 查询一批accids是否在某个服务器身份组的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetExistingServerRoleMembersByAccidsHandler)(NSError *__nullable error, NIMQChatGetExistingServerRoleMembersByAccidsResult *__nullable result);
/**
 * 查询自己是否有某个权限的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatCheckPermissionHandler)(NSError *__nullable error, BOOL result);


#pragma mark - 频道分组
/**
 * 将某身份组加入某频道分组的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatAddChannelCategoryRoleHandler)(NSError *__nullable error, NIMQChatChannelCategoryRole *__nullable result);

/**
 * 更新某身份组加入某频道分组的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatUpdateChannelCategoryRoleHandler)(NSError *__nullable error, NIMQChatChannelCategoryRole *__nullable result);

/**
 * 查询某频道分组下的身份组信息列表的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetChannelCategoryRolesHandler)(NSError *__nullable error, NIMQChatGetChannelCategoryRolesResult *__nullable result);

/**
 * 为某个人定制某频道分组的权限的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatAddChannelCategoryMemberRoleHandler)(NSError *__nullable error, NIMQChatChannelCategoryMemberRole *__nullable result);

/**
 * 更新某个人定制某频道分组的权限的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatUpdateChannelCategoryMemberRoleHandler)(NSError *__nullable error, NIMQChatChannelCategoryMemberRole *__nullable result);

/**
 * 获取channel分组下人的定制权限的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetChannelCategoryMemberRolesHandler)(NSError *__nullable error, NIMQChatGetChannelCategoryMemberRolesResult *__nullable result);
/**
 * 查询自己是否有某些权限的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatCheckPermissionsHandler)(NSError *__nullable error, NIMQChatCheckPermissionsResult *__nullable result);
/**
 *   圈组身份组管理器回调
 */
@protocol NIMQChatRoleManagerDelegate <NSObject>

@optional

@end

/**
 *  圈组身份组管理器
 */
@protocol NIMQChatRoleManager <NSObject>
/**
 * 创建服务器身份组
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)createServerRole:(NIMQChatCreateServerRoleParam *)param
                  completion:(nullable NIMQChatCreateServerRoleHandler)completion;

/**
 * 删除服务器身份组
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)deleteServerRole:(NIMQChatDeleteServerRoleParam *)param
                  completion:(nullable NIMQChatDeleteServerRoleHandler)completion;

/**
 * 更新服务器身份组
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)updateServerRole:(NIMQChatUpdateServerRoleParam *)param
                  completion:(nullable NIMQChatUpdateServerRoleHandler)completion;

/**
 * 获取服务器身份组
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getServerRoles:(NIMQChatGetServerRolesParam *)param
                 completion:(nullable NIMQChatGetServerRolesHandler)completion;

/**
 * 将某身份组加入某频道
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)addChannelRole:(NIMQChatAddChannelRoleParam *)param
                   completion:(nullable NIMQChatAddChannelRoleHandler)completion;

/**
 * 删除某频道下的某身份组
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)removeChannelRole:(NIMQChatRemoveChannelRoleParam *)param
                   completion:(nullable NIMQChatRemoveChannelRoleHandler)completion;

/**
 * 修改频道下某身份组的权限
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)updateChannelRole:(NIMQChatUpdateChannelRoleParam *)param
                   completion:(nullable NIMQChatUpdateChannelRoleHandler)completion;

/**
 * 查询某频道下的身份组信息列表
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getChannelRoles:(NIMQChatGetChannelRolesParam *)param
                  completion:(nullable NIMQChatGetChannelRolesHandler)completion;

/**
 * 为某个人定制某频道的权限
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)addMemberRole:(NIMQChatAddMemberRoleParam *)param
                completion:(nullable NIMQChatAddMemberRoleHandler)completion;

/**
 * 删除频道下某人的定制权限
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)removeMemberRole:(NIMQChatRemoveMemberRoleParam *)param
                completion:(nullable NIMQChatRemoveMemberRoleHandler)completion;

/**
 * 修改某人的定制权限
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)updateMemberRole:(NIMQChatUpdateMemberRoleParam *)param
                completion:(nullable NIMQChatUpdateMemberRoleHandler)completion;

/**
 * 查询channel下人的定制权限
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getMemberRoles:(NIMQChatGetMemberRolesParam *)param
               completion:(nullable NIMQChatGetMemberRolesHandler)completion;

#pragma mark - 频道分组
/**
 * 将某身份组加入某频道分组
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)addChannelCategoryRole:(NIMQChatAddChannelCategoryRoleParam *)param
                   completion:(nullable NIMQChatAddChannelCategoryRoleHandler)completion;

/**
 * 删除某频道分组下的某身份组
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)removeChannelCategoryRole:(NIMQChatRemoveChannelCategoryRoleParam *)param
                   completion:(nullable NIMQChatRemoveChannelCategoryRoleHandler)completion;

/**
 * 修改频道分组下某身份组的权限
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)updateChannelCategoryRole:(NIMQChatUpdateChannelCategoryRoleParam *)param
                   completion:(nullable NIMQChatUpdateChannelCategoryRoleHandler)completion;

/**
 * 查询某频道分组下的身份组信息列表
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getChannelCategoryRoles:(NIMQChatGetChannelCategoryRolesParam *)param
                  completion:(nullable NIMQChatGetChannelCategoryRolesHandler)completion;

/**
 * 为某个人定制某频道分组的权限
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)addChannelCategoryMemberRole:(NIMQChatAddChannelCategoryMemberRoleParam *)param
                completion:(nullable NIMQChatAddChannelCategoryMemberRoleHandler)completion;

/**
 * 删除频道分组下某人的定制权限
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)removeChannelCategoryMemberRole:(NIMQChatRemoveChannelCategoryMemberRoleParam *)param
                completion:(nullable NIMQChatRemoveChannelCategoryMemberRoleHandler)completion;

/**
 * 修改频道分组某人的定制权限
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)updateChannelCategoryMemberRole:(NIMQChatUpdateChannelCategoryMemberRoleParam *)param
                completion:(nullable NIMQChatUpdateChannelCategoryMemberRoleHandler)completion;

/**
 * 查询频道分组下人的定制权限
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getChannelCategoryMemberRoles:(NIMQChatGetChannelCategoryMemberRolesParam *)param
               completion:(nullable NIMQChatGetChannelCategoryMemberRolesHandler)completion;

#pragma mark -服务器身份组
/**
 * 将某些人加入某服务器身份组
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)addServerRoleMembers:(NIMQChatAddServerRoleMembersParam *)param
                        completion:(nullable NIMQChatAddServerRoleMembersHandler)completion;

/**
 * 将某些人移除某服务器身份组
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)removeServerRoleMember:(NIMQChatRemoveServerRoleMemberParam *)param
                        completion:(nullable NIMQChatRemoveServerRoleMembersHandler)completion;

/**
 * 查询某服务器下某身份组下的成员列表
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getServerRoleMembers:(NIMQChatGetServerRoleMembersParam *)param
                      completion:(nullable NIMQChatGetServerRoleMembersHandler)completion;

/**
 * 通过accid查询自定义身份组列表
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getServerRolesByAccid:(NIMQChatGetServerRolesByAccidParam *)param
                     completion:(nullable NIMQChatGetServerRolesByAccidHandler)completion;
/**
 * 查询一批accids的自定义身份组列表
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getExistingAccidsInServerRole:(NIMQChatGetExistingAccidsInServerRoleParam *)param
                     completion:(nullable NIMQChatGetExistingAccidsInServerRoleHandler)completion;

/**
 * 查询一批服务器身份组在频道中的身份组信息，只会返回存在的
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getExistingChannelRolesByServerRoleIds:(NIMQChatGetExistingChannelRolesByServerRoleIdsParam *)param
                     completion:(nullable NIMQChatGetExistingChannelRolesByServerRoleIdsHandler)completion;

/**
 * 查询一批accids在频道中配置了权限的，只会返回存在的
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getExistingAccidsOfMemberRoles:(NIMQChatGetExistingAccidsOfMemberRolesParam *)param
                     completion:(nullable NIMQChatGetExistingAccidsOfMemberRolesHandler)completion;

/**
 * 批量更新服务器身份组的权限优先级
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)updateServerRolePriorities:(NIMQChatupdateServerRolePrioritiesParam *)param
                     completion:(nullable NIMQChatupdateServerRolePrioritiesHandler)completion;
/**
* 查询一批accids是否在某个服务器身份组,返回在的成员信息
*
* @param param 传入参数
* @param completion 结果回调
*/
- (void)getExistingServerRoleMembersByAccids:(NIMQChatGetExistingServerRoleMembersByAccidsParam *)param
                    completion:(nullable NIMQChatGetExistingServerRoleMembersByAccidsHandler)completion;
/**
 * 查询自己是否有某个权限
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)checkPermission:(NIMQChatCheckPermissionParam *)param
                    completion:(nullable NIMQChatCheckPermissionHandler)completion;

/**
 * 查询自己是否拥有某些权限
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)checkPermissions:(NIMQChatCheckPermissionsParam *)param
                      completion:(nullable NIMQChatCheckPermissionsHandler)completion;
/**
 *  添加通知对象
 *
 *  @param delegate 通知对象
 */
- (void)addDelegate:(id<NIMQChatRoleManagerDelegate>)delegate;

/**
 *  移除通知对象
 *
 *  @param delegate 通知对象
 */
- (void)removeDelegate:(id<NIMQChatRoleManagerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
