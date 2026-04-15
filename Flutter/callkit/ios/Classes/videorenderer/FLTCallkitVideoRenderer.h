// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <NERtcSDK/NERtcSDK.h>

NS_ASSUME_NONNULL_BEGIN

/// 基于 Flutter Texture 的视频渲染器
///
/// 实现 FlutterTexture 和 NERtcEngineVideoRenderSink 协议
@interface FLTCallkitVideoRenderer : NSObject <FlutterTexture, NERtcEngineVideoRenderSink, FlutterStreamHandler>

@property(nonatomic, readonly) int64_t textureId;

- (instancetype)initWithTextureRegistry:(id<FlutterTextureRegistry>)registry
                              messenger:(NSObject<FlutterBinaryMessenger> *)messenger;
- (void)dispose;
- (void)setMirror:(BOOL)mirror;

@end

NS_ASSUME_NONNULL_END
