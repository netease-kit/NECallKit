// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 放大模式布局类型
///
/// 根据 Figma 设计，放大模式分为三种布局：
/// - bottomHorizontal: 底部横排模式（2-4人）
/// - lShape: L形布局模式（5-9人）
/// - compactLShape: 紧凑L形模式（10人）
enum EnlargedLayoutType {
  /// 底部横排模式：放大区域占满宽度，缩略图在底部左对齐排列
  bottomHorizontal,

  /// L形布局模式：放大区域在左上，右侧竖列+底部行
  lShape,

  /// 紧凑L形模式：类似L形但使用更小的缩略图
  compactLShape,
}

/// 放大模式布局配置
///
/// 定义不同人数下的放大模式布局规则
/// 放大模式：一个用户的视频放大显示，其他用户以缩略图形式展示
///
/// 布局模式（根据 Figma 设计）：
/// - 2-4人：底部横排模式，375×375px 放大区域，125×125px 缩略图
/// - 5-9人：L形布局模式，250×250px 放大区域，125×125px 缩略图
/// - 10人：紧凑L形模式，281×281px 放大区域，94×94px 缩略图
class EnlargedLayoutConfig {
  /// 布局类型
  final EnlargedLayoutType layoutType;

  /// 放大区域宽度
  final double enlargedWidth;

  /// 放大区域高度
  final double enlargedHeight;

  /// 缩略图宽度
  final double thumbnailWidth;

  /// 缩略图高度
  final double thumbnailHeight;

  /// 缩略图之间的间距（水平和垂直）
  final double thumbnailSpacing;

  /// 右侧竖列最大缩略图数量（仅 L形布局使用）
  final int rightColumnMaxCount;

  /// 底部区域每行最大缩略图数量
  final int bottomRowMaxCount;

  const EnlargedLayoutConfig({
    required this.layoutType,
    required this.enlargedWidth,
    required this.enlargedHeight,
    required this.thumbnailWidth,
    required this.thumbnailHeight,
    this.thumbnailSpacing = 0,
    this.rightColumnMaxCount = 0,
    this.bottomRowMaxCount = 3,
  });
}

/// 放大模式布局配置映射表（2-10 人）
///
/// 根据 Figma 设计稿定义三种布局模式：
/// - 2-4人：底部横排模式，375×375px 放大区域，125×125px 缩略图
/// - 5-9人：L形布局模式，250×250px 放大区域，125×125px 缩略图
/// - 10人：紧凑L形模式，281×281px 放大区域，94×94px 缩略图
///
/// 缩略图填充顺序：先右侧竖列（从上到下），再底部行（从左到右，从上到下）
final Map<int, EnlargedLayoutConfig> enlargedLayoutConfigs = {
  // ============================================================================
  // 底部横排模式 (2-4人): 放大区域 375×375px, 缩略图 125×125px
  // ============================================================================

  // 2人放大模式: 1个缩略图在底部左侧
  // Figma: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19276-2715
  2: EnlargedLayoutConfig(
    layoutType: EnlargedLayoutType.bottomHorizontal,
    enlargedWidth: 375.w,
    enlargedHeight: 375.w,
    thumbnailWidth: 125.w,
    thumbnailHeight: 125.w,
    thumbnailSpacing: 0,
    rightColumnMaxCount: 0,
    bottomRowMaxCount: 3,
  ),

  // 3人放大模式: 2个缩略图在底部左对齐
  // Figma: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19276-2875
  3: EnlargedLayoutConfig(
    layoutType: EnlargedLayoutType.bottomHorizontal,
    enlargedWidth: 375.w,
    enlargedHeight: 375.w,
    thumbnailWidth: 125.w,
    thumbnailHeight: 125.w,
    thumbnailSpacing: 0,
    rightColumnMaxCount: 0,
    bottomRowMaxCount: 3,
  ),

  // 4人放大模式: 3个缩略图填满底部
  // Figma: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19276-2981
  4: EnlargedLayoutConfig(
    layoutType: EnlargedLayoutType.bottomHorizontal,
    enlargedWidth: 375.w,
    enlargedHeight: 375.w,
    thumbnailWidth: 125.w,
    thumbnailHeight: 125.w,
    thumbnailSpacing: 0,
    rightColumnMaxCount: 0,
    bottomRowMaxCount: 3,
  ),

  // ============================================================================
  // L形布局模式 (5-9人): 放大区域 250×250px, 缩略图 125×125px
  // 右侧竖列最多2个，底部每行最多3个
  // ============================================================================

  // 5人放大模式: 右侧2个 + 底部2个
  // Figma: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19276-2483
  5: EnlargedLayoutConfig(
    layoutType: EnlargedLayoutType.lShape,
    enlargedWidth: 250.w,
    enlargedHeight: 250.w,
    thumbnailWidth: 125.w,
    thumbnailHeight: 125.w,
    thumbnailSpacing: 0,
    rightColumnMaxCount: 2,
    bottomRowMaxCount: 3,
  ),

  // 6人放大模式: 右侧2个 + 底部3个
  // Figma: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19276-1701
  6: EnlargedLayoutConfig(
    layoutType: EnlargedLayoutType.lShape,
    enlargedWidth: 250.w,
    enlargedHeight: 250.w,
    thumbnailWidth: 125.w,
    thumbnailHeight: 125.w,
    thumbnailSpacing: 0,
    rightColumnMaxCount: 2,
    bottomRowMaxCount: 3,
  ),

  // 7人放大模式: 右侧2个 + 底部3个 + 底部第二行1个
  // Figma: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19276-3284
  7: EnlargedLayoutConfig(
    layoutType: EnlargedLayoutType.lShape,
    enlargedWidth: 250.w,
    enlargedHeight: 250.w,
    thumbnailWidth: 125.w,
    thumbnailHeight: 125.w,
    thumbnailSpacing: 0,
    rightColumnMaxCount: 2,
    bottomRowMaxCount: 3,
  ),

  // 8人放大模式: 右侧2个 + 底部3个 + 底部第二行2个
  // Figma: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19276-3440
  8: EnlargedLayoutConfig(
    layoutType: EnlargedLayoutType.lShape,
    enlargedWidth: 250.w,
    enlargedHeight: 250.w,
    thumbnailWidth: 125.w,
    thumbnailHeight: 125.w,
    thumbnailSpacing: 0,
    rightColumnMaxCount: 2,
    bottomRowMaxCount: 3,
  ),

  // 9人放大模式: 右侧2个 + 底部3个 + 底部第二行3个
  // Figma: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19276-3655
  9: EnlargedLayoutConfig(
    layoutType: EnlargedLayoutType.lShape,
    enlargedWidth: 250.w,
    enlargedHeight: 250.w,
    thumbnailWidth: 125.w,
    thumbnailHeight: 125.w,
    thumbnailSpacing: 0,
    rightColumnMaxCount: 2,
    bottomRowMaxCount: 3,
  ),

  // ============================================================================
  // 紧凑L形模式 (10人): 放大区域 281×281px, 缩略图 94×94px
  // 右侧竖列最多3个，底部每行最多4个
  // ============================================================================

  // 10人放大模式: 右侧3个 + 底部4个 + 底部第二行2个
  // Figma: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19294-5089
  10: EnlargedLayoutConfig(
    layoutType: EnlargedLayoutType.compactLShape,
    enlargedWidth: 281.w,
    enlargedHeight: 281.w,
    thumbnailWidth: 94.w,
    thumbnailHeight: 94.w,
    thumbnailSpacing: 0,
    rightColumnMaxCount: 3,
    bottomRowMaxCount: 4,
  ),
};

/// 获取指定人数的放大模式布局配置
EnlargedLayoutConfig getEnlargedLayoutConfig(int memberCount) {
  final count = memberCount.clamp(2, 10);
  return enlargedLayoutConfigs[count]!;
}
