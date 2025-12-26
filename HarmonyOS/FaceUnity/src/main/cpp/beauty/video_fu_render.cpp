//
// Created on 2025/2/13.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#include "video_fu_render.h"
#include <EGL/eglext.h>
#include <GLES3/gl3.h>
#include <cassert>
#include "beauty/include/CNamaSDK.h"
#include "log.h"
#include "authpack-ohos-wy.h"
#include "fu_video_constants.h"
#include <cstddef>
#include <fstream>
#include <iostream>
#include <unistd.h>

VideoFuRender::VideoFuRender()
  : env_(nullptr), 
    process_ref_(nullptr), 
    running_(false), 
    ready_(false), 
    share_egl_context_(nullptr), 
    egl_surface_(nullptr) {
}

VideoFuRender::~VideoFuRender() {
  AV_INFO("VideoFuRender DeConstruct ...");
  napi_delete_reference(env_, process_ref_);
  ready_ = false;
  running_ = false;
  frame_id_ = 0;
  share_egl_context_ = nullptr;
}

napi_value VideoFuRender::Construct(napi_env env, napi_callback_info info) {
  AV_INFO("VideoFuRender Construct ...");
  napi_value thisVar;
  assert(napi_get_cb_info(env, info, nullptr, nullptr, &thisVar, nullptr) == napi_ok);
  VideoFuRender *render = new VideoFuRender();
  render->env_ = env;
  assert(napi_wrap(env, thisVar, (void*)render, [](napi_env env, void* data, void* hint) {
    auto fu_render = (VideoFuRender *)data;
    delete fu_render;
  }, nullptr, &render->process_ref_) == napi_ok);
  return thisVar;
}

void VideoFuRender::onCaptureFrame(void* data, int32_t color_format, uint32_t width, uint32_t height, 
uint32_t count, int64_t offset[4], uint32_t stride[4], uint16_t rotation) {
  if (ready_) {
    std::unique_lock<std::mutex> lock(wakeup_mutex_);
    video_frame_.data = data;
    video_frame_.width = width;
    video_frame_.height = height;
    video_frame_.filled = true;
    wakeup_cond_.wait(lock, [this]() {
      return video_frame_.filled == false;
    });
  }
}

void VideoFuRender::onCaptureFrame2(const IVideoCallbackFrame &frame){
    
};

napi_value VideoFuRender::SetBundlePath(napi_env env, napi_callback_info info) {
  napi_value thisVar;
  size_t argc = 1;
  napi_value args[1];
  assert(napi_get_cb_info(env, info, &argc, args, &thisVar, nullptr) == napi_ok);
  
  size_t len;
  assert(napi_get_value_string_utf8(env, args[0], nullptr, 0, &len) == napi_ok);
  
  std::vector<char> buf(len + 1);
  assert(napi_get_value_string_utf8(env, args[0], buf.data(), len + 1, &len) == napi_ok);
  
  std::string file_path = std::string(buf.data());
  AV_INFO("file_path: %{public}s", file_path.c_str());
  
  VideoFuRender *fu_render;
  assert(napi_unwrap(env, thisVar, reinterpret_cast<void **>(&fu_render)) == napi_ok);
  fu_render->bundle_path_ = file_path;
  return thisVar;
}

napi_value VideoFuRender::GetVideoFuRenderHandle(napi_env env, napi_callback_info info) {
  
  napi_value thisVar;
  assert(napi_get_cb_info(env, info, nullptr, nullptr, &thisVar, nullptr) == napi_ok);
  
  VideoFuRender* fu_render;
  assert(napi_unwrap(env, thisVar, reinterpret_cast<void **>(&fu_render)) == napi_ok);
  AV_INFO("GetVideoFuRenderHandle addr: %{public}p", fu_render);
  
  napi_value handle;
  assert(napi_create_bigint_uint64(env, (uint64_t)fu_render, &handle) == napi_ok);
  return handle;
}

napi_value VideoFuRender::SetBeautyParam(napi_env env, napi_callback_info info) {
  napi_value thisVar;
  size_t argc = 2;
  napi_value args[2];
  assert(napi_get_cb_info(env, info, &argc, args, &thisVar, nullptr) == napi_ok);
  
  size_t len;
  assert(napi_get_value_string_utf8(env, args[0], nullptr, 0, &len) == napi_ok);
  std::vector<char> buf(len + 1);
  assert(napi_get_value_string_utf8(env, args[0], buf.data(), len + 1, &len) == napi_ok);
  std::string key = std::string(buf.data());
  AV_INFO("SetBeautyParam key: %{public}s", key.c_str());
  
  double value;
  assert(napi_get_value_double(env, args[1], &value) == napi_ok);
  AV_INFO("SetBeautyParam value: %{public}f", value);
  
  VideoFuRender* fu_render;
  assert(napi_unwrap(env, thisVar, reinterpret_cast<void **>(&fu_render)) == napi_ok);
  
  if (fu_render->ready_) {
    fu_render->SetBeautyFilterImpl(false, key, value);
  } else {
    fu_render->beauty_params_cache_[key] = value;
  }
  return thisVar;
}

napi_value VideoFuRender::SetFilterParam(napi_env env, napi_callback_info info) {
  napi_value thisVar;
  size_t argc = 2;
  napi_value args[2];
  assert(napi_get_cb_info(env, info, &argc, args, &thisVar, nullptr) == napi_ok);
  
  size_t len;
  assert(napi_get_value_string_utf8(env, args[0], nullptr, 0, &len) == napi_ok);
  std::vector<char> buf(len + 1);
  assert(napi_get_value_string_utf8(env, args[0], buf.data(), len + 1, &len) == napi_ok);
  std::string filter_name = std::string(buf.data());
  AV_INFO("SetFilterParam filter_name: %{public}s", filter_name.c_str());
  
  double filter_level;
  assert(napi_get_value_double(env, args[1], &filter_level) == napi_ok);
  AV_INFO("SetFilterParam filter_level: %f", filter_level);
  
  VideoFuRender* fu_render;
  assert(napi_unwrap(env, thisVar, reinterpret_cast<void **>(&fu_render)) == napi_ok);
  
  if (fu_render->ready_) {
    fu_render->SetBeautyFilterImpl(true, filter_name, filter_level);
  } else {
    fu_render->filter_cache_.first = filter_name;
    fu_render->filter_cache_.second = filter_level;
  }
  return thisVar;
}

napi_value VideoFuRender::EnableBeauty(napi_env env, napi_callback_info info) {
  
  napi_value thisVar;
  size_t argc = 1;
  napi_value args[1];
  assert(napi_get_cb_info(env, info, &argc, args, &thisVar, nullptr) == napi_ok);
  
  VideoFuRender* fu_render;
  assert(napi_unwrap(env, thisVar, reinterpret_cast<void **>(&fu_render)) == napi_ok);
  
  if (fu_render == nullptr) {
    AV_ERROR("fu_render is nullptr.");
    return thisVar;
  }
  
  bool enable = false;
  assert(napi_get_value_bool(env, args[0], &enable) == napi_ok);
  AV_INFO("EnableBeauty enable:%{public}d", enable);
  
    if (enable && fu_render->running_){
    AV_INFO("AI fu render is running...");
    return thisVar;
  }
  
  fu_render->EnableBeauty(enable);
  return thisVar;
}

napi_value VideoFuRender::Init(napi_env env, napi_value exports) {
  
  AV_INFO("Export class VideoFuRender.");
  napi_property_descriptor properties[] = {
    {"setBundlePath", nullptr, SetBundlePath, nullptr, nullptr, nullptr, napi_default, nullptr},
    {"getNativeHandle", nullptr, GetVideoFuRenderHandle, nullptr, nullptr, nullptr, napi_default, nullptr},
    {"setBeautyParam", nullptr, SetBeautyParam, nullptr, nullptr, nullptr, napi_default, nullptr},
    {"setFilterParam", nullptr, SetFilterParam, nullptr,  nullptr, nullptr, napi_default, nullptr},
    {"enableBeauty", nullptr, EnableBeauty, nullptr, nullptr, nullptr, napi_default, nullptr}
  };
  
  napi_value clazz;
  assert(napi_define_class(env, "VideoFuRender", NAPI_AUTO_LENGTH, VideoFuRender::Construct, nullptr, sizeof(properties)/sizeof(properties[0]), properties, &clazz) == napi_ok);
  assert(napi_set_named_property(env, exports, "VideoFuRender", clazz) == napi_ok);
  return exports;
}

bool VideoFuRender::LoadBundle(const std::string& model_path, std::vector<char>& data) {
  const std::string dest_path = bundle_path_ + "/" + model_path;
  std::ifstream fin(dest_path, std::ios::binary);
  if (fin.good() == false) {
    fin.close();
    return false;
  }
  
  //Get file size.
  std::streampos old_pos = fin.tellg();
  fin.seekg(0, std::ios::beg);
  std::streampos beg = fin.tellg();
  fin.seekg(0, std::ios::end);
  std::streampos end = fin.tellg();
  fin.seekg(old_pos, std::ios::beg);
  size_t file_size = end  - beg;
  
  if (file_size == 0) {
    fin.close();
    return false;
  }
  
  AV_INFO("load model name: %{public}s,  file size: %{public}zu", model_path.c_str(), file_size);
  data.resize(file_size);
  fin.read(reinterpret_cast<char*>(&data[0]), file_size);
  fin.close();
  return true;
}

void VideoFuRender::EnableBeauty(bool enable) {
  if (enable) {
      //start render thread.
      running_ = true;
      render_thread_ = std::thread([this]() {
        ThreadLoop();
        running_ = false;
      });
      render_thread_.detach();
  } else {
    ready_ = false;
    running_ = false;
  }
}

void VideoFuRender::ReleaseRender() {
  
  fuReleaseAIModel(FUAITYPE::FUAITYPE_FACEPROCESSOR);
  fuReleaseAIModel(FUAITYPE::FUAITYPE_FACEPROCESSOR_IMAGE_BEAUTY);
  fuReleaseGLResources();
  
  glClear(GL_COLOR_BUFFER_BIT);
  eglMakeCurrent(egl_display_, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
  eglDestroySurface(egl_display_, egl_surface_);
  eglDestroyContext(egl_display_, share_egl_context_);
  eglTerminate(egl_display_);
}

bool VideoFuRender::SetBeautyFilterImpl(bool filter, const std::string& key, const double val) {
  if (filter) {
    if (fuItemSetParams(item_handles_[FACE_BEAUTY_INDEX], "filter_name", key.c_str()) == 0) {
      AV_ERROR("fuItemSetParams set filter_name: %{public}s failed.", key.c_str());  
      return false;
    }
    if (fuItemSetParamd(item_handles_[FACE_BEAUTY_INDEX], "filter_level", val) == 0) {
      AV_ERROR("fuItemSetParamd set filter_level: %f failed.", val);
      return false;
    }    
  } else {
    if (fuItemSetParamd(item_handles_[FACE_BEAUTY_INDEX], key.c_str(), val) == 0) {
      AV_ERROR("fuItemSetParamd key: %{public}s, value:%{public}f failed.", key.c_str(), val);
      return false;
    }
  }
  return true;
}

void VideoFuRender::ThreadLoop() {

  if (!SetUpFuRender()) {
    return;
  }
  
  if (!InitOpenGLEnv()) {
    return;
  }
  
  const GLubyte* gl_version = glGetString(GL_VERSION);
  AV_INFO("VideoFuRender gl_version: %{public}s", gl_version);
  
  ready_ = true;
  while (running_) {
    if (!video_frame_.filled) {
      usleep(5000);
    } else {
      //handle.
      std::unique_lock<std::mutex> lock(wakeup_mutex_);
      
      //flush cache.
      if (!beauty_params_cache_.empty()) {
        for (const auto& pair: beauty_params_cache_) {
          SetBeautyFilterImpl(false, pair.first, pair.second);
        }
        beauty_params_cache_.clear();
      }
      
      if (!filter_cache_.first.empty() && filter_cache_.second >= 0) {
        SetBeautyFilterImpl(true, filter_cache_.first, filter_cache_.second);
        filter_cache_ = std::pair<std::string, double>();
      }
      
      if (video_frame_.data == nullptr) {
        AV_ERROR("VideoFuRender input_video_frame_.data_ptr is nullptr.");
        continue;
      }
      fuRenderItemsEx2(FU_FORMAT_I420_BUFFER, video_frame_.data, FU_FORMAT_I420_BUFFER, video_frame_.data,video_frame_.width, video_frame_.height, frame_id_, item_handles_, sizeof(item_handles_)/sizeof(item_handles_[0]), NAMA_RENDER_FEATURE_FULL, nullptr);
      video_frame_.filled = false;
      wakeup_cond_.notify_one();
    }
  }
  
  //release
  {
    std::unique_lock<std::mutex> lock(wakeup_mutex_);
    ready_ = false;
    wakeup_cond_.notify_one();
  }
  ReleaseRender();
}

bool VideoFuRender::InitOpenGLEnv() {
  AV_INFO("InitOpenGlEnv...");
  egl_display_ = eglGetDisplay(EGL_DEFAULT_DISPLAY);
  if (egl_display_ == EGL_NO_DISPLAY) {
    AV_ERROR("Unable to get egl display.");
    return false;
  }
  
  EGLint major_version;
  EGLint minor_version;
  if (!eglInitialize(egl_display_, &major_version, &minor_version)) {
    AV_ERROR("Unable init egl display.");
    return false;
  }
  
  const EGLint max_config_size = 1;
  EGLint num_configs;
  EGLConfig egl_config = EGL_NO_CONFIG_KHR;
  if (!eglChooseConfig(egl_display_, ATTRIB_LIST, &egl_config, max_config_size, &num_configs)) {
    AV_ERROR("Unable choose config.");
    return false;
  }
  
  const EGLint surface_attribs[] = {EGL_WIDTH, 1, EGL_HEIGHT, 1, EGL_NONE};
  egl_surface_ = eglCreatePbufferSurface(egl_display_, egl_config, surface_attribs);
  if (egl_surface_ == EGL_NO_SURFACE) {
    AV_ERROR("Failed to create pixel buffer surface, error: %d", eglGetError());
    return false;
  }
  
  if (share_egl_context_ == nullptr) {
    AV_ERROR("share egl context is nullptr.");
    return false;
  }
  
  auto context_ptr = eglCreateContext(egl_display_, egl_config, share_egl_context_, nullptr);
  AV_INFO("eglCreateContext share_egl_context: %{public}p, context_ptr:%{public}p", share_egl_context_, context_ptr);
  
  if (egl_surface_ == nullptr || share_egl_context_ == nullptr) {
    AV_ERROR("egl surface or context is nullptr.");
    return false;
  }
  
  if (!eglMakeCurrent(egl_display_, egl_surface_, egl_surface_, share_egl_context_)) {
    AV_ERROR("Unable make current.");
    return false;
  }
  return true;
}

bool VideoFuRender::SetUpFuRender() {
  AV_INFO("SetUpFuRender...");
  auto result = fuSetup(nullptr, 0, nullptr, g_auth_package,sizeof(g_auth_package));
  if (result == 0) {
    AV_ERROR("FU Setup failed, result: %{public}d", result);
    return false;
  }
  fuSetLogLevel(FULOGLEVEL::FU_LOG_LEVEL_WARN);
  
  share_egl_context_ = fuInitGLContext(nullptr);
  AV_INFO("fuInitGLContext after share_egl_context_:%{public}p", share_egl_context_);
  
  // load ai processor.
  std::vector<char> ai_face_processor_model;
  if (!LoadBundle(AI_FACE_PROCESSOR, ai_face_processor_model)) {
    AV_ERROR("Fail load ai face processor...");
  } else {
    fuSetFaceModelConfig(FUAIFACE_ALL_DEFAULT);
    fuSetFaceAlgorithmConfig(FUAIFACE_ENABLE_ALL);
    fuLoadAIModelFromPackage(reinterpret_cast<float*>(&ai_face_processor_model[0]), ai_face_processor_model.size(), FUAITYPE::FUAITYPE_FACEPROCESSOR);
    fuSetMaxFaces(VIDEO_FU_MAX_FACES);
  }
  
  int device_level = fuGetDeviceLevel();
  AV_INFO("fuGetDeviceLevel : %{public}d", device_level);
  
  std::vector<char> propData;
  if (!LoadBundle(AI_FACE_BEAUTIFICATION, propData)) {
    AV_ERROR("Fail load face beautification data.");
  } else {
    item_handles_[FACE_BEAUTY_INDEX] = fuCreateItemFromPackage(&propData[0], propData.size());
  }
  return true;
}