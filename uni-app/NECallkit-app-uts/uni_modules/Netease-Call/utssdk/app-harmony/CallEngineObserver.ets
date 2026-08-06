import {
  NECallEngineDelegate,
  NECallEndInfo,
  NECallInfo,
  NECallType,
  NECallTypeChangeInfo,
  NEInviteInfo
} from '@yunxin/callkit';
import { NEFloatWindowObserver } from '@yunxin/callkit_ui';

export type HarmonyCallEventSink = (
  eventName: string,
  payloadJson: string,
  callInfo?: NECallInfo
) => void;

export function toInviteEventInfo(info: NEInviteInfo): Record<string, Object> {
  const eventInfo: Record<string, Object> = {
    'callId': info.callId,
    'inviter': info.inviter,
    'inviteList': info.inviteList.slice(),
    'callType': info.callType,
    'callerAccId': info.callerAccId ?? info.inviter,
    'calleeIDList': info.inviteList.slice()
  };
  if (info.groupId !== undefined) {
    eventInfo['groupId'] = info.groupId;
    eventInfo['chatGroupId'] = info.groupId;
  }
  if (info.channelId !== undefined) {
    eventInfo['channelId'] = info.channelId;
  }
  if (info.extraInfo !== undefined) {
    eventInfo['extraInfo'] = info.extraInfo;
  }
  if (info.globalExtra !== undefined) {
    eventInfo['globalExtra'] = info.globalExtra;
  }
  if (info.callScene !== undefined) {
    eventInfo['callScene'] = info.callScene;
  }
  if (info.participantCount !== undefined) {
    eventInfo['participantCount'] = info.participantCount;
  }
  return eventInfo;
}

export function toCallInfoRecord(info: NECallInfo): Record<string, Object> {
  const callerInfo: Record<string, Object> = {
    'userId': info.callerInfo.userId,
    'uid': info.callerInfo.uid.toString()
  };
  const calleeInfo: Record<string, Object> = {
    'userId': info.calleeInfo.userId,
    'uid': info.calleeInfo.uid.toString()
  };
  const signalInfo: Record<string, Object> = {
    'channelName': info.signalInfo.channelName,
    'signalingToken': info.signalInfo.signalingToken,
    'serverAddress': info.signalInfo.serverAddress
  };
  const rtcInfo: Record<string, Object> = {
    'channelId': info.rtcInfo.channelId,
    'token': info.rtcInfo.token,
    'uid': info.rtcInfo.uid.toString(),
    'cid': info.rtcInfo.cid.toString()
  };
  return {
    'callId': info.callId,
    'currentAccId': info.currentAccId,
    'callerInfo': callerInfo,
    'calleeInfo': calleeInfo,
    'callType': info.callType,
    'signalInfo': signalInfo,
    'rtcInfo': rtcInfo,
    'callStatus': info.callStatus
  };
}

export function toCallTypeChangeEventInfo(info: NECallTypeChangeInfo): Record<string, Object> {
  return {
    'callId': info.callId,
    'callType': info.callType,
    'state': info.state
  };
}

export function toCallEndEventInfo(info: NECallEndInfo): Record<string, Object> {
  return {
    'callId': info.callId,
    'reason': info.reason,
    'duration': info.duration,
    'reasonCode': info.reason
  };
}

class HarmonyFloatWindowObserver implements NEFloatWindowObserver {
  private readonly sink: HarmonyCallEventSink;

  constructor(sink: HarmonyCallEventSink) {
    this.sink = sink;
  }

  tapFloatWindow(): void {
    this.sink('onFloatWindowClick', '{}');
  }

  tapIncomingBanner(action: string): void {
    if (action !== 'accept' && action !== 'reject' && action !== 'open') {
      return;
    }
    this.sink('onIncomingBannerClick', JSON.stringify({ 'action': action }));
  }
}

export function createCallEngineDelegate(sink: HarmonyCallEventSink): NECallEngineDelegate {
  return new NECallEngineDelegate({
    onReceiveInvited: (info: NEInviteInfo): void => {
      sink('onCallReceived', JSON.stringify({ 'info': toInviteEventInfo(info) }));
    },
    onCallConnected: (info: NECallInfo): void => {
      sink('onCallConnected', JSON.stringify({ 'info': toCallInfoRecord(info) }), info);
    },
    onCallTypeChange: (info: NECallTypeChangeInfo): void => {
      sink('onCallTypeChange', JSON.stringify({ 'info': toCallTypeChangeEventInfo(info) }));
    },
    onCallEnd: (info: NECallEndInfo): void => {
      sink('onCallEnd', JSON.stringify({ 'info': toCallEndEventInfo(info) }));
    },
    onVideoAvailable: (available: boolean, userID: string): void => {
      sink('onVideoAvailable', JSON.stringify({ 'userId': userID, 'available': available }));
    },
    onVideoMuted: (muted: boolean, userID: string): void => {
      sink('onVideoMuted', JSON.stringify({ 'userId': userID, 'mute': muted }));
    },
    onAudioMuted: (muted: boolean, userID: string): void => {
      sink('onAudioMuted', JSON.stringify({ 'userId': userID, 'mute': muted }));
    },
    onLocalAudioMuted: (muted: boolean): void => {
      sink('onLocalAudioMuted', JSON.stringify({ 'mute': muted }));
    },
    onRtcInitEnd: (): void => {
      sink('onRtcInitEnd', '{}');
    }
  });
}

export function createFloatWindowObserver(sink: HarmonyCallEventSink): NEFloatWindowObserver {
  return new HarmonyFloatWindowObserver(sink);
}

export function emitCallEngineError(
  sink: HarmonyCallEventSink,
  code: number,
  message: string,
  apiName?: string
): void {
  if (apiName === undefined) {
    sink('onError', JSON.stringify({ 'code': code, 'message': message }));
    return;
  }
  sink('onError', JSON.stringify({ 'code': code, 'message': message, 'apiName': apiName }));
}
