import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

typedef NeCallBridgeCreateNative = Pointer<Void> Function();
typedef NeCallBridgeCreateDart = Pointer<Void> Function();

typedef NeCallBridgeDestroyNative = Void Function();
typedef NeCallBridgeDestroyDart = void Function();

typedef NeCallBridgeSetupNative = Int32 Function(
  Pointer<Void>,
  Pointer<NECallBridgeSetupConfigNative>,
);
typedef NeCallBridgeSetupDart = int Function(
  Pointer<Void>,
  Pointer<NECallBridgeSetupConfigNative>,
);

typedef NeCallBridgeCallNative = Int32 Function(
  Pointer<Void>,
  Pointer<NECallBridgeCallParamNative>,
  Pointer<NativeFunction<NeCallBridgeCallCompletionNative>>,
  Pointer<Void>,
);
typedef NeCallBridgeCallDart = int Function(
  Pointer<Void>,
  Pointer<NECallBridgeCallParamNative>,
  Pointer<NativeFunction<NeCallBridgeCallCompletionNative>>,
  Pointer<Void>,
);

typedef NeCallBridgeAcceptNative = Int32 Function(
  Pointer<Void>,
  Pointer<NativeFunction<NeCallBridgeCallCompletionNative>>,
  Pointer<Void>,
);
typedef NeCallBridgeAcceptDart = int Function(
  Pointer<Void>,
  Pointer<NativeFunction<NeCallBridgeCallCompletionNative>>,
  Pointer<Void>,
);

typedef NeCallBridgeHangupNative = Int32 Function(
  Pointer<Void>,
  Pointer<NECallBridgeHangupParamNative>,
  Pointer<NativeFunction<NeCallBridgeHangupCompletionNative>>,
  Pointer<Void>,
);
typedef NeCallBridgeHangupDart = int Function(
  Pointer<Void>,
  Pointer<NECallBridgeHangupParamNative>,
  Pointer<NativeFunction<NeCallBridgeHangupCompletionNative>>,
  Pointer<Void>,
);

typedef NeCallBridgeCallCompletionNative = Void Function(
  Pointer<NECallBridgeErrorNative>,
  Pointer<NECallBridgeCallInfoParamNative>,
  Pointer<Void>,
);
typedef NeCallBridgeCallCompletionDart = void Function(
  Pointer<NECallBridgeErrorNative>,
  Pointer<NECallBridgeCallInfoParamNative>,
  Pointer<Void>,
);

typedef NeCallBridgeHangupCompletionNative = Void Function(
  Pointer<NECallBridgeErrorNative>,
  Pointer<Void>,
);
typedef NeCallBridgeHangupCompletionDart = void Function(
  Pointer<NECallBridgeErrorNative>,
  Pointer<Void>,
);

typedef NeCallBridgeReleaseErrorNative = Void Function(
  Pointer<NECallBridgeErrorNative>,
);
typedef NeCallBridgeReleaseErrorDart = void Function(
  Pointer<NECallBridgeErrorNative>,
);

typedef NeCallBridgeReleaseCallInfoNative = Void Function(
  Pointer<NECallBridgeCallInfoParamNative>,
);
typedef NeCallBridgeReleaseCallInfoDart = void Function(
  Pointer<NECallBridgeCallInfoParamNative>,
);

typedef NeCallBridgeGetVersionNative = Int32 Function(
  Pointer<Void>,
  Pointer<Int8>,
  Uint32,
);
typedef NeCallBridgeGetVersionDart = int Function(
  Pointer<Void>,
  Pointer<Int8>,
  int,
);

typedef NeCallBridgeSetTimeoutNative = Int32 Function(
  Pointer<Void>,
  Int32,
);
typedef NeCallBridgeSetTimeoutDart = int Function(
  Pointer<Void>,
  int,
);

typedef NeCallBridgeSwitchCallTypeNative = Int32 Function(
  Pointer<Void>,
  Int32,
  Int32,
);
typedef NeCallBridgeSwitchCallTypeDart = int Function(
  Pointer<Void>,
  int,
  int,
);

typedef NeCallBridgeSetCallConfigNative = Int32 Function(
  Pointer<Void>,
  Pointer<NECallBridgeConfigParamNative>,
);
typedef NeCallBridgeSetCallConfigDart = int Function(
  Pointer<Void>,
  Pointer<NECallBridgeConfigParamNative>,
);

typedef NeCallBridgeGetCallConfigNative = Int32 Function(
  Pointer<Void>,
  Pointer<NECallBridgeConfigParamNative>,
);
typedef NeCallBridgeGetCallConfigDart = int Function(
  Pointer<Void>,
  Pointer<NECallBridgeConfigParamNative>,
);

typedef NeCallBridgeGetCallInfoNative = Int32 Function(
  Pointer<Void>,
  Pointer<NECallBridgeCallInfoParamNative>,
);
typedef NeCallBridgeGetCallInfoDart = int Function(
  Pointer<Void>,
  Pointer<NECallBridgeCallInfoParamNative>,
);

typedef NeCallBridgeSetCallRecordProviderNative = Int32 Function(
  Pointer<Void>,
  Uint8,
);
typedef NeCallBridgeSetCallRecordProviderDart = int Function(
  Pointer<Void>,
  int,
);

typedef NeCallBridgeEnableLocalVideoNative = Int32 Function(
  Pointer<Void>,
  Uint8,
);
typedef NeCallBridgeEnableLocalVideoDart = int Function(
  Pointer<Void>,
  int,
);

typedef NeCallBridgeMuteLocalVideoNative = Int32 Function(
  Pointer<Void>,
  Uint8,
);
typedef NeCallBridgeMuteLocalVideoDart = int Function(
  Pointer<Void>,
  int,
);

typedef NeCallBridgeMuteLocalAudioNative = Int32 Function(
  Pointer<Void>,
  Uint8,
);
typedef NeCallBridgeMuteLocalAudioDart = int Function(
  Pointer<Void>,
  int,
);

typedef NeCallBridgeSwitchCameraNative = Int32 Function(Pointer<Void>);
typedef NeCallBridgeSwitchCameraDart = int Function(Pointer<Void>);

typedef NeCallBridgeSetSpeakerphoneOnNative = Int32 Function(
  Pointer<Void>,
  Uint8,
);
typedef NeCallBridgeSetSpeakerphoneOnDart = int Function(
  Pointer<Void>,
  int,
);

typedef NeCallBridgeIsSpeakerphoneOnNative = Int32 Function(
  Pointer<Void>,
  Pointer<Uint8>,
);
typedef NeCallBridgeIsSpeakerphoneOnDart = int Function(
  Pointer<Void>,
  Pointer<Uint8>,
);

typedef NeCallBridgeRegisterEventCallbackNative = Int32 Function(
  Pointer<Void>,
  Pointer<NativeFunction<NeCallBridgeEventCallbackNative>>,
  Pointer<Void>,
);
typedef NeCallBridgeRegisterEventCallbackDart = int Function(
  Pointer<Void>,
  Pointer<NativeFunction<NeCallBridgeEventCallbackNative>>,
  Pointer<Void>,
);

typedef NeCallBridgeReleaseEventNative = Void Function(
  Pointer<NECallBridgeEventNative>,
);
typedef NeCallBridgeReleaseEventDart = void Function(
  Pointer<NECallBridgeEventNative>,
);

typedef NeCallBridgeSetupLocalVideoRendererNative = Int32 Function(
  Pointer<Void>,
  Int64,
);
typedef NeCallBridgeSetupLocalVideoRendererDart = int Function(
  Pointer<Void>,
  int,
);

typedef NeCallBridgeSetupRemoteVideoRendererNative = Int32 Function(
  Pointer<Void>,
  Int64,
);
typedef NeCallBridgeSetupRemoteVideoRendererDart = int Function(
  Pointer<Void>,
  int,
);

typedef NeCallBridgeSetupRemoteVideoRendererWithUidNative = Int32 Function(
  Pointer<Void>,
  Uint64,
  Int64,
);
typedef NeCallBridgeSetupRemoteVideoRendererWithUidDart = int Function(
  Pointer<Void>,
  int,
  int,
);

typedef NeCallBridgeSetVideoRendererMirrorNative = Int32 Function(
  Pointer<Void>,
  Int64,
  Uint8,
);
typedef NeCallBridgeSetVideoRendererMirrorDart = int Function(
  Pointer<Void>,
  int,
  int,
);

typedef NeCallBridgeGetUserWithRtcUidNative = Int32 Function(
  Pointer<Void>,
  Uint64,
  Pointer<NECallBridgeUserInfoParamNative>,
);
typedef NeCallBridgeGetUserWithRtcUidDart = int Function(
  Pointer<Void>,
  int,
  Pointer<NECallBridgeUserInfoParamNative>,
);

typedef NeCallBridgeListVideoCaptureDevicesNative = Int32 Function(
  Pointer<Void>,
  Pointer<Int8>,
  Uint32,
  Pointer<Uint32>,
);
typedef NeCallBridgeListVideoCaptureDevicesDart = int Function(
  Pointer<Void>,
  Pointer<Int8>,
  int,
  Pointer<Uint32>,
);

typedef NeCallBridgeGetCurrentVideoCaptureDeviceNative = Int32 Function(
  Pointer<Void>,
  Pointer<Int8>,
  Uint32,
  Pointer<Uint32>,
);
typedef NeCallBridgeGetCurrentVideoCaptureDeviceDart = int Function(
  Pointer<Void>,
  Pointer<Int8>,
  int,
  Pointer<Uint32>,
);

typedef NeCallBridgeSetVideoCaptureDeviceNative = Int32 Function(
  Pointer<Void>,
  Pointer<Utf8>,
);
typedef NeCallBridgeSetVideoCaptureDeviceDart = int Function(
  Pointer<Void>,
  Pointer<Utf8>,
);

typedef NeCallBridgeListAudioRecordingDevicesNative = Int32 Function(
  Pointer<Void>,
  Pointer<Int8>,
  Uint32,
  Pointer<Uint32>,
);
typedef NeCallBridgeListAudioRecordingDevicesDart = int Function(
  Pointer<Void>,
  Pointer<Int8>,
  int,
  Pointer<Uint32>,
);

typedef NeCallBridgeGetCurrentAudioRecordingDeviceNative = Int32 Function(
  Pointer<Void>,
  Pointer<Int8>,
  Uint32,
  Pointer<Uint32>,
);
typedef NeCallBridgeGetCurrentAudioRecordingDeviceDart = int Function(
  Pointer<Void>,
  Pointer<Int8>,
  int,
  Pointer<Uint32>,
);

typedef NeCallBridgeSetAudioRecordingDeviceNative = Int32 Function(
  Pointer<Void>,
  Pointer<Utf8>,
);
typedef NeCallBridgeSetAudioRecordingDeviceDart = int Function(
  Pointer<Void>,
  Pointer<Utf8>,
);

typedef NeCallBridgeListAudioPlaybackDevicesNative = Int32 Function(
  Pointer<Void>,
  Pointer<Int8>,
  Uint32,
  Pointer<Uint32>,
);
typedef NeCallBridgeListAudioPlaybackDevicesDart = int Function(
  Pointer<Void>,
  Pointer<Int8>,
  int,
  Pointer<Uint32>,
);

typedef NeCallBridgeGetCurrentAudioPlaybackDeviceNative = Int32 Function(
  Pointer<Void>,
  Pointer<Int8>,
  Uint32,
  Pointer<Uint32>,
);
typedef NeCallBridgeGetCurrentAudioPlaybackDeviceDart = int Function(
  Pointer<Void>,
  Pointer<Int8>,
  int,
  Pointer<Uint32>,
);

typedef NeCallBridgeSetAudioPlaybackDeviceNative = Int32 Function(
  Pointer<Void>,
  Pointer<Utf8>,
);
typedef NeCallBridgeSetAudioPlaybackDeviceDart = int Function(
  Pointer<Void>,
  Pointer<Utf8>,
);

typedef NeCallBridgeGetCapabilitiesNative = Uint64 Function();
typedef NeCallBridgeGetCapabilitiesDart = int Function();

typedef NeCallBridgeSupportsCapabilityNative = Int32 Function(Uint64);
typedef NeCallBridgeSupportsCapabilityDart = int Function(int);

typedef NeCallBridgeEventCallbackNative = Void Function(
  Pointer<NECallBridgeEventNative>,
  Pointer<Void>,
);
typedef NeCallBridgeEventCallbackDart = void Function(
  Pointer<NECallBridgeEventNative>,
  Pointer<Void>,
);

class NECallBridgeSetupConfigNative extends Struct {
  external Pointer<Utf8> appKey;
  external Pointer<Utf8> framework;
  external Pointer<Utf8> channel;

  @Uint64()
  external int currentUserRtcUid;

  @Uint8()
  external int enableJoinRtcWhenCall;

  @Int32()
  external int initRtcMode;

  @Int32()
  external int preferredVideoRenderMode;
}

class NECallBridgePushConfigNative extends Struct {
  @Uint8()
  external int needPush;

  external Pointer<Utf8> pushTitle;
  external Pointer<Utf8> pushContent;
  external Pointer<Utf8> pushPayload;

  @Uint8()
  external int needBadge;
}

class NECallBridgeCallParamNative extends Struct {
  external Pointer<Utf8> accId;

  @Int32()
  external int callType;

  external Pointer<Utf8> extraInfo;
  external Pointer<Utf8> rtcChannelName;
  external Pointer<Utf8> globalExtraCopy;
  external Pointer<NECallBridgePushConfigNative> pushConfig;
}

class NECallBridgeHangupParamNative extends Struct {
  external Pointer<Utf8> channelId;
  external Pointer<Utf8> extraString;
}

class NECallBridgeErrorNative extends Struct {
  @Int32()
  external int code;

  external Pointer<Utf8> message;
}

class NECallBridgeConfigParamNative extends Struct {
  @Bool()
  external bool enableOffline;

  @Bool()
  external bool enableSwitchVideoConfirm;

  @Bool()
  external bool enableSwitchAudioConfirm;
}

class NECallBridgeCallUserInfoNative extends Struct {
  external Pointer<Utf8> accId;

  @Uint64()
  external int uid;
}

class NECallBridgeSignalInfoNative extends Struct {
  external Pointer<Utf8> channelId;
  external Pointer<Utf8> requestId;
  external Pointer<Utf8> channelName;
  external Pointer<Utf8> extraInfo;
  external Pointer<Utf8> globalExtraCopy;
}

class NECallBridgeRtcInfoNative extends Struct {
  external Pointer<Utf8> channelName;
  external Pointer<Utf8> token;

  @Uint64()
  external int cid;

  @Uint64()
  external int uid;
}

class NECallBridgeCallInfoParamNative extends Struct {
  external Pointer<Utf8> callId;
  external Pointer<Utf8> currentAccId;
  external NECallBridgeCallUserInfoNative callerInfo;
  external NECallBridgeCallUserInfoNative calleeInfo;

  @Int32()
  external int callType;

  external NECallBridgeSignalInfoNative signalInfo;
  external NECallBridgeRtcInfoNative rtcInfo;

  @Int32()
  external int callStatus;
}

class NECallBridgeUserInfoParamNative extends Struct {
  external Pointer<Utf8> userId;

  @Uint64()
  external int rtcUid;
}

class NECallBridgeInvitedPayloadNative extends Struct {
  external Pointer<Utf8> callerAccId;

  @Int32()
  external int callType;

  external Pointer<Utf8> extraInfo;
  external Pointer<Utf8> channelId;
}

class NECallBridgeConnectedPayloadNative extends Struct {
  external Pointer<Utf8> callId;
  external Pointer<Utf8> currentAccId;
  external NECallBridgeCallUserInfoNative callerInfo;
  external NECallBridgeCallUserInfoNative calleeInfo;

  @Int32()
  external int callType;

  external NECallBridgeSignalInfoNative signalInfo;
  external NECallBridgeRtcInfoNative rtcInfo;

  @Int32()
  external int callStatus;
}

class NECallBridgeEndPayloadNative extends Struct {
  @Int32()
  external int reasonCode;

  external Pointer<Utf8> extraString;
  external Pointer<Utf8> message;
}

class NECallBridgeTypeChangePayloadNative extends Struct {
  @Uint64()
  external int callId;

  @Int32()
  external int callType;

  @Uint64()
  external int timestampMs;
}

class NECallBridgeVideoAvailablePayloadNative extends Struct {
  @Uint64()
  external int callId;

  external Pointer<Utf8> userId;

  @Uint8()
  external int available;

  @Uint64()
  external int timestampMs;
}

class NECallBridgeVideoMutedPayloadNative extends Struct {
  @Uint64()
  external int callId;

  external Pointer<Utf8> userId;

  @Uint8()
  external int muted;

  @Uint64()
  external int timestampMs;
}

class NECallBridgeAudioMutedPayloadNative extends Struct {
  @Uint64()
  external int callId;

  external Pointer<Utf8> userId;

  @Uint8()
  external int muted;

  @Uint64()
  external int timestampMs;
}

class NECallBridgeDebugLogPayloadNative extends Struct {
  @Uint64()
  external int callId;

  external Pointer<Utf8> message;

  @Uint64()
  external int timestampMs;
}

class NECallBridgeLocalAudioMutedPayloadNative extends Struct {
  @Uint64()
  external int callId;

  @Uint8()
  external int muted;

  @Uint64()
  external int timestampMs;
}

class NECallBridgeRtcInitEndPayloadNative extends Struct {
  @Uint64()
  external int callId;

  @Uint64()
  external int timestampMs;
}

class NECallBridgeRecordSendPayloadNative extends Struct {
  @Uint64()
  external int callId;

  external Pointer<Utf8> accId;

  @Int32()
  external int callType;

  @Int32()
  external int callState;

  @Uint64()
  external int timestampMs;
}

class NECallBridgeRtcRawPayloadNative extends Struct {
  external Pointer<Utf8> eventName;
  external Pointer<Utf8> jsonData;
}

class NECallBridgeEventPayloadNative extends Union {
  external NECallBridgeInvitedPayloadNative invited;
  external NECallBridgeConnectedPayloadNative connected;
  external NECallBridgeEndPayloadNative ended;
  external NECallBridgeTypeChangePayloadNative typeChanged;
  external NECallBridgeVideoAvailablePayloadNative videoAvailable;
  external NECallBridgeVideoMutedPayloadNative videoMuted;
  external NECallBridgeAudioMutedPayloadNative audioMuted;
  external NECallBridgeDebugLogPayloadNative debugLog;
  external NECallBridgeLocalAudioMutedPayloadNative localAudioMuted;
  external NECallBridgeRtcInitEndPayloadNative rtcInitEnd;
  external NECallBridgeRecordSendPayloadNative recordSend;
  external NECallBridgeRtcRawPayloadNative rtcRaw;
}

class NECallBridgeEventNative extends Struct {
  @Int32()
  external int type;

  external NECallBridgeEventPayloadNative payload;
}

class DesktopFfiBindings {
  DesktopFfiBindings._(DynamicLibrary dynamicLibrary)
      : create = dynamicLibrary.lookupFunction<NeCallBridgeCreateNative,
            NeCallBridgeCreateDart>('ne_call_bridge_create'),
        destroy = dynamicLibrary.lookupFunction<NeCallBridgeDestroyNative,
            NeCallBridgeDestroyDart>('ne_call_bridge_destroy'),
        setup = dynamicLibrary.lookupFunction<NeCallBridgeSetupNative,
            NeCallBridgeSetupDart>('ne_call_bridge_setup'),
        call = dynamicLibrary.lookupFunction<NeCallBridgeCallNative,
            NeCallBridgeCallDart>('ne_call_bridge_call'),
        accept = dynamicLibrary.lookupFunction<NeCallBridgeAcceptNative,
            NeCallBridgeAcceptDart>('ne_call_bridge_accept'),
        hangup = dynamicLibrary.lookupFunction<NeCallBridgeHangupNative,
            NeCallBridgeHangupDart>('ne_call_bridge_hangup'),
        releaseError = dynamicLibrary.lookupFunction<
            NeCallBridgeReleaseErrorNative,
            NeCallBridgeReleaseErrorDart>('ne_call_bridge_release_error'),
        releaseCallInfo = dynamicLibrary.lookupFunction<
                NeCallBridgeReleaseCallInfoNative,
                NeCallBridgeReleaseCallInfoDart>(
            'ne_call_bridge_release_call_info'),
        getVersion = dynamicLibrary.lookupFunction<NeCallBridgeGetVersionNative,
            NeCallBridgeGetVersionDart>('ne_call_bridge_get_version'),
        setTimeout = dynamicLibrary.lookupFunction<NeCallBridgeSetTimeoutNative,
            NeCallBridgeSetTimeoutDart>('ne_call_bridge_set_timeout'),
        switchCallType = dynamicLibrary.lookupFunction<
            NeCallBridgeSwitchCallTypeNative,
            NeCallBridgeSwitchCallTypeDart>('ne_call_bridge_switch_call_type'),
        setCallConfig = dynamicLibrary.lookupFunction<
            NeCallBridgeSetCallConfigNative,
            NeCallBridgeSetCallConfigDart>('ne_call_bridge_set_call_config'),
        getCallConfig = dynamicLibrary.lookupFunction<
            NeCallBridgeGetCallConfigNative,
            NeCallBridgeGetCallConfigDart>('ne_call_bridge_get_call_config'),
        getCallInfo = dynamicLibrary.lookupFunction<
            NeCallBridgeGetCallInfoNative,
            NeCallBridgeGetCallInfoDart>('ne_call_bridge_get_call_info'),
        setCallRecordProvider = dynamicLibrary.lookupFunction<
                NeCallBridgeSetCallRecordProviderNative,
                NeCallBridgeSetCallRecordProviderDart>(
            'ne_call_bridge_set_call_record_provider'),
        enableLocalVideo = dynamicLibrary.lookupFunction<
                NeCallBridgeEnableLocalVideoNative,
                NeCallBridgeEnableLocalVideoDart>(
            'ne_call_bridge_enable_local_video'),
        muteLocalVideo = dynamicLibrary.lookupFunction<
            NeCallBridgeMuteLocalVideoNative,
            NeCallBridgeMuteLocalVideoDart>('ne_call_bridge_mute_local_video'),
        muteLocalAudio = dynamicLibrary.lookupFunction<
            NeCallBridgeMuteLocalAudioNative,
            NeCallBridgeMuteLocalAudioDart>('ne_call_bridge_mute_local_audio'),
        switchCamera = dynamicLibrary.lookupFunction<
            NeCallBridgeSwitchCameraNative,
            NeCallBridgeSwitchCameraDart>('ne_call_bridge_switch_camera'),
        setSpeakerphoneOn = dynamicLibrary.lookupFunction<
                NeCallBridgeSetSpeakerphoneOnNative,
                NeCallBridgeSetSpeakerphoneOnDart>(
            'ne_call_bridge_set_speakerphone_on'),
        isSpeakerphoneOn = dynamicLibrary.lookupFunction<
                NeCallBridgeIsSpeakerphoneOnNative,
                NeCallBridgeIsSpeakerphoneOnDart>(
            'ne_call_bridge_is_speakerphone_on'),
        registerEventCallback = dynamicLibrary.lookupFunction<
                NeCallBridgeRegisterEventCallbackNative,
                NeCallBridgeRegisterEventCallbackDart>(
            'ne_call_bridge_register_event_callback'),
        releaseEvent = dynamicLibrary.lookupFunction<
            NeCallBridgeReleaseEventNative,
            NeCallBridgeReleaseEventDart>('ne_call_bridge_release_event'),
        setupLocalVideoRenderer = dynamicLibrary.lookupFunction<
                NeCallBridgeSetupLocalVideoRendererNative,
                NeCallBridgeSetupLocalVideoRendererDart>(
            'ne_call_bridge_setup_local_video_renderer'),
        setupRemoteVideoRenderer = dynamicLibrary.lookupFunction<
                NeCallBridgeSetupRemoteVideoRendererNative,
                NeCallBridgeSetupRemoteVideoRendererDart>(
            'ne_call_bridge_setup_remote_video_renderer'),
        setupRemoteVideoRendererWithUid = dynamicLibrary.lookupFunction<
                NeCallBridgeSetupRemoteVideoRendererWithUidNative,
                NeCallBridgeSetupRemoteVideoRendererWithUidDart>(
            'ne_call_bridge_setup_remote_video_renderer_with_uid'),
        setVideoRendererMirror = dynamicLibrary.lookupFunction<
                NeCallBridgeSetVideoRendererMirrorNative,
                NeCallBridgeSetVideoRendererMirrorDart>(
            'ne_call_bridge_set_video_renderer_mirror'),
        getUserWithRtcUid = dynamicLibrary.lookupFunction<
                NeCallBridgeGetUserWithRtcUidNative,
                NeCallBridgeGetUserWithRtcUidDart>(
            'ne_call_bridge_get_user_with_rtc_uid'),
        listVideoCaptureDevices = dynamicLibrary.lookupFunction<
                NeCallBridgeListVideoCaptureDevicesNative,
                NeCallBridgeListVideoCaptureDevicesDart>(
            'ne_call_bridge_list_video_capture_devices'),
        getCurrentVideoCaptureDevice = dynamicLibrary.lookupFunction<
                NeCallBridgeGetCurrentVideoCaptureDeviceNative,
                NeCallBridgeGetCurrentVideoCaptureDeviceDart>(
            'ne_call_bridge_get_current_video_capture_device'),
        setVideoCaptureDevice = dynamicLibrary.lookupFunction<
                NeCallBridgeSetVideoCaptureDeviceNative,
                NeCallBridgeSetVideoCaptureDeviceDart>(
            'ne_call_bridge_set_video_capture_device'),
        listAudioRecordingDevices = dynamicLibrary.lookupFunction<
                NeCallBridgeListAudioRecordingDevicesNative,
                NeCallBridgeListAudioRecordingDevicesDart>(
            'ne_call_bridge_list_audio_recording_devices'),
        getCurrentAudioRecordingDevice = dynamicLibrary.lookupFunction<
                NeCallBridgeGetCurrentAudioRecordingDeviceNative,
                NeCallBridgeGetCurrentAudioRecordingDeviceDart>(
            'ne_call_bridge_get_current_audio_recording_device'),
        setAudioRecordingDevice = dynamicLibrary.lookupFunction<
                NeCallBridgeSetAudioRecordingDeviceNative,
                NeCallBridgeSetAudioRecordingDeviceDart>(
            'ne_call_bridge_set_audio_recording_device'),
        listAudioPlaybackDevices = dynamicLibrary.lookupFunction<
                NeCallBridgeListAudioPlaybackDevicesNative,
                NeCallBridgeListAudioPlaybackDevicesDart>(
            'ne_call_bridge_list_audio_playback_devices'),
        getCurrentAudioPlaybackDevice = dynamicLibrary.lookupFunction<
                NeCallBridgeGetCurrentAudioPlaybackDeviceNative,
                NeCallBridgeGetCurrentAudioPlaybackDeviceDart>(
            'ne_call_bridge_get_current_audio_playback_device'),
        setAudioPlaybackDevice = dynamicLibrary.lookupFunction<
                NeCallBridgeSetAudioPlaybackDeviceNative,
                NeCallBridgeSetAudioPlaybackDeviceDart>(
            'ne_call_bridge_set_audio_playback_device'),
        getCapabilities = dynamicLibrary.lookupFunction<
            NeCallBridgeGetCapabilitiesNative,
            NeCallBridgeGetCapabilitiesDart>('ne_call_bridge_get_capabilities'),
        supportsCapability = dynamicLibrary.lookupFunction<
                NeCallBridgeSupportsCapabilityNative,
                NeCallBridgeSupportsCapabilityDart>(
            'ne_call_bridge_supports_capability');

  final NeCallBridgeCreateDart create;
  final NeCallBridgeDestroyDart destroy;
  final NeCallBridgeSetupDart setup;
  final NeCallBridgeCallDart call;
  final NeCallBridgeAcceptDart accept;
  final NeCallBridgeHangupDart hangup;
  final NeCallBridgeReleaseErrorDart releaseError;
  final NeCallBridgeReleaseCallInfoDart releaseCallInfo;
  final NeCallBridgeGetVersionDart getVersion;
  final NeCallBridgeSetTimeoutDart setTimeout;
  final NeCallBridgeSwitchCallTypeDart switchCallType;
  final NeCallBridgeSetCallConfigDart setCallConfig;
  final NeCallBridgeGetCallConfigDart getCallConfig;
  final NeCallBridgeGetCallInfoDart getCallInfo;
  final NeCallBridgeSetCallRecordProviderDart setCallRecordProvider;
  final NeCallBridgeEnableLocalVideoDart enableLocalVideo;
  final NeCallBridgeMuteLocalVideoDart muteLocalVideo;
  final NeCallBridgeMuteLocalAudioDart muteLocalAudio;
  final NeCallBridgeSwitchCameraDart switchCamera;
  final NeCallBridgeSetSpeakerphoneOnDart setSpeakerphoneOn;
  final NeCallBridgeIsSpeakerphoneOnDart isSpeakerphoneOn;
  final NeCallBridgeRegisterEventCallbackDart registerEventCallback;
  final NeCallBridgeReleaseEventDart releaseEvent;
  final NeCallBridgeSetupLocalVideoRendererDart setupLocalVideoRenderer;
  final NeCallBridgeSetupRemoteVideoRendererDart setupRemoteVideoRenderer;
  final NeCallBridgeSetupRemoteVideoRendererWithUidDart
      setupRemoteVideoRendererWithUid;
  final NeCallBridgeSetVideoRendererMirrorDart setVideoRendererMirror;
  final NeCallBridgeGetUserWithRtcUidDart getUserWithRtcUid;
  final NeCallBridgeListVideoCaptureDevicesDart listVideoCaptureDevices;
  final NeCallBridgeGetCurrentVideoCaptureDeviceDart
      getCurrentVideoCaptureDevice;
  final NeCallBridgeSetVideoCaptureDeviceDart setVideoCaptureDevice;
  final NeCallBridgeListAudioRecordingDevicesDart listAudioRecordingDevices;
  final NeCallBridgeGetCurrentAudioRecordingDeviceDart
      getCurrentAudioRecordingDevice;
  final NeCallBridgeSetAudioRecordingDeviceDart setAudioRecordingDevice;
  final NeCallBridgeListAudioPlaybackDevicesDart listAudioPlaybackDevices;
  final NeCallBridgeGetCurrentAudioPlaybackDeviceDart
      getCurrentAudioPlaybackDevice;
  final NeCallBridgeSetAudioPlaybackDeviceDart setAudioPlaybackDevice;
  final NeCallBridgeGetCapabilitiesDart getCapabilities;
  final NeCallBridgeSupportsCapabilityDart supportsCapability;

  static DesktopFfiBindings? _instance;

  static DesktopFfiBindings get instance {
    _instance ??= DesktopFfiBindings._(_loadDesktopLibrary());
    return _instance!;
  }

  static DynamicLibrary _loadDesktopLibrary() {
    final candidates = <String>[
      if (Platform.isMacOS) ...<String>[
        'libne_callkit.dylib',
        '@rpath/libne_callkit.dylib',
        '@executable_path/../Frameworks/libne_callkit.dylib',
        '@loader_path/../Frameworks/libne_callkit.dylib',
        'libne_call_bridge.dylib',
        '@rpath/libne_call_bridge.dylib',
        '@executable_path/../Frameworks/libne_call_bridge.dylib',
        '@loader_path/../Frameworks/libne_call_bridge.dylib',
      ],
      if (Platform.isWindows) ...<String>[
        'ne_callkit.dll',
        'ne_call_bridge.dll',
      ],
      if (Platform.isLinux) ...<String>[
        'libne_callkit.so',
        'libne_call_bridge.so',
      ],
    ];
    for (final candidate in candidates) {
      try {
        return DynamicLibrary.open(candidate);
      } catch (_) {}
    }
    return DynamicLibrary.process();
  }
}
