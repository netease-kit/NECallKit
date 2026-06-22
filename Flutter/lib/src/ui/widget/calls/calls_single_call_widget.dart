// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:netease_callkit_ui/src/data/constants.dart';
import 'package:netease_callkit_ui/src/data/user.dart';
import 'package:netease_callkit_ui/src/event/event_notify.dart';
import 'package:netease_callkit_ui/src/platform/platform_compat.dart';
import 'package:netease_callkit_ui/src/ui/widget/calls/calls_user_widget_data.dart';
import 'package:netease_callkit_ui/src/utils/string_stream.dart';

class CallsIndividualUserWidget extends StatefulWidget {
  final Function close;

  const CallsIndividualUserWidget({
    super.key,
    required this.close,
  });

  @override
  State<StatefulWidget> createState() => _CallsIndividualUserWidgetState();
}

class _CallsIndividualUserWidgetState extends State<CallsIndividualUserWidget>
    with SingleTickerProviderStateMixin {
  static const String _tag = 'CallsIndividualUserWidget';
  static const Size _desktopDefaultLocalVideoSize = Size(1280, 720);
  NEEventCallback? setSateCallBack;
  final Key _bigViewKey = GlobalKey(debugLabel: 'bigView');
  final Key _smallViewKey = GlobalKey(debugLabel: 'smallView');

  // 保存大画面和小画面的viewId
  int? _bigViewId;
  int? _smallViewId;
  NECallType? _lastBoundCallType;
  NECallStatus? _lastBoundCallStatus;
  bool? _lastBoundIsLocalViewBig;
  bool? _lastBoundPreferLocalPreviewBeforeRemoteVideo;
  String? _lastBoundPrimaryRemoteUserId;
  int? _lastBoundRemoteUserCount;

  // Desktop-only: actual video frame dimensions for each source.
  Size _localVideoSize = Size.zero;
  Size _remoteVideoSize = Size.zero;
  StreamSubscription<Map<String, dynamic>>? _rtcRawSub;

  // 添加动画控制器和状态管理
  late AnimationController _animationController;

  // _localVideoView 固定为大画面，保存 bigViewId
  late final Widget _bigVideoView = NECallkitVideoView(
      key: _bigViewKey,
      onPlatformViewCreated: (viewId) {
        _bigViewId = viewId;
        if (PlatformCompat.isOhos) {
          return;
        }
        var isLocalViewBig = _keepLocalPreviewOnConnect()
            ? true
            : CallState.instance.isLocalViewBig;
        if (isLocalViewBig) {
          CallManager.instance.setupLocalView(_bigViewId!);
          if (CallState.instance.isCameraOpen) {
            CallManager.instance
                .openCamera(CallState.instance.camera, _bigViewId!);
          }
        } else {
          if (CallState.instance.remoteUserList.isNotEmpty) {
            CallManager.instance.setupRemoteView(
                CallState.instance.remoteUserList[0].id, _bigViewId!);
          }
        }
      },
      onVideoViewReady: () {
        // HarmonyOS: 必须等待 onLoad 回调后再设置视频画布
        if (_bigViewId == null || !PlatformCompat.isOhos) return;
        var isLocalViewBig = _keepLocalPreviewOnConnect()
            ? true
            : CallState.instance.isLocalViewBig;
        if (isLocalViewBig) {
          CallManager.instance.setupLocalView(_bigViewId!);
          if (CallState.instance.isCameraOpen) {
            CallManager.instance
                .openCamera(CallState.instance.camera, _bigViewId!);
          }
        } else {
          if (CallState.instance.remoteUserList.isNotEmpty) {
            CallManager.instance.setupRemoteView(
                CallState.instance.remoteUserList[0].id, _bigViewId!);
          }
        }
      });

  // _remoteVideoView 固定为小画面，保存 smallViewId
  late final Widget _smallVideoView = NECallkitVideoView(
      key: _smallViewKey,
      desktopVideoFit: BoxFit.cover,
      onPlatformViewCreated: (viewId) {
        _smallViewId = viewId;
        if (PlatformCompat.isOhos) {
          return;
        }
        var isLocalViewBig = _keepLocalPreviewOnConnect()
            ? true
            : CallState.instance.isLocalViewBig;
        if (isLocalViewBig) {
          if (CallState.instance.remoteUserList.isNotEmpty) {
            CallManager.instance.setupRemoteView(
                CallState.instance.remoteUserList[0].id, _smallViewId!);
          }
        } else {
          CallManager.instance.setupLocalView(_smallViewId!);
          if (CallState.instance.isCameraOpen) {
            CallManager.instance
                .openCamera(CallState.instance.camera, _smallViewId!);
          }
        }
      },
      onVideoViewReady: () {
        // HarmonyOS: 必须等待 onLoad 回调后再设置视频画布
        if (_smallViewId == null || !PlatformCompat.isOhos) return;
        // 初始状态：小画面显示远程视频
        var isLocalViewBig = _keepLocalPreviewOnConnect()
            ? true
            : CallState.instance.isLocalViewBig;
        if (isLocalViewBig) {
          if (CallState.instance.remoteUserList.isNotEmpty) {
            CallManager.instance.setupRemoteView(
                CallState.instance.remoteUserList[0].id, _smallViewId!);
          }
        } else {
          CallManager.instance.setupLocalView(_smallViewId!);
          if (CallState.instance.isCameraOpen) {
            CallManager.instance
                .openCamera(CallState.instance.camera, _smallViewId!);
          }
        }
      });

  NEEventCallback? _refreshCallback;

  /// 刷新视频视图（不重建 widget，直接重新设置视频流）
  bool _keepLocalPreviewOnConnect() {
    if (Platform.isIOS) {
      return false;
    }
    return CallState.instance.callType == NECallType.video &&
        CallState.instance.selfUser.callStatus == NECallStatus.accept &&
        CallState.instance.preferLocalPreviewBeforeRemoteVideo;
  }

  void _refreshVideoViews() {
    CallKitUILog.i(_tag, 'Refreshing video views');

    // 重新绑定视频流
    final keepLocalPreviewOnConnect = _keepLocalPreviewOnConnect();
    var isLocalViewBig =
        keepLocalPreviewOnConnect ? true : CallState.instance.isLocalViewBig;

    if (isLocalViewBig) {
      // 大画面显示本地视频，小画面显示远程视频
      if (_bigViewId != null) {
        CallManager.instance.setupLocalView(_bigViewId!);
      }
      if (!keepLocalPreviewOnConnect &&
          _smallViewId != null &&
          CallState.instance.remoteUserList.isNotEmpty) {
        CallManager.instance.setupRemoteView(
            CallState.instance.remoteUserList[0].id, _smallViewId!);
      }
    } else {
      // 大画面显示远程视频，小画面显示本地视频
      if (_bigViewId != null && CallState.instance.remoteUserList.isNotEmpty) {
        CallManager.instance.setupRemoteView(
            CallState.instance.remoteUserList[0].id, _bigViewId!);
      }
      if (_smallViewId != null) {
        CallManager.instance.setupLocalView(_smallViewId!);
      }
    }
    _recordVideoBindingState();
    CallKitUILog.i(
      _tag,
      'refreshVideoViews bound big=${isLocalViewBig ? 'local' : 'remote'} '
      'small=${isLocalViewBig ? 'remote' : 'local'} '
      'keepLocalPreview=$keepLocalPreviewOnConnect '
      'isLocalViewBig=${CallState.instance.isLocalViewBig} '
      'bigViewId=$_bigViewId smallViewId=$_smallViewId',
    );
    _logSmallViewLayout('refreshVideoViews');
  }

  bool _shouldRefreshVideoViews() {
    final remoteUserList = CallState.instance.remoteUserList;
    final primaryRemoteUserId =
        remoteUserList.isEmpty ? null : remoteUserList.first.id;
    return _lastBoundCallType != CallState.instance.callType ||
        _lastBoundCallStatus != CallState.instance.selfUser.callStatus ||
        _lastBoundIsLocalViewBig != CallState.instance.isLocalViewBig ||
        _lastBoundPreferLocalPreviewBeforeRemoteVideo !=
            CallState.instance.preferLocalPreviewBeforeRemoteVideo ||
        _lastBoundPrimaryRemoteUserId != primaryRemoteUserId ||
        _lastBoundRemoteUserCount != remoteUserList.length;
  }

  void _recordVideoBindingState() {
    final remoteUserList = CallState.instance.remoteUserList;
    _lastBoundCallType = CallState.instance.callType;
    _lastBoundCallStatus = CallState.instance.selfUser.callStatus;
    _lastBoundIsLocalViewBig = CallState.instance.isLocalViewBig;
    _lastBoundPreferLocalPreviewBeforeRemoteVideo =
        CallState.instance.preferLocalPreviewBeforeRemoteVideo;
    _lastBoundPrimaryRemoteUserId =
        remoteUserList.isEmpty ? null : remoteUserList.first.id;
    _lastBoundRemoteUserCount = remoteUserList.length;
  }

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animationController.forward();
    _recordVideoBindingState();
    setSateCallBack = (arg) {
      if (mounted) {
        setState(() {});
        final skipVideoRefresh =
            arg is Map<String, dynamic> && arg['refreshVideoViews'] == false;
        if (!skipVideoRefresh && _shouldRefreshVideoViews()) {
          _refreshVideoViews();
        }
      }
    };
    CallKitUILog.i(_tag, 'initState register NEEventNotify');
    NEEventNotify().register(setStateEvent, setSateCallBack);

    // 注册应用外悬浮窗返回事件
    _refreshCallback = (arg) {
      if (mounted) {
        // 重新设置视频流，使用现有的 viewId
        _refreshVideoViews();
      }
    };
    NEEventNotify().register('refreshVideoViews', _refreshCallback);

    if (Platform.isMacOS || Platform.isWindows) {
      _rtcRawSub = NECallEngine.instance.rtcRawEvents.listen(_onRtcRawEvent);
      CallKitUILog.i(_tag, 'rtcRawEvents subscribed desktop runtime');
      _logSmallViewLayout('rtcRawSubscriptionReady');
    }
  }

  @override
  void dispose() {
    _rtcRawSub?.cancel();
    // Dispose animation and unregister listeners before super.dispose()
    _animationController.dispose();
    NEEventNotify().unregister(setStateEvent, setSateCallBack);
    if (_refreshCallback != null) {
      NEEventNotify().unregister('refreshVideoViews', _refreshCallback);
    }

    final shouldReleaseLocalView = !CallState.instance.isOpenFloatWindow ||
        CallState.instance.selfUser.callStatus != NECallStatus.accept;
    CallKitUILog.i(
      _tag,
      'dispose releaseLocalView=$shouldReleaseLocalView, '
      'isOpenFloatWindow=${CallState.instance.isOpenFloatWindow}, '
      'callStatus=${CallState.instance.selfUser.callStatus}, '
      'currentCallId=${CallState.instance.currentCallId}, '
      'bigViewId=$_bigViewId, smallViewId=$_smallViewId',
    );

    // 如果悬浮窗未打开或通话未接听，则释放本地视频资源
    final isPotentialPipReturn = PlatformCompat.isOhos &&
        CallState.instance.enableFloatWindowOutOfApp &&
        CallState.instance.enableFloatWindow &&
        CallState.instance.selfUser.callStatus == NECallStatus.accept &&
        NECallKitNavigatorObserver.currentPage == CallPage.callingPage;

    if (shouldReleaseLocalView && !isPotentialPipReturn) {
      CallManager.instance.setupLocalView(-1);
    } else {
      CallKitUILog.i(
        _tag,
        'dispose keep local view binding for float window reuse '
        'isPotentialPipReturn=$isPotentialPipReturn',
      );
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: _getBackgroundColor(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildBackground(),
            _buildBigVideoWidget(),
            CallsIndividualUserWidgetData.isOnlyShowBigVideoView
                ? const SizedBox()
                : _buildSmallVideoWidget(),
            CallsIndividualUserWidgetData.isOnlyShowBigVideoView
                ? const SizedBox()
                : _buildUserInfoWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    var avatar = '';
    if (CallState.instance.remoteUserList.isNotEmpty) {
      avatar = StringStream.makeNull(
          CallState.instance.remoteUserList[0].avatar, Constants.defaultAvatar);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Image(
          height: double.infinity,
          image: NetworkImage(avatar),
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stackTrace) => Image.asset(
            'assets/images/user_icon.png',
            package: 'netease_callkit_ui',
          ),
        ),
        Opacity(
            opacity: 1,
            child: Container(
              color: const Color.fromRGBO(45, 45, 45, 0.9),
            ))
      ],
    );
  }

  Widget _buildUserInfoWidget() {
    var showName = '';
    var avatar = '';
    if (CallState.instance.remoteUserList.isNotEmpty) {
      showName = User.getUserDisplayName(CallState.instance.remoteUserList[0]);
      avatar = StringStream.makeNull(
          CallState.instance.remoteUserList[0].avatar, Constants.defaultAvatar);
    }

    final userInfoWidget = Positioned(
        top: MediaQuery.of(context).size.height / 4,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 110,
              width: 110,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Image(
                image: NetworkImage(avatar),
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stackTrace) => Image.asset(
                  'assets/images/user_icon.png',
                  package: 'netease_callkit_ui',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              showName,
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontSize: 24,
                color: _getTextColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ));

    if (CallState.instance.callType == NECallType.video &&
        CallState.instance.selfUser.callStatus == NECallStatus.accept) {
      return const SizedBox();
    }
    return userInfoWidget;
  }

  Widget _buildBigVideoWidget() {
    var remoteAvatar = '';
    var remoteVideoAvailable = false;
    if (CallState.instance.remoteUserList.isNotEmpty) {
      remoteAvatar = StringStream.makeNull(
          CallState.instance.remoteUserList[0].avatar, Constants.defaultAvatar);
      remoteVideoAvailable =
          CallState.instance.remoteUserList[0].videoAvailable;
    }
    var selfAvatar = StringStream.makeNull(
        CallState.instance.selfUser.avatar, Constants.defaultAvatar);
    var isCameraOpen = CallState.instance.isCameraOpen;

    if (CallState.instance.callType == NECallType.audio) {
      return const SizedBox();
    }

    var isLocalViewBig = true;
    if (CallState.instance.selfUser.callStatus == NECallStatus.waiting) {
      isLocalViewBig = true;
    } else {
      isLocalViewBig = _keepLocalPreviewOnConnect()
          ? true
          : CallState.instance.isLocalViewBig;
    }

    return CallState.instance.callType == NECallType.video
        ? InkWell(
            onTap: () {
              CallsIndividualUserWidgetData.isOnlyShowBigVideoView =
                  !CallsIndividualUserWidgetData.isOnlyShowBigVideoView;
              NEEventNotify().notify(setStateEventGroupCallUserWidgetRefresh);
            },
            child: Container(
              color: Colors.black54,
              child: Stack(
                children: [
                  CallState.instance.selfUser.callStatus == NECallStatus.accept
                      ? Visibility(
                          visible: (isLocalViewBig
                              ? !isCameraOpen
                              : !remoteVideoAvailable),
                          child: Center(
                              child: Container(
                            height: 80,
                            width: 80,
                            clipBehavior: Clip.hardEdge,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Image(
                              image: NetworkImage(
                                  isLocalViewBig ? selfAvatar : remoteAvatar),
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stackTrace) =>
                                  Image.asset(
                                'assets/images/user_icon.png',
                                package: 'netease_callkit_ui',
                              ),
                            ),
                          )),
                        )
                      : Container(),
                  Opacity(
                      opacity: isLocalViewBig
                          ? _getOpacityByVis(isCameraOpen)
                          : _getOpacityByVis(remoteVideoAvailable),
                      child: _bigVideoView)
                ],
              ),
            ))
        : Container();
  }

  Widget _buildSmallVideoWidget() {
    if (CallState.instance.callType == NECallType.audio) {
      return const SizedBox();
    }
    if (_keepLocalPreviewOnConnect()) {
      return const SizedBox();
    }

    var isRemoteViewSmall = true;

    if (CallState.instance.selfUser.callStatus == NECallStatus.accept) {
      if (CallState.instance.isLocalViewBig) {
        isRemoteViewSmall = true;
      } else {
        isRemoteViewSmall = false;
      }
    }

    // 获取视频状态信息
    var remoteAvatar = '';
    var remoteVideoAvailable = false;
    var remoteAudioAvailable = false;

    if (CallState.instance.remoteUserList.isNotEmpty) {
      remoteAvatar = StringStream.makeNull(
          CallState.instance.remoteUserList[0].avatar, Constants.defaultAvatar);
      remoteVideoAvailable =
          CallState.instance.remoteUserList[0].videoAvailable;
      remoteAudioAvailable =
          CallState.instance.remoteUserList[0].audioAvailable;
    }
    var selfAvatar = StringStream.makeNull(
        CallState.instance.selfUser.avatar, Constants.defaultAvatar);
    var isCameraOpen = CallState.instance.isCameraOpen;

    var smallVideoWidget =
        CallState.instance.selfUser.callStatus == NECallStatus.accept
            ? Container(
                height: _smallViewHeight,
                width: _smallViewWidth,
                color: Colors.black54,
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Visibility(
                      visible: (isRemoteViewSmall
                          ? !remoteVideoAvailable
                          : !isCameraOpen),
                      child: Center(
                        child: Container(
                          height: 80,
                          width: 80,
                          clipBehavior: Clip.hardEdge,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Image(
                            image: NetworkImage(
                                isRemoteViewSmall ? remoteAvatar : selfAvatar),
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stackTrace) => Image.asset(
                              'assets/images/user_icon.png',
                              package: 'netease_callkit_ui',
                            ),
                          ),
                        ),
                      ),
                    ),
                    Opacity(
                        opacity: isRemoteViewSmall
                            ? _getOpacityByVis(remoteVideoAvailable)
                            : _getOpacityByVis(isCameraOpen),
                        child: _smallVideoView),
                    Positioned(
                      left: 5,
                      bottom: 5,
                      width: 20,
                      height: 20,
                      child: (isRemoteViewSmall && !remoteAudioAvailable)
                          ? Image.asset(
                              'assets/images/audio_unavailable_grey.png',
                              package: 'netease_callkit_ui',
                            )
                          : const SizedBox(),
                    )
                  ],
                ))
            : Container();

    return Positioned(
        top: CallsIndividualUserWidgetData.smallViewTop - 40,
        right: CallsIndividualUserWidgetData.smallViewRight,
        child: GestureDetector(
          onTap: _changeVideoView,
          onPanUpdate: (DragUpdateDetails e) {
            if (CallState.instance.callType == NECallType.video) {
              CallsIndividualUserWidgetData.smallViewRight -= e.delta.dx;
              CallsIndividualUserWidgetData.smallViewTop += e.delta.dy;
              if (CallsIndividualUserWidgetData.smallViewTop < 100) {
                CallsIndividualUserWidgetData.smallViewTop = 100;
              }
              if (CallsIndividualUserWidgetData.smallViewTop >
                  MediaQuery.of(context).size.height - _smallViewHeight) {
                CallsIndividualUserWidgetData.smallViewTop =
                    MediaQuery.of(context).size.height - _smallViewHeight;
              }
              if (CallsIndividualUserWidgetData.smallViewRight < 0) {
                CallsIndividualUserWidgetData.smallViewRight = 0;
              }
              if (CallsIndividualUserWidgetData.smallViewRight >
                  MediaQuery.of(context).size.width - _smallViewWidth) {
                CallsIndividualUserWidgetData.smallViewRight =
                    MediaQuery.of(context).size.width - _smallViewWidth;
              }
              setState(() {});
            }
          },
          child: SizedBox(
            width: _smallViewWidth,
            child: smallVideoWidget,
          ),
        ));
  }

  static const double _smallViewShortSide = 110.0;
  static const double _smallViewLongSide = 216.0;

  bool get _isDesktopRuntime => Platform.isMacOS || Platform.isWindows;

  bool get _isLocalVideoOnBigView =>
      _keepLocalPreviewOnConnect() || CallState.instance.isLocalViewBig;

  bool get _hasLocalVideoSize =>
      _localVideoSize.width > 0 && _localVideoSize.height > 0;

  bool get _shouldUseDesktopLocalVideoFallback =>
      _isDesktopRuntime &&
      !_isLocalVideoOnBigView &&
      !_hasLocalVideoSize &&
      CallState.instance.callType == NECallType.video &&
      CallState.instance.selfUser.callStatus == NECallStatus.accept;

  // Keep the desktop small view shape stable when the local slot falls back to
  // avatar before any local size callback arrives.
  Size get _effectiveLocalVideoSize => _shouldUseDesktopLocalVideoFallback
      ? _desktopDefaultLocalVideoSize
      : _localVideoSize;

  Size get _smallViewVideoSize =>
      _isLocalVideoOnBigView ? _remoteVideoSize : _effectiveLocalVideoSize;

  bool get _isSmallViewLandscape =>
      _isDesktopRuntime &&
      _smallViewVideoSize.width > _smallViewVideoSize.height &&
      _smallViewVideoSize.width > 0;

  double get _smallViewWidth =>
      _isSmallViewLandscape ? _smallViewLongSide : _smallViewShortSide;
  double get _smallViewHeight =>
      _isSmallViewLandscape ? _smallViewShortSide : _smallViewLongSide;

  String _formatSize(Size size) =>
      '${size.width.toInt()}x${size.height.toInt()}';

  void _logSmallViewLayout(
    String reason, {
    String? eventName,
    int? width,
    int? height,
  }) {
    final localSize = _formatSize(_localVideoSize);
    final remoteSize = _formatSize(_remoteVideoSize);
    final effectiveSmallSize = _formatSize(_smallViewVideoSize);
    final fallbackLocal = _shouldUseDesktopLocalVideoFallback
        ? _formatSize(_desktopDefaultLocalVideoSize)
        : 'off';
    final rawSize =
        width != null && height != null ? ' raw=${width}x$height' : '';
    CallKitUILog.i(
      _tag,
      '[smallView] reason=$reason'
      '${eventName == null ? '' : ' event=$eventName'}$rawSize '
      'smallSource=${_isLocalVideoOnBigView ? 'remote' : 'local'} '
      'keepLocalPreview=${_keepLocalPreviewOnConnect()} '
      'isLocalViewBig=${CallState.instance.isLocalViewBig} '
      'local=$localSize remote=$remoteSize fallbackLocal=$fallbackLocal '
      'effectiveSmall=$effectiveSmallSize '
      'landscape=$_isSmallViewLandscape '
      'frame=${_smallViewWidth.toInt()}x${_smallViewHeight.toInt()}',
    );
  }

  void _onRtcRawEvent(Map<String, dynamic> event) {
    if (!mounted) return;
    final eventName = event['event'] as String?;
    if (eventName != 'onRemoteVideoReceiveSizeChanged' &&
        eventName != 'onFirstVideoFrameDecoded' &&
        eventName != 'onLocalVideoRenderSizeChanged') {
      return;
    }

    final w = (event['width'] as num?)?.toInt();
    final h = (event['height'] as num?)?.toInt();
    if (w == null || h == null || w <= 0 || h <= 0) {
      _logSmallViewLayout(
        'rtcRawIgnoredInvalidSize',
        eventName: eventName,
        width: w,
        height: h,
      );
      return;
    }

    if (eventName == 'onRemoteVideoReceiveSizeChanged' ||
        eventName == 'onFirstVideoFrameDecoded') {
      setState(() => _remoteVideoSize = Size(w.toDouble(), h.toDouble()));
    } else if (eventName == 'onLocalVideoRenderSizeChanged') {
      setState(() => _localVideoSize = Size(w.toDouble(), h.toDouble()));
    }
    _logSmallViewLayout(
      'rtcRawUpdated',
      eventName: eventName,
      width: w,
      height: h,
    );
  }

  void _changeVideoView() {
    if (CallState.instance.callType == NECallType.audio ||
        CallState.instance.selfUser.callStatus == NECallStatus.waiting) {
      return;
    }

    // 切换状态
    CallState.instance.isLocalViewBig = !CallState.instance.isLocalViewBig;

    _refreshVideoViews();

    setState(() {});
    _logSmallViewLayout('changeVideoView');
  }

  double _getOpacityByVis(bool vis) {
    return vis ? 1.0 : 0;
  }

  Color _getBackgroundColor() {
    return CallState.instance.callType == NECallType.audio
        ? const Color(0xFFF2F2F2)
        : const Color(0xFF444444);
  }

  Color _getTextColor() {
    return Colors.white;
  }
}
