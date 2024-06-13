//
// Created by chenjili on 2021/3/22.
// Copyright (c) 2021 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NIMAddEmptyRecentSessionBySessionOption : NSObject
/**
 *  是否填入最后一条消息
 *  @discussion ，默认为 NO，仅创建空会话；为YES，将同时添加最后一条消息
 */
@property   (nonatomic,assign)  BOOL    withLastMsg;

/**
 *  如果没有最后一条消息，是否用一条空消息补位
 *  @discussion ，默认为 YES，创建一条空消息补位；为NO，不使用补位消息
 */
@property   (nonatomic,assign)  BOOL    addEmptyMsgIfNoLastMsgExist;

@end

NS_ASSUME_NONNULL_END