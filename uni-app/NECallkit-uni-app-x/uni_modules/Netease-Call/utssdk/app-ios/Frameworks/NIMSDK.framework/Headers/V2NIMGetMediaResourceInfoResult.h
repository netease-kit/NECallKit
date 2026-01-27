//
//  V2NIMGetMediaResourceInfoResult.h
//  NIMSDK
//
//  Created by 陈吉力 on 2024/6/12.
//  Copyright © 2024 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "V2NIMMessageAttachment.h"
#import "V2NIMStorageServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface V2NIMGetMediaResourceInfoResult : NSObject
/// 附件资源完整下载地址
@property(nonatomic,copy,readonly)NSString *url;
/// 该资源所需的鉴权信息
@property(nonatomic,strong,readonly)NSDictionary *authHeaders;
@end

NS_ASSUME_NONNULL_END
