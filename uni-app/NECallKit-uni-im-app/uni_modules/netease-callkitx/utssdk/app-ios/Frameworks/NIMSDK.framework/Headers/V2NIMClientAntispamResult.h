//
//  V2NIMMessageClientAntispamResult.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/8/14.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "V2NIMMessageEnum.h"

NS_ASSUME_NONNULL_BEGIN

@interface V2NIMClientAntispamResult : NSObject
/// 客户端反垃圾文本命中后操作类型
@property (nonatomic, assign) V2NIMClientAntispamOperateType operateType;
/// 处理后的文本内容
@property (nonatomic, copy) NSString *replacedText;

@end

NS_ASSUME_NONNULL_END
