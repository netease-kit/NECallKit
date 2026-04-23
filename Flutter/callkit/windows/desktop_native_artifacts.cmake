function(_ne_call_get_env out_var name)
  if(DEFINED ENV{${name}} AND NOT "$ENV{${name}}" STREQUAL "")
    set(${out_var} "$ENV{${name}}" PARENT_SCOPE)
  else()
    set(${out_var} "" PARENT_SCOPE)
  endif()
endfunction()

function(_ne_call_read_mode out_var name default)
  set(_allowed_modes auto download source)
  foreach(_extra_mode IN LISTS ARGN)
    list(APPEND _allowed_modes "${_extra_mode}")
  endforeach()

  _ne_call_get_env(_mode_value "${name}")
  if("${_mode_value}" STREQUAL "")
    set(_mode_value "${default}")
  endif()
  string(TOLOWER "${_mode_value}" _mode_value)

  list(FIND _allowed_modes "${_mode_value}" _mode_index)
  if(_mode_index EQUAL -1)
    string(REPLACE ";" ", " _expected_modes "${_allowed_modes}")
    message(FATAL_ERROR
      "[netease_callkit] invalid value for ${name}: ${_mode_value}. "
      "Expected one of ${_expected_modes}.")
  endif()

  set(${out_var} "${_mode_value}" PARENT_SCOPE)
endfunction()

function(_ne_call_default_cache_root out_var)
  _ne_call_get_env(_override "NE_CALL_DESKTOP_ARTIFACT_CACHE_DIR")
  if(_override)
    set(${out_var} "${_override}" PARENT_SCOPE)
    return()
  endif()

  if(DEFINED ENV{LOCALAPPDATA} AND NOT "$ENV{LOCALAPPDATA}" STREQUAL "")
    set(${out_var}
        "$ENV{LOCALAPPDATA}/netease_callkit/native_artifacts"
        PARENT_SCOPE)
    return()
  endif()

  if(DEFINED ENV{USERPROFILE} AND NOT "$ENV{USERPROFILE}" STREQUAL "")
    set(${out_var}
        "$ENV{USERPROFILE}/AppData/Local/netease_callkit/native_artifacts"
        PARENT_SCOPE)
    return()
  endif()

  set(${out_var}
      "${CMAKE_CURRENT_BINARY_DIR}/netease_callkit_native_artifacts"
      PARENT_SCOPE)
endfunction()

function(_ne_call_read_file_if_exists out_var path)
  if(EXISTS "${path}")
    file(READ "${path}" _content)
    set(${out_var} "${_content}" PARENT_SCOPE)
  else()
    set(${out_var} "" PARENT_SCOPE)
  endif()
endfunction()

function(_ne_call_find_bridge_dll out_var root_dir)
  set(_bridge_path "")
  foreach(_candidate IN ITEMS "ne_callkit.dll" "ne_call_bridge.dll")
    if(EXISTS "${root_dir}/${_candidate}")
      set(_bridge_path "${root_dir}/${_candidate}")
      break()
    endif()
  endforeach()
  set(${out_var} "${_bridge_path}" PARENT_SCOPE)
endfunction()

function(_ne_call_collect_direct_dlls out_var root_dir)
  if(EXISTS "${root_dir}")
    file(GLOB _dlls LIST_DIRECTORIES false "${root_dir}/*.dll")
  else()
    set(_dlls "")
  endif()
  list(SORT _dlls)
  set(${out_var} "${_dlls}" PARENT_SCOPE)
endfunction()

function(_ne_call_collect_recursive_dlls out_var root_dir)
  if(EXISTS "${root_dir}")
    file(GLOB_RECURSE _dlls LIST_DIRECTORIES false "${root_dir}/*.dll")
  else()
    set(_dlls "")
  endif()
  list(SORT _dlls)
  set(${out_var} "${_dlls}" PARENT_SCOPE)
endfunction()

function(_ne_call_filter_runtime_dlls out_var arch)
  set(_runtime_dlls "")
  foreach(_candidate IN LISTS ARGN)
    if(NOT EXISTS "${_candidate}")
      continue()
    endif()

    get_filename_component(_dll_name "${_candidate}" NAME)
    string(TOLOWER "${_dll_name}" _dll_name_lower)
    if(_dll_name_lower STREQUAL "nim.dll" OR
       _dll_name_lower STREQUAL "ne_callkit.dll" OR
       _dll_name_lower STREQUAL "ne_call_bridge.dll")
      continue()
    endif()

    string(REPLACE "\\" "/" _normalized_candidate "${_candidate}")
    if(_normalized_candidate MATCHES "/x64/" OR _normalized_candidate MATCHES "/x86/")
      if(NOT _normalized_candidate MATCHES "/${arch}/")
        continue()
      endif()
    endif()

    list(APPEND _runtime_dlls "${_candidate}")
  endforeach()
  list(REMOVE_DUPLICATES _runtime_dlls)
  list(SORT _runtime_dlls)
  set(${out_var} "${_runtime_dlls}" PARENT_SCOPE)
endfunction()

function(_ne_call_find_existing_dir out_var root_dir)
  foreach(_relative_dir IN LISTS ARGN)
    if(EXISTS "${root_dir}/${_relative_dir}")
      set(${out_var} "${root_dir}/${_relative_dir}" PARENT_SCOPE)
      return()
    endif()
  endforeach()
  set(${out_var} "" PARENT_SCOPE)
endfunction()

function(_ne_call_resolve_windows_archive_url out_var archive_name)
  _ne_call_get_env(_url_override "NE_CALL_DESKTOP_WINDOWS_X64_ARTIFACT_URL")
  if(_url_override)
    set(${out_var} "${_url_override}" PARENT_SCOPE)
    return()
  endif()

  _ne_call_get_env(_base_url_override "NE_CALL_DESKTOP_ARTIFACT_BASE_URL")
  if(_base_url_override)
    string(REGEX REPLACE "/+$" "" _base_url "${_base_url_override}")
    set(${out_var} "${_base_url}/${archive_name}" PARENT_SCOPE)
    return()
  endif()

  if(DEFINED NE_CALL_ARTIFACT_BASE_URL AND
     NOT "${NE_CALL_ARTIFACT_BASE_URL}" STREQUAL "")
    string(REGEX REPLACE "/+$" "" _base_url "${NE_CALL_ARTIFACT_BASE_URL}")
    set(${out_var} "${_base_url}/${archive_name}" PARENT_SCOPE)
    return()
  endif()

  set(${out_var} "" PARENT_SCOPE)
endfunction()

function(_ne_call_ensure_archive_downloaded out_archive_path out_expected_stamp
         downloads_dir archive_name url sha256)
  file(MAKE_DIRECTORY "${downloads_dir}")
  set(_archive_path "${downloads_dir}/${archive_name}")
  set(_archive_stamp_path "${_archive_path}.stamp")
  set(_expected_stamp "url=${url}\nsha256=${sha256}\n")

  _ne_call_read_file_if_exists(_archive_stamp "${_archive_stamp_path}")
  if(NOT EXISTS "${_archive_path}" OR NOT "${_archive_stamp}" STREQUAL "${_expected_stamp}")
    message(STATUS "[netease_callkit] downloading ${archive_name} from ${url}")
    if("${sha256}" STREQUAL "")
      file(DOWNLOAD "${url}" "${_archive_path}"
        STATUS _download_status
        SHOW_PROGRESS
      )
    else()
      file(DOWNLOAD "${url}" "${_archive_path}"
        EXPECTED_HASH "SHA256=${sha256}"
        STATUS _download_status
        SHOW_PROGRESS
      )
    endif()
    list(GET _download_status 0 _download_code)
    list(GET _download_status 1 _download_message)
    if(NOT _download_code EQUAL 0)
      message(FATAL_ERROR
        "[netease_callkit] failed to download ${archive_name}: ${_download_message}")
    endif()
    file(WRITE "${_archive_stamp_path}" "${_expected_stamp}")
  endif()

  set(${out_archive_path} "${_archive_path}" PARENT_SCOPE)
  set(${out_expected_stamp} "${_expected_stamp}" PARENT_SCOPE)
endfunction()

function(_ne_call_ensure_archive_extracted out_extract_dir archive_path expected_stamp extract_dir description)
  set(_extract_stamp_path "${extract_dir}/.artifact_stamp")
  _ne_call_read_file_if_exists(_extract_stamp "${_extract_stamp_path}")
  if(NOT EXISTS "${extract_dir}" OR NOT "${_extract_stamp}" STREQUAL "${expected_stamp}")
    file(REMOVE_RECURSE "${extract_dir}")
    file(MAKE_DIRECTORY "${extract_dir}")
    execute_process(
      COMMAND "${CMAKE_COMMAND}" -E tar xvf "${archive_path}"
      WORKING_DIRECTORY "${extract_dir}"
      RESULT_VARIABLE _extract_result
      ERROR_VARIABLE _extract_error
      OUTPUT_QUIET
    )
    if(NOT _extract_result EQUAL 0)
      message(FATAL_ERROR
        "[netease_callkit] failed to extract ${description}: ${_extract_error}")
    endif()
    file(WRITE "${_extract_stamp_path}" "${expected_stamp}")
  endif()

  set(${out_extract_dir} "${extract_dir}" PARENT_SCOPE)
endfunction()

function(ne_call_resolve_windows_artifact_dir out_var package_root arch)
  if(NOT "${arch}" STREQUAL "x64")
    set(${out_var} "" PARENT_SCOPE)
    return()
  endif()

  set(_manifest "${package_root}/native_artifacts/manifest.cmake")
  if(NOT EXISTS "${_manifest}")
    message(FATAL_ERROR
      "[netease_callkit] missing native artifact manifest: ${_manifest}")
  endif()
  include("${_manifest}")

  _ne_call_get_env(_local_dir "NE_CALL_DESKTOP_WINDOWS_X64_ARTIFACT_DIR")
  if(_local_dir)
    _ne_call_find_bridge_dll(_local_bridge "${_local_dir}")
    if("${_local_bridge}" STREQUAL "")
      message(FATAL_ERROR
        "[netease_callkit] NE_CALL_DESKTOP_WINDOWS_X64_ARTIFACT_DIR is missing ne_callkit.dll: ${_local_dir}")
    endif()
    set(${out_var} "${_local_dir}" PARENT_SCOPE)
    return()
  endif()

  if(NOT DEFINED NE_CALL_ARTIFACT_WINDOWS_X64_ARCHIVE OR
     "${NE_CALL_ARTIFACT_WINDOWS_X64_ARCHIVE}" STREQUAL "")
    set(${out_var} "" PARENT_SCOPE)
    return()
  endif()

  _ne_call_resolve_windows_archive_url(
    _artifact_url "${NE_CALL_ARTIFACT_WINDOWS_X64_ARCHIVE}")
  if("${_artifact_url}" STREQUAL "")
    set(${out_var} "" PARENT_SCOPE)
    return()
  endif()

  _ne_call_get_env(_sha_override "NE_CALL_DESKTOP_WINDOWS_X64_SHA256")
  if(_sha_override)
    set(_artifact_sha256 "${_sha_override}")
  else()
    set(_artifact_sha256 "${NE_CALL_ARTIFACT_WINDOWS_X64_SHA256}")
  endif()

  _ne_call_default_cache_root(_cache_root)
  set(_downloads_dir "${_cache_root}/downloads")
  set(_archive_path "${_downloads_dir}/${NE_CALL_ARTIFACT_WINDOWS_X64_ARCHIVE}")
  set(_archive_stamp_path "${_archive_path}.stamp")
  set(_expected_stamp "url=${_artifact_url}\nsha256=${_artifact_sha256}\n")

  file(MAKE_DIRECTORY "${_downloads_dir}")
  _ne_call_read_file_if_exists(_archive_stamp "${_archive_stamp_path}")
  if(NOT EXISTS "${_archive_path}" OR NOT "${_archive_stamp}" STREQUAL "${_expected_stamp}")
    message(STATUS "[netease_callkit] downloading Windows desktop artifacts from ${_artifact_url}")
    if("${_artifact_sha256}" STREQUAL "")
      file(DOWNLOAD "${_artifact_url}" "${_archive_path}"
        STATUS _download_status
        SHOW_PROGRESS
      )
    else()
      file(DOWNLOAD "${_artifact_url}" "${_archive_path}"
        EXPECTED_HASH "SHA256=${_artifact_sha256}"
        STATUS _download_status
        SHOW_PROGRESS
      )
    endif()
    list(GET _download_status 0 _download_code)
    list(GET _download_status 1 _download_message)
    if(NOT _download_code EQUAL 0)
      message(FATAL_ERROR
        "[netease_callkit] failed to download Windows desktop artifacts: ${_download_message}")
    endif()
    file(WRITE "${_archive_stamp_path}" "${_expected_stamp}")
  endif()

  set(_staging_dir "${_cache_root}/${NE_CALL_ARTIFACT_VERSION}/windows/${arch}")
  set(_extract_stamp_path "${_staging_dir}/.artifact_stamp")
  _ne_call_read_file_if_exists(_extract_stamp "${_extract_stamp_path}")
  if(NOT EXISTS "${_staging_dir}" OR NOT "${_extract_stamp}" STREQUAL "${_expected_stamp}")
    file(REMOVE_RECURSE "${_staging_dir}")
    file(MAKE_DIRECTORY "${_staging_dir}")
    execute_process(
      COMMAND "${CMAKE_COMMAND}" -E tar xvf "${_archive_path}"
      WORKING_DIRECTORY "${_staging_dir}"
      RESULT_VARIABLE _extract_result
      ERROR_VARIABLE _extract_error
      OUTPUT_QUIET
    )
    if(NOT _extract_result EQUAL 0)
      message(FATAL_ERROR
        "[netease_callkit] failed to extract Windows desktop artifacts: ${_extract_error}")
    endif()
    file(WRITE "${_extract_stamp_path}" "${_expected_stamp}")
  endif()

  if(DEFINED NE_CALL_ARTIFACT_WINDOWS_X64_ROOT_DIR AND
     NOT "${NE_CALL_ARTIFACT_WINDOWS_X64_ROOT_DIR}" STREQUAL "")
    set(_artifact_dir "${_staging_dir}/${NE_CALL_ARTIFACT_WINDOWS_X64_ROOT_DIR}")
  else()
    set(_artifact_dir "${_staging_dir}")
  endif()

  _ne_call_find_bridge_dll(_resolved_bridge "${_artifact_dir}")
  if("${_resolved_bridge}" STREQUAL "")
    message(FATAL_ERROR
      "[netease_callkit] extracted Windows desktop artifacts are missing ne_callkit.dll: ${_artifact_dir}")
  endif()

  set(${out_var} "${_artifact_dir}" PARENT_SCOPE)
endfunction()

function(ne_call_resolve_windows_packaged_bridge_dll out_var package_root arch)
  set(_search_roots "")
  if(NOT "${arch}" STREQUAL "")
    list(APPEND _search_roots "${package_root}/windows/Frameworks/${arch}")
  endif()
  list(APPEND _search_roots "${package_root}/windows/Frameworks")

  foreach(_search_root IN LISTS _search_roots)
    _ne_call_find_bridge_dll(_bridge_path "${_search_root}")
    if(NOT "${_bridge_path}" STREQUAL "")
      set(${out_var} "${_bridge_path}" PARENT_SCOPE)
      return()
    endif()
  endforeach()

  set(${out_var} "" PARENT_SCOPE)
endfunction()

function(ne_call_collect_source_windows_runtime_dlls out_var desktop_root arch)
  _ne_call_collect_direct_dlls(
    _nertc_dlls "${desktop_root}/third_party/nertc/lib/windows/dll/${arch}")
  _ne_call_collect_direct_dlls(
    _observability_dlls "${desktop_root}/third_party/observability/lib/windows/dll/${arch}")

  set(_runtime_dlls
    ${_nertc_dlls}
    ${_observability_dlls}
  )
  list(REMOVE_DUPLICATES _runtime_dlls)
  list(SORT _runtime_dlls)
  set(${out_var} "${_runtime_dlls}" PARENT_SCOPE)
endfunction()

function(ne_call_resolve_windows_downloaded_runtime_dlls out_var package_root arch artifact_dir)
  if(NOT "${artifact_dir}" STREQUAL "")
    _ne_call_collect_direct_dlls(_artifact_dlls "${artifact_dir}")
    _ne_call_filter_runtime_dlls(_runtime_dlls "${arch}" ${_artifact_dlls})
    if("${_runtime_dlls}" STREQUAL "")
      message(FATAL_ERROR
        "[netease_callkit] Windows artifact is missing runtime DLLs: ${artifact_dir}")
    endif()
    set(${out_var} "${_runtime_dlls}" PARENT_SCOPE)
    return()
  endif()

  set(_manifest "${package_root}/native_artifacts/manifest.cmake")
  if(NOT EXISTS "${_manifest}")
    message(FATAL_ERROR
      "[netease_callkit] missing native artifact manifest: ${_manifest}")
  endif()
  include("${_manifest}")

  _ne_call_get_env(_nertc_url_override "NE_CALL_UPSTREAM_NERTC_WINDOWS_SDK_URL")
  _ne_call_get_env(_observability_url_override "NE_CALL_UPSTREAM_OBSERVABILITY_WINDOWS_SDK_URL")
  if(_nertc_url_override)
    set(_nertc_url "${_nertc_url_override}")
  else()
    set(_nertc_url "${NE_CALL_UPSTREAM_NERTC_WINDOWS_SDK_URL}")
  endif()
  if(_observability_url_override)
    set(_observability_url "${_observability_url_override}")
  else()
    set(_observability_url "${NE_CALL_UPSTREAM_OBSERVABILITY_WINDOWS_SDK_URL}")
  endif()

  if("${_nertc_url}" STREQUAL "" OR "${_observability_url}" STREQUAL "")
    message(FATAL_ERROR
      "[netease_callkit] Windows runtime mode is download, but no downloadable runtime source is configured. "
      "Set one of: "
      "NE_CALL_DESKTOP_WINDOWS_X64_ARTIFACT_DIR, "
      "NE_CALL_DESKTOP_WINDOWS_X64_ARTIFACT_URL, "
      "NE_CALL_DESKTOP_ARTIFACT_BASE_URL, "
      "NE_CALL_UPSTREAM_NERTC_WINDOWS_SDK_URL, "
      "NE_CALL_UPSTREAM_OBSERVABILITY_WINDOWS_SDK_URL.")
  endif()

  set(_artifact_version "${NE_CALL_ARTIFACT_VERSION}")
  if("${_artifact_version}" STREQUAL "")
    set(_artifact_version "unknown")
  endif()

  _ne_call_default_cache_root(_cache_root)
  set(_upstream_root "${_cache_root}/upstream_sdk/${_artifact_version}/windows/${arch}")
  set(_downloads_root "${_upstream_root}/downloads")
  set(_extracts_root "${_upstream_root}/extracts")

  _ne_call_ensure_archive_downloaded(
    _nertc_archive _nertc_stamp
    "${_downloads_root}" "nertc_windows_sdk.zip" "${_nertc_url}" "")
  _ne_call_ensure_archive_downloaded(
    _observability_archive _observability_stamp
    "${_downloads_root}" "observability_windows_sdk.zip" "${_observability_url}" "")

  _ne_call_ensure_archive_extracted(
    _nertc_extract_root "${_nertc_archive}" "${_nertc_stamp}"
    "${_extracts_root}/rtc" "NERtc Windows SDK")
  _ne_call_ensure_archive_extracted(
    _observability_extract_root "${_observability_archive}" "${_observability_stamp}"
    "${_extracts_root}/observability" "observability Windows SDK")

  _ne_call_find_existing_dir(_nertc_dll_dir "${_nertc_extract_root}"
    "sdk/dll/${arch}" "dll/${arch}" "${arch}")
  if("${_nertc_dll_dir}" STREQUAL "")
    _ne_call_collect_recursive_dlls(_nertc_candidates "${_nertc_extract_root}")
  else()
    _ne_call_collect_direct_dlls(_nertc_candidates "${_nertc_dll_dir}")
  endif()
  _ne_call_filter_runtime_dlls(_nertc_dlls "${arch}" ${_nertc_candidates})
  if("${_nertc_dlls}" STREQUAL "")
    message(FATAL_ERROR
      "[netease_callkit] unable to locate downloaded NERtc runtime DLLs under ${_nertc_extract_root}")
  endif()

  _ne_call_find_existing_dir(_observability_dll_dir "${_observability_extract_root}"
    "sdk/dll/${arch}" "dll/${arch}" "${arch}")
  if("${_observability_dll_dir}" STREQUAL "")
    _ne_call_collect_recursive_dlls(_observability_candidates "${_observability_extract_root}")
  else()
    _ne_call_collect_direct_dlls(_observability_candidates "${_observability_dll_dir}")
  endif()
  _ne_call_filter_runtime_dlls(
    _observability_dlls "${arch}" ${_observability_candidates})
  if("${_observability_dlls}" STREQUAL "")
    message(FATAL_ERROR
      "[netease_callkit] unable to locate downloaded observability runtime DLLs under ${_observability_extract_root}")
  endif()

  set(_runtime_dlls
    ${_nertc_dlls}
    ${_observability_dlls}
  )
  list(REMOVE_DUPLICATES _runtime_dlls)
  list(SORT _runtime_dlls)
  set(${out_var} "${_runtime_dlls}" PARENT_SCOPE)
endfunction()
