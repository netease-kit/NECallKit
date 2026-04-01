// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import '../../group_call/group_call_state.dart';
import '../../group_call/group_call_manager.dart';
import '../../group_call/group_call_ui_state.dart';
import '../../group_call/group_call_member_ui.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'group_calls_widget.dart';
import 'safe_page_close_mixin.dart';
import '../../utils/permission.dart';

/// 群呼被叫邀请页面
///
/// 当收到群呼邀请时显示的全屏页面
///
/// 页面结构（基于 Figma 设计）:
/// - 毛玻璃背景
/// - 邀请者大头像 (124×124px，圆角12px)
/// - 邀请者昵称 (28px)
/// - 邀请提示文案 (16px, 50%透明度)
/// - 其他参与者头像列表 (40×40px，圆角4px)
/// - 左上角忽略按钮
/// - 底部接听（绿色）和挂断（红色）按钮
///
/// Figma: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=20095-7595
class GroupCallIncomingPage extends StatefulWidget {
  /// 群呼状态
  final GroupCallState groupCallState;

  const GroupCallIncomingPage({
    super.key,
    required this.groupCallState,
  });

  @override
  State<GroupCallIncomingPage> createState() => _GroupCallIncomingPageState();
}

class _GroupCallIncomingPageState extends State<GroupCallIncomingPage>
    with SafePageCloseMixin {
  /// 缓存主叫昵称和头像，避免主叫离开成员列表后显示"未知用户"
  String? _cachedCallerNickname;
  String? _cachedCallerAvatar;

  @override
  void initState() {
    super.initState();
    // 初始化主叫信息缓存
    _updateCallerCache();
    // 监听状态变化（用户信息异步获取后刷新 UI）
    // 防止竞态条件：GroupCallState 可能在页面构建前已被 dispose
    if (!widget.groupCallState.isDisposed) {
      widget.groupCallState.addListener(_onStateChanged);
    }
  }

  bool _hasCheckedCallState = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 初始化安全关闭机制
    initSafePageClose(context);
    // 检查群呼是否已结束（锁屏期间主叫挂断，Flutter UI 不响应关闭请求，
    // 解锁后 didChangeDependencies 会被调用，在此关闭页面）
    if (!_hasCheckedCallState) {
      _hasCheckedCallState = true;
      if (GroupCallManager.instance.currentState == null) {
        CallKitUILog.i('GroupCallIncomingPage',
            'didChangeDependencies: call already ended, closing page');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          handleSafeClose();
        });
      }
    }
  }

  @override
  void dispose() {
    if (!widget.groupCallState.isDisposed) {
      widget.groupCallState.removeListener(_onStateChanged);
    }
    // 仅在群呼流程结束时恢复屏幕方向（接听转场到通话页面时不恢复，避免覆盖）
    final currentState = GroupCallManager.instance.currentState;
    if (currentState == null ||
        currentState.uiState != GroupCallUIState.inCall) {
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
    // 释放安全关闭机制
    disposeSafePageClose();
    super.dispose();
  }

  /// 状态变化回调
  void _onStateChanged() {
    // 更新主叫信息缓存（昵称/头像异步获取后会触发）
    _updateCallerCache();
    if (mounted) {
      setState(() {});
    }
  }

  /// 从成员列表更新主叫缓存（只在有新值时更新，不会被 null 覆盖）
  void _updateCallerCache() {
    final callerUserId = widget.groupCallState.callerUserId;
    if (callerUserId == null) return;
    final caller = widget.groupCallState.members
        .cast<GroupCallMemberUI?>()
        .firstWhere((m) => m?.userId == callerUserId, orElse: () => null);
    if (caller?.nickname != null) _cachedCallerNickname = caller!.nickname;
    if (caller?.avatar != null) _cachedCallerAvatar = caller!.avatar;
  }

  @override
  Widget build(BuildContext context) {
    // 锁定竖屏方向（来电页面基于竖屏设计，不支持横屏）
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    ScreenUtil.init(context, designSize: const Size(375, 812));

    // 使用缓存的主叫头像用于背景
    final callerAvatar = _cachedCallerAvatar;

    final child = Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 毛玻璃背景（使用邀请者头像）
          _buildBlurredBackground(callerAvatar),

          // 主要内容
          SafeArea(
            child: Column(
              children: [
                // 顶部忽略按钮
                _buildIgnoreButton(),

                // 中间内容区（扩展以填充空间）
                Expanded(
                  child: _buildContentArea(),
                ),

                // 底部操作按钮
                _buildActionButtons(),

                // iOS Home Indicator 占位
                SizedBox(height: 34.w),
              ],
            ),
          ),
        ],
      ),
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light, // 浅色图标
        systemStatusBarContrastEnforced: false,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light, // 浅色图标
        systemNavigationBarContrastEnforced: false,
      ),
      child: PopScope(canPop: false, child: child),
    );
  }

  /// 构建毛玻璃背景
  ///
  /// 如果邀请者有头像，使用头像填充背景并添加模糊效果
  Widget _buildBlurredBackground(String? avatarUrl) {
    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 底层：头像或纯黑背景
          if (avatarUrl != null && avatarUrl.isNotEmpty)
            Image.network(
              avatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.black,
              ),
            )
          else
            Container(color: Colors.black),

          // 模糊层
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建左上角忽略按钮
  Widget _buildIgnoreButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: GestureDetector(
          onTap: _handleIgnore,
          child: Container(
            width: 80.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18.w),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.volume_off,
                  size: 20.w,
                  color: Colors.white,
                ),
                SizedBox(width: 4.w),
                Text(
                  NECallKitUI.localizations.groupCallIgnore,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建中间内容区
  Widget _buildContentArea() {
    final members = widget.groupCallState.members;
    final callerUserId = widget.groupCallState.callerUserId;
    // 其他被邀请的成员：排除主叫和被叫端自己
    final otherMembers = members
        .where((m) => m.userId != callerUserId && !m.isLocal)
        .toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 邀请者头像 (124×124px，圆角12px)（使用缓存）
        _buildCallerAvatar(null),

        SizedBox(height: 20.w),

        // 邀请者昵称 (28px)（使用缓存）
        _buildCallerNickname(null),

        SizedBox(height: 12.w),

        // 邀请提示文案 (16px, 50%透明度)
        _buildInvitationText(),

        SizedBox(height: 40.w),

        // 其他参与者提示和头像列表
        if (otherMembers.isNotEmpty) _buildOtherMembers(otherMembers),
      ],
    );
  }

  /// 构建邀请者头像（使用缓存值）
  Widget _buildCallerAvatar(dynamic caller) {
    final avatar = _cachedCallerAvatar;
    return Container(
      width: 124.w,
      height: 124.w,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: avatar != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12.w),
              child: Image.network(
                avatar,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultAvatar(120.w),
              ),
            )
          : _buildDefaultAvatar(120.w),
    );
  }

  /// 构建默认头像
  Widget _buildDefaultAvatar(double size) {
    return Icon(
      Icons.person,
      size: size * 0.6,
      color: Colors.white70,
    );
  }

  /// 构建邀请者昵称（使用缓存值）
  Widget _buildCallerNickname(dynamic caller) {
    final callerUserId = widget.groupCallState.callerUserId;
    return Text(
      _cachedCallerNickname ?? callerUserId ?? NECallKitUI.localizations.unknownUser,
      style: TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    );
  }

  /// 构建邀请提示文案
  Widget _buildInvitationText() {
    return Text(
      '${NECallKitUI.localizations.groupCallInviteYouToJoin}...',
      style: TextStyle(
        fontSize: 16.sp,
        color: Colors.white.withValues(alpha: 0.5),
      ),
    );
  }

  /// 构建其他参与者信息
  Widget _buildOtherMembers(List<dynamic> otherMembers) {
    return Column(
      children: [
        // 提示文案
        Text(
          NECallKitUI.localizations.groupCallOthersInCall(otherMembers.length),
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),

        SizedBox(height: 12.w),

        // 头像列表 (40×40px，圆角4px，间距12px，每行最多5个)
        SizedBox(
          width: 40.w * 5 + 12.w * 4, // 5个头像 + 4个间距
          child: Wrap(
          spacing: 12.w,
          runSpacing: 12.w,
          alignment: WrapAlignment.center,
          children: otherMembers.map((member) {
            return Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4.w),
              ),
              child: member.avatar != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4.w),
                      child: Image.network(
                        member.avatar! as String,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildDefaultAvatar(24.w),
                      ),
                    )
                  : _buildDefaultAvatar(24.w),
            );
          }).toList(),
        )),
      ],
    );
  }

  /// 构建底部操作按钮
  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 40.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 挂断按钮（红色）
          _buildActionButton(
            icon: Icons.call_end,
            label: NECallKitUI.localizations.hangUp,
            backgroundColor: const Color(0xFFE54040),
            onPressed: _handleReject,
          ),

          SizedBox(width: 60.w),

          // 接听按钮（绿色）
          _buildActionButton(
            icon: Icons.call,
            label: NECallKitUI.localizations.accept,
            backgroundColor: const Color(0xFF4CAF50),
            onPressed: _handleAccept,
          ),
        ],
      ),
    );
  }

  /// 构建单个操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 圆形按钮 (64×64px)
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 36.w,
              color: Colors.white,
            ),
          ),

          SizedBox(height: 12.w),

          // 按钮文案 (12px)
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 事件处理方法
  // ============================================================================

  /// 处理忽略按钮（静默拒绝）
  void _handleIgnore() {
    GroupCallManager.instance.ignore(widget.groupCallState.callId);
  }

  /// 处理挂断按钮（拒绝邀请）
  void _handleReject() {
    GroupCallManager.instance.reject(widget.groupCallState.callId);
  }

  /// 处理接听按钮
  Future<void> _handleAccept() async {
    // iOS SDK 的 groupAccept 内部会校验麦克风和摄像头权限，需提前请求
    if (Platform.isIOS) {
      await Permission.request(NECallType.video);
      if (!mounted) return;
    }

    final result = await GroupCallManager.instance.accept(widget.groupCallState.callId);
    if (!mounted) return;

    if (result.code == 0) {
      // 接听成功，替换当前页面为通话页面
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GroupCallsWidget(
            groupCallState: widget.groupCallState,
            onMinimize: () => Navigator.of(context).pop(),
            onInvitePressed: GroupCallManager.instance.onInvitePressed,
          ),
        ),
      );
    } else if (result.code == 4402) {
      // 4402: 其他端已接听，本端直接忽略退出
      Fluttertoast.showToast(msg: NECallKitUI.localizations.answerOnOtherDevice);
      GroupCallManager.instance.ignore(widget.groupCallState.callId);
    } else {
      // 其他错误，提示用户并挂断
      if (result.code == 21000) {
        Fluttertoast.showToast(msg: '未开启麦克风权限');
      } else if (result.code == 21001) {
        Fluttertoast.showToast(msg: '未开启摄像头权限');
      } else if (result.msg != null && result.msg!.isNotEmpty) {
        Fluttertoast.showToast(msg: result.msg!);
      } else {
        Fluttertoast.showToast(msg: '接听失败');
      }
      GroupCallManager.instance.hangup(widget.groupCallState.callId);
    }
  }
}
