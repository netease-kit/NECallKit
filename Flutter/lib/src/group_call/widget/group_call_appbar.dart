// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import '../../group_call/group_call_ui_state.dart';

/// 群呼通话页面 AppBar
///
/// 根据 Figma 设计 1:1 还原
/// - 高度: 56px (y=44~100，不含状态栏)
/// - 左侧: 缩小按钮 (20, 16), 24×24px
/// - 中间: 状态文案（呼叫中: "等待接听"，通话中: 通话时长）
/// - 右侧: 邀请按钮 (331, 16), 24×24px（可选显示）
///
/// Figma 参考:
/// - 呼叫中: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19276-1037
/// - 通话中: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19274-917
class GroupCallAppBar extends StatelessWidget {
  /// 当前 UI 状态
  final GroupCallUIState uiState;

  /// 通话时长通知器（用于独立更新时间显示，不触发整体 UI 重建）
  final ValueNotifier<String> durationNotifier;

  /// 缩小按钮点击回调
  final VoidCallback? onMinimize;

  /// 邀请按钮点击回调（为 null 时不显示邀请按钮）
  final VoidCallback? onInvitePressed;

  const GroupCallAppBar({
    super.key,
    required this.uiState,
    required this.durationNotifier,
    this.onMinimize,
    this.onInvitePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.w,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          // 左侧缩小按钮
          // _buildMinimizeButton(),

          // 中间状态文案（扩展以填充剩余空间）
          Expanded(
            child: Center(
              child: _buildCenterText(),
            ),
          ),

          // 右侧邀请按钮（可选）
          if (onInvitePressed != null) _buildInviteButton(),
        ],
      ),
    );
  }

  /// 构建中间文案
  Widget _buildCenterText() {
    // 通话中状态：使用 ValueListenableBuilder 监听时间变化，独立更新
    if (uiState == GroupCallUIState.inCall) {
      return ValueListenableBuilder<String>(
        valueListenable: durationNotifier,
        builder: (context, duration, child) {
          return Text(
            duration,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: 'PingFang SC',
            ),
          );
        },
      );
    }

    // 其他状态：静态文案
    final text = _getStaticText();
    return Text(
      text,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        fontFamily: 'PingFang SC',
      ),
    );
  }

  /// 获取静态文案（非通话中状态）
  String _getStaticText() {
    switch (uiState) {
      case GroupCallUIState.calling:
        return NECallKitUI.localizations.groupCallWaiting;
      case GroupCallUIState.incoming:
        return NECallKitUI.localizations.groupCallInvitation;
      case GroupCallUIState.inCall:
        return ''; // 通话中状态由 ValueListenableBuilder 处理
    }
  }

  /// 构建邀请按钮
  Widget _buildInviteButton() {
    return GestureDetector(
      onTap: onInvitePressed,
      child: Container(
        width: 24.w,
        height: 24.w,
        alignment: Alignment.center,
        child: Icon(
          Icons.person_add,
          size: 24.w,
          color: Colors.white,
        ),
      ),
    );
  }
}
