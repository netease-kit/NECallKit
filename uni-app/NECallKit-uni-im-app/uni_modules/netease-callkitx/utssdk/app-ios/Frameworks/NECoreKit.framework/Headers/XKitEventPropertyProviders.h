// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "ReportEvent.h"

@interface XKitSDKVersionsProvider : NSObject <NECoreEventPropertyProvider>

@end

@interface XKitApplicationInfoProvider : NSObject <NECoreEventPropertyProvider>

@end

@interface XKitDeviceInfoProvider : NSObject <NECoreEventPropertyProvider>

@end

@interface XKitNetworkTypeProvider : NSObject <NECoreEventPropertyProvider>

@end
