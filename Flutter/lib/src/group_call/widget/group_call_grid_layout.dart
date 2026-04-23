// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../group_call_member_ui.dart';
import '../layout/enlarged_layout_config.dart';
import '../layout/grid_layout_config.dart';
import 'group_call_member_view.dart';

/// 群呼网格布局组件
///
/// 负责根据成员数量和放大模式状态，动态渲染普通宫格布局或放大模式布局
///
/// 使用 Stack + AnimatedPositioned 实现平滑的布局切换动画:
/// - 成员加入/离开时的布局切换动画
/// - 进入/退出放大模式时的位置/尺寸动画
/// - 切换放大成员时的流畅过渡
///
/// 核心设计：统一使用单一 Stack 渲染所有成员，通过 _calculateMemberRect()
/// 统一计算每个成员的位置，让 AnimatedPositioned 自动处理位置/大小变化的动画
///
/// 参考 Figma 设计:
/// - 普通模式: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19274-917
/// - 放大模式: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19276-2715
class GroupCallGridLayout extends StatelessWidget {
  /// 成员列表
  final List<GroupCallMemberUI> members;

  /// 是否处于放大模式
  final bool isEnlargedMode;

  /// 放大模式下被放大的成员 userId
  final String? enlargedMemberUserId;

  /// 点击成员视图回调
  final void Function(String userId) onMemberTap;

  /// 切换摄像头回调
  final VoidCallback? onSwitchCamera;

  /// 动画时长
  static const Duration _animationDuration = Duration(milliseconds: 300);

  /// 动画曲线
  static const Curve _animationCurve = Curves.easeInOut;

  const GroupCallGridLayout({
    super.key,
    required this.members,
    required this.isEnlargedMode,
    this.enlargedMemberUserId,
    required this.onMemberTap,
    this.onSwitchCamera,
  });

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const Center(
        child: Text(
          '暂无参与者',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    // 统一使用单一 Stack 渲染所有成员
    // 通过 _calculateMemberRect() 计算每个成员的位置
    // AnimatedPositioned 自动处理位置/大小变化的动画
    return Stack(
      children: members.map((member) {
        final rect = _calculateMemberRect(member.userId);
        final isEnlarged =
            isEnlargedMode && member.userId == enlargedMemberUserId;

        return AnimatedPositioned(
          key: ValueKey(member.userId), // 统一 Key，确保模式切换时 widget 复用
          duration: _animationDuration,
          curve: _animationCurve,
          left: rect.left,
          top: rect.top,
          width: rect.width,
          height: rect.height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GroupCallMemberView(
                member: member,
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                showNickname: isEnlarged, // 仅放大模式下放大的成员显示昵称
                showSwitchCamera: member.isLocal && member.isCameraOn,
                onSwitchCamera: onSwitchCamera,
                onTap: () => onMemberTap(member.userId),
              );
            }
          ),
        );
      }).toList(),
    );
  }

  // ============================================================================
  // 位置计算方法
  // ============================================================================

  /// 计算成员在当前布局中的位置和大小
  ///
  /// 根据是否处于放大模式，分别调用普通模式或放大模式的位置计算方法
  Rect _calculateMemberRect(String userId) {
    if (isEnlargedMode && enlargedMemberUserId != null) {
      return _calculateEnlargedModeRect(userId);
    } else {
      return _calculateNormalModeRect(userId);
    }
  }

  /// 计算普通宫格模式下成员的位置和大小
  ///
  /// 根据成员数量获取布局配置，计算网格位置
  Rect _calculateNormalModeRect(String userId) {
    final memberCount = members.length;
    final config = getLayoutConfig(memberCount);

    // 找到成员在列表中的索引
    final index = members.indexWhere((m) => m.userId == userId);
    if (index < 0) {
      // 成员不存在，返回默认位置
      return Rect.fromLTWH(0, 0, config.cellWidth, config.cellHeight);
    }

    // 计算实际行数
    final actualRows = (memberCount / config.columns).ceil();

    // 计算内容总高度
    final contentHeight = actualRows * config.cellHeight +
        (actualRows - 1) * config.verticalSpacing;

    // 计算垂直偏移（如果需要垂直居中）
    final verticalOffset =
        config.verticalCenter ? (375.w - contentHeight) / 2 : 0.0;

    // 计算网格位置
    final row = index ~/ config.columns;
    final col = index % config.columns;

    // 计算当前行的成员数量
    final isLastRow = row == actualRows - 1;
    final rowMemberCount = isLastRow
        ? memberCount - (actualRows - 1) * config.columns
        : config.columns;

    // 计算水平偏移
    // 特殊处理：3人布局的下排需要居中
    // 其他不满行情况：左对齐（偏移为0）
    double rowHorizontalOffset;
    if (memberCount == 3 && isLastRow) {
      // 3人布局下排居中
      rowHorizontalOffset = (375.w -
              (rowMemberCount * config.cellWidth +
                  (rowMemberCount - 1) * config.horizontalSpacing)) /
          2;
    } else if (isLastRow && rowMemberCount < config.columns) {
      // 其他不满行：左对齐
      rowHorizontalOffset = 0;
    } else {
      // 满行：居中（如果内容宽度小于容器宽度）
      final rowWidth = config.columns * config.cellWidth +
          (config.columns - 1) * config.horizontalSpacing;
      rowHorizontalOffset = (375.w - rowWidth) / 2;
    }

    final left =
        rowHorizontalOffset + col * (config.cellWidth + config.horizontalSpacing);
    final top =
        verticalOffset + row * (config.cellHeight + config.verticalSpacing);

    return Rect.fromLTWH(left, top, config.cellWidth, config.cellHeight);
  }

  /// 计算放大模式下成员的位置和大小
  ///
  /// 根据人数选择布局模式（底部横排/L形），计算放大区域和缩略图位置
  Rect _calculateEnlargedModeRect(String userId) {
    final memberCount = members.length;
    final config = getEnlargedLayoutConfig(memberCount);

    // 判断是否是被放大的成员
    final isEnlarged = userId == enlargedMemberUserId;

    if (isEnlarged) {
      // 放大的成员：位于左上角
      return Rect.fromLTWH(
        0,
        0,
        config.enlargedWidth,
        config.enlargedHeight,
      );
    }

    // 缩略图成员：需要计算在缩略图区域的位置
    // 获取缩略图成员列表（不包括被放大的成员）
    final thumbnailMembers =
        members.where((m) => m.userId != enlargedMemberUserId).toList();

    // 找到当前成员在缩略图列表中的索引
    final thumbnailIndex =
        thumbnailMembers.indexWhere((m) => m.userId == userId);
    if (thumbnailIndex < 0) {
      // 成员不存在于缩略图列表，返回默认位置
      return Rect.fromLTWH(0, 0, config.thumbnailWidth, config.thumbnailHeight);
    }

    // 根据布局类型计算缩略图位置
    switch (config.layoutType) {
      case EnlargedLayoutType.bottomHorizontal:
        return _calculateBottomHorizontalThumbnailRect(
            config, thumbnailIndex);
      case EnlargedLayoutType.lShape:
      case EnlargedLayoutType.compactLShape:
        return _calculateLShapeThumbnailRect(
            config, thumbnailIndex, thumbnailMembers.length);
    }
  }

  /// 计算底部横排布局（2-4人）中缩略图的位置
  ///
  /// 缩略图在放大区域下方，从左到右排列
  Rect _calculateBottomHorizontalThumbnailRect(
    EnlargedLayoutConfig config,
    int thumbnailIndex,
  ) {
    final left =
        thumbnailIndex * (config.thumbnailWidth + config.thumbnailSpacing);
    final top = config.enlargedHeight; // 紧贴放大区域下方

    return Rect.fromLTWH(
      left,
      top,
      config.thumbnailWidth,
      config.thumbnailHeight,
    );
  }

  /// 计算L形布局（5-10人）中缩略图的位置
  ///
  /// 缩略图填充顺序：
  /// 1. 先填右侧竖列（从上到下）
  /// 2. 再填底部行（从左到右，从上到下）
  Rect _calculateLShapeThumbnailRect(
    EnlargedLayoutConfig config,
    int thumbnailIndex,
    int totalThumbnails,
  ) {
    // 计算右侧竖列的缩略图数量
    final rightColumnCount =
        totalThumbnails.clamp(0, config.rightColumnMaxCount);

    double left;
    double top;

    if (thumbnailIndex < rightColumnCount) {
      // 右侧竖列：紧贴放大区域右侧，从上到下排列
      left = config.enlargedWidth;
      top = thumbnailIndex * (config.thumbnailHeight + config.thumbnailSpacing);
    } else {
      // 底部区域：放大区域下方，从左到右、从上到下排列
      final bottomIndex = thumbnailIndex - rightColumnCount;
      final row = bottomIndex ~/ config.bottomRowMaxCount;
      final col = bottomIndex % config.bottomRowMaxCount;

      left = col * (config.thumbnailWidth + config.thumbnailSpacing);
      top = config.enlargedHeight +
          row * (config.thumbnailHeight + config.thumbnailSpacing);
    }

    return Rect.fromLTWH(
      left,
      top,
      config.thumbnailWidth,
      config.thumbnailHeight,
    );
  }
}
