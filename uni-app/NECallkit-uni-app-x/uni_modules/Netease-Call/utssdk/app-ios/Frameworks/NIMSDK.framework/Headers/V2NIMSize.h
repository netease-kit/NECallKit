//
//  V2NIMSize.h
//  NIMSDK
//
//  Created by 陈吉力 on 2024/6/12.
//  Copyright © 2024 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface V2NIMSize : NSObject

/**
 * 二维平面宽度
 */
@property (nonatomic,assign,readonly) NSInteger width;

/**
* 二维平面高度
*/
@property (nonatomic,assign,readonly) NSInteger height;

- (instancetype)initWithWidth:(NSInteger)width height:(NSInteger)height;
@end

NS_ASSUME_NONNULL_END
