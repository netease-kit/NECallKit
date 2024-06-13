//
//  NIMQChatMessageAntispamSetting.h
//  NIMLib
//
//  Created by Evang on 2022/3/23.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 *  圈组消息反垃圾设置
 */
@interface NIMQChatMessageAntispamSetting : NSObject 

/**
*  指定是否需要使用自定义反垃圾字段(即antiSpamContent), YES:不需要,NO:需要, 默认NO, *一般使用的情况是通用反垃圾转易盾
*
*/
@property (nonatomic, assign) BOOL enableAntiSpamContent;

/**
*  开发者自定义的反垃圾字段
*  @discussion 如果提供了这个字段, 在过反垃圾时不会再使用content或者attach
*/
@property (nullable,nonatomic,copy) NSString *antiSpamContent;

/**
*  用户配置的对某些单条消息另外的反垃圾的业务ID
*/
@property (nullable,nonatomic,copy) NSString *antiSpamBusinessId;

/**
*  此条消息是否使用易盾反垃圾, NO:(在开通易盾的情况下)表示这条消息不过易盾反垃圾, 其他都是按照原来的规则
*/
@property (nonatomic, assign) BOOL antiSpamUsingYidun;

/**
*  易盾check的回调URL, 目前仅支持Audio类型的消息, 最长256个字符, 如果不合法则忽略该参数
*/
@property (nullable,nonatomic,copy) NSString *yidunCallback;

/**
*  易盾反垃圾增强反作弊专属字段
*  @discussion 透传易盾反垃圾增强反作弊专属字段
*/
@property (nullable,nonatomic,copy) NSDictionary *yidunAntiCheating;

/**
 * 易盾反垃圾扩展字段，限制json，长度限制1024
 */
@property (nullable,nonatomic,copy) NSString *yidunAntiSpamExt;


@end

NS_ASSUME_NONNULL_END
