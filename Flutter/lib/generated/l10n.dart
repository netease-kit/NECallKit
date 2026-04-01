// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `You have a new call`
  String get youHaveANewCall {
    return Intl.message(
      'You have a new call',
      name: 'youHaveANewCall',
      desc: '',
      args: [],
    );
  }

  /// `Init engine failed`
  String get initEngineFail {
    return Intl.message(
      'Init engine failed',
      name: 'initEngineFail',
      desc: '',
      args: [],
    );
  }

  /// `Call failed, userId is empty`
  String get callFailedUserIdEmpty {
    return Intl.message(
      'Call failed, userId is empty',
      name: 'callFailedUserIdEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Permission result fail`
  String get permissionResultFail {
    return Intl.message(
      'Permission result fail',
      name: 'permissionResultFail',
      desc: '',
      args: [],
    );
  }

  /// `Start camera permission denied.`
  String get startCameraPermissionDenied {
    return Intl.message(
      'Start camera permission denied.',
      name: 'startCameraPermissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `apply for microphone permission`
  String get applyForMicrophonePermission {
    return Intl.message(
      'apply for microphone permission',
      name: 'applyForMicrophonePermission',
      desc: '',
      args: [],
    );
  }

  /// `apply for camera permission`
  String get applyForCameraPermission {
    return Intl.message(
      'apply for camera permission',
      name: 'applyForCameraPermission',
      desc: '',
      args: [],
    );
  }

  /// `apply for microphone and camera permissions`
  String get applyForMicrophoneAndCameraPermissions {
    return Intl.message(
      'apply for microphone and camera permissions',
      name: 'applyForMicrophoneAndCameraPermissions',
      desc: '',
      args: [],
    );
  }

  /// `need to access microphone permission`
  String get needToAccessMicrophonePermission {
    return Intl.message(
      'need to access microphone permission',
      name: 'needToAccessMicrophonePermission',
      desc: '',
      args: [],
    );
  }

  /// `need to access camera permission`
  String get needToAccessCameraPermission {
    return Intl.message(
      'need to access camera permission',
      name: 'needToAccessCameraPermission',
      desc: '',
      args: [],
    );
  }

  /// `error in peer blacklist`
  String get errorInPeerBlacklist {
    return Intl.message(
      'error in peer blacklist',
      name: 'errorInPeerBlacklist',
      desc: '',
      args: [],
    );
  }

  /// `insufficient permissions`
  String get insufficientPermissions {
    return Intl.message(
      'insufficient permissions',
      name: 'insufficientPermissions',
      desc: '',
      args: [],
    );
  }

  /// `display popUpWindow while running in the background and display popUpWindow permissions`
  String
  get displayPopUpWindowWhileRunningInTheBackgroundAndDisplayPopUpWindowPermissions {
    return Intl.message(
      'display popUpWindow while running in the background and display popUpWindow permissions',
      name:
          'displayPopUpWindowWhileRunningInTheBackgroundAndDisplayPopUpWindowPermissions',
      desc: '',
      args: [],
    );
  }

  /// `need to access microphone and camera permissions`
  String get needToAccessMicrophoneAndCameraPermissions {
    return Intl.message(
      'need to access microphone and camera permissions',
      name: 'needToAccessMicrophoneAndCameraPermissions',
      desc: '',
      args: [],
    );
  }

  /// `no float window permission`
  String get noFloatWindowPermission {
    return Intl.message(
      'no float window permission',
      name: 'noFloatWindowPermission',
      desc: '',
      args: [],
    );
  }

  /// `need float window permission`
  String get needFloatWindowPermission {
    return Intl.message(
      'need float window permission',
      name: 'needFloatWindowPermission',
      desc: '',
      args: [],
    );
  }

  /// `no background start permission`
  String get noBackgroundStartPermission {
    return Intl.message(
      'no background start permission',
      name: 'noBackgroundStartPermission',
      desc: '',
      args: [],
    );
  }

  /// `Your phone has not granted background start permission, minimizing calls may not work properly`
  String get needBackgroundStartPermission {
    return Intl.message(
      'Your phone has not granted background start permission, minimizing calls may not work properly',
      name: 'needBackgroundStartPermission',
      desc: '',
      args: [],
    );
  }

  /// `accept`
  String get accept {
    return Intl.message('accept', name: 'accept', desc: '', args: []);
  }

  /// `cameraIsOn`
  String get cameraIsOn {
    return Intl.message('cameraIsOn', name: 'cameraIsOn', desc: '', args: []);
  }

  /// `cameraIsOff`
  String get cameraIsOff {
    return Intl.message('cameraIsOff', name: 'cameraIsOff', desc: '', args: []);
  }

  /// `speakerIsOn`
  String get speakerIsOn {
    return Intl.message('speakerIsOn', name: 'speakerIsOn', desc: '', args: []);
  }

  /// `speakerIsOff`
  String get speakerIsOff {
    return Intl.message(
      'speakerIsOff',
      name: 'speakerIsOff',
      desc: '',
      args: [],
    );
  }

  /// `microphoneIsOn`
  String get microphoneIsOn {
    return Intl.message(
      'microphoneIsOn',
      name: 'microphoneIsOn',
      desc: '',
      args: [],
    );
  }

  /// `microphoneIsOff`
  String get microphoneIsOff {
    return Intl.message(
      'microphoneIsOff',
      name: 'microphoneIsOff',
      desc: '',
      args: [],
    );
  }

  /// `blurBackground`
  String get blurBackground {
    return Intl.message(
      'blurBackground',
      name: 'blurBackground',
      desc: '',
      args: [],
    );
  }

  /// `switchCamera`
  String get switchCamera {
    return Intl.message(
      'switchCamera',
      name: 'switchCamera',
      desc: '',
      args: [],
    );
  }

  /// `waiting`
  String get waiting {
    return Intl.message('waiting', name: 'waiting', desc: '', args: []);
  }

  /// `hangUp`
  String get hangUp {
    return Intl.message('hangUp', name: 'hangUp', desc: '', args: []);
  }

  /// `Other party is busy`
  String get userBusy {
    return Intl.message(
      'Other party is busy',
      name: 'userBusy',
      desc: '',
      args: [],
    );
  }

  /// `User is already in a call`
  String get userInCall {
    return Intl.message(
      'User is already in a call',
      name: 'userInCall',
      desc: '',
      args: [],
    );
  }

  /// `The other client has answered the call`
  String get answerOnOtherDevice {
    return Intl.message(
      'The other client has answered the call',
      name: 'answerOnOtherDevice',
      desc: '',
      args: [],
    );
  }

  /// `The other client has rejected the call`
  String get rejectOnOtherDevice {
    return Intl.message(
      'The other client has rejected the call',
      name: 'rejectOnOtherDevice',
      desc: '',
      args: [],
    );
  }

  /// `remote user rejected`
  String get remoteUserReject {
    return Intl.message(
      'remote user rejected',
      name: 'remoteUserReject',
      desc: '',
      args: [],
    );
  }

  /// `Timeout and no response`
  String get remoteTimeout {
    return Intl.message(
      'Timeout and no response',
      name: 'remoteTimeout',
      desc: '',
      args: [],
    );
  }

  /// `The call was canceled`
  String get remoteCancel {
    return Intl.message(
      'The call was canceled',
      name: 'remoteCancel',
      desc: '',
      args: [],
    );
  }

  /// `Group Call Invitation`
  String get groupCallInvitation {
    return Intl.message(
      'Group Call Invitation',
      name: 'groupCallInvitation',
      desc: '',
      args: [],
    );
  }

  /// `Waiting`
  String get groupCallWaiting {
    return Intl.message(
      'Waiting',
      name: 'groupCallWaiting',
      desc: '',
      args: [],
    );
  }

  /// `In Call`
  String get groupCallInProgress {
    return Intl.message(
      'In Call',
      name: 'groupCallInProgress',
      desc: '',
      args: [],
    );
  }

  /// `Duration`
  String get groupCallDuration {
    return Intl.message(
      'Duration',
      name: 'groupCallDuration',
      desc: '',
      args: [],
    );
  }

  /// `Invite`
  String get groupCallInvite {
    return Intl.message('Invite', name: 'groupCallInvite', desc: '', args: []);
  }

  /// `Ignore`
  String get groupCallIgnore {
    return Intl.message('Ignore', name: 'groupCallIgnore', desc: '', args: []);
  }

  /// `Joining...`
  String get groupCallJoining {
    return Intl.message(
      'Joining...',
      name: 'groupCallJoining',
      desc: '',
      args: [],
    );
  }

  /// `Connecting...`
  String get groupCallConnecting {
    return Intl.message(
      'Connecting...',
      name: 'groupCallConnecting',
      desc: '',
      args: [],
    );
  }

  /// `Joined`
  String get groupCallMemberJoined {
    return Intl.message(
      'Joined',
      name: 'groupCallMemberJoined',
      desc: '',
      args: [],
    );
  }

  /// `Left`
  String get groupCallMemberLeft {
    return Intl.message(
      'Left',
      name: 'groupCallMemberLeft',
      desc: '',
      args: [],
    );
  }

  /// `invites you to join group call`
  String get groupCallInviteYouToJoin {
    return Intl.message(
      'invites you to join group call',
      name: 'groupCallInviteYouToJoin',
      desc: '',
      args: [],
    );
  }

  /// `and {count} others`
  String groupCallOtherMembers(Object count) {
    return Intl.message(
      'and $count others',
      name: 'groupCallOtherMembers',
      desc: '',
      args: [count],
    );
  }

  /// `Microphone`
  String get groupCallToggleMic {
    return Intl.message(
      'Microphone',
      name: 'groupCallToggleMic',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get groupCallToggleCamera {
    return Intl.message(
      'Camera',
      name: 'groupCallToggleCamera',
      desc: '',
      args: [],
    );
  }

  /// `Speaker`
  String get groupCallToggleSpeaker {
    return Intl.message(
      'Speaker',
      name: 'groupCallToggleSpeaker',
      desc: '',
      args: [],
    );
  }

  /// `Mic On`
  String get groupCallMicOn {
    return Intl.message(
      'Mic On',
      name: 'groupCallMicOn',
      desc: '',
      args: [],
    );
  }

  /// `Mic Off`
  String get groupCallMicOff {
    return Intl.message(
      'Mic Off',
      name: 'groupCallMicOff',
      desc: '',
      args: [],
    );
  }

  /// `Speaker On`
  String get groupCallSpeakerOn {
    return Intl.message(
      'Speaker On',
      name: 'groupCallSpeakerOn',
      desc: '',
      args: [],
    );
  }

  /// `Speaker Off`
  String get groupCallSpeakerOff {
    return Intl.message(
      'Speaker Off',
      name: 'groupCallSpeakerOff',
      desc: '',
      args: [],
    );
  }

  /// `Camera On`
  String get groupCallCameraOn {
    return Intl.message(
      'Camera On',
      name: 'groupCallCameraOn',
      desc: '',
      args: [],
    );
  }

  /// `Switch Camera`
  String get groupCallSwitchCamera {
    return Intl.message(
      'Switch Camera',
      name: 'groupCallSwitchCamera',
      desc: '',
      args: [],
    );
  }

  /// `Minimize`
  String get groupCallMinimize {
    return Intl.message(
      'Minimize',
      name: 'groupCallMinimize',
      desc: '',
      args: [],
    );
  }

  /// `Invite More`
  String get groupCallInviteMore {
    return Intl.message(
      'Invite More',
      name: 'groupCallInviteMore',
      desc: '',
      args: [],
    );
  }

  /// `Video not enabled`
  String get groupCallNoVideo {
    return Intl.message(
      'Video not enabled',
      name: 'groupCallNoVideo',
      desc: '',
      args: [],
    );
  }

  /// `Speaking`
  String get groupCallSpeaking {
    return Intl.message(
      'Speaking',
      name: 'groupCallSpeaking',
      desc: '',
      args: [],
    );
  }

  /// `Muted`
  String get groupCallMuted {
    return Intl.message('Muted', name: 'groupCallMuted', desc: '', args: []);
  }

  /// `Camera Off`
  String get groupCallCameraOff {
    return Intl.message(
      'Camera Off',
      name: 'groupCallCameraOff',
      desc: '',
      args: [],
    );
  }

  /// `Group call init failed`
  String get groupCallInitFailed {
    return Intl.message(
      'Group call init failed',
      name: 'groupCallInitFailed',
      desc: '',
      args: [],
    );
  }

  /// `Join group call failed`
  String get groupCallJoinFailed {
    return Intl.message(
      'Join group call failed',
      name: 'groupCallJoinFailed',
      desc: '',
      args: [],
    );
  }

  /// `Create group call failed`
  String get groupCallCreateFailed {
    return Intl.message(
      'Create group call failed',
      name: 'groupCallCreateFailed',
      desc: '',
      args: [],
    );
  }

  /// `Network error, please try again`
  String get groupCallNetworkError {
    return Intl.message(
      'Network error, please try again',
      name: 'groupCallNetworkError',
      desc: '',
      args: [],
    );
  }

  /// `Group call is full`
  String get groupCallMembersFull {
    return Intl.message(
      'Group call is full',
      name: 'groupCallMembersFull',
      desc: '',
      args: [],
    );
  }

  /// `Group call ended`
  String get groupCallEnded {
    return Intl.message(
      'Group call ended',
      name: 'groupCallEnded',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
