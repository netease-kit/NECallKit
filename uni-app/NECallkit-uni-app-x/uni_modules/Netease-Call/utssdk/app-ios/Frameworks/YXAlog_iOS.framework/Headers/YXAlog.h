//
//  YXAlog.h
//  YXAlog
//
//  Created by Long on 2021/3/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 日志级别
typedef enum {
    YXAlogLevelVerbose = 0,
    YXAlogLevelDebug, // Detailed information on the flow through the system.
    YXAlogLevelInfo,  // Interesting runtime events (startup/shutdown), should be conservative and keep to a minimum.
    YXAlogLevelWarn,  // Other runtime situations that are undesirable or unexpected, but not necessarily "wrong".
    YXAlogLevelError, // Other runtime errors or unexpected conditions.
    YXAlogLevelTest
} YXAlogLevel;

/// 日志类型
typedef enum {
    YXAlogTypeNormal  = 0,
    YXAlogTypeApi     = 1
} YXAlogType;

/**
 日志配置类
 */
@interface YXAlogOptions : NSObject

@property (nonatomic, assign)   YXAlogLevel   level;
@property (nonatomic, copy)   NSString    *path;
@property (nonatomic, copy)   NSString    *filePrefix;
@property (nonatomic, copy)   NSString    *moduleName;

@end

/**
 日志服务类
 */
@interface YXAlog : NSObject

/**
 获取日志服务单例
 */
+ (YXAlog *)shared;

/**
 配置日志服务
 @param options 日志配置类
 */
- (void)setupWithOptions:(YXAlogOptions *)options;

/**
 打印日志
 @param level   日志级别
 @param tag        日志tag
 @param type    日志类型
 @param line    执行代码行数
 @param format  日志格式化字符串
 */
- (void)logWithLevel:(YXAlogLevel)level
                 tag:(NSString *)tag
                type:(YXAlogType)type
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
- (void)logWithLevel:(YXAlogLevel)level
          moduleName:(nullable NSString *)moduleName
                 tag:(NSString *)tag
                type:(YXAlogType)type
                line:(int32_t)line
                desc:(NSString *)format, ...;

/**
 异步写入文件
 */
- (int)flushAsync;

- (instancetype)init NS_UNAVAILABLE;

@end

/**
 日志打印快捷方法
 */
#define YXAlogDebug(frmt, ...)    [[YXAlog shared] logWithLevel:YXAlogLevelDebug tag:[NSString stringWithFormat:@"%s", __FUNCTION__] type:YXAlogTypeNormal line:__LINE__ desc:(frmt), ## __VA_ARGS__];
#define YXAlogInfo(frmt, ...)     [[YXAlog shared] logWithLevel:YXAlogLevelInfo tag:[NSString stringWithFormat:@"%s", __FUNCTION__] type:YXAlogTypeNormal line:__LINE__ desc:(frmt), ## __VA_ARGS__];
#define YXAlogWarn(frmt, ...)     [[YXAlog shared] logWithLevel:YXAlogLevelWarn tag:[NSString stringWithFormat:@"%s", __FUNCTION__] type:YXAlogTypeNormal line:__LINE__ desc:(frmt), ## __VA_ARGS__];
#define YXAlogError(frmt, ...)    [[YXAlog shared] logWithLevel:YXAlogLevelError tag:[NSString stringWithFormat:@"%s", __FUNCTION__] type:YXAlogTypeNormal line:__LINE__ desc:(frmt), ## __VA_ARGS__];
#define YXAlogTest(frmt, ...)     [[YXAlog shared] logWithLevel:YXAlogLevelTest tag:[NSString stringWithFormat:@"%s", __FUNCTION__] type:YXAlogTypeNormal line:__LINE__ desc:(frmt), ## __VA_ARGS__];

/**
 接口日志打印快捷方法
 */
#define ApiLogDebug(frmt, ...)    [[YXAlog shared] logWithLevel:YXAlogLevelDebug tag:[NSString stringWithFormat:@"%s", __FUNCTION__] type:YXAlogTypeApi line:__LINE__ desc:(frmt), ## __VA_ARGS__];
#define ApiLogInfo(frmt, ...)     [[YXAlog shared] logWithLevel:YXAlogLevelInfo tag:[NSString stringWithFormat:@"%s", __FUNCTION__] type:YXAlogTypeApi line:__LINE__ desc:(frmt), ## __VA_ARGS__];
#define ApiLogWarn(frmt, ...)     [[YXAlog shared] logWithLevel:YXAlogLevelWarn tag:[NSString stringWithFormat:@"%s", __FUNCTION__] type:YXAlogTypeApi line:__LINE__ desc:(frmt), ## __VA_ARGS__];
#define ApiLogError(frmt, ...)    [[YXAlog shared] logWithLevel:YXAlogLevelError tag:[NSString stringWithFormat:@"%s", __FUNCTION__] type:YXAlogTypeApi line:__LINE__ desc:(frmt), ## __VA_ARGS__];
#define ApiLogTest(frmt, ...)    [[YXAlog shared] logWithLevel:YXAlogLevelTest tag:[NSString stringWithFormat:@"%s", __FUNCTION__] type:YXAlogTypeApi line:__LINE__ desc:(frmt), ## __VA_ARGS__];

static inline int YXAlogFlushAsync() {
    return [YXAlog.shared flushAsync];
}

NS_ASSUME_NONNULL_END
