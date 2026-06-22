// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:netease_callkit_ui/src/data/constants.dart';
import 'package:netease_callkit_ui/src/event/event_notify.dart';
import 'package:netease_callkit_ui/src/platform/call_kit_runtime_adapter.dart';
import 'package:netease_callkit_ui/src/ui/widget/common/extent_button.dart';
import 'package:netease_callkit_ui/src/utils/permission.dart';

import 'calls_widget.dart';

class CallsFunctionWidget {
  static const String _tag = 'CallsFunctionWidget';
  static const CallKitRuntimeAdapter _runtimeAdapter = CallKitRuntimeAdapter();
  static bool _isAccepting = false; // 添加接听状态标志
  @visibleForTesting
  static bool? desktopRuntimeOverride;
  static bool get _isDesktopRuntime =>
      desktopRuntimeOverride ?? Platform.isMacOS || Platform.isWindows;

  @visibleForTesting
  static const Key microphoneButtonKey =
      ValueKey<String>('callkit_microphone_button');
  @visibleForTesting
  static const Key speakerButtonKey =
      ValueKey<String>('callkit_speaker_button');
  @visibleForTesting
  static const Key cameraButtonKey = ValueKey<String>('callkit_camera_button');
  @visibleForTesting
  static const Key switchCameraButtonKey =
      ValueKey<String>('callkit_switch_camera_button');
  @visibleForTesting
  static const Duration desktopRouteHoverOpenDelay = Duration(seconds: 1);
  @visibleForTesting
  static const Duration desktopRouteHoverTapSuppressDuration =
      Duration(milliseconds: 260);
  @visibleForTesting
  static const double desktopRouteMenuGap = 4;
  @visibleForTesting
  static const double desktopRouteMenuVerticalPadding = 16;
  @visibleForTesting
  static const double desktopRouteMenuItemHeight = kMinInteractiveDimension;
  @visibleForTesting
  static const double desktopRouteMenuDividerHeight = 1;

  // 备用网络图片URL常量
  static const String _hangupNetworkUrl =
      'https://yx-web-nosdn.netease.im/common/e2ca6c0b7a35174efde6e3ec7eaf1609/hangup.png';
  static const String _acceptNetworkUrl =
      'https://yx-web-nosdn.netease.im/common/ed23abfde97d28036502095c071264e6/dialing.png';
  static const String _acceptVideoNetworkUrl =
      'https://yx-web-nosdn.netease.im/common/eeb01ce8ca84a9f5a749c5d88babcea4/dialing_video.png';

  /// 根据通话类型获取接听按钮图片路径
  /// 视频通话使用 dialing_video.png，音频通话使用 dialing.png
  static String _getAcceptButtonImage() {
    return CallState.instance.callType == NECallType.video
        ? 'assets/images/dialing_video.png'
        : 'assets/images/dialing.png';
  }

  /// 根据通话类型获取接听按钮备用网络图片URL
  /// 视频通话使用 _acceptVideoNetworkUrl，音频通话使用 _acceptNetworkUrl
  static String _getAcceptButtonNetworkUrl() {
    return CallState.instance.callType == NECallType.video
        ? _acceptVideoNetworkUrl
        : _acceptNetworkUrl;
  }

  @visibleForTesting
  static bool shouldShowDesktopSwitchCameraShortcut({
    required bool isDesktopRuntime,
  }) {
    return !isDesktopRuntime;
  }

  @visibleForTesting
  static bool shouldOpenDesktopRouteMenuOnHover({
    required bool menuOpen,
    required bool pointerDown,
    required DateTime now,
    DateTime? suppressHoverUntil,
  }) {
    if (menuOpen || pointerDown) {
      return false;
    }
    if (suppressHoverUntil != null && now.isBefore(suppressHoverUntil)) {
      return false;
    }
    return true;
  }

  @visibleForTesting
  static double estimateDesktopRouteMenuHeight({
    required int deviceCount,
  }) {
    final deviceTotal = math.max(0, deviceCount);
    final itemCount = 2 + deviceTotal;
    final dividerCount = deviceTotal > 0 ? 2 : 1;
    return desktopRouteMenuVerticalPadding +
        (itemCount * desktopRouteMenuItemHeight) +
        (dividerCount * desktopRouteMenuDividerHeight);
  }

  @visibleForTesting
  static RelativeRect buildDesktopRouteMenuPosition({
    required Rect buttonRect,
    required Size overlaySize,
    required int deviceCount,
  }) {
    final menuHeight = estimateDesktopRouteMenuHeight(deviceCount: deviceCount);
    final menuTop = math.max(
      0.0,
      buttonRect.top - menuHeight - desktopRouteMenuGap,
    );
    return RelativeRect.fromRect(
      Rect.fromLTWH(
        buttonRect.left,
        menuTop,
        buttonRect.width,
        buttonRect.height,
      ),
      Offset.zero & overlaySize,
    );
  }

  static Widget buildIndividualFunctionWidget(Function close) {
    if (NECallStatus.waiting == CallState.instance.selfUser.callStatus) {
      if (NECallRole.caller == CallState.instance.selfUser.callRole) {
        if (NECallType.audio == CallState.instance.callType) {
          return _buildAudioCallerWaitingAndAcceptedView(close);
        } else {
          if (CallState.instance.showVirtualBackgroundButton) {
            return _buildVBgVideoCallerWaitingView(close);
          } else {
            return _buildVideoCallerWaitingView(close);
          }
        }
      } else {
        // 每次显示接听页面时重置接听状态标志
        _isAccepting = false;
        return _buildAudioAndVideoCalleeWaitingView(close);
      }
    } else if (NECallStatus.accept == CallState.instance.selfUser.callStatus) {
      if (NECallType.audio == CallState.instance.callType) {
        return _buildAudioCallerWaitingAndAcceptedView(close);
      } else {
        return _buildVideoCallerAndCalleeAcceptedView(close);
      }
    } else {
      return Container();
    }
  }

  static Widget buildMultiCallFunctionWidget(
      BuildContext context, Function close) {
    Widget functionWidget;
    if (NECallStatus.waiting == CallState.instance.selfUser.callStatus &&
        NECallRole.called == CallState.instance.selfUser.callRole) {
      // 每次显示接听页面时重置接听状态标志
      _isAccepting = false;
      functionWidget = _buildAudioAndVideoCalleeWaitingFunctionView(close);
    } else {
      functionWidget =
          _buildVideoCallerAndCalleeAcceptedFunctionView(context, close);
    }

    return functionWidget;
  }

  static Widget _buildAudioAndVideoCalleeWaitingFunctionView(Function close) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ExtendButton(
              imgUrl: 'assets/images/hangup.png',
              fallbackNetworkUrl: _hangupNetworkUrl,
              tips: NECallKitUI.localizations.hangUp,
              textColor: Colors.white,
              imgHeight: 64,
              onTap: () {
                _handleReject(close);
              },
            ),
            ExtendButton(
              imgUrl: _getAcceptButtonImage(),
              fallbackNetworkUrl: _getAcceptButtonNetworkUrl(),
              tips: NECallKitUI.localizations.accept,
              textColor: Colors.white,
              imgHeight: 64,
              onTap: () {
                _handleAccept(close);
              },
            ),
          ],
        ),
        const SizedBox(height: 80)
      ],
    );
  }

  static Widget _buildVideoCallerAndCalleeAcceptedFunctionView(
      BuildContext context, Function close) {
    double bigBtnHeight = 52;
    double smallBtnHeight = 35;
    double edge = 40;
    double bottomEdge = 10;
    var duration = 300;
    var btnWidth = 100;
    Curve curve = Curves.easeInOut;
    return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        child: GestureDetector(
            onVerticalDragUpdate: _functionWidgetVerticalDragUpdate,
            child: AnimatedContainer(
                curve: curve,
                height: CallsWidget.isFunctionExpand ? 200 : 90,
                duration: Duration(milliseconds: duration),
                color: const Color.fromRGBO(52, 56, 66, 1.0),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      curve: curve,
                      duration: Duration(milliseconds: duration),
                      left: CallsWidget.isFunctionExpand
                          ? ((MediaQuery.of(context).size.width / 4) -
                              (btnWidth / 2))
                          : (MediaQuery.of(context).size.width * 2 / 6 -
                              btnWidth / 2),
                      bottom: CallsWidget.isFunctionExpand
                          ? bottomEdge + bigBtnHeight + edge
                          : bottomEdge,
                      child: ExtendButton(
                        imgUrl: CallState.instance.isMicrophoneMute
                            ? 'assets/images/mute_on.png'
                            : 'assets/images/mute.png',
                        tips: CallsWidget.isFunctionExpand
                            ? (CallState.instance.isMicrophoneMute
                                ? NECallKitUI.localizations.microphoneIsOff
                                : NECallKitUI.localizations.microphoneIsOn)
                            : '',
                        textColor: Colors.white,
                        imgHeight: CallsWidget.isFunctionExpand
                            ? bigBtnHeight
                            : smallBtnHeight,
                        onTap: _handleSwitchMic,
                        userAnimation: true,
                        duration: Duration(milliseconds: duration),
                      ),
                    ),
                    AnimatedPositioned(
                      curve: curve,
                      duration: Duration(milliseconds: duration),
                      left: CallsWidget.isFunctionExpand
                          ? (MediaQuery.of(context).size.width / 2 -
                              btnWidth / 2)
                          : (MediaQuery.of(context).size.width * 3 / 6 -
                              btnWidth / 2),
                      bottom: CallsWidget.isFunctionExpand
                          ? bottomEdge + bigBtnHeight + edge
                          : bottomEdge,
                      child: ExtendButton(
                        imgUrl: CallState.instance.isEnableSpeaker
                            ? 'assets/images/handsfree_on.png'
                            : 'assets/images/handsfree.png',
                        tips: CallsWidget.isFunctionExpand
                            ? (CallState.instance.isEnableSpeaker
                                ? NECallKitUI.localizations.speakerIsOn
                                : NECallKitUI.localizations.speakerIsOff)
                            : '',
                        textColor: Colors.white,
                        imgHeight: CallsWidget.isFunctionExpand
                            ? bigBtnHeight
                            : smallBtnHeight,
                        onTap: _handleSwitchAudioDevice,
                        userAnimation: true,
                        duration: Duration(milliseconds: duration),
                      ),
                    ),
                    AnimatedPositioned(
                      curve: curve,
                      duration: Duration(milliseconds: duration),
                      left: CallsWidget.isFunctionExpand
                          ? (MediaQuery.of(context).size.width * 3 / 4 -
                              btnWidth / 2)
                          : (MediaQuery.of(context).size.width * 4 / 6 -
                              btnWidth / 2),
                      bottom: CallsWidget.isFunctionExpand
                          ? bottomEdge + bigBtnHeight + edge
                          : bottomEdge,
                      child: ExtendButton(
                        imgUrl: CallState.instance.isCameraOpen
                            ? 'assets/images/camera_on.png'
                            : 'assets/images/camera_off.png',
                        tips: CallsWidget.isFunctionExpand
                            ? (CallState.instance.isCameraOpen
                                ? NECallKitUI.localizations.cameraIsOn
                                : NECallKitUI.localizations.cameraIsOff)
                            : '',
                        textColor: Colors.white,
                        imgHeight: CallsWidget.isFunctionExpand
                            ? bigBtnHeight
                            : smallBtnHeight,
                        onTap: _handleOpenCloseCamera,
                        userAnimation: true,
                        duration: Duration(milliseconds: duration),
                      ),
                    ),
                    AnimatedPositioned(
                      curve: curve,
                      duration: Duration(milliseconds: duration),
                      left: CallsWidget.isFunctionExpand
                          ? (MediaQuery.of(context).size.width / 2 -
                              btnWidth / 2)
                          : (MediaQuery.of(context).size.width * 5 / 6 -
                              btnWidth / 2),
                      bottom: bottomEdge,
                      child: ExtendButton(
                        imgUrl: 'assets/images/hangup.png',
                        fallbackNetworkUrl: _hangupNetworkUrl,
                        textColor: Colors.white,
                        imgHeight: CallsWidget.isFunctionExpand
                            ? bigBtnHeight
                            : smallBtnHeight,
                        onTap: () {
                          _handleHangUp(close);
                        },
                        userAnimation: true,
                        duration: Duration(milliseconds: duration),
                      ),
                    ),
                    AnimatedPositioned(
                        curve: curve,
                        duration: Duration(milliseconds: duration),
                        left: (MediaQuery.of(context).size.width / 6 -
                            smallBtnHeight / 2),
                        bottom: CallsWidget.isFunctionExpand
                            ? bottomEdge + smallBtnHeight / 4 + 22
                            : bottomEdge + 22,
                        child: InkWell(
                          onTap: () {
                            CallsWidget.isFunctionExpand =
                                !CallsWidget.isFunctionExpand;
                            NEEventNotify().notify(
                              setStateEvent,
                              {'refreshVideoViews': false},
                            );
                          },
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.diagonal3Values(1.0,
                                CallsWidget.isFunctionExpand ? 1.0 : -1.0, 1.0),
                            child: Image.asset(
                              'assets/images/arrow.png',
                              package: 'netease_callkit_ui',
                              width: smallBtnHeight,
                            ),
                          ),
                        ))
                  ],
                ))));
  }

  static void _functionWidgetVerticalDragUpdate(DragUpdateDetails details) {
    if (details.delta.dy < 0 && !CallsWidget.isFunctionExpand) {
      CallsWidget.isFunctionExpand = true;
    } else if (details.delta.dy > 0 && CallsWidget.isFunctionExpand) {
      CallsWidget.isFunctionExpand = false;
    }
    NEEventNotify().notify(setStateEventGroupCallUserWidgetRefresh);
  }

  static Widget _buildAudioCallerWaitingAndAcceptedView(Function close) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildMicControlButton(),
        _buildHangupButton(close),
        _buildSpeakerphoneButton(),
      ],
    );
  }

  static Widget _buildVideoCallerWaitingView(Function close) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _buildHangupButton(close),
        ]),
      ],
    );
  }

  static Widget _buildVBgVideoCallerWaitingView(Function close) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSwitchCameraButton(),
            _buildVirtualBackgroundButton(),
            _buildCameraControlButton(),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(
              width: 100,
            ),
            _buildHangupButton(close),
            const SizedBox(
              width: 100,
            ),
          ],
        ),
      ],
    );
  }

  static Widget _buildVideoCallerAndCalleeAcceptedView(Function close) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMicControlButton(),
            _buildSpeakerphoneButton(),
            _buildCameraControlButton(),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          CallState.instance.showVirtualBackgroundButton
              ? _buildVirtualBackgroundSmallButton()
              : const SizedBox(
                  width: 100,
                ),
          _buildHangupButton(close),
          CallState.instance.isCameraOpen
              ? _buildSwitchCameraSmallButton()
              : const SizedBox(
                  width: 100,
                ),
        ]),
      ],
    );
  }

  static Widget _buildAudioAndVideoCalleeWaitingView(Function close) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ExtendButton(
              imgUrl: 'assets/images/hangup.png',
              fallbackNetworkUrl: _hangupNetworkUrl,
              tips: NECallKitUI.localizations.hangUp,
              textColor: _getTextColor(),
              imgHeight: 60,
              onTap: () {
                _handleReject(close);
              },
            ),
            ExtendButton(
              imgUrl: _getAcceptButtonImage(),
              fallbackNetworkUrl: _getAcceptButtonNetworkUrl(),
              tips: NECallKitUI.localizations.accept,
              textColor: _getTextColor(),
              imgHeight: 60,
              onTap: () {
                _handleAccept(close);
              },
            ),
          ],
        )
      ],
    );
  }

  static Future<void> _handleSwitchMic() async {
    if (CallState.instance.isMicrophoneMute) {
      CallState.instance.isMicrophoneMute = false;
      await CallManager.instance.openMicrophone();
    } else {
      CallState.instance.isMicrophoneMute = true;
      await CallManager.instance.closeMicrophone();
    }
    NEEventNotify().notify(
      setStateEvent,
      {'refreshVideoViews': false},
    );
  }

  static Future<void> _handleSwitchAudioDevice() async {
    final previousSpeakerState = CallState.instance.isEnableSpeaker;
    final targetSpeakerState = !previousSpeakerState;
    CallState.instance.isEnableSpeaker = targetSpeakerState;
    final result = await CallManager.instance.setSpeakerphoneOn(
      targetSpeakerState,
    );
    if (result.code != 0) {
      CallState.instance.isEnableSpeaker = previousSpeakerState;
      if (result.message != null && result.message!.isNotEmpty) {
        CallManager.instance.showToast(result.message!);
      }
    }
    NEEventNotify().notify(
      setStateEvent,
      {'refreshVideoViews': false},
    );
  }

  static Widget _buildSpeakerphoneButton() {
    if (_isDesktopRuntime) {
      return _DesktopHoverRouteButton(
        buttonKey: speakerButtonKey,
        imgUrl: CallState.instance.isEnableSpeaker
            ? 'assets/images/handsfree_on.png'
            : 'assets/images/handsfree.png',
        tips: CallState.instance.isEnableSpeaker
            ? NECallKitUI.localizations.speakerIsOn
            : NECallKitUI.localizations.speakerIsOff,
        textColor: _getTextColor(),
        imgHeight: 60,
        menuTitle: NECallKitUI.localizations.chooseSpeaker,
        toggleLabelWhenEnabled: NECallKitUI.localizations.closeSpeaker,
        toggleLabelWhenDisabled: NECallKitUI.localizations.openSpeaker,
        isEnabled: CallState.instance.isEnableSpeaker,
        onPrimaryTap: _handleSwitchAudioDevice,
        loadDevices: () async {
          final devices =
              await CallManager.instance.getDesktopAudioPlaybackDevices();
          return devices
              .map(
                (device) => _DesktopRouteDeviceOption(
                  deviceId: device.deviceId,
                  displayName: device.displayName,
                ),
              )
              .toList(growable: false);
        },
        loadCurrentDeviceId: () async {
          return CallManager.instance.getCurrentDesktopAudioPlaybackDeviceId();
        },
        onDeviceSelected: _handleDesktopAudioPlaybackDeviceSelected,
      );
    }
    return ExtendButton(
      key: speakerButtonKey,
      imgUrl: CallState.instance.isEnableSpeaker
          ? 'assets/images/handsfree_on.png'
          : 'assets/images/handsfree.png',
      tips: CallState.instance.isEnableSpeaker
          ? NECallKitUI.localizations.speakerIsOn
          : NECallKitUI.localizations.speakerIsOff,
      textColor: _getTextColor(),
      imgHeight: 60,
      onTap: _handleSwitchAudioDevice,
    );
  }

  static Widget _buildCameraControlButton() {
    if (_isDesktopRuntime) {
      return _DesktopHoverRouteButton(
        buttonKey: cameraButtonKey,
        imgUrl: CallState.instance.isCameraOpen
            ? 'assets/images/camera_on.png'
            : 'assets/images/camera_off.png',
        tips: CallState.instance.isCameraOpen
            ? NECallKitUI.localizations.cameraIsOn
            : NECallKitUI.localizations.cameraIsOff,
        textColor: _getTextColor(),
        imgHeight: 60,
        menuTitle: NECallKitUI.localizations.chooseCamera,
        toggleLabelWhenEnabled: NECallKitUI.localizations.closeCamera,
        toggleLabelWhenDisabled: NECallKitUI.localizations.openCamera,
        isEnabled: CallState.instance.isCameraOpen,
        onPrimaryTap: _handleOpenCloseCamera,
        loadDevices: () async {
          final devices =
              await CallManager.instance.getDesktopVideoCaptureDevices();
          return devices
              .map(
                (device) => _DesktopRouteDeviceOption(
                  deviceId: device.deviceId,
                  displayName: device.displayName,
                ),
              )
              .toList(growable: false);
        },
        loadCurrentDeviceId: () async {
          return CallManager.instance.getCurrentDesktopVideoCaptureDeviceId();
        },
        onDeviceSelected: _handleDesktopVideoCaptureDeviceSelected,
      );
    }
    return ExtendButton(
      key: cameraButtonKey,
      imgUrl: CallState.instance.isCameraOpen
          ? 'assets/images/camera_on.png'
          : 'assets/images/camera_off.png',
      tips: CallState.instance.isCameraOpen
          ? NECallKitUI.localizations.cameraIsOn
          : NECallKitUI.localizations.cameraIsOff,
      textColor: _getTextColor(),
      imgHeight: 60,
      onTap: _handleOpenCloseCamera,
    );
  }

  static Widget _buildMicControlButton() {
    if (_isDesktopRuntime) {
      return _DesktopHoverRouteButton(
        buttonKey: microphoneButtonKey,
        imgUrl: CallState.instance.isMicrophoneMute
            ? 'assets/images/mute_on.png'
            : 'assets/images/mute.png',
        tips: CallState.instance.isMicrophoneMute
            ? NECallKitUI.localizations.microphoneIsOff
            : NECallKitUI.localizations.microphoneIsOn,
        textColor: _getTextColor(),
        imgHeight: 60,
        menuTitle: NECallKitUI.localizations.chooseMicrophone,
        toggleLabelWhenEnabled: NECallKitUI.localizations.closeMicrophone,
        toggleLabelWhenDisabled: NECallKitUI.localizations.openMicrophone,
        isEnabled: !CallState.instance.isMicrophoneMute,
        onPrimaryTap: _handleSwitchMic,
        loadDevices: () async {
          final devices =
              await CallManager.instance.getDesktopAudioRecordingDevices();
          return devices
              .map(
                (device) => _DesktopRouteDeviceOption(
                  deviceId: device.deviceId,
                  displayName: device.displayName,
                ),
              )
              .toList(growable: false);
        },
        loadCurrentDeviceId: () async {
          return CallManager.instance.getCurrentDesktopAudioRecordingDeviceId();
        },
        onDeviceSelected: _handleDesktopAudioRecordingDeviceSelected,
      );
    }
    return ExtendButton(
      key: microphoneButtonKey,
      imgUrl: CallState.instance.isMicrophoneMute
          ? 'assets/images/mute_on.png'
          : 'assets/images/mute.png',
      tips: CallState.instance.isMicrophoneMute
          ? NECallKitUI.localizations.microphoneIsOff
          : NECallKitUI.localizations.microphoneIsOn,
      textColor: _getTextColor(),
      imgHeight: 60,
      onTap: _handleSwitchMic,
    );
  }

  static Widget _buildHangupButton(Function close) {
    return ExtendButton(
      imgUrl: 'assets/images/hangup.png',
      fallbackNetworkUrl: _hangupNetworkUrl,
      tips: NECallKitUI.localizations.hangUp,
      textColor: _getTextColor(),
      imgHeight: 60,
      onTap: () {
        _handleHangUp(close);
      },
    );
  }

  static Widget _buildSwitchCameraSmallButton() {
    if (!shouldShowDesktopSwitchCameraShortcut(
      isDesktopRuntime: _isDesktopRuntime,
    )) {
      return const SizedBox(width: 100);
    }
    return ExtendButton(
      key: switchCameraButtonKey,
      imgUrl: 'assets/images/switch_camera.png',
      tips: '',
      textColor: _getTextColor(),
      imgHeight: 28,
      imgOffsetX: -16,
      onTap: _handleSwitchCamera,
    );
  }

  static Widget _buildVirtualBackgroundSmallButton() {
    return ExtendButton(
      imgUrl: 'assets/images/blur_background_accept.png',
      tips: '',
      textColor: _getTextColor(),
      imgHeight: 28,
      imgOffsetX: 16,
      onTap: _handleOpenBlurBackground,
    );
  }

  static Widget _buildVirtualBackgroundButton() {
    return ExtendButton(
      imgUrl: CallState.instance.enableBlurBackground
          ? 'assets/images/blur_background_waiting_enable.png'
          : 'assets/images/blur_background_waiting_disable.png',
      tips: NECallKitUI.localizations.blurBackground,
      textColor: _getTextColor(),
      imgHeight: 60,
      onTap: _handleOpenBlurBackground,
    );
  }

  static Widget _buildSwitchCameraButton() {
    if (!shouldShowDesktopSwitchCameraShortcut(
      isDesktopRuntime: _isDesktopRuntime,
    )) {
      return const SizedBox(width: 100);
    }
    return ExtendButton(
      key: switchCameraButtonKey,
      imgUrl: 'assets/images/switch_camera_group.png',
      tips: NECallKitUI.localizations.switchCamera,
      textColor: _getTextColor(),
      imgHeight: 60,
      onTap: _handleSwitchCamera,
    );
  }

  static void _handleHangUp(Function close) async {
    await CallManager.instance.hangup();
    close();
  }

  static void _handleReject(Function close) async {
    await CallManager.instance.reject();
    close();
  }

  static void _handleAccept(Function close) async {
    // 防止重复点击
    if (_isAccepting) {
      CallKitUILog.i(
          _tag, '_handleAccept already in progress, ignore duplicate click');
      return;
    }

    _isAccepting = true;
    CallKitUILog.i(_tag, '_handleAccept');

    try {
      final permissionRequestResult =
          await _runtimeAdapter.requestPermissions(CallState.instance.callType);
      if (permissionRequestResult == PermissionResult.granted) {
        CallKitUILog.i(_tag,
            '_handleAccept permissionRequestResult = $permissionRequestResult');
        var result = await CallManager.instance.accept();
        if (result.code == 0) {
          CallState.instance.selfUser.callStatus = NECallStatus.accept;
        } else {
          CallState.instance.selfUser.callStatus = NECallStatus.none;
          close();
        }
      } else {
        if (!_isDesktopRuntime) {
          CallManager.instance
              .showToast(NECallKitUI.localizations.insufficientPermissions);
        }
      }
    } finally {
      _isAccepting = false; // 确保无论成功还是失败都重置状态
    }

    NEEventNotify().notify(setStateEvent);
  }

  static Future<void> _handleOpenCloseCamera() async {
    CallState.instance.isCameraOpen = !CallState.instance.isCameraOpen;
    if (CallState.instance.isCameraOpen) {
      await CallManager.instance.openCamera(
          CallState.instance.camera, CallState.instance.selfUser.viewID);
    } else {
      await CallManager.instance.closeCamera();
    }
    NEEventNotify().notify(
      setStateEvent,
      {'refreshVideoViews': false},
    );
  }

  static void _handleOpenBlurBackground() async {
    CallState.instance.enableBlurBackground =
        !CallState.instance.enableBlurBackground;
    await CallManager.instance
        .setBlurBackground(CallState.instance.enableBlurBackground);
    NEEventNotify().notify(
      setStateEvent,
      {'refreshVideoViews': false},
    );
  }

  static Future<void> _handleSwitchCamera() async {
    if (NECamera.front == CallState.instance.camera) {
      CallState.instance.camera = NECamera.back;
    } else {
      CallState.instance.camera = NECamera.front;
    }
    await CallManager.instance.switchCamera(CallState.instance.camera);
    NEEventNotify().notify(
      setStateEvent,
      {'refreshVideoViews': false},
    );
  }

  static Future<NEResult> _handleDesktopVideoCaptureDeviceSelected(
    String deviceId,
  ) async {
    final result =
        await CallManager.instance.setDesktopVideoCaptureDevice(deviceId);
    if (result.code != 0 && result.message != null) {
      CallManager.instance.showToast(result.message!);
      return result;
    }
    NEEventNotify().notify(
      setStateEvent,
      {'refreshVideoViews': false},
    );
    return result;
  }

  static Future<NEResult> _handleDesktopAudioRecordingDeviceSelected(
    String deviceId,
  ) async {
    final result =
        await CallManager.instance.setDesktopAudioRecordingDevice(deviceId);
    if (result.code != 0 && result.message != null) {
      CallManager.instance.showToast(result.message!);
      return result;
    }
    NEEventNotify().notify(
      setStateEvent,
      {'refreshVideoViews': false},
    );
    return result;
  }

  static Future<NEResult> _handleDesktopAudioPlaybackDeviceSelected(
    String deviceId,
  ) async {
    final result =
        await CallManager.instance.setDesktopAudioPlaybackDevice(deviceId);
    if (result.code != 0 && result.message != null) {
      CallManager.instance.showToast(result.message!);
      return result;
    }
    NEEventNotify().notify(
      setStateEvent,
      {'refreshVideoViews': false},
    );
    return result;
  }

  static Color _getTextColor() {
    return Colors.white;
  }
}

class _DesktopRouteDeviceOption {
  const _DesktopRouteDeviceOption({
    required this.deviceId,
    required this.displayName,
  });

  final String deviceId;
  final String displayName;
}

class _DesktopRouteMenuValue {
  const _DesktopRouteMenuValue.device(this.deviceId) : toggleEnabled = null;

  const _DesktopRouteMenuValue.toggle(this.toggleEnabled) : deviceId = null;

  final String? deviceId;
  final bool? toggleEnabled;
}

class _DesktopHoverRouteButton extends StatefulWidget {
  const _DesktopHoverRouteButton({
    required this.imgUrl,
    required this.tips,
    required this.textColor,
    required this.imgHeight,
    required this.menuTitle,
    required this.toggleLabelWhenEnabled,
    required this.toggleLabelWhenDisabled,
    required this.isEnabled,
    required this.onPrimaryTap,
    required this.loadDevices,
    required this.loadCurrentDeviceId,
    required this.onDeviceSelected,
    this.buttonKey,
  });

  final String imgUrl;
  final String tips;
  final Color textColor;
  final double imgHeight;
  final String menuTitle;
  final String toggleLabelWhenEnabled;
  final String toggleLabelWhenDisabled;
  final bool isEnabled;
  final Future<void> Function() onPrimaryTap;
  final Future<List<_DesktopRouteDeviceOption>> Function() loadDevices;
  final Future<String?> Function() loadCurrentDeviceId;
  final Future<NEResult> Function(String deviceId) onDeviceSelected;
  final Key? buttonKey;

  @override
  State<_DesktopHoverRouteButton> createState() =>
      _DesktopHoverRouteButtonState();
}

class _DesktopHoverRouteButtonState extends State<_DesktopHoverRouteButton> {
  static const Color _menuDividerColor = Color(0xFF4A4A4A);
  Timer? _hoverTimer;
  bool _menuOpen = false;
  bool _pointerDown = false;
  DateTime? _suppressHoverUntil;

  @override
  void dispose() {
    _hoverTimer?.cancel();
    super.dispose();
  }

  bool _shouldOpenMenu() {
    return CallsFunctionWidget.shouldOpenDesktopRouteMenuOnHover(
      menuOpen: _menuOpen,
      pointerDown: _pointerDown,
      now: DateTime.now(),
      suppressHoverUntil: _suppressHoverUntil,
    );
  }

  void _suppressHoverMenu() {
    _suppressHoverUntil = DateTime.now().add(
      CallsFunctionWidget.desktopRouteHoverTapSuppressDuration,
    );
  }

  void _scheduleMenu() {
    if (!_shouldOpenMenu()) {
      return;
    }
    if (_hoverTimer?.isActive ?? false) {
      return;
    }
    _hoverTimer?.cancel();
    _hoverTimer =
        Timer(CallsFunctionWidget.desktopRouteHoverOpenDelay, _showMenu);
  }

  void _cancelScheduledMenu() {
    _hoverTimer?.cancel();
  }

  Future<void> _handlePrimaryTap() async {
    _cancelScheduledMenu();
    _suppressHoverMenu();
    await widget.onPrimaryTap();
  }

  Future<void> _showMenu() async {
    if (!mounted || !_shouldOpenMenu()) {
      return;
    }

    final devices = await widget.loadDevices();
    final currentDeviceId = await widget.loadCurrentDeviceId();
    if (!mounted || !_shouldOpenMenu()) {
      return;
    }

    final buttonBox = context.findRenderObject() as RenderBox?;
    final overlay = Overlay.maybeOf(context);
    final overlayBox = overlay?.context.findRenderObject() as RenderBox?;
    if (buttonBox == null || overlayBox == null) {
      return;
    }

    final buttonRect = Rect.fromPoints(
      buttonBox.localToGlobal(Offset.zero, ancestor: overlayBox),
      buttonBox.localToGlobal(
        buttonBox.size.bottomRight(Offset.zero),
        ancestor: overlayBox,
      ),
    );
    final menuPosition = CallsFunctionWidget.buildDesktopRouteMenuPosition(
      buttonRect: buttonRect,
      overlaySize: overlayBox.size,
      deviceCount: devices.length,
    );

    _menuOpen = true;
    const _menuBgColor = Color(0xFF3D3D3D);
    const _menuTextStyle = TextStyle(color: Colors.white);
    const _menuDisabledTextStyle = TextStyle(color: Color(0xFFAAAAAA));
    final selection = await showMenu<_DesktopRouteMenuValue>(
      context: context,
      color: _menuBgColor,
      position: menuPosition,
      items: <PopupMenuEntry<_DesktopRouteMenuValue>>[
        PopupMenuItem<_DesktopRouteMenuValue>(
          enabled: false,
          child: Text(widget.menuTitle, style: _menuDisabledTextStyle),
        ),
        const PopupMenuDivider(height: 1),
        ...devices.map(
          (device) => PopupMenuItem<_DesktopRouteMenuValue>(
            value: _DesktopRouteMenuValue.device(device.deviceId),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  child: device.deviceId == currentDeviceId
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    device.displayName,
                    overflow: TextOverflow.ellipsis,
                    style: _menuTextStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (devices.isNotEmpty) const PopupMenuDivider(height: 1),
        PopupMenuItem<_DesktopRouteMenuValue>(
          value: _DesktopRouteMenuValue.toggle(!widget.isEnabled),
          child: Text(
            widget.isEnabled
                ? widget.toggleLabelWhenEnabled
                : widget.toggleLabelWhenDisabled,
            style: _menuTextStyle,
          ),
        ),
      ],
    );
    _menuOpen = false;
    if (!mounted || selection == null) {
      return;
    }
    if (selection.deviceId != null) {
      await widget.onDeviceSelected(selection.deviceId!);
      return;
    }
    if (selection.toggleEnabled != null) {
      await widget.onPrimaryTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerTheme: const DividerThemeData(
          color: _menuDividerColor,
          thickness: 1,
          space: 1,
        ),
      ),
      child: MouseRegion(
        onEnter: (_) => _scheduleMenu(),
        onHover: (_) => _scheduleMenu(),
        onExit: (_) {
          _pointerDown = false;
          _cancelScheduledMenu();
        },
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) {
            _pointerDown = true;
            _cancelScheduledMenu();
            _suppressHoverMenu();
          },
          onPointerUp: (_) {
            _pointerDown = false;
          },
          onPointerCancel: (_) {
            _pointerDown = false;
          },
          child: ExtendButton(
            key: widget.buttonKey,
            imgUrl: widget.imgUrl,
            tips: widget.tips,
            textColor: widget.textColor,
            imgHeight: widget.imgHeight,
            onTap: _handlePrimaryTap,
          ),
        ),
      ),
    );
  }
}
