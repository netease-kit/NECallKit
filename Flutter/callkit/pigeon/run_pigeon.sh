# Copyright (c) 2022 NetEase, Inc. All rights reserved.
# Use of this source code is governed by a MIT license that can be
# found in the LICENSE file.

# Please run this script under `roomkit_platform_interface`
# directory to generate the pigeon code

dart  run pigeon \
  --input pigeon/messages.dart \
  --dart_out lib/src/impl/pigeon.dart \
  --objc_header_out ios/Classes/pigeon/Pigeon.h \
  --objc_source_out ios/Classes/pigeon/Pigeon.m \
  --objc_prefix FLT \
  --java_out android/src/main/kotlin/com/netease/yunxin/flutter/plugins/callkit/pigeon/Pigeon.java \
  --java_package "com.netease.yunxin.flutter.plugins.callkit.pigeon"