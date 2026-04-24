// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import '../../group_call/group_call_ui_state.dart';

/// 媒体按钮状态枚举
enum MediaButtonState {
  /// 开启状态：背景纯白，图标纯黑
  on,

  /// 关闭状态：背景纯黑，图标纯白
  off,

  /// 禁用状态：背景纯黑，图标纯白带0.5透明度
  disabled,
}

/// 群呼功能按钮组
///
/// 包含 4 个功能按钮：麦克风、扬声器、摄像头、挂断
///
/// Figma 规格:
/// - 圆形背景: 64×64px
/// - 图标尺寸: 36×36px，居中
/// - 文案: 12px 白色，位于按钮下方
///
/// 状态规则:
/// - 开启状态: 背景纯白 + 图标纯黑
/// - 关闭状态: 背景纯黑 + 图标纯白
/// - 禁用状态: 背景纯黑 + 图标纯白(透明度0.5)
/// - 挂断按钮: 背景红色 #E54040 + 图标纯白
///
/// Figma 参考:
/// - 呼叫中: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19276-1037
/// - 通话中: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19274-917
class GroupCallFunctionWidget extends StatelessWidget {
  /// 当前 UI 状态
  final GroupCallUIState uiState;

  /// 麦克风是否静音
  final bool isMicMuted;

  /// 扬声器是否开启
  final bool isSpeakerOn;

  /// 摄像头是否开启
  final bool isCameraOn;

  /// 麦克风按钮点击回调
  final VoidCallback? onToggleMic;

  /// 扬声器按钮点击回调
  final VoidCallback? onToggleSpeaker;

  /// 摄像头按钮点击回调
  final VoidCallback? onToggleCamera;

  /// 挂断按钮点击回调
  final VoidCallback? onHangup;

  const GroupCallFunctionWidget({
    super.key,
    required this.uiState,
    required this.isMicMuted,
    required this.isSpeakerOn,
    required this.isCameraOn,
    this.onToggleMic,
    this.onToggleSpeaker,
    this.onToggleCamera,
    this.onHangup,
  });

  @override
  Widget build(BuildContext context) {
    // 麦克风、扬声器、摄像头只在通话中（inCall）状态可以操作
    // 呼叫中（calling）和来电（incoming）状态下按钮禁用
    final audioButtonsEnabled = uiState == GroupCallUIState.inCall || uiState == GroupCallUIState.calling;
    final cameraButtonEnabled = uiState == GroupCallUIState.inCall;

    return Container(
      height: 103.w, // 64 (button) + 12 (spacing) + 27 (label height estimate)
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 麦克风按钮
          _buildAssetButton(
            assetOn: 'assets/images/mute.png',
            assetOff: 'assets/images/mute_on.png',
            label: isMicMuted
                ? NECallKitUI.localizations.groupCallMicOff
                : NECallKitUI.localizations.groupCallMicOn,
            state: _getButtonState(isOn: !isMicMuted, isEnabled: audioButtonsEnabled),
            isOn: !isMicMuted,
            onPressed: audioButtonsEnabled ? onToggleMic : null,
          ),

          // 扬声器按钮
          _buildAssetButton(
            assetOn: 'assets/images/handsfree_on.png',
            assetOff: 'assets/images/handsfree.png',
            label: isSpeakerOn
                ? NECallKitUI.localizations.groupCallSpeakerOn
                : NECallKitUI.localizations.groupCallSpeakerOff,
            state: _getButtonState(isOn: isSpeakerOn, isEnabled: audioButtonsEnabled),
            isOn: isSpeakerOn,
            onPressed: audioButtonsEnabled ? onToggleSpeaker : null,
          ),

          // 摄像头按钮
          _buildAssetButton(
            assetOn: 'assets/images/camera_on.png',
            assetOff: 'assets/images/camera_off.png',
            label: isCameraOn
                ? NECallKitUI.localizations.groupCallCameraOn
                : NECallKitUI.localizations.groupCallCameraOff,
            state: _getButtonState(isOn: isCameraOn, isEnabled: cameraButtonEnabled),
            isOn: isCameraOn,
            onPressed: cameraButtonEnabled ? onToggleCamera : null,
          ),

          // 挂断按钮（红色，始终可用）
          _buildAssetHangupButton(
            label: NECallKitUI.localizations.hangUp,
            onPressed: onHangup,
          ),
        ],
      ),
    );
  }

  /// 根据开关状态和启用状态获取按钮状态
  MediaButtonState _getButtonState({
    required bool isOn,
    required bool isEnabled,
  }) {
    if (!isEnabled) {
      return MediaButtonState.disabled;
    }
    return isOn ? MediaButtonState.on : MediaButtonState.off;
  }

  /// 构建媒体控制按钮（麦克风、扬声器、摄像头）
  ///
  /// 使用项目 assets/images 下的图标资源
  Widget _buildAssetButton({
    required String assetOn,
    required String assetOff,
    required String label,
    required MediaButtonState state,
    required bool isOn,
    VoidCallback? onPressed,
  }) {
    final String asset;
    final double opacity;

    switch (state) {
      case MediaButtonState.on:
        asset = assetOn;
        opacity = 1.0;
        break;
      case MediaButtonState.off:
        asset = assetOff;
        opacity = 1.0;
        break;
      case MediaButtonState.disabled:
        // 禁用状态下仍根据实际开关状态显示对应图标，仅降低透明度
        asset = isOn ? assetOn : assetOff;
        opacity = 0.5;
        break;
    }

    return GestureDetector(
      onTap: onPressed,
      child: Opacity(
        opacity: opacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              asset,
              package: 'netease_callkit_ui',
              width: 64.w,
              height: 64.w,
            ),

            SizedBox(height: 12.w),

            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontFamily: 'PingFang SC',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建挂断按钮
  ///
  /// 使用项目 assets/images/hangup.png
  Widget _buildAssetHangupButton({
    required String label,
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/hangup.png',
            package: 'netease_callkit_ui',
            width: 64.w,
            height: 64.w,
          ),

          SizedBox(height: 12.w),

          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontFamily: 'PingFang SC',
            ),
          ),
        ],
      ),
    );
  }
}
