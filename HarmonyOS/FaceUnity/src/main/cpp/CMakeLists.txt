# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(myNpmLib)

if (CMAKE_HOST_SYSTEM_NAME MATCHES "Windows")
    message(WARNING "Host is windows")
    set(FIND_WRAPPER ${CMAKE_CURRENT_SOURCE_DIR}/../../../find_dir.bat)
endif()

if (CMAKE_HOST_SYSTEM_NAME MATCHES "Darwin")
    message(WARNING "Host is Darwin")
    set(FIND_WRAPPER ${CMAKE_CURRENT_SOURCE_DIR}/../../../find_dir.sh)
endif()


if (CMAKE_HOST_SYSTEM_NAME MATCHES "Darwin")
    execute_process(
        COMMAND chmod +x ${FIND_WRAPPER}
        RESULT_VARIABLE CHMOD_RESULT
        ERROR_VARIABLE CHMOD_ERROR
    )
endif()

if (CMAKE_HOST_SYSTEM_NAME MATCHES "Windows")
    execute_process(
        COMMAND ${FIND_WRAPPER}
        RESULT_VARIABLE result
        OUTPUT_VARIABLE output
        ERROR_VARIABLE error
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
else()
    execute_process(
        COMMAND ${SHELL} ${FIND_WRAPPER}
        RESULT_VARIABLE result
        OUTPUT_VARIABLE output
        ERROR_VARIABLE error
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
endif()

if(NOT result EQUAL 0)
    message(FATAL_ERROR "Command failed: ${error}")
else()
    message(WARNING "Command output: ${output}")
endif()

set(WRAPPER_PATH ${output})

include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${WRAPPER_PATH}/include)

add_library(nertc_sdk SHARED IMPORTED)
set_target_properties(nertc_sdk PROPERTIES IMPORTED_LOCATION ${WRAPPER_PATH}/libs/${CMAKE_OHOS_ARCH_ABI}/libnertc_sdk.so)

add_library(FUAI SHARED IMPORTED)
set_target_properties(FUAI PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/beauty/lib/${CMAKE_OHOS_ARCH_ABI}/libfuai.so)

add_library(CNameSDK SHARED IMPORTED)
set_target_properties(CNameSDK PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/beauty/lib/${CMAKE_OHOS_ARCH_ABI}/libCNamaSDK.so)

file(GLOB BEAUTY "${CMAKE_SOURCE_DIR}/beauty/*.cpp")
set(ALL_SOURCES ${BEAUTY})

add_library(faceunity SHARED napi_init.cpp ${ALL_SOURCES})
target_link_libraries(faceunity PUBLIC nertc_sdk  FUAI CNameSDK libace_napi.z.so libhilog_ndk.z.so EGL GLESv3 libnative_drawing.so)
