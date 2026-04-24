#import "CallkitPlugin.h"

#import <AVFoundation/AVFoundation.h>
#import <AppKit/AppKit.h>

#include <dlfcn.h>

#include <cstring>
#include <memory>
#include <mutex>
#include <string>
#include <utility>
#include <vector>

#include "../../desktop_bridge/include/ne_call_bridge.h"

@class NECallkitDesktopRenderer;

namespace {

constexpr const char* kCreateRendererChannel =
    "dev.flutter.pigeon.CallkitVideoRendererApi.createVideoRenderer";
constexpr const char* kSetMirrorChannel =
    "dev.flutter.pigeon.CallkitVideoRendererApi.setMirror";
constexpr const char* kSetupLocalRendererChannel =
    "dev.flutter.pigeon.CallkitVideoRendererApi.setupLocalVideoRenderer";
constexpr const char* kSetupRemoteRendererChannel =
    "dev.flutter.pigeon.CallkitVideoRendererApi.setupRemoteVideoRenderer";
constexpr const char* kDisposeRendererChannel =
    "dev.flutter.pigeon.CallkitVideoRendererApi.disposeVideoRenderer";
constexpr const char* kMacOSVideoViewChannel =
    "ne_call_kit/macos_video_view";
constexpr const char* kMacOSPermissionChannel =
    "ne_call_kit/permission";
constexpr const char* kCallkitVideoViewType = "callkit_video_view";

template <typename T>
T LookupBridgeSymbol(void* library_handle,
                     const char* symbol_name,
                     T fallback_symbol) {
  if (library_handle != nullptr) {
    if (auto* symbol = dlsym(library_handle, symbol_name)) {
      return reinterpret_cast<T>(symbol);
    }
  }
  if (fallback_symbol != nullptr) {
    return fallback_symbol;
  }
  if (auto* symbol = dlsym(RTLD_DEFAULT, symbol_name)) {
    return reinterpret_cast<T>(symbol);
  }
  return nullptr;
}

class BridgeApi {
 public:
  bool EnsureLoaded() {
    if (loaded_) {
      return create_ != nullptr;
    }
    loaded_ = true;

    const char* candidates[] = {
        "libne_callkit.dylib",
        "@rpath/libne_callkit.dylib",
        "@executable_path/../Frameworks/libne_callkit.dylib",
        "@loader_path/../Frameworks/libne_callkit.dylib",
        "libne_call_bridge.dylib",
        "@rpath/libne_call_bridge.dylib",
        "@executable_path/../Frameworks/libne_call_bridge.dylib",
        "@loader_path/../Frameworks/libne_call_bridge.dylib",
        nullptr,
    };
    for (const char** candidate = candidates; *candidate != nullptr; ++candidate) {
      library_handle_ = dlopen(*candidate, RTLD_NOW | RTLD_LOCAL);
      if (library_handle_ != nullptr) {
        break;
      }
    }

    create_ = LookupBridgeSymbol<CreateFn>(
        library_handle_, "ne_call_bridge_create", nullptr);
    destroy_ = LookupBridgeSymbol<DestroyFn>(
        library_handle_, "ne_call_bridge_destroy", nullptr);
    register_video_renderer_ = LookupBridgeSymbol<RegisterVideoRendererFn>(
        library_handle_, "ne_call_bridge_register_video_renderer", nullptr);
    unregister_video_renderer_ = LookupBridgeSymbol<UnregisterVideoRendererFn>(
        library_handle_, "ne_call_bridge_unregister_video_renderer", nullptr);
    setup_local_video_renderer_ =
        LookupBridgeSymbol<SetupLocalVideoRendererFn>(
            library_handle_, "ne_call_bridge_setup_local_video_renderer", nullptr);
    setup_remote_video_renderer_with_uid_ =
        LookupBridgeSymbol<SetupRemoteVideoRendererWithUidFn>(
            library_handle_,
            "ne_call_bridge_setup_remote_video_renderer_with_uid",
            nullptr);
    setup_local_video_window_ = LookupBridgeSymbol<SetupLocalVideoWindowFn>(
        library_handle_, "ne_call_bridge_setup_local_video_window", nullptr);
    setup_remote_video_window_ = LookupBridgeSymbol<SetupRemoteVideoWindowFn>(
        library_handle_, "ne_call_bridge_setup_remote_video_window", nullptr);
    set_local_video_window_scaling_mode_ =
        LookupBridgeSymbol<SetVideoWindowScalingModeFn>(
            library_handle_,
            "ne_call_bridge_set_local_video_window_scaling_mode",
            nullptr);
    set_remote_video_window_scaling_mode_ =
        LookupBridgeSymbol<SetVideoWindowScalingModeFn>(
            library_handle_,
            "ne_call_bridge_set_remote_video_window_scaling_mode",
            nullptr);
    set_video_renderer_mirror_ = LookupBridgeSymbol<SetVideoRendererMirrorFn>(
        library_handle_, "ne_call_bridge_set_video_renderer_mirror", nullptr);
    return create_ != nullptr && register_video_renderer_ != nullptr &&
           unregister_video_renderer_ != nullptr &&
           setup_local_video_renderer_ != nullptr &&
           setup_remote_video_renderer_with_uid_ != nullptr &&
           setup_local_video_window_ != nullptr &&
           setup_remote_video_window_ != nullptr &&
           set_local_video_window_scaling_mode_ != nullptr &&
           set_remote_video_window_scaling_mode_ != nullptr &&
           set_video_renderer_mirror_ != nullptr;
  }

  NECallBridgeHandle EnsureHandle() {
    if (bridge_handle_ != nullptr) {
      return bridge_handle_;
    }
    if (!EnsureLoaded()) {
      return nullptr;
    }
    bridge_handle_ = create_();
    return bridge_handle_;
  }

  void Destroy() {
    if (!EnsureLoaded()) {
      bridge_handle_ = nullptr;
      return;
    }
    if (destroy_ != nullptr) {
      destroy_();
    }
    bridge_handle_ = nullptr;
  }

  int32_t RegisterVideoRenderer(const NECallBridgeVideoRendererParam& param) {
    auto handle = EnsureHandle();
    return handle == nullptr ? -1 : register_video_renderer_(handle, &param);
  }

  int32_t UnregisterVideoRenderer(int64_t renderer_id) {
    auto handle = EnsureHandle();
    return handle == nullptr ? -1 : unregister_video_renderer_(handle, renderer_id);
  }

  int32_t SetupLocalVideoRenderer(int64_t renderer_id) {
    auto handle = EnsureHandle();
    return handle == nullptr ? -1
                             : setup_local_video_renderer_(handle, renderer_id);
  }

  int32_t SetupRemoteVideoRenderer(int64_t uid, int64_t renderer_id) {
    auto handle = EnsureHandle();
    return handle == nullptr
               ? -1
               : setup_remote_video_renderer_with_uid_(
                     handle, static_cast<uint64_t>(uid), renderer_id);
  }

  int32_t SetupLocalVideoWindow(void* window) {
    auto handle = EnsureHandle();
    return handle == nullptr ? -1 : setup_local_video_window_(handle, window);
  }

  int32_t SetupRemoteVideoWindow(void* window) {
    auto handle = EnsureHandle();
    return handle == nullptr ? -1 : setup_remote_video_window_(handle, window);
  }

  int32_t SetLocalVideoWindowScalingMode(int32_t scaling_mode) {
    auto handle = EnsureHandle();
    return handle == nullptr
               ? -1
               : set_local_video_window_scaling_mode_(handle, scaling_mode);
  }

  int32_t SetRemoteVideoWindowScalingMode(int32_t scaling_mode) {
    auto handle = EnsureHandle();
    return handle == nullptr
               ? -1
               : set_remote_video_window_scaling_mode_(handle, scaling_mode);
  }

  int32_t SetVideoRendererMirror(int64_t renderer_id, bool mirror) {
    auto handle = EnsureHandle();
    return handle == nullptr ? -1
                             : set_video_renderer_mirror_(
                                   handle, renderer_id, mirror ? 1 : 0);
  }

 private:
  using CreateFn = NECallBridgeHandle (*)();
  using DestroyFn = void (*)();
  using RegisterVideoRendererFn = int32_t (*)(
      NECallBridgeHandle, const NECallBridgeVideoRendererParam*);
  using UnregisterVideoRendererFn = int32_t (*)(NECallBridgeHandle, int64_t);
  using SetupLocalVideoRendererFn = int32_t (*)(NECallBridgeHandle, int64_t);
  using SetupRemoteVideoRendererWithUidFn =
      int32_t (*)(NECallBridgeHandle, uint64_t, int64_t);
  using SetupLocalVideoWindowFn = int32_t (*)(NECallBridgeHandle, void*);
  using SetupRemoteVideoWindowFn = int32_t (*)(NECallBridgeHandle, void*);
  using SetVideoWindowScalingModeFn =
      int32_t (*)(NECallBridgeHandle, int32_t);
  using SetVideoRendererMirrorFn =
      int32_t (*)(NECallBridgeHandle, int64_t, uint8_t);

  bool loaded_ = false;
  void* library_handle_ = nullptr;
  NECallBridgeHandle bridge_handle_ = nullptr;
  CreateFn create_ = nullptr;
  DestroyFn destroy_ = nullptr;
  RegisterVideoRendererFn register_video_renderer_ = nullptr;
  UnregisterVideoRendererFn unregister_video_renderer_ = nullptr;
  SetupLocalVideoRendererFn setup_local_video_renderer_ = nullptr;
  SetupRemoteVideoRendererWithUidFn setup_remote_video_renderer_with_uid_ =
      nullptr;
  SetupLocalVideoWindowFn setup_local_video_window_ = nullptr;
  SetupRemoteVideoWindowFn setup_remote_video_window_ = nullptr;
  SetVideoWindowScalingModeFn set_local_video_window_scaling_mode_ = nullptr;
  SetVideoWindowScalingModeFn set_remote_video_window_scaling_mode_ = nullptr;
  SetVideoRendererMirrorFn set_video_renderer_mirror_ = nullptr;
};

BridgeApi& GetBridgeApi() {
  static BridgeApi bridge_api;
  return bridge_api;
}

NSArray* SuccessReply(id _Nullable value) {
  return value == nil ? @[] : @[ value ];
}

NSArray* ErrorReply(NSString* code, NSString* message, id _Nullable details) {
  return @[ code ?: @"error", message ?: @"error", details ?: [NSNull null] ];
}

void DesktopRendererFrameCallback(int64_t renderer_id,
                                  const uint8_t* bgra,
                                  uint32_t width,
                                  uint32_t height,
                                  uint32_t rotation,
                                  void* user_data);

}  // namespace

@interface NECallkitDesktopRenderer : NSObject <FlutterTexture, FlutterStreamHandler> {
 @private
  NSObject<FlutterTextureRegistry>* _textureRegistry;
  NSObject<FlutterBinaryMessenger>* _messenger;
  FlutterEventChannel* _eventChannel;
  FlutterEventSink _eventSink;
  int64_t _textureId;
  std::mutex _frameMutex;
  std::vector<uint8_t> _bgraBuffer;
  uint32_t _width;
  uint32_t _height;
  uint32_t _rotation;
  uint32_t _lastEventWidth;
  uint32_t _lastEventHeight;
  uint32_t _lastEventRotation;
  BOOL _hasFrame;
  BOOL _didEmitFirstFrame;
}

@property(nonatomic, readonly) int64_t textureId;

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;
- (void)dispose;
- (void)handleFrame:(const uint8_t*)bgra
              width:(uint32_t)width
             height:(uint32_t)height
           rotation:(uint32_t)rotation;

@end

@implementation NECallkitDesktopRenderer

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  self = [super init];
  if (self == nil) {
    return nil;
  }

  _textureRegistry = [registrar textures];
  _messenger = [registrar messenger];
  _textureId = [_textureRegistry registerTexture:self];
  NSString* channel_name =
      [NSString stringWithFormat:@"NECallkitRenderer/Texture%lld", _textureId];
  _eventChannel = [FlutterEventChannel eventChannelWithName:channel_name
                                            binaryMessenger:_messenger];
  [_eventChannel setStreamHandler:self];
  _width = 0;
  _height = 0;
  _rotation = 0;
  _lastEventWidth = 0;
  _lastEventHeight = 0;
  _lastEventRotation = 0;
  _hasFrame = NO;
  _didEmitFirstFrame = NO;
  return self;
}

- (int64_t)textureId {
  return _textureId;
}

- (void)dispose {
  [_eventChannel setStreamHandler:nil];
  [_textureRegistry unregisterTexture:_textureId];
  GetBridgeApi().UnregisterVideoRenderer(_textureId);
}

- (void)handleFrame:(const uint8_t*)bgra
              width:(uint32_t)width
             height:(uint32_t)height
           rotation:(uint32_t)rotation {
  if (bgra == nullptr || width == 0 || height == 0) {
    return;
  }

  BOOL emitFirstFrame = NO;
  BOOL emitResolutionChanged = NO;
  {
    std::lock_guard<std::mutex> lock(_frameMutex);
    const size_t length = static_cast<size_t>(width) * height * 4;
    _bgraBuffer.resize(length);
    std::memcpy(_bgraBuffer.data(), bgra, length);
    _width = width;
    _height = height;
    _rotation = rotation;
    _hasFrame = YES;
    emitFirstFrame = !_didEmitFirstFrame;
    if (!_didEmitFirstFrame) {
      _didEmitFirstFrame = YES;
    }
    emitResolutionChanged =
        (_lastEventWidth != width || _lastEventHeight != height ||
         _lastEventRotation != rotation);
    _lastEventWidth = width;
    _lastEventHeight = height;
    _lastEventRotation = rotation;
  }

  dispatch_async(dispatch_get_main_queue(), ^{
    [self->_textureRegistry textureFrameAvailable:self->_textureId];
    if (self->_eventSink == nil) {
      return;
    }
    if (emitFirstFrame) {
      self->_eventSink(@{
        @"event" : @"onFirstFrameRendered",
        @"id" : @(self->_textureId),
      });
    }
    if (emitResolutionChanged) {
      self->_eventSink(@{
        @"event" : @"onFrameResolutionChanged",
        @"id" : @(self->_textureId),
        @"width" : @(width),
        @"height" : @(height),
        @"rotation" : @(rotation),
      });
    }
  });
}

- (CVPixelBufferRef _Nullable)copyPixelBuffer {
  std::lock_guard<std::mutex> lock(_frameMutex);
  if (!_hasFrame || _width == 0 || _height == 0 || _bgraBuffer.empty()) {
    return nil;
  }

  NSDictionary* options = @{
    (NSString*)kCVPixelBufferMetalCompatibilityKey : @YES
  };
  CVPixelBufferRef pixel_buffer = nil;
  const CVReturn status = CVPixelBufferCreate(
      kCFAllocatorDefault,
      _width,
      _height,
      kCVPixelFormatType_32BGRA,
      (__bridge CFDictionaryRef)options,
      &pixel_buffer);
  if (status != kCVReturnSuccess || pixel_buffer == nil) {
    return nil;
  }

  if (CVPixelBufferLockBaseAddress(pixel_buffer, 0) != kCVReturnSuccess) {
    CVPixelBufferRelease(pixel_buffer);
    return nil;
  }
  auto* base = static_cast<uint8_t*>(CVPixelBufferGetBaseAddress(pixel_buffer));
  const size_t bytes_per_row = CVPixelBufferGetBytesPerRow(pixel_buffer);
  const size_t src_stride = static_cast<size_t>(_width) * 4;
  for (uint32_t row = 0; row < _height; ++row) {
    std::memcpy(base + static_cast<size_t>(row) * bytes_per_row,
                _bgraBuffer.data() + static_cast<size_t>(row) * src_stride,
                src_stride);
  }
  CVPixelBufferUnlockBaseAddress(pixel_buffer, 0);
  return pixel_buffer;
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)events {
  _eventSink = [events copy];
  return nil;
}

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
  _eventSink = nil;
  return nil;
}

@end

namespace {

void DesktopRendererFrameCallback(int64_t renderer_id,
                                  const uint8_t* bgra,
                                  uint32_t width,
                                  uint32_t height,
                                  uint32_t rotation,
                                  void* user_data) {
  (void)renderer_id;
  auto* renderer =
      (__bridge NECallkitDesktopRenderer*)user_data;
  [renderer handleFrame:bgra width:width height:height rotation:rotation];
}

CallkitPlugin* g_plugin_instance = nil;

}  // namespace

@interface CallkitPlugin () <FlutterPlatformViewFactory>

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;
- (void)handleApplicationWillTerminate:(NSNotification*)notification;
- (void)teardownDesktopBridge;
- (void)handlePlatformViewMethodCall:(FlutterMethodCall*)call
                              viewId:(int64_t)viewId
                              result:(FlutterResult)result;
- (void)handleMacOSVideoViewMethodCall:(FlutterMethodCall*)call
                                result:(FlutterResult)result;
- (void)handlePermissionMethodCall:(FlutterMethodCall*)call
                            result:(FlutterResult)result;
- (void)destroyPlatformViewWithId:(int64_t)viewId;

@end

@implementation CallkitPlugin {
  NSObject<FlutterPluginRegistrar>* _registrar;
  NSMutableDictionary<NSNumber*, NECallkitDesktopRenderer*>* _renderers;
  NSMutableDictionary<NSNumber*, NSView*>* _platformViews;
  NSMutableDictionary<NSNumber*, FlutterMethodChannel*>* _platformViewChannels;
  NSMutableDictionary<NSNumber*, NSNumber*>* _platformViewScalingModes;
  NSMutableArray<FlutterBasicMessageChannel*>* _channels;
  FlutterMethodChannel* _macosVideoViewChannel;
  FlutterMethodChannel* _permissionChannel;
  NSNumber* _localPlatformViewId;
  NSNumber* _remotePlatformViewId;
  BOOL _didTeardownDesktopBridge;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  g_plugin_instance = [[CallkitPlugin alloc] initWithRegistrar:registrar];
  [registrar registerViewFactory:g_plugin_instance
                          withId:[NSString stringWithUTF8String:kCallkitVideoViewType]];
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  self = [super init];
  if (self == nil) {
    return nil;
  }
  _registrar = registrar;
  _renderers = [[NSMutableDictionary alloc] init];
  _platformViews = [[NSMutableDictionary alloc] init];
  _platformViewChannels = [[NSMutableDictionary alloc] init];
  _platformViewScalingModes = [[NSMutableDictionary alloc] init];
  _channels = [[NSMutableArray alloc] init];
  _didTeardownDesktopBridge = NO;
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleApplicationWillTerminate:)
                                               name:NSApplicationWillTerminateNotification
                                             object:nil];
  [self setupChannels];
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  if (g_plugin_instance == self) {
    g_plugin_instance = nil;
  }
}

- (void)setupChannels {
  FlutterStandardMessageCodec* codec = [FlutterStandardMessageCodec sharedInstance];
  __weak CallkitPlugin* weakSelf = self;
  _macosVideoViewChannel =
      [FlutterMethodChannel methodChannelWithName:
                                [NSString stringWithUTF8String:kMacOSVideoViewChannel]
                                  binaryMessenger:[_registrar messenger]];
  [_macosVideoViewChannel setMethodCallHandler:^(FlutterMethodCall* call,
                                                 FlutterResult result) {
    CallkitPlugin* strongSelf = weakSelf;
    if (strongSelf == nil) {
      result(@(-1));
      return;
    }
    [strongSelf handleMacOSVideoViewMethodCall:call result:result];
  }];
  _permissionChannel =
      [FlutterMethodChannel methodChannelWithName:
                                [NSString stringWithUTF8String:kMacOSPermissionChannel]
                                  binaryMessenger:[_registrar messenger]];
  [_permissionChannel setMethodCallHandler:^(FlutterMethodCall* call,
                                             FlutterResult result) {
    CallkitPlugin* strongSelf = weakSelf;
    if (strongSelf == nil) {
      result(@(NO));
      return;
    }
    [strongSelf handlePermissionMethodCall:call result:result];
  }];
  [self addChannel:kCreateRendererChannel
             codec:codec
           handler:^(id message, FlutterReply reply) {
             CallkitPlugin* strongSelf = weakSelf;
             if (strongSelf == nil) {
               reply(ErrorReply(@"plugin_unavailable", @"callkit plugin released", nil));
               return;
             }
             [strongSelf handleCreateRendererWithReply:reply];
           }];
  [self addChannel:kSetMirrorChannel
             codec:codec
           handler:^(id message, FlutterReply reply) {
             CallkitPlugin* strongSelf = weakSelf;
             if (strongSelf == nil) {
               reply(ErrorReply(@"plugin_unavailable", @"callkit plugin released", nil));
               return;
             }
             [strongSelf handleSetMirror:message reply:reply];
           }];
  [self addChannel:kSetupLocalRendererChannel
             codec:codec
           handler:^(id message, FlutterReply reply) {
             CallkitPlugin* strongSelf = weakSelf;
             if (strongSelf == nil) {
               reply(ErrorReply(@"plugin_unavailable", @"callkit plugin released", nil));
               return;
             }
             [strongSelf handleSetupLocalRenderer:message reply:reply];
           }];
  [self addChannel:kSetupRemoteRendererChannel
             codec:codec
           handler:^(id message, FlutterReply reply) {
             CallkitPlugin* strongSelf = weakSelf;
             if (strongSelf == nil) {
               reply(ErrorReply(@"plugin_unavailable", @"callkit plugin released", nil));
               return;
             }
             [strongSelf handleSetupRemoteRenderer:message reply:reply];
           }];
  [self addChannel:kDisposeRendererChannel
             codec:codec
           handler:^(id message, FlutterReply reply) {
             CallkitPlugin* strongSelf = weakSelf;
             if (strongSelf == nil) {
               reply(ErrorReply(@"plugin_unavailable", @"callkit plugin released", nil));
               return;
             }
             [strongSelf handleDisposeRenderer:message reply:reply];
           }];
}

- (void)handleApplicationWillTerminate:(NSNotification*)notification {
  (void)notification;
  [self teardownDesktopBridge];
}

- (void)teardownDesktopBridge {
  if (_didTeardownDesktopBridge) {
    return;
  }
  _didTeardownDesktopBridge = YES;

  [_macosVideoViewChannel setMethodCallHandler:nil];
  [_permissionChannel setMethodCallHandler:nil];
  for (FlutterBasicMessageChannel* channel in _channels) {
    [channel setMessageHandler:nil];
  }
  for (FlutterMethodChannel* channel in _platformViewChannels.objectEnumerator) {
    [channel setMethodCallHandler:nil];
  }

  GetBridgeApi().Destroy();
}

- (NSView*)createWithViewIdentifier:(int64_t)viewId arguments:(id _Nullable)args {
  (void)args;
  NSView* view = [[NSView alloc] initWithFrame:NSZeroRect];
  view.wantsLayer = YES;

  NSNumber* viewKey = @(viewId);
  _platformViews[viewKey] = view;
  _platformViewScalingModes[viewKey] = @0;

  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:
                                [NSString stringWithFormat:@"ne_call_kit/video_view_%lld",
                                                           viewId]
                                  binaryMessenger:[_registrar messenger]];
  __weak CallkitPlugin* weakSelf = self;
  [channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
    CallkitPlugin* strongSelf = weakSelf;
    if (strongSelf == nil) {
      result(@(-1));
      return;
    }
    [strongSelf handlePlatformViewMethodCall:call viewId:viewId result:result];
  }];
  _platformViewChannels[viewKey] = channel;
  return view;
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec {
  return [FlutterStandardMessageCodec sharedInstance];
}

- (void)handlePlatformViewMethodCall:(FlutterMethodCall*)call
                              viewId:(int64_t)viewId
                              result:(FlutterResult)result {
  NSDictionary* args =
      [call.arguments isKindOfClass:[NSDictionary class]] ? call.arguments : nil;
  if ([call.method isEqualToString:@"destroyVideoView"]) {
    [self destroyPlatformViewWithId:viewId];
    result(@YES);
    return;
  }
  if ([call.method isEqualToString:@"setDesktopScalingMode"]) {
    NSNumber* scalingMode =
        [args[@"scalingMode"] isKindOfClass:[NSNumber class]]
            ? args[@"scalingMode"]
            : nil;
    NSNumber* viewKey = @(viewId);
    const int32_t mode = scalingMode == nil ? 0 : scalingMode.intValue;
    _platformViewScalingModes[viewKey] = @(mode);
    if ([_localPlatformViewId isEqualToNumber:viewKey]) {
      result(@(GetBridgeApi().SetLocalVideoWindowScalingMode(mode)));
      return;
    }
    if ([_remotePlatformViewId isEqualToNumber:viewKey]) {
      result(@(GetBridgeApi().SetRemoteVideoWindowScalingMode(mode)));
      return;
    }
    result(@YES);
    return;
  }
  result(FlutterMethodNotImplemented);
}

- (AVMediaType)mediaTypeForPermission:(NSInteger)permissionType {
  switch (permissionType) {
    case 0:
      return AVMediaTypeVideo;
    case 1:
      return AVMediaTypeAudio;
    default:
      return nil;
  }
}

- (BOOL)hasPermission:(NSInteger)permissionType {
  AVMediaType mediaType = [self mediaTypeForPermission:permissionType];
  if (mediaType == nil) {
    return NO;
  }
  AVAuthorizationStatus status =
      [AVCaptureDevice authorizationStatusForMediaType:mediaType];
  return status == AVAuthorizationStatusAuthorized;
}

- (void)requestPermissionAtIndex:(NSUInteger)index
                     permissions:(NSArray<NSNumber*>*)permissions
                      completion:(void (^)(BOOL granted))completion {
  if (index >= permissions.count) {
    completion(YES);
    return;
  }

  NSInteger permissionType = permissions[index].integerValue;
  AVMediaType mediaType = [self mediaTypeForPermission:permissionType];
  if (mediaType == nil) {
    completion(NO);
    return;
  }

  AVAuthorizationStatus status =
      [AVCaptureDevice authorizationStatusForMediaType:mediaType];
  if (status == AVAuthorizationStatusAuthorized) {
    [self requestPermissionAtIndex:index + 1
                       permissions:permissions
                        completion:completion];
    return;
  }
  if (status == AVAuthorizationStatusDenied ||
      status == AVAuthorizationStatusRestricted) {
    completion(NO);
    return;
  }

  [AVCaptureDevice requestAccessForMediaType:mediaType
                           completionHandler:^(BOOL granted) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (!granted) {
        completion(NO);
        return;
      }
      [self requestPermissionAtIndex:index + 1
                         permissions:permissions
                          completion:completion];
    });
  }];
}

- (void)handleMacOSVideoViewMethodCall:(FlutterMethodCall*)call
                                result:(FlutterResult)result {
  NSDictionary* args =
      [call.arguments isKindOfClass:[NSDictionary class]] ? call.arguments : nil;
  NSNumber* viewId = [args[@"viewId"] isKindOfClass:[NSNumber class]] ? args[@"viewId"] : nil;

  if ([call.method isEqualToString:@"setupLocalView"]) {
    if (viewId == nil || viewId.longLongValue < 0) {
      const int32_t bridgeResult = GetBridgeApi().SetupLocalVideoWindow(nullptr);
      if (bridgeResult == 0) {
        _localPlatformViewId = nil;
      }
      result(@(bridgeResult));
      return;
    }

    NSView* view = _platformViews[viewId];
    if (view == nil) {
      result(@(-1));
      return;
    }

    const int32_t scalingMode = [_platformViewScalingModes[viewId] intValue];
    const int32_t bridgeResult =
        GetBridgeApi().SetupLocalVideoWindow((__bridge void*)view);
    if (bridgeResult == 0) {
      const int32_t modeResult =
          GetBridgeApi().SetLocalVideoWindowScalingMode(scalingMode);
      if (modeResult != 0) {
        result(@(modeResult));
        return;
      }
      _localPlatformViewId = viewId;
    }
    result(@(bridgeResult));
    return;
  }

  if ([call.method isEqualToString:@"setupRemoteView"]) {
    if (viewId == nil || viewId.longLongValue < 0) {
      const int32_t bridgeResult = GetBridgeApi().SetupRemoteVideoWindow(nullptr);
      if (bridgeResult == 0) {
        _remotePlatformViewId = nil;
      }
      result(@(bridgeResult));
      return;
    }

    NSView* view = _platformViews[viewId];
    if (view == nil) {
      result(@(-1));
      return;
    }

    const int32_t scalingMode = [_platformViewScalingModes[viewId] intValue];
    const int32_t bridgeResult =
        GetBridgeApi().SetupRemoteVideoWindow((__bridge void*)view);
    if (bridgeResult == 0) {
      const int32_t modeResult =
          GetBridgeApi().SetRemoteVideoWindowScalingMode(scalingMode);
      if (modeResult != 0) {
        result(@(modeResult));
        return;
      }
      _remotePlatformViewId = viewId;
    }
    result(@(bridgeResult));
    return;
  }

  result(FlutterMethodNotImplemented);
}

- (void)handlePermissionMethodCall:(FlutterMethodCall*)call
                            result:(FlutterResult)result {
  NSDictionary* args =
      [call.arguments isKindOfClass:[NSDictionary class]] ? call.arguments : nil;
  NSArray<NSNumber*>* permissions =
      [args[@"permission"] isKindOfClass:[NSArray class]] ? args[@"permission"] : nil;

  if ([call.method isEqualToString:@"hasPermissions"]) {
    if (permissions == nil) {
      result(@(NO));
      return;
    }
    BOOL granted = YES;
    for (NSNumber* permission in permissions) {
      if (![self hasPermission:permission.integerValue]) {
        granted = NO;
        break;
      }
    }
    result(@(granted));
    return;
  }

  if ([call.method isEqualToString:@"requestPermissions"]) {
    if (permissions == nil || permissions.count == 0) {
      result(@(1));
      return;
    }
    [self requestPermissionAtIndex:0
                       permissions:permissions
                        completion:^(BOOL granted) {
      result(@(granted ? 0 : 1));
    }];
    return;
  }

  if ([call.method isEqualToString:@"startToPermissionSetting"]) {
    NSURL* url = [NSURL URLWithString:
        @"x-apple.systempreferences:com.apple.preference.security?Privacy"];
    BOOL opened = NO;
    if (url != nil) {
      opened = [[NSWorkspace sharedWorkspace] openURL:url];
    }
    result(@(opened));
    return;
  }

  result(FlutterMethodNotImplemented);
}

- (void)destroyPlatformViewWithId:(int64_t)viewId {
  NSNumber* viewKey = @(viewId);
  if ([_localPlatformViewId isEqualToNumber:viewKey]) {
    GetBridgeApi().SetupLocalVideoWindow(nullptr);
    _localPlatformViewId = nil;
  }
  if ([_remotePlatformViewId isEqualToNumber:viewKey]) {
    GetBridgeApi().SetupRemoteVideoWindow(nullptr);
    _remotePlatformViewId = nil;
  }

  FlutterMethodChannel* channel = _platformViewChannels[viewKey];
  [channel setMethodCallHandler:nil];
  [_platformViewChannels removeObjectForKey:viewKey];
  [_platformViewScalingModes removeObjectForKey:viewKey];

  NSView* view = _platformViews[viewKey];
  [view removeFromSuperview];
  [_platformViews removeObjectForKey:viewKey];
}

- (void)addChannel:(const char*)name
             codec:(FlutterStandardMessageCodec*)codec
           handler:(FlutterMessageHandler)handler {
  FlutterBasicMessageChannel* channel =
      [FlutterBasicMessageChannel
          messageChannelWithName:[NSString stringWithUTF8String:name]
                                        binaryMessenger:[_registrar messenger]
                                                  codec:codec];
  [channel setMessageHandler:handler];
  [_channels addObject:channel];
}

- (void)handleCreateRendererWithReply:(FlutterReply)reply {
  if (GetBridgeApi().EnsureHandle() == nullptr) {
    reply(ErrorReply(@"bridge_unavailable", @"desktop bridge unavailable", nil));
    return;
  }

  auto* renderer =
      [[NECallkitDesktopRenderer alloc] initWithRegistrar:_registrar];
  NECallBridgeVideoRendererParam param{};
  param.renderer_id = renderer.textureId;
  param.on_frame = DesktopRendererFrameCallback;
  param.user_data = (__bridge void*)renderer;
  const int32_t result = GetBridgeApi().RegisterVideoRenderer(param);
  if (result != 0) {
    [renderer dispose];
    reply(ErrorReply(@"bridge_register_failed",
                     @"failed to register desktop renderer",
                     @(result)));
    return;
  }

  _renderers[@(renderer.textureId)] = renderer;
  reply(SuccessReply(@(renderer.textureId)));
}

- (void)handleSetMirror:(id)message reply:(FlutterReply)reply {
  NSArray* args = [message isKindOfClass:[NSArray class]] ? message : nil;
  if (args.count < 2) {
    reply(ErrorReply(@"invalid_args", @"invalid mirror arguments", nil));
    return;
  }
  const int64_t texture_id = [args[0] longLongValue];
  const BOOL mirror = [args[1] boolValue];
  const int32_t result = GetBridgeApi().SetVideoRendererMirror(texture_id, mirror);
  reply(SuccessReply(@(result)));
}

- (void)handleSetupLocalRenderer:(id)message reply:(FlutterReply)reply {
  NSArray* args = [message isKindOfClass:[NSArray class]] ? message : nil;
  if (args.count < 1) {
    reply(ErrorReply(@"invalid_args", @"invalid local renderer arguments", nil));
    return;
  }
  const int64_t texture_id = [args[0] longLongValue];
  const int32_t result = GetBridgeApi().SetupLocalVideoRenderer(texture_id);
  reply(SuccessReply(@(result)));
}

- (void)handleSetupRemoteRenderer:(id)message reply:(FlutterReply)reply {
  NSArray* args = [message isKindOfClass:[NSArray class]] ? message : nil;
  if (args.count < 2) {
    reply(ErrorReply(@"invalid_args", @"invalid remote renderer arguments", nil));
    return;
  }
  const int64_t uid = [args[0] longLongValue];
  const int64_t texture_id = [args[1] longLongValue];
  const int32_t result = GetBridgeApi().SetupRemoteVideoRenderer(uid, texture_id);
  reply(SuccessReply(@(result)));
}

- (void)handleDisposeRenderer:(id)message reply:(FlutterReply)reply {
  NSArray* args = [message isKindOfClass:[NSArray class]] ? message : nil;
  if (args.count < 1) {
    reply(ErrorReply(@"invalid_args", @"invalid dispose arguments", nil));
    return;
  }
  NSNumber* texture_key = @([args[0] longLongValue]);
  auto* renderer = _renderers[texture_key];
  if (renderer != nil) {
    [renderer dispose];
    [_renderers removeObjectForKey:texture_key];
  } else {
    GetBridgeApi().UnregisterVideoRenderer([texture_key longLongValue]);
  }
  reply(SuccessReply(nil));
}

@end
