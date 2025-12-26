//
// Created on 2024/11/20.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef HARMONY_LOG_H
#define HARMONY_LOG_H

#include <hilog/log.h>
#define TAG "DataProcessing"

#define AV_DEBUG(...) OH_LOG_Print(LogType::LOG_APP, LogLevel::LOG_DEBUG, 0x1, TAG, __VA_ARGS__)
#define AV_INFO(...) OH_LOG_Print(LogType::LOG_APP, LogLevel::LOG_INFO, 0x1, TAG, __VA_ARGS__)
#define AV_ERROR(...) OH_LOG_Print(LogType::LOG_APP, LogLevel::LOG_ERROR, 0x1, TAG, __VA_ARGS__)


#endif //HARMONY_LOG_H
