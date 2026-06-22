#include "callkit_plugin.h"

#include <windows.h>

#include <algorithm>
#include <flutter/basic_message_channel.h>
#include <flutter/encodable_value.h>
#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/standard_method_codec.h>
#include <flutter/standard_message_codec.h>
#include <flutter/texture_registrar.h>

#include <atomic>
#include <cstring>
#include <memory>
#include <mutex>
#include <optional>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>

#include "ne_call_bridge.h"

namespace netease_callkit {
namespace {

constexpr char kCreateRendererChannel[] =
    "dev.flutter.pigeon.CallkitVideoRendererApi.createVideoRenderer";
constexpr char kSetMirrorChannel[] =
    "dev.flutter.pigeon.CallkitVideoRendererApi.setMirror";
constexpr char kSetupLocalRendererChannel[] =
    "dev.flutter.pigeon.CallkitVideoRendererApi.setupLocalVideoRenderer";
constexpr char kSetupRemoteRendererChannel[] =
    "dev.flutter.pigeon.CallkitVideoRendererApi.setupRemoteVideoRenderer";
constexpr char kDisposeRendererChannel[] =
    "dev.flutter.pigeon.CallkitVideoRendererApi.disposeVideoRenderer";

using EncodableValue = flutter::EncodableValue;
using EncodableList = flutter::EncodableList;
using EncodableMap = flutter::EncodableMap;
using MessageReply = flutter::MessageReply<EncodableValue>;

EncodableValue SuccessReply() {
  return EncodableValue(EncodableList{});
}

EncodableValue SuccessReply(int64_t value) {
  return EncodableValue(EncodableList{EncodableValue(value)});
}

EncodableValue ErrorReply(const std::string& code,
                          const std::string& message,
                          int64_t details) {
  return EncodableValue(EncodableList{
      EncodableValue(code),
      EncodableValue(message),
      EncodableValue(details),
  });
}

std::optional<int64_t> GetInt64Arg(const EncodableValue& message, size_t index) {
  const auto* list = std::get_if<EncodableList>(&message);
  if (list == nullptr || index >= list->size()) {
    return std::nullopt;
  }
  const auto& value = list->at(index);
  if (const auto* int_value = std::get_if<int32_t>(&value)) {
    return *int_value;
  }
  if (const auto* int64_value = std::get_if<int64_t>(&value)) {
    return *int64_value;
  }
  return std::nullopt;
}

std::optional<bool> GetBoolArg(const EncodableValue& message, size_t index) {
  const auto* list = std::get_if<EncodableList>(&message);
  if (list == nullptr || index >= list->size()) {
    return std::nullopt;
  }
  const auto* bool_value = std::get_if<bool>(&list->at(index));
  return bool_value == nullptr ? std::nullopt : std::optional<bool>(*bool_value);
}

template <typename T>
T LookupSymbol(HMODULE module, const char* name) {
  if (module == nullptr) {
    return nullptr;
  }
  return reinterpret_cast<T>(GetProcAddress(module, name));
}

class BridgeApi {
 public:
  bool EnsureLoaded() {
    if (loaded_) {
      return create_ != nullptr;
    }
    loaded_ = true;

    const wchar_t* candidates[] = {
        L"ne_callkit.dll",
        L"ne_call_bridge.dll",
        nullptr,
    };
    for (const wchar_t** candidate = candidates; *candidate != nullptr; ++candidate) {
      module_ = LoadLibraryW(*candidate);
      if (module_ != nullptr) {
        break;
      }
      module_ = GetModuleHandleW(*candidate);
      if (module_ != nullptr) {
        break;
      }
    }

    create_ = LookupSymbol<CreateFn>(module_, "ne_call_bridge_create");
    register_video_renderer_ = LookupSymbol<RegisterVideoRendererFn>(
        module_, "ne_call_bridge_register_video_renderer");
    unregister_video_renderer_ = LookupSymbol<UnregisterVideoRendererFn>(
        module_, "ne_call_bridge_unregister_video_renderer");
    setup_local_video_renderer_ = LookupSymbol<SetupLocalVideoRendererFn>(
        module_, "ne_call_bridge_setup_local_video_renderer");
    setup_remote_video_renderer_with_uid_ =
        LookupSymbol<SetupRemoteVideoRendererWithUidFn>(
            module_, "ne_call_bridge_setup_remote_video_renderer_with_uid");
    set_video_renderer_mirror_ = LookupSymbol<SetVideoRendererMirrorFn>(
        module_, "ne_call_bridge_set_video_renderer_mirror");

    return create_ != nullptr && register_video_renderer_ != nullptr &&
           unregister_video_renderer_ != nullptr &&
           setup_local_video_renderer_ != nullptr &&
           setup_remote_video_renderer_with_uid_ != nullptr &&
           set_video_renderer_mirror_ != nullptr;
  }

  NECallBridgeHandle EnsureHandle() {
    if (bridge_handle_ != nullptr) {
      return bridge_handle_;
    }
    if (!EnsureLoaded()) {
      return nullptr;
    }
    bridge_handle_ = create_();
    return bridge_handle_;
  }

  int32_t RegisterVideoRenderer(const NECallBridgeVideoRendererParam& param) {
    auto handle = EnsureHandle();
    return handle == nullptr ? -1 : register_video_renderer_(handle, &param);
  }

  int32_t UnregisterVideoRenderer(int64_t renderer_id) {
    auto handle = EnsureHandle();
    return handle == nullptr ? -1 : unregister_video_renderer_(handle, renderer_id);
  }

  int32_t SetupLocalVideoRenderer(int64_t renderer_id) {
    auto handle = EnsureHandle();
    return handle == nullptr ? -1
                             : setup_local_video_renderer_(handle, renderer_id);
  }

  int32_t SetupRemoteVideoRenderer(int64_t uid, int64_t renderer_id) {
    auto handle = EnsureHandle();
    return handle == nullptr
               ? -1
               : setup_remote_video_renderer_with_uid_(
                     handle, static_cast<uint64_t>(uid), renderer_id);
  }

  int32_t SetVideoRendererMirror(int64_t renderer_id, bool mirror) {
    auto handle = EnsureHandle();
    return handle == nullptr ? -1
                             : set_video_renderer_mirror_(
                                   handle, renderer_id, mirror ? 1 : 0);
  }

 private:
  using CreateFn = NECallBridgeHandle (*)();
  using RegisterVideoRendererFn = int32_t (*)(
      NECallBridgeHandle, const NECallBridgeVideoRendererParam*);
  using UnregisterVideoRendererFn = int32_t (*)(NECallBridgeHandle, int64_t);
  using SetupLocalVideoRendererFn = int32_t (*)(NECallBridgeHandle, int64_t);
  using SetupRemoteVideoRendererWithUidFn =
      int32_t (*)(NECallBridgeHandle, uint64_t, int64_t);
  using SetVideoRendererMirrorFn =
      int32_t (*)(NECallBridgeHandle, int64_t, uint8_t);

  bool loaded_ = false;
  HMODULE module_ = nullptr;
  NECallBridgeHandle bridge_handle_ = nullptr;
  CreateFn create_ = nullptr;
  RegisterVideoRendererFn register_video_renderer_ = nullptr;
  UnregisterVideoRendererFn unregister_video_renderer_ = nullptr;
  SetupLocalVideoRendererFn setup_local_video_renderer_ = nullptr;
  SetupRemoteVideoRendererWithUidFn setup_remote_video_renderer_with_uid_ =
      nullptr;
  SetVideoRendererMirrorFn set_video_renderer_mirror_ = nullptr;
};

BridgeApi& GetBridgeApi() {
  static BridgeApi api;
  return api;
}

class DesktopVideoRenderer
    : public std::enable_shared_from_this<DesktopVideoRenderer> {
 public:
  class CallbackState {
   public:
    void AttachOwner(const std::shared_ptr<DesktopVideoRenderer>& owner) {
      std::lock_guard<std::mutex> lock(mutex_);
      owner_ = owner;
      retired_.store(false);
    }

    void Retire() {
      std::lock_guard<std::mutex> lock(mutex_);
      retired_.store(true);
      owner_.reset();
    }

    std::shared_ptr<DesktopVideoRenderer> AcquireOwner() {
      std::lock_guard<std::mutex> lock(mutex_);
      if (retired_.load()) {
        return nullptr;
      }
      return owner_.lock();
    }

    void BeginCallback() { in_flight_callbacks_.fetch_add(1); }

    void EndCallback() { in_flight_callbacks_.fetch_sub(1); }

    bool CanDestroy() const {
      return retired_.load() && in_flight_callbacks_.load() == 0;
    }

   private:
    mutable std::mutex mutex_;
    std::weak_ptr<DesktopVideoRenderer> owner_;
    std::atomic<bool> retired_{false};
    std::atomic<uint32_t> in_flight_callbacks_{0};
  };

  static std::shared_ptr<DesktopVideoRenderer> Create(
      flutter::BinaryMessenger* messenger,
      flutter::TextureRegistrar* texture_registrar) {
    auto renderer = std::shared_ptr<DesktopVideoRenderer>(
        new DesktopVideoRenderer(messenger, texture_registrar));
    renderer->callback_state_->AttachOwner(renderer);
    return renderer;
  }

  DesktopVideoRenderer(flutter::BinaryMessenger* messenger,
                       flutter::TextureRegistrar* texture_registrar)
      : messenger_(messenger), texture_registrar_(texture_registrar) {
    texture_ = std::make_unique<flutter::TextureVariant>(
        flutter::PixelBufferTexture([this](size_t width, size_t height) {
          return this->CopyPixelBuffer(width, height);
        }));
    texture_id_ = texture_registrar_->RegisterTexture(texture_.get());
    event_channel_ = std::make_unique<flutter::EventChannel<EncodableValue>>(
        messenger_,
        "NECallkitRenderer/Texture" + std::to_string(texture_id_),
        &flutter::StandardMethodCodec::GetInstance());
    event_channel_->SetStreamHandler(
        std::make_unique<flutter::StreamHandlerFunctions<EncodableValue>>(
            [this](const EncodableValue* arguments,
                   std::unique_ptr<flutter::EventSink<EncodableValue>>&& events)
                -> std::unique_ptr<flutter::StreamHandlerError<EncodableValue>> {
              std::lock_guard<std::mutex> lock(event_sink_mutex_);
              event_sink_ = std::move(events);
              return nullptr;
            },
            [this](const EncodableValue* arguments)
                -> std::unique_ptr<flutter::StreamHandlerError<EncodableValue>> {
              std::lock_guard<std::mutex> lock(event_sink_mutex_);
              event_sink_.reset();
              return nullptr;
            }));
    pixel_buffer_.release_callback = [](void* release_context) {
      auto* mutex = static_cast<std::mutex*>(release_context);
      if (mutex != nullptr) {
        mutex->unlock();
      }
    };
  }

  ~DesktopVideoRenderer() = default;

  int64_t texture_id() const { return texture_id_; }
  CallbackState* callback_state() const { return callback_state_.get(); }
  std::shared_ptr<CallbackState> shared_callback_state() const {
    return callback_state_;
  }

  void Dispose() {
    bool expected = false;
    if (!disposed_.compare_exchange_strong(expected, true)) {
      return;
    }

    callback_state_->Retire();
    event_channel_->SetStreamHandler(nullptr);
    {
      std::lock_guard<std::mutex> lock(event_sink_mutex_);
      event_sink_.reset();
    }
    has_frame_ = false;
    // Stop native callbacks before tearing down the Flutter texture.
    GetBridgeApi().UnregisterVideoRenderer(texture_id_);
    // Keep the renderer alive until Flutter finishes unregistering the texture.
    auto keep_alive = shared_from_this();
    texture_registrar_->UnregisterTexture(texture_id_,
                                          [keep_alive = std::move(keep_alive)]() {});
  }

  void HandleFrame(const uint8_t* bgra,
                   uint32_t width,
                   uint32_t height,
                   uint32_t rotation) {
    if (disposed_.load()) {
      return;
    }
    if (bgra == nullptr || width == 0 || height == 0) {
      return;
    }

    bool emit_first_frame = false;
    bool emit_resolution_changed = false;
    {
      std::lock_guard<std::mutex> lock(frame_mutex_);
      const size_t length = static_cast<size_t>(width) * height * 4;
      rgba_buffer_.resize(length);
      for (size_t offset = 0; offset < length; offset += 4) {
        rgba_buffer_[offset] = bgra[offset + 2];
        rgba_buffer_[offset + 1] = bgra[offset + 1];
        rgba_buffer_[offset + 2] = bgra[offset];
        rgba_buffer_[offset + 3] = bgra[offset + 3];
      }
      width_ = width;
      height_ = height;
      rotation_ = rotation;
      has_frame_ = true;
      pixel_buffer_.buffer = rgba_buffer_.data();
      pixel_buffer_.width = width_;
      pixel_buffer_.height = height_;
      emit_first_frame = !did_emit_first_frame_;
      if (!did_emit_first_frame_) {
        did_emit_first_frame_ = true;
      }
      emit_resolution_changed = last_event_width_ != width ||
                                last_event_height_ != height ||
                                last_event_rotation_ != rotation;
      last_event_width_ = width;
      last_event_height_ = height;
      last_event_rotation_ = rotation;
    }

    if (disposed_.load()) {
      return;
    }
    if (frame_notification_pending_.exchange(true)) {
      return;
    }
    texture_registrar_->MarkTextureFrameAvailable(texture_id_);
    frame_notification_pending_.store(false);
    std::lock_guard<std::mutex> event_sink_lock(event_sink_mutex_);
    if (event_sink_ != nullptr) {
      if (emit_first_frame) {
        EncodableMap event{
            {EncodableValue("event"), EncodableValue("onFirstFrameRendered")},
            {EncodableValue("id"), EncodableValue(texture_id_)},
        };
        event_sink_->Success(EncodableValue(event));
      }
      if (emit_resolution_changed) {
        EncodableMap event{
            {EncodableValue("event"),
             EncodableValue("onFrameResolutionChanged")},
            {EncodableValue("id"), EncodableValue(texture_id_)},
            {EncodableValue("width"), EncodableValue(static_cast<int32_t>(width))},
            {EncodableValue("height"),
             EncodableValue(static_cast<int32_t>(height))},
            {EncodableValue("rotation"),
             EncodableValue(static_cast<int32_t>(rotation))},
        };
        event_sink_->Success(EncodableValue(event));
      }
    }
  }

 private:
  const FlutterDesktopPixelBuffer* CopyPixelBuffer(size_t width, size_t height) {
    std::unique_lock<std::mutex> lock(frame_mutex_);
    if (!has_frame_ || rgba_buffer_.empty() || width_ == 0 || height_ == 0) {
      return nullptr;
    }
    pixel_buffer_.release_context = lock.release();
    return &pixel_buffer_;
  }

  flutter::BinaryMessenger* messenger_;
  flutter::TextureRegistrar* texture_registrar_;
  std::unique_ptr<flutter::TextureVariant> texture_;
  std::unique_ptr<flutter::EventChannel<EncodableValue>> event_channel_;
  std::mutex event_sink_mutex_;
  std::unique_ptr<flutter::EventSink<EncodableValue>> event_sink_;
  std::shared_ptr<CallbackState> callback_state_ =
      std::make_shared<CallbackState>();
  int64_t texture_id_ = -1;
  std::mutex frame_mutex_;
  std::vector<uint8_t> rgba_buffer_;
  FlutterDesktopPixelBuffer pixel_buffer_{};
  uint32_t width_ = 0;
  uint32_t height_ = 0;
  uint32_t rotation_ = 0;
  uint32_t last_event_width_ = 0;
  uint32_t last_event_height_ = 0;
  uint32_t last_event_rotation_ = 0;
  bool has_frame_ = false;
  bool did_emit_first_frame_ = false;
  std::atomic<bool> disposed_{false};
  std::atomic<bool> frame_notification_pending_{false};
};

void DesktopRendererFrameCallback(int64_t renderer_id,
                                  const uint8_t* bgra,
                                  uint32_t width,
                                  uint32_t height,
                                  uint32_t rotation,
                                  void* user_data) {
  (void)renderer_id;
  auto* callback_state =
      static_cast<DesktopVideoRenderer::CallbackState*>(user_data);
  if (callback_state == nullptr) {
    return;
  }
  callback_state->BeginCallback();
  auto renderer = callback_state->AcquireOwner();
  if (renderer == nullptr) {
    callback_state->EndCallback();
    return;
  }
  renderer->HandleFrame(bgra, width, height, rotation);
  callback_state->EndCallback();
}

}  // namespace

class CallkitPlugin::Impl {
 public:
  explicit Impl(flutter::PluginRegistrarWindows* registrar)
      : registrar_(registrar),
        messenger_(registrar->messenger()),
        texture_registrar_(registrar->texture_registrar()) {
    AddChannel(kCreateRendererChannel,
               [this](const EncodableValue& message, const MessageReply& reply) {
                 HandleCreateRenderer(reply);
               });
    AddChannel(kSetMirrorChannel,
               [this](const EncodableValue& message, const MessageReply& reply) {
                 HandleSetMirror(message, reply);
               });
    AddChannel(kSetupLocalRendererChannel,
               [this](const EncodableValue& message, const MessageReply& reply) {
                 HandleSetupLocalRenderer(message, reply);
               });
    AddChannel(kSetupRemoteRendererChannel,
               [this](const EncodableValue& message, const MessageReply& reply) {
                 HandleSetupRemoteRenderer(message, reply);
               });
    AddChannel(kDisposeRendererChannel,
               [this](const EncodableValue& message, const MessageReply& reply) {
                 HandleDisposeRenderer(message, reply);
               });
  }

  void HandleCreateRenderer(const MessageReply& reply) {
    if (GetBridgeApi().EnsureHandle() == nullptr) {
      reply(ErrorReply("bridge_unavailable", "desktop bridge unavailable", -1));
      return;
    }

    CleanupRetiredCallbackStates();
    auto renderer = DesktopVideoRenderer::Create(messenger_, texture_registrar_);
    NECallBridgeVideoRendererParam param{};
    param.renderer_id = renderer->texture_id();
    param.on_frame = DesktopRendererFrameCallback;
    param.user_data = renderer->callback_state();
    const int32_t result = GetBridgeApi().RegisterVideoRenderer(param);
    if (result != 0) {
      renderer->Dispose();
      reply(ErrorReply("bridge_register_failed",
                       "failed to register desktop renderer", result));
      return;
    }

    const int64_t texture_id = renderer->texture_id();
    renderers_[texture_id] = std::move(renderer);
    reply(SuccessReply(texture_id));
  }

  void HandleSetMirror(const EncodableValue& message, const MessageReply& reply) {
    const auto texture_id = GetInt64Arg(message, 0);
    const auto mirror = GetBoolArg(message, 1);
    if (!texture_id.has_value() || !mirror.has_value()) {
      reply(ErrorReply("invalid_args", "invalid mirror arguments", -1));
      return;
    }
    const int32_t result =
        GetBridgeApi().SetVideoRendererMirror(*texture_id, *mirror);
    reply(SuccessReply(result));
  }

  void HandleSetupLocalRenderer(const EncodableValue& message,
                                const MessageReply& reply) {
    const auto texture_id = GetInt64Arg(message, 0);
    if (!texture_id.has_value()) {
      reply(ErrorReply("invalid_args", "invalid local renderer arguments", -1));
      return;
    }
    const int32_t result = GetBridgeApi().SetupLocalVideoRenderer(*texture_id);
    reply(SuccessReply(result));
  }

  void HandleSetupRemoteRenderer(const EncodableValue& message,
                                 const MessageReply& reply) {
    const auto uid = GetInt64Arg(message, 0);
    const auto texture_id = GetInt64Arg(message, 1);
    if (!uid.has_value() || !texture_id.has_value()) {
      reply(ErrorReply("invalid_args", "invalid remote renderer arguments", -1));
      return;
    }
    const int32_t result =
        GetBridgeApi().SetupRemoteVideoRenderer(*uid, *texture_id);
    reply(SuccessReply(result));
  }

  void HandleDisposeRenderer(const EncodableValue& message,
                             const MessageReply& reply) {
    const auto texture_id = GetInt64Arg(message, 0);
    if (!texture_id.has_value()) {
      reply(ErrorReply("invalid_args", "invalid dispose arguments", -1));
      return;
    }
    auto it = renderers_.find(*texture_id);
    if (it != renderers_.end()) {
      retired_callback_states_.push_back(it->second->shared_callback_state());
      it->second->Dispose();
      renderers_.erase(it);
      CleanupRetiredCallbackStates();
    } else {
      GetBridgeApi().UnregisterVideoRenderer(*texture_id);
    }
    reply(SuccessReply());
  }

 private:
  void CleanupRetiredCallbackStates() {
    retired_callback_states_.erase(
        std::remove_if(retired_callback_states_.begin(),
                       retired_callback_states_.end(),
                       [](const std::shared_ptr<DesktopVideoRenderer::CallbackState>& state) {
                         return state == nullptr || state->CanDestroy();
                       }),
        retired_callback_states_.end());
  }

  void AddChannel(
      const std::string& name,
      const flutter::MessageHandler<EncodableValue>& handler) {
    auto channel = std::make_unique<flutter::BasicMessageChannel<EncodableValue>>(
        messenger_, name, &flutter::StandardMessageCodec::GetInstance());
    channel->SetMessageHandler(handler);
    channels_.push_back(std::move(channel));
  }

  flutter::PluginRegistrarWindows* registrar_;
  flutter::BinaryMessenger* messenger_;
  flutter::TextureRegistrar* texture_registrar_;
  std::vector<
      std::unique_ptr<flutter::BasicMessageChannel<EncodableValue>>>
      channels_;
  std::unordered_map<int64_t, std::shared_ptr<DesktopVideoRenderer>> renderers_;
  std::vector<std::shared_ptr<DesktopVideoRenderer::CallbackState>>
      retired_callback_states_;
};

void CallkitPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<CallkitPlugin>(registrar);
  registrar->AddPlugin(std::move(plugin));
}

CallkitPlugin::CallkitPlugin(flutter::PluginRegistrarWindows* registrar)
    : impl_(std::make_unique<Impl>(registrar)) {}

CallkitPlugin::~CallkitPlugin() = default;

}  // namespace netease_callkit

extern "C" __declspec(dllexport) void CallkitPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  auto* plugin_registrar =
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar);
  netease_callkit::CallkitPlugin::RegisterWithRegistrar(plugin_registrar);
}
