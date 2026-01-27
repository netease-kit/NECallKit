//
//  NEXKitBaseLog.h
//  NEXKitBase
//
//  Created by Claude on 2025/9/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 日志级别
typedef NS_ENUM(NSInteger, NEXKitBaseLogLevel) {
    NEXKitBaseLogLevelVerbose = 0,
    NEXKitBaseLogLevelDebug = 1, // Detailed information on the flow through the system.
    NEXKitBaseLogLevelInfo = 2,  // Interesting runtime events (startup/shutdown), should be conservative and keep to a minimum.
    NEXKitBaseLogLevelWarn = 3,  // Other runtime situations that are undesirable or unexpected, but not necessarily "wrong".
    NEXKitBaseLogLevelError = 4, // Other runtime errors or unexpected conditions.
};

/// 日志类型
typedef NS_ENUM(NSInteger, NEXKitBaseLogType) {
    NEXKitBaseLogTypeNormal  = 0,
    NEXKitBaseLogTypeApi     = 1
};

/**
 日志配置类
 */
@interface NEXKitBaseLogOptions : NSObject

@property (nonatomic, assign)   NEXKitBaseLogLevel   level;
@property (nonatomic, copy)   NSString    *path;
@property (nonatomic, copy)   NSString    *filePrefix;
@property (nonatomic, copy)   NSString    *moduleName;

@end

/**
 日志服务类
 */
@interface NEXKitBaseLog : NSObject

/**
 获取日志服务单例
 */
+ (NEXKitBaseLog *)shared;

/**
 配置日志服务
 @param options 日志配置类
 */
- (BOOL)setupWithOptions:(NEXKitBaseLogOptions *)options;

/**
 检查是否已初始化
 */
- (BOOL)isInitialized;

/**
 打印日志
 @param level   日志级别
 @param tag        日志tag
 @param type    日志类型
 @param line    执行代码行数
 @param format  日志格式化字符串
 */
- (void)logWithLevel:(NEXKitBaseLogLevel)level
                 tag:(NSString *)tag
                type:(NEXKitBaseLogType)type
                line:(int32_t)line
                desc:(NSString *)format, ...;

/**
 打印日志
 @param level   日志级别
 @param moduleName   模块名，不传则使用setupWithOptions里的moduleName
 @param tag        日志tag
 @param type    日志类型
 @param line    执行代码行数
 @param format  日志格式化字符串
 */
- (void)logWithLevel:(NEXKitBaseLogLevel)level
          moduleName:(nullable NSString *)moduleName
                 tag:(NSString *)tag
                type:(NEXKitBaseLogType)type
                line:(int32_t)line
                desc:(NSString *)format, ...;

/**
 打印日志
 @param level   日志级别
 @param moduleName   模块名，不传则使用setupWithOptions里的moduleName
 @param tag        日志tag
 @param type    日志类型
 @param line    执行代码行数
 @param message  日志内容字符串
 */
- (void)log:(NEXKitBaseLogLevel)level
          moduleName:(nullable NSString *)moduleName
                 tag:(NSString *)tag
                type:(NEXKitBaseLogType)type
                line:(int32_t)line
                message:(NSString *)message;

- (instancetype)init NS_UNAVAILABLE;

@end

/**
 日志打印快捷方法
 */
#define NEXKitBaseLogVerbose(frmt, ...)    [[NEXKitBaseLog shared] logWithLevel:NEXKitBaseLogLevelVerbose tag:[NSString stringWithFormat:@"%s", __FUNCTION__] type:NEXKitBaseLogTypeNormal line:__LINE__ desc:(frmt), ## __VA_ARGS__];
#define NEXKitBaseLogDebug(frmt, ...)    [[NEXKitBaseLog shared] logWithLevel:NEXKitBaseLogLevelDebug tag:[NSString stringWithFormat:@"%s", __FUNCTION__] type:NEXKitBaseLogTypeNormal line:__LINE__ desc:(frmt), ## __VA_ARGS__];
#define NEXKitBaseLogInfo(frmt, ...)     [[NEXKitBaseLog shared] logWithLevel:NEXKitBaseLogLevelInfo tag:[NSString stringWithFormat:@"%s", __FUNCTION__] type:NEXKitBaseLogTypeNormal line:__LINE__ desc:(frmt), ## __VA_ARGS__];
#define NEXKitBaseLogWarn(frmt, ...)     [[NEXKitBaseLog shared] logWithLevel:NEXKitBaseLogLevelWarn tag:[NSString stringWithFormat:@"%s", __FUNCTION__] type:NEXKitBaseLogTypeNormal line:__LINE__ desc:(frmt), ## __VA_ARGS__];
#define NEXKitBaseLogError(frmt, ...)    [[NEXKitBaseLog shared] logWithLevel:NEXKitBaseLogLevelError tag:[NSString stringWithFormat:@"%s", __FUNCTION__] type:NEXKitBaseLogTypeNormal line:__LINE__ desc:(frmt), ## __VA_ARGS__];

/**
 接口日志打印快捷方法
 */
#define XKitApiLogVerbose(frmt, ...)    [[NEXKitBaseLog shared] logWithLevel:NEXKitBaseLogLevelVerbose tag:[NSString stringWithFormat:@"%s", __FUNCTION__] type:NEXKitBaseLogTypeApi line:__LINE__ desc:(frmt), ## __VA_ARGS__];
#define XKitApiLogDebug(frmt, ...)    [[NEXKitBaseLog shared] logWithLevel:NEXKitBaseLogLevelDebug tag:[NSString stringWithFormat:@"%s", __FUNCTION__] type:NEXKitBaseLogTypeApi line:__LINE__ desc:(frmt), ## __VA_ARGS__];
#define XKitApiLogInfo(frmt, ...)     [[NEXKitBaseLog shared] logWithLevel:NEXKitBaseLogLevelInfo tag:[NSString stringWithFormat:@"%s", __FUNCTION__] type:NEXKitBaseLogTypeApi line:__LINE__ desc:(frmt), ## __VA_ARGS__];
#define XKitApiLogWarn(frmt, ...)     [[NEXKitBaseLog shared] logWithLevel:NEXKitBaseLogLevelWarn tag:[NSString stringWithFormat:@"%s", __FUNCTION__] type:NEXKitBaseLogTypeApi line:__LINE__ desc:(frmt), ## __VA_ARGS__];
#define XKitApiLogError(frmt, ...)    [[NEXKitBaseLog shared] logWithLevel:NEXKitBaseLogLevelError tag:[NSString stringWithFormat:@"%s", __FUNCTION__] type:NEXKitBaseLogTypeApi line:__LINE__ desc:(frmt), ## __VA_ARGS__];

NS_ASSUME_NONNULL_END
