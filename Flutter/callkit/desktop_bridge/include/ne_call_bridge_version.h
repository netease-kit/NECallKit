#ifndef NE_CALL_BRIDGE_VERSION_H
#define NE_CALL_BRIDGE_VERSION_H

#include <stdint.h>

#include "ne_call_bridge_types.h"

#ifdef __cplusplus
extern "C" {
#endif

#define NE_CALL_BRIDGE_ABI_VERSION_MAJOR 2u
#define NE_CALL_BRIDGE_ABI_VERSION_MINOR 0u
#define NE_CALL_BRIDGE_ABI_VERSION_PATCH 0u

enum {
  NE_CALL_BRIDGE_CAPABILITY_LIFECYCLE = 1ull << 0,
  NE_CALL_BRIDGE_CAPABILITY_CALL_CONTROL = 1ull << 1,
  NE_CALL_BRIDGE_CAPABILITY_CALLBACK = 1ull << 2,
  NE_CALL_BRIDGE_CAPABILITY_MEDIA_CONTROL = 1ull << 3,
  NE_CALL_BRIDGE_CAPABILITY_QUERY = 1ull << 4,
  NE_CALL_BRIDGE_CAPABILITY_ERROR_MAPPING = 1ull << 5,
  NE_CALL_BRIDGE_CAPABILITY_RECORD_PROVIDER = 1ull << 6,
  NE_CALL_BRIDGE_CAPABILITY_MULTI_CLIENT_LOGIN = 1ull << 7,
};

// Returns the current bridge ABI version. Backward-compatible additive changes
// must keep the same major version and only increment minor/patch.
NECallBridgeVersion ne_call_bridge_get_abi_version(void);

// Returns the full capability bitmask for the current bridge build.
uint64_t ne_call_bridge_get_capabilities(void);

// Returns 1 only when all requested capability bits are supported.
int32_t ne_call_bridge_supports_capability(uint64_t capability);

#ifdef __cplusplus
}
#endif

#endif // NE_CALL_BRIDGE_VERSION_H
