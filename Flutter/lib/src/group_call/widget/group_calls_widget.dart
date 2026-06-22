// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/video_renderer_cache.dart';
import '../../group_call/group_call_manager.dart';
import '../../group_call/group_call_state.dart';
import '../../impl/call_manager.dart';
import 'group_call_appbar.dart';
import 'group_call_function_widget.dart';
import 'group_call_grid_layout.dart';
import 'safe_page_close_mixin.dart';

/// 群呼通话主页面
///
/// 响应式 UI，使用 ListenableBuilder 监听 GroupCallState 变化
///
/// 页面结构（Figma 规格）:
/// - 背景层: 毛玻璃效果 (backdrop-blur: 40px) + 半透明黑色遮罩 (rgba(0,0,0,0.5))
/// - 顶部状态栏: y=0~44px，白色样式
/// - 通话信息栏: y=44~100px (56px)
/// - 视频区域: y=100px 起，显示参与者视频
/// - 底部控制栏: y=675~778px
///
/// Figma 参考:
/// - 呼叫中: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19276-1037
/// - 通话中: https://www.figma.com/design/svXd8toBgQmQS4ix4A97Vg?node-id=19274-917
class GroupCallsWidget extends StatefulWidget {
  /// 群呼状态
  final GroupCallState groupCallState;

  /// 缩小按钮回调
  final VoidCallback? onMinimize;

  /// 邀请按钮回调（参数为当前通话的 callId）
  final void Function(String callId)? onInvitePressed;

  const GroupCallsWidget({
    super.key,
    required this.groupCallState,
    this.onMinimize,
    this.onInvitePressed,
  });

  @override
  State<GroupCallsWidget> createState() => _GroupCallsWidgetState();
}

class _GroupCallsWidgetState extends State<GroupCallsWidget>
    with WidgetsBindingObserver, SafePageCloseMixin {
  /// 媒体设备是否已初始化（确保只初始化一次）
  bool _isMediaInitialized = false;

  @override
  void initState() {
    super.initState();
    // 注册生命周期监听
    WidgetsBinding.instance.addObserver(this);
    // Android：启动前台 Service 防止后台被杀
    if (Platform.isAndroid) {
      CallManager.instance.startForegroundService();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 初始化安全关闭机制
    initSafePageClose(context);

    // 初始化媒体设备（发起、加入、接听场景统一在此处理）
    // 使用标志位确保只执行一次
    if (!_isMediaInitialized) {
      _isMediaInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        GroupCallManager.instance.initializeMediaDevices();
      });
    }
  }

  @override
  void dispose() {
    // 恢复屏幕方向，避免影响宿主 App 其他页面
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    // 移除生命周期监听
    WidgetsBinding.instance.removeObserver(this);
    // 重置音视频设备状态（与 initializeMediaDevices 配对）
    GroupCallManager.instance.resetMediaDevices();
    // Android：关闭前台 Service
    if (Platform.isAndroid) {
      CallManager.instance.stopForegroundService();
    }
    // 释放安全关闭机制
    disposeSafePageClose();
    NEVideoRendererCache.instance.releaseAll();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        // 应用退到后台：可以在这里暂停视频渲染以节省资源
        // TODO: 调用 NEGroupCallEngine 暂停视频渲染
        break;
      case AppLifecycleState.resumed:
        // 应用恢复前台：恢复视频渲染
        // TODO: 调用 NEGroupCallEngine 恢复视频渲染
        // Android：确保前台 Service 正在运行
        if (Platform.isAndroid) {
          CallManager.instance.startForegroundService();
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 锁定竖屏方向（群呼 UI 基于竖屏设计，不支持横屏）
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // 初始化 ScreenUtil（基于 iPhone X 设计稿 375×812）
    ScreenUtil.init(context, designSize: const Size(375, 812));

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
      child: PopScope(
        canPop: false,
        child: Scaffold(
        backgroundColor: Colors.black,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: ListenableBuilder(
          listenable: widget.groupCallState,
          builder: (context, child) {
            return Stack(
              children: [
                // 毛玻璃背景
                _buildBlurredBackground(),

                // 主要内容
                SafeArea(
                  child: Column(
                    children: [
                      // AppBar
                      GroupCallAppBar(
                        uiState: widget.groupCallState.uiState,
                        durationNotifier: widget.groupCallState.durationNotifier,
                        onMinimize: onMinimize,
                        onInvitePressed: widget.onInvitePressed != null
                            ? () => widget.onInvitePressed!(widget.groupCallState.callId)
                            : null,
                      ),

                      // 视频区域（扩展以填充剩余空间）
                      Expanded(
                        child: _buildVideoArea(),
                      ),

                      // 底部功能按钮
                      GroupCallFunctionWidget(
                        uiState: widget.groupCallState.uiState,
                        isMicMuted: widget.groupCallState.isMicrophoneMute,
                        isSpeakerOn: widget.groupCallState.isSpeakerOn,
                        isCameraOn: widget.groupCallState.isCameraOpen,
                        onToggleMic: _handleToggleMic,
                        onToggleSpeaker: _handleToggleSpeaker,
                        onToggleCamera: _handleToggleCamera,
                        onHangup: _handleHangup,
                      ),

                      // iOS Home Indicator 占位
                      SizedBox(height: 34.w),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      ),
    );
  }

  /// 构建毛玻璃背景
  ///
  /// 使用本地用户（自己）的头像作为背景图片，应用模糊效果
  /// 如果没有头像则使用深色渐变背景
  Widget _buildBlurredBackground() {
    // 使用本地用户（自己）的头像作为背景
    final backgroundAvatar = _findLocalUserAvatar();

    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 背景图片层（铺满并放大避免模糊边缘）
          Positioned.fill(
            child: backgroundAvatar != null
                ? Image.network(
                    backgroundAvatar,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildDefaultBackground(),
                  )
                : _buildDefaultBackground(),
          ),
      
          // 模糊层 + 半透明遮罩
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

  /// 查找本地用户（自己）的头像
  String? _findLocalUserAvatar() {
    for (final member in widget.groupCallState.members) {
      if (member.isLocal && member.avatar != null && member.avatar!.isNotEmpty) {
        return member.avatar;
      }
    }
    return null;
  }

  /// 构建默认背景（深色渐变）
  Widget _buildDefaultBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2C2C2C),
            Color(0xFF1A1A1A),
          ],
        ),
      ),
    );
  }

  /// 构建视频区域
  ///
  /// 布局最多支持 maxGroupCallParticipants 人，超出时优先保留自己，其余按顺序截取
  Widget _buildVideoArea() {
    var members = widget.groupCallState.members;
    final maxParticipants = GroupCallManager.maxGroupCallParticipants;
    if (members.length > maxParticipants) {
      final localMember = members.where((m) => m.isLocal).toList();
      final remoteMember = members.where((m) => !m.isLocal).toList();
      members = [...localMember, ...remoteMember].take(maxParticipants).toList();
    }
    return GroupCallGridLayout(
      members: members,
      isEnlargedMode: widget.groupCallState.isEnlargedMode,
      enlargedMemberUserId: widget.groupCallState.enlargedMemberUserId,
      onMemberTap: _handleMemberTap,
      onSwitchCamera: _handleSwitchCamera,
    );
  }

  // ============================================================================
  // 事件处理方法
  // ============================================================================

  /// 处理麦克风切换
  void _handleToggleMic() {
    GroupCallManager.instance.toggleMicrophone();
  }

  /// 处理扬声器切换
  void _handleToggleSpeaker() {
    GroupCallManager.instance.toggleSpeaker();
  }

  /// 处理摄像头切换
  void _handleToggleCamera() {
    GroupCallManager.instance.toggleCamera();
  }

  /// 处理挂断
  void _handleHangup() {
    GroupCallManager.instance.hangup(widget.groupCallState.callId);
    Navigator.of(context).pop();
  }

  /// 处理切换摄像头
  void _handleSwitchCamera() {
    GroupCallManager.instance.switchCamera();
  }

  /// 处理点击成员视图（进入放大模式）
  void _handleMemberTap(String userId) {
    if (widget.groupCallState.isEnlargedMode) {
      // 如果已经在放大模式，点击当前放大的成员则退出放大模式
      if (widget.groupCallState.enlargedMemberUserId == userId) {
        widget.groupCallState.exitEnlargedMode();
      } else {
        // 否则切换到点击的成员
        widget.groupCallState.switchEnlargedMember(userId);
      }
    } else {
      // 进入放大模式
      widget.groupCallState.enterEnlargedMode(userId);
    }
  }

  /// 处理缩小按钮
  void onMinimize() {
    widget.onMinimize?.call();
    // 默认行为：关闭页面（接入方可自定义浮窗等）
    Navigator.of(context).pop();
  }
}
