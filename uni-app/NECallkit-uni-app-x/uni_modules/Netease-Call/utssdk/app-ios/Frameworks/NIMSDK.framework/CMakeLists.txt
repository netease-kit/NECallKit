cmake_minimum_required(VERSION 3.18)

project(storage-middleware)

file(GLOB_RECURSE STORAGE_UNITTEST_SOURCES *_unittest.cc)
file(GLOB_RECURSE STORAGE_SOURCES *.cc *.h)

add_library(${PROJECT_NAME} STATIC ${STORAGE_SOURCES})

target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_LIST_DIR})
