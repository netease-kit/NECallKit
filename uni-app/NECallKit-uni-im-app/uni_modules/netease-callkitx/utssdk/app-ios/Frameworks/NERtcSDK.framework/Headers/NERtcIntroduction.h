/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 */
#import <Foundation/Foundation.h>
#import "INERtcEngine.h"
#import "INERtcEngineEx.h"
#import "NERtcEngineErrorCode.h"
#import "NERtcEngineDelegate.h"
#import "NERtcEngineEnum.h"

/**
 * @mainpage 简介
 * @brief <p>网易云信 NERTC SDK
 * 提供完善的音视频通话开发框架，提供基于网络的点对点视频通话和语音通话功能，还提供多人视频和音频会议功能，支持通话中音视频设备控制和实时音视频模式切换，支持视频采集数据回调以实现美颜等自定义功能。</p>
 * 
 * - INERtcEngine 接口类包含应用程序调用的主要方法。
 * - NERtcEngine 接口类包含获取和销毁 SDK 实例的方法。
 * - INERtcEngineEx  接口类包含应用程序调用的扩展方法。
 * - INERtcChannel 类在指定房间中实现实时音视频功能。通过创建多个 INERtcChannel 对象，用户可以同时加入多个房间。
 * - NERtcChannelDelegate 类监听和报告指定房间的事件和数据。
 * - NERtcEngineAudioFrameObserver 接口类用于向应用程序回调音频帧。
 * - NERtcEngineDelegate 接口类采用 Delegate 方法向应用程序发送回调通知。
 * - NERtcEngineDelegateEx 接口类采用 Delegate 方法向应用程序发送扩展回调通知。
 * - NERtcEngineLiveStreamObserver 接口类用于向应用程序发送直播媒体流回调通知。
 * - NERtcEngineMediaStatsObserver 接口类用于向应用程序发送媒体状态类回调通知。
 * - NERtcEngineVideoFrameObserver 接口类用于向应用程序回调视频帧。
 * - NERtcEngineAudioSessionObserver 接口类用于向应用程序发送音频会话回调通知。
 * - NERtcBeauty 类接口类包含实现美颜的方法。
 * 
 * ## 错误码
 * 
 * 在调用 SDK API 的过程中，SDK 可能会返回错误码或状态码，您可以根据错误码或状态码判断当前 SDK 或任务的状态。如果遇到未知的错误码，请联系技术支持排查。
 * 
 * 当前 SDK API 的错误码如下，各类错误码页面顶部可以查看对应的错误码值。
 * - 通用错误码：{@link NERtcEngineErrorCode.NERtcError}
 * - 伴音错误码：{@link NERtcAudioMixingErrorCode}
 * - 客户端录音状态码：{@link NERtcAudioRecordingCode}
 * - 视频水印状态码：{@link NERtcConstants.NERtcLocalVideoWatermarkState}
 * - 警告码：{@link NERtcWarning}


 <h2 id="房间管理">房间管理</h2>

 <table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngine#setupEngineWithContext:} </td>
    <td>初始化设置 NERtcEngine </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngine#setChannelProfile:}</td>
    <td> 设置房间场景</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngine#setClientRole:} </td>
    <td>设置用户角色</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngine#joinChannelWithToken:channelName:myUid:completion:} </td>
    <td>加入房间</td>
    <td>V3.6.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngine#joinChannelWithToken:channelName:myUid:channelOptions:completion:} </td>
    <td>加入房间，可以携带鉴权密钥等特定参数。</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> {@link INERtcEngine#switchChannelWithToken:channelName:completion:} </td>
    <td>直播场景中观众角色快速切换房间</td>
    <td>V4.1.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngine#leaveChannel} </td>
    <td>离开房间</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngine#connectionState} </td>
    <td>NERtcEngine 的连接状态</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngine#setParameters:} </td>
    <td>复杂参数设置接口</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#updatePermissionKey:} </td>
    <td>更新权限密钥</td>
    <td>V4.6.29</td>
  </tr>
 </table>

 ## 房间事件
 
 <table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineDidClientRoleChanged:newRole:} </td>
    <td>用户角色已切换回调。</td>
    <td>V3.9.0</td>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineRejoinChannel:} </td>
    <td>重新加入房间回调。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineDidLeaveChannelWithResult:} </td>
    <td>离开房间回调。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineUserDidJoinWithUserID:userName:} </td>
    <td>远端用户加入当前房间回调。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineUserDidJoinWithUserID:userName:joinExtraInfo:} </td>
    <td>远端用户加入当前房间回调。</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineUserDidLeaveWithUserID:reason:} </td>
    <td>远端用户离开当前房间回调。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineUserDidLeaveWithUserID:reason:leaveExtraInfo:} </td>
    <td>远端用户离开当前房间回调。</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineNetworkConnectionTypeChanged:} </td>
    <td>本地网络类型已改变回调。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineConnectionStateChangeWithState:reason:}  </td>
    <td>房间连接状态已改变回调。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineDidDisconnectWithReason:} </td>
    <td>服务器连接断开回调。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineReconnectingStart} </td>
    <td>重连开始回调。</td>
    <td>V3.6.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEnginePermissionKeyWillExpire} </td>
    <td>权限密钥即将过期事件回调。</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineUpdatePermissionKey:error:timeout:} </td>
    <td>更新权限密钥事件回调。</td>
    <td>V4.6.29</td>
  </tr>
</table>

 ## 音频管理

 <table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngine#setAudioProfile:scenario:} </td>
    <td>设置音频编码配置</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#adjustRecordingSignalVolume:} </td>
    <td>调节录音音量</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#adjustPlaybackSignalVolume: } </td>
    <td>调节播放音量</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#adjustUserPlaybackSignalVolume:forUserID:} </td>
    <td>调节本地播放的指定远端用户的信号音量。</td>
    <td>V4.2.1</td>
  </tr>
  <tr>
    <td> {@link INERtcEngine#enableLocalAudio:} </td>
    <td>开关本地音频采集</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#muteLocalAudio: } </td>
    <td>开关本地音频发送</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#subscribeRemoteAudio:forUserID:} </td>
    <td>订阅／取消订阅指定音频流。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#subscribeAllRemoteAudio:} </td>
    <td>订阅／取消订阅所有远端音频流</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setAudioSessionOperationRestriction:} </td>
    <td>设置 SDK 对 Audio Session 的控制权限。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setRemoteHighPriorityAudioStream:forUserID:streamType:} </td>
    <td>设置远端用户音频流的高优先级。</td>
    <td>V4.6.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#enableLocalSubStreamAudio:} </td>
    <td>开启或关闭音频辅流</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#subscribeRemoteSubStreamAudio:forUserID:} </td>
    <td>订阅远端用户辅流</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#muteLocalSubStreamAudio:} </td>
    <td>静音本地音频辅流</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setAudioSubscribeOnlyBy:} </td>
    <td>设置本地用户音频只能被房间内其他指定用户订阅</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link INERtcEngine#enableMediaPub:withMediaType:} </td>
    <td>发布或停止发布本地音频</td>
    <td>V4.6.10</td>
  </tr>
</table>
 
<br>
<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineAudioHasHowling} </td>
    <td>检测到啸叫回调。</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineAudioFrameObserver#onNERtcEngineSubStreamAudioFrameDidRecord:} </td>
    <td>本地音频辅流数据回调。</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineAudioFrameObserver#onNERtcEnginePlaybackSubStreamAudioFrameBeforeMixingWithUserID:frame:channelId:} </td>
    <td>获取开启音频辅流的远端用户的辅流数据。</td>
    <td>V4.6.10</td>
  </tr>
</table>


 ## 视频管理
 
 <table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngine#enableLocalVideo:} </td>
    <td>开启/关闭本地视频的采集与发送</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngine#enableLocalVideo:streamType:} </td>
    <td>开启/关闭本地视频的采集与发送</td>
    <td>V4.6.20</td>
  </tr>
  <tr>
    <td> {@link INERtcEngine#setLocalVideoConfig:} </td>
    <td>设置视频编码属性</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngine#setLocalVideoConfig:streamType:} </td>
    <td>设置视频编码属性</td>
    <td>V4.6.20</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setCameraCaptureConfig:} </td>
    <td>设置本地摄像头的采集偏好等配置</td>
    <td>V4.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setCameraCaptureConfig:streamType:} </td>
    <td>设置本地摄像头的采集偏好等配置</td>
    <td>V4.6.20</td>
  </tr>
  <tr>
    <td> {@link INERtcEngine#setupLocalVideoCanvas:} </td>
    <td>设置本地用户视图</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngine#setupRemoteVideoCanvas:forUserID:} </td>
    <td>设置远端用户视图</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#startPreview} </td>
    <td>开启视频预览</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#startPreview:} </td>
    <td>开启视频预览</td>
    <td>V4.6.20</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#stopPreview} </td>
    <td>停止视频预览</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#stopPreview:} </td>
    <td>停止视频预览</td>
    <td>V4.6.20</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#muteLocalVideo:} </td>
    <td>取消/恢复发布本地视频</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#muteLocalVideo:streamType:} </td>
    <td>取消/恢复发布本地视频</td>
    <td>V4.6.20</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#subscribeRemoteVideo:forUserID:streamType:} </td>
    <td>订阅/取消订阅指定远端用户的视频流</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setLocalRenderScaleMode:} </td>
    <td>设置本地的视频渲染缩放模式</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setRemoteRenderScaleMode:forUserID:} </td>
    <td>设置远端的视频渲染缩放模式</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setVideoRotationMode:} </td>
    <td>设置本地视频画面的旋转模式。</td>
    <td>V4.3.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#enableSuperResolution:} </td>
    <td>启用或停止 AI 超分。</td>
    <td>V4.4.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#enableVideoCorrection:} </td>
    <td>启用或关闭视频图像畸变矫正。</td>
    <td>V4.6.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setVideoCorrectionConfig:} </td>
    <td>设置视频图像矫正参数。</td>
    <td>V4.6.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#enableVirtualBackground:backData:} </td>
    <td>开启虚拟背景。</td>
    <td>V4.6.10</td>
  </tr>
</table>

<h2 id="本地媒体事件">本地媒体事件</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onEngineFirstAudioFrameDecoded:} </td>
    <td>已解码远端音频首帧的回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onEngineFirstVideoFrameDecoded:width:height:} </td>
    <td>已接收到远端视频首帧并完成解码的回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onEngineFirstVideoFrameDecoded:width:height:streamType:} </td>
    <td>已接收到远端视频首帧并完成解码的回调</td>
    <td>V4.6.20</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineFirstVideoDataDidReceiveWithUserID:} </td>
    <td>已显示远端视频首帧的回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineFirstVideoDataDidReceiveWithUserID:streamType:} </td>
    <td>已显示远端视频首帧的回调</td>
    <td>V4.6.20</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineFirstAudioDataDidReceiveWithUserID:} </td>
    <td>已接收远端音频首帧的回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineMediaRightChangeWithAudio:video:} </td>
    <td>服务端禁言音视频权限变化回调</td>
    <td>V4.6.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineVirtualBackgroundSourceEnabled:reason:}  </td>
    <td>通知虚拟背景是否成功开启的回调</td>
    <td>V4.6.10</td>
  </tr>
</table>

<h2 id="远端媒体事件">远端媒体事件</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineUserVideoProfileDidUpdate:maxProfile:} </td>
    <td>远端用户更改视频分辨率类型的回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineUser:videoMuted:} </td>
    <td>远端用户暂停或恢复发送视频主流的回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineUser:videoMuted:streamType:} </td>
    <td>远端用户暂停或恢复发送视频主流或辅流的回调</td>
    <td>V4.6.20</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineUser:audioMuted:} </td>
    <td>远端用户暂停或恢复音频主流发送的回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcChannelDelegate#onNERtcChannelUser:subStreamAudioMuted:} </td>
    <td>远端用户暂停或恢复音频辅流发送的回调</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineUserAudioDidStart:} </td>
    <td>远端用户开启音频主流的回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcChannelDelegate#onNERtcChannelUserSubStreamAudioDidStart:} </td>
    <td>远端用户开启音频辅流的回调</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineUserAudioDidStop:} </td>
    <td>远端用户关闭音频主流的回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcChannelDelegate#onNERtcChannelUserSubStreamAudioDidStop:} </td>
    <td>远端用户关闭音频辅流的回调</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineUserVideoDidStartWithUserID:videoProfile:} </td>
    <td>远端用户开启视频的回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineUserVideoDidStop:} </td>
    <td>远端用户关闭视频的回调</td>
    <td>V3.5.0</td>
  </tr>
</table>

<h2 id="数据统计事件">数据统计事件</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineMediaStatsObserver#onRtcStats:} </td>
    <td>当前通话统计回调，每2秒触发一次</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineMediaStatsObserver#onNetworkQuality:} </td>
    <td>通话中每个用户的网络上下行质量报告回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineMediaStatsObserver#onLocalAudioStat:} </td>
    <td>本地音频流统计信息回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineMediaStatsObserver#onLocalVideoStat:} </td>
    <td>本地视频流统计信息回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineMediaStatsObserver#onRemoteAudioStats:} </td>
    <td>通话中远端音频流的统计信息回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineMediaStatsObserver#onRemoteVideoStats:} </td>
    <td>通话中远端视频流的统计信息回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#addEngineMediaStatsObserver:} </td>
    <td>添加 media 统计信息观测器</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#removeEngineMediaStatsObserver: } </td>
    <td>删除指定 media 统计信息观测器</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#cleanupEngineMediaStatsObserver} </td>
    <td>清空 media 统计信息观测器</td>
    <td>V3.5.0</td>
  </tr>
</table>

## 多房间管理

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#createChannel:} </td>
    <td>创建并获取一个 NERtcChannel 对象。通过创建多个对象，用户可以同时加入多个房间。</td>
    <td>V4.5.0</td>
  </tr>
  <tr>
    <td> INERtcChannel  </td>
    <td>该类提供在指定房间内实现实时音视频功能的方法。</td>
    <td>V4.5.0</td>
  </tr>
  <tr>
    <td>NERtcChannelDelegate</td>
    <td>该类提供监听指定房间事件和数据的回调。</td>
    <td>V4.5.0</td>
  </tr>
</table>

<h2 id="屏幕共享">屏幕共享</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setupLocalSubStreamVideoCanvas:} </td>
    <td>设置本端的辅流视频回放画布</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setupRemoteSubStreamVideoCanvas:forUserID:} </td>
    <td>设置远端的辅流视频回放画布</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#startScreenCapture:} </td>
    <td>开启屏幕共享</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#stopScreenCapture} </td>
    <td>停止屏幕共享</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setLocalRenderSubStreamScaleMode:}</td>
    <td>订阅或取消订阅远端的屏幕共享辅流视频，订阅之后才能接收远端的辅流视频数据</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setRemoteRenderSubStreamVideoScaleMode:forUserID:}</td>
    <td>订阅或取消订阅远端的屏幕共享辅流视频，订阅之后才能接收远端的辅流视频数据</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#subscribeRemoteSubStreamVideo:forUserID:}</td>
    <td>订阅或取消订阅远端的屏幕共享辅流视频，订阅之后才能接收远端的辅流视频数据</td>
    <td>V3.9.0</td>
  </tr>
</table>

<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineUserSubStreamDidStartWithUserID:subStreamProfile:} </td>
    <td>远端用户开启屏幕共享辅流通道的回调</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineUserSubStreamDidStop:}  </td>
    <td>远端用户停止屏幕共享辅流通道的回调</td>
    <td>V3.9.0</td>
  </tr>
</table>

<h2 id="美颜">美颜</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link NERtcBeauty#startBeauty} </td>
    <td>开启美颜功能模块</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link NERtcBeauty#stopBeauty} </td>
    <td>结束美颜功能模块</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link NERtcBeauty#isOpenBeauty} </td>
    <td>暂停或恢复美颜效果</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link NERtcBeauty#setBeautyEffectWithValue:atType:} </td>
    <td>设置美颜效果</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link NERtcBeauty#addTempleteWithPath:andName:} </td>
    <td>导入美颜资源或模型</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link NERtcBeauty#addBeautyFilterWithPath:andName:}</td>
    <td>添加滤镜效果</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link NERtcBeauty#removeBeautyFilter}</td>
    <td>移除滤镜</td>
    <td>V4.6.10</td>
  </tr>
</table>

## 通话前网络测试

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#startLastmileProbeTest:}</td>
    <td>开始通话前网络质量探测。</td>
    <td>V4.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#stopLastmileProbeTest}</td>
    <td>停止通话前网络质量探测。</td>
    <td>V4.5.0</td>
  </tr>
</table>

<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineLastmileQuality:} </td>
    <td>报告本地用户的网络质量。</td>
    <td>V4.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineLastmileProbeTestResult:}</td>
    <td>报告通话前网络上下行 last mile 质量。</td>
    <td>V4.5.0</td>
  </tr>
</table>

<h2 id="音乐文件播放及混音">音乐文件播放及混音（伴音）</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#startAudioMixingWithOption:} </td>
    <td>开始播放伴音</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#stopAudioMixing} </td>
    <td>停止播放伴音</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#pauseAudioMixing} </td>
    <td>暂停播放伴音</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#resumeAudioMixing} </td>
    <td>恢复播放伴音</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setAudioMixingPlaybackVolume:} </td>
    <td>设置伴音的播放音量</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setAudioMixingSendVolume:} </td>
    <td>设置伴音的发送音量</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setAudioMixingPitch:} </td>
    <td>设置伴音的音调</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#getAudioMixingPlaybackVolume:} </td>
    <td>获取伴音的播放音量</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#getAudioMixingSendVolume:} </td>
    <td>获取伴音的发送音量</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#getAudioMixingPitch:} </td>
    <td>获取伴音的音调</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#getAudioMixingDuration:} </td>
    <td>获取伴音的总长度</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setAudioMixingPosition:} </td>
    <td>设置伴音的播放进度</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#getAudioMixingCurrentPosition:} </td>
    <td>获取伴音的播放进度</td>
    <td>V3.5.0</td>
  </tr>
</table>

<br>

<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onAudioMixingStateChanged:errorCode:} </td>
    <td>本地用户的音乐文件播放状态改变回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onAudioMixingTimestampUpdate:} </td>
    <td>本地用户的音乐文件播放进度回调</td>
    <td>V3.5.0</td>
  </tr>
</table>

<h2 id="音效文件播放管理">音效文件播放管理</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#getEffectPlaybackVolumeWithId:volume:} </td>
    <td>获取音效文件播放音量。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setEffectPlaybackVolumeWithId:volume:} </td>
    <td>设置音效文件播放音量</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#playEffectWitdId:effectOption:} </td>
    <td>播放指定音效文件</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#stopEffectWitdId:} </td>
    <td>停止播放指定音效文件</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#stopAllEffects} </td>
    <td>停止播放所有音效文件</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#pauseEffectWitdId:} </td>
    <td>暂停音效文件播放</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#pauseAllEffects} </td>
    <td>暂停所有音效文件播放</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#resumeEffectWitdId:} </td>
    <td>恢复播放指定音效文件</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#resumeAllEffects} </td>
    <td>恢复播放所有音效文件</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setEffectSendVolumeWithId:volume:} </td>
    <td>调节音效文件发送音量</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#getEffectDurationWithId:duration:} </td>
    <td>获取音效文件时长。</td>
    <td>V4.4.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#getEffectCurrentPositionWithId:position:} </td>
    <td>获取音效的播放进度。</td>
    <td>V4.4.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setEffectPitchWithId:pitch:} </td>
    <td>设置音效文件音调。</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#getEffectPitchWithId:pitch:} </td>
    <td>获取音效文件音调。</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setEffectPositionWithId:position:} </td>
    <td>设置音效文件播放进度。</td>
    <td>V4.6.29</td>
  </tr>
</table>

<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onAudioEffectTimestampUpdateWithId:timeStampMS:} </td>
    <td>指定音效文件播放进度回调</td>
    <td>V4.6.29</td>
  </tr>
</table>

<h2 id="变声与混响">变声与混响</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setAudioEffectPreset:}</td>
    <td>设置 SDK 预设的人声的变声音效</td>
    <td>V4.1.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setVoiceBeautifierPreset:}</td>
    <td>设置 SDK 预设的美声效果</td>
    <td>V4.0.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setLocalVoiceEqualizationOfBandFrequency:withGain:}</td>
    <td>设置本地语音音效均衡，即自定义设置本地人声均衡波段的中心频率</td>
    <td>V4.0.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setLocalVoicePitch:}</td>
    <td>设置本地语音音调</td>
    <td>V4.1.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setLocalVoiceReverbParam:}</td>
    <td>V开启本地语音混响效果</td>
    <td>4.6.10</td>
  </tr>
</table>


<h2 id="旁路推流">旁路推流</h2>

注意：该组方法仅适用于互动直播 2.0。

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#addLiveStreamTask:compeltion:} </td>
    <td>添加房间推流任务</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#updateLiveStreamTask:compeltion:} </td>
    <td>更新修改房间推流任务</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#removeLiveStreamTask:compeltion:} </td>
    <td>删除房间推流任务</td>
    <td>V3.5.0</td>
  </tr>
</table>

<br>

<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineLiveStreamObserver#onNERTCEngineLiveStreamState:taskID:url:} </td>
    <td>直播推流状态回调</td>
    <td>V3.5.0</td>
  </tr>
 </table>

 <h2 id="媒体增强信息">媒体增强信息</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#sendSEIMsg:}</td>
    <td>通过主流通道发送媒体补充增强信息。	</td>
    <td>V4.0.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#sendSEIMsg:streamChannelType:} </td>
    <td>发送媒体补充增强信息。通过本接口可指定发送 SEI 时使用主流或辅流通道。	</td>
    <td>V4.0.0</td>
  </tr>
</table>

<br>

<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineVideoSEIObserver#onNERtcEngineRecvSEIMsg:message:}</td>
    <td>收到远端流的 SEI 内容回调。</td>
    <td>V4.0.0</td>
  </tr>
</table>

<h2 id="跨房间媒体流转发">跨房间媒体流转发</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#startChannelMediaRelay:} </td>
    <td>开始跨房间媒体流转发</td>
    <td>V4.2.1</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#updateChannelMediaRelay:} </td>
    <td>更新媒体流转发的目标房间。</td>
    <td>V4.2.1</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#stopChannelMediaRelay} </td>
    <td>停止跨房间媒体流转发。</td>
    <td>V4.2.1</td>
  </tr>
</table>

<br>

<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineChannelMediaRelayStateDidChange:channelName:}</td>
    <td>跨房间媒体流转发状态发生改变回调。</td>
    <td>V4.2.1</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineDidReceiveChannelMediaRelayEvent:channelName:error:}</td>
    <td>媒体流相关转发事件回调。</td>
    <td>V4.2.1</td>
  </tr>
</table>

<h2 id="音量提示">音量提示</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#enableAudioVolumeIndication:interval:} </td>
    <td>启用说话者音量提示</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#enableAudioVolumeIndication:interval:vad:} </td>
    <td>启用说话者音量及本地是否有人声提示</td>
    <td>V4.6.10</td>
  </tr>
</table>

<br>

<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onRemoteAudioVolumeIndication:totalVolume:} </td>
    <td>提示房间内谁正在说话及说话者音量的回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onLocalAudioVolumeIndication:} </td>
    <td>提示房间内本地用户瞬时音量的回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onLocalAudioVolumeIndication:withVad:} </td>
    <td>提示房间内本地用户瞬时音量及是否存在人声的回调</td>
    <td>V4.6.10</td>
  </tr>
</table>


<h2 id="耳返">耳返</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#enableEarback:volume:} </td>
    <td>开启耳返功能</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setEarbackVolume:} </td>
    <td>设置耳返音量</td>
    <td>V3.5.0</td>
  </tr>
</table>

 

<h2 id="音频播放路由">音频播放路由</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setLoudspeakerMode:} </td>
    <td>启用/关闭扬声器播放</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#getLoudspeakerMode:} </td>
    <td>查询扬声器启用状态</td>
    <td>V3.5.0</td>
  </tr>
</table>

<br>

<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td>{@link NERtcEngineAudioSessionObserver#onNERtcEngineAudioDeviceRoutingDidChange:} </td>
    <td>音频路由变化回调。</td>
    <td>V3.6.0</td>
  </tr>
</table>

<h2 id="视频大小流">视频大小流</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#enableDualStreamMode:} </td>
    <td>设置是否开启视频大小流模式。</td>
    <td>V3.5.0</td>
  </tr>
</table>

<h2 id="音视频流回退">音视频流回退</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setLocalPublishFallbackOption:} </td>
    <td>设置弱网条件下发布的音视频流回退选项。	</td>
    <td>V4.3.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setRemoteSubscribeFallbackOption:} </td>
    <td>设置弱网条件下订阅的音视频流回退选项。	</td>
    <td>V4.3.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setLocalMediaPriority:preemptive:} </td>
    <td>设置本地用户的媒体流优先级。	</td>
    <td>V4.2.0</td>
  </tr>
</table>

<br>

<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td>{@link NERtcEngineDelegateEx#onNERtcEngineLocalPublishFallbackToAudioOnly:streamType:} </td>
    <td>本地发布流已回退为音频流或恢复为音视频流回调。</td>
    <td>V4.3.0</td>
  </tr>
  <tr>
    <td>{@link NERtcEngineDelegateEx#onNERtcEngineRemoteSubscribeFallbackToAudioOnly:isFallback:streamType:} </td>
    <td>远端订阅流已回退为音频流或恢复为音视频流回调。</td>
    <td>V4.3.0</td>
  </tr>
</table>

 <h2 id="自定义音频采集与渲染">自定义音频采集与渲染</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setExternalAudioSource:sampleRate:channels:} </td>
    <td>启用外部自定义音频数据主流输入功能，并设置采集参数。</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setExternalSubStreamAudioSource:sampleRate:channels:} </td>
    <td>启用外部自定义音频数据辅流输入功能，并设置采集参数。</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#pushExternalAudioFrame:} </td>
    <td>将外部音频数据帧推送给内部引擎</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#pushExternalSubStreamAudioFrame:} </td>
    <td>将外部音频辅流数据帧推送给内部引擎</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setExternalAudioRender:sampleRate:channels:} </td>
    <td>开启或关闭外部音频渲染</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#pullExternalAudioFrame:length:} </td>
    <td>推送外部音频数据</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setStreamAlignmentProperty:} </td>
    <td>对齐本地系统时间与服务端时间。</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#getNtpTimeOffset} </td>
    <td>获取本地系统时间与服务端时间的差值。</td>
    <td>V4.6.10</td>
  </tr>
</table>

 <h2 id="自定义视频采集">自定义视频采集</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setExternalVideoSource:isScreen:} </td>
    <td>开启/关闭外部视频源数据输入</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setExternalVideoSource:streamType:} </td>
    <td>开启/关闭外部视频源数据输入</td>
    <td>V4.6.20</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#pushExternalVideoFrame:} </td>
    <td>推送外部视频帧</td>
    <td>V3.5.0</td>
  </tr>
</table>

<h2 id="音视频裸流传输">音视频裸流传输</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setPreDecodeObserver:} </td>
    <td>注册解码前媒体数据观测器。</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#pushExternalAudioEncodedFrame:} </td>
    <td>推送外部音频主流编码帧。</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#pushExternalSubStreamAudioEncodedFrame:} </td>
    <td>推送外部音频辅流编码帧。</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#pushExternalVideoEncodedFrame:} </td>
    <td>推送外部视频编码帧。</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setVideoEncoderQosObserver:} </td>
    <td>注册视频编码 QoS 信息监听器。</td>
    <td>V4.6.29</td>
  </tr>
</table>

<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEnginePreDecodeObserver#onNERtcEnginePreDecoderFrame:} </td>
    <td>解码前媒体数据回调。</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineVideoEncoderQosObserver#onNERtcEngineRequestSendKeyFrame:} </td>
    <td>帧请求事件回调。</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineVideoEncoderQosObserver#onNERtcEngineVideoCodecUpdated:videoStreamType:} </td>
    <td>视频编码器类型信息回调。</td>
    <td>V4.6.29</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineVideoEncoderQosObserver#onNERtcEngineBitrateUpdated:videoStreamType:} </td>
    <td>码率信息回调。</td>
    <td>V4.6.29</td>
  </tr>
</table>

<h2 id="原始音频数据">原始音频数据</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setRecordingAudioFrameParameters:}</td>
    <td>设置录制的声音格式</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setPlaybackAudioFrameParameters:} </td>
    <td>设置播放的声音格式</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setAudioFrameObserver:}</td>
    <td>注册语音观测器对象</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setMixedAudioFrameParameters:}</td>
    <td>设置采集和播放后的混合后的采样率。需要在加入房间之前调用该接口</td>
    <td>V3.5.0</td>
  </tr>
</table>

<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineAudioFrameObserver#onNERtcEngineAudioFrameDidRecord:}</td>
    <td>采集音频数据回调。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineAudioFrameObserver#onNERtcEngineAudioFrameWillPlayback:}</td>
    <td>播放音频数据回调。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineAudioFrameObserver#onNERtcEngineMixedAudioFrame:}</td>
    <td>音频采集与播放混合后数据帧回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineAudioFrameObserver#onNERtcEnginePlaybackAudioFrameBeforeMixingWithUserID:frame:} </td>
    <td>某一远端用户的原始音频帧回调。<br>即将废弃，请改用接口 {@link NERtcEngineAudioFrameObserver#onNERtcEnginePlaybackAudioFrameBeforeMixingWithUserID:frame:channelId:}。</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td>{@link NERtcEngineAudioFrameObserver#onNERtcEnginePlaybackAudioFrameBeforeMixingWithUserID:frame:channelId:}</td>
    <td>某一远端用户的原始音频帧回调。</td>
    <td>V4.5.0</td>
 </tr>
</table>

 <h2 id="原始视频数据">原始视频数据</h2>

<table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineVideoFrameObserver#onNERtcEngineVideoFrameCaptured:rotation:}</td>
    <td>采集视频数据回调。</td>
    <td>V3.5.0</td>
  </tr>
</table>

 <h2 id="截图">截图</h2>

 <table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#takeLocalSnapshot:callback:}</td>
    <td>本地视频画面截图。</td>
    <td>V4.2.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#takeRemoteSnapshot:forUserID:callback:}</td>
    <td>远端视频画面截图。</td>
    <td>V4.2.0</td>
  </tr>
</table>

 <table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngine#NERtcTakeSnapshotCallback}</td>
    <td>截图结果回调。</td>
    <td>V4.2.0</td>
  </tr>
</table>

 <h2 id="水印">水印</h2>

 <table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setLocalVideoWatermarkConfigs:withStreamType:}</td>
    <td>添加本地视频水印。</td>
    <td>V4.6.10</td>
  </tr>
</table>

<br>

 <table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineLocalVideoWatermarkStateWithStreamType:state:}</td>
    <td>水印结果回调。</td>
    <td>V4.6.10</td>
  </tr>
</table>

<h2 id="加密">加密</h2>

 <table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td>{@link INERtcEngineEx#enableEncryption:config:}</td>
    <td>开启或关闭媒体流加密。</td>
    <td>V4.4.0</td>
  </tr>
 </table>

 <h2 id="客户端音频录制">客户端音频录制</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#startAudioRecording:sampleRate:quality:}</td>
    <td>开始客户端录音。</td>
    <td>V4.2.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#startAudioRecordingWithConfig:}</td>
    <td>开始客户端录音。</td>
    <td>V4.6.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#stopAudioRecording}</td>
    <td>停止客户端录音。</td>
    <td>V4.2.0</td>
  </tr>
</table>


 <table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineAudioRecording:filePath:}</td>
    <td>音频录制状态回调。</td>
    <td>V4.2.0</td>
  </tr>
</table>

<h2 id="云代理">云代理</h2>

 <table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td>{@link INERtcEngineEx#setCloudProxy:}</td>
    <td>开启并设置云代理服务。</td>
    <td>V4.6.0</td>
  </tr>
 </table>

 <h2 id="设备管理">设备管理</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngine#switchCamera} </td>
    <td>切换前置/后置摄像头</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#switchCameraWithPosition:} </td>
    <td>指定前置/后置摄像头</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#isCameraTorchSupported} </td>
    <td>检测设备是否支持闪光灯常开</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setCameraZoomFactor:} </td>
    <td>设置摄像头缩放比例</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setCameraFocusPositionX:Y:} </td>
    <td>设置当前摄像头聚焦点位置</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setCameraTorchOn:} </td>
    <td>设置是否打开闪光灯</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#isCameraTorchOn} </td>
    <td>查询当前摄像头是否打开手电筒</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#maxCameraZoomScale} </td>
    <td>获取摄像头支持的最大视频缩放比例</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#isCameraZoomSupported} </td>
    <td>检测设备是否支持摄像头缩放功能</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#isCameraFocusSupported} </td>
    <td>检测设备是否支持手动对焦功能</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#isCameraExposurePositionSupported} </td>
    <td>检测设备是否支持手动曝光功能</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setCameraExposurePosition:} </td>
    <td>设置手动曝光位置</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setPlayoutDeviceMute:} </td>
    <td>设置音频播放设备的状态</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#getPlayoutDeviceMute:} </td>
    <td>获取当前音频播放设备是否静音</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setRecordDeviceMute:} </td>
    <td>设置录音设备的状态</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#getRecordDeviceMute:} </td>
    <td>获取当前音频采集设备是否静音</td>
    <td>V3.5.0</td>
  </tr>
</table>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineAudioDeviceStateChangeWithDeviceID:deviceType:deviceState:} </td>
    <td>音频设备状态更改回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineVideoDeviceStateChangeWithDeviceID:deviceType:deviceState:} </td>
    <td>视频设备状态切换回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineHardwareResourceReleased:} </td>
    <td>硬件资源已经释放的回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcCameraFocusChanged:} </td>
    <td>摄像头对焦区域已改变回调</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcCameraExposureChanged:} </td>
    <td>摄像头曝光区域已改变回调</td>
    <td>V3.5.0</td>
  </tr>
</table>


 <h2 id="空间音效">空间音效（3D 音效）和范围语音</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
    </tr>
    <tr>
    <td> {@link INERtcEngineEx#initSpatializer}  </td>
    <td>初始化空间音效</td>
    <td>V5.5.10</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#enableSpatializer:applyToTeam:} </td>
    <td>开启/关闭空间音效</td>
    <td>V5.4.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setAudioRecvRange:conversationalDistance:rollOff:} </td>
    <td>设置空间音效的距离衰减属性和语音范围</td>
    <td>V5.5.10</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setSpatializerRoomProperty:} </td>
    <td>设置房间混响属性</td>
    <td>V5.4.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#enableSpatializerRoomEffects:} </td>
    <td>开启或关闭空间音效的房间混响效果</td>
    <td>V5.4.0</td>
  </tr>
  <tr>
    <td> {@link  INERtcEngineEx#updateSelfPosition:} </td>
    <td>设置说话者和接收者的位置信息</td>
    <td>V5.4.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setSpatializerRenderMode:} </td>
    <td>设置渲染模式</td>
    <td>V5.4.0</td>
  </tr>
    <tr>
    <td>{@link INERtcEngineEx#setRangeAudioTeamID:} </td>
    <td>设置范围语音的队伍号</td>
    <td>V5.5.10</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setRangeAudioMode:} </td>
    <td>设置范围语音的模式</td>
    <td>V5.5.10</td>
  </tr>
    </tr>
    <tr>
    <td>{@link INERtcEngineEx#setSubscribeAudioAllowlist:} </td>
    <td>设置只订阅指定用户的音频流</td>
    <td>V5.5.10</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setSubscribeAudioBlocklist:uidArray:} </td>
    <td>设置不订阅指定用户的音频流</td>
    <td>V5.5.10</td>
  </tr>
</table>
 

 <h2 id="故障排查">故障排查</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#uploadSdkInfo} </td>
    <td>上传SDK日志信息</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#startAudioDump} </td>
    <td>开始记录音频 dump</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#stopAudioDump} </td>
    <td>结束记录音频 dump</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#startAudioDumpWithType:} </td>
    <td>开始进行音频 dump</td>
    <td>V4.6.0</td>
  </tr>
</table>

 <table>
  <tr>
    <th width=400><b>事件</b></th>
    <th width=600><b>描述</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineDidError:} </td>
    <td>引擎发生了运行时的错误，需要用户干预</td>
    <td>V3.5.0</td>
  </tr><tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineDidWarning:msg:} </td>
    <td>发生警告回调。</td>
    <td>V4.3.0</td>
  </tr>
</table>

*/

