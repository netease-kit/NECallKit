//
// Created on 2025/4/8.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef HARMONY_NAPI_BASE_H
#define HARMONY_NAPI_BASE_H
#include <EGL/eglplatform.h>
#include <EGL/egl.h>

struct VideoFrame {
  void* data;
  int width;
  int height;
  bool filled{false};
  
  void Reset() {
    data = nullptr;
    width = 0;
    height = 0;
    filled = false;
  }
};

const int EGL_RED_SIZE_DEFAULT = 8;
const int EGL_GREEN_SIZE_DEFAULT = 8;
const int EGL_BLUE_SIZE_DEFAULT = 8;
const int EGL_ALPHA_SIZE_DEFAULT = 8;

const EGLint ATTRIB_LIST[] = {
    // Key,value.
    EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
    EGL_RED_SIZE, EGL_RED_SIZE_DEFAULT,
    EGL_GREEN_SIZE, EGL_GREEN_SIZE_DEFAULT,
    EGL_BLUE_SIZE, EGL_BLUE_SIZE_DEFAULT,
    EGL_ALPHA_SIZE, EGL_ALPHA_SIZE_DEFAULT,
    EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
    // End.
    EGL_NONE
};



#endif //HARMONY_NAPI_BASE_H
