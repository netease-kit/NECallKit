import {
  CallStatus,
  CallRole,
  MediaType,
  AudioPlaybackDevice,
} from "../const/index";

export interface ICallStore {
  callStatus: CallStatus;
  callRole: CallRole;
  mediaType: MediaType;
  localUserInfo: string;
  remoteUserInfoList: Array<string>;
  callerUserInfo: string;
  callExtraInfo: string;
  callDuration: string; 
  callTips: string;
  language: string;
  chatGroupID: string;
  translate: Function;
  enableFloatWindow: boolean;
  enableIncomingBanner: boolean;
  isInIncomingBanner: boolean;
  isGroupCall: boolean;
  isLocalMicOpen: boolean;
  isLocalCameraOpen: boolean;
  isEarPhone: boolean;
  currentSpeakerStatus: AudioPlaybackDevice;
  isLocalBlurOpen: boolean;
  currentCameraIsOpen: boolean;
}
