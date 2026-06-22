#ifndef FLUTTER_PLUGIN_NETEASE_CALLKIT_PLUGIN_C_API_H_
#define FLUTTER_PLUGIN_NETEASE_CALLKIT_PLUGIN_C_API_H_

#include <flutter/plugin_registrar_windows.h>

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FLUTTER_PLUGIN_EXPORT __declspec(dllimport)
#endif

#if defined(__cplusplus)
extern "C" {
#endif

FLUTTER_PLUGIN_EXPORT void CallkitPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar);

#if defined(__cplusplus)
}  // extern "C"
#endif

#endif  // FLUTTER_PLUGIN_NETEASE_CALLKIT_PLUGIN_C_API_H_
