// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:netease_callkit/netease_callkit.dart';

class HawkNECallEngineEx {
  static Future<dynamic> handleHawkMethodCall(
      Object? obj,
      String method,
      List<Map> params,
      Map<Type, Future<dynamic> Function(Map)> factory) async {
    if (method == 'addCallDelegateEx') {
      final callbackParam = params[0]['callback'] as Map?;

      final stream = StreamController<Map>();
      final data = {};
      void notifyData(String key, List<dynamic> value) {
        if (callbackParam != null &&
            callbackParam.isNotEmpty &&
            !callbackParam.containsKey(key)) {
          return;
        }
        data[key] = value.length == 1
            ? value.single
            : value.fold<Map>(<String, dynamic>{}, (map, element) {
                map['arg${map.length}'] = element;
                return map;
              });
        stream.add(data);
      }

      final callback = NECallEngineDelegate(
        onReceiveInvited: (NEInviteInfo info) =>
            notifyData('onReceiveInvited', [info]),
        onCallEnd: (NECallEndInfo info) => notifyData('onCallEnd', [info]),
        onCallConnected: (NECallInfo info) =>
            notifyData('onCallConnected', [info]),
        onLCKAccept: (NELCKAcceptResult result) =>
            notifyData('onLCKAccept', [result]),
        onLCKHangup: (NELCKHangupResult result) =>
            notifyData('onLCKHangup', [result]),
        onCallTypeChange: (NECallTypeChangeInfo info) =>
            notifyData('onCallTypeChange', [info]),
        onVideoAvailable: (bool available, String userID) =>
            notifyData('onVideoAvailable', [available, userID]),
        onVideoMuted: (bool muted, String userID) =>
            notifyData('onVideoMuted', [muted, userID]),
        onAudioMuted: (bool muted, String userID) =>
            notifyData('onAudioMuted', [muted, userID]),
        onLocalAudioMuted: (bool muted) =>
            notifyData('onLocalAudioMuted', [muted]),
        onRtcInitEnd: () => notifyData('onRtcInitEnd', []),
        onNERtcEngineVirtualBackgroundSourceEnabled:
            (bool enabled, int reason) => notifyData(
                'onNERtcEngineVirtualBackgroundSourceEnabled',
                [enabled, reason]),
      );

      stream.onCancel = () {
        stream.close();
        (obj as NECallEngine).removeCallDelegate(callback);
      };
      (obj as NECallEngine).addCallDelegate(callback);
      return [stream.stream];
    }
  }
}
