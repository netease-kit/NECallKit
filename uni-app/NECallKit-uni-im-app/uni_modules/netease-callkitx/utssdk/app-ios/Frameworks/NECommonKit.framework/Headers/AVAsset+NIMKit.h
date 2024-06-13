
// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVAsset (NIMKit)

- (AVMutableVideoComposition *)nim_videoComposition;

@end

NS_ASSUME_NONNULL_END
