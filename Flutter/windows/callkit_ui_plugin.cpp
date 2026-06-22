#include "callkit_ui_plugin.h"

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <shellapi.h>
#include <windows.h>
#include <mmsystem.h>
#include <winrt/Windows.Devices.Enumeration.h>

#include <cwchar>
#include <filesystem>
#include <memory>
#include <optional>
#include <string>
#include <utility>
#include <vector>

namespace netease_callkit_ui {

namespace {

constexpr char kMethodChannelName[] = "call_kit_ui";
constexpr int kPermissionGranted = 0;
constexpr int kPermissionDenied = 1;
constexpr int kCameraPermission = 0;
constexpr int kMicrophonePermission = 1;
constexpr int kBluetoothPermission = 2;

using EncodableValue = flutter::EncodableValue;
using EncodableMap = flutter::EncodableMap;
using MethodCall = flutter::MethodCall<EncodableValue>;
using MethodResult = flutter::MethodResult<EncodableValue>;
using winrt::Windows::Devices::Enumeration::DeviceAccessInformation;
using winrt::Windows::Devices::Enumeration::DeviceAccessStatus;
using winrt::Windows::Devices::Enumeration::DeviceClass;

std::wstring Utf8ToWide(const std::string& utf8) {
  if (utf8.empty()) {
    return std::wstring();
  }
  const int size_needed =
      MultiByteToWideChar(CP_UTF8, 0, utf8.c_str(), -1, nullptr, 0);
  if (size_needed <= 0) {
    return std::wstring();
  }
  std::wstring wide(static_cast<size_t>(size_needed) - 1, L'\0');
  MultiByteToWideChar(
      CP_UTF8, 0, utf8.c_str(), -1, wide.data(), size_needed);
  return wide;
}

std::string WideToUtf8(const std::wstring& wide) {
  if (wide.empty()) {
    return std::string();
  }
  const int size_needed =
      WideCharToMultiByte(CP_UTF8, 0, wide.c_str(), -1, nullptr, 0, nullptr, nullptr);
  if (size_needed <= 0) {
    return std::string();
  }
  std::string utf8(static_cast<size_t>(size_needed) - 1, '\0');
  WideCharToMultiByte(
      CP_UTF8, 0, wide.c_str(), -1, utf8.data(), size_needed, nullptr, nullptr);
  return utf8;
}

const EncodableMap* GetArgs(const MethodCall& call) {
  const auto* arguments = call.arguments();
  if (arguments == nullptr) {
    return nullptr;
  }
  return std::get_if<EncodableMap>(arguments);
}

std::optional<std::string> GetStringArg(const EncodableMap& args,
                                        const char* key) {
  const auto it = args.find(EncodableValue(key));
  if (it == args.end()) {
    return std::nullopt;
  }
  const auto* value = std::get_if<std::string>(&it->second);
  if (value == nullptr || value->empty()) {
    return std::nullopt;
  }
  return *value;
}

std::vector<int> GetIntListArg(const EncodableMap& args, const char* key) {
  std::vector<int> values;
  const auto it = args.find(EncodableValue(key));
  if (it == args.end()) {
    return values;
  }
  const auto* list = std::get_if<flutter::EncodableList>(&it->second);
  if (list == nullptr) {
    return values;
  }
  values.reserve(list->size());
  for (const auto& value : *list) {
    if (const auto* int32_value = std::get_if<int32_t>(&value)) {
      values.push_back(*int32_value);
      continue;
    }
    if (const auto* int64_value = std::get_if<int64_t>(&value)) {
      values.push_back(static_cast<int>(*int64_value));
    }
  }
  return values;
}

std::optional<std::wstring> ReadRegistryString(HKEY root,
                                               const std::wstring& subkey,
                                               const wchar_t* value_name) {
  HKEY key = nullptr;
  if (RegOpenKeyExW(root, subkey.c_str(), 0, KEY_READ, &key) != ERROR_SUCCESS) {
    return std::nullopt;
  }

  DWORD type = 0;
  DWORD size = 0;
  const LONG size_result =
      RegQueryValueExW(key, value_name, nullptr, &type, nullptr, &size);
  if (size_result != ERROR_SUCCESS || (type != REG_SZ && type != REG_EXPAND_SZ) ||
      size == 0) {
    RegCloseKey(key);
    return std::nullopt;
  }

  std::wstring value(size / sizeof(wchar_t), L'\0');
  const LONG read_result = RegQueryValueExW(
      key,
      value_name,
      nullptr,
      &type,
      reinterpret_cast<LPBYTE>(value.data()),
      &size);
  RegCloseKey(key);
  if (read_result != ERROR_SUCCESS) {
    return std::nullopt;
  }

  while (!value.empty() && value.back() == L'\0') {
    value.pop_back();
  }
  return value;
}

bool IsDeviceClassAllowed(DeviceClass device_class) {
  try {
    const auto access_info =
        DeviceAccessInformation::CreateFromDeviceClass(device_class);
    switch (access_info.CurrentStatus()) {
      case DeviceAccessStatus::DeniedBySystem:
      case DeviceAccessStatus::DeniedByUser:
        return false;
      case DeviceAccessStatus::Allowed:
      case DeviceAccessStatus::Unspecified:
      default:
        return true;
    }
  } catch (...) {
    return true;
  }
}

bool HasPermission(int permission) {
  switch (permission) {
    case kCameraPermission:
      return IsDeviceClassAllowed(DeviceClass::VideoCapture);
    case kMicrophonePermission:
      return IsDeviceClassAllowed(DeviceClass::AudioCapture);
    case kBluetoothPermission:
      return true;
    default:
      return false;
  }
}

std::string MciErrorToString(MCIERROR error_code) {
  wchar_t message[256] = {0};
  if (mciGetErrorStringW(error_code, message, sizeof(message) / sizeof(wchar_t)) ==
      FALSE) {
    return "unknown mci error";
  }
  return WideToUtf8(message);
}

bool OpenPrivacySettings() {
  const HINSTANCE result =
      ShellExecuteW(nullptr,
                    L"open",
                    L"ms-settings:privacy",
                    nullptr,
                    nullptr,
                    SW_SHOWNORMAL);
  return reinterpret_cast<INT_PTR>(result) > 32;
}

}  // namespace

class CallKitUIPlugin::Impl {
 public:
  static constexpr wchar_t kRingAlias[] = L"ne_callkit_ui_ring";

  explicit Impl(flutter::PluginRegistrarWindows* registrar)
      : registrar_(registrar),
        method_channel_(std::make_unique<flutter::MethodChannel<EncodableValue>>(
            registrar_->messenger(),
            kMethodChannelName,
            &flutter::StandardMethodCodec::GetInstance())) {
    method_channel_->SetMethodCallHandler(
        [this](const MethodCall& call,
               std::unique_ptr<MethodResult> result) {
          HandleMethodCall(call, std::move(result));
        });
    window_proc_delegate_id_ =
        registrar_->RegisterTopLevelWindowProcDelegate(
            [this](HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam)
                -> std::optional<LRESULT> {
              return HandleWindowProc(hwnd, message, wparam, lparam);
            });
  }

  ~Impl() {
    StopRingPlayback();
    if (window_proc_delegate_id_ != 0) {
      registrar_->UnregisterTopLevelWindowProcDelegate(window_proc_delegate_id_);
      window_proc_delegate_id_ = 0;
    }
  }

 private:
  void StopRingPlayback() {
    if (!ring_open_) {
      return;
    }
    mciSendStringW((std::wstring(L"stop ") + kRingAlias).c_str(), nullptr, 0, nullptr);
    mciSendStringW((std::wstring(L"close ") + kRingAlias).c_str(), nullptr, 0, nullptr);
    ring_open_ = false;
  }

  bool StartRingPlayback(const std::string& file_path, std::string* error_detail) {
    const std::wstring wide_path = Utf8ToWide(file_path);
    if (wide_path.empty() || !std::filesystem::exists(wide_path)) {
      if (error_detail != nullptr) {
        *error_detail = "ring file does not exist";
      }
      return false;
    }

    StopRingPlayback();

    const std::wstring open_command =
        std::wstring(L"open \"") + wide_path + L"\" type mpegvideo alias " + kRingAlias;
    MCIERROR error = mciSendStringW(open_command.c_str(), nullptr, 0, nullptr);
    if (error != 0) {
      if (error_detail != nullptr) {
        *error_detail = MciErrorToString(error);
      }
      return false;
    }

    error = mciSendStringW(
        (std::wstring(L"play ") + kRingAlias + L" repeat").c_str(), nullptr, 0, nullptr);
    if (error != 0) {
      mciSendStringW((std::wstring(L"close ") + kRingAlias).c_str(), nullptr, 0, nullptr);
      if (error_detail != nullptr) {
        *error_detail = MciErrorToString(error);
      }
      return false;
    }

    ring_open_ = true;
    return true;
  }

  void HandleMethodCall(const MethodCall& call,
                        std::unique_ptr<MethodResult> result) {
    if (call.method_name() == "startRing") {
      const auto* args = GetArgs(call);
      if (args == nullptr) {
        result->Error("invalid_args", "missing arguments");
        return;
      }
      const auto file_path = GetStringArg(*args, "filePath");
      if (!file_path.has_value()) {
        result->Error("invalid_args", "filePath is required");
        return;
      }
      if (!std::filesystem::exists(Utf8ToWide(*file_path))) {
        result->Error("ring_missing", "ring file does not exist", *file_path);
        return;
      }
      std::string error_detail;
      if (!StartRingPlayback(*file_path, &error_detail)) {
        result->Error("ring_start_failed", "failed to start ring", error_detail);
        return;
      }
      result->Success();
      return;
    }

    if (call.method_name() == "stopRing") {
      StopRingPlayback();
      result->Success();
      return;
    }

    if (call.method_name() == "hasPermissions") {
      const auto* args = GetArgs(call);
      if (args == nullptr) {
        result->Success(EncodableValue(false));
        return;
      }
      const auto permissions = GetIntListArg(*args, "permission");
      bool granted = !permissions.empty();
      for (const int permission : permissions) {
        if (!HasPermission(permission)) {
          granted = false;
          break;
        }
      }
      result->Success(EncodableValue(granted));
      return;
    }

    if (call.method_name() == "requestPermissions") {
      const auto* args = GetArgs(call);
      if (args == nullptr) {
        result->Success(EncodableValue(kPermissionDenied));
        return;
      }
      const auto permissions = GetIntListArg(*args, "permission");
      bool granted = !permissions.empty();
      for (const int permission : permissions) {
        if (!HasPermission(permission)) {
          granted = false;
          break;
        }
      }
      result->Success(
          EncodableValue(granted ? kPermissionGranted : kPermissionDenied));
      return;
    }

    if (call.method_name() == "startToPermissionSetting") {
      result->Success(EncodableValue(OpenPrivacySettings()));
      return;
    }

    result->NotImplemented();
  }

  std::optional<LRESULT> HandleWindowProc(HWND hwnd,
                                          UINT message,
                                          WPARAM wparam,
                                          LPARAM lparam) {
    (void)hwnd;
    (void)wparam;
    (void)lparam;
    switch (message) {
      case WM_CLOSE:
      case WM_DESTROY:
      case WM_ENDSESSION:
      case WM_QUERYENDSESSION:
        StopRingPlayback();
        break;
      default:
        break;
    }
    return std::nullopt;
  }

  flutter::PluginRegistrarWindows* registrar_ = nullptr;
  std::unique_ptr<flutter::MethodChannel<EncodableValue>> method_channel_;
  int window_proc_delegate_id_ = 0;
  bool ring_open_ = false;
};

CallKitUIPlugin::CallKitUIPlugin(flutter::PluginRegistrarWindows* registrar)
    : impl_(std::make_unique<Impl>(registrar)) {}

CallKitUIPlugin::~CallKitUIPlugin() = default;

void CallKitUIPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<CallKitUIPlugin>(registrar);
  registrar->AddPlugin(std::move(plugin));
}

}  // namespace netease_callkit_ui
