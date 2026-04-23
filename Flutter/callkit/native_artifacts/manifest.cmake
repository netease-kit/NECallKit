# Desktop native artifacts for published Flutter desktop packages.
#
# Release pipeline should upload the versioned archives below, then either:
# 1. update NE_CALL_ARTIFACT_BASE_URL in this file, or
# 2. inject platform-specific URLs via environment variables during packaging.
#
# Archive layout conventions:
# - macOS archive root contains:
#     libne_callkit.dylib
#     nertc_sdk_Mac.xcframework/
#     NEXKitBase.xcframework/
# - Windows x64 archive root contains:
#     ne_callkit.dll
#     *.dll required by NERtc / observability

set(NE_CALL_ARTIFACT_VERSION "4.4.5-beta.1")

# Optional shared base URL. When set, platform archive URLs are derived as:
#   ${NE_CALL_ARTIFACT_BASE_URL}/${archive_name}
set(NE_CALL_ARTIFACT_BASE_URL "")

# Optional upstream RTC SDK source URLs for release automation.
# These are not the final customer-facing desktop artifact URLs. They are
# reserved for packaging pipelines that assemble the published desktop
# artifact archives consumed by netease_callkit.
set(NE_CALL_UPSTREAM_NERTC_MACOS_SDK_URL
    "https://yx-nosdn.chatnos.com/package/1774575520/NERTC_MacOS_SDK_V5.10.0.zip?download=NERTC_MacOS_SDK_V5.10.0.zip")
set(NE_CALL_UPSTREAM_NERTC_WINDOWS_SDK_URL
    "https://yx-nosdn.chatnos.com/package/1774575576/NERTC_Windows_SDK_V5.10.0.zip?download=NERTC_Windows_SDK_V5.10.0.zip")
set(NE_CALL_UPSTREAM_OBSERVABILITY_MACOS_SDK_URL
    "https://yx-web-nosdn.netease.im/package/NEXKitBase_Mac_v1.2.0.xcframework.zip?download=NEXKitBase_Mac_v1.2.0.xcframework.zip")
set(NE_CALL_UPSTREAM_OBSERVABILITY_WINDOWS_SDK_URL
    "https://yx-web-nosdn.netease.im/package/NEXKitBase_Windows_v1.2.0.zip?download=NEXKitBase_Windows_v1.2.0.zip")

set(NE_CALL_ARTIFACT_MACOS_ARCHIVE
    "netease_callkit_desktop_macos_universal_4.4.5-beta.1.zip")
set(NE_CALL_ARTIFACT_MACOS_SHA256 "")
set(NE_CALL_ARTIFACT_MACOS_ROOT_DIR "")

set(NE_CALL_ARTIFACT_WINDOWS_X64_ARCHIVE
    "netease_callkit_desktop_windows_x64_4.4.5-beta.1.zip")
set(NE_CALL_ARTIFACT_WINDOWS_X64_SHA256 "")
set(NE_CALL_ARTIFACT_WINDOWS_X64_ROOT_DIR "")
