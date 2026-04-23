// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

enum AuthState {
  init,
  authed,
  tokenIllegal,
  kicked,
}

class AuthStateSnapshot {
  const AuthStateSnapshot({
    required this.state,
    this.errorTip,
  });

  final AuthState state;
  final String? errorTip;
}

class AuthStateManager {
  static AuthStateManager? _instance;
  AuthState _state = AuthState.init;
  String? _errorTip;
  final StreamController<AuthStateSnapshot> _changes =
      StreamController<AuthStateSnapshot>.broadcast();

  factory AuthStateManager() => _instance ??= AuthStateManager._internal();

  AuthStateManager._internal();

  AuthState get state => _state;
  String? get errorTip => _errorTip;
  AuthStateSnapshot get snapshot =>
      AuthStateSnapshot(state: _state, errorTip: _errorTip);

  Stream<AuthStateSnapshot> changes() => _changes.stream;

  void updateState({required AuthState state, String? errorTip}) {
    _state = state;
    _errorTip = errorTip;
    _changes.add(snapshot);
  }
}
