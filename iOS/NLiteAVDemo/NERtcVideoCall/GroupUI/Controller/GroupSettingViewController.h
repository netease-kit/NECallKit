// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NECallBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^GroupCallParamSettingCompletion)(NSString *_Nullable groupId,
                                                NSString *_Nullable extraInfo,
                                                BOOL extraInfoAutoFillEnabled);

@interface GroupSettingViewController : NECallBaseViewController

@property(nonatomic, assign) BOOL showsGroupCallParams;
@property(nonatomic, copy, nullable) NSString *groupId;
@property(nonatomic, copy, nullable) NSString *extraInfo;
@property(nonatomic, assign) BOOL extraInfoAutoFillEnabled;
@property(nonatomic, copy, nullable) GroupCallParamSettingCompletion completion;

@end

NS_ASSUME_NONNULL_END
