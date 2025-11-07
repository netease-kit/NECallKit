// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEFLTCallUIKitLog.h"
#import <NEXKitBase/NEXKitBaseLog.h>
@import NECoreKit;

static NEXKitBaseLog *_callKitLog = nil;
static NSArray<NSString *> *sensitives = nil;
@implementation NEFLTCallUIKitLog

+ (void)setupLog {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _callKitLog = [NEXKitBaseLog shared];
    NEXKitBaseLogOptions *options = [[NEXKitBaseLogOptions alloc] init];
    options.path = [NEPathUtils getDirectoryForDocumentsWithDir:@"NIMSDK/Logs/extra_log/XKitLog"];
    options.level = NEXKitBaseLogLevelInfo;
    options.moduleName = @"NERtcCallkit";
    options.filePrefix = @"xkit";
    [_callKitLog setupWithOptions:options];

    sensitives = @[];
  });
}

+ (void)apiLog:(NSString *)className desc:(NSString *)desc {
  if (_callKitLog && desc && className) {
    NSString *desensitizedDesc = [self desensitize:[desc stringByRemovingPercentEncoding]];
    [_callKitLog logWithLevel:NEXKitBaseLogLevelInfo
                          tag:className
                         type:NEXKitBaseLogTypeApi
                         line:0
                         desc:@"🚰 %@", desensitizedDesc];
  }
}

+ (void)apiLog:(NSString *)className desc:(NSString *)desc function:(NSString *)function {
  if (_callKitLog && desc && className && function) {
    NSString *desensitizedDesc = [self desensitize:[desc stringByRemovingPercentEncoding]];
    [_callKitLog logWithLevel:NEXKitBaseLogLevelInfo
                          tag:className
                         type:NEXKitBaseLogTypeApi
                         line:0
                         desc:@"[%@][API] %@ %@", className, function, desensitizedDesc];
  }
}

+ (void)infoLog:(NSString *)className desc:(NSString *)desc {
  if (_callKitLog && desc && className) {
    NSString *desensitizedDesc = [self desensitize:[desc stringByRemovingPercentEncoding]];
    [_callKitLog logWithLevel:NEXKitBaseLogLevelInfo
                          tag:className
                         type:NEXKitBaseLogTypeNormal
                         line:0
                         desc:@"⚠️ %@", desensitizedDesc];
  }
}

+ (void)infoLog:(NSString *)className desc:(NSString *)desc function:(NSString *)function {
  if (_callKitLog && desc && className && function) {
    NSString *desensitizedDesc = [self desensitize:[desc stringByRemovingPercentEncoding]];
    [_callKitLog logWithLevel:NEXKitBaseLogLevelInfo
                          tag:className
                         type:NEXKitBaseLogTypeNormal
                         line:0
                         desc:@"[%@] %@ %@", className, function, desensitizedDesc];
  }
}

+ (void)infoResultLog:(NSString *)className desc:(NSString *)desc function:(NSString *)function {
  if (_callKitLog && desc && className && function) {
    NSString *desensitizedDesc = [self desensitize:[desc stringByRemovingPercentEncoding]];
    [_callKitLog logWithLevel:NEXKitBaseLogLevelInfo
                          tag:className
                         type:NEXKitBaseLogTypeNormal
                         line:0
                         desc:@"[%@][RESULT] %@ %@", className, function, desensitizedDesc];
  }
}

+ (void)infoEventLog:(NSString *)className desc:(NSString *)desc function:(NSString *)function {
  if (_callKitLog && desc && className && function) {
    NSString *desensitizedDesc = [self desensitize:[desc stringByRemovingPercentEncoding]];
    [_callKitLog logWithLevel:NEXKitBaseLogLevelInfo
                          tag:className
                         type:NEXKitBaseLogTypeNormal
                         line:0
                         desc:@"[%@][EVENT] %@ %@", className, function, desensitizedDesc];
  }
}

/// warn类型 log
+ (void)warnLog:(NSString *)className desc:(NSString *)desc {
  if (_callKitLog && desc && className) {
    NSString *desensitizedDesc = [self desensitize:[desc stringByRemovingPercentEncoding]];
    [_callKitLog logWithLevel:NEXKitBaseLogLevelWarn
                          tag:className
                         type:NEXKitBaseLogTypeNormal
                         line:0
                         desc:@"❗️ %@", desensitizedDesc];
  }
}

+ (void)warnLog:(NSString *)className desc:(NSString *)desc function:(NSString *)function {
  if (_callKitLog && desc && className && function) {
    NSString *desensitizedDesc = [self desensitize:[desc stringByRemovingPercentEncoding]];
    [_callKitLog logWithLevel:NEXKitBaseLogLevelWarn
                          tag:className
                         type:NEXKitBaseLogTypeNormal
                         line:0
                         desc:@"❗️[%@] %@ %@", className, function, desensitizedDesc];
  }
}

+ (void)warnEventLog:(NSString *)className desc:(NSString *)desc function:(NSString *)function {
  if (_callKitLog && desc && className && function) {
    NSString *desensitizedDesc = [self desensitize:[desc stringByRemovingPercentEncoding]];
    [_callKitLog logWithLevel:NEXKitBaseLogLevelWarn
                          tag:className
                         type:NEXKitBaseLogTypeNormal
                         line:0
                         desc:@"❗️[%@][EVENT] %@ %@", className, function, desensitizedDesc];
  }
}

+ (void)warnResultLog:(NSString *)className desc:(NSString *)desc function:(NSString *)function {
  if (_callKitLog && desc && className && function) {
    NSString *desensitizedDesc = [self desensitize:[desc stringByRemovingPercentEncoding]];
    [_callKitLog logWithLevel:NEXKitBaseLogLevelWarn
                          tag:className
                         type:NEXKitBaseLogTypeNormal
                         line:0
                         desc:@"❗️[%@][RESULT] %@ %@", className, function, desensitizedDesc];
  }
}

+ (void)successLog:(NSString *)className desc:(NSString *)desc {
  if (_callKitLog && desc && className) {
    NSString *desensitizedDesc = [self desensitize:[desc stringByRemovingPercentEncoding]];
    [_callKitLog logWithLevel:NEXKitBaseLogLevelInfo
                          tag:className
                         type:NEXKitBaseLogTypeNormal
                         line:0
                         desc:@"✅ %@", desensitizedDesc];
  }
}

/// error类型 log
+ (void)errorLog:(NSString *)className desc:(NSString *)desc {
  if (_callKitLog && desc && className) {
    NSString *desensitizedDesc = [self desensitize:[desc stringByRemovingPercentEncoding]];
    [_callKitLog logWithLevel:NEXKitBaseLogLevelError
                          tag:className
                         type:NEXKitBaseLogTypeNormal
                         line:0
                         desc:@"❌ %@", desensitizedDesc];
  }
}

+ (void)errorLog:(NSString *)className desc:(NSString *)desc function:(NSString *)function {
  if (_callKitLog && desc && className && function) {
    NSString *desensitizedDesc = [self desensitize:[desc stringByRemovingPercentEncoding]];
    [_callKitLog logWithLevel:NEXKitBaseLogLevelError
                          tag:className
                         type:NEXKitBaseLogTypeNormal
                         line:0
                         desc:@"❌ [%@] %@ %@", className, function, desensitizedDesc];
  }
}

+ (void)errorEventLog:(NSString *)className desc:(NSString *)desc function:(NSString *)function {
  if (_callKitLog && desc && className && function) {
    NSString *desensitizedDesc = [self desensitize:[desc stringByRemovingPercentEncoding]];
    [_callKitLog logWithLevel:NEXKitBaseLogLevelError
                          tag:className
                         type:NEXKitBaseLogTypeNormal
                         line:0
                         desc:@"❌ [%@][EVENT] %@ %@", className, function, desensitizedDesc];
  }
}

+ (void)errorResultLog:(NSString *)className desc:(NSString *)desc function:(NSString *)function {
  if (_callKitLog && desc && className && function) {
    NSString *desensitizedDesc = [self desensitize:[desc stringByRemovingPercentEncoding]];
    [_callKitLog logWithLevel:NEXKitBaseLogLevelError
                          tag:className
                         type:NEXKitBaseLogTypeNormal
                         line:0
                         desc:@"❌ [%@][RESULT] %@ %@", className, function, desensitizedDesc];
  }
}

+ (void)messageLog:(NSString *)className desc:(NSString *)desc {
  if (_callKitLog && desc && className) {
    NSString *desensitizedDesc = [self desensitize:[desc stringByRemovingPercentEncoding]];
    [_callKitLog logWithLevel:NEXKitBaseLogLevelInfo
                          tag:className
                         type:NEXKitBaseLogTypeNormal
                         line:0
                         desc:@"✉️ %@", desensitizedDesc];
  }
}

+ (void)networkLog:(NSString *)className desc:(NSString *)desc {
  if (_callKitLog && desc && className) {
    NSString *desensitizedDesc = [self desensitize:[desc stringByRemovingPercentEncoding]];
    [_callKitLog logWithLevel:NEXKitBaseLogLevelInfo
                          tag:className
                         type:NEXKitBaseLogTypeNormal
                         line:0
                         desc:@"📶 %@", desensitizedDesc];
  }
}

// 对日志内容进行脱敏
+ (NSString *)desensitize:(NSString *)desc {
  if (!desc) {
    return @"";
  }

  NSString *target = desc;
  if (sensitives) {
    for (NSString *sensitive in sensitives) {
      if (sensitive && sensitive.length > 0) {
        target = [NEStringUtils desensitizeWithString:target sensitive:sensitive];
      }
    }
  }
  return target;
}

@end
