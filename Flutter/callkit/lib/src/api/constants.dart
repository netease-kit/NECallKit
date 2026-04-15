// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of 'package:netease_callkit/netease_callkit.dart';

/// Collection of error codes that can occur during calls.
///
/// These values are typically returned by the SDK or included in
/// [SimpleResponse] instances to indicate specific failure states.
class NECallError {
  /// Unknown error.
  static const int unKnow = -1;

  /// Invalid state: already in calling state when placing a new call.
  static const int stateCallCalling = 20002;

  /// Invalid state: already in called state when placing a new call.
  static const int stateCallCalled = 20003;

  /// Invalid state: already in an active call when placing a new call.
  static const int stateCallOnTheCall = 20004;

  /// Invalid state: hangup requested while idle.
  static const int stateHangupIdle = 20005;

  /// Invalid state: leave requested while idle.
  static const int stateLeaveIdle = 20009;

  /// Invalid state: leave requested while calling.
  static const int stateLeaveCalling = 20010;

  /// Invalid state: leave requested while called.
  static const int stateLeaveCalled = 20011;

  /// Invalid state: cancel requested while idle.
  static const int stateCancelIdle = 20013;

  /// Invalid state: cancel requested while called.
  static const int stateCancelCalled = 20015;

  /// Invalid state: cancel requested while in an active call.
  static const int stateCancelOnTheCall = 20016;

  /// Invalid state: accept requested while idle.
  static const int stateAcceptIdle = 20017;

  /// Invalid state: accept requested while calling.
  static const int stateAcceptCalling = 20018;

  /// Invalid state: accept requested while already in a call.
  static const int stateAcceptOnTheCall = 20020;

  /// Invalid state: reject requested while idle.
  static const int stateRejectIdle = 20021;

  /// Invalid state: reject requested while calling.
  static const int stateRejectCalling = 20022;

  /// Invalid state: reject requested while already in a call.
  static const int stateRejectOnTheCall = 20024;

  /// Invalid state: switch requested while idle.
  static const int stateSwitchIdle = 20025;

  /// Invalid state: switch requested while calling.
  static const int stateSwitchCalling = 20026;

  /// Invalid state: switch requested while called.
  static const int stateSwitchCalled = 20027;

  /// Invalid state: group invite requested while idle.
  static const int stateGroupInviteIdle = 20029;

  /// Invalid state: group invite requested while called.
  static const int stateGroupInviteCalled = 20031;
}
