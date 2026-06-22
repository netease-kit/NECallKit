cmake_minimum_required(VERSION 3.14)

set(PROJECT_NAME "netease_callkit")
project(${PROJECT_NAME} LANGUAGES CXX)

cmake_policy(VERSION 3.14...3.25)

set(PLUGIN_NAME "netease_callkit_plugin")

include("${CMAKE_CURRENT_SOURCE_DIR}/desktop_native_artifacts.cmake")

list(APPEND PLUGIN_SOURCES
  "callkit_plugin.cpp"
  "callkit_plugin.h"
)

add_library(${PLUGIN_NAME} SHARED
  "include/netease_callkit/callkit_plugin_c_api.h"
  "callkit_plugin_c_api.cpp"
  ${PLUGIN_SOURCES}
)

apply_standard_settings(${PLUGIN_NAME})

set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden
)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_compile_features(${PLUGIN_NAME} PRIVATE cxx_std_17)

target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
)
target_include_directories(${PLUGIN_NAME} PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}/../desktop_bridge/include"
)

target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

set(NE_CALL_PACKAGE_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/..")
set(NE_CALL_DESKTOP_DIR "")
if(DEFINED ENV{NE_CALL_DESKTOP_SOURCE_DIR} AND
   NOT "$ENV{NE_CALL_DESKTOP_SOURCE_DIR}" STREQUAL "")
  set(NE_CALL_DESKTOP_DIR "$ENV{NE_CALL_DESKTOP_SOURCE_DIR}")
else()
  set(NE_CALL_DESKTOP_DIR "${NE_CALL_PACKAGE_ROOT}/../../desktop")
endif()
set(netease_callkit_bundled_libraries "")

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
  set(NE_CALL_ARCH_DIR "x64")
else()
  set(NE_CALL_ARCH_DIR "x86")
endif()

_ne_call_read_mode(NE_CALL_WINDOWS_DEFAULT_MODE "NE_CALL_DESKTOP_WINDOWS_MODE" "auto")
_ne_call_read_mode(
  NE_CALL_WINDOWS_BRIDGE_MODE
  "NE_CALL_DESKTOP_WINDOWS_BRIDGE_MODE"
  "${NE_CALL_WINDOWS_DEFAULT_MODE}"
  "packaged"
)
_ne_call_read_mode(
  NE_CALL_WINDOWS_RUNTIME_MODE
  "NE_CALL_DESKTOP_WINDOWS_RUNTIME_MODE"
  "${NE_CALL_WINDOWS_DEFAULT_MODE}"
)

ne_call_resolve_windows_artifact_dir(
  NE_CALL_WINDOWS_ARTIFACT_DIR "${NE_CALL_PACKAGE_ROOT}" "${NE_CALL_ARCH_DIR}")
ne_call_resolve_windows_packaged_bridge_dll(
  NE_CALL_WINDOWS_PACKAGED_BRIDGE_DLL "${NE_CALL_PACKAGE_ROOT}" "${NE_CALL_ARCH_DIR}")

set(NE_CALL_WINDOWS_SOURCE_AVAILABLE OFF)
if(EXISTS "${NE_CALL_DESKTOP_DIR}/CMakeLists.txt")
  set(NE_CALL_WINDOWS_SOURCE_AVAILABLE ON)
endif()

set(NE_CALL_WINDOWS_BRIDGE_DLL "")
set(NE_CALL_WINDOWS_RUNTIME_DLLS "")
set(NE_CALL_USE_SOURCE_BRIDGE OFF)

if(NE_CALL_WINDOWS_BRIDGE_MODE STREQUAL "download")
  if("${NE_CALL_WINDOWS_ARTIFACT_DIR}" STREQUAL "")
    message(FATAL_ERROR
      "[netease_callkit] Windows bridge mode is download, but no downloadable artifact is configured. "
      "Set NE_CALL_DESKTOP_WINDOWS_X64_ARTIFACT_DIR, "
      "NE_CALL_DESKTOP_WINDOWS_X64_ARTIFACT_URL, or "
      "NE_CALL_DESKTOP_ARTIFACT_BASE_URL.")
  endif()
  _ne_call_find_bridge_dll(NE_CALL_WINDOWS_BRIDGE_DLL "${NE_CALL_WINDOWS_ARTIFACT_DIR}")
elseif(NE_CALL_WINDOWS_BRIDGE_MODE STREQUAL "packaged")
  set(NE_CALL_WINDOWS_BRIDGE_DLL "${NE_CALL_WINDOWS_PACKAGED_BRIDGE_DLL}")
  if("${NE_CALL_WINDOWS_BRIDGE_DLL}" STREQUAL "")
    message(FATAL_ERROR
      "[netease_callkit] Windows bridge mode is packaged, but no packaged bridge DLL is available "
      "under ${NE_CALL_PACKAGE_ROOT}/windows/Frameworks.")
  endif()
elseif(NE_CALL_WINDOWS_BRIDGE_MODE STREQUAL "source")
  set(NE_CALL_USE_SOURCE_BRIDGE ON)
else()
  if(NOT "${NE_CALL_WINDOWS_ARTIFACT_DIR}" STREQUAL "")
    _ne_call_find_bridge_dll(NE_CALL_WINDOWS_BRIDGE_DLL "${NE_CALL_WINDOWS_ARTIFACT_DIR}")
  endif()
  if("${NE_CALL_WINDOWS_BRIDGE_DLL}" STREQUAL "" AND NE_CALL_WINDOWS_SOURCE_AVAILABLE)
    set(NE_CALL_USE_SOURCE_BRIDGE ON)
  endif()
  if("${NE_CALL_WINDOWS_BRIDGE_DLL}" STREQUAL "" AND
     NOT NE_CALL_USE_SOURCE_BRIDGE AND
     NOT "${NE_CALL_WINDOWS_PACKAGED_BRIDGE_DLL}" STREQUAL "")
    set(NE_CALL_WINDOWS_BRIDGE_DLL "${NE_CALL_WINDOWS_PACKAGED_BRIDGE_DLL}")
  endif()
endif()

if(NE_CALL_WINDOWS_RUNTIME_MODE STREQUAL "download")
  ne_call_resolve_windows_downloaded_runtime_dlls(
    NE_CALL_WINDOWS_RUNTIME_DLLS
    "${NE_CALL_PACKAGE_ROOT}"
    "${NE_CALL_ARCH_DIR}"
    "${NE_CALL_WINDOWS_ARTIFACT_DIR}"
  )
elseif(NE_CALL_WINDOWS_RUNTIME_MODE STREQUAL "source")
  if(NOT NE_CALL_WINDOWS_SOURCE_AVAILABLE)
    message(FATAL_ERROR
      "[netease_callkit] Windows runtime mode is source, but no local desktop source is available. "
      "Set NE_CALL_DESKTOP_SOURCE_DIR or use download mode.")
  endif()
  ne_call_collect_source_windows_runtime_dlls(
    NE_CALL_WINDOWS_RUNTIME_DLLS "${NE_CALL_DESKTOP_DIR}" "${NE_CALL_ARCH_DIR}")
else()
  if(NOT "${NE_CALL_WINDOWS_ARTIFACT_DIR}" STREQUAL "")
    ne_call_resolve_windows_downloaded_runtime_dlls(
      NE_CALL_WINDOWS_RUNTIME_DLLS
      "${NE_CALL_PACKAGE_ROOT}"
      "${NE_CALL_ARCH_DIR}"
      "${NE_CALL_WINDOWS_ARTIFACT_DIR}"
    )
  elseif(NE_CALL_WINDOWS_SOURCE_AVAILABLE)
    ne_call_collect_source_windows_runtime_dlls(
      NE_CALL_WINDOWS_RUNTIME_DLLS "${NE_CALL_DESKTOP_DIR}" "${NE_CALL_ARCH_DIR}")
  else()
    ne_call_resolve_windows_downloaded_runtime_dlls(
      NE_CALL_WINDOWS_RUNTIME_DLLS
      "${NE_CALL_PACKAGE_ROOT}"
      "${NE_CALL_ARCH_DIR}"
      ""
    )
  endif()
endif()

if(NE_CALL_USE_SOURCE_BRIDGE)
  if(NOT NE_CALL_WINDOWS_SOURCE_AVAILABLE)
    message(FATAL_ERROR
      "[netease_callkit] Windows bridge mode is source, but no local desktop source is available. "
      "Set NE_CALL_DESKTOP_SOURCE_DIR or use download/packaged mode.")
  endif()
  set(NE_CALL_BUILD_SHARED_BRIDGE ON CACHE BOOL "" FORCE)
  add_subdirectory("${NE_CALL_DESKTOP_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/ne_call_desktop")
  add_dependencies(${PLUGIN_NAME} ne_call_bridge)
  list(APPEND netease_callkit_bundled_libraries
    $<TARGET_FILE:ne_call_bridge>
  )
elseif(NOT "${NE_CALL_WINDOWS_BRIDGE_DLL}" STREQUAL "")
  list(APPEND netease_callkit_bundled_libraries
    "${NE_CALL_WINDOWS_BRIDGE_DLL}"
  )
else()
  message(FATAL_ERROR
    "[netease_callkit] no Windows bridge DLL resolved for ${NE_CALL_ARCH_DIR}. "
    "Provide one of: "
    "NE_CALL_DESKTOP_WINDOWS_BRIDGE_MODE=packaged with a DLL under windows/Frameworks, "
    "NE_CALL_DESKTOP_WINDOWS_X64_ARTIFACT_DIR, "
    "NE_CALL_DESKTOP_WINDOWS_X64_ARTIFACT_URL, "
    "NE_CALL_DESKTOP_ARTIFACT_BASE_URL, "
    "or NE_CALL_DESKTOP_SOURCE_DIR.")
endif()

list(APPEND netease_callkit_bundled_libraries
  ${NE_CALL_WINDOWS_RUNTIME_DLLS}
)
list(REMOVE_DUPLICATES netease_callkit_bundled_libraries)

set(netease_callkit_bundled_libraries
  ${netease_callkit_bundled_libraries}
  PARENT_SCOPE
)
