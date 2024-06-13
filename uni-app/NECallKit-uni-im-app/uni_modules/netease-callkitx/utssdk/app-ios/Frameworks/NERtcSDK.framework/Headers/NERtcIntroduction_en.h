/*
 * Copyright (c) 2021 CommsEase, Inc.  All rights reserved.
 */
#import <Foundation/Foundation.h>
#import "INERtcEngine.h"
#import "INERtcEngineEx.h"
#import "NERtcEngineErrorCode.h"
#import "NERtcEngineDelegate.h"
#import "NERtcEngineEnum.h"

/**
 * @mainpage Introduction
 * @brief<p> CommsEase NERTC SDK
 * provides a comprehensive Real-time Communication (RTC) development platform that allows developers to implement Internet-based peer-to-peer audio and video calls, and group audio and video conferencing. The SDK enables users to manage audio and video devices and switch audio and video modes during calls. The SDK also implements capturing video data callbacks and offers additional features, such as personalized image enhancement. </p>
 * 
 * - INERtcEngine interface classes that contain main methods invoked by applications.
 * - NERtcEngine interface classes that contain methods used to instantiate or destroy SDK instances.
 * - INERtcEngineEx interface classes that contain extension methods invoked by applications
 * - INERtcChannel classes used to implement audio and video calling in a room. Users can join multiple rooms by creating multiple INERtcChannel objects.
 * - NERtcChannelDelegate classes used to listen for and report events and data for a specified room.
 * - NERtcEngineAudioFrameObserver interface classes used to return audio frames to applications.
 * - NERtcEngineDelegate interface classes used to return notifications to applications using delegate methods.
 * - NERtcEngineDelegateEx interface classes used to return extended notifications to applications using delegate methods.
 * - NERtcEngineLiveStreamObserver interface classes used to return notifications about live media streams to applications.
 * - NERtcEngineMediaStatsObserver interface classes used to return notifications about media status to applications.
 * - NERtcEngineVideoFrameObserver interface classes used to return video frames to applications.
 * - NERtcEngineAudioSessionObserver interface classes used to return notifications about audio sessions to applications.
 * - NERtcBeauty interface classes used to add beauty effects.
 * 
 * ## Error codes
 * 
 * The SDK may return error codes or status codes when your app calls an API. You can learn about the status of the SDK or specific tasks based on the information provided by the error codes or status codes. If unknown errors are returned, you can contact our technical support for help.
 * 
 * The following error codes are supported by the SDK and APIs. You can view the specific code at the top of the page for each error code.
 *- Common error codes: {@link NERtcEngineErrorCode.NERtcError}
 *- Error codes related to mixing audio: {@link NERtcAudioMixingErrorCode}
 *- Error codes related to publishing audio and video streams in live streaming: {@link NERtcEngineErrorCode.kNERtcLiveStreamError}
 *- Status codes related to audio recording: {@link NERtcAudioRecordingCode}
 * - Video watermark status codes: {@link NERtcConstants.NERtcLocalVideoWatermarkState}
 * - Warning codes: {@link NERtcWarning}


 <h2 id="Room management">Room management</h2>

 <table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td>{@link INERtcEngine#setupEngineWithContext:}</td>
    <td>Initializes NERtcEngine</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngine#setChannelProfile:}</td>
    <td>Sets a room scene.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngine#setClientRole:} </td>
    <td>Sets the role of a user in live streaming.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngine#joinChannelWithToken:channelName:myUid:completion:} </td>
    <td>Joins an RTC channel.</td>
    <td>V3.6.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngine#switchChannelWithToken:channelName:completion:} </td>
    <td>Switches to a different RTC room.</td>
    <td>V4.1.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngine#leaveChannel} </td>
    <td>Leaves a room.</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngine#connectionState} </td>
    <td>Gets the connection status of NERtcEngine.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngine#setParameters:} </td>
    <td>Sets complex parameters.</td>
    <td>V3.5.0</td>
  </tr>
 </table>

 ## Room event
 
 <table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td>{@link NERtcEngineDelegate#onNERtcEngineDidClientRoleChanged: newRole:}</td>
    <td>Occurs when a user changes the role in live streaming. </td>
    <td>V3.9.0</td>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineRejoinChannel:} </td>
    <td> Occurs when a user rejoins a room. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineDidLeaveChannelWithResult:} </td>
    <td> Occurs when a user leaves a room. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineUserDidJoinWithUserID:userName:} </td>
    <td> Occurs when a remote user joins the current room. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineUserDidLeaveWithUserID:reason:} </td>
    <td> Occurs when a remote user leaves a room. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineNetworkConnectionTypeChanged:} </td>
    <td> Occurs when the type of the local network changes. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineConnectionStateChangeWithState:reason:} </td>
    <td>Occurs when connection state changes. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineDidDisconnectWithReason:} </td>
    <td> Occurs when the server becomes disconnected. callback. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineReconnectingStart} </td>
    <td> Occurs when the reconnection starts </td>
    <td>V3.6.0</td>
  </tr>
</table>

 ## Audio management

 <table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngine#setAudioProfile:scenario:} </td>
    <td> Sets the audio profile.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#adjustRecordingSignalVolume:} </td>
    <td>Adjusts the recording volume.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#adjustPlaybackSignalVolume: } </td>
    <td>Adjusts the playback volume.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#adjustUserPlaybackSignalVolume:forUserID:} </td>
    <td> Adjusts the local playback volume of the stream from a specified remote user. </td>
    <td>V4.2.1</td>
  </tr>
  <tr>
    <td> {@link INERtcEngine#enableLocalAudio:} </td>
    <td> Stops or resumes local audio capture.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#muteLocalAudio: } </td>
    <td> Mute or unmute local audio.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#subscribeRemoteAudio:forUserID:} </td>
    <td> Subscribes to or unsubscribes from specified audio streams. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#subscribeAllRemoteAudio:} </td>
    <td> Subscribes to or unsubscribes from all remote audio streams.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setAudioSessionOperationRestriction:} </td>
    <td>Sets the permissions of Audio Session for the SDK. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setRemoteHighPriorityAudioStream:forUserID:streamType:} </td>
    <td>Sets high priority to a remote audio stream. </td>
    <td>V4.6.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#enableLocalSubStreamAudio:} </td>
    <td> Enables or disables the audio substream.</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#subscribeRemoteSubStreamAudio:forUserID:} </td>
    <td> Subscribes to the audio substream from a specified remote user.
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#muteLocalSubStreamAudio:} </td>
    <td> Mutes the local audio substream.</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setAudioSubscribeOnlyBy:} </td>
    <td>Allows the local audio stream to be subscribed only by specified users in the room.</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link INERtcEngine#enableMediaPub:withMediaType:} </td>
    <td> Publishes or unpublishes the local audio stream.</td>
    <td>V4.6.10</td>
  </tr>
</table>
 
<br>
<table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineAudioHasHowling} </td>
    <td> Occurs when howling is detected. </td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineAudioFrameObserver#onNERtcEngineSubStreamAudioFrameDidRecord:} </td>
    <td> Returns the audio substream data. </td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineAudioFrameObserver#onNERtcEnginePlaybackSubStreamAudioFrameBeforeMixingWithUserID:frame:channelId:} </td>
    <td>Gets the audio substream data published by a specified remote user before mixing. </td>
    <td>V4.6.10</td>
  </tr>
</table>


 ## Video management
 
 <table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngine#enableLocalVideo:} </td>
    <td> Enables or disables the local video stream.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngine#setLocalVideoConfig:} </td>
    <td> Sets the local video configuration.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setCameraCaptureConfig:} </td>
    <td>Sets the configuration for capturing the camera data. </td>
    <td>V4.5.0</td>
    </tr>
  <tr>
    <td> {@link INERtcEngine#setupLocalVideoCanvas:} </td>
    <td>Sets the local video canvas.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngine#setupRemoteVideoCanvas:forUserID:} </td>
    <td> Sets the remote video canvas. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#startPreview} </td>
    <td> Starts video preview.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#stopPreview} </td>
    <td> Stops video preview</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#muteLocalVideo:} </td>
    <td> Mutes or unmutes local video stream.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#subscribeRemoteVideo:forUserID:streamType:} </td>
    <td> Subscribes to or unsubscribes from video streams from specified remote users.
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setLocalRenderScaleMode:} </td>
    <td> Sets the zoom mode of local video rendering.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setRemoteRenderScaleMode:forUserID:} </td>
    <td> Sets the zoom mode of remote video rendering.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setVideoRotationMode:} </td>
    <td> Sets the rotation mode of the local video screen. </td>
    <td>V4.3.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#enableSuperResolution:} </td>
    <td> Enables or disables AI super resolution. </td>
    <td>V4.4.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#enableVideoCorrection:} </td>
    <td>Enables or disables video correction. </td>
    <td>V4.6.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setVideoCorrectionConfig:} </td>
    <td>Ses the parameters of video correction configuration. </td>
    <td>V4.6.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#enableVirtualBackground:backData:} </td>
    <td> Enables the virtual background. </td>
    <td>V4.6.10</td>
  </tr>
</table>

<h2 id="Local media events">Local media events</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onEngineFirstAudioFrameDecoded:} </td>
    <td> Occurs when the first audio frame from a remote user is decoded.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onEngineFirstVideoFrameDecoded:width:height:} </td>
    <td> Occurs when the first video frame from a remote user is decoded.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineFirstVideoDataDidReceiveWithUserID:} </td>
    <td> Occurs when the first video frame from a remote user is received.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineFirstAudioDataDidReceiveWithUserID:} </td>
    <td> Occurs when the first audio frame from a remote user is received.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineMediaRightChangeWithAudio:video:} </td>
    <td>Occurs when audio and video permissions are revoked on the server side.</td>
    <td>V4.6.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineVirtualBackgroundSourceEnabled:reason:}  </td>
    <td>Callback that returns the result of enabling the virtual background</td>
    <td>V4.6.10</td>
  </tr>
</table>

<h2 id="Remote media event">Remote media event</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineUserVideoProfileDidUpdate:maxProfile:} </td>
    <td> Occurs when a remote user changes the video resolution type.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineUser:videoMuted:} </td>
    <td> Occurs when a remote user closes the video.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineUser:audioMuted:} </td>
    <td> Occurs when a remote user mutes the audio.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcChannelDelegate#onNERtcChannelUser:subStreamAudioMuted:} </td>
    <td> Occurs when a remote user unpublishes the audio substream.</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineUserAudioDidStart:} </td>
    <td> Occurs when a remote user enables the audio.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcChannelDelegate#onNERtcChannelUserSubStreamAudioDidStart:} </td>
    <td> Occurs when a remote user publishes the audio substream.</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineUserAudioDidStop:} </td>
    <td> Occurs when a remote user stops the audio stream.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcChannelDelegate#onNERtcChannelUserSubStreamAudioDidStop:} </td>
    <td> Occurs when a remote user unpublishes the audio substream.</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td>{@link NERtcEngineDelegate#onNERtcEngineUserVideoDidStartWithUserID: videoProfile:}</td>
    <td> Occurs when a remote user enables the video.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineUserVideoDidStop:} </td>
    <td> Occurs when a remote user stops sending the video stream.</td>
    <td>V3.5.0</td>
  </tr>
</table>

<h2 id="Stats event">Stats event</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineMediaStatsObserver#onRtcStats:} </td>
    <td> Occurs when the stats for the current call is collected. The callback is triggered every 2 seconds.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineMediaStatsObserver#onNetworkQuality:} </td>
    <td> Occurs when the stats of uplink and downlink network quality for each user are reported during the call</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineMediaStatsObserver#onLocalAudioStat:} </td>
    <td> Occurs when the stats of the local audio stream are collected.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineMediaStatsObserver#onLocalVideoStat:} </td>
    <td> Occurs when the stats of the local video stream are collected.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineMediaStatsObserver#onRemoteAudioStats:} </td>
    <td> Occurs when the stats of the remote audio stream in the call are collected.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineMediaStatsObserver#onRemoteVideoStats:} </td>
    <td> Occurs when the stats of the video stream in the call are collected.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#addEngineMediaStatsObserver:} </td>
    <td> Adds a media stats observer.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#removeEngineMediaStatsObserver: } </td>
    <td> Deletes the specified media stats observer.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#cleanupEngineMediaStatsObserver} </td>
    <td> Clears the media stats observer.</td>
    <td>V3.5.0</td>
  </tr>
</table>

## Multiple room management

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#createChannel:} </td>
    <td>Creates and gets an NERtcChannel object. Users can join multiple rooms by creating multiple NERtcChannel objects. </td>
    <td>V4.5.0</td>
  </tr>
  <tr>
    <td> INERtcChannel  </td>
    <td>The classes provide methods to implement audio and video calling in a specified room. </td>
    <td>V4.5.0</td>
  </tr>
  <tr>
    <td>NERtcChannelDelegate</td>
    <td>The classes provide callbacks for listening to events and returning data in a specified room. </td>
    <td>V4.5.0</td>
  </tr>
</table>

<h2 id="Screen sharing">Screen sharing</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setupLocalSubStreamVideoCanvas:} </td>
    <td> Sets a playback canvas for local video substream.</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setupRemoteSubStreamVideoCanvas:forUserID:} </td>
    <td> Sets a playback canvas for remote video substream.</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#startScreenCapture:} </td>
    <td> Starts screen sharing.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#stopScreenCapture} </td>
    <td> Stops screen sharing</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setLocalRenderSubStreamScaleMode:}</td>
    <td> Subscribes to or unsubscribes from local video substream from screen sharing. You can receive the video substream data only after you subscribe to the local video substream. </td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setRemoteRenderSubStreamVideoScaleMode:forUserID:}</td>
    <td> Subscribes to or unsubscribes from the remote video substream from screen sharing. You can receive the video substream data only after you subscribe to the remote video substream. </td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#subscribeRemoteSubStreamVideo:forUserID:}</td>
    <td> Subscribes to or unsubscribes from the remote video substream from screen sharing. You can receive the video substream data only after you subscribe to the remote video substream. </td>
    <td>V3.9.0</td>
  </tr>
</table>

<table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineUserSubStreamDidStartWithUserID:subStreamProfile:} </td>
    <td> Occurs when a remote user starts screen sharing through the substream.</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineUserSubStreamDidStop:}  </td>
    <td> Occurs when a remote user stops screen sharing through the substream.</td>
    <td>V3.9.0</td>
  </tr>
</table>

<h2 id="Beauty">Beauty</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link NERtcBeauty#startBeauty} </td>
    <td> Enables the beauty module.</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link NERtcBeauty#stopBeauty} </td>
    <td>Stops the beauty module.</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link NERtcBeauty#isOpenBeauty} </td>
    <td>Pauses or resumes beauty effects</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link NERtcBeauty#setBeautyEffectWithValue} </td>
    <td>Sets a beauty effect.</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link NERtcBeauty#addTempleteWithPath} </td>
    <td>Imports beauty resources or models</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link NERtcBeauty#addBeautyFilter}</td>
    <td>Adds a filter effect</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link NERtcBeauty#removeBeautyFilter}</td>
    <td>Removes a filter</td>
    <td>V4.6.10</td>
  </tr>
</table>

## Network probe testing before calling

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#startLastmileProbeTest:}</td>
    <Td>Performs a probe test before starting a call. </td>
    <td>V4.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#stopLastmileProbeTest}</td>
    <td>Performs a probe test before stopping a call. </td>
    <td>V4.5.0</td>
  </tr>
</table>

<table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineLastmileQuality:} </td>
    <td>Reports the network quality of the current user. </td>
    <td>V4.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineLastmileProbeTestResult:}</td>
    <td>Reports the upstream and downstream network quality of the last mile before starting a call. </td>
    <td>V4.5.0</td>
  </tr>
</table>

<h2 id="Music file playback and mixing">Music file playback and mixing</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td>{@link INERtcEngineEx#startAudioMixingWithOption:}</td>
    <td> Starts to play a music file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#stopAudioMixing} </td>
    <td> Stops playing a music file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td>{@link INERtcEngineEx#pauseAudioMixing}</td>
    <td> Pauses playing a music file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#resumeAudioMixing} </td>
    <td> Resumes playing a music file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setAudioMixingPlaybackVolume:} </td>
    <td> Sets the playback volume of a music file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setAudioMixingSendVolume:} </td>
    <td> Sets the publishing volume of a music file.
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#getAudioMixingPlaybackVolume:} </td>
    <td> Gets the playback volume of a music file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#getAudioMixingSendVolume:} </td>
    <td>Get the publishing volume of a music file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#getAudioMixingDuration:} </td>
    <td> Gets the total duration of a music file</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setAudioMixingPosition:} </td>
    <td> Sets the playback position of a music file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#getAudioMixingCurrentPosition:} </td>
    <td> Gets the current playback position of a music file.</td>
    <td>V3.5.0</td>
  </tr>
</table>

<br>

<table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onAudioMixingStateChanged:errorCode:} </td>
    <td> Occurs when the playback status of a local music file changes.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onAudioMixingTimestampUpdate:} </td>
    <td> Occurs when the timestamp of a music file is updated.</td>
    <td>V3.5.0</td>
  </tr>
</table>

<h2 id="Audio effect file playback management">Audio effect file playback management</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#getEffectPlaybackVolumeWithId:volume:} </td>
    <td> Gets the playback volume of an audio effect file. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setEffectPlaybackVolumeWithId:volume:} </td>
    <td> Sets the playback volume of an audio effect file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#playEffectWitdId:effectOption:} </td>
    <td> Plays back a specified audio effect file</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#stopEffectWitdId:} </td>
    <td> Stops playing a specified audio effect file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td>{@link INERtcEngineEx#stopAllEffects}</td>
    <td> Stops playing all audio effect files.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#pauseEffectWitdId:} </td>
    <td> Pauses the playback of an audio effect file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td>{@link INERtcEngineEx#pauseAllEffects}</td>
    <td> Pauses all audio file playback</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#resumeEffectWitdId:} </td>
    <td> Resumes playing back a specified audio effect file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#resumeAllEffects} </td>
    <td> Resumes playing back all audio effect files.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setEffectSendVolumeWithId:volume:} </td>
    <td> Adjusts the publishing volume of a effect file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#getEffectDurationWithId:duration:} </td>
    <td> Gets the duration of of an audio effect file. </td>
    <td>V4.4.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#getEffectCurrentPositionWithId:position:} </td>
    <td> Gets the playback position of an audio effect file. </td>
    <td>V4.4.0</td>
  </tr>
</table>

<h2 id="Voice change and reverberation">Voice change and reverberation</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setAudioEffectPreset:}</td>
    <td> Sets a voice change effect preset by the SDK. </td>
    <td>4.1.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setVoiceBeautifierPreset:}</td>
    <td> Sets an voice beautifier effect preset by the SDK. </td>
    <td>4.0.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setLocalVoiceEqualizationOfBandFrequency:withGain:}</td>
    <td> Sets the local voice equalization effect. You can customize the center frequencies of the local voice effects. </td>
    <td>4.0.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setLocalVoicePitch:}</td>
    <td> Sets the voice pitch of a local voice. </td>
    <td>4.1.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setLocalVoiceReverbParam:}</td>
    <td>Enables the local reverb effect. </td>
    <td>4.6.10</td>
  </tr>
</table>


<h2 id="CDN relayed streaming">CDN relayed streaming</h2>

Note: This methods are applicable only to Interactive Live Streaming v2.0.

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#addLiveStreamTask:compeltion:} </td>
    <td> Adds a streaming task in a room.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#updateLiveStreamTask:compeltion:} </td>
    <td> Updates a streaming task in a room.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#removeLiveStreamTask:compeltion:} </td>
    <td> Deletes a streaming task in a room.</td>
    <td>V3.5.0</td>
  </tr>
</table>

<br>

<table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineLiveStreamObserver#onNERTCEngineLiveStreamState:taskID:url:} </td>
    <td>Live streaming status callbacks</td>
    <td>V3.5.0</td>
  </tr>
 </table>

 <h2 id="Supplemental enhancement information">Supplemental enhancement information</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#sendSEIMsg:}</td>
    <td> Sends supplemental enhancement information (SEI) messages through the bigtream. 	</td>
    <td>V4.0.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#sendSEIMsg:streamChannelType:} </td>
    <td> Sends SEI messages. You can use the bigstream or substream to send SEI messages by calling this method. 	</td>
    <td>V4.0.0</td>
  </tr>
</table>

<br>

<table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineVideoSEIObserver#onNERtcEngineRecvSEIMsg:message:}</td>
    <td> Occurs when the message that contains the SEI of the remote stream. </td>
    <td>V4.0.0</td>
  </tr>
</table>

<h2 id="Media stream relay across rooms">Media stream relay across rooms</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#startChannelMediaRelay:} </td>
    <td> Starts to relay media streams across rooms.</td>
    <td>V4.2.1</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#updateChannelMediaRelay:} </td>
    <td> Updates the information about the destination room to which the media stream is relayed. </td>
    <td>V4.2.1</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#stopChannelMediaRelay} </td>
    <td> Stops media stream relay across rooms. </td>
    <td>V4.2.1</td>
  </tr>
</table>

<br>

<table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineChannelMediaRelayStateDidChange:channelName:}</td>
    <td> Occurs when the status of media stream relay changes. </td>
    <td>V4.2.1</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineDidReceiveChannelMediaRelayEvent:channelName:error:}</td>
    <td>  Occurs when events related to media stream relay are triggered. </td>
    <td>V4.2.1</td>
  </tr>
</table>

<h2 id="Volume reminder">Volume reminder</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#enableAudioVolumeIndication:interval:} </td>
    <td> Enables volume indication for the current speaker. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#enableAudioVolumeIndication:interval:vad:} </td>
    <td> Enables volume indication for the current speaker and voice detection. </td>
    <td>V4.6.10</td>
  </tr>
</table>

<br>

<table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td>{@link NERtcEngineDelegateEx#onRemoteAudioVolumeIndication: totalVolume:}</td>
    <td> Occurs when the system indicates the active speaker and the audio volume.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onLocalAudioVolumeIndication:} </td>
    <td> Occurs when the system indicates current local audio volume in the room.
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onLocalAudioVolumeIndication:withVad:} </td>
    <td> Occurs when the system indicates current local audio volume in the room and detects voice activities.</td>
    <td>V4.6.10</td>
  </tr>
</table>


<h2 id="In-ears monitoring">In-ears monitoring</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#enableEarback:volume:} </td>
    <td> enables the in-ear monitoring feature.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td>{@link INERtcEngineEx#setEarbackVolume:}</td>
    <td> Sets the volume for in-ear monitoring.</td>
    <td>V3.5.0</td>
  </tr>
</table>

 

<h2 id="Audio playback routing">Audio playback routing</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setLoudspeakerMode:} </td>
    <td> Enables or disables speakerphone playback.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#getLoudspeakerMode:} </td>
    <td> Gets the status of the speakerphone.</td>
    <td>V3.5.0</td>
  </tr>
</table>

<br>

<table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td>{@link NERtcEngineAudioSessionObserver#onNERtcEngineAudioDeviceRoutingDidChange:} </td>
    <td>Occurs when the audio route changes. </td>
    <td>V3.6.0</td>
  </tr>
</table>

<h2 id="Video dual stream mode">Video dual stream mode</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#enableDualStreamMode:} </td>
    <td> Enables or disables the video dual stream mode. </td>
    <td>V3.5.0</td>
  </tr>
</table>

<h2 id="Audio and video stream fallback">Audio and video stream fallback</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setLocalPublishFallbackOption:} </td>
    <td> Sets the fallback option for the published local video stream for unreliable network conditions. 	</td>
    <td>V4.3.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setRemoteSubscribeFallbackOption:} </td>
    <td> Sets the fallback option for the subscribed remote audio and video stream for unreliable network conditions. 	</td>
    <td>V4.3.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setLocalMediaPriority:preemptive:} </td>
    <td> Sets the priority of local media streams. 	</td>
    <td>V4.2.0</td>
  </tr>
</table>

<br>

<table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td>{@link NERtcEngineDelegateEx#onNERtcEngineLocalPublishFallbackToAudioOnly:streamType:} </td>
    <td> Occurs when the published local media stream falls back to an audio-only stream or switches back to an audio and video stream. </td>
    <td>V4.3.0</td>
  </tr>
  <tr>
    <td>{@link NERtcEngineDelegateEx#onNERtcEngineRemoteSubscribeFallbackToAudioOnly:isFallback:streamType:} </td>
    <td> Occurs when the subscribed remote media stream falls back to an audio-only stream or switches back to an audio and video stream. </td>
    <td>V4.3.0</td>
  </tr>
</table>

 <h2 id="External audio source capture and rendering">External audio source capture and rendering</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setExternalAudioSource:sampleRate:channels:} </td>
    <td> Enables external source for the audio mainstream and sets the capture parameters. </td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setExternalSubStreamAudioSource:sampleRate:channels:} </td>
    <td> Enables external source for the audio substream and sets the capture parameters. </td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#pushExternalAudioFrame:} </td>
    <td> Pushs the audio frame data captured from the external audio source to the internal audio engine.</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#pushExternalSubStreamAudioFrame:} </td>
    <td> Pushes the audio substream data captured from the external audio source to the internal audio engine.</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setExternalAudioRender:sampleRate:channels:} </td>
    <td> Enables or disables the external audio rendering.</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#pullExternalAudioFrame:length:} </td>
    <td> Pulls the audio frame data captured from the external audio source.</td>
    <td>V3.9.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setStreamAlignmentProperty:} </td>
    <td> Syncs the local system time with the server time. </td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#getNtpTimeOffset} </td>
    <td>Gets the difference between the local system time and the server time. </td>
    <td>V4.6.10</td>
  </tr>
</table>

 <h2 id="External video source capture">External video source capture</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setExternalVideoSource:isScreen:} </td>
    <td> Configure external video source.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#pushExternalVideoFrame:} </td>
    <td> Pushes the external video frame data captured from the external video source.</td>
    <td>V3.5.0</td>
  </tr>
</table>

<h2 id="Raw audio data">Raw audio data</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setRecordingAudioFrameParameters:}</td>
    <td> Sets the audio recording format.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setPlaybackAudioFrameParameters:} </td>
    <td> Sets the audio playback format.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setAudioFrameObserver:}</td>
    <td> Registers the audio frame observer.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setMixedAudioFrameParameters:}</td>
    <td> Sets the sample rate of the mixed stream after the audio is captured and playback. You must call this method before you join a room.
    <td>V3.5.0</td>
  </tr>
</table>

<table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineAudioFrameObserver#onNERtcEngineAudioFrameDidRecord:}</td>
    <td> Retrieves the audio data captured. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineAudioFrameObserver#onNERtcEngineAudioFrameWillPlayback:}</td>
    <td> Retrieves the audio playback data. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineAudioFrameObserver#onNERtcEngineMixedAudioFrame:}</td>
    <td> Retrieves the mixed recorded and playback audio frame.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineAudioFrameObserver#onNERtcEnginePlaybackAudioFrameBeforeMixingWithUserID:frame:} </td>
    <td>Returns the raw audio frames of a remote user. <br>To be deprecated. User {@link NERtcEngineAudioFrameObserver#onNERtcEnginePlaybackAudioFrameBeforeMixingWithUserID:frame:channelId:}. </td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td>{@link NERtcEngineAudioFrameObserver#onNERtcEnginePlaybackAudioFrameBeforeMixingWithUserID:frame:channelId:}</td>
    <td>Returns the raw audio frames of a remote user. </td>
    <td>V4.5.0</td>
 </tr>
</table>

 <h2 id="Raw video data">Raw video data</h2>

<table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineVideoFrameObserver#onNERtcEngineVideoFrameCaptured:rotation:}</td>
    <td> Retrieves the video data captured. </td>
    <td>V3.5.0</td>
  </tr>
</table>

 <h2 id="Screenshots">Screenshots</h2>

 <table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#takeLocalSnapshot:callback:}</td>
    <td> Takes a local video snapshot. </td>
    <td>V4.2.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#takeRemoteSnapshot:forUserID:callback:}</td>
    <td> Takes a snapshot of a remote video screen. </td>
    <td>V4.2.0</td>
  </tr>
</table>

 <table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngine#NERtcTakeSnapshotCallback}</td>
    <td> Returns the screenshot result. </td>
    <td>V4.2.0</td>
  </tr>
</table>

 <h2 id="Watermark">Watermark</h2>

 <table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setLocalVideoWatermarkConfigs:withStreamType:}</td>
    <td> Adds a watermark to the local video. </td>
    <td>V4.6.10</td>
  </tr>
</table>

<br>

 <table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineLocalVideoWatermarkStateWithStreamType:state:}</td>
    <td> Returns the watermark result. </td>
    <td>V4.6.10</td>
  </tr>
</table>

<h2 id="Encryption">Encryption</h2>

 <table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td>{@link INERtcEngineEx#enableEncryption:config:}</td>
    <td>  Enables or disables media stream encryption. </td>
    <td>V4.4.0</td>
  </tr>
 </table>

 <h2 id="Client audio recording">Client audio recording</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#startAudioRecording:sampleRate:quality:}</td>
    <td> Starts an audio recording on a client. </td>
    <td>V4.2.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#startAudioRecordingWithConfig:}</td>
    <td> Starts an audio recording on a client. </td>
    <td>V4.6.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#stopAudioRecording}</td>
    <td> Stops an audio recording on the client. </td>
    <td>V4.2.0</td>
  </tr>
</table>


 <table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineAudioRecording:filePath:}</td>
    <td> Returns the audio recording status. </td>
    <td>V4.2.0</td>
  </tr>
</table>

<h2 id="Cloud proxy">Cloud prox</h2>

 <table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td>{@link INERtcEngineEx#setCloudProxy:}</td>
    <td>Enables and sets the cloud proxy service. </td>
    <td>V4.6.0</td>
  </tr>
 </table>

 <h2 id="Device management">Device management</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngine#switchCamera} </td>
    <td> Switches between front and rear cameras.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#switchCameraWithPosition:} </td>
    <td> Specifies the front or rear camera.</td>
    <td>V4.6.10</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#isCameraTorchSupported} </td>
    <td> Checks whether the camera flash is supported.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setCameraZoomFactor:} </td>
    <td> Sets the camera zoom ratio.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td>{@link INERtcEngineEx#setCameraFocusPositionX: Y:}</td>
    <td> Sets the current camera focus position</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setCameraTorchOn:} </td>
    <td> Sets the camera flash function.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#isCameraTorchOn} </td>
    <td> Check whether the camera flash is on.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#maxCameraZoomScale} </td>
    <td> Gets the maximum zoom ratio supported by the camera.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#isCameraZoomSupported} </td>
    <td> Checks whether the camera zoom function is supported.
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#isCameraFocusSupported} </td>
    <td> Checks whether the camera manual focus function is supported.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#isCameraExposurePositionSupported} </td>
    <td> Checks whether the camera exposure function is supported.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setCameraExposurePosition:} </td>
    <td> Sets the camera manual exposure position.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setPlayoutDeviceMute:} </td>
    <td> Mutes or unmutes the audio playback device.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td>{@link INERtcEngineEx#getPlayoutDeviceMute:}</td>
    <td> Gets whether the audio playback device is muted.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#setRecordDeviceMute:} </td>
    <td> Sets the status of the recording device</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#getRecordDeviceMute:} </td>
    <td> Gets whether the audio capture device is muted.</td>
    <td>V3.5.0</td>
  </tr>
</table>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineAudioDeviceStateChangeWithDeviceID:deviceType:deviceState:} </td>
    <td> Occurs when the status of the audio playback device changes.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineVideoDeviceStateChangeWithDeviceID:deviceType:deviceState:} </td>
    <td>Occurs when video devices change</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcEngineHardwareResourceReleased:} </td>
    <td> Occurs when the hardware resources are released.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcCameraFocusChanged:} </td>
    <td> Occurs when the camera focus position changes.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegateEx#onNERtcCameraExposureChanged:} </td>
    <td> Occurs when the camera exposure position changes.</td>
    <td>V3.5.0</td>
  </tr>
</table>

 <h2 id="Troubleshooting">Troubleshooting</h2>

<table>
  <tr>
    <th width= 400><b>Method</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#uploadSdkInfo} </td>
    <td> Uploads the log records collected by the SDK.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td>{@link INERtcEngineEx#startAudioDump}</td>
    <td> Starts recording an audio dump file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#stopAudioDump} </td>
    <td> Stops recording an audio dump file.</td>
    <td>V3.5.0</td>
  </tr>
  <tr>
    <td> {@link INERtcEngineEx#startAudioDumpWithType:} </td>
    <td>Start creating an audio dump file</td>
    <td>V4.6.0</td>
  </tr>
</table>

 <table>
  <tr>
    <th width= 400><b>Event</b></th>
    <th width= 600><b>Description</b></th>
    <th width= 200><b>Supported version</b></th>
  </tr>
  <tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineDidError:} </td>
    <td> Occurs when a runtime error occurred in the engine and manual troubleshooting is required.</td>
    <td>V3.5.0</td>
  </tr><tr>
    <td> {@link NERtcEngineDelegate#onNERtcEngineDidWarning:msg:} </td>
    <td> Occurs when a warnning occurs. </td>
    <td>V4.3.0</td>
  </tr>
</table>

*/

