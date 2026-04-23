cmake_minimum_required(VERSION 3.14)

set(PROJECT_NAME "netease_callkit_ui")
project(${PROJECT_NAME} LANGUAGES CXX)

cmake_policy(VERSION 3.14...3.25)

set(PLUGIN_NAME "netease_callkit_ui_plugin")

add_library(${PLUGIN_NAME} SHARED
  "include/netease_callkit_ui/callkit_ui_plugin_c_api.h"
  "callkit_ui_plugin.cpp"
  "callkit_ui_plugin.h"
  "callkit_ui_plugin_c_api.cpp"
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

target_link_libraries(${PLUGIN_NAME} PRIVATE
  flutter
  flutter_wrapper_plugin
  winmm
)
