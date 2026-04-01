// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// Convenience utilities for accessing CallKit localizations.
///
/// This library provides a simplified interface for accessing localized
/// strings in CallKit UI components, with support for default language
/// preferences and fallback mechanisms.
library l10n;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:netease_callkit_ui/l10n/call_ui_localization/call_ui_localizations.dart';
import 'package:netease_callkit_ui/l10n/call_ui_localization/call_ui_localizations_en.dart';
import 'package:netease_callkit_ui/l10n/call_ui_localization/call_ui_localizations_zh.dart';
import 'default_language.dart';

/// A convenience class for accessing CallKit localizations.
///
/// This class provides static methods to retrieve localized strings with
/// intelligent fallback logic:
///
/// 1. First checks the default language preference from [DefaultLanguage]
/// 2. Falls back to [BuildContext] if provided
/// 3. Finally uses the system locale or defaults to English
///
/// Example usage:
///
/// ```dart
/// final localizations = S.of(context);
/// final message = localizations.youHaveANewCall;
/// ```
///
/// See also:
/// - [CallKitClientLocalizations], the base localization class
/// - [delegate], the localization delegate for use in MaterialApp
class S {
  /// The [LocalizationsDelegate] for CallKit localizations.
  ///
  /// This delegate can be used in MaterialApp's `localizationsDelegates` list
  /// to enable CallKit localization support.
  ///
  /// See also:
  /// - [CallKitClientLocalizations.delegate], the underlying delegate
  static const LocalizationsDelegate<CallKitClientLocalizations> delegate =
      CallKitClientLocalizations.delegate;

  /// Retrieves the appropriate [CallKitClientLocalizations] instance.
  ///
  /// This method provides a convenient way to get localizations with intelligent
  /// fallback logic:
  ///
  /// 1. If [DefaultLanguage] is set to Chinese, returns Chinese localizations
  /// 2. If [DefaultLanguage] is set to English, returns English localizations
  /// 3. If [context] is provided, attempts to get localizations from the widget tree
  /// 4. Falls back to system locale or defaults to English
  ///
  /// The [context] parameter is optional. If provided, the method will attempt
  /// to retrieve localizations from the widget tree first.
  ///
  /// Returns a [CallKitClientLocalizations] instance, never null (defaults to
  /// English if all other methods fail).
  ///
  /// Example:
  ///
  /// ```dart
  /// // With context
  /// final localizations = S.of(context);
  ///
  /// // Without context (uses default language or system locale)
  /// final localizations = S.of();
  /// ```
  static CallKitClientLocalizations of([BuildContext? context]) {
    CallKitClientLocalizations? localizations;
    if (DefaultLanguage.defaultLanguage == languageZh) {
      return CallKitClientLocalizationsZh();
    }
    if (DefaultLanguage.defaultLanguage == languageEn) {
      return CallKitClientLocalizationsEn();
    }
    if (context != null) {
      localizations = CallKitClientLocalizations.of(context);
    }
    if (localizations == null) {
      var local = PlatformDispatcher.instance.locale;
      try {
        localizations = lookupCallKitClientLocalizations(local);
      } catch (e) {
        localizations = CallKitClientLocalizationsEn();
      }
    }
    return localizations;
  }
}
