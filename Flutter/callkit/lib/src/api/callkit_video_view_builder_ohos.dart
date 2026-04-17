import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget buildOhosCallkitVideoView({
  required String viewType,
  required PlatformViewCreatedCallback onPlatformViewCreated,
  required PlatformViewHitTestBehavior hitTestBehavior,
  required Map<String, dynamic> creationParams,
  required MessageCodec<dynamic> creationParamsCodec,
  Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
}) {
  return OhosView(
    viewType: viewType,
    onPlatformViewCreated: onPlatformViewCreated,
    hitTestBehavior: hitTestBehavior,
    creationParams: creationParams,
    creationParamsCodec: creationParamsCodec,
    gestureRecognizers: gestureRecognizers,
  );
}
