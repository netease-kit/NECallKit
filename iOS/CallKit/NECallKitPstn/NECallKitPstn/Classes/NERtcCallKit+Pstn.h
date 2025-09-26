// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NERtcCallKit/NERtcCallKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NERtcCallKit (Pstn)

- (void)changeStatusIdle;

- (void)changeStatusCalling;

- (void)changeStatusInCall;

@end

NS_ASSUME_NONNULL_END
