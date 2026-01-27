//
//  V2NIMMessageFilter.h
//  NIMSDK
//
//  Created by 陈吉力 on 2025/6/16.
//  Copyright © 2025 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class V2NIMMessage;

NS_ASSUME_NONNULL_BEGIN

@protocol V2NIMMessageFilter <NSObject>

- (BOOL)shouldIgnore:(V2NIMMessage *)message;

@end

NS_ASSUME_NONNULL_END
