// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// HawkEntryPointGenerator
// **************************************************************************

import 'package:netease_callkit/src/debug/debug_service.dart';

class HawkDebugService {
  static Future<dynamic> handleHawkMethodCall(
      Object? obj,
      String method,
      List<Map> params,
      Map<Type, Future<dynamic> Function(Map)> factory) async {
    // ignore: unused_element
    T enumValueFromNameOrIndex<T extends Enum>(
        Iterable<T> values, dynamic value) {
      for (var e in values) {
        if (e.name == value || e.index == value) return e;
      }
      throw ArgumentError.value(value, T.toString(), "No enum with that value");
    }

    final target = obj as DebugService?;
    switch (method) {
      ///  {
      ///    "className": "DebugService",
      ///    "methodName": "debugLogin",
      ///    "params": [
      ///      {
      ///        "appKey": "String"
      ///      },
      ///      {
      ///        "accountId": "String"
      ///      },
      ///      {
      ///        "token": "String"
      ///      }
      ///    ]
      ///  }
      case 'debugLogin':
        {
          var argAppKey;
          argAppKey = (params[0]['appKey'] ??
                  (params[0].length == 1 ? params[0].values.first : null))
              as String;
          var argAccountId;
          argAccountId = (params[1]['accountId'] ??
                  (params[1].length == 1 ? params[1].values.first : null))
              as String;
          var argToken;
          argToken = (params[2]['token'] ??
                  (params[2].length == 1 ? params[2].values.first : null))
              as String;
          return [
            target!.debugLogin(
              argAppKey,
              argAccountId,
              argToken,
            )
          ];
        }

      ///  {
      ///    "className": "DebugService",
      ///    "methodName": "debugLogout",
      ///    "params": []
      ///  }
      case 'debugLogout':
        {
          return [target!.debugLogout()];
        }
    }
    return null;
  }
}
