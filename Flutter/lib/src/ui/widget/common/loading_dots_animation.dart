// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// 三点 loading 动画组件
///
/// 用于显示等待状态，如群呼中等待成员接听时
/// 三个静态圆点，通过透明度变化依次高亮切换
class LoadingDotsAnimation extends StatefulWidget {
  /// 点的颜色
  final Color color;

  /// 点的大小
  final double size;

  /// 点之间的间距
  final double spacing;

  const LoadingDotsAnimation({
    super.key,
    this.color = Colors.white,
    this.size = 8.0,
    this.spacing = 4.0,
  });

  @override
  State<LoadingDotsAnimation> createState() => _LoadingDotsAnimationState();
}

class _LoadingDotsAnimationState extends State<LoadingDotsAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  /// 未激活圆点的透明度
  static const double _inactiveOpacity = 0.5;

  /// 激活圆点的透明度
  static const double _activeOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900), // 每个点约 300ms
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // 计算当前激活的圆点索引 (0, 1, 2 依次循环)
              final activeIndex = (_controller.value * 3).floor() % 3;
              final isActive = index == activeIndex;

              return Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.color.withValues(
                    alpha: isActive ? _activeOpacity : _inactiveOpacity,
                  ),
                  shape: BoxShape.circle,
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
