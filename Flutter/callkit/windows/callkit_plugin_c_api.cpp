#include "include/netease_callkit/callkit_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "callkit_plugin.h"

void CallkitPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  auto* plugin_registrar =
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar);
  netease_callkit::CallkitPlugin::RegisterWithRegistrar(plugin_registrar);
}
