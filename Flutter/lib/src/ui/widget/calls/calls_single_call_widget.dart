// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netease_callkit/netease_callkit.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:netease_callkit_ui/src/event/event_notify.dart';
import 'package:netease_callkit_ui/src/ui/widget/calls/calls_user_widget_data.dart';
import 'package:netease_callkit_ui/src/data/constants.dart';
import 'package:netease_callkit_ui/src/data/user.dart';
import 'package:netease_callkit_ui/src/utils/string_stream.dart';

class CallsIndividualUserWidget extends StatefulWidget {
  final Function close;

  const CallsIndividualUserWidget({
    Key? key,
    required this.close,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CallsIndividualUserWidgetState();
}

class _CallsIndividualUserWidgetState extends State<CallsIndividualUserWidget>
    with SingleTickerProviderStateMixin {
  static const String _tag = "CallsIndividualUserWidget";
  NEEventCallback? setSateCallBack;
  final Key _bigViewKey = GlobalKey(debugLabel: "bigView");
  final Key _smallViewKey = GlobalKey(debugLabel: "smallView");

  // 保存大画面和小画面的viewId
  int? _bigViewId;
  int? _smallViewId;

  // 添加动画控制器和状态管理
  late AnimationController _animationController;

  // _localVideoView 固定为大画面，保存 bigViewId
  late final Widget _bigVideoView = NECallkitVideoView(
      key: _bigViewKey,
      onPlatformViewCreated: (viewId) {
        _bigViewId = viewId;
        bool isLocalViewBig = CallState.instance.isLocalViewBig;
        if (isLocalViewBig) {
          CallManager.instance.setupLocalView(viewId);
          if (CallState.instance.isCameraOpen) {
            CallManager.instance.openCamera(CallState.instance.camera, viewId);
          }
        } else {
          if (CallState.instance.remoteUserList.isNotEmpty) {
            CallManager.instance.setupRemoteView(
                CallState.instance.remoteUserList[0].id, viewId);
          }
        }
      });

  // _remoteVideoView 固定为小画面，保存 smallViewId
  late final Widget _smallVideoView = NECallkitVideoView(
      key: _smallViewKey,
      onPlatformViewCreated: (viewId) {
        _smallViewId = viewId;
        // 初始状态：小画面显示远程视频
        bool isLocalViewBig = CallState.instance.isLocalViewBig;
        if (isLocalViewBig) {
          if (CallState.instance.remoteUserList.isNotEmpty) {
            CallManager.instance.setupRemoteView(
                CallState.instance.remoteUserList[0].id, viewId);
          }
        } else {
          CallManager.instance.setupLocalView(viewId);
          if (CallState.instance.isCameraOpen) {
            CallManager.instance.openCamera(CallState.instance.camera, viewId);
          }
        }
      });

  NEEventCallback? _refreshCallback;

  /// 刷新视频视图（不重建 widget，直接重新设置视频流）
  void _refreshVideoViews() {
    CallKitUILog.i(_tag, 'Refreshing video views');

    // 重新绑定视频流
    bool isLocalViewBig = CallState.instance.isLocalViewBig;

    if (isLocalViewBig) {
      // 大画面显示本地视频，小画面显示远程视频
      if (_bigViewId != null) {
        CallManager.instance.setupLocalView(_bigViewId!);
      }
      if (_smallViewId != null &&
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
    setSateCallBack = (arg) {
      if (mounted) {
        setState(() {});
        _refreshVideoViews();
      }
    };
    CallKitUILog.i(_tag, "initState register NEEventNotify");
    NEEventNotify().register(setStateEvent, setSateCallBack);

    // 注册应用外悬浮窗返回事件
    _refreshCallback = (arg) {
      if (mounted) {
        // 重新设置视频流，使用现有的 viewId
        _refreshVideoViews();
      }
    };
    NEEventNotify().register('refreshVideoViews', _refreshCallback);
  }

  @override
  dispose() {
    // Dispose animation and unregister listeners before super.dispose()
    _animationController.dispose();
    NEEventNotify().unregister(setStateEvent, setSateCallBack);
    if (_refreshCallback != null) {
      NEEventNotify().unregister('refreshVideoViews', _refreshCallback);
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

  _buildBackground() {
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

  _buildUserInfoWidget() {
    var showName = '';
    var avatar = '';
    if (CallState.instance.remoteUserList.isNotEmpty) {
      showName = User.getUserDisplayName(CallState.instance.remoteUserList[0]);
      avatar = StringStream.makeNull(
          CallState.instance.remoteUserList[0].avatar, Constants.defaultAvatar);
    }
    CallKitUILog.i(_tag, "_buildUserInfoWidget avatar = $avatar");

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
              textScaleFactor: 1.0,
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

    bool isLocalViewBig = true;
    if (CallState.instance.selfUser.callStatus == NECallStatus.waiting) {
      isLocalViewBig = true;
    } else {
      isLocalViewBig = CallState.instance.isLocalViewBig;
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

    bool isRemoteViewSmall = true;

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
                height: 216,
                width: 110,
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
          onTap: () {
            _changeVideoView();
          },
          onPanUpdate: (DragUpdateDetails e) {
            if (CallState.instance.callType == NECallType.video) {
              CallsIndividualUserWidgetData.smallViewRight -= e.delta.dx;
              CallsIndividualUserWidgetData.smallViewTop += e.delta.dy;
              if (CallsIndividualUserWidgetData.smallViewTop < 100) {
                CallsIndividualUserWidgetData.smallViewTop = 100;
              }
              if (CallsIndividualUserWidgetData.smallViewTop >
                  MediaQuery.of(context).size.height - 216) {
                CallsIndividualUserWidgetData.smallViewTop =
                    MediaQuery.of(context).size.height - 216;
              }
              if (CallsIndividualUserWidgetData.smallViewRight < 0) {
                CallsIndividualUserWidgetData.smallViewRight = 0;
              }
              if (CallsIndividualUserWidgetData.smallViewRight >
                  MediaQuery.of(context).size.width - 110) {
                CallsIndividualUserWidgetData.smallViewRight =
                    MediaQuery.of(context).size.width - 110;
              }
              setState(() {});
            }
          },
          child: SizedBox(
            width: 110,
            child: smallVideoWidget,
          ),
        ));
  }

  _changeVideoView() {
    if (CallState.instance.callType == NECallType.audio ||
        CallState.instance.selfUser.callStatus == NECallStatus.waiting) {
      return;
    }

    // 切换状态
    CallState.instance.isLocalViewBig = !CallState.instance.isLocalViewBig;

    _refreshVideoViews();

    setState(() {});
  }

  double _getOpacityByVis(bool vis) {
    return vis ? 1.0 : 0;
  }

  _getBackgroundColor() {
    return CallState.instance.callType == NECallType.audio
        ? const Color(0xFFF2F2F2)
        : const Color(0xFF444444);
  }

  _getTextColor() {
    return Colors.white;
  }
}
