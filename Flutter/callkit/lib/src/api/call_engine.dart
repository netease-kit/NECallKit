// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of 'package:netease_callkit/netease_callkit.dart';

/// Primary CallKit engine entry point exposed to Flutter.
///
/// Use [NECallEngine.instance] to initialize the SDK, place and receive calls,
/// and control audio/video behavior during a call.
///
/// Desktop runtime keeps the same public lifecycle as mobile:
/// `setup -> call/accept/hangup -> destroy`.
/// The Windows/macOS implementation is backed by `desktop/bridge` via Dart
/// FFI. If a public API does not yet have a native desktop export, it returns
/// an explicit unsupported result instead of falling back to mobile-only
/// plugin channels.
///
/// For multi-client login alignment on desktop, the public API still does not
/// add a desktop-only kicked-offline callback. Active-call kicked scenarios are
/// normalized into [NECallEngineDelegate.onCallEnd] with
/// [NECallTerminalCode.kicked], while kicked detail stays inside desktop
/// adapter / host coordination.
@HawkEntryPoint()
abstract class NECallEngine {
  static final NECallEngine _instance = NECallKitImpl.instance;
  factory NECallEngine() => _instance;

  static NECallEngine get instance => _instance;

  /// Initializes CallKit with the given [config].
  ///
  /// This must be called before placing or receiving calls.
  /// In desktop runtime (Windows/macOS), the lifecycle remains aligned with
  /// existing mobile semantics and is bridged through `desktop/bridge`.
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
    NECallType callType,
    NECallSwitchState state,
  );

  /// Sets the call timeout in seconds.
  ///
  /// The default timeout is `30s`, the maximum is `120s`, and desktop runtime
  /// only applies updates before entering an outgoing or incoming session.
  Future<VoidResult> setTimeout(int time);

  /// Binds the local video stream to the render target identified by [viewId].
  ///
  /// [viewId] is typically returned by [NECallkitVideoView.onPlatformViewCreated].
  /// On macOS this is a platform view id backed by a native `NSView`. On
  /// Windows this is a texture renderer id.
  ///
  /// On macOS, [NECallkitVideoView] and texture-based renderers
  /// ([NECallkitTextureView] / [NECallkitVideoRenderer]) cannot be mixed in
  /// the same active RTC lifecycle.
  Future<VoidResult> setupLocalView(int viewId);

  /// Binds the remote video stream to the render target identified by [viewId].
  ///
  /// [viewId] is typically returned by [NECallkitVideoView.onPlatformViewCreated].
  /// On macOS this is a platform view id backed by a native `NSView`. On
  /// Windows this is a texture renderer id.
  ///
  /// On macOS, [NECallkitVideoView] and texture-based renderers
  /// ([NECallkitTextureView] / [NECallkitVideoRenderer]) cannot be mixed in
  /// the same active RTC lifecycle.
  Future<VoidResult> setupRemoteView(int viewId);

  /// Enables or disables the local video stream.
  Future<VoidResult> enableLocalVideo(bool enable);

  /// Mutes or unmutes the local video stream.
  Future<VoidResult> muteLocalVideo(bool muted);

  /// Mutes or unmutes the local audio stream.
  Future<VoidResult> muteLocalAudio(bool muted);

  /// Returns whether the speakerphone is currently enabled.
  ///
  /// On desktop runtime, this reflects whether audio playback output is
  /// enabled. It does not mean a mobile-style earpiece/speaker route switch.
  Future<bool> isSpeakerphoneOn();

  /// Enables or disables the speakerphone.
  ///
  /// On desktop runtime, this controls playback output on/off for the current
  /// playout device. Device selection stays on
  /// [getAudioPlaybackDevices]/[setAudioPlaybackDevice].
  Future<VoidResult> setSpeakerphoneOn(bool enable);

  /// Switches between available cameras (for example, front and back).
  Future<VoidResult> switchCamera();

  /// Returns available desktop video capture devices.
  ///
  /// Desktop-only API. Mobile runtimes return an empty list.
  Future<List<NEDesktopVideoDevice>> getVideoCaptureDevices();

  /// Returns the currently selected desktop video capture device id.
  ///
  /// Desktop-only API. Mobile runtimes return `null`.
  Future<String?> getCurrentVideoCaptureDeviceId();

  /// Switches the active desktop video capture device to [deviceId].
  ///
  /// Desktop-only API.
  Future<VoidResult> setVideoCaptureDevice(String deviceId);

  /// Returns available desktop audio recording devices.
  ///
  /// Desktop-only API. Mobile runtimes return an empty list.
  Future<List<NEDesktopAudioDevice>> getAudioRecordingDevices();

  /// Returns the currently selected desktop audio recording device id.
  ///
  /// Desktop-only API. Mobile runtimes return `null`.
  Future<String?> getCurrentAudioRecordingDeviceId();

  /// Switches the active desktop audio recording device to [deviceId].
  ///
  /// Desktop-only API.
  Future<VoidResult> setAudioRecordingDevice(String deviceId);

  /// Returns available desktop audio playback devices.
  ///
  /// Desktop-only API. Mobile runtimes return an empty list.
  Future<List<NEDesktopAudioDevice>> getAudioPlaybackDevices();

  /// Returns the currently selected desktop audio playback device id.
  ///
  /// Desktop-only API. Mobile runtimes return `null`.
  Future<String?> getCurrentAudioPlaybackDeviceId();

  /// Switches the active desktop audio playback device to [deviceId].
  ///
  /// Desktop-only API. This changes the playout device selection and is
  /// independent from [setSpeakerphoneOn], which only toggles playback output
  /// on/off on desktop.
  Future<VoidResult> setAudioPlaybackDevice(String deviceId);

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
  ///
  /// For desktop runtime, this keeps the same public lifecycle contract and
  /// does not introduce desktop-only business APIs.
  Future<VoidResult> destroy();

  /// Starts ASR (speech-to-text) captioning with the given [config].
  ///
  /// **Not supported on Windows/macOS.** Returns an unsupported result on
  /// desktop runtimes.
  Future<VoidResult> startASRCaption(NEASRCaptionConfig config);

  /// Stops the currently running ASR captioning session.
  ///
  /// **Not supported on Windows/macOS.** Returns an unsupported result on
  /// desktop runtimes.
  Future<VoidResult> stopASRCaption();

  /// Sets the call record provider used to send call records.
  ///
  /// When a [provider] is set, the internal record sending flow is intercepted
  /// and the app becomes responsible for sending call records itself. Passing
  /// `null` restores the default internal behavior.
  void setCallRecordProvider(NERecordProvider? provider);

  /// A broadcast stream of raw NERtc events forwarded by the desktop bridge.
  ///
  /// Each event is a [Map] containing at minimum an `"event"` key holding the
  /// NERtc callback name (e.g. `"onRemoteVideoReceiveSizeChanged"`). The
  /// remaining keys are event-specific fields decoded from the bridge JSON.
  ///
  /// On non-desktop platforms this stream never emits. Subscribe using
  /// `where((e) => e['event'] == 'myEvent')` to filter by event name.
  Stream<Map<String, dynamic>> get rtcRawEvents;
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
  ///
  /// **iOS only.** Never fired on Android, Windows, or macOS.
  final void Function(NELCKAcceptResult result)? onLCKAccept;

  /// Called when the iOS Live Communication Kit hangup action completes.
  ///
  /// This is an action-result callback, not a call-state callback.
  ///
  /// **iOS only.** Never fired on Android, Windows, or macOS.
  final void Function(NELCKHangupResult result)? onLCKHangup;
  final void Function(NECallTypeChangeInfo info)? onCallTypeChange;
  final void Function(bool available, String userID)? onVideoAvailable;
  final void Function(bool muted, String userID)? onVideoMuted;
  final void Function(bool muted, String userID)? onAudioMuted;
  final void Function(bool muted)? onLocalAudioMuted;
  final void Function()? onRtcInitEnd;

  /// **Not supported on Windows/macOS.** Never fired on desktop runtimes.
  final void Function(bool enabled, int reason)?
      onNERtcEngineVirtualBackgroundSourceEnabled;

  /// **Not supported on Windows/macOS.** Never fired on desktop runtimes.
  final void Function(int asrState, int code, String message)?
      onAsrCaptionStateChanged;

  /// **Not supported on Windows/macOS.** Never fired on desktop runtimes.
  final void Function(List<NEAsrCaptionResult?> result)? onAsrCaptionResult;
}
