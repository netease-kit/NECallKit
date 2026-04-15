// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// HawkEntryPointGenerator
// **************************************************************************

import 'package:callkit_example/auth/auth_manager.dart';
import 'package:callkit_example/auth/login_info.dart';
import 'package:netease_callkit/netease_callkit.dart';

class HawkNECallEngine {
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

    final target = obj as NECallEngine?;
    switch (method) {
      case 'login':
        {
          var info = ((await factory[LoginInfo]?.call(params[0]['info'])) ??
                  LoginInfo.fromJson((params[0]['info'] as Map).cast()))
              as LoginInfo;
          return [AuthManager().loginByInfo(info)];
        }
      case 'logout':
        {
          return [AuthManager().logout()];
        }
      case 'setup':
        {
          var argConfig;
          var configParam = (params[0]['config'] ??
              (params[0].length == 1 ? params[0].values.first : null));
          argConfig = ((await factory[NESetupConfig]?.call(configParam)) ??
                  NESetupConfig.fromJson((configParam as Map).cast()))
              as NESetupConfig;
          return [
            target!.setup(
              argConfig,
            )
          ];
        }

      ///  {
      ///    "className": "NECallEngine",
      ///    "methodName": "getVersion",
      ///    "params": []
      ///  }
      case 'getVersion':
        {
          return [target!.getVersion()];
        }

      ///  {
      ///    "className": "NECallEngine",
      ///    "methodName": "call",
      ///    "params": [
      ///      {
      ///        "accId": "String"
      ///      },
      ///      {
      ///        "callType": "NECallType"
      ///      },
      ///      {
      ///        "extraInfo": "String?",
      ///        "rtcChannelName": "String?",
      ///        "globalExtraCopy": "String?",
      ///        "pushConfig": "NECallPushConfig?"
      ///      }
      ///    ]
      ///  }
      case 'call':
        {
          var argAccId;
          argAccId = (params[0]['accId'] ??
                  (params[0].length == 1 ? params[0].values.first : null))
              as String;
          var argCallType;
          argCallType = enumValueFromNameOrIndex(
              NECallType.values,
              (params[1]['callType'] ??
                  (params[1].length == 1 ? params[1].values.first : null)));
          final namedParamsMap =
              params.length > 2 ? params[2] : <String, dynamic>{};
          var argExtraInfo;
          if (namedParamsMap.containsKey('extraInfo')) {
            argExtraInfo = namedParamsMap['extraInfo'] as String?;
          } else {
            argExtraInfo = null;
          }
          var argRtcChannelName;
          if (namedParamsMap.containsKey('rtcChannelName')) {
            argRtcChannelName = namedParamsMap['rtcChannelName'] as String?;
          } else {
            argRtcChannelName = null;
          }
          var argGlobalExtraCopy;
          if (namedParamsMap.containsKey('globalExtraCopy')) {
            argGlobalExtraCopy = namedParamsMap['globalExtraCopy'] as String?;
          } else {
            argGlobalExtraCopy = null;
          }
          var argPushConfig;
          if (namedParamsMap.containsKey('pushConfig')) {
            var pushConfigParam = namedParamsMap['pushConfig'];
            argPushConfig = ((await factory[NECallPushConfig]
                    ?.call(pushConfigParam)) ??
                (pushConfigParam != null
                    ? NECallPushConfig.fromJson((pushConfigParam as Map).cast())
                    : null)) as NECallPushConfig?;
          } else {
            argPushConfig = null;
          }

          return [
            await target!.call(
              argAccId,
              argCallType,
              extraInfo: argExtraInfo,
              rtcChannelName: argRtcChannelName,
              globalExtraCopy: argGlobalExtraCopy,
              pushConfig: argPushConfig,
            )
          ];
        }

      ///  {
      ///    "className": "NECallEngine",
      ///    "methodName": "accept",
      ///    "params": []
      ///  }
      case 'accept':
        {
          return [target!.accept()];
        }

      ///  {
      ///    "className": "NECallEngine",
      ///    "methodName": "hangup",
      ///    "params": [
      ///      {
      ///        "channelId": "String"
      ///      },
      ///      {
      ///        "extraString": "String?"
      ///      }
      ///    ]
      ///  }
      case 'hangup':
        {
          var argChannelId;
          argChannelId = (params[0]['channelId'] ??
                  (params[0].length == 1 ? params[0].values.first : null))
              as String;
          final namedParamsMap =
              params.length > 1 ? params[1] : <String, dynamic>{};
          var argExtraString;
          if (namedParamsMap.containsKey('extraString')) {
            argExtraString = namedParamsMap['extraString'] as String?;
          } else {
            argExtraString = null;
          }
          return [
            target!.hangup(
              channelId: argChannelId,
              extraString: argExtraString,
            )
          ];
        }

      ///  {
      ///    "className": "NECallEngine",
      ///    "methodName": "switchCallType",
      ///    "params": [
      ///      {
      ///        "callType": "NECallType"
      ///      },
      ///      {
      ///        "state": "NECallSwitchState"
      ///      }
      ///    ]
      ///  }
      case 'switchCallType':
        {
          var argCallType;
          argCallType = enumValueFromNameOrIndex(
              NECallType.values,
              (params[0]['callType'] ??
                  (params[0].length == 1 ? params[0].values.first : null)));
          var argState;
          argState = enumValueFromNameOrIndex(
              NECallSwitchState.values,
              (params[1]['state'] ??
                  (params[1].length == 1 ? params[1].values.first : null)));
          return [
            target!.switchCallType(
              argCallType,
              argState,
            )
          ];
        }

      ///  {
      ///    "className": "NECallEngine",
      ///    "methodName": "setTimeout",
      ///    "params": [
      ///      {
      ///        "time": "int"
      ///      }
      ///    ]
      ///  }
      case 'setTimeout':
        {
          var argTime;
          argTime = (params[0]['time'] ??
              (params[0].length == 1 ? params[0].values.first : null)) as int;
          return [
            target!.setTimeout(
              argTime,
            )
          ];
        }

      ///  {
      ///    "className": "NECallEngine",
      ///    "methodName": "setupLocalView",
      ///    "params": [
      ///      {
      ///        "viewId": "int"
      ///      }
      ///    ]
      ///  }
      case 'setupLocalView':
        {
          var argViewId;
          argViewId = (params[0]['viewId'] ??
              (params[0].length == 1 ? params[0].values.first : null)) as int;
          return [
            target!.setupLocalView(
              argViewId,
            )
          ];
        }

      ///  {
      ///    "className": "NECallEngine",
      ///    "methodName": "setupRemoteView",
      ///    "params": [
      ///      {
      ///        "viewId": "int"
      ///      }
      ///    ]
      ///  }
      case 'setupRemoteView':
        {
          var argViewId;
          argViewId = (params[0]['viewId'] ??
              (params[0].length == 1 ? params[0].values.first : null)) as int;
          return [
            target!.setupRemoteView(
              argViewId,
            )
          ];
        }

      ///  {
      ///    "className": "NECallEngine",
      ///    "methodName": "enableLocalVideo",
      ///    "params": [
      ///      {
      ///        "enable": "bool"
      ///      }
      ///    ]
      ///  }
      case 'enableLocalVideo':
        {
          var argEnable;
          argEnable = (params[0]['enable'] ??
              (params[0].length == 1 ? params[0].values.first : null)) as bool;
          return [
            target!.enableLocalVideo(
              argEnable,
            )
          ];
        }

      ///  {
      ///    "className": "NECallEngine",
      ///    "methodName": "muteLocalVideo",
      ///    "params": [
      ///      {
      ///        "muted": "bool"
      ///      }
      ///    ]
      ///  }
      case 'muteLocalVideo':
        {
          var argMuted;
          argMuted = (params[0]['muted'] ??
              (params[0].length == 1 ? params[0].values.first : null)) as bool;
          return [
            target!.muteLocalVideo(
              argMuted,
            )
          ];
        }

      ///  {
      ///    "className": "NECallEngine",
      ///    "methodName": "muteLocalAudio",
      ///    "params": [
      ///      {
      ///        "muted": "bool"
      ///      }
      ///    ]
      ///  }
      case 'muteLocalAudio':
        {
          var argMuted;
          argMuted = (params[0]['muted'] ??
              (params[0].length == 1 ? params[0].values.first : null)) as bool;
          return [
            target!.muteLocalAudio(
              argMuted,
            )
          ];
        }

      ///  {
      ///    "className": "NECallEngine",
      ///    "methodName": "isSpeakerphoneOn",
      ///    "params": []
      ///  }
      case 'isSpeakerphoneOn':
        {
          return [target!.isSpeakerphoneOn()];
        }

      ///  {
      ///    "className": "NECallEngine",
      ///    "methodName": "setSpeakerphoneOn",
      ///    "params": [
      ///      {
      ///        "enable": "bool"
      ///      }
      ///    ]
      ///  }
      case 'setSpeakerphoneOn':
        {
          var argEnable;
          argEnable = (params[0]['enable'] ??
              (params[0].length == 1 ? params[0].values.first : null)) as bool;
          return [
            target!.setSpeakerphoneOn(
              argEnable,
            )
          ];
        }

      ///  {
      ///    "className": "NECallEngine",
      ///    "methodName": "switchCamera",
      ///    "params": []
      ///  }
      case 'switchCamera':
        {
          return [target!.switchCamera()];
        }

      ///  {
      ///    "className": "NECallEngine",
      ///    "methodName": "setCallConfig",
      ///    "params": [
      ///      {
      ///        "enableOffline": "bool",
      ///        "enableSwitchVideoConfirm": "bool",
      ///        "enableSwitchAudioConfirm": "bool"
      ///      }
      ///    ]
      ///  }
      case 'setCallConfig':
        {
          final namedParamsMap =
              params.length > 0 ? params[0] : <String, dynamic>{};
          var argEnableOffline;
          if (namedParamsMap.containsKey('enableOffline')) {
            argEnableOffline = namedParamsMap['enableOffline'] as bool;
          } else {
            argEnableOffline = true;
          }
          var argEnableSwitchVideoConfirm;
          if (namedParamsMap.containsKey('enableSwitchVideoConfirm')) {
            argEnableSwitchVideoConfirm =
                namedParamsMap['enableSwitchVideoConfirm'] as bool;
          } else {
            argEnableSwitchVideoConfirm = false;
          }
          var argEnableSwitchAudioConfirm;
          if (namedParamsMap.containsKey('enableSwitchAudioConfirm')) {
            argEnableSwitchAudioConfirm =
                namedParamsMap['enableSwitchAudioConfirm'] as bool;
          } else {
            argEnableSwitchAudioConfirm = false;
          }
          return [
            target!.setCallConfig(
              enableOffline: argEnableOffline,
              enableSwitchVideoConfirm: argEnableSwitchVideoConfirm,
              enableSwitchAudioConfirm: argEnableSwitchAudioConfirm,
            )
          ];
        }

      ///  {
      ///    "className": "NECallEngine",
      ///    "methodName": "addCallDelegate",
      ///    "params": [
      ///      {
      ///        "delegate": "NECallEngineDelegate"
      ///      }
      ///    ]
      ///  }
      case 'addCallDelegate':
        {
          var argDelegate;
          argDelegate = (await factory[NECallEngineDelegate]?.call((params[0]
                      ['delegate'] ??
                  (params[0].length == 1 ? params[0].values.first : null))))
              as NECallEngineDelegate;
          return [
            target!.addCallDelegate(
              argDelegate,
            )
          ];
        }

      ///  {
      ///    "className": "NECallEngine",
      ///    "methodName": "removeCallDelegate",
      ///    "params": [
      ///      {
      ///        "delegate": "NECallEngineDelegate"
      ///      }
      ///    ]
      ///  }
      case 'removeCallDelegate':
        {
          var argDelegate;
          argDelegate = (await factory[NECallEngineDelegate]?.call((params[0]
                      ['delegate'] ??
                  (params[0].length == 1 ? params[0].values.first : null))))
              as NECallEngineDelegate;
          return [
            target!.removeCallDelegate(
              argDelegate,
            )
          ];
        }

      ///  {
      ///    "className": "NECallEngine",
      ///    "methodName": "getCallInfo",
      ///    "params": []
      ///  }
      case 'getCallInfo':
        {
          return [target!.getCallInfo()];
        }

      ///  {
      ///    "className": "NECallEngine",
      ///    "methodName": "getCallConfig",
      ///    "params": []
      ///  }
      case 'getCallConfig':
        {
          return [target!.getCallConfig()];
        }

      ///  {
      ///    "className": "NECallEngine",
      ///    "methodName": "destroy",
      ///    "params": []
      ///  }
      case 'destroy':
        {
          return [target!.destroy()];
        }

      ///  {
      ///    "className": "NECallEngine",
      ///    "methodName": "getInstance",
      ///    "params": []
      ///  }
      case 'getInstance':
        {
          return [NECallEngine.instance];
        }
    }
    return null;
  }
}

class HawkNEGroupCallEngine {
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

    final target = obj as NEGroupCallEngine?;
    switch (method) {
      ///  {
      ///    "className": "NEGroupCallEngine",
      ///    "methodName": "init",
      ///    "params": [
      ///      {
      ///        "config": "NEGroupConfigParam"
      ///      }
      ///    ]
      ///  }
      case 'init':
        {
          var argConfig;
          argConfig = (await factory[NEGroupConfigParam]?.call((params[0]
                      ['config'] ??
                  (params[0].length == 1 ? params[0].values.first : null))))
              as NEGroupConfigParam;
          return [
            target!.init(
              argConfig,
            )
          ];
        }

      ///  {
      ///    "className": "NEGroupCallEngine",
      ///    "methodName": "release",
      ///    "params": []
      ///  }
      case 'release':
        {
          return [target!.release()];
        }

      ///  {
      ///    "className": "NEGroupCallEngine",
      ///    "methodName": "groupCall",
      ///    "params": [
      ///      {
      ///        "param": "NEGroupCallParam"
      ///      }
      ///    ]
      ///  }
      case 'groupCall':
        {
          var argParam;
          argParam = (await factory[NEGroupCallParam]?.call((params[0]
                      ['param'] ??
                  (params[0].length == 1 ? params[0].values.first : null))))
              as NEGroupCallParam;
          return [
            target!.groupCall(
              argParam,
            )
          ];
        }

      ///  {
      ///    "className": "NEGroupCallEngine",
      ///    "methodName": "groupAccept",
      ///    "params": [
      ///      {
      ///        "param": "NEGroupAcceptParam"
      ///      }
      ///    ]
      ///  }
      case 'groupAccept':
        {
          var argParam;
          argParam = (await factory[NEGroupAcceptParam]?.call((params[0]
                      ['param'] ??
                  (params[0].length == 1 ? params[0].values.first : null))))
              as NEGroupAcceptParam;
          return [
            target!.groupAccept(
              argParam,
            )
          ];
        }

      ///  {
      ///    "className": "NEGroupCallEngine",
      ///    "methodName": "groupHangup",
      ///    "params": [
      ///      {
      ///        "param": "NEGroupHangupParam"
      ///      }
      ///    ]
      ///  }
      case 'groupHangup':
        {
          var argParam;
          argParam = (await factory[NEGroupHangupParam]?.call((params[0]
                      ['param'] ??
                  (params[0].length == 1 ? params[0].values.first : null))))
              as NEGroupHangupParam;
          return [
            target!.groupHangup(
              argParam,
            )
          ];
        }

      ///  {
      ///    "className": "NEGroupCallEngine",
      ///    "methodName": "groupInvite",
      ///    "params": [
      ///      {
      ///        "param": "NEGroupInviteParam"
      ///      }
      ///    ]
      ///  }
      case 'groupInvite':
        {
          var argParam;
          argParam = (await factory[NEGroupInviteParam]?.call((params[0]
                      ['param'] ??
                  (params[0].length == 1 ? params[0].values.first : null))))
              as NEGroupInviteParam;
          return [
            target!.groupInvite(
              argParam,
            )
          ];
        }

      ///  {
      ///    "className": "NEGroupCallEngine",
      ///    "methodName": "groupJoin",
      ///    "params": [
      ///      {
      ///        "param": "NEGroupJoinParam"
      ///      }
      ///    ]
      ///  }
      case 'groupJoin':
        {
          var argParam;
          argParam = (await factory[NEGroupJoinParam]?.call((params[0]
                      ['param'] ??
                  (params[0].length == 1 ? params[0].values.first : null))))
              as NEGroupJoinParam;
          return [
            target!.groupJoin(
              argParam,
            )
          ];
        }

      ///  {
      ///    "className": "NEGroupCallEngine",
      ///    "methodName": "groupQueryCallInfo",
      ///    "params": [
      ///      {
      ///        "callId": "String"
      ///      }
      ///    ]
      ///  }
      case 'groupQueryCallInfo':
        {
          var argCallId;
          argCallId = (params[0]['callId'] ??
                  (params[0].length == 1 ? params[0].values.first : null))
              as String;
          return [
            target!.groupQueryCallInfo(
              argCallId,
            )
          ];
        }

      ///  {
      ///    "className": "NEGroupCallEngine",
      ///    "methodName": "groupQueryMembers",
      ///    "params": [
      ///      {
      ///        "callId": "String"
      ///      }
      ///    ]
      ///  }
      case 'groupQueryMembers':
        {
          var argCallId;
          argCallId = (params[0]['callId'] ??
                  (params[0].length == 1 ? params[0].values.first : null))
              as String;
          return [
            target!.groupQueryMembers(
              argCallId,
            )
          ];
        }

      ///  {
      ///    "className": "NEGroupCallEngine",
      ///    "methodName": "enableLocalVideo",
      ///    "params": [
      ///      {
      ///        "enable": "bool"
      ///      }
      ///    ]
      ///  }
      case 'enableLocalVideo':
        {
          var argEnable;
          argEnable = (params[0]['enable'] ??
              (params[0].length == 1 ? params[0].values.first : null)) as bool;
          return [
            target!.enableLocalVideo(
              argEnable,
            )
          ];
        }

      ///  {
      ///    "className": "NEGroupCallEngine",
      ///    "methodName": "muteLocalVideo",
      ///    "params": [
      ///      {
      ///        "mute": "bool"
      ///      }
      ///    ]
      ///  }
      case 'muteLocalVideo':
        {
          var argMute;
          argMute = (params[0]['mute'] ??
              (params[0].length == 1 ? params[0].values.first : null)) as bool;
          return [
            target!.muteLocalVideo(
              argMute,
            )
          ];
        }

      ///  {
      ///    "className": "NEGroupCallEngine",
      ///    "methodName": "enableLocalAudio",
      ///    "params": [
      ///      {
      ///        "enable": "bool"
      ///      }
      ///    ]
      ///  }
      case 'enableLocalAudio':
        {
          var argEnable;
          argEnable = (params[0]['enable'] ??
              (params[0].length == 1 ? params[0].values.first : null)) as bool;
          return [
            target!.enableLocalAudio(
              argEnable,
            )
          ];
        }

      ///  {
      ///    "className": "NEGroupCallEngine",
      ///    "methodName": "muteLocalAudio",
      ///    "params": [
      ///      {
      ///        "mute": "bool"
      ///      }
      ///    ]
      ///  }
      case 'muteLocalAudio':
        {
          var argMute;
          argMute = (params[0]['mute'] ??
              (params[0].length == 1 ? params[0].values.first : null)) as bool;
          return [
            target!.muteLocalAudio(
              argMute,
            )
          ];
        }

      ///  {
      ///    "className": "NEGroupCallEngine",
      ///    "methodName": "setSpeakerphoneOn",
      ///    "params": [
      ///      {
      ///        "enable": "bool"
      ///      }
      ///    ]
      ///  }
      case 'setSpeakerphoneOn':
        {
          var argEnable;
          argEnable = (params[0]['enable'] ??
              (params[0].length == 1 ? params[0].values.first : null)) as bool;
          return [
            target!.setSpeakerphoneOn(
              argEnable,
            )
          ];
        }

      ///  {
      ///    "className": "NEGroupCallEngine",
      ///    "methodName": "isSpeakerphoneOn",
      ///    "params": []
      ///  }
      case 'isSpeakerphoneOn':
        {
          return [target!.isSpeakerphoneOn()];
        }

      ///  {
      ///    "className": "NEGroupCallEngine",
      ///    "methodName": "switchCamera",
      ///    "params": []
      ///  }
      case 'switchCamera':
        {
          return [target!.switchCamera()];
        }

      ///  {
      ///    "className": "NEGroupCallEngine",
      ///    "methodName": "setupLocalView",
      ///    "params": [
      ///      {
      ///        "viewId": "int?"
      ///      }
      ///    ]
      ///  }
      case 'setupLocalView':
        {
          var argViewId;
          argViewId = (params[0]['viewId'] ??
              (params[0].length == 1 ? params[0].values.first : null)) as int?;
          return [
            target!.setupLocalView(
              argViewId,
            )
          ];
        }

      ///  {
      ///    "className": "NEGroupCallEngine",
      ///    "methodName": "setupRemoteView",
      ///    "params": [
      ///      {
      ///        "uid": "int"
      ///      },
      ///      {
      ///        "viewId": "int?"
      ///      }
      ///    ]
      ///  }
      case 'setupRemoteView':
        {
          var argUid;
          argUid = (params[0]['uid'] ??
              (params[0].length == 1 ? params[0].values.first : null)) as int;
          var argViewId;
          argViewId = (params[1]['viewId'] ??
              (params[1].length == 1 ? params[1].values.first : null)) as int?;
          return [
            target!.setupRemoteView(
              argUid,
              argViewId,
            )
          ];
        }

      ///  {
      ///    "className": "NEGroupCallEngine",
      ///    "methodName": "enableAudioVolumeIndication",
      ///    "params": [
      ///      {
      ///        "enable": "bool"
      ///      },
      ///      {
      ///        "interval": "int"
      ///      }
      ///    ]
      ///  }
      case 'enableAudioVolumeIndication':
        {
          var argEnable;
          argEnable = (params[0]['enable'] ??
              (params[0].length == 1 ? params[0].values.first : null)) as bool;
          var argInterval;
          argInterval = (params[1]['interval'] ??
              (params[1].length == 1 ? params[1].values.first : null)) as int;
          return [
            target!.enableAudioVolumeIndication(
              argEnable,
              argInterval,
            )
          ];
        }

      ///  {
      ///    "className": "NEGroupCallEngine",
      ///    "methodName": "setParameters",
      ///    "params": [
      ///      {
      ///        "params": "Map<String, dynamic>"
      ///      }
      ///    ]
      ///  }
      case 'setParameters':
        {
          var argParams;
          argParams = ((params[0]['params'] ??
                      (params[0].length == 1 ? params[0].values.first : null))
                  as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, v as dynamic))
              .cast<String, dynamic>();
          return [
            target!.setParameters(
              argParams,
            )
          ];
        }

      ///  {
      ///    "className": "NEGroupCallEngine",
      ///    "methodName": "addGroupCallDelegate",
      ///    "params": [
      ///      {
      ///        "delegate": "NEGroupCallEngineDelegate"
      ///      }
      ///    ]
      ///  }
      case 'addGroupCallDelegate':
        {
          var argDelegate;
          argDelegate = (await factory[NEGroupCallEngineDelegate]?.call(
                  (params[0]['delegate'] ??
                      (params[0].length == 1 ? params[0].values.first : null))))
              as NEGroupCallEngineDelegate;
          return [
            target!.addGroupCallDelegate(
              argDelegate,
            )
          ];
        }

      ///  {
      ///    "className": "NEGroupCallEngine",
      ///    "methodName": "removeGroupCallDelegate",
      ///    "params": [
      ///      {
      ///        "delegate": "NEGroupCallEngineDelegate"
      ///      }
      ///    ]
      ///  }
      case 'removeGroupCallDelegate':
        {
          var argDelegate;
          argDelegate = (await factory[NEGroupCallEngineDelegate]?.call(
                  (params[0]['delegate'] ??
                      (params[0].length == 1 ? params[0].values.first : null))))
              as NEGroupCallEngineDelegate;
          return [
            target!.removeGroupCallDelegate(
              argDelegate,
            )
          ];
        }

      ///  {
      ///    "className": "NEGroupCallEngine",
      ///    "methodName": "addGroupMediaDelegate",
      ///    "params": [
      ///      {
      ///        "delegate": "NEGroupMediaDelegate"
      ///      }
      ///    ]
      ///  }
      case 'addGroupMediaDelegate':
        {
          var argDelegate;
          argDelegate = (await factory[NEGroupMediaDelegate]?.call((params[0]
                      ['delegate'] ??
                  (params[0].length == 1 ? params[0].values.first : null))))
              as NEGroupMediaDelegate;
          return [
            target!.addGroupMediaDelegate(
              argDelegate,
            )
          ];
        }

      ///  {
      ///    "className": "NEGroupCallEngine",
      ///    "methodName": "removeGroupMediaDelegate",
      ///    "params": [
      ///      {
      ///        "delegate": "NEGroupMediaDelegate"
      ///      }
      ///    ]
      ///  }
      case 'removeGroupMediaDelegate':
        {
          var argDelegate;
          argDelegate = (await factory[NEGroupMediaDelegate]?.call((params[0]
                      ['delegate'] ??
                  (params[0].length == 1 ? params[0].values.first : null))))
              as NEGroupMediaDelegate;
          return [
            target!.removeGroupMediaDelegate(
              argDelegate,
            )
          ];
        }

      ///  {
      ///    "className": "NEGroupCallEngine",
      ///    "methodName": "getInstance",
      ///    "params": []
      ///  }
      case 'getInstance':
        {
          return [NEGroupCallEngine.instance];
        }
    }
    return null;
  }
}
