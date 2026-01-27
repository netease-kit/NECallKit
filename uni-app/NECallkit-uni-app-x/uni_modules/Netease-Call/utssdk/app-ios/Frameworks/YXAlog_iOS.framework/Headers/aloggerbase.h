// Tencent is pleased to support the open source community by making Mars available.
// Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.

// Licensed under the MIT License (the "License"); you may not use this file except in 
// compliance with the License. You may obtain a copy of the License at
// http://opensource.org/licenses/MIT

// Unless required by applicable law or agreed to in writing, software distributed under the License is
// distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
// either express or implied. See the License for the specific language governing permissions and
// limitations under the License.


/*
 ============================================================================
 ============================================================================
 */

#ifndef ALOGGERBASE_H_
#define ALOGGERBASE_H_

#include <sys/time.h>
#include <time.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    kLevelAll = 0,
    kLevelVerbose = 0,
    kLevelDebug,    // Detailed information on the flow through the system.
    kLevelInfo,     // Interesting runtime events (startup/shutdown), should be conservative and keep to a minimum.
    kLevelWarn,     // Other runtime situations that are undesirable or unexpected, but not necessarily "wrong".
    kLevelError,    // Other runtime errors or unexpected conditions.
    kLevelFatal,    // Severe errors that cause premature termination.
    kLevelNone,     // Special level used to disable all log messages.
} TLogLevel;

typedef enum {
    kLogNormal = 0, // 正常日志打印
    kLogApi,// api 接口打印
} LogType;

typedef struct ALoggerInfo_t {
    TLogLevel level;
    const char* tag;
    const char* filename;
    const char* func_name;
    const char* module_name;

    LogType type;

    int line;

    struct timeval timeval;
    intmax_t pid;
    intmax_t tid;
    intmax_t maintid;
    int traceLog;
} ALoggerInfo;

extern intmax_t alogger_pid();
extern intmax_t alogger_tid();
extern intmax_t alogger_maintid();
typedef void (*alogger_appender_t)(const ALoggerInfo* _info, const char* _log);
extern const char* alogger_dump(const void* _dumpbuffer, size_t _len);
extern const char* alogger_memory_dump(const void* _dumpbuffer, size_t _len);   // same as alogger_dump, but don't write dumpbuffer to file.

TLogLevel   alogger_Level();
void alogger_SetLevel(TLogLevel _level);
int  alogger_IsEnabledFor(TLogLevel _level);
alogger_appender_t alogger_SetAppender(alogger_appender_t _appender);

typedef int (*alogger_filter_t)(ALoggerInfo* _info, const char* _log);
void alogger_SetFilter(alogger_filter_t _filter);
alogger_filter_t alogger_GetFilter();

// no level filter
#ifdef __GNUC__
__attribute__((__format__(printf, 3, 4)))
#endif
void        alogger_AssertP(const ALoggerInfo* _info, const char* _expression, const char* _format, ...);
void        alogger_Assert(const ALoggerInfo* _info, const char* _expression, const char* _log);
#ifdef __GNUC__
__attribute__((__format__(printf, 2, 0)))
#endif
void        alogger_VPrint(const ALoggerInfo* _info, const char* _format, va_list _list);
#ifdef __GNUC__
__attribute__((__format__(printf, 2, 3)))
#endif
void        alogger_Print(const ALoggerInfo* _info, const char* _format, ...);
void        alogger_Write(const ALoggerInfo* _info, const char* _log);

/**
 * ALog 初始化
 * @param _level 最低输出 log 等级
 * @param _path 日志文件路径
 * @param _name 日志文件名称
 */
int alogger_init(int _level, const char* _path, const char* _name);
/**
 * verbose 打印
 * @param _tag tag 说明
 * @param _type 0-普通log，1-api log
 * @param _module_name 模块名称
 * @param _line 行数，不支持传 0 即可
 * @param _tid 线程 id
 * @param _log 日志内容
 */
int alogger_verbose(const char* _tag, int _type, const char * _module_name,int _line, int _tid,const char * _log);

int alogger_debug(const char* _tag, int _type, const char * _module_name,int _line, int _tid,const char * _log);

int alogger_info(const char* _tag, int _type, const char * _module_name,int _line,int _tid,const char * _log);

int alogger_warn(const char* _tag, int _type, const char * _module_name,int _line,int _tid,const char * _log);

int alogger_error(const char* _tag, int _type, const char * _module_name,int _line,int _tid,const char * _log);

int alogger_test(const char* _tag, int _type, const char * _module_name,int _line, int _tid,const char * _log);

/**
 * 将缓存信息同步写入目标日志
 */
int alogger_flushSync();

/**
 * 将缓存信息异步写入目标日志
 */
int alogger_flushAsync();

/**
 * 销毁对应日志，如果再次使用需要调用 init
 */
int alogger_release();

#ifdef __cplusplus
}
#endif

#endif
