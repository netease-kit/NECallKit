// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netease_callkit/netease_callkit.dart';
import '../../group_call/group_call_member_ui.dart';
import '../../ui/widget/common/loading_dots_animation.dart';
import '../../common/video_renderer_cache.dart';

/// 群呼成员视图组件
///
/// 显示单个成员的视频/头像、昵称、状态指示等
///
/// 功能：
/// - 视频/头像自动切换（AnimatedCrossFade）
/// - 讲话中指示（左下角绿色圆形 + 音量图标）
/// - 昵称显示（仅放大模式放大区域）
/// - 切换摄像头按钮（仅本端 + 摄像头开启时，右下角）
/// - 等待状态三点动画（叠加在中央偏下）
///
/// Figma 参考:
/// - 通话中-3人: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19274-917
class GroupCallMemberView extends StatefulWidget {
  /// 成员数据
  final GroupCallMemberUI member;

  /// 单元格宽度
  final double width;

  /// 单元格高度
  final double height;

  /// 是否显示昵称（仅放大模式放大区域显示）
  final bool showNickname;

  /// 是否显示切换摄像头按钮（仅本端 + 摄像头开启时显示）
  final bool showSwitchCamera;

  /// 切换摄像头按钮点击回调
  final VoidCallback? onSwitchCamera;

  /// 点击成员视图回调
  final VoidCallback? onTap;

  const GroupCallMemberView({
    super.key,
    required this.member,
    required this.width,
    required this.height,
    this.showNickname = false,
    this.showSwitchCamera = false,
    this.onSwitchCamera,
    this.onTap,
  });

  @override
  State<GroupCallMemberView> createState() => _GroupCallMemberViewState();
}

class _GroupCallMemberViewState extends State<GroupCallMemberView> {
  // 使用 NECallkitTextureView + NEVideoRendererCache 统一管理渲染器

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.width,
        height: widget.height,
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 视频/头像层
            _buildVideoOrAvatar(),

            // 等待状态动画（未加入时显示）
            if (!widget.member.isJoined) _buildLoadingOverlay(),

            // 底部信息叠加层
            _buildBottomOverlay(),

            // 切换摄像头按钮（右下角，仅本端且摄像头开启时）
            if (widget.showSwitchCamera &&
                widget.member.isLocal &&
                widget.member.isCameraOn)
              _buildSwitchCameraButton(),
          ],
        ),
      ),
    );
  }

  /// 构建视频/头像切换
  Widget _buildVideoOrAvatar() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: widget.member.isCameraOn
          ? _buildVideoView() // key 自动区分
          : _buildAvatarView(),
    );
  }

  /// 构建视频视图
  ///
  /// 使用 NECallkitTextureView + NEVideoRendererCache 实现视频渲染
  Widget _buildVideoView() {
    final member = widget.member;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: NECallkitTextureView(
        key: ValueKey('video_${member.userId}'),
        controller: NEVideoRendererCache.instance,
        uid: member.isLocal ? null : member.rtcUid,
        fitType: BoxFit.cover,
        backgroundColor: const Color(0xFF1A1A1A),
      ),
    );
  }

  /// 构建头像视图
  ///
  /// 头像铺满整个成员视图区域，昵称显示在底部叠加层
  Widget _buildAvatarView() {
    final member = widget.member;
    return Container(
      width: widget.width,
      height: widget.height,
      color: const Color(0xFF1A1A1A),
      child: member.avatar != null
          ? Image.network(
              member.avatar!,
              width: widget.width,
              height: widget.height,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildDefaultAvatarFullSize(),
            )
          : _buildDefaultAvatarFullSize(),
    );
  }

  /// 构建默认头像（铺满整个区域，居中显示用户图标）
  Widget _buildDefaultAvatarFullSize() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: const Color(0xFF1A1A1A),
      alignment: Alignment.center,
      child: Icon(
        Icons.person,
        size: widget.width * 0.4,
        color: Colors.white70,
      ),
    );
  }

  /// 构建等待状态动画叠加层
  Widget _buildLoadingOverlay() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.black38,
      alignment: Alignment.center,
      child: const LoadingDotsAnimation(
        color: Colors.white,
        size: 10.0,
        spacing: 8.0,
      ),
    );
  }

  /// 构建底部信息叠加层（讲话指示 + 昵称）
  Widget _buildBottomOverlay() {
    final member = widget.member;
    // 仅远端用户显示讲话指示（本地用户不显示）
    final showSpeaking = member.isSpeaking && !member.isLocal;

    // 如果没有讲话指示和昵称需要显示，则返回空容器
    if (!showSpeaking && !widget.showNickname) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 8.w,
      right: 8.w,
      bottom: 8.w,
      child: Row(
        children: [
          // 讲话中指示（左下角，仅远端用户）
          if (showSpeaking) _buildSpeakingIndicator(),

          if (showSpeaking && widget.showNickname) SizedBox(width: 6.w),

          // 昵称（仅放大模式放大区域显示）
          if (widget.showNickname)
            Expanded(
              child: Text(
                member.nickname ?? member.userId,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  shadows: const [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 2,
                      color: Colors.black54,
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  /// 构建讲话中指示
  ///
  /// 绿色圆形背景 24×24px，白色音量图标 18×18px
  /// Figma 规格: 左下角，与昵称相邻
  Widget _buildSpeakingIndicator() {
    return Container(
      width: 24.w,
      height: 24.w,
      decoration: const BoxDecoration(
        color: Colors.white, // 绿色
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Transform.rotate(
        angle: pi * 0.5,
        child: Icon(
          Icons.wifi,
          size: 18.w,
          color: const Color(0xFF17C77C),
        ),
      ),
    );
  }

  /// 构建切换摄像头按钮（右下角）
  Widget _buildSwitchCameraButton() {
    return Positioned(
      right: 8.w,
      bottom: 8.w,
      child: GestureDetector(
        onTap: widget.onSwitchCamera,
        child: Container(
          width: 32.w,
          height: 32.w,
          decoration: const BoxDecoration(
            color: Colors.black38,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.cameraswitch,
            size: 20.w,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
