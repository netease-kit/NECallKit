//
//  NIMQChatChannelManagerProtocol.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN

@class NIMQChatChannel;

@class NIMQChatCreateChannelParam;
@class NIMQChatDeleteChannelParam;
@class NIMQChatUpdateChannelParam;
@class NIMQChatGetChannelsParam;
@class NIMQChatGetChannelsByPageParam;
@class NIMQChatGetChannelMembersByPageParam;
@class NIMQChatGetChannelBlackWhiteRolesByPageParam;
@class NIMQChatGetChannelBlackWhiteMembersByPageParam;
@class NIMQChatUpdateChannelBlackWhiteRoleParam;
@class NIMQChatUpdateChannelBlackWhiteMembersParam;
@class NIMQChatGetExistingChannelBlackWhiteRolesParam;
@class NIMQChatGetExistingChannelBlackWhiteMembersParam;

@class NIMQChatGetChannelsResult;
@class NIMQChatGetChannelMembersByPageResult;
@class NIMQChatGetChannelBlackWhiteRolesByPageResult;
@class NIMQChatGetChannelBlackWhiteMembersByPageResult;

@class NIMQChatSubscribeChannelParam;
@class NIMQChatGetChannelUnreadInfosParam;
@class NIMQChatGetChannelUnreadInfosResult;
@class NIMQChatGetChannelsByPageResult;
@class NIMQChatGetExistingChannelBlackWhiteRolesResult;
@class NIMQChatGetExistingChannelBlackWhiteMembersResult;

@class NIMQChatServerRole;
@class NIMQChatServerMember;
@class NIMQChatChannelMember;

// 频道分组
@class NIMQChatCreateChannelCategoryParam;
@class NIMQChatUpdateChannelCategoryParam;
@class NIMQChatDeleteChannelCategoryParam;
@class NIMQChatGetChannelCategoriesParam;
@class NIMQChatGetChannelCategoryBlackWhiteRolesByPageParam;
@class NIMQChatGetChannelCategoryBlackWhiteMembersByPageParam;
@class NIMQChatUpdateChannelCategoryBlackWhiteRoleParam;
@class NIMQChatUpdateChannelCategoryBlackWhiteMembersParam;
@class NIMQChatGetExistingChannelCategoryBlackWhiteRolesParam;
@class NIMQChatGetExistingChannelCategoryBlackWhiteMembersParam;
@class NIMQChatGetChannelsInCategoryByPageParam;
@class NIMQChatGetCategoriesInServerByPageParam;

@class NIMQChatGetChannelCategoriesResult;
@class NIMQChatGetChannelCategoryMembersByPageResult;
@class NIMQChatGetChannelCategoryBlackWhiteRolesByPageResult;
@class NIMQChatGetChannelCategoryBlackWhiteMembersByPageResult;

@class NIMQChatGetExistingChannelCategoryBlackWhiteRolesResult;
@class NIMQChatGetExistingChannelCategoryBlackWhiteMembersResult;
@class NIMQChatGetChannelsInCategoryByPageResult;
@class NIMQChatGetCategoriesInServerByPageResult;
@class NIMQChatUpdateCategoryInfoOfChannelParam;

@class NIMQChatChannelCategory;
@class NIMQChatSearchChannelByPageResult;
@class NIMQChatSearchChannelByPageParam;
@class NIMQChatSubscribeChannelResult;
@class NIMQChatSubscribeChannelAsVisitorResult;
@class NIMQChatSubscribeChannelAsVisitorParam;

/**
 * 创建圈组频道的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatCreateChannelHandler)(NSError *__nullable error,
                                            NIMQChatChannel *__nullable result);

/**
 * 查询圈组频道信息的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetChannelsHandler)(NSError *__nullable error,
                                          NIMQChatGetChannelsResult *__nullable result);

/**
 * 分页查询圈组频道信息的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetChannelsByPageHandler)(NSError *__nullable error,
                                          NIMQChatGetChannelsByPageResult *__nullable result);

/**
 * 更新圈组频道信息的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatUpdateChannelHandler)(NSError *__nullable error,
                                            NIMQChatChannel *__nullable result);

/**
 * 更新圈组频道中所属频道分组信息的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatUpdateCategoryInfoOfChannelHandler)(NSError *__nullable error,
                                            NIMQChatChannel *__nullable result);

/**
 * 分页查询圈组频道成员的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetChannelMembersByPageHandler)(NSError *__nullable error,
                                          NIMQChatGetChannelMembersByPageResult *__nullable result);
/**
 * 分页查询频道黑白名单身份组列表的结果回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetChannelBlackWhiteRolesByPageHandler)(NSError *__nullable error,
                                          NIMQChatGetChannelBlackWhiteRolesByPageResult *__nullable result);

/**
 * 分页查询频道黑白名单成员列表的结果回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetChannelBlackWhiteMembersByPageHandler)(NSError *__nullable error,
                                          NIMQChatGetChannelBlackWhiteMembersByPageResult *__nullable result);
/**
 * 批量查询频道黑白名单身份组列表的结果回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetExistingChannelBlackWhiteRolesHandler)(NSError *__nullable error,
                                                         NIMQChatGetExistingChannelBlackWhiteRolesResult *__nullable result);
/**
 * 批量查询频道黑白名单成员列表的结果回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetExistingChannelBlackWhiteMembersHandler)(NSError *__nullable error,
                                                           NIMQChatGetExistingChannelBlackWhiteMembersResult *__nullable result);
/**
 * 查询未读信息的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetChannelUnreadInfosHandler)(NSError *__nullable error,
                                                    NIMQChatGetChannelUnreadInfosResult *__nullable result);
/**
 * 创建圈组频道分组的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatCreateChannelCategoryHandler)(NSError *__nullable error,
                                            NIMQChatChannelCategory *__nullable result);

/**
 * 更新圈组频道分组信息的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatUpdateChannelCategoryHandler)(NSError *__nullable error,
                                            NIMQChatChannelCategory *__nullable result);

/**
 * 查询圈组频道分组信息的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetChannelCategoriesHandler)(NSError *__nullable error,
                                          NIMQChatGetChannelCategoriesResult *__nullable result);

/**
 * 分页查询频道分组黑白名单身份组列表的结果回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetChannelCategoryBlackWhiteRolesByPageHandler)(NSError *__nullable error,
                                          NIMQChatGetChannelCategoryBlackWhiteRolesByPageResult *__nullable result);

/**
 * 分页查询频道分组黑白名单成员列表的结果回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetChannelCategoryBlackWhiteMembersByPageHandler)(NSError *__nullable error,
                                          NIMQChatGetChannelCategoryBlackWhiteMembersByPageResult *__nullable result);
/**
 * 批量查询频道分组黑白名单身份组列表的结果回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetExistingChannelCategoryBlackWhiteRolesHandler)(NSError *__nullable error,
                                                         NIMQChatGetExistingChannelCategoryBlackWhiteRolesResult *__nullable result);
/**
 * 批量查询频道分组黑白名单成员列表的结果回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetExistingChannelCategoryBlackWhiteMembersHandler)(NSError *__nullable error,
                                                           NIMQChatGetExistingChannelCategoryBlackWhiteMembersResult *__nullable result);

/**
 * 分页查询频道分组中频道信息的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetChannelsInCategoryByPageHandler)(NSError *__nullable error,
                                          NIMQChatGetChannelsInCategoryByPageResult *__nullable result);

/**
 * 分页查询服务器内频道分组的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetCategoriesInServerByPageHandler)(NSError *__nullable error,
                                          NIMQChatGetCategoriesInServerByPageResult *__nullable result);

/**
 *  分页检索频道信息回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatSearchChannelByPageHandler)(NSError *__nullable error, NIMQChatSearchChannelByPageResult *__nullable result);

/**
 *  订阅频道的结果回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatSubscribeChannelHandler)(NSError *__nullable error, NIMQChatSubscribeChannelResult *__nullable result);

/**
 *  以游客身份订阅频道的结果回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatSubscribeChannelAsVisitorHandler)(NSError *__nullable error, NIMQChatSubscribeChannelAsVisitorResult *__nullable result);

/**
 *   圈组频道管理器回调
 */
@protocol NIMQChatChannelManagerDelegate <NSObject>

@optional

@end

/**
 *  圈组频道管理器
 */
@protocol NIMQChatChannelManager <NSObject>
/**
 * 创建圈组频道
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)createChannel:(NIMQChatCreateChannelParam *)param
           completion:(nullable NIMQChatCreateChannelHandler)completion;

/**
 * 删除圈组频道
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)deleteChannel:(NIMQChatDeleteChannelParam *)param
           completion:(nullable NIMQChatHandler)completion;

/**
 * 修改圈组频道信息
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)updateChannel:(NIMQChatUpdateChannelParam *)param
           completion:(nullable NIMQChatUpdateChannelHandler)completion;

/**
 * 修改圈组频道中所属分组相关信息
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)updateCategoryInfoOfChannel:(NIMQChatUpdateCategoryInfoOfChannelParam *)param
           completion:(nullable NIMQChatUpdateCategoryInfoOfChannelHandler)completion;

/**
 * 查询圈组频道信息
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getChannels:(NIMQChatGetChannelsParam *)param
         completion:(nullable NIMQChatGetChannelsHandler)completion;

/**
 * 分页查询圈组频道信息
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getChannelsByPage:(NIMQChatGetChannelsByPageParam *)param
               completion:(nullable NIMQChatGetChannelsByPageHandler)completion;

/**
 * 订阅频道请求
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)subscribeChannel:(NIMQChatSubscribeChannelParam *)param
             completion:(nullable NIMQChatSubscribeChannelHandler)completion;

/**
 * 查询未读信息
 */
- (void)getChannelUnreadInfos:(NIMQChatGetChannelUnreadInfosParam *)param
                   completion:(nullable NIMQChatGetChannelUnreadInfosHandler)completion;

/**
 * 分页查询圈组频道成员
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getChannelMembersByPage:(NIMQChatGetChannelMembersByPageParam *)param
               completion:(nullable NIMQChatGetChannelMembersByPageHandler)completion;

/**
 * 分页查询频道黑白名单成员列表
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getBlackWhiteMembersByPage:(NIMQChatGetChannelBlackWhiteMembersByPageParam *)param
               completion:(nullable NIMQChatGetChannelBlackWhiteMembersByPageHandler)completion;

/**
 * 更新频道黑白名单成员
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)updateBlackWhiteMembers:(NIMQChatUpdateChannelBlackWhiteMembersParam *)param
               completion:(nullable NIMQChatHandler)completion;

/**
 * 分页查询频道黑白名单身份组列表
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getBlackWhiteRolesByPage:(NIMQChatGetChannelBlackWhiteRolesByPageParam *)param
               completion:(nullable NIMQChatGetChannelBlackWhiteRolesByPageHandler)completion;

/**
 * 更新频道黑白名单身份组
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)updateBlackWhiteRole:(NIMQChatUpdateChannelBlackWhiteRoleParam *)param
               completion:(nullable NIMQChatHandler)completion;

/**
 * 批量查询频道黑白名单身份组列表
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getExistingChannelBlackWhiteRoles:(NIMQChatGetExistingChannelBlackWhiteRolesParam *)param
               completion:(nullable NIMQChatGetExistingChannelBlackWhiteRolesHandler)completion;
/**
 * 批量查询频道黑白名单成员列表
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getExistingChannelBlackWhiteMembers:(NIMQChatGetExistingChannelBlackWhiteMembersParam *)param
               completion:(nullable NIMQChatGetExistingChannelBlackWhiteMembersHandler)completion;

#pragma mark -- 频道分组 --

/**
 * 创建圈组频道分组
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)createChannelCategory:(NIMQChatCreateChannelCategoryParam *)param
           completion:(nullable NIMQChatCreateChannelCategoryHandler)completion;

/**
 * 删除圈组频道分组
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)deleteChannelCategory:(NIMQChatDeleteChannelCategoryParam *)param
           completion:(nullable NIMQChatHandler)completion;

/**
 * 修改圈组频道分组信息
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)updateChannelCategory:(NIMQChatUpdateChannelCategoryParam *)param
           completion:(nullable NIMQChatUpdateChannelCategoryHandler)completion;

/**
 * 查询圈组频道分组信息
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getChannelCategories:(NIMQChatGetChannelCategoriesParam *)param
         completion:(nullable NIMQChatGetChannelCategoriesHandler)completion;

/**
 * 分页查询频道分组黑白名单成员列表
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getChannelCategoryBlackWhiteMembersByPage:(NIMQChatGetChannelCategoryBlackWhiteMembersByPageParam *)param
               completion:(nullable NIMQChatGetChannelCategoryBlackWhiteMembersByPageHandler)completion;

/**
 * 更新频道分组黑白名单成员
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)updateChannelCategoryBlackWhiteMembers:(NIMQChatUpdateChannelCategoryBlackWhiteMembersParam *)param
               completion:(nullable NIMQChatHandler)completion;

/**
 * 分页查询频道分组黑白名单身份组列表
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getChannelCategoryBlackWhiteRolesByPage:(NIMQChatGetChannelCategoryBlackWhiteRolesByPageParam *)param
               completion:(nullable NIMQChatGetChannelCategoryBlackWhiteRolesByPageHandler)completion;

/**
 * 更新频道分组黑白名单身份组
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)updateChannelCategoryBlackWhiteRole:(NIMQChatUpdateChannelCategoryBlackWhiteRoleParam *)param
               completion:(nullable NIMQChatHandler)completion;

/**
 * 批量查询频道分组黑白名单身份组列表
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getExistingChannelCategoryBlackWhiteRoles:(NIMQChatGetExistingChannelCategoryBlackWhiteRolesParam *)param
               completion:(nullable NIMQChatGetExistingChannelCategoryBlackWhiteRolesHandler)completion;
/**
 * 批量查询频道分组黑白名单成员列表
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getExistingChannelCategoryBlackWhiteMembers:(NIMQChatGetExistingChannelCategoryBlackWhiteMembersParam *)param
               completion:(nullable NIMQChatGetExistingChannelCategoryBlackWhiteMembersHandler)completion;
/**
 * 分页查询频道分组内频道信息
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getChannelsInCategoryByPage:(NIMQChatGetChannelsInCategoryByPageParam *)param
               completion:(nullable NIMQChatGetChannelsInCategoryByPageHandler)completion;

 /**
 * 分页查询服务器内频道分组
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getCategoriesInServerByPage:(NIMQChatGetCategoriesInServerByPageParam *)param
               completion:(nullable NIMQChatGetCategoriesInServerByPageHandler)completion;

/**
 * 检索频道列表
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)searchChannelByPage:(NIMQChatSearchChannelByPageParam *)param completion:(nullable NIMQChatSearchChannelByPageHandler) completion;

/**
 * 以游客身份订阅频道
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)subscribeAsVisitor:(nonnull NIMQChatSubscribeChannelAsVisitorParam*)param
                completion:(nullable NIMQChatSubscribeChannelAsVisitorHandler)completion;

/**
 *  添加通知对象
 *
 *  @param delegate 通知对象
 */
- (void)addDelegate:(id<NIMQChatChannelManagerDelegate>)delegate;

/**
 *  移除通知对象
 *
 *  @param delegate 通知对象
 */
- (void)removeDelegate:(id<NIMQChatChannelManagerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
