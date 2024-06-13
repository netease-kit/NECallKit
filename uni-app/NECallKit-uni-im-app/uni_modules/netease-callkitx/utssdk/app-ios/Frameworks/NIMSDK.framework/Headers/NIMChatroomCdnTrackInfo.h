//
//  NIMChatroomCdnTrackInfo.h
//  NIMLib
//
//  Created by 丁文超 on 2020/7/8.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NIMChatroomCdnTrackInfo : NSObject

/**
 * 基础信息
 * s: 成功次数
 * f:  失败次数
 * sr: 成功平均响应时间(s)
 * fr：失败平均响应时间(s)
 * smr：成功最大响应时间(s)
 * fmr：失败最大响应时间(s)
 * 例： {
        "cdn.netease.com": {
            "s": 10,
            "f": 5,
            "sr": 0.3,
            "fr": 0.2,
            "smr": 0.5,
            "fmr": 0.3
        }
 *     }
 */
@property (nonatomic, copy) NSDictionary *baseInfo;

/**
 * 总共失败次数
 */
@property (nonatomic, assign) NSInteger finalFailureCount;

@end

NS_ASSUME_NONNULL_END
