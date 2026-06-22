#ifndef NE_CALL_BRIDGE_H
#define NE_CALL_BRIDGE_H

#include <stdbool.h>
#include <stdint.h>

#include "ne_call_bridge_events.h"
#include "ne_call_bridge_types.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef void* NECallBridgeHandle;

typedef void (*NECallBridgeEventCallback)(const NECallBridgeEvent* event,
                                          void* user_data);

typedef struct {
  const char* app_key;
  const char* framework;
  const char* channel;
  uint64_t current_user_rtc_uid;
  uint8_t enable_join_rtc_when_call;
  int32_t init_rtc_mode;
  int32_t preferred_video_render_mode;
} NECallBridgeSetupConfig;

typedef struct {
  uint8_t need_push;
  const char* push_title;
  const char* push_content;
  const char* push_payload;
  uint8_t need_badge;
} NECallBridgePushConfig;

typedef struct {
  const char* acc_id;
  int32_t call_type;
  const char* extra_info;
  const char* rtc_channel_name;
  const char* global_extra_copy;
  const NECallBridgePushConfig* push_config;
} NECallBridgeCallParam;

typedef struct {
  const char* channel_id;
  const char* extra_string;
} NECallBridgeHangupParam;

typedef struct {
  bool enable_offline;
  bool enable_switch_video_confirm;
  bool enable_switch_audio_confirm;
} NECallBridgeConfigParam;

typedef struct {
  uint64_t current_user_rtc_uid;
} NECallBridgeSelfInfoParam;

typedef struct {
  const char* user_id;
  uint64_t rtc_uid;
} NECallBridgeUserInfoParam;

typedef void (*NECallBridgeVideoFrameCallback)(int64_t renderer_id,
                                               const uint8_t* bgra,
                                               uint32_t width,
                                               uint32_t height,
                                               uint32_t rotation,
                                               void* user_data);

typedef struct {
  int64_t renderer_id;
  NECallBridgeVideoFrameCallback on_frame;
  void* user_data;
} NECallBridgeVideoRendererParam;

typedef void (*NECallBridgeOnReceiveInvited)(const NECallBridgeInvitedPayload* payload,
                                             void* user_data);
typedef void (*NECallBridgeOnCallEnd)(const NECallBridgeEndPayload* payload,
                                      void* user_data);
typedef void (*NECallBridgeOnCallConnected)(const NECallBridgeConnectedPayload* payload,
                                            void* user_data);
typedef void (*NECallBridgeOnCallTypeChange)(const NECallBridgeTypeChangePayload* payload,
                                             void* user_data);
typedef void (*NECallBridgeOnVideoAvailable)(const NECallBridgeVideoAvailablePayload* payload,
                                             void* user_data);
typedef void (*NECallBridgeOnVideoMuted)(const NECallBridgeVideoMutedPayload* payload,
                                         void* user_data);
typedef void (*NECallBridgeOnAudioMuted)(const NECallBridgeAudioMutedPayload* payload,
                                         void* user_data);
typedef void (*NECallBridgeOnLocalAudioMuted)(uint8_t muted, void* user_data);
typedef void (*NECallBridgeOnRtcInitEnd)(void* user_data);
typedef void (*NECallBridgeOnDebugLog)(const NECallBridgeDebugLogPayload* payload,
                                       void* user_data);
typedef void (*NECallBridgeCallCompletion)(
    const NECallBridgeError* error,
    const NECallBridgeCallInfoParam* call_info,
    void* user_data);
typedef void (*NECallBridgeHangupCompletion)(const NECallBridgeError* error,
                                             void* user_data);

typedef struct {
  NECallBridgeOnReceiveInvited on_receive_invited;
  NECallBridgeOnCallEnd on_call_end;
  NECallBridgeOnCallConnected on_call_connected;
  NECallBridgeOnCallTypeChange on_call_type_change;
  NECallBridgeOnVideoAvailable on_video_available;
  NECallBridgeOnVideoMuted on_video_muted;
  NECallBridgeOnAudioMuted on_audio_muted;
  NECallBridgeOnLocalAudioMuted on_local_audio_muted;
  NECallBridgeOnRtcInitEnd on_rtc_init_end;
  NECallBridgeOnDebugLog on_debug_log;
} NECallBridgeDelegate;

NECallBridgeHandle ne_call_bridge_create(void);

void ne_call_bridge_destroy(void);

int32_t ne_call_bridge_setup(NECallBridgeHandle handle,
                             const NECallBridgeSetupConfig* config);

int32_t ne_call_bridge_add_delegate(NECallBridgeHandle handle,
                                    const NECallBridgeDelegate* delegate,
                                    void* user_data);

int32_t ne_call_bridge_remove_delegate(NECallBridgeHandle handle);

int32_t ne_call_bridge_call(NECallBridgeHandle handle,
                            const NECallBridgeCallParam* param,
                            NECallBridgeCallCompletion completion,
                            void* user_data);

int32_t ne_call_bridge_accept(NECallBridgeHandle handle,
                              NECallBridgeCallCompletion completion,
                              void* user_data);

// Aligned with iOS `hangup`: the bridge resolves outgoing cancel, incoming
// reject, and in-call hangup by current state.
int32_t ne_call_bridge_hangup(NECallBridgeHandle handle,
                              const NECallBridgeHangupParam* param,
                              NECallBridgeHangupCompletion completion,
                              void* user_data);

int32_t ne_call_bridge_get_version(NECallBridgeHandle handle,
                                   char* version_buffer,
                                   uint32_t buffer_len);

int32_t ne_call_bridge_set_timeout(NECallBridgeHandle handle, int32_t seconds);

int32_t ne_call_bridge_switch_call_type(NECallBridgeHandle handle,
                                        int32_t call_type,
                                        int32_t state);

int32_t ne_call_bridge_set_call_config(NECallBridgeHandle handle,
                                       const NECallBridgeConfigParam* param);

int32_t ne_call_bridge_get_call_config(NECallBridgeHandle handle,
                                       NECallBridgeConfigParam* param);

int32_t ne_call_bridge_get_call_info(NECallBridgeHandle handle,
                                     NECallBridgeCallInfoParam* param);

int32_t ne_call_bridge_set_self_info(NECallBridgeHandle handle,
                                     const NECallBridgeSelfInfoParam* param);

int32_t ne_call_bridge_set_call_record_provider(NECallBridgeHandle handle,
                                                uint8_t enabled);

int32_t ne_call_bridge_enable_local_video(NECallBridgeHandle handle,
                                          uint8_t enabled);

int32_t ne_call_bridge_mute_local_video(NECallBridgeHandle handle,
                                        uint8_t muted);

int32_t ne_call_bridge_mute_local_audio(NECallBridgeHandle handle,
                                        uint8_t muted);

int32_t ne_call_bridge_switch_camera(NECallBridgeHandle handle);

int32_t ne_call_bridge_set_speakerphone_on(NECallBridgeHandle handle,
                                           uint8_t enabled);

int32_t ne_call_bridge_is_speakerphone_on(NECallBridgeHandle handle,
                                          uint8_t* enabled);

int32_t ne_call_bridge_register_video_renderer(
    NECallBridgeHandle handle,
    const NECallBridgeVideoRendererParam* param);

int32_t ne_call_bridge_unregister_video_renderer(NECallBridgeHandle handle,
                                                 int64_t renderer_id);

int32_t ne_call_bridge_setup_local_video_renderer(NECallBridgeHandle handle,
                                                  int64_t renderer_id);

int32_t ne_call_bridge_setup_remote_video_renderer(NECallBridgeHandle handle,
                                                   int64_t renderer_id);

int32_t ne_call_bridge_setup_remote_video_renderer_with_uid(
    NECallBridgeHandle handle,
    uint64_t rtc_uid,
    int64_t renderer_id);

int32_t ne_call_bridge_setup_local_video_window(NECallBridgeHandle handle,
                                                void* window);

int32_t ne_call_bridge_setup_remote_video_window(NECallBridgeHandle handle,
                                                 void* window);

int32_t ne_call_bridge_set_local_video_window_scaling_mode(
    NECallBridgeHandle handle,
    int32_t scaling_mode);

int32_t ne_call_bridge_set_remote_video_window_scaling_mode(
    NECallBridgeHandle handle,
    int32_t scaling_mode);

int32_t ne_call_bridge_set_video_renderer_mirror(NECallBridgeHandle handle,
                                                 int64_t renderer_id,
                                                 uint8_t mirror);

int32_t ne_call_bridge_get_user_with_rtc_uid(NECallBridgeHandle handle,
                                             uint64_t rtc_uid,
                                             NECallBridgeUserInfoParam* param);

int32_t ne_call_bridge_list_video_capture_devices(NECallBridgeHandle handle,
                                                  char* devices_json_buffer,
                                                  uint32_t buffer_len,
                                                  uint32_t* out_required_len);

int32_t ne_call_bridge_get_current_video_capture_device(
    NECallBridgeHandle handle,
    char* device_id_buffer,
    uint32_t buffer_len,
    uint32_t* out_required_len);

int32_t ne_call_bridge_set_video_capture_device(NECallBridgeHandle handle,
                                                const char* device_id);

int32_t ne_call_bridge_list_audio_recording_devices(NECallBridgeHandle handle,
                                                    char* devices_json_buffer,
                                                    uint32_t buffer_len,
                                                    uint32_t* out_required_len);

int32_t ne_call_bridge_get_current_audio_recording_device(
    NECallBridgeHandle handle,
    char* device_id_buffer,
    uint32_t buffer_len,
    uint32_t* out_required_len);

int32_t ne_call_bridge_set_audio_recording_device(NECallBridgeHandle handle,
                                                  const char* device_id);

int32_t ne_call_bridge_list_audio_playback_devices(NECallBridgeHandle handle,
                                                   char* devices_json_buffer,
                                                   uint32_t buffer_len,
                                                   uint32_t* out_required_len);

int32_t ne_call_bridge_get_current_audio_playback_device(
    NECallBridgeHandle handle,
    char* device_id_buffer,
    uint32_t buffer_len,
    uint32_t* out_required_len);

int32_t ne_call_bridge_set_audio_playback_device(NECallBridgeHandle handle,
                                                 const char* device_id);

int32_t ne_call_bridge_register_event_callback(NECallBridgeHandle handle,
                                               NECallBridgeEventCallback callback,
                                               void* user_data);

// Releases events delivered by `ne_call_bridge_register_event_callback`.
void ne_call_bridge_release_event(const NECallBridgeEvent* event);

int32_t ne_call_bridge_emit_debug_event(NECallBridgeHandle handle,
                                        const NECallBridgeEvent* event);

int32_t ne_call_bridge_emit_receive_invited(NECallBridgeHandle handle,
                                            uint64_t call_id,
                                            const char* from_user_id,
                                            int32_t call_type,
                                            uint64_t timestamp_ms);

int32_t ne_call_bridge_emit_call_connected(NECallBridgeHandle handle,
                                           uint64_t call_id,
                                           const char* peer_user_id,
                                           uint64_t timestamp_ms);

int32_t ne_call_bridge_emit_call_end(NECallBridgeHandle handle,
                                     int32_t reason_code,
                                     const char* extra_string,
                                     const char* message);

int32_t ne_call_bridge_emit_call_type_change(NECallBridgeHandle handle,
                                             uint64_t call_id,
                                             int32_t call_type,
                                             uint64_t timestamp_ms);

#ifdef __cplusplus
}
#endif

#endif // NE_CALL_BRIDGE_H
