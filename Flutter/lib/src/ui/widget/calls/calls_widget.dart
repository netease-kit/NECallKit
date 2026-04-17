// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:netease_callkit_ui/src/platform/platform_compat.dart';

import 'package:flutter/material.dart';
import 'package:netease_callkit/netease_callkit.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:netease_callkit_ui/src/data/constants.dart';
import 'package:netease_callkit_ui/src/data/user.dart';
import 'package:netease_callkit_ui/src/event/event_notify.dart';
import 'package:netease_callkit_ui/src/platform/call_kit_platform_interface.dart';
import 'package:netease_callkit_ui/src/ui/widget/calls/calls_function_widget.dart';
import 'package:netease_callkit_ui/src/ui/widget/calls/calls_user_widget_data.dart';
import 'package:netease_callkit_ui/src/ui/widget/common/float_permission_dialog.dart';
import 'package:netease_callkit_ui/src/ui/widget/common/timing_widget.dart';

import 'calls_single_call_widget.dart';

class CallsWidget extends StatefulWidget {
  static bool isFunctionExpand = true;
  final Function close;

  const CallsWidget({
    super.key,
    required this.close,
  });

  @override
  State<CallsWidget> createState() => _CallsWidgetState();
}

class _CallsWidgetState extends State<CallsWidget>
    with TickerProviderStateMixin {
  static const String _tag = 'CallsWidgetState';
  late NEEventCallback setStateCallBack;
  late NEEventCallback groupCallUserWidgetRefreshCallback;
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _fadeOutAnimation;
  bool isDirectMulti = false;
  bool isMultiPerson = false;
  bool isShowInvite = false;
  bool _isCaptionEnabled = false; // 字幕是否开启
  bool isShowTranslation = false; // 是否显示翻译字幕
  // ASR 字幕信息列表（仅保留最新的两条，类似 Android 端 AISubtitle.translationInfo）
  final List<_TranslationInfo> _captionInfos = [];
  late NECallEngineDelegate _captionDelegate; // 字幕回调代理
  Offset _captionOffset = Offset.zero; // 字幕组件的位置偏移量
  NECallType? _lastCallType; // 记录上次的通话类型，用于检测类型变化

  void _initUsersViewWidget() {
    CallsIndividualUserWidgetData.isOnlyShowBigVideoView = false;
    CallsMultiUserWidgetData.initBlockCounter();
    CallsMultiUserWidgetData.updateBlockBigger(
        CallState.instance.remoteUserList.length + 1);
    CallsMultiUserWidgetData.initCanPlaceSquare(
        CallsMultiUserWidgetData.blockBigger,
        CallState.instance.remoteUserList.length + 1);

    CallsMultiUserWidgetData.blockCount++;

    for (var _ in CallState.instance.remoteUserList) {
      CallsMultiUserWidgetData.blockCount++;
    }
    setState(() {
      if (!isMultiPerson) {
        isMultiPerson = true;
        _controller.forward();
      }
    });
  }

  void _initAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _fadeOutAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
  }

  @override
  void initState() {
    super.initState();
    CallsWidget.isFunctionExpand = true;
    CallsIndividualUserWidgetData.initIndividualUserWidgetData();
    if (CallState.instance.groupId != '') {
      isDirectMulti = true;
      isShowInvite = true;
    }

    _initAnimation();

    // 初始化字幕回调代理
    _captionDelegate = NECallEngineDelegate(
      onAsrCaptionStateChanged: (asrState, code, message) {
        CallKitUILog.i(_tag,
            'onAsrCaptionStateChanged: asrState=$asrState, code=$code, message=$message');
        if (mounted) {
          setState(() {
            if (code == 2) {
              // 如果出错，关闭字幕
              _isCaptionEnabled = true;
            } else if (code == 3) {
              _isCaptionEnabled = false;
            }
          });
        }
      },
      onAsrCaptionResult: (results) async {
        // CallKitUILog.i(_tag, 'onAsrCaptionResult: result=${results}');
        if (!mounted) return;

        // 先异步计算所有显示名，避免在 setState 中执行异步操作
        final newInfos = <_TranslationInfo>[];
        for (var result in results) {
          if (result == null) continue;
          // 仅处理最终结果，避免中间结果频繁刷新
          if (!result.isFinal) continue;

          CallKitUILog.i(
              _tag,
              'onAsrCaptionResult: uid=${result.uid}, '
              'content=${result.content}, translated=${result.translatedText}, '
              'haveTranslation=${result.haveTranslation}, isFinal=${result.isFinal}');

          final displayName = await _resolveDisplayName(result);

          // 构建字幕信息并追加到列表（同时保存原文和翻译，具体展示由 isShowTranslation 决定）
          final info = _TranslationInfo(
            uid: result.uid,
            content: result.content,
            translatedText: result.translatedText,
            haveTranslation: result.haveTranslation,
            displayName: displayName,
          );
          newInfos.add(info);
        }

        if (!mounted || newInfos.isEmpty) return;

        setState(() {
          for (final info in newInfos) {
            _captionInfos.add(info);
            // 只保留最新的两条字幕，和 Android AISubtitle 保持一致
            if (_captionInfos.length > 2) {
              _captionInfos.removeAt(0);
            }
          }
        });
      },
    );
    NECallEngine.instance.addCallDelegate(_captionDelegate);

    setStateCallBack = (arg) {
      if (mounted) {
        CallKitUILog.i(_tag,
            'state callback isMultiPerson:$isMultiPerson, remoteUserList length:${CallState.instance.remoteUserList.length}');
        if (isMultiPerson || CallState.instance.remoteUserList.length >= 2) {
          _initUsersViewWidget();
        } else {
          setState(() {});
        }
      }
    };

    groupCallUserWidgetRefreshCallback = (arg) {
      if (mounted) {
        if (CallsMultiUserWidgetData.hasBiggerSquare()) {
          CallsWidget.isFunctionExpand = false;
        } else {
          CallsWidget.isFunctionExpand = true;
        }
        setState(() {});
      }
    };

    NEEventNotify().register(setStateEvent, setStateCallBack);
    NEEventNotify().register(setStateEventGroupCallUserWidgetRefresh,
        groupCallUserWidgetRefreshCallback);

    CallsMultiUserWidgetData.initBlockBigger();
    if (isDirectMulti || CallState.instance.remoteUserList.length >= 2) {
      isDirectMulti = true;
      _initUsersViewWidget();
    }
  }

  @override
  void dispose() {
    // Stop animations and unregister listeners before calling super.dispose()
    _controller.dispose();
    NECallEngine.instance.removeCallDelegate(_captionDelegate);
    NEEventNotify().unregister(setStateEvent, setStateCallBack);
    NEEventNotify().unregister(setStateEventGroupCallUserWidgetRefresh,
        groupCallUserWidgetRefreshCallback);

    // 如果字幕正在运行，停止字幕
    if (_isCaptionEnabled) {
      unawaited(_stopASRCaptionSilently());
    }

    super.dispose();
  }

  // 静默停止字幕（用于dispose时清理资源）
  Future<void> _stopASRCaptionSilently() async {
    try {
      final result = await NECallEngine.instance.stopASRCaption();
      CallKitUILog.i(_tag,
          'stopASRCaption in dispose: code=${result.code}, msg=${result.msg}');
    } catch (e) {
      CallKitUILog.e(_tag, 'stopASRCaption in dispose error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // padding: const EdgeInsets.only(top: 40),
        color: const Color.fromRGBO(45, 45, 45, 1.0),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: <Widget>[
            Visibility(
              visible: !isDirectMulti && _fadeOutAnimation.value != 0 ||
                  !isMultiPerson,
              child: FadeTransition(
                opacity: _fadeOutAnimation,
                child: CallsIndividualUserWidget(close: widget.close),
              ),
            ),
            CallsIndividualUserWidgetData.isOnlyShowBigVideoView
                ? const SizedBox()
                : _buildTopWidget(),
            CallsIndividualUserWidgetData.isOnlyShowBigVideoView
                ? const SizedBox()
                : _buildFunctionWidget(),
            // 字幕显示区域
            _buildCaptionWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopWidget() {
    final floatWindowBtnWidget = CallState.instance.enableFloatWindow &&
            NECallStatus.accept == CallState.instance.selfUser.callStatus
        ? Visibility(
            visible: CallState.instance.enableFloatWindow &&
                NECallStatus.accept == CallState.instance.selfUser.callStatus,
            child: InkWell(
                onTap: _openFloatWindow,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 12, 12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: Image.asset(
                      'assets/images/floating_button.png',
                      package: 'netease_callkit_ui',
                    ),
                  ),
                )),
          )
        : const SizedBox();

    final timerWidget =
        (NECallStatus.accept == CallState.instance.selfUser.callStatus)
            ? const SizedBox(width: 100, child: Center(child: TimingWidget()))
            : const SizedBox();

    // 字幕按钮
    // final captionBtnWidget =
    //     NECallStatus.accept == CallState.instance.selfUser.callStatus
    //         ? Positioned(
    //             right: 16,
    //             child: InkWell(
    //               onTap: () => _toggleCaption(),
    //               child: Container(
    //                 padding:
    //                     const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    //                 decoration: BoxDecoration(
    //                   color: _isCaptionEnabled
    //                       ? Colors.blue.withAlpha((255.0 * 0.8).round())
    //                       : Colors.grey.withAlpha((255.0 * 0.6).round()),
    //                   borderRadius: BorderRadius.circular(16),
    //                 ),
    //                 child: Text(
    //                   _isCaptionEnabled ? '关闭字幕' : '打开字幕',
    //                   style: const TextStyle(
    //                     color: Colors.white,
    //                     fontSize: 12,
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           )
    //         : const SizedBox();

    return Positioned(
        top: 55,
        width: MediaQuery.of(context).size.width,
        height: 100,
        child: Stack(
          children: [
            Positioned(left: 16, child: floatWindowBtnWidget),
            Positioned(
                left: (MediaQuery.of(context).size.width / 2) - 50,
                child: timerWidget),
            // captionBtnWidget,
          ],
        ));
  }

  Widget _buildFunctionWidget() {
    return Positioned(
      left: 0,
      bottom: 0,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Visibility(
            visible: !isDirectMulti && _fadeOutAnimation.value != 0 ||
                !isMultiPerson,
            child: FadeTransition(
              opacity: _fadeOutAnimation,
              child: Container(
                margin: const EdgeInsets.only(bottom: 50),
                child: CallsFunctionWidget.buildIndividualFunctionWidget(
                    widget.close),
              ),
            ),
          ),
          isDirectMulti
              ? CallsFunctionWidget.buildMultiCallFunctionWidget(
                  context, widget.close)
              : Visibility(
                  visible: _fadeInAnimation.value != 0 || isMultiPerson,
                  child: FadeTransition(
                    opacity: _fadeInAnimation,
                    child: CallsFunctionWidget.buildMultiCallFunctionWidget(
                        context, widget.close),
                  ),
                ),
        ],
      ),
    );
  }

  void _openFloatWindow() async {
    CallKitUILog.i(_tag, 'CallsWidget openFloatWindow()');
    
    // 鸿蒙平台：视频通话使用画中画（PiP），语音通话使用普通悬浮窗
    if (PlatformCompat.isOhos) {
      if (CallState.instance.callType == NECallType.video) {
        // 视频通话：使用画中画模式
        debugPrint('NECallKitPip: Video call, opening PiP on HarmonyOS');
        try {
          // 先初始化画中画配置
          debugPrint('NECallKitPip: Calling setupPIP first...');
          await NECallKitPlatform.instance.setupPIP();
          
          // 然后启动画中画
          debugPrint('NECallKitPip: Calling startPIP...');
          final success = await NECallKitPlatform.instance.startPIP();
          debugPrint('NECallKitPip: startPIP result=$success');
          if (success) {
            // 画中画启动成功，退出通话页面
            debugPrint('NECallKitPip: PiP started successfully, exiting calling page');
            if (NECallKitNavigatorObserver.currentPage == CallPage.callingPage) {
              NECallKitNavigatorObserver.getInstance().exitCallingPage();
            }
          } else {
            debugPrint('NECallKitPip: PiP failed to start');
          }
        } catch (e) {
          debugPrint('NECallKitPip: Error starting PiP: $e');
        }
      } else {
        // 语音通话：使用普通悬浮窗
        debugPrint('NECallKitFloatWindow: Audio call, opening float window on HarmonyOS');
        await CallManager.instance.openFloatWindowWithPageState();
      }
      return;
    }
    
    // Android: 检查悬浮窗权限
    if (Platform.isAndroid) {
      var hasFloat = await NECallKitPlatform.instance.hasFloatPermission();
      if (!hasFloat) {
        if (mounted) {
          await FloatPermissionDialog.show(context);
          return;
        }
      }
      // 同时校验后台启动权限（MIUI 等机型）
      var hasBgStart =
          await NECallKitPlatform.instance.hasBackgroundStartPermission();
      if (!hasBgStart) {
        if (mounted) {
          await FloatPermissionDialog.show(context, isBackgroundStart: true);
          return;
        }
      }
    } else if (Platform.isIOS) {
    } else if (PlatformCompat.isOhos) {
      // OHOS 子窗口无需特殊权限
    }
    await CallManager.instance.openFloatWindowWithPageState();
  }

  // 切换字幕开关
  // void _toggleCaption() async {
  //   CallKitUILog.i(_tag,
  //       'CallsWidget _toggleCaption: _isCaptionEnabled=$_isCaptionEnabled');
  //
  //   if (!_isCaptionEnabled) {
  //     // 打开字幕
  //     try {
  //       final config = NEASRCaptionConfig(
  //         srcLanguage: 'zh', // 指定字幕的源语言，zh表示简体中文，AUTO表示中英文自动识别
  //       );
  //       final result = await NECallEngine.instance.startASRCaption(config);
  //       CallKitUILog.i(_tag,
  //           'startASRCaption result: code=${result.code}, msg=${result.msg}');
  //
  //       if (mounted) {
  //         setState(() {
  //           // 检查返回码，0表示成功
  //           if (result.code == 0) {
  //             _isCaptionEnabled = true;
  //             _captionInfos.clear(); // 清空之前的字幕
  //             _captionOffset = Offset.zero; // 重置位置
  //           } else {
  //             // 如果启动失败，保持关闭状态
  //             CallKitUILog.e(_tag,
  //                 'startASRCaption failed: code=${result.code}, msg=${result.msg}');
  //             _isCaptionEnabled = false;
  //           }
  //         });
  //       }
  //     } catch (e) {
  //       CallKitUILog.e(_tag, 'startASRCaption error: $e');
  //       if (mounted) {
  //         setState(() {
  //           _isCaptionEnabled = false;
  //         });
  //       }
  //     }
  //   } else {
  //     // 关闭字幕
  //     try {
  //       final result = await NECallEngine.instance.stopASRCaption();
  //       CallKitUILog.i(_tag,
  //           'stopASRCaption result: code=${result.code}, msg=${result.msg}');
  //
  //       if (mounted) {
  //         setState(() {
  //           // 检查返回码，0表示成功
  //           if (result.code == 0) {
  //             _isCaptionEnabled = false;
  //             _captionInfos.clear();
  //             _captionOffset = Offset.zero; // 重置位置
  //           } else {
  //             // 如果停止失败，记录错误但保持当前状态
  //             CallKitUILog.e(_tag,
  //                 'stopASRCaption failed: code=${result.code}, msg=${result.msg}');
  //             // 可以选择保持字幕开启状态，或者强制关闭
  //             _isCaptionEnabled = false;
  //             _captionInfos.clear();
  //             _captionOffset = Offset.zero; // 重置位置
  //           }
  //         });
  //       }
  //     } catch (e) {
  //       CallKitUILog.e(_tag, 'stopASRCaption error: $e');
  //       if (mounted) {
  //         setState(() {
  //           // 发生异常时，强制关闭字幕显示
  //           _isCaptionEnabled = false;
  //           _captionInfos.clear();
  //           _captionOffset = Offset.zero; // 重置位置
  //         });
  //       }
  //     }
  //   }
  // }

  // 构建字幕显示区域
  Widget _buildCaptionWidget() {
    if (!_isCaptionEnabled || _captionInfos.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 根据通话类型调整默认位置
    // 语音通话时，字幕显示在更靠上的位置（距离底部更远）
    // 视频通话时，字幕显示在较低的位置（避免遮挡视频画面）
    final currentCallType = CallState.instance.callType;
    final isAudioCall = currentCallType == NECallType.audio;
    final defaultBottom = isAudioCall ? 400.0 : 280.0; // 语音通话时更靠上
    const defaultLeft = 16.0; // 默认左边距
    final captionWidth = screenWidth - 32.0; // 字幕容器的宽度（屏幕宽度减去左右边距）
    const captionMaxHeight = 200.0; // 字幕容器的最大高度

    // 如果通话类型发生变化，重置字幕位置偏移量
    if (_lastCallType != null && _lastCallType != currentCallType) {
      _captionOffset = Offset.zero;
    }
    _lastCallType = currentCallType;

    // 计算实际位置，考虑拖动偏移量
    var left = defaultLeft + _captionOffset.dx;
    var bottom = defaultBottom - _captionOffset.dy; // dy 向上为正，所以用减法

    // 限制拖动范围，确保不超出屏幕
    left = left.clamp(0.0, screenWidth - captionWidth);
    bottom = bottom.clamp(0.0, screenHeight - captionMaxHeight - 100);

    return Positioned(
      bottom: bottom,
      left: left,
      child: GestureDetector(
        onPanUpdate: (details) {
          if (mounted) {
            setState(() {
              // 计算新的偏移量
              final newOffset = _captionOffset + details.delta;

              // 计算新位置
              final newLeft = defaultLeft + newOffset.dx;
              final newBottom = defaultBottom - newOffset.dy;

              // 限制拖动范围，确保不超出屏幕
              final clampedLeft =
                  newLeft.clamp(0.0, screenWidth - captionWidth);
              final clampedBottom =
                  newBottom.clamp(0.0, screenHeight - captionMaxHeight - 100);

              // 更新偏移量（考虑边界限制）
              _captionOffset = Offset(
                clampedLeft - defaultLeft,
                defaultBottom - clampedBottom,
              );
            });
          }
        },
        child: Container(
          width: captionWidth,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            // 语音通话时使用更明显的背景色
            color: CallState.instance.callType == NECallType.audio
                ? Colors.black.withAlpha((255.0 * 0.85).round())
                : Colors.black.withAlpha((255.0 * 0.7).round()),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withAlpha((255.0 * 0.3).round()),
              width: 1,
            ),
            // 语音通话时添加阴影效果，使其更突出
            boxShadow: CallState.instance.callType == NECallType.audio
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha((255.0 * 0.3).round()),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          constraints: const BoxConstraints(
            maxHeight: captionMaxHeight,
          ),
          child: SingleChildScrollView(
            reverse: true, // 从底部开始滚动
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: _captionInfos.map((info) {
                final isAudioCall =
                    CallState.instance.callType == NECallType.audio;
                final baseStyle = TextStyle(
                  color: Colors.white,
                  fontSize: isAudioCall ? 16 : 14, // 语音通话时字体稍大一些
                  height: 1.5,
                  fontWeight: isAudioCall ? FontWeight.w500 : FontWeight.normal,
                );
                final nameStyle = baseStyle.copyWith(
                  color: const Color(0xFFD9CC66),
                  fontWeight: FontWeight.bold,
                );

                // 根据 isShowTranslation 决定显示翻译还是原文
                final text = info.textToDisplay(isShowTranslation);
                if (text.isEmpty) {
                  return const SizedBox.shrink();
                }

                final displayName = info.displayName.isNotEmpty
                    ? info.displayName
                    : info.uid.toString();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$displayName:\n',
                          style: nameStyle,
                        ),
                        TextSpan(
                          text: '$text\n',
                          style: baseStyle,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  /// 根据 ASR 结果推导展示用的昵称，尽量与 Android 端逻辑对齐
  Future<String> _resolveDisplayName(NEAsrCaptionResult result) async {
    var userInfo = await NECallEngine.instance.getUserWithRtcUid(result.uid);
    // 本端用户
    if (userInfo?.accId == CallState.instance.selfUser.id) {
      final self = CallState.instance.selfUser;
      return User.getUserDisplayName(self);
    }

    // 远端用户：当前只支持单人通话场景，取第一个远端用户
    if (CallState.instance.remoteUserList.isNotEmpty) {
      final remote = CallState.instance.remoteUserList.first;
      return User.getUserDisplayName(remote);
    }

    // 兜底：使用 rtc uid
    return result.uid.toString();
  }
}

/// ASR 字幕单条信息，参考 Android 端 AISubtitle.TranslationInfo
class _TranslationInfo {
  _TranslationInfo({
    required this.uid,
    required this.content,
    required this.translatedText,
    required this.haveTranslation,
    required this.displayName,
  });

  final int uid;
  final String? content;
  final String? translatedText;
  final bool haveTranslation;
  final String displayName;

  /// 根据 isShowTranslation 决定展示文案：
  /// - true：优先展示翻译内容（如果有且非空）
  /// - false：展示原文内容
  String textToDisplay(bool isShowTranslation) {
    if (isShowTranslation &&
        haveTranslation &&
        (translatedText?.isNotEmpty ?? false)) {
      return translatedText!;
    }
    return content ?? '';
  }
}
