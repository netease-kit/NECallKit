// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NECallUIIncomingBackgroundSourceType) {
  /// 本地 UIImage。
  NECallUIIncomingBackgroundSourceTypeImage = 0,
  /// 公开 http/https 图片 URL。
  NECallUIIncomingBackgroundSourceTypeURL = 1,
};

@interface NECallUIIncomingBackgroundSource : NSObject

@property(nonatomic, assign, readonly) NECallUIIncomingBackgroundSourceType type;
@property(nonatomic, strong, nullable, readonly) UIImage *image;
@property(nonatomic, strong, nullable, readonly) NSURL *url;

+ (instancetype)imageSource:(UIImage *)image;
+ (instancetype)urlSource:(NSURL *)url;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

@interface NECallUIDynamicConfig : NSObject

/// 接收方来电响铃/待接听页面自定义背景图。为空时使用现有头像虚化背景。
@property(nonatomic, strong, nullable) NECallUIIncomingBackgroundSource *incomingCallBackground;

@end

NS_ASSUME_NONNULL_END
