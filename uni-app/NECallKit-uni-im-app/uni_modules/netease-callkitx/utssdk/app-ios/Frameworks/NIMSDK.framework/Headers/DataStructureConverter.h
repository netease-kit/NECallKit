//
//  DataStructureConverter.h
//  NIMLib
//
//  Created by 齐洪茹 on 2023/12/26.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NIMMessage;
@class V2NIMMessage;

NS_ASSUME_NONNULL_BEGIN

@interface DataStructureConverter : NSObject
+ (NIMMessage *)messageConvertToV1:(V2NIMMessage *)message;

@end

NS_ASSUME_NONNULL_END
