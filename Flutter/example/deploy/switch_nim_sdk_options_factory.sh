#!/usr/bin/env bash

set -e
set +x

TARGET_PLATFORM="$1"

if [ -z "$TARGET_PLATFORM" ]; then
  echo "Usage: sh deploy/switch_nim_sdk_options_factory.sh <android|ios|ohos>"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EXAMPLE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PLUGIN_ROOT="$(cd "${EXAMPLE_ROOT}/.." && pwd)"
IMPL_DIR="${PLUGIN_ROOT}/lib/src/impl"
CALLKIT_ROOT="$(cd "${PLUGIN_ROOT}/./callkit" && pwd)"
CALLKIT_API_DIR="${CALLKIT_ROOT}/lib/src/api"

TARGET_FILE="${IMPL_DIR}/nim_sdk_options_factory.dart"
DEFAULT_FILE="${IMPL_DIR}/nim_sdk_options_factory_stub.dart"
OHOS_FILE="${IMPL_DIR}/nim_sdk_options_factory_ohos.dart"

VIDEO_BUILDER_TARGET_FILE="${CALLKIT_API_DIR}/callkit_video_view.dart"
VIDEO_BUILDER_DEFAULT_FILE="${CALLKIT_API_DIR}/callkit_video_view_builder_stub.dart"
VIDEO_BUILDER_OHOS_FILE="${CALLKIT_API_DIR}/callkit_video_view_builder_ohos.dart"

switch_pubspec_for_dir() {
  local target_dir="$1"
  local platform="$2"
  local active_file="${target_dir}/pubspec.yaml"
  local normal_file="${target_dir}/pubspec_normal.yaml"
  local ohos_file="${target_dir}/pubspec_ohos.yaml"

  if [ ! -d "${target_dir}" ]; then
    return
  fi

  if [ "${platform}" = "ohos" ]; then
    if [ -f "${active_file}" ] && [ ! -f "${normal_file}" ]; then
      mv "${active_file}" "${normal_file}"
    fi

    if [ -f "${ohos_file}" ]; then
      mv "${ohos_file}" "${active_file}"
      echo "Switched ${target_dir} pubspec to OHOS."
      return
    fi

    if [ -f "${normal_file}" ] && [ -f "${active_file}" ]; then
      echo "Already in OHOS pubspec mode: ${target_dir}"
      return
    fi

    echo "Missing pubspec file for OHOS switch in ${target_dir}"
    exit 1
  else
    if [ -f "${normal_file}" ]; then
      if [ -f "${active_file}" ]; then
        mv "${active_file}" "${ohos_file}"
      fi
      mv "${normal_file}" "${active_file}"
      echo "Switched ${target_dir} pubspec to Android/iOS."
      return
    fi

    if [ -f "${active_file}" ] && [ -f "${ohos_file}" ]; then
      echo "Already in Android/iOS pubspec mode: ${target_dir}"
      return
    fi

    echo "Missing pubspec file for Android/iOS switch in ${target_dir}"
    exit 1
  fi
}

case "${TARGET_PLATFORM}" in
  ohos)
    cp "${OHOS_FILE}" "${TARGET_FILE}"
    echo "Switched nim_sdk_options_factory.dart to OHOS implementation."
    cp "${VIDEO_BUILDER_OHOS_FILE}" "${VIDEO_BUILDER_TARGET_FILE}"
    echo "Switched callkit_video_view_builder.dart to OHOS implementation."
    ;;
  android|ios)
    cp "${DEFAULT_FILE}" "${TARGET_FILE}"
    echo "Switched nim_sdk_options_factory.dart to Android/iOS implementation."
    cp "${VIDEO_BUILDER_DEFAULT_FILE}" "${VIDEO_BUILDER_TARGET_FILE}"
    echo "Switched callkit_video_view_builder.dart to Android/iOS implementation."
    ;;
  *)
    echo "Unsupported platform: ${TARGET_PLATFORM}"
    echo "Usage: sh deploy/switch_nim_sdk_options_factory.sh <android|ios|ohos>"
    exit 1
    ;;
esac

switch_pubspec_for_dir "${PLUGIN_ROOT}" "${TARGET_PLATFORM}"
switch_pubspec_for_dir "${EXAMPLE_ROOT}" "${TARGET_PLATFORM}"
switch_pubspec_for_dir "${CALLKIT_ROOT}" "${TARGET_PLATFORM}"
switch_pubspec_for_dir "${CALLKIT_ROOT}/example" "${TARGET_PLATFORM}"
