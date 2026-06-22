#include "include/netease_callkit_ui/callkit_ui_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "callkit_ui_plugin.h"

void CallKitUIPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  auto* plugin_registrar =
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar);
  netease_callkit_ui::CallKitUIPlugin::RegisterWithRegistrar(plugin_registrar);
}

void CallKitUIPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  CallKitUIPluginCApiRegisterWithRegistrar(registrar);
}
