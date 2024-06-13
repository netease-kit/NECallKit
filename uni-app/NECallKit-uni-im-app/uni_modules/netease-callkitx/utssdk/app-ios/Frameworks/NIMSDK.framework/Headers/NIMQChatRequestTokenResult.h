//
//  NIMQChatRequestTokenResult.h
//  NIMLib
//
//  Created by lihuang on 2022/6/29.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NIMQChatRequestTokenResult : NSObject

@property (nonatomic, copy) NSString *token;

@property (nonatomic, assign) NSTimeInterval expireTime;

@end

NS_ASSUME_NONNULL_END
