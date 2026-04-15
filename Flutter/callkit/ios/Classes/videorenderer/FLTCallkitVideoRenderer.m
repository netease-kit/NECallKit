// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "FLTCallkitVideoRenderer.h"
#import <NEDyldYuv/Libyuv.h>

@interface FLTCallkitVideoRenderer () <FlutterStreamHandler>
@property(nonatomic, weak) id<FlutterTextureRegistry> registry;
@property(nonatomic, strong) FlutterEventSink eventSink;
@end

@implementation FLTCallkitVideoRenderer {
  CVPixelBufferRef _pixelBufferRef;
  CGSize _frameSize;
  CGSize _renderSize;
  NERtcVideoRotationType _rotation;
  FlutterEventChannel *_eventChannel;
  bool _isFirstFrameRendered;
  bool _mirror;
}

@synthesize textureId = _textureId;

- (instancetype)initWithTextureRegistry:(id<FlutterTextureRegistry>)registry
                              messenger:(NSObject<FlutterBinaryMessenger> *)messenger {
  self = [super init];
  if (self) {
    _isFirstFrameRendered = false;
    _registry = registry;
    _pixelBufferRef = nil;
    _eventSink = nil;
    _rotation = kNERtcVideoRotation_0;
    _frameSize = CGSizeZero;
    _renderSize = CGSizeZero;
    _mirror = false;
    _textureId = [registry registerTexture:self];
    _eventChannel = [FlutterEventChannel
        eventChannelWithName:[NSString
                                 stringWithFormat:@"NECallkitRenderer/Texture%lld", _textureId]
             binaryMessenger:messenger];
    [_eventChannel setStreamHandler:self];
  }
  return self;
}

- (void)dealloc {
  if (_pixelBufferRef) {
    CVBufferRelease(_pixelBufferRef);
  }
}

- (CVPixelBufferRef)copyPixelBuffer {
  if (_pixelBufferRef != nil) {
    CVBufferRetain(_pixelBufferRef);
    return _pixelBufferRef;
  }
  return nil;
}

- (void)dispose {
  [_registry unregisterTexture:_textureId];
}

- (void)setMirror:(BOOL)mirror {
  _mirror = mirror;
}

- (void)copyI420BufferToCVPixelBuffer:(CVPixelBufferRef)pixelBuffer
                       withI420Buffer:(void *)i420Buffer
                          bufferWidth:(int)width
                         bufferHeight:(int)height
                        frameRotation:(int)rotation {
  CVPixelBufferLockBaseAddress(pixelBuffer, 0);

  const OSType pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
  uint8_t *dst = CVPixelBufferGetBaseAddress(pixelBuffer);
  size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);

  if (pixelFormat == kCVPixelFormatType_32BGRA) {
    // Corresponds to libyuv::FOURCC_ARGB
    ConvertToARGB(
        (const uint8_t *)i420Buffer, 0, dst, (int)bytesPerRow, 0, 0, width,
        _mirror ? -height : height, width, height,
        (RotationModeEnum)(_mirror ? (rotation + (rotation == 90 ? 0 : 180)) % 360 : rotation),
        FOURCC_I420);
  }

  CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
}

#pragma mark - NERtcEngineVideoRenderSink

- (void)onNERtcEngineRenderFrame:(NERtcVideoFrame *_Nonnull)frame {
  // Current supported I420
  if (frame.format != kNERtcVideoFormatI420) return;

  CGSize current_size = (frame.rotation % 180 == 0) ? CGSizeMake(frame.width, frame.height)
                                                    : CGSizeMake(frame.height, frame.width);

  if (!CGSizeEqualToSize(_frameSize, current_size)) {
    [self setSize:current_size];
  }

  [self copyI420BufferToCVPixelBuffer:_pixelBufferRef
                       withI420Buffer:frame.buffer
                          bufferWidth:frame.width
                         bufferHeight:frame.height
                        frameRotation:(int)frame.rotation];

  __weak FLTCallkitVideoRenderer *weakSelf = self;
  if (_renderSize.width != frame.width || _renderSize.height != frame.height ||
      _rotation != frame.rotation) {
    dispatch_async(dispatch_get_main_queue(), ^{
      FLTCallkitVideoRenderer *strongSelf = weakSelf;
      if (strongSelf.eventSink) {
        strongSelf.eventSink(@{
          @"event" : @"onFrameResolutionChanged",
          @"id" : @(strongSelf.textureId),
          @"width" : @(frame.width),
          @"height" : @(frame.height),
          @"rotation" : @(frame.rotation)
        });
      }
    });
    _renderSize = CGSizeMake(frame.width, frame.height);
    _rotation = frame.rotation;
  }

  dispatch_async(dispatch_get_main_queue(), ^{
    FLTCallkitVideoRenderer *strongSelf = weakSelf;
    [strongSelf.registry textureFrameAvailable:strongSelf.textureId];
    if (!strongSelf->_isFirstFrameRendered) {
      if (strongSelf.eventSink) {
        strongSelf.eventSink(@{@"event" : @"onFirstFrameRendered"});
        strongSelf->_isFirstFrameRendered = true;
      }
    }
  });
}

- (void)setSize:(CGSize)size {
  if (_pixelBufferRef == nil ||
      (size.width != _frameSize.width || size.height != _frameSize.height)) {
    if (_pixelBufferRef) {
      CVBufferRelease(_pixelBufferRef);
    }
    NSDictionary *pixelAttributes = @{(id)kCVPixelBufferIOSurfacePropertiesKey : @{}};
    CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32BGRA,
                        (__bridge CFDictionaryRef)(pixelAttributes), &_pixelBufferRef);

    _frameSize = size;
  }
}

#pragma mark - FlutterStreamHandler

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
  _eventSink = nil;
  return nil;
}

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)sink {
  _eventSink = sink;
  return nil;
}

@end
