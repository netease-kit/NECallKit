// Copyright (C) 2020 Beijing Bytedance Network Technology Co., Ltd.
#ifndef bef_effect_ai_api_advanced_h
#define bef_effect_ai_api_advanced_h

#include "bef_effect_ai_api.h"


//typedef int(*EffectRenderInjectFunc)(unsigned int texId, int width, int height, void* userdata);

typedef int(*BEFRenderInjectFunc)(unsigned int texId, int width, int height);

/**
* @brief Register customized render callback, make compatible with internal render process
* @param handle      Effect handle
* @param key         Customized key for callback function
* @param pfunc       Funtion pointer. Do customized render inside this callback funtion
* @return            If succeed return BEF_EFFECT_RESULT_SUC, other value please see   bef_effect_ai_public_define.h.
*/
BEF_SDK_API bef_effect_result_t bef_effect_ai_register_render_inject_func(bef_effect_handle_t handle, const char* key, BEFRenderInjectFunc pfunc);

#endif/* bef_effect_ai_api_advanced_h */


