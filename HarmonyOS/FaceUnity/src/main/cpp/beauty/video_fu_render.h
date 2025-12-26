//
// Created on 2025/2/13.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef HARMONY_VIDEOFURENDER_H
#define HARMONY_VIDEOFURENDER_H
#include "INERtcEngine.h"
#include "napi/native_api.h"
#include <EGL/egl.h>
#include <string>
#include <thread>
#include <map>
#include "napi_base.h"


using namespace nertc_sdk;
class VideoFuRender : public IVideoFrameObserver{

public:
  VideoFuRender();
  ~VideoFuRender();
  static napi_value Init(napi_env env, napi_value exports);
  
public:
  void onCaptureFrame(void* data, int32_t color_format, uint32_t width, uint32_t height, 
    uint32_t count, int64_t offset[4], uint32_t stride[4], uint16_t rotation) override;
    void onCaptureFrame2(const IVideoCallbackFrame &frame) override;

  static napi_value Construct(napi_env env, napi_callback_info info);
  
// caller from ts.
private:
  static napi_value SetBundlePath(napi_env env, napi_callback_info info);
  static napi_value GetVideoFuRenderHandle(napi_env env, napi_callback_info info);
  static napi_value SetBeautyParam(napi_env env, napi_callback_info info);
  static napi_value SetFilterParam(napi_env env, napi_callback_info info);
  static napi_value EnableBeauty(napi_env env, napi_callback_info info);
  
// inner render operator.
private: 
  bool LoadBundle(const std::string& model_path, std::vector<char>& data);
  void EnableBeauty(bool enable);
  void ThreadLoop();
  bool SetUpFuRender();
  bool InitOpenGLEnv();
  void ReleaseRender();
  bool SetBeautyFilterImpl(bool filter, const std::string& key, const double val);
  
private:
  napi_ref process_ref_;
  napi_env env_;
  std::string bundle_path_;
  //about render thread.
  std::thread render_thread_;
  bool running_;
  bool ready_;
  std::mutex wakeup_mutex_;
  std::condition_variable wakeup_cond_;
  //about fu render.
  int item_handles_[2] = {0, 0}; 
  VideoFrame video_frame_;
  int frame_id_ = 0;
  EGLContext share_egl_context_;
  EGLSurface egl_surface_;
  EGLDisplay egl_display_;
  std::map<std::string, double> beauty_params_cache_;
  std::pair<std::string, double> filter_cache_;
};

#endif //HARMONY_VIDEOFURENDER_H
