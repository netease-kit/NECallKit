//
//  V2NIMMessageRevokeParams.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/8/14.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface V2NIMMessageRevokeParams : NSObject
/// 撤回的附言
@property(nullable, nonatomic, strong) NSString *postscript;
/// 扩展信息
@property(nullable, nonatomic, strong) NSString *serverExtension;
/// 推送内容,长度限制500字
@property (nullable, nonatomic, strong) NSString *pushContent;
/// 推送数据,长度限制 2K
@property (nullable, nonatomic, strong) NSString *pushPayload;
/// 路由抄送地址
@property (nullable, nonatomic, strong) NSString *env;
@end

NS_ASSUME_NONNULL_END
