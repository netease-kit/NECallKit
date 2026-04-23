#ifndef NE_CALL_BRIDGE_EVENTS_H
#define NE_CALL_BRIDGE_EVENTS_H

#include <stdint.h>

#include "ne_call_bridge_types.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
  NE_CALL_BRIDGE_EVENT_UNKNOWN = 0,
  NE_CALL_BRIDGE_EVENT_RECEIVE_INVITED = 1,
  NE_CALL_BRIDGE_EVENT_CALL_CONNECTED = 2,
  NE_CALL_BRIDGE_EVENT_CALL_END = 3,
  NE_CALL_BRIDGE_EVENT_CALL_TYPE_CHANGE = 4,
  NE_CALL_BRIDGE_EVENT_VIDEO_AVAILABLE = 5,
  NE_CALL_BRIDGE_EVENT_VIDEO_MUTED = 6,
  NE_CALL_BRIDGE_EVENT_AUDIO_MUTED = 7,
  NE_CALL_BRIDGE_EVENT_DEBUG_LOG = 8,
  NE_CALL_BRIDGE_EVENT_LOCAL_AUDIO_MUTED = 9,
  NE_CALL_BRIDGE_EVENT_RTC_INIT_END = 10,
  NE_CALL_BRIDGE_EVENT_RECORD_SEND = 11,
} NECallBridgeEventType;

// All string fields are UTF-8 and may be null when the upstream runtime does
// not expose a value.
typedef struct {
  const char* caller_acc_id;
  int32_t call_type;
  const char* extra_info;
  const char* channel_id;
} NECallBridgeInvitedPayload;

typedef NECallBridgeCallInfoParam NECallBridgeConnectedPayload;

typedef struct {
  int32_t reason_code;
  const char* extra_string;
  const char* message;
} NECallBridgeEndPayload;

typedef struct {
  uint64_t call_id;
  int32_t call_type;
  uint64_t timestamp_ms;
} NECallBridgeTypeChangePayload;

typedef struct {
  uint64_t call_id;
  const char* user_id;
  uint8_t available;
  uint64_t timestamp_ms;
} NECallBridgeVideoAvailablePayload;

typedef struct {
  uint64_t call_id;
  const char* user_id;
  uint8_t muted;
  uint64_t timestamp_ms;
} NECallBridgeVideoMutedPayload;

typedef struct {
  uint64_t call_id;
  const char* user_id;
  uint8_t muted;
  uint64_t timestamp_ms;
} NECallBridgeAudioMutedPayload;

typedef struct {
  uint64_t call_id;
  const char* message;
  uint64_t timestamp_ms;
} NECallBridgeDebugLogPayload;

typedef struct {
  uint64_t call_id;
  uint8_t muted;
  uint64_t timestamp_ms;
} NECallBridgeLocalAudioMutedPayload;

typedef struct {
  uint64_t call_id;
  uint64_t timestamp_ms;
} NECallBridgeRtcInitEndPayload;

typedef struct {
  uint64_t call_id;
  const char* acc_id;
  int32_t call_type;
  // Call record status aligned with iOS `NIMRtcCallStatus`: 1 complete,
  // 2 cancelled, 3 rejected, 4 timeout, 5 busy.
  int32_t call_state;
  uint64_t timestamp_ms;
} NECallBridgeRecordSendPayload;

// Consumers must switch on `type` before reading the union payload. Unknown
// event types must be ignored so future additive event expansion stays
// backward-compatible for existing hosts.
typedef struct {
  NECallBridgeEventType type;
  union {
    NECallBridgeInvitedPayload invited;
    NECallBridgeConnectedPayload connected;
    NECallBridgeEndPayload ended;
    NECallBridgeTypeChangePayload type_changed;
    NECallBridgeVideoAvailablePayload video_available;
    NECallBridgeVideoMutedPayload video_muted;
    NECallBridgeAudioMutedPayload audio_muted;
    NECallBridgeDebugLogPayload debug_log;
    NECallBridgeLocalAudioMutedPayload local_audio_muted;
    NECallBridgeRtcInitEndPayload rtc_init_end;
    NECallBridgeRecordSendPayload record_send;
  } payload;
} NECallBridgeEvent;

#ifdef __cplusplus
}
#endif

#endif // NE_CALL_BRIDGE_EVENTS_H
