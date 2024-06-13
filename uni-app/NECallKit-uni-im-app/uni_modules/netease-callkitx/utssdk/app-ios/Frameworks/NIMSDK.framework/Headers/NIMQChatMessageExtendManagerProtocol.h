//
//  NIMQChatMessageExtendManagerProtocol.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatMessageManagerProtocol.h"
#import "NIMQChatMessage.h"

@class NIMQChatGetThreadMessagesParam;
@class NIMQChatGetThreadMessagesResult;

@class NIMQChatUpdateQuickCommentInfo;
@class NIMQChatFetchQuickCommentsByMsgsResult;
@class NIMQChatMessageThreadInfo;

NS_ASSUME_NONNULL_BEGIN

/**
 * 拉取thread消息的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetThreadMessagesHandler)(NSError *__nullable error, NIMQChatGetThreadMessagesResult *__nullable result);

/**
 * 拉取消息Thread信息的回调
 *
 * @param error 错误信息
 * @param result 回调结果 [消息的messageId: NIMQChatMessageThreadInfo]
 */
typedef void(^NIMQChatBatchGetMessageThreadInfoHandler)(NSError *__nullable error, NSDictionary <NSString *, NIMQChatMessageThreadInfo *> *__nullable result);

/**
 *   圈组消息扩展管理器回调
 */
@protocol NIMQChatMessageExtendManagerDelegate <NSObject>

@optional

@end


/**
 *  批量获取快捷评论回调
 *
 *  @param error 结果
 *  @param result 获取结果

 */
typedef void (^NIMQChatFetchQuickCommentsByMsgsHandler) (NSError * _Nullable  error, NIMQChatFetchQuickCommentsByMsgsResult * _Nullable result);

/**
 *  圈组消息扩展管理器
 */
@protocol NIMQChatMessageExtendManager <NSObject>

#pragma mark - Thread Message

/**
 *  回复消息
 *
 *  @param message 新生成的消息
 *  @param target  被回复的消息
 *  @param error   错误 如果在准备发送消息阶段发生错误,这个error会被填充相应的信息
 *
 *  @return 是否调用成功,这里返回的 result 只是表示当前这个函数调用是否成功,需要后续的回调才能够判断消息是否已经发送至服务器
 */
- (BOOL)reply:(NIMQChatMessage *)message
           to:(NIMQChatMessage *)target
        error:(NSError * __nullable *)error;

/**
 *  异步回复消息
 *
 *  @param message  新生成的消息
 *  @param target   被回复的消息
 *  @param completion    发送完成后的回调，这里的回调完成只表示当前这个函数调用完成，需要后续的回调才能判断消息是否已经发送至服务器
 */
- (void)reply:(NIMQChatMessage *)message
           to:(NIMQChatMessage *)target
   completion:(__nullable NIMQChatHandler)completion;

/**
 * 从服务端查询引用的消息
 *
 * @param message  消息
 * @param type 引用类型
 * @param completion 结果回调
 */
- (void)getReferMessages:(NIMQChatMessage *)message
                    type:(NIMQChatMessageReferType)type
              completion:(nullable NIMQChatGetMessageHistoryHandler)completion;

/**
 * 从服务端查询Thread的所有消息
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getThreadMessages:(NIMQChatGetThreadMessagesParam *)param
               completion:(nullable NIMQChatGetThreadMessagesHandler)completion;

/**
 *  批量从服务端查询消息Thread的meta信息
 *
 * @param param 传入参数，消息数组
 * @param completion 结果回调
 */
- (void)batchGetMessageThreadInfo:(NSArray <NIMQChatMessage *> *)param
               completion:(nullable NIMQChatBatchGetMessageThreadInfoHandler)completion;


#pragma mark - Quick Comment
/**
 *  发送快捷评论
 *
 *  @param type         评论类型
 *  @param message      被评论消息
 *  @param completion   完成回调
 */
- (void)addQuickCommentType:(int64_t)type
                  toMessage:(NIMQChatMessage *)message
                 completion:(NIMQChatHandler _Nullable)completion;

/**
 *  从服务端删除一条评论
 *
 *  @param type         评论类型
 *  @param message      被评论消息
 *  @param completion   完成回调
 */
- (void)deleteQuickCommentType:(int64_t)type
                     toMessage:(NIMQChatMessage *)message
                    completion:(NIMQChatHandler _Nullable)completion;

/**
 *  批量获取快捷评论
 *
 *  @param messages 参数，消息列表，必须为同一个频道内的消息
 *  @param completion 完成回调
 */
- (void)fetchQuickComments:(NSArray <NIMQChatMessage *> *)messages
                completion:(NIMQChatFetchQuickCommentsByMsgsHandler)completion;


/**
 *  添加通知对象
 *
 *  @param delegate 通知对象
 */
- (void)addDelegate:(id<NIMQChatMessageExtendManagerDelegate>)delegate;

/**
 *  移除通知对象
 *
 *  @param delegate 通知对象
 */
- (void)removeDelegate:(id<NIMQChatMessageExtendManagerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
