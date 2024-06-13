//
//  V2NIMMessageQuickCommentPushConfig.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/8/31.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface V2NIMMessageQuickCommentPushConfig : NSObject
/// 是否需要推送
@property(nonatomic,assign,readwrite) BOOL pushEnabled;
/// 是否需要角标
@property(nonatomic,assign,readwrite) BOOL needBadge;
/// 推送标题
@property(nonatomic,strong,readwrite) NSString *title;
///推送内容
@property(nonatomic,strong,readwrite) NSString *pushContent;
/// 推送数据
@property(nonatomic,strong,readwrite) NSString *pushPayload;

@end

NS_ASSUME_NONNULL_END
