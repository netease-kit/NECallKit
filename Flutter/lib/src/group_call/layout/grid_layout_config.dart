// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 网格布局配置
///
/// 定义不同人数下的视频网格布局规则（普通模式）
/// 设计基准：375×812px (iPhone X)
class GridLayoutConfig {
  /// 列数
  final int columns;

  /// 行数
  final int rows;

  /// 单元格宽度 (逻辑像素)
  final double cellWidth;

  /// 单元格高度 (逻辑像素)
  final double cellHeight;

  /// 单元格之间的水平间距
  final double horizontalSpacing;

  /// 单元格之间的垂直间距
  final double verticalSpacing;

  /// 整体布局的水平内边距
  final double paddingHorizontal;

  /// 整体布局的垂直内边距
  final double paddingVertical;

  /// 是否垂直居中
  /// 根据 Figma 设计：当内容高度 < 375px 时垂直居中
  final bool verticalCenter;

  const GridLayoutConfig({
    required this.columns,
    required this.rows,
    required this.cellWidth,
    required this.cellHeight,
    this.horizontalSpacing = 0,
    this.verticalSpacing = 0,
    this.paddingHorizontal = 0,
    this.paddingVertical = 0,
    this.verticalCenter = false,
  });
}

/// 普通模式布局配置映射表（2-10 人）
///
/// 根据 Figma 设计稿精确定义每种人数的布局
/// 参考：spec.md Figma 设计链接
///
/// 垂直居中规则（根据 Figma 分析）：
/// - 内容高度 < 375px 时垂直居中
/// - 内容高度 >= 375px 时从顶部开始
final Map<int, GridLayoutConfig> normalLayoutConfigs = {
  // 2人: 1×2 左右并排布局 (188×187px 单元格)
  // 内容高度: 187px < 375px → 垂直居中
  // Figma: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19276-1124
  2: GridLayoutConfig(
    columns: 2,
    rows: 1,
    cellWidth: 188.w,
    cellHeight: 187.w,
    horizontalSpacing: 0,
    verticalSpacing: 0,
    verticalCenter: true,
  ),

  // 3人: 2+1 布局 (上方2个并排，下方居中1个，188×187px 单元格)
  // 内容高度: 374px ≈ 375px → 不垂直居中
  // Figma: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19276-2600
  3: GridLayoutConfig(
    columns: 2,
    rows: 2,
    cellWidth: 188.w,
    cellHeight: 187.w,
    horizontalSpacing: 0,
    verticalSpacing: 0,
    verticalCenter: false,
  ),

  // 4人: 2×2 等分网格布局 (187×187px 单元格，无间距)
  // 内容高度: 374px ≈ 375px → 不垂直居中
  // Figma: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19276-1324
  4: GridLayoutConfig(
    columns: 2,
    rows: 2,
    cellWidth: 187.w,
    cellHeight: 187.w,
    horizontalSpacing: 0,
    verticalSpacing: 0,
    verticalCenter: false,
  ),

  // 5人: 3+2 布局 (125×125px 单元格)
  // 内容高度: 250px < 375px → 垂直居中
  // Figma: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19276-3090
  5: GridLayoutConfig(
    columns: 3,
    rows: 2,
    cellWidth: 125.w,
    cellHeight: 125.w,
    horizontalSpacing: 0,
    verticalSpacing: 0,
    verticalCenter: true,
  ),

  // 6人: 3×2 网格布局 (125×125px 单元格)
  // 内容高度: 250px < 375px → 垂直居中
  // Figma: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19276-3178
  6: GridLayoutConfig(
    columns: 3,
    rows: 2,
    cellWidth: 125.w,
    cellHeight: 125.w,
    horizontalSpacing: 0,
    verticalSpacing: 0,
    verticalCenter: true,
  ),

  // 7人: 3+3+1 布局 (125×125px 单元格)
  // 内容高度: 375px → 不垂直居中
  // Figma: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19276-1930
  7: GridLayoutConfig(
    columns: 3,
    rows: 3,
    cellWidth: 125.w,
    cellHeight: 125.w,
    horizontalSpacing: 0,
    verticalSpacing: 0,
    verticalCenter: false,
  ),

  // 8人: 3+3+2 布局 (125×125px 单元格)
  // 内容高度: 375px → 不垂直居中
  // Figma: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19276-3562
  8: GridLayoutConfig(
    columns: 3,
    rows: 3,
    cellWidth: 125.w,
    cellHeight: 125.w,
    horizontalSpacing: 0,
    verticalSpacing: 0,
    verticalCenter: false,
  ),

  // 9人: 3×3 等分网格布局 (125×125px 单元格)
  // 内容高度: 375px → 不垂直居中
  // Figma: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19276-2378
  9: GridLayoutConfig(
    columns: 3,
    rows: 3,
    cellWidth: 125.w,
    cellHeight: 125.w,
    horizontalSpacing: 0,
    verticalSpacing: 0,
    verticalCenter: false,
  ),

  // 10人: 4+4+2 布局 (94×94px 单元格)
  // 内容高度: 282px < 375px → 垂直居中
  // Figma: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19294-4917
  10: GridLayoutConfig(
    columns: 4,
    rows: 3,
    cellWidth: 94.w,
    cellHeight: 94.w,
    horizontalSpacing: 0,
    verticalSpacing: 0,
    verticalCenter: true,
  ),
};

/// 获取指定人数的布局配置
GridLayoutConfig getLayoutConfig(int memberCount) {
  // 确保人数在有效范围内
  final count = memberCount.clamp(2, 10);
  return normalLayoutConfigs[count]!;
}
