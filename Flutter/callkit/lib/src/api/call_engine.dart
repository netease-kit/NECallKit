// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of 'package:netease_callkit/netease_callkit.dart';

/// Primary CallKit engine entry point exposed to Flutter.
///
/// Use [NECallEngine.instance] to initialize the SDK, place and receive calls,
/// and control audio/video behavior during a call.
@HawkEntryPoint()
abstract class NECallEngine {
  static final NECallEngine _instance = NECallKitImpl.instance;
  factory NECallEngine() => _instance;

  static NECallEngine get instance => _instance;

  /// Initializes CallKit with the given [config].
  ///
  /// This must be called before placing or receiving calls.
  Future<VoidResult> setup(NESetupConfig config);

  /// Returns the version string of the underlying CallKit SDK.
  Future<String> getVersion();

  /// Places an outgoing call to the specified [accId].
  ///
  /// The [callType] determines whether this is an audio or video call.
  /// Optional [extraInfo], [rtcChannelName], [globalExtraCopy] and [pushConfig]
  /// can be used to attach custom metadata and push notification behavior.
  Future<NEResult<NECallInfo>> call(
    String accId,
    NECallType callType, {
    String? extraInfo,
    String? rtcChannelName,
    String? globalExtraCopy,
    NECallPushConfig? pushConfig,
  });

  /// Accepts the current incoming call.
  Future<NEResult<NECallInfo>> accept();

  /// Hangs up the current call.
  ///
  /// An optional [channelId] or [extraString] can be provided for custom
  /// signaling or analytics.
  Future<VoidResult> hangup({String? channelId, String? extraString});

  /// Switches the current call type, for example from audio to video.
  ///
  /// [callType] describes the target type and [state] indicates the switch
  /// state (invite, agree, reject).
  Future<VoidResult> switchCallType(
      NECallType callType, NECallSwitchState state);

  /// Sets the call timeout in seconds.
  Future<VoidResult> setTimeout(int time);

  /// Binds the local video stream to the platform view identified by [viewId].
  Future<VoidResult> setupLocalView(int viewId);

  /// Binds the remote video stream to the platform view identified by [viewId].
  Future<VoidResult> setupRemoteView(int viewId);

  /// Enables or disables the local video stream.
  Future<VoidResult> enableLocalVideo(bool enable);

  /// Mutes or unmutes the local video stream.
  Future<VoidResult> muteLocalVideo(bool muted);

  /// Mutes or unmutes the local audio stream.
  Future<VoidResult> muteLocalAudio(bool muted);

  /// Returns whether the speakerphone is currently enabled.
  Future<bool> isSpeakerphoneOn();

  /// Enables or disables the speakerphone.
  Future<VoidResult> setSpeakerphoneOn(bool enable);

  /// Switches between available cameras (for example, front and back).
  Future<VoidResult> switchCamera();

  /// Updates the call configuration used by the engine.
  ///
  /// - [enableOffline]: whether offline push and signaling are supported.
  /// - [enableSwitchVideoConfirm]: whether switching to video requires
  ///   confirmation.
  /// - [enableSwitchAudioConfirm]: whether switching to audio requires
  ///   confirmation.
  Future<VoidResult> setCallConfig({
    bool enableOffline = true,
    bool enableSwitchVideoConfirm = false,
    bool enableSwitchAudioConfirm = false,
  });

  /// Adds a call delegate to receive call-related callbacks.
  void addCallDelegate(NECallEngineDelegate delegate);

  /// Removes a previously added call delegate.
  void removeCallDelegate(NECallEngineDelegate delegate);

  /// Returns information about the current call, or `null` if there is no call.
  Future<NECallInfo?> getCallInfo();

  /// Returns the current call configuration, or `null` if none is set.
  Future<NECallConfig?> getCallConfig();

  /// Returns user information for the given RTC [uid], if available.
  Future<NEUserInfo?> getUserWithRtcUid(int uid);

  /// Destroys the engine and releases underlying resources.
  Future<VoidResult> destroy();

  /// Starts ASR (speech-to-text) captioning with the given [config].
  Future<VoidResult> startASRCaption(NEASRCaptionConfig config);

  /// Stops the currently running ASR captioning session.
  Future<VoidResult> stopASRCaption();

  /// Sets the call record provider used to send call records.
  ///
  /// When a [provider] is set, the internal record sending flow is intercepted
  /// and the app becomes responsible for sending call records itself. Passing
  /// `null` restores the default internal behavior.
  void setCallRecordProvider(NERecordProvider? provider);
}

/// Provider interface for custom call record sending.
///
/// When a [NERecordProvider] is set via [NECallEngine.setCallRecordProvider],
/// the SDK will no longer automatically send call records and will instead
/// invoke [onRecordSend].
abstract class NERecordProvider {
  /// Called when a call record needs to be sent.
  ///
  /// Implementations should send the record described by [config] to the
  /// appropriate backend or storage. The SDK will not send records on its own
  /// when a provider is configured.
  void onRecordSend(NERecordConfig config);
}

/// Callback listener container for call-related events.
class NECallEngineDelegate {
  const NECallEngineDelegate({
    this.onReceiveInvited,
    this.onCallEnd,
    this.onCallConnected,
    this.onLCKAccept,
    this.onLCKHangup,
    this.onCallTypeChange,
    this.onVideoAvailable,
    this.onVideoMuted,
    this.onAudioMuted,
    this.onLocalAudioMuted,
    this.onRtcInitEnd,
    this.onNERtcEngineVirtualBackgroundSourceEnabled,
    this.onAsrCaptionStateChanged,
    this.onAsrCaptionResult,
  });

  final void Function(NEInviteInfo info)? onReceiveInvited;
  final void Function(NECallEndInfo info)? onCallEnd;
  final void Function(NECallInfo info)? onCallConnected;

  /// Called when the iOS Live Communication Kit accept action completes.
  ///
  /// This is an action-result callback, not a call-state callback.
  final void Function(NELCKAcceptResult result)? onLCKAccept;

  /// Called when the iOS Live Communication Kit hangup action completes.
  ///
  /// This is an action-result callback, not a call-state callback.
  final void Function(NELCKHangupResult result)? onLCKHangup;
  final void Function(NECallTypeChangeInfo info)? onCallTypeChange;
  final void Function(bool available, String userID)? onVideoAvailable;
  final void Function(bool muted, String userID)? onVideoMuted;
  final void Function(bool muted, String userID)? onAudioMuted;
  final void Function(bool muted)? onLocalAudioMuted;
  final void Function()? onRtcInitEnd;
  final void Function(bool enabled, int reason)?
      onNERtcEngineVirtualBackgroundSourceEnabled;
  final void Function(int asrState, int code, String message)?
      onAsrCaptionStateChanged;
  final void Function(List<NEAsrCaptionResult?> result)? onAsrCaptionResult;
}
