// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "ReportEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface NECoreApiEvent : NSObject <NECoreEvent>

/// 用户标识
@property(nonatomic, copy) NSString *userId;
/// ID标识1
@property(nonatomic, copy) NSString *id1;
/// ID标识2
@property(nonatomic, copy) NSString *id2;
/// 额外可带信息
@property(nonatomic, copy) NSString *extension;

/// 创建一个API埋点对象
/// - Parameters:
///   - methodName: API名称
///   - params: API参数
- (instancetype)initWithMethodName:(NSString *)methodName params:(NSDictionary *__nullable)params;

/// 设置API埋点的结果
/// - Parameters:
///   - code: API调用结果
///   - message: API调用结果描述
- (void)setResult:(NSInteger)code message:(NSString *__nullable)message;

/// 强制设置字符串类型的params，调用这个接口后通过init传入的params将失效
/// - Parameter params: API参数
- (void)setParamsForce:(NSString *_Nonnull)params;

@end

NS_ASSUME_NONNULL_END
