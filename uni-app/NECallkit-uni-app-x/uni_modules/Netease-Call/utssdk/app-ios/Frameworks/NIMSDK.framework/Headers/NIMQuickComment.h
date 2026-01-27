//
//  NIMQuickComment.h
//  NIMLib
//
//  Created by He on 2020/4/8.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMChatExtendBasicInfo;
@class NIMQuickCommentSetting;
@class NIMMessage;

NS_ASSUME_NONNULL_BEGIN


/**
 *  快捷评论
 */
@interface NIMQuickComment : NSObject <NSCopying>
/**
 *  评论发送方
 */
@property (nonatomic,copy,readonly) NSString *from;

/**
 *  类型
 *  @discussion 对同一条消息回复相同的replyType将会覆盖之前的回复
 */
@property (nonatomic,assign) int64_t replyType;

/**
 *  回复时间
 */
@property (nonatomic,assign,readonly) NSTimeInterval timestamp;

/**
 *  自定义扩展字段，最大16字符
 */
@property (nonatomic,copy,nullable) NSString *ext;

/**
 *  评论设置
 */
@property (nonatomic,strong,nullable) NIMQuickCommentSetting *setting;
/**
 *  评论所在的消息
 */
@property (nonatomic,strong,readonly) NIMMessage *message;
/**
 *  评论所在消息的元信息
 */
@property (nonatomic,strong,readonly) NIMChatExtendBasicInfo *basicInfo;


@end

/**
 * 快捷评论推送设置
 */
@interface NIMQuickCommentSetting : NSObject <NSCopying>
/**
 * 是否需要推送，默认NO，不推送
 */
@property (nonatomic,assign) BOOL needPush;
/**
 * 是否需要计入未读数，默认NO，不计入
 */
@property (nonatomic,assign) BOOL needBadge;
/**
 *  推送标题
 */
@property (nonatomic,copy,nullable) NSString *pushTitle;
/**
 *  推送内容
 */
@property (nonatomic,copy,nullable) NSString *pushContent;
/**
 *  推送参数设置
 */
@property (nonatomic,copy,nullable) NSDictionary *pushPayload;

@end

NS_ASSUME_NONNULL_END
