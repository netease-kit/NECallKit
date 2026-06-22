//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <alog_windows/alog_windows_plugin_c_api.h>
#include <netease_callkit/callkit_plugin.h>
#include <netease_callkit_ui/call_kit_u_i_plugin.h>
#include <nim_core_v2_windows/nim_core_windows.h>
#include <permission_handler_windows/permission_handler_windows_plugin.h>
#include <url_launcher_windows/url_launcher_windows.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  AlogWindowsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AlogWindowsPluginCApi"));
  CallkitPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("CallkitPlugin"));
  CallKitUIPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("CallKitUIPlugin"));
  NimCoreWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("NimCoreWindows"));
  PermissionHandlerWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PermissionHandlerWindowsPlugin"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
}
