// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.



// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'call_ui_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class CallKitClientLocalizationsEn extends CallKitClientLocalizations {
  CallKitClientLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get youHaveANewCall => 'You have a new call';

  @override
  String get initEngineFail => 'Init engine failed';

  @override
  String get callFailedUserIdEmpty => 'Call failed, userId is empty';

  @override
  String get permissionResultFail => 'Permission result fail';

  @override
  String get startCameraPermissionDenied => 'Start camera permission denied.';

  @override
  String get startMicrophonePermissionDenied => 'Start microphone permission denied.';

  @override
  String get applyForMicrophonePermission => 'apply for microphone permission';

  @override
  String get applyForCameraPermission => 'apply for camera permission';

  @override
  String get applyForMicrophoneAndCameraPermissions => 'apply for microphone and camera permissions';

  @override
  String get needToAccessMicrophonePermission => 'need to access microphone permission';

  @override
  String get needToAccessCameraPermission => 'need to access camera permission';

  @override
  String get errorInPeerBlacklist => 'error in peer blacklist';

  @override
  String get insufficientPermissions => 'insufficient permissions';

  @override
  String get displayPopUpWindowWhileRunningInTheBackgroundAndDisplayPopUpWindowPermissions => 'display popUpWindow while running in the background and display popUpWindow permissions';

  @override
  String get needToAccessMicrophoneAndCameraPermissions => 'need to access microphone and camera permissions';

  @override
  String get noFloatWindowPermission => 'no float window permission';

  @override
  String get needFloatWindowPermission => 'need float window permission';

  @override
  String get noBackgroundStartPermission => 'no background start permission';

  @override
  String get needBackgroundStartPermission => 'Your phone has not granted background start permission, minimizing calls may not work properly';

  @override
  String get accept => 'accept';

  @override
  String get cameraIsOn => 'cameraIsOn';

  @override
  String get cameraIsOff => 'cameraIsOff';

  @override
  String get speakerIsOn => 'speakerIsOn';

  @override
  String get speakerIsOff => 'speakerIsOff';

  @override
  String get microphoneIsOn => 'microphoneIsOn';

  @override
  String get microphoneIsOff => 'microphoneIsOff';

  @override
  String get blurBackground => 'blurBackground';

  @override
  String get switchCamera => 'switchCamera';

  @override
  String get waiting => 'waiting';

  @override
  String get hangUp => 'hangUp';

  @override
  String get userBusy => 'Other party is busy';

  @override
  String get userInCall => 'User is already in a call';

  @override
  String get answerOnOtherDevice => 'The other client has answered the call';

  @override
  String get rejectOnOtherDevice => 'The other client has rejected the call';

  @override
  String get remoteUserReject => 'remote user rejected';

  @override
  String get remoteTimeout => 'Timeout and no response';

  @override
  String get remoteCancel => 'The call was canceled';

  @override
  String get groupCallInvitation => 'Group Call Invitation';

  @override
  String get groupCallWaiting => 'Waiting';

  @override
  String get groupCallInProgress => 'In Call';

  @override
  String get groupCallDuration => 'Duration';

  @override
  String get groupCallInvite => 'Invite';

  @override
  String get groupCallIgnore => 'Ignore';

  @override
  String get groupCallJoining => 'Joining...';

  @override
  String get groupCallConnecting => 'Connecting...';

  @override
  String get groupCallMemberJoined => 'Joined';

  @override
  String get groupCallMemberLeft => 'Left';

  @override
  String get groupCallInviteYouToJoin => 'invites you to join group call';

  @override
  String groupCallOtherMembers(Object count) {
    return 'and $count others';
  }

  @override
  String get groupCallToggleMic => 'Microphone';

  @override
  String get groupCallToggleCamera => 'Camera';

  @override
  String get groupCallToggleSpeaker => 'Speaker';

  @override
  String get groupCallMicOn => 'Mic On';

  @override
  String get groupCallMicOff => 'Mic Off';

  @override
  String get groupCallSpeakerOn => 'Speaker On';

  @override
  String get groupCallSpeakerOff => 'Speaker Off';

  @override
  String get groupCallCameraOn => 'Camera On';

  @override
  String get groupCallCameraOff => 'Camera Off';

  @override
  String get groupCallSwitchCamera => 'Switch Camera';

  @override
  String get groupCallMinimize => 'Minimize';

  @override
  String get groupCallInviteMore => 'Invite More';

  @override
  String get groupCallNoVideo => 'Video not enabled';

  @override
  String get groupCallSpeaking => 'Speaking';

  @override
  String get groupCallMuted => 'Muted';

  @override
  String get groupCallInitFailed => 'Group call init failed';

  @override
  String get groupCallJoinFailed => 'Join group call failed';

  @override
  String get groupCallCreateFailed => 'Create group call failed';

  @override
  String get groupCallNetworkError => 'Network error, please try again';

  @override
  String get groupCallMembersFull => 'Group call is full';

  @override
  String get groupCallEnded => 'Group call ended';

  @override
  String get cancel => 'Cancel';

  @override
  String get goToSettings => 'Go to Settings';

  @override
  String get unknownUser => 'Unknown User';

  @override
  String groupCallOthersInCall(Object count) {
    return '$count others in call:';
  }
}
