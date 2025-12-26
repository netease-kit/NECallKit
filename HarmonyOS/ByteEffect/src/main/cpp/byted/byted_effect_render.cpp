//
// Created on 2025/4/3.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#include "byted_effect_render.h"
#include "byted/include/bef_effect_ai_public_define.h"
#include "log.h"
#include <cassert>
#include "byted/include/bef_effect_ai_api.h"
#include <chrono>
#include <GLES3/gl3.h>
#include <native_drawing/drawing_canvas.h>
#include <native_drawing/drawing_bitmap.h>

BytedEffectRender::BytedEffectRender()
  : env_(nullptr), process_ref_(nullptr), handle_(nullptr), output_texture_(-9999) {
  AV_INFO("BytedEffectRender Constructor.");
}

BytedEffectRender::~BytedEffectRender() {
  AV_INFO("BytedEffectRender DeConstructor.");
  napi_delete_reference(env_, process_ref_);
  initialized = false;
  handle_ = nullptr;
  output_texture_ = -9999;
}

napi_value BytedEffectRender::Construct(napi_env env, napi_callback_info info) {
  AV_INFO("BytedEffectRender Construct ...");
  napi_value thisVar;
  assert(napi_get_cb_info(env, info, nullptr, nullptr, &thisVar, nullptr) == napi_ok);
  BytedEffectRender *render = new BytedEffectRender();
  render->env_ = env;
  assert(napi_wrap(env, thisVar, (void*)render, [](napi_env env, void* data, void* hint) {
    auto effect_render = (BytedEffectRender *)data;
    delete effect_render;
  }, nullptr, &render->process_ref_) == napi_ok);
  return thisVar;
}

napi_value BytedEffectRender::Init(napi_env env, napi_value exports) {
  AV_INFO("Export class BytedRender.");
  napi_property_descriptor properties[] = {
    {"setBundlePath", nullptr, SetBundlePath, nullptr, nullptr, nullptr, napi_default, nullptr},
    {"enableBeauty", nullptr, EnableBeauty, nullptr, nullptr, nullptr, napi_default,  nullptr},
    {"getNativeHandle", nullptr, GetVideoRenderHandle, nullptr, nullptr, nullptr, napi_default, nullptr},
    {"setComposerNodes", nullptr, SetComposerNodes, nullptr, nullptr, nullptr, napi_default, nullptr},
    {"updateComposerNode", nullptr, UpdateComposerNode, nullptr, nullptr, nullptr, napi_default, nullptr},
  };
  napi_value clazz;
  assert(napi_define_class(env, "BytedRender", NAPI_AUTO_LENGTH, BytedEffectRender::Construct, nullptr, sizeof(properties)/sizeof(properties[0]), properties, &clazz) == napi_ok);
  assert(napi_set_named_property(env, exports, "BytedRender",clazz) == napi_ok);
  return exports;
}

napi_value BytedEffectRender::SetBundlePath(napi_env env, napi_callback_info info) {
    napi_value thisVar;
    size_t argc = 2;
    napi_value args[2];
    assert(napi_get_cb_info(env, info, &argc, args, &thisVar, nullptr) == napi_ok);
  
    size_t len;
    assert(napi_get_value_string_utf8(env, args[0], nullptr, 0, &len) == napi_ok);
    std::vector<char> buf(len + 1);
    assert(napi_get_value_string_utf8(env, args[0], buf.data(), len + 1, &len) == napi_ok);
  
    std::string file_path = std::string(buf.data());
    AV_INFO("file_path: %{public}s", file_path.c_str());
  
    assert(napi_get_value_string_utf8(env, args[1], nullptr, 0, &len) == napi_ok);
    std::vector<char> buf1(len + 1);
    assert(napi_get_value_string_utf8(env, args[1], buf1.data(), len + 1, &len) == napi_ok);
    std::string license_path = std::string(buf1.data());
    AV_INFO("license_path: %{public}s", license_path.c_str());
  
    BytedEffectRender *effect_render;
    assert(napi_unwrap(env, thisVar, reinterpret_cast<void **>(&effect_render)) == napi_ok);
    effect_render->bundle_path_ = file_path;
    effect_render->license_path_ = license_path;
    return thisVar;
}

napi_value BytedEffectRender::EnableBeauty(napi_env env, napi_callback_info info) {
  
    napi_value thisVar;
    size_t argc = 1;
    napi_value args[1];
    assert(napi_get_cb_info(env, info, &argc, args, &thisVar, nullptr) == napi_ok);
  
    BytedEffectRender* effect_render;
    assert(napi_unwrap(env, thisVar, reinterpret_cast<void **>(&effect_render)) == napi_ok);
  
    if (effect_render == nullptr) {
      AV_ERROR("effect_render is nullptr.");
      return thisVar;
    }
  
    bool enable = false;
    assert(napi_get_value_bool(env, args[0], &enable) == napi_ok);
    AV_INFO("EnableBeauty enable:%{public}d", enable);
  
    effect_render->EnableBeauty(enable);
    return thisVar;
}

napi_value BytedEffectRender::GetVideoRenderHandle(napi_env env, napi_callback_info info) {
  
  napi_value thisVar;
  assert(napi_get_cb_info(env, info, nullptr, nullptr, &thisVar, nullptr) == napi_ok);

  BytedEffectRender* byted_render;
  assert(napi_unwrap(env, thisVar, reinterpret_cast<void **>(&byted_render)) == napi_ok);
  AV_INFO("GetBytedEffectRenderHandle addr: %{public}p", byted_render);
  
  napi_value handle;
  assert(napi_create_bigint_uint64(env, (uint64_t)byted_render, &handle) == napi_ok);
  return handle;
}

napi_value BytedEffectRender::SetComposerNodes(napi_env env, napi_callback_info info) {
    napi_value thisVar;
    size_t argc = 1;
    napi_value args[1];
    assert(napi_get_cb_info(env, info, &argc, args, &thisVar, nullptr) == napi_ok);
  
    uint32_t len = 0;
    assert(napi_get_array_length(env, args[0], &len) == napi_ok);
    
    const char** node_paths = new const char*[len];
    for (uint32_t i = 0; i < len; i++) {
      napi_value element;
      napi_get_element(env, args[0], i, &element);
    
      napi_valuetype value_type;
      napi_typeof(env, element, &value_type);
      if (value_type != napi_string) continue;
    
      //get string len.
      size_t str_len;
      napi_get_value_string_utf8(env, element, nullptr, 0, &str_len);
      char* str_copy = new char[str_len + 1];
      size_t copied;
      napi_get_value_string_utf8(env, element, str_copy, str_len + 1, &copied);
      node_paths[i] = str_copy;
    }
  
    BytedEffectRender* byted_render;
    assert(napi_unwrap(env, thisVar, reinterpret_cast<void **>(&byted_render)) == napi_ok);
    bef_effect_ai_composer_set_nodes(byted_render->handle_, node_paths, len);
    
    for (int i = 0; i < len; i++) 
      delete[] node_paths[i];
    delete [] node_paths;
    return thisVar;
}

napi_value BytedEffectRender::UpdateComposerNode(napi_env env, napi_callback_info info) {
    napi_value thisVar;
    size_t argc = 3;
    napi_value args[3];
    assert(napi_get_cb_info(env, info, &argc, args, &thisVar, nullptr) == napi_ok);
      
    size_t str_len;
    napi_get_value_string_utf8(env, args[0], nullptr, 0, &str_len);
    std::string node_path(str_len, '\0');
    napi_get_value_string_utf8(env,  args[0], &node_path[0], str_len + 1, &str_len);
    AV_INFO("UpdateComposerNode node_path: %{public}s", node_path.c_str());
  
    napi_get_value_string_utf8(env, args[1], nullptr, 0, &str_len);
    std::string key(str_len, '\0');
    napi_get_value_string_utf8(env, args[1], &key[0], str_len + 1, &str_len);
    AV_INFO("UpdateComposerNode key: %{public}s", key.c_str());
  
    double value = 0.0f;
    napi_get_value_double(env, args[2], &value);
    
    BytedEffectRender* byted_render;
    assert(napi_unwrap(env, thisVar, reinterpret_cast<void **>(&byted_render)) == napi_ok); 
    bef_effect_ai_composer_update_node(byted_render->handle_, node_path.c_str(), key.c_str(), value);
    return thisVar;
}

int BytedEffectRender::Effect_Log_Callback(int logLevel, const char* msg) {
  AV_INFO("logLevel:%{public}d, msg:%{public}s", logLevel, msg);
  return 0;
}

void BytedEffectRender::EnableBeauty(bool enable) {
  if (enable) {
    SetUpEffectRender();
  } else {
    ReleaseRender();
  }
}

bool BytedEffectRender::SetUpEffectRender() {
  AV_INFO("SetUp ByteEffect Render");
  if (initialized) {
    AV_INFO("ByteEffect has been init already.");
    return true;
  }
  //创建 SDK 实例
  bef_effect_result_t ret = bef_effect_ai_create(&handle_);
  if (ret != BEF_RESULT_SUC) {
    AV_ERROR("ByteEffect create handle failed, ret:%{public}d", ret);
    return false;
  }
  //设置日志级别
  bef_effect_ai_set_log_level(BEF_AI_LOG_LEVEL_DEBUG);
  bef_effect_ai_set_log_callback(Effect_Log_Callback);
  //鉴权
//  const auto license_path = bundle_path_ + "/LicenseBag.bundle/shuzhi_test_20250328_20250628_com.netease.rtcdemo_4.7.0_2682.licbag";
  const auto license_path = bundle_path_ + license_path_;
  ret = bef_effect_ai_check_license(handle_, license_path.c_str());
  if (ret != BEF_RESULT_SUC) {
    AV_ERROR("ByteEffect check license failed, ret:%{public}d", ret);
    return false;
  }
  //设置 opengl es 版本
  bef_effect_ai_set_render_api(handle_, bef_ai_render_api_gles30);
  //初始化，设置模型路径
  const auto model_path = bundle_path_ + EFFECT_MODEL_PATH;
  ret = bef_effect_ai_init(handle_, 10, 10, model_path.c_str(), "");
  if (ret != BEF_RESULT_SUC) {
    AV_ERROR("ByteEffect init failed, ret:%{public}d", ret);
    return false;
  }
  bef_effect_ai_use_builtin_sensor(handle_, true);
  bef_effect_ai_use_3buffer(handle_, false);
  //设置 SDK 美颜模式
  ret = bef_effect_ai_composer_set_mode(handle_, 1, 0);
  if (ret != BEF_RESULT_SUC) {
    AV_ERROR("ByteEffect set mode failed, ret:%{public}d", ret);
    return false;
  }
  initialized = true;
  return true;
}

void BytedEffectRender::ReleaseRender() {
  if (!initialized) {
    AV_ERROR("ByteEffectRender release done.");
    return;
  }
  initialized = false;  
  bef_effect_ai_clean_pipeline_processor_task(handle_);
  bef_effect_ai_set_log_callback(nullptr);
  bef_effect_ai_destroy(handle_);
}

void BytedEffectRender::GeneratorTexture(int width, int height) {
    glGenTextures(1, &output_texture_);
    glBindTexture(GL_TEXTURE_2D, output_texture_);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glBindTexture(GL_TEXTURE_2D, GL_NONE);
}

int BytedEffectRender::CalculateOrientation(int rotation) {
  switch(rotation) {
    case 90: return BEF_AI_CLOCKWISE_ROTATE_90;
    case 180: return BEF_AI_CLOCKWISE_ROTATE_180;
    case 270: return BEF_AI_CLOCKWISE_ROTATE_270;
    default: return BEF_AI_CLOCKWISE_ROTATE_0;
  }
}

void BytedEffectRender::CheckTexturePixels(int texture_id, int width, int height) {
    GLuint fbo[1];
    glGenFramebuffers(1, fbo);
    glBindFramebuffer(GL_FRAMEBUFFER, fbo[0]);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture_id, 0);
    void* pixels = malloc(width * height * 4);
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glDeleteFramebuffers(1, fbo);

    OH_Drawing_Image_Info screenImageInfo = { static_cast<int32_t>(width), static_cast<int32_t>(height), COLOR_FORMAT_RGBA_8888, ALPHA_FORMAT_OPAQUE};
    OH_Drawing_Bitmap* screenBitmap = OH_Drawing_BitmapCreateFromPixels(&screenImageInfo, pixels, width * 4);
    OH_Drawing_Canvas* screenCanvas = OH_Drawing_CanvasCreate();
    OH_Drawing_CanvasBind(screenCanvas, screenBitmap);
    free(pixels);  
}

void BytedEffectRender::onCaptureFrame(void* data, int32_t color_format, uint32_t width, uint32_t height, 
uint32_t count, int64_t offset[4], uint32_t stride[4], uint16_t rotation) {
  
  if (!initialized) {
    return;
  }

  if (color_format == NERTC_FORMAT_TEXTURE_2D && data != nullptr) {
      //设置图像宽高
      int ret = bef_effect_ai_set_width_height(handle_, width, height);
      if (ret != BEF_RESULT_SUC) {
        AV_ERROR("BytedEffect setWidth, Height failed, ret: %{public}d", ret);
        return;
      }
    
      //设置图像的旋转角度，一般直接取系统提供的手机旋转方向即可
      ret = bef_effect_ai_set_orientation(handle_, static_cast<bef_ai_rotate_type>(CalculateOrientation(rotation)));
      if (ret != BEF_RESULT_SUC) {
        AV_ERROR("BytedEffect set orientation failed, ret:%{public}d", ret);
        return;
      }
      auto starTime = std::chrono::duration_cast<std::chrono::milliseconds>(
		  std::chrono::system_clock::now().time_since_epoch());
      double timestamp = (double)starTime.count() / 1000.0;
      //对图像做算法处理，调用此函数才会执行人脸检测
      int* src_texture = reinterpret_cast<int*>(data);
      if (!glIsTexture(*src_texture)) {
        abort();
      }
    
#ifdef PIXELS_CHECK
    CheckTexturePixels(*src_texture, width, height);
#endif
    
      ret = bef_effect_ai_algorithm_texture(handle_, *src_texture, timestamp);  
      if (ret != BEF_RESULT_SUC) {
        //AV_ERROR("bef_effect_ai_algorithm_texture failed, ret: %{public}d", ret);
      }
         
      //对图像做特效处理
      if (output_texture_ == -9999) {
        GeneratorTexture(width, height);
      }
      bef_effect_ai_set_camera_device_position(handle_, bef_ai_camera_position_front);
      ret = bef_effect_ai_process_texture(handle_, *src_texture, output_texture_, timestamp);
    
#ifdef PIXELS_CHECK
      CheckTexturePixels(output_texture_, width, height);
#endif
    
      if (ret != BEF_RESULT_SUC) {
        AV_ERROR("bef_effect_ai_process_texture failed, ret: %{public}d", ret);
      } else {
        *src_texture = output_texture_;
      }
  }
}

void BytedEffectRender::onCaptureFrame2(const IVideoCallbackFrame &frame) {
}