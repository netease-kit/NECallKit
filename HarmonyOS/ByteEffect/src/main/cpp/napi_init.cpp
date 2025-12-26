#include "napi/native_api.h"
#include "./byted/byted_effect_render.h"

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    BytedEffectRender::Init(env, exports);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "byteeffect",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterByteEffectModule(void)
{
    napi_module_register(&demoModule);
}
