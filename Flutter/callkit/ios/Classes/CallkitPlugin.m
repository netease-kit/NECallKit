// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "CallkitPlugin.h"

#if __has_include(<netease_callkit/netease_callkit-Swift.h>)
#import <netease_callkit/netease_callkit-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "netease_callkit-Swift.h"
#endif

@implementation CallkitPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [SwiftCallkitPlugin registerWithRegistrar:registrar];
}
@end