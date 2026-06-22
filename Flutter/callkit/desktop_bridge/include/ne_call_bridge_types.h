#ifndef NE_CALL_BRIDGE_TYPES_H
#define NE_CALL_BRIDGE_TYPES_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
  uint32_t major;
  uint32_t minor;
  uint32_t patch;
} NECallBridgeVersion;

typedef struct {
  int32_t code;
  const char* message;
} NECallBridgeError;

typedef struct {
  void* opaque;
} NECallBridgeHandleRef;

typedef struct {
  const char* acc_id;
  uint64_t uid;
} NECallBridgeCallUserInfo;

typedef struct {
  const char* channel_id;
  const char* request_id;
  const char* channel_name;
  const char* extra_info;
  const char* global_extra_copy;
} NECallBridgeSignalInfo;

typedef struct {
  const char* channel_name;
  const char* token;
  uint64_t cid;
  uint64_t uid;
} NECallBridgeRtcInfo;

typedef struct {
  const char* call_id;
  const char* current_acc_id;
  NECallBridgeCallUserInfo caller_info;
  NECallBridgeCallUserInfo callee_info;
  int32_t call_type;
  NECallBridgeSignalInfo signal_info;
  NECallBridgeRtcInfo rtc_info;
  // Public call state aligned with iOS `NERtcCallStatus`: 0 idle, 1 calling,
  // 2 called, 3 inCall.
  int32_t call_status;
} NECallBridgeCallInfoParam;

#ifdef __cplusplus
}
#endif

#endif // NE_CALL_BRIDGE_TYPES_H
