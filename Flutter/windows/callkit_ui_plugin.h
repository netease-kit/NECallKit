#ifndef FLUTTER_PLUGIN_CALLKIT_UI_PLUGIN_H_
#define FLUTTER_PLUGIN_CALLKIT_UI_PLUGIN_H_

#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace netease_callkit_ui {

class CallKitUIPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  explicit CallKitUIPlugin(flutter::PluginRegistrarWindows* registrar);
  ~CallKitUIPlugin() override;

  CallKitUIPlugin(const CallKitUIPlugin&) = delete;
  CallKitUIPlugin& operator=(const CallKitUIPlugin&) = delete;

 private:
  class Impl;
  std::unique_ptr<Impl> impl_;
};

}  // namespace netease_callkit_ui

#endif  // FLUTTER_PLUGIN_CALLKIT_UI_PLUGIN_H_
