//// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEBufferDisplayView.h"

@interface NEBufferDisplayView ()
@property(nonatomic, strong) AVSampleBufferDisplayLayer *displayLayer;
@end

@implementation NEBufferDisplayView

@synthesize displayLayer = _displayLayer;

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // UIView.layer 只能在主线程访问；View 创建时缓存图层，视频回调线程只读取缓存。
    _displayLayer = (AVSampleBufferDisplayLayer *)self.layer;
  }
  return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (Class)layerClass {
  return AVSampleBufferDisplayLayer.class;
}

- (AVSampleBufferDisplayLayer *)getLayer {
  return _displayLayer;
}

@end
