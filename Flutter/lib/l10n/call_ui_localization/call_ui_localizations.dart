// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'call_ui_localizations_en.dart';
import 'call_ui_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of CallKitClientLocalizations
/// returned by `CallKitClientLocalizations.of(context)`.
///
/// Applications need to include `CallKitClientLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'call_ui_localization/call_ui_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: CallKitClientLocalizations.localizationsDelegates,
///   supportedLocales: CallKitClientLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the CallKitClientLocalizations.supportedLocales
/// property.
abstract class CallKitClientLocalizations {
  CallKitClientLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static CallKitClientLocalizations? of(BuildContext context) {
    return Localizations.of<CallKitClientLocalizations>(context, CallKitClientLocalizations);
  }

  static const LocalizationsDelegate<CallKitClientLocalizations> delegate = _CallKitClientLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @youHaveANewCall.
  ///
  /// In en, this message translates to:
  /// **'You have a new call'**
  String get youHaveANewCall;

  /// No description provided for @initEngineFail.
  ///
  /// In en, this message translates to:
  /// **'Init engine failed'**
  String get initEngineFail;

  /// No description provided for @callFailedUserIdEmpty.
  ///
  /// In en, this message translates to:
  /// **'Call failed, userId is empty'**
  String get callFailedUserIdEmpty;

  /// No description provided for @permissionResultFail.
  ///
  /// In en, this message translates to:
  /// **'Permission result fail'**
  String get permissionResultFail;

  /// No description provided for @startCameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Start camera permission denied.'**
  String get startCameraPermissionDenied;

  /// No description provided for @startMicrophonePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Start microphone permission denied.'**
  String get startMicrophonePermissionDenied;

  /// No description provided for @applyForMicrophonePermission.
  ///
  /// In en, this message translates to:
  /// **'apply for microphone permission'**
  String get applyForMicrophonePermission;

  /// No description provided for @applyForCameraPermission.
  ///
  /// In en, this message translates to:
  /// **'apply for camera permission'**
  String get applyForCameraPermission;

  /// No description provided for @applyForMicrophoneAndCameraPermissions.
  ///
  /// In en, this message translates to:
  /// **'apply for microphone and camera permissions'**
  String get applyForMicrophoneAndCameraPermissions;

  /// No description provided for @needToAccessMicrophonePermission.
  ///
  /// In en, this message translates to:
  /// **'need to access microphone permission'**
  String get needToAccessMicrophonePermission;

  /// No description provided for @needToAccessCameraPermission.
  ///
  /// In en, this message translates to:
  /// **'need to access camera permission'**
  String get needToAccessCameraPermission;

  /// No description provided for @errorInPeerBlacklist.
  ///
  /// In en, this message translates to:
  /// **'error in peer blacklist'**
  String get errorInPeerBlacklist;

  /// No description provided for @insufficientPermissions.
  ///
  /// In en, this message translates to:
  /// **'insufficient permissions'**
  String get insufficientPermissions;

  /// No description provided for @displayPopUpWindowWhileRunningInTheBackgroundAndDisplayPopUpWindowPermissions.
  ///
  /// In en, this message translates to:
  /// **'display popUpWindow while running in the background and display popUpWindow permissions'**
  String get displayPopUpWindowWhileRunningInTheBackgroundAndDisplayPopUpWindowPermissions;

  /// No description provided for @needToAccessMicrophoneAndCameraPermissions.
  ///
  /// In en, this message translates to:
  /// **'need to access microphone and camera permissions'**
  String get needToAccessMicrophoneAndCameraPermissions;

  /// No description provided for @noFloatWindowPermission.
  ///
  /// In en, this message translates to:
  /// **'no float window permission'**
  String get noFloatWindowPermission;

  /// No description provided for @needFloatWindowPermission.
  ///
  /// In en, this message translates to:
  /// **'need float window permission'**
  String get needFloatWindowPermission;

  /// No description provided for @noBackgroundStartPermission.
  ///
  /// In en, this message translates to:
  /// **'no background start permission'**
  String get noBackgroundStartPermission;

  /// No description provided for @needBackgroundStartPermission.
  ///
  /// In en, this message translates to:
  /// **'Your phone has not granted background start permission, minimizing calls may not work properly'**
  String get needBackgroundStartPermission;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'accept'**
  String get accept;

  /// No description provided for @cameraIsOn.
  ///
  /// In en, this message translates to:
  /// **'cameraIsOn'**
  String get cameraIsOn;

  /// No description provided for @cameraIsOff.
  ///
  /// In en, this message translates to:
  /// **'cameraIsOff'**
  String get cameraIsOff;

  /// No description provided for @speakerIsOn.
  ///
  /// In en, this message translates to:
  /// **'speakerIsOn'**
  String get speakerIsOn;

  /// No description provided for @speakerIsOff.
  ///
  /// In en, this message translates to:
  /// **'speakerIsOff'**
  String get speakerIsOff;

  /// No description provided for @microphoneIsOn.
  ///
  /// In en, this message translates to:
  /// **'microphoneIsOn'**
  String get microphoneIsOn;

  /// No description provided for @microphoneIsOff.
  ///
  /// In en, this message translates to:
  /// **'microphoneIsOff'**
  String get microphoneIsOff;

  /// No description provided for @blurBackground.
  ///
  /// In en, this message translates to:
  /// **'blurBackground'**
  String get blurBackground;

  /// No description provided for @switchCamera.
  ///
  /// In en, this message translates to:
  /// **'switchCamera'**
  String get switchCamera;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'waiting'**
  String get waiting;

  /// No description provided for @hangUp.
  ///
  /// In en, this message translates to:
  /// **'hangUp'**
  String get hangUp;

  /// No description provided for @userBusy.
  ///
  /// In en, this message translates to:
  /// **'Other party is busy'**
  String get userBusy;

  /// No description provided for @userInCall.
  ///
  /// In en, this message translates to:
  /// **'User is already in a call'**
  String get userInCall;

  /// No description provided for @answerOnOtherDevice.
  ///
  /// In en, this message translates to:
  /// **'The other client has answered the call'**
  String get answerOnOtherDevice;

  /// No description provided for @rejectOnOtherDevice.
  ///
  /// In en, this message translates to:
  /// **'The other client has rejected the call'**
  String get rejectOnOtherDevice;

  /// No description provided for @remoteUserReject.
  ///
  /// In en, this message translates to:
  /// **'remote user rejected'**
  String get remoteUserReject;

  /// No description provided for @remoteTimeout.
  ///
  /// In en, this message translates to:
  /// **'Timeout and no response'**
  String get remoteTimeout;

  /// No description provided for @remoteCancel.
  ///
  /// In en, this message translates to:
  /// **'The call was canceled'**
  String get remoteCancel;

  /// No description provided for @groupCallInvitation.
  ///
  /// In en, this message translates to:
  /// **'Group Call Invitation'**
  String get groupCallInvitation;

  /// No description provided for @groupCallWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get groupCallWaiting;

  /// No description provided for @groupCallInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Call'**
  String get groupCallInProgress;

  /// No description provided for @groupCallDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get groupCallDuration;

  /// No description provided for @groupCallInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get groupCallInvite;

  /// No description provided for @groupCallIgnore.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get groupCallIgnore;

  /// No description provided for @groupCallJoining.
  ///
  /// In en, this message translates to:
  /// **'Joining...'**
  String get groupCallJoining;

  /// No description provided for @groupCallConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get groupCallConnecting;

  /// No description provided for @groupCallMemberJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get groupCallMemberJoined;

  /// No description provided for @groupCallMemberLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get groupCallMemberLeft;

  /// No description provided for @groupCallInviteYouToJoin.
  ///
  /// In en, this message translates to:
  /// **'invites you to join group call'**
  String get groupCallInviteYouToJoin;

  /// No description provided for @groupCallOtherMembers.
  ///
  /// In en, this message translates to:
  /// **'and {count} others'**
  String groupCallOtherMembers(Object count);

  /// No description provided for @groupCallToggleMic.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get groupCallToggleMic;

  /// No description provided for @groupCallToggleCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get groupCallToggleCamera;

  /// No description provided for @groupCallToggleSpeaker.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get groupCallToggleSpeaker;

  String get groupCallMicOn;
  String get groupCallMicOff;
  String get groupCallSpeakerOn;
  String get groupCallSpeakerOff;
  String get groupCallCameraOn;

  /// No description provided for @groupCallSwitchCamera.
  ///
  /// In en, this message translates to:
  /// **'Switch Camera'**
  String get groupCallSwitchCamera;

  /// No description provided for @groupCallMinimize.
  ///
  /// In en, this message translates to:
  /// **'Minimize'**
  String get groupCallMinimize;

  /// No description provided for @groupCallInviteMore.
  ///
  /// In en, this message translates to:
  /// **'Invite More'**
  String get groupCallInviteMore;

  /// No description provided for @groupCallNoVideo.
  ///
  /// In en, this message translates to:
  /// **'Video not enabled'**
  String get groupCallNoVideo;

  /// No description provided for @groupCallSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Speaking'**
  String get groupCallSpeaking;

  /// No description provided for @groupCallMuted.
  ///
  /// In en, this message translates to:
  /// **'Muted'**
  String get groupCallMuted;

  /// No description provided for @groupCallCameraOff.
  ///
  /// In en, this message translates to:
  /// **'Camera Off'**
  String get groupCallCameraOff;

  /// No description provided for @groupCallInitFailed.
  ///
  /// In en, this message translates to:
  /// **'Group call init failed'**
  String get groupCallInitFailed;

  /// No description provided for @groupCallJoinFailed.
  ///
  /// In en, this message translates to:
  /// **'Join group call failed'**
  String get groupCallJoinFailed;

  /// No description provided for @groupCallCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Create group call failed'**
  String get groupCallCreateFailed;

  /// No description provided for @groupCallNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network error, please try again'**
  String get groupCallNetworkError;

  /// No description provided for @groupCallMembersFull.
  ///
  /// In en, this message translates to:
  /// **'Group call is full'**
  String get groupCallMembersFull;

  /// No description provided for @groupCallEnded.
  ///
  /// In en, this message translates to:
  /// **'Group call ended'**
  String get groupCallEnded;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @goToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get goToSettings;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;

  /// No description provided for @groupCallOthersInCall.
  ///
  /// In en, this message translates to:
  /// **'{count} others in call:'**
  String groupCallOthersInCall(Object count);
}

class _CallKitClientLocalizationsDelegate extends LocalizationsDelegate<CallKitClientLocalizations> {
  const _CallKitClientLocalizationsDelegate();

  @override
  Future<CallKitClientLocalizations> load(Locale locale) {
    return SynchronousFuture<CallKitClientLocalizations>(lookupCallKitClientLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_CallKitClientLocalizationsDelegate old) => false;
}

CallKitClientLocalizations lookupCallKitClientLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return CallKitClientLocalizationsEn();
    case 'zh': return CallKitClientLocalizationsZh();
  }

  throw FlutterError(
    'CallKitClientLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
