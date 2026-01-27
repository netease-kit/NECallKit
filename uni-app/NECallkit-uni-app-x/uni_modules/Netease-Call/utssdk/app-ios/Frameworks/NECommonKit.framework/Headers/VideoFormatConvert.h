
// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

typedef void (^NIMKitCameraFetchResult)(NSString *path, UIImage *image);

@interface VideoFormatConvert : NSObject

/// convertToMP4
/// @param inputURL inputurl
/// @param quality av quality  default is AVAssetExportPresetHighestQuality
/// @param completion call back
+ (void)convertToMP4WithURL:(NSURL *)inputURL
                  avQuality:(NSString *)quality
             withCompletion:(_Nonnull NIMKitCameraFetchResult)completion;

@end
