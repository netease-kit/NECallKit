//
//  V2NIMTeamMessageReadReceiptDetail.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/9/5.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
@class V2NIMTeamMessageReadReceipt;

NS_ASSUME_NONNULL_BEGIN

/// 群消息已读回执详情
@interface V2NIMTeamMessageReadReceiptDetail : NSObject
/// 群消息已读回执
@property (nonatomic,strong,readonly) V2NIMTeamMessageReadReceipt *readReceipt;
/// 已读账号列表
@property (nonatomic,strong,readonly) NSArray<NSString *> *readAccountList;
/// 未读账号列表
@property (nonatomic,strong,readonly) NSArray<NSString *> *unreadAccountList;
@end

NS_ASSUME_NONNULL_END
