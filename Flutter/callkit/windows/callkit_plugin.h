#ifndef FLUTTER_PLUGIN_NETEASE_CALLKIT_PLUGIN_H_
#define FLUTTER_PLUGIN_NETEASE_CALLKIT_PLUGIN_H_

#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace netease_callkit {

class CallkitPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  explicit CallkitPlugin(flutter::PluginRegistrarWindows* registrar);
  ~CallkitPlugin() override;

  CallkitPlugin(const CallkitPlugin&) = delete;
  CallkitPlugin& operator=(const CallkitPlugin&) = delete;

 private:
  class Impl;
  std::unique_ptr<Impl> impl_;
};

}  // namespace netease_callkit

#endif  // FLUTTER_PLUGIN_NETEASE_CALLKIT_PLUGIN_H_
