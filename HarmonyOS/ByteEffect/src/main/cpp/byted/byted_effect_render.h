//
// Created on 2025/4/3.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef HARMONY_BYTED_EFFECT_RENDER_H
#define HARMONY_BYTED_EFFECT_RENDER_H

#include "INERtcEngine.h"
#include "napi/native_api.h"
#include <string>

#define NERTC_FORMAT_TEXTURE_2D  7
#define EFFECT_MODEL_PATH "/ModelResource.bundle"

using namespace nertc_sdk;
class BytedEffectRender : public IVideoFrameObserver{

public:
  BytedEffectRender();
  ~BytedEffectRender();
  static napi_value Init(napi_env env, napi_value exports);
  static napi_value SetBundlePath(napi_env env, napi_callback_info info);
  static napi_value EnableBeauty(napi_env env, napi_callback_info info);
  static napi_value GetVideoRenderHandle(napi_env env, napi_callback_info info);
  static napi_value SetComposerNodes(napi_env env, napi_callback_info info);
  static napi_value UpdateComposerNode(napi_env env, napi_callback_info info);
  
public:
  void onCaptureFrame(void* data, int32_t color_format, uint32_t width, uint32_t height, 
  uint32_t count, int64_t offset[4], uint32_t stride[4], uint16_t rotation) override;
    void onCaptureFrame2(const IVideoCallbackFrame &frame) override;
  static napi_value Construct(napi_env, napi_callback_info info);
  
private:
  static int Effect_Log_Callback(int logLevel, const char* msg);
  void EnableBeauty(bool enable);
  bool SetUpEffectRender();
  void ReleaseRender();
  void GeneratorTexture(int width, int height);
  int CalculateOrientation(int rotation);
  void CheckTexturePixels(int texture_id, int width, int height);
  
private:
  void* handle_;
  unsigned int output_texture_;
  //render resources.
  napi_ref process_ref_;
  napi_env env_;
  std::string bundle_path_;
  std::string license_path_;
  bool initialized {false};
  
};

#endif //HARMONY_BYTED_EFFECT_RENDER_H
