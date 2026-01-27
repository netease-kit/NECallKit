//
//  V2NIMMessage+V1API.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2025 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "V2NIMMessage.h"

@interface V2NIMMessage (V1API)

/**
 *  消息是否被播放过（兼容V1）
 *  @discussion 仅本地状态，云端不保存。
 */
@property(nonatomic,assign,readonly) BOOL v1_isPlayed;

@end
