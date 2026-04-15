// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

library netease_callkit;

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:hawk_meta/hawk_meta.dart';
import 'package:netease_common/netease_common.dart';
import 'netease_callkit.dart';
import 'src/impl/callkit_impl.dart';
import 'src/impl/group_callkit_impl.dart';

// Re-export pigeon classes for public API (needed by group_callkit_impl and external consumers)
export 'src/impl/pigeon.dart' hide SimpleResponse;

// Export models
export 'src/api/models.dart';

// Video Renderer exports (Texture-based)
part 'src/video_renderer/ne_callkit_video_renderer.dart';
part 'src/video_renderer/ne_callkit_video_renderer_impl.dart';
part 'src/video_renderer/ne_callkit_video_renderer_controller.dart';
part 'src/video_view/ne_callkit_texture_view.dart';

part 'src/api/call_engine.dart';
part 'src/api/constants.dart';
part 'src/api/callkit_video_view.dart';

// Group Call API exports
part 'src/api/group_models.dart';
part 'src/api/group_constants.dart';
part 'src/api/group_call_delegate.dart';
part 'src/api/group_media_delegate.dart';
part 'src/api/group_call_engine.dart';
