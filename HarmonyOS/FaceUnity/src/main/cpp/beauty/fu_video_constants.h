//
// Created on 2025/2/14.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef HARMONY_FU_VIDEO_CONFIG_H
#define HARMONY_FU_VIDEO_CONFIG_H


/**
 * Config attribute list.
 */

const char* AI_FACE_PROCESSOR = "ai_face_processor.bundle";
const char* AI_HUMAN_PROCESSOR = "ai_human_processor.bundle";
const char* AI_FACE_BEAUTIFICATION = "face_beautification.bundle";
const int FACE_BEAUTY_INDEX = 0;

const int VIDEO_FU_MAX_FACES = 4;
#endif //HARMONY_FU_VIDEO_CONFIG_H
