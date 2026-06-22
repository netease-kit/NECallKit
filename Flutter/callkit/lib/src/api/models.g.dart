// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimpleResponse _$SimpleResponseFromJson(Map<String, dynamic> json) =>
    SimpleResponse(
      code: (json['code'] as num).toInt(),
      msg: json['msg'] as String?,
      data1: (json['data1'] as num?)?.toInt(),
      data2: (json['data2'] as num?)?.toInt(),
      data3: json['data3'] as String?,
    );

Map<String, dynamic> _$SimpleResponseToJson(SimpleResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data1': instance.data1,
      'data2': instance.data2,
      'data3': instance.data3,
    };

NELCKConfig _$NELCKConfigFromJson(Map<String, dynamic> json) => NELCKConfig(
      enableLiveCommunicationKit: json['enableLiveCommunicationKit'] as bool,
      ringtoneName: json['ringtoneName'] as String?,
    );

Map<String, dynamic> _$NELCKConfigToJson(NELCKConfig instance) =>
    <String, dynamic>{
      'enableLiveCommunicationKit': instance.enableLiveCommunicationKit,
      'ringtoneName': instance.ringtoneName,
    };

NESetupConfig _$NESetupConfigFromJson(Map<String, dynamic> json) =>
    NESetupConfig(
      appKey: json['appKey'] as String,
      currentAccountId: json['currentAccountId'] as String?,
      currentUserRtcUid: (json['currentUserRtcUid'] as num?)?.toInt(),
      enableJoinRtcWhenCall: json['enableJoinRtcWhenCall'] as bool?,
      initRtcMode:
          $enumDecodeNullable(_$NECallInitRtcModeEnumMap, json['initRtcMode']),
      desktopVideoRenderMode: $enumDecodeNullable(
          _$NEDesktopVideoRenderModeEnumMap, json['desktopVideoRenderMode']),
      lckConfig: json['lckConfig'] == null
          ? null
          : NELCKConfig.fromJson(json['lckConfig'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NESetupConfigToJson(NESetupConfig instance) =>
    <String, dynamic>{
      'appKey': instance.appKey,
      'currentAccountId': instance.currentAccountId,
      'currentUserRtcUid': instance.currentUserRtcUid,
      'enableJoinRtcWhenCall': instance.enableJoinRtcWhenCall,
      'initRtcMode': _$NECallInitRtcModeEnumMap[instance.initRtcMode],
      'desktopVideoRenderMode':
          _$NEDesktopVideoRenderModeEnumMap[instance.desktopVideoRenderMode],
      'lckConfig': instance.lckConfig,
    };

const _$NECallInitRtcModeEnumMap = {
  NECallInitRtcMode.global: 0,
  NECallInitRtcMode.inNeed: 1,
  NECallInitRtcMode.inNeedDelayToAccept: 2,
};

const _$NEDesktopVideoRenderModeEnumMap = {
  NEDesktopVideoRenderMode.auto: 0,
  NEDesktopVideoRenderMode.externalRenderer: 1,
  NEDesktopVideoRenderMode.platformWindow: 2,
};

NECallParam _$NECallParamFromJson(Map<String, dynamic> json) => NECallParam(
      accId: json['accId'] as String,
      extraInfo: json['extraInfo'] as String?,
      rtcChannelName: json['rtcChannelName'] as String?,
      globalExtraCopy: json['globalExtraCopy'] as String?,
      callType: $enumDecode(_$NECallTypeEnumMap, json['callType']),
      pushConfig: json['pushConfig'] == null
          ? null
          : NECallPushConfig.fromJson(
              json['pushConfig'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NECallParamToJson(NECallParam instance) =>
    <String, dynamic>{
      'accId': instance.accId,
      'extraInfo': instance.extraInfo,
      'rtcChannelName': instance.rtcChannelName,
      'globalExtraCopy': instance.globalExtraCopy,
      'callType': _$NECallTypeEnumMap[instance.callType]!,
      'pushConfig': instance.pushConfig,
    };

const _$NECallTypeEnumMap = {
  NECallType.none: 0,
  NECallType.audio: 1,
  NECallType.video: 2,
};

NECallPushConfig _$NECallPushConfigFromJson(Map<String, dynamic> json) =>
    NECallPushConfig(
      pushTitle: json['pushTitle'] as String?,
      pushContent: json['pushContent'] as String?,
      pushPayload: json['pushPayload'] as String?,
      needBadge: json['needBadge'] as bool,
      needPush: json['needPush'] as bool,
    );

Map<String, dynamic> _$NECallPushConfigToJson(NECallPushConfig instance) =>
    <String, dynamic>{
      'pushTitle': instance.pushTitle,
      'pushContent': instance.pushContent,
      'pushPayload': instance.pushPayload,
      'needBadge': instance.needBadge,
      'needPush': instance.needPush,
    };

NEUserInfo _$NEUserInfoFromJson(Map<String, dynamic> json) => NEUserInfo(
      accId: json['accId'] as String,
      uid: (json['uid'] as num).toInt(),
    );

Map<String, dynamic> _$NEUserInfoToJson(NEUserInfo instance) =>
    <String, dynamic>{
      'accId': instance.accId,
      'uid': instance.uid,
    };

NESignalInfo _$NESignalInfoFromJson(Map<String, dynamic> json) => NESignalInfo(
      channelId: json['channelId'] as String?,
      requestId: json['requestId'] as String?,
      channelName: json['channelName'] as String?,
      extraInfo: json['extraInfo'] as String?,
      globalExtraCopy: json['globalExtraCopy'] as String?,
    );

Map<String, dynamic> _$NESignalInfoToJson(NESignalInfo instance) =>
    <String, dynamic>{
      'channelId': instance.channelId,
      'requestId': instance.requestId,
      'channelName': instance.channelName,
      'extraInfo': instance.extraInfo,
      'globalExtraCopy': instance.globalExtraCopy,
    };

NERtcInfo _$NERtcInfoFromJson(Map<String, dynamic> json) => NERtcInfo(
      channelName: json['channelName'] as String?,
      token: json['token'] as String?,
      channelId: (json['channelId'] as num).toInt(),
      uid: (json['uid'] as num).toInt(),
    );

Map<String, dynamic> _$NERtcInfoToJson(NERtcInfo instance) => <String, dynamic>{
      'channelName': instance.channelName,
      'token': instance.token,
      'channelId': instance.channelId,
      'uid': instance.uid,
    };

NECallInfo _$NECallInfoFromJson(Map<String, dynamic> json) => NECallInfo(
      callId: json['callId'] as String,
      currentAccId: json['currentAccId'] as String,
      callerInfo: json['callerInfo'] == null
          ? null
          : NEUserInfo.fromJson(json['callerInfo'] as Map<String, dynamic>),
      calleeInfo: json['calleeInfo'] == null
          ? null
          : NEUserInfo.fromJson(json['calleeInfo'] as Map<String, dynamic>),
      callType: $enumDecode(_$NECallTypeEnumMap, json['callType']),
      signalInfo: json['signalInfo'] == null
          ? null
          : NESignalInfo.fromJson(json['signalInfo'] as Map<String, dynamic>),
      rtcInfo: json['rtcInfo'] == null
          ? null
          : NERtcInfo.fromJson(json['rtcInfo'] as Map<String, dynamic>),
      callStatus: $enumDecode(_$NECallEngineStatusEnumMap, json['callStatus']),
    );

Map<String, dynamic> _$NECallInfoToJson(NECallInfo instance) =>
    <String, dynamic>{
      'callId': instance.callId,
      'currentAccId': instance.currentAccId,
      'callerInfo': instance.callerInfo,
      'calleeInfo': instance.calleeInfo,
      'callType': _$NECallTypeEnumMap[instance.callType]!,
      'signalInfo': instance.signalInfo,
      'rtcInfo': instance.rtcInfo,
      'callStatus': _$NECallEngineStatusEnumMap[instance.callStatus]!,
    };

const _$NECallEngineStatusEnumMap = {
  NECallEngineStatus.idle: 0,
  NECallEngineStatus.calling: 1,
  NECallEngineStatus.called: 2,
  NECallEngineStatus.inCall: 3,
};

NEHangupParam _$NEHangupParamFromJson(Map<String, dynamic> json) =>
    NEHangupParam(
      channelId: json['channelId'] as String,
      extraString: json['extraString'] as String?,
    );

Map<String, dynamic> _$NEHangupParamToJson(NEHangupParam instance) =>
    <String, dynamic>{
      'channelId': instance.channelId,
      'extraString': instance.extraString,
    };

NESwitchParam _$NESwitchParamFromJson(Map<String, dynamic> json) =>
    NESwitchParam(
      callType: $enumDecode(_$NECallTypeEnumMap, json['callType']),
      state: $enumDecode(_$NECallSwitchStateEnumMap, json['state']),
    );

Map<String, dynamic> _$NESwitchParamToJson(NESwitchParam instance) =>
    <String, dynamic>{
      'callType': _$NECallTypeEnumMap[instance.callType]!,
      'state': _$NECallSwitchStateEnumMap[instance.state]!,
    };

const _$NECallSwitchStateEnumMap = {
  NECallSwitchState.invite: 0,
  NECallSwitchState.agree: 1,
  NECallSwitchState.reject: 2,
};

NECallConfig _$NECallConfigFromJson(Map<String, dynamic> json) => NECallConfig(
      enableOffline: json['enableOffline'] as bool,
      enableSwitchVideoConfirm: json['enableSwitchVideoConfirm'] as bool,
      enableSwitchAudioConfirm: json['enableSwitchAudioConfirm'] as bool,
    );

Map<String, dynamic> _$NECallConfigToJson(NECallConfig instance) =>
    <String, dynamic>{
      'enableOffline': instance.enableOffline,
      'enableSwitchVideoConfirm': instance.enableSwitchVideoConfirm,
      'enableSwitchAudioConfirm': instance.enableSwitchAudioConfirm,
    };

NEViewParam _$NEViewParamFromJson(Map<String, dynamic> json) => NEViewParam(
      viewId: (json['viewId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$NEViewParamToJson(NEViewParam instance) =>
    <String, dynamic>{
      'viewId': instance.viewId,
    };

NEInviteInfo _$NEInviteInfoFromJson(Map<String, dynamic> json) => NEInviteInfo(
      callerAccId: json['callerAccId'] as String,
      callType: $enumDecode(_$NECallTypeEnumMap, json['callType']),
      callId: json['callId'] as String?,
      extraInfo: json['extraInfo'] as String?,
      channelId: json['channelId'] as String?,
    );

Map<String, dynamic> _$NEInviteInfoToJson(NEInviteInfo instance) =>
    <String, dynamic>{
      'callerAccId': instance.callerAccId,
      'callType': _$NECallTypeEnumMap[instance.callType]!,
      'callId': instance.callId,
      'extraInfo': instance.extraInfo,
      'channelId': instance.channelId,
    };

NECallEndInfo _$NECallEndInfoFromJson(Map<String, dynamic> json) =>
    NECallEndInfo(
      reasonCode: $enumDecode(_$NECallTerminalCodeEnumMap, json['reasonCode']),
      callId: json['callId'] as String?,
      extraString: json['extraString'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$NECallEndInfoToJson(NECallEndInfo instance) =>
    <String, dynamic>{
      'reasonCode': _$NECallTerminalCodeEnumMap[instance.reasonCode]!,
      'callId': instance.callId,
      'extraString': instance.extraString,
      'message': instance.message,
    };

const _$NECallTerminalCodeEnumMap = {
  NECallTerminalCode.normal: 0,
  NECallTerminalCode.tokenError: 1,
  NECallTerminalCode.timeOut: 2,
  NECallTerminalCode.busy: 3,
  NECallTerminalCode.rtcInitError: 4,
  NECallTerminalCode.joinRtcError: 5,
  NECallTerminalCode.cancelErrorParam: 6,
  NECallTerminalCode.callFailed: 7,
  NECallTerminalCode.kicked: 8,
  NECallTerminalCode.emptyUid: 9,
  NECallTerminalCode.rtcDisconnected: 10,
  NECallTerminalCode.callerCancel: 11,
  NECallTerminalCode.calleeCancel: 12,
  NECallTerminalCode.calleeReject: 13,
  NECallTerminalCode.callerRejected: 14,
  NECallTerminalCode.hangUp: 15,
  NECallTerminalCode.beHangUp: 16,
  NECallTerminalCode.otherRejected: 17,
  NECallTerminalCode.otherAccepted: 18,
  NECallTerminalCode.userRtcDisconnected: 19,
  NECallTerminalCode.userRtcLeave: 20,
  NECallTerminalCode.acceptFail: 21,
};

NECallTypeChangeInfo _$NECallTypeChangeInfoFromJson(
        Map<String, dynamic> json) =>
    NECallTypeChangeInfo(
      callType: $enumDecode(_$NECallTypeEnumMap, json['callType']),
      state: $enumDecode(_$NECallSwitchStateEnumMap, json['state']),
    );

Map<String, dynamic> _$NECallTypeChangeInfoToJson(
        NECallTypeChangeInfo instance) =>
    <String, dynamic>{
      'callType': _$NECallTypeEnumMap[instance.callType]!,
      'state': _$NECallSwitchStateEnumMap[instance.state]!,
    };

NERecordConfig _$NERecordConfigFromJson(Map<String, dynamic> json) =>
    NERecordConfig(
      accId: json['accId'] as String,
      callType: $enumDecode(_$NECallTypeEnumMap, json['callType']),
      callState: $enumDecode(_$NIMRtcCallStatusEnumMap, json['callState']),
    );

Map<String, dynamic> _$NERecordConfigToJson(NERecordConfig instance) =>
    <String, dynamic>{
      'accId': instance.accId,
      'callType': _$NECallTypeEnumMap[instance.callType]!,
      'callState': _$NIMRtcCallStatusEnumMap[instance.callState]!,
    };

const _$NIMRtcCallStatusEnumMap = {
  NIMCallStatus.completed: 0,
  NIMCallStatus.cancelled: 1,
  NIMCallStatus.rejected: 2,
  NIMCallStatus.timeout: 3,
  NIMCallStatus.busy: 4,
};

NEASRCaptionConfig _$NEASRCaptionConfigFromJson(Map<String, dynamic> json) =>
    NEASRCaptionConfig(
      srcLanguage: json['srcLanguage'] as String?,
      srcLanguages: (json['srcLanguages'] as List<dynamic>?)
          ?.map((e) => e as String?)
          .toList(),
      dstLanguage: json['dstLanguage'] as String?,
      dstLanguages: (json['dstLanguages'] as List<dynamic>?)
          ?.map((e) => e as String?)
          .toList(),
      needTranslateSameLanguage: json['needTranslateSameLanguage'] as bool?,
    );

Map<String, dynamic> _$NEASRCaptionConfigToJson(NEASRCaptionConfig instance) =>
    <String, dynamic>{
      'srcLanguage': instance.srcLanguage,
      'srcLanguages': instance.srcLanguages,
      'dstLanguage': instance.dstLanguage,
      'dstLanguages': instance.dstLanguages,
      'needTranslateSameLanguage': instance.needTranslateSameLanguage,
    };

NEAsrCaptionResult _$NEAsrCaptionResultFromJson(Map<String, dynamic> json) =>
    NEAsrCaptionResult(
      uid: (json['uid'] as num).toInt(),
      isLocalUser: json['isLocalUser'] as bool,
      timestamp: (json['timestamp'] as num).toInt(),
      content: json['content'] as String?,
      language: json['language'] as String?,
      haveTranslation: json['haveTranslation'] as bool,
      translatedText: json['translatedText'] as String?,
      translationLanguage: json['translationLanguage'] as String?,
      isFinal: json['isFinal'] as bool,
    );

Map<String, dynamic> _$NEAsrCaptionResultToJson(NEAsrCaptionResult instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'isLocalUser': instance.isLocalUser,
      'timestamp': instance.timestamp,
      'content': instance.content,
      'language': instance.language,
      'haveTranslation': instance.haveTranslation,
      'translatedText': instance.translatedText,
      'translationLanguage': instance.translationLanguage,
      'isFinal': instance.isFinal,
    };
